import SwiftUI

struct InsightPreviewView: View {
    @Environment(AppState.self) private var appState

    private var eyebrow: String {
        switch appState.insightStrength {
        case .none:   return "TODAY"
        case .weak:   return "THIS WEEK"
        case .strong: return "PATTERN"
        }
    }

    private var title: String {
        switch appState.insightStrength {
        case .none:   return "One thing to carry forward."
        case .weak:   return "Something worth noticing."
        case .strong: return appState.isPremium
            ? "What's been showing up."
            : "Something has been showing up."
        }
    }

    private var cardLabel: String {
        switch appState.insightStrength {
        case .none:   return "REFLECTION"
        case .weak:   return "OBSERVATION"
        case .strong: return "PATTERN"
        }
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(eyebrow)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg)

                contentCard

                Spacer().frame(height: DS.Space.md)

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("THIS WEEK")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)
                    Text(MantraEngine.weeklyMantra())
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(3)
                }

                Spacer()

                Button("Continue") {
                    appState.advanceFromInsightPreview()
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

    @ViewBuilder
    private var contentCard: some View {
        if appState.insightStrength == .strong && !appState.isPremium {
            lockedTeaser
        } else {
            InfoCard(label: cardLabel, value: appState.insightText)
        }
    }

    private var lockedTeaser: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Text("PATTERN")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(DS.textDim)
            }
            Text("Your mornings this week have a shape to them.")
                .font(.callout)
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(3)
            Text("Premium shows you what it is.")
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .padding(.top, DS.Space.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }
}
