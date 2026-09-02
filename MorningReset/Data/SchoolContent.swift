import Foundation

// MARK: - School content v2 (Energy Reset)
//
// Content lives in bundled JSON (content/schools/<id>.json) so schools can be
// authored and audited as data. Each school teaches: overview → teachings →
// routines (grouped, with steps). Framing stays experiential; traditional
// practices are labelled traditional, never medical.

enum SchoolKind: String, Codable {
    case traditional
    case evidence
}

enum RoutineGroup: String, Codable, CaseIterable {
    case starter, core, deep, restorative

    var title: String {
        switch self {
        case .starter:     return "Starter"
        case .core:        return "Core"
        case .deep:        return "Deep"
        case .restorative: return "Restorative"
        }
    }
}

struct Teaching: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
}

struct Routine: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let group: RoutineGroup
    let minutes: Int
    let purpose: String
    let steps: [String]
    let safety: String?
    let free: Bool
}

struct SchoolContent: Codable, Identifiable {
    let id: String
    let name: String
    let tagline: String
    let overview: String
    let kind: SchoolKind
    let framingNote: String
    /// Short plain-English rider shown under the (often unfamiliar) name.
    let subtitle: String?
    let pronunciation: String?
    /// One cited line of provenance, shown on the detail screen.
    let origin: String?
    let teachings: [Teaching]
    let routines: [Routine]
    let sources: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, tagline, overview, kind, teachings, routines, sources
        case subtitle, pronunciation, origin
        case framingNote = "framing_note"
    }

    func routines(in group: RoutineGroup) -> [Routine] {
        routines.filter { $0.group == group }
    }

    var freeRoutine: Routine? { routines.first(where: { $0.free }) }
}

enum SchoolContentStore {
    /// School ids in display order.
    static let order = ["reiki", "breathing", "qigong", "meditation", "yoga",
                        "sound", "coldheat", "sleep", "nature", "journal"]

    static let all: [SchoolContent] = order.compactMap(load)

    static func load(_ id: String) -> SchoolContent? {
        // Content ships as a folder reference, so look in the Schools/ subdirectory
        // first and fall back to the bundle root.
        let url = Bundle.main.url(forResource: id, withExtension: "json", subdirectory: "Schools")
            ?? Bundle.main.url(forResource: id, withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        do {
            return try JSONDecoder().decode(SchoolContent.self, from: data)
        } catch {
            assertionFailure("School content decode failed for \(id): \(error)")
            return nil
        }
    }

    static func school(_ id: String) -> SchoolContent? {
        all.first { $0.id == id }
    }

    /// Which paid tier a school belongs to. Every school still ships one free
    /// routine, so all ten are sampleable without paying.
    /// Resolve a logged session back to its school and routine.
    static func lookup(schoolID: String, routineID: String) -> (SchoolContent, Routine)? {
        guard let s = school(schoolID), let r = s.routines.first(where: { $0.id == routineID }) else { return nil }
        return (s, r)
    }

    static func tier(for id: String) -> EnergyTier {
        switch id {
        case "breathing", "meditation", "yoga", "journal", "nature": return .foundations
        default:                                                     return .deep   // reiki, qigong, sound, coldheat, sleep
        }
    }
}
