import SwiftUI
import UserNotifications

@main
struct MorningResetApp: App {
    @State private var appState      = AppState()
    @State private var insightEngine = InsightEngine()

    // Both objects are created before the scene is ready.
    // The delegate is registered in init() so cold-launch notification
    // responses are captured before the first run loop tick.
    private let router               = AlarmEntryRouter()
    private let notificationDelegate = WakeNotificationDelegate()

    init() {
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
        }
    }
}

// MARK: - WakeNotificationDelegate
//
// Handles UNUserNotificationCenter callbacks for LocalNotificationAlarmManager.
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

    // User tapped the alarm notification.
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
