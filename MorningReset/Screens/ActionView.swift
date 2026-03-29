import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var panel: Panel = .main

    private enum Panel { case main, learn, mode }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Group {
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

            Text("What's next?")
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

            Button("Skip") { appState.endFlow() }
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
                linkCard(headline: "Why your first hour shapes the whole day",
                         url: "https://example.com")
                linkCard(headline: "The case for a no-phone morning",
                         url: "https://example.com")
                linkCard(headline: "One habit that changes everything",
                         url: "https://example.com")
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
                linkCard(headline: "Focus", url: "https://example.com")
                linkCard(headline: "Chill",  url: "https://example.com")
                linkCard(headline: "Energy", url: "https://example.com")
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Shared components

    private var backButton: some View {
        Button("← Back") { panel = .main }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.5))
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

    private func linkCard(headline: String, url: String) -> some View {
        Button {
            if let u = URL(string: url) { openURL(u) }
        } label: {
            HStack {
                Text(headline)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
