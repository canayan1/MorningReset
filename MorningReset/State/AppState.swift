import Foundation
import Observation

enum Screen: Equatable {
    case alarm
    case quiz
    case results(MorningResult)
    case action(MorningResult)
}

@Observable
final class AppState {
    var screen: Screen = .alarm
    var answers: [String] = []

    private var inactivityTimer: Timer?
    private let inactivityLimit: TimeInterval = 60

    // MARK: - Flow

    func startFlow() {
        answers = []
        screen = .quiz
        resetInactivityTimer()
    }

    func recordAnswer(_ answer: String) {
        resetInactivityTimer()
        answers.append(answer)
        if answers.count == MorningData.questions.count {
            stopInactivityTimer()
            let result = MorningData.score(answers: answers)
            screen = .results(result)
        }
    }

    func proceedToAction(result: MorningResult) {
        screen = .action(result)
    }

    func saveMode(_ mode: String) {
        UserDefaults.standard.set(mode, forKey: "lastMode")
        UserDefaults.standard.set(Date(), forKey: "lastResetDate")
    }

    func endFlow() {
        stopInactivityTimer()
        screen = .alarm
        answers = []
    }

    // MARK: - Inactivity timer

    func resetInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityLimit, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.endFlow()
            }
        }
    }

    func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
}
