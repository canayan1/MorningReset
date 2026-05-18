import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            if !appState.onboardingSeen {
                OnboardingView()
                    .transition(.opacity)
            } else {
                mainFlow
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.3), value: appState.onboardingSeen)
        .preferredColorScheme(.light)
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
            case .flowCheckout:       FlowCheckoutView().transition(.opacity)
            case .premiumHub:         PremiumHubView().transition(.opacity)
            case .breathReset:        BreathResetView().transition(.opacity)
            case .morningPages:       MorningPagesView().transition(.opacity)
            case .monthlyStory:       MonthlyStoryView().transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: appState.screen)
    }
}
