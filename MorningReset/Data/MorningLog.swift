import Foundation

// MARK: - The morning log
//
// One line per morning: what the pulse was when the day started, and whether
// the smile happened. Kept apart from the practice log on purpose — a morning
// is not a practice. It has no school and no routine, it must not feed the orb
// or the streak, and mixing it in would quietly inflate both.
//
// At most one record per day, and a later one replaces an earlier one: the
// morning you actually got up is the morning that counts.

struct MorningRecord: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var date: Date
    /// Beats per minute, or nothing. A reading the app did not trust is stored
    /// as nothing rather than as a number, so the calendar never shows a figure
    /// that was really a shrug.
    var bpm: Int?
    var smiled: Bool

    var dayStart: Date { Calendar.current.startOfDay(for: date) }
}

enum MorningLogStore {
    private static let key = "morning_log_v1"

    static func all() -> [MorningRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([MorningRecord].self, from: data)
        else { return [] }
        return list.sorted { $0.date > $1.date }
    }

    private static func save(_ list: [MorningRecord]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Records this morning, replacing anything already stored for the day.
    @discardableResult
    static func record(bpm: Int?, smiled: Bool, on date: Date = Date()) -> MorningRecord {
        let record = MorningRecord(date: date, bpm: bpm, smiled: smiled)
        let day = Calendar.current.startOfDay(for: date)
        var list = all().filter { Calendar.current.startOfDay(for: $0.date) != day }
        list.append(record)
        save(list)
        return record
    }

    static func record(for date: Date) -> MorningRecord? {
        let day = Calendar.current.startOfDay(for: date)
        return all().first { Calendar.current.startOfDay(for: $0.date) == day }
    }

    /// The mornings of one month, newest first.
    static func month(containing date: Date) -> [MorningRecord] {
        let cal = Calendar.current
        guard let range = cal.dateInterval(of: .month, for: date) else { return [] }
        return all().filter { range.contains($0.date) }
    }

    /// The typical waking pulse over the last few weeks — what a single
    /// morning is worth comparing against.
    ///
    /// The median rather than the mean: one bad contact reading drags a mean
    /// several beats and would make every ordinary morning look unusual.
    static func typicalBPM(days: Int = 30, now: Date = Date()) -> Int? {
        let cal = Calendar.current
        guard let cutoff = cal.date(byAdding: .day, value: -days, to: now) else { return nil }
        let values = all().filter { $0.date >= cutoff }.compactMap(\.bpm).sorted()
        guard values.count >= 3 else { return nil }
        return values[values.count / 2]
    }

    /// Mornings in a row. One missed day is forgiven, the same way the practice
    /// streak forgives one — a single slip must not wipe out a month.
    static func currentStreak(now: Date = Date()) -> Int {
        let cal = Calendar.current
        let days = Set(all().map { cal.startOfDay(for: $0.date) })
        guard let latest = days.max() else { return 0 }
        let today = cal.startOfDay(for: now)
        guard let gap = cal.dateComponents([.day], from: latest, to: today).day,
              gap >= 0, gap <= 2 else { return 0 }

        var streak = 0
        var cursor = latest
        while true {
            guard let previous = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            if days.contains(cursor) {
                streak += 1
            } else if !days.contains(previous) {
                break
            }
            cursor = previous
        }
        return streak
    }

    /// Replaces the log wholesale. For the tests, and for the UI tests that
    /// need a deterministic month to photograph.
    static func replaceAll(_ list: [MorningRecord]) { save(list) }
}
