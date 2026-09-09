#!/usr/bin/env python3
"""Turn the 30 shot prompts into HeyGen `cinematic_avatar` request bodies.

    python3 build_requests.py --looks looks.json --assets assets.json

`looks.json`  — {"woman_30s": "<look id>", "man_40s": "<look id>", ...}
                from `heygen avatar list --ownership public`
`assets.json` — {"tradition-breathing": "<asset_id>", ...}
                from `heygen asset create` on the tradition photographs

Writes one JSON per shot into requests/, ready for
    heygen video create --wait -d requests/01_pranayama_1.json

The house style is prepended to every prompt; each film pins one person
(its look id) across its three shots, and passes the tradition's photograph
as a reference so place and light hold from shot to shot.
"""
import argparse, json, os

HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = json.load(open(os.path.join(HERE, "..", "ai_shots.json")))

# who appears in each film — matches the scripts
CAST = {
    "01_pranayama": "woman_30s", "02_qigong": "man_40s",  "03_reiki": "woman_50s",
    "04_bhavana":  "woman_20s", "05_hatha":  "man_30s",   "06_nada":  "woman_40s",
    "07_loyly":    "man_20s",   "08_shinrin": "woman_30s", "09_nidra": "man_40s",
    "10_notes":    "woman_20s",
}
PHOTO = {f["id"]: f["insert"] for f in SHOTS["films"]}  # not used for refs; see below
PHOTO_ASSET_KEY = {
    "01_pranayama": "tradition-breathing", "02_qigong": "tradition-qigong", "03_reiki": "tradition-reiki",
    "04_bhavana": "tradition-meditation", "05_hatha": "tradition-yoga", "06_nada": "tradition-sound",
    "07_loyly": "tradition-coldheat", "08_shinrin": "tradition-nature", "09_nidra": "tradition-sleep",
    "10_notes": "tradition-journal",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--looks", required=True)
    ap.add_argument("--assets", required=True)
    ap.add_argument("--duration", type=int, default=8)
    ap.add_argument("--resolution", default="1080p")
    a = ap.parse_args()
    looks = json.load(open(a.looks)); assets = json.load(open(a.assets))
    out = os.path.join(HERE, "requests"); os.makedirs(out, exist_ok=True)
    n = 0
    for film in SHOTS["films"]:
        look = looks.get(CAST[film["id"]]) or looks.get("default")
        ref = assets.get(PHOTO_ASSET_KEY[film["id"]])
        for i, shot in enumerate(film["shots"], 1):
            body = {
                "type": "cinematic_avatar",
                "title": f"Inner Light · {film['name']} · shot {i}",
                "prompt": SHOTS["style"] + " " + shot,
                "avatar_id": [look] if look else [],
                "aspect_ratio": "9:16",
                "resolution": a.resolution,
                "duration": a.duration,
                "enhance_prompt": False,
            }
            if ref:
                body["references"] = [{"type": "asset_id", "asset_id": ref}]
            path = os.path.join(out, f"{film['id']}_{i}.json")
            json.dump(body, open(path, "w"), indent=1, ensure_ascii=False); n += 1
    print(f"{n} istek yazildi -> {out}")

if __name__ == "__main__":
    main()
