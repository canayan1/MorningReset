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
    /// Kept alongside red: at full torch the red channel often saturates
    /// against a fingertip, and then green is the one still moving.
    private var greenSamples: [Double] = []
    private var startedAt: CFTimeInterval?
    private var fingerSince: CFTimeInterval?
    private var exposureLocked = false
    private var finished = false

    // MARK: - Lifecycle

    func start() {
        finished = false
        samples.removeAll()
        greenSamples.removeAll()
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
            // Full power. A quarter of it looked kinder on paper and simply did
            // not put enough light through a fingertip to see blood move.
            try? device.setTorchModeOn(level: 1.0)
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
        // A lens hunting for focus on a fingertip changes the frame as much as
        // a heartbeat does.
        if device.isFocusModeSupported(.locked) { device.focusMode = .locked }
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

        // A fingertip over a lit lens reads as a red frame. How red and how
        // bright varies enormously with skin and with how hard it is pressed,
        // so the test is the ratio rather than an absolute level.
        let covered = red > 0.22 && red > green * 1.45
        guard covered else {
            fingerSince = nil
            startedAt = nil
            samples.removeAll()
            greenSamples.removeAll()
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
        greenSamples.append(green)
        let elapsed = now - (startedAt ?? now)
        let detrended = Self.strongerTrace(red: samples, green: greenSamples)

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

    /// Whichever channel is actually moving.
    ///
    /// At full torch the red channel often pins against the top of its range on
    /// a fingertip and stops carrying anything; green keeps its swing. Rather
    /// than guessing which happens on a given phone and a given hand, both are
    /// detrended and the one with more energy wins.
    static func strongerTrace(red: [Double], green: [Double]) -> [Double] {
        let r = detrend(red)
        let g = detrend(green)
        func energy(_ x: [Double]) -> Double {
            guard !x.isEmpty else { return 0 }
            return x.reduce(0) { $0 + $1 * $1 } / Double(x.count)
        }
        return energy(g) > energy(r) * 1.2 ? g : r
    }

    /// Finds the beat by asking how well the trace lines up with itself.
    ///
    /// Counting peaks is the obvious way and it is what this did first; it is
    /// also fragile, because a fingertip trace is full of small bumps that look
    /// like peaks and a single missed or doubled one throws the whole estimate.
    /// Autocorrelation asks a steadier question — at what shift does this
    /// signal most resemble itself — and answers it with a number between 0 and
    /// 1 that is a fair measure of how sure we should be.
    static func estimate(_ signal: [Double], sampleRate: Double) -> (bpm: Double, confidence: Double)? {
        guard signal.count > Int(sampleRate * 5) else { return nil }

        let mean = signal.reduce(0, +) / Double(signal.count)
        let x = signal.map { $0 - mean }
        guard x.contains(where: { abs($0) > 1e-9 }) else { return nil }   // flat: no finger

        let minLag = Int(sampleRate * 60 / 180)   // 180 bpm
        let maxLag = Int(sampleRate * 60 / 40)    //  40 bpm
        guard maxLag < x.count / 2 else { return nil }

        func correlation(at lag: Int) -> Double {
            let n = x.count - lag
            guard n > 0 else { return 0 }
            var num = 0.0, a = 0.0, b = 0.0
            for i in 0..<n {
                num += x[i] * x[i + lag]
                a += x[i] * x[i]
                b += x[i + lag] * x[i + lag]
            }
            let denom = (a * b).squareRoot()
            return denom > 0 ? num / denom : 0
        }

        var scores: [Int: Double] = [:]
        var best = (lag: 0, score: -1.0)
        for lag in minLag...maxLag {
            let c = correlation(at: lag)
            scores[lag] = c
            if c > best.score { best = (lag, c) }
        }
        guard best.lag > 0, best.score > 0.30 else { return nil }

        // A signal also resembles itself at twice or three times its period, so
        // the strongest match can be a whole beat too slow. Look specifically
        // where a genuine subharmonic would be — near half and a third of the
        // winning lag — rather than at any shorter lag that happens to score
        // nearly as well, which is most of them, since the curve is smooth
        // around its peak and taking the shortest of those reads every pulse
        // about five percent fast.
        var lag = best.lag
        for divisor in [2, 3] {
            let candidate = Int((Double(best.lag) / Double(divisor)).rounded())
            guard candidate >= minLag else { continue }
            let slack = max(1, candidate / 10)
            let low = max(minLag, candidate - slack), high = min(maxLag, candidate + slack)
            guard low <= high else { continue }
            guard let local = (low...high).max(by: { (scores[$0] ?? 0) < (scores[$1] ?? 0) }),
                  let score = scores[local], score >= best.score * 0.85 else { continue }
            lag = local
            break
        }

        // Place the lag between whole frames: at 30fps the gap between two of
        // them is several bpm at a running heart rate.
        var refined = Double(lag)
        if lag > minLag, lag < maxLag,
           let a = scores[lag - 1], let b = scores[lag], let c = scores[lag + 1] {
            let curve = a - 2 * b + c
            if abs(curve) > 1e-12 {
                refined += max(-0.5, min(0.5, 0.5 * (a - c) / curve))
            }
        }

        let bpm = 60 * sampleRate / refined
        guard bpm > 40, bpm < 180 else { return nil }
        return (bpm, min(1, max(0, best.score)))
    }
}
