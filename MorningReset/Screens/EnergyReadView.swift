import SwiftUI
import AVFoundation
import UIKit

struct EnergyReadView: View {
    @Environment(AppState.self) private var appState
    @StateObject private var camera = CameraSession()

    private enum Stage { case intro, capturing, analyzing, result }

    @State private var stage: Stage = .intro
    @State private var capturedImage: UIImage?
    @State private var reading: EnergyReading?
    @State private var permissionDenied = false
    @State private var glow = false

    private let language = AppLanguage.current

    var body: some View {
        ZStack {
            AuraBackground(path: reading?.recommendedPath ?? appState.activePath, intensity: 0.4)

            switch stage {
            case .intro:      introView
            case .capturing:  captureView
            case .analyzing:  analyzingView
            case .result:     resultView
            }
        }
        .onDisappear { camera.stop() }
    }

    // MARK: - Intro

    private var introView: some View {
        VStack(spacing: 0) {
            closeBar

            Spacer()

            Image(systemName: "face.smiling")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(DS.accent.opacity(0.7))
                .padding(.bottom, DS.Space.lg)

            Text(L10n.text(language: language,
                           en: "Read your\nenergy",
                           tr: "Enerjini\noku",
                           es: "Lee tu\nenergía"))
                .font(.system(size: 32, weight: .light, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(5)

            Spacer().frame(height: DS.Space.md)

            Text(L10n.text(language: language,
                           en: "Take a selfie and smile. We read your energy on-device and suggest today's practice — your photo never leaves your phone.",
                           tr: "Bir selfie çek ve gülümse. Enerjini cihazında okuruz ve günün pratiğini öneririz — fotoğrafın telefonundan asla çıkmaz.",
                           es: "Hazte un selfie y sonríe. Leemos tu energía en el dispositivo y sugerimos la práctica de hoy — tu foto nunca sale del teléfono."))
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 36)

            Spacer().frame(height: DS.Space.md)

            Text(L10n.text(language: language,
                           en: "An experiential wellbeing reading — not a medical or scientific measurement.",
                           tr: "Deneyimsel bir wellbeing okuması — tıbbi ya da bilimsel bir ölçüm değildir.",
                           es: "Una lectura de bienestar experiencial — no una medición médica o científica."))
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(DS.textDim)
                .padding(.horizontal, 40)

            Spacer()

            if permissionDenied {
                deniedNote
            }

            Button(L10n.text(language: language, en: "Read my energy", tr: "Enerjimi oku", es: "Leer mi energía")) {
                beginCapture()
            }
            .font(.system(.body, design: .serif))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(DS.accent)
            .foregroundStyle(DS.background)
            .clipShape(Capsule())
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.xl)
        }
    }

    private var deniedNote: some View {
        VStack(spacing: DS.Space.sm) {
            Text(L10n.text(language: language,
                           en: "Camera access is off. Enable it in Settings to read your energy.",
                           tr: "Kamera erişimi kapalı. Enerjini okumak için Ayarlar'dan aç.",
                           es: "El acceso a la cámara está desactivado. Actívalo en Ajustes para leer tu energía."))
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(DS.accent)
                .padding(.horizontal, DS.Space.lg)
            Button(L10n.text(language: language, en: "Open Settings", tr: "Ayarları aç", es: "Abrir ajustes")) {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(DS.accent)
        }
        .padding(.bottom, DS.Space.md)
    }

    // MARK: - Capture

    private var captureView: some View {
        ZStack {
            if camera.available {
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()

                LinearGradient(colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.45)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack {
                    closeBar.tint(.white)
                    Spacer()
                    HStack(spacing: DS.Space.sm) {
                        Image(systemName: camera.smiling ? "face.smiling.inverse" : "face.smiling")
                            .font(.system(size: 16, weight: .medium))
                        Text(camera.smiling
                             ? L10n.text(language: language, en: "Hold still", tr: "Sabit tut", es: "Mantén así")
                             : L10n.text(language: language, en: "Smile to capture", tr: "Çekmek için gülümse", es: "Sonríe para capturar"))
                            .font(.system(.subheadline, design: .serif))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.sm)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, DS.Space.lg)

                    Button {
                        camera.capture()
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 4)
                            .frame(width: 74, height: 74)
                            .overlay(Circle().fill(.white).frame(width: 60, height: 60))
                    }
                    .padding(.bottom, DS.Space.xl)
                }
            } else {
                VStack(spacing: 0) {
                    closeBar
                    Spacer()
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(DS.textDim)
                    Text(L10n.text(language: language,
                                   en: "Camera isn't available on this device.",
                                   tr: "Bu cihazda kamera kullanılamıyor.",
                                   es: "La cámara no está disponible en este dispositivo."))
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.top, DS.Space.md)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Analyzing

    private var analyzingView: some View {
        VStack(spacing: DS.Space.lg) {
            Spacer()
            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(DS.accent.opacity(glow ? 0.6 : 0.2), lineWidth: 3))
                    .shadow(color: DS.accent.opacity(glow ? 0.5 : 0.15), radius: glow ? 36 : 12)
                    .scaleEffect(glow ? 1.03 : 0.98)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: glow)
            }
            Text(L10n.text(language: language, en: "Reading your field…", tr: "Enerji alanını okuyor…", es: "Leyendo tu campo…"))
                .font(.system(.callout, design: .serif))
                .italic()
                .foregroundStyle(DS.textSecondary)
            Spacer()
        }
        .onAppear { glow = true }
    }

    // MARK: - Result

    @ViewBuilder
    private var resultView: some View {
        if let reading, let img = capturedImage {
            VStack(spacing: 0) {
                closeBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Photo with mood-tinted aura
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [auraColors(reading.energy)[0].opacity(0.85),
                                                              auraColors(reading.energy)[1].opacity(0.0)],
                                                     center: .center, startRadius: 0, endRadius: 170))
                                .frame(width: 300, height: 300)
                                .blur(radius: 24)
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 168, height: 168)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(auraColors(reading.energy)[0].opacity(0.7), lineWidth: 3))
                        }
                        .padding(.top, DS.Space.xs)

                        Text("\(reading.energy.emoji)  \(reading.energy.label.uppercased())")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(2.0)
                            .foregroundStyle(auraColors(reading.energy)[1])
                            .padding(.top, DS.Space.sm)

                        // Energy level — colour + icons, no number
                        HStack(spacing: 10) {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: i < energyLevel(reading) ? "circle.fill" : "circle")
                                    .font(.system(size: 13))
                                    .foregroundStyle(i < energyLevel(reading) ? auraColors(reading.energy)[0] : DS.border)
                                    .shadow(color: i < energyLevel(reading) ? auraColors(reading.energy)[0].opacity(0.5) : .clear, radius: 4)
                            }
                        }
                        .padding(.top, DS.Space.md)

                        Text(reading.energy.headline)
                            .font(.system(size: 21, weight: .light, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(DS.textPrimary)
                            .padding(.horizontal, 32)
                            .padding(.top, DS.Space.xs)

                        // ── Energy teaching ────────────────────────────
                        Text(reading.teaching)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(DS.textSecondary)
                            .lineSpacing(5)
                            .padding(.horizontal, 30)
                            .padding(.top, DS.Space.md)

                        if let suggestion = appState.suggestedRoutine(for: reading.recommendedPath) {
                            practiceCard(suggestion.school, suggestion.routine)
                                .padding(.horizontal, DS.Space.lg)
                                .padding(.top, DS.Space.lg)

                            if let practice = reading.recommendedPractice {
                                PracticeVisual(path: reading.recommendedPath, practiceId: practice.id, showYouTubeLink: true)
                                    .padding(.top, DS.Space.sm)
                            }
                        }
                    }
                    .padding(.bottom, DS.Space.md)
                }

                // ── Pinned CTAs ────────────────────────────────────────
                if let suggestion = appState.suggestedRoutine(for: reading.recommendedPath) {
                    Button(L10n.text(language: language, en: "Make it today's practice", tr: "Bugünün pratiği yap", es: "Hacerla la práctica de hoy")) {
                        appState.makeTodaysRoutine(schoolID: suggestion.school.id,
                                                   routineID: suggestion.routine.id)
                        appState.showWakeHome()
                    }
                    .accessibilityIdentifier("energyRead.makeTodaysPractice")
                    .font(.system(.body, design: .serif))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())
                    .padding(.horizontal, DS.Space.lg)
                }

                Button(L10n.text(language: language, en: "Read again", tr: "Tekrar oku", es: "Leer otra vez")) {
                    retake()
                }
                .font(.footnote)
                .foregroundStyle(DS.textDim)
                .padding(.top, DS.Space.sm)
                .padding(.bottom, DS.Space.lg)
            }
        }
    }

    private func practiceCard(_ school: SchoolContent, _ routine: Routine) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: SchoolPalette.symbol(school.id))
                .font(.system(size: 24))
                .foregroundStyle(SchoolPalette.color(school.id))
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.text(language: language, en: "SUGGESTED PRACTICE", tr: "ÖNERİLEN PRATİK", es: "PRÁCTICA SUGERIDA"))
                    .font(.system(size: 9, weight: .semibold))
                    .kerning(1.2)
                    .foregroundStyle(DS.textDim)
                Text(routine.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(DS.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(school.name) · \(routine.minutes) min")
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
            }
            Spacer()
        }
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
    }

    // MARK: - Shared

    private var closeBar: some View {
        HStack {
            Spacer()
            Button {
                camera.stop()
                    appState.showWakeHome()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(stage == .capturing && camera.available ? .white : DS.textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(L10n.text(language: language, en: "Close", tr: "Kapat", es: "Cerrar"))
        }
        .padding(.top, 20)
        .padding(.horizontal, DS.Space.lg)
    }

    private func energyLevel(_ reading: EnergyReading) -> Int {
        max(1, min(5, Int((Double(reading.score) / 100.0 * 5).rounded())))
    }

    private func auraColors(_ energy: MorningEnergy) -> [Color] {
        switch energy {
        case .radiant: return [Color(red: 1.00, green: 0.78, blue: 0.35), Color(red: 0.96, green: 0.55, blue: 0.30)]
        case .warm:    return [DS.accentSoft, Color(red: 0.93, green: 0.60, blue: 0.55)]
        case .steady:  return [Color(red: 0.55, green: 0.78, blue: 0.65), DS.accentSoft]
        case .foggy:   return [Color(red: 0.55, green: 0.65, blue: 0.85), Color(red: 0.62, green: 0.56, blue: 0.82)]
        }
    }

    // MARK: - Flow

    private func beginCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { startCamera() } else { permissionDenied = true }
                }
            }
        default:
            permissionDenied = true
        }
    }

    private func startCamera() {
        permissionDenied = false
        camera.setAutoCapture(true)
        camera.onCapture = { image in
            capturedImage = image
            analyze(image)
        }
        withAnimation(.easeOut(duration: 0.2)) { stage = .capturing }
        camera.configureAndStart()
    }

    private func analyze(_ image: UIImage) {
        withAnimation(.easeOut(duration: 0.2)) { stage = .analyzing }
        let path = appState.activePath
        DispatchQueue.global(qos: .userInitiated).async {
            let result = EnergyReader.read(from: image, activePath: path)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                reading = result
                withAnimation(.easeOut(duration: 0.4)) { stage = .result }
            }
        }
    }

    private func retake() {
        capturedImage = nil
        reading = nil
        startCamera()
    }
}
