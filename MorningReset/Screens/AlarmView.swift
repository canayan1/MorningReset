import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self)      private var appState
    @Environment(InsightEngine.self) private var insightEngine
    @State private var showAbout   = false
    @State private var showSignIn  = false
    @State private var schedule    = WakeScheduleStore.load()

    private var advisorMessage: String? {
        IntentionAdvisor.advise(
            entries:      DailyEntryStore.load(),
            checkouts:    FlowCheckoutStore.last(7),
            streakCount:  appState.streakCount
        )
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning." }
        if h < 17 { return "Good afternoon." }
        return "Good evening."
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Top nav
                HStack {
                    if appState.streakCount > 0 {
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(DS.accent)
                                .frame(width: 2, height: 11)
                            Text("\(appState.streakCount)d")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(DS.textDim)
                        }
                    }
                    Spacer()
                    if appState.userAppleID == nil {
                        Button("Sign in") { showSignIn = true }
                            .font(.caption)
                            .foregroundStyle(DS.textDim)
                            .padding(.trailing, DS.Space.sm)
                    }
                    Button("About") { showAbout = true }
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                }
                .padding(.top, 20)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                // Greeting + next alarm
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(greeting)
                        .font(.system(size: 40, design: .serif).weight(.regular))
                        .foregroundStyle(DS.textPrimary)

                    Text("When the morning notification arrives,\ntap it instead of doom scrolling.")
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(2)

                    nextAlarmLine
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                // Weekly AI insight (premium only, shown when available)
                if appState.isPremium, let summary = insightEngine.weeklySummary {
                    WeeklyInsightCardView(summary: summary)
                        .padding(.horizontal, DS.Space.lg)
                    Spacer().frame(height: DS.Space.sm)
                }

                // Soft premium intro (first launch only)
                if !appState.onboardingSeen {
                    onboardingCard
                    Spacer().frame(height: DS.Space.sm)
                }

                // Intention advisor (all users, rule-based)
                if let advice = advisorMessage {
                    InfoCard(label: "TODAY", value: advice)
                        .padding(.horizontal, DS.Space.lg)
                    Spacer().frame(height: DS.Space.sm)
                }

                // Actions
                VStack(spacing: DS.Space.sm) {
                    Button("Start Morning Reset") {
                        appState.startFlow()
                    }
                    .font(.system(.body, design: .serif))
                    .tracking(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())

                    Button("Set morning notification") {
                        appState.showScheduleSetup()
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DS.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(DS.border, lineWidth: DS.hairline))
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            schedule = WakeScheduleStore.load()
            Task {
                await AlarmManager.current.requestAuthorization()
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
    }

    // MARK: - Onboarding card

    private var onboardingCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("Set your morning notification")
                .font(.callout.weight(.semibold))
                .foregroundStyle(DS.background)
            Text("Each morning, this app will send you a quiet ping.\nTap it instead of doom scrolling —\nthat single tap is the start of a different day.")
                .font(.caption)
                .foregroundStyle(DS.background.opacity(0.75))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            Button("Start your first reset") {
                appState.dismissOnboarding()
                appState.startFlow()
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(DS.background)
        }
        .padding(DS.Space.md)
        .background(DS.accent)
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Next alarm display

    @ViewBuilder
    private var nextAlarmLine: some View {
        if schedule.isEnabled, let next = AlarmManager.current.nextFireDate(for: schedule) {
            Text(formatNextAlarm(next))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
        } else {
            Text("No alarm set.")
                .font(.callout)
                .foregroundStyle(DS.textDim)
        }
    }

    private func formatNextAlarm(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE 'at' h:mm a"
        return "Next ping: \(f.string(from: date))"
    }
}
