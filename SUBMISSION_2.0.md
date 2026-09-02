# Energy Reset 2.0 — submission checklist

**State today:** 1.2 is live (READY_FOR_SALE). Annual + monthly subscriptions APPROVED.
The two tier subscriptions are **MISSING_METADATA** (no price). Repo is at 1.2 build 4 —
must bump to 2.0 because 1.2 is already released.

Legend: 🤖 = Claude can do it · 👤 = only you can do it (account-bound / judgement)

---

## PHASE 1 — Before anything is uploaded

### 👤 1. Set every price  ← blocks purchases
App Store Connect → **Monetization → Subscriptions**. All four need to move together —
the ladder set during 1.x is incoherent (yearly cost barely more than one month, and each
tier cost more per year than All-Access while giving half the schools).

| Product | Was | Set to |
|---|---|---|
| All-Access Annual | $19.99 | **$59.99** |
| All-Access Monthly | $17.99 | **$12.99** |
| Foundations Monthly | $4.99 | **$2.99** |
| Deep Monthly | $7.99 | **$3.99** |

At these numbers the yearly plan reads as "$5.00 a month" and honestly claims a 62% saving,
and a single tier is finally cheaper than All-Access rather than dearer.

Each tier also needs **Availability** set (territories) — without it the product stays
*Missing Metadata* even once priced.
(Apple's API rejects subscription pricing; this genuinely cannot be automated.)

### 👤 2. Decide the app name and check availability
Proposed: **Energy Reset: Daily Rituals** (≤30 chars), subtitle **Reset your energy in 30 days** (≤30).
App Store names must be unique — if taken, ASC will reject it when you save. Fallbacks:
*Energy Reset — Daily Practice* · *Energy Reset: Practice Daily*.

### 👤 3. Confirm the free/paid model reads fairly
Free: one routine in every school (10 free routines) + the daily loop + optional check-in.
Paid: Foundations $2.99/mo · Deep $3.99/mo · All-Access $12.99/mo or $59.99/yr (7-day trial on annual).

---

## PHASE 2 — Build and metadata

### 🤖 4. Bump to 2.0, archive, upload
Version **2.0**, build **5**. Archive → export → upload via the API key.

### 🤖 5. Fresh screenshots (6.9") + App Preview
New UI: orb home · schools · a school with teachings · routine player · library · progress.

### 🤖 6. Push metadata via API
Name, subtitle, promotional text, description, keywords, What's New.

---

## PHASE 3 — Only in the web UI (👤)

### 7. Attach the in-app purchases to the 2.0 version
Version page → **In-App Purchases and Subscriptions** → **+** → add *Foundations Monthly*,
*Deep Monthly* (annual/monthly All-Access already exist). Without this the new tiers are not reviewed.

### 8. App Privacy — re-confirm
Should remain **Data Not Collected**: the selfie energy read is processed on device and never
uploaded; the practice log is local (UserDefaults); no analytics, no backend, no accounts.
If Apple asks about the camera: *used only for an on-device reading; the image never leaves the device.*

### 9. Age rating
Recommended **4+**. Answer *None* to all content questions. It is not a medical app;
do not tick medical/treatment information.

### 10. Export compliance
**No** — the app uses no non-exempt encryption (`ITSAppUsesNonExemptEncryption = NO` is already set).

### 11. Review notes (paste this)
> Energy Reset is a daily practice app built around ten "schools" of energy practice.
> No account or login is required — all features are reachable immediately.
> Every school includes one free routine, so the reviewer can try the full experience without paying.
> Paid tiers unlock the remaining routines.
> Content framing: practices are presented experientially. Traditional practices (Reiki, Qigong,
> Nada Yoga) are explicitly labelled as traditional, and the app states plainly that they are not
> medical treatment. Evidence-based schools cite their sources in-app. No health claims, no
> diagnosis, no treatment claims. Routines involving cold, heat, breath retention or physical
> movement carry explicit safety notes and contraindications.
> The optional "energy check-in" uses the front camera; the image is analysed on device with
> Core Image and is never stored, uploaded or transmitted.
> Voice guidance uses the system speech synthesiser; no microphone access is requested.

### 12. Submit for Review
Version page → **Add for Review** → **Submit**.
Release option: recommended **Manually release this version** so you control the launch.

---

## Risk notes (worth knowing before you submit)

1. **Guideline 2.1 / IAP metadata** — the two new tiers must have a price, a localised display
   name and description, and a review screenshot (all present except price). Missing price = rejection.
2. **Guideline 1.4.1 / physical harm** — a wellness app with cold exposure and breathwork gets
   read carefully. Our Cold & Heat school carries contraindications on all 25 routines, forbids
   breath-holds in water, and the breath school warns on kapalabhati/bhastrika. Keep it that way.
3. **Guideline 2.3.1 / accurate metadata** — do not describe the app as improving health
   conditions. "Reset your energy" is experiential; "reduces anxiety" would not be.
4. **Reiki** — presented as a traditional practice with an explicit non-medical statement and the
   NCCIH position quoted. This is the defensible framing.
5. **1.2 is live** — if 2.0 is rejected, 1.2 stays on sale; nothing is lost.

---

## Your shortest path

1. Set the two prices (👤, 2 minutes)
2. Tell Claude to run Phase 2 (🤖 build + screenshots + metadata)
3. Do Phase 3 in the web UI (👤, ~15 minutes) and press Submit
