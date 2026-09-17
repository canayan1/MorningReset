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

// MARK: - What will actually happen
//
// Asked for and delivered are two different things, and the gap between them
// is silent. An alarm the person set in good faith can come back as an
// ordinary notification — AlarmKit declined in Settings, or never asked — and
// an ordinary notification is exactly what Sleep Focus is for suppressing. The
// app used to report success either way. Now it records which one it got, so
// the screen that promises a morning can say what it actually arranged.

/// Whether the system will let this app ring a real alarm.
///
/// Told apart from "not yet asked" on purpose: one of them is a question the
/// app can still put to the person, and the other is a trip to Settings. A
/// screen that cannot tell the difference offers the wrong button.
enum WakeAlarmPermission {
    case notAsked
    case allowed
    case refused
    /// Older than iOS 26.1 — there is no alarm to allow.
    case unsupported
}

enum WakeDelivery: String, Codable {
    /// AlarmKit. Rings through Silent mode and Sleep Focus.
    case alarm
    /// A notification. Sleep Focus can hold it back.
    case notification
    case none
}

enum WakeDeliveryStore {
    private static let key = "wake_delivery_v1"
    private static let reasonKey = "wake_delivery_reason_v1"

    static var current: WakeDelivery {
        get { WakeDelivery(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .none }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: key) }
    }

    /// Why it is not an alarm, when it is not. Kept for the screen to explain
    /// itself with, and for working out afterwards what a quiet morning was.
    static var reason: String? {
        get { UserDefaults.standard.string(forKey: reasonKey) }
        set { UserDefaults.standard.set(newValue, forKey: reasonKey) }
    }

    static func record(_ delivery: WakeDelivery, reason: String? = nil) {
        current = delivery
        self.reason = reason
    }
}

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
        // Without this a Focus simply swallows it, which is the whole failure
        // this path exists to avoid. Time-sensitive still asks the person's
        // permission — it is not a way around their settings — but a morning
        // alarm is the case the level was made for.
        content.interruptionLevel = .timeSensitive

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
        WakeDeliveryStore.current = .notification

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

// MARK: - Alarm permission
//
// Deliberately a small enum rather than a Bool: "not asked" and "refused" want
// different words and a different button, and collapsing them is how a screen
// ends up telling someone to visit Settings for a prompt it never showed.

enum WakeAlarmPermissionCheck {
    static var current: WakeAlarmPermission {
        if #available(iOS 26.1, *) { return AlarmKitWakeScheduler.permission }
        return .unsupported
    }

    @discardableResult
    static func request() async -> WakeAlarmPermission {
        if #available(iOS 26.1, *) { return await AlarmKitWakeScheduler.requestAlarmPermission() }
        return .unsupported
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
import os

@available(iOS 26.1, *)
final class AlarmKitWakeScheduler: WakeScheduling {

    private let base = LocalNotificationWakeScheduler()

    // Stable IDs so reschedule replaces, not duplicates.
    static let weekdayAlarmID = UUID(uuidString: "A0000000-0000-0000-0000-000000000001")!
    static let weekendAlarmID  = UUID(uuidString: "A0000000-0000-0000-0000-000000000002")!

    /// The chain behind the first alarm, at three-minute steps. One-shot, so
    /// finishing the ritual can clear what is left of today without touching
    /// tomorrow; they are re-armed whenever the app comes forward.
    static let followUpIDs = (0..<4).map {
        UUID(uuidString: String(format: "A0000000-0000-0000-0000-0000000000%02d", $0 + 16))!
    }
    private static let followUpStep = 3

    /// The alarm you can ask to hear now.
    ///
    /// An alarm is the one thing in an app that cannot be tried before it
    /// matters: you find out whether it works by sleeping through it. This
    /// fires the real thing — same sound, same presentation, same Stop — a few
    /// seconds from now, so the morning is not the first time.
    static let previewID = UUID(uuidString: "A0000000-0000-0000-0000-0000000000FF")!

    static let log = Logger(subsystem: "com.canayan.MorningReset", category: "alarm")

    func requestAuthorization() async -> Bool {
        // If the person declines alarms, fall through to notifications so the
        // morning still reaches them — just not through Silent mode.
        do {
            let state = try await AlarmManager.shared.requestAuthorization()
            Self.log.notice("AlarmKit authorization: \(String(describing: state), privacy: .public)")
            if state == .authorized { return true }
        } catch {
            Self.log.error("AlarmKit authorization threw: \(error.localizedDescription, privacy: .public)")
        }
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
                title: "Your morning is ready. Tap Begin.",
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
            sound: .named("inner_light_alarm.caf")
        )
        let weekendConfig = AlarmManager.AlarmConfiguration<MorningAlarmMeta>.alarm(
            schedule: .relative(Alarm.Schedule.Relative(
                time: .init(hour: wakeSchedule.weekendHour, minute: wakeSchedule.weekendMinute),
                repeats: .weekly([.saturday, .sunday])
            )),
            attributes: attrs,
            secondaryIntent: begin,
            sound: .named("inner_light_alarm.caf")
        )

        // AlarmKit rings through Sleep Focus and Silent. If scheduling fails —
        // alarms declined in Settings, say — fall back to notifications.
        // Ask first and say so. Scheduling into a manager that has not been
        // authorized throws, and the throw used to be swallowed into a
        // notification the person was never told about.
        guard AlarmManager.shared.authorizationState == .authorized else {
            Self.log.error("AlarmKit not authorized (\(String(describing: AlarmManager.shared.authorizationState), privacy: .public)); using notifications")
            await base.schedule(wakeSchedule)
            WakeDeliveryStore.record(.notification, reason: "alarms-not-allowed")
            return
        }

        do {
            try await AlarmManager.shared.schedule(id: Self.weekdayAlarmID, configuration: weekdayConfig)
            try await AlarmManager.shared.schedule(id: Self.weekendAlarmID, configuration: weekendConfig)
            WakeDeliveryStore.record(.alarm)
            // What the system says it is holding, rather than what we believe
            // we handed it. The two have already differed once.
            UserDefaults.standard.set(Self.scheduledCount, forKey: "wake_alarm_count_v1")
            if wakeSchedule.insistUntilRitual {
                await Self.armFollowUps(for: wakeSchedule, attributes: attrs, begin: begin)
            }

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
            Self.log.error("AlarmKit schedule failed, using notifications: \(error.localizedDescription, privacy: .public)")
            await base.schedule(wakeSchedule)
            WakeDeliveryStore.record(.notification, reason: error.localizedDescription)
        }
        Self.log.notice("AlarmKit alarms scheduled for \(wakeSchedule.weekdayHour):\(wakeSchedule.weekdayMinute) / \(wakeSchedule.weekendHour):\(wakeSchedule.weekendMinute)")
    }

    /// The chain that makes the alarm insist.
    ///
    /// Each one is a one-shot at the next occurrence of its own clock time, so
    /// they can be cleared for today the moment the ritual is finished without
    /// disarming tomorrow. Scheduled ahead rather than on demand, because the
    /// app does not get to run when somebody taps Stop and rolls over.
    static func armFollowUps(for schedule: WakeSchedule,
                             attributes: AlarmAttributes<MorningAlarmMeta>,
                             begin: BeginPracticeIntent) async {
        guard schedule.isEnabled, schedule.insistUntilRitual, !MorningRitual.completedToday else { return }
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date())
        let times = MorningAlarmChain.times(hour: schedule.hour(forWeekday: weekday),
                                            minute: schedule.minute(forWeekday: weekday))
        for (id, time) in zip(followUpIDs, times) {
            let config = AlarmManager.AlarmConfiguration<MorningAlarmMeta>.alarm(
                schedule: .relative(Alarm.Schedule.Relative(
                    time: .init(hour: time.hour, minute: time.minute),
                    repeats: .never
                )),
                attributes: attributes,
                secondaryIntent: begin,
                sound: .named("inner_light_alarm.caf")
            )
            try? await AlarmManager.shared.schedule(id: id, configuration: config)
        }
        log.notice("follow-up chain armed: \(times.count, privacy: .public) alarms")
    }

    /// Build the chain from nothing — for the app coming forward, when the
    /// alarm's own scheduling call is long past.
    static func reconcileFollowUps() async {
        let schedule = WakeScheduleStore.load()
        guard schedule.isEnabled, schedule.insistUntilRitual, !MorningRitual.completedToday else {
            cancelFollowUps()
            return
        }
        let attrs = AlarmAttributes<MorningAlarmMeta>(
            presentation: AlarmPresentation(alert: AlarmPresentation.Alert(
                title: "Your morning is ready. Tap Begin.",
                secondaryButton: AlarmButton(text: "Begin", textColor: .white, systemImageName: "play.fill"),
                secondaryButtonBehavior: .custom)),
            tintColor: DS.accent
        )
        await armFollowUps(for: schedule, attributes: attrs, begin: BeginPracticeIntent())
    }

    /// Called the moment the ritual is finished: the morning has happened, so
    /// the rest of the chain has nothing left to insist about.
    static func cancelFollowUps() {
        for id in followUpIDs { try? AlarmManager.shared.cancel(id: id) }
    }

    /// Stops whatever is ringing right now, without touching tomorrow.
    ///
    /// Every alarm this app owns, because the one that woke you could be the
    /// morning alarm or any link of the chain behind it, and there is no way
    /// to ask the system which one is making the noise.
    static func silenceRinging() {
        // Everything the system is holding, by asking it what that is.
        //
        // Stopping a list of ids we believe in is how this failed: the alarm
        // went on at full volume behind the ritual, which then masked the soft
        // bell underneath — so the bell looked broken as well. The system knows
        // which alarms exist and one of them is the one making the noise; the
        // known ids stay as a fallback for when that list cannot be read.
        if let live = try? AlarmManager.shared.alarms {
            for alarm in live { try? AlarmManager.shared.stop(id: alarm.id) }
            log.notice("silenced \(live.count, privacy: .public) alarm(s)")
        }
        for id in [weekdayAlarmID, weekendAlarmID, previewID] + followUpIDs {
            try? AlarmManager.shared.stop(id: id)
        }
    }

    /// Rings the real alarm a few seconds from now.
    static func previewAlarm() async -> Bool {
        guard isAuthorized else { return false }
        let config = AlarmManager.AlarmConfiguration<MorningAlarmMeta>.timer(
            duration: 4,
            attributes: AlarmAttributes<MorningAlarmMeta>(
                presentation: AlarmPresentation(alert: AlarmPresentation.Alert(
                    title: "This is your alarm",
                    secondaryButton: AlarmButton(text: "Begin", textColor: .white, systemImageName: "play.fill"),
                    secondaryButtonBehavior: .custom)),
                tintColor: DS.accent),
            secondaryIntent: BeginPracticeIntent(),
            sound: .named("inner_light_alarm.caf")
        )
        do {
            _ = try await AlarmManager.shared.schedule(id: previewID, configuration: config)
            try AlarmManager.shared.countdown(id: previewID)
            return true
        } catch {
            log.error("alarm preview failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// Whether the system will actually ring, checked live rather than
    /// remembered — alarms can be turned off in Settings long after the
    /// morning was set up.
    static var isAuthorized: Bool {
        AlarmManager.shared.authorizationState == .authorized
    }

    static var permission: WakeAlarmPermission {
        switch AlarmManager.shared.authorizationState {
        case .authorized:    return .allowed
        case .denied:        return .refused
        case .notDetermined: return .notAsked
        @unknown default:    return .notAsked
        }
    }

    /// Asks, and only asks. The system shows its prompt once; after that this
    /// returns what was decided and the screen has to send the person to
    /// Settings instead.
    static func requestAlarmPermission() async -> WakeAlarmPermission {
        guard AlarmManager.shared.authorizationState == .notDetermined else { return permission }
        do {
            _ = try await AlarmManager.shared.requestAuthorization()
        } catch {
            log.error("AlarmKit authorization threw: \(error.localizedDescription, privacy: .public)")
        }
        return permission
    }

    /// How many alarms the system is holding for this app. The honest answer
    /// to "is my alarm set", and the one thing worth trusting over anything
    /// the app itself has written down.
    static var scheduledCount: Int {
        (try? AlarmManager.shared.alarms.count) ?? 0
    }

    func cancel() {
        try? AlarmManager.shared.cancel(id: Self.weekdayAlarmID)
        try? AlarmManager.shared.cancel(id: Self.weekendAlarmID)
        Self.cancelFollowUps()
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

// MARK: - The chain

/// When the follow-up alarms ring, as clock times.
///
/// Split out from the scheduling so the arithmetic can be checked: an alarm
/// late at night pushes its chain past midnight, and a chain that silently
/// landed at hour 24 would never ring at all.
enum MorningAlarmChain {
    static let count = 4
    static let stepMinutes = 3

    static func times(hour: Int, minute: Int) -> [(hour: Int, minute: Int)] {
        (1...count).map { i in
            let total = hour * 60 + minute + i * stepMinutes
            return ((total / 60) % 24, total % 60)
        }
    }
}
