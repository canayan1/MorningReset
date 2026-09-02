import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState

    private var win: FirstWinPresentation { appState.ritualPresentation }

    private var practiceContext: (EnergyPath, String)? {
        guard let kind = appState.activeFirstWin?.kind else { return nil }
        if case .practice(let path, let id) = kind { return (path, id) }
        return nil
    }

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.45)

            VStack(alignment: .center, spacing: 0) {
                Spacer().frame(height: DS.Space.xl)

                // The action — icon-forward, nothing else competes
                VStack(alignment: .center, spacing: DS.Space.md) {
                    Image(systemName: win.symbol)
                        .font(.system(size: 68))
                        .foregroundStyle(DS.accent)

                    Text(win.title)
                        .font(DS.Typo.display)
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)

                    if !win.how.isEmpty {
                        Text(win.how)
                            .font(.callout)
                            .foregroundStyle(DS.textSecondary)
                            .lineSpacing(4)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                if let ctx = practiceContext {
                    PracticeVisual(path: ctx.0, practiceId: ctx.1, showYouTubeLink: true)
                        .frame(maxWidth: .infinity)
                        .padding(.top, DS.Space.lg)
                }

                if !win.steps.isEmpty {
                    Spacer().frame(height: DS.Space.xl)
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        ForEach(Array(win.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: DS.Space.md) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DS.accent)
                                    .frame(width: 16)
                                Text(step)
                                    .font(.callout)
                                    .foregroundStyle(DS.textPrimary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                Spacer()

                Button(L10n.text(en: "I did it", tr: "Yaptım", es: "Lo hice")) {
                    appState.completeFirstWin()
                }
                .primaryCTA()
                .accessibilityIdentifier("action.primaryButton")

                if appState.isPremium {
                    Button(L10n.text(en: "Open Rise & Flow instead", tr: "Bunun yerine Rise & Flow aç", es: "Abrir Rise & Flow en su lugar")) {
                        appState.openMobilityFlow()
                    }
                    .font(.footnote)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
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
