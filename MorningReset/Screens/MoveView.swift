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
                "Lie still.\nThree deep breaths.\nThen sit up slowly.",
                "Sit at the edge of the bed.\nRoll your shoulders back.\nTwo minutes of stillness.",
                "Put your feet on the floor.\nSit upright.\nNotice how you feel.",
                "Breathe in for four counts.\nHold for four.\nOut for four.\nRepeat three times.",
            ]
        case .steady:
            pool = [
                "Stand up.\nWalk to the kitchen.\nDrink a glass of water.",
                "Stand up.\nStretch your arms overhead.\nHold for ten seconds.\nThen get water.",
                "Walk to the nearest window.\nLook outside for thirty seconds.\nThen get water.",
                "Stand up.\nWalk to another room and back.\nThen sit down with water.",
                "Stand up.\nRoll your neck side to side.\nDrink a glass of water.",
            ]
        case .push:
            pool = [
                "Stand up.\nDo 10 quick squats.",
                "Drop and do 10 push-ups.\nRight now.",
                "Stand up.\nJump 10 times.\nGo.",
                "15 jumping jacks.\nDon't think, just move.",
                "10 squats, 5 push-ups.\nDone.",
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
