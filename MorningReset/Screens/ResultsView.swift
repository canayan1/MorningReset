import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage("selected_intention") private var selectedIntention: String = IntentionType.focus.rawValue

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
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                row(label: Strings.Results.startWithLabel, value: result.startWith)
                    .opacity(revealed >= 1 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                VStack(alignment: .leading, spacing: 8) {
                    Text(result.mode)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Text(result.meaning)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(revealed >= 2 ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: revealed)

                row(label: Strings.Results.avoidLabel, value: result.avoid)
                    .opacity(revealed >= 3 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                row(label: Strings.Results.winTodayLabel, value: result.win)
                    .opacity(revealed >= 4 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                row(label: Strings.Results.musicLabel, value: result.music)
                    .opacity(revealed >= 5 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Text(result.bonus)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
                    .opacity(revealed >= 6 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Text(mantra)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.white.opacity(0.2))
                    .opacity(revealed >= 7 ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: revealed)

                Spacer()

                Button(Strings.Results.continueButton) {
                    appState.showAction()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 48)
                .opacity(revealed >= 7 ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: revealed)
            }
            .padding(.horizontal, 24)
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

    private func row(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            Text(value)
                .font(.body)
                .foregroundStyle(.white)
        }
    }
}
