import Foundation
import Observation

enum Screen {
    case alarm
    case scheduleSetup
    case quiz
    case intention
    case results
    case move
    case win
    case cycleComplete
    case action
    case insightPreview
    case paywall
    case guidedPause
    case mobilityFlow
}

@Observable
final class AppState {
    var screen: Screen = .alarm
    var answers: [String] = []

    // Premium state (persisted via UserDefaults)
    var isPremium: Bool
    var onboardingSeen: Bool
    private var paywallLastShownDate: Double

    // Session-scoped (reset each flow)
    var paywallShownThisFlow: Bool = false
    var paywallContext: PaywallContext = .contextual
    var insightStrength: InsightStrength = .none
    var insightText: String = ""
    var sessionMode: MorningMode = .steady

    private var inactivityTimer: Timer?

    // MARK: - Mobility state
    var currentMobilityFlow: MobilityFlow? = nil
    var currentMobilityMoveIndex: Int = 0
    var mobilitySecondsRemaining: Int = 0
    var isMobilityRunning: Bool = false
    private var mobilityTimer: Timer?

    init() {
        isPremium            = UserDefaults.standard.bool(forKey: "premium_unlocked")
        onboardingSeen       = UserDefaults.standard.bool(forKey: "onboarding_seen")
        paywallLastShownDate = UserDefaults.standard.double(forKey: "paywall_last_shown_date")
    }

    // MARK: - Existing navigation

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
        screen = .quiz
        resetInactivityTimer()
    }

    func recordAnswer(_ answer: String) {
        answers.append(answer)
    }

    func showIntention() {
        screen = .intention
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
            let intentionStr = UserDefaults.standard.string(forKey: "selected_intention") ?? IntentionType.focus.rawValue
            DailyEntryStore.append(mode: mode.rawValue, intention: intentionStr)
        }
        screen = .alarm
    }

    // MARK: - Premium flow navigation

    func advanceFromResults() {
        let history = DailyEntryStore.load()
        let strength = PatternReader.strength(for: history)
        insightStrength = strength

        let intentionStr = UserDefaults.standard.string(forKey: "selected_intention") ?? IntentionType.focus.rawValue
        let intention = IntentionType(rawValue: intentionStr) ?? .focus
        let result = MorningData.result(from: answers)
        let mode = MorningMode(from: result.mode) ?? .steady
        sessionMode = mode

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

    func onPaywallPresented() {
        guard !paywallShownThisFlow else { return }
        paywallShownThisFlow = true
        paywallLastShownDate = Date().timeIntervalSince1970
        UserDefaults.standard.set(paywallLastShownDate, forKey: "paywall_last_shown_date")
    }

    func advanceFromPaywall() {
        screen = .action
    }

    func unlockPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: "premium_unlocked")
    }

    func dismissOnboarding() {
        onboardingSeen = true
        UserDefaults.standard.set(true, forKey: "onboarding_seen")
    }

    func recordManualPaywallShown() {
        paywallLastShownDate = Date().timeIntervalSince1970
        paywallShownThisFlow = true
        UserDefaults.standard.set(paywallLastShownDate, forKey: "paywall_last_shown_date")
    }

    // MARK: - Mobility methods

    func openMobilityFlow() {
        let flow = MobilityLibrary.flow()
        currentMobilityFlow = flow
        currentMobilityMoveIndex = 0
        mobilitySecondsRemaining = flow.moves.first?.duration ?? 0
        isMobilityRunning = false
        screen = .mobilityFlow
    }

    func startMobility() {
        guard currentMobilityFlow != nil else { return }
        isMobilityRunning = true
        mobilityTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.tickMobility() }
        }
    }

    func pauseMobility() {
        mobilityTimer?.invalidate()
        mobilityTimer = nil
        isMobilityRunning = false
    }

    func resumeMobility() {
        guard currentMobilityFlow != nil, !isMobilityRunning else { return }
        startMobility()
    }

    func advanceMobilityMove() {
        guard let flow = currentMobilityFlow else { return }
        let nextIndex = currentMobilityMoveIndex + 1
        if nextIndex < flow.moves.count {
            currentMobilityMoveIndex = nextIndex
            mobilitySecondsRemaining = flow.moves[nextIndex].duration
        } else {
            completeMobilityFlow()
        }
    }

    func completeMobilityFlow() {
        mobilityTimer?.invalidate()
        mobilityTimer = nil
        isMobilityRunning = false
        currentMobilityFlow = nil
        screen = .action
    }

    private func tickMobility() {
        if mobilitySecondsRemaining > 1 {
            mobilitySecondsRemaining -= 1
        } else {
            mobilityTimer?.invalidate()
            mobilityTimer = nil
            isMobilityRunning = false
            advanceMobilityMove()
        }
    }

    // MARK: - Inactivity timer

    func resetInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            DispatchQueue.main.async { self?.endFlow() }
        }
    }

    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
}
