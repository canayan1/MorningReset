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
        case .calm:        modifier = "Calm is the method."
        case .focus:       modifier = "One thing at a time."
        case .energy:      modifier = "Direct what you have."
        case .confidence:  modifier = "Act on what you know."
        case .connection:  modifier = "Presence over performance."
        case .discipline:  modifier = "Do the first thing."
        }

        return "\(base) \(modifier)"
    }

    private static let protectBases = [
        "Slow is still forward.",
        "Protect the baseline first.",
        "Less today means more tomorrow."
    ]

    private static let steadyBases = [
        "Use the window while it's open.",
        "Clean conditions. Don't waste them.",
        "Momentum doesn't need a perfect start."
    ]

    private static let pushBases = [
        "The signal is here. Move on it.",
        "Don't ease into a morning like this.",
        "Move before the day finds you."
    ]
}
