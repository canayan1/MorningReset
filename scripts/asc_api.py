import json, os, time, urllib.request, urllib.error
import jwt

# The repository is public, so the key identifiers live outside it, alongside
# the .p8 they belong to. Set ASC_ISSUER_ID / ASC_KEY_ID, or write
# ~/.appstoreconnect/keys.json as {"issuer": "...", "keyId": "..."}.
_HOME = os.path.expanduser("~/.appstoreconnect")
_cfg = {}
try:
    with open(os.path.join(_HOME, "keys.json")) as _f:
        _cfg = json.load(_f)
except OSError:
    pass

ISSUER = os.environ.get("ASC_ISSUER_ID") or _cfg.get("issuer")
KEY_ID = os.environ.get("ASC_KEY_ID") or _cfg.get("keyId")
if not (ISSUER and KEY_ID):
    raise SystemExit("App Store Connect credentials not configured — see the "
                     "comment at the top of scripts/asc_api.py")
KEY_PATH = os.path.join(_HOME, "private_keys", f"AuthKey_{KEY_ID}.p8")
BASE = "https://api.appstoreconnect.apple.com"
_tok = {"v": None, "exp": 0}
def token():
    now = int(time.time())
    if _tok["v"] and now < _tok["exp"] - 60: return _tok["v"]
    with open(KEY_PATH) as f: pk = f.read()
    _tok["v"] = jwt.encode({"iss": ISSUER, "iat": now, "exp": now + 1000,
                            "aud": "appstoreconnect-v1"}, pk,
                           algorithm="ES256", headers={"kid": KEY_ID})
    _tok["exp"] = now + 1000
    return _tok["v"]
def call(method, path, body=None, params=None):
    url = BASE + path
    if params: url += "?" + "&".join(f"{k}={v}" for k, v in params.items())
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token()}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as r:
            raw = r.read().decode()
            return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try: return e.code, json.loads(raw)
        except Exception: return e.code, {"raw": raw}
