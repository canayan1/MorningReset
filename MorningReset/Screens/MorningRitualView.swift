import SwiftUI

// MARK: - The morning ritual
//
// What the alarm opens into, and the only thing that ends it. Three steps and
// none of them is a chore: hold a finger still while a voice says something
// kind, then smile at the phone, then the morning is yours.
//
// It is deliberately not a practice. A practice asks you to do something; this
// asks you to be looked at for forty seconds while someone tells you the day
// has not started making demands yet. The practices are elsewhere, for later,
// when you have chosen them.

struct MorningRitualView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    private enum Step { case pulse, smile, done }

    @StateObject private var camera = CameraSession()
    @State private var step: Step = .pulse
    @State private var reading: PulseReading?
    @State private var energy: EnergyReading?
    @State private var glow = false

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.4)

            switch step {
            case .pulse: Color.clear
            case .smile: smileStep
            case .done:  doneStep
            }
        }
        .accessibilityIdentifier("ritual.screen")
        .fullScreenCover(isPresented: .constant(step == .pulse)) {
            PulseCheckView(moment: .before, affirmations: true, showsSkip: false) { result in
                reading = result
                SpeechGuide.shared.speak("Now — let yourself smile.")
                withAnimation(.easeOut(duration: 0.35)) { step = .smile }
            }
        }
        .onDisappear {
            camera.stop()
            SpeechGuide.shared.stop()
        }
    }

    // MARK: - Smile

    private var smileStep: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(L10n.text(en: "NOW", tr: "ŞİMDİ", es: "AHORA"))
                .font(DS.Typo.label).kerning(1.4)
                .foregroundStyle(DS.accent)

            Spacer().frame(height: DS.Space.sm)

            Text(L10n.text(en: "Smile.", tr: "Gülümse.", es: "Sonríe."))
                .font(.system(size: 40, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Spacer().frame(height: DS.Space.xl)

            ZStack {
                Circle()
                    .fill(DS.accentSoft.opacity(camera.smiling ? 0.30 : 0.14))
                    .frame(width: 300, height: 300)
                    .blur(radius: 30)
                    .scaleEffect(glow ? 1.06 : 0.96)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: glow)

                if camera.available {
                    CameraPreview(session: camera.session)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(camera.smiling ? DS.accent : DS.border, lineWidth: 3))
                        .animation(.easeOut(duration: 0.25), value: camera.smiling)
                } else {
                    Circle()
                        .fill(DS.surface)
                        .frame(width: 250, height: 250)
                        .overlay(Image(systemName: "face.smiling")
                            .font(.system(size: 54, weight: .ultraLight))
                            .foregroundStyle(DS.textDim))
                }
            }

            Spacer().frame(height: DS.Space.xl)

            Text(camera.available
                 ? L10n.text(en: "It holds until it sees one. No hurry.",
                             tr: "Görene kadar bekler. Acelesi yok.",
                             es: "Espera hasta verla. Sin prisa.")
                 : L10n.text(en: "No camera here — carry on.",
                             tr: "Burada kamera yok — devam.",
                             es: "Sin cámara aquí — continúa."))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            // Present, but quiet: the ritual is the point, not a gate that
            // traps someone who has to be somewhere.
            Button(L10n.text(en: "Not this morning", tr: "Bu sabah değil", es: "Esta mañana no")) {
                finish()
            }
            .font(.footnote)
            .foregroundStyle(DS.textDim)
            .padding(.bottom, DS.Space.xl)
            .accessibilityIdentifier("ritual.skipSmile")
        }
        .padding(.horizontal, DS.Space.lg)
        .onAppear { startSmileCapture() }
    }

    private func startSmileCapture() {
        glow = true
        camera.setAutoCapture(true)
        camera.onCapture = { image in
            let result = EnergyReader.read(from: image, activePath: appState.activePath)
            energy = result
            camera.stop()
            finish()
        }
        camera.configureAndStart()
        // A phone with no camera must not hold the morning hostage.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !camera.available, step == .smile { finish() }
        }
    }

    // MARK: - Done

    private var doneStep: some View {
        VStack(spacing: DS.Space.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(DS.accentSoft.opacity(0.22))
                    .frame(width: 260, height: 260)
                    .blur(radius: 34)
                EnergyOrbBadge(total: EnergyOrb.totalSessions, tint: DS.accent, size: 150, celebrate: true)
            }

            VStack(spacing: DS.Space.sm) {
                Text(L10n.text(en: "Good morning.", tr: "Günaydın.", es: "Buenos días."))
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)

                if let energy {
                    Text(energy.energy.headline)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let bpm = reading?.bpm, bpm > 0 {
                    HStack(spacing: DS.Space.xs) {
                        Text("\(bpm)")
                            .font(.system(size: 34, weight: .light, design: .serif))
                            .foregroundStyle(DS.textPrimary)
                            .monospacedDigit()
                        Text("BPM")
                            .font(DS.Typo.label).kerning(1.6)
                            .foregroundStyle(DS.textDim)
                    }
                    .padding(.top, DS.Space.xs)
                }
            }
            .padding(.horizontal, DS.Space.lg)

            Spacer()

            Button(L10n.text(en: "Begin the day", tr: "Güne başla", es: "Comenzar el día")) {
                dismiss()
            }
            .primaryCTA()
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.xl)
            .accessibilityIdentifier("ritual.done")
        }
    }

    // MARK: - Finish

    private func finish() {
        guard step != .done else { return }
        camera.stop()
        MorningRitual.markCompleted()
        SpeechGuide.shared.speak("Good morning. The day is yours.")
        withAnimation(.easeOut(duration: 0.4)) { step = .done }
    }
}

// MARK: - Ritual state

/// Whether this morning's ritual has been done.
///
/// The alarm reads this: until the ritual is finished it comes back, because
/// an alarm that stops for a tap has only ever proved that a hand can move.
enum MorningRitual {
    private static let key = "morning_ritual_completed_on"

    static func markCompleted() {
        UserDefaults.standard.set(dayStamp(), forKey: key)
    }

    static var completedToday: Bool {
        UserDefaults.standard.string(forKey: key) == dayStamp()
    }

    private static func dayStamp(_ date: Date = Date()) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}
