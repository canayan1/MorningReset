import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState
    @State private var showAbout = false
    @State private var schedule  = WakeScheduleStore.load()

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
                    Spacer()
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
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(DS.textPrimary)

                    Text("No bad vibes. No negative noise.")
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)

                    nextAlarmLine
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                // Soft premium intro (first launch only)
                if !appState.onboardingSeen {
                    onboardingCard
                    Spacer().frame(height: DS.Space.sm)
                }

                // Actions
                VStack(spacing: DS.Space.sm) {
                    Button("Start Morning Reset") {
                        appState.startFlow()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.textPrimary)
                    .foregroundStyle(DS.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button("Set wake schedule") {
                        appState.showScheduleSetup()
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DS.surface)
                    .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            schedule = WakeScheduleStore.load()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }

    // MARK: - Onboarding card

    private var onboardingCard: some View {
        HStack(alignment: .top, spacing: DS.Space.md) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("Begin before autopilot does.")
                    .font(.callout.bold())
                    .foregroundStyle(DS.background)
                Text("A short reset that helps you choose how your morning starts.")
                    .font(.caption)
                    .foregroundStyle(DS.background.opacity(0.65))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button {
                appState.dismissOnboarding()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DS.background.opacity(0.35))
            }
        }
        .padding(DS.Space.md)
        .background(DS.textPrimary)
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
        return "Next: \(f.string(from: date))"
    }
}
