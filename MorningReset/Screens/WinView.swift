import SwiftUI

struct WinView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selfie_step_seen") private var selfieStepSeen = false

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("First win ✓")
                        .font(DS.Typo.label)
                        .tracking(1.4)
                        .foregroundStyle(DS.accent)

                    Text("You started.")
                        .font(DS.Typo.display)
                        .foregroundStyle(DS.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.xl)

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
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text("Optional")
                    .font(DS.Typo.label)
                    .tracking(1.2)
                    .foregroundStyle(DS.textDim)
                Text("Capture this moment.\nA small smile is enough.")
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DS.Space.xl)
            .padding(.bottom, DS.Space.lg)

            HStack(spacing: DS.Space.sm + 4) {
                Button("Skip") {
                    selfieStepSeen = true
                    proceed()
                }
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(DS.border, lineWidth: DS.hairline))

                Button("Done") {
                    selfieStepSeen = true
                    proceed()
                }
                .font(.system(.body, design: .serif))
                .foregroundStyle(DS.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .clipShape(Capsule())
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.xl)
        }
    }

    // MARK: - Normal continue

    private var doneButton: some View {
        Button("Done") {
            proceed()
        }
        .font(.system(.body, design: .serif))
        .tracking(0.5)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(DS.accent)
        .foregroundStyle(DS.background)
        .clipShape(Capsule())
        .padding(.horizontal, DS.Space.lg)
        .padding(.bottom, DS.Space.xl)
    }
}
