# Frame packet: 03-the-smile

## Project inputs

- Project: /Users/can/Projects/MorningReset/AppStoreAssets/video/morning-promo
- Design tokens: /Users/can/Projects/MorningReset/AppStoreAssets/video/morning-promo/frame.md
- RULES_DIR: /Users/can/.claude/skills/hyperframes-animation/rules

## Assigned storyboard block

## Frame 3 — The smile

- scene: The card dissolves into the app's own breath circle. The melody draws away as the line lands.
- duration: 5.0s
- src: compositions/frames/03-the-smile.html
- poster: 3s
- transition_in: crossfade
- blueprint: video-text-pivot
- status: outline
- voiceover: "A smile. And the bell lets go."
- asset_candidates: capture/assets/r_arrival.png (the ritual's breath transition, real capture), assets/audio/alarm-melody.m4a (fading out under the line)

The payoff, and the one place picture and sound have to agree exactly: the
melody that has run since the first frame fades out as the second clause lands,
so the viewer hears the cause and effect rather than being told about it. This
is the product's whole argument in five seconds — the alarm ends because of
something you did, not because you silenced it.

The card dissolves and the app's breath circle takes its place, swelling once
across the frame the way it does in the app. `A smile.` sets first; `And the
bell lets go.` arrives under it as the sound goes.

- handoff_in: the card at 62% scale centred at x 50% / y 58%, opacity 1, still drifting down at ~6px/s; it dissolves over the first 0.8s.
- handoff_out: the breath circle at 100% scale, centred, opacity 1, settling (no drift).

## Selected blueprint: video-text-pivot

# video-text-pivot — Video → Text Pivot

**intent**: A product video holds center and claims attention, then slides aside to hand its weight to a hero stat in the space it vacates, then both clear and kinetic text types into the center — accent words carrying the meaning the video used to carry — sealed by a gradient pill. The arc is "show → yield → pivot → stamp," and each handoff pairs an exit with a same-anchor entrance so two beats read, not four.

**roles served**

- Product_Intro (from `metric-video-text-pivot`): when the open is "see the feature" then "see the impact" and the `[product video]` must stay visible through the stat reveal — it slides, it doesn't cut.
- Key_Feature: a feature clip that yields to a frame-filling metric and a typographic impact line.

**duration**: 6–8s

**shot structure** (a `[bg]` canvas; one `[product video]` as a real muted `.mp4` clip, a hero stat, then kinetic text — each pair shares a screen anchor so the handoff reads as a weight-transfer)

- **Scene 1 (0.0–~1.6s) — the video shows.** The `[product video]` lands centered on a smooth scale-up and breathes (a small y-bob), claiming full attention. Camera static.
- **Scene 2 (~1.6–3.2s) — yield + stat (signature move).** The video SLIDES aside (x + scale down) **into the very space** the `[hero stat]` now fills as the stat pops in with 3D-depth type — one weight-transfer reading as a single event, not two. The stat breathes within this window.
- **Scene 3 (~3.2–5.0s) — pivot to text.** Both video and stat clear out and kinetic `[impact text]` TYPES into the vacated center, character by character; its `[accent words]` carry the meaning the video used to carry.
- **Scene 4 (~5.0–end) — stamp.** A gradient `[pill]` snaps shut around the closing line (`scaleX` 0→1), its glow halo resolving a beat behind so the silhouette reads before the bloom — sealing the statement as one graphic. Holds.

**motion vocabulary**: video scale-in + small breath; weight-transfer slide (video x + scale-down handing off to the stat at the same anchor); 3D-depth stat type; character-stream typing; gradient pill scaleX-snap; glow-halo bloom trailing the silhouette.

**rule mapping**

- video entrance (smooth) and the weight-transfer slide → `gsap-effects` (scale/opacity then x + scale on a long-tail `power3`); the video itself is a muted `<video class="clip">` direct child of the root
- hero stat's frame-filling 3D type → `3d-text-depth-layers` (static-depth variation — layers built at setup, no cascade fighting the entry)
- the same-anchor video-exit ↔ stat-entry handoff (if treated as a morph) → `scale-swap-transition` (shared center)
- character-by-character impact typing through segmented spans → `dynamic-content-sequencing` (clean character stream) or `discrete-text-sequence`
- pill `scaleX` snap + trailing glow halo → `gsap-effects` (scaleX) + `ambient-glow-bloom` (the halo, resolving a beat behind)
- video / stat breath within their windows → `sine-wave-loop` (low-amplitude register — subtle jitter, gated to each element's window, never a forever loop)

**camera modifier**: camera-static — all motion is element-space (the video translates), so the "pivot" is the elements moving, not a camera.
