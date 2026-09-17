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
    @State private var smiled = false
    /// Shown once the detector has had a fair chance and still hasn't seen
    /// one. Someone smiling at a phone that will not respond stops smiling.
    @State private var showsShutter = false
    @State private var showsCalendar = false

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
        .sheet(isPresented: $showsCalendar) { MorningCalendarView() }
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

            Text(smileGuidance)
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .animation(.easeOut(duration: 0.25), value: camera.seesFace)

            Spacer()

            // Their own shutter, once waiting has stopped being charming. It
            // takes the picture from the same live frames, so the morning is
            // finished the same way — just decided by them instead.
            if showsShutter {
                Button(L10n.text(en: "I'm smiling — take it",
                                 tr: "Gülümsüyorum — çek",
                                 es: "Estoy sonriendo — tómala")) {
                    camera.capture()
                }
                .primaryCTA()
                .padding(.bottom, DS.Space.md)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityIdentifier("ritual.smileShutter")
            }

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

    private var smileGuidance: String {
        guard camera.available else {
            return L10n.text(en: "No camera here — carry on.",
                             tr: "Burada kamera yok — devam.",
                             es: "Sin cámara aquí — continúa.")
        }
        if camera.smiling {
            return L10n.text(en: "There it is.", tr: "İşte bu.", es: "Ahí está.")
        }
        if camera.seesFace {
            return L10n.text(en: "It holds until it sees one. No hurry.",
                             tr: "Görene kadar bekler. Acelesi yok.",
                             es: "Espera hasta verla. Sin prisa.")
        }
        return L10n.text(en: "Bring your face into the circle.",
                         tr: "Yüzünü çemberin içine getir.",
                         es: "Trae tu cara al círculo.")
    }

    private func startSmileCapture() {
        glow = true
        showsShutter = false
        camera.setAutoCapture(true)
        camera.onCapture = { image in
            let result = EnergyReader.read(from: image, activePath: appState.activePath)
            energy = result
            smiled = true
            camera.stop()
            finish()
        }
        camera.configureAndStart()
        // A phone with no camera must not hold the morning hostage.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !camera.available, step == .smile { finish() }
        }
        // Eight seconds is long enough for a real smile to be found and short
        // enough that nobody concludes the app is broken.
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if step == .smile, camera.available {
                withAnimation(.easeOut(duration: 0.3)) { showsShutter = true }
            }
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

            VStack(spacing: DS.Space.sm) {
                Button(L10n.text(en: "Begin the day", tr: "Güne başla", es: "Comenzar el día")) {
                    dismiss()
                }
                .primaryCTA()
                .accessibilityIdentifier("ritual.done")

                Button(L10n.text(en: "See your mornings", tr: "Sabahlarını gör", es: "Ver tus mañanas")) {
                    showsCalendar = true
                }
                .font(.footnote)
                .foregroundStyle(DS.accent)
                .accessibilityIdentifier("ritual.seeMornings")
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.xl)
        }
    }

    // MARK: - Finish

    private func finish() {
        guard step != .done else { return }
        camera.stop()
        // One line in the log for this morning. A reading the app did not
        // trust goes in as nothing, so the calendar never shows a number that
        // was really a shrug.
        let trusted = reading.flatMap { $0.isTrustworthy && $0.bpm > 0 ? $0.bpm : nil }
        MorningLogStore.record(bpm: trusted, smiled: smiled)
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
        // The morning has happened. Whatever is left of the chain can go.
        if #available(iOS 26.1, *) { AlarmKitWakeScheduler.cancelFollowUps() }
    }

    static var completedToday: Bool {
        UserDefaults.standard.string(forKey: key) == dayStamp()
    }

    private static func dayStamp(_ date: Date = Date()) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}
