import SwiftUI
import UserNotifications

@main
struct MorningResetApp: App {
    @State private var appState: AppState
    @State private var insightEngine: InsightEngine
    @Environment(\.scenePhase) private var scenePhase

    // Both objects are created before the scene is ready.
    // The delegate is registered in init() so cold-launch notification
    // responses are captured before the first run loop tick.
    private let router               = AlarmEntryRouter()
    private let notificationDelegate = WakeNotificationDelegate()

    init() {
        let launchConfig = LaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
        launchConfig.apply()
        let initialState = AppState(skipEntitlementCheck: launchConfig.skipEntitlementCheck)
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-showPathLearn") {
            initialState.onboardingSeen = true
            initialState.screen = .pathLearn
        } else if args.contains("-showQuiz") {
            initialState.onboardingSeen = true
            initialState.screen = .quiz
        } else if args.contains("-showLibrary") {
            initialState.onboardingSeen = true
            initialState.activeTab = .library
        }
        _appState = State(initialValue: initialState)
        _insightEngine = State(initialValue: InsightEngine())
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(insightEngine)
                .onAppear {
                    // Wire appState into the router here, not in init(),
                    // because @State is not accessible before the scene renders.
                    router.appState               = appState
                    notificationDelegate.router   = router
                    checkAlarmKitWakeFlag()
                    reconcileWakeActivity()
                }
                .onOpenURL { url in
                    guard url.scheme == "morningreset", url.host == "start" else { return }
                    // The daily reminder opens today's practice, not the retired ritual.
                    appState.showWakeHome()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        checkAlarmKitWakeFlag()
                        reconcileWakeActivity()
                    }
                }
        }
    }

    /// On every foreground, ensure the morning Live Activity is in the
    /// correct state. Critical for users who set their wake time during
    /// the day — the Activity should appear later, when they open the
    /// app close to bedtime.
    /// When the AlarmKit stop intent fires, it writes a flag to the shared
    /// UserDefaults suite. Check and clear that flag on every app foreground
    /// so AlarmEntryRouter can route to the morning flow.
    private func checkAlarmKitWakeFlag() {
        let defaults = UserDefaults(suiteName: "group.com.canayan.MorningReset")
        guard defaults?.bool(forKey: "alarmKitStartFlow") == true else { return }
        defaults?.removeObject(forKey: "alarmKitStartFlow")
        router.routeToWakeFlow()
    }

    @MainActor
    private func reconcileWakeActivity() {
        let schedule = WakeScheduleStore.load()
        guard schedule.isEnabled else {
            WakeActivityController.endAll()
            return
        }
        let fireDate = LocalNotificationWakeScheduler().nextFireDate(for: schedule)
        WakeActivityController.reconcile(
            fireDate: fireDate,
            tagline: L10n.text(
                en: "Your daily reset is ready.",
                tr: "Scroll başlamadan önce sessiz bir ritüel.",
                es: "Un ritual tranquilo antes del scroll."
            )
        )
    }
}

private struct LaunchConfiguration {
    let arguments: [String]

    var skipEntitlementCheck: Bool {
        arguments.contains("-uiTesting")
    }

    func apply() {
        guard arguments.contains("-uiTesting") else { return }
        resetPersistentStateIfNeeded()
        applyOnboardingState()
        applyWakeScheduleIfNeeded()
        applyPremiumState()
        applyRecentPaywallIfNeeded()
        seedHistoryIfNeeded()
        seedGoalIfNeeded()
        seedFirstWinIfNeeded()
        seedPracticeIfNeeded()
    }

    private func resetPersistentStateIfNeeded() {
        guard arguments.contains("-resetState"), let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        UserDefaults.standard.synchronize()
        // Daily entries live in the shared App Group, not standard defaults — clear them
        // too so each UI-test run starts from a clean, deterministic streak.
        if let group = UserDefaults(suiteName: "group.com.canayan.MorningReset") {
            group.removeObject(forKey: UDKey.dailyEntries)
        }
        FirstWinStore.saveActive(nil)
        FirstWinStore.saveCompleted([])
    }

    private func seedGoalIfNeeded() {
        guard arguments.contains("-seedGoal") else { return }
        UserDefaults.standard.set(EnergyPath.reiki.rawValue, forKey: UDKey.energyPath)
    }

    private func seedFirstWinIfNeeded() {
        guard arguments.contains("-seedFirstWin") else { return }
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        UserDefaults.standard.set(EnergyPath.qigong.rawValue, forKey: UDKey.energyPath)
        FirstWinStore.saveActive(ActiveFirstWin(kind: .practice(path: .qigong, id: "qi.sky"), streak: 2, lastCheckDay: yesterday, startedAt: Date()))
        let done = [
            EnergyPath.qigong.practice(id: "qi.shake"),
            EnergyPath.breathwork.practice(id: "breath.nadi")
        ].compactMap { $0 }
        FirstWinStore.saveCompleted(done.map { CompletedFirstWin(symbol: $0.symbol, title: $0.title, completedAt: Date()) })
    }

    /// A week of real practice, so the Wins screen and the orb show what the app
    /// looks like once someone has been using it — not an empty state.
    private func seedPracticeIfNeeded() {
        guard arguments.contains("-seedPractice") else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Seven consecutive mornings, so the streak reads 7.
        let entries = (0..<7).compactMap { offset -> DailyEntry? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DailyEntry(date: day,
                              mode: MorningMode.steady.rawValue,
                              intention: IntentionType.focus.rawValue)
        }
        DailyEntryStore.replaceAll(entries)

        // The sessions behind that streak, spread across five schools. One is
        // left `partial` so the honest-logging behaviour is visible.
        let plan: [(String, String, String, Int, PracticeOutcome, Int)] = [
            ("reiki",      "reiki.r01",      "First Gassho",                    5, .done,    0),
            ("breathing",  "breathing.r02",  "The Longer Out-Breath",           4, .done,    0),
            ("qigong",     "qigong.r02",     "Shake It Loose",                  4, .done,    1),
            ("meditation", "meditation.r01", "Three-Minute Breath Anchor",      3, .done,    1),
            ("reiki",      "reiki.r03",      "Kenyoku: Dry Bathing",            4, .done,    2),
            ("nature",     "nature.r01",     "Two Minutes of Morning Daylight", 2, .done,    3),
            ("journal",    "journal.r01",    "One Line of Gratitude",           2, .partial, 3),
            ("breathing",  "breathing.r03",  "Belly Breathing",                 5, .done,    4),
            ("qigong",     "qigong.r01",     "Wuji Standing: Finding Your Root", 5, .done,   5),
            ("reiki",      "reiki.r02",      "For Today Only",                  3, .done,    6)
        ]
        let sessions = plan.compactMap { school, routine, title, minutes, outcome, daysAgo -> PracticeSession? in
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: today),
                  let at = cal.date(byAdding: .minute, value: 7 * 60 + 20, to: day)
            else { return nil }
            return PracticeSession(schoolID: school,
                                   routineID: routine,
                                   routineTitle: title,
                                   date: at,
                                   minutes: minutes,
                                   outcome: outcome)
        }
        PracticeLogStore.replaceAll(sessions)
    }

    private func applyOnboardingState() {
        guard arguments.contains("-skipOnboarding") else { return }
        UserDefaults.standard.set(true, forKey: UDKey.onboardingComplete)
    }

    private func applyWakeScheduleIfNeeded() {
        guard arguments.contains("-enableSchedule") else { return }
        WakeScheduleStore.save(
            WakeSchedule(
                weekdayHour: 7,
                weekdayMinute: 0,
                weekendHour: 8,
                weekendMinute: 0,
                isEnabled: true
            )
        )
    }

    private func applyPremiumState() {
        if arguments.contains("-premiumUnlocked") {
            UserDefaults.standard.set(true, forKey: UDKey.premiumUnlocked)
        } else if arguments.contains("-premiumLocked") {
            UserDefaults.standard.set(false, forKey: UDKey.premiumUnlocked)
        }
    }

    private func applyRecentPaywallIfNeeded() {
        guard arguments.contains("-suppressPeriodicPaywall") else { return }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UDKey.paywallLastShown)
    }

    private func seedHistoryIfNeeded() {
        guard arguments.contains("-seedStrongPattern") else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = (0..<5).map { offset in
            DailyEntry(
                date: calendar.date(byAdding: .day, value: -offset, to: today) ?? today,
                mode: MorningMode.steady.rawValue,
                intention: IntentionType.focus.rawValue
            )
        }
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: UDKey.dailyEntries)
        UserDefaults.standard.set(0, forKey: UDKey.paywallLastShown)
    }
}

// MARK: - WakeNotificationDelegate
//
// Handles UNUserNotificationCenter callbacks for the morning notification entry.
// Delegates all navigation decisions to AlarmEntryRouter — this class only
// reads the notification payload and decides whether to route.
//
// AlarmKit integration note:
//   When AlarmKitManager is wired, add the AlarmKit delegate conformance
//   alongside this class (or extend it). Both call router.routeToWakeFlow().

final class WakeNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var router: AlarmEntryRouter?

    // Keep banner + sound visible even when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // User tapped the morning notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = response.notification.request.content.userInfo["action"] as? String
        if action == "startWakeFlow" {
            router?.routeToWakeFlow()
        }
        completionHandler()
    }
}
