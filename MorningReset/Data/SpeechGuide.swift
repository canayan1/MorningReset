import Foundation
import AVFoundation
import CryptoKit

// Softly-spoken step guidance during a routine.
//
// Every line the app speaks ships as a recording, because the system voices
// that are actually installed on most devices are the compact ones, and they
// read a slow instruction as a flat machine. A line with no recording — a
// translated string, or copy added after the last render — still falls back to
// the synthesiser rather than going silent.

@MainActor
final class SpeechGuide {

    static let shared = SpeechGuide()

    private let synth = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?

    /// Bumped on every new line, so a duck left over from the previous one
    /// cannot lift the ambient bed in the middle of this one.
    private var token = 0
    /// How long the line now playing will take, at the rate it is played at.
    private(set) var currentLength: Double = 0

    private init() {}

    static var isMuted: Bool {
        get { UserDefaults.standard.bool(forKey: UDKey.voiceMuted) }
        set { UserDefaults.standard.set(newValue, forKey: UDKey.voiceMuted) }
    }

    func speak(_ text: String) {
        guard !Self.isMuted, !text.isEmpty else { return }
        stop()
        token += 1
        if playRecording(of: text) { return }
        synthesise(text)
    }

    /// Says several things, one after another, with silence between them.
    ///
    /// The silence is the point. A guide who has just said "there's no
    /// hurry" and then immediately says the next thing has contradicted
    /// herself; the gap after a line is where the line lands. Returns false
    /// if something newer started speaking part-way through, so a caller
    /// waiting on the last word knows it never came.
    @discardableResult
    func say(_ lines: [String], pause: Double) async -> Bool {
        for (i, line) in lines.enumerated() {
            speak(line)
            let mine = token
            let gap = i < lines.count - 1 ? pause : 0
            try? await Task.sleep(nanoseconds: UInt64((currentLength + gap) * 1_000_000_000))
            guard mine == token else { return false }
        }
        return true
    }

    // MARK: - Recorded voice

    /// Clips are named for the SHA-256 of the line they speak, so finding one is
    /// a hash of the string about to be spoken rather than an index that has to
    /// be kept in step with the copy.
    static func clipName(for text: String) -> String {
        let hex = SHA256.hash(data: Data(text.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return String(hex.prefix(16))
    }

    private func playRecording(of text: String) -> Bool {
        let name = Self.clipName(for: text)
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a", subdirectory: "Voice")
                ?? Bundle.main.url(forResource: name, withExtension: "m4a") else { return false }

        // The ambient bed may not have claimed the session yet, and the voice
        // has to sit alongside it rather than interrupt it.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let p = try? AVAudioPlayer(contentsOf: url) else { return false }
        // Slower than recorded. The clips were rendered at 0.78 of Kokoro's
        // natural pace and that is still brisk for someone who has been awake
        // for ninety seconds and is being asked to follow along rather than
        // read. Rate-shifting keeps the pitch, so it is the same voice taking
        // its time, not a tape slowed down.
        p.enableRate = true
        p.rate = 0.8
        p.volume = 0.85
        p.prepareToPlay()
        p.play()
        player = p

        // At 0.8 the clip takes a quarter longer than its file says.
        currentLength = p.duration / Double(p.rate)
        AmbientPlayer.shared.duck(true)
        unduck(after: currentLength + 0.3)
        return true
    }

    // MARK: - Fallback

    /// Speaks a line one sentence at a time.
    ///
    /// A single utterance runs the whole line together at a flat pace, which is
    /// most of what makes system speech sound mechanical. Breaking on sentence
    /// boundaries and leaving a real gap between them is closer to how someone
    /// guiding a practice actually talks.
    private func synthesise(_ text: String) {
        let sentences = Self.sentences(in: text)
        guard !sentences.isEmpty else { return }

        AmbientPlayer.shared.duck(true)
        var spoken = 0.0
        for (i, sentence) in sentences.enumerated() {
            let u = AVSpeechUtterance(string: sentence)
            u.voice = voice
            u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.66   // unhurried, matched to the clips
            u.pitchMultiplier = 0.95                             // a touch lower
            u.volume = 0.52                                      // quiet over the bed
            u.preUtteranceDelay = i == 0 ? 0.25 : 0
            u.postUtteranceDelay = i == sentences.count - 1 ? 0 : 0.55
            synth.speak(u)
            spoken += Double(sentence.count) / 11.0 + 0.55
        }
        currentLength = max(2.0, spoken)
        unduck(after: currentLength)
    }

    /// Preferred calm female voices, best first. Falls back to any female en voice.
    private static let preferred = [
        "com.apple.voice.premium.en-US.Ava",
        "com.apple.voice.enhanced.en-US.Ava",
        "com.apple.voice.enhanced.en-US.Samantha",
        "com.apple.voice.enhanced.en-US.Allison",
        "com.apple.ttsbundle.siri_female_en-US_compact",
        "com.apple.voice.compact.en-US.Samantha"
    ]

    private lazy var voice: AVSpeechSynthesisVoice? = {
        let all = AVSpeechSynthesisVoice.speechVoices()
        for id in Self.preferred {
            if let v = all.first(where: { $0.identifier == id }) { return v }
        }
        let english = all.filter { $0.language.hasPrefix("en") }
        if let v = english.first(where: { $0.gender == .female && $0.quality != .default }) { return v }
        if let v = english.first(where: { $0.gender == .female }) { return v }
        return AVSpeechSynthesisVoice(language: "en-US")
    }()

    /// Splits on sentence endings, keeping the punctuation so the synthesiser
    /// still hears the difference between a statement and a question.
    private static func sentences(in text: String) -> [String] {
        var out: [String] = []
        var current = ""
        for ch in text {
            current.append(ch)
            if ch == "." || ch == "?" || ch == "!" {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count > 1 { out.append(trimmed) }
                current = ""
            }
        }
        let tail = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if tail.count > 1 { out.append(tail) }
        return out.isEmpty ? [text] : out
    }

    // MARK: - Shared

    private func unduck(after seconds: Double) {
        let mine = token
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard mine == token else { return }   // a newer line is speaking
            AmbientPlayer.shared.duck(false)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        AmbientPlayer.shared.duck(false)
    }

    func toggleMute() {
        Self.isMuted.toggle()
        if Self.isMuted { stop() }
    }
}
