import Foundation

// MARK: - Enums

enum FlowDifficulty: String, Codable, CaseIterable {
    case easy, neutral, hard

    var label: String {
        switch self {
        case .easy:    return "Easy"
        case .neutral: return "Neutral"
        case .hard:    return "Hard"
        }
    }
}

enum FlowHelpfulness: String, Codable, CaseIterable {
    case yes, somewhat, no

    var label: String {
        switch self {
        case .yes:      return "Yes"
        case .somewhat: return "Somewhat"
        case .no:       return "Not really"
        }
    }
}

enum FlowTag: String, Codable, CaseIterable {
    case distracted, grounded, sleepy, stressed
    case focused, calm, restless, energized

    var label: String { rawValue.capitalized }
}

// MARK: - Model

struct FlowCheckout: Codable {
    let date: Date
    let mode: String
    let intention: String
    let streakCount: Int
    let difficulty: FlowDifficulty
    let helpfulness: FlowHelpfulness
    let tags: [FlowTag]
}

// MARK: - Store

enum FlowCheckoutStore {
    private static let key = "flow_checkouts"
    private static let cap = 90

    static func load() -> [FlowCheckout] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([FlowCheckout].self, from: data)
        else { return [] }
        return items
    }

    static func append(_ checkout: FlowCheckout) {
        var items = load()
        items.append(checkout)
        if items.count > cap { items = Array(items.suffix(cap)) }
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func last(_ n: Int) -> [FlowCheckout] {
        Array(load().suffix(n))
    }
}
