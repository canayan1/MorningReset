import SwiftUI

struct CycleCompleteView: View {
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
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    Text(IntentionType(rawValue: selectedIntention)?.label ?? "")
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.white)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: 8) {
                        Text("7 wins")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.white)
                        Text("You kept showing up.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a new direction")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.horizontal, 24)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        ForEach(IntentionType.allCases, id: \.self) { intention in
                            intentionCard(intention)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 32)

                Button("Start fresh") {
                    appState.endFlow()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
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
            VStack(alignment: .leading, spacing: 6) {
                Text(intention.label)
                    .font(.subheadline.bold())
                    .foregroundStyle(selected ? .black : .white)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? .black.opacity(0.6) : .white.opacity(0.25))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .padding(16)
            .background(selected ? Color.white : Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(selected ? 0 : 0.08), lineWidth: 1)
            )
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
