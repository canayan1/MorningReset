import Foundation
import ActivityKit

// Manages the lifecycle of the morning wake-up Live Activity.
//
// Strategy:
//   - When the user saves a wake schedule, we start an Activity that runs
//     from "now" until ~2 hours after fireDate. The Live Activity stays
//     pinned on the lock screen so it is the first thing the user sees
//     when they pick up the phone in the morning.
//   - On each app launch, we reconcile: if a schedule exists but no
//     Activity, we re-start one. If an Activity exists but the schedule
//     is disabled, we end it.
//   - When the user begins the flow, we mark the Activity .completed
//     and let it dismiss naturally.

@MainActor
enum WakeActivityController {

    private static let label = "Morning Reset"

    private static var current: Activity<WakeActivityAttributes>? {
        Activity<WakeActivityAttributes>.activities.first
    }

    static var isSupported: Bool {
        if #available(iOS 16.2, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }

    static func start(for schedule: WakeSchedule, fireDate: Date, tagline: String) {
        guard #available(iOS 16.2, *), isSupported else { return }

        // End any stale activity before starting a fresh one.
        endAll()

        let attributes = WakeActivityAttributes(label: label)
        let state = WakeActivityAttributes.ContentState(
            fireDate: fireDate,
            phase: .armed,
            tagline: tagline
        )
        let content = ActivityContent(
            state: state,
            staleDate: fireDate.addingTimeInterval(2 * 60 * 60) // expire 2h after fire
        )

        do {
            _ = try Activity<WakeActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Silently ignore — Live Activity is a delight, not a requirement.
        }
    }

    static func transitionToRinging(tagline: String) {
        guard #available(iOS 16.2, *), let activity = current else { return }
        let newState = WakeActivityAttributes.ContentState(
            fireDate: activity.content.state.fireDate,
            phase: .ringing,
            tagline: tagline
        )
        Task {
            await activity.update(ActivityContent(state: newState, staleDate: nil))
        }
    }

    static func markCompleted(tagline: String) {
        guard #available(iOS 16.2, *), let activity = current else { return }
        let finalState = WakeActivityAttributes.ContentState(
            fireDate: activity.content.state.fireDate,
            phase: .completed,
            tagline: tagline
        )
        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .after(.now + 30)
            )
        }
    }

    static func endAll() {
        guard #available(iOS 16.2, *) else { return }
        Task {
            for activity in Activity<WakeActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
