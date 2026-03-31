import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState
    @State private var panel: Panel = .main

    private enum Panel { case main, learn, action }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            switch panel {
            case .main:   mainPanel
            case .learn:  learnPanel
            case .action: actionPanel
            }
        }
    }

    // MARK: - Main

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("OPTIONAL")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textDim)
                    .kerning(1.2)

                Text("Keep going?")
                    .font(.title2.bold())
                    .foregroundStyle(DS.textPrimary)
            }

            Spacer().frame(height: 28)

            VStack(spacing: DS.Space.md) {
                sectionCard(
                    label: "INSIGHT",
                    preview: ActionContent.todayInsight
                ) { panel = .learn }

                sectionCard(
                    label: "ONE MORE STEP",
                    preview: ActionContent.todayBonusAction
                ) { panel = .action }
            }

            Spacer().frame(height: DS.Space.lg)

            Text("No bad vibes. No negative noise.")
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Learn

    private var learnPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "INSIGHT", value: ActionContent.todayInsight)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Action

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "ONE MORE STEP", value: ActionContent.todayBonusAction)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Shared

    private var backButton: some View {
        Button { panel = .main } label: {
            Label(Strings.Action.backButton, systemImage: "chevron.left")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
        }
    }

    private var doneButton: some View {
        Button("Done") { appState.endFlow() }
            .font(.subheadline)
            .foregroundStyle(DS.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
    }

    private func sectionCard(label: String, preview: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(preview)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.md)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }
}
