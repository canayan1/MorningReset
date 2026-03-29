import Foundation

struct Question {
    let text: String
    let options: [String]
}

struct MorningResult {
    let mode: String
    let suggestion: String
    let warning: String
}

enum MorningData {
    static let questions: [Question] = [
        Question(
            text: "How did you sleep?",
            options: ["Deeply — felt rested", "Light but okay", "Poorly — still tired"]
        ),
        Question(
            text: "What's your energy level right now?",
            options: ["High — ready to go", "Medium — warming up", "Low — barely awake"]
        ),
        Question(
            text: "How's your mood?",
            options: ["Positive and calm", "Neutral", "Anxious or stressed"]
        ),
        Question(
            text: "Can you focus on a single task right now?",
            options: ["Yes, easily", "Probably, with effort", "Not really"]
        ),
        Question(
            text: "What do you want from today?",
            options: ["Make real progress", "Get through it fine", "Just survive it"]
        ),
    ]

    // MARK: - Scoring
    //
    // Each question's options are ordered: [focus, recovery, survival]
    // Tally by option index. Tiebreak: higher-stress mode wins (survival > recovery > focus).

    static func result(from answers: [String]) -> MorningResult {
        var tally = [0, 0, 0]
        for (i, answer) in answers.enumerated() {
            guard i < questions.count else { continue }
            if let idx = questions[i].options.firstIndex(of: answer) {
                tally[min(idx, 2)] += 1
            }
        }
        if tally[2] >= tally[1] && tally[2] >= tally[0] { return survival }
        if tally[1] >= tally[0]                          { return recovery }
        return focus
    }

    // MARK: - Results

    private static let focus = MorningResult(
        mode: "Focus Mode",
        suggestion: "Start with your hardest task before opening any app.",
        warning: "This window closes fast. Protect the first hour."
    )

    private static let recovery = MorningResult(
        mode: "Recovery Mode",
        suggestion: "Drink water. Pick one task. Skip the news.",
        warning: "Don't schedule anything demanding before midday."
    )

    private static let survival = MorningResult(
        mode: "Survival Mode",
        suggestion: "Pick one small thing you can finish today. Just one.",
        warning: "Keep the load light. No big decisions today."
    )
}
