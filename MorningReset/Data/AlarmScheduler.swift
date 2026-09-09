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
        content.title    = "Inner Light"
        content.body     = L10n.text(
            en: "Your practice is ready. Tap to begin.",
            tr: "Pratiğin hazır. Başlamak için dokun.",
            es: "Tu práctica está lista. Toca para empezar."
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

        // Reconcile the Live Activity so the morning ritual is the first
        // thing the user sees on the lock screen when they pick up their
        // phone. Reconcile (rather than start) avoids burning an Activity
        // hours before fireDate when it would expire before morning.
        let fireDate = nextFireDate(for: schedule)
        await MainActor.run {
            WakeActivityController.reconcile(
                fireDate: fireDate,
                tagline: L10n.text(
                    en: "Your practice is ready.",
                    tr: "Pratiğin hazır.",
                    es: "Tu práctica está lista."
                )
            )
        }
    }

    func cancel() {
        let ids = (1...7).flatMap { [idPrefix + "\($0)", legacyIDPrefix + "\($0)"] }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        Task { @MainActor in WakeActivityController.endAll() }
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

// MARK: - AlarmKitWakeScheduler (iOS 26.1+)
//
// Replaces the local-notification backend on iOS 26.1+.
// AlarmKit alarms bypass Silent mode and Sleep Focus — the system shows
// a full-screen alarm UI identical to the built-in Clock app.
// The alarm rings with the guide's own voice. Its Begin button runs
// BeginPracticeIntent, which opens the app; AlarmEntryRouter picks up the
// shared-container flag and starts the practice without a tap.

import AlarmKit
import ActivityKit   // AlertConfiguration.AlertSound
import SwiftUI

@available(iOS 26.1, *)
final class AlarmKitWakeScheduler: WakeScheduling {

    private let base = LocalNotificationWakeScheduler()

    // Stable IDs so reschedule replaces, not duplicates.
    private static let weekdayAlarmID = UUID(uuidString: "A0000000-0000-0000-0000-000000000001")!
    private static let weekendAlarmID  = UUID(uuidString: "A0000000-0000-0000-0000-000000000002")!

    func requestAuthorization() async -> Bool {
        // If the person declines alarms, fall through to notifications so the
        // morning still reaches them — just not through Silent mode.
        if (try? await AlarmManager.shared.requestAuthorization()) == .authorized { return true }
        return await base.requestAuthorization()
    }

    func schedule(_ wakeSchedule: WakeSchedule) async {
        cancel()
        guard wakeSchedule.isEnabled else { return }

        // The alarm is the practice: it rings with the guide's own voice, and its
        // second button opens the app straight into the session. Stop is the
        // system's and only silences it.
        let presentation = AlarmPresentation(
            alert: AlarmPresentation.Alert(
                title: "Your practice is ready",
                secondaryButton: AlarmButton(text: "Begin", textColor: .white, systemImageName: "play.fill"),
                secondaryButtonBehavior: .custom
            )
        )
        let attrs = AlarmAttributes<MorningAlarmMeta>(
            presentation: presentation,
            tintColor: DS.accent
        )
        let begin = BeginPracticeIntent()

        let weekdayConfig = AlarmManager.AlarmConfiguration<MorningAlarmMeta>.alarm(
            schedule: .relative(Alarm.Schedule.Relative(
                time: .init(hour: wakeSchedule.weekdayHour, minute: wakeSchedule.weekdayMinute),
                repeats: .weekly([.monday, .tuesday, .wednesday, .thursday, .friday])
            )),
            attributes: attrs,
            secondaryIntent: begin,
            sound: .named("wake_opening.caf")
        )
        let weekendConfig = AlarmManager.AlarmConfiguration<MorningAlarmMeta>.alarm(
            schedule: .relative(Alarm.Schedule.Relative(
                time: .init(hour: wakeSchedule.weekendHour, minute: wakeSchedule.weekendMinute),
                repeats: .weekly([.saturday, .sunday])
            )),
            attributes: attrs,
            secondaryIntent: begin,
            sound: .named("wake_opening.caf")
        )

        // AlarmKit rings through Sleep Focus and Silent. If scheduling fails —
        // alarms declined in Settings, say — fall back to notifications.
        do {
            try await AlarmManager.shared.schedule(id: Self.weekdayAlarmID, configuration: weekdayConfig)
            try await AlarmManager.shared.schedule(id: Self.weekendAlarmID, configuration: weekendConfig)

            let fireDate = nextFireDate(for: wakeSchedule)
            await MainActor.run {
                WakeActivityController.reconcile(
                    fireDate: fireDate,
                    tagline: L10n.text(
                        en: "Your practice is ready.",
                        tr: "Pratiğin hazır.",
                        es: "Tu práctica está lista."
                    )
                )
            }
        } catch {
            // AlarmKit failed — fall back to notification + Live Activity so the
            // morning still arrives.
            await base.schedule(wakeSchedule)
        }
    }

    func cancel() {
        try? AlarmManager.shared.cancel(id: Self.weekdayAlarmID)
        try? AlarmManager.shared.cancel(id: Self.weekendAlarmID)
        // Also cancel any local notification fallback alarms from a previous schedule.
        base.cancel()
    }

    func nextFireDate(for schedule: WakeSchedule) -> Date? {
        base.nextFireDate(for: schedule)
    }
}

// MARK: - ReEngagementNotifier
//
// Self-correcting lapse re-engagement. Each time the user completes a morning
// reset we (re)arm two one-shot local notifications:
//   1. "Streak at risk" — tomorrow evening, to protect the running streak.
//   2. "Comeback"       — two mornings out, to reclaim a lapsed streak.
// Completing the next reset cancels and re-arms them, so a consistent user
// never sees them; only a genuine lapse lets one fire.

enum ReEngagementNotifier {
    private static let atRiskID   = "mr_atrisk"
    private static let comebackID = "mr_comeback"

    static func cancelAll() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [atRiskID, comebackID])
    }

    static func scheduleAfterReset(streak: Int, schedule: WakeSchedule) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [atRiskID, comebackID])
        guard schedule.isEnabled else { return }

        let cal = Calendar.current
        let now = Date()

        // 1. Streak at risk — tomorrow evening at 19:00
        if streak > 0,
           let tomorrow = cal.date(byAdding: .day, value: 1, to: now),
           let atRisk   = cal.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) {
            let content = UNMutableNotificationContent()
            content.title    = "Inner Light"
            content.body     = L10n.text(
                en: "Your \(streak)-day streak is still alive. Keep it going before the day ends.",
                tr: "\(streak) günlük serin hâlâ sürüyor. Gün bitmeden devam ettir.",
                es: "Tu racha de \(streak) días sigue viva. Mantenla antes de que acabe el día."
            )
            content.sound    = .default
            content.userInfo = ["action": "startWakeFlow"]
            let comps   = cal.dateComponents([.year, .month, .day, .hour, .minute], from: atRisk)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: atRiskID, content: content, trigger: trigger))
        }

        // 2. Comeback — two mornings out, at the user's wake time
        if let day2 = cal.date(byAdding: .day, value: 2, to: now) {
            let weekday = cal.component(.weekday, from: day2)
            let h = schedule.hour(forWeekday: weekday)
            let m = schedule.minute(forWeekday: weekday)
            if let comeback = cal.date(bySettingHour: h, minute: m, second: 0, of: day2) {
                let content = UNMutableNotificationContent()
                content.title    = "Inner Light"
                content.body     = L10n.text(
                    en: "Your practice is here whenever you are.",
                    tr: "Pratiğin, sen hazır olduğunda burada.",
                    es: "Tu práctica está aquí cuando tú lo estés."
                )
                content.sound    = .default
                content.userInfo = ["action": "startWakeFlow"]
                let comps   = cal.dateComponents([.year, .month, .day, .hour, .minute], from: comeback)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                center.add(UNNotificationRequest(identifier: comebackID, content: content, trigger: trigger))
            }
        }
    }
}
