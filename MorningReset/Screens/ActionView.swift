import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState
    @State private var panel: Panel = .main

    private enum Panel { case main, learn, headlines, action }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZStack {
                switch panel {
                case .main:      mainPanel
                case .learn:     learnPanel
                case .headlines: headlinesPanel
                case .action:    actionPanel
                }
            }
        }
    }

    // MARK: - Main

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Want to keep going?")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Spacer().frame(height: 28)

            VStack(spacing: 16) {
                sectionCard(title: "Learn something new", subtitle: "One insight worth keeping.") {
                    panel = .learn
                }
                sectionCard(title: "Stay informed", subtitle: "Brief and neutral.") {
                    panel = .headlines
                }
                sectionCard(title: "One more step", subtitle: "One small action.") {
                    panel = .action
                }
            }

            Spacer()

            doneButton
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Learn

    private var learnPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: 28)

            Text(ActionContent.todayInsight)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            doneButton
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Headlines

    private var headlinesPanel: some View {
        let headlines = ActionContent.todayHeadlines
        return VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: 28)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(headlines.enumerated()), id: \.offset) { index, headline in
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    if index < headlines.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            doneButton
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Action

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: 28)

            VStack(alignment: .leading, spacing: 16) {
                Text("One more.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Text(ActionContent.todayBonusAction)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .lineSpacing(5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(28)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            doneButton
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Shared

    private var backButton: some View {
        Button { panel = .main } label: {
            Label(Strings.Action.backButton, systemImage: "chevron.left")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var doneButton: some View {
        Button("Done") { appState.endFlow() }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
    }

    private func sectionCard(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
