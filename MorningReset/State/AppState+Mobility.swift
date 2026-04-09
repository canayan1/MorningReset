import Foundation

extension AppState {

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
        invalidateStreakCache()
        let s = streakCount
        if s == 3 || s == 7 || s == 14 || s == 30 {
            screen = .feedback
        } else {
            screen = .action
        }
    }

    func tickMobility() {
        if mobilitySecondsRemaining > 1 {
            mobilitySecondsRemaining -= 1
        } else {
            mobilityTimer?.invalidate()
            mobilityTimer = nil
            isMobilityRunning = false
            advanceMobilityMove()
        }
    }
}
