import SwiftUI

// MARK: - AIInsightCardView
//
// Renders a DailyInsight or WeeklySummary as a surface card.
// Handles loading, content, and AI-generated badge states.

struct AIInsightCardView: View {
    let eyebrow: String
    let text: String
    var isLoading: Bool   = false
    var isAIGenerated: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(eyebrow)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Spacer()
                if isAIGenerated {
                    Text("AI")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(0.8)
                }
            }

            if isLoading {
                HStack(spacing: DS.Space.sm) {
                    ProgressView()
                        .tint(DS.textDim)
                        .scaleEffect(0.75)
                    Text("Reading your patterns…")
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                }
                .padding(.top, 2)
            } else {
                Text(text)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }
}

// MARK: - AIInsightCardLockedView
//
// Shown to non-premium users in place of the AI insight card.
// Teases without being pushy.

struct AIInsightCardLockedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Text("YOUR INSIGHT")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(DS.textDim)
            }
            Text("Your morning patterns, reflected back.")
                .font(.callout)
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(3)
            Text("Unlock with Premium.")
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

// MARK: - WeeklyInsightCardView
//
// Compact weekly summary card for AlarmView.

struct WeeklyInsightCardView: View {
    let summary: WeeklySummary

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text("THIS WEEK")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textSecondary)
                .kerning(1.2)

            Text(summary.headline)
                .font(.callout.bold())
                .foregroundStyle(DS.textPrimary)

            Text(summary.body)
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }
}
