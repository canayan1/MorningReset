import SwiftUI

// MARK: - The energy orb
//
// One orb per person. Every completed routine feeds it: it grows a little and
// glows a little brighter. This is the app's central progress metaphor —
// experiential, never a health measurement.

enum EnergyOrb {
    /// Every routine you finish, in any school.
    static var totalSessions: Int { PracticeLogStore.completedCount() }

    static let perLevel = 5

    static func level(_ total: Int) -> Int { total / perLevel + 1 }

    /// 0…1 progress toward the next level.
    static func progress(_ total: Int) -> Double {
        Double(total % perLevel) / Double(perLevel)
    }

    /// Visual scale, easing off so it never overwhelms the screen.
    static func scale(_ level: Int) -> CGFloat {
        0.78 + min(0.42, CGFloat(level - 1) * 0.035)
    }

    /// Glow strength, 0…1.
    static func glow(_ level: Int) -> Double {
        min(1.0, 0.32 + Double(level - 1) * 0.05)
    }

    static func title(_ level: Int) -> String {
        switch level {
        case 1:      return "A first spark"
        case 2...3:  return "Steadying"
        case 4...6:  return "Warming"
        case 7...10: return "Bright"
        case 11...15: return "Radiant"
        default:     return "Luminous"
        }
    }
}

struct EnergyOrbView: View {
    var total: Int
    var tint: Color = DS.accent
    var size: CGFloat = 190
    /// Set true briefly after a session to play the "it grew" flourish.
    var celebrate: Bool = false

    @State private var breathe = false
    @State private var burst: CGFloat = 0

    private var level: Int { EnergyOrb.level(total) }
    private var glow: Double { EnergyOrb.glow(level) }
    private var scale: CGFloat { EnergyOrb.scale(level) }

    var body: some View {
        ZStack {
            // Outer halo
            Circle()
                .fill(RadialGradient(colors: [tint.opacity(glow * 0.55), tint.opacity(0)],
                                     center: .center, startRadius: 0, endRadius: size * 0.62))
                .frame(width: size * 1.25, height: size * 1.25)
                .scaleEffect(breathe ? 1.06 : 0.94)
                .blur(radius: 12)

            // Body
            Circle()
                .fill(RadialGradient(colors: [Color.white.opacity(0.85),
                                              tint.opacity(0.85),
                                              tint.opacity(0.35)],
                                     center: UnitPoint(x: 0.38, y: 0.34),
                                     startRadius: 2, endRadius: size * 0.55))
                .frame(width: size * scale, height: size * scale)
                .shadow(color: tint.opacity(glow), radius: 26)
                .scaleEffect(breathe ? 1.03 : 0.97)

            // Progress ring toward the next level
            Circle()
                .trim(from: 0, to: EnergyOrb.progress(total))
                .stroke(tint.opacity(0.75), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: size * 1.02, height: size * 1.02)
                .rotationEffect(.degrees(-90))

            // Celebration burst
            if celebrate {
                Circle()
                    .stroke(tint.opacity(0.55), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(1 + burst)
                    .opacity(1 - Double(burst))
            }
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathe)
        .onAppear {
            breathe = true
            if celebrate {
                withAnimation(.easeOut(duration: 1.1)) { burst = 0.7 }
            }
        }
        .accessibilityLabel("Your energy orb, level \(level)")
    }
}

/// Orb + its level caption, used on the home screen and after a session.
struct EnergyOrbBadge: View {
    var total: Int
    var tint: Color = DS.accent
    var size: CGFloat = 190
    var celebrate: Bool = false

    var body: some View {
        VStack(spacing: DS.Space.sm) {
            EnergyOrbView(total: total, tint: tint, size: size, celebrate: celebrate)
            Text(EnergyOrb.title(EnergyOrb.level(total)).uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(1.8)
                .foregroundStyle(tint)
            Text("\(total) \(total == 1 ? "practice" : "practices")")
                .font(.caption).foregroundStyle(DS.textDim)
        }
    }
}
