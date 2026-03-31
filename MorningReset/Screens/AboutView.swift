import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer()

                VStack(alignment: .leading, spacing: 24) {
                    Text("About Morning Reset")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Morning Reset helps you break the habit of reaching for your phone when you wake up.")
                            .foregroundStyle(.white.opacity(0.8))

                        Text("Instead of scrolling, you take one small action.\n\nThat action becomes your first win.\n\nFrom there, the day feels easier to start.")
                            .foregroundStyle(.white.opacity(0.8))

                        Text("You don't need motivation.\nYou just need one small movement.\n\nThat's enough.")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.body)
                    .lineSpacing(3)
                }
                .padding(.horizontal, 24)

                Spacer()

                Text("Break the scroll. Start with a win.")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.white.opacity(0.2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }
}
