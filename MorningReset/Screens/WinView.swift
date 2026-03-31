import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selfie_step_seen") private var selfieStepSeen = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("First win ✓")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))

                    Text("You started.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)

                Spacer()

                if !selfieStepSeen {
                    selfieSection
                } else {
                    doneButton
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
            .padding(.horizontal, 40)
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

                Button("Done") {
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

    private var doneButton: some View {
        Button("Done") {
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
