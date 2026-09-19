---
format: 1080x1920
duration: 29s
message: "The alarm asks for one smile. The practice waits until you want it."
arc: Future Pacing — imagine → name it → the mechanism → the offer → what it keeps → CTA
audience: people who dread their alarm
mode: collaborative
music: quiet ambient dawn, no percussion, enters under Frame 2 and never competes with the voice
---

> **Source note.** Generated human footage was refused by the account's plan
> ("Cinematic Shots requires a Pro plan" — the account is `creator`), so the
> film is built from the product's own surface instead of a bedroom. That is
> not a downgrade of the story: the lock screen at 06:40 *is* the moment being
> sold, and every screen after it is a real capture from the shipping build.
> If the plan is upgraded later, footage layers behind Frames 1–3 without the
> story or the narration changing.

> **On the durations.** `sync-durations` set each frame to the length of its
> spoken line, which collapsed the film from 29s to about 15s. That is the right
> default and the wrong answer here: every line in this script is written to land
> and then stop, and the silence after it is the thing being sold. Each frame is
> the measured voice length plus its designed pause — 2.3s of voice inside 5.0s
> of frame, and so on. Do not re-sync.

## Frame 1 — The melody

- scene: A near-black phone at 06:40. The notification arrives and the app's own five-note phrase plays; light blooms outward in slow rings.
- duration: 4.5s
- src: compositions/frames/01-the-melody.html
- poster: 3s
- transition_in: cut
- blueprint: titlecard-reveal
- status: outline
- voiceover: ""
- asset_candidates: assets/audio/alarm-melody.m4a (the app's shipping `inner_light_alarm.caf`)

The hook is a sound, not a sentence. Open almost black — a phone face-up in a
dark room, the time small and thin at the top. The Inner Light card fades up:
`INNER LIGHT` in tracked caps, `Your morning is ready.` in serif, `06:40` large
and thin at the right. As the melody's first phrase plays, three concentric
rings bloom out from the card and fade at the edges — the sound made visible.

No type of our own, no logo, no voice. Anyone who has been jolted awake knows
within two seconds that this is not that.

Build the card in HTML from `frame.md` — it is the app's real lock-screen
presentation and its proportions matter more than pixel-copying a screenshot.

## Frame 2 — One thing

- scene: The dark lifts toward dawn mist. The card stays. One line of type arrives.
- duration: 5.0s
- src: compositions/frames/02-one-thing.html
- poster: 3.5s
- transition_in: crossfade
- blueprint: kinetic-type-beats
- status: outline
- voiceover: "Your alarm asks one thing of you this morning."
- asset_candidates: assets/audio/alarm-melody.m4a (still playing, second pass)

The turn. Every other alarm asks you to make it stop; this one is still playing
and nothing is fighting it. The ground lifts from near-black to the app's dawn
mist over the full five seconds — the room getting light, expressed as the
canvas rather than as a photograph. The card drifts down and back, still legible.

The line sets in serif at the upper third, one clause, arriving as the voice
says it. The emphasis is on *one*.

- handoff_out: the dawn-mist ground at full strength, the card at 62% scale centred at x 50% / y 58%, opacity 1, drifting down at ~6px/s.

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

## Frame 4 — The offer

- scene: The real app screen, held: the practice offered, with Later beside it.
- duration: 5.5s
- src: compositions/frames/04-the-offer.html
- poster: 4s
- transition_in: crossfade
- blueprint: device-surface-showcase
- status: outline
- voiceover: "Your practice is here whenever you want it."
- asset_candidates: capture/assets/r_offer.png, capture/assets/01_Today.png

The differentiator, and the reason the morning is light. The alarm's demand has
already ended; what follows is on the table, not on the clock. The first real
interface in the film, and it is a true capture because the claim being made
here is a claim about the product.

Hold long enough that the `Later` button is legible, and let the push-in end
before the line does. `Later` is the most persuasive element in the frame —
frame it deliberately, do not let a crop or a vignette eat it.

## Frame 5 — Breath, pulse, mornings

- scene: Three real screens at the pace of the line — the practice, then the month of mornings.
- duration: 5.5s
- src: compositions/frames/05-breath-pulse-mornings.html
- poster: 4s
- transition_in: crossfade
- blueprint: device-surface-showcase
- status: outline
- voiceover: "Your breath. Then your pulse. And a month of your own mornings."
- asset_candidates: capture/assets/04_Practice.png, capture/assets/07_Mornings.png

What is actually inside, one screen per clause, each arriving as its words do.
No feature list and no callouts — the screens are quiet enough to read alone.

`Your breath.` → the practice player. `Then your pulse.` → hold on the breath
circle rather than invent a screen; the pulse reader has no honest capture yet
and a substitute screen would be a lie about the product. `And a month of your
own mornings.` → the calendar, which is the strongest still in the film: real
readings, real gaps, the summary row legible.

The pulse figures in the calendar carry no claim of any kind. This is a wellness
reading and the film must not imply otherwise.

## Frame 6 — Inner Light

- scene: The mark on dawn mist, the line beneath it, the App Store badge.
- duration: 3.5s
- src: compositions/frames/06-inner-light.html
- poster: 2.5s
- transition_in: crossfade
- blueprint: titlecard-reveal
- status: outline
- voiceover: "Inner Light. Daily practice."
- asset_candidates: capture/assets/01_Today.png (for the orb motif)

End on the ground the whole app is painted on — dawn mist, one periwinkle
accent, the serif name. Nothing sells here; the film has already made its case.
The badge sits where the eye lands last.

## Video direction

One continuous morning, expressed as one continuous rise in light: the canvas
begins near-black in Frame 1 and reaches full dawn mist by Frame 4, and never
goes back down. Nothing in the film cuts hard except the very first frame —
every other seam is a slow crossfade, because a busy cut would contradict the
thing being sold.

Motion is limited to three moves and no others: **bloom** (rings out from a
source, used for sound), **drift** (a slow settle downward, used for handing
over), and **breathe** (a single swell and settle, used for the circle). No
whips, no bounces, no parallax, no kinetic type beyond a quiet set-and-hold.

Type sets in the app's own register: serif display, sentence case, one clause
at a time, generous leading, never more than two lines on screen. Labels are
tracked caps at 10–11px. One accent only — periwinkle — and never two competing.

Sound is the spine. The app's real alarm melody runs from 0.0s and fades out
across Frame 3 as the smile line lands; the music bed enters under Frame 2 and
stays below the voice throughout. The voice is the app's own.
