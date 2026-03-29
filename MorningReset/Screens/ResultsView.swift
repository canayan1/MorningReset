import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var state
    let result: MorningResult

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your morning mode")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(result.modeLabel)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                Divider().overlay(Color.white.opacity(0.2))

                resultRow(
                    label: "Do this now",
                    icon: "arrow.right.circle.fill",
                    text: result.suggestion
                )

                resultRow(
                    label: "Watch out for",
                    icon: "exclamationmark.triangle.fill",
                    text: result.warning
                )

                Spacer()

                Button {
                    state.proceedToAction(result: result)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.bottom, 48)
            }
            .padding(.horizontal, 24)
        }
    }

    private func resultRow(label: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.5))
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
                .lineSpacing(4)
        }
    }
}
