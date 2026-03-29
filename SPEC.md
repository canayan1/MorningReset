# Morning Reset — Product Spec

## Problem

Most people pick up their phone within minutes of waking and immediately open social media or news. This sets a reactive, anxious tone for the day. The goal of Morning Reset is to insert a 2-minute intentional flow before the user can reach their feed.

---

## Core flow

```
[Alarm Screen]
      ↓ tap Start
[Question 1 of 5]
      ↓ tap answer (auto-advance)
[Question 2 of 5]
      ↓ ...
[Question 5 of 5]
      ↓ auto-advance after last answer
[Results Screen]
      ↓ tap Continue
[Action Screen]
      ↓ tap Learn / Choose Mode / Skip
[Done — app returns to idle or closes flow]
```

If the user is **inactive for 60 seconds** at any point during the quiz, the app returns to the Alarm Screen and the flow restarts.

---

## Screens

### 1. Alarm Screen
- Full-screen
- App name + short prompt ("Good morning. Take 2 minutes.")
- Single large **Start** button
- No back navigation once flow begins

### 2. Quiz Screen (5 questions)
- One question at a time
- 3–4 answer options per question
- Tapping an answer highlights it briefly, then auto-advances after ~0.6s
- Progress indicator (e.g. "2 of 5")
- 60-second inactivity timer — resets on any tap; triggers return to Alarm Screen if expired
- Questions cover: sleep quality, energy level, mood, focus readiness, intention for the day

### 3. Results Screen
Three outputs derived from answers:

| Output | Description |
|--------|-------------|
| **Current Mode** | A label summarising the user's state (e.g. "Recovery Mode", "Focus Mode", "Survival Mode") |
| **Action Suggestion** | One short, specific action to do right now (e.g. "Drink a full glass of water before opening any app") |
| **Warning** | One short risk to watch out for today (e.g. "Low energy — avoid scheduling complex decisions before 11am") |

Mode is determined by a simple scoring function over the 5 answers. No ML, no backend.

### 4. Action Screen
Three choices presented as large tappable cards:

| Choice | Behaviour |
|--------|-----------|
| **Learn one thing** | Opens a placeholder URL (future: curated article or tip) |
| **Choose your mode** | Opens a sub-panel with three music mode options (Focus, Chill, Energy); each taps open a placeholder URL |
| **Skip** | Dismisses and ends the flow |

---

## Inactivity timer

- Starts when the first question appears
- Resets on every tap anywhere in the quiz
- If 60 seconds pass with no tap: return to Alarm Screen, reset all state
- Timer does not run on the Results or Action screens

---

## State & persistence

- All flow state is in-memory (`@Observable` class)
- No persistence is implemented in the current MVP
- No user account, no cloud sync

---

## Mode scoring (MVP logic)

Each answer maps to one of three modes: **Focus**, **Recovery**, **Survival**

- Most answers → Focus: user gets "Focus Mode"
- Most answers → Recovery: user gets "Recovery Mode"
- Mixed or low energy: user gets "Survival Mode"

Exact mapping defined in `MorningData.swift`.

---

## Out of scope for MVP

- Push notifications / alarm scheduling
- Streaks or history beyond last session
- Onboarding
- Dark/light mode theming beyond system default
- iPad support
- Accessibility audit
