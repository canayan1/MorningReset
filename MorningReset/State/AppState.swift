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
    private var paywallLastShownDate: Double

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
    private var mobilityTimer: Timer?

    init() {
        isPremium            = UserDefaults.standard.bool(forKey: "premium_unlocked")
        onboardingSeen       = UserDefaults.standard.bool(forKey: "onboarding_complete")
        paywallLastShownDate = UserDefaults.standard.double(forKey: "paywall_last_shown_date")
        userAppleID          = UserDefaults.standard.string(forKey: "apple_user_id")
        userName             = UserDefaults.standard.string(forKey: "apple_user_name")
        Task { await self.checkEntitlement() }
    }

    // MARK: - Streak

    var streakCount: Int {
        let entries = DailyEntryStore.load()
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
            let intentionStr = UserDefaults.standard.string(forKey: "selected_intention") ?? IntentionType.focus.rawValue
            DailyEntryStore.append(mode: mode.rawValue, intention: intentionStr)
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

        let intentionStr = UserDefaults.standard.string(forKey: "selected_intention") ?? IntentionType.focus.rawValue
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

    // MARK: - StoreKit 2

    private static let productID = "com.canayan.MorningReset.premium.annual"

    @MainActor
    func purchase() async throws {
        guard let product = try await Product.products(for: [Self.productID]).first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                unlockPremium()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            return
        }
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlockPremium()
                return
            }
        }
    }

    @MainActor
    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlockPremium()
                return
            }
        }
    }

    func dismissOnboarding() {
        onboardingSeen = true
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }

    // MARK: - Apple Sign In

    func handleAppleSignIn(result: ASAuthorization) {
        guard let credential = result.credential as? ASAuthorizationAppleIDCredential else { return }
        let id = credential.user
        let name = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }.joined(separator: " ")
        userAppleID = id
        UserDefaults.standard.set(id, forKey: "apple_user_id")
        if !name.isEmpty {
            userName = name
            UserDefaults.standard.set(name, forKey: "apple_user_name")
        }
    }

    func signOut() {
        userAppleID = nil
        userName = nil
        UserDefaults.standard.removeObject(forKey: "apple_user_id")
        UserDefaults.standard.removeObject(forKey: "apple_user_name")
    }

    func recordManualPaywallShown() {
        paywallLastShownDate = Date().timeIntervalSince1970
        paywallShownThisFlow = true
        UserDefaults.standard.set(paywallLastShownDate, forKey: "paywall_last_shown_date")
    }

    // MARK: - Mobility methods

    func openMobilityFlow() {
        guard isPremium else {
            paywallContext = .riseAndFlow
            screen = .paywall
            return
        }
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
        let s = streakCount
        if s == 3 || s == 7 || s == 14 || s == 30 {
            screen = .feedback
        } else {
            screen = .action
        }
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
