import Foundation
import ActivityKit

// Live Activity attributes for the morning wake-up Live Activity.
// Lives on the lock screen from when the user goes to bed until they
// complete (or dismiss) the morning reset.
//
// Shared between the main app (which starts/updates/ends the activity)
// and the widget extension (which renders the lock screen / Dynamic Island UI).

struct WakeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // The scheduled wake fire time (used by Live Activity timer views).
        let fireDate: Date
        // Current state of the wake moment.
        let phase: Phase
        // Localized one-line ritual tagline shown on the lock screen.
        let tagline: String

        enum Phase: String, Codable, Hashable {
            case armed       // Set tonight, waiting for fireDate
            case ringing     // fireDate reached, awaiting user tap
            case completed   // User has begun the flow
        }
    }

    // Fixed identifier shown to the user in lock screen settings.
    let label: String
}
