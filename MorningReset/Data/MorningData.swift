import Foundation

struct Question {
    let text: String
    let options: [String]
}

struct MorningResult {
    let mode: String
    let meaning: String
    let startWith: String
    let avoid: String
    let win: String
    let music: String
    let bonus: String
}

enum MorningData {
    static let questions: [Question] = [
        Question(text: "Do you feel ready to move, not just think?",                options: ["Yes", "No"]),
        Question(text: "Does today feel manageable from where you are right now?",  options: ["Yes", "No"]),
        Question(text: "Can you give one important thing your full attention?",     options: ["Yes", "No"]),
        Question(text: "Would momentum help you more than rest today?",             options: ["Yes", "No"]),
        Question(text: "Do you want your morning to feel active rather than gentle?", options: ["Yes", "No"]),
    ]

    private static var variantIndex: Int {
        Calendar.current.component(.day, from: Date()) % 5
    }

    static func result(from answers: [String]) -> MorningResult {
        let yesCount = answers.filter { $0 == "Yes" }.count
        if yesCount >= 4 { return push }
        if yesCount >= 2 { return steady }
        return protect
    }

    private static var protect: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Protect",
            meaning: [
                "Starting low this morning. Adjust the day accordingly.",
                "Today starts sensitive. Keep it usable.",
                "Lean toward stability today. Intensity can wait.",
                "The signals this morning are mixed. Stabilize before you take on more.",
                "Not a high-capacity morning. Keep demands low."
            ][i],
            startWith: [
                "feet on the floor, then water — nothing else yet",
                "up slowly, curtains open, water before anything",
                "bathroom, water, one easy thing — in that order",
                "stand up, drink water, then one task with a clear end point",
                "get up gently, water first, then your most predictable task"
            ][i],
            avoid: [
                "messages before you settle",
                "reactive planning",
                "news and feeds",
                "high-stakes decisions before you've settled",
                "decisions you can push to tomorrow"
            ][i],
            win: [
                "a calm first hour",
                "no spiral, no crash",
                "clear enough to move, without draining yourself",
                "finishing the morning intact",
                "one task done without running yourself down"
            ][i],
            music: [
                "slow, spacious, non-lyrical",
                "ambient, minimal, no beat pressure",
                "low tempo, sparse arrangement",
                "instrumental, nothing demanding",
                "quiet, unobtrusive, background"
            ][i],
            bonus: [
                "Today's line: protect the system before you push it.",
                "Morning signal: recovery day. move gently.",
                "Morning signal: low signal day. protect your pace.",
                "Today's line: a stable floor beats a shaky ceiling.",
                "Morning signal: low day. don't overextend."
            ][i]
        )
    }

    private static var steady: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Steady",
            meaning: [
                "You're stable enough to move. Use the day properly.",
                "This morning is workable. Don't waste it.",
                "No major drag this morning. Use it cleanly.",
                "Neither high nor low. Work with what you have.",
                "A clean start this morning. Use it."
            ][i],
            startWith: [
                "up, water, then the task that gives the day shape",
                "get up now, water, then one deliberate action before input",
                "feet down, water, then your clearest priority",
                "stand up, water, then the task you've been postponing for no real reason",
                "up, water, then one concrete deliverable — not a planning session"
            ][i],
            avoid: [
                "random scrolling disguised as warming up",
                "noise before momentum",
                "fake productivity",
                "optimizing instead of executing",
                "over-preparing what you should just start"
            ][i],
            win: [
                "one meaningful thing done cleanly",
                "clean movement from morning to noon",
                "clarity, rhythm, no unnecessary detours",
                "real progress on one item before the morning ends",
                "forward movement before the morning runs out"
            ][i],
            music: [
                "focused, light, mid-tempo",
                "instrumental, consistent rhythm",
                "lo-fi, moderate pace, no spikes",
                "clean background, steady beat",
                "low distraction, balanced energy"
            ][i],
            bonus: [
                "Today's line: rhythm beats intensity.",
                "Morning signal: no friction this morning. stay in motion.",
                "Morning signal: stable air. good day for clean execution.",
                "Today's line: use it. don't overthink it.",
                "Morning signal: clean baseline. good conditions to work."
            ][i]
        )
    }

    private static var push: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Push",
            meaning: [
                "Strong signals this morning. Act on them early.",
                "This morning has leverage. Don't dilute it.",
                "There's usable momentum here. Direct it.",
                "Conditions are good. Don't let the morning drift.",
                "The morning is leaning toward output. Give it a direction."
            ][i],
            startWith: [
                "up fast, water, then the hardest task — in that order",
                "out of bed, water, then real work before the feed opens",
                "stand up, water, then the task with the highest return",
                "up now, water, then something concrete before you open anything",
                "get up, water first, then the work that needs your full attention"
            ][i],
            avoid: [
                "admin before output",
                "checking everything before doing anything",
                "scattered effort",
                "warming up for too long before you commit",
                "low-value tasks that borrow time from the real work"
            ][i],
            win: [
                "one strong block of real progress",
                "progress before noon",
                "turn energy into something concrete",
                "real output in the first two hours",
                "one substantial move on what actually matters"
            ][i],
            music: [
                "energizing, focused, low-chaos",
                "driving tempo, no lyrics",
                "high energy, structured rhythm",
                "fast-paced, clean arrangement",
                "momentum-building, no distraction"
            ][i],
            bonus: [
                "Today's line: high signal morning. don't spend it on small tasks.",
                "Today's line: the output window is open. go through it.",
                "Morning signal: forward motion is high. choose your target well.",
                "Today's line: don't ease into a morning like this.",
                "Morning signal: strong signal. set the target early."
            ][i]
        )
    }
}
