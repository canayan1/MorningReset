import SwiftUI

// MARK: - The Tree You Breathe
//
// The app's own practice, and the only one where nothing is on a clock. The
// tree grows on the out-breath and waits on the in-breath, so sitting through
// it without breathing grows nothing. Its shape comes from how you breathed —
// long and slow opens a wide tree with few heavy limbs, quick and shallow a
// narrow one with many fine ones — which means no two trees are the same and
// yours is different tomorrow.
//
// It runs in silence. The microphone is listening for a breath, and an ambient
// bed or a voice reading steps would be the loudest thing in the room. One line
// at the start, one at the end, nothing in between.

struct SignatureMeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var onComplete: () -> Void = {}

    /// Out-breaths for a full tree. At an unhurried pace that is most of three
    /// minutes, so the tree fills about when the practice ends.
    private static let breathsForFullTree = 24
    private static let length: TimeInterval = 180
    /// If the room never resolves into breathing, stop waiting on it.
    private static let patience: TimeInterval = 30

    @StateObject private var breath = BreathDetector()
    @State private var started = false
    @State private var finished = false
    @State private var elapsed: TimeInterval = 0
    @State private var ticker: Timer?
    @State private var fellBackToTime = false
    @State private var glow = false

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.3)

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: DS.Space.md)
                if finished { completeView } else if started { growingView } else { introView }
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

    // MARK: - Growth

    /// 0…1. The breath drives it; the clock only takes over when the room
    /// turns out to be unlistenable.
    private var grown: Double {
        let byBreath = Double(breath.exhaleCount) / Double(Self.breathsForFullTree)
        guard fellBackToTime else { return min(1, byBreath) }
        return min(1, max(byBreath, elapsed / Self.length))
    }

    private var character: Double { treeCharacter(averageExhale: breath.averageExhale) }

    /// The colour carries the last thing the app measured about you: the more
    /// the pulse came down, the deeper and stiller the tree.
    private var tint: Color {
        let drop = PracticeLogStore.all()
            .sorted { $0.date > $1.date }
            .compactMap(\.pulseDrop)
            .first ?? 0
        return DS.accent.mixed(with: DS.calm, by: min(1, max(0, Double(drop) / 15)))
    }

    // MARK: - Screens

    private var introView: some View {
        VStack(spacing: DS.Space.lg) {
            EnergyTreeView(progress: 0, tint: tint, size: 220, character: 0.5)
                .opacity(0.5)

            VStack(spacing: DS.Space.sm) {
                Text(L10n.text(en: "The Tree You Breathe", tr: "Nefesinle Büyüyen Ağaç", es: "El Árbol Que Respiras"))
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.text(
                    en: "It grows on the out-breath and waits on the in.\nHow you breathe is the shape it takes.",
                    tr: "Verişte büyür, alışta bekler.\nNasıl nefes aldığın, aldığı şekildir.",
                    es: "Crece al exhalar y espera al inhalar.\nCómo respiras es la forma que toma."
                ))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private var growingView: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                // The glow rides the live breath, so the screen moves with the
                // person rather than with a timer.
                Circle()
                    .fill(tint.opacity(0.10 + breath.level * 0.22))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .scaleEffect(1 + breath.level * 0.12)
                    .animation(.easeOut(duration: 0.35), value: breath.level)

                EnergyTreeView(progress: grown, tint: tint, size: 280, character: character)
            }
            .frame(height: 340)

            VStack(spacing: DS.Space.xs) {
                Text("\(breath.exhaleCount)")
                    .font(.system(size: 44, weight: .light, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: breath.exhaleCount)
                Text(L10n.text(en: "BREATHS", tr: "NEFES", es: "RESPIRACIONES"))
                    .font(DS.Typo.label).kerning(2)
                    .foregroundStyle(DS.textDim)
            }

            Text(hint)
                .font(.footnote)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
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
                Text(breath.exhaleCount > 0
                     ? L10n.text(en: "\(breath.exhaleCount) breaths, and no one else's shape.",
                                 tr: "\(breath.exhaleCount) nefes, başka kimsede olmayan bir şekil.",
                                 es: "\(breath.exhaleCount) respiraciones, una forma de nadie más.")
                     : L10n.text(en: "Logged.", tr: "Kaydedildi.", es: "Registrado."))
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
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
                    .primaryCTA()
                    .accessibilityIdentifier("signature.done")
            } else if started {
                Button(L10n.text(en: "Finish", tr: "Bitir", es: "Terminar")) { complete() }
                    .primaryCTA()
                    .accessibilityIdentifier("signature.finish")
            } else {
                Button(L10n.text(en: "Begin", tr: "Başla", es: "Comenzar")) { begin() }
                    .primaryCTA()
                    .accessibilityIdentifier("signature.begin")
            }
        }
        .padding(.horizontal, DS.Space.lg).padding(.bottom, DS.Space.xl)
    }

    private var hint: String {
        if !breath.available {
            return L10n.text(en: "No microphone here, so the tree grows on time instead.",
                             tr: "Burada mikrofon yok; ağaç bu kez zamanla büyüyor.",
                             es: "Sin micrófono aquí; el árbol crece con el tiempo.")
        }
        if fellBackToTime {
            return L10n.text(en: "Too much in the room to hear a breath — growing on time instead.",
                             tr: "Oda nefesi duyamayacak kadar kalabalık — ağaç zamanla büyüyor.",
                             es: "Demasiado ruido para oír la respiración — crece con el tiempo.")
        }
        if !breath.listening {
            return L10n.text(en: "Listening to the room…", tr: "Odayı dinliyorum…", es: "Escuchando la sala…")
        }
        if breath.exhaleCount == 0 {
            return L10n.text(en: "Let the out-breath be long, and let it be audible.",
                             tr: "Verişin uzun olsun, ve duyulsun.",
                             es: "Que la exhalación sea larga, y que se oiga.")
        }
        return ""
    }

    // MARK: - Running

    private func begin() {
        guard !started else { return }
        started = true
        breath.start()
        SpeechGuide.shared.speak("Let the out-breath be long, and let it be audible. The tree does the rest.")
        glow = true
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard !finished else { return }
            elapsed += 1
            // Waited long enough on a room that will not settle.
            if !fellBackToTime, elapsed > Self.patience, breath.exhaleCount == 0 {
                fellBackToTime = true
            }
            if elapsed >= Self.length || grown >= 1 { complete() }
        }
    }

    private func complete() {
        guard !finished else { return }
        finished = true
        ticker?.invalidate()
        breath.stop()

        // It logs like any other practice, under the breath tradition it
        // belongs to, so the orb and the streak count it.
        let routine = Routine(id: "breathing.signature",
                              title: "The Tree You Breathe",
                              group: .starter,
                              minutes: max(1, Int(elapsed / 60)),
                              purpose: "The app's own practice: a tree grown by the out-breath.",
                              steps: [],
                              safety: nil,
                              free: true)
        _ = PracticeLogStore.add(schoolID: "breathing", routine: routine,
                                 outcome: grown >= 0.5 ? .done : .partial)
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
