import SwiftUI

// A calm, continuously-moving energy background. Soft drifting glows over
// the warm base, optionally tinted to the active path, with a faint
// radiant emblem behind. Pure SwiftUI, no assets. Designed to sit behind
// content at low intensity so text stays readable.

struct AuraBackground: View {
    var path: EnergyPath? = nil
    var intensity: Double = 1.0
    var showEmblem: Bool = true

    private var tints: [Color] {
        switch path {
        case .reiki:      return [DS.accentSoft, Color(red: 0.93, green: 0.66, blue: 0.55)]
        case .breathwork: return [Color(red: 0.62, green: 0.78, blue: 0.80), DS.accentSoft]
        case .qigong:     return [Color(red: 0.66, green: 0.78, blue: 0.62), DS.accentSoft]
        case .none:       return [DS.accentSoft, DS.accent]
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                DS.background

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    ZStack {
                        orb(color: tints[0], t: t, w: w, h: h, speed: 0.045, phase: 0.0, size: w * 1.1, yBias: 0.42)
                        orb(color: tints[1], t: t, w: w, h: h, speed: 0.037, phase: 2.1, size: w * 0.95, yBias: 0.66)
                        orb(color: tints[0].opacity(0.7), t: t, w: w, h: h, speed: 0.029, phase: 4.3, size: w * 0.8, yBias: 0.28)
                    }
                    .blur(radius: 60)
                    .opacity(0.5 * intensity)

                    if showEmblem {
                        EnergyEmblem()
                            .stroke(tints[0].opacity(0.10 * intensity), lineWidth: 1.2)
                            .frame(width: w * 0.7, height: w * 0.7)
                            .position(x: w * 0.5, y: h * 0.34)
                            .rotationEffect(.degrees((t * 2).truncatingRemainder(dividingBy: 360)))
                    }
                }
            }
            .ignoresSafeArea()
        }
    }

    private func orb(color: Color, t: Double, w: CGFloat, h: CGFloat, speed: Double, phase: Double, size: CGFloat, yBias: Double) -> some View {
        let x = 0.5 + 0.30 * sin(t * speed + phase)
        let y = yBias + 0.16 * cos(t * speed * 1.3 + phase)
        return Circle()
            .fill(RadialGradient(colors: [color.opacity(0.9), color.opacity(0.0)], center: .center, startRadius: 0, endRadius: size / 2))
            .frame(width: size, height: size)
            .position(x: CGFloat(x) * w, y: CGFloat(y) * h)
    }
}

// An original radiant emblem: concentric rings with evenly-spaced rays.
// Abstract energy motif — not a traditional sacred symbol.
struct EnergyEmblem: Shape {
    var progress: Double = 0

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let maxR = min(rect.width, rect.height) / 2

        // concentric rings
        for ring in 1...3 {
            let r = maxR * CGFloat(ring) / 3.0
            p.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
        }
        // rays
        let rays = 12
        for i in 0..<rays {
            let a = (Double(i) / Double(rays)) * 2 * .pi
            let inner = maxR * 0.32
            let outer = maxR * 0.98
            p.move(to: CGPoint(x: c.x + CGFloat(cos(a)) * inner, y: c.y + CGFloat(sin(a)) * inner))
            p.addLine(to: CGPoint(x: c.x + CGFloat(cos(a)) * outer, y: c.y + CGFloat(sin(a)) * outer))
        }
        return p
    }
}
