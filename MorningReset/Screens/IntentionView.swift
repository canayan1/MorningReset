import SwiftUI

struct IntentionView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selected_intention") private var selectedIntention: String = IntentionType.focus.rawValue

    private let descriptors: [IntentionType: String] = [
        .calm:        "settle the morning",
        .focus:       "one clear target",
        .energy:      "get it moving",
        .confidence:  "own what's ahead",
        .connection:  "open to others",
        .discipline:  "do it anyway",
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Text("What do you want from today?")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("Pick one.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
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
                    .font(.headline)
                    .foregroundStyle(selected ? .black : .white)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? .black.opacity(0.55) : .white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(selected ? Color.white : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
