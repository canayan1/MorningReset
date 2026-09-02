# App Store Assets

Generated from the running app via `MorningResetUITests` on **iPhone 17 Pro Max**
(6.9", 1320×2868). Regenerate with the commands in `../APP_STORE_HANDOFF.md`
(manual step 6).

All screenshots use a clean **9:41** status bar (full battery / signal / wifi).

## screenshots_en/ · screenshots_tr/ · screenshots_es/ — product-page screenshots

Localized sets for English, Turkish, and Spanish (6 each, identical order).
Ordered to tell the submission story (captions are suggestions for the overlay):

| File | Screen | Suggested caption |
|------|--------|-------------------|
| `01_WakeHome.png`  | Wake home    | A calmer first minute |
| `02_Quiz.png`      | Morning quiz | Five fast questions |
| `03_Results.png`   | Mode result  | Know your morning mode |
| `04_Action.png`    | First win    | One concrete first win |
| `05_Win.png`       | Win          | Finish before the scroll |
| `06_Checkout.png`  | Checkout     | Seal the day |

## marketing/ — supporting screens (English)

- `PA01_PathPick.png` — choose an energy path (reiki / breathwork / qigong)
- `PA02_Basics.png` — learn your path
- `PA03_PracticePick.png` — choose your first practice
- `PA04_TryNow.png` — **new** onboarding "try it now" activation step
- `FW01_Home.png`, `FW02_MyWins.png`, `FW03_Checked.png` — First Win habit loop

## AppPreview_6.9.mp4 — App Preview video

~22s, H.264, 30fps, 1320×2868, clean 9:41 status bar. Opens on the home screen
and walks the morning ritual (home → quiz → sound → results → action → win →
checkout). Within App Store Connect's 6.9" App Preview spec (15–30s, ≤500 MB).

To regenerate: `xcrun simctl status_bar <udid> override --time "9:41" ...`,
record with `xcrun simctl io <udid> recordVideo ...` while running
`testCaptureAppStoreScreenshots`, then trim the ritual segment with ffmpeg.
