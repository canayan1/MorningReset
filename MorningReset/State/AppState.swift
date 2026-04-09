import Foundation
import Observation
import StoreKit
import AuthenticationServices

enum Screen {
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
}

@Observable
final class AppState {
    var screen: Screen = .alarm
    var answers: [String] = []

    // Premium state (persisted via UserDefaults)
    var isPremium: Bool
    var onboardingSeen: Bool
    var paywallLastShownDate: Double

    // Apple Sign In (persisted via UserDefaults)
    var userAppleID: String?
    var userName: String?

    // Session-scoped (reset each flow)
    var paywallShownThisFlow: Bool = false
    var paywallContext: PaywallContext = .contextual
    var insightStrength: InsightStrength = .none
    var insightText: String = ""
    var sessionMode: MorningMode = .steady
    var selectedSoundDirection: SoundDirection = .focus

    private var inactivityTimer: Timer?

    // MARK: - Mobility state
    var currentMobilityFlow: MobilityFlow? = nil
    var currentMobilityMoveIndex: Int = 0
    var mobilitySecondsRemaining: Int = 0
    var isMobilityRunning: Bool = false
    var mobilityTimer: Timer?

    // MARK: - Streak cache
    private var _cachedStreak: Int? = nil

    init() {
        isPremium            = UserDefaults.standard.bool(forKey: UDKey.premiumUnlocked)
        onboardingSeen       = UserDefaults.standard.bool(forKey: UDKey.onboardingComplete)
        paywallLastShownDate = UserDefaults.standard.double(forKey: UDKey.paywallLastShown)
        userAppleID          = UserDefaults.standard.string(forKey: UDKey.appleUserID)
        userName             = UserDefaults.standard.string(forKey: UDKey.appleUserName)
        Task { await self.checkEntitlement() }
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
        screen = .scheduleSetup
    }

    func startFlow() {
        answers = []
        paywallShownThisFlow = false
        paywallContext = .contextual
        insightStrength = .none
        insightText = ""
        sessionMode = .steady
        selectedSoundDirection = .focus
        screen = .quiz
        resetInactivityTimer()
    }

    func recordAnswer(_ answer: String) {
        answers.append(answer)
    }

    func showWeeklyAffirmation() {
        let result = MorningData.result(from: answers)
        let mode = MorningMode(from: result.mode) ?? .steady
        sessionMode = mode
        selectedSoundDirection = SoundDirection.recommended(for: mode)
        screen = .weeklyAffirmation
    }

    func showMorningSound() {
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

    func endFlow() {
        stopInactivityTimer()
        if answers.count == MorningData.questions.count {
            let result = MorningData.result(from: answers)
            let mode = MorningMode(from: result.mode) ?? .steady
            let intentionStr = UserDefaults.standard.string(forKey: UDKey.selectedIntention) ?? IntentionType.focus.rawValue
            let intention = IntentionType(rawValue: intentionStr) ?? .focus
            DailyEntryStore.append(mode: mode.rawValue, intention: intentionStr)
            invalidateStreakCache()
            WidgetSnapshot.write(
                mode:   mode.rawValue,
                mantra: MantraEngine.generate(mode: mode, intention: intention),
                streak: streakCount
            )
        }
        let s = streakCount
        if s == 3 || s == 7 || s == 14 || s == 30 {
            screen = .feedback
        } else {
            screen = .alarm
        }
    }

    func dismissFeedback() {
        screen = .alarm
    }

    func showFlowCheckout() {
        screen = .flowCheckout
    }

    // MARK: - Premium flow navigation

    func advanceFromResults() {
        let history = DailyEntryStore.load()
        let strength = PatternReader.strength(for: history)
        insightStrength = strength

        let intentionStr = UserDefaults.standard.string(forKey: UDKey.selectedIntention) ?? IntentionType.focus.rawValue
        let intention = IntentionType(rawValue: intentionStr) ?? .focus
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
        if isPremium {
            screen = .guidedPause
            return
        }
        if paywallShownThisFlow {
            screen = .action
            return
        }
        if insightStrength == .strong {
            paywallContext = .contextual
            screen = .paywall
            return
        }
        let daysSince = paywallLastShownDate == 0
            ? Double.infinity
            : (Date().timeIntervalSince1970 - paywallLastShownDate) / 86400
        if daysSince >= 21 {
            paywallContext = .periodic
            screen = .paywall
            return
        }
        screen = .action
    }

    func dismissOnboarding() {
        onboardingSeen = true
        UserDefaults.standard.set(true, forKey: UDKey.onboardingComplete)
    }

    // MARK: - Inactivity timer

    func resetInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            DispatchQueue.main.async { self?.endFlow() }
        }
    }

    func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
}
