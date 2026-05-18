import Foundation

// MARK: - Enums

enum FlowDifficulty: String, Codable, CaseIterable {
    case easy, neutral, hard

    var label: String {
        switch self {
        case .easy:
            return L10n.text(en: "Easy", tr: "Kolay", es: "Fácil")
        case .neutral:
            return L10n.text(en: "Neutral", tr: "Nötr", es: "Neutro")
        case .hard:
            return L10n.text(en: "Hard", tr: "Zor", es: "Difícil")
        }
    }
}

enum FlowHelpfulness: String, Codable, CaseIterable {
    case yes, somewhat, no

    var label: String {
        switch self {
        case .yes:
            return L10n.text(en: "Yes", tr: "Evet", es: "Sí")
        case .somewhat:
            return L10n.text(en: "Somewhat", tr: "Biraz", es: "Más o menos")
        case .no:
            return L10n.text(en: "Not really", tr: "Pek değil", es: "No mucho")
        }
    }
}

enum FirstWinStatus: String, Codable, CaseIterable {
    case done, notYet

    var label: String {
        switch self {
        case .done:
            return L10n.text(en: "Yes", tr: "Evet", es: "Sí")
        case .notYet:
            return L10n.text(en: "Not yet", tr: "Henüz değil", es: "Todavía no")
        }
    }
}

enum FlowTag: String, Codable, CaseIterable {
    case distracted, grounded, sleepy, stressed
    case focused, calm, restless, energized

    var label: String {
        switch self {
        case .distracted:
            return L10n.text(en: "Distracted", tr: "Dağınık", es: "Distraído")
        case .grounded:
            return L10n.text(en: "Grounded", tr: "Dengede", es: "Con los pies en la tierra")
        case .sleepy:
            return L10n.text(en: "Sleepy", tr: "Uykulu", es: "Somnoliento")
        case .stressed:
            return L10n.text(en: "Stressed", tr: "Gergin", es: "Estresado")
        case .focused:
            return L10n.text(en: "Focused", tr: "Odaklı", es: "Enfocado")
        case .calm:
            return L10n.text(en: "Calm", tr: "Sakin", es: "Calmado")
        case .restless:
            return L10n.text(en: "Restless", tr: "Huzursuz", es: "Inquieto")
        case .energized:
            return L10n.text(en: "Energized", tr: "Enerjik", es: "Con energía")
        }
    }
}

// MARK: - Model

struct FlowCheckout: Codable {
    let date: Date
    let mode: String
    let intention: String
    let streakCount: Int
    let firstWin: FirstWinAction
    let firstWinStatus: FirstWinStatus
    let difficulty: FlowDifficulty
    let helpfulness: FlowHelpfulness
    let tags: [FlowTag]

    private enum CodingKeys: String, CodingKey {
        case date
        case mode
        case intention
        case streakCount
        case firstWin
        case firstWinStatus
        case difficulty
        case helpfulness
        case tags
    }

    init(
        date: Date,
        mode: String,
        intention: String,
        streakCount: Int,
        firstWin: FirstWinAction,
        firstWinStatus: FirstWinStatus,
        difficulty: FlowDifficulty,
        helpfulness: FlowHelpfulness,
        tags: [FlowTag]
    ) {
        self.date = date
        self.mode = mode
        self.intention = intention
        self.streakCount = streakCount
        self.firstWin = firstWin
        self.firstWinStatus = firstWinStatus
        self.difficulty = difficulty
        self.helpfulness = helpfulness
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        mode = try container.decode(String.self, forKey: .mode)
        intention = try container.decode(String.self, forKey: .intention)
        streakCount = try container.decode(Int.self, forKey: .streakCount)
        firstWin = try container.decodeIfPresent(FirstWinAction.self, forKey: .firstWin) ?? .water
        firstWinStatus = try container.decodeIfPresent(FirstWinStatus.self, forKey: .firstWinStatus) ?? .done
        difficulty = try container.decodeIfPresent(FlowDifficulty.self, forKey: .difficulty) ?? .neutral
        helpfulness = try container.decodeIfPresent(FlowHelpfulness.self, forKey: .helpfulness) ?? .somewhat
        tags = try container.decodeIfPresent([FlowTag].self, forKey: .tags) ?? []
    }
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
