import SwiftUI

struct IntentionView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(UDKey.selectedIntention) private var selectedIntention: String = IntentionType.focus.rawValue

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

            VStack(alignment: .leading, spacing: 0) {

                // Header — anchored near top, left-aligned
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("INTENTION")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text("Choose today's direction.")
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)

                    Text("Pick the quality you want to return to today.")
                        .font(.footnote)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(2)
                }
                .padding(.top, 56)
                .padding(.horizontal, DS.Space.lg)

                Spacer().frame(height: 32)

                // Intention grid
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(IntentionType.allCases, id: \.self) { intention in
                        intentionCard(intention)
                    }
                }
                .padding(.horizontal, DS.Space.lg)

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
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, 48)
            }
        }
    }

    private func intentionCard(_ intention: IntentionType) -> some View {
        let selected = selectedIntention == intention.rawValue
        return Button {
            selectedIntention = intention.rawValue
        } label: {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(intention.label)
                    .font(.callout.bold())
                    .foregroundStyle(selected ? DS.background : DS.textPrimary)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? DS.background.opacity(0.8) : DS.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
            .padding(DS.Space.md)
            .background(selected ? DS.accent : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selected ? Color.clear : DS.border, lineWidth: 1)
            )
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
