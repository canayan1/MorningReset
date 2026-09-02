#!/usr/bin/env python3
"""Render the Energy Reset app icon: a lit crescent in the app's blue tones.

The crescent is carved out of a sphere lit from one side — the same energy orb
the app is built around, seen at its edge. Three appearances are produced, as
iOS 18+ asks for: light, dark, and a grayscale tinted version.

    python3 AppStoreAssets/gen_app_icon.py
"""
import os
import subprocess

S = 1024
HERE = os.path.dirname(os.path.abspath(__file__))
ICONSET = os.path.abspath(os.path.join(
    HERE, "..", "MorningReset", "MorningReset", "MorningReset",
    "Assets.xcassets", "AppIcon.appiconset"))

# Taken straight from DesignSystem.swift so the icon and the app are the same
# blue, not two blues that merely resemble each other.
#   accent      #6F73C7   accentInk  #44478F   accentSoft #9CA5E0
#   background  #F4F6FC   surface    #EDF1FA   calm       #6998C4
VARIANTS = {
    "icon-light": {
        "bg_top": "#44478F",        # accentInk
        "bg_bottom": "#6F73C7",     # accent
        "halo": "#9CA5E0",          # accentSoft
        "moon_bright": "#F4F6FC",   # background — the app's dawn mist, not white
        "moon_soft": "#DDE2F7",
        "glow": "#9CA5E0",          # accentSoft
        "glow_opacity": "0.60",
    },
    "icon-dark": {
        "bg_top": "#161A33",
        "bg_bottom": "#44478F",     # accentInk
        "halo": "#6F73C7",          # accent
        "moon_bright": "#EDF1FA",   # surface
        "moon_soft": "#B6BEE6",
        "glow": "#6F73C7",
        "glow_opacity": "0.55",
    },
    "icon-tinted": {
        "bg_top": "#1A1A1A",
        "bg_bottom": "#4A4A4A",
        "halo": "#7D7D7D",
        "moon_bright": "#F4F4F4",
        "moon_soft": "#D2D2D2",
        "glow": "#9A9A9A",
        "glow_opacity": "0.45",
    },
}


def svg(v):
    # The crescent cradles a small orb of light: the app's whole mechanic in one
    # mark — the light you tend, held. A lone crescent left the right-hand side
    # of the tile dead, and read as a generic moon.
    cx, cy, r = S * 0.455, S * 0.525, S * 0.315
    # The bite that opens the disc into a crescent, offset up and to the right.
    bx, by, br = cx + r * 0.52, cy - r * 0.34, r * 0.94
    # The orb sits in the opening the bite left behind.
    ox, oy, orr = S * 0.655, S * 0.375, S * 0.125
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" viewBox="0 0 {S} {S}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0.35" y2="1">
      <stop offset="0%" stop-color="{v['bg_top']}"/>
      <stop offset="100%" stop-color="{v['bg_bottom']}"/>
    </linearGradient>
    <linearGradient id="lit" x1="0" y1="1" x2="1" y2="0">
      <stop offset="0%" stop-color="{v['moon_soft']}"/>
      <stop offset="55%" stop-color="{v['moon_bright']}"/>
      <stop offset="100%" stop-color="{v['moon_bright']}"/>
    </linearGradient>
    <radialGradient id="orb" cx="38%" cy="34%" r="72%">
      <stop offset="0%" stop-color="{v['moon_bright']}"/>
      <stop offset="55%" stop-color="{v['moon_soft']}"/>
      <stop offset="100%" stop-color="{v['glow']}"/>
    </radialGradient>
    <filter id="bloom" x="-70%" y="-70%" width="240%" height="240%">
      <feGaussianBlur stdDeviation="42"/>
    </filter>
    <filter id="haze" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="90"/>
    </filter>
    <mask id="crescent">
      <rect width="{S}" height="{S}" fill="black"/>
      <circle cx="{cx}" cy="{cy}" r="{r}" fill="white"/>
      <circle cx="{bx}" cy="{by}" r="{br}" fill="black"/>
    </mask>
  </defs>

  <rect width="{S}" height="{S}" fill="url(#sky)"/>

  <!-- the aura, kept faint so the two real shapes stay the only shapes -->
  <g filter="url(#haze)" opacity="0.5">
    <circle cx="{cx - r*0.5:.0f}" cy="{cy + r*0.6:.0f}" r="{r*1.1:.0f}" fill="{v['halo']}" opacity="0.42"/>
    <circle cx="{ox:.0f}" cy="{oy:.0f}" r="{orr*2.4:.0f}" fill="{v['halo']}" opacity="0.40"/>
  </g>
  <circle cx="{S*0.5}" cy="{S*0.5}" r="{S*0.435:.0f}" fill="none"
          stroke="{v['halo']}" stroke-width="3" opacity="0.24"/>

  <!-- light spilling off the crescent's lit edge -->
  <g mask="url(#crescent)" filter="url(#bloom)" opacity="{v['glow_opacity']}">
    <circle cx="{cx}" cy="{cy}" r="{r}" fill="{v['glow']}"/>
  </g>
  <g mask="url(#crescent)">
    <circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#lit)"/>
  </g>

  <!-- the orb it holds -->
  <circle cx="{ox}" cy="{oy}" r="{orr*1.55:.0f}" fill="{v['glow']}"
          opacity="0.42" filter="url(#bloom)"/>
  <circle cx="{ox}" cy="{oy}" r="{orr}" fill="url(#orb)"/>
</svg>'''


def main():
    for name, v in VARIANTS.items():
        svg_path = os.path.join(HERE, name + ".svg")
        png_path = os.path.join(ICONSET, name + ".png")
        with open(svg_path, "w") as fh:
            fh.write(svg(v))
        # --background-color removes the alpha channel, which the App Store
        # rejects on icons.
        subprocess.run(["rsvg-convert", "-w", str(S), "-h", str(S),
                        "-b", v["bg_bottom"], svg_path, "-o", png_path], check=True)
        os.remove(svg_path)
        print("wrote", png_path)


if __name__ == "__main__":
    main()
