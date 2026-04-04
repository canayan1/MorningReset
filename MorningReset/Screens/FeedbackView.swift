import SwiftUI

struct FeedbackView: View {
    @Environment(AppState.self) private var appState
    @State private var appeared = false

    private var item: FeedbackItem {
        FeedbackContent.item(
            streak: appState.streakCount,
            mode: appState.sessionMode.rawValue
        )
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(item.tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: appeared)

                    Text(item.body)
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                        .lineSpacing(4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
                }

                Spacer().frame(height: DS.Space.lg)

                streakBadge
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 6)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

                Spacer()

                Button("Continue") {
                    appState.dismissFeedback()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
                .padding(.bottom, 48)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private var streakBadge: some View {
        let count = appState.streakCount
        if count > 0 {
            HStack(spacing: DS.Space.sm) {
                Rectangle()
                    .fill(DS.accent)
                    .frame(width: 2, height: 16)
                Text("\(count) day streak")
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
            }
        }
    }
}
