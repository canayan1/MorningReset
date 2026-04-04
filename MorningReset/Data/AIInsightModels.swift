import Foundation

// MARK: - Context (input to AI service — summarized, no raw text)

struct AIInsightContext {
    let recentEntries: [DailyEntry]       // last 14 days max
    let recentCheckouts: [FlowCheckout]   // last 14 checkouts max
    let streakCount: Int
    let todayMode: String
    let todayIntention: String
}

// MARK: - Daily insight

struct DailyInsight: Codable {
    let reflection: String
    let recommendation: String
    let nextFlowSuggestion: String
    let generatedAt: Date
    let isAIGenerated: Bool
}

// MARK: - Weekly summary

struct WeeklySummary: Codable {
    let headline: String
    let body: String
    let completionCount: Int
    let generatedAt: Date
    let isAIGenerated: Bool
}
