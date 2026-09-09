# Marketing video sources

HyperFrames compositions, rendered locally (Chrome headless + FFmpeg; no HeyGen
account needed). Rendered outputs live in the founder's `~/Desktop/energy reset
marketing/`, not here.

- `showcase.html` — the 22 s promo: the alarm rings with the guide's voice, then
  setup, Today, the practice, and the end card. Render as a project's `index.html`.
- `films/index.html` — the 17 s tradition film, variable-driven (`name`, `rider`,
  `photo`, `vo`). One render per row in `films/batch/*.json`.

Assets the compositions expect, all derivable from this repo:

- `assets/photos/tradition-*.jpg` — from `Assets.xcassets/tradition-*.imageset`
- `assets/frames/*.png` — from `AppStoreAssets/v2_screenshots`
- `assets/audio/*.m4a` — the voiceovers (`scripts/build_voice.py` toolchain, Kokoro
  `af_heart`, speed 0.85) and `bed.mp3` from `AppStoreAssets/social/music`

To rebuild: `npx hyperframes init <dir> --example blank --resolution portrait`,
drop the files in, stage the assets, `npx hyperframes check`, then
`npx hyperframes render` (films: `render --variables-file films/batch/<row>.json`).
The two things lint will catch if you edit: never tween a clip element's own
opacity at its boundary (use the inner `.scene` wrapper + `tl.set` hard kill), and
system fonts need a `@font-face { src: local(...) }` declaration.

## Generated-footage films (HeyGen)

- `heygen/ai_shots.json` — the house style plus three shot prompts per film,
  lifted from the real-use scripts (a person, a place, the practice, the phone
  as it sits in life; screens dim and unreadable so no interface is invented).
- `heygen/build_requests.py` — turns those into `cinematic_avatar` request
  bodies for `heygen video create` (one person pinned per film via avatar look
  ids; the tradition's photograph passed as a reference).
- `heygen/01_pranayama.prompt.txt` — the one-shot Video Agent prompt for the
  showcase film (`heygen video-agent create --prompt "$(cat …)" --orientation portrait`).
- `films-ai/index.html` — the assembly: three generated clips crossfaded, the
  tradition's name as a lower third, one app frame, the end card, the app's
  own voice and a music bed. Variables: name, rider, clip1–3, insert, vo.

HeyGen CLI: `curl -fsSL https://static.heygen.ai/cli/install.sh | bash`, then
`heygen auth login --oauth` (subscription credits; an API key bills separately).
