import SwiftUI

// MARK: - The morning check-up
//
// What the alarm opens into, and the only thing that ends it.
//
// The order is the argument. A smile first, because it is the one thing you
// can do before you are really awake and it costs nothing — and because the
// bell fades out as a result of it, so the room going quiet is something you
// did rather than something that happened. Then the pulse, which asks you to
// hold still, which is only reasonable once the noise has stopped. Then the
// breath. Then the day.
//
// It is deliberately not a practice. A practice asks you to do something; this
// asks you to be looked at for a minute while someone tells you the day has
// not started making demands yet. The practices are elsewhere, for later,
// when you have chosen them.

struct MorningRitualView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    private enum Step: Equatable {
        case arrival          // the bell recedes, the voice says there is no hurry
        case smile
        case toPulse          // one breath, and the voice says what is next
        case pulse
        case toBreath
        case breath
        case done
    }

    @StateObject private var camera = CameraSession()
    @State private var step: Step = .arrival
    @State private var reading: PulseReading?
    @State private var energy: EnergyReading?
    @State private var glow = false
    @State private var smiled = false
    /// Shown once the detector has had a fair chance and still hasn't seen
    /// one. Someone smiling at a phone that will not respond stops smiling.
    @State private var showsShutter = false
    @State private var showsCalendar = false
    @State private var previewIn = false
    @State private var doneButtonIn = false

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.4)

            switch step {
            case .arrival:
                MorningBreathTransition(lines: [
                    "Good morning.",
                    "There's no hurry.",
                    "Your morning is starting. Stay where you are for a moment."
                ]) { go(.smile) }
                .transition(.opacity)

            case .smile:
                smileStep.transition(.opacity)

            case .toPulse:
                MorningBreathTransition(lines: [
                    "Next, your pulse.",
                    "Place your finger over the camera on the back of the phone.",
                    "And cover the little light beside it."
                ]) { go(.pulse) }
                .transition(.opacity)

            case .toBreath:
                MorningBreathTransition(lines: [
                    "Next, your breath.",
                    "Breathe out towards the phone, slowly, and let it be heard."
                ]) { go(.breath) }
                .transition(.opacity)

            case .pulse, .breath:
                Color.clear

            case .done:
                doneStep.transition(.opacity)
            }
        }
        .accessibilityIdentifier("ritual.screen")
        .onAppear {
            // Silence the alarm here as well as in the intent — whether the
            // intent's stop reaches it is not a thing to discover at six in the
            // morning — and bring the same bell back underneath, receding.
            if #available(iOS 26.1, *) { AlarmKitWakeScheduler.silenceRinging() }
            AlarmChime.shared.startSoftly()
        }
        .fullScreenCover(isPresented: .constant(step == .pulse)) {
            PulseCheckView(moment: .before, affirmations: true,
                           affirmationGap: Pace.affirmationGap, showsSkip: false) { result in
                reading = result
                go(.toBreath)
            }
        }
        .fullScreenCover(isPresented: .constant(step == .breath)) {
            SignatureMeditationView(onComplete: { finish() }, spokenIntro: false)
        }
        .sheet(isPresented: $showsCalendar) { MorningCalendarView() }
        .onDisappear {
            camera.stop()
            AlarmChime.shared.stop()
            SpeechGuide.shared.stop()

            // Leaving early is not finishing.
            //
            // The system's Stop belongs to the phone's owner and always will —
            // no app gets to cover it, and an alarm that cannot be silenced is
            // a safety problem rather than a feature. What an app can decide is
            // what Stop *achieves*: here it buys three minutes. Tapping Begin
            // silenced the chain, so walking away without the morning having
            // happened has to put it back, or the one escape route in the whole
            // design is to start and then not finish.
            if step != .done, !MorningRitual.completedToday {
                if #available(iOS 26.1, *) {
                    Task { await AlarmKitWakeScheduler.reconcileFollowUps() }
                }
            }
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
                        .opacity(previewIn ? 1 : 0)
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
            Button(L10n.text(en: "Skip this", tr: "Bunu geç", es: "Saltar esto")) {
                camera.stop()
                AlarmChime.shared.fadeOut(over: 1.0)
                go(.toPulse)
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
        previewIn = false
        // The voice first; the lens after. A camera opening on your face
        // before anyone has said why is the single most startling thing the
        // old flow did. The preview now comes up out of the glow over three
        // seconds, once the invitation has been made.
        SpeechGuide.shared.speak("When you're ready — let yourself smile.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 3)) { previewIn = true }
        }
        camera.setAutoCapture(true)
        // Held, not glimpsed. Two seconds is long enough to be a smile and
        // short enough that nobody feels held there.
        camera.setSmileHold(2.0)
        camera.onCapture = { image in
            let result = EnergyReader.read(from: image, activePath: appState.activePath)
            energy = result
            smiled = true
            camera.stop()
            // The room goes quiet because of the smile, not because of a timer.
            AlarmChime.shared.fadeOut()
            SpeechGuide.shared.speak("There it is.")
            // And then nothing, for a moment. The smile is allowed to be the
            // last thing that happened before the next thing starts.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Pace.afterLine) {
                go(.toPulse)
            }
        }
        camera.configureAndStart()
        // A phone with no camera must not hold the morning hostage.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !camera.available, step == .smile {
                AlarmChime.shared.fadeOut(over: 1.0)
                go(.toPulse)
            }
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
                Text(L10n.text(en: "You're ready for the day.",
                               tr: "Güne hazırsın.",
                               es: "Estás listo para el día."))
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
            .opacity(doneButtonIn ? 1 : 0)
        }
    }

    /// Every change of screen takes the same unhurried moment.
    private func go(_ next: Step) {
        withAnimation(.easeInOut(duration: Pace.crossfade)) { step = next }
    }

    // MARK: - Finish

    private func finish() {
        guard step != .done else { return }
        camera.stop()
        AlarmChime.shared.stop()
        // One line in the log for this morning. A reading the app did not
        // trust goes in as nothing, so the calendar never shows a number that
        // was really a shrug.
        let trusted = reading.flatMap { $0.isTrustworthy && $0.bpm > 0 ? $0.bpm : nil }
        MorningLogStore.record(bpm: trusted, smiled: smiled)
        MorningRitual.markCompleted()
        doneButtonIn = false
        Task {
            await SpeechGuide.shared.say(["That's your morning check-up.", "The day is yours."],
                                         pause: Pace.afterLine)
        }
        // The button arrives after the words have. Nothing on this screen
        // should look like it is waiting for you.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeInOut(duration: Pace.crossfade)) { doneButtonIn = true }
        }
        go(.done)
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

// MARK: - Pace

/// How fast the morning moves. All of it, in one place.
///
/// Time here is measured in breaths, not seconds. When something feels
/// rushed the answer is one of these numbers, not a new screen.
enum Pace {
    /// One breath: the length of a transition. In for half of it, out for
    /// the rest.
    static let breath: Double = 8
    /// Silence after a spoken line, before the next one. This is where the
    /// line lands.
    static let afterLine: Double = 3
    /// Every change of screen.
    static let crossfade: Double = 1.5
    /// How long the bell takes to draw away after the alarm.
    static let bellEase: Double = 6
    /// Between one affirmation and the next, over the pulse.
    static let affirmationGap: Double = 11
}

// MARK: - The breath between two things

/// Says what is about to happen, and takes one breath before it does.
///
/// This replaced a countdown. Numbers ticking down are a timer however
/// gently they are drawn, and a timer is a demand. What sits between two
/// parts of the morning now is the thing the whole app is about: a circle
/// that fills as if breathing in and settles as if breathing out, while the
/// voice names what comes next and then leaves a silence for it to land in.
/// The next screen fades in on the out-breath.
///
/// It lasts as long as the words need, and never less than one full breath.
struct MorningBreathTransition: View {
    /// Spoken in order, with a pause after each.
    let lines: [String]
    var onDone: () -> Void

    @State private var swell = false

    var body: some View {
        ZStack {
            Circle()
                .fill(DS.accentSoft.opacity(0.20))
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .scaleEffect(swell ? 1.18 : 0.78)

            Circle()
                .fill(DS.accent.opacity(0.10))
                .frame(width: 150, height: 150)
                .scaleEffect(swell ? 1.0 : 0.70)

            Circle()
                .stroke(DS.accentSoft.opacity(swell ? 0.55 : 0.25), lineWidth: 1.5)
                .frame(width: 150, height: 150)
                .scaleEffect(swell ? 1.0 : 0.70)
        }
        .animation(.easeInOut(duration: Pace.breath / 2).repeatForever(autoreverses: true), value: swell)
        .accessibilityIdentifier("ritual.handoff")
        .accessibilityLabel(lines.joined(separator: " "))
        .onAppear {
            swell = true
            Task {
                let started = Date()
                await SpeechGuide.shared.say(lines, pause: Pace.afterLine)
                // Finish on an out-breath: however long the words took, wait
                // out the remainder of the current breath, then one more
                // moment of nothing.
                let elapsed = Date().timeIntervalSince(started)
                let intoBreath = elapsed.truncatingRemainder(dividingBy: Pace.breath)
                let untilSettled = max(Pace.breath - elapsed, Pace.breath - intoBreath)
                try? await Task.sleep(nanoseconds: UInt64((untilSettled + Pace.afterLine) * 1_000_000_000))
                onDone()
            }
        }
    }
}
