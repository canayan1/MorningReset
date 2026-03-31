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

                VStack(alignment: .leading, spacing: 28) {
                    Text("About Morning Reset")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Most mornings don't really start.")
                            .font(.body.bold())
                            .foregroundStyle(.white)

                        Text("You wake up,\nreach for your phone,\nand begin reacting to everything around you.")
                            .foregroundStyle(.white.opacity(0.8))

                        Text("It feels harmless.\n\nBut it sets the tone of your day.")
                            .foregroundStyle(.white.opacity(0.8))

                        Text("Morning Reset interrupts that pattern.")
                            .foregroundStyle(.white.opacity(0.8))

                        Text("Instead of scrolling,\nyou take one small action.\n\nThat action becomes your first win.\n\nFrom there,\nyou start your day on your own terms.")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.body)
                    .lineSpacing(4)
                }
                .padding(.horizontal, 24)

                Spacer()

                Text("Start with a win.")
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
