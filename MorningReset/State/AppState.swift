import Foundation
import Observation

enum Screen {
    case alarm
    case quiz
    case results
    case action
}

@Observable
final class AppState {
    var screen: Screen = .alarm

    private var inactivityTimer: Timer?

    func startFlow() {
        screen = .quiz
        resetInactivityTimer()
    }

    func showResults() {
        stopInactivityTimer()
        screen = .results
    }

    func showAction() {
        screen = .action
    }

    func endFlow() {
        stopInactivityTimer()
        screen = .alarm
    }

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
