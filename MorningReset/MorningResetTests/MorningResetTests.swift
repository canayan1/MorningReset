import XCTest
@testable import MorningReset

final class MorningResetTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetPersistentState()
    }

    override func tearDown() {
        resetPersistentState()
        super.tearDown()
    }

    func testEnglishAnswerMappingReturnsPush() {
        let answers = ["No", "No", "No", "No", "Yes"]
        XCTAssertEqual(MorningData.result(from: answers, language: .en).mode, "Push")
    }

    func testTurkishAnswerMappingReturnsProtect() {
        let answers = ["Evet", "Evet", "Evet", "Evet", "Hayır"]
        XCTAssertEqual(MorningData.result(from: answers, language: .tr).mode, "Protect")
    }

    func testSpanishMixedAnswersReturnSteady() {
        let answers = ["No", "Sí", "No", "Sí", "No"]
        XCTAssertEqual(MorningData.result(from: answers, language: .es).mode, "Steady")
    }

    func testLocalizedQuestionsUseExpectedAnswerOrder() {
        XCTAssertEqual(MorningData.questions(for: .en).first?.options, ["Yes", "No"])
        XCTAssertEqual(MorningData.questions(for: .tr).first?.options, ["Evet", "Hayır"])
        XCTAssertEqual(MorningData.questions(for: .es).first?.options, ["Sí", "No"])
    }

    func testNavigationPathReachesActionForFreeSteadyFlow() {
        let state = AppState(skipEntitlementCheck: true)
        let answers = steadyAnswers(for: .current)

        state.startFlow()
        XCTAssertEqual(state.screen, .quiz)

        answers.forEach(state.recordAnswer)
        state.showWeeklyAffirmation()
        XCTAssertEqual(state.screen, .weeklyAffirmation)
        XCTAssertEqual(state.sessionMode, .steady)
        XCTAssertEqual(state.currentFirstWin, .firstTask)

        state.showMorningSound()
        XCTAssertEqual(state.screen, .morningSound)

        state.showResults()
        XCTAssertEqual(state.screen, .results)

        state.advanceFromResults(history: [], intention: .focus)
        XCTAssertEqual(state.screen, .insightPreview)
        XCTAssertEqual(state.insightStrength, .none)

        state.paywallLastShownDate = referenceDate.timeIntervalSince1970
        state.advanceFromInsightPreview(now: referenceDate)
        XCTAssertEqual(state.screen, .action)
    }

    func testAdvanceFromResultsBuildsStrongPatternInsightFromHistory() {
        let state = configuredSteadyState()
        let history = repeatedHistory(mode: .steady, intention: .focus, count: 5)

        state.advanceFromResults(history: history, intention: .focus)

        XCTAssertEqual(state.screen, .insightPreview)
        XCTAssertEqual(state.insightStrength, .strong)
        XCTAssertFalse(state.insightText.isEmpty)
    }

    func testAdvanceFromInsightPreviewRoutesPremiumUserToGuidedPause() {
        let state = AppState(skipEntitlementCheck: true)
        state.isPremium = true
        state.insightStrength = .strong

        state.advanceFromInsightPreview(now: referenceDate)

        XCTAssertEqual(state.screen, .guidedPause)
    }

    func testAdvanceFromInsightPreviewRoutesStrongPatternToContextualPaywall() {
        let state = AppState(skipEntitlementCheck: true)
        state.isPremium = false
        state.insightStrength = .strong

        state.advanceFromInsightPreview(now: referenceDate)

        XCTAssertEqual(state.screen, .paywall)
        XCTAssertEqual(state.paywallContext, .contextual)
    }

    func testAdvanceFromInsightPreviewRoutesPeriodicPaywallAfterTwentyOneDays() {
        let state = AppState(skipEntitlementCheck: true)
        state.isPremium = false
        state.insightStrength = .weak
        state.paywallLastShownDate = referenceDate.addingTimeInterval(-22 * 86_400).timeIntervalSince1970

        state.advanceFromInsightPreview(now: referenceDate)

        XCTAssertEqual(state.screen, .paywall)
        XCTAssertEqual(state.paywallContext, .periodic)
    }

    func testAdvanceFromInsightPreviewSkipsPaywallAfterShowingItThisFlow() {
        let state = AppState(skipEntitlementCheck: true)
        state.isPremium = false
        state.insightStrength = .strong
        state.paywallShownThisFlow = true

        state.advanceFromInsightPreview(now: referenceDate)

        XCTAssertEqual(state.screen, .action)
    }

    func testStreakZeroOnEmptyHistory() {
        XCTAssertEqual(AppState.computeStreak(from: []), 0)
    }

    func testStreakCountsConsecutiveDaysUntilGap() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        let entries = [
            DailyEntry(date: today, mode: "steady", intention: "focus"),
            DailyEntry(date: calendar.date(byAdding: .day, value: -1, to: today)!, mode: "steady", intention: "focus"),
            DailyEntry(date: calendar.date(byAdding: .day, value: -3, to: today)!, mode: "steady", intention: "focus")
        ]

        XCTAssertEqual(AppState.computeStreak(from: entries), 2)
    }

    func testPatternStrengthStrongOnFiveOfSevenMatches() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        var entries = (0..<5).map {
            DailyEntry(date: calendar.date(byAdding: .day, value: -$0, to: today)!, mode: "push", intention: "focus")
        }
        entries.append(DailyEntry(date: calendar.date(byAdding: .day, value: -5, to: today)!, mode: "steady", intention: "calm"))
        entries.append(DailyEntry(date: calendar.date(byAdding: .day, value: -6, to: today)!, mode: "protect", intention: "energy"))

        XCTAssertEqual(PatternReader.strength(for: entries), .strong)
    }

    private func configuredSteadyState() -> AppState {
        let state = AppState(skipEntitlementCheck: true)
        steadyAnswers(for: .current).forEach(state.recordAnswer)
        state.showWeeklyAffirmation()
        state.showMorningSound()
        state.showResults()
        return state
    }

    private func steadyAnswers(for language: AppLanguage) -> [String] {
        let questions = MorningData.questions(for: language)
        return [
            questions[0].options[1],
            questions[1].options[1],
            questions[2].options[0],
            questions[3].options[0],
            questions[4].options[1]
        ]
    }

    private func repeatedHistory(mode: MorningMode, intention: IntentionType, count: Int) -> [DailyEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        return (0..<count).map { offset in
            DailyEntry(
                date: calendar.date(byAdding: .day, value: -offset, to: today)!,
                mode: mode.rawValue,
                intention: intention.rawValue
            )
        }
    }

    private func resetPersistentState() {
        let defaults = UserDefaults.standard
        [
            UDKey.premiumUnlocked,
            UDKey.onboardingComplete,
            UDKey.paywallLastShown,
            UDKey.selectedIntention,
            UDKey.dailyEntries,
            UDKey.insightDailyCache,
            UDKey.insightWeeklyCache,
            "wake_schedule_v1",
            "flow_checkouts",
            "mantra_start_date"
        ].forEach(defaults.removeObject(forKey:))
    }
}

private let referenceDate = Date(timeIntervalSince1970: 1_776_211_200)
