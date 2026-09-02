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
        // AlarmKit (iOS 26.1+) is gated behind the `com.apple.developer.alarmkit`
        // entitlement, which Apple's provisioning currently refuses to include for
        // this App ID — verified for BOTH development and App Store profiles
        // ("Entitlement com.apple.developer.alarmkit not found and could not be
        // included in profile"). Until Apple opens the capability, ship the
        // local-notification + Live Activity path on every OS version. When it
        // becomes provisionable: re-add the entitlement and re-enable this branch.
        //
        // if #available(iOS 26.1, *) { return AlarmKitWakeScheduler() }
        return LocalNotificationWakeScheduler()
    }
}
