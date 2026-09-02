import Foundation
import UserNotifications
import FoundationModels

// MARK: - Monthly Story Engine
//
// Checks whether last month has enough Morning Pages entries and no cached story.
// If so, generates a short personal narrative using Apple Intelligence (iOS 26+)
// with a rule-based local fallback for older devices.
// Fires a local notification once the story is ready.

enum MonthlyStoryEngine {

    static let minimumEntries = 5

    /// Call once per app session (e.g. from PremiumHubView.onAppear).
    /// No-ops if story already exists or not enough entries.
    static func generateIfNeeded() async {
        let cal = Calendar.current
        let now = Date()
        guard let lastMonth = cal.date(byAdding: .month, value: -1, to: now) else { return }
        let comps = cal.dateComponents([.year, .month], from: lastMonth)
        guard let year = comps.year, let month = comps.month else { return }

        guard MorningPagesStore.cachedStory(year: year, month: month) == nil else { return }

        let entries = MorningPagesStore.entriesForMonth(year: year, month: month)
        guard entries.count >= minimumEntries else { return }

        let story = await generate(entries: entries)
        guard !story.isEmpty else { return }

        MorningPagesStore.cacheStory(story, year: year, month: month)
        sendNotification(month: month, year: year)
    }

    // MARK: - Generation

    private static func generate(entries: [MorningPageEntry]) async -> String {
        if #available(iOS 26, *) {
            if case .available = SystemLanguageModel.default.availability {
                if let story = try? await generateWithAppleIntelligence(entries: entries) {
                    return story
                }
            }
        }
        return localFallback(entries: entries)
    }

    @available(iOS 26, *)
    private static func generateWithAppleIntelligence(entries: [MorningPageEntry]) async throws -> String {
        let session = LanguageModelSession(instructions: systemPrompt)
        let response = try await session.respond(to: buildPrompt(entries: entries))
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Prompts

    private static let systemPrompt = """
    You write short personal reflections for people who kept a daily morning journal.
    Each entry is one sentence the person wrote about themselves or their intention for the day.
    Write a short narrative — 3 to 4 short paragraphs — that weaves their entries into a story of their month.

    Rules:
    - Second person ("you").
    - Tone: warm, literary, personal, quietly hopeful. Not motivational. Not preachy.
    - Do not list or quote the entries directly.
    - No headers, no bullet points. Plain paragraphs only.
    - Maximum 200 words.
    """

    private static func buildPrompt(entries: [MorningPageEntry]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let lines = entries
            .sorted { $0.date < $1.date }
            .map { "\(formatter.string(from: $0.date)): \"\($0.text)\"" }
            .joined(separator: "\n")
        return "Morning journal entries:\n\n\(lines)\n\nWrite their monthly story."
    }

    // MARK: - Local fallback (rule-based, always available)

    private static func localFallback(entries: [MorningPageEntry]) -> String {
        let count     = entries.count
        let modes     = entries.map { $0.mode }
        let dominant  = mostFrequent(modes) ?? "steady"
        let monthName = Self.monthName(for: entries.first?.date ?? Date())

        let opening = count >= 20
            ? "You showed up \(count) mornings in \(monthName). That's a real month of starts."
            : "You kept \(count) morning entries in \(monthName). Each one a moment you chose yourself over the scroll."

        let middle: String
        switch dominant {
        case "protect":
            middle = "A lot of those mornings were quieter ones. You were moving slowly, choosing carefully — protecting something that mattered."
        case "push":
            middle = "Many of those mornings arrived with clarity and drive. You knew what you were going after and said so."
        default:
            middle = "Most of those mornings were steady. You returned to yourself, checked in, and kept going."
        }

        let closing = "The sentences were short. But they were honest. And honesty, written in the first moments of the day, has a way of carrying further than you expect."

        return "\(opening)\n\n\(middle)\n\n\(closing)"
    }

    // MARK: - Notification

    private static func sendNotification(month: Int, year: Int) {
        let content = UNMutableNotificationContent()
        let name = monthName(month: month)
        content.title = L10n.text(
            en: "Your \(name) story is ready",
            tr: "\(name) hikayeniz hazır",
            es: "Tu historia de \(name) está lista"
        )
        content.body = L10n.text(
            en: "Written from your practice entries. Open Inner Light to read it.",
            tr: "Pratik kayıtlarından yazıldı. Okumak için Inner Light'ı aç.",
            es: "Escrita a partir de tus prácticas. Abre Inner Light para leerla."
        )
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "monthlyStory_\(year)_\(month)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Helpers

    private static func mostFrequent(_ items: [String]) -> String? {
        var counts: [String: Int] = [:]
        items.forEach { counts[$0, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private static func monthName(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f.string(from: date)
    }

    private static func monthName(month: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return f.string(from: date)
    }
}
