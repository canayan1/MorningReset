import XCTest
import SwiftUI
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

    // MARK: - The alarm chain

    /// The follow-ups sit three minutes apart behind the first alarm.
    func testAlarmChainStepsEveryThreeMinutes() {
        let times = MorningAlarmChain.times(hour: 7, minute: 0)
        XCTAssertEqual(times.count, 4)
        XCTAssertEqual(times.map(\.hour), [7, 7, 7, 7])
        XCTAssertEqual(times.map(\.minute), [3, 6, 9, 12])
    }

    /// A chain set late at night runs past midnight. An hour of 24 is not a
    /// time, and an alarm scheduled at one would simply never ring.
    func testAlarmChainWrapsPastMidnight() {
        let times = MorningAlarmChain.times(hour: 23, minute: 55)
        XCTAssertEqual(times.map { "\($0.hour):\($0.minute)" },
                       ["23:58", "0:1", "0:4", "0:7"])
        for t in times {
            XCTAssertTrue((0..<24).contains(t.hour), "hour \(t.hour) is not a time of day")
            XCTAssertTrue((0..<60).contains(t.minute), "minute \(t.minute) is not a minute")
        }
    }

    // MARK: - The signature session

    /// The shape of the practice is the spec: five rounds of three a side, then
    /// ten of four. Getting this wrong is silent — it would simply be a
    /// different practice — so it is pinned here.
    func testSignatureSessionIsFiveThreesThenTenFours() {
        XCTAssertEqual(SignatureMeditationView.exhaleCount, 15, "five rounds then ten, one out-breath each")
        XCTAssertEqual(SignatureMeditationView.totalSeconds, 5 * 4 * 3 + 10 * 4 * 4, accuracy: 0.001)
        XCTAssertEqual(SignatureMeditationView.totalSeconds, 220, accuracy: 0.001, "three minutes and forty seconds")
    }

    // MARK: - The tree you breathe

    /// The character runs from a quick breath to a long one, and saturates
    /// rather than running away at either end.
    func testTreeCharacterMapsTheBreath() {
        XCTAssertEqual(treeCharacter(averageExhale: 1.5), 0.0, accuracy: 0.01, "a short breath sits at the quick end")
        XCTAssertEqual(treeCharacter(averageExhale: 4.0), 0.5, accuracy: 0.01, "a middling breath sits in the middle")
        XCTAssertEqual(treeCharacter(averageExhale: 6.5), 1.0, accuracy: 0.01, "a long breath reaches the slow end")
        XCTAssertEqual(treeCharacter(averageExhale: 20), 1.0, "and stays there")
        XCTAssertEqual(treeCharacter(averageExhale: 0.2), 0.0, "and at the other end too")
        XCTAssertEqual(treeCharacter(averageExhale: 0), 0.5, "no breath yet is the middle, not an extreme")
    }

    /// The whole promise of growing a tree from breath rather than a clock is
    /// that two people do not get the same tree. That has to be true of the
    /// drawing, not just of the copy.
    func testTwoBreathsGrowDifferentTrees() {
        let box = CGRect(x: 0, y: 0, width: 200, height: 200)
        let quick = EnergyTree(progress: 1, character: 0).path(in: box).boundingRect
        let slow  = EnergyTree(progress: 1, character: 1).path(in: box).boundingRect
        XCTAssertGreaterThan(slow.width, quick.width + 8, "a slow breath must open a visibly wider tree")

        // And the same breath twice must give the same tree — the shape is the
        // person's, not a random number.
        let again = EnergyTree(progress: 1, character: 1).path(in: box).boundingRect
        XCTAssertEqual(slow, again, "the same breath must grow the same tree")
    }

    /// Growth comes from breaths counted, so no breathing means no tree.
    func testTreeGrowthStaysPutWithoutBreath() {
        XCTAssertEqual(treeGrowth(0), 0.30, accuracy: 0.001, "a seedling, not nothing")
        XCTAssertEqual(treeGrowth(1), 1.0, accuracy: 0.001)
        XCTAssertGreaterThan(treeGrowth(0.25), treeGrowth(0.1), "and it only ever goes up")
    }

    // MARK: - Pulse

    /// The band has to be flat where hearts actually beat. The filter this
    /// replaced subtracted a 0.75s moving average, which is a comb: it passed
    /// 80 and 160 bpm at full strength while taking a third out of 60 and two
    /// thirds out of 40 — suppressing exactly the resting rates it existed for.
    func testPulseBandIsFlatWhereHeartsBeat() {
        func gain(_ bpm: Double) -> Double {
            let fs = 30.0
            let x = (0..<900).map { sin(2 * .pi * bpm / 60 * Double($0) / fs) }
            let y = PulseSignal.bandpass(x, sampleRate: fs)
            func amp(_ a: [Double]) -> Double {
                let mid = Array(a[(a.count / 4)..<(3 * a.count / 4)])   // skip edge transients
                return ((mid.max() ?? 0) - (mid.min() ?? 0)) / 2
            }
            return amp(y) / amp(x)
        }
        for bpm in [60.0, 75, 100, 140] {
            XCTAssertGreaterThan(gain(bpm), 0.85, "\(bpm) bpm is inside the band and must pass")
        }
        XCTAssertGreaterThan(gain(45), 0.65, "a slow resting heart must survive")
        XCTAssertLessThan(gain(12), 0.15, "breathing drift must not")
    }

    /// The real thing: a hue trace with a slow baseline drift, uneven frame
    /// times, and a pulse under two percent of the signal.
    func testPulseSurvivesARealisticTrace() {
        var seed: UInt64 = 11
        func random() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 40) / Double(1 << 24) - 0.5
        }
        for bpm in [48.0, 58, 72, 96, 124] {
            var times: [Double] = [], values: [Double] = [], clock = 0.0
            for _ in 0..<240 {
                clock += 1.0 / 30 + random() * 0.012          // frames do not arrive evenly
                values.append(0.020                            // a red frame's hue
                              + 0.0015 * sin(2 * .pi * 0.07 * clock)   // the finger settling
                              + 0.00035 * sin(2 * .pi * bpm / 60 * clock)
                              + 0.00012 * sin(4 * .pi * bpm / 60 * clock)
                              + random() * 0.0008)
                times.append(clock)
            }
            let grid = PulseSignal.resample(times: times, values: values, to: 30)
            guard let r = PulseSignal.estimate(PulseSignal.bandpass(grid, sampleRate: 30), sampleRate: 30) else {
                return XCTFail("lost the beat at \(bpm) bpm")
            }
            XCTAssertEqual(r.bpm, bpm, accuracy: 2.5, "off at \(bpm) bpm")
            XCTAssertGreaterThan(r.confidence, PulseReader.minimumConfidence)
        }
    }

    /// Presence is a ratio, not a brightness. The version this replaced asked
    /// for red above 0.22 — about a quarter of what a torch-lit fingertip
    /// actually reads — so it said yes while auto-exposure was still ramping,
    /// which is the moment the old code chose to lock exposure.
    func testFingerPresenceRejectsTheExposureRamp() {
        func sample(r: Double, g: Double, b: Double) -> PulseSignal.Sample {
            PulseSignal.Sample(hue: PulseSignal.hue(r: r, g: g, b: b),
                               redShare: r / (r + g + b), red: r, clipped: 0)
        }
        XCTAssertTrue(PulseSignal.fingerPresent(sample(r: 0.745, g: 0.04, b: 0.04)),
                      "a torch-lit fingertip reads about 190/255 red")
        XCTAssertFalse(PulseSignal.fingerPresent(sample(r: 0.22, g: 0.01, b: 0.01)),
                       "mid-ramp is not a finger, however red it already looks")
        XCTAssertFalse(PulseSignal.fingerPresent(sample(r: 0.42, g: 0.38, b: 0.36)),
                       "a room is not a finger")
        XCTAssertTrue(PulseSignal.fingerPresent(sample(r: 0.50, g: 0.05, b: 0.04)),
                      "a darker fingertip, or a torch the phone has dimmed, is still a finger")
    }

    /// Noise must be reported as nothing, never as a number.
    func testPulseEstimatorRefusesNoise() {
        var seed: UInt64 = 42
        let noise = (0..<600).map { _ -> Double in
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 40) / Double(1 << 24) * 0.006 - 0.003
        }
        XCTAssertNil(PulseSignal.estimate(PulseSignal.bandpass(noise, sampleRate: 30), sampleRate: 30),
                     "noise must not produce a reading")
        let flat = Array(repeating: 0.5, count: 600)
        XCTAssertNil(PulseSignal.estimate(PulseSignal.bandpass(flat, sampleRate: 30), sampleRate: 30),
                     "a flat trace means no finger, not a pulse")
    }

    /// A number is shown when consecutive windows agree, not when one window
    /// clears a threshold — band-limited noise clears one often enough.
    func testReadingNeedsConsecutiveWindowsToAgree() {
        XCTAssertEqual(PulseSignal.agreed([71, 72, 73]) ?? 0, 72, accuracy: 1)
        XCTAssertNil(PulseSignal.agreed([72, 95, 60]), "windows that disagree are not a reading")
        XCTAssertNil(PulseSignal.agreed([72, 72]), "two is not enough")
        XCTAssertNotNil(PulseSignal.agreed([120, 71, 72, 73]), "an early stray does not spoil a settled run")
    }

    func testHueIsAChannelRatio() {
        XCTAssertEqual(PulseSignal.hue(r: 1, g: 0, b: 0), 0, accuracy: 0.001, "pure red sits at zero")
        // Doubling the light must not move the hue — the whole reason it is the
        // analysed series rather than brightness.
        XCTAssertEqual(PulseSignal.hue(r: 0.40, g: 0.02, b: 0.02),
                       PulseSignal.hue(r: 0.80, g: 0.04, b: 0.04), accuracy: 0.001)
        XCTAssertEqual(PulseSignal.hue(r: 0.5, g: 0.5, b: 0.5), 0, accuracy: 0.001, "grey has no hue")
    }

    /// The pair is the point: the drop is what the app shows.
    func testPulseDropIsOnlyThereWhenBothReadingsAre() {
        var s = PracticeSession(schoolID: "breathing", routineID: "breathing.r01",
                                routineTitle: "Three Physiological Sighs",
                                date: referenceDate, minutes: 1, outcome: .done)
        XCTAssertNil(s.pulseDrop)
        s.pulseBefore = 78
        XCTAssertNil(s.pulseDrop, "one number is not a pair")
        s.pulseAfter = 64
        XCTAssertEqual(s.pulseDrop, 14)
        s.pulseAfter = 82
        XCTAssertEqual(s.pulseDrop, -4, "a rise is a real answer too")
    }


    func testSchoolContentLoadsAndIsWellFormed() throws {
        let schools = SchoolContentStore.all
        XCTAssertFalse(schools.isEmpty, "No school content loaded from the bundle")

        for s in schools {
            XCTAssertEqual(s.routines.count, 25, "\(s.id): expected 25 routines")
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

        // One practice is free for everyone, and it is the one the alarm wakes
        // you into — so its identity is part of the contract, not just its count.
        let free = schools.flatMap(\.routines).filter(\.free)
        XCTAssertEqual(free.count, 1, "expected exactly one free routine app-wide, got \(free.map(\.id))")
        XCTAssertEqual(SchoolContentStore.freePractice?.routine.id, "breathing.r01")
        XCTAssertEqual(SchoolContentStore.freePractice?.school.id, "breathing")
    }
}

private let referenceDate = Date(timeIntervalSince1970: 1_776_211_200)
