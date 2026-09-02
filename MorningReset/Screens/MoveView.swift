import SwiftUI

struct MoveView: View {
    @Environment(AppState.self) private var appState

    @State private var isRunning = false
    @State private var secondsRemaining = 60

    private var mode: MorningMode {
        appState.sessionMode
    }

    private var cue: String {
        let elapsed = 60 - secondsRemaining

        switch mode {
        case .protect:
            switch elapsed {
            case 0..<20:
                return L10n.text(en: "Roll your shoulders slowly.", tr: "Omuzlarını yavaşça çevir.", es: "Rota los hombros lentamente.")
            case 20..<40:
                return L10n.text(en: "Reach up, then lower your arms.", tr: "Yukarı uzan, sonra kollarını indir.", es: "Estírate hacia arriba y luego baja los brazos.")
            default:
                return L10n.text(en: "March softly in place.", tr: "Olduğun yerde yumuşakça adımla.", es: "Marcha suavemente en tu sitio.")
            }
        case .steady:
            switch elapsed {
            case 0..<20:
                return L10n.text(en: "March in place.", tr: "Olduğun yerde adımla.", es: "Marcha en tu sitio.")
            case 20..<40:
                return L10n.text(en: "Circle your arms and open your chest.", tr: "Kollarını çevir ve göğsünü aç.", es: "Haz círculos con los brazos y abre el pecho.")
            default:
                return L10n.text(en: "Twist gently left and right.", tr: "Nazikçe sağa sola dön.", es: "Gira suavemente a izquierda y derecha.")
            }
        case .push:
            switch elapsed {
            case 0..<20:
                return L10n.text(en: "Fast march or high knees.", tr: "Hızlı adımla ya da dizlerini yükselt.", es: "Marcha rápido o sube las rodillas.")
            case 20..<40:
                return L10n.text(en: "Do light squats or quick reaches.", tr: "Hafif squat yap ya da hızlı uzanışlar dene.", es: "Haz sentadillas suaves o alcances rápidos.")
            default:
                return L10n.text(en: "Shake out the body and stay tall.", tr: "Bedeni silk ve dik kal.", es: "Sacude el cuerpo y mantente erguido.")
            }
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .center, spacing: DS.Space.xs) {
                    Text(L10n.text(en: "60-SECOND MOVE", tr: "60 SANİYELİK HAREKET", es: "MOVIMIENTO DE 60 SEGUNDOS"))
                        .font(DS.Typo.label)
                        .foregroundStyle(DS.textDim)
                        .kerning(1.4)

                    Text(timeLabel)
                        .font(.system(size: 56, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)

                    Text(cue)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                ProgressView(value: Double(60 - secondsRemaining), total: 60)
                    .tint(DS.accent)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.md)

                Button(primaryButtonTitle) {
                    handlePrimaryAction()
                }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .disabled(isRunning)
                .accessibilityIdentifier("move.primaryButton")

                Text(
                    isRunning
                    ? L10n.text(en: "Stay with the minute.", tr: "Dakikada kal.", es: "Quédate con el minuto.")
                    : L10n.text(en: "Movement first. Scrolling later.", tr: "Önce hareket. Kaydırma sonra.", es: "Primero movimiento. El scroll después.")
                )
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                    .padding(.top, DS.Space.md)
                    .padding(.bottom, DS.Space.xl)
            }
        }
        .accessibilityIdentifier("move.screen")
        .task(id: isRunning) {
            guard isRunning else { return }
            while isRunning && secondsRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard isRunning else { return }
                secondsRemaining -= 1
            }
            if secondsRemaining == 0 {
                isRunning = false
            }
        }
        .onDisappear {
            isRunning = false
        }
    }

    private var timeLabel: String {
        String(format: "0:%02d", secondsRemaining)
    }

    private var primaryButtonTitle: String {
        secondsRemaining == 0
            ? L10n.text(en: "Lock in this win", tr: "Bu kazanımı kilitle", es: "Fija esta victoria")
            : L10n.text(en: "Start moving", tr: "Harekete başla", es: "Empieza a moverte")
    }

    private func handlePrimaryAction() {
        if secondsRemaining == 0 {
            appState.completeFirstWin()
            return
        }
        isRunning = true
    }
}
