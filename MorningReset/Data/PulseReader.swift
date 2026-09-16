import AVFoundation
import Combine
import CoreVideo
import Foundation

// MARK: - Pulse reader (on-device)
//
// Reads a pulse from the back camera with the torch on: a fingertip over the
// lens turns the frame into a window onto the blood moving through it, and the
// red channel brightens and dims once per beat. We average the red channel per
// frame, detrend it, and time the peaks.
//
// Nothing is recorded. Frames are reduced to a single number each and thrown
// away; no image is ever written, stored or sent anywhere.
//
// This is a wellness reading, not a medical measurement, and the app says so
// wherever a number is shown. Two things make or break it and both are handled
// below: the exposure must be locked (auto-exposure would compensate for the
// very brightness changes we are trying to see) and the torch must be dim
// enough to sit against at seven in the morning.

struct PulseReading: Codable, Equatable, Hashable {
    var bpm: Int
    /// 0…1 — how regular the beats were. Below `PulseReader.minimumConfidence`
    /// the reading is not worth showing.
    var confidence: Double
    var date: Date

    var isTrustworthy: Bool { confidence >= PulseReader.minimumConfidence }
}

final class PulseReader: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    enum Phase: Equatable {
        case idle
        /// Camera is running, waiting for a fingertip to cover the lens.
        case waitingForFinger
        /// Counting beats.
        case measuring
        case done(PulseReading)
        /// No camera, no torch, or permission refused.
        case unavailable
    }

    static let minimumConfidence = 0.45

    /// Long enough for a steady estimate, short enough to sit through.
    private static let fullWindow: TimeInterval = 20
    /// Once this much has been counted, a confident reading may finish early.
    private static let earliestFinish: TimeInterval = 12
    private static let sampleRate: Double = 30

    @Published private(set) var phase: Phase = .idle
    /// 0…1 through the measurement window.
    @Published private(set) var progress: Double = 0
    /// Live beats per minute while measuring — for the number on screen.
    @Published private(set) var liveBPM: Int?
    /// Recent detrended samples, normalised to -1…1, for drawing the trace.
    @Published private(set) var trace: [Double] = []

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "pulse.session")
    private let videoQueue = DispatchQueue(label: "pulse.video")
    private var device: AVCaptureDevice?

    private var samples: [Double] = []
    private var startedAt: CFTimeInterval?
    private var fingerSince: CFTimeInterval?
    private var exposureLocked = false
    private var finished = false

    // MARK: - Lifecycle

    func start() {
        finished = false
        samples.removeAll()
        startedAt = nil
        fingerSince = nil
        exposureLocked = false
        publish { self.phase = .waitingForFinger; self.progress = 0; self.liveBPM = nil; self.trace = [] }

        // Ask the first time; after a refusal say so plainly rather than
        // running a camera that will never deliver a frame.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            beginSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted { self.beginSession() } else { self.publish { self.phase = .unavailable } }
            }
        default:
            publish { self.phase = .unavailable }
        }
    }

    private func beginSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.inputs.isEmpty { self.configure() }
            guard !self.session.inputs.isEmpty else {
                self.publish { self.phase = .unavailable }
                return
            }
            if !self.session.isRunning { self.session.startRunning() }
            self.setTorch(on: true)
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.setTorch(on: false)
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    // MARK: - Camera

    private func configure() {
        session.beginConfiguration()
        // The smallest preset there is: we only ever need the average of a
        // frame, and a small frame is far cheaper to average.
        session.sessionPreset = .low

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        self.device = device
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }

        // A fixed frame rate keeps the timing of the peaks honest.
        if let _ = try? device.lockForConfiguration() {
            let duration = CMTime(value: 1, timescale: CMTimeScale(Self.sampleRate))
            if device.activeVideoMinFrameDuration < duration { device.activeVideoMinFrameDuration = duration }
            device.activeVideoMaxFrameDuration = duration
            device.unlockForConfiguration()
        }
        session.commitConfiguration()
    }

    private func setTorch(on: Bool) {
        guard let device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
        if on {
            // A quarter of full power is plenty through a fingertip, and it is
            // not something to point at a face at dawn.
            try? device.setTorchModeOn(level: 0.25)
        } else {
            device.torchMode = .off
        }
        device.unlockForConfiguration()
    }

    /// Auto-exposure would iron out the very fluctuation we are measuring, so
    /// it is locked once the finger has had a moment to settle.
    private func lockExposure() {
        guard let device, !exposureLocked, (try? device.lockForConfiguration()) != nil else { return }
        if device.isExposureModeSupported(.locked) { device.exposureMode = .locked }
        if device.isWhiteBalanceModeSupported(.locked) { device.whiteBalanceMode = .locked }
        device.unlockForConfiguration()
        exposureLocked = true
    }

    // MARK: - Frames

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !finished, let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let (red, green) = Self.channelMeans(buffer) else { return }

        let now = CACurrentMediaTime()

        // A fingertip over a lit lens reads as an almost pure red frame. Open
        // air, a pocket or a face does not.
        let covered = red > 0.40 && (red - green) > 0.14
        guard covered else {
            fingerSince = nil
            startedAt = nil
            samples.removeAll()
            publish { if self.phase != .unavailable { self.phase = .waitingForFinger }
                      self.progress = 0; self.liveBPM = nil; self.trace = [] }
            return
        }

        if fingerSince == nil { fingerSince = now }
        // Give the sensor a second on the finger, then lock and start counting.
        guard now - (fingerSince ?? now) > 1.0 else { return }
        lockExposure()
        if startedAt == nil {
            startedAt = now
            publish { self.phase = .measuring }
        }

        samples.append(red)
        let elapsed = now - (startedAt ?? now)
        let detrended = Self.detrend(samples)

        publish {
            self.progress = min(1, elapsed / Self.fullWindow)
            self.trace = Array(detrended.suffix(140))
        }

        // Only bother analysing a few times a second.
        if samples.count % 10 == 0, elapsed > 5 {
            let result = Self.estimate(detrended, sampleRate: Self.sampleRate)
            publish { self.liveBPM = result.map { Int($0.bpm.rounded()) } }

            let enough = elapsed >= Self.fullWindow
                || (elapsed >= Self.earliestFinish && (result?.confidence ?? 0) >= 0.8)
            if enough, let result {
                finished = true
                let reading = PulseReading(bpm: Int(result.bpm.rounded()),
                                           confidence: result.confidence,
                                           date: Date())
                publish { self.progress = 1; self.phase = .done(reading) }
                stop()
            } else if elapsed >= Self.fullWindow {
                // The window ran out without a usable rhythm: say so rather
                // than inventing a number.
                finished = true
                publish { self.progress = 1
                          self.phase = .done(PulseReading(bpm: 0, confidence: 0, date: Date())) }
                stop()
            }
        }
    }

    private func publish(_ work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }

    // MARK: - Signal

    /// Mean red and green of a frame, 0…1. Sampled on a coarse grid — the
    /// average of a tenth of the pixels is the same average.
    private static func channelMeans(_ buffer: CVPixelBuffer) -> (red: Double, green: Double)? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }

        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let stride = CVPixelBufferGetBytesPerRow(buffer)
        let pixels = base.assumingMemoryBound(to: UInt8.self)

        var redTotal = 0, greenTotal = 0, count = 0
        let step = 4   // every fourth pixel, every fourth row
        for y in Swift.stride(from: 0, to: height, by: step) {
            let row = pixels + y * stride
            for x in Swift.stride(from: 0, to: width, by: step) {
                let p = row + x * 4          // BGRA
                greenTotal += Int(p[1])
                redTotal += Int(p[2])
                count += 1
            }
        }
        guard count > 0 else { return nil }
        return (Double(redTotal) / Double(count) / 255.0,
                Double(greenTotal) / Double(count) / 255.0)
    }

    /// Subtract a moving average to remove the slow drift of a finger settling,
    /// leaving the beat itself.
    private static func detrend(_ input: [Double]) -> [Double] {
        let window = Int(sampleRate * 0.75)
        guard input.count > window else { return [] }
        var out: [Double] = []
        out.reserveCapacity(input.count - window)
        var running = input.prefix(window).reduce(0, +)
        for i in window..<input.count {
            running += input[i] - input[i - window]
            out.append(input[i] - running / Double(window))
        }
        return Self.smooth(out, window: Int(sampleRate * 0.12))
    }

    private static func smooth(_ input: [Double], window: Int) -> [Double] {
        guard window > 1, input.count > window else { return input }
        var out: [Double] = []
        out.reserveCapacity(input.count)
        var running = 0.0
        for (i, v) in input.enumerated() {
            running += v
            if i >= window { running -= input[i - window] }
            out.append(running / Double(Swift.min(i + 1, window)))
        }
        return out
    }

    /// Peak-to-peak timing. Returns nil when the trace has no rhythm worth
    /// trusting — which is the honest answer for a shaking hand.
    static func estimate(_ signal: [Double], sampleRate: Double) -> (bpm: Double, confidence: Double)? {
        guard signal.count > Int(sampleRate * 4) else { return nil }

        let amplitude = (signal.max() ?? 0) - (signal.min() ?? 0)
        guard amplitude > 0.0006 else { return nil }   // flat: no finger, or no blood moving
        let threshold = amplitude * 0.30
        let refractory = Int(sampleRate * 0.33)        // 180 bpm ceiling

        var peaks: [Int] = []
        var i = 1
        while i < signal.count - 1 {
            if signal[i] > threshold, signal[i] >= signal[i - 1], signal[i] > signal[i + 1] {
                if let last = peaks.last, i - last < refractory {
                    if signal[i] > signal[last] { peaks[peaks.count - 1] = i }
                } else {
                    peaks.append(i)
                }
            }
            i += 1
        }
        guard peaks.count >= 5 else { return nil }

        // A peak rarely lands on a whole frame. At 30fps the gap between two
        // whole frames is about 4bpm up at a running heart rate, so the peak is
        // placed between frames by fitting a parabola through its neighbours.
        let refined: [Double] = peaks.map { i in
            guard i > 0, i < signal.count - 1 else { return Double(i) }
            let (a, b, c) = (signal[i - 1], signal[i], signal[i + 1])
            let curve = a - 2 * b + c
            guard abs(curve) > 1e-12 else { return Double(i) }
            return Double(i) + max(-0.5, min(0.5, 0.5 * (a - c) / curve))
        }

        let intervals = zip(refined.dropFirst(), refined).map { ($0 - $1) / sampleRate }
        let sorted = intervals.sorted()
        let median = sorted[sorted.count / 2]
        guard median > 0.33, median < 1.5 else { return nil }   // 40–180 bpm

        // Confidence is how closely the beats agree with each other. Below a
        // floor there is no reading — a number nobody should trust is worse
        // than no number, so it is never returned in the first place.
        let spread = intervals.map { abs($0 - median) / median }.reduce(0, +) / Double(intervals.count)
        let confidence = max(0, min(1, 1 - spread * 3.2))
        guard confidence >= 0.25 else { return nil }
        return (60.0 / median, confidence)
    }
}
