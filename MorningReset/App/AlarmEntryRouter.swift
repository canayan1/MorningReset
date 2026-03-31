import Foundation

// MARK: - AlarmEntryRouter
//
// The single entry point for all alarm-triggered app opens.
// Any alarm backend — LocalNotificationAlarmManager today,
// AlarmKitManager tomorrow — calls routeToWakeFlow() here.
// Navigation logic lives here, not inside the notification delegate.
//
// Future AlarmKit integration:
//   When AlarmKitManager is fully wired, have its wake callback call
//   AlarmEntryRouter.shared.routeToWakeFlow(). No other code changes.
//
// Cold launch safety:
//   If routeToWakeFlow() fires before appState is set (cold launch race),
//   the action is stored and replayed the moment appState becomes available.

final class AlarmEntryRouter {

    weak var appState: AppState? {
        didSet {
            guard pendingWakeFlow else { return }
            pendingWakeFlow = false
            performRoute()
        }
    }

    private var pendingWakeFlow = false

    /// Route directly into the morning flow, bypassing AlarmView.
    /// Safe to call before appState is wired — action will be replayed.
    func routeToWakeFlow() {
        guard appState != nil else {
            pendingWakeFlow = true
            return
        }
        performRoute()
    }

    private func performRoute() {
        DispatchQueue.main.async {
            self.appState?.startFlow()
        }
    }
}
