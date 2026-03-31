import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    private var message: String {
        switch MorningMode(from: result.mode) ?? .steady {
        case .protect: return "You showed up.\nThat's enough for now."
        case .steady:  return "You're in motion.\nKeep it clean."
        case .push:    return "Good.\nBuild on that."
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("First win")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))

                    Text(message)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

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
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
