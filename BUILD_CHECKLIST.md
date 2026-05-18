# Morning Reset — Build, QA, Localization, Listing Checklist

## Build targets

Requirements:
- Xcode with iOS 26.4 simulator support
- iPhone simulator only
- No package install step

Build:

```bash
xcodebuild -project MorningReset/MorningReset.xcodeproj -scheme MorningReset -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' build CODE_SIGNING_ALLOWED=NO
```

Unit tests:

```bash
xcodebuild -project MorningReset/MorningReset.xcodeproj -scheme MorningReset -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 test -only-testing:MorningResetTests CODE_SIGNING_ALLOWED=NO
```

UI tests:

```bash
xcodebuild -project MorningReset/MorningReset.xcodeproj -scheme MorningReset -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 test -only-testing:MorningResetUITests CODE_SIGNING_ALLOWED=NO
```

Full test pass:

```bash
xcodebuild -project MorningReset/MorningReset.xcodeproj -scheme MorningReset -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 test CODE_SIGNING_ALLOWED=NO
```

Current verification snapshot:
- `build` passes with the command above.
- `MorningResetTests` passes with the command above.
- `MorningResetUITests` passes with the command above, including the EN/TR/ES happy path, premium smoke coverage, and launch tests.

## Automated acceptance

- `MorningResetTests`
  - EN/TR/ES answer mapping matches the shipped scoring rules.
  - Free flow reaches `action` without false premium blocks.
  - Strong-pattern users reach the contextual paywall.
  - Premium users bypass the paywall and reach guided pause.
  - Periodic re-prompt appears only after the cooldown window.
- `MorningResetUITests`
  - Happy-path reset completes end to end in EN/TR/ES.
  - Strong-pattern smoke test reaches the paywall and can continue without Premium.

## Manual QA — EN / TR / ES

Run the full ritual once in each locale:
- English: `en_US`
- Turkish: `tr_TR`
- Spanish: `es_ES`

Check each screen on at least one modern iPhone simulator and one compact-width iPhone simulator:
- Onboarding
  - Promise is honest: notification-first ritual, not an alarm claim.
  - CTA copy fits without clipping.
- Schedule setup
  - Weekday and weekend labels fit.
  - Notification disclaimer remains readable.
- Alarm home
  - Primary and secondary CTA labels fit.
  - “Morning ping” copy still makes sense in locale.
- Quiz
  - Question wording stays binary and clear.
  - Button labels fit without truncation.
- Weekly affirmation
  - Weekly mantra is localized.
  - No line wraps feel broken or awkward.
- Sound cue
  - Direction label and helper copy are localized.
- Results
  - Mode name, meaning, first-win section, and recommendation badge fit.
  - Selected first win remains visually obvious.
- Insight preview
  - Reflection / observation / pattern labels make sense in locale.
  - Locked teaser still clearly communicates Premium is optional.
- Paywall
  - Core reset stays clearly free.
  - Premium copy only mentions features that exist in the app.
  - Purchase / restore / legal labels fit.
- Action
  - Action title, steps, and Rise & Flow upsell all fit.
  - “Choose a different first win” still reads naturally.
- Move
  - Timer, movement cues, and CTA fit during the full 60-second sequence.
- Win + Check-out
  - Completion copy fits.
  - Segment labels and tags remain tappable and legible.

Mark locale QA complete only if:
- No clipped or overlapping text appears in the core flow.
- No screen falls back to English unexpectedly in EN/TR/ES core flow.
- Premium and non-premium paths communicate the same product truth.

## Listing truth check

Before submission, verify the App Store copy still matches the shipped app exactly:
- Do not call Morning Reset an alarm clock.
- Do describe it as a local notification-led ritual.
- Do not promise accounts, sync, analytics, widgets, coaching, meditation library, or news feed features.
- Do not imply Premium is required for the core reset.
- Do mention the real premium extras only:
  - fuller pattern insight
  - guided pause
  - Rise & Flow

## App Review copy to paste

Use this as the review-note base unless product behavior changes:

`Morning Reset uses a local notification to invite the user into a short morning ritual after waking. It does not replace the system alarm and does not guarantee alarm-like behavior when the device is muted, in Silent mode, or filtered by Focus.

The core reset flow is free and complete without a subscription. Premium only unlocks deeper follow-up tools already present in the app.

The launch build does not include account creation, analytics, ad SDKs, or third-party tracking.`

Metadata URLs:
- Privacy Policy: `https://canayan1.github.io/MorningReset/privacy-policy.html`
- Support: `https://canayan1.github.io/MorningReset/support.html`

## Release sign-off

- Build passes.
- Targeted unit and UI tests pass.
- EN/TR/ES manual QA has no unresolved copy or layout surprises in the core flow.
- README and App Store draft describe the same shipping flow users actually experience.

Detailed App Store Connect and GitHub Pages handoff steps live in [APP_STORE_HANDOFF.md](APP_STORE_HANDOFF.md).
