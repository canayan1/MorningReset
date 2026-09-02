# Energy Reset — product vision (2.0 pivot)

Pivot from **Morning Reset** (a morning ritual app) to **Energy Reset** — an all-day,
evidence-based energy-practice platform with a 30-day reset promise and à-la-carte "schools."

---

## 1. Positioning

- **Promise:** *"Reset your energy in 30 days."* A daily energy practice you shape to your life.
- **All day, not just morning:** practices for morning lift, midday reset, and evening wind-down.
- **Optional check-in:** the "read your energy" check-in becomes **on-demand** (a button any time),
  never a forced gate. Open the app → do a practice, or check in first if you want.
- **Schools:** structured, multi-session practice tracks you can unlock individually or all-access.

### Name (App Store)
- **App name (≤30):** `Energy Reset: Daily Rituals`  ·  alt: `Energy Reset`, `Reset: Energy Rituals`
- **Subtitle (≤30):** `Reset your energy in 30 days`  ·  alt: `Daily energy rituals & work`
- Bundle ID stays `com.canayan.MorningReset` (rename is display-only; goes through review).

---

## 2. The 10 schools (evidence-based)

Each school = a track of short daily sessions (a 30-day arc + an open "daily" mode).
Framing is **experiential** ("energy / how you feel"), grounded in real research — **no medical claims**.

| # | School | What it is | Evidence base (honest) |
|---|--------|-----------|------------------------|
| 1 | **Breath** | Physiological sigh, slow/box breathing, CO₂-tolerance | Strong — breathwork ↓stress, HRV↑ (Balban 2023, Cell Rep Med) |
| 2 | **Light** | Morning light, daylight timing, evening dimming | Strong — circadian science |
| 3 | **Move** | Mobility flows, "exercise snacks," walks | Strong — activity & mood/energy |
| 4 | **Still** | Focused-attention & open-monitoring meditation | Strong — mindfulness research |
| 5 | **Sleep** | Wind-down, sleep hygiene, NSDR / yoga nidra | Strong (sleep) / emerging (NSDR) |
| 6 | **Cold** | Cold exposure, contrast showers | Moderate/emerging — alertness, mood (frame carefully) |
| 7 | **Sound** | Vagal humming (Bhramari), music for state, resonance | Mixed — slow-exhale/humming has vagal support; label the rest |
| 8 | **Nature** | "Green time," daylight walks, outdoor breaks | Moderate — nature-exposure studies (avoid "grounding/earthing" claims) |
| 9 | **Reflect** | Gratitude, expressive writing, morning pages | Moderate/strong — gratitude & expressive-writing research |
| 10 | **Fuel** | Hydration, caffeine timing, energy-aware eating rhythm | Moderate — hydration & caffeine-timing evidence |

**Separate "Traditions" bucket (NOT labeled evidence-based):** Reiki · Qigong · Nada Yoga —
the app's existing contemplative paths, kept clearly as *traditional practice, for experience not medicine*.

---

## 3. Monetization

The founder wants each school separately priced for access. Recommended **hybrid** (best conversion + honors that):

- **Free:** optional daily check-in + a rotating free daily practice + **one starter school** (e.g., Breath, first 3 days).
- **Single school:** `$4.99 / month` each — unlocks that one school. (à-la-carte, as requested.)
- **All-Access pass:** `$17.99 / month` or `$99.99 / year` (existing products) — all 10 schools + everything.
  Positioned as the obvious value vs. buying 2+ schools.

**App Store reality to decide:** 10 school subscriptions = 10 auto-renewable products in the group
(heavy to manage + review). Alternatives: (a) schools as **non-consumable one-time unlocks**
($9.99 each, own forever) instead of subs; (b) a smaller set of **tier bundles** (Foundations / Deep / All).
→ *Decision needed (see §6).* All-Access annual already exists and is APPROVED.

---

## 4. App structure changes

- **Tabs:** `Today` (schools + daily practice) · `Schools` (browse/unlock) · `Wins` · (check-in is a button, not a tab).
- **Optional check-in:** remove the forced quiz gate; "Read my energy" is a prominent optional action.
- **Per-school 30-day journey:** each school has a day-by-day arc + an "anytime" library of its sessions.
- **Home reframed:** "How's your energy right now?" → suggests a practice for the time of day (morning/mid/evening).

---

## 5. Integrity & App Store guardrails

- Keep the **experiential** frame everywhere ("energy / how you feel"), never diagnostic or curative.
- "Evidence-based" applies to the **10 schools** (real research). Traditions bucket stays "traditional practice."
- Each school shows a short, honest **"why it works"** with a source note — builds trust + defends the claim.
- Privacy stays **Data Not Collected** (practices are on-device content; check-in is on-device).
- Multiple subscriptions must each have a review screenshot + clear "what you get" — App Review scrutinizes IAP.

---

## 6. Sequencing & decisions

**Recommended sequencing:** ship **1.2 (Morning Reset)** as-is first (it's mid-submission), then build **2.0 (Energy Reset)**
as the pivot. Renaming + 10 IAPs mid-review would complicate the current submission.

**Decisions that gate the build:**
1. **Name** — confirm `Energy Reset: Daily Rituals` (or pick another).
2. **Monetization** — per-school subscriptions vs one-time unlocks vs tier bundles (+ keep All-Access).
3. **First build step** — (a) rename + reposition + optional check-in (small, shippable), then (b) schools engine, then (c) content for each school.

---

*Draft — for discussion. Nothing here is built yet.*
