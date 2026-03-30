import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("selected_intention") private var selectedIntention: String = IntentionType.focus.rawValue

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text(Strings.Alarm.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Get up. Take two minutes.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                intentionGrid

                Spacer()

                Button(Strings.Alarm.startButton) {
                    appState.startFlow()
                }
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }

    private var intentionGrid: some View {
        VStack(spacing: 10) {
            Text("Today's intention")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ForEach(IntentionType.allCases, id: \.self) { intention in
                    Button(intention.label) {
                        selectedIntention = intention.rawValue
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedIntention == intention.rawValue
                            ? Color.white
                            : Color.white.opacity(0.08)
                    )
                    .foregroundStyle(
                        selectedIntention == intention.rawValue
                            ? Color.black
                            : Color.white
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 32)
        }
    }
}
