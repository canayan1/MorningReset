import Foundation

struct WeeklyMantra {
    let weekNumber: Int
    let text: String
}

enum MantraLibrary {

    static func mantra(for date: Date = Date()) -> WeeklyMantra {
        var week = Calendar.current.component(.weekOfYear, from: date)
        if week > 52 { week = 52 }
        let index = week - 1
        return all[index]
    }

    static let all: [WeeklyMantra] = [
        WeeklyMantra(weekNumber:  1, text: "I start with one honest, small action."),
        WeeklyMantra(weekNumber:  2, text: "I notice what matters before I react."),
        WeeklyMantra(weekNumber:  3, text: "I move slower than my urgency today."),
        WeeklyMantra(weekNumber:  4, text: "I choose clarity over extra input this morning."),
        WeeklyMantra(weekNumber:  5, text: "I can begin softly and still be steady."),
        WeeklyMantra(weekNumber:  6, text: "I return to one thing at a time."),
        WeeklyMantra(weekNumber:  7, text: "I don't need to win the morning."),
        WeeklyMantra(weekNumber:  8, text: "I make space before I make decisions."),
        WeeklyMantra(weekNumber:  9, text: "I begin where my feet already are."),
        WeeklyMantra(weekNumber: 10, text: "I protect my attention like something valuable."),
        WeeklyMantra(weekNumber: 11, text: "I let the day arrive in its own time."),
        WeeklyMantra(weekNumber: 12, text: "I'm allowed to start again, right now."),
        WeeklyMantra(weekNumber: 13, text: "I keep my morning simple on purpose."),
        WeeklyMantra(weekNumber: 14, text: "I listen to my body's first signals."),
        WeeklyMantra(weekNumber: 15, text: "I choose one priority, not ten intentions."),
        WeeklyMantra(weekNumber: 16, text: "I can be calm and still be serious."),
        WeeklyMantra(weekNumber: 17, text: "I meet today with steadiness, not speed."),
        WeeklyMantra(weekNumber: 18, text: "I give myself a clean first minute."),
        WeeklyMantra(weekNumber: 19, text: "I release what I can't set today."),
        WeeklyMantra(weekNumber: 20, text: "I begin with care, not commentary."),
        WeeklyMantra(weekNumber: 21, text: "I breathe once before I reach for more."),
        WeeklyMantra(weekNumber: 22, text: "I choose fewer inputs to feel more clear."),
        WeeklyMantra(weekNumber: 23, text: "I can take my time and still move."),
        WeeklyMantra(weekNumber: 24, text: "I start with water, breath, or movement."),
        WeeklyMantra(weekNumber: 25, text: "I let my attention settle, then decide."),
        WeeklyMantra(weekNumber: 26, text: "I don't owe the world my first energy."),
        WeeklyMantra(weekNumber: 27, text: "I give my mind one quiet sentence."),
        WeeklyMantra(weekNumber: 28, text: "I choose a steady start over a fast one."),
        WeeklyMantra(weekNumber: 29, text: "I can hold less, and feel more present."),
        WeeklyMantra(weekNumber: 30, text: "I notice my state without making it a story."),
        WeeklyMantra(weekNumber: 31, text: "I begin with what's real, not ideal."),
        WeeklyMantra(weekNumber: 32, text: "I do one thing that helps future me."),
        WeeklyMantra(weekNumber: 33, text: "I keep my edges soft, my focus clear."),
        WeeklyMantra(weekNumber: 34, text: "I start the day from the inside out."),
        WeeklyMantra(weekNumber: 35, text: "I make room for a better next step."),
        WeeklyMantra(weekNumber: 36, text: "I choose calm direction over loud momentum."),
        WeeklyMantra(weekNumber: 37, text: "I let my brain warm up gently."),
        WeeklyMantra(weekNumber: 38, text: "I can be focused without being harsh."),
        WeeklyMantra(weekNumber: 39, text: "I don't need answers before I begin."),
        WeeklyMantra(weekNumber: 40, text: "I begin with a pause I can feel."),
        WeeklyMantra(weekNumber: 41, text: "I choose one small boundary for my morning."),
        WeeklyMantra(weekNumber: 42, text: "I let the first minutes be unrushed."),
        WeeklyMantra(weekNumber: 43, text: "I keep my morning steady, even if brief."),
        WeeklyMantra(weekNumber: 44, text: "I return to breath when I scatter."),
        WeeklyMantra(weekNumber: 45, text: "I can start with less input and more presence."),
        WeeklyMantra(weekNumber: 46, text: "I choose what supports me, then I go."),
        WeeklyMantra(weekNumber: 47, text: "I keep the day's first story simple."),
        WeeklyMantra(weekNumber: 48, text: "I offer myself a calm start, not perfection."),
        WeeklyMantra(weekNumber: 49, text: "I begin with steady movement, not thinking."),
        WeeklyMantra(weekNumber: 50, text: "I protect my first attention like a ritual."),
        WeeklyMantra(weekNumber: 51, text: "I start the day with one clear choice."),
        WeeklyMantra(weekNumber: 52, text: "I close the week by beginning again, gently."),
    ]
}
