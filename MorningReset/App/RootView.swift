import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            switch appState.screen {
            case .alarm:   AlarmView().transition(.opacity)
            case .quiz:    QuizView().transition(.opacity)
            case .results: ResultsView().transition(.opacity)
            case .action:  ActionView().transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: appState.screen)
    }
}
