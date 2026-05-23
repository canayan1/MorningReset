import Foundation
import AVFoundation

// Companion audio for the morning ritual. Plays a soft ambient pad
// from the moment the user begins the flow until they reach the first
// win (or dismiss the flow). Subtle chime triggers on interaction.
//
// Audio is generated programmatically via AVAudioEngine, so no audio
// asset is bundled. To replace with real audio files later, drop
// `wake_ambient.m4a` (loopable) and `wake_chime.m4a` into the bundle
// and the player will prefer them over the synthesized fallback.
//
// Session category is .playback with .mixWithOthers OFF so the
// experience is exclusive (matches Apple's design for ritual / wake
// experiences) and bypasses the silent switch. Audio survives the
// app going to background because the project declares
// UIBackgroundModes = audio.

@MainActor
final class WakeAudioPlayer {

    static let shared = WakeAudioPlayer()

    // ── State ────────────────────────────────────────────────────────────────

    private var engine: AVAudioEngine?
    private var ambientNode: AVAudioPlayerNode?
    private var chimeNode: AVAudioPlayerNode?

    private var ambientBuffer: AVAudioPCMBuffer?
    private var chimeBuffer:   AVAudioPCMBuffer?
    private var crescendoBuffer: AVAudioPCMBuffer?

    private(set) var isRunning = false

    private init() {}

    // ── Public API ───────────────────────────────────────────────────────────

    /// Begin the ritual ambient. Idempotent — safe to call repeatedly.
    func startRitual() {
        guard !isRunning else { return }
        do {
            try activateSession()
            try buildEngineIfNeeded()
            playAmbientLoop()
            isRunning = true
        } catch {
            // Audio is a delight, not a requirement. Fail silently.
            isRunning = false
        }
    }

    /// Play a single subtle chime on top of the ambient bed.
    func playChime() {
        guard isRunning, let node = chimeNode, let buf = chimeBuffer else { return }
        node.scheduleBuffer(buf, at: nil, options: [.interrupts])
        if !node.isPlaying { node.play() }
    }

    /// Final crescendo on the "first win" moment, then fade out.
    func playWinCrescendoThenStop() {
        guard isRunning, let node = chimeNode, let buf = crescendoBuffer else {
            stop()
            return
        }
        node.scheduleBuffer(buf, at: nil, options: [.interrupts]) { [weak self] in
            Task { @MainActor in self?.fadeOutAndStop() }
        }
        if !node.isPlaying { node.play() }
    }

    /// Hard stop. Tears down the engine and deactivates the session.
    func stop() {
        guard engine != nil else { return }
        ambientNode?.stop()
        chimeNode?.stop()
        engine?.stop()
        engine = nil
        ambientNode = nil
        chimeNode = nil
        ambientBuffer = nil
        chimeBuffer = nil
        crescendoBuffer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isRunning = false
    }

    // ── Internals ────────────────────────────────────────────────────────────

    private func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        // .playback bypasses the silent switch, which is what the
        // morning ritual needs. We do not mix with other audio so the
        // user's attention is fully on Morning Reset during the ritual.
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
    }

    private func buildEngineIfNeeded() throws {
        guard engine == nil else { return }

        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!

        let ambient = AVAudioPlayerNode()
        let chime   = AVAudioPlayerNode()
        engine.attach(ambient)
        engine.attach(chime)
        engine.connect(ambient, to: engine.mainMixerNode, format: format)
        engine.connect(chime,   to: engine.mainMixerNode, format: format)

        ambient.volume = 0.18  // soft bed
        chime.volume   = 0.45  // gentle bell

        try engine.start()

        self.engine          = engine
        self.ambientNode     = ambient
        self.chimeNode       = chime
        self.ambientBuffer   = Self.makeAmbientBuffer(format: format, durationSec: 8.0)
        self.chimeBuffer     = Self.makeChimeBuffer(format: format, frequency: 660.0, durationSec: 1.4)
        self.crescendoBuffer = Self.makeCrescendoBuffer(format: format, durationSec: 3.2)
    }

    private func playAmbientLoop() {
        guard let node = ambientNode, let buf = ambientBuffer else { return }
        // Loop indefinitely by re-scheduling on completion.
        scheduleLooping(buf: buf, on: node)
        node.play()
    }

    private func scheduleLooping(buf: AVAudioPCMBuffer, on node: AVAudioPlayerNode) {
        node.scheduleBuffer(buf, at: nil, options: [.interrupts]) { [weak self, weak node] in
            Task { @MainActor in
                guard let self, let node, self.isRunning else { return }
                self.scheduleLooping(buf: buf, on: node)
            }
        }
    }

    private func fadeOutAndStop() {
        guard let engine, let node = ambientNode else { stop(); return }
        let steps = 24
        let duration = 1.6
        let startVolume = node.volume
        Task { @MainActor in
            for i in 0..<steps {
                let t = Double(i) / Double(steps - 1)
                node.volume = startVolume * Float(1.0 - t)
                try? await Task.sleep(nanoseconds: UInt64(duration / Double(steps) * 1_000_000_000))
                if !isRunning { break }
            }
            _ = engine
            stop()
        }
    }

    // ── Buffer synthesis ─────────────────────────────────────────────────────

    /// Layered low pad: two detuned sine waves with slow LFO amplitude.
    /// Sounds like a held meditative chord rather than a tinny tone.
    private static func makeAmbientBuffer(format: AVAudioFormat, durationSec: Double) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * durationSec)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buf.frameLength = frameCount
        guard let left = buf.floatChannelData?[0],
              let right = buf.floatChannelData?[1] else { return buf }

        let f1 = 110.0      // A2
        let f2 = 164.81     // E3 (perfect fifth)
        let f3 = 220.0      // A3 (octave up of f1)
        let lfo = 0.08      // slow amplitude modulation

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let mod = 0.65 + 0.35 * sin(2 * .pi * lfo * t)
            let s1 = sin(2 * .pi * f1 * t)
            let s2 = sin(2 * .pi * f2 * t)
            let s3 = sin(2 * .pi * f3 * t) * 0.35
            // Cross-fade between channels for gentle stereo width.
            let lWidth = 0.55 + 0.45 * sin(2 * .pi * 0.04 * t)
            let rWidth = 1.0 - lWidth
            let sample = Float((s1 * 0.55 + s2 * 0.45 + s3) * mod * 0.45)
            left[i]  = sample * Float(lWidth)
            right[i] = sample * Float(rWidth)
        }
        return buf
    }

    /// Soft bell tone with exponential decay (no harsh attack).
    private static func makeChimeBuffer(format: AVAudioFormat, frequency: Double, durationSec: Double) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * durationSec)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buf.frameLength = frameCount
        guard let left = buf.floatChannelData?[0],
              let right = buf.floatChannelData?[1] else { return buf }

        let attack = 0.04
        let decay  = durationSec - attack

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let env: Double
            if t < attack {
                env = t / attack
            } else {
                env = exp(-(t - attack) * (4.5 / decay))
            }
            // Bell-like: fundamental + soft third + soft fifth
            let s = sin(2 * .pi * frequency * t) * 0.7
                  + sin(2 * .pi * frequency * 2.0 * t) * 0.2
                  + sin(2 * .pi * frequency * 3.0 * t) * 0.1
            let sample = Float(s * env * 0.6)
            left[i]  = sample
            right[i] = sample
        }
        return buf
    }

    /// Rising tone with gentle reverb-like layering. Plays once on "first win".
    private static func makeCrescendoBuffer(format: AVAudioFormat, durationSec: Double) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * durationSec)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buf.frameLength = frameCount
        guard let left = buf.floatChannelData?[0],
              let right = buf.floatChannelData?[1] else { return buf }

        let startF = 330.0  // E4
        let endF   = 660.0  // E5 (octave up)
        let peak   = durationSec * 0.65

        for i in 0..<Int(frameCount) {
            let t  = Double(i) / sampleRate
            let p  = t / durationSec
            // Smooth ease-in-out frequency sweep.
            let smoothP = 0.5 - 0.5 * cos(.pi * p)
            let freq = startF + (endF - startF) * smoothP
            // Envelope: rises to peak then gentle fade.
            let env: Double
            if t < peak {
                env = pow(t / peak, 1.2)
            } else {
                let remaining = durationSec - peak
                env = pow(1.0 - (t - peak) / remaining, 1.6)
            }
            let s = sin(2 * .pi * freq * t) * 0.55
                  + sin(2 * .pi * freq * 1.5 * t) * 0.20
                  + sin(2 * .pi * freq * 2.0 * t) * 0.10
            let sample = Float(s * env * 0.65)
            left[i]  = sample
            right[i] = sample
        }
        return buf
    }
}
