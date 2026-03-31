import Foundation

// MARK: - AlarmBackend protocol
//
// All alarm scheduling in MorningReset goes through this protocol.
// Views and controllers never reference a specific backend directly.
//
// Implementations:
//   UNAlarmBackend   — iOS 17.6+, UNUserNotificationCenter, respects mute switch
//   AlarmKitBackend  — iOS 26+,   AlarmKit, bypasses silent mode (stub until API verified)

protocol AlarmBackend {
    func requestAuthorization() async -> Bool
    func schedule(_ schedule: WakeSchedule) async
    func cancel()
    func nextFireDate(for schedule: WakeSchedule) -> Date?
}

// MARK: - AlarmManager factory

enum AlarmManager {
    /// Returns the best available backend for the current OS.
    /// Always call through this — never instantiate a backend directly.
    static var current: any AlarmBackend {
        if #available(iOS 26, *) {
            return AlarmKitBackend()
        }
        return UNAlarmBackend()
    }
}
