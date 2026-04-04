import Foundation

struct FeedbackItem {
    let tag: String
    let body: String
}

enum FeedbackContent {

    static func item(streak: Int, mode: String) -> FeedbackItem {
        if let milestone = milestone(for: streak) { return milestone }
        return daily(for: mode)
    }

    // MARK: - Milestone messages (streak-triggered)

    private static func milestone(for streak: Int) -> FeedbackItem? {
        switch streak {
        case 3:
            return FeedbackItem(
                tag: "3-DAY STREAK",
                body: "Three mornings in a row.\nThe hardest part is already behind you."
            )
        case 7:
            return FeedbackItem(
                tag: "7-DAY STREAK",
                body: "A full week.\nYou're building something real here."
            )
        case 14:
            return FeedbackItem(
                tag: "14-DAY STREAK",
                body: "Two weeks of intentional mornings.\nThat's not a habit — that's a practice."
            )
        case 30:
            return FeedbackItem(
                tag: "30-DAY STREAK",
                body: "Thirty mornings.\nMost people never get here.\nYou did."
            )
        default:
            return nil
        }
    }

    // MARK: - Daily rotational messages (mode-aware)

    private static func daily(for mode: String) -> FeedbackItem {
        let pool: [FeedbackItem]
        switch mode {
        case "push":
            pool = drivenPool
        case "protect":
            pool = gentlePool
        default:
            pool = steadyPool
        }
        let day = Calendar.current.component(.day, from: Date())
        return pool[day % pool.count]
    }

    private static let steadyPool: [FeedbackItem] = [
        FeedbackItem(tag: "REFLECTION", body: "Steady is underrated.\nYou showed up. That counts."),
        FeedbackItem(tag: "REFLECTION", body: "Not every morning needs to be a breakthrough.\nSome just need to start."),
        FeedbackItem(tag: "REFLECTION", body: "Consistency over intensity.\nYou're living that."),
        FeedbackItem(tag: "REFLECTION", body: "Small mornings build large lives.\nKeep going."),
        FeedbackItem(tag: "REFLECTION", body: "One reset at a time.\nThat's how it works."),
    ]

    private static let drivenPool: [FeedbackItem] = [
        FeedbackItem(tag: "MOMENTUM", body: "High energy this morning.\nChannel it well today."),
        FeedbackItem(tag: "MOMENTUM", body: "Driven mornings set the tone.\nYou've already started strong."),
        FeedbackItem(tag: "MOMENTUM", body: "This energy is yours.\nProtect it through the day."),
        FeedbackItem(tag: "MOMENTUM", body: "Focus follows intention.\nYou set yours today."),
        FeedbackItem(tag: "MOMENTUM", body: "The day bends toward how you start it.\nWell done."),
    ]

    private static let gentlePool: [FeedbackItem] = [
        FeedbackItem(tag: "EASE", body: "Gentle mornings are not weak mornings.\nThey're wise ones."),
        FeedbackItem(tag: "EASE", body: "Starting soft is still starting.\nYou're here."),
        FeedbackItem(tag: "EASE", body: "Rest and reset aren't opposites.\nSometimes they're the same thing."),
        FeedbackItem(tag: "EASE", body: "Not every day needs full throttle.\nToday needed this."),
        FeedbackItem(tag: "EASE", body: "Showing up quietly still counts.\nMaybe more."),
    ]
}
