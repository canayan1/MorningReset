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
        // AlarmKit needs no provisioning entitlement. An earlier attempt added a
        // `com.apple.developer.alarmkit` key that does not exist, provisioning
        // rejected it, and the failure was misread as Apple gating the framework.
        // What it actually needs is `NSAlarmKitUsageDescription` in Info.plist —
        // the plist carried `NSAlarmsUsageDescription`, so authorization silently
        // failed. Both are fixed; on iOS 26.1+ the alarm rings through Silent
        // mode and Sleep Focus, and older systems get the notification path.
        if #available(iOS 26.1, *) { return AlarmKitWakeScheduler() }
        return LocalNotificationWakeScheduler()
    }
}
