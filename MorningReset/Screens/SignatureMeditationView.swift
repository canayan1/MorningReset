import SwiftUI

// MARK: - The Tree You Breathe
//
// The app's own practice: box breathing, guided, with a tree that grows on the
// out-breath. Five rounds at three seconds a side to settle into the shape,
// then ten at four, which is the pace that actually does the work.
//
// The microphone is listening for the out-breath, so an audible one grows the
// tree faster than a silent one — but a silent one still grows it. The point is
// a practice that can tell whether you are doing it, not one that stops when it
// cannot hear you.
//
// It runs without an ambient bed. The only thing in the room should be the
// person breathing, or the microphone has nothing to listen to but us.

struct SignatureMeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var onComplete: () -> Void = {}

    /// One side of the box. Five short rounds to find the shape, then ten at
    /// the longer count.
    private static let rounds: [(count: Int, side: Double)] = [(5, 3), (10, 4)]

    private enum Phase: Equatable {
        case inhale, holdIn, exhale, holdOut

        var label: String {
            switch self {
            case .inhale:  L10n.text(en: "Breathe in", tr: "Nefes al", es: "Inhala")
            case .holdIn:  L10n.text(en: "Hold", tr: "Tut", es: "Sostén")
            case .exhale:  L10n.text(en: "Breathe out", tr: "Nefes ver", es: "Exhala")
            case .holdOut: L10n.text(en: "Hold", tr: "Tut", es: "Sostén")
            }
        }
    }

    /// The whole session, flattened: every phase in order with its length.
    private static let schedule: [(phase: Phase, seconds: Double)] = {
        var out: [(Phase, Double)] = []
        for (count, side) in rounds {
            for _ in 0..<count {
                out += [(.inhale, side), (.holdIn, side), (.exhale, side), (.holdOut, side)]
            }
        }
        return out
    }()

    static let exhaleCount = schedule.filter { $0.phase == .exhale }.count
    static let totalSeconds = schedule.reduce(0) { $0 + $1.seconds }

    @StateObject private var breath = BreathDetector()
    @State private var started = false
    @State private var finished = false
    @State private var index = 0
    @State private var inPhase: Double = 0
    @State private var grown: Double = 0
    @State private var exhalesDone = 0
    @State private var effortTotal: Double = 0
    @State private var effortSamples = 0
    @State private var ticker: Timer?

    private static let tick = 0.05

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.3)
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: DS.Space.md)
                if finished { completeView } else if started { breathingView } else { introView }
                Spacer(minLength: DS.Space.md)
                controls
            }
        }
        .accessibilityIdentifier("signature.screen")
        .onDisappear {
            ticker?.invalidate()
            breath.stop()
            SpeechGuide.shared.stop()
        }
    }

    // MARK: - State

    private var phase: Phase { Self.schedule[min(index, Self.schedule.count - 1)].phase }
    private var phaseLength: Double { Self.schedule[min(index, Self.schedule.count - 1)].seconds }
    private var secondsLeft: Int { max(1, Int(ceil(phaseLength - inPhase))) }

    /// How hard the out-breaths have been. This is what makes the tree theirs:
    /// everyone breathes to the same count here, but not everyone means it.
    private var character: Double {
        guard effortSamples > 0 else { return 0.5 }
        return min(1, effortTotal / Double(effortSamples) * 1.6)
    }

    /// The colour carries the last thing the app measured about this person.
    private var tint: Color {
        let drop = PracticeLogStore.all()
            .sorted { $0.date > $1.date }
            .compactMap(\.pulseDrop)
            .first ?? 0
        return DS.accent.mixed(with: DS.calm, by: min(1, max(0, Double(drop) / 15)))
    }

    /// The guide circle: full on a held-in breath, small on a held-out one.
    private var circleScale: CGFloat {
        let t = min(1, inPhase / phaseLength)
        switch phase {
        case .inhale:  return 0.55 + 0.45 * t
        case .holdIn:  return 1.0
        case .exhale:  return 1.0 - 0.45 * t
        case .holdOut: return 0.55
        }
    }

    // MARK: - Screens

    private var introView: some View {
        VStack(spacing: DS.Space.lg) {
            EnergyTreeView(progress: 0, tint: tint, size: 210, character: 0.5).opacity(0.5)
            VStack(spacing: DS.Space.sm) {
                Text(L10n.text(en: "The Tree You Breathe", tr: "Nefesinle Büyüyen Ağaç", es: "El Árbol Que Respiras"))
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                Text(L10n.text(
                    en: "Five rounds of three, then ten of four.\nBreathe out towards the phone, and let it be heard.",
                    tr: "Beş tur üçer, sonra on tur dörder.\nTelefona doğru ver, ve duyulsun.",
                    es: "Cinco rondas de tres, luego diez de cuatro.\nExhala hacia el teléfono, y que se oiga."
                ))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private var breathingView: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                // The tree stands behind the whole thing, growing on the out-breath.
                EnergyTreeView(progress: grown, tint: tint, size: 300, character: character)
                    .opacity(0.5)
                    .offset(y: -30)

                // The guide: it opens as you breathe in and closes as you let go.
                Circle()
                    .fill(tint.opacity(0.12 + (phase == .exhale ? breath.level * 0.18 : 0)))
                    .frame(width: 210, height: 210)
                    .scaleEffect(circleScale)

                Circle()
                    .stroke(tint.opacity(0.55), lineWidth: 2.5)
                    .frame(width: 210, height: 210)
                    .scaleEffect(circleScale)

                VStack(spacing: 2) {
                    Text(phase.label)
                        .font(.system(size: 21, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                    Text("\(secondsLeft)")
                        .font(.system(size: 46, weight: .light, design: .serif))
                        .foregroundStyle(DS.textSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            }
            .frame(height: 360)
            .animation(.linear(duration: Self.tick), value: circleScale)

            Text(hint)
                .font(.footnote)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300, minHeight: 34)
                .animation(.easeInOut(duration: 0.3), value: hint)
        }
    }

    private var completeView: some View {
        VStack(spacing: DS.Space.lg) {
            EnergyTreeView(progress: grown, tint: tint, size: 260, character: character)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            VStack(spacing: DS.Space.xs) {
                Text(L10n.text(en: "This one was yours.", tr: "Bu, senindi.", es: "Este fue tuyo."))
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                Text(L10n.text(en: "No one else grew this shape.",
                               tr: "Bu şekli başka kimse büyütmedi.",
                               es: "Nadie más hizo crecer esta forma."))
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textDim).frame(width: 32, height: 32)
            }
            .accessibilityLabel(L10n.text(en: "Close", tr: "Kapat", es: "Cerrar"))
        }
        .padding(.top, DS.Space.md).padding(.horizontal, DS.Space.lg)
    }

    private var controls: some View {
        VStack(spacing: DS.Space.sm) {
            if finished {
                Button(L10n.text(en: "Done", tr: "Tamam", es: "Hecho")) { dismiss() }
                    .primaryCTA().accessibilityIdentifier("signature.done")
            } else if started {
                Button(L10n.text(en: "Finish", tr: "Bitir", es: "Terminar")) { complete() }
                    .primaryCTA().accessibilityIdentifier("signature.finish")
            } else {
                Button(L10n.text(en: "Begin", tr: "Başla", es: "Comenzar")) { begin() }
                    .primaryCTA().accessibilityIdentifier("signature.begin")
            }
        }
        .padding(.horizontal, DS.Space.lg).padding(.bottom, DS.Space.xl)
    }

    private var hint: String {
        guard phase == .exhale else { return "" }
        if !breath.available || !breath.listening {
            return L10n.text(en: "Breathe out slowly.", tr: "Yavaşça ver.", es: "Exhala despacio.")
        }
        return breath.level > 0.3
            ? L10n.text(en: "That's it — it can hear you.", tr: "İşte böyle — seni duyuyor.", es: "Eso es — te oye.")
            : L10n.text(en: "Out through the mouth, towards the phone.",
                        tr: "Ağızdan, telefona doğru.",
                        es: "Por la boca, hacia el teléfono.")
    }

    // MARK: - Running

    private func begin() {
        guard !started else { return }
        started = true
        breath.start()
        SpeechGuide.shared.speak("Breathe out towards the phone, and let it be heard. The tree does the rest.")
        cue()
        ticker = Timer.scheduledTimer(withTimeInterval: Self.tick, repeats: true) { _ in advance() }
    }

    private func advance() {
        guard !finished else { return }
        inPhase += Self.tick

        if phase == .exhale {
            // The tree creeps forward through the out-breath, and a breath the
            // microphone can hear moves it further than a silent one.
            let share = 1.0 / Double(Self.exhaleCount)
            let effort = 0.45 + 0.55 * min(1, breath.level)
            grown = min(1, grown + share * (Self.tick / phaseLength) * effort)
            effortTotal += min(1, breath.level)
            effortSamples += 1
        }

        guard inPhase >= phaseLength else { return }
        if phase == .exhale { exhalesDone += 1 }
        inPhase = 0
        index += 1
        if index >= Self.schedule.count { complete(); return }
        cue()
    }

    /// Says the breath out loud.
    ///
    /// The screen was doing all the work here and the voice said one line at
    /// the start and then nothing for nearly four minutes — which is a long
    /// time to be watching a phone for instructions when the whole point is to
    /// have your eyes closed.
    ///
    /// The two holds stay silent. Saying "hold" thirty times is nagging, and
    /// the hold is the part where nothing is being asked of you — the label on
    /// screen is there for anyone who opens their eyes.
    private func cue() {
        switch phase {
        case .inhale:
            SpeechGuide.shared.speak("Breathe in.")
        case .exhale:
            // The first one carries the instruction; the rest are just the beat.
            SpeechGuide.shared.speak(exhalesDone == 0 ? "Breathe out, towards the phone." : "Breathe out.")
        case .holdIn, .holdOut:
            break
        }
        // The sides get longer once, a third of the way in, and that change is
        // worth a word — it arrives as a surprise otherwise.
        if index == Self.rounds[0].count * 4 {
            SpeechGuide.shared.speak("Now a little longer.")
        }
    }

    private func complete() {
        guard !finished else { return }
        finished = true
        ticker?.invalidate()
        breath.stop()

        let routine = Routine(id: "breathing.signature",
                              title: "The Tree You Breathe",
                              group: .starter,
                              minutes: max(1, Int(Self.totalSeconds / 60)),
                              purpose: "The app's own practice: box breathing, with a tree grown by the out-breath.",
                              steps: [],
                              safety: nil,
                              free: true)
        _ = PracticeLogStore.add(schoolID: "breathing", routine: routine,
                                 outcome: exhalesDone >= Self.exhaleCount / 2 ? .done : .partial)
        appState.invalidateStreakCache()
        SpeechGuide.shared.speak("That one was yours. No one else grew this tree.")
        onComplete()
    }
}

// MARK: - Colour

extension Color {
    /// A straight blend between two colours, for carrying a measurement into a
    /// tint.
    func mixed(with other: Color, by amount: Double) -> Color {
        let t = min(1, max(0, amount))
        let a = UIColor(self), b = UIColor(other)
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(red: Double(r1 + (r2 - r1) * t),
                     green: Double(g1 + (g2 - g1) * t),
                     blue: Double(b1 + (b2 - b1) * t))
    }
}
