import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState
    @State private var panel: Panel = .main

    private enum Panel { case main, learn, mode }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZStack {
                switch panel {
                case .main:  mainPanel
                case .learn: learnPanel
                case .mode:  modePanel
                }
            }
        }
    }

    // MARK: - Main

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            Text(Strings.Action.heading)
                .font(.title2.bold())
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                sectionCard(title: "Learn one thing", subtitle: "Read something worth your time.") {
                    panel = .learn
                }
                sectionCard(title: "Choose your mode", subtitle: "Pick a soundtrack for the day.") {
                    panel = .mode
                }
            }

            Spacer()

            Button(Strings.Action.skipButton) { appState.endFlow() }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Learn

    private var learnPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            backButton

            VStack(spacing: 12) {
                ForEach(ActionContent.articles, id: \.headline) { article in
                    contentCard(headline: article.headline, body: article.body)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Mode

    private var modePanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            backButton

            VStack(spacing: 12) {
                ForEach(ActionContent.playlists, id: \.title) { playlist in
                    contentCard(headline: playlist.title, body: playlist.description)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Shared components

    private var backButton: some View {
        Button { panel = .main } label: {
            Label(Strings.Action.backButton, systemImage: "chevron.left")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
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

    private func contentCard(headline: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(headline)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
            Text(body)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
