import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selfie_step_seen") private var selfieStepSeen = false

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

                if !selfieStepSeen {
                    selfieSection
                } else {
                    continueButton
                }
            }
        }
    }

    private var selfieSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Text("Take a quick photo of yourself.\nJust a small smile is enough.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            HStack(spacing: 12) {
                Button("Skip") {
                    selfieStepSeen = true
                    appState.showAction()
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("Continue") {
                    selfieStepSeen = true
                    appState.showAction()
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var continueButton: some View {
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
