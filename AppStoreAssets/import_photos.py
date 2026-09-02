#!/usr/bin/env python3
"""Bring the tradition photographs into the app's asset catalogue.

Each of the ten traditions gets one photograph, plus one for the paywall. They
are cropped to a single portrait ratio, resized once, and saved as JPEG — the
catalogue is the only place these live, so the sizes here are the sizes that
ship.

Source is Unsplash under the Unsplash Licence (commercial use, no attribution
required). PHOTOS records the photographer for every shipped file anyway, so
the provenance of each asset stays known.

    python3 AppStoreAssets/import_photos.py
"""
import json
import os
import shutil

from PIL import Image

SRC = "/private/tmp/claude-501/stock"
HERE = os.path.dirname(os.path.abspath(__file__))
CATALOG = os.path.abspath(os.path.join(
    HERE, "..", "MorningReset", "MorningReset", "MorningReset", "Assets.xcassets"))

# asset name -> source file
PHOTOS = {
    "tradition-reiki":      "woman-0.jpg",    # hands resting on the chest
    "tradition-breathing":  "breath-1.jpg",   # head tipped back, mid-breath
    "tradition-qigong":     "man-2.jpg",      # seated on rock against open sky
    "tradition-meditation": "man-1.jpg",      # cross-legged, still
    "tradition-yoga":       "yoga-1.jpg",     # long holds on mats
    "tradition-sound":      "sound-0.jpg",    # singing bowl in the hand
    "tradition-coldheat":   "cold-0.jpg",     # standing out in the cold
    "tradition-sleep":      "sleep-1.jpg",    # soft light through blinds
    "tradition-nature":     "nature-1.jpg",   # forest path, morning light
    "tradition-journal":    "journal-0.jpg",  # notebook by a window
    "paywall-hero":         "man-2.jpg",      # the aspirational one
}

W, H = 900, 1200          # 3:4, covers a row thumbnail and a detail header
PAYWALL_W, PAYWALL_H = 1200, 900   # the paywall band is landscape


def cover(img, w, h):
    """Scale to fill, then centre-crop — never letterbox."""
    ratio = max(w / img.width, h / img.height)
    img = img.resize((round(img.width * ratio), round(img.height * ratio)), Image.LANCZOS)
    left, top = (img.width - w) // 2, (img.height - h) // 2
    return img.crop((left, top, left + w, top + h))


def write_imageset(name, image):
    folder = os.path.join(CATALOG, f"{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    filename = f"{name}.jpg"
    image.convert("RGB").save(os.path.join(folder, filename), "JPEG",
                              quality=82, optimize=True, progressive=True)
    contents = {
        "images": [{"filename": filename, "idiom": "universal", "scale": "1x"},
                   {"idiom": "universal", "scale": "2x"},
                   {"idiom": "universal", "scale": "3x"}],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(folder, "Contents.json"), "w") as fh:
        json.dump(contents, fh, indent=2)
    return os.path.getsize(os.path.join(folder, filename))


def main():
    total = 0
    for name, src in PHOTOS.items():
        path = os.path.join(SRC, src)
        if not os.path.exists(path):
            print("missing source:", src)
            continue
        img = Image.open(path)
        size = (PAYWALL_W, PAYWALL_H) if name == "paywall-hero" else (W, H)
        total += write_imageset(name, cover(img, *size))
        print(f"  {name:22} <- {src}")
    print(f"\n{len(PHOTOS)} assets, {total/1024:.0f} KB total")

    credits = os.path.join(HERE, "photo-credits.json")
    manifest = json.load(open(os.path.join(SRC, "manifest.json")))
    by_file = {m["file"]: m for m in manifest}
    shutil.copy(os.path.join(SRC, "manifest.json"), credits + ".raw")
    json.dump([{"asset": k, **{kk: by_file[v][kk] for kk in ("by", "link", "id") if v in by_file}}
               for k, v in PHOTOS.items() if v in by_file],
              open(credits, "w"), indent=1)
    print("credits ->", credits)


if __name__ == "__main__":
    main()
