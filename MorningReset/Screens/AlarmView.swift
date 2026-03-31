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

                // Actions
                VStack(spacing: DS.Space.sm) {
                    Button("Begin") {
                        appState.startFlow()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.textPrimary)
                    .foregroundStyle(DS.background)
                    .clipShape(Rectangle())

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

    // MARK: - Next alarm display

    @ViewBuilder
    private var nextAlarmLine: some View {
        if schedule.isEnabled, let next = AlarmScheduler.nextFireDate(for: schedule) {
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
