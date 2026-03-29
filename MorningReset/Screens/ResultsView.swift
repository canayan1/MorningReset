import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your mode today")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(result.mode)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Do this now")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(result.suggestion)
                        .font(.body)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Watch out for")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(result.warning)
                        .font(.body)
                        .foregroundStyle(.white)
                }

                Spacer()

                Button("Continue") {
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
}
