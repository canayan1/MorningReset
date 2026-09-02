import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage(UDKey.selectedIntention) private var selectedIntention: String = IntentionType.focus.rawValue

    private var result: MorningResult {
        MorningData.result(for: appState.sessionMode)
    }

    private var mode: MorningMode { appState.sessionMode }

    private var mantra: String {
        let intention = IntentionType(rawValue: selectedIntention) ?? .focus
        return MantraEngine.generate(mode: mode, intention: intention)
    }

    private var recommendedFirstWin: FirstWinAction {
        ActionContent.recommendedFirstWin(for: mode)
    }

    private var selectedFirstWin: FirstWinAction {
        appState.selectedFirstWin ?? recommendedFirstWin
    }

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.45)

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                if let sym = appState.activePath?.symbol {
                    Image(systemName: sym)
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundStyle(DS.accent.opacity(0.7))
                        .padding(.bottom, DS.Space.lg)
                }

                // Mode — the diagnosis, clean and large
                VStack(alignment: .center, spacing: DS.Space.xs) {
                    Text(result.mode.uppercased())
                        .font(.system(size: 56, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(result.meaning)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: DS.Space.lg)

                // Mantra — the emotional note
                Text(mantra)
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(DS.textDim)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: DS.Space.xl)

                // Committed First Win — the morning's action
                committedWinCard

                Spacer()

                Button(L10n.text(en: "Begin", tr: "Başla", es: "Comenzar")) {
                    appState.advanceFromResults()
                }
                .primaryCTA()
                .padding(.bottom, DS.Space.xl)
                .accessibilityIdentifier("results.continueButton")
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("results.screen")
        .onAppear {
            appState.selectFirstWin(selectedFirstWin)
        }
    }

    private var committedWinCard: some View {
        let win = appState.ritualPresentation
        return HStack(spacing: DS.Space.md) {
            Image(systemName: win.symbol)
                .font(.system(size: 28))
                .foregroundStyle(DS.accent)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.text(en: "YOUR FIRST WIN", tr: "FIRST WIN'İN", es: "TU FIRST WIN"))
                    .font(.system(size: 9, weight: .semibold))
                    .kerning(1.2)
                    .foregroundStyle(DS.textDim)
                Text(win.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(DS.textPrimary)
                if !win.how.isEmpty {
                    Text(win.how)
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
            }
            Spacer()
        }
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.border, lineWidth: DS.hairline))
        .accessibilityIdentifier("results.committedWin")
    }
}
