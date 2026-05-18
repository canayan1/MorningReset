import SwiftUI
import UserNotifications

@main
struct MorningResetApp: App {
    @State private var appState: AppState
    @State private var insightEngine: InsightEngine

    // Both objects are created before the scene is ready.
    // The delegate is registered in init() so cold-launch notification
    // responses are captured before the first run loop tick.
    private let router               = AlarmEntryRouter()
    private let notificationDelegate = WakeNotificationDelegate()

    init() {
        let launchConfig = LaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
        launchConfig.apply()
        _appState = State(initialValue: AppState(skipEntitlementCheck: launchConfig.skipEntitlementCheck))
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
                }
                .onOpenURL { url in
                    guard url.scheme == "morningreset", url.host == "start" else { return }
                    appState.startFlow()
                }
        }
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
    }

    private func resetPersistentStateIfNeeded() {
        guard arguments.contains("-resetState"), let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        UserDefaults.standard.synchronize()
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
