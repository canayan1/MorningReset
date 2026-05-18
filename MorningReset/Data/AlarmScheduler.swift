import Foundation
import UserNotifications

// MARK: - LocalNotificationWakeScheduler (iOS 17.6+)
//
// Schedules one repeating UNCalendarNotificationTrigger per day-of-week.
// Fires at the correct weekday/weekend time from WakeSchedule.
//
// Wake tap path:
//   Notification fires → user taps → NotificationDelegate.didReceive →
//   AlarmEntryRouter.routeToWakeFlow() → appState.startFlow()
//
// Known limitation:
//   Local notification sound respects mute / Silent mode.
//   To bypass: use .defaultCritical — requires critical-alerts entitlement
//   (Apple review required, not yet applied for).

final class LocalNotificationWakeScheduler: WakeScheduling {

    private let idPrefix = "mr_ping_"
    private let legacyIDPrefix = "mr_wake_"

    func requestAuthorization() async -> Bool {
        let center   = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized  { return true }
        if settings.authorizationStatus == .provisional { return true }
        guard let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        else { return false }
        return granted
    }

    func schedule(_ schedule: WakeSchedule) async {
        cancel()
        guard schedule.isEnabled else { return }

        let center  = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title    = "Morning Reset"
        content.body     = L10n.text(
            en: "Tap to start your reset before the scroll begins.",
            tr: "Scroll başlamadan önce reset'i başlatmak için dokun.",
            es: "Toca para empezar tu reset antes de que comience el scroll."
        )
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
            do {
                try await center.add(request)
            } catch {
                // Scheduling failure for a single slot is non-fatal; continue remaining days.
            }
        }
    }

    func cancel() {
        let ids = (1...7).flatMap { [idPrefix + "\($0)", legacyIDPrefix + "\($0)"] }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

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

// MARK: - AlarmKitWakeScheduler (iOS 26+)
//
// ─────────────────────────────────────────────────────────────────────────
// STATUS: Structure ready. AlarmKit calls not yet written.
//
// To complete this implementation:
//   1. Add `import AlarmKit` here
//   2. Link AlarmKit.framework in Xcode → Build Phases → Link Binary With Libraries
//   3. Verify entitlement requirements at developer.apple.com
//   4. Replace the LocalNotificationWakeScheduler delegation below with AlarmKit calls
//   5. In AlarmEntryRouter, add any AlarmKit-specific delegate conformance
//      and call routeToWakeFlow() from the AlarmKit wake callback
//
// AlarmKit provides: bypass silent mode, system-level alarm UI,
// no critical-alerts entitlement needed. All routing still goes through
// AlarmEntryRouter — this manager only handles scheduling, not navigation.
//
// Until implementation is complete: delegates to LocalNotificationWakeScheduler
// so WakeNotificationManager.current works end-to-end on iOS 26+ devices.
// ─────────────────────────────────────────────────────────────────────────

@available(iOS 26, *)
final class AlarmKitWakeScheduler: WakeScheduling {

    private let base = LocalNotificationWakeScheduler()

    func requestAuthorization() async -> Bool {
        // TODO: Replace with AlarmKit authorization request.
        await base.requestAuthorization()
    }

    func schedule(_ schedule: WakeSchedule) async {
        // TODO: Replace with AlarmKit.AlarmManager.shared.schedule(...) or equivalent.
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
