import SwiftUI
import UIKit

struct ScheduleSetupView: View {
    @Environment(AppState.self) private var appState

    @State private var weekdayDate: Date
    @State private var weekendDate: Date
    @State private var authDenied = false
    @State private var insist: Bool

    init() {
        let s   = WakeScheduleStore.load()
        let cal = Calendar.current
        let wd  = cal.date(bySettingHour: s.weekdayHour, minute: s.weekdayMinute, second: 0, of: .now) ?? .now
        let we  = cal.date(bySettingHour: s.weekendHour, minute: s.weekendMinute, second: 0, of: .now) ?? .now
        _weekdayDate = State(initialValue: wd)
        _weekendDate = State(initialValue: we)
        _insist = State(initialValue: s.insistUntilRitual)
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

                Text(L10n.text(en: "MORNING PRACTICE", tr: "SABAH PRATİĞİ", es: "PRÁCTICA MATUTINA"))
                    .font(DS.Typo.label)
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.4)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                Text(L10n.text(en: "Wake up into\nyour practice.", tr: "Pratiğinin içine\nuyan.", es: "Despierta dentro\nde tu práctica."))
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                Text(
                    L10n.text(
                        en: "At the time you choose, a voice wakes you and the practice begins — through Silent mode and Sleep Focus. Change it or switch it off any time.",
                        tr: "Seçtiğin saatte bir ses seni uyandırır ve pratik başlar — Sessiz mod ve Uyku Odağı'nda bile. İstediğin zaman değiştir ya da kapat.",
                        es: "A la hora que elijas, una voz te despierta y la práctica comienza — incluso en modo Silencio y Concentración de sueño. Cámbialo o desactívalo cuando quieras."
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

                Spacer().frame(height: DS.Space.md)

                insistToggle

                if authDenied {
                    VStack(alignment: .center, spacing: DS.Space.sm) {
                        Text(L10n.text(en: "Alarms are off for Inner Light. Enable them in Settings.", tr: "Inner Light için alarmlar kapalı. Ayarlar'dan etkinleştir.", es: "Las alarmas están desactivadas para Inner Light. Actívalas en Ajustes."))
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

                Button(L10n.text(en: "Set morning practice", tr: "Sabah pratiğini kur", es: "Configurar práctica matutina")) {
                    Task { await saveAndSchedule() }
                }
                .primaryCTA()
                .padding(.bottom, DS.Space.xl)
                .accessibilityIdentifier("schedule.saveButton")
            }
            .padding(.horizontal, DS.Space.lg)
        }
        // No identifier on the container: SwiftUI would stamp it onto every
        // child and erase the save button's own.
    }

    // MARK: - Time block

    private var lockScreenPreview: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("INNER LIGHT")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(DS.textDim)
                Text(L10n.text(
                    en: "Your practice is ready.",
                    tr: "Pratiğin hazır.",
                    es: "Tu práctica está lista."
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

    /// iOS will not let anyone block its Stop button, so what this really does
    /// is put a few more alarms behind the first one. The copy says that rather
    /// than promising something the system does not allow.
    private var insistToggle: some View {
        Toggle(isOn: $insist) {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.text(en: "Keep asking until I'm up",
                               tr: "Kalkana kadar vazgeçme",
                               es: "Insiste hasta que me levante"))
                    .font(.body.weight(.medium))
                    .foregroundStyle(DS.textPrimary)
                Text(L10n.text(
                    en: "It rings again every three minutes until the morning is done.",
                    tr: "Sabah tamamlanana kadar üç dakikada bir tekrar çalar.",
                    es: "Suena otra vez cada tres minutos hasta terminar la mañana."
                ))
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(DS.accent)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        .accessibilityIdentifier("schedule.insistToggle")
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
        updated.insistUntilRitual = insist

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
