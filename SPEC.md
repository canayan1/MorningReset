# Morning Reset — Shipping Spec

## Product promise

Morning Reset helps users interrupt the urge to scroll right after waking and start with one intentional first win instead.

The app does not replace the system alarm clock. It relies on a local notification that the user taps after waking with their normal routine.

## Shipping flow

```text
[Onboarding]
      ↓
[Schedule Setup]
      ↓
[Wake Home]
      ↓ tap Morning Reset
[Question 1 of 5]
      ↓ auto-advance
[Question 5 of 5]
      ↓
[Weekly Affirmation]
      ↓
[Sound Cue]
      ↓
[Results + First Win Selection]
      ↓
[Insight Preview]
      ↓
[Action]
      ↓
[Win]
      ↓
[Flow Check-out]
      ↓
[Wake Home]
```

Premium-only follow-up surfaces may appear after Insight Preview or from the Action screen:
- Paywall
- Guided Pause
- Rise & Flow

## Core behavior

### Wake home
- Must describe the wake entry as a local notification, not an alarm guarantee
- Shows next scheduled ping
- Lets the user either start immediately or edit the schedule

### Quiz
- 5 binary questions
- One question at a time
- Auto-advances after each answer
- 60-second inactivity timer resets the flow back to wake home

### Ritual continuity
- Weekly affirmation and sound cue keep the user inside the ritual
- No external app jump before the ritual reaches Results and Action

### Results and action
- Results names the morning mode and asks the user to pick one concrete first win
- Action screen is built around that one selected first win
- Win confirms completion
- Flow check-out records completion locally

## Persistence

- App state is driven by a single `@Observable` `AppState`
- Local persistence is limited to:
  - onboarding completion
  - wake schedule
  - streak/history needed for the shipped experience
  - premium entitlement state
- No account, login, or cloud sync in the launch build

## Premium boundaries

Premium can unlock:
- fuller pattern insight
- guided pause
- Rise & Flow

Premium must not:
- block the core 2-minute ritual
- be described as required for the app to work

## Out of launch scope

- Alarm clock replacement
- Widget
- Sign in with Apple or any account feature
- iPad support
- Analytics, ads, or tracking
