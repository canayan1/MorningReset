import Foundation
import Observation
import StoreKit
import WidgetKit

enum Screen: Equatable {
    case alarm
    case scheduleSetup
    case quiz
    case weeklyAffirmation
    case morningSound
    case results
    case move
    case win
    case cycleComplete
    case action
    case insightPreview
    case paywall
    case guidedPause
    case mobilityFlow
    case feedback
    case flowCheckout
    case premiumHub
    case breathReset
    case morningPages
    case monthlyStory
    case firstWinPick
    case myWins
    case pathLearn
}

@Observable
final class AppState {
    var screen: Screen = .alarm
    var answers: [String] = []

    // Premium state (persisted via UserDefaults)
    var isPremium: Bool
    var onboardingSeen: Bool
    var paywallLastShownDate: Double

    // Session-scoped (reset each flow)
    var paywallShownThisFlow: Bool = false
    var paywallContext: PaywallContext = .contextual
    var insightStrength: InsightStrength = .none
    var insightText: String = ""
    var sessionMode: MorningMode = .steady
    var selectedSoundDirection: SoundDirection = .focus
    var selectedFirstWin: FirstWinAction? = nil
    var didCompleteFirstWin: Bool = false

    // First Win habit (persisted)
    var activeFirstWin: ActiveFirstWin?
    var completedFirstWins: [CompletedFirstWin] = []
    var firstWinJustGraduated: CompletedFirstWin? = nil
    var morningGoal: MorningGoal? = nil
    var activePath: EnergyPath? = nil

    private var inactivityTimer: Timer?

    // MARK: - Mobility state
    var currentMobilityFlow: MobilityFlow? = nil
    var currentMobilityMoveIndex: Int = 0
    var mobilitySecondsRemaining: Int = 0
    var isMobilityRunning: Bool = false
    var mobilityTimer: Timer?

    // MARK: - Streak cache
    private var _cachedStreak: Int? = nil

    private let skipEntitlementCheck: Bool

    init(skipEntitlementCheck: Bool = false) {
        self.skipEntitlementCheck = skipEntitlementCheck
        isPremium            = UserDefaults.standard.bool(forKey: UDKey.premiumUnlocked)
        onboardingSeen       = UserDefaults.standard.bool(forKey: UDKey.onboardingComplete)
        paywallLastShownDate = UserDefaults.standard.double(forKey: UDKey.paywallLastShown)
        activeFirstWin       = FirstWinStore.loadActive()
        completedFirstWins   = FirstWinStore.loadCompleted()
        morningGoal          = UserDefaults.standard.string(forKey: UDKey.morningGoal).flatMap(MorningGoal.init(rawValue:))
        activePath           = UserDefaults.standard.string(forKey: UDKey.energyPath).flatMap(EnergyPath.init(rawValue:))
        if !skipEntitlementCheck {
            Task { await self.checkEntitlement() }
        }
    }

    // MARK: - First Win habit

    var ritualPresentation: FirstWinPresentation {
        if let kind = activeFirstWin?.kind { return kind.presentation }
        let fw = currentFirstWin
        return FirstWinPresentation(
            symbol: fw.symbol,
            title: fw.title,
            how: fw.actionBody,
            checkPrompt: fw.checkoutTitle,
            winTitle: fw.winTitle,
            winBody: fw.winBody
        )
    }

    func selectMorningGoal(_ goal: MorningGoal) {
        morningGoal = goal
        UserDefaults.standard.set(goal.rawValue, forKey: UDKey.morningGoal)
    }

    func selectMorningPath(_ path: EnergyPath) {
        activePath = path
        UserDefaults.standard.set(path.rawValue, forKey: UDKey.energyPath)
    }

    var pathPractices: [PathPractice] {
        activePath?.practices ?? []
    }

    var recommendedNextPractice: PathPractice? {
        guard let path = activePath else { return nil }
        let done = Set(completedFirstWins.map { $0.title })
        return path.practices.first { !done.contains($0.title) } ?? path.practices.first
    }

    func showPathLearn() {
        stopInactivityTimer()
        screen = .pathLearn
    }

    var recommendedNextFirstWin: FirstWinPreset {
        let titles = Set(completedFirstWins.map { $0.title })
        return FirstWinRecommender.nextRecommended(goal: morningGoal, completedTitles: titles, excluding: activeFirstWin?.kind.title)
    }

    func selectActiveFirstWin(_ kind: FirstWinKind) {
        let win = ActiveFirstWin(kind: kind, streak: 0, lastCheckDay: nil, startedAt: Date())
        activeFirstWin = win
        firstWinJustGraduated = nil
        FirstWinStore.saveActive(win)
    }

    @discardableResult
    func registerFirstWinCheck(now: Date = Date()) -> Bool {
        guard var win = activeFirstWin else { return false }
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        if let last = win.lastCheckDay, cal.isDate(last, inSameDayAs: now) { return false }
        if let last = win.lastCheckDay,
           let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.startOfDay(for: last) == yesterday {
            win.streak += 1
        } else {
            win.streak = 1
        }
        win.lastCheckDay = today
        if win.streak >= FirstWinStore.target {
            let completed = CompletedFirstWin(symbol: win.kind.symbol, title: win.kind.title, completedAt: now)
            completedFirstWins.insert(completed, at: 0)
            FirstWinStore.saveCompleted(completedFirstWins)
            activeFirstWin = nil
            FirstWinStore.saveActive(nil)
            firstWinJustGraduated = completed
            return true
        }
        activeFirstWin = win
        FirstWinStore.saveActive(win)
        return false
    }

    func showFirstWinPick() {
        stopInactivityTimer()
        firstWinJustGraduated = nil
        screen = .firstWinPick
    }

    func showMyWins() {
        stopInactivityTimer()
        screen = .myWins
    }

    // MARK: - Streak

    var streakCount: Int {
        if let cached = _cachedStreak { return cached }
        let value = Self.computeStreak(from: DailyEntryStore.load())
        _cachedStreak = value
        return value
    }

    func invalidateStreakCache() {
        _cachedStreak = nil
    }

    static func computeStreak(from entries: [DailyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let days = Array(Set(entries.map { cal.startOfDay(for: $0.date) })).sorted(by: >)
        guard let first = days.first, first == today || first == yesterday else { return 0 }
        var streak = 0
        var expected = first
        for day in days {
            if day == expected {
                streak += 1
                expected = cal.date(byAdding: .day, value: -1, to: expected)!
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Navigation

    func showScheduleSetup() {
        stopInactivityTimer()
        screen = .scheduleSetup
    }

    func showWakeHome() {
        stopInactivityTimer()
        resetFlowSession()
        screen = .alarm
        WakeAudioPlayer.shared.stop()
    }

    func completeOnboardingAndShowScheduleSetup() {
        dismissOnboarding()
        showScheduleSetup()
    }

    func finishScheduleSetup() {
        showWakeHome()
    }

    func startFlow() {
        resetFlowSession()
        screen = .quiz
        resetInactivityTimer()
        WakeActivityController.markCompleted(tagline: L10n.text(
            en: "You showed up.",
            tr: "Devam ettin.",
            es: "Apareciste."
        ))
        WakeAudioPlayer.shared.startRitual()
    }

    func recordAnswer(_ answer: String) {
        guard answers.count < MorningData.questions.count else { return }
        answers.append(answer)
        resetInactivityTimer()
        WakeAudioPlayer.shared.playChime()
    }

    func showWeeklyAffirmation() {
        stopInactivityTimer()
        let result = MorningData.result(from: answers)
        let mode = MorningMode(from: result.mode) ?? .steady
        sessionMode = mode
        selectedSoundDirection = SoundDirection.recommended(for: mode)
        selectedFirstWin = ActionContent.recommendedFirstWin(for: mode)
        didCompleteFirstWin = false
        screen = .weeklyAffirmation
    }

    func showMorningSound() {
        stopInactivityTimer()
        screen = .morningSound
    }

    func setSoundDirection(_ direction: SoundDirection) {
        selectedSoundDirection = direction
    }

    func showResults() {
        stopInactivityTimer()
        screen = .results
    }

    func showMove() {
        screen = .move
    }

    func showWin() {
        screen = .win
        WakeAudioPlayer.shared.playWinCrescendoThenStop()
    }

    func showCycleComplete() {
        screen = .cycleComplete
    }

    func showAction() {
        screen = .action
    }

    var currentFirstWin: FirstWinAction {
        selectedFirstWin ?? ActionContent.recommendedFirstWin(for: sessionMode)
    }

    func selectFirstWin(_ firstWin: FirstWinAction) {
        selectedFirstWin = firstWin
        didCompleteFirstWin = false
    }

    func completeFirstWin() {
        didCompleteFirstWin = true
        showWin()
    }

    func endFlow() {
        stopInactivityTimer()
        if answers.count == MorningData.questions.count {
            let result = MorningData.result(from: answers)
            let mode = MorningMode(from: result.mode) ?? .steady
            let intentionStr = UserDefaults.standard.string(forKey: UDKey.selectedIntention) ?? IntentionType.focus.rawValue
            DailyEntryStore.append(mode: mode.rawValue, intention: intentionStr)
            invalidateStreakCache()
            WidgetCenter.shared.reloadAllTimelines()
        }
        let s = streakCount
        if s == 3 || s == 7 || s == 14 || s == 30 {
            screen = .feedback
        } else {
            screen = .premiumHub
        }
    }

    func dismissFeedback() {
        screen = .premiumHub
    }

    func showPremiumHub() {
        screen = .premiumHub
    }

    func showMonthlyStory() {
        screen = .monthlyStory
    }

    func openBreathReset() {
        guard isPremium else {
            paywallContext = .riseAndFlow
            screen = .paywall
            return
        }
        screen = .breathReset
    }

    func openMorningPages() {
        guard isPremium else {
            paywallContext = .riseAndFlow
            screen = .paywall
            return
        }
        screen = .morningPages
    }

    func showFlowCheckout() {
        screen = .flowCheckout
    }

    // MARK: - Premium flow navigation

    func advanceFromResults() {
        let history = DailyEntryStore.load()
        let intentionStr = UserDefaults.standard.string(forKey: UDKey.selectedIntention) ?? IntentionType.focus.rawValue
        let intention = IntentionType(rawValue: intentionStr) ?? .focus
        advanceFromResults(history: history, intention: intention)
    }

    func advanceFromResults(history: [DailyEntry], intention: IntentionType) {
        if selectedFirstWin == nil {
            selectedFirstWin = ActionContent.recommendedFirstWin(for: sessionMode)
        }
        let strength = PatternReader.strength(for: history)
        insightStrength = strength
        let result = MorningData.result(from: answers)
        let mode = MorningMode(from: result.mode) ?? .steady

        switch strength {
        case .none:
            insightText = PatternReader.todayReflection(mode: mode, intention: intention)
        case .weak:
            insightText = PatternReader.weakInsight(for: history)
                ?? PatternReader.todayReflection(mode: mode, intention: intention)
        case .strong:
            insightText = PatternReader.strongInsight(for: history)
                ?? PatternReader.todayReflection(mode: mode, intention: intention)
        }

        screen = .insightPreview
    }

    func advanceFromInsightPreview() {
        advanceFromInsightPreview(now: Date())
    }

    func advanceFromInsightPreview(now: Date) {
        screen = nextScreenAfterInsightPreview(now: now)
    }

    func nextScreenAfterInsightPreview(now: Date) -> Screen {
        return .guidedPause
    }

    func dismissOnboarding() {
        onboardingSeen = true
        UserDefaults.standard.set(true, forKey: UDKey.onboardingComplete)
    }

    // MARK: - Inactivity timer

    func resetInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            DispatchQueue.main.async { self?.showWakeHome() }
        }
    }

    func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }

    private func resetFlowSession() {
        answers = []
        paywallShownThisFlow = false
        paywallContext = .contextual
        insightStrength = .none
        insightText = ""
        sessionMode = .steady
        selectedSoundDirection = .focus
        selectedFirstWin = nil
        didCompleteFirstWin = false
    }
}
