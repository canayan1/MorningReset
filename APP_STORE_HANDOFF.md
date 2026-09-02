# Morning Reset App Store Handoff

This file is the manual checklist for shipping `Morning Reset` to the App Store.

## Current release values

- App name: `Morning Reset`
- Bundle identifier: `com.canayan.MorningReset`
- Version (MARKETING_VERSION): `1.1`
- Build (CURRENT_PROJECT_VERSION): `4`  (bumped for this update; increment again if `4` was already uploaded)
- Platform: iPhone only
- Minimum iOS version: `17.6`  (app target; note the unit/UI-test targets are set to 26.4 — that does not affect the shipped app)
- Privacy URL: `https://canayan-ios-apps.vercel.app/apps/morning-reset/privacy`
- Support URL: `https://canayan-ios-apps.vercel.app/apps/morning-reset/support`
  (pages live in the `canayanIOSapps` Next.js site — see Manual step 1)
- Subscription product ID: `com.canayan.MorningReset.premium.annual`
- Subscription price: `$99.99 / year` (premium top-band)
- Subscription offer: annual plan with `7-day free trial`

## Build 4 — design pass (this update)

- App-wide UI redesign enforcing four rules on every screen: one clear primary
  button (shared `.primaryCTA()` gold capsule), text density ≤ 20%, no flat/white
  background (shared living `AppBackground()` aura everywhere), symmetric/centered
  composition. See the `design-rules` memory.
- Paywall trimmed from ~45% → ~20% text; onboarding "building" percent counter
  fixed; `AuraBackground` now pauses under `-uiTesting` (XCUITest reliability).
- **All App Store assets regenerated against the new design:**
  `AppStoreAssets/screenshots_en|_tr|_es` (6 each, 9:41 status bar),
  `AppStoreAssets/onboarding` (PA01–PA05), and `AppStoreAssets/AppPreview_6.9.mp4`
  (1320×2868, H.264, 29.9 s).
- Full unit + UI suite green; device build installed and launched.

## What is already handled in the repo

- App icon asset set exists in the Xcode project.
- Privacy policy and support pages exist under `docs/`.
- The app links to the same privacy and support URLs shown above.
- Home-screen + lock-screen widget (StreakWidget) wired with App Groups.
- Live Activity (`WakeLiveActivity`) wired: lock-screen + Dynamic Island UI,
  reconciled on every app foreground so it appears at bedtime for next morning.
- The project declares `ITSAppUsesNonExemptEncryption = NO`.
- `NSSupportsLiveActivities` + frequent updates flag enabled in Info.plist.
- Build, unit tests, UI tests, and the full test pass all succeed locally.

## Reviewer notes — Live Activity behavior

Morning Reset uses ActivityKit to put a single Live Activity on the lock
screen each night the user has a wake time saved. The Activity is
reconciled on app foreground: started only when the user is within
~11 hours of their next wake fire date (so it does not expire before
morning), and ended when the user begins the flow. No remote push,
no frequent background updates — purely local state.

## Reviewer notes — Background audio mode

Morning Reset declares `UIBackgroundModes: audio` for one specific use:
during the morning ritual flow (from the moment the user taps the Live
Activity / notification until they reach the first-win screen), the app
plays a soft ambient pad and subtle chime. The audio session starts
ONLY after explicit user entry into the flow, not in the background or
overnight. The session is deactivated immediately when:
- the user completes the flow (after the win crescendo fade-out), or
- the user returns to the home screen, or
- the user dismisses the flow at any point.

There is no silent background playback to keep the app alive, no remote
audio, no media downloads, no music. This matches the standard
meditation / morning-ritual audio pattern.

## What I still cannot do from inside the repo

These steps need your Apple or GitHub account session, so you must do them manually:

- turn on GitHub Pages in the GitHub repository settings
- create or edit the App Store Connect app record
- complete App Privacy and export compliance forms in App Store Connect
- create the subscription in App Store Connect
- upload screenshots to App Store Connect
- archive and upload a signed build with your Apple team credentials
- submit the app and subscription for review

Everything else around those steps can be prepared in code or docs here.

## Copy-paste App Store metadata

### English

- Name: `Morning Reset`
- Subtitle: `Own the first three minutes`
- Promotional text: `Keep your usual alarm. Morning Reset waits on your lock screen, ready to greet you when you reach for your phone.`
- Keywords: `morning routine,focus,habit,wellbeing,productivity,intention,wake up,scrolling`
- Description:

`Morning Reset is designed for the morning you reach for your phone.

Keep using your trusted alarm. From the night you set it, Morning Reset waits on your lock screen, ready to greet you when you turn on the screen.

Tap it before anything else. In about two minutes, the app guides you through:
- five quick yes/no questions
- one clear morning mode
- one short reflection or pattern read
- one concrete first win to do right away

Not a feed. Not a productivity system. A small ritual that wins the first three minutes of your day before reactive phone use takes over.

The core ritual is fully usable for free. Premium only unlocks deeper follow-up tools already present in the app: fuller pattern insight, a guided pause, Rise & Flow (guided movement reset), Breath Reset (guided breathing), and Morning Pages (freewriting prompt).

Morning Reset includes optional breathing and mobility exercises. These are not a substitute for professional medical advice. Consult your doctor before starting any exercise programme, especially if you have a health condition. Stop immediately if you feel pain or discomfort.`

### Turkish

- Name: `Morning Reset`
- Subtitle: `Günün ilk üç dakikasını kazan`
- Promotional text: `Normal alarmını kullan. Morning Reset kilit ekranında bekler, telefonu eline aldığında seni karşılamaya hazır.`
- Keywords: `sabah rutini,odak,alışkanlık,iyi oluş,üretkenlik,niyet,uyanma,scroll`
- Description:

`Morning Reset, telefonu eline uzandığın sabah için tasarlandı.

Güvendiğin alarmını kullanmaya devam et. Ayarladığın geceden itibaren Morning Reset kilit ekranında bekler — sabah ekranı açtığında seni karşılamaya hazır.

Başka bir şeyden önce ona dokun. Uygulama yaklaşık iki dakika içinde sana şunlarda eşlik eder:
- beş hızlı evet/hayır sorusu
- net bir sabah modu
- kısa bir yansıma ya da örüntü okuması
- hemen yapabileceğin tek bir somut ilk kazanım

Bir akış değil. Bir üretkenlik sistemi değil. Tepkisel telefon kullanımı başlamadan önce günün ilk üç dakikasını kazanan küçük bir ritüel.

Çekirdek ritüel ücretsiz ve tamdır. Premium yalnızca uygulamada zaten bulunan daha derin takip araçlarını açar: daha dolu örüntü içgörüsü, rehberli duraklama, Rise & Flow (rehberli hareket), Breath Reset (rehberli nefes) ve Morning Pages (serbest yazma).

Morning Reset, isteğe bağlı nefes ve hareketlilik egzersizleri içerir. Bunlar profesyonel tıbbi tavsiyenin yerini tutmaz. Mevcut bir sağlık durumunuz varsa egzersiz programına başlamadan önce doktorunuza danışın. Ağrı veya rahatsızlık hissederseniz hemen durun.`

### Spanish

- Name: `Morning Reset`
- Subtitle: `Gana los primeros 3 minutos`
- Promotional text: `Mantén tu alarma. Morning Reset espera en tu pantalla bloqueada, listo para recibirte cuando tomas el teléfono.`
- Keywords: `rutina matinal,enfoque,hábito,bienestar,productividad,intención,despertar,scroll`
- Description:

`Morning Reset está diseñado para la mañana en que tomas el teléfono.

Sigue usando tu alarma de siempre. Desde la noche que la configuras, Morning Reset espera en tu pantalla bloqueada — listo para recibirte cuando enciendes la pantalla por la mañana.

Tócalo antes que nada. En unos dos minutos, la app te guía por:
- cinco preguntas rápidas de sí o no
- un modo matinal claro
- una breve reflexión o lectura de patrón
- una primera victoria concreta para hacer de inmediato

No es un feed. No es un sistema de productividad. Un pequeño ritual que gana los primeros tres minutos del día antes de que empiece el uso reactivo del teléfono.

El ritual principal se puede usar completo gratis. Premium solo desbloquea herramientas de seguimiento más profundas que ya existen en la app: una lectura de patrón más completa, una pausa guiada, Rise & Flow (movimiento guiado), Breath Reset (respiración guiada) y Morning Pages (escritura libre).

Morning Reset incluye ejercicios opcionales de respiración y movilidad. No sustituyen el consejo médico profesional. Consulta a tu médico antes de comenzar cualquier programa de ejercicio, especialmente si tienes alguna condición de salud. Detente de inmediato si sientes dolor o malestar.`

## Manual step 1 — Put privacy and support pages live

The app and App Store metadata now expect these two URLs to be live:

- `https://canayan1.github.io/MorningReset/privacy-policy.html`
- `https://canayan1.github.io/MorningReset/support.html`

### Easiest path: GitHub Pages with the included workflow

1. Push this repo to GitHub.
2. Open the repo on GitHub.
3. Go to `Settings -> Pages`.
4. Under build/deployment, set the source to `GitHub Actions`.
5. Push the branch that will become your public release branch to `main`.
6. Open the `Actions` tab and wait for `Deploy Pages` to finish successfully.
7. Visit:
   - `https://canayan1.github.io/MorningReset/`
   - `https://canayan1.github.io/MorningReset/privacy-policy.html`
   - `https://canayan1.github.io/MorningReset/support.html`
8. Confirm all three pages load without a GitHub 404.

### If you want to keep `setup` as your working branch

1. Merge the release-ready docs changes into `main`.
2. Push `main`.
3. Let the GitHub Pages workflow publish from `main`.

Do not enter the privacy/support URLs into App Store Connect until those pages are actually reachable.

## Manual step 2 — Create or verify the App Store Connect app record

In App Store Connect:

1. Create the app record if it does not exist.
2. Use bundle ID `com.canayan.MorningReset`.
3. Pick a stable SKU that you will keep forever. Example: `morningreset-ios-1`.
4. Confirm the platform is iOS.
5. Confirm the app is iPhone-only.

Use the canonical, trilingual copy from the "Copy-paste App Store metadata"
section above (do not retype it here — that section is the single source of
truth so the subtitle/promo text stay consistent across languages):

- Name: `Morning Reset`
- Subtitle: `Own the first three minutes`
- Promotional text: `Keep your usual alarm. Morning Reset waits on your lock screen, ready to greet you when you reach for your phone.`
- Support URL: `https://canayan1.github.io/MorningReset/support.html`
- Privacy Policy URL: `https://canayan1.github.io/MorningReset/privacy-policy.html`

When you create version `1.0`:

1. Paste the long description from the README.
2. Paste the review notes from `/Users/can/Projects/MorningReset/BUILD_CHECKLIST.md`.
3. Keep the positioning honest:
   - call it a Live Activity + notification-led morning ritual
   - it does NOT replace the system alarm — it meets the user on the lock screen the moment they wake up
   - do not mention login, sync, analytics, or non-shipping features

## Manual step 3 — Complete App Privacy

The codebase currently indicates:

- no third-party analytics
- no ad SDKs
- no tracking
- no account creation
- local on-device state only

Recommended App Privacy answer, based on the current repo:

- `Data Not Collected`

Only use that answer if you have not added any SDKs or remote data collection outside this repo.

If you later add analytics, crash collection beyond Apple defaults, account sync, or server logging, you must update both:

- App Store Connect privacy answers
- `/Users/can/Projects/MorningReset/PrivacyPolicy.md`

## Manual step 4 — Complete export compliance

The project now sets `ITSAppUsesNonExemptEncryption = NO`.

That means the app declares that it does not use non-exempt proprietary encryption. If App Store Connect still asks export questions:

1. Answer based on the app as shipped today, not future plans.
2. Do not claim custom encryption.
3. If the questionnaire appears, keep your answers consistent with the project setting above.

If you later add your own crypto library, VPN behavior, or custom secure transport, revisit this answer before submitting.

## Manual step 5 — Create the subscriptions in App Store Connect

Create **two** auto-renewable subscriptions in the **same subscription group**
(`Morning Reset Premium`). The app's paywall shows both as a plan picker with the
annual pre-selected and badged "BEST VALUE". Both are already in the local
`.storekit` for testing.

**Plan 1 — Annual (hero plan, with trial):**

- Product ID: `com.canayan.MorningReset.premium.annual`
- Reference name: `Morning Reset Premium Annual`
- Duration: `1 year`
- **Price: `$99.99 / year`** (premium top-band — Morning Reset combines a morning
  ritual + guided energy practices + the on-device energy read in one app; this
  sits at the top of the mainstream wellbeing band, below the $129–150 premium
  breathwork outliers.)
- Introductory offer: `7-day free trial` (on this annual plan only)

**Plan 2 — Monthly (anchor plan, no trial):**

- Product ID: `com.canayan.MorningReset.premium.monthly`
- Reference name: `Morning Reset Premium Monthly`
- Duration: `1 month`
- **Price: `≈ €18 / month` (the `$17.99` USD tier)** — deliberately high so the
  $99.99 annual reads as a strong discount (~55% off vs paying monthly).
- Introductory offer: none

To see both plans while testing in the simulator: Xcode → Edit Scheme → Run →
Options → **StoreKit Configuration → `MorningReset.storekit`**, then run and open
the paywall. On a real device the paywall shows whatever is live in App Store
Connect, so add the monthly product there to see both plans on device.

Suggested English display copy:

- Display name: `Morning Reset Premium Annual`
- Description: `Premium unlocks the deeper layer: fuller weekly pattern insight, a guided pause, Rise & Flow (guided 5-minute movement reset), Breath Reset (guided breathing), and Morning Pages (freewriting prompt). The core morning ritual and energy read stay free.`

Important:

1. Match the product ID exactly.
2. Match the 7-day free trial exactly.
3. Submit the subscription together with the app if App Store Connect asks for it.
4. Verify the paywall only promises these extras:
   - fuller pattern insight
   - guided pause
   - Rise & Flow
   - Breath Reset
   - Morning Pages

## Manual step 6 — Upload screenshots

### Generated assets (already produced in this repo)

Real 6.9-inch (1320×2868) assets are checked in under `AppStoreAssets/`:

- `AppStoreAssets/screenshots_en/01_WakeHome.png` … `06_Checkout.png` — six English
  product-page screenshots straight from the running app.
- `AppStoreAssets/AppPreview_6.9.mp4` — a ~27s App Preview video (H.264, 30fps,
  1320×2868) walking the morning ritual. Within App Store Connect spec for the 6.9" slot.

To regenerate after UI changes (capture runs on `iPhone 17 Pro Max`):

```
xcodebuild test \
  -project MorningReset/MorningReset.xcodeproj -scheme MorningReset \
  -destination 'id=<iPhone 17 Pro Max sim udid>' -parallel-testing-enabled NO \
  -only-testing:MorningResetUITests/MorningResetUITests/testCaptureAppStoreScreenshots \
  -resultBundlePath /tmp/shots.xcresult
xcrun xcresulttool export attachments --path /tmp/shots.xcresult --output-path /tmp/shots_out
```

For Turkish/Spanish localized screenshots, change the language in
`testCaptureAppStoreScreenshots` (`launchApp(language:region:)`) and re-run.

### Apple's requirement

Apple’s current screenshot reference says iPhone apps need 6.9-inch screenshots, or 6.5-inch if 6.9-inch is not provided. The easiest path is:

1. Use a current large iPhone simulator such as `iPhone 17 Pro Max`.
2. Capture screenshots in portrait.
3. Upload `1` to `10` screenshots for the iPhone product page.

Recommended screenshot set:

1. Onboarding promise
2. Schedule setup
3. Wake home
4. Quiz
5. Results with first win
6. Action or Win screen

If you localize the App Store page into Turkish and Spanish, upload matching localized screenshots too.

Suggested screenshot story:

1. `A calmer first minute`
   Show onboarding or wake-home promise.
2. `Use your normal alarm`
   Show schedule setup with the notification disclaimer visible.
3. `Five fast questions`
   Show the one-question quiz flow.
4. `Know your morning mode`
   Show the results screen.
5. `Choose one first win`
   Show first-win selection or action focus.
6. `Finish before the scroll starts`
   Show win or check-out.

## Manual step 7 — Archive and upload the build

In Xcode:

1. Open `/Users/can/Projects/MorningReset/MorningReset/MorningReset.xcodeproj`.
2. Select the `MorningReset` scheme.
3. Select `Any iOS Device (arm64)`.
4. Confirm version/build:
   - Version `1.1`
   - Build `3` (or the next unused build number if `3` was already used in TestFlight)
5. Run `Product -> Archive`.
6. In Organizer, choose `Distribute App`.
7. Choose `App Store Connect`.
8. Upload the archive.
9. Wait for processing to finish in App Store Connect.

## Manual step 8 — Run the last human checks before Submit for Review

Do these checks yourself even though automated tests are green:

1. Open the privacy URL in a normal browser and confirm it loads.
2. Open the support URL in a normal browser and confirm it loads.
3. Install the TestFlight build on a real iPhone.
4. Verify notification permission flow on a real device.
5. Verify the app copy never implies alarm-like behavior when the phone is muted or Focus hides alerts.
6. Verify purchase, restore, and trial messaging with a Sandbox Apple Account.
7. Confirm the paywall links open:
   - Terms of Use
   - Privacy Policy
   - Support

## Manual step 9 — Submit for review

Before pressing submit:

1. Make sure the app record points to build `1.0 (1)`.
2. Make sure the subscription is attached if required.
3. Make sure screenshots are uploaded.
4. Make sure App Privacy is complete.
5. Make sure the review notes mention:
   - local notification, not alarm replacement
   - free core flow
   - no account or third-party tracking

## If something is rejected

Most likely rejection surfaces for this app are:

- metadata says “alarm” too strongly
- privacy/support URLs are dead
- subscription metadata does not match the paywall
- screenshots do not reflect the shipped flow

If that happens, fix the repo copy first, then fix App Store Connect, then resubmit so both stay aligned.
