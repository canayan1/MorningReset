import SwiftUI
import UIKit

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
            AppBackground()

            VStack(alignment: .center, spacing: 0) {

                // Nav
                HStack {
                    Button {
                        appState.showWakeHome()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.textSecondary)
                    }
                    .accessibilityLabel(L10n.text(en: "Close", tr: "Kapat", es: "Cerrar"))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, DS.Space.lg)

                Text(L10n.text(en: "DAILY REMINDER", tr: "GÜNLÜK HATIRLATICI", es: "RECORDATORIO DIARIO"))
                    .font(DS.Typo.label)
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.4)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                Text(L10n.text(en: "Practice at the same\ntime each day?", tr: "Her gün aynı saatte\npratik yapalım mı?", es: "¿Practicar a la misma\nhora cada día?"))
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                Text(
                    L10n.text(
                        en: "Optional — we'll send a gentle reminder. Turn it off any time.",
                        tr: "İsteğe bağlı — nazik bir hatırlatma göndeririz. İstediğinde kapat.",
                        es: "Opcional — te enviaremos un recordatorio suave. Desactívalo cuando quieras."
                    )
                )
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.md)

                lockScreenPreview

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
                    VStack(alignment: .center, spacing: DS.Space.sm) {
                        Text(L10n.text(en: "Notifications are off. Enable them in Settings.", tr: "Bildirimler kapalı. Ayarlar'dan etkinleştir.", es: "Las notificaciones están desactivadas. Actívalas en Ajustes."))
                            .font(.caption)
                            .foregroundStyle(DS.accent)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                        Button(L10n.text(en: "Open Settings", tr: "Ayarları aç", es: "Abrir ajustes")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DS.accent)
                    }
                    .padding(.top, DS.Space.md)
                }

                Spacer()

                Button(L10n.text(en: "Save wake time", tr: "Uyanma saatini kaydet", es: "Guardar hora de despertar")) {
                    Task { await saveAndSchedule() }
                }
                .primaryCTA()
                .padding(.bottom, DS.Space.xl)
                .accessibilityIdentifier("schedule.saveButton")
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("schedule.screen")
    }

    // MARK: - Time block

    private var lockScreenPreview: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("ENERGY RESET")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(DS.textDim)
                Text(L10n.text(
                    en: "Your daily reset is ready.",
                    tr: "Scroll başlamadan önce sessiz bir ritüel.",
                    es: "Un ritual tranquilo antes del scroll."
                ))
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Text(weekdayDate, style: .time)
                .font(.system(size: 22, weight: .thin, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(DS.border, lineWidth: DS.hairline)
        )
        .overlay(
            Text(L10n.text(en: "ON LOCK SCREEN", tr: "KİLİT EKRANINDA", es: "EN PANTALLA BLOQUEADA"))
                .font(.system(size: 8, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(DS.background)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(DS.accent)
                .clipShape(Capsule())
                .offset(y: -10),
            alignment: .topLeading
        )
    }

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
