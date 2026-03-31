import SwiftUI

struct GuidedPauseView: View {
    @Environment(AppState.self) private var appState

    private static var weekIndex: Int {
        Calendar.current.component(.weekOfYear, from: Date()) % 4
    }

    private let prompts: [(breath: String, reflect: String)] = [
        ("One slow breath.",           "What's worth your full attention today?"),
        ("Three quiet breaths.",       "What's one thing worth protecting today?"),
        ("Inhale. Hold. Release.",     "What would a clean first hour look like?"),
        ("Breathe in. Let it settle.", "What matters most before noon?"),
    ]

    private var prompt: (breath: String, reflect: String) {
        prompts[Self.weekIndex]
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("PAUSE")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text(prompt.breath)
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg)

                InfoCard(label: "REFLECT", value: prompt.reflect)

                Spacer()

                Button("Continue") {
                    appState.showAction()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 48)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }
}
