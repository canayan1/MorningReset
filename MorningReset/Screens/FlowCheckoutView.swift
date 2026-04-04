import SwiftUI

// MARK: - FlowCheckoutView
//
// Lightweight post-flow check-out screen. Designed to be completable in < 10 seconds.
// Tapping "Done" saves a FlowCheckout, triggers InsightEngine.refresh(), then calls endFlow().
// Tapping "Skip" calls endFlow() directly without saving.

struct FlowCheckoutView: View {
    @Environment(AppState.self)    private var appState
    @Environment(InsightEngine.self) private var insightEngine

    @State private var difficulty:   FlowDifficulty  = .neutral
    @State private var helpfulness:  FlowHelpfulness = .somewhat
    @State private var selectedTags: Set<FlowTag>    = []

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("CHECK-IN")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text("How did that feel?")
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg)

                difficultyRow

                Spacer().frame(height: DS.Space.md)

                helpfulnessRow

                Spacer().frame(height: DS.Space.md)

                tagSection

                Spacer()

                Button("Done") { saveAndContinue() }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.textPrimary)
                    .foregroundStyle(DS.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("Skip") { appState.endFlow() }
                    .font(.subheadline)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    // MARK: - Difficulty

    private var difficultyRow: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("DIFFICULTY")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            HStack(spacing: DS.Space.sm) {
                ForEach(FlowDifficulty.allCases, id: \.self) { option in
                    segmentButton(option.label, selected: difficulty == option) {
                        difficulty = option
                    }
                }
            }
        }
    }

    // MARK: - Helpfulness

    private var helpfulnessRow: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("DID THIS HELP?")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            HStack(spacing: DS.Space.sm) {
                ForEach(FlowHelpfulness.allCases, id: \.self) { option in
                    segmentButton(option.label, selected: helpfulness == option) {
                        helpfulness = option
                    }
                }
            }
        }
    }

    // MARK: - Tag section

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("HOW YOU FELT  (optional)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DS.Space.sm), count: 4),
                spacing: DS.Space.sm
            ) {
                ForEach(FlowTag.allCases, id: \.self) { tag in
                    tagPill(tag)
                }
            }
        }
    }

    // MARK: - Reusable components

    private func segmentButton(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.callout)
                .foregroundStyle(selected ? DS.background : DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? DS.textPrimary : DS.surface)
                .overlay(Rectangle().stroke(selected ? DS.textPrimary : DS.border, lineWidth: 1))
        }
    }

    private func tagPill(_ tag: FlowTag) -> some View {
        let active = selectedTags.contains(tag)
        return Button {
            if active { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
        } label: {
            Text(tag.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(active ? DS.background : DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(active ? DS.accent : DS.surface)
                .overlay(Rectangle().stroke(active ? DS.accent : DS.border, lineWidth: 1))
        }
    }

    // MARK: - Actions

    private func saveAndContinue() {
        let intentionStr = UserDefaults.standard.string(forKey: "selected_intention")
            ?? IntentionType.focus.rawValue

        let checkout = FlowCheckout(
            date:        Date(),
            mode:        appState.sessionMode.rawValue,
            intention:   intentionStr,
            streakCount: appState.streakCount,
            difficulty:  difficulty,
            helpfulness: helpfulness,
            tags:        Array(selectedTags)
        )
        FlowCheckoutStore.append(checkout)

        Task {
            await insightEngine.refresh(
                mode:      appState.sessionMode.rawValue,
                intention: intentionStr,
                streak:    appState.streakCount
            )
        }

        appState.endFlow()
    }
}
