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
        // Check-in is optional now: startFlow goes straight to the practice (steady default).
        XCTAssertEqual(state.screen, .weeklyAffirmation)
        XCTAssertEqual(state.sessionMode, .steady)

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

    // MARK: - Today's practice pick

    @MainActor
    private func freshState() -> AppState {
        UserDefaults.standard.removeObject(forKey: UDKey.todaysRoutinePick)
        UserDefaults.standard.removeObject(forKey: UDKey.activeSchool)
        let state = AppState(skipEntitlementCheck: true)
        state.isPremium = true          // so no routine is filtered out by tier
        return state
    }

    @MainActor
    func testMakeTodaysRoutineChangesTodaysPractice() {
        let state = freshState()
        let before = state.todaysRoutine
        guard let qigong = SchoolContentStore.school("qigong"),
              let wanted = qigong.routines.first(where: { $0.id != before.id })
        else { return XCTFail("Expected a qigong routine distinct from the default") }

        state.makeTodaysRoutine(schoolID: "qigong", routineID: wanted.id)

        XCTAssertEqual(state.todaysRoutine.id, wanted.id,
                       "Accepting the suggestion must change today's practice")
        XCTAssertEqual(state.activeSchoolID, "qigong",
                       "The home screen pairs the school with the routine, so both must move")
        UserDefaults.standard.removeObject(forKey: UDKey.todaysRoutinePick)
    }

    @MainActor
    func testTodaysPickLapsesOnALaterDay() {
        let state = freshState()
        guard let qigong = SchoolContentStore.school("qigong"),
              let wanted = qigong.routines.first else { return XCTFail("No qigong content") }
        state.makeTodaysRoutine(schoolID: "qigong", routineID: wanted.id)

        // Re-stamp the stored pick as yesterday's.
        var stale = state.todaysPick
        XCTAssertNotNil(stale)
        stale?.day -= 1
        if let stale, let data = try? JSONEncoder().encode(stale) {
            UserDefaults.standard.set(data, forKey: UDKey.todaysRoutinePick)
        }

        XCTAssertNil(state.todaysPick, "Yesterday's pick should not survive into today")
        UserDefaults.standard.removeObject(forKey: UDKey.todaysRoutinePick)
    }

    @MainActor
    func testTodaysPickIgnoredWhenTheRoutineIsLocked() {
        let state = freshState()
        state.isPremium = false
        state.ownedTiers = []
        guard let qigong = SchoolContentStore.school("qigong"),
              let locked = qigong.routines.first(where: { !$0.free })
        else { return XCTFail("Expected a locked qigong routine") }

        state.makeTodaysRoutine(schoolID: "qigong", routineID: locked.id)

        XCTAssertNotEqual(state.todaysRoutine.id, locked.id,
                          "A locked routine must not become today's practice")
        XCTAssertTrue(state.todaysRoutine.free,
                      "The fallback must be something the user can actually play")
        UserDefaults.standard.removeObject(forKey: UDKey.todaysRoutinePick)
    }

    @MainActor
    func testSuggestedRoutineResolvesEveryEnergyPath() {
        let state = freshState()
        for path in EnergyPath.allCases {
            let suggestion = state.suggestedRoutine(for: path)
            XCTAssertNotNil(suggestion, "No school content for path \(path.rawValue)")
        }
        XCTAssertEqual(state.suggestedRoutine(for: .breathwork)?.school.id, "breathing")
        XCTAssertEqual(state.suggestedRoutine(for: .qigong)?.school.id, "qigong")
        XCTAssertEqual(state.suggestedRoutine(for: .reiki)?.school.id, "reiki")
    }

    // MARK: - Time of day

    func testTimeOfDayBoundaries() {
        let cal = Calendar.current
        func at(_ hour: Int) -> TimeOfDay {
            let date = cal.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
            return TimeOfDay.at(date, calendar: cal)
        }
        XCTAssertEqual(at(4),  .night)
        XCTAssertEqual(at(5),  .morning)
        XCTAssertEqual(at(11), .morning)
        XCTAssertEqual(at(12), .afternoon)
        XCTAssertEqual(at(16), .afternoon)
        XCTAssertEqual(at(17), .evening)
        XCTAssertEqual(at(21), .evening)
        XCTAssertEqual(at(22), .night)
    }

    func testOnlyTheMorningCaseSaysMorning() {
        // This is the regression the whole change exists to prevent: copy that
        // says "morning" while the user is opening the app in the afternoon.
        for slot in TimeOfDay.allCases {
            XCTAssertFalse(slot.phrase.isEmpty)
            XCTAssertFalse(slot.span.isEmpty)
            if slot != .morning {
                XCTAssertFalse(slot.phrase.lowercased().contains("morning"),
                               "\(slot.rawValue) should not mention the morning")
                XCTAssertFalse(slot.span.lowercased().contains("morning"),
                               "\(slot.rawValue) should not mention the morning")
            }
        }
    }

    // MARK: - Practice streak (forgiving)

    private func seedLog(_ daysAgo: [Int], outcome: PracticeOutcome = .done) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let sessions = daysAgo.compactMap { offset -> PracticeSession? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return PracticeSession(schoolID: "reiki", routineID: "reiki.r01",
                                   routineTitle: "First Gassho", date: day,
                                   minutes: 5, outcome: outcome)
        }
        PracticeLogStore.replaceAll(sessions)
    }

    func testPracticeStreakCountsConsecutiveDays() {
        seedLog([0, 1, 2, 3])
        XCTAssertEqual(PracticeLogStore.currentStreak(), 4)
        PracticeLogStore.replaceAll([])
    }

    func testPracticeStreakForgivesOneMissedDay() {
        // Practised today, skipped yesterday, practised the two days before.
        seedLog([0, 2, 3])
        XCTAssertEqual(PracticeLogStore.currentStreak(), 3,
                       "A single missed day should bridge, not reset")
        PracticeLogStore.replaceAll([])
    }

    func testPracticeStreakBreaksAfterTwoMissedDays() {
        seedLog([0, 3, 4])
        XCTAssertEqual(PracticeLogStore.currentStreak(), 1,
                       "Two blank days in a row should end the chain")
        PracticeLogStore.replaceAll([])
    }

    func testPracticeStreakSurvivesOneDayAway() {
        // Last practised yesterday: the chain is still live today.
        seedLog([1, 2])
        XCTAssertEqual(PracticeLogStore.currentStreak(), 2)
        PracticeLogStore.replaceAll([])
    }

    func testPracticeStreakEndsAfterThreeDaysAway() {
        seedLog([3, 4, 5])
        XCTAssertEqual(PracticeLogStore.currentStreak(), 0)
        PracticeLogStore.replaceAll([])
    }

    func testSkippedSessionsDoNotFeedTheStreak() {
        seedLog([0, 1], outcome: .skipped)
        XCTAssertEqual(PracticeLogStore.currentStreak(), 0)
        PracticeLogStore.replaceAll([])
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

        XCTAssertEqual(AppState.computeStreak(from: entries, now: referenceDate), 2)
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

    // MARK: - School content (Energy Reset 2.0)

    func testSchoolContentLoadsAndIsWellFormed() throws {
        let schools = SchoolContentStore.all
        XCTAssertFalse(schools.isEmpty, "No school content loaded from the bundle")

        for s in schools {
            XCTAssertEqual(s.routines.count, 25, "\(s.id): expected 25 routines")
            XCTAssertEqual(s.routines.filter(\.free).count, 1, "\(s.id): expected exactly 1 free routine")
            XCTAssertGreaterThanOrEqual(s.teachings.count, 4, "\(s.id): too few teachings")
            XCTAssertFalse(s.framingNote.isEmpty, "\(s.id): missing framing note")
            XCTAssertFalse(s.sources.isEmpty, "\(s.id): missing sources")
            for g in RoutineGroup.allCases {
                XCTAssertFalse(s.routines(in: g).isEmpty, "\(s.id): no routines in \(g.rawValue)")
            }
            for r in s.routines {
                XCTAssertFalse(r.steps.isEmpty, "\(r.id): no steps")
                XCTAssertGreaterThan(r.minutes, 0, "\(r.id): bad minutes")
            }
        }
    }
}

private let referenceDate = Date(timeIntervalSince1970: 1_776_211_200)
