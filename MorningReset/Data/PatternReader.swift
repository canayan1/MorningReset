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
                return "This morning feels slower — keep it simple."
            case "steady":
                return "Start steady. No need to rush."
            case "push":
                return "Move with intention today."
            default: break
            }
        }

        let intentions7 = last7.map { $0.intention }
        if let top = intentions7.mostFrequent(), intentions7.filter({ $0 == top }).count >= 3 {
            return "Today you're leaning toward \(top.capitalized)."
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
                return "Your mornings have been slower lately."
            case "steady":
                return "You've been leaning toward steadiness recently."
            case "push":
                return "You're building consistency, even if it feels small."
            default: break
            }
        }

        if let top = intentions.mostFrequent(), intentions.filter({ $0 == top }).count >= 5 {
            return "You've been returning to \(top.capitalized) a lot this week."
        }

        return nil
    }

    // MARK: - Today reflection (always available, no history needed)

    static func todayReflection(mode: MorningMode, intention: IntentionType) -> String {
        switch (mode, intention) {
        case (.protect, .calm):
            return "Today begins with a lighter step."
        case (.protect, .focus):
            return "Keep your attention where it matters."
        case (.protect, .energy):
            return "Start steady. No need to rush."
        case (.protect, .confidence):
            return "Today is about clarity, not intensity."
        case (.protect, .connection):
            return "Move with intention today."
        case (.protect, .discipline):
            return "This morning feels slower — keep it simple."
        case (.steady, .focus):
            return "Keep your attention where it matters."
        case (.steady, .calm):
            return "You're starting with calm today."
        case (.steady, .energy):
            return "Start steady. No need to rush."
        case (.steady, .confidence):
            return "Today is about clarity, not intensity."
        case (.steady, .connection):
            return "Move with intention today."
        case (.steady, .discipline):
            return "Today is about clarity, not intensity."
        case (.push, .calm):
            return "You're starting with calm today."
        case (.push, .focus):
            return "Today you're leaning toward Focus."
        case (.push, .energy):
            return "Move with intention today."
        case (.push, .confidence):
            return "Today is about clarity, not intensity."
        case (.push, .connection):
            return "Move with intention today."
        case (.push, .discipline):
            return "Today is about clarity, not intensity."
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
