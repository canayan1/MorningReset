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

    func lerp(to other: StickFigurePose, t: CGFloat) -> StickFigurePose {
        func mix(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * t }
        return StickFigurePose(
            headTilt:       mix(headTilt,       other.headTilt),
            torsoLean:      mix(torsoLean,      other.torsoLean),
            leftArmAngle:   mix(leftArmAngle,   other.leftArmAngle),
            rightArmAngle:  mix(rightArmAngle,  other.rightArmAngle),
            leftLegAngle:   mix(leftLegAngle,   other.leftLegAngle),
            rightLegAngle:  mix(rightLegAngle,  other.rightLegAngle),
            verticalOffset: mix(verticalOffset, other.verticalOffset)
        )
    }

    var breathing: StickFigurePose {
        var p = self
        p.leftArmAngle  -= 0.05
        p.rightArmAngle += 0.05
        p.verticalOffset -= 2
        return p
    }
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

// MARK: - Named pose presets

extension StickFigurePose {
    static let neckTiltRight = StickFigurePose(headTilt:  0.40)
    static let neckTiltLeft  = StickFigurePose(headTilt: -0.40)

    static let sideReachRight = StickFigurePose(
        torsoLean:     -0.12,
        leftArmAngle:  -0.35,
        rightArmAngle:  2.85
    )
    static let sideReachLeft = StickFigurePose(
        torsoLean:     0.12,
        leftArmAngle: -2.85,
        rightArmAngle: 0.35
    )

    static let forwardFold = StickFigurePose(
        torsoLean:     1.30,
        leftArmAngle:  0.05,
        rightArmAngle: -0.05
    )
    static let halfLift = StickFigurePose(
        torsoLean:     0.75,
        leftArmAngle:  0.30,
        rightArmAngle: -0.30
    )

    static let lungeRight = StickFigurePose(
        torsoLean:     0.18,
        leftArmAngle: -0.50,
        rightArmAngle: 0.20,
        leftLegAngle: -0.30,
        rightLegAngle: 0.65
    )
    static let lungeLeft = StickFigurePose(
        torsoLean:    -0.18,
        leftArmAngle: -0.20,
        rightArmAngle: 0.50,
        leftLegAngle: -0.65,
        rightLegAngle: 0.30
    )

    static let plank = StickFigurePose(
        torsoLean:     1.50,
        leftArmAngle: -0.30,
        rightArmAngle: 0.30,
        leftLegAngle: -0.05,
        rightLegAngle: 0.05
    )
    static let downwardDog = StickFigurePose(
        torsoLean:     1.15,
        leftArmAngle:  1.00,
        rightArmAngle: 1.00,
        leftLegAngle: -0.22,
        rightLegAngle: 0.22
    )
    static let childPose = StickFigurePose(
        torsoLean:     1.45,
        leftArmAngle:  1.20,
        rightArmAngle: 1.20,
        leftLegAngle: -0.08,
        rightLegAngle: 0.08
    )

    static let twistRight = StickFigurePose(
        torsoLean:     0.12,
        leftArmAngle:  0.75,
        rightArmAngle: -0.30
    )
    static let twistLeft = StickFigurePose(
        torsoLean:    -0.12,
        leftArmAngle:  0.30,
        rightArmAngle: -0.75
    )

    static let calfRaiseDown = StickFigurePose()
    static let calfRaiseUp   = StickFigurePose(verticalOffset: -5)

    static let marchA = StickFigurePose(
        leftArmAngle:  -0.65,
        rightArmAngle:  0.20,
        leftLegAngle:  -0.60,
        rightLegAngle:  0.18
    )
    static let marchB = StickFigurePose(
        leftArmAngle:  -0.20,
        rightArmAngle:  0.65,
        leftLegAngle:  -0.18,
        rightLegAngle:  0.60
    )
}

// MARK: - PoseFamily

enum PoseFamily {
    case neutral
    case neckTiltRight, neckTiltLeft
    case sideReachRight, sideReachLeft
    case forwardFold, halfLift
    case lungeRight, lungeLeft
    case plank
    case downwardDog
    case childPose
    case twistRight, twistLeft
    case calfRaise
    case march
    case stillness

    var from: StickFigurePose {
        switch self {
        case .neutral:        return .neutral
        case .neckTiltRight:  return .neckTiltRight
        case .neckTiltLeft:   return .neckTiltLeft
        case .sideReachRight: return .sideReachRight
        case .sideReachLeft:  return .sideReachLeft
        case .forwardFold:    return .forwardFold
        case .halfLift:       return .halfLift
        case .lungeRight:     return .lungeRight
        case .lungeLeft:      return .lungeLeft
        case .plank:          return .plank
        case .downwardDog:    return .downwardDog
        case .childPose:      return .childPose
        case .twistRight:     return .twistRight
        case .twistLeft:      return .twistLeft
        case .calfRaise:      return .calfRaiseDown
        case .march:          return .marchA
        case .stillness:      return .neutral
        }
    }

    var to: StickFigurePose {
        switch self {
        case .calfRaise: return .calfRaiseUp
        case .march:     return .marchB
        default:         return from.breathing
        }
    }

    var duration: Double {
        switch self {
        case .march:                          return 1.4
        case .calfRaise:                      return 1.6
        case .sideReachRight, .sideReachLeft: return 3.0
        case .twistRight, .twistLeft:         return 3.5
        default:                              return 4.0
        }
    }
}

// MARK: - AnimatedStickFigureView

struct AnimatedStickFigureView: View {
    let from: StickFigurePose
    let to: StickFigurePose
    var duration: Double
    var isAnimating: Bool
    var color: Color

    init(
        from: StickFigurePose = .neutral,
        to: StickFigurePose? = nil,
        duration: Double = 3.0,
        isAnimating: Bool = true,
        color: Color = .primary
    ) {
        self.from        = from
        self.to          = to ?? from.breathing
        self.duration    = duration
        self.isAnimating = isAnimating
        self.color       = color
    }

    var body: some View {
        if isAnimating {
            TimelineView(.animation) { timeline in
                StickFigureView(
                    pose: from.lerp(to: to, t: Self.phase(for: timeline.date, duration: duration)),
                    color: color
                )
            }
        } else {
            StickFigureView(pose: from, color: color)
        }
    }

    private static func phase(for date: Date, duration: Double) -> CGFloat {
        let t = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
        return CGFloat((sin(t * 2 * .pi - .pi / 2) + 1) / 2)
    }
}

#Preview("neutral") {
    let f = PoseFamily.neutral
    return AnimatedStickFigureView(from: f.from, to: f.to, duration: f.duration)
        .frame(width: 140, height: 140).padding().background(Color(.systemBackground))
}

#Preview("forwardFold") {
    let f = PoseFamily.forwardFold
    return AnimatedStickFigureView(from: f.from, to: f.to, duration: f.duration)
        .frame(width: 140, height: 140).padding().background(Color(.systemBackground))
}

#Preview("sideReachRight") {
    let f = PoseFamily.sideReachRight
    return AnimatedStickFigureView(from: f.from, to: f.to, duration: f.duration)
        .frame(width: 140, height: 140).padding().background(Color(.systemBackground))
}

#Preview("march") {
    let f = PoseFamily.march
    return AnimatedStickFigureView(from: f.from, to: f.to, duration: f.duration)
        .frame(width: 140, height: 140).padding().background(Color(.systemBackground))
}
