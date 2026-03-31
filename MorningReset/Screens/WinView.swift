import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selfie_step_seen") private var selfieStepSeen = false

    private var result: MorningResult {
        MorningData.result(from: appState.answers)
    }

    private var message: String {
        switch MorningMode(from: result.mode) ?? .steady {
        case .protect: return "You showed up.\nThat's all you needed to do."
        case .steady:  return "You started.\nKeep it clean."
        case .push:    return "Good start.\nNow build on it."
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("First win ✓")
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

    // MARK: - Shared progression

    private func proceed() {
        let current = UserDefaults.standard.integer(forKey: "completed_wins")
        let updated = current + 1
        if updated >= 7 {
            UserDefaults.standard.set(0, forKey: "completed_wins")
            appState.showCycleComplete()
        } else {
            UserDefaults.standard.set(updated, forKey: "completed_wins")
            appState.showAction()
        }
    }

    // MARK: - Selfie step (first run only)

    private var selfieSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Text("Capture this moment.\nA small smile is enough.")
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
                    proceed()
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("Continue") {
                    selfieStepSeen = true
                    proceed()
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

    // MARK: - Normal continue

    private var continueButton: some View {
        Button("Continue") {
            proceed()
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
