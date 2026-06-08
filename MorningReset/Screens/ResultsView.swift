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
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Mode — the diagnosis, clean and large
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(result.mode.uppercased())
                        .font(.system(size: 42, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)

                    Text(result.meaning)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(3)
                }

                Spacer().frame(height: DS.Space.lg)

                // Mantra — the emotional note
                Text(mantra)
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(DS.textDim)

                Spacer().frame(height: DS.Space.xl)

                // Committed First Win — the morning's action
                committedWinCard

                Spacer()

                Button(L10n.text(en: "Begin", tr: "Başla", es: "Comenzar")) {
                    appState.advanceFromResults()
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
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
                .font(.system(size: 22))
                .foregroundStyle(DS.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
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
        .padding(DS.Space.md)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.border, lineWidth: DS.hairline))
        .accessibilityIdentifier("results.committedWin")
    }
}
