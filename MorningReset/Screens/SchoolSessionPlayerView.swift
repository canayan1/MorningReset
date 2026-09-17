import SwiftUI
import StoreKit

// Guided routine player: walks the authored steps on a calm timer, surfaces the
// safety note up front when the routine has one, and records a completion.

struct RoutinePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    let school: SchoolContent
    let routine: Routine
    var onComplete: () -> Void = {}
    /// Take a pulse before and after. Only worth it on the short practices,
    /// where the pair is close enough together to mean something.
    var measuresPulse: Bool = false

    @State private var total: Int
    @State private var remaining: Int
    @State private var stepIndex = 0
    @State private var running = true
    @State private var finished = false
    @State private var showSafety = false
    @State private var pulse = false
    @State private var ticker: Timer?
    @State private var orbTotal = 0
    @State private var voiceMuted = SpeechGuide.isMuted
    @State private var spokenCues: Set<String> = []
    @State private var cueIndex = 0
    @State private var fedOrb = true
    @State private var started = false
    @State private var session: PracticeSession?
    /// Between steps, the practice stops and says something. Nothing here is a
    /// gate — the only reason to pause is that arriving somewhere is worth
    /// noticing, and a practice that never stops to say so is just a list.
    @State private var resting = false
    @State private var restLine = ""
    @State private var restsTaken = 0
    /// The pause carries on by itself unless it is stopped. Someone with their
    /// eyes closed should not have to open them to keep practising, and a
    /// screen waiting for a tap is a practice that has quietly halted.
    @State private var restHeld = false
    @State private var pulseBefore: PulseReading?
    @State private var pulseAfter: PulseReading?
    @State private var showPulseBefore = false
    @State private var showPulseAfter = false
    @Environment(\.requestReview) private var requestReview

    init(school: SchoolContent, routine: Routine,
         onComplete: @escaping () -> Void = {}, measuresPulse: Bool = false) {
        self.school = school
        self.routine = routine
        self.onComplete = onComplete
        self.measuresPulse = measuresPulse
        let secs = max(30, routine.minutes * 60)
        _total = State(initialValue: secs)
        _remaining = State(initialValue: secs)
    }

    private var color: Color { SchoolPalette.color(school.id) }

    /// How far the practice has come, 0 to 1. The tree reads only this.
    private var grown: Double {
        guard total > 0 else { return 0 }
        return 1 - Double(remaining) / Double(total)
    }
    private var hasSafety: Bool { !(routine.safety ?? "").isEmpty }
    private var steps: [String] { routine.steps }

    /// Gentle lines spoken in the gaps so the silence never feels empty.
    private static let generalCues = [
        "Stay with it.",
        "Nothing to fix. Just be here.",
        "Let your shoulders drop.",
        "Soften your jaw.",
        "No rush. There's time.",
        "I'm here with you.",
        "Let the breath be easy.",
        "Keep resting your attention here.",
        "If your mind wandered, that's fine. Come back.",
        "You're doing it.",
        "Let this be simple.",
        "Settle a little deeper."
    ]

    private static let breathCues = [
        "Breathe with me.",
        "Let the out-breath be longer.",
        "Easy in, slow out.",
        "Let the belly move.",
        "Nothing forced.",
        "Stay with the rhythm."
    ]

    /// Said at each step's end. Every one names what happened, never how much
    /// is left — the whole point of taking the counter off the screen is lost
    /// if the celebration puts it back.
    private static let restLines = [
        (en: "That's one.",          tr: "Bir tane oldu.",        es: "Ahí va una."),
        (en: "You stayed with it.",  tr: "Onunla kaldın.",        es: "Te quedaste con ello."),
        (en: "Still here.",          tr: "Hâlâ buradasın.",       es: "Sigues aquí."),
        (en: "That one settled.",    tr: "Bu oturdu.",            es: "Esa se asentó."),
        (en: "Good. That's yours.",  tr: "Güzel. Bu senin.",      es: "Bien. Esa es tuya."),
        (en: "Something softened.",  tr: "Bir şey yumuşadı.",     es: "Algo se ablandó.")
    ]

    /// How long the practice waits before carrying on by itself. Long enough
    /// to land, short enough that the practice does not become a series of
    /// stops. No number is shown counting it down — a practice with a clock
    /// ticking at you is the opposite of the thing.
    private static let restSeconds = 5.0

    private var cuePool: [String] {
        (school.id == "breathing" || school.id == "sound") ? Self.breathCues + Self.generalCues : Self.generalCues
    }

    private func speakCue(_ key: String) {
        guard !voiceMuted, !finished, !spokenCues.contains(key) else { return }
        spokenCues.insert(key)
        let pool = cuePool
        let line = pool[cueIndex % pool.count]
        cueIndex += 1
        SpeechGuide.shared.speak(line)
    }

    /// A review is worth asking for right after a practice lands, never before.
    /// Only completed sessions count: the first — one practice is enough to
    /// have an opinion — and again at the tenth and twenty-fifth, since the
    /// system may decline to show the first.
    private func askForReviewIfEarned(after outcome: PracticeOutcome) {
        // Never during automated runs: the sheet lands on top of the screen the
        // capture is trying to photograph.
        guard !ProcessInfo.processInfo.arguments.contains("-uiTesting") else { return }
        guard outcome.feedsOrb else { return }
        let done = PracticeLogStore.completedCount()
        guard [1, 10, 25].contains(done) else { return }
        let key = "review_asked_at_\(done)"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        // Let the completion animation settle before the sheet arrives.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { requestReview() }
    }

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.35)
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: DS.Space.md)
                if finished { completeView } else { runningView }
                Spacer(minLength: DS.Space.md)
                controls
            }
        }
        .sensoryFeedback(.success, trigger: restsTaken)
        .onAppear {
            pulse = true
            showSafety = hasSafety
            if measuresPulse { showPulseBefore = true } else { begin() }
        }
        .fullScreenCover(isPresented: $showPulseBefore) {
            PulseCheckView(moment: .before) { reading in
                pulseBefore = reading
                begin()
            }
        }
        .fullScreenCover(isPresented: $showPulseAfter) {
            PulseCheckView(moment: .after) { reading in
                pulseAfter = reading
                storePulse()
            }
        }
        .onDisappear {
            ticker?.invalidate()
            SpeechGuide.shared.stop()
            AmbientPlayer.shared.stop()
        }
    }

    private var topBar: some View {
        HStack {
            if hasSafety {
                Button { withAnimation { showSafety.toggle() } } label: {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DS.textDim).frame(width: 32, height: 32)
                }
                .accessibilityLabel("Safety note")
            }
            Button {
                SpeechGuide.shared.toggleMute()
                voiceMuted = SpeechGuide.isMuted
                if !voiceMuted { speakCurrentStep() }
            } label: {
                Image(systemName: voiceMuted ? "speaker.slash" : "speaker.wave.2")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.textDim).frame(width: 32, height: 32)
            }
            .accessibilityLabel(voiceMuted ? "Turn voice on" : "Turn voice off")

            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textDim).frame(width: 32, height: 32)
            }
        }
        .padding(.top, DS.Space.md).padding(.horizontal, DS.Space.lg)
    }

    private var runningView: some View {
        VStack(spacing: DS.Space.lg) {
            Text(routine.title)
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.lg)

            if showSafety, let s = routine.safety, !s.isEmpty {
                ScrollView {
                    Text(s).font(.caption).foregroundStyle(DS.textSecondary).lineSpacing(3)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxHeight: 150)
                .padding(DS.Space.md)
                .background(DS.surfaceAlt).clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DS.border, lineWidth: DS.hairline))
                .padding(.horizontal, DS.Space.lg)
                .transition(.opacity)
            }

            ZStack {
                Circle().fill(color.opacity(0.14)).frame(width: 190, height: 190)
                    .scaleEffect(pulse ? 1.05 : 0.92)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulse)
                EnergyTreeView(progress: grown, tint: color, size: 300)
                    .opacity(0.45)
                    .offset(y: -86)
                Circle().stroke(DS.border, lineWidth: 3).frame(width: 172, height: 172)
                Circle()
                    .trim(from: 0, to: 1 - CGFloat(remaining) / CGFloat(total))
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 172, height: 172).rotationEffect(.degrees(-90))
                Text(timeString)
                    .font(.system(size: 36, weight: .thin, design: .serif))
                    .monospacedDigit().foregroundStyle(DS.textPrimary)
            }

            // The step itself, or the moment between two of them.
            //
            // No "step 3 of 6". A practice that opens by telling you there are
            // six of these reads as a list of chores before it has said a
            // single useful thing, and the number is the part nobody needs:
            // the ring already shows the time, and the only step that matters
            // is the one being done.
            if resting {
                restView
            } else {
                Text(steps.isEmpty ? routine.purpose : steps[min(stepIndex, steps.count - 1)])
                    .font(.callout).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center).lineSpacing(4)
                    .padding(.horizontal, DS.Space.xl)
                    .id(stepIndex).transition(.opacity)
            }
        }
    }

    private var restView: some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(color)
                .padding(10)
                .background(color.opacity(0.14), in: Circle())

            Text(restLine)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)

            Text(restHeld
                 ? L10n.text(en: "Whenever you're ready.", tr: "Hazır olduğunda.", es: "Cuando quieras.")
                 : L10n.text(en: "Going on in a moment.", tr: "Birazdan devam ediyoruz.", es: "Seguimos en un momento."))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .animation(.easeOut(duration: 0.2), value: restHeld)
        }
        .padding(.horizontal, DS.Space.xl)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .accessibilityIdentifier("player.rest")
    }

    private var completeView: some View {
        VStack(spacing: DS.Space.lg) {
            if fedOrb {
                EnergyTreeView(progress: 1, tint: color, size: 200)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
            EnergyOrbBadge(total: orbTotal, tint: color, size: 160, celebrate: true)
            if let before = pulseBefore?.bpm, let after = pulseAfter?.bpm {
                pulseResult(before: before, after: after)
            }
            VStack(spacing: DS.Space.xs) {
                Text(fedOrb ? "Your orb is brighter" : "Logged")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                Text(fedOrb
                     ? "That's one more for \(school.name)."
                     : "Marked as not a full practice — you can change that in Wins.")
                    .font(.callout).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// The pair, side by side. The drop is the whole point, so it is the thing
    /// set in the largest type — and when it went the other way, it says so.
    private func pulseResult(before: Int, after: Int) -> some View {
        let drop = before - after
        return VStack(spacing: DS.Space.sm) {
            HStack(spacing: DS.Space.md) {
                pulseFigure(before, L10n.text(en: "BEFORE", tr: "ÖNCE", es: "ANTES"))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.textDim)
                pulseFigure(after, L10n.text(en: "AFTER", tr: "SONRA", es: "DESPUÉS"))
            }
            Text(drop > 0
                 ? L10n.text(en: "\(drop) beats slower", tr: "\(drop) atış daha yavaş", es: "\(drop) latidos más lento")
                 : L10n.text(en: "Steady through", tr: "Baştan sona sabit", es: "Estable en todo"))
                .font(.system(size: 19, weight: .medium, design: .serif))
                .foregroundStyle(drop > 0 ? DS.calm : DS.textSecondary)
        }
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(DS.border, lineWidth: DS.hairline))
        .transition(.opacity)
        .accessibilityElement(children: .combine)
    }

    private func pulseFigure(_ bpm: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(bpm)")
                .font(.system(size: 40, weight: .light, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(DS.Typo.label).kerning(1.2)
                .foregroundStyle(DS.textDim)
        }
    }

    private var controls: some View {
        VStack(spacing: DS.Space.sm) {
            if finished {
                Button("Done") { dismiss() }.primaryCTA()
            } else {
                if resting {
                    if restHeld {
                        Button(L10n.text(en: "Go on", tr: "Devam", es: "Seguir")) { goOn() }
                            .primaryCTA()
                            .accessibilityIdentifier("player.goOn")
                    } else {
                        // Small, and deliberately so. The pause carries on by
                        // itself; stopping it is the rarer thing, and a
                        // full-width button saying Stop in the middle of a
                        // practice reads as the thing you are meant to press.
                        Button(L10n.text(en: "Stop", tr: "Dur", es: "Parar")) { holdRest() }
                            .font(.caption)
                            .foregroundStyle(DS.textDim)
                            .padding(.vertical, DS.Space.md)
                            .accessibilityIdentifier("player.holdRest")
                    }
                    Button(L10n.text(en: "That's enough for today",
                                     tr: "Bugünlük bu kadar",
                                     es: "Por hoy es suficiente")) { complete() }
                        .font(.footnote).foregroundStyle(DS.textSecondary)
                } else if stepIndex < steps.count - 1 {
                    Button(L10n.text(en: "Next step", tr: "Sonraki adım", es: "Siguiente paso")) { reachStepEnd() }
                        .primaryCTA()
                    Button(running ? L10n.text(en: "Pause", tr: "Duraklat", es: "Pausa")
                                   : L10n.text(en: "Resume", tr: "Devam et", es: "Reanudar")) { running.toggle() }
                        .font(.footnote).foregroundStyle(DS.textSecondary)
                } else {
                    Button(L10n.text(en: "Finish", tr: "Bitir", es: "Terminar")) { complete() }
                        .primaryCTA()
                    Button(running ? L10n.text(en: "Pause", tr: "Duraklat", es: "Pausa")
                                   : L10n.text(en: "Resume", tr: "Devam et", es: "Reanudar")) { running.toggle() }
                        .font(.footnote).foregroundStyle(DS.textSecondary)
                }
            }
        }
        .padding(.horizontal, DS.Space.lg).padding(.bottom, DS.Space.xl)
    }

    private var timeString: String { String(format: "%d:%02d", remaining / 60, remaining % 60) }

    /// A step has finished. Stop the clock and say so.
    ///
    /// The clock stops rather than running through the pause, so lingering
    /// here never shortens the practice or turns a full one into a partial in
    /// the log. The minutes the routine asks for are still the minutes it gets.
    private func reachStepEnd() {
        guard !resting, !finished else { return }
        guard stepIndex < steps.count - 1 else { return complete() }
        let line = Self.restLines[restsTaken % Self.restLines.count]
        restsTaken += 1
        restLine = L10n.text(en: line.en, tr: line.tr, es: line.es)
        running = false
        restHeld = false
        withAnimation(.easeOut(duration: 0.3)) { resting = true }
        // Spoken as well as shown: at this point in a breathing practice the
        // eyes are usually closed, and what the voice says is the only way to
        // know the practice is still moving.
        SpeechGuide.shared.speak("\(line.en) Going on in a moment.")

        // Carries on by itself. The token is the rest count, so a rest that
        // has already been stopped, skipped or finished cannot be resumed by
        // a timer left over from it.
        let token = restsTaken
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.restSeconds) {
            guard resting, !restHeld, !finished, restsTaken == token else { return }
            goOn()
        }
    }

    /// Stop. The practice stays where it is until it is asked to move.
    private func holdRest() {
        guard resting else { return }
        restsTaken += 1                 // invalidates the pending resume
        withAnimation(.easeOut(duration: 0.2)) { restHeld = true }
        SpeechGuide.shared.stop()
    }

    private func goOn() {
        guard resting else { return }
        restHeld = false
        withAnimation(.easeOut(duration: 0.25)) {
            resting = false
            stepIndex = min(stepIndex + 1, max(0, steps.count - 1))
        }
        running = true
        speakCurrentStep()
    }

    private func speakCurrentStep() {
        guard !finished, !steps.isEmpty else { return }
        SpeechGuide.shared.speak(steps[min(stepIndex, steps.count - 1)])
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard running, !finished else { return }
            if remaining > 1 {
                remaining -= 1
                // Pace the steps evenly across the routine.
                if !steps.isEmpty {
                    let per = max(1, total / steps.count)
                    let elapsed = total - remaining
                    let target = min(steps.count - 1, elapsed / per)
                    if target > stepIndex { reachStepEnd() }
                    // Keep company in the gap: a couple of soft cues per step,
                    // only when the step is long enough to fall silent.
                    if per >= 24 {
                        let into = elapsed - (stepIndex * per)
                        if into == Int(Double(per) * 0.45) { speakCue("\(stepIndex)-a") }
                        if into == Int(Double(per) * 0.80) { speakCue("\(stepIndex)-b") }
                    }
                }
            } else {
                complete()
            }
        }
    }

    /// The practice proper — held back until the first reading is in.
    private func begin() {
        guard !started else { return }
        started = true
        AmbientPlayer.shared.start(path: nil)
        startTicker()
        speakCurrentStep()
    }

    /// Attach the pair to the session already written to the log.
    private func storePulse() {
        guard var s = session else { return }
        s.pulseBefore = pulseBefore?.bpm
        s.pulseAfter = pulseAfter?.bpm
        PracticeLogStore.update(s)
        session = s
    }

    private func complete() {
        guard !finished else { return }
        finished = true
        ticker?.invalidate()
        // Be honest about how it went: tapping straight through logs as skipped,
        // stopping part-way logs as interrupted. Both are editable afterwards.
        let outcome: PracticeOutcome
        let fractionLeft = Double(remaining) / Double(max(1, total))
        if fractionLeft > 0.6      { outcome = .skipped }
        else if fractionLeft > 0.25 { outcome = .partial }
        else                        { outcome = .done }
        fedOrb = outcome.feedsOrb
        session = PracticeLogStore.add(schoolID: school.id, routine: routine, outcome: outcome)
        appState.invalidateStreakCache()
        orbTotal = EnergyOrb.totalSessions
        askForReviewIfEarned(after: outcome)
        SpeechGuide.shared.speak(outcome.feedsOrb ? "Your light is a little brighter now." : "Noted. You can adjust this any time.")
        // The second reading is only meaningful next to a first one.
        if measuresPulse, pulseBefore != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { showPulseAfter = true }
        }
        onComplete()
    }
}
