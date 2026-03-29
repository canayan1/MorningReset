import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                Text("What's next?")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    actionCard(title: "Learn one thing", subtitle: "Read something worth your time.") {
                        // Placeholder — URL will be added later
                    }

                    actionCard(title: "Choose your mode", subtitle: "Lock in your intention for the day.") {
                        // Placeholder — mode selection will be added later
                    }
                }

                Spacer()

                Button("Skip") {
                    appState.endFlow()
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }

    private func actionCard(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
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
