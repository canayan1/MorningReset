import SwiftUI

// MARK: - Energy tree
//
// The tree is the session; the orb is the life. It opens as a seedling and
// grows for exactly as long as the practice runs, so a five-minute sit has
// something to watch that is neither a countdown nor a spinner. When the
// practice ends the tree is full, and that growth is what feeds the orb.
//
// Drawn rather than animated frame by frame: `progress` is the single input, so
// the shape is correct at any moment, including after a pause or a scrub.

/// Maps elapsed practice onto growth.
///
/// A raw fraction is wrong twice over: at one percent there is nothing on
/// screen but a stub, and the last minutes add almost nothing. So the tree
/// opens as a sapling that already has a shape, and the early minutes carry
/// more visible change than the late ones — which is also how growth looks.
func treeGrowth(_ progress: Double) -> Double {
    let p = max(0, min(1, progress))
    return 0.30 + 0.70 * pow(p, 0.62)
}

struct EnergyTree: Shape {
    /// 0 = seedling, 1 = full grown.
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p = treeGrowth(progress)
        let base = CGPoint(x: rect.midX, y: rect.maxY)
        let trunkHeight = rect.height * 0.60 * p
        let trunkTop = CGPoint(x: base.x, y: base.y - trunkHeight)

        path.move(to: base)
        path.addLine(to: trunkTop)

        // Branches unfurl in pairs as the practice goes on: the first at a
        // fifth of the way through, the last near the end.
        let pairs = 4
        for i in 0..<pairs {
            let start = 0.2 + Double(i) * 0.18
            guard p > start else { break }
            let local = min(1, (p - start) / 0.34)
            let along = 0.42 + Double(i) * 0.17
            let origin = CGPoint(x: base.x, y: base.y - trunkHeight * along)
            let spread = rect.width * 0.34 * local * (1 - Double(i) * 0.13)
            let lift = rect.height * 0.17 * local

            for side in [-1.0, 1.0] {
                let end = CGPoint(x: origin.x + spread * side, y: origin.y - lift)
                let control = CGPoint(x: origin.x + spread * 0.35 * side,
                                      y: origin.y - lift * 1.25)
                path.move(to: origin)
                path.addQuadCurve(to: end, control: control)
            }
        }
        return path
    }
}

/// Leaves appear at the branch ends once a branch has finished opening.
struct EnergyTreeLeaves: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p = treeGrowth(progress)
        let base = CGPoint(x: rect.midX, y: rect.maxY)
        let trunkHeight = rect.height * 0.60 * p

        for i in 0..<4 {
            let start = 0.2 + Double(i) * 0.18
            guard p > start + 0.22 else { continue }
            let grown = min(1, (p - start - 0.22) / 0.3)
            let local = min(1, (p - start) / 0.34)
            let along = 0.42 + Double(i) * 0.17
            let origin = CGPoint(x: base.x, y: base.y - trunkHeight * along)
            let spread = rect.width * 0.34 * local * (1 - Double(i) * 0.13)
            let lift = rect.height * 0.17 * local
            let r = rect.width * 0.045 * grown

            for side in [-1.0, 1.0] {
                let c = CGPoint(x: origin.x + spread * side, y: origin.y - lift)
                path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
            }
        }
        return path
    }
}

/// The tree plus its glow, sized for the routine player.
struct EnergyTreeView: View {
    let progress: Double
    var tint: Color = DS.accent
    var size: CGFloat = 210

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.10 + 0.10 * progress))
                .frame(width: size * 1.15, height: size * 1.15)
                .blur(radius: 26)

            EnergyTree(progress: progress)
                .stroke(tint.opacity(0.85),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)

            EnergyTreeLeaves(progress: progress)
                .fill(tint.opacity(0.55))
                .frame(width: size, height: size)
        }
        .frame(width: size * 1.15, height: size * 1.15)
        .animation(.easeInOut(duration: 0.9), value: progress)
        .accessibilityHidden(true)
    }
}
