import SwiftUI

struct MoveView: View {
    @Environment(AppState.self) private var appState
    @State private var tapped = false

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    // Deterministic: same action for the entire calendar day, cycles through pool.
    private static var dayIndex: Int {
        Calendar.current.component(.day, from: Date())
    }

    private var action: String {
        let pool: [String]
        switch MorningMode(from: result.mode) ?? .steady {
        case .protect:
            pool = [
                "Sit up.\nFeet flat on the floor.\nFive slow breaths.",
                "Roll to your side.\nSit up slowly.\nThree breaths before standing.",
                "Sit at the edge of the bed.\nOpen the curtains.\nLet the light in.",
                "Sit up.\nDo three slow shoulder rolls.\nThen stand.",
                "Feet on the floor.\nSit still for thirty seconds.\nThen stand slowly.",
            ]
        case .steady:
            pool = [
                "Stand up.\nWalk to the kitchen.\nDrink a glass of water.",
                "Stand up.\nOpen the curtains.\nDrink a glass of water.",
                "Stand up.\nSplash cold water on your face.",
                "Stand up.\nStretch your arms overhead for ten seconds.\nThen get water.",
                "Stand up.\nStep outside for thirty seconds.\nThen get water.",
            ]
        case .push:
            pool = [
                "Stand up.\nDo 10 quick squats.",
                "Drop and do 10 push-ups.\nRight now.",
                "Stand up.\nJump 10 times.\nGo.",
                "Splash cold water on your face.\nThen do 5 fast squats.",
                "15 jumping jacks.\nNo warmup needed.",
            ]
        }
        return pool[Self.dayIndex % pool.count]
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

                Button("Do it now") {
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
