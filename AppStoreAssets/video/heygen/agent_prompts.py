#!/usr/bin/env python3
"""Compose one Video Agent prompt per film from the real-use scripts."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = json.load(open(os.path.join(HERE, "..", "ai_shots.json")))
VO = {f["id"]: None for f in SHOTS["films"]}
VO_TEXT = {
 "01_pranayama": "Seven o'clock. The voice that wakes you is the one that guides you. Two breaths in through the nose, one long breath out. Again. And once more. One minute, and the day has started on your terms. Three physiological sighs — the first practice, and it is free for everyone.",
 "02_qigong": "Above Zermatt, before the lifts open. Feet hip-width, knees soft, the crown of the head lifted. Nothing to do but stand, breathe through the nose, and feel the ground through the soles of your feet. Two thousand years of people finding that this steadies them. Wuji standing — the root under everything else.",
 "03_reiki": "A balcony, a coffee going cold, and five minutes before anything else. Palms together in front of the chest, no force. Eyes closed, attention where the middle fingers meet. Each time the mind wanders, come back. Tokyo, nineteen twenty-two, and still practised the same way. First Gassho.",
 "04_bhavana": "A cala on Mallorca, seven in the morning, nobody else. Find the breath where you feel it most clearly, and stay there. When you notice you have been thinking — that noticing is the practice. Come back. Three minutes. Bhavana. You already know how.",
 "05_hatha": "Hands under the shoulders, knees under the hips. Inhale — the belly drops, the chest comes forward. Exhale — the tailbone tucks, the back domes. Ten slow rounds, the breath leading every change of shape. Three minutes, and the night is out of your back. Cat-Cow. Hatha.",
 "06_nada": "The Corniche in Marseille, wind off the sea. Lips closed, hum out through the nose — low, quiet, a buzz you feel in the cheekbones, not a note for anyone else. Ten times. Then thirty seconds of nothing but listening. Nada yoga. The sound is already inside you.",
 "07_loyly": "Cold water, cupped hands, five or six splashes. Breathe normally the whole time — nothing held, nothing submerged. A little at the back of the neck. Pat dry, stand still, and notice how much sharper the room looks. Löyly. Small doses, brakes on, all yours.",
 "08_shinrin": "Within an hour of waking, step outside. Face the brightest part of the sky, away from the sun. Two minutes, no phone. Notice one thing about the light — its colour, its angle. Then go back in. That is the entire practice. Shinrin-yoku. It always was free.",
 "09_nidra": "The brightest light off, one warm lamp on. Sit somewhere that is not the bed. In through the nose, and let the out-breath be longer than the in-breath. Five minutes, then straight to bed — no last check of anything. Nidra. Tomorrow's alarm is already set.",
 "10_notes": "A notebook, a pen, and a two-minute timer. One sentence: today I'm glad that… Make it specific — not \"my family\", but the way your sister texted back at eleven last night. Three words on why it mattered. Close the page. Notes to self. The quietest way to hear yourself.",
}
OPEN = {
 "01_pranayama": "Wake up into your practice.", "02_qigong": "Slow movement, quiet breath.", "03_reiki": "Quiet hands, five minutes.",
 "04_bhavana": "One thing to rest attention on.", "05_hatha": "Every direction your spine has.", "06_nada": "Use your voice, then your ears.",
 "07_loyly": "Thirty seconds of cold.", "08_shinrin": "Daylight on your face.", "09_nidra": "Let the day set.", "10_notes": "Think on paper.",
}
TAG = {f["id"]: f"{f['name'].upper()} · {f['rider'].lower()}" for f in SHOTS["films"]}

TEMPLATE = """Make a 30-second vertical (9:16) cinematic film for the iOS app "Inner Light: Daily Practice". No presenter, no avatar, no talking head: cinematic B-roll only, with a calm female narrator voice-over. Standard mode is fine.

STORY (a real-use moment, three shots in this order):
1. {s1}
2. {s2}
3. {s3}
Between shot 2 and 3, hold for three seconds on the tradition's name.

VOICE-OVER (read exactly, unhurried, warm, no additions): "{vo}"

ON-SCREEN TEXT (only these, small, elegant serif, no other captions or subtitles): at the start "{open}" — over shot 2 "{tag}". Final 3 seconds: a soft glowing periwinkle orb on a pale ground with the words "Inner Light" and "Ten traditions. One practice free."

STYLE: {style} Music: a very quiet ambient bed under the narration, fading out at the end."""

for f in SHOTS["films"]:
    s = f["shots"]
    p = TEMPLATE.format(s1=s[0], s2=s[1], s3=s[2], vo=VO_TEXT[f["id"]], open=OPEN[f["id"]], tag=TAG[f["id"]], style=SHOTS["style"])
    open(os.path.join(HERE, "agent", f["id"] + ".prompt.txt"), "w").write(p)
print("agent promptlari:", len(SHOTS["films"]))
