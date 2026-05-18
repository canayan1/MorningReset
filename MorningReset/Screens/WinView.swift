import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @State private var appeared = false

    private var firstWin: FirstWinAction { appState.currentFirstWin }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(firstWin.winTitle)
                        .font(DS.Typo.display)
                        .foregroundStyle(DS.textPrimary)

                    Text(firstWin.winBody)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Button(L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")) {
                    appState.showFlowCheckout()
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
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
