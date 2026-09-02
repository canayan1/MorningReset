# Morning Reset

Morning Reset is an iPhone-only SwiftUI app that interrupts the scroll impulse after waking with a short, honest ritual. The app does not replace the system Clock alarm. It asks the user to keep their normal wake-up routine, then tap a Morning Reset local notification before opening feeds, news, or messages.

## Shipping flow

1. Onboarding frames the app as a notification-led ritual, not an alarm clock.
2. Schedule setup lets the user choose weekday and weekend ping times.
3. Wake home shows the next morning ping and offers either schedule editing or an immediate start.
4. Quiz asks 5 one-tap yes/no questions and auto-advances; inactivity for 60 seconds resets the flow.
5. Weekly affirmation and sound cue keep the ritual moving without sending the user to another app.
6. Results names the user's morning mode and asks them to choose one concrete first win.
7. Insight preview shows a reflection or pattern teaser; Premium only appears for stronger follow-up reads or Rise & Flow.
8. Action, Win, and Flow Check-out close the ritual around one immediate next step.

## Free vs Premium

Free:
- Notification setup, onboarding, wake home, 5-question ritual, weekly affirmation, sound cue, results, insight preview, first-win action flow, win, and check-out.
- Local streaks and recent history stored on device.

Premium:
- Full pattern insight when stronger repeats show up.
- Guided pause after those stronger patterns.
- Rise & Flow, a guided 5-minute movement reset.

Premium does not unlock the core 2-minute reset. The free ritual is complete without a subscription.

## Product truths

- iPhone only.
- SwiftUI, no external packages.
- No backend, analytics, ads, or tracking.
- No account, login, or cloud sync in the launch build.
- Notification-based wake entry, not an alarm guarantee.
- Localized core flow for English, Turkish, and Spanish.

## Hosted metadata surfaces

- Privacy policy draft source: [PrivacyPolicy.md](PrivacyPolicy.md)
- Production privacy URL target: [privacy-policy.html](https://canayan1.github.io/MorningReset/privacy-policy.html)
- Production support URL target: [support.html](https://canayan1.github.io/MorningReset/support.html)

The `docs/` folder contains the static pages intended for GitHub Pages hosting before App Store submission.

Manual release steps live in [APP_STORE_HANDOFF.md](APP_STORE_HANDOFF.md).

## App Store listing draft

App name:
`Morning Reset`

Subtitle:
`Own the first three minutes`

Promotional text:
`Keep your usual alarm. Morning Reset waits on your lock screen, ready to greet you when you reach for your phone.`

Short description:
`A short notification-led ritual that helps you start the day with one clear first win.`

Long description:
`Morning Reset helps you interrupt the urge to scroll the moment your day starts.

Keep the wake-up routine you already trust. Then tap the Morning Reset notification first.

In about two minutes, the app guides you through:
- five quick yes/no questions
- one clear morning mode
- one short reflection or pattern read
- one concrete first win to do right away

Morning Reset is not an alarm clock, not a content feed, and not a giant productivity system. It is a small interruption before reactive phone use takes over.

The core ritual is fully usable for free. Premium only unlocks deeper follow-up tools already present in the app: fuller pattern insight, a guided pause, and Rise & Flow.`

## App Review notes draft

`Morning Reset uses a local notification to invite the user into a short morning ritual. It does not replace the system alarm and does not guarantee alarm-like behaviour when the device is muted, in Silent mode, or filtered by Focus.

The core reset flow is free and complete without a subscription. Premium only unlocks deeper follow-up tools already visible in the app.

No account, analytics, ad SDKs, or third-party tracking are included in the launch build.`

## Build

Build, test, and manual submission checks live in [BUILD_CHECKLIST.md](BUILD_CHECKLIST.md).
