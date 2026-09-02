import Foundation

// MARK: - Practice log
//
// Every session you run is recorded here, so it can be reviewed, corrected or
// removed later. The energy orb counts only sessions marked `done` — deleting
// or downgrading one lowers it again, which keeps the orb honest.

enum PracticeOutcome: String, Codable, CaseIterable, Identifiable {
    case done, partial, skipped
    var id: String { rawValue }

    var title: String {
        switch self {
        case .done:    return "Practised"
        case .partial: return "Interrupted"
        case .skipped: return "Skipped through"
        }
    }

    var symbol: String {
        switch self {
        case .done:    return "checkmark.circle.fill"
        case .partial: return "pause.circle.fill"
        case .skipped: return "forward.circle.fill"
        }
    }

    /// Only a full practice feeds the orb.
    var feedsOrb: Bool { self == .done }
}

struct PracticeSession: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var schoolID: String
    var routineID: String
    var routineTitle: String
    var date: Date
    var minutes: Int
    var outcome: PracticeOutcome
    var note: String?
}

enum PracticeLogStore {
    private static let key = "practice_log_v1"

    static func all() -> [PracticeSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([PracticeSession].self, from: data)
        else { return [] }
        return list.sorted { $0.date > $1.date }
    }

    private static func save(_ list: [PracticeSession]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    @discardableResult
    static func add(schoolID: String, routine: Routine, outcome: PracticeOutcome = .done) -> PracticeSession {
        let s = PracticeSession(schoolID: schoolID,
                                routineID: routine.id,
                                routineTitle: routine.title,
                                date: Date(),
                                minutes: routine.minutes,
                                outcome: outcome)
        var list = all(); list.append(s); save(list)
        return s
    }

    static func update(_ session: PracticeSession) {
        var list = all()
        if let i = list.firstIndex(where: { $0.id == session.id }) {
            list[i] = session; save(list)
        }
    }

    static func delete(_ id: String) {
        save(all().filter { $0.id != id })
    }

    /// Sessions that count toward the orb.
    static func completedCount() -> Int {
        all().filter(\.outcome.feedsOrb).count
    }

    static func completedCount(school id: String) -> Int {
        all().filter { $0.schoolID == id && $0.outcome.feedsOrb }.count
    }

    static func recent(_ limit: Int = 20) -> [PracticeSession] {
        Array(all().prefix(limit))
    }

    /// Days in a row with a completed practice.
    ///
    /// One missed day is forgiven. The chain only breaks after two in a row, so
    /// a single slip never wipes out weeks of work — the app promises the orb
    /// waits for you, and the streak has to keep that promise too.
    static func currentStreak(now: Date = Date()) -> Int {
        let cal = Calendar.current
        let days = Set(all().filter(\.outcome.feedsOrb).map { cal.startOfDay(for: $0.date) })
        guard let latest = days.max() else { return 0 }

        // Still live if the last practice was today, yesterday, or the day
        // before — that third day is the forgiven one.
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
                break   // two blank days in a row ends it
            }
            cursor = previous
        }
        return streak
    }

    /// Replaces the log wholesale. Used by the UI tests to build a deterministic
    /// history for store screenshots.
    static func replaceAll(_ list: [PracticeSession]) {
        save(list)
    }
}
