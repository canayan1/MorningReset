import AVFoundation
import Combine
import CoreVideo
import Foundation

// MARK: - Pulse reader (on-device)
//
// Reads a pulse from the back camera with the torch on: a fingertip over the
// lens turns the frame into a window onto the blood moving through it.
//
// Nothing is recorded. Each frame is reduced to four numbers and discarded; no
// image is ever written, stored or sent anywhere.
//
// This is a wellness reading, not a medical measurement, and the app says so
// wherever a number is shown.
//
// The analysed series is the frame's mean *red*, and the drift that comes with
// it — breathing, the torch dimming as the phone warms, an exposure step — is
// removed by the filter rather than by dividing red by the other channels. The
// ratios are the tempting choice and both were tried: hue is unusable because a
// torch-lit fingertip sits exactly on its wrap point, where one count between
// green and blue swings it the whole way across the range, and red's share is
// noisy because green and blue are near zero, where a couple of counts of
// sensor noise is a large fraction of the value. Exposure is never locked:
// locking it early is what clips the red channel, and a clipped channel has no
// pulse in it at all.

struct PulseReading: Codable, Equatable, Hashable {
    var bpm: Int
    /// 0…1 — how strongly the trace repeats at that rate.
    var confidence: Double
    var date: Date

    var isTrustworthy: Bool { confidence >= PulseReader.minimumConfidence }
}

final class PulseReader: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    enum Phase: Equatable {
        case idle
        /// Camera running, waiting for a fingertip.
        case waitingForFinger
        case measuring
        case done(PulseReading)
        /// No camera, or permission refused.
        case unavailable
    }

    static let minimumConfidence = 0.45

    /// The window each estimate is made from, and how often one is made.
    private static let windowSeconds = 6.0
    private static let hopSeconds = 0.5
    private static let gridRate = 30.0
    /// Give up rather than hold someone there forever.
    private static let patience = 40.0
    /// Frames thrown away while the sensor and torch come up.
    private static let warmUpFrames = 30

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var progress: Double = 0
    @Published private(set) var liveBPM: Int?
    @Published private(set) var trace: [Double] = []
    /// What to tell the person when something is wrong in a way they can fix.
    /// Empty when there is nothing useful to say.
    @Published private(set) var guidance: String = ""

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "pulse.session")
    private let videoQueue = DispatchQueue(label: "pulse.video")
    private var device: AVCaptureDevice?

    private var times: [Double] = []
    private var reds: [Double] = []
    private var startedAt: Double?
    private var lastEstimateAt: Double = 0
    private var candidates: [Double] = []
    private var frameNumber = 0
    private var finished = false

    // MARK: - Lifecycle

    func start() {
        reset()
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

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.setTorch(on: false)
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    private func reset() {
        finished = false
        times.removeAll(); reds.removeAll(); candidates.removeAll()
        startedAt = nil; lastEstimateAt = 0; frameNumber = 0
        publish {
            self.phase = .waitingForFinger; self.progress = 0
            self.liveBPM = nil; self.trace = []; self.guidance = ""
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

    // MARK: - Camera

    private func configure() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        self.device = device

        session.beginConfiguration()
        guard session.canAddInput(input) else { session.commitConfiguration(); return }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        // Keep every frame: a dropped one is a gap in the trace, and the
        // timestamps are what turn the remaining ones into a rate.
        output.alwaysDiscardsLateVideoFrames = false
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()

        // Choose the format rather than a preset, and set the frame durations
        // last: they are reset by a preset change and by adding an input, so
        // the old ordering quietly threw the thirty-frame lock away.
        if (try? device.lockForConfiguration()) != nil {
            let usable = device.formats.filter { f in
                f.videoSupportedFrameRateRanges.contains { $0.minFrameRate <= 30 && $0.maxFrameRate >= 30 }
            }
            if let smallest = usable.min(by: {
                let a = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
                let b = CMVideoFormatDescriptionGetDimensions($1.formatDescription)
                return Int(a.width) * Int(a.height) < Int(b.width) * Int(b.height)
            }) {
                device.activeFormat = smallest
            }
            if #available(iOS 18.0, *), device.isAutoVideoFrameRateEnabled {
                // Leaving this on hands the frame rate to the system, and then
                // setting a fixed duration throws.
                device.isAutoVideoFrameRateEnabled = false
            }
            let duration = CMTime(value: 1, timescale: 30)
            device.activeVideoMinFrameDuration = duration
            device.activeVideoMaxFrameDuration = duration
            device.unlockForConfiguration()
        }
    }

    /// Full torch. A warm phone can refuse a level it would otherwise give, so
    /// ask for the most available rather than naming a number.
    private func setTorch(on: Bool) {
        guard let device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
        defer { device.unlockForConfiguration() }
        guard on else { device.torchMode = .off; return }
        do {
            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
        } catch {
            device.torchMode = .on   // whatever the system will give
        }
    }

    // MARK: - Frames

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !finished, let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        frameNumber += 1
        // The first second is the sensor and the torch coming up, not a person.
        guard frameNumber > Self.warmUpFrames, let sample = Self.read(buffer) else { return }

        let now = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        guard now.isFinite else { return }

        guard PulseSignal.fingerPresent(sample) else {
            times.removeAll(); reds.removeAll(); candidates.removeAll()
            startedAt = nil
            publish {
                if self.phase != .unavailable { self.phase = .waitingForFinger }
                self.progress = 0; self.liveBPM = nil; self.trace = []; self.guidance = ""
            }
            return
        }

        if startedAt == nil {
            startedAt = now
            publish { self.phase = .measuring }
        }
        times.append(now); reds.append(sample.red)

        // The two things a person can actually do something about.
        let advice: String
        if sample.clipped > 0.05 || sample.red > 0.98 {
            advice = L10n.text(en: "Ease off the pressure a little.",
                               tr: "Basıncı biraz azalt.",
                               es: "Afloja un poco la presión.")
        } else if sample.red < 0.45 {
            advice = L10n.text(en: "Press a little more, and cover the light too.",
                               tr: "Biraz daha bastır, ışığı da kapat.",
                               es: "Presiona un poco más y cubre también la luz.")
        } else {
            advice = ""
        }
        publish { self.guidance = advice }

        let elapsed = now - (startedAt ?? now)
        guard elapsed >= Self.windowSeconds, now - lastEstimateAt >= Self.hopSeconds else {
            if elapsed >= Self.patience { finish(with: nil) }
            return
        }
        lastEstimateAt = now
        analyse(upTo: now, elapsed: elapsed)
    }

    private func analyse(upTo now: Double, elapsed: Double) {
        // Only the last window, on an even grid, filtered forwards and back so
        // the filter adds no phase to the peaks that become the answer.
        let cutoff = now - Self.windowSeconds
        var t: [Double] = [], v: [Double] = []
        for (i, time) in times.enumerated() where time >= cutoff {
            t.append(time); v.append(reds[i])
        }
        let grid = PulseSignal.resample(times: t, values: v, to: Self.gridRate)
        let filtered = PulseSignal.bandpass(grid, sampleRate: Self.gridRate)
        guard !filtered.isEmpty else { return }

        publish { self.trace = Array(filtered.suffix(140)) }

        guard let result = PulseSignal.estimate(filtered, sampleRate: Self.gridRate) else {
            if elapsed >= Self.patience { finish(with: nil) }
            return
        }
        candidates.append(result.bpm)
        publish {
            self.liveBPM = Int(result.bpm.rounded())
            self.progress = min(1, Double(self.candidates.count) / 3.0)
        }

        // A reading is what consecutive windows agree on, not what one window
        // happened to say — band-limited noise clears a single threshold often
        // enough to be worth nothing.
        if let settled = PulseSignal.agreed(candidates) {
            finish(with: PulseReading(bpm: Int(settled.rounded()),
                                      confidence: result.confidence,
                                      date: Date()))
        } else if elapsed >= Self.patience {
            finish(with: nil)
        }
    }

    private func finish(with reading: PulseReading?) {
        guard !finished else { return }
        finished = true
        let value = reading ?? PulseReading(bpm: 0, confidence: 0, date: Date())
        publish { self.progress = 1; self.phase = .done(value) }
        stop()
    }

    private func publish(_ work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }

    // MARK: - Reading a frame

    /// The mean of the middle of the frame.
    ///
    /// Only the centre: at the edges light leaks around the fingertip and the
    /// torch leaves a hot spot, and both move whenever the hand does. Still
    /// thousands of pixels, because the pulse is a fraction of one count and
    /// only the averaging gets below that.
    static func read(_ buffer: CVPixelBuffer) -> PulseSignal.Sample? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }

        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let stride = CVPixelBufferGetBytesPerRow(buffer)
        let pixels = base.assumingMemoryBound(to: UInt8.self)

        let x0 = width * 35 / 100, x1 = width * 65 / 100
        let y0 = height * 35 / 100, y1 = height * 65 / 100
        guard x1 > x0, y1 > y0 else { return nil }

        var rt = 0, gt = 0, bt = 0, n = 0, clipped = 0
        for y in y0..<y1 {
            let row = pixels + y * stride
            for x in Swift.stride(from: x0, to: x1, by: 2) {
                let p = row + x * 4              // BGRA
                bt += Int(p[0]); gt += Int(p[1])
                let r = Int(p[2]); rt += r
                n += 1
                if r >= 250 { clipped += 1 }
            }
        }
        guard n > 0 else { return nil }

        let r = Double(rt) / Double(n) / 255
        let g = Double(gt) / Double(n) / 255
        let b = Double(bt) / Double(n) / 255
        let sum = r + g + b
        return PulseSignal.Sample(
            hue: PulseSignal.hue(r: r, g: g, b: b),
            redShare: sum > 0 ? r / sum : 0,
            red: r,
            clipped: Double(clipped) / Double(n)
        )
    }
}
