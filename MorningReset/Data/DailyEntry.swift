import Foundation

struct DailyEntry: Codable {
    let date: Date
    let mode: String       // MorningMode.rawValue
    let intention: String  // IntentionType.rawValue
}

enum DailyEntryStore {

    private static let key = "daily_entries"
    private static let cap = 90

    static func load() -> [DailyEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([DailyEntry].self, from: data)
        else { return [] }
        return entries
    }

    static func append(mode: String, intention: String) {
        let today = Calendar.current.startOfDay(for: Date())
        var entries = load()
        if entries.contains(where: { Calendar.current.startOfDay(for: $0.date) == today }) { return }
        entries.append(DailyEntry(date: Date(), mode: mode, intention: intention))
        if entries.count > cap { entries = Array(entries.suffix(cap)) }
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
