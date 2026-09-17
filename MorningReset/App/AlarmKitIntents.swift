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
        // Silence the alarm here, not later. Begin used to only raise a flag,
        // so the alarm kept ringing over the whole of the morning it had just
        // handed over to — you were asked to hold still for a pulse reading
        // while the phone shouted at you. The app brings the same bell back
        // underneath, much quieter, as soon as the ritual opens.
        if #available(iOS 26.1, *) { AlarmKitWakeScheduler.silenceRinging() }
        return .result()
    }
}
