import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                row(label: Strings.Results.startWithLabel, value: result.startWith)

                VStack(alignment: .leading, spacing: 8) {
                    Text(result.mode)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Text(result.meaning)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }

                row(label: Strings.Results.avoidLabel, value: result.avoid)
                row(label: Strings.Results.winTodayLabel, value: result.win)

                Text(result.bonus)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))

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
            }
            .padding(.horizontal, 24)
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
