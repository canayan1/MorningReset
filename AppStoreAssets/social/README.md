# Social content engine

Reusable generators for Instagram content. Output is brand-consistent with the app
(mimoza aura, Georgia serif, gold accent, "MORNING RESET" wordmark).

## Carousels — `gen_carousel.py`
Renders 1080×1350 slides as PNG via `rsvg-convert`.
- Edit the `CAROUSELS` dict (each entry = list of `(kind, head_lines, body_lines, tag)`;
  `kind` ∈ `cover` | `body` | `cta`).
- Run all: `python3 gen_carousel.py`
- Run one: `python3 gen_carousel.py c1_energy`
- Output: `carousels/<name>/slide_NN.png`

## Reels — `gen_reel.py`
Frames a simulator screen-recording into a 1080×1920 Reel (aura bg + hook + device + wordmark).
```
python3 gen_reel.py "Hook line 1|Hook line 2" INPUT.mov SS TO SPEED OUTPUT.mp4
```
- `SS`/`TO` = source in/out seconds; `SPEED` = playback multiplier (1.4–1.5 reads well).
- To capture a fresh recording: boot a sim, install the app, then
  `xcrun simctl io <udid> recordVideo --codec=h264 out.mov` while driving the app
  (a paced UI test or by hand), Ctrl-C to stop.

## Notes
- Keep all energy/wellness copy **experiential — no medical/efficacy claims**.
- The live "energy read" camera is black in the simulator; show it on a real device
  (or as a static/mockup), not via a sim recording.
- To add your handle: edit the `wordmark()` text in `gen_carousel.py` / the wordmark line in `gen_reel.py`.
