import Foundation

struct Question {
    let text: String
    let options: [String]
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
}
