import SwiftUI

struct FlowCheckoutView: View {
    @Environment(AppState.self) private var appState
    @Environment(InsightEngine.self) private var insightEngine

    @State private var firstWinStatus: FirstWinStatus = .done
    @State private var difficulty: FlowDifficulty = .neutral
    @State private var sealed = false

    private var firstWin: FirstWinAction { appState.currentFirstWin }
    private var currentStreak: Int { appState.streakCount }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                // ── Day sealed animation ──────────────────────────────
                if sealed {
                    sealedState
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    checkoutForm
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, DS.Space.lg)
            .animation(.easeOut(duration: 0.35), value: sealed)
        }
        .accessibilityIdentifier("checkout.screen")
        .onAppear {
            firstWinStatus = appState.didCompleteFirstWin ? .done : .notYet
        }
    }

    // MARK: - Checkout form

    private var checkoutForm: some View {
        VStack(alignment: .center, spacing: DS.Space.xl) {

            // Header
            VStack(alignment: .center, spacing: DS.Space.xs) {
                Text(appState.ritualPresentation.checkPrompt)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            // Question 1 — Did you do it?
            VStack(alignment: .center, spacing: DS.Space.sm) {
                Text(L10n.text(en: "Did you complete it?", tr: "Tamamladın mı?", es: "¿Lo completaste?"))
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: DS.Space.sm) {
                    ForEach(FirstWinStatus.allCases, id: \.self) { option in
                        pillButton(option.label, selected: firstWinStatus == option) {
                            firstWinStatus = option
                        }
                    }
                }
            }

            // Question 2 — How did it feel?
            VStack(alignment: .center, spacing: DS.Space.sm) {
                Text(L10n.text(en: "How did it feel?", tr: "Nasıl hissettirdi?", es: "¿Cómo se sintió?"))
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: DS.Space.sm) {
                    ForEach(FlowDifficulty.allCases, id: \.self) { option in
                        pillButton(option.label, selected: difficulty == option) {
                            difficulty = option
                        }
                    }
                }
            }

            // Current streak — quiet reminder of what's at stake
            if currentStreak > 0 {
                HStack(spacing: DS.Space.xs) {
                    Circle()
                        .fill(DS.accent)
                        .frame(width: 6, height: 6)
                    Text(L10n.text(
                        en: "\(currentStreak)-day streak",
                        tr: "\(currentStreak) günlük seri",
                        es: "racha de \(currentStreak) días"
                    ))
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                }
            }

            // CTA
            Button(L10n.text(en: "Seal the day", tr: "Günü mühürle", es: "Sellar el día")) {
                sealAndContinue()
            }
            .primaryCTA()
            .accessibilityIdentifier("checkout.finishButton")

            Button(L10n.text(en: "Skip", tr: "Atla", es: "Saltar")) {
                appState.endFlow()
            }
            .font(.subheadline)
            .foregroundStyle(DS.textDim)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("checkout.skipButton")
        }
    }

    // MARK: - Sealed state (brief moment before transition)

    private var sealedState: some View {
        VStack(alignment: .center, spacing: DS.Space.sm) {
            Text("\(currentStreak + 1)")
                .font(.system(size: 72, weight: .thin, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .monospacedDigit()

            Text(L10n.text(
                en: (currentStreak + 1) == 1 ? "first routine." : "days in a row.",
                tr: (currentStreak + 1) == 1 ? "ilk rutin." : "gün üst üste.",
                es: (currentStreak + 1) == 1 ? "primera rutina." : "días seguidos."
            ))
            .font(.system(.title3, design: .serif))
            .foregroundStyle(DS.textSecondary)
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Pill button

    private func pillButton(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.callout)
                .foregroundStyle(selected ? DS.background : DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selected ? DS.accent : DS.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }

    // MARK: - Save logic

    private func sealAndContinue() {
        let intentionStr = UserDefaults.standard.string(forKey: UDKey.selectedIntention)
            ?? IntentionType.focus.rawValue

        let checkout = FlowCheckout(
            date: Date(),
            mode: appState.sessionMode.rawValue,
            intention: intentionStr,
            streakCount: appState.streakCount,
            firstWin: firstWin,
            firstWinStatus: firstWinStatus,
            difficulty: difficulty,
            helpfulness: helpfulness,
            tags: []
        )
        FlowCheckoutStore.append(checkout)

        Task {
            await insightEngine.refresh(
                mode: appState.sessionMode.rawValue,
                intention: intentionStr,
                streak: appState.streakCount
            )
        }

        if firstWinStatus == .done {
            appState.registerFirstWinCheck()
        }

        // Flash sealed state briefly then transition
        withAnimation { sealed = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            appState.endFlow()
        }
    }

    private var helpfulness: FlowHelpfulness {
        switch (firstWinStatus, difficulty) {
        case (.done, .easy):    return .yes
        case (.notYet, _):      return .no
        default:                return .somewhat
        }
    }
}
