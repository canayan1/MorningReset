import SwiftUI
import UIKit

struct ScheduleSetupView: View {
    @Environment(AppState.self) private var appState

    /// Shown as a step inside first-run rather than on its own.
    ///
    /// The alarm is what the app is for, and the old first run neither
    /// explained it nor set one — somebody could finish onboarding and own an
    /// alarm clock with no alarm in it. In that mode this screen has no close
    /// button, hands control back through `onDone` instead of dismissing, and
    /// offers a way past for anyone who does not want one.
    let isOnboarding: Bool
    let onDone: () -> Void

    @State private var weekdayDate: Date
    @State private var weekendDate: Date
    @State private var authDenied = false
    @State private var insist: Bool
    /// Set once scheduling has run and what came back was not an alarm. The
    /// screen stays put in that case rather than closing on a promise it
    /// cannot keep.
    @State private var deliveredAsNotification = false
    @State private var permission: WakeAlarmPermission = .notAsked
    @State private var showsGuide = false
    @State private var previewing = false

    init(isOnboarding: Bool = false, onDone: @escaping () -> Void = {}) {
        self.isOnboarding = isOnboarding
        self.onDone = onDone
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
                    if isOnboarding {
                        Spacer()
                        Button(L10n.text(en: "Not now", tr: "Şimdi değil", es: "Ahora no")) { onDone() }
                            .font(.footnote)
                            .foregroundStyle(DS.textDim)
                            .accessibilityIdentifier("schedule.skip")
                    } else {
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
                    // Inside onboarding this sits in a shorter column and was
                    // being clipped to "Wake up into…". An ellipsis is banned
                    // copy here, and a headline that truncates is the app
                    // trailing off mid-sentence at the one moment it is making
                    // its case.
                    .fixedSize(horizontal: false, vertical: true)

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
                    // Same reason as the headline above: in onboarding's
                    // shorter column this was clipping to "Change it or…".
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: DS.Space.md)

                lockScreenPreview

                Spacer().frame(height: DS.Space.sm)

                nextRingLine

                Spacer().frame(height: DS.Space.md)

                permissionRow

                Spacer().frame(height: 28)

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

                if deliveredAsNotification {
                    VStack(alignment: .center, spacing: DS.Space.sm) {
                        Text(L10n.text(
                            en: "This will arrive as a notification, and Sleep Focus can hold one back. Allow alarms for Inner Light to be woken through Silent mode.",
                            tr: "Bu bir bildirim olarak gelecek ve Uyku Odağı bildirimi tutabilir. Sessiz modda da uyandırılmak için Inner Light'a alarm izni ver.",
                            es: "Esto llegará como una notificación, y la Concentración de sueño puede retenerla. Permite alarmas para Inner Light y despierta incluso en modo Silencio."
                        ))
                            .font(.caption)
                            .foregroundStyle(DS.accent)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: DS.Space.lg) {
                            Button(L10n.text(en: "Show me how", tr: "Nasıl yapacağımı göster", es: "Muéstrame cómo")) {
                                showsGuide = true
                            }
                            Button(L10n.text(en: "Keep it anyway", tr: "Yine de kalsın", es: "Dejarlo así")) {
                                if isOnboarding { onDone() } else { appState.finishScheduleSetup() }
                            }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DS.accent)
                    }
                    .padding(.top, DS.Space.md)
                }

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
        // Re-checked every time the screen comes forward: alarms can be turned
        // on in Settings and the answer has to be current when they come back.
        .sheet(isPresented: $showsGuide) {
            AlarmPermissionGuideView { resolved in
                permission = resolved
                if resolved == .allowed {
                    deliveredAsNotification = false
                    // Granted while the screen was open: the morning that was
                    // saved as a notification has to be re-made as an alarm,
                    // or the switch changes nothing until they save again.
                    Task { await WakeNotificationManager.current.schedule(WakeScheduleStore.load()) }
                }
            }
        }
        .task { permission = WakeAlarmPermissionCheck.current }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification)) { _ in
            permission = WakeAlarmPermissionCheck.current
            if permission == .allowed { deliveredAsNotification = false }
        }
        // No identifier on the container: SwiftUI would stamp it onto every
        // child and erase the save button's own.
    }

    // MARK: - When it rings

    /// The one thing the screen never said.
    ///
    /// Setting 10:10 at 10:11 schedules tomorrow, which is correct and reads
    /// exactly like a broken alarm: you wait, and nothing happens. It costs a
    /// line to say which morning this is for, and the line moves as the
    /// pickers move, so the case announces itself before it is saved.
    private var nextRingLine: some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: "bell")
                .font(.system(size: 10, weight: .medium))
            Text(nextRingText)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(DS.accent)
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.2), value: nextRingText)
    }

    private var nextRingText: String {
        let cal = Calendar.current
        let wd = cal.dateComponents([.hour, .minute], from: weekdayDate)
        let we = cal.dateComponents([.hour, .minute], from: weekendDate)
        var preview = WakeScheduleStore.load()
        preview.weekdayHour = wd.hour ?? 7;   preview.weekdayMinute = wd.minute ?? 0
        preview.weekendHour = we.hour ?? 8;   preview.weekendMinute = we.minute ?? 0
        preview.isEnabled = true

        guard let fire = WakeNotificationManager.current.nextFireDate(for: preview) else {
            return L10n.text(en: "No morning set", tr: "Kurulu sabah yok", es: "Sin mañana fijada")
        }
        let time = fire.formatted(date: .omitted, time: .shortened)
        let when: String
        if cal.isDateInToday(fire) {
            when = L10n.text(en: "Rings today", tr: "Bugün çalar", es: "Suena hoy")
        } else if cal.isDateInTomorrow(fire) {
            when = L10n.text(en: "Rings tomorrow", tr: "Yarın çalar", es: "Suena mañana")
        } else {
            let day = fire.formatted(.dateTime.weekday(.wide).locale(L10n.locale))
            when = L10n.text(en: "Rings \(day)", tr: "\(day) çalar", es: "Suena el \(day)")
        }
        return "\(when) · \(time)"
    }

    /// What the system will actually do, said before it is asked to do it.
    ///
    /// Without this the only way to discover that an alarm is really a
    /// notification is to sleep through it. The row states what will happen
    /// and, when that is not a ringing alarm, carries the one control that
    /// changes it — the prompt while there is still a prompt to show, and
    /// Settings once there isn't.
    @ViewBuilder
    private var permissionRow: some View {
        switch permission {
        case .allowed, .unsupported:
            VStack(spacing: DS.Space.sm) {
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text(L10n.text(en: "Rings through Silent mode and Sleep Focus",
                                   tr: "Sessiz modda ve Uyku Odağı'nda da çalar",
                                   es: "Suena en modo Silencio y Concentración de sueño"))
                        .font(.caption)
                }
                .foregroundStyle(DS.calm)
                .multilineTextAlignment(.center)

                // An alarm is the one thing you cannot try before it matters:
                // you find out whether it works by sleeping through it.
                Button(previewing
                       ? L10n.text(en: "Listen…", tr: "Dinle…", es: "Escucha…")
                       : L10n.text(en: "Hear it now", tr: "Şimdi dinle", es: "Escúchala ahora")) {
                    Task {
                        previewing = true
                        if #available(iOS 26.1, *) { _ = await AlarmKitWakeScheduler.previewAlarm() }
                        try? await Task.sleep(nanoseconds: 6_000_000_000)
                        previewing = false
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(DS.accent)
                .disabled(previewing)
                .accessibilityIdentifier("schedule.previewAlarm")
            }
            .frame(maxWidth: .infinity)

        case .notAsked, .refused:
            VStack(spacing: DS.Space.sm) {
                Text(L10n.text(
                    en: "Alarms are off, so this would arrive as a notification — and Sleep Focus can hold one back.",
                    tr: "Alarmlar kapalı, bu yüzden bu bir bildirim olarak gelir — ve Uyku Odağı bildirimi tutabilir.",
                    es: "Las alarmas están desactivadas, así que esto llegaría como una notificación — y la Concentración de sueño puede retenerla."
                ))
                .font(.caption)
                .foregroundStyle(DS.accent)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

                Button(L10n.text(en: "Show me how", tr: "Nasıl yapacağımı göster", es: "Muéstrame cómo")) {
                    showsGuide = true
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(DS.accent)
                .accessibilityIdentifier("schedule.allowAlarms")
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.md)
            .frame(maxWidth: .infinity)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
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
                    en: "It comes back every thirty seconds until the morning is done.",
                    tr: "Sabah tamamlanana kadar otuz saniyede bir geri gelir.",
                    es: "Vuelve cada treinta segundos hasta terminar la mañana."
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

        // Close only on a morning that will actually arrive. Anything else
        // stays here and says what it got instead — the failure this is for
        // is silent by nature, and a screen that closes on it is the app
        // agreeing that everything is fine.
        if WakeDeliveryStore.current == .alarm {
            if isOnboarding { onDone() } else { appState.finishScheduleSetup() }
        } else {
            withAnimation(.easeOut(duration: 0.25)) { deliveredAsNotification = true }
        }
    }
}
