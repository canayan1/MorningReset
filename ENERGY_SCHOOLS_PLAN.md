# Energy Reset — Schools content platform (build plan)

The app becomes a **school of energy practice**: 10 schools × 25 routines = **250 routines**,
each teaching *what it is, why it works, how to do it*. Free tier: **1 routine unlocked per school**
(10 free), the rest by tier subscription.

---

## 1. What a "school" is (structure per school)

Each school = a body of teaching, not just a list of timers:

| Layer | Content |
|-------|---------|
| **Overview** | What this tradition/discipline is, where it comes from, what it's for |
| **Teachings** | 3–5 short "learn" cards: core concepts, terminology, symbols/positions where relevant |
| **Routines (25)** | Individual practices: purpose · duration · step-by-step · what it's for |
| **Evidence note** | Honest framing: what research supports, what is traditional practice |

**Routine grouping inside a school:** `Starter` (free 1 + entry level) · `Core` · `Deep` · `Restorative`

---

## 2. The 10 schools (revised — practice-rich, teaching-led)

Grounded in real traditions + evidence. Each gets 25 routines.

| # | School | What it teaches | Notes |
|---|--------|-----------------|-------|
| 1 | **Reiki** | The system of Reiki: gassho, byosen, hand positions, self-treatment, the 5 precepts, symbol-adjacent practice (traditional framing) | Traditional practice, NOT medical |
| 2 | **Conscious Breathing** | Pranayama + modern breathwork: nadi shodhana, ujjayi, kapalabhati, box, physiological sigh, coherent | Strong evidence base |
| 3 | **Qigong** | Standing, Eight Brocades (Ba Duan Jin), Six Healing Sounds, energy-gathering forms | Traditional + moderate evidence |
| 4 | **Meditation** | Focused attention, open monitoring, body scan, loving-kindness, mantra, walking meditation | Strong evidence base |
| 5 | **Yoga & Mobility** | Sun salutations, spinal work, hip/shoulder openers, restorative poses | Strong evidence base |
| 6 | **Sound & Mantra** | Bhramari, Om/bija, chanting, humming, resonance, listening practice | Vagal/humming evidence + tradition |
| 7 | **Cold & Heat** | Cold exposure, contrast, sauna-style heat, breath-with-cold safety | Emerging evidence, safety-first |
| 8 | **Sleep & Rest** | Yoga nidra / NSDR, wind-down, sleep hygiene, restorative rest | Strong (sleep) |
| 9 | **Nature & Light** | Circadian light, forest bathing (shinrin-yoku), grounding walks, sky-gazing | Moderate evidence |
| 10 | **Mind & Journal** | Gratitude, expressive writing, intention, morning pages, reflection, visualization | Moderate/strong evidence |

*(Replaces the earlier 10 — richer, more "school"-like, and includes Reiki as its own school per the founder's direction.)*

---

## 3. Content quality bar (non-negotiable)

- Every routine researched from **elite, reliable sources** (peer-reviewed research; recognized
  traditional lineages/teaching bodies for the traditional schools).
- **Experiential framing** — no medical claims, no cure language. Traditional practices are
  labeled as traditional, not evidence-based.
- **Safety notes** where warranted (cold, breath retention, pregnancy, heart conditions).
- Consistent voice: calm, plain, instructional. English only for 2.0.

---

## 4. Onboarding rework

New flow: **welcome → see the 10 energy schools → pick what draws you → (optional) reminder setup → plan → paywall**
- Schools are shown **first** (the app's core value), not the quiz.
- Reminder is **opt-in**: "Want to practice at the same time each day? We'll remind you." → time picker → notification.
- Remove the leftover morning-only framing.

---

## 5. Build sequence

| Step | Work |
|------|------|
| **A** | Data model v2: `School` (overview, teachings, routines), `Routine` (group, purpose, steps, duration, safety), free-routine flag |
| **B** | Research + author content, **school by school** (agents, elite sources, verified) |
| **C** | UI: school overview + teachings + routine list (grouped) + routine player with steps |
| **D** | Onboarding rework (schools first + optional reminder) |
| **E** | Regular audits: content accuracy, no medical claims, build/tests green, design rules |

**Cadence:** one school at a time — research → write → review → integrate → audit. The founder reviews
regularly; Claude audits every step.

---

*Living document — updated as we build.*
