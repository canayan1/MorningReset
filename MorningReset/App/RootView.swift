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
            case .alarm:              AlarmView().transition(.opacity)
            case .scheduleSetup:      ScheduleSetupView().transition(.opacity)
            case .quiz:               QuizView().transition(.opacity)
            case .weeklyAffirmation:  WeeklyAffirmationView().transition(.opacity)
            case .morningSound:       MorningSoundView().transition(.opacity)
            case .results:            ResultsView().transition(.opacity)
            case .move:               MoveView().transition(.opacity)
            case .win:                WinView().transition(.opacity)
            case .cycleComplete:      CycleCompleteView().transition(.opacity)
            case .action:             ActionView().transition(.opacity)
            case .insightPreview:     InsightPreviewView().transition(.opacity)
            case .paywall:            PaywallView(context: appState.paywallContext).transition(.opacity)
            case .guidedPause:        GuidedPauseView().transition(.opacity)
            case .mobilityFlow:       MobilityFlowView().transition(.opacity)
            case .feedback:           FeedbackView().transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: appState.screen)
    }
}
