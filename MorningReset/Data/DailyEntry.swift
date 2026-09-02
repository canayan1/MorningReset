import Foundation

struct DailyEntry: Codable {
    let date: Date
    let mode: String       // MorningMode.rawValue
    let intention: String  // IntentionType.rawValue
}

enum DailyEntryStore {

    private static let key       = UDKey.dailyEntries
    private static let cap       = 90
    private static let suiteName = "group.com.canayan.MorningReset"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    }

    static func load() -> [DailyEntry] {
        guard let data    = defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([DailyEntry].self, from: data)
        else { return [] }
        return entries
    }

    /// Replaces the stored history. Used by the UI tests to build a deterministic
    /// streak for store screenshots.
    static func replaceAll(_ entries: [DailyEntry]) {
        guard let data = try? JSONEncoder().encode(Array(entries.suffix(cap))) else { return }
        defaults.set(data, forKey: key)
    }

    static func append(mode: String, intention: String) {
        let today = Calendar.current.startOfDay(for: Date())
        var entries = load()
        if entries.contains(where: { Calendar.current.startOfDay(for: $0.date) == today }) { return }
        entries.append(DailyEntry(date: Date(), mode: mode, intention: intention))
        if entries.count > cap { entries = Array(entries.suffix(cap)) }
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: key)
    }
}
