import AppIntents
import AlarmKit
import Foundation

// MARK: - AlarmKit metadata (no custom fields needed)

@available(iOS 26.1, *)
struct MorningAlarmMeta: AlarmMetadata {}

// MARK: - Stop intent: called when user dismisses the alarm

@available(iOS 26.1, *)
struct StopMorningAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Start Inner Light"
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: "group.com.canayan.MorningReset")?
            .set(true, forKey: "alarmKitStartFlow")
        return .result()
    }
}
