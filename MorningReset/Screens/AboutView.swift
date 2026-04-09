import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                }
                .padding(.top, DS.Space.lg)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.lg + 4) {
                    Text("About Morning Reset")
                        .font(DS.Typo.subtitle)
                        .foregroundStyle(DS.textPrimary)

                    VStack(alignment: .leading, spacing: DS.Space.md + 4) {
                        Text("Most mornings don't really start.")
                            .font(.body)
                            .foregroundStyle(DS.textPrimary)

                        Text("You wake up,\nreach for your phone,\nand begin reacting to everything around you.")
                            .foregroundStyle(DS.textSecondary)

                        Text("It feels harmless.\n\nBut it sets the tone of your day.")
                            .foregroundStyle(DS.textSecondary)

                        Text("Morning Reset interrupts that pattern.")
                            .foregroundStyle(DS.textSecondary)

                        Text("When the morning notification arrives,\ntap it instead of opening Instagram.\n\nThat one small action becomes your first win,\nand the day begins on your own terms.")
                            .foregroundStyle(DS.textSecondary)
                    }
                    .font(.body)
                    .lineSpacing(5)
                }
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                if !appState.isPremium {
                    Button("Upgrade to Premium") {
                        appState.recordManualPaywallShown()
                        showPaywall = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.md)
                }

                Text("Start with a win.")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(context: .onboarding, isSheet: true)
        }
    }
}
