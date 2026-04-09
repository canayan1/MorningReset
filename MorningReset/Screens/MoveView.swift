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
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(action)
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(10)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Space.xl)

                Spacer()

                VStack(spacing: DS.Space.md) {
                    Button("Start") {
                        guard !tapped else { return }
                        tapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            appState.showWin()
                        }
                    }
                    .font(.system(.body, design: .serif))
                    .tracking(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())
                    .disabled(tapped)
                    .sensoryFeedback(.success, trigger: tapped)

                    Text("Stay here.")
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }
}
