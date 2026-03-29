# AGENTS.md

Instructions for AI agents working on this repository.

---

## Project identity

- App name: Morning Reset
- Platform: iOS 17+, iPhone only
- Language: Swift / SwiftUI
- No external packages, no backend, no analytics

## What this app does

Guides users through a 2-minute morning flow after waking to prevent immediate doom scrolling.
Flow: Alarm → 5-question quiz → Results → Action screen.

---

## Architecture

Flat and simple. Do not add layers.

```
MorningReset/
├── App/
│   ├── MorningResetApp.swift      @main entry, injects AppState
│   └── RootView.swift             Screen switcher, reads AppState.screen
├── State/
│   └── AppState.swift             Single @Observable state object
├── Data/
│   └── MorningData.swift          Questions, options, mode scoring — plain Swift
└── Screens/
    ├── AlarmView.swift
    ├── QuizView.swift
    ├── ResultsView.swift
    └── ActionView.swift
```

Total: 8 files. Do not create additional files unless strictly necessary.

---

## Rules for agents

### Do
- Work on the `setup` branch first; PR to `main`
- Make small, focused commits with clear messages
- Keep each file under ~120 lines where possible
- Use `@Observable` for state (iOS 17 pattern)
- Use `@State` in views for local ephemeral state (e.g. timer countdown display)

### Do not
- Add Firebase, SwiftData, Combine, or any external package
- Add authentication, login, or user accounts
- Add analytics or tracking of any kind
- Add subscription or paywall logic
- Add new screens beyond the 4 defined in SPEC.md
- Refactor working code without a concrete reason
- Add comments that only restate what the code already says
- Introduce abstractions for one-time use cases
- Add iPad layout or macOS target

---

## State machine

```swift
enum Screen {
    case alarm
    case quiz
    case results
    case action
}
```

`AppState` holds `screen: Screen` and drives all navigation.
Views read from `AppState` and call methods on it — no direct mutation from views.

---

## Inactivity timer

Lives in `AppState`. Starts when quiz begins. Resets on every answer tap.
On expiry (60s): sets `screen = .alarm` and stops the timer.
Does NOT run on Results or Action screens.

---

## Persistence

All flow state is in-memory (`AppState`). No persistence is implemented in the current MVP. Do not add UserDefaults or SwiftData without a concrete product requirement.

---

## Commit style

```
feat: add quiz auto-advance after answer
fix: inactivity timer not resetting on tap
chore: add BUILD_CHECKLIST.md
```

## Branch strategy

- `main` — stable, buildable
- `setup` — initial scaffolding
- `feature/<name>` — new screens or behaviour
