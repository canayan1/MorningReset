import Foundation
import UserNotifications

// MARK: - UNAlarmBackend (iOS 17.6+)
//
// Schedules repeating UNCalendarNotificationTrigger requests —
// one per day-of-week — based on the WakeSchedule.
//
// Limitation: notification sound respects the device mute switch.
// UNNotificationSound.defaultCritical bypasses mute, but requires
// the critical-alerts entitlement (Apple review required).
// Until that entitlement is granted, .default is used.
//
// Wake flow entry: notification fires → user taps banner →
// NotificationDelegate.didReceive reads userInfo["action"] == "startWakeFlow"
// → appState.startFlow().

final class UNAlarmBackend: AlarmBackend {

    private let idPrefix = "mr_wake_"

    // MARK: Authorization

    func requestAuthorization() async -> Bool {
        let center   = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized  { return true }
        if settings.authorizationStatus == .provisional { return true }
        guard let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        else { return false }
        return granted
    }

    // MARK: Schedule

    func schedule(_ schedule: WakeSchedule) async {
        cancel()
        guard schedule.isEnabled else { return }

        let center  = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title    = "Good morning."
        content.body     = "Start before you react."
        content.sound    = .default
        content.userInfo = ["action": "startWakeFlow"]

        for weekday in 1...7 {
            var components     = DateComponents()
            components.weekday = weekday
            components.hour    = schedule.hour(forWeekday: weekday)
            components.minute  = schedule.minute(forWeekday: weekday)
            components.second  = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: idPrefix + "\(weekday)",
                content:    content,
                trigger:    trigger
            )
            center.add(request)
        }
    }

    // MARK: Cancel

    func cancel() {
        let ids = (1...7).map { idPrefix + "\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: Next fire date

    func nextFireDate(for schedule: WakeSchedule) -> Date? {
        guard schedule.isEnabled else { return nil }
        let calendar = Calendar.current
        let now      = Date()

        for offset in 0...7 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            let weekday = calendar.component(.weekday, from: candidate)
            let h = schedule.hour(forWeekday: weekday)
            let m = schedule.minute(forWeekday: weekday)
            guard let fire = calendar.date(bySettingHour: h, minute: m, second: 0, of: candidate)
            else { continue }
            if fire > now { return fire }
        }
        return nil
    }
}

// MARK: - AlarmKitBackend (iOS 26+)
//
// ─────────────────────────────────────────────────────────────────────────
// ALARMKIT INTEGRATION — STRUCTURE READY, IMPLEMENTATION PENDING
//
// When AlarmKit is ready to wire:
//   1. Add `import AlarmKit` at the top of this file
//   2. Link AlarmKit.framework in Xcode target → Build Phases → Link Binary
//   3. Verify required entitlement in Apple developer docs
//   4. Replace the UNAlarmBackend delegation below with AlarmKit calls:
//        - AlarmManager.shared (or equivalent) to schedule an alarm
//        - Handle the AlarmKit wake callback and route to appState.startFlow()
//
// Until then: this class conforms correctly to AlarmBackend and delegates
// to UNAlarmBackend. AlarmManager.current will return this type on iOS 26+,
// so the dual-backend selection path is live end-to-end — only the
// AlarmKit-specific calls need to be filled in here.
// ─────────────────────────────────────────────────────────────────────────

@available(iOS 26, *)
final class AlarmKitBackend: AlarmBackend {

    private let base = UNAlarmBackend()

    func requestAuthorization() async -> Bool {
        // TODO: Request AlarmKit authorization here (if separate from UNUserNotificationCenter).
        await base.requestAuthorization()
    }

    func schedule(_ schedule: WakeSchedule) async {
        // TODO: Replace with AlarmKit scheduling call.
        await base.schedule(schedule)
    }

    func cancel() {
        // TODO: Replace with AlarmKit cancel call.
        base.cancel()
    }

    func nextFireDate(for schedule: WakeSchedule) -> Date? {
        // TODO: Replace with AlarmKit next-fire query if available.
        base.nextFireDate(for: schedule)
    }
}
