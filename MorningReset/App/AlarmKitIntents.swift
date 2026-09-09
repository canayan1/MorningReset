import AppIntents
import AlarmKit
import Foundation

// MARK: - Begin: the alarm's second button
//
// Stop is the system's own and just silences the alarm. Begin opens the app
// straight into the practice: it leaves a flag in the shared container, and the
// app picks it up on activation and starts the session without a tap.

@available(iOS 26.1, *)
struct BeginPracticeIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Begin practice"
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: "group.com.canayan.MorningReset")?
            .set(true, forKey: "alarmKitStartFlow")
        return .result()
    }
}
