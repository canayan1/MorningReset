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
                "Sit up.\nFeet down.\nThree slow breaths.",
                "Sit up.\nLook around the room.\nStay for 10 seconds.",
                "Feet on the floor.\nHands on your knees.\nBreathe slowly.",
                "Sit up.\nStretch your neck slowly.\nLeft and right.",
                "Sit at the edge of the bed.\nStay there.\nBreathe.",
                "Feet down.\nBack straight.\nThree slow inhales.",
                "Sit up.\nPlace one hand on your chest.\nBreathe slowly.",
            ]
        case .steady:
            pool = [
                "Stand up.\nGet water.\nDrink slowly.",
                "Stand up.\nWalk to the kitchen.\nPause there.",
                "Stand up.\nOpen a window.\nTake one breath.",
                "Stand up.\nTurn on the light.\nStep forward.",
                "Stand up.\nTake 5 steps.\nStop.",
                "Stand up.\nStretch your arms up.\nHold for 5 seconds.",
                "Stand up.\nWalk across the room.\nTurn back.",
            ]
        case .push:
            pool = [
                "Ten squats.\nNow.",
                "Jump in place.\n10 seconds.",
                "Five push-ups.\nRight now.",
                "Fast walk across the room.\nTwice.",
                "Arms up.\nShake out your body.\n10 seconds.",
                "Step forward fast.\nTurn.\nRepeat.",
                "Quick stretch.\nReach high.\nThen move.",
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
                    Text("Right now.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))

                    Text(action)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineSpacing(8)
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
