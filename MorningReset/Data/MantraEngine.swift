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

enum SoundDirection: CaseIterable, Identifiable {
    case calm, focus, energy

    var id: Self { self }

    var label: String {
        switch self {
        case .calm:   return "Calm"
        case .focus:  return "Focus"
        case .energy: return "Energy"
        }
    }

    var playlistURL: URL? {
        switch self {
        case .calm:   return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DX3Ogo9pFvBkY")
        case .focus:  return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DXZeyjIkhend1")
        case .energy: return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP")
        }
    }

    static func recommended(for mode: MorningMode) -> SoundDirection {
        switch mode {
        case .protect: return .calm
        case .steady:  return .focus
        case .push:    return .energy
        }
    }
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
        MantraLibrary.mantra(for: date).text
    }

    private static let protectBases = [
        "Today doesn't need to be big. Just a little lighter than yesterday.",
        "You don't have to fight the morning. Meet it where it is.",
        "Less noise, less pressure. That's enough to work with."
    ]

    private static let steadyBases = [
        "You know what to do. Stay with it and don't overcomplicate today.",
        "No sudden moves. Keep the rhythm you already have.",
        "Today is a continuation, not a restart. Pick up where you left off."
    ]

    private static let pushBases = [
        "You have something going. Use it cleanly and don't overload the day.",
        "Move forward. Not faster — just forward.",
        "One good decision builds the next. Start there."
    ]
}
