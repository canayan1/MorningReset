import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var state
    let result: MorningResult
    @State private var modeSaved = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                Text("What's next?")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                actionCard(
                    title: "Learn one thing",
                    subtitle: "Read something worth your time.",
                    icon: "book.fill"
                ) {
                    // Placeholder — open a URL in a future iteration
                    if let url = URL(string: "https://example.com") {
                        UIApplication.shared.open(url)
                    }
                }

                actionCard(
                    title: modeSaved ? "Mode saved ✓" : "Lock in \(result.modeLabel)",
                    subtitle: "Save your mode for the day.",
                    icon: "flag.fill"
                ) {
                    state.saveMode(result.modeLabel)
                    modeSaved = true
                }
                .disabled(modeSaved)

                Spacer()

                Button {
                    state.endFlow()
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }

    private func actionCard(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())

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
