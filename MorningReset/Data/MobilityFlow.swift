import Foundation

enum MobilityFlowType {
    case yin
    case vinyasa
}

struct MobilityMove: Identifiable {
    let id: UUID
    let name: String
    let cue: String
    let duration: Int
    let animationName: String
}

struct MobilityFlow: Identifiable {
    let id: UUID
    let month: Int
    let title: String
    let subtitle: String
    let type: MobilityFlowType
    let moves: [MobilityMove]
}
