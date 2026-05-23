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
        if !skipEntitlementCheck {
            Task { await self.checkEntitlement() }
        }
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
    }

    func recordAnswer(_ answer: String) {
        guard answers.count < MorningData.questions.count else { return }
        answers.append(answer)
        resetInactivityTimer()
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
