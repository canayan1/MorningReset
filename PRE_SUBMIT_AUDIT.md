# Energy Reset 2.0 — pre-submission audit

Findings from auditing the build before review. Competitor/review-guideline research
is being added below as it lands.

Severity: 🔴 blocks submission · 🟠 likely rejection or bad first impression · 🟡 polish

---

## 🔴 BLOCKERS  — 1, 2, 3 and 12 FIXED (19 Aug)

### 1. Info.plist permission strings still say "Morning Reset" / "morning selfie"
```
NSCameraUsageDescription  = "Morning Reset uses the front camera so you can take a morning selfie…"
NSAlarmsUsageDescription  = "Morning Reset uses alarms to start your morning ritual…"
```
The app is now **Energy Reset**, the check-in is not morning-only, and the reviewer sees these
strings in the permission dialog. Mismatched app name in a usage string is exactly the kind of
metadata inconsistency that gets flagged (2.3.1), and it looks unfinished.

### 2. Tapping the daily reminder opens the OLD ritual
`AlarmEntryRouter.routeToWakeFlow()` and the `morningreset://start` URL both call
`appState.startFlow()`, which runs the retired 8-screen morning ritual
(affirmation → sound → results → insight → action → win → checkout → premium hub).
A reviewer who taps the notification lands in a different app than the one being reviewed —
with old copy ("Unlock all three features", Spotify links, First Win).
**Fix:** the reminder should open Today (or today's practice), not the legacy flow.

### 3. Tier purchase has no Restore / Terms / renewal disclosure
`SchoolDetailView` sells **Foundations $4.99/mo** and **Deep $7.99/mo** with a single
"Unlock …" button. Guideline **3.1.2** requires every auto-renewable subscription purchase
surface to show: title, duration, price per period, what's included, **Restore Purchases**,
and links to **Terms of Use (EULA)** and **Privacy Policy**. The main paywall has all of this;
the school lock card has none of it. This is the single most likely rejection.

---

## 🟠 HIGH

### 4. Legacy screens still ship and are reachable via the notification
19 of the 25 screens in the `Screen` enum belong to the retired flow: `quiz`,
`weeklyAffirmation`, `morningSound`, `results`, `insightPreview`, `guidedPause`, `action`,
`win`, `flowCheckout`, `feedback`, `premiumHub`, `cycleComplete`, `move`, `mobilityFlow`,
`breathReset`, `morningPages`, `monthlyStory`, `firstWinPick`, `pathLearn`.
They carry old branding and an old paywall context ("riseAndFlow", "Unlock all three features").

### 5. Spotify deep links still in the shipped build
`SoundLibrary` builds Spotify search URLs and `LSApplicationQueriesSchemes` declares `spotify`.
Only reachable through the legacy flow. Either remove it, or keep it and be ready to justify it.

### 6. Background audio mode (2.5.4)
`UIBackgroundModes: audio` is legitimate for the night soundscape (it really does play audio).
The risk is the **morning alarm built on that keepalive** — a timer that fires while the app is
kept alive by audio. Apple rejects `audio` used purely to stay alive. Decide before submitting:
ship the night soundscape as an audio feature (defensible) and be careful how the alarm is
described, or drop the alarm-through-keepalive for 2.0.

### 7. Practice content is English-only, app declares en/tr/es
`CFBundleLocalizations = en, tr, es`. The interface is localised, but all 250 routines,
teachings and sources are English. A Turkish or Spanish user gets an English school.
Either ship English-only for 2.0, or state the limitation in the localised descriptions.

---

## 🟡 POLISH

8. **Widget** still shows the old ritual streak/mantra, not practice progress or the orb.
9. **AlarmKit** code remains (`AlarmKitWakeScheduler`) though the entitlement isn't provisioned;
   it is correctly never instantiated (`AlarmBackend` returns the notification scheduler), so it is
   dead code rather than a runtime risk.
10. **First Win** habit still occupies space in Wins beneath the new practice progress.

---

## Verified GOOD (no action)

- ✅ No account or sign-in required — reviewer can reach everything immediately (5.1.1 safe)
- ✅ Ten free routines (one per school) — reviewer can experience the full loop without paying
- ✅ Main paywall has price, duration, renewal terms, Restore, Terms and Privacy links
- ✅ Selfie check-in is on-device (Core Image), never stored or uploaded — "Data Not Collected" holds
- ✅ Speech guidance uses the system synthesiser — **no microphone permission requested**
- ✅ Safety notes: 169 across the content; Cold & Heat has one on all 25 routines, forbids
  breath-holds in/near water; breath school warns on kapalabhati/bhastrika
- ✅ Traditional practices explicitly labelled traditional, with a non-medical statement and
  NCCIH's position quoted for Reiki
- ✅ `ITSAppUsesNonExemptEncryption = NO` already set
- ✅ Full unit + UI suite green; content audit 0 blocking issues

---

## 🔴 BLOCKER 12 — the pricing ladder is broken (found before prices were set)

| Purchase | Price / mo | What you get |
|---|---|---|
| Foundations | $4.99 | 5 schools |
| Deep | $7.99 | 5 schools |
| **Both tiers** | **$12.98** | **all 10 schools** |
| **All-Access** | **$17.99** | **all 10 schools** |

**All-Access is strictly dominated** — it costs $5.01/month more for identical content.
A rational user never buys it. The annual ($99.99 ≈ $8.33/mo) is fine and remains the best value;
it's the *monthly* All-Access rung that is broken.

Fix options (pick one before setting prices in ASC):
1. **Raise the tiers** so the sum exceeds All-Access — e.g. Foundations **$8.99** + Deep **$10.99**
   = $19.98 > $17.99. Each tier is ~half the content at ~55% of the bundle price — standard bundle math.
2. **Lower All-Access monthly** to ~$11.99 so it beats buying both.
3. **Give All-Access something extra** (all future schools, everything unlocked as content grows).

Recommended: **option 1** — it protects the premium positioning you chose, and it's the only one
that needs no change to the already-APPROVED All-Access products.

## Market context (partial — research was cut short by the usage limit)

From the one benchmark that completed (journaling/Stoic category, 13 apps):
- Category annual median **$45–50**; meditation apps sit **$69.99–79.99**.
  **$99.99/yr is at or above the top of the market** — defensible only if the 250-routine,
  ten-tradition library is presented as the reason.
- **7-day trial is the universal standard** in this category — no 3-day, no 14-day found.
  Ours matches (annual only, which is also the common conversion tactic).
- **Tiering is spreading**, and successful apps tier by *added capability*, not by splitting
  the core library in half — worth remembering if option 1 above feels arbitrary to users.
- Free tiers that win are generous: Finch (741K ratings) makes its paid tier almost entirely
  cosmetic. Our "one free routine in every school" is defensible but on the stingier side.


---

## Fixes applied (19 Aug)

- **1 ✅** Permission strings rewritten for Energy Reset — camera string now describes the optional
  check-in and states the photo is never saved and never leaves the device.
- **2 ✅** The daily reminder and the `morningreset://start` URL now open **Today**, not the retired
  ritual. The legacy flow is no longer reachable from a notification.
- **3 ✅** Tier purchase surface is now 3.1.2-compliant: tier name, **price per month**, what it
  unlocks, auto-renewal disclosure, **Restore**, **Terms of Use** and **Privacy Policy**.
- **12 ✅** Pricing ladder fixed by **adding value to All-Access** rather than repricing, so the two
  APPROVED products stay untouched:
  - **Night soundscapes** — one free, the rest All-Access. This lives *outside* the ten schools,
    so buying both tiers no longer equals All-Access.
  - **Full practice history** — free and tier users see the last 7 sessions; All-Access sees all.
  - **Every future school and routine** included.
  Paywall, Schools tab and the tier lock card all state the difference plainly.
