import SwiftUI

// MARK: - Reiki: slowly rotating energy emblem with a breathing glow

struct EnergyPulse: View {
    var color: Color
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.95
    @State private var glowOpacity: Double = 0.2

    var body: some View {
        ZStack {
            EnergyEmblem()
                .stroke(color.opacity(glowOpacity * 0.5), lineWidth: 0.8)
                .frame(width: 190, height: 190)
                .blur(radius: 12)
            EnergyEmblem()
                .stroke(color.opacity(0.55), lineWidth: 1.2)
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
        }
        .frame(height: 210)
        .onAppear {
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                scale = 1.07
                glowOpacity = 0.55
            }
        }
    }
}

// MARK: - Breathwork: expanding circle with inhale / exhale cue

struct BreathingCircle: View {
    var isFast: Bool
    var color: Color

    @State private var circleScale: CGFloat = 0.48
    @State private var glowScale: CGFloat = 0.48
    @State private var phaseLabel = ""
    @State private var labelOpacity: Double = 0.0

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.09))
                .frame(width: 165, height: 165)
                .scaleEffect(glowScale * 1.35)
                .blur(radius: 14)
            Circle()
                .stroke(color.opacity(0.45), lineWidth: 1.5)
                .frame(width: 165, height: 165)
                .scaleEffect(circleScale)
            Circle()
                .fill(color.opacity(0.09))
                .frame(width: 165, height: 165)
                .scaleEffect(circleScale)
            Text(phaseLabel)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(color)
                .opacity(labelOpacity)
        }
        .frame(height: 210)
        .task {
            if isFast {
                while true {
                    withAnimation(.easeInOut(duration: 0.38)) { circleScale = 0.95; glowScale = 0.95 }
                    try? await Task.sleep(nanoseconds: 380_000_000)
                    if Task.isCancelled { return }
                    withAnimation(.easeInOut(duration: 0.38)) { circleScale = 0.48; glowScale = 0.48 }
                    try? await Task.sleep(nanoseconds: 380_000_000)
                    if Task.isCancelled { return }
                }
            } else {
                let inDur: Double = 4.0
                let outDur: Double = 6.0
                while true {
                    phaseLabel = L10n.text(en: "breathe in", tr: "nefes al", es: "inhala")
                    withAnimation(.easeIn(duration: 0.4)) { labelOpacity = 1.0 }
                    withAnimation(.easeInOut(duration: inDur)) { circleScale = 1.0; glowScale = 1.0 }
                    try? await Task.sleep(nanoseconds: UInt64(inDur * 1_000_000_000))
                    if Task.isCancelled { return }
                    phaseLabel = L10n.text(en: "breathe out", tr: "nefes ver", es: "exhala")
                    withAnimation(.easeInOut(duration: outDur)) { circleScale = 0.48; glowScale = 0.48 }
                    try? await Task.sleep(nanoseconds: UInt64(outDur * 1_000_000_000))
                    if Task.isCancelled { return }
                }
            }
        }
    }
}

// MARK: - Qigong: concentric rings that breathe in offset phases

struct QigongOrb: View {
    var color: Color

    @State private var s1: CGFloat = 0.70
    @State private var s2: CGFloat = 0.85
    @State private var s3: CGFloat = 1.00
    @State private var o1: Double  = 0.55
    @State private var o2: Double  = 0.35
    @State private var o3: Double  = 0.18

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(o3), lineWidth: 1.0)
                .frame(width: 170, height: 170).scaleEffect(s3)
            Circle().stroke(color.opacity(o2), lineWidth: 1.3)
                .frame(width: 115, height: 115).scaleEffect(s2)
            Circle().fill(color.opacity(0.09))
                .frame(width: 65, height: 65).scaleEffect(s1)
            Circle().fill(color.opacity(0.30))
                .frame(width: 18, height: 18)
        }
        .frame(height: 210)
        .onAppear {
            let dur: Double = 4.5
            withAnimation(.easeInOut(duration: dur).repeatForever(autoreverses: true)) {
                s1 = 1.18; o1 = 0.28
            }
            withAnimation(.easeInOut(duration: dur).delay(0.7).repeatForever(autoreverses: true)) {
                s2 = 1.12; o2 = 0.50
            }
            withAnimation(.easeInOut(duration: dur).delay(1.4).repeatForever(autoreverses: true)) {
                s3 = 1.16; o3 = 0.22
            }
        }
    }
}

// MARK: - Main dispatch view

struct PracticeVisual: View {
    var path: EnergyPath
    var practiceId: String
    var showYouTubeLink: Bool = false

    private enum AnimKind { case reikiPulse, breathSlow, breathFast, qigongOrb }

    private var animKind: AnimKind {
        switch practiceId {
        case "breath.kapalabhati", "breath.bhastrika":
            return .breathFast
        case "breath.nadi", "breath.surya", "breath.coherent",
             "breath.ujjayi", "breath.bhramari", "reiki.breath":
            return .breathSlow
        default:
            switch path {
            case .reiki:      return .reikiPulse
            case .breathwork: return .breathSlow
            case .qigong:     return .qigongOrb
            }
        }
    }

    private var pathColor: Color {
        switch path {
        case .reiki:      return DS.accent
        case .breathwork: return Color(red: 0.50, green: 0.72, blue: 0.76)
        case .qigong:     return Color(red: 0.52, green: 0.72, blue: 0.50)
        }
    }

    private var youtubeURL: URL? {
        guard showYouTubeLink else { return nil }
        let map: [String: String] = [
            "qi.shake":          "qigong shaking practice beginner",
            "qi.sky":            "qigong lifting the sky exercise",
            "qi.gather":         "qigong gathering qi energy ball",
            "qi.spine":          "qigong spinal wave movement",
            "qi.stand":          "zhan zhuang standing meditation qigong",
            "qi.knock":          "qigong knock on door of life",
            "qi.crane":          "white crane spreads wings qigong",
            "breath.nadi":       "nadi shodhana alternate nostril breathing",
            "breath.kapalabhati":"kapalabhati pranayama skull shining breath",
            "breath.bhastrika":  "bhastrika pranayama bellows breath",
            "breath.surya":      "surya bhedana right nostril breathing pranayama",
            "breath.coherent":   "coherent breathing 5 seconds rhythm",
            "breath.ujjayi":     "ujjayi pranayama ocean breath yoga",
            "breath.bhramari":   "bhramari pranayama humming bee breath",
            "reiki.gassho":      "gassho reiki meditation morning ritual",
            "reiki.kenyoku":     "kenyoku ho dry bathing reiki cleansing",
            "reiki.hands":       "self reiki hand positions healing",
            "reiki.breath":      "joshin kokyu ho reiki breathing technique",
            "reiki.gokai":       "gokai five reiki principles morning",
            "reiki.byosen":      "byosen scanning reiki sensing energy",
            "reiki.shower":      "reiki shower visualization meditation",
        ]
        guard let q = map[practiceId],
              let enc = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.youtube.com/results?search_query=\(enc)") else {
            return nil
        }
        return url
    }

    var body: some View {
        VStack(spacing: DS.Space.md) {
            switch animKind {
            case .reikiPulse:  EnergyPulse(color: pathColor)
            case .breathSlow:  BreathingCircle(isFast: false, color: pathColor)
            case .breathFast:  BreathingCircle(isFast: true,  color: pathColor)
            case .qigongOrb:   QigongOrb(color: pathColor)
            }

            if let url = youtubeURL {
                Link(destination: url) {
                    HStack(spacing: 5) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 11))
                        Text(L10n.text(en: "Watch on YouTube", tr: "YouTube'da izle", es: "Ver en YouTube"))
                            .font(.caption)
                    }
                    .foregroundStyle(DS.textDim)
                    .padding(.vertical, 6)
                    .padding(.horizontal, DS.Space.sm)
                    .background(DS.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(DS.border, lineWidth: DS.hairline))
                }
            }
        }
    }
}
