#!/usr/bin/env python3
"""Compose the App Store screenshots for Energy Reset.

Takes the raw device captures produced by MorningResetUITests and puts each one
on a branded panel at the 6.9" size Apple asks for (1320x2868).

The design follows what the category leaders actually do — verified by reading
the live product pages of Calm, Headspace, Balance, Insight Timer, Waking Up,
Happier and Plum Village in August 2026:

  * heavy sans headline above the screen, never a serif
  * one phrase split into two treatments, so a single word carries the emphasis
  * a background that flows unbroken from panel to panel rather than resetting
  * benefit language, and no product chrome — a floating card, no phone bezel

Two things they do that we deliberately cannot: open on an awards laurel, and
quote a review count. This app has neither yet, so panel one buys trust with
scale and generosity instead.

    python3 AppStoreAssets/gen_store_screenshots.py
"""
import base64
import html
import os
import subprocess
import sys

W, H = 1320, 2868
N = 6  # panels, used to walk the shared background across the set

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "v2_screenshots")
OUT = os.path.join(HERE, "store_6.9")

# App design tokens (DesignSystem.swift)
BG = "#F4F6FC"
HAZE = "#E6ECFA"
ACCENT = "#6F73C7"
ACCENT_SOFT = "#9CA5E0"
ACCENT_INK = "#44478F"
CALM = "#6998C4"
INK = "#22263D"
SLATE = "#5D657E"

SANS = "Avenir Next"

# (file, quiet first line, emphasised second line, supporting line)
#
# The voice: name what is present, never what is absent. These practices are met
# from the inside, not taught — so no "learn", and nothing about a missed day.
# Poetry on top, proof underneath: the leaders all pair an inward line with a
# concrete number, and a new app has only the number to trade on.
PANELS = [
    ("01_Today.png",
     "Come home", "to yourself",
     "Ten traditions · 250 practices · one free in each"),
    ("02_Schools.png",
     "Ten traditions,", "kept whole",
     "Reiki, Pranayama, Qigong, Hatha and six more"),
    ("03_Teachings.png",
     "Feel it", "from the inside",
     "Where each practice comes from, in its own words"),
    ("04_Practice.png",
     "A quiet voice", "stays with you",
     "Step by step, on a timer that never hurries you"),
    ("05_Library.png",
     "Two minutes,", "or twenty",
     "250 practices, yours to move through"),
    ("06_Progress.png",
     "Your light", "remembers",
     "Every practice you finish stays with you"),
]


def esc(s):
    return html.escape(s, quote=False)


def data_uri(path):
    with open(path, "rb") as fh:
        return "data:image/png;base64," + base64.b64encode(fh.read()).decode()


def panel_svg(shot_path, quiet, loud, support, i):
    """One panel. `i` is its index in the set, which slides the shared aura
    along so the six read as one continuous field when swiped."""
    dev_w = 1010
    dev_h = int(dev_w * 2868 / 1320)
    dev_x = (W - dev_w) // 2
    dev_y = 1010

    # The aura drifts left across the set: panel 0 has it on the right, the last
    # panel has it on the left, so consecutive panels share an edge.
    t = i / (N - 1)
    ax = W * (1.15 - 1.9 * t)
    bx = W * (1.95 - 1.9 * t)

    # Avenir Next runs about 0.55em per character at these weights. Cap each
    # line to the safe width so a long headline shrinks instead of overflowing.
    safe = W - 150
    q_size = min(96, int(safe / (len(quiet) * 0.55)))
    l_size = min(102, int(safe / (len(loud) * 0.56)))
    drop = 0 if max(len(quiet), len(loud)) > 14 else 14

    return f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="{W}" height="{H}" viewBox="0 0 {W} {H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{HAZE}"/>
      <stop offset="55%" stop-color="{BG}"/>
      <stop offset="100%" stop-color="{HAZE}"/>
    </linearGradient>
    <filter id="soft" x="-70%" y="-70%" width="240%" height="240%">
      <feGaussianBlur stdDeviation="170"/>
    </filter>
    <filter id="cast" x="-30%" y="-15%" width="160%" height="150%">
      <feDropShadow dx="0" dy="30" stdDeviation="46" flood-color="{INK}" flood-opacity="0.22"/>
    </filter>
    <clipPath id="screen">
      <rect x="{dev_x}" y="{dev_y}" width="{dev_w}" height="{dev_h}" rx="78" ry="78"/>
    </clipPath>
  </defs>

  <rect width="{W}" height="{H}" fill="url(#sky)"/>

  <g filter="url(#soft)" opacity="0.62">
    <circle cx="{ax:.0f}" cy="560" r="470" fill="{ACCENT_SOFT}" opacity="0.62"/>
    <circle cx="{bx:.0f}" cy="1180" r="420" fill="{CALM}" opacity="0.34"/>
    <circle cx="{(ax + bx) / 2:.0f}" cy="150" r="360" fill="{ACCENT}" opacity="0.22"/>
  </g>

  <text x="{W//2}" y="{360 + drop}" text-anchor="middle" font-family="{SANS}" font-weight="600"
        font-size="{q_size}" fill="{SLATE}">{esc(quiet)}</text>
  <text x="{W//2}" y="{486 + drop}" text-anchor="middle" font-family="{SANS}" font-weight="700"
        font-size="{l_size}" fill="{ACCENT_INK}">{esc(loud)}</text>

  <text x="{W//2}" y="{626 + drop}" text-anchor="middle" font-family="{SANS}" font-weight="500"
        font-size="44" fill="{SLATE}">{esc(support)}</text>

  <g filter="url(#cast)">
    <rect x="{dev_x}" y="{dev_y}" width="{dev_w}" height="{dev_h}" rx="78" ry="78" fill="#ffffff"/>
  </g>
  <image x="{dev_x}" y="{dev_y}" width="{dev_w}" height="{dev_h}"
         clip-path="url(#screen)" preserveAspectRatio="xMidYMin slice"
         xlink:href="{data_uri(shot_path)}"/>
  <rect x="{dev_x}" y="{dev_y}" width="{dev_w}" height="{dev_h}" rx="78" ry="78"
        fill="none" stroke="#ffffff" stroke-width="9" opacity="0.92"/>
</svg>'''


def main():
    os.makedirs(OUT, exist_ok=True)
    missing = [f for f, *_ in PANELS if not os.path.exists(os.path.join(RAW, f))]
    if missing:
        sys.exit("Missing raw captures in %s: %s" % (RAW, ", ".join(missing)))

    for i, (fname, quiet, loud, support) in enumerate(PANELS):
        svg = panel_svg(os.path.join(RAW, fname), quiet, loud, support, i)
        svg_path = os.path.join(OUT, fname.replace(".png", ".svg"))
        png_path = os.path.join(OUT, fname)
        with open(svg_path, "w") as fh:
            fh.write(svg)
        subprocess.run(
            ["rsvg-convert", "-w", str(W), "-h", str(H), svg_path, "-o", png_path],
            check=True,
        )
        os.remove(svg_path)
        print("%d/%d  %s" % (i + 1, len(PANELS), png_path))


if __name__ == "__main__":
    main()
