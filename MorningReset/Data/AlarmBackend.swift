import Foundation

// MARK: - WakeScheduling
//
// The only interface any scheduling call site touches.
// Views and setup flow call sites depend on this protocol, never on a
// specific notification backend.
//
// Current implementations:
//   LocalNotificationWakeScheduler  — iOS 17.6+  (UNUserNotificationCenter)
//   AlarmKitWakeScheduler          — iOS 26+    (stub, ready for wiring)
//
// To add a new backend:
//   1. Conform to WakeScheduling
//   2. Add an availability branch in WakeNotificationManager.current
//   No other file needs to change.

protocol WakeScheduling {
    func requestAuthorization() async -> Bool
    func schedule(_ schedule: WakeSchedule) async
    func cancel()
    func nextFireDate(for schedule: WakeSchedule) -> Date?
}

// MARK: - WakeNotificationManager

enum WakeNotificationManager {
    static var current: any WakeScheduling {
        if #available(iOS 26, *) {
            return AlarmKitWakeScheduler()
        }
        return LocalNotificationWakeScheduler()
    }
}
