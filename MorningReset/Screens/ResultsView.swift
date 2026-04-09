import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage(UDKey.selectedIntention) private var selectedIntention: String = IntentionType.focus.rawValue

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    private var mantra: String {
        let intention = IntentionType(rawValue: selectedIntention) ?? .focus
        let mode = MorningMode(from: result.mode) ?? .steady
        return MantraEngine.generate(mode: mode, intention: intention)
    }

    @State private var revealed: Int = 0

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Spacer()

                modeBlock
                    .opacity(revealed >= 1 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                InfoCard(label: Strings.Results.startWithLabel, value: result.startWith)
                    .opacity(revealed >= 2 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                InfoCard(label: Strings.Results.avoidLabel, value: result.avoid)
                    .opacity(revealed >= 3 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                InfoCard(label: Strings.Results.winTodayLabel, value: result.win)
                    .opacity(revealed >= 4 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                InfoCard(label: Strings.Results.musicLabel, value: result.music)
                    .opacity(revealed >= 5 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Text(result.bonus)
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                    .padding(.top, DS.Space.sm)
                    .opacity(revealed >= 6 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Text(mantra)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(DS.textDim)
                    .opacity(revealed >= 7 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Spacer()

                Button(Strings.Results.continueButton) {
                    appState.advanceFromResults()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(Rectangle())
                .padding(.bottom, 48)
                .opacity(revealed >= 7 ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: revealed)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .task {
            try? await Task.sleep(nanoseconds:  80_000_000)
            revealed = 1
            try? await Task.sleep(nanoseconds: 120_000_000)
            revealed = 2
            try? await Task.sleep(nanoseconds: 220_000_000)
            revealed = 3
            try? await Task.sleep(nanoseconds: 240_000_000)
            revealed = 4
            try? await Task.sleep(nanoseconds: 260_000_000)
            revealed = 5
            try? await Task.sleep(nanoseconds: 300_000_000)
            revealed = 6
            try? await Task.sleep(nanoseconds: 350_000_000)
            revealed = 7
        }
    }

    // MARK: - Mode block

    private var modeBlock: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(DS.accent)
                .frame(width: 2)

            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("MODE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(result.mode.uppercased())
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(DS.textPrimary)
                Text(result.meaning)
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.surface)
        }
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }
}
