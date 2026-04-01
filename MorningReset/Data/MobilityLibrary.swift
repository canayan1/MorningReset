import Foundation

enum MobilityLibrary {

    static func flow(for date: Date = Date()) -> MobilityFlow {
        let month = Calendar.current.component(.month, from: date)
        return all.first { $0.month == month } ?? all[0]
    }

    static let all: [MobilityFlow] = [
        january, february, march, april, may, june,
        july, august, september, october, november, december
    ]

    // MARK: - Yin (Jan, Feb, Nov, Dec) — 7 moves × 45s = ~5:15

    private static let january = MobilityFlow(
        id: UUID(), month: 1,
        title: "Ground & Hold",
        subtitle: "Slow the body down before the day begins.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Neck release (right)",            duration: 45, animationName: "neck_release_right"),
            MobilityMove(id: UUID(), name: "Neck release (left)",             duration: 45, animationName: "neck_release_left"),
            MobilityMove(id: UUID(), name: "Shoulder opener (clasped hands)", duration: 45, animationName: "shoulder_opener_clasp"),
            MobilityMove(id: UUID(), name: "Forward fold (soft knees)",       duration: 45, animationName: "forward_fold_hold"),
            MobilityMove(id: UUID(), name: "Figure-four stretch (right)",     duration: 45, animationName: "figure_four_right"),
            MobilityMove(id: UUID(), name: "Figure-four stretch (left)",      duration: 45, animationName: "figure_four_left"),
            MobilityMove(id: UUID(), name: "Child's pose",                    duration: 45, animationName: "child_pose"),
        ]
    )

    private static let february = MobilityFlow(
        id: UUID(), month: 2,
        title: "Open & Settle",
        subtitle: "Release tension held overnight.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Side neck stretch (right)",       duration: 45, animationName: "side_neck_right"),
            MobilityMove(id: UUID(), name: "Side neck stretch (left)",        duration: 45, animationName: "side_neck_left"),
            MobilityMove(id: UUID(), name: "Chest opener (doorway-style)",    duration: 45, animationName: "chest_opener_hold"),
            MobilityMove(id: UUID(), name: "Seated forward fold",             duration: 45, animationName: "seated_forward_fold"),
            MobilityMove(id: UUID(), name: "Hip opener (right, low lunge)",   duration: 45, animationName: "low_lunge_right_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (left, low lunge)",    duration: 45, animationName: "low_lunge_left_hold"),
            MobilityMove(id: UUID(), name: "Supine twist (both sides)",       duration: 45, animationName: "supine_twist"),
        ]
    )

    private static let november = MobilityFlow(
        id: UUID(), month: 11,
        title: "Slow Down",
        subtitle: "Meet the colder mornings with ease.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Neck stretch (right)",            duration: 45, animationName: "neck_stretch_right"),
            MobilityMove(id: UUID(), name: "Neck stretch (left)",             duration: 45, animationName: "neck_stretch_left"),
            MobilityMove(id: UUID(), name: "Shoulder fold (arm across)",      duration: 45, animationName: "shoulder_fold"),
            MobilityMove(id: UUID(), name: "Forward fold hold",               duration: 45, animationName: "forward_fold_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (right, low lunge)",   duration: 45, animationName: "hip_opener_right_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (left, low lunge)",    duration: 45, animationName: "hip_opener_left_hold"),
            MobilityMove(id: UUID(), name: "Child's pose",                    duration: 45, animationName: "child_pose"),
        ]
    )

    private static let december = MobilityFlow(
        id: UUID(), month: 12,
        title: "Still & Warm",
        subtitle: "Hold space before the day takes over.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Ear-to-shoulder (right)",         duration: 45, animationName: "ear_shoulder_right"),
            MobilityMove(id: UUID(), name: "Ear-to-shoulder (left)",          duration: 45, animationName: "ear_shoulder_left"),
            MobilityMove(id: UUID(), name: "Chest opener hold",               duration: 45, animationName: "chest_opener_hold"),
            MobilityMove(id: UUID(), name: "Seated fold",                     duration: 45, animationName: "seated_fold_hold"),
            MobilityMove(id: UUID(), name: "Figure-four (right)",             duration: 45, animationName: "figure_four_right"),
            MobilityMove(id: UUID(), name: "Figure-four (left)",              duration: 45, animationName: "figure_four_left"),
            MobilityMove(id: UUID(), name: "Resting pose (knees bent)",       duration: 45, animationName: "resting_knees_bent"),
        ]
    )

    // MARK: - Vinyasa (Mar–Oct) — 15 moves × 20s = 5:00

    private static let march = MobilityFlow(
        id: UUID(), month: 3,
        title: "Wake Up",
        subtitle: "Light movement to build momentum.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand tall, slow breath",         duration: 20, animationName: "stand_breathe"),
            MobilityMove(id: UUID(), name: "Arm circles",                     duration: 20, animationName: "arm_circles"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step-back lunge (right)",         duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Step-back lunge (left)",          duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog (soft)",                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise up, reach",                  duration: 20, animationName: "rise_reach"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let april = MobilityFlow(
        id: UUID(), month: 4,
        title: "Rise & Flow",
        subtitle: "Build warmth before the day takes shape.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "March in place",                  duration: 20, animationName: "march_in_place"),
            MobilityMove(id: UUID(), name: "Arm sweep",                       duration: 20, animationName: "arm_sweep"),
            MobilityMove(id: UUID(), name: "Chest opener",                    duration: 20, animationName: "chest_open"),
            MobilityMove(id: UUID(), name: "Neck check (gentle nods)",        duration: 20, animationName: "neck_nods"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Runner lunge (right)",            duration: 20, animationName: "runner_lunge_right"),
            MobilityMove(id: UUID(), name: "Runner lunge (left)",             duration: 20, animationName: "runner_lunge_left"),
            MobilityMove(id: UUID(), name: "Low squat (supported)",           duration: 20, animationName: "supported_squat"),
            MobilityMove(id: UUID(), name: "Fold + sway",                     duration: 20, animationName: "fold_sway"),
            MobilityMove(id: UUID(), name: "Rise up",                         duration: 20, animationName: "rise_up"),
            MobilityMove(id: UUID(), name: "Side bend (right)",               duration: 20, animationName: "side_bend_right"),
            MobilityMove(id: UUID(), name: "Side bend (left)",                duration: 20, animationName: "side_bend_left"),
            MobilityMove(id: UUID(), name: "Shake out arms",                  duration: 20, animationName: "shake_arms"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let may = MobilityFlow(
        id: UUID(), month: 5,
        title: "Build Momentum",
        subtitle: "Short and deliberate — enough to shift the state.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand + inhale reach",            duration: 20, animationName: "inhale_reach"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step to plank (knees optional)",  duration: 20, animationName: "plank_option"),
            MobilityMove(id: UUID(), name: "Down dog (soft knees)",           duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Chair pose (light)",              duration: 20, animationName: "chair_pose_light"),
            MobilityMove(id: UUID(), name: "Fold",                            duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Calf raises",                     duration: 20, animationName: "calf_raises"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (right)",        duration: 20, animationName: "shoulder_cross_right"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (left)",         duration: 20, animationName: "shoulder_cross_left"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let june = MobilityFlow(
        id: UUID(), month: 6,
        title: "Open Up",
        subtitle: "Use the longer days — start with space.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Breath + posture reset",          duration: 20, animationName: "posture_reset"),
            MobilityMove(id: UUID(), name: "Neck release (right)",            duration: 20, animationName: "neck_release_right_short"),
            MobilityMove(id: UUID(), name: "Neck release (left)",             duration: 20, animationName: "neck_release_left_short"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step-back (right)",               duration: 20, animationName: "step_back_right"),
            MobilityMove(id: UUID(), name: "Step-back (left)",                duration: 20, animationName: "step_back_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise + open chest",               duration: 20, animationName: "rise_open_chest"),
            MobilityMove(id: UUID(), name: "Gentle backbend (hands to hips)", duration: 20, animationName: "gentle_backbend"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let july = MobilityFlow(
        id: UUID(), month: 7,
        title: "Move & Breathe",
        subtitle: "Warm mornings, deliberate movement.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "March in place",                  duration: 20, animationName: "march_in_place"),
            MobilityMove(id: UUID(), name: "Reach up",                        duration: 20, animationName: "reach_up"),
            MobilityMove(id: UUID(), name: "Side bend (right)",               duration: 20, animationName: "side_bend_right"),
            MobilityMove(id: UUID(), name: "Side bend (left)",                duration: 20, animationName: "side_bend_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Knee-to-chest (right, standing)", duration: 20, animationName: "knee_hug_right"),
            MobilityMove(id: UUID(), name: "Knee-to-chest (left, standing)",  duration: 20, animationName: "knee_hug_left"),
            MobilityMove(id: UUID(), name: "Quad stretch (right)",            duration: 20, animationName: "quad_stretch_right"),
            MobilityMove(id: UUID(), name: "Quad stretch (left)",             duration: 20, animationName: "quad_stretch_left"),
            MobilityMove(id: UUID(), name: "Shake out",                       duration: 20, animationName: "shake_out"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let august = MobilityFlow(
        id: UUID(), month: 8,
        title: "Stay Loose",
        subtitle: "Keep the body moving before momentum fades.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand + long exhale",             duration: 20, animationName: "long_exhale"),
            MobilityMove(id: UUID(), name: "Shoulder opener",                 duration: 20, animationName: "shoulder_opener"),
            MobilityMove(id: UUID(), name: "Chest opener",                    duration: 20, animationName: "chest_open"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Fold",                            duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Side lunge (right)",              duration: 20, animationName: "side_lunge_right"),
            MobilityMove(id: UUID(), name: "Side lunge (left)",               duration: 20, animationName: "side_lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk forward",                    duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise up",                         duration: 20, animationName: "rise_up"),
            MobilityMove(id: UUID(), name: "Heel raises",                     duration: 20, animationName: "heel_raises"),
            MobilityMove(id: UUID(), name: "Shake arms",                      duration: 20, animationName: "shake_arms"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )

    private static let september = MobilityFlow(
        id: UUID(), month: 9,
        title: "Find Center",
        subtitle: "Transition season — steady the body.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Posture reset",                   duration: 20, animationName: "posture_reset"),
            MobilityMove(id: UUID(), name: "Arm circles",                     duration: 20, animationName: "arm_circles"),
            MobilityMove(id: UUID(), name: "Forward fold",                    duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Chair pose (light)",              duration: 20, animationName: "chair_pose_light"),
            MobilityMove(id: UUID(), name: "Fold",                            duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Reach up",                        duration: 20, animationName: "reach_up"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (right)",        duration: 20, animationName: "shoulder_cross_right"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (left)",         duration: 20, animationName: "shoulder_cross_left"),
        ]
    )

    private static let october = MobilityFlow(
        id: UUID(), month: 10,
        title: "Wind Down & Ground",
        subtitle: "Shorter days — ground the body before cooling starts.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Long exhale",                     duration: 20, animationName: "long_exhale"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Fold",                            duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Supported squat",                 duration: 20, animationName: "supported_squat"),
            MobilityMove(id: UUID(), name: "Fold + sway",                     duration: 20, animationName: "fold_sway"),
            MobilityMove(id: UUID(), name: "Rise + chest open",               duration: 20, animationName: "rise_open_chest"),
            MobilityMove(id: UUID(), name: "Calf raises",                     duration: 20, animationName: "calf_raises"),
            MobilityMove(id: UUID(), name: "Neck check (gentle turns)",       duration: 20, animationName: "neck_turns"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Shake out",                       duration: 20, animationName: "shake_out"),
            MobilityMove(id: UUID(), name: "Stillness",                       duration: 20, animationName: "stillness"),
        ]
    )
}
