import Foundation

// MARK: - AlarmManaging
//
// The only interface any scheduling call site touches.
// Views, ScheduleSetupView, and AlarmEntryRouter depend on this protocol —
// never on a specific manager class.
//
// Current implementations:
//   LocalNotificationAlarmManager  — iOS 17.6+  (UNUserNotificationCenter)
//   AlarmKitManager                — iOS 26+    (stub, ready for wiring)
//
// To add a new backend:
//   1. Conform to AlarmManaging
//   2. Add an availability branch in AlarmManager.current
//   No other file needs to change.

protocol AlarmManaging {
    func requestAuthorization() async -> Bool
    func schedule(_ schedule: WakeSchedule) async
    func cancel()
    func nextFireDate(for schedule: WakeSchedule) -> Date?
}

// MARK: - AlarmManager

enum AlarmManager {
    /// Returns the best available manager for the current OS.
    /// This is the only place that knows which backend is active.
    static var current: any AlarmManaging {
        if #available(iOS 26, *) {
            return AlarmKitManager()
        }
        return LocalNotificationAlarmManager()
    }
}
