import SwiftUI

struct WeeklyAffirmationView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("THIS WEEK")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text(MantraEngine.weeklyMantra())
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                        .lineSpacing(4)
                }

                Spacer().frame(height: DS.Space.lg)

                Text("Read it once. Say it three times if you want.")
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)

                Spacer()

                Button("Continue") {
                    appState.showMorningSound()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 48)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }
}
