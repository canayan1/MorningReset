import Foundation

struct Question {
    let text: String
    let options: [Option]
}

struct Option {
    let text: String
    let mode: Mode
}

enum Mode: String {
    case focus    = "Focus"
    case recovery = "Recovery"
    case survival = "Survival"
}

struct MorningResult: Equatable {
    let mode: Mode
    let modeLabel: String
    let suggestion: String
    let warning: String
}

enum MorningData {
    static let questions: [Question] = [
        Question(
            text: "How did you sleep?",
            options: [
                Option(text: "Deeply — felt rested", mode: .focus),
                Option(text: "Light but okay",       mode: .recovery),
                Option(text: "Poorly — still tired", mode: .survival),
            ]
        ),
        Question(
            text: "What's your energy level right now?",
            options: [
                Option(text: "High — ready to go",   mode: .focus),
                Option(text: "Medium — warming up",  mode: .recovery),
                Option(text: "Low — barely awake",   mode: .survival),
            ]
        ),
        Question(
            text: "How's your mood?",
            options: [
                Option(text: "Positive and calm",    mode: .focus),
                Option(text: "Neutral",              mode: .recovery),
                Option(text: "Anxious or stressed",  mode: .survival),
            ]
        ),
        Question(
            text: "Can you focus on a single task right now?",
            options: [
                Option(text: "Yes, easily",          mode: .focus),
                Option(text: "Probably, with effort",mode: .recovery),
                Option(text: "Not really",           mode: .survival),
            ]
        ),
        Question(
            text: "What do you want from today?",
            options: [
                Option(text: "Make real progress",   mode: .focus),
                Option(text: "Get through it fine",  mode: .recovery),
                Option(text: "Just survive it",      mode: .survival),
            ]
        ),
    ]

    static func score(answers: [String]) -> MorningResult {
        var counts: [Mode: Int] = [.focus: 0, .recovery: 0, .survival: 0]
        for (i, answer) in answers.enumerated() {
            guard i < questions.count else { continue }
            if let option = questions[i].options.first(where: { $0.text == answer }) {
                counts[option.mode, default: 0] += 1
            }
        }
        let dominant = counts.max(by: { $0.value < $1.value })?.key ?? .recovery
        return result(for: dominant)
    }

    private static func result(for mode: Mode) -> MorningResult {
        switch mode {
        case .focus:
            return MorningResult(
                mode: .focus,
                modeLabel: "Focus Mode",
                suggestion: "Pick your one most important task and start it before opening any app.",
                warning: "Don't waste this window — avoid meetings or social media for the first hour."
            )
        case .recovery:
            return MorningResult(
                mode: .recovery,
                modeLabel: "Recovery Mode",
                suggestion: "Drink a full glass of water, then take 5 slow breaths before anything else.",
                warning: "Avoid heavy decisions before midday — your brain is still warming up."
            )
        case .survival:
            return MorningResult(
                mode: .survival,
                modeLabel: "Survival Mode",
                suggestion: "Lower the bar: identify just one small win you can get done today.",
                warning: "High stress risk — don't check news or social media until after lunch."
            )
        }
    }
}
