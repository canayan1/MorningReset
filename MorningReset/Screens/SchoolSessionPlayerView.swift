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
    @Environment(\.requestReview) private var requestReview

    init(school: SchoolContent, routine: Routine, onComplete: @escaping () -> Void = {}) {
        self.school = school
        self.routine = routine
        self.onComplete = onComplete
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
    /// Only completed sessions count, and only at the third, tenth and
    /// twenty-fifth — enough of a pattern that the person has something to say.
    private func askForReviewIfEarned(after outcome: PracticeOutcome) {
        // Never during automated runs: the sheet lands on top of the screen the
        // capture is trying to photograph.
        guard !ProcessInfo.processInfo.arguments.contains("-uiTesting") else { return }
        guard outcome.feedsOrb else { return }
        let done = PracticeLogStore.completedCount()
        guard [3, 10, 25].contains(done) else { return }
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
        .onAppear {
            pulse = true
            showSafety = hasSafety
            AmbientPlayer.shared.start(path: nil)
            startTicker()
            speakCurrentStep()
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

            // Current step
            VStack(spacing: DS.Space.xs) {
                Text("STEP \(stepIndex + 1) OF \(steps.count)")
                    .font(.system(size: 10, weight: .semibold)).tracking(1.4)
                    .foregroundStyle(color)
                Text(steps.isEmpty ? routine.purpose : steps[min(stepIndex, steps.count - 1)])
                    .font(.callout).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center).lineSpacing(4)
                    .padding(.horizontal, DS.Space.xl)
                    .id(stepIndex).transition(.opacity)
            }
        }
    }

    private var completeView: some View {
        VStack(spacing: DS.Space.lg) {
            if fedOrb {
                EnergyTreeView(progress: 1, tint: color, size: 200)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
            EnergyOrbBadge(total: orbTotal, tint: color, size: 160, celebrate: true)
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

    private var controls: some View {
        VStack(spacing: DS.Space.sm) {
            if finished {
                Button("Done") { dismiss() }.primaryCTA()
            } else {
                if stepIndex < steps.count - 1 {
                    Button("Next step") { advanceStep() }.primaryCTA()
                } else {
                    Button("Finish") { complete() }.primaryCTA()
                }
                Button(running ? "Pause" : "Resume") { running.toggle() }
                    .font(.footnote).foregroundStyle(DS.textSecondary)
            }
        }
        .padding(.horizontal, DS.Space.lg).padding(.bottom, DS.Space.xl)
    }

    private var timeString: String { String(format: "%d:%02d", remaining / 60, remaining % 60) }

    private func advanceStep() {
        withAnimation(.easeOut(duration: 0.2)) {
            stepIndex = min(stepIndex + 1, max(0, steps.count - 1))
        }
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
                    if target > stepIndex {
                        withAnimation(.easeOut(duration: 0.2)) { stepIndex = target }
                        speakCurrentStep()
                    }
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
        PracticeLogStore.add(schoolID: school.id, routine: routine, outcome: outcome)
        appState.invalidateStreakCache()
        orbTotal = EnergyOrb.totalSessions
        askForReviewIfEarned(after: outcome)
        SpeechGuide.shared.speak(outcome.feedsOrb ? "Your light is a little brighter now." : "Noted. You can adjust this any time.")
        onComplete()
    }
}
