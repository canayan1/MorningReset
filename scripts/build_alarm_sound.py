#!/usr/bin/env python3
"""Synthesise the alarm — a phrase you could hum, with the bell behind it.

Why a melody and not just the bell. Sounds people rate as melodic are linked to
*less* grogginess on waking; sounds rated neutral — a tone, a metronomic beep,
an unpitched strike — are linked to more of it (McFarlane et al., PLOS One
2019; bioRxiv 2020). The bell this replaces was inharmonic strikes alternating
two notes: lovely, and squarely in the neutral half. So the alarm now opens
with a five-note phrase in D major pentatonic, the safest interval set there
is — no semitones, nothing that can sound like a warning — played on a
music-box timbre, and the familiar bell arrives underneath it as the tail.

It escalates the way it did: the phrase comes in twice, quiet then present,
before the bell. The first pass is something you could sleep through; the last
strike is not.

    python3 scripts/build_alarm_sound.py
"""
import math, os, struct, subprocess, tempfile, wave

RATE, SECONDS = 44100, 10.0
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "MorningReset", "Resources", "inner_light_alarm.caf")

# D major pentatonic: D E F# A B. No semitones anywhere in it, which is why it
# is the scale that cannot accidentally sound like an alert.
D4, E4, FS4, A4, B4, D5 = 293.66, 329.63, 369.99, 440.00, 493.88, 587.33

# A rising phrase that settles rather than ending high — up to the fifth, a
# step past it, and home. Hummable in one breath, which is the whole test.
PHRASE = [(0.00, D4), (0.52, FS4), (1.04, A4), (1.62, B4), (2.24, A4), (3.00, FS4)]

# Music box: fundamental plus a couple of quick, quiet overtones.
VOICE = [(1.0, 2.6, 1.00), (2.0, 1.3, 0.30), (3.0, 0.7, 0.12)]
# The bell keeps its own inharmonic partials — that is what makes it metal.
BELL = [(1.00, 3.4, 1.00), (2.00, 2.3, 0.42), (2.76, 1.5, 0.26), (5.40, 0.8, 0.11)]

STRIKES = [(6.50, D4, 0.62), (7.75, A4, 0.78), (8.75, D4, 0.90), (9.40, A4, 1.00)]

n = int(RATE * SECONDS)
buf = [0.0] * n

def voice(at, f0, amp, partials):
    i0 = int(at * RATE)
    for ratio, decay, weight in partials:
        f = f0 * ratio
        w = 2 * math.pi * f / RATE
        length = min(n - i0, int(decay * 5 * RATE))
        for i in range(length):
            env = math.exp(-i / (decay * RATE))
            if i < 88:                       # 2 ms attack, no click
                env *= i / 88
            buf[i0 + i] += amp * weight * env * math.sin(w * i)

# The phrase twice: once at the edge of hearing, once present.
for pass_at, amp in [(0.00, 0.30), (3.30, 0.52)]:
    for t, f in PHRASE:
        voice(pass_at + t, f, amp, VOICE)

for at, f0, amp in STRIKES:
    voice(at, f0, amp, BELL)

# A low drone under it, swelling as the phrase does: the room the bell is in.
for i in range(n):
    t = i / RATE
    swell = 0.5 - 0.5 * math.cos(2 * math.pi * t / SECONDS)
    buf[i] += swell * (0.050 * math.sin(2 * math.pi * 146.83 * t)
                       + 0.022 * math.sin(2 * math.pi * 220.00 * t))

# Loop seams: the file restarts, so neither end may have an edge on it.
for i in range(int(0.006 * RATE)):
    buf[i] *= i / (0.006 * RATE)
tail = int(0.30 * RATE)
for i in range(tail):
    buf[n - 1 - i] *= i / tail

peak = max(abs(x) for x in buf)
gain = 0.89 / peak                           # leave headroom; never clip
pcm = b"".join(struct.pack("<h", int(max(-32767, min(32767, x * gain * 32767)))) for x in buf)

with tempfile.TemporaryDirectory() as tmp:
    path = os.path.join(tmp, "a.wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(pcm)
    subprocess.run(["afconvert", "-f", "caff", "-d", "LEI16@44100", path, OUT],
                   check=True, capture_output=True)

print(f"{OUT}  {os.path.getsize(OUT)/1024:.0f} KB  {SECONDS:.0f} sn  tepe {peak*gain:.2f}")
