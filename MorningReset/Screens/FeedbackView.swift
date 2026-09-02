import SwiftUI
import StoreKit

/// Milestone celebration screen — shown at day 3, 7, 14, 30 streaks.
/// Replaces the old text-only FeedbackView with a quiet, earned moment.
struct FeedbackView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.requestReview) private var requestReview
    @AppStorage("mrLastReviewMilestone") private var lastReviewMilestone = 0

    @State private var appeared    = false
    @State private var numberShown = false

    private var streak: Int { appState.streakCount }
    private var entries: [DailyEntry] { DailyEntryStore.load() }

    // Most common mode in the current streak run
    private var dominantMode: String? {
        let recent = Array(entries.suffix(streak))
        let modes = recent.map { $0.mode }
        var counts: [String: Int] = [:]
        modes.forEach { counts[$0, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private var milestoneMessage: String {
        switch streak {
        case 3:
            return L10n.text(
                en: "Three mornings.\nThe hardest part is already behind you.",
                tr: "Üç sabah.\nEn zor kısım çoktan geride kaldı.",
                es: "Tres mañanas.\nLa parte más difícil ya quedó atrás."
            )
        case 7:
            return L10n.text(
                en: "A full week.\nYou're building something real.",
                tr: "Tam bir hafta.\nGerçek bir şey inşa ediyorsun.",
                es: "Una semana completa.\nEstás construyendo algo real."
            )
        case 14:
            return L10n.text(
                en: "Two weeks of intentional mornings.\nThis is a practice now.",
                tr: "İki hafta boyunca bilinçli sabahlar.\nBu artık bir pratik.",
                es: "Dos semanas de mañanas intencionales.\nEsto es una práctica ahora."
            )
        case 30:
            return L10n.text(
                en: "Thirty mornings.\nMost people never get here.",
                tr: "Otuz sabah.\nÇoğu insan buraya hiç ulaşamıyor.",
                es: "Treinta mañanas.\nLa mayoría de la gente nunca llega aquí."
            )
        default:
            return L10n.text(
                en: "Keep going.",
                tr: "Devam et.",
                es: "Sigue adelante."
            )
        }
    }

    private var modeNote: String? {
        guard let mode = dominantMode else { return nil }
        switch mode {
        case "protect":
            return L10n.text(
                en: "Most of these mornings started slow and steady.",
                tr: "Bu sabahların çoğu yavaş ve dengeli başladı.",
                es: "La mayoría de estas mañanas empezaron despacio y con calma."
            )
        case "push":
            return L10n.text(
                en: "These have been high-energy mornings.",
                tr: "Bunlar yüksek enerjili sabahlardı.",
                es: "Han sido mañanas de mucha energía."
            )
        default:
            return L10n.text(
                en: "These have been consistent, grounded mornings.",
                tr: "Bunlar tutarlı, dengeli sabahlardı.",
                es: "Han sido mañanas consistentes y equilibradas."
            )
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                // ── Big number ────────────────────────────────────────
                VStack(alignment: .center, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 96, weight: .thin, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .monospacedDigit()
                        .scaleEffect(numberShown ? 1 : 0.7)
                        .opacity(numberShown ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: numberShown)

                    Text(L10n.text(en: "days in a row.", tr: "gün üst üste.", es: "días seguidos."))
                        .font(.system(.title3, design: .serif).weight(.light))
                        .foregroundStyle(DS.textSecondary)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: DS.Space.xl)

                // ── Milestone message ─────────────────────────────────
                Text(milestoneMessage)
                    .font(.system(.title3, design: .serif).weight(.regular))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.45).delay(0.45), value: appeared)

                if let note = modeNote {
                    Spacer().frame(height: DS.Space.lg)
                    Text(note)
                        .font(.callout)
                        .foregroundStyle(DS.textDim)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)
                }

                Spacer().frame(height: DS.Space.xl)

                // ── 7-day strip ───────────────────────────────────────
                VStack(spacing: 8) {
                    StreakStripLegend(days: 7)
                    StreakStripView(entries: entries, days: 7)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.7), value: appeared)

                Spacer()

                // ── CTA ───────────────────────────────────────────────
                Button(L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")) {
                    let earned = streak
                    appState.dismissFeedback()
                    // Ask for an App Store review at a real pride moment — only on a
                    // weekly+ milestone, and only once per milestone tier. Apple still
                    // caps the actual prompt to ~3×/year.
                    if (earned == 7 || earned == 14 || earned == 30), earned > lastReviewMilestone {
                        lastReviewMilestone = earned
                        Task {
                            try? await Task.sleep(for: .milliseconds(600))
                            await MainActor.run { requestReview() }
                        }
                    }
                }
                .primaryCTA()
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.8), value: appeared)
                .padding(.bottom, DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear {
            appeared    = true
            numberShown = true
        }
    }
}
