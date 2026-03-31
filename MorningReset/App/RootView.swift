import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    var body: some View {
        ZStack {
            if !onboardingComplete {
                OnboardingView()
                    .transition(.opacity)
            } else {
                mainFlow
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.3), value: onboardingComplete)
    }

    @ViewBuilder
    private var mainFlow: some View {
        ZStack {
            switch appState.screen {
            case .alarm:     AlarmView().transition(.opacity)
            case .quiz:      QuizView().transition(.opacity)
            case .intention: IntentionView().transition(.opacity)
            case .results:   ResultsView().transition(.opacity)
            case .move:      MoveView().transition(.opacity)
            case .win:       WinView().transition(.opacity)
            case .action:    ActionView().transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: appState.screen)
    }
}
