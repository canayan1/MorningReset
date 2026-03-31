# MorningReset

A minimal SwiftUI iPhone app that interrupts autopilot before passive scrolling takes over.

When you wake up, MorningReset gets you out of bed and moving before the feed opens.

---

## Flow

1. **Alarm screen** — title + single start button. No choices yet.
2. **Quiz** — 5 binary yes/no questions that detect your morning state.
3. **Intention** — pick one quality to return to today (calm / focus / energy / confidence / connection / discipline).
4. **Results** — structured output based on your mode:
   - **Mode** — Protect / Steady / Push
   - **Meaning** — short calibration of the morning
   - **Start with** — physical-first directive
   - **Avoid** — one specific risk for the morning
   - **First win** — immediate, achievable target
   - **Music** — tone suggestion for the day
   - **Mantra** — generated from your mode + intention
5. **Move** — one physical action matched to your mode. Varies daily.
6. **Win** — short reinforcing message after completion.
7. **Continue (optional)** — three soft paths:
   - Learn something — one short behavioral insight
   - See what's happening — 2–3 brief neutral headlines
   - Do one more thing — one additional small action

---

## Modes

| Mode | Signal | Tone |
|---|---|---|
| Protect | Low capacity morning | Gentle, grounding |
| Steady | Functional but not explosive | Rhythmic, clean |
| Push | Available momentum | Active, directed |

---

## What it does not do

- No backend
- No login
- No notifications (alarm is triggered externally, e.g. iOS Clock)
- No persistence between sessions
- No analytics
- No subscriptions
- No third-party libraries
- No external links

---

## Tech

- SwiftUI
- iOS 17+
- `@Observable` state — in-memory only
- Deterministic content variation: `Calendar.day % pool.count`

---

## Build

See [BUILD_CHECKLIST.md](BUILD_CHECKLIST.md)
