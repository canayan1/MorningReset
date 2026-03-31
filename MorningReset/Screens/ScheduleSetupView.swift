import SwiftUI

struct ScheduleSetupView: View {
    @Environment(AppState.self) private var appState

    @State private var weekdayDate: Date
    @State private var weekendDate: Date
    @State private var authDenied = false

    init() {
        let s   = WakeScheduleStore.load()
        let cal = Calendar.current
        let wd  = cal.date(bySettingHour: s.weekdayHour, minute: s.weekdayMinute, second: 0, of: .now) ?? .now
        let we  = cal.date(bySettingHour: s.weekendHour, minute: s.weekendMinute, second: 0, of: .now) ?? .now
        _weekdayDate = State(initialValue: wd)
        _weekendDate = State(initialValue: we)
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Nav
                HStack {
                    Button {
                        appState.endFlow()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.textSecondary)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, DS.Space.lg)

                Text("WAKE SCHEDULE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)

                Spacer().frame(height: DS.Space.sm)

                Text("Set your\nmorning times.")
                    .font(.title2.bold())
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(4)

                Spacer().frame(height: 40)

                timeBlock(label: "WEEKDAYS  MON – FRI", date: $weekdayDate)

                Spacer().frame(height: DS.Space.md)

                timeBlock(label: "WEEKENDS  SAT – SUN", date: $weekendDate)

                if authDenied {
                    Text("Notification access required. Enable it in Settings → MorningReset.")
                        .font(.caption)
                        .foregroundStyle(DS.accent)
                        .padding(.top, DS.Space.md)
                }

                Spacer()

                Button("Save Schedule") {
                    Task { await saveAndSchedule() }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(Rectangle())
                .padding(.bottom, 48)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    // MARK: - Time block

    private func timeBlock(label: String, date: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textSecondary)
                .kerning(1.2)
            Spacer()
            DatePicker("", selection: date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(DS.accent)
        }
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }

    // MARK: - Save

    @MainActor
    private func saveAndSchedule() async {
        let cal     = Calendar.current
        let wdComps = cal.dateComponents([.hour, .minute], from: weekdayDate)
        let weComps = cal.dateComponents([.hour, .minute], from: weekendDate)

        var updated = WakeScheduleStore.load()
        updated.weekdayHour   = wdComps.hour   ?? 7
        updated.weekdayMinute = wdComps.minute ?? 0
        updated.weekendHour   = weComps.hour   ?? 8
        updated.weekendMinute = weComps.minute ?? 0
        updated.isEnabled     = true

        let backend    = AlarmManager.current
        let authorized = await backend.requestAuthorization()
        guard authorized else {
            authDenied = true
            return
        }

        WakeScheduleStore.save(updated)
        await backend.schedule(updated)
        appState.endFlow()
    }
}
