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
    static var questions: [Question] {
        questions(for: .current)
    }

    static func questions(for language: AppLanguage) -> [Question] {
        switch language {
        case .tr:
            return [
                Question(text: "Hâlâ yatakta mısın?",            options: ["Evet", "Hayır"]),
                Question(text: "Enerjin düşük mü?",              options: ["Evet", "Hayır"]),
                Question(text: "Kalkmak zor geliyor mu?",        options: ["Evet", "Hayır"]),
                Question(text: "Yavaş bir başlangıç ister misin?", options: ["Evet", "Hayır"]),
                Question(text: "Kısa bir reset'e hazır mısın?",  options: ["Evet", "Hayır"]),
            ]
        case .es:
            return [
                Question(text: "¿Sigues en la cama?",              options: ["Sí", "No"]),
                Question(text: "¿Poca energía?",                   options: ["Sí", "No"]),
                Question(text: "¿Levantarse se siente difícil?",   options: ["Sí", "No"]),
                Question(text: "¿Quieres un inicio lento?",        options: ["Sí", "No"]),
                Question(text: "¿Listo para un reset rápido?",     options: ["Sí", "No"]),
            ]
        case .en:
            return [
                Question(text: "Still in bed?",             options: ["Yes", "No"]),
                Question(text: "Low on energy?",            options: ["Yes", "No"]),
                Question(text: "Getting up feels hard?",    options: ["Yes", "No"]),
                Question(text: "Want a slow start?",        options: ["Yes", "No"]),
                Question(text: "Ready for a quick reset?",  options: ["Yes", "No"]),
            ]
        }
    }

    private static let variantPoolSize = 12

    static var variantIndex: Int {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return day % variantPoolSize
    }

    private static func positiveAnswer(for language: AppLanguage) -> String {
        switch language {
        case .tr: return "Hayır"
        case .es: return "No"
        case .en: return "No"
        }
    }

    private static func positiveQ5(for language: AppLanguage) -> String {
        switch language {
        case .tr: return "Evet"
        case .es: return "Sí"
        case .en: return "Yes"
        }
    }

    static func result(from answers: [String]) -> MorningResult {
        result(from: answers, language: .current)
    }

    static func result(from answers: [String], language: AppLanguage) -> MorningResult {
        var positive = 0
        for (i, answer) in answers.enumerated() {
            if i < 4,  answer == positiveAnswer(for: language) { positive += 1 }
            if i == 4, answer == positiveQ5(for: language)     { positive += 1 }
        }
        if positive >= 4 { return pushResult(for: language) }
        if positive >= 2 { return steadyResult(for: language) }
        return protectResult(for: language)
    }

    private static func protectResult(for language: AppLanguage) -> MorningResult {
        switch language {
        case .tr: return protectTR
        case .es: return protectES
        case .en: return protect
        }
    }

    private static func steadyResult(for language: AppLanguage) -> MorningResult {
        switch language {
        case .tr: return steadyTR
        case .es: return steadyES
        case .en: return steady
        }
    }

    private static func pushResult(for language: AppLanguage) -> MorningResult {
        switch language {
        case .tr: return pushTR
        case .es: return pushES
        case .en: return push
        }
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
                "Not a high-capacity morning. Keep demands low.",
                "Soft start. Treat the morning like glass.",
                "Low fuel. Move with care, not pressure.",
                "Quiet weather inside. Don't open the door too fast.",
                "Half-light morning. Don't force the room bright.",
                "The body is asking for patience. Listen once.",
                "A held breath kind of morning. Don't release it into noise.",
                "Reserved morning. Spend nothing you can save."
            ][i],
            startWith: [
                "feet on the floor, then water — nothing else yet",
                "up slowly, curtains open, water before anything",
                "bathroom, water, one easy thing — in that order",
                "stand up, drink water, then one task with a clear end point",
                "get up gently, water first, then your most predictable task",
                "sit on the edge of the bed, breathe twice, then water",
                "up, light a single lamp, drink water before reaching for the phone",
                "feet down, three slow breaths, water, one quiet task",
                "stand, open one window, water, then the easiest thing on your list",
                "up, splash your face with cool water, then drink a full glass",
                "sit upright, breathe slowly for ten counts, water, then move once",
                "feet on the floor, eyes on the room, water, nothing more"
            ][i],
            avoid: [
                "messages before you settle",
                "reactive planning",
                "news and feeds",
                "high-stakes decisions before you've settled",
                "decisions you can push to tomorrow",
                "anything that asks for an immediate answer",
                "comparing yourself to anyone, anywhere",
                "the urge to make this morning productive",
                "the inbox until you've eaten something",
                "anyone else's emergency before your first cup of water",
                "the spiral of fixing things that aren't broken yet",
                "promising more than you can carry today"
            ][i],
            win: [
                "a calm first hour",
                "no spiral, no crash",
                "clear enough to move, without draining yourself",
                "finishing the morning intact",
                "one task done without running yourself down",
                "ending the morning with something left in the tank",
                "no broken promises to yourself",
                "a soft landing instead of a hard start",
                "one quiet success before noon",
                "leaving the morning with your nervous system intact",
                "showing up for one small thing on time",
                "a morning you don't owe an apology for"
            ][i],
            music: [
                "slow, spacious, non-lyrical",
                "ambient, minimal, no beat pressure",
                "low tempo, sparse arrangement",
                "instrumental, nothing demanding",
                "quiet, unobtrusive, background",
                "soft piano, room-tone, room-warm",
                "stretched chords, weather-like",
                "neoclassical, paper-thin",
                "single instrument, single thought",
                "blurred edges, no rhythm",
                "field recording over a held note",
                "tape hiss and a slow chord"
            ][i],
            bonus: [
                "Today's line: protect the system before you push it.",
                "Morning signal: recovery day. move gently.",
                "Morning signal: low signal day. protect your pace.",
                "Today's line: a stable floor beats a shaky ceiling.",
                "Morning signal: low day. don't overextend.",
                "Today's line: small and finished beats large and abandoned.",
                "Morning signal: thin air. breathe before you act.",
                "Today's line: keep one promise to yourself, no more.",
                "Morning signal: hold the line, don't widen it.",
                "Today's line: rest is also direction.",
                "Morning signal: walk through, don't sprint through.",
                "Today's line: the day is long enough."
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
                "A clean start this morning. Use it.",
                "Average weather inside. Average weather is enough.",
                "Nothing in the way. Begin without negotiation.",
                "Quiet engine, full tank. Drive carefully.",
                "Even ground. Take one honest step.",
                "Calm baseline. Don't reach for stimulation.",
                "Workable morning. Don't dress it up.",
                "Still water. Move through, not against."
            ][i],
            startWith: [
                "up, water, then the task that gives the day shape",
                "get up now, water, then one deliberate action before input",
                "feet down, water, then your clearest priority",
                "stand up, water, then the task you've been postponing for no real reason",
                "up, water, then one concrete deliverable — not a planning session",
                "up, water, then twenty minutes on the thing that actually matters",
                "feet down, water, then the first real sentence of the day",
                "up, water, then one move that makes the next move easier",
                "stand, water, then start the work before you start the explanation",
                "feet on the floor, water, then begin with the part you understand",
                "up, water, then one paragraph, one rep, one call",
                "stand, water, then the smallest version of the right thing"
            ][i],
            avoid: [
                "random scrolling disguised as warming up",
                "noise before momentum",
                "fake productivity",
                "optimizing instead of executing",
                "over-preparing what you should just start",
                "rearranging your tools instead of using them",
                "the fifth tab you don't need open",
                "checking something that doesn't change your next step",
                "the comfort of organizing the day instead of beginning it",
                "the second cup of coffee before the first sentence",
                "explaining the work to yourself instead of doing it",
                "asking which task before answering with motion"
            ][i],
            win: [
                "one meaningful thing done cleanly",
                "clean movement from morning to noon",
                "clarity, rhythm, no unnecessary detours",
                "real progress on one item before the morning ends",
                "forward movement before the morning runs out",
                "shipping the small version instead of polishing the imagined one",
                "leaving the morning lighter than you found it",
                "one thing finished, then the next thing begun",
                "a morning that earns the afternoon",
                "no stalling, no apology, just one done thing",
                "evidence on the page, not in your head",
                "movement that compounds"
            ][i],
            music: [
                "focused, light, mid-tempo",
                "instrumental, consistent rhythm",
                "lo-fi, moderate pace, no spikes",
                "clean background, steady beat",
                "low distraction, balanced energy",
                "tokyo lo-fi, steady kick",
                "warm minimal house, nothing busy",
                "scandinavian downtempo, restrained",
                "japanese city pop morning side",
                "modern jazz, brushes only",
                "ambient techno at conversational volume",
                "post-rock, no climaxes"
            ][i],
            bonus: [
                "Today's line: rhythm beats intensity.",
                "Morning signal: no friction this morning. stay in motion.",
                "Morning signal: stable air. good day for clean execution.",
                "Today's line: use it. don't overthink it.",
                "Morning signal: clean baseline. good conditions to work.",
                "Today's line: motion is the answer to most morning questions.",
                "Morning signal: nothing dramatic, which is the gift.",
                "Today's line: trust the boring version of the plan.",
                "Morning signal: steady is a competitive advantage.",
                "Today's line: small consistent beats large occasional.",
                "Morning signal: quiet conditions for honest work.",
                "Today's line: keep the rhythm, change the pace later."
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
                "The morning is leaning toward output. Give it a direction.",
                "Tailwind morning. Aim before you accelerate.",
                "High signal. Don't spend it on small tasks.",
                "Open road. Pick the right exit early.",
                "Engine warm. Use it on the real climb.",
                "Bright window. Move while it's open.",
                "The morning is offering you a clean shot. Take it.",
                "Loaded morning. Spend it on the highest-leverage thing."
            ][i],
            startWith: [
                "up fast, water, then the hardest task — in that order",
                "out of bed, water, then real work before the feed opens",
                "stand up, water, then the task with the highest return",
                "up now, water, then something concrete before you open anything",
                "get up, water first, then the work that needs your full attention",
                "up, water, then the thing you'd be relieved to have done by noon",
                "feet down, water, then ninety minutes on the real climb",
                "stand, water, then the task you've been negotiating with",
                "up, water, then the move that raises the floor of the whole day",
                "out of bed, water, then start with the part that needs courage",
                "up, water, then ship the version that exists, not the one in your head",
                "stand, water, then commit before you check anything"
            ][i],
            avoid: [
                "admin before output",
                "checking everything before doing anything",
                "scattered effort",
                "warming up for too long before you commit",
                "low-value tasks that borrow time from the real work",
                "pretending preparation is the same as work",
                "the slack message that wants to redirect your morning",
                "burning the morning on shallow tabs",
                "any meeting that could be a sentence",
                "letting the inbox set your priorities",
                "reading about the work instead of doing it",
                "polishing the wrong thing"
            ][i],
            win: [
                "one strong block of real progress",
                "progress before noon",
                "turn energy into something concrete",
                "real output in the first two hours",
                "one substantial move on what actually matters",
                "ship it, even if it's ugly, even if it's small",
                "ninety minutes that change the shape of the day",
                "finish the part you've been avoiding",
                "leave the morning with proof of work, not proof of effort",
                "send the thing. close the loop. move on.",
                "one decision made, executed, and forgotten",
                "the version that exists is better than the version that doesn't"
            ][i],
            music: [
                "energizing, focused, low-chaos",
                "driving tempo, no lyrics",
                "high energy, structured rhythm",
                "fast-paced, clean arrangement",
                "momentum-building, no distraction",
                "deep house, propulsive but restrained",
                "techno at sunrise, no drops",
                "electronic post-rock, all forward",
                "krautrock motorik, hold the line",
                "uk garage at low volume",
                "minimal techno, single hypnotic loop",
                "afrobeat instrumental, full body"
            ][i],
            bonus: [
                "Today's line: high signal morning. don't spend it on small tasks.",
                "Today's line: the output window is open. go through it.",
                "Morning signal: forward motion is high. choose your target well.",
                "Today's line: don't ease into a morning like this.",
                "Morning signal: strong signal. set the target early.",
                "Today's line: a strong morning is a wasted one if it has no aim.",
                "Morning signal: leverage day. compound it.",
                "Today's line: be direct with this morning.",
                "Morning signal: green light. don't ask permission.",
                "Today's line: aim narrow, hit hard, move on.",
                "Morning signal: high tide. row.",
                "Today's line: the morning won't ask twice."
            ][i]
        )
    }
}
