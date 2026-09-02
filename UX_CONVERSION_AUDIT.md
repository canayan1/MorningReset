# Energy Reset — UX & conversion audit

Audited against the shipped 2.0 build. Competitor A/B specifics could not be researched
(weekly usage limit) — everything below is measured from our own funnel plus established
subscription-app patterns. Marked ⚠️ where a claim is pattern-based rather than researched.

---

## 1. The funnel is too long before value

**Fresh install → first practice = 8 interactions + a 9-second forced wait.**

| # | Screen | Cost |
|---|--------|------|
| 1 | Hook slide 1 | tap |
| 2 | Hook slide 2 | tap |
| 3 | Orb intro | tap |
| 4 | Ten schools | tap (a real, good choice) |
| 5 | "Building your routine" | **9s wait, no input** |
| 6 | Plan ready | tap |
| 7 | **Paywall** | tap to dismiss |
| 8 | Reminder setup | tap |
| 9 | Home → Start today's practice | **first practice** |

### 🔴 1a. The paywall fires before the user has practised once
We ask for money before delivering any value. The user has read about practice but never
felt it. It is dismissible ("Continue without Premium"), so it won't be rejected — but it is
the weakest possible moment to convert, and it costs goodwill on first run. ⚠️

**Recommendation:** move the first practice *before* the paywall.
After picking a school → "Try your first practice now" → run the free routine → orb grows →
*then* the paywall, framed as "keep going". The user has felt the product and seen the orb move.

### 🔴 1b. The "building your routine" screen is now theatre with no input
It animates for 9 seconds saying *"Opening Pranayama… Laying out your routines… Picking your
first routine…"* — but the personalisation quiz was removed, so **nothing is being computed**.
The user picked a school one tap earlier; we're simulating work we don't do.

A labour-illusion loader is a legitimate pattern **when there is something to compute**. Here
there isn't. Options, best first:
1. **Cut it** — go straight from school choice to the plan. Fastest, most honest.
2. **Shorten to ~3s** and reword to what actually happens ("Setting up your school").
3. **Give it real input** — ask one question (time of day / how long you have) and use it.

### 🟠 1c. Reminder setup sits between the paywall and the app
Another gate before the user reaches Today. It should come *after* the first practice, or move
into the menu entirely (it's already optional).

---

## 2. Paywall: the cheapest entry point is invisible

The main paywall sells **only All-Access** ($17.99/mo, $99.99/yr) — `subscriptionProducts()`
returns just the two All-Access SKUs. The **$4.99 Foundations tier is only purchasable inside a
locked school**.

So a user who balks at $99.99 sees no cheaper option and leaves. The entry-level price exists
but never appears at the moment of highest intent. ⚠️

**Recommendation:** show a third, lighter option on the paywall — "Just one tier, from $4.99/mo"
— either as a real purchase row or a link into the tier chooser. Anchoring $99.99 against
$4.99 also makes All-Access read as the considered middle, not the ceiling.

### What the paywall does well
- ✅ Annual first with the trial line and the post-trial billing line
- ✅ Restore, Terms and Privacy present
- ✅ Dismissible in every context
- ✅ Copy now sells the real product (ten schools, 250 routines)

### Missing, in rough order of expected value ⚠️
1. **No "what happens next" trial timeline** (today free → day 5 reminder → day 7 billed).
   This is the single most common addition in high-converting subscription paywalls.
2. **No social proof** — no rating, no count, no testimonial. Nothing to borrow trust from.
3. **No value framing against the price** — "$99.99/yr" alone is a big number; "less than a
   single class" or "250 routines" reframes it.
4. **No annual/monthly savings maths** — annual is 54% cheaper per month than monthly and we
   never say so.

---

## 3. Ease of use — mostly good

**Working well**
- ✅ Four tabs, each with one clear job
- ✅ Home is now four elements: orb, today's practice, optional check-in, one button
- ✅ Library search + length filters make 250 routines navigable
- ✅ No account, no sign-in, nothing to configure before use
- ✅ Nothing truncates; long practice names wrap

**Friction found**
- 🟠 **School detail is a long scroll**: overview + framing + 5 teachings + 25 routines + sources.
  The routines — the thing you came for — are below all the teaching. Consider a segmented
  control (Practise | Learn) or putting Starter routines above the teachings.
- 🟠 **No way to browse schools before onboarding commits you.** The picker asks you to choose
  from ten unfamiliar names (Bhavana? Löyly?) with only a 3-word subtitle. A "not sure — show me"
  option that picks a sensible default would reduce choice paralysis. ⚠️
- 🟡 **The orb's meaning isn't visible on the home screen** beyond a level word. A tap could
  explain what it counts and what's next.
- 🟡 **Wins tab mixes two systems** — practice progress on top, legacy First Win below.

---

## 4. Onboarding: strong idea, weak sequencing

**Strong:** the ten-school grid is a genuinely good moment — real choice, beautiful, and it makes
the product's promise concrete. The orb intro gives the streak mechanic meaning *before* it
starts, which is the right order.

**Weak:** everything after the school pick is delay. Building (9s theatre) → plan (repeats what
they just chose) → paywall (before value) → reminder (another form).

**Proposed sequence**
1. Hook (cut to **one** slide)
2. Orb intro *(keep — it sets the mechanic)*
3. Ten schools *(keep — the best screen)*
4. **First practice, right now** — the free routine, guided
5. Orb grows — the payoff moment
6. **Paywall** — "keep going" at peak felt value
7. Reminder — optional, one tap, skippable

That's 3 screens before practice instead of 6, and the paywall lands after the user has felt
something rather than before.

---

## 5. Priority

| Priority | Change | Why |
|---|---|---|
| **1** | First practice before the paywall | Biggest conversion + retention lever |
| **2** | Cut or shorten the 9s fake loader | It's dishonest now and costs 9s of attention |
| **3** | Offer the $4.99 tier on the paywall | Cheapest entry currently invisible |
| **4** | Trial timeline + annual savings on the paywall | Standard, cheap to add |
| **5** | Practise/Learn split in school detail | Routines are buried under teaching |
| **6** | Move reminder setup out of the funnel | Removes a gate |

⚠️ Items marked with a caution flag are based on established subscription-app patterns, not on
researched competitor A/B results — that research was cut short by the usage limit and should be
completed before treating the ordering as settled.


---

## Implemented (21 Aug)

**1 ✅ First practice now happens before the paywall.**
New sequence: hook (**one** slide) → orb intro → ten schools → **first practice** → payoff → paywall.
After picking a school the user is offered that school's free routine — *"Let's do one now… Free, and
yours to keep. Your orb starts here."* — with a "Later" escape. The paywall now lands after the user
has practised and watched the orb light up, instead of before they've felt anything.

**2 ✅ The 9-second fake loader is gone.**
Deleted outright rather than shortened: with the quiz removed there was nothing to compute, so the
"engine" was simulating work it wasn't doing. The plan screen it fed is now the payoff screen —
it shows the orb with its first light in it.

**3 ✅ The cheapest entry point is on the paywall.**
The paywall now loads the tier products too and shows *"Only want one tier? From $4.99/mo"*,
expanding to Foundations and Deep with prices and one-tap purchase. The $4.99 anchor also reframes
All-Access as the considered middle rather than the ceiling.

Funnel before: 8 interactions + 9s wait before the first practice.
Funnel now: **3 screens, then practise.**

Still open from this audit: trial timeline + annual savings maths on the paywall (4),
Practise/Learn split in school detail (5), reminder setup out of the funnel (6).
