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
                        appState.showWakeHome()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.textSecondary)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, DS.Space.lg)

                Text(L10n.text(en: "MORNING NOTIFICATION", tr: "SABAH BİLDİRİMİ", es: "NOTIFICACIÓN MATINAL"))
                    .font(DS.Typo.label)
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.4)

                Spacer().frame(height: DS.Space.sm)

                Text(L10n.text(en: "Set your\nmorning notification", tr: "Sabah\nbildirimini ayarla", es: "Configura tu\nnotificación matinal"))
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(6)

                Spacer().frame(height: DS.Space.sm)

                Text(
                    L10n.text(
                        en: "Morning Reset sends a local notification at the time you choose.\nUse your normal alarm or wake-up routine, then tap this ping first.",
                        tr: "Morning Reset seçtiğin saatte yerel bir bildirim gönderir.\nNormal alarmını ya da uyanma rutinini kullan, sonra önce bu ping'e dokun.",
                        es: "Morning Reset envía una notificación local a la hora que elijas.\nUsa tu alarma o rutina habitual y luego toca primero este aviso."
                    )
                )
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                    .lineSpacing(3)

                Spacer().frame(height: DS.Space.sm)

                Text(
                    L10n.text(
                        en: "It follows your iPhone notification, mute, and Focus settings, so it stays honest about what it can do.",
                        tr: "iPhone bildirim, sessiz ve Focus ayarlarını takip eder; yani ne yapabildiği konusunda dürüst kalır.",
                        es: "Sigue los ajustes de notificaciones, silencio y Focus de tu iPhone, así que es honesto sobre lo que puede hacer."
                    )
                )
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)

                Spacer().frame(height: 40)

                timeBlock(
                    label: L10n.text(en: "WEEKDAYS  MON – FRI", tr: "HAFTA İÇİ  PZT – CUM", es: "ENTRE SEMANA  LUN – VIE"),
                    date: $weekdayDate
                )

                Spacer().frame(height: DS.Space.md)

                timeBlock(
                    label: L10n.text(en: "WEEKENDS  SAT – SUN", tr: "HAFTA SONU  CMT – PAZ", es: "FIN DE SEMANA  SÁB – DOM"),
                    date: $weekendDate
                )

                if authDenied {
                    Text(L10n.text(en: "Notifications are off. Enable them in Settings → MorningReset to receive the morning ping.", tr: "Bildirimler kapalı. Sabah ping'ini almak için Ayarlar → MorningReset içinde etkinleştir.", es: "Las notificaciones están desactivadas. Actívalas en Ajustes → MorningReset para recibir el aviso matinal."))
                        .font(.caption)
                        .foregroundStyle(DS.accent)
                        .padding(.top, DS.Space.md)
                }

                Spacer()

                Button(L10n.text(en: "Save morning notification", tr: "Sabah bildirimini kaydet", es: "Guardar notificación matinal")) {
                    Task { await saveAndSchedule() }
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.bottom, DS.Space.xl)
                .accessibilityIdentifier("schedule.saveButton")
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("schedule.screen")
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

        let backend    = WakeNotificationManager.current
        let authorized = await backend.requestAuthorization()
        guard authorized else {
            authDenied = true
            return
        }

        authDenied = false
        WakeScheduleStore.save(updated)
        await backend.schedule(updated)
        appState.finishScheduleSetup()
    }
}
