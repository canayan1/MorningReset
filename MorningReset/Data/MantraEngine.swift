import Foundation

enum MorningMode: String {
    case protect, steady, push

    init?(from string: String) {
        self.init(rawValue: string.lowercased())
    }
}

enum IntentionType: String, CaseIterable {
    case calm, focus, energy, confidence, connection, discipline

    var label: String { rawValue.capitalized }
}

enum MantraEngine {

    private static let startDateKey = "mantra_start_date"

    private static var cycleIndex: Int {
        let defaults = UserDefaults.standard
        let start: Date
        if let stored = defaults.object(forKey: startDateKey) as? Date {
            start = stored
        } else {
            let now = Date()
            defaults.set(now, forKey: startDateKey)
            start = now
        }
        let days = max(0, Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0)
        return (days / 21) % 3
    }

    static func generate(mode: MorningMode, intention: IntentionType) -> String {
        if mode == .protect && intention == .calm       { return "Today, you move gently and protect your attention." }
        if mode == .steady  && intention == .focus      { return "Today, you stay clear and follow what matters." }
        if mode == .push    && intention == .discipline { return "Today, you take action and build momentum." }

        let base: String
        switch mode {
        case .protect: base = protectBases[cycleIndex]
        case .steady:  base = steadyBases[cycleIndex]
        case .push:    base = pushBases[cycleIndex]
        }

        let modifier: String
        switch intention {
        case .calm:        modifier = "Calm is the method."
        case .focus:       modifier = "One thing at a time."
        case .energy:      modifier = "Direct what you have."
        case .confidence:  modifier = "Act on what you know."
        case .connection:  modifier = "Presence over performance."
        case .discipline:  modifier = "Do the first thing."
        }

        return "\(base) \(modifier)"
    }

    // MARK: - Weekly mantra

    static func weeklyMantra(for date: Date = Date()) -> String {
        let week = Calendar.current.component(.weekOfYear, from: date)
        return weeklyMantras[(week - 1) % weeklyMantras.count]
    }

    private static let weeklyMantras: [String] = [
        "Small steps still move things forward.",
        "Steady is enough.",
        "One thing at a time is a complete strategy.",
        "What you give attention to, you feed.",
        "A clear start is worth protecting.",
        "You don't have to earn rest.",
        "Direction matters more than speed.",
        "Presence is the work.",
        "A calm morning is a choice worth making.",
        "Not everything needs a reaction.",
        "Doing less, better, is still progress.",
        "What's worth your focus today?",
        "Stillness is not the absence of momentum.",
        "The first hour sets the shape of the day.",
        "You can slow down without stopping.",
        "Simple decisions made calmly compound over time.",
        "Attention is the thing you're actually spending.",
        "What you protect in the morning stays yours.",
        "Good enough, done, beats perfect, pending.",
        "Some mornings just need to begin.",
        "Consistency is less visible than results — and more important.",
        "What's one thing you can finish today?",
        "Progress doesn't always look like movement.",
        "You're allowed to set the pace.",
        "The noise is always loud. Your direction doesn't have to change.",
        "Rest is part of the work.",
        "How you start shapes how you continue.",
        "Not everything is urgent. You get to decide what is.",
        "You already know what matters.",
        "Calm is a skill, not a personality type.",
        "Slow mornings tend to produce clearer days.",
        "One honest effort is worth ten distracted ones.",
        "What you let in first thing matters.",
        "Some days are for building. Some are for holding ground.",
        "The simplest path is often the right one.",
        "You are not behind.",
        "What would a steady day look like?",
        "Ease is not weakness.",
        "Being present is the most useful thing.",
        "Clarity before speed.",
        "The most important thing is usually obvious — we just skip it.",
        "You have enough to begin.",
        "Momentum starts small.",
        "Your attention is a limited resource. Spend it deliberately.",
        "What matters at the end of today?",
        "Let the first hour belong to you.",
        "A good morning doesn't require everything to go right.",
        "Make one decision clearly. Then the next.",
        "The steadiest people are not the fastest ones.",
        "You're building something — even if you can't see it yet.",
        "Take one clear breath. Then begin.",
        "What you do in the first ten minutes echoes through the day.",
    ]

    private static let protectBases = [
        "You've been showing up — continue from there.",
        "You've been showing up — continue from there.",
        "You've been showing up — continue from there."
    ]

    private static let steadyBases = [
        "You've been moving steadily — keep that direction.",
        "You've been moving steadily — keep that direction.",
        "You've been moving steadily — keep that direction."
    ]

    private static let pushBases = [
        "You're building something consistent — stay with it.",
        "You're building something consistent — stay with it.",
        "You're building something consistent — stay with it."
    ]
}
