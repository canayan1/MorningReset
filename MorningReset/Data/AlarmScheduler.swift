import Foundation
import UserNotifications

// MARK: - AlarmScheduler
//
// IMPLEMENTATION STATUS
// ─────────────────────────────────────────────────────────────────────
// IMPLEMENTED NOW:
//   - Notification authorization request
//   - Calendar-based UNCalendarNotificationTrigger scheduling (7 weekday slots)
//   - Cancel all pending wake notifications
//   - Next fire date calculation (for UI display)
//
// DEPENDS ON APPLE CONSTRAINTS (not yet active):
//   - Critical alert entitlement  → bypasses silent mode / Do Not Disturb
//     Requires explicit Apple approval: developer.apple.com/contact/request/notifications-critical-alerts-entitlement
//     Until granted, sound plays at notification volume (respects silent mode).
//   - Background Audio capability → keeps alarm sound playing after notification fires
//     Requires "Background Modes > Audio" in Xcode target capabilities.
//     Not enabled yet — no provisioning profile / entitlement change made.
//
// STAGED / TODO:
//   - UNUserNotificationCenterDelegate in MorningResetApp.swift
//     Needed to intercept tapped notification response and route into wake flow.
//     Connection point: userInfo["action"] == "startWakeFlow" → appState.startFlow()
//   - AVAudioSession playback for in-app alarm sound (post-entitlement)
// ─────────────────────────────────────────────────────────────────────

enum AlarmScheduler {

    private static let notificationIDPrefix = "wake_weekday_"

    // MARK: - Authorization

    static func requestAuthorization() async -> Bool {
        let center   = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized  { return true }
        if settings.authorizationStatus == .provisional { return true }
        guard let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        else { return false }
        return granted
    }

    // MARK: - Schedule

    /// Cancels existing wake notifications, then schedules one repeating
    /// UNCalendarNotificationTrigger per day-of-week based on the provided WakeSchedule.
    static func schedule(_ schedule: WakeSchedule) {
        cancel()
        guard schedule.isEnabled else { return }

        let center  = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title    = "Good morning."
        content.body     = "Start before you react."
        content.userInfo = ["action": "startWakeFlow"]
        // NOTE: .defaultCritical bypasses silent mode but requires the critical-alerts entitlement.
        // Currently using .default — will respect the device's mute switch.
        content.sound    = .default

        for weekday in 1...7 {
            var components    = DateComponents()
            components.weekday = weekday
            components.hour    = schedule.hour(forWeekday: weekday)
            components.minute  = schedule.minute(forWeekday: weekday)
            components.second  = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: notificationIDPrefix + "\(weekday)",
                content:    content,
                trigger:    trigger
            )
            center.add(request)
        }
    }

    // MARK: - Cancel

    static func cancel() {
        let ids = (1...7).map { notificationIDPrefix + "\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Next fire date (display only)

    static func nextFireDate(for schedule: WakeSchedule) -> Date? {
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
