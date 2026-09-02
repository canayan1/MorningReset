#!/usr/bin/env python
"""Pre-render every line the app speaks, with Kokoro-82M running locally.

Each clip is named for the SHA-256 of its text, so the app finds a recording by
hashing the string it is about to say — no index to keep in step with the copy.

Resumable: a line whose .m4a already exists is skipped, so a re-run after a
content change only renders what actually changed. Edited copy leaves its old
clip behind unused; delete Resources/Voice and re-run for a clean set.

Setup — Kokoro needs Python 3.10+, and the espeakng-loader wheel ships a dylib
with a CI build path compiled in that ignores the data path handed to it, so we
use the Homebrew espeak-ng instead:

    brew install espeak-ng
    uv venv --python 3.12 venv && VIRTUAL_ENV=$PWD/venv uv pip install kokoro-onnx soundfile

The model itself (kokoro-v1.0.onnx + voices-v1.0.bin) is fetched on first use by
`npx hyperframes tts` and cached under ~/.cache/hyperframes/tts.

    ./venv/bin/python scripts/build_voice.py
"""
import hashlib, json, glob, os, subprocess, sys, tempfile, time

VOICE, SPEED = "af_heart", 0.78
BITRATE = 32000            # mono AAC; plenty for speech

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SCHOOLS = os.path.join(ROOT, "MorningReset", "Resources", "Schools")
OUT = os.path.join(ROOT, "MorningReset", "Resources", "Voice")

# Spoken in the gaps, and at the end. Kept in step with SchoolSessionPlayerView.
CUES = [
    "Stay with it.", "Nothing to fix. Just be here.", "Let your shoulders drop.",
    "Soften your jaw.", "No rush. There's time.", "I'm here with you.",
    "Let the breath be easy.", "Keep resting your attention here.",
    "If your mind wandered, that's fine. Come back.", "You're doing it.",
    "Let this be simple.", "Settle a little deeper.",
    "Breathe with me.", "Let the out-breath be longer.", "Easy in, slow out.",
    "Let the belly move.", "Nothing forced.", "Stay with the rhythm.",
    "Your light is a little brighter now.", "Noted. You can adjust this any time.",
]

def key(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]

def collect():
    lines = []
    for f in sorted(glob.glob(os.path.join(SCHOOLS, "*.json"))):
        for r in json.load(open(f)).get("routines", []):
            lines += r.get("steps", [])
    lines += CUES
    seen, out = set(), []
    for l in lines:
        if l not in seen:
            seen.add(l); out.append(l)
    return out

def main():
    os.makedirs(OUT, exist_ok=True)
    lines = collect()
    todo = [l for l in lines if not os.path.exists(os.path.join(OUT, key(l) + ".m4a"))]
    print(f"{len(lines)} satir, {len(todo)} uretilecek", flush=True)
    if not todo:
        return

    from kokoro_onnx import Kokoro, EspeakConfig
    import soundfile as sf
    CACHE = os.path.expanduser("~/.cache/hyperframes/tts")
    k = Kokoro(os.path.join(CACHE, "models", "kokoro-v1.0.onnx"),
               os.path.join(CACHE, "voices", "voices-v1.0.bin"),
               espeak_config=EspeakConfig(lib_path="/opt/homebrew/lib/libespeak-ng.dylib",
                                          data_path="/opt/homebrew/share/espeak-ng-data"))

    t0, secs, failed = time.time(), 0.0, []
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, "line.wav")
        for i, text in enumerate(todo, 1):
            dest = os.path.join(OUT, key(text) + ".m4a")
            try:
                samples, rate = k.create(text, voice=VOICE, speed=SPEED, lang="en-us")
                sf.write(wav, samples, rate)
                subprocess.run(["afconvert", "-f", "m4af", "-d", "aac",
                                "-b", str(BITRATE), wav, dest],
                               check=True, capture_output=True)
                secs += len(samples) / rate
            except Exception as e:
                failed.append((text, str(e)[:80]))
                continue
            if i % 100 == 0 or i == len(todo):
                el = time.time() - t0
                print(f"  {i}/{len(todo)}  {el/60:.1f} dk gecti, "
                      f"~{el/i*(len(todo)-i)/60:.1f} dk kaldi", flush=True)

    size = sum(os.path.getsize(os.path.join(OUT, f)) for f in os.listdir(OUT))
    print(f"\nbitti: {len(os.listdir(OUT))} dosya, {size/1024/1024:.1f} MB, "
          f"{secs/60:.0f} dk ses, {(time.time()-t0)/60:.1f} dk surdu")
    if failed:
        print(f"BASARISIZ {len(failed)}:")
        for t, e in failed[:10]:
            print("  -", t[:60], "|", e)
        sys.exit(1)

if __name__ == "__main__":
    main()
