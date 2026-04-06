import Foundation
import Observation
import FoundationModels

// MARK: - InsightEngine
//
// @Observable class that owns the AI insight lifecycle.
// - On init: loads cached insights from UserDefaults.
// - refresh(): called after each FlowCheckout save.
//   Tries primary service (remote when configured, local otherwise),
//   falls back to local if primary throws.
// - Results are cached per calendar day (daily) and per week (weekly).
// - To enable remote AI: replace `primary` initializer with RemoteAIInsightService.

@Observable
final class InsightEngine {

    var dailyInsight: DailyInsight?   = nil
    var weeklySummary: WeeklySummary? = nil
    var isRefreshing: Bool            = false

    private let primary: any AIInsightService
    private let fallback: any AIInsightService = LocalAIInsightService()

    private static let dailyKey  = "insight_daily_cache"
    private static let weeklyKey = "insight_weekly_cache"

    init() {
        if #available(iOS 26, *), case .available = SystemLanguageModel.default.availability {
            primary = AppleIntelligenceInsightService()
        } else {
            primary = LocalAIInsightService()
        }
        dailyInsight  = loadCached(key: Self.dailyKey)
        weeklySummary = loadCached(key: Self.weeklyKey)
    }

    // MARK: - Refresh
    //
    // Called from FlowCheckoutView after saving checkout.
    // Runs both daily and weekly generation concurrently.
    // Never throws to the caller — errors are handled internally.

    @MainActor
    func refresh(mode: String, intention: String, streak: Int) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        let context = buildContext(mode: mode, intention: intention, streak: streak)

        async let newDaily  = generateDaily(context: context)
        async let newWeekly = generateWeekly(context: context)
        let (d, w) = await (newDaily, newWeekly)

        if let d { dailyInsight  = d; persistCached(d, key: Self.dailyKey)  }
        if let w { weeklySummary = w; persistCached(w, key: Self.weeklyKey) }
    }

    // MARK: - Generation

    private func generateDaily(context: AIInsightContext) async -> DailyInsight? {
        if let cached = dailyInsight, Calendar.current.isDateInToday(cached.generatedAt) {
            return cached
        }
        do {
            return try await primary.dailyInsight(context: context)
        } catch {
            return try? await fallback.dailyInsight(context: context)
        }
    }

    private func generateWeekly(context: AIInsightContext) async -> WeeklySummary? {
        if let cached = weeklySummary,
           Calendar.current.isDate(cached.generatedAt, equalTo: Date(), toGranularity: .weekOfYear) {
            return cached
        }
        do {
            return try await primary.weeklySummary(context: context)
        } catch {
            return try? await fallback.weeklySummary(context: context)
        }
    }

    // MARK: - Context builder

    private func buildContext(mode: String, intention: String, streak: Int) -> AIInsightContext {
        AIInsightContext(
            recentEntries:   Array(DailyEntryStore.load().suffix(14)),
            recentCheckouts: FlowCheckoutStore.last(14),
            streakCount:     streak,
            todayMode:       mode,
            todayIntention:  intention
        )
    }

    // MARK: - Persistence

    private func persistCached<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadCached<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
