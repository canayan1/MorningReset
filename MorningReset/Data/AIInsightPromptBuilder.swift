import Foundation

// MARK: - Prompt builder
//
// Constructs structured, bounded prompts from summarized context.
// Raw user history is never sent — only aggregated signals.

enum AIInsightPromptBuilder {

    static let systemPrompt = """
You are the reflection layer for a minimal iOS morning reset app.
Give short, calm, useful observations about the user's morning flow patterns.

Rules:
- Maximum 2 sentences. Never more.
- Tone: calm, human, observational. Never preachy or clinical.
- Never use: "AI", "algorithm", "data", "mental health", "healing", "journey", "synergy".
- Never overclaim. Speak to tendencies, not certainties.
- Output plain text only. No markdown, no lists.

Good examples:
"You seem to respond well to shorter calming resets on busy days."
"Your consistency is stronger when the flow feels light rather than intense."
"This week, grounding sessions were easier for you to complete than energizing ones."
"""

    static func buildDailyPrompt(context: AIInsightContext) -> String {
        var lines: [String] = []
        lines.append("Today's mode: \(context.todayMode)")
        lines.append("Streak: \(context.streakCount) days")

        let checkouts = Array(context.recentCheckouts.suffix(7))
        if !checkouts.isEmpty {
            let diffs = checkouts.map { $0.difficulty.rawValue }.joined(separator: ", ")
            let helps = checkouts.map { $0.helpfulness.rawValue }.joined(separator: ", ")
            let tags  = checkouts.flatMap { $0.tags.map(\.rawValue) }
            lines.append("Recent difficulties (oldest first): \(diffs)")
            lines.append("Whether each felt useful: \(helps)")
            if !tags.isEmpty {
                lines.append("Common feelings: \(tags.joined(separator: ", "))")
            }
        }
        lines.append("\nWrite a 1–2 sentence daily reflection for this user.")
        return lines.joined(separator: "\n")
    }

    static func buildWeeklyPrompt(context: AIInsightContext) -> String {
        var lines: [String] = []
        let entries   = Array(context.recentEntries.suffix(7))
        let checkouts = Array(context.recentCheckouts.suffix(7))
        lines.append("Flows completed this week: \(entries.count) of 7")

        if !checkouts.isEmpty {
            let diffs = checkouts.map { $0.difficulty.rawValue }.joined(separator: ", ")
            let helps = checkouts.map { $0.helpfulness.rawValue }.joined(separator: ", ")
            let tags  = checkouts.flatMap { $0.tags.map(\.rawValue) }
            lines.append("Session difficulties: \(diffs)")
            lines.append("Session helpfulness: \(helps)")
            if !tags.isEmpty {
                lines.append("Feelings noted: \(tags.joined(separator: ", "))")
            }
        }
        lines.append("\nWrite a 1–2 sentence weekly pattern summary for this user.")
        return lines.joined(separator: "\n")
    }
}
