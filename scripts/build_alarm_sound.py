#!/usr/bin/env python3
"""Synthesise the alarm — Inner Light's own, rather than a stock tone.

A struck bowl, not a beep. The partials are inharmonic in the way a real bell's
are (1, 2, 2.76, 5.4 of the fundamental), and the higher ones decay faster than
the lower, which is the whole of why a bell sounds like metal and a stack of
sines sounds like an organ.

It escalates. Six strikes over ten seconds, each louder and closer than the
last, so the first one is something you could sleep through and the last one is
not. The loop then restarts quiet, which makes the alarm breathe rather than
nag — someone waking on the second wave is woken by something that sounds like
the app, and someone who needs eight waves gets them.

    python3 scripts/build_alarm_sound.py
"""
import math, os, struct, subprocess, tempfile, wave

# 44.1 kHz, not the 24 kHz the voice clips use.
#
# The system plays this one, not the app, and what the system will accept is
# narrower than what an audio file can be. The alarm that fired silently on the
# phone — vibration and a lock-screen banner, no sound — was a 24 kHz file, and
# so was the one before it, so nothing here has ever been shown to play. 44.1
# kHz linear PCM is what Apple's own examples use, and there is no reason to be
# the interesting case.
RATE, SECONDS = 44100, 10.0
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "MorningReset", "Resources", "inner_light_alarm.caf")

# ratio, decay seconds, weight — higher partials shorter and quieter
PARTIALS = [(1.00, 3.4, 1.00), (2.00, 2.3, 0.42), (2.76, 1.5, 0.26), (5.40, 0.8, 0.11)]

# time, fundamental, amplitude. D4 and A4 alternating: a two-note motif rather
# than one repeated note, so it reads as a phrase and not an alert.
STRIKES = [(0.00, 293.66, 0.34), (2.55, 440.00, 0.46), (4.70, 293.66, 0.60),
           (6.45, 440.00, 0.74), (7.95, 293.66, 0.88), (9.05, 440.00, 1.00)]

n = int(RATE * SECONDS)
buf = [0.0] * n

for start, f0, amp in STRIKES:
    i0 = int(start * RATE)
    for ratio, decay, weight in PARTIALS:
        f = f0 * ratio
        w = 2 * math.pi * f / RATE
        # Run each partial until it is inaudible rather than to the end.
        length = min(n - i0, int(decay * 5 * RATE))
        for i in range(length):
            env = math.exp(-i / (decay * RATE))
            if i < 88:                      # 2 ms attack, no click
                env *= i / 88
            buf[i0 + i] += amp * weight * env * math.sin(w * i)

# A low drone under it, swelling as the strikes do: the room the bell is in.
for i in range(n):
    t = i / RATE
    swell = 0.5 - 0.5 * math.cos(2 * math.pi * t / SECONDS)
    buf[i] += swell * (0.055 * math.sin(2 * math.pi * 146.83 * t)
                       + 0.025 * math.sin(2 * math.pi * 220.00 * t))

# Loop seams: the file restarts, so neither end may have an edge on it.
for i in range(int(0.006 * RATE)):
    buf[i] *= i / (0.006 * RATE)
tail = int(0.30 * RATE)
for i in range(tail):
    buf[n - 1 - i] *= i / tail

peak = max(abs(x) for x in buf)
gain = 0.89 / peak                          # leave headroom; never clip
pcm = b"".join(struct.pack("<h", int(max(-32767, min(32767, x * gain * 32767)))) for x in buf)

with tempfile.TemporaryDirectory() as tmp:
    path = os.path.join(tmp, "a.wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(pcm)
    subprocess.run(["afconvert", "-f", "caff", "-d", "LEI16@44100", path, OUT],
                   check=True, capture_output=True)

print(f"{OUT}  {os.path.getsize(OUT)/1024:.0f} KB  {SECONDS:.0f} sn  tepe {peak*gain:.2f}")
