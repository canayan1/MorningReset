import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        switch state.screen {
        case .alarm:
            AlarmView()
        case .quiz:
            QuizView()
        case .results(let result):
            ResultsView(result: result)
        case .action(let result):
            ActionView(result: result)
        }
    }
}
