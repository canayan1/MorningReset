import SwiftUI

struct IntentionView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selected_intention") private var selectedIntention: String = IntentionType.focus.rawValue

    private let descriptors: [IntentionType: String] = [
        .calm:        "Move without noise",
        .focus:       "Stay with what matters",
        .energy:      "Protect and use your fuel well",
        .confidence:  "Trust your next move",
        .connection:  "Show up with presence",
        .discipline:  "Return to clean action",
    ]

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Choose today's direction")
                        .font(.title3.bold())
                        .foregroundStyle(DS.textPrimary)
                    Text("Pick the quality you want to return to today.")
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 36)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(IntentionType.allCases, id: \.self) { intention in
                        intentionCard(intention)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button("Continue") {
                    appState.showResults()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func intentionCard(_ intention: IntentionType) -> some View {
        let selected = selectedIntention == intention.rawValue
        return Button {
            selectedIntention = intention.rawValue
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(intention.label)
                    .font(.subheadline.bold())
                    .foregroundStyle(selected ? DS.background : DS.textPrimary)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? DS.background.opacity(0.7) : DS.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .padding(16)
            .background(selected ? DS.textPrimary : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selected ? Color.clear : DS.border, lineWidth: 1)
            )
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
