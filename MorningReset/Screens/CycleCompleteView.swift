import SwiftUI

struct CycleCompleteView: View {
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

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    Text(IntentionType(rawValue: selectedIntention)?.label ?? "")
                        .font(DS.Typo.label)
                        .tracking(1.4)
                        .foregroundStyle(DS.background)
                        .padding(.horizontal, DS.Space.md)
                        .padding(.vertical, 7)
                        .background(DS.accent)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text("7 wins")
                            .font(.system(size: 52, design: .serif).weight(.regular))
                            .foregroundStyle(DS.textPrimary)
                        Text("You kept showing up.")
                            .font(.body)
                            .foregroundStyle(DS.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("Choose a new direction")
                        .font(DS.Typo.label)
                        .tracking(1.2)
                        .foregroundStyle(DS.textDim)
                        .padding(.horizontal, DS.Space.lg)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: DS.Space.sm + 2
                    ) {
                        ForEach(IntentionType.allCases, id: \.self) { intention in
                            intentionCard(intention)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                }

                Spacer().frame(height: DS.Space.xl - 8)

                Button("Start fresh") {
                    appState.endFlow()
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }

    private func intentionCard(_ intention: IntentionType) -> some View {
        let selected = selectedIntention == intention.rawValue
        return Button {
            selectedIntention = intention.rawValue
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(intention.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selected ? DS.background : DS.textPrimary)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? DS.background.opacity(0.8) : DS.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .padding(DS.Space.md)
            .background(selected ? DS.accent : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selected ? Color.clear : DS.border, lineWidth: DS.hairline)
            )
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
