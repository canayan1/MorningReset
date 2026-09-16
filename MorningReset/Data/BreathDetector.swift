import AVFoundation
import Combine
import Foundation

// MARK: - Breath detector (on-device)
//
// Listens for the out-breath. An exhale near a phone is a long, soft rush of
// broadband noise — quite unlike a word, a door or a passing car, all of which
// either stop too soon or never rise far enough above the room.
//
// Nothing is recorded. Each buffer is reduced to one loudness number and
// discarded; no audio is written, kept or sent anywhere.
//
// The room decides the threshold, not us: the first seconds establish that
// room's own quiet, and everything after is measured against it. A library and
// a kitchen are different rooms and a fixed number would be wrong in both.

final class BreathDetector: ObservableObject {

    /// Live loudness above the room's floor, 0…1 — what the visual rides on.
    @Published private(set) var level: Double = 0
    /// Completed out-breaths so far.
    @Published private(set) var exhaleCount: Int = 0
    @Published private(set) var isExhaling: Bool = false
    /// False when there is no microphone, or permission was refused.
    @Published private(set) var available = true
    /// True once the room's quiet has been established.
    @Published private(set) var listening = false

    /// Mean length of the out-breaths so far, in seconds. This is what gives a
    /// session its shape: a long slow breather grows a different tree from a
    /// short quick one.
    private(set) var averageExhale: Double = 0

    /// An exhale must last at least this long to count — a cough or a word
    /// stops well before it.
    private static let minimumExhale: TimeInterval = 0.7
    /// And no longer than this, or it is a sustained noise, not a breath.
    private static let maximumExhale: TimeInterval = 12

    private let engine = AVAudioEngine()
    private var floor: Double = 0
    private var floorSamples: [Double] = []
    private var exhaleStart: CFTimeInterval?
    private var exhaleLengths: [Double] = []
    private var lastAbove: CFTimeInterval = 0
    private var running = false

    // MARK: - Lifecycle

    func start() {
        guard !running else { return }
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            begin()
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                guard let self else { return }
                if granted { self.begin() } else { self.publish { self.available = false } }
            }
        default:
            publish { self.available = false }
        }
    }

    func stop() {
        guard running else { return }
        running = false
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        publish { self.listening = false; self.level = 0; self.isExhaling = false }
    }

    private func begin() {
        // Recording and playing at once, mixing with anything else already
        // going. The practice this belongs to runs without an ambient bed, so
        // the only thing the microphone hears is the person.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement,
                                    options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            publish { self.available = false }
            return
        }

        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        guard format.sampleRate > 0 else {
            publish { self.available = false }
            return
        }

        floor = 0
        floorSamples.removeAll()
        exhaleStart = nil
        exhaleLengths.removeAll()

        input.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
            self?.consume(buffer)
        }

        do {
            engine.prepare()
            try engine.start()
            running = true
            publish { self.available = true }
        } catch {
            publish { self.available = false }
        }
    }

    // MARK: - Listening

    private func consume(_ buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return }

        var sum: Float = 0
        for i in 0..<count { sum += channel[i] * channel[i] }
        let rms = Double((sum / Float(count)).squareRoot())
        let now = CACurrentMediaTime()

        // The first two seconds are the room, not the person.
        if floorSamples.count < 60 {
            floorSamples.append(rms)
            if floorSamples.count == 60 {
                let sorted = floorSamples.sorted()
                // The quiet of the room, taken low enough to ignore the odd knock.
                floor = max(sorted[sorted.count / 4], 0.0005)
                publish { self.listening = true }
            }
            return
        }

        // How far above the room this is. The scale is generous: a breath is
        // only a few times the floor, not a hundred.
        let above = max(0, (rms - floor) / (floor * 6))
        let smoothed = min(1, above)
        publish { self.level = self.level * 0.6 + smoothed * 0.4 }

        let breathing = smoothed > 0.35
        if breathing { lastAbove = now }

        if breathing, exhaleStart == nil {
            exhaleStart = now
            publish { self.isExhaling = true }
        } else if let started = exhaleStart {
            // Allow a brief dip — a real breath wavers rather than stopping dead.
            let ended = !breathing && now - lastAbove > 0.25
            let length = now - started
            if ended || length > Self.maximumExhale {
                exhaleStart = nil
                publish { self.isExhaling = false }
                if length >= Self.minimumExhale, length <= Self.maximumExhale {
                    exhaleLengths.append(length)
                    averageExhale = exhaleLengths.reduce(0, +) / Double(exhaleLengths.count)
                    publish { self.exhaleCount = self.exhaleLengths.count }
                }
            }
        }
    }

    private func publish(_ work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
}
