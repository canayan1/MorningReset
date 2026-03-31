import Foundation

// MARK: - Wake schedule model

struct WakeSchedule: Codable, Equatable {
    var weekdayHour:   Int  = 7
    var weekdayMinute: Int  = 0
    var weekendHour:   Int  = 8
    var weekendMinute: Int  = 0
    var isEnabled: Bool     = false

    // Weekday = Mon–Fri (weekday 2–6), Weekend = Sat–Sun (weekday 7, 1)
    func hour(forWeekday weekday: Int) -> Int {
        (weekday == 1 || weekday == 7) ? weekendHour : weekdayHour
    }

    func minute(forWeekday weekday: Int) -> Int {
        (weekday == 1 || weekday == 7) ? weekendMinute : weekdayMinute
    }

    func displayTime(isWeekend: Bool) -> String {
        let h = isWeekend ? weekendHour   : weekdayHour
        let m = isWeekend ? weekendMinute : weekdayMinute
        let suffix   = h >= 12 ? "PM" : "AM"
        let display  = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return String(format: "%d:%02d %@", display, m, suffix)
    }
}

// MARK: - Persistence

enum WakeScheduleStore {
    private static let key = "wake_schedule_v1"

    static func load() -> WakeSchedule {
        guard
            let data     = UserDefaults.standard.data(forKey: key),
            let schedule = try? JSONDecoder().decode(WakeSchedule.self, from: data)
        else { return WakeSchedule() }
        return schedule
    }

    static func save(_ schedule: WakeSchedule) {
        guard let data = try? JSONEncoder().encode(schedule) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
