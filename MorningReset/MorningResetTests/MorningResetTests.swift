//
//  MorningResetTests.swift
//  MorningResetTests
//
//  Created by Begum Yoldas on 29/03/2026.
//

import Testing
import Foundation
@testable import MorningReset

struct MorningResetTests {

    // MARK: - MorningData.result

    @Test func resultPushOnAllPositive() {
        let answers = ["No", "No", "No", "No", "Yes"]
        let r = MorningData.result(from: answers)
        #expect(r.mode == "Push")
    }

    @Test func resultProtectOnAllNegative() {
        let answers = ["Yes", "Yes", "Yes", "Yes", "No"]
        let r = MorningData.result(from: answers)
        #expect(r.mode == "Protect")
    }

    @Test func resultSteadyOnMixed() {
        let answers = ["No", "No", "Yes", "Yes", "No"]
        let r = MorningData.result(from: answers)
        #expect(r.mode == "Steady")
    }

    // MARK: - Streak computation

    @Test func streakZeroOnEmpty() {
        #expect(AppState.computeStreak(from: []) == 0)
    }

    @Test func streakOneForTodayOnly() {
        let entries = [DailyEntry(date: Date(), mode: "steady", intention: "focus")]
        #expect(AppState.computeStreak(from: entries) == 1)
    }

    @Test func streakBreaksOnGap() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let entries: [DailyEntry] = [
            DailyEntry(date: today, mode: "steady", intention: "focus"),
            DailyEntry(date: cal.date(byAdding: .day, value: -1, to: today)!, mode: "steady", intention: "focus"),
            DailyEntry(date: cal.date(byAdding: .day, value: -3, to: today)!, mode: "steady", intention: "focus"),
        ]
        #expect(AppState.computeStreak(from: entries) == 2)
    }

    @Test func streakZeroIfLatestOlderThanYesterday() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let entries: [DailyEntry] = [
            DailyEntry(date: cal.date(byAdding: .day, value: -2, to: today)!, mode: "steady", intention: "focus"),
            DailyEntry(date: cal.date(byAdding: .day, value: -3, to: today)!, mode: "steady", intention: "focus"),
        ]
        #expect(AppState.computeStreak(from: entries) == 0)
    }

    // MARK: - PatternReader.strength

    @Test func patternStrengthNoneIfFewEntries() {
        let entries = [DailyEntry(date: Date(), mode: "steady", intention: "focus")]
        #expect(PatternReader.strength(for: entries) == .none)
    }

    @Test func patternStrengthWeakOnThreeSameModes() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let entries: [DailyEntry] = (0..<3).map {
            DailyEntry(date: cal.date(byAdding: .day, value: -$0, to: today)!, mode: "steady", intention: "focus")
        }
        #expect(PatternReader.strength(for: entries) == .weak)
    }

    @Test func patternStrengthStrongOnFiveOfSeven() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var entries: [DailyEntry] = (0..<5).map {
            DailyEntry(date: cal.date(byAdding: .day, value: -$0, to: today)!, mode: "push", intention: "focus")
        }
        entries.append(DailyEntry(date: cal.date(byAdding: .day, value: -5, to: today)!, mode: "steady", intention: "calm"))
        entries.append(DailyEntry(date: cal.date(byAdding: .day, value: -6, to: today)!, mode: "protect", intention: "energy"))
        #expect(PatternReader.strength(for: entries) == .strong)
    }
}
