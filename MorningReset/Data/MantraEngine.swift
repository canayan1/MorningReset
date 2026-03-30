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
        let base: String
        switch mode {
        case .protect: base = protectBases[cycleIndex]
        case .steady:  base = steadyBases[cycleIndex]
        case .push:    base = pushBases[cycleIndex]
        }

        let modifier: String
        switch intention {
        case .calm:        modifier = "Begin with calm."
        case .focus:       modifier = "Stay on one thing."
        case .energy:      modifier = "Channel what you have."
        case .confidence:  modifier = "Move as if it's already done."
        case .connection:  modifier = "Start with presence."
        case .discipline:  modifier = "Do the work first."
        }

        return "\(base) \(modifier)"
    }

    private static let protectBases = [
        "Protect your energy today.",
        "This morning calls for stability.",
        "Move slow and stay intact."
    ]

    private static let steadyBases = [
        "Use this morning well.",
        "You have enough to move forward.",
        "Keep the rhythm, not the rush."
    ]

    private static let pushBases = [
        "Your drive is here. Use it.",
        "The morning is yours.",
        "Move early. Move deliberately."
    ]
}
