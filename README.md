# Morning Reset

A minimal SwiftUI iPhone app that helps you avoid doom scrolling immediately after waking up.

When your alarm fires, Morning Reset forces a 2-minute guided flow before you can reach your phone's feed.

---

## What it does

1. Shows an alarm screen — you must tap Start to proceed
2. Walks you through 5 quick multiple-choice questions about how you feel
3. If you go inactive for 60 seconds, the alarm restarts
4. Shows a results screen: your current mode, one action, one warning
5. Ends with a final action screen: learn something, pick your mode, or skip

## What it does not do

- No backend
- No login
- No notifications (alarm is triggered externally, e.g. iOS Clock)
- No subscriptions
- No analytics
- No third-party libraries

## Tech

- SwiftUI
- iOS 17+
- Local state only (in-memory, no persistence)

## Build

See [BUILD_CHECKLIST.md](BUILD_CHECKLIST.md)
