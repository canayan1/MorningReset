import Foundation

enum InsightStrength {
    case none, weak, strong
}

enum PatternReader {

    // MARK: - Strength

    static func strength(for history: [DailyEntry]) -> InsightStrength {
        guard history.count >= 3 else { return .none }
        let last7 = Array(history.suffix(7))
        let last3 = Array(history.suffix(3))

        // Strong: same mode or intention in 5+ of last 7
        if last7.count >= 5 {
            let modes = last7.map { $0.mode }
            if let top = modes.mostFrequent(), modes.filter({ $0 == top }).count >= 5 { return .strong }
            let intentions = last7.map { $0.intention }
            if let top = intentions.mostFrequent(), intentions.filter({ $0 == top }).count >= 5 { return .strong }
        }

        // Weak: same mode all 3 of last 3, or same intention 3+ of last 7
        let modes3 = last3.map { $0.mode }
        if Set(modes3).count == 1 { return .weak }
        let intentions7 = last7.map { $0.intention }
        if let top = intentions7.mostFrequent(), intentions7.filter({ $0 == top }).count >= 3 { return .weak }

        return .none
    }

    // MARK: - Insight text

    static func weakInsight(for history: [DailyEntry]) -> String? {
        let last7 = Array(history.suffix(7))
        let last3 = Array(history.suffix(3))

        let modes3 = last3.map { $0.mode }
        if Set(modes3).count == 1, let mode = modes3.first {
            switch mode {
            case "protect":
                return "Lately your mornings have been starting slow. That's a pattern — not a problem, just something to work with."
            case "steady":
                return "It looks like your mornings have been consistent lately. That kind of baseline is worth holding."
            case "push":
                return "Your mornings have had good signal lately. That doesn't mean push harder — it means direct it somewhere useful."
            default: break
            }
        }

        let intentions7 = last7.map { $0.intention }
        if let top = intentions7.mostFrequent(), intentions7.filter({ $0 == top }).count >= 3 {
            return "This week you keep coming back to \(top.capitalized). That kind of pull is usually pointing at something real."
        }

        return nil
    }

    static func strongInsight(for history: [DailyEntry]) -> String? {
        let last7 = Array(history.suffix(7))
        let modes = last7.map { $0.mode }
        let intentions = last7.map { $0.intention }

        if let top = modes.mostFrequent(), modes.filter({ $0 == top }).count >= 5 {
            switch top {
            case "protect":
                return "Most of your mornings this week have been in low-energy territory. That's the body asking for margin, not more. Protect that before you push."
            case "steady":
                return "This week your mornings have been consistently workable. That's not boring — it's a rhythm. The question is what you're doing with it."
            case "push":
                return "You've had strong signal most mornings this week. It looks like conditions are good right now. That window won't stay open indefinitely."
            default: break
            }
        }

        if let top = intentions.mostFrequent(), intentions.filter({ $0 == top }).count >= 5 {
            return "You've been orienting toward \(top.capitalized) most of this week. That kind of consistency usually means it's either still unresolved, or it's where you actually want to go."
        }

        return nil
    }

    // MARK: - Today reflection (always available, no history needed)

    static func todayReflection(mode: MorningMode, intention: IntentionType) -> String {
        switch (mode, intention) {
        case (.protect, .calm):
            return "This morning reads as low. That's not a bad thing — it's just information. Calm is the right call."
        case (.protect, .focus):
            return "It looks like a slow start today. Focus, in this case, might mean fewer things rather than harder ones."
        case (.protect, .energy):
            return "Today's signal is low. Energy today is probably better protected than spent."
        case (.protect, .confidence):
            return "This morning reads as low. Confidence today isn't about doing more — it's about not letting that stop you."
        case (.protect, .connection):
            return "Today starts slow. Showing up quietly is still showing up."
        case (.protect, .discipline):
            return "This morning is a low one. Discipline today looks like holding the line, not pushing through it."
        case (.steady, .focus):
            return "Today looks stable. That's a good condition for staying with one thing — use it before it shifts."
        case (.steady, .calm):
            return "You're starting steady today. Calm here isn't passive — it's how you keep the morning clean."
        case (.steady, .energy):
            return "Today has a usable baseline. Not a push day, but enough to make real progress if you direct it."
        case (.steady, .confidence):
            return "Steady morning today. The next move doesn't need to be bold — it just needs to happen."
        case (.steady, .connection):
            return "Today starts on a level surface. Presence is easier when you're not already running behind."
        case (.steady, .discipline):
            return "This morning looks clean. Discipline in conditions like this is about not wasting the window."
        case (.push, .calm):
            return "Strong signal this morning. Calm here means directing the energy, not suppressing it."
        case (.push, .focus):
            return "This morning has real momentum. Focus today means picking a target before the window closes."
        case (.push, .energy):
            return "High signal this morning. The question isn't whether the energy is there — it's where it goes."
        case (.push, .confidence):
            return "It looks like a strong morning. Conditions like this don't require certainty — they require motion."
        case (.push, .connection):
            return "Today has good momentum. Presence in a morning like this means bringing something, not just showing up."
        case (.push, .discipline):
            return "Strong signal today. Discipline here means using it on what actually matters, not just whatever's in front of you."
        }
    }
}

// MARK: - Array helper

private extension Array where Element == String {
    func mostFrequent() -> String? {
        var counts: [String: Int] = [:]
        for item in self { counts[item, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
