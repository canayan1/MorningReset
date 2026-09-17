import SwiftUI

// MARK: - Pulse check
//
// Twenty seconds with a fingertip over the camera, before and after a practice.
// The point is not the number on its own — it is the pair. Most apps in this
// category say a practice will settle you; this one shows you.
//
// It never insists. Skip is always there, and a reading the app does not trust
// is reported as exactly that rather than dressed up as a result.

struct PulseCheckView: View {
    /// What this reading is for — it only changes the words.
    enum Moment { case before, after }

    let moment: Moment
    /// Speak over the reading. The morning ritual does; a reading taken either
    /// side of a practice does not, because the practice has its own voice.
    var affirmations: Bool = false
    /// Seconds between one affirmation and the next. The reading itself is
    /// done in about ten; what fills the rest is the reason to keep still.
    var affirmationGap: Double = 7
    /// Hidden during the morning ritual, where the whole point is that it is
    /// the thing you get up for.
    var showsSkip: Bool = true
    var onFinish: (PulseReading?) -> Void

    @StateObject private var reader = PulseReader()
    @Environment(\.dismiss) private var dismiss
    @State private var pulseScale: CGFloat = 1
    @State private var affirmationTimer: Timer?
    @State private var affirmationIndex = 0
    /// The reading is in but the voice has not finished. With affirmations
    /// on, the screen waits for the last line rather than leaving mid-sentence
    /// — the number is not the point of this minute, the minute is.
    @State private var result: PulseReading?? = nil
    @State private var linesDone = false

    /// Said over the reading, in the guide's own voice. Nothing is asked of the
    /// person here — they are holding a finger still, and these are the only
    /// twenty seconds of the day when that is the whole job.
    /// Said while the finger is still.
    ///
    /// Good morning is said once, at the very start of the flow, and never
    /// again — greeting somebody at every new screen is how an app stops
    /// sounding like a person. These open with the one thing worth saying to
    /// someone who got up and did this at all.
    private static let lines = [
        "I'm proud of you for showing up this morning.",
        "Stay just as you are. Let the breath be easy.",
        "Let your shoulders drop, and let your jaw soften.",
        "You are already here. That is enough.",
        "Be gentle with yourself today."
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if showsSkip {
                    Button {
                        reader.stop()
                        onFinish(nil)
                        dismiss()
                    } label: {
                        Text(L10n.text(en: "Skip", tr: "Atla", es: "Omitir"))
                            .font(.subheadline)
                            .foregroundStyle(DS.textSecondary)
                    }
                    .accessibilityIdentifier("pulse.skip")
                    }
                }
                .frame(height: 24)
                .padding(.top, 20)

                Spacer()

                Text(eyebrow)
                    .font(DS.Typo.label)
                    .kerning(1.4)
                    .foregroundStyle(DS.accent)

                Spacer().frame(height: DS.Space.sm)

                Text(headline)
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                Spacer().frame(height: DS.Space.xl)

                dial

                Spacer().frame(height: DS.Space.xl)

                Text(instruction)
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 300)
                    .animation(.easeInOut(duration: 0.25), value: instruction)

                Spacer()

                Text(L10n.text(
                    en: "A wellness reading, not a medical one. Nothing is recorded.",
                    tr: "Tıbbi değil, kişisel bir okuma. Hiçbir görüntü kaydedilmiyor.",
                    es: "Una lectura de bienestar, no médica. No se graba nada."
                ))
                .font(.caption2)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
                .padding(.bottom, DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("pulse.screen")
        .onAppear {
            reader.start()
            if affirmations { speakAffirmations() }
        }
        .onDisappear { reader.stop(); affirmationTimer?.invalidate() }
        .onChange(of: reader.phase) { _, phase in
            switch phase {
            case .done(let reading):
                // Let the final number land before leaving.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    result = .some(reading.bpm > 0 && reading.isTrustworthy ? reading : nil)
                    leaveIfReady()
                }
            case .unavailable:
                // No camera, or the person said no. Never hold the practice
                // hostage to a reading — show the reason, then get out of the way.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    result = .some(nil)
                    leaveIfReady()
                }
            default:
                break
            }
        }
    }

    private func speakAffirmations() {
        SpeechGuide.shared.speak(Self.lines[0])
        affirmationIndex = 1
        affirmationTimer = Timer.scheduledTimer(withTimeInterval: affirmationGap, repeats: true) { t in
            guard affirmationIndex < Self.lines.count else {
                // One more gap after the last line, so it is heard out and
                // sat with, then the screen is free to go.
                t.invalidate()
                linesDone = true
                leaveIfReady()
                return
            }
            SpeechGuide.shared.speak(Self.lines[affirmationIndex])
            affirmationIndex += 1
        }
    }

    private func leaveIfReady() {
        guard let result else { return }
        guard !affirmations || linesDone else { return }
        onFinish(result)
        dismiss()
    }

    // MARK: - Dial

    private var dial: some View {
        ZStack {
            Circle()
                .fill(DS.accentSoft.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .scaleEffect(pulseScale)

            Circle()
                .stroke(DS.border, lineWidth: 2)
                .frame(width: 230, height: 230)

            Circle()
                .trim(from: 0, to: reader.progress)
                .stroke(DS.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 230, height: 230)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: reader.progress)

            VStack(spacing: DS.Space.xs) {
                if let bpm = reader.liveBPM {
                    Text("\(bpm)")
                        .font(.system(size: 76, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.3), value: bpm)
                    Text("BPM")
                        .font(DS.Typo.label)
                        .kerning(2)
                        .foregroundStyle(DS.textDim)
                } else {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(DS.accentSoft)
                }

                if !reader.trace.isEmpty {
                    PulseTrace(samples: reader.trace)
                        .stroke(DS.calm.opacity(0.85), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                        .frame(width: 150, height: 34)
                        .padding(.top, DS.Space.xs)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reader.liveBPM.map { "\($0) beats per minute" } ?? instruction)
    }

    // MARK: - Words

    private var eyebrow: String {
        switch moment {
        case .before: L10n.text(en: "BEFORE", tr: "ÖNCE", es: "ANTES")
        case .after:  L10n.text(en: "AFTER", tr: "SONRA", es: "DESPUÉS")
        }
    }

    private var headline: String {
        switch moment {
        case .before:
            L10n.text(en: "Where you are\nright now.",
                      tr: "Şu an\nneredesin.",
                      es: "Dónde estás\nahora mismo.")
        case .after:
            L10n.text(en: "And where you are\nnow.",
                      tr: "Ve şimdi\nneredesin.",
                      es: "Y dónde estás\nahora.")
        }
    }

    private var instruction: String {
        switch reader.phase {
        case .unavailable:
            return L10n.text(en: "This phone's camera isn't available for a reading.",
                             tr: "Bu telefonun kamerası okuma için kullanılamıyor.",
                             es: "La cámara de este teléfono no está disponible.")
        case .waitingForFinger:
            return L10n.text(en: "Rest a fingertip over the back camera and hold it still.",
                             tr: "Parmak ucunu arka kameraya koy ve kıpırdatma.",
                             es: "Apoya la yema del dedo sobre la cámara trasera y no la muevas.")
        case .measuring:
            return L10n.text(en: "Hold it there. Breathe normally.",
                             tr: "Öyle tut. Normal nefes al.",
                             es: "Mantenlo ahí. Respira normal.")
        case .done(let reading):
            return reading.bpm > 0 && reading.isTrustworthy
                ? L10n.text(en: "Got it.", tr: "Aldım.", es: "Listo.")
                : L10n.text(en: "That one didn't settle. We can try again after.",
                            tr: "Bu okuma oturmadı. Sonra tekrar deneyebiliriz.",
                            es: "Esa lectura no cuajó. Podemos intentarlo después.")
        case .idle:
            return ""
        }
    }
}

// MARK: - Trace

/// The detrended signal, drawn as it arrives.
struct PulseTrace: Shape {
    let samples: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard samples.count > 1 else { return path }
        let peak = max(samples.map { abs($0) }.max() ?? 1, 0.0001)
        let dx = rect.width / CGFloat(samples.count - 1)
        for (i, v) in samples.enumerated() {
            let y = rect.midY - CGFloat(v / peak) * rect.height * 0.45
            let point = CGPoint(x: CGFloat(i) * dx, y: y)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }
}
