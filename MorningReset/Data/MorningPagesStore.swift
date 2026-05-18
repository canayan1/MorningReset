import Foundation

// MARK: - Model

struct MorningPageEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mode: String
    let prompt: String
    let text: String

    init(date: Date = Date(), mode: String, prompt: String, text: String) {
        self.id     = UUID()
        self.date   = date
        self.mode   = mode
        self.prompt = prompt
        self.text   = text
    }
}

// MARK: - Store

enum MorningPagesStore {

    private static let entriesKey = "morningPageEntries"
    private static let storyKeyPrefix = "monthlyStory"
    private static let cap = 365

    // MARK: Entries

    static func load() -> [MorningPageEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let entries = try? JSONDecoder().decode([MorningPageEntry].self, from: data)
        else { return [] }
        return entries
    }

    /// Appends an entry — one per calendar day, silently ignores duplicates.
    static func append(_ entry: MorningPageEntry) {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        var entries = load()
        guard !entries.contains(where: { cal.startOfDay(for: $0.date) == today }) else { return }
        entries.append(entry)
        if entries.count > cap { entries = Array(entries.suffix(cap)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
    }

    static func hasEntryForToday() -> Bool {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return load().contains { cal.startOfDay(for: $0.date) == today }
    }

    static func todayEntry() -> MorningPageEntry? {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return load().first { cal.startOfDay(for: $0.date) == today }
    }

    static func entriesForMonth(year: Int, month: Int) -> [MorningPageEntry] {
        let cal = Calendar.current
        return load().filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == year && c.month == month
        }
    }

    /// Last month's entries — used for story generation.
    static func lastMonthEntries() -> [MorningPageEntry] {
        let cal = Calendar.current
        guard let lastMonth = cal.date(byAdding: .month, value: -1, to: Date()) else { return [] }
        let c = cal.dateComponents([.year, .month], from: lastMonth)
        return entriesForMonth(year: c.year ?? 0, month: c.month ?? 0)
    }

    // MARK: Monthly story cache

    static func cachedStory(year: Int, month: Int) -> String? {
        UserDefaults.standard.string(forKey: storyKey(year: year, month: month))
    }

    static func cacheStory(_ story: String, year: Int, month: Int) {
        UserDefaults.standard.set(story, forKey: storyKey(year: year, month: month))
    }

    private static func storyKey(year: Int, month: Int) -> String {
        "\(storyKeyPrefix)_\(year)_\(month)"
    }
}
