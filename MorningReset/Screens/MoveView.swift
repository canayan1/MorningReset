import SwiftUI

struct MoveView: View {
    @Environment(AppState.self) private var appState
    @State private var tapped = false

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    private var action: String {
        switch MorningMode(from: result.mode) ?? .steady {
        case .protect: return "Sit at the edge of your bed.\nFeet flat on the floor.\nThree slow breaths."
        case .steady:  return "Stand up.\nPour a glass of water.\nDrink it slowly."
        case .push:    return "Ten squats.\nRight now, before anything else."
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("One thing first.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))

                    Text(action)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)

                Spacer()

                Button("I did it") {
                    guard !tapped else { return }
                    tapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.showWin()
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .disabled(tapped)
                .sensoryFeedback(.success, trigger: tapped)
            }
        }
    }
}
