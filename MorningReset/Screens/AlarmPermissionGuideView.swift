import SwiftUI
import UIKit

// MARK: - How to let the alarm ring
//
// The one setting the app cannot change for you, shown rather than described.
//
// iOS asks for alarm permission exactly once. Say no — or miss the prompt —
// and every morning afterwards arrives as a notification, which is precisely
// what Sleep Focus is built to silence. Nothing about that failure is visible:
// the alarm is set, the phone is quiet, and the morning simply does not come.
//
// So this screen has two jobs and picks between them. While the prompt can
// still be shown it shows what the prompt will look like and asks for it.
// Once it can't, it gives the three steps through Settings with a picture of
// the row being looked for — a switch is easier to find when you have seen it.

struct AlarmPermissionGuideView: View {
    @Environment(\.dismiss) private var dismiss

    /// Told when permission changes, so the screen that opened this can settle
    /// without waiting to be asked again.
    var onResolved: (WakeAlarmPermission) -> Void = { _ in }

    @State private var permission: WakeAlarmPermission = WakeAlarmPermissionCheck.current
    @State private var asking = false

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.35)

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: DS.Space.lg) {
                        title

                        switch permission {
                        case .allowed, .unsupported: allowedBody
                        case .notAsked:              notAskedBody
                        case .refused:               refusedBody
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
                }
            }
        }
        .accessibilityIdentifier("alarmPermission.screen")
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification)) { _ in refresh() }
    }

    // MARK: - Chrome

    private var header: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textSecondary)
            }
            .accessibilityLabel(L10n.text(en: "Close", tr: "Kapat", es: "Cerrar"))
        }
        .padding(.top, 20)
        .padding(.horizontal, DS.Space.lg)
        .padding(.bottom, DS.Space.md)
    }

    private var title: some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: permission == .allowed ? "bell.badge.fill" : "bell.slash")
                .font(.system(size: 30, weight: .ultraLight))
                .foregroundStyle(permission == .allowed ? DS.calm : DS.accent)

            Text(permission == .allowed
                 ? L10n.text(en: "Your alarm will ring.", tr: "Alarmın çalacak.", es: "Tu alarma sonará.")
                 : L10n.text(en: "One switch, and it rings.",
                             tr: "Tek bir anahtar, ve çalar.",
                             es: "Un interruptor, y suena."))
                .font(.system(size: 27, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)

            Text(permission == .allowed
                 ? L10n.text(en: "It comes through Silent mode and Sleep Focus, with its own bell.",
                             tr: "Sessiz modda ve Uyku Odağı'nda da gelir, kendi çanıyla.",
                             es: "Llega en modo Silencio y Concentración de sueño, con su propia campana.")
                 : L10n.text(en: "Only a real alarm reaches through Silent mode and Sleep Focus. Without it, the morning arrives as a notification — and a Focus can hold one back.",
                             tr: "Sessiz modu ve Uyku Odağı'nı yalnızca gerçek bir alarm aşar. O olmadan sabah bildirim olarak gelir — ve Odak bildirimi tutabilir.",
                             es: "Solo una alarma real atraviesa el modo Silencio y la Concentración de sueño. Sin ella, la mañana llega como notificación — y un Modo puede retenerla."))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Allowed

    private var allowedBody: some View {
        VStack(spacing: DS.Space.lg) {
            settingsRowFacsimile(on: true)
            Button(L10n.text(en: "Good", tr: "Tamam", es: "Bien")) { dismiss() }
                .primaryCTA()
        }
        .padding(.top, DS.Space.sm)
    }

    // MARK: - The prompt is still available

    private var notAskedBody: some View {
        VStack(spacing: DS.Space.lg) {
            promptFacsimile

            Text(L10n.text(en: "iOS asks once, and only once. Choose Allow.",
                           tr: "iOS yalnızca bir kez sorar. İzin Ver'i seç.",
                           es: "iOS pregunta una sola vez. Elige Permitir."))
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)

            Button(L10n.text(en: "Ask me now", tr: "Şimdi sor", es: "Pregúntame ahora")) {
                Task {
                    asking = true
                    let result = await WakeAlarmPermissionCheck.request()
                    asking = false
                    apply(result)
                }
            }
            .primaryCTA()
            .disabled(asking)
            .accessibilityIdentifier("alarmPermission.ask")
        }
        .padding(.top, DS.Space.sm)
    }

    /// What iOS is about to put on the screen. Shown beforehand so the real
    /// thing is recognised rather than dismissed — a permission sheet arriving
    /// unannounced is a sheet people tap through to make it go away.
    private var promptFacsimile: some View {
        VStack(spacing: 0) {
            VStack(spacing: DS.Space.xs) {
                Text(L10n.text(en: "“Inner Light” Would Like to Add Alarms",
                               tr: "“Inner Light” Alarm Eklemek İstiyor",
                               es: "“Inner Light” quiere añadir alarmas"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                Text(L10n.text(en: "Alarms ring through Silent mode and Focus.",
                               tr: "Alarmlar Sessiz modda ve Odak'ta çalar.",
                               es: "Las alarmas suenan en modo Silencio y Concentración."))
                    .font(.system(size: 11))
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.md)

            Rectangle().fill(DS.divider).frame(height: DS.hairline)

            HStack(spacing: 0) {
                Text(L10n.text(en: "Don't Allow", tr: "İzin Verme", es: "No permitir"))
                    .font(.system(size: 13))
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity)
                Rectangle().fill(DS.divider).frame(width: DS.hairline, height: 36)
                Text(L10n.text(en: "Allow", tr: "İzin Ver", es: "Permitir"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.accent)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 36)
        }
        .frame(maxWidth: 260)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(DS.border, lineWidth: DS.hairline))
    }

    // MARK: - The prompt is spent

    private var refusedBody: some View {
        VStack(spacing: DS.Space.lg) {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                step(1, L10n.text(en: "Tap the button below. It opens straight to Inner Light's own settings.",
                                  tr: "Aşağıdaki düğmeye dokun. Doğrudan Inner Light'ın kendi ayarlarını açar.",
                                  es: "Toca el botón de abajo. Abre directamente los ajustes de Inner Light."))
                step(2, L10n.text(en: "Turn on Alarms.", tr: "Alarmlar'ı aç.", es: "Activa Alarmas."))
                step(3, L10n.text(en: "Come back here. This screen will say your alarm will ring.",
                                  tr: "Buraya dön. Bu ekran alarmının çalacağını yazacak.",
                                  es: "Vuelve aquí. Esta pantalla dirá que tu alarma sonará."))
            }

            settingsRowFacsimile(on: false)

            Button(L10n.text(en: "Open Settings", tr: "Ayarları aç", es: "Abrir ajustes")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .primaryCTA()
            .accessibilityIdentifier("alarmPermission.openSettings")
        }
        .padding(.top, DS.Space.sm)
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.md) {
            Text("\(number)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DS.background)
                .frame(width: 22, height: 22)
                .background(DS.accent, in: Circle())
            Text(text)
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    /// The row they are looking for, drawn rather than named. A switch in a
    /// long settings list is found much faster once you have seen it.
    private func settingsRowFacsimile(on: Bool) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(on ? DS.calm : DS.accent, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(L10n.text(en: "Alarms", tr: "Alarmlar", es: "Alarmas"))
                .font(.system(size: 15))
                .foregroundStyle(DS.textPrimary)

            Spacer()

            // A switch, drawn: the real one belongs to Settings.
            Capsule()
                .fill(on ? DS.calm : DS.border)
                .frame(width: 44, height: 26)
                .overlay(alignment: on ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .frame(width: 22, height: 22)
                        .padding(2)
                        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                }
                .animation(.easeOut(duration: 0.25), value: on)
        }
        .padding(.vertical, DS.Space.sm)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(DS.border, lineWidth: DS.hairline))
        .overlay(alignment: .topLeading) {
            Text(L10n.text(en: "IN SETTINGS", tr: "AYARLAR'DA", es: "EN AJUSTES"))
                .font(DS.Typo.micro).kerning(1.2)
                .foregroundStyle(DS.background)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(on ? DS.calm : DS.accent, in: Capsule())
                .offset(x: 10, y: -9)
        }
    }

    // MARK: - State

    private func refresh() { apply(WakeAlarmPermissionCheck.current) }

    private func apply(_ result: WakeAlarmPermission) {
        guard result != permission else { return }
        withAnimation(.easeOut(duration: 0.3)) { permission = result }
        onResolved(result)
    }
}
