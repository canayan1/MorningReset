import SwiftUI
import UserNotifications

@main
struct MorningResetApp: App {
    @State private var appState = AppState()
    private let notificationDelegate = NotificationDelegate()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    notificationDelegate.appState = appState
                    UNUserNotificationCenter.current().delegate = notificationDelegate
                }
        }
    }
}

// MARK: - NotificationDelegate
//
// Intercepts UNUserNotificationCenter callbacks for both backends:
//
//   UNAlarmBackend path:
//     Notification fires → user taps banner → didReceive fires →
//     userInfo["action"] == "startWakeFlow" → appState.startFlow()
//
//   AlarmKitBackend path (iOS 26+):
//     AlarmKit may deliver its own wake callback in addition to or instead of
//     a standard notification response. When AlarmKitBackend is implemented,
//     add the AlarmKit delegate conformance here alongside this class,
//     or extend NotificationDelegate to also conform to the AlarmKit delegate protocol.
//
// Both paths route into the same appState.startFlow() entry point.

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var appState: AppState?

    // App is foregrounded when notification fires — show banner and play sound.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // User tapped the notification banner.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = response.notification.request.content.userInfo["action"] as? String
        if action == "startWakeFlow" {
            DispatchQueue.main.async {
                self.appState?.startFlow()
            }
        }
        completionHandler()
    }
}
