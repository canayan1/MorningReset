import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState

    private var firstWin: FirstWinAction { appState.currentFirstWin }
    private var mode: MorningMode { appState.sessionMode }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // The action — nothing else competes
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(firstWin.actionTitle(for: mode))
                        .font(DS.Typo.display)
                        .foregroundStyle(DS.textPrimary)

                    Text(firstWin.actionBody)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(4)
                }

                Spacer().frame(height: DS.Space.xl)

                // Steps — inline, minimal
                if !firstWin.steps.isEmpty {
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        ForEach(Array(firstWin.steps.prefix(3).enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: DS.Space.md) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(DS.textDim)
                                    .frame(width: 16)

                                Text(step)
                                    .font(.callout)
                                    .foregroundStyle(DS.textPrimary)
                                    .lineSpacing(3)
                            }
                        }
                    }
                    .padding(.bottom, DS.Space.lg)
                }

                Spacer()

                Button(firstWin.buttonTitle) {
                    if firstWin == .movement {
                        appState.showMove()
                    } else {
                        appState.completeFirstWin()
                    }
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .accessibilityIdentifier("action.primaryButton")

                if appState.isPremium {
                    Button(L10n.text(en: "Open Rise & Flow instead", tr: "Bunun yerine Rise & Flow aç", es: "Abrir Rise & Flow en su lugar")) {
                        appState.openMobilityFlow()
                    }
                    .font(.footnote)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.top, DS.Space.md)
                    .accessibilityIdentifier("action.riseAndFlowButton")
                }

                Spacer().frame(height: DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("action.screen")
    }
}
