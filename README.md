# MorningReset

A minimal SwiftUI iPhone app that interrupts autopilot before passive scrolling takes over.

When you wake up, MorningReset gets you out of bed and moving before the feed opens.

---

## What it does

1. Alarm screen — prompts physical activation before anything else
2. 5-question fast scan — sleep, energy, mood, focus, intention
3. 60-second inactivity timer — resets to alarm if the user goes idle during the scan
4. Result screen — structured output based on scan:
   - **Mode** — Protect / Steady / Push
   - **Meaning** — short calibration of the morning
   - **Start with** — physical-first directive (bed exit → water → first task)
   - **Avoid** — one specific risk for the morning
   - **First win** — immediate, achievable target
   - **Bonus** — secondary signal (line, music cue, or morning note)
5. Action screen — continuation prompt to keep momentum

## What it does not do

- No backend
- No login
- No notifications (alarm is triggered externally, e.g. iOS Clock)
- No persistence
- No analytics
- No subscriptions
- No third-party libraries

## Tech

- SwiftUI
- iOS 17+
- In-memory state only — nothing is stored between sessions

## Build

See [BUILD_CHECKLIST.md](BUILD_CHECKLIST.md)
