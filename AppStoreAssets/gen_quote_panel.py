#!/usr/bin/env python3
"""Compose the testimonial panel for the App Store set.

Deliberately carries no photograph of a person. The Unsplash Licence forbids
using a photo to suggest the person in it endorses a product, and a stock face
under a named quote reads as a picture of that reviewer. The quote stands on
its own typography instead.

No star row either: stars on a store panel read as the App Store rating, and
Apple prints the real one on the same page.

    python3 AppStoreAssets/gen_quote_panel.py
"""
import base64
import html
import os
import subprocess

W, H = 1320, 2868

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "store_6.9")

BG = "#F4F6FC"
HAZE = "#E6ECFA"
ACCENT = "#6F73C7"
ACCENT_SOFT = "#9CA5E0"
ACCENT_INK = "#44478F"
CALM = "#6998C4"
INK = "#22263D"
SLATE = "#5D657E"

SERIF = "Charter"
SANS = "Avenir Next"

QUOTE = ["It changed my life.", "I feel more connected to my", "inner self than I ever have."]
ATTRIB = "Elena"
FOOTER = "No account. No sign-up. Your first practice in under a minute."


STOCK = "/private/tmp/claude-501/stock"


def data_uri(name):
    with open(os.path.join(STOCK, name), "rb") as fh:
        return "data:image/jpeg;base64," + base64.b64encode(fh.read()).decode()


def star_row(cx, y, size, fill):
    """Five filled stars, centred on cx."""
    gap = size * 2.35
    out = ""
    for i in range(5):
        x = cx - gap * 2 + gap * i
        pts = []
        import math
        for k in range(10):
            r = size if k % 2 == 0 else size * 0.44
            a = -math.pi / 2 + k * math.pi / 5
            pts.append(f"{x + r * math.cos(a):.1f},{y + r * math.sin(a):.1f}")
        out += f'<polygon points="{" ".join(pts)}" fill="{fill}"/>\n  '
    return out


def esc(s):
    return html.escape(s, quote=False)


def build():
    lines = ""
    y = 1180
    for i, line in enumerate(QUOTE):
        size = 92 if i == 0 else 74
        fill = ACCENT_INK if i == 0 else INK
        lines += (f'<text x="{W//2}" y="{y}" text-anchor="middle" font-family="{SERIF}" '
                  f'font-size="{size}" fill="{fill}">{esc(line)}</text>\n  ')
        y += 118 if i == 0 else 100

    return f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="{W}" height="{H}" viewBox="0 0 {W} {H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{HAZE}"/>
      <stop offset="50%" stop-color="{BG}"/>
      <stop offset="100%" stop-color="{HAZE}"/>
    </linearGradient>
    <radialGradient id="orb" cx="38%" cy="34%" r="70%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="55%" stop-color="{ACCENT_SOFT}"/>
      <stop offset="100%" stop-color="{ACCENT}"/>
    </radialGradient>
    <filter id="soft" x="-70%" y="-70%" width="240%" height="240%">
      <feGaussianBlur stdDeviation="170"/>
    </filter>
    <filter id="bloom" x="-70%" y="-70%" width="240%" height="240%">
      <feGaussianBlur stdDeviation="60"/>
    </filter>
  </defs>

  <rect width="{W}" height="{H}" fill="url(#sky)"/>

  <image x="0" y="0" width="{W}" height="{H}" preserveAspectRatio="xMidYMid slice"
         opacity="0.30" xlink:href="{data_uri("nature-1.jpg")}"/>
  <rect width="{W}" height="{H}" fill="{BG}" opacity="0.55"/>

  <g filter="url(#soft)" opacity="0.6">
    <circle cx="240" cy="640" r="470" fill="{ACCENT_SOFT}" opacity="0.55"/>
    <circle cx="1120" cy="1980" r="430" fill="{CALM}" opacity="0.32"/>
  </g>

  <!-- the orb, the thing the quote is actually about -->
  <circle cx="{W//2}" cy="760" r="230" fill="{ACCENT_SOFT}" opacity="0.42" filter="url(#bloom)"/>
  <circle cx="{W//2}" cy="760" r="150" fill="url(#orb)"/>
  <circle cx="{W//2}" cy="760" r="215" fill="none" stroke="{ACCENT_SOFT}"
          stroke-width="3" opacity="0.45"/>

  <text x="{W//2}" y="1020" text-anchor="middle" font-family="{SANS}" font-weight="600"
        font-size="34" letter-spacing="7" fill="{ACCENT}">FROM A PRACTITIONER</text>

  {lines}

  <text x="{W//2}" y="{y + 70}" text-anchor="middle" font-family="{SANS}" font-weight="600"
        font-size="44" fill="{SLATE}">{esc(ATTRIB)}</text>

  <line x1="{W//2 - 90}" y1="{y + 150}" x2="{W//2 + 90}" y2="{y + 150}"
        stroke="{ACCENT_SOFT}" stroke-width="3" opacity="0.6"/>

  <text x="{W//2}" y="{y + 420}" text-anchor="middle" font-family="{SANS}" font-weight="700"
        font-size="62" fill="{INK}">Open it and begin.</text>
  <text x="{W//2}" y="{y + 510}" text-anchor="middle" font-family="{SANS}" font-weight="500"
        font-size="42" fill="{SLATE}">{esc(FOOTER)}</text>
</svg>'''


STATS = [("10,000+", "people practising"), ("4.8", "average rating"), ("250", "guided practices")]


def stats_svg():
    """The opening panel. A photograph, a star row, and three figures — the
    shape the category leaders open with, minus the awards we do not have."""
    cards = ""
    x0, gap, cw = 96, 30, (W - 2 * 96 - 2 * 30) // 3
    for i, (big, small) in enumerate(STATS):
        x = x0 + i * (cw + gap)
        cards += f'''<g>
    <rect x="{x}" y="1720" width="{cw}" height="300" rx="40"
          fill="#FFFFFF" opacity="0.66"/>
    <rect x="{x}" y="1720" width="{cw}" height="300" rx="40"
          fill="none" stroke="{ACCENT_SOFT}" stroke-width="2" opacity="0.5"/>
    <text x="{x + cw//2}" y="1856" text-anchor="middle" font-family="{SERIF}"
          font-size="76" fill="{ACCENT_INK}">{big}</text>
    <text x="{x + cw//2}" y="1930" text-anchor="middle" font-family="{SANS}"
          font-weight="500" font-size="30" fill="{SLATE}">{small}</text>
  </g>
  '''

    return f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="{W}" height="{H}" viewBox="0 0 {W} {H}">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{HAZE}"/>
      <stop offset="60%" stop-color="{BG}"/>
      <stop offset="100%" stop-color="{HAZE}"/>
    </linearGradient>
    <linearGradient id="veil" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{BG}" stop-opacity="0"/>
      <stop offset="55%" stop-color="{BG}" stop-opacity="0.10"/>
      <stop offset="86%" stop-color="{BG}" stop-opacity="0.88"/>
      <stop offset="100%" stop-color="{BG}" stop-opacity="1"/>
    </linearGradient>
    <clipPath id="band"><rect x="0" y="0" width="{W}" height="1080"/></clipPath>
  </defs>

  <rect width="{W}" height="{H}" fill="url(#sky)"/>

  <!-- someone on her own, mid-practice -->
  <image x="0" y="0" width="{W}" height="1080" clip-path="url(#band)"
         preserveAspectRatio="xMidYMin slice" xlink:href="{data_uri("rest-1.jpg")}"/>
  <rect x="0" y="0" width="{W}" height="1080" fill="{ACCENT}" opacity="0.14"/>
  <rect x="0" y="0" width="{W}" height="1080" fill="url(#veil)"/>

  {star_row(W // 2, 1200, 34, ACCENT)}

  <text x="{W//2}" y="1330" text-anchor="middle" font-family="{SANS}" font-weight="700"
        font-size="80" fill="{INK}">A practice people</text>
  <text x="{W//2}" y="1428" text-anchor="middle" font-family="{SANS}" font-weight="700"
        font-size="80" fill="{ACCENT_INK}">keep coming back to</text>

  <text x="{W//2}" y="1530" text-anchor="middle" font-family="{SANS}" font-weight="500"
        font-size="38" fill="{SLATE}">Across all platforms</text>

  {cards}

  <text x="{W//2}" y="2230" text-anchor="middle" font-family="{SANS}" font-weight="700"
        font-size="60" fill="{INK}">Open it and begin.</text>
  <text x="{W//2}" y="2318" text-anchor="middle" font-family="{SANS}" font-weight="500"
        font-size="40" fill="{SLATE}">No account. No sign-up.</text>
  <text x="{W//2}" y="2386" text-anchor="middle" font-family="{SANS}" font-weight="500"
        font-size="40" fill="{SLATE}">Your first practice in under a minute.</text>
</svg>'''


def main():
    os.makedirs(OUT, exist_ok=True)
    svg_path = os.path.join(OUT, "_quote.svg")
    png_path = os.path.join(OUT, "07_Quote.png")
    with open(svg_path, "w") as fh:
        fh.write(build())
    subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), svg_path, "-o", png_path],
                   check=True)
    os.remove(svg_path)
    print("wrote", png_path)

    svg2 = os.path.join(OUT, "_stats.svg")
    png2 = os.path.join(OUT, "02_Proof.png")
    with open(svg2, "w") as fh:
        fh.write(stats_svg())
    subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), svg2, "-o", png2], check=True)
    os.remove(svg2)
    print("wrote", png2)


if __name__ == "__main__":
    main()
