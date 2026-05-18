# Morning Reset App Store Handoff

This file is the manual checklist for shipping `Morning Reset` to the App Store.

## Current release values

- App name: `Morning Reset`
- Bundle identifier: `com.canayan.MorningReset`
- Version: `1.0`
- Build: `1`
- Platform: iPhone only
- Minimum iOS version: `17.6`
- Privacy URL: `https://canayan1.github.io/MorningReset/privacy-policy.html`
- Support URL: `https://canayan1.github.io/MorningReset/support.html`
- Subscription product ID: `com.canayan.MorningReset.premium.annual`
- Subscription offer: annual plan with `7-day free trial`

## What is already handled in the repo

- App icon asset set exists in the Xcode project.
- Privacy policy and support pages exist under `docs/`.
- The app links to the same privacy and support URLs shown above.
- Dormant account and widget code is removed from the launch build.
- The project declares `ITSAppUsesNonExemptEncryption = NO`.
- Build, unit tests, UI tests, and the full test pass all succeed locally.

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
- Subtitle: `Interrupt the scroll impulse`
- Promotional text: `Use your normal alarm, then start with five quick questions and one first win before you open anything else.`
- Keywords: `morning routine,focus,habit,wellbeing,productivity,intention,wake up,scrolling`
- Description:

`Morning Reset helps you interrupt the urge to scroll the moment your day starts.

Keep the wake-up routine you already trust. Then tap the Morning Reset notification first.

In about two minutes, the app guides you through:
- five quick yes/no questions
- one clear morning mode
- one short reflection or pattern read
- one concrete first win to do right away

Morning Reset is not an alarm clock, not a content feed, and not a giant productivity system. It is a small interruption before reactive phone use takes over.

The core ritual is fully usable for free. Premium only unlocks deeper follow-up tools already present in the app: fuller pattern insight, a guided pause, Rise & Flow (guided movement reset), Breath Reset (guided breathing), and Morning Pages (freewriting prompt).

Morning Reset includes optional breathing and mobility exercises. These are not a substitute for professional medical advice. Consult your doctor before starting any exercise programme, especially if you have a health condition. Stop immediately if you feel pain or discomfort.`

### Turkish

- Name: `Morning Reset`
- Subtitle: `Scroll dürtüsünü kes`
- Promotional text: `Normal alarmını kullan, sonra başka hiçbir şeyi açmadan önce beş kısa soru ve tek bir ilk kazanımla güne başla.`
- Keywords: `sabah rutini,odak,alışkanlık,iyi oluş,üretkenlik,niyet,uyanma,scroll`
- Description:

`Morning Reset, gün başlarken telefona refleks olarak uzanıp scroll'a gitme dürtüsünü kesmeye yardımcı olur.

Güvendiğin normal uyanma rutinini kullan. Sonra önce Morning Reset bildirimine dokun.

Uygulama yaklaşık iki dakika içinde sana şunlarda eşlik eder:
- beş hızlı evet/hayır sorusu
- net bir sabah modu
- kısa bir yansıma ya da örüntü okuması
- hemen yapabileceğin tek bir ilk kazanım

Morning Reset bir alarm saati değildir, bir içerik akışı değildir ve dev bir üretkenlik sistemi değildir. Tepkisel telefon kullanımından önce gelen küçük bir kesintidir.

Çekirdek ritüel ücretsiz ve tamdır. Premium yalnızca uygulamada zaten bulunan daha derin takip araçlarını açar: daha dolu örüntü içgörüsü, rehberli duraklama, Rise & Flow (rehberli hareket), Breath Reset (rehberli nefes) ve Morning Pages (serbest yazma).

Morning Reset, isteğe bağlı nefes ve hareketlilik egzersizleri içerir. Bunlar profesyonel tıbbi tavsiyenin yerini tutmaz. Mevcut bir sağlık durumunuz varsa egzersiz programına başlamadan önce doktorunuza danışın. Ağrı veya rahatsızlık hissederseniz hemen durun.`

### Spanish

- Name: `Morning Reset`
- Subtitle: `Corta el impulso del scroll`
- Promotional text: `Usa tu alarma habitual y luego empieza con cinco preguntas rápidas y una primera victoria antes de abrir cualquier otra cosa.`
- Keywords: `rutina matinal,enfoque,hábito,bienestar,productividad,intención,despertar,scroll`
- Description:

`Morning Reset te ayuda a interrumpir el impulso de empezar el día haciendo scroll en cuanto te despiertas.

Mantén la rutina de despertar en la que ya confías. Después, toca primero la notificación de Morning Reset.

En unos dos minutos, la app te guía por:
- cinco preguntas rápidas de sí o no
- un modo matinal claro
- una breve reflexión o lectura de patrón
- una primera victoria concreta para hacer de inmediato

Morning Reset no es un despertador, no es un feed de contenido y no es un gran sistema de productividad. Es una pequeña interrupción antes de que empiece el uso reactivo del teléfono.

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

Use the shipping copy from `/Users/can/Projects/MorningReset/README.md`:

- Name: `Morning Reset`
- Subtitle: `Interrupt the scroll impulse`
- Promotional text: `Use your normal alarm, then start with five quick questions and one first win before you open anything else.`
- Support URL: `https://canayan1.github.io/MorningReset/support.html`
- Privacy Policy URL: `https://canayan1.github.io/MorningReset/privacy-policy.html`

When you create version `1.0`:

1. Paste the long description from the README.
2. Paste the review notes from `/Users/can/Projects/MorningReset/BUILD_CHECKLIST.md`.
3. Keep the positioning honest:
   - call it a local-notification-led ritual
   - do not call it an alarm clock
   - do not mention login, widget, sync, analytics, or non-shipping features

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

## Manual step 5 — Create the subscription in App Store Connect

Create one auto-renewable subscription:

- Subscription group name: `Morning Reset Premium`
- Product ID: `com.canayan.MorningReset.premium.annual`
- Reference name: `Morning Reset Premium Annual`
- Duration: `1 year`
- Introductory offer: `7-day free trial`

Suggested English display copy:

- Display name: `Morning Reset Premium Annual`
- Description: `Unlock weekly pattern insight, a short guided pause, Rise & Flow (guided 5-minute movement reset), Breath Reset (guided breathing), and Morning Pages (freewriting prompt).`

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
4. Set version/build to:
   - Version `1.0`
   - Build `1`
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
