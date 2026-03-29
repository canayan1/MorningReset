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

    func startFlow() {
        screen = .quiz
    }

    func showResults() {
        screen = .results
    }

    func showAction() {
        screen = .action
    }

    func endFlow() {
        screen = .alarm
    }
}
