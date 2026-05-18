# AGENTS.md

Instructions for AI agents working on this repository.

## Project identity

- App name: Morning Reset
- Platform: iOS 17.6+, iPhone only
- Language: Swift / SwiftUI
- No external packages, no backend, no analytics or ad SDKs

## What ships in 1.0

Morning Reset is a notification-led morning ritual that interrupts the scroll impulse after waking.

Current user flow:
- Onboarding
- Schedule setup
- Wake home
- 5-question quiz
- Weekly affirmation
- Sound cue
- Results
- Insight preview
- Action / Win / Flow check-out
- Optional Premium follow-up surfaces: paywall, guided pause, Rise & Flow

Not in launch scope:
- Alarm clock replacement
- Widget
- Account, login, Sign in with Apple, or cloud sync
- iPad or macOS layouts

## Architecture

Keep the project flat and direct. Do not add layers or framework-style abstraction.

- `MorningReset/App`: app entry, routing, design tokens, shared strings
- `MorningReset/State`: single `@Observable` `AppState` plus small feature extensions
- `MorningReset/Data`: plain Swift models, content, scoring, and utilities
- `MorningReset/Screens`: SwiftUI screens driven by `AppState.screen`

Use `AppState` as the only navigation/state authority for the user flow.

## Rules for agents

### Do
- Work on the `setup` branch first; PR to `main`
- Make focused changes with clear commit messages
- Preserve the product truth: this is a local notification entry, not an alarm guarantee
- Use `@Observable` for app state and `@State` for local ephemeral state
- Keep Premium optional and avoid blocking the core ritual

### Do not
- Add Firebase, SwiftData, Combine, or external packages
- Reintroduce authentication, login, or account state
- Reintroduce widget, news-feed, or non-launch surfaces into onboarding, About, listing copy, or review notes
- Add analytics, ads, or tracking
- Add iPad layout or macOS target
- Refactor working code without a concrete product or release reason

## Key behavior constraints

- The wake entry is a local notification and must be described honestly in UI and docs.
- The quiz auto-advances after each answer and resets to wake home after 60 seconds of inactivity.
- The ritual should keep the user inside the app until the first win is selected and completed.
- The core ritual remains usable without Premium.

## Docs to keep aligned

When changing user-visible behavior, update these in the same sweep:
- `/Users/can/Projects/MorningReset/README.md`
- `/Users/can/Projects/MorningReset/SPEC.md`
- `/Users/can/Projects/MorningReset/BUILD_CHECKLIST.md`
- `/Users/can/Projects/MorningReset/PrivacyPolicy.md`

## Commit style

```text
feat: tighten morning action flow
fix: remove dormant auth state from launch build
chore: align App Store metadata with shipping ritual
```
