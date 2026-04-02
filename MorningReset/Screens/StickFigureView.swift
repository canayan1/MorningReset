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

    static let shoulderOpenA = StickFigurePose(
        leftArmAngle:  -1.30,
        rightArmAngle:  1.30
    )
    static let shoulderOpenB = StickFigurePose(
        leftArmAngle:  -1.50,
        rightArmAngle:  1.50
    )

    static let shoulderCrossA = StickFigurePose(
        leftArmAngle:  0.50,
        rightArmAngle: -0.50
    )
    static let shoulderCrossB = StickFigurePose(
        leftArmAngle:  0.55,
        rightArmAngle: -0.55
    )

    static let squat = StickFigurePose(
        torsoLean:     0.15,
        leftArmAngle: -0.30,
        rightArmAngle: 0.30,
        leftLegAngle: -0.55,
        rightLegAngle: 0.55,
        verticalOffset: 3
    )
}

// MARK: - PoseFamily

enum PoseFamily {
    case neutral
    case neckTiltRight, neckTiltLeft
    case shoulderOpen
    case shoulderCross
    case sideReachRight, sideReachLeft
    case forwardFold, halfLift
    case lungeRight, lungeLeft
    case plank
    case downwardDog
    case childPose
    case twistRight, twistLeft
    case calfRaise
    case march
    case squat
    case stillness

    var from: StickFigurePose {
        switch self {
        case .neutral:        return .neutral
        case .neckTiltRight:  return .neckTiltRight
        case .neckTiltLeft:   return .neckTiltLeft
        case .shoulderOpen:   return .shoulderOpenA
        case .shoulderCross:  return .shoulderCrossA
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
        case .squat:          return .squat
        case .stillness:      return .neutral
        }
    }

    var to: StickFigurePose {
        switch self {
        case .calfRaise:     return .calfRaiseUp
        case .march:         return .marchB
        case .shoulderOpen:  return .shoulderOpenB
        case .shoulderCross: return .shoulderCrossB
        default:             return from.breathing
        }
    }

    var duration: Double {
        switch self {
        case .march:                          return 1.4
        case .calfRaise:                      return 1.6
        case .shoulderOpen:                   return 2.5
        case .sideReachRight, .sideReachLeft: return 3.0
        case .twistRight, .twistLeft:         return 3.5
        default:                              return 4.0
        }
    }
}

// MARK: - Animation name → PoseFamily

extension PoseFamily {
    static func resolve(_ name: String) -> PoseFamily {
        switch name {
        // Neck
        case "neck_release_right", "neck_release_right_short",
             "side_neck_right", "neck_stretch_right",
             "ear_shoulder_right", "neck_turns", "neck_nods":
            return .neckTiltRight
        case "neck_release_left", "neck_release_left_short",
             "side_neck_left", "neck_stretch_left", "ear_shoulder_left":
            return .neckTiltLeft

        // Shoulder open
        case "shoulder_opener_clasp", "chest_opener_hold", "chest_open",
             "shoulder_opener", "arm_circles", "shoulder_rolls",
             "shoulder_roll_forward", "shoulder_roll_back", "shoulder_circles",
             "shake_arms", "shake_out", "reach_up", "inhale_reach",
             "rise_reach", "stand_reach", "reach_high", "arm_reach",
             "arm_reach_up", "rise_open_chest", "arm_sweep",
             "gentle_backbend", "posture_reset":
            return .shoulderOpen

        // Shoulder cross
        case "shoulder_fold", "shoulder_cross_right", "shoulder_cross_left":
            return .shoulderCross

        // Forward fold
        case "forward_fold_hold", "forward_fold", "fold", "fold_down",
             "seated_forward_fold", "seated_fold_hold", "fold_sway",
             "walk_to_top", "walk_forward", "walk_in":
            return .forwardFold

        // Half lift
        case "half_lift", "half_fold":
            return .halfLift

        // Side reach
        case "side_reach_right", "side_bend_right":
            return .sideReachRight
        case "side_reach_left", "side_bend_left":
            return .sideReachLeft

        // Lunge — right
        case "low_lunge_right", "low_lunge_right_hold",
             "hip_opener_right", "hip_opener_right_hold",
             "lunge_right", "runner_lunge_right", "step_back_right",
             "high_lunge_right", "side_lunge_right", "quad_stretch_right":
            return .lungeRight

        // Lunge — left
        case "low_lunge_left", "low_lunge_left_hold",
             "hip_opener_left", "hip_opener_left_hold",
             "lunge_left", "runner_lunge_left", "step_back_left",
             "high_lunge_left", "side_lunge_left", "quad_stretch_left":
            return .lungeLeft

        // Plank
        case "plank", "plank_option", "plank_tap", "plank_shoulder_tap":
            return .plank

        // Downward dog
        case "down_dog_soft", "downward_dog", "plank_to_dog":
            return .downwardDog

        // Child pose
        case "child_pose":
            return .childPose

        // Supine rest
        case "supine_twist", "torso_twist", "standing_twist",
             "standing_twist_right", "twist_right":
            return .twistRight
        case "standing_twist_left", "twist_left":
            return .twistLeft

        // Floor rest
        case "resting_knees_bent":
            return .stillness

        // March / knee
        case "march_in_place", "knee_hug_right", "knee_hug_left",
             "knee_chest_right", "knee_chest_left":
            return .march

        // Squat
        case "supported_squat", "chair_pose_light":
            return .squat

        // Calf / heel
        case "calf_raises", "heel_raises", "calf_raise":
            return .calfRaise

        // Neutral rise
        case "rise_up", "roll_up", "roll_up_slow", "stand_tall":
            return .neutral

        // Stillness
        case "stand_breathe", "long_exhale", "stillness", "pause":
            return .stillness

        default:
            return .stillness
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
