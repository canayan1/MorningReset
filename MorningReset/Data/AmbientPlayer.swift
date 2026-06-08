import Foundation
import AVFoundation

// Continuous, procedurally-generated meditative ambient for the energy
// screens. A soft evolving pad whose chord is tinted to the active path.
// No audio assets. Honors a persisted mute preference. Independent of the
// wake-ritual player; only one should run at a time.

@MainActor
final class AmbientPlayer {

    static let shared = AmbientPlayer()

    private var engine: AVAudioEngine?
    private var node: AVAudioPlayerNode?
    private var buffer: AVAudioPCMBuffer?
    private var currentPath: EnergyPath?
    private(set) var isRunning = false

    private init() {}

    static var isMuted: Bool {
        get { UserDefaults.standard.bool(forKey: UDKey.ambientMuted) }
        set { UserDefaults.standard.set(newValue, forKey: UDKey.ambientMuted) }
    }

    /// Start (or retune) the ambient for a path. Idempotent per path.
    func start(path: EnergyPath?) {
        guard !Self.isMuted else { stop(); return }
        if isRunning && currentPath == path { return }
        if isRunning { stop() }
        currentPath = path
        do {
            try activateSession()
            try buildEngine(path: path)
            playLoop()
            fadeIn()
            isRunning = true
        } catch {
            isRunning = false
        }
    }

    func stop() {
        guard engine != nil else { return }
        node?.stop()
        engine?.stop()
        engine = nil; node = nil; buffer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isRunning = false
    }

    func toggleMute() {
        Self.isMuted.toggle()
        if Self.isMuted { stop() } else { start(path: currentPath) }
    }

    // MARK: - Internals

    private func activateSession() throws {
        let s = AVAudioSession.sharedInstance()
        try s.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try s.setActive(true)
    }

    private func buildEngine(path: EnergyPath?) throws {
        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!
        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        node.volume = 0.0
        try engine.start()
        self.engine = engine
        self.node = node
        self.buffer = Self.makePad(format: format, root: Self.root(for: path), durationSec: 16.0)
    }

    private func playLoop() {
        guard let node, let buffer else { return }
        scheduleLoop(buffer, on: node)
        node.play()
    }

    private func scheduleLoop(_ buf: AVAudioPCMBuffer, on node: AVAudioPlayerNode) {
        node.scheduleBuffer(buf, at: nil, options: []) { [weak self, weak node] in
            Task { @MainActor in
                guard let self, let node, self.isRunning else { return }
                self.scheduleLoop(buf, on: node)
            }
        }
    }

    private func fadeIn() {
        guard let node else { return }
        Task { @MainActor in
            let steps = 30
            for i in 0..<steps {
                guard isRunning else { return }
                node.volume = 0.16 * Float(i + 1) / Float(steps)
                try? await Task.sleep(nanoseconds: 40_000_000)
            }
        }
    }

    private static func root(for path: EnergyPath?) -> Double {
        switch path {
        case .reiki:      return 110.0     // A2 — warm
        case .breathwork: return 146.83    // D3 — airy
        case .qigong:     return 98.0      // G2 — earthy
        case .none:       return 110.0
        }
    }

    /// Long, slowly-evolving pad: root + fifth + octave with two slow LFOs
    /// for amplitude and stereo movement. Loops seamlessly (whole-cycle LFOs).
    private static func makePad(format: AVAudioFormat, root: Double, durationSec: Double) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let frames = AVAudioFrameCount(sr * durationSec)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buf.frameLength = frames
        guard let l = buf.floatChannelData?[0], let r = buf.floatChannelData?[1] else { return buf }

        let f1 = root
        let f2 = root * 1.5      // perfect fifth
        let f3 = root * 2.0      // octave
        let f4 = root * 3.0      // soft upper octave+fifth
        // LFO frequencies chosen as integer cycles over the loop for seamlessness.
        let ampCycles = 2.0, panCycles = 1.0
        let ampLFO = ampCycles / durationSec
        let panLFO = panCycles / durationSec

        for i in 0..<Int(frames) {
            let t = Double(i) / sr
            let amp = 0.6 + 0.4 * sin(2 * .pi * ampLFO * t)
            let s = sin(2 * .pi * f1 * t) * 0.5
                  + sin(2 * .pi * f2 * t) * 0.32
                  + sin(2 * .pi * f3 * t) * 0.22
                  + sin(2 * .pi * f4 * t) * 0.08
            let pan = 0.5 + 0.4 * sin(2 * .pi * panLFO * t)
            let sample = Float(s * amp * 0.4)
            l[i] = sample * Float(pan)
            r[i] = sample * Float(1.0 - pan)
        }
        return buf
    }
}
