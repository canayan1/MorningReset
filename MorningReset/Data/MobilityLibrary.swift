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

    // MARK: - Yin (Nov, Dec, Jan, Feb) — 45s holds, ~7 moves, ~5 min

    private static let january = MobilityFlow(
        id: UUID(),
        month: 1,
        title: "Ground & Hold",
        subtitle: "Slow the body down before the day begins.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Child's Pose", duration: 45, animationName: "childs_pose"),
            MobilityMove(id: UUID(), name: "Supine Twist Left", duration: 45, animationName: "supine_twist_left"),
            MobilityMove(id: UUID(), name: "Supine Twist Right", duration: 45, animationName: "supine_twist_right"),
            MobilityMove(id: UUID(), name: "Seated Forward Fold", duration: 45, animationName: "seated_forward_fold"),
            MobilityMove(id: UUID(), name: "Butterfly Hold", duration: 45, animationName: "butterfly"),
            MobilityMove(id: UUID(), name: "Legs Up the Wall", duration: 45, animationName: "legs_up_wall"),
            MobilityMove(id: UUID(), name: "Savasana", duration: 45, animationName: "savasana"),
        ]
    )

    private static let february = MobilityFlow(
        id: UUID(),
        month: 2,
        title: "Open & Settle",
        subtitle: "Release tension held overnight.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Supported Fish", duration: 45, animationName: "supported_fish"),
            MobilityMove(id: UUID(), name: "Dragonfly Left", duration: 45, animationName: "dragonfly_left"),
            MobilityMove(id: UUID(), name: "Dragonfly Right", duration: 45, animationName: "dragonfly_right"),
            MobilityMove(id: UUID(), name: "Sleeping Swan Left", duration: 45, animationName: "sleeping_swan_left"),
            MobilityMove(id: UUID(), name: "Sleeping Swan Right", duration: 45, animationName: "sleeping_swan_right"),
            MobilityMove(id: UUID(), name: "Melting Heart", duration: 45, animationName: "melting_heart"),
            MobilityMove(id: UUID(), name: "Constructive Rest", duration: 45, animationName: "constructive_rest"),
        ]
    )

    private static let november = MobilityFlow(
        id: UUID(),
        month: 11,
        title: "Slow Down",
        subtitle: "Meet the colder mornings with ease.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Reclined Bound Angle", duration: 45, animationName: "reclined_bound_angle"),
            MobilityMove(id: UUID(), name: "Caterpillar", duration: 45, animationName: "caterpillar"),
            MobilityMove(id: UUID(), name: "Sphinx Hold", duration: 45, animationName: "sphinx"),
            MobilityMove(id: UUID(), name: "Thread the Needle Left", duration: 45, animationName: "thread_needle_left"),
            MobilityMove(id: UUID(), name: "Thread the Needle Right", duration: 45, animationName: "thread_needle_right"),
            MobilityMove(id: UUID(), name: "Square Pose Left", duration: 45, animationName: "square_left"),
            MobilityMove(id: UUID(), name: "Savasana", duration: 45, animationName: "savasana"),
        ]
    )

    private static let december = MobilityFlow(
        id: UUID(),
        month: 12,
        title: "Still & Warm",
        subtitle: "Hold space before the day takes over.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Child's Pose", duration: 45, animationName: "childs_pose"),
            MobilityMove(id: UUID(), name: "Seal Pose", duration: 45, animationName: "seal"),
            MobilityMove(id: UUID(), name: "Shoelace Left", duration: 45, animationName: "shoelace_left"),
            MobilityMove(id: UUID(), name: "Shoelace Right", duration: 45, animationName: "shoelace_right"),
            MobilityMove(id: UUID(), name: "Banana Left", duration: 45, animationName: "banana_left"),
            MobilityMove(id: UUID(), name: "Banana Right", duration: 45, animationName: "banana_right"),
            MobilityMove(id: UUID(), name: "Savasana", duration: 45, animationName: "savasana"),
        ]
    )

    // MARK: - Vinyasa (Mar–Oct) — 20s transitions, ~15 moves, ~5 min

    private static let march = MobilityFlow(
        id: UUID(),
        month: 3,
        title: "Wake Up",
        subtitle: "Build warmth as the season shifts.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Cat-Cow", duration: 20, animationName: "cat_cow"),
            MobilityMove(id: UUID(), name: "Downward Dog", duration: 20, animationName: "down_dog"),
            MobilityMove(id: UUID(), name: "Low Lunge Left", duration: 20, animationName: "low_lunge_left"),
            MobilityMove(id: UUID(), name: "Low Lunge Right", duration: 20, animationName: "low_lunge_right"),
            MobilityMove(id: UUID(), name: "Standing Forward Fold", duration: 20, animationName: "standing_forward_fold"),
            MobilityMove(id: UUID(), name: "Chair Pose", duration: 20, animationName: "chair"),
            MobilityMove(id: UUID(), name: "Warrior I Left", duration: 20, animationName: "warrior1_left"),
            MobilityMove(id: UUID(), name: "Warrior I Right", duration: 20, animationName: "warrior1_right"),
            MobilityMove(id: UUID(), name: "Side Stretch Left", duration: 20, animationName: "side_stretch_left"),
            MobilityMove(id: UUID(), name: "Side Stretch Right", duration: 20, animationName: "side_stretch_right"),
            MobilityMove(id: UUID(), name: "Hip Circle Left", duration: 20, animationName: "hip_circle_left"),
            MobilityMove(id: UUID(), name: "Hip Circle Right", duration: 20, animationName: "hip_circle_right"),
            MobilityMove(id: UUID(), name: "Shoulder Roll", duration: 20, animationName: "shoulder_roll"),
            MobilityMove(id: UUID(), name: "Neck Release", duration: 20, animationName: "neck_release"),
            MobilityMove(id: UUID(), name: "Mountain Pose", duration: 20, animationName: "mountain"),
        ]
    )

    private static let april = MobilityFlow(
        id: UUID(),
        month: 4,
        title: "Rise & Flow",
        subtitle: "Let the body lead the day.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Sun Breath", duration: 20, animationName: "sun_breath"),
            MobilityMove(id: UUID(), name: "Forward Fold Sway", duration: 20, animationName: "forward_fold_sway"),
            MobilityMove(id: UUID(), name: "Half Lift", duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Crescent Left", duration: 20, animationName: "crescent_left"),
            MobilityMove(id: UUID(), name: "Crescent Right", duration: 20, animationName: "crescent_right"),
            MobilityMove(id: UUID(), name: "Warrior II Left", duration: 20, animationName: "warrior2_left"),
            MobilityMove(id: UUID(), name: "Warrior II Right", duration: 20, animationName: "warrior2_right"),
            MobilityMove(id: UUID(), name: "Reverse Warrior Left", duration: 20, animationName: "reverse_warrior_left"),
            MobilityMove(id: UUID(), name: "Reverse Warrior Right", duration: 20, animationName: "reverse_warrior_right"),
            MobilityMove(id: UUID(), name: "Wide Leg Fold", duration: 20, animationName: "wide_leg_fold"),
            MobilityMove(id: UUID(), name: "Triangle Left", duration: 20, animationName: "triangle_left"),
            MobilityMove(id: UUID(), name: "Triangle Right", duration: 20, animationName: "triangle_right"),
            MobilityMove(id: UUID(), name: "Standing Hip Opener Left", duration: 20, animationName: "hip_opener_left"),
            MobilityMove(id: UUID(), name: "Standing Hip Opener Right", duration: 20, animationName: "hip_opener_right"),
            MobilityMove(id: UUID(), name: "Mountain Pose", duration: 20, animationName: "mountain"),
        ]
    )

    private static let may = MobilityFlow(
        id: UUID(),
        month: 5,
        title: "Build Momentum",
        subtitle: "Short and deliberate — enough to shift the state.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Breath of Fire Prep", duration: 20, animationName: "breath_fire_prep"),
            MobilityMove(id: UUID(), name: "Cat-Cow", duration: 20, animationName: "cat_cow"),
            MobilityMove(id: UUID(), name: "Plank Hold", duration: 20, animationName: "plank"),
            MobilityMove(id: UUID(), name: "Cobra", duration: 20, animationName: "cobra"),
            MobilityMove(id: UUID(), name: "Downward Dog", duration: 20, animationName: "down_dog"),
            MobilityMove(id: UUID(), name: "Three-Legged Dog Left", duration: 20, animationName: "three_leg_left"),
            MobilityMove(id: UUID(), name: "Three-Legged Dog Right", duration: 20, animationName: "three_leg_right"),
            MobilityMove(id: UUID(), name: "Low Lunge Left", duration: 20, animationName: "low_lunge_left"),
            MobilityMove(id: UUID(), name: "Low Lunge Right", duration: 20, animationName: "low_lunge_right"),
            MobilityMove(id: UUID(), name: "Warrior I Left", duration: 20, animationName: "warrior1_left"),
            MobilityMove(id: UUID(), name: "Warrior I Right", duration: 20, animationName: "warrior1_right"),
            MobilityMove(id: UUID(), name: "Chair Pose", duration: 20, animationName: "chair"),
            MobilityMove(id: UUID(), name: "Eagle Arms", duration: 20, animationName: "eagle_arms"),
            MobilityMove(id: UUID(), name: "Shoulder Opener", duration: 20, animationName: "shoulder_opener"),
            MobilityMove(id: UUID(), name: "Mountain Pose", duration: 20, animationName: "mountain"),
        ]
    )

    private static let june = MobilityFlow(
        id: UUID(),
        month: 6,
        title: "Open Up",
        subtitle: "Use the longer days — start with space.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Sun Salutation A — Breath", duration: 20, animationName: "sun_a_breath"),
            MobilityMove(id: UUID(), name: "Forward Fold", duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Halfway Lift", duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Chaturanga", duration: 20, animationName: "chaturanga"),
            MobilityMove(id: UUID(), name: "Upward Dog", duration: 20, animationName: "up_dog"),
            MobilityMove(id: UUID(), name: "Downward Dog", duration: 20, animationName: "down_dog"),
            MobilityMove(id: UUID(), name: "Pigeon Left", duration: 20, animationName: "pigeon_left"),
            MobilityMove(id: UUID(), name: "Pigeon Right", duration: 20, animationName: "pigeon_right"),
            MobilityMove(id: UUID(), name: "Seated Twist Left", duration: 20, animationName: "seated_twist_left"),
            MobilityMove(id: UUID(), name: "Seated Twist Right", duration: 20, animationName: "seated_twist_right"),
            MobilityMove(id: UUID(), name: "Bridge", duration: 20, animationName: "bridge"),
            MobilityMove(id: UUID(), name: "Supine Hamstring Left", duration: 20, animationName: "supine_hamstring_left"),
            MobilityMove(id: UUID(), name: "Supine Hamstring Right", duration: 20, animationName: "supine_hamstring_right"),
            MobilityMove(id: UUID(), name: "Happy Baby", duration: 20, animationName: "happy_baby"),
            MobilityMove(id: UUID(), name: "Savasana", duration: 20, animationName: "savasana"),
        ]
    )

    private static let july = MobilityFlow(
        id: UUID(),
        month: 7,
        title: "Move & Breathe",
        subtitle: "Warm mornings, deliberate movement.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Standing Breath", duration: 20, animationName: "standing_breath"),
            MobilityMove(id: UUID(), name: "Chest Opener", duration: 20, animationName: "chest_opener"),
            MobilityMove(id: UUID(), name: "Side Bend Left", duration: 20, animationName: "side_bend_left"),
            MobilityMove(id: UUID(), name: "Side Bend Right", duration: 20, animationName: "side_bend_right"),
            MobilityMove(id: UUID(), name: "Forward Fold", duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Squat Hold", duration: 20, animationName: "squat"),
            MobilityMove(id: UUID(), name: "Low Lunge Left", duration: 20, animationName: "low_lunge_left"),
            MobilityMove(id: UUID(), name: "Low Lunge Right", duration: 20, animationName: "low_lunge_right"),
            MobilityMove(id: UUID(), name: "Warrior II Left", duration: 20, animationName: "warrior2_left"),
            MobilityMove(id: UUID(), name: "Warrior II Right", duration: 20, animationName: "warrior2_right"),
            MobilityMove(id: UUID(), name: "Extended Side Angle Left", duration: 20, animationName: "ext_side_angle_left"),
            MobilityMove(id: UUID(), name: "Extended Side Angle Right", duration: 20, animationName: "ext_side_angle_right"),
            MobilityMove(id: UUID(), name: "Wide Leg Forward Fold", duration: 20, animationName: "wide_leg_fold"),
            MobilityMove(id: UUID(), name: "Neck Roll", duration: 20, animationName: "neck_roll"),
            MobilityMove(id: UUID(), name: "Mountain Pose", duration: 20, animationName: "mountain"),
        ]
    )

    private static let august = MobilityFlow(
        id: UUID(),
        month: 8,
        title: "Stay Loose",
        subtitle: "Keep the body moving before momentum fades.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Wrist Circles", duration: 20, animationName: "wrist_circles"),
            MobilityMove(id: UUID(), name: "Shoulder Shrug & Roll", duration: 20, animationName: "shoulder_shrug"),
            MobilityMove(id: UUID(), name: "Torso Rotation Left", duration: 20, animationName: "torso_rotation_left"),
            MobilityMove(id: UUID(), name: "Torso Rotation Right", duration: 20, animationName: "torso_rotation_right"),
            MobilityMove(id: UUID(), name: "Forward Fold", duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Cat-Cow", duration: 20, animationName: "cat_cow"),
            MobilityMove(id: UUID(), name: "Thread the Needle Left", duration: 20, animationName: "thread_needle_left"),
            MobilityMove(id: UUID(), name: "Thread the Needle Right", duration: 20, animationName: "thread_needle_right"),
            MobilityMove(id: UUID(), name: "Downward Dog", duration: 20, animationName: "down_dog"),
            MobilityMove(id: UUID(), name: "Pigeon Left", duration: 20, animationName: "pigeon_left"),
            MobilityMove(id: UUID(), name: "Pigeon Right", duration: 20, animationName: "pigeon_right"),
            MobilityMove(id: UUID(), name: "Seated Forward Fold", duration: 20, animationName: "seated_forward_fold"),
            MobilityMove(id: UUID(), name: "Supine Twist Left", duration: 20, animationName: "supine_twist_left"),
            MobilityMove(id: UUID(), name: "Supine Twist Right", duration: 20, animationName: "supine_twist_right"),
            MobilityMove(id: UUID(), name: "Constructive Rest", duration: 20, animationName: "constructive_rest"),
        ]
    )

    private static let september = MobilityFlow(
        id: UUID(),
        month: 9,
        title: "Find Center",
        subtitle: "Transition season — steady the body.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Breath Awareness", duration: 20, animationName: "breath_awareness"),
            MobilityMove(id: UUID(), name: "Neck Side Stretch Left", duration: 20, animationName: "neck_side_left"),
            MobilityMove(id: UUID(), name: "Neck Side Stretch Right", duration: 20, animationName: "neck_side_right"),
            MobilityMove(id: UUID(), name: "Shoulder Opener", duration: 20, animationName: "shoulder_opener"),
            MobilityMove(id: UUID(), name: "Standing Twist Left", duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Standing Twist Right", duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "High Lunge Left", duration: 20, animationName: "high_lunge_left"),
            MobilityMove(id: UUID(), name: "High Lunge Right", duration: 20, animationName: "high_lunge_right"),
            MobilityMove(id: UUID(), name: "Warrior III Left", duration: 20, animationName: "warrior3_left"),
            MobilityMove(id: UUID(), name: "Warrior III Right", duration: 20, animationName: "warrior3_right"),
            MobilityMove(id: UUID(), name: "Tree Pose Left", duration: 20, animationName: "tree_left"),
            MobilityMove(id: UUID(), name: "Tree Pose Right", duration: 20, animationName: "tree_right"),
            MobilityMove(id: UUID(), name: "Wide Squat", duration: 20, animationName: "wide_squat"),
            MobilityMove(id: UUID(), name: "Hip Flexor Left", duration: 20, animationName: "hip_flexor_left"),
            MobilityMove(id: UUID(), name: "Mountain Pose", duration: 20, animationName: "mountain"),
        ]
    )

    private static let october = MobilityFlow(
        id: UUID(),
        month: 10,
        title: "Wind Down & Ground",
        subtitle: "Shorter days — ground the body before cooling starts.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Child's Pose", duration: 20, animationName: "childs_pose"),
            MobilityMove(id: UUID(), name: "Cat-Cow", duration: 20, animationName: "cat_cow"),
            MobilityMove(id: UUID(), name: "Downward Dog", duration: 20, animationName: "down_dog"),
            MobilityMove(id: UUID(), name: "Low Lunge Left", duration: 20, animationName: "low_lunge_left"),
            MobilityMove(id: UUID(), name: "Low Lunge Right", duration: 20, animationName: "low_lunge_right"),
            MobilityMove(id: UUID(), name: "Pyramid Left", duration: 20, animationName: "pyramid_left"),
            MobilityMove(id: UUID(), name: "Pyramid Right", duration: 20, animationName: "pyramid_right"),
            MobilityMove(id: UUID(), name: "Warrior I Left", duration: 20, animationName: "warrior1_left"),
            MobilityMove(id: UUID(), name: "Warrior I Right", duration: 20, animationName: "warrior1_right"),
            MobilityMove(id: UUID(), name: "Seated Forward Fold", duration: 20, animationName: "seated_forward_fold"),
            MobilityMove(id: UUID(), name: "Supine Twist Left", duration: 20, animationName: "supine_twist_left"),
            MobilityMove(id: UUID(), name: "Supine Twist Right", duration: 20, animationName: "supine_twist_right"),
            MobilityMove(id: UUID(), name: "Bridge", duration: 20, animationName: "bridge"),
            MobilityMove(id: UUID(), name: "Knees to Chest", duration: 20, animationName: "knees_to_chest"),
            MobilityMove(id: UUID(), name: "Savasana", duration: 20, animationName: "savasana"),
        ]
    )
}
