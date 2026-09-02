import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @State private var appeared = false

    private var win: FirstWinPresentation { appState.ritualPresentation }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                VStack(alignment: .center, spacing: DS.Space.md) {
                    Image(systemName: win.symbol)
                        .font(.system(size: 40))
                        .foregroundStyle(DS.accent)

                    Text(win.winTitle)
                        .font(DS.Typo.display)
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(win.winBody)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Button(L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")) {
                    appState.showFlowCheckout()
                }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
                .accessibilityIdentifier("win.continueButton")
            }
        }
        .accessibilityIdentifier("win.screen")
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear { appeared = true }
    }
}
