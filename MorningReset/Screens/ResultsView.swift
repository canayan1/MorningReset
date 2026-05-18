import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage(UDKey.selectedIntention) private var selectedIntention: String = IntentionType.focus.rawValue

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    private var mode: MorningMode {
        MorningMode(from: result.mode) ?? .steady
    }

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

                // First win options — title only, no noise
                VStack(spacing: DS.Space.sm) {
                    ForEach(ActionContent.orderedFirstWins(for: mode)) { firstWin in
                        firstWinButton(firstWin)
                    }
                }

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

    private func firstWinButton(_ firstWin: FirstWinAction) -> some View {
        let selected = firstWin == selectedFirstWin

        return Button {
            appState.selectFirstWin(firstWin)
        } label: {
            Text(firstWin.title)
                .font(selected ? .body.weight(.medium) : .body)
                .foregroundStyle(selected ? DS.background : DS.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selected ? DS.accent : DS.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
        .animation(.easeOut(duration: 0.15), value: selected)
        .accessibilityIdentifier("results.firstWin.\(firstWin.rawValue)")
    }
}
