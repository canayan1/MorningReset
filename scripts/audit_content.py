#!/usr/bin/env python3
"""Audit school content JSON: schema, safety, and claim-language checks."""
import json, sys, re, pathlib

DIR = pathlib.Path(__file__).resolve().parent.parent / "content" / "schools"
GROUPS = {"starter", "core", "deep", "restorative"}

# Language that would read as a medical/efficacy claim.
BANNED = [
    r"\bcures?\b", r"\bheals? (disease|illness|cancer|depression|anxiety)",
    r"\btreats? (disease|illness|cancer|depression|anxiety|insomnia)",
    r"\bproven to (cure|treat|heal)\b", r"\bwill (cure|heal|fix)\b",
    r"\bguarantees?\b", r"\bdetox(ifies|ify)\b", r"\bboosts? (your )?immune system\b",
    r"\bmedically proven\b", r"\bclinically proven\b", r"\breverses? (aging|disease)\b",
]
# Negation/disclaimer context — a hit preceded by these is honest framing, not a claim.
NEG = re.compile(r"(not|never|no|isn.t|doesn.t|does not|cannot|can.t|without|rather than|instead of)\W+(\w+\W+){0,6}$")
# Fields that are disclaimers by design — claim-scan skips them.
SKIP_FIELDS = {"framing_note", "safety", "sources"}
# Genuinely risky practices that MUST carry a safety note (word-boundary matched).
NEEDS_SAFETY_RE = re.compile(
    r"\b(kapalabhati|bhastrika|breath of fire|hyperventilat\w*|wim hof|"
    r"breath retention|retain the breath|hold (?:the|your) breath|4-?7-?8|"
    r"cold plunge|ice bath|cold shower|sauna|heat exposure|contrast shower)\b")

def audit(path):
    issues, warns = [], []
    try:
        d = json.loads(path.read_text())
    except Exception as e:
        return [f"INVALID JSON: {e}"], []
    sid = d.get("id", path.stem)

    for f in ["id","name","tagline","overview","kind","framing_note","teachings","routines","sources"]:
        if not d.get(f): issues.append(f"missing/empty field: {f}")
    if d.get("kind") not in ("traditional","evidence"):
        issues.append(f"bad kind: {d.get('kind')}")

    te = d.get("teachings", [])
    if len(te) < 4: issues.append(f"teachings: {len(te)} (expected 4-5)")
    for t in te:
        w = len(t.get("body","").split())
        if not (60 <= w <= 170): warns.append(f"teaching {t.get('id')} body {w} words (target 80-140)")

    r = d.get("routines", [])
    if len(r) != 25: issues.append(f"routines: {len(r)} (expected 25)")
    ids = [x.get("id") for x in r]
    if len(set(ids)) != len(ids): issues.append("duplicate routine ids")
    free = [x for x in r if x.get("free")]
    if len(free) != 1: issues.append(f"free routines: {len(free)} (expected exactly 1)")
    counts = {g: 0 for g in GROUPS}
    for x in r:
        g = x.get("group")
        if g not in GROUPS: issues.append(f"{x.get('id')}: bad group {g}")
        else: counts[g] += 1
        steps = x.get("steps", [])
        if not (3 <= len(steps) <= 10): issues.append(f"{x.get('id')}: {len(steps)} steps (want 4-8)")
        m = x.get("minutes", 0)
        if not (1 <= m <= 45): issues.append(f"{x.get('id')}: minutes {m} out of range")
        if not x.get("purpose"): issues.append(f"{x.get('id')}: no purpose")
        blob = " ".join([x.get("title",""), x.get("purpose","")] + steps).lower()
        if NEEDS_SAFETY_RE.search(blob) and not (x.get("safety") or "").strip():
            issues.append(f"{x.get('id')} ('{x.get('title')}'): risky practice with NO safety note")

    scan = []
    scan.append(("overview", d.get("overview","")))
    for tc in te: scan.append((f"teaching {tc.get('id')}", tc.get("title","")+" "+tc.get("body","")))
    for x in r:
        scan.append((f"{x.get('id')}", " ".join([x.get("title",""), x.get("purpose","")] + x.get("steps",[]))))
    for where, blob in scan:
        low = blob.lower()
        for pat in BANNED:
            for m in re.finditer(pat, low):
                before = low[max(0, m.start()-60):m.start()]
                if NEG.search(before):      # "does not cure", "not a diagnosis" → fine
                    continue
                seg = low[max(0,m.start()-60):m.end()+60].replace("\n"," ")
                issues.append(f"CLAIM LANGUAGE in {where} /{pat}/ → …{seg}…")
    # framing_note must actually carry a disclaimer
    fn = (d.get("framing_note") or "").lower()
    if not re.search(r"not (a )?(medical|substitute|treatment)|not medical|experiential|traditional", fn):
        issues.append("framing_note lacks an explicit non-medical/experiential disclaimer")

    n_safety = sum(1 for x in r if (x.get("safety") or "").strip())
    print(f"\n=== {sid} ({d.get('name')}) — {d.get('kind')} ===")
    print(f"  routines 25 ✓ | groups {dict(counts)} | free: {free[0]['title'] if len(free)==1 else '!!'} "
          f"| teachings {len(te)} | safety notes {n_safety} | sources {len(d.get('sources',[]))}")
    for i in issues: print("  ✗", i)
    for w in warns[:5]: print("  ~", w)
    if not issues: print("  ✓ PASS")
    return issues, warns

if __name__ == "__main__":
    files = sorted(DIR.glob("*.json"))
    if not files: print("no content files yet"); sys.exit(0)
    total = 0
    for f in files:
        iss, _ = audit(f); total += len(iss)
    print(f"\n{'='*60}\nTOTAL BLOCKING ISSUES: {total} across {len(files)} school(s)")
    sys.exit(1 if total else 0)
