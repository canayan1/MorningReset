import SwiftUI

// All angles are in radians, measured from straight-down.
// sin(angle) * length → x offset, cos(angle) * length → y offset (downward).
// Positive angle = clockwise (right). Negative = counterclockwise (left).

struct StickFigurePose {
    var headTilt: CGFloat = 0          // positive = tilt right
    var torsoLean: CGFloat = 0         // positive = lean right
    var leftArmAngle: CGFloat = -0.35  // negative = outward left
    var rightArmAngle: CGFloat = 0.35  // positive = outward right
    var leftLegAngle: CGFloat = -0.18  // negative = outward left
    var rightLegAngle: CGFloat = 0.18  // positive = outward right
    var verticalOffset: CGFloat = 0    // positive = shift figure down

    static let neutral = StickFigurePose()
}

struct StickFigureView: View {
    let pose: StickFigurePose
    let color: Color

    init(pose: StickFigurePose = .neutral, color: Color = .primary) {
        self.pose = pose
        self.color = color
    }

    var body: some View {
        Canvas { ctx, size in
            draw(&ctx, size)
        }
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let h  = size.height
        let cx = size.width / 2

        let headR  = h * 0.10
        let neckL  = h * 0.05
        let torsoL = h * 0.25
        let armL   = h * 0.21
        let legL   = h * 0.34
        let lw     = max(1.8, h * 0.014)

        let ss = StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round)

        // Hip anchors so feet land at ~90% of height
        let hipX = cx
        let hipY = h * 0.90 - legL + pose.verticalOffset

        // Shoulder — torso extends upward from hip
        let shoulderX = hipX + sin(pose.torsoLean) * torsoL
        let shoulderY = hipY - cos(pose.torsoLean) * torsoL

        // Neck and head follow torso lean + head tilt
        let headAngle = pose.torsoLean + pose.headTilt
        let neckDX = sin(headAngle)
        let neckDY = -cos(headAngle)

        let neckTopX = shoulderX + neckDX * neckL
        let neckTopY = shoulderY + neckDY * neckL
        let headCX   = neckTopX + neckDX * headR
        let headCY   = neckTopY + neckDY * headR

        let hip      = CGPoint(x: hipX,      y: hipY)
        let shoulder = CGPoint(x: shoulderX, y: shoulderY)
        let neckTop  = CGPoint(x: neckTopX,  y: neckTopY)

        // All straight segments in one path
        var body = Path()

        body.move(to: hip)
        body.addLine(to: CGPoint(x: hipX + sin(pose.leftLegAngle)  * legL,
                                  y: hipY + cos(pose.leftLegAngle)  * legL))
        body.move(to: hip)
        body.addLine(to: CGPoint(x: hipX + sin(pose.rightLegAngle) * legL,
                                  y: hipY + cos(pose.rightLegAngle) * legL))
        body.move(to: hip)
        body.addLine(to: shoulder)

        body.move(to: shoulder)
        body.addLine(to: CGPoint(x: shoulderX + sin(pose.leftArmAngle)  * armL,
                                  y: shoulderY + cos(pose.leftArmAngle)  * armL))
        body.move(to: shoulder)
        body.addLine(to: CGPoint(x: shoulderX + sin(pose.rightArmAngle) * armL,
                                  y: shoulderY + cos(pose.rightArmAngle) * armL))
        body.move(to: shoulder)
        body.addLine(to: neckTop)

        ctx.stroke(body, with: .color(color), style: ss)

        // Head as separate ellipse
        var head = Path()
        head.addEllipse(in: CGRect(x: headCX - headR, y: headCY - headR,
                                   width: headR * 2,  height: headR * 2))
        ctx.stroke(head, with: .color(color), style: ss)
    }
}

#Preview {
    StickFigureView(pose: .neutral, color: .primary)
        .frame(width: 140, height: 140)
        .padding()
        .background(Color(.systemBackground))
}
