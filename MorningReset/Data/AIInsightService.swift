import Foundation
import FoundationModels

// MARK: - Protocol

protocol AIInsightService {
    func dailyInsight(context: AIInsightContext) async throws -> DailyInsight
    func weeklySummary(context: AIInsightContext) async throws -> WeeklySummary
}

// MARK: - Local (always available, no API key needed)

final class LocalAIInsightService: AIInsightService {

    func dailyInsight(context: AIInsightContext) async throws -> DailyInsight {
        let checkouts = Array(context.recentCheckouts.suffix(7))
        return DailyInsight(
            reflection:          buildReflection(checkouts: checkouts, mode: context.todayMode),
            recommendation:      buildRecommendation(checkouts: checkouts),
            nextFlowSuggestion:  buildNextFlowSuggestion(checkouts: checkouts, mode: context.todayMode),
            generatedAt:         Date(),
            isAIGenerated:       false
        )
    }

    func weeklySummary(context: AIInsightContext) async throws -> WeeklySummary {
        let checkouts = Array(context.recentCheckouts.suffix(7))
        let entries   = Array(context.recentEntries.suffix(7))
        return WeeklySummary(
            headline:        buildWeeklyHeadline(entries: entries),
            body:            buildWeeklyBody(checkouts: checkouts, entries: entries),
            completionCount: entries.count,
            generatedAt:     Date(),
            isAIGenerated:   false
        )
    }

    // MARK: - Daily builders

    private func buildReflection(checkouts: [FlowCheckout], mode: String) -> String {
        if checkouts.isEmpty {
            switch mode {
            case "push":    return "You're moving with intention today."
            case "protect": return "A lighter morning can be exactly the right call."
            default:        return "Steady starts tend to carry further."
            }
        }
        let completedCount = checkouts.filter { $0.firstWinStatus == .done }.count
        let helpfulCount = checkouts.filter { $0.helpfulness == .yes }.count
        let easyCount    = checkouts.filter { $0.difficulty  == .easy }.count
        let dominantTag  = checkouts.flatMap { $0.tags }.mostFrequent()

        if completedCount == checkouts.count {
            return "You've been closing the loop on your first win consistently. That follow-through matters."
        }
        if completedCount <= max(1, checkouts.count / 3) {
            return "The first win still looks like the friction point. Smaller and more physical may land better."
        }
        if helpfulCount >= Int(ceil(Double(checkouts.count) * 0.7)) {
            return "Your recent flows are landing well. Keep the rhythm going."
        }
        if easyCount >= checkouts.count / 2 {
            return "Lighter flows seem to suit you right now."
        }
        if let tag = dominantTag {
            switch tag {
            case .calm, .grounded:
                return "You've been finding calm in these sessions lately."
            case .focused, .energized:
                return "Your energy through these flows has been consistent."
            case .sleepy, .restless:
                return "Your body's still settling into the morning. That's worth knowing."
            case .stressed, .distracted:
                return "Busy mornings are hard to reset from. Even a short flow counts."
            }
        }
        return "You showed up. That's always the first step."
    }

    private func buildRecommendation(checkouts: [FlowCheckout]) -> String {
        let recent = Array(checkouts.suffix(5))
        if recent.isEmpty { return "Try a shorter flow tomorrow if today felt like a stretch." }

        let missedWins  = recent.filter { $0.firstWinStatus == .notYet }.count
        let hardCount   = recent.filter { $0.difficulty == .hard }.count
        let notHelpful  = recent.filter { $0.helpfulness == .no }.count
        let easyHelpful = recent.filter { $0.difficulty == .easy && $0.helpfulness == .yes }

        if missedWins >= 2 {
            return "Make tomorrow's first win smaller and easier to complete before you reach for input."
        }
        if hardCount >= 3 {
            return "Flows have felt heavy lately. A lighter format might be a better fit for now."
        }
        if notHelpful >= 2 {
            return "Try adjusting the intensity — a gentler flow might land better right now."
        }
        if easyHelpful.count >= 2 {
            return "Shorter, easier flows are working well for you. Stick with that pace."
        }
        return "Keep the consistency. Even a steady flow builds something over time."
    }

    private func buildNextFlowSuggestion(checkouts: [FlowCheckout], mode: String) -> String {
        guard let last = checkouts.last else { return "Same pace tomorrow." }

        if last.firstWinStatus == .notYet {
            return "Pick a simpler first win tomorrow and close it before you open the day."
        }
        if last.difficulty == .hard || last.helpfulness == .no {
            return "A calmer, shorter reset tomorrow."
        }
        if last.difficulty == .easy && last.helpfulness == .yes {
            switch mode {
            case "push":    return "Stay with a driven format. It's working."
            case "protect": return "Light flows are the right rhythm right now."
            default:        return "Your steady pace is working. Keep going."
            }
        }
        return "Same pace tomorrow."
    }

    // MARK: - Weekly builders

    private func buildWeeklyHeadline(entries: [DailyEntry]) -> String {
        let n = entries.count
        switch n {
        case 7:        return "A full week of resets."
        case 5, 6:     return "Strong week."
        case 3, 4:     return "\(n) flows this week."
        case 1, 2:     return "\(n == 1 ? "One" : "Two") reset\(n == 1 ? "" : "s") this week."
        default:       return "A quiet week."
        }
    }

    private func buildWeeklyBody(checkouts: [FlowCheckout], entries: [DailyEntry]) -> String {
        if checkouts.isEmpty {
            let n = entries.count
            if n >= 5  { return "You completed \(n) flows this week. Consistency like this builds over time." }
            if n >= 3  { return "Three flows is a real foundation. See if you can add one more next week." }
            if n >= 1  { return "Every flow shifts the next one slightly. Keep going." }
            return "Even one flow is worth more than none. Start there next week."
        }

        let completedWins = checkouts.filter { $0.firstWinStatus == .done }.count
        let helpful = checkouts.filter { $0.helpfulness != .no }.count
        let easy    = checkouts.filter { $0.difficulty == .easy }.count
        let hard    = checkouts.filter { $0.difficulty == .hard }.count

        if completedWins == checkouts.count {
            return "You followed through on your first win every time this week. That kind of clean start compounds."
        }
        if completedWins <= checkouts.count / 2 {
            return "The first win is still where mornings slip. Make that step smaller and easier next week."
        }
        if helpful == checkouts.count {
            return "Every flow this week felt useful. That kind of consistency is rare — protect it."
        }
        if easy > hard {
            return "Lighter flows dominated this week and they landed well. That's data worth keeping."
        }
        if hard > easy {
            return "Some sessions were a stretch. Easier flows might serve you better for now."
        }
        let dominantMode = entries.map { $0.mode }.mostFrequent()
        switch dominantMode {
        case "push":    return "This was a driven week. Make sure recovery is built in too."
        case "protect": return "This was a quieter week. Sometimes that's exactly what's needed."
        default:        return "Steady across the week. That kind of consistency compounds quietly."
        }
    }
}

// MARK: - Apple Intelligence (iOS 26+, on-device, no cost)

@available(iOS 26, *)
final class AppleIntelligenceInsightService: AIInsightService {

    func dailyInsight(context: AIInsightContext) async throws -> DailyInsight {
        guard case .available = SystemLanguageModel.default.availability else {
            throw CocoaError(.featureUnsupported)
        }
        let session = LanguageModelSession(instructions: AIInsightPromptBuilder.systemPrompt)
        let response = try await session.respond(
            to: AIInsightPromptBuilder.buildDailyPrompt(context: context)
        )
        return DailyInsight(
            reflection:         response.content,
            recommendation:     "",
            nextFlowSuggestion: "",
            generatedAt:        Date(),
            isAIGenerated:      true
        )
    }

    func weeklySummary(context: AIInsightContext) async throws -> WeeklySummary {
        guard case .available = SystemLanguageModel.default.availability else {
            throw CocoaError(.featureUnsupported)
        }
        let session = LanguageModelSession(instructions: AIInsightPromptBuilder.systemPrompt)
        let response = try await session.respond(
            to: AIInsightPromptBuilder.buildWeeklyPrompt(context: context)
        )
        return WeeklySummary(
            headline:        "This week",
            body:            response.content,
            completionCount: context.recentEntries.count,
            generatedAt:     Date(),
            isAIGenerated:   true
        )
    }
}

// MARK: - Intention Advisor (rule-based, all users)

enum IntentionAdvisor {

    static func advise(entries: [DailyEntry], checkouts: [FlowCheckout], streakCount: Int) -> String? {
        let recentEntries   = Array(entries.suffix(7))
        let recentCheckouts = Array(checkouts.suffix(5))

        let hardCount  = recentCheckouts.filter { $0.difficulty == .hard }.count
        let notHelpful = recentCheckouts.filter { $0.helpfulness == .no }.count
        if hardCount >= 3 || notHelpful >= 2 {
            return "Recent flows have felt heavy. Consider a lighter start today."
        }

        if recentEntries.count >= 3 {
            let modes = recentEntries.map { $0.mode }
            if let dominant = mostFrequent(modes), modes.filter({ $0 == dominant }).count >= 3 {
                switch dominant {
                case "protect": return "You've been in protect mode lately. A lighter start might carry better today."
                case "push":    return "You've been pushing consistently. Notice if today calls for a softer start."
                default: break
                }
            }
        }

        if streakCount == 6 || streakCount == 13 || streakCount == 29 {
            return "One more reset and you'll hit \(streakCount + 1) days in a row."
        }

        if recentCheckouts.count >= 3,
           recentCheckouts.suffix(3).allSatisfy({ $0.helpfulness == .yes }) {
            return "Your last few flows have all landed well. Keep that rhythm."
        }

        return nil
    }

    private static func mostFrequent<T: Hashable>(_ items: [T]) -> T? {
        var counts: [T: Int] = [:]
        for item in items { counts[item, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Remote (OpenAI-ready stub)

final class RemoteAIInsightService: AIInsightService {

    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func dailyInsight(context: AIInsightContext) async throws -> DailyInsight {
        let text = try await send(AIInsightPromptBuilder.buildDailyPrompt(context: context))
        return DailyInsight(
            reflection: text, recommendation: "", nextFlowSuggestion: "",
            generatedAt: Date(), isAIGenerated: true
        )
    }

    func weeklySummary(context: AIInsightContext) async throws -> WeeklySummary {
        let text = try await send(AIInsightPromptBuilder.buildWeeklyPrompt(context: context))
        return WeeklySummary(
            headline: "This week",
            body: text,
            completionCount: context.recentEntries.count,
            generatedAt: Date(),
            isAIGenerated: true
        )
    }

    private func send(_ userPrompt: String) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "max_tokens": 80,
            "messages": [
                ["role": "system", "content": AIInsightPromptBuilder.systemPrompt],
                ["role": "user",   "content": userPrompt]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        guard
            let json    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw URLError(.cannotParseResponse) }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Helpers

private extension Array where Element: Hashable {
    func mostFrequent() -> Element? {
        var counts: [Element: Int] = [:]
        for item in self { counts[item, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
