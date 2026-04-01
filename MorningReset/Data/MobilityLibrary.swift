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
            MobilityMove(id: UUID(), name: "Neck release (right)",            cue: "Drop your right ear toward your shoulder. Let the left side of your neck lengthen. Breathe slowly.",                    duration: 45, animationName: "neck_release_right"),
            MobilityMove(id: UUID(), name: "Neck release (left)",             cue: "Drop your left ear toward your shoulder. Let the right side of your neck lengthen. Breathe slowly.",                     duration: 45, animationName: "neck_release_left"),
            MobilityMove(id: UUID(), name: "Shoulder opener (clasped hands)", cue: "Clasp your hands behind your back. Lift your chest and draw your shoulder blades together. Hold and breathe.",          duration: 45, animationName: "shoulder_opener_clasp"),
            MobilityMove(id: UUID(), name: "Forward fold (soft knees)",       cue: "Soft knees. Let your upper body hang heavy. Release your neck completely.",                                              duration: 45, animationName: "forward_fold_hold"),
            MobilityMove(id: UUID(), name: "Figure-four stretch (right)",     cue: "Cross your right ankle over your left knee. Sit back into the stretch. Keep your chest open.",                           duration: 45, animationName: "figure_four_right"),
            MobilityMove(id: UUID(), name: "Figure-four stretch (left)",      cue: "Cross your left ankle over your right knee. Sit back into the stretch. Keep your chest open.",                           duration: 45, animationName: "figure_four_left"),
            MobilityMove(id: UUID(), name: "Child's pose",                    cue: "Kneel and reach your arms forward. Let your forehead rest down. Breathe into your lower back.",                          duration: 45, animationName: "child_pose"),
        ]
    )

    private static let february = MobilityFlow(
        id: UUID(), month: 2,
        title: "Open & Settle",
        subtitle: "Release tension held overnight.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Side neck stretch (right)",       cue: "Tilt your head gently to the right. No forcing — let the weight do the work. Breathe.",                                 duration: 45, animationName: "side_neck_right"),
            MobilityMove(id: UUID(), name: "Side neck stretch (left)",        cue: "Tilt your head gently to the left. No forcing — let the weight do the work. Breathe.",                                  duration: 45, animationName: "side_neck_left"),
            MobilityMove(id: UUID(), name: "Chest opener (doorway-style)",    cue: "Open your arms wide and let your chest expand forward. Draw your shoulder blades together. Breathe in.",                 duration: 45, animationName: "chest_opener_hold"),
            MobilityMove(id: UUID(), name: "Seated forward fold",             cue: "Sit tall and extend your legs. Reach forward and let your spine lengthen. Don't force — just breathe.",                  duration: 45, animationName: "seated_forward_fold"),
            MobilityMove(id: UUID(), name: "Hip opener (right, low lunge)",   cue: "Step your right foot forward. Lower your back knee down. Let your hip sink slowly toward the floor.",                   duration: 45, animationName: "low_lunge_right_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (left, low lunge)",    cue: "Step your left foot forward. Lower your back knee down. Let your hip sink slowly toward the floor.",                    duration: 45, animationName: "low_lunge_left_hold"),
            MobilityMove(id: UUID(), name: "Supine twist (both sides)",       cue: "Lie on your back. Draw one knee across your body. Arms wide. Let your spine unwind with each breath.",                  duration: 45, animationName: "supine_twist"),
        ]
    )

    private static let november = MobilityFlow(
        id: UUID(), month: 11,
        title: "Slow Down",
        subtitle: "Meet the colder mornings with ease.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Neck stretch (right)",            cue: "Drop your right ear toward your shoulder. Keep the other shoulder low. Hold and breathe.",                              duration: 45, animationName: "neck_stretch_right"),
            MobilityMove(id: UUID(), name: "Neck stretch (left)",             cue: "Drop your left ear toward your shoulder. Keep the other shoulder low. Hold and breathe.",                               duration: 45, animationName: "neck_stretch_left"),
            MobilityMove(id: UUID(), name: "Shoulder fold (arm across)",      cue: "Bring one arm across your chest. Hold it with the other hand. Let your shoulder relax completely.",                     duration: 45, animationName: "shoulder_fold"),
            MobilityMove(id: UUID(), name: "Forward fold hold",               cue: "Soft knees. Let your upper body hang. Release your neck completely. Stay here.",                                        duration: 45, animationName: "forward_fold_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (right, low lunge)",   cue: "Step your right foot forward. Lower your back knee. Breathe into the front of your right hip.",                        duration: 45, animationName: "hip_opener_right_hold"),
            MobilityMove(id: UUID(), name: "Hip opener (left, low lunge)",    cue: "Step your left foot forward. Lower your back knee. Breathe into the front of your left hip.",                          duration: 45, animationName: "hip_opener_left_hold"),
            MobilityMove(id: UUID(), name: "Child's pose",                    cue: "Kneel and reach your arms forward. Let your forehead rest down. Breathe into your lower back.",                        duration: 45, animationName: "child_pose"),
        ]
    )

    private static let december = MobilityFlow(
        id: UUID(), month: 12,
        title: "Still & Warm",
        subtitle: "Hold space before the day takes over.",
        type: .yin,
        moves: [
            MobilityMove(id: UUID(), name: "Ear-to-shoulder (right)",         cue: "Let your right ear drop toward your right shoulder. Keep the left shoulder down. Breathe.",                             duration: 45, animationName: "ear_shoulder_right"),
            MobilityMove(id: UUID(), name: "Ear-to-shoulder (left)",          cue: "Let your left ear drop toward your left shoulder. Keep the right shoulder down. Breathe.",                              duration: 45, animationName: "ear_shoulder_left"),
            MobilityMove(id: UUID(), name: "Chest opener hold",               cue: "Open your arms wide and draw your shoulder blades together. Let your chest expand. Breathe in.",                       duration: 45, animationName: "chest_opener_hold"),
            MobilityMove(id: UUID(), name: "Seated fold",                     cue: "Sit tall and extend your legs. Fold gently forward. Let gravity do the work.",                                         duration: 45, animationName: "seated_fold_hold"),
            MobilityMove(id: UUID(), name: "Figure-four (right)",             cue: "Cross your right ankle over your left knee. Sit back into the stretch. Keep your chest open.",                          duration: 45, animationName: "figure_four_right"),
            MobilityMove(id: UUID(), name: "Figure-four (left)",              cue: "Cross your left ankle over your right knee. Sit back into the stretch. Keep your chest open.",                          duration: 45, animationName: "figure_four_left"),
            MobilityMove(id: UUID(), name: "Resting pose (knees bent)",       cue: "Lie on your back. Knees bent, feet flat. Arms at your sides. Close your eyes and breathe.",                            duration: 45, animationName: "resting_knees_bent"),
        ]
    )

    // MARK: - Vinyasa (Mar–Oct) — 15 moves × 20s = 5:00

    private static let march = MobilityFlow(
        id: UUID(), month: 3,
        title: "Wake Up",
        subtitle: "Light movement to build momentum.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand tall, slow breath",         cue: "Stand tall. Inhale slowly. Exhale for twice as long.",                                                                  duration: 20, animationName: "stand_breathe"),
            MobilityMove(id: UUID(), name: "Arm circles",                     cue: "Extend your arms. Draw slow circles forward, then backward.",                                                           duration: 20, animationName: "arm_circles"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  cue: "Roll your shoulders back and down. Let them drop away from your ears.",                                                 duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              cue: "Reach your right arm overhead. Lean gently to the left. Feel the length along your right side.",                       duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               cue: "Reach your left arm overhead. Lean gently to the right. Feel the length along your left side.",                        duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step-back lunge (right)",         cue: "Step your right foot back. Bend your front knee. Feel the front of your hip open.",                                    duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Step-back lunge (left)",          cue: "Step your left foot back. Bend your front knee. Feel the front of your hip open.",                                     duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog (soft)",                 cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     cue: "Walk your feet toward your hands, one small step at a time.",                                                          duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise up, reach",                  cue: "Slowly roll up through your spine. Reach your arms overhead as you stand.",                                            duration: 20, animationName: "rise_reach"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   cue: "Stand tall. Rotate your torso to the right. Let your arms follow naturally.",                                          duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    cue: "Stand tall. Rotate your torso to the left. Let your arms follow naturally.",                                           duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let april = MobilityFlow(
        id: UUID(), month: 4,
        title: "Rise & Flow",
        subtitle: "Build warmth before the day takes shape.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "March in place",                  cue: "Lift your knees one at a time. Keep a steady rhythm. Let your arms swing naturally.",                                  duration: 20, animationName: "march_in_place"),
            MobilityMove(id: UUID(), name: "Arm sweep",                       cue: "Sweep your arms wide and overhead in a full arc. Move slowly.",                                                        duration: 20, animationName: "arm_sweep"),
            MobilityMove(id: UUID(), name: "Chest opener",                    cue: "Open your arms wide and draw your shoulder blades together. Let your chest expand.",                                   duration: 20, animationName: "chest_open"),
            MobilityMove(id: UUID(), name: "Neck check (gentle nods)",        cue: "Gently nod your head yes, then no. Slow and deliberate. No forcing.",                                                  duration: 20, animationName: "neck_nods"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Runner lunge (right)",            cue: "Step your right foot forward into a long lunge. Back leg stays straight. Breathe.",                                    duration: 20, animationName: "runner_lunge_right"),
            MobilityMove(id: UUID(), name: "Runner lunge (left)",             cue: "Step your left foot forward into a long lunge. Back leg stays straight. Breathe.",                                     duration: 20, animationName: "runner_lunge_left"),
            MobilityMove(id: UUID(), name: "Low squat (supported)",           cue: "Feet wide. Sit into a squat. Use a wall if needed. Hold.",                                                             duration: 20, animationName: "supported_squat"),
            MobilityMove(id: UUID(), name: "Fold + sway",                     cue: "Fold forward and gently sway side to side. Let your spine unwind.",                                                    duration: 20, animationName: "fold_sway"),
            MobilityMove(id: UUID(), name: "Rise up",                         cue: "Slowly roll up through your spine. Reach overhead as you stand.",                                                      duration: 20, animationName: "rise_up"),
            MobilityMove(id: UUID(), name: "Side bend (right)",               cue: "Reach your right arm up and lean to the left. Feel the length along your right side.",                                 duration: 20, animationName: "side_bend_right"),
            MobilityMove(id: UUID(), name: "Side bend (left)",                cue: "Reach your left arm up and lean to the right. Feel the length along your left side.",                                  duration: 20, animationName: "side_bend_left"),
            MobilityMove(id: UUID(), name: "Shake out arms",                  cue: "Relax your arms and shake them loose. Let your hands flop.",                                                           duration: 20, animationName: "shake_arms"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let may = MobilityFlow(
        id: UUID(), month: 5,
        title: "Build Momentum",
        subtitle: "Short and deliberate — enough to shift the state.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand + inhale reach",            cue: "Stand tall and reach both arms overhead as you inhale. Hold for a moment at the top.",                                 duration: 20, animationName: "inhale_reach"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step to plank (knees optional)",  cue: "Step back into a plank. Knees down is fine. Hold your body in one long line.",                                        duration: 20, animationName: "plank_option"),
            MobilityMove(id: UUID(), name: "Down dog (soft knees)",           cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   cue: "Step your right foot forward. Bend your front knee. Feel the hip open.",                                               duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    cue: "Step your left foot forward. Bend your front knee. Feel the hip open.",                                                duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Chair pose (light)",              cue: "Bend your knees as if sitting back into a chair. Arms forward. Keep it light.",                                        duration: 20, animationName: "chair_pose_light"),
            MobilityMove(id: UUID(), name: "Fold",                            cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   cue: "Stand tall. Rotate your torso to the right. Let your arms follow naturally.",                                          duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    cue: "Stand tall. Rotate your torso to the left. Let your arms follow naturally.",                                           duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Calf raises",                     cue: "Rise onto the balls of your feet, then lower slowly. Move with control.",                                             duration: 20, animationName: "calf_raises"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (right)",        cue: "Bring your right arm across your chest. Hold with your left hand. Keep your neck long.",                              duration: 20, animationName: "shoulder_cross_right"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (left)",         cue: "Bring your left arm across your chest. Hold with your right hand. Keep your neck long.",                              duration: 20, animationName: "shoulder_cross_left"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let june = MobilityFlow(
        id: UUID(), month: 6,
        title: "Open Up",
        subtitle: "Use the longer days — start with space.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Breath + posture reset",          cue: "Chin level. Shoulders back and down. Take one full breath here.",                                                       duration: 20, animationName: "posture_reset"),
            MobilityMove(id: UUID(), name: "Neck release (right)",            cue: "Drop your right ear toward your shoulder. Let it go. Breathe.",                                                        duration: 20, animationName: "neck_release_right_short"),
            MobilityMove(id: UUID(), name: "Neck release (left)",             cue: "Drop your left ear toward your shoulder. Let it go. Breathe.",                                                         duration: 20, animationName: "neck_release_left_short"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  cue: "Roll your shoulders back and down. Let them drop away from your ears.",                                                 duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              cue: "Reach your right arm overhead. Lean gently to the left. Feel the length.",                                             duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               cue: "Reach your left arm overhead. Lean gently to the right. Feel the length.",                                             duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Step-back (right)",               cue: "Step your right foot back. Bend your front knee. Feel the hip open.",                                                  duration: 20, animationName: "step_back_right"),
            MobilityMove(id: UUID(), name: "Step-back (left)",                cue: "Step your left foot back. Bend your front knee. Feel the hip open.",                                                   duration: 20, animationName: "step_back_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     cue: "Walk your feet toward your hands, one small step at a time.",                                                          duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise + open chest",               cue: "As you rise, open your arms wide. Lift your chest and breathe in.",                                                    duration: 20, animationName: "rise_open_chest"),
            MobilityMove(id: UUID(), name: "Gentle backbend (hands to hips)", cue: "Hands on hips. Gently arch backward. Keep your chin slightly tucked.",                                                 duration: 20, animationName: "gentle_backbend"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let july = MobilityFlow(
        id: UUID(), month: 7,
        title: "Move & Breathe",
        subtitle: "Warm mornings, deliberate movement.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "March in place",                  cue: "Lift your knees one at a time. Keep a steady rhythm. Let your arms swing naturally.",                                  duration: 20, animationName: "march_in_place"),
            MobilityMove(id: UUID(), name: "Reach up",                        cue: "Reach both arms overhead. Press through your palms. Feel tall.",                                                       duration: 20, animationName: "reach_up"),
            MobilityMove(id: UUID(), name: "Side bend (right)",               cue: "Reach your right arm up and lean to the left. Feel the length along your right side.",                                 duration: 20, animationName: "side_bend_right"),
            MobilityMove(id: UUID(), name: "Side bend (left)",                cue: "Reach your left arm up and lean to the right. Feel the length along your left side.",                                  duration: 20, animationName: "side_bend_left"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   cue: "Step your right foot back. Bend your front knee. Feel the hip open.",                                                  duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    cue: "Step your left foot back. Bend your front knee. Feel the hip open.",                                                   duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Knee-to-chest (right, standing)", cue: "Draw your right knee toward your chest. Balance and breathe.",                                                         duration: 20, animationName: "knee_hug_right"),
            MobilityMove(id: UUID(), name: "Knee-to-chest (left, standing)",  cue: "Draw your left knee toward your chest. Balance and breathe.",                                                          duration: 20, animationName: "knee_hug_left"),
            MobilityMove(id: UUID(), name: "Quad stretch (right)",            cue: "Bend your right knee and bring your heel toward your glute. Hold your ankle. Stand tall.",                             duration: 20, animationName: "quad_stretch_right"),
            MobilityMove(id: UUID(), name: "Quad stretch (left)",             cue: "Bend your left knee and bring your heel toward your glute. Hold your ankle. Stand tall.",                              duration: 20, animationName: "quad_stretch_left"),
            MobilityMove(id: UUID(), name: "Shake out",                       cue: "Relax your arms and shake them loose. Let your hands flop.",                                                           duration: 20, animationName: "shake_out"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let august = MobilityFlow(
        id: UUID(), month: 8,
        title: "Stay Loose",
        subtitle: "Keep the body moving before momentum fades.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Stand + long exhale",             cue: "Stand tall. Inhale slowly. Exhale for twice as long. Let your shoulders drop.",                                        duration: 20, animationName: "long_exhale"),
            MobilityMove(id: UUID(), name: "Shoulder opener",                 cue: "Interlace your fingers behind your head. Open your elbows wide. Lift your chest.",                                     duration: 20, animationName: "shoulder_opener"),
            MobilityMove(id: UUID(), name: "Chest opener",                    cue: "Open your arms wide and draw your shoulder blades together. Let your chest expand.",                                   duration: 20, animationName: "chest_open"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   cue: "Stand tall. Rotate your torso to the right. Let your arms follow naturally.",                                          duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    cue: "Stand tall. Rotate your torso to the left. Let your arms follow naturally.",                                           duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Fold",                            cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Side lunge (right)",              cue: "Step wide to the right. Bend your right knee and sit into it. Left leg stays straight.",                               duration: 20, animationName: "side_lunge_right"),
            MobilityMove(id: UUID(), name: "Side lunge (left)",               cue: "Step wide to the left. Bend your left knee and sit into it. Right leg stays straight.",                                duration: 20, animationName: "side_lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk forward",                    cue: "Walk your feet toward your hands, one small step at a time.",                                                          duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Rise up",                         cue: "Slowly roll up through your spine. Reach overhead as you stand.",                                                      duration: 20, animationName: "rise_up"),
            MobilityMove(id: UUID(), name: "Heel raises",                     cue: "Rise onto the balls of your feet, then lower slowly. Move with control.",                                             duration: 20, animationName: "heel_raises"),
            MobilityMove(id: UUID(), name: "Shake arms",                      cue: "Relax your arms and shake them loose. Let your hands flop.",                                                           duration: 20, animationName: "shake_arms"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )

    private static let september = MobilityFlow(
        id: UUID(), month: 9,
        title: "Find Center",
        subtitle: "Transition season — steady the body.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Posture reset",                   cue: "Chin level. Shoulders back and down. Take one full breath here.",                                                       duration: 20, animationName: "posture_reset"),
            MobilityMove(id: UUID(), name: "Arm circles",                     cue: "Extend your arms. Draw slow circles forward, then backward.",                                                           duration: 20, animationName: "arm_circles"),
            MobilityMove(id: UUID(), name: "Forward fold",                    cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Chair pose (light)",              cue: "Bend your knees as if sitting back into a chair. Arms forward. Keep it light.",                                        duration: 20, animationName: "chair_pose_light"),
            MobilityMove(id: UUID(), name: "Fold",                            cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   cue: "Step your right foot back. Bend your front knee. Feel the hip open.",                                                  duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    cue: "Step your left foot back. Bend your front knee. Feel the hip open.",                                                   duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Down dog",                        cue: "Press through your palms. Hips high. Soft bend in the knees is fine.",                                                 duration: 20, animationName: "down_dog_soft"),
            MobilityMove(id: UUID(), name: "Walk to top",                     cue: "Walk your feet toward your hands, one small step at a time.",                                                          duration: 20, animationName: "walk_to_top"),
            MobilityMove(id: UUID(), name: "Reach up",                        cue: "Reach both arms overhead. Press through your palms. Feel tall.",                                                       duration: 20, animationName: "reach_up"),
            MobilityMove(id: UUID(), name: "Twist (right)",                   cue: "Stand tall. Rotate your torso to the right. Let your arms follow naturally.",                                          duration: 20, animationName: "standing_twist_right"),
            MobilityMove(id: UUID(), name: "Twist (left)",                    cue: "Stand tall. Rotate your torso to the left. Let your arms follow naturally.",                                           duration: 20, animationName: "standing_twist_left"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (right)",        cue: "Bring your right arm across your chest. Hold with your left hand. Keep your neck long.",                              duration: 20, animationName: "shoulder_cross_right"),
            MobilityMove(id: UUID(), name: "Shoulder stretch (left)",         cue: "Bring your left arm across your chest. Hold with your right hand. Keep your neck long.",                              duration: 20, animationName: "shoulder_cross_left"),
        ]
    )

    private static let october = MobilityFlow(
        id: UUID(), month: 10,
        title: "Wind Down & Ground",
        subtitle: "Shorter days — ground the body before cooling starts.",
        type: .vinyasa,
        moves: [
            MobilityMove(id: UUID(), name: "Long exhale",                     cue: "Stand tall. Inhale slowly. Exhale for twice as long. Let your shoulders drop.",                                        duration: 20, animationName: "long_exhale"),
            MobilityMove(id: UUID(), name: "Side reach (right)",              cue: "Reach your right arm overhead. Lean gently to the left. Feel the length.",                                             duration: 20, animationName: "side_reach_right"),
            MobilityMove(id: UUID(), name: "Side reach (left)",               cue: "Reach your left arm overhead. Lean gently to the right. Feel the length.",                                             duration: 20, animationName: "side_reach_left"),
            MobilityMove(id: UUID(), name: "Fold",                            cue: "Hinge at your hips. Let your arms hang. Head drops. Soft knees.",                                                      duration: 20, animationName: "forward_fold"),
            MobilityMove(id: UUID(), name: "Half lift",                       cue: "Hands on shins. Lift your chest and make your back flat. Look slightly forward.",                                      duration: 20, animationName: "half_lift"),
            MobilityMove(id: UUID(), name: "Lunge (right)",                   cue: "Step your right foot back. Bend your front knee. Feel the hip open.",                                                  duration: 20, animationName: "lunge_right"),
            MobilityMove(id: UUID(), name: "Lunge (left)",                    cue: "Step your left foot back. Bend your front knee. Feel the hip open.",                                                   duration: 20, animationName: "lunge_left"),
            MobilityMove(id: UUID(), name: "Supported squat",                 cue: "Feet wide. Sit into a squat. Use a wall if needed. Hold.",                                                             duration: 20, animationName: "supported_squat"),
            MobilityMove(id: UUID(), name: "Fold + sway",                     cue: "Fold forward and gently sway side to side. Let your spine unwind.",                                                    duration: 20, animationName: "fold_sway"),
            MobilityMove(id: UUID(), name: "Rise + chest open",               cue: "As you rise, open your arms wide. Lift your chest and breathe in.",                                                    duration: 20, animationName: "rise_open_chest"),
            MobilityMove(id: UUID(), name: "Calf raises",                     cue: "Rise onto the balls of your feet, then lower slowly. Move with control.",                                             duration: 20, animationName: "calf_raises"),
            MobilityMove(id: UUID(), name: "Neck check (gentle turns)",       cue: "Slowly turn your head to the right, then to the left. Keep your shoulders still.",                                    duration: 20, animationName: "neck_turns"),
            MobilityMove(id: UUID(), name: "Shoulder rolls",                  cue: "Roll your shoulders back and down. Let them drop away from your ears.",                                                 duration: 20, animationName: "shoulder_rolls"),
            MobilityMove(id: UUID(), name: "Shake out",                       cue: "Relax your arms and shake them loose. Let your hands flop.",                                                           duration: 20, animationName: "shake_out"),
            MobilityMove(id: UUID(), name: "Stillness",                       cue: "Stand still. Notice your breath. Let the movement settle.",                                                            duration: 20, animationName: "stillness"),
        ]
    )
}
