import AVFoundation

// MARK: - The bell, kept low
//
// What happens when someone taps Begin.
//
// The system alarm is loud on purpose and it has done its job the moment
// somebody is awake enough to press a button. Cutting it to silence there is
// abrupt — the morning falls off a cliff — and leaving it at alarm volume
// makes the first thing the app asks of you a shouting match. So the alarm is
// stopped and the same bell comes back underneath at a third of the level,
// quiet enough to talk over, and fades out once the smile has happened.
//
// It is the same recording the alarm rang with, so nothing about the sound
// changes as you cross from the system's screen into the app's — only its
// distance.

final class AlarmChime {
    static let shared = AlarmChime()
    private init() {}

    private var player: AVAudioPlayer?
    private var fade: Timer?

    /// Roughly seventy percent quieter than the alarm — present, not insistent.
    private static let level: Float = 0.3

    func startSoftly() {
        guard player == nil,
              let url = Bundle.main.url(forResource: "inner_light_alarm", withExtension: "caf")
        else { return }

        // Mix rather than interrupt: the guide's voice is the thing being
        // listened to from here on, and it has to sit on top of this.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let p = try? AVAudioPlayer(contentsOf: url) else { return }
        p.numberOfLoops = -1
        p.volume = 0
        p.prepareToPlay()
        p.play()
        player = p
        ramp(to: Self.level, over: 1.2)
    }

    /// Let it go. Called when the smile lands, so the room goes quiet as a
    /// result of something the person did rather than on a timer.
    func fadeOut(over seconds: Double = 2.0) {
        guard player != nil else { return }
        ramp(to: 0, over: seconds) { [weak self] in
            self?.player?.stop()
            self?.player = nil
        }
    }

    func stop() {
        fade?.invalidate(); fade = nil
        player?.stop(); player = nil
    }

    private func ramp(to target: Float, over seconds: Double, then done: (() -> Void)? = nil) {
        fade?.invalidate()
        guard let p = player, seconds > 0 else { player?.volume = target; done?(); return }
        let start = p.volume
        let steps = max(1, Int(seconds / 0.05))
        var step = 0
        fade = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] t in
            step += 1
            let f = Float(step) / Float(steps)
            self?.player?.volume = start + (target - start) * min(1, f)
            if step >= steps {
                t.invalidate()
                self?.fade = nil
                done?()
            }
        }
    }
}
