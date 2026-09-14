#!/usr/bin/env bash
# Refresh the LobeHub Market user OAuth token and update the GitHub secret.
#
# The market-cli login flow is OAuth2 PKCE with a localhost callback, which
# cannot complete on headless machines (CI runners, SSH boxes, containers).
# This script performs the same PKCE flow without the CLI's callback server:
#   1. Generates a code_verifier/code_challenge pair and prints the
#      authorization URL — you open it in any browser
#   2. After authorizing, the browser redirects to a dead
#      http://localhost:51234/callback?code=...&state=... URL
#   3. You paste that URL back here; the script extracts the code and
#      exchanges it directly at the OIDC token endpoint (no local server,
#      no CLI callback timeout)
#   4. The fresh ~/.lobehub-market/user-credentials.json is written in the
#      exact format lhm expects and pushed into the LOBEHUB_USER_CREDENTIALS
#      GitHub secret
#
# Prerequisites:
#   - curl, python3
#   - npx (optional, for the final `lhm auth status` sanity check)
#   - gh CLI authenticated with secret write access to the repo
#
# Usage:
#   ./refresh-lobehub-auth.sh               # refresh token + update secret
#   ./refresh-lobehub-auth.sh --dry-run     # stop before updating the secret
#   ./refresh-lobehub-auth.sh --run-publish # also trigger lobehub-publish.yml
#
# Env overrides:
#   GH_REPO=owner/name    target repo (default: detected via `gh repo view`)
#   MARKET_BASE_URL=...   market API base (default: https://market.lobehub.com)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDS_DIR="$HOME/.lobehub-market"
USER_CREDS="$CREDS_DIR/user-credentials.json"
SECRET_NAME="LOBEHUB_USER_CREDENTIALS"
BASE_URL="${MARKET_BASE_URL:-https://market.lobehub.com}"
CLIENT_ID="lobehub-cli"
REDIRECT_URI="http://localhost:51234/callback"
DRY_RUN=false
RUN_PUBLISH=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --run-publish) RUN_PUBLISH=true ;;
    -h|--help)
      sed -n '2,29p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    *) echo "ERROR: unknown argument: $arg" >&2; exit 2 ;;
  esac
done

for cmd in curl python3 gh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $cmd" >&2
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

REPO="${GH_REPO:-}"
if [[ -z "$REPO" ]]; then
  cd "$SCRIPT_DIR"
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
fi
if [[ -z "$REPO" ]]; then
  echo "ERROR: could not determine GitHub repo (run inside the repo or pass GH_REPO=owner/name)" >&2
  exit 1
fi
echo "Target repo: $REPO"
echo "Secret:      $SECRET_NAME"
echo

# --- Generate PKCE pair + state -------------------------------------------
read -r VERIFIER CHALLENGE STATE < <(python3 - <<'EOF'
import base64, hashlib, secrets
verifier = base64.urlsafe_b64encode(secrets.token_bytes(64)).rstrip(b"=").decode()
challenge = base64.urlsafe_b64encode(
    hashlib.sha256(verifier.encode()).digest()
).rstrip(b"=").decode()
state = secrets.token_hex(32)
print(verifier, challenge, state)
EOF
)

AUTH_URL="$BASE_URL/lobehub-oidc/auth?client_id=$CLIENT_ID&response_type=code&scope=openid+profile+email+offline_access&prompt=consent&code_challenge=$CHALLENGE&code_challenge_method=S256&redirect_uri=$(python3 -c "import urllib.parse;print(urllib.parse.quote('$REDIRECT_URI',safe=''))")&state=$STATE"

cat <<EOF
>>> ACTION REQUIRED <<<

1. Open this URL in your browser and authorize with your LobeHub account:

   $AUTH_URL

2. The browser will redirect to a localhost URL that WILL NOT LOAD —
   expected, nothing listens there. What matters is the URL itself.

3. Copy the FULL URL from the address bar — it looks like:
   $REDIRECT_URI?code=...&state=...&iss=...

4. Paste it below and press Enter. (Ctrl+C to abort.)

EOF

read -r -p "Paste callback URL: " CALLBACK_URL

# --- Extract and validate code/state ---------------------------------------
read -r CODE GOT_STATE < <(CALLBACK_URL="$CALLBACK_URL" python3 - <<'EOF'
import os, sys, urllib.parse
u = urllib.parse.urlparse(os.environ["CALLBACK_URL"])
q = urllib.parse.parse_qs(u.query)
code = q.get("code", [""])[0]
state = q.get("state", [""])[0]
print(code, state)
EOF
)

if [[ -z "$CODE" ]]; then
  echo "ERROR: no 'code' parameter in that URL. Expected $REDIRECT_URI?code=...&state=..." >&2
  exit 1
fi
if [[ "$GOT_STATE" != "$STATE" ]]; then
  echo "ERROR: state mismatch — that URL belongs to a different login attempt. Re-run and use the fresh URL." >&2
  exit 1
fi

# --- Exchange code for tokens ----------------------------------------------
echo
echo "=== Exchanging code for tokens ==="
TOKEN_JSON="$(curl -sf -X POST "$BASE_URL/lobehub-oidc/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "client_id=$CLIENT_ID" \
  --data-urlencode "code=$CODE" \
  --data-urlencode "code_verifier=$VERIFIER" \
  --data-urlencode "redirect_uri=$REDIRECT_URI")" || {
    echo "ERROR: token endpoint request failed" >&2
    exit 1
  }

if ! printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; json.load(sys.stdin)['access_token']" 2>/dev/null; then
  echo "ERROR: token exchange failed. Server response:" >&2
  printf '%s\n' "$TOKEN_JSON" >&2
  echo "(codes are single-use and short-lived — re-run for a fresh URL)" >&2
  exit 1
fi

ACCESS_TOKEN="$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])")"
REFRESH_TOKEN="$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json;print(json.load(sys.stdin).get('refresh_token') or '')")"
EXPIRES_IN="$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json;print(json.load(sys.stdin).get('expires_in', 90000))")"

# --- Resolve user identity (id_token claims, falling back to /user/me) ------
# A User-Agent header is required: the API sits behind Cloudflare, which
# blocks requests with no UA (error 1010).
ME_JSON="$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "User-Agent: @lobehub/market-cli" "$BASE_URL/api/v1/user/me" || echo '{}')"

EXPIRES_AT="$(python3 -c "
from datetime import datetime, timezone, timedelta
print((datetime.now(timezone.utc) + timedelta(seconds=$EXPIRES_IN)).isoformat(timespec='milliseconds').replace('+00:00','Z'))
")"

# --- Write credentials file in lhm format -----------------------------------
mkdir -p "$CREDS_DIR"
ACCESS_TOKEN="$ACCESS_TOKEN" REFRESH_TOKEN="$REFRESH_TOKEN" BASE_URL="$BASE_URL" \
TOKEN_JSON="$TOKEN_JSON" ME_JSON="$ME_JSON" EXPIRES_AT="$EXPIRES_AT" \
python3 - <<'EOF'
import base64, json, os
name = email = uid = ""
try:
    tok = json.loads(os.environ["TOKEN_JSON"]).get("id_token", "")
    if tok:
        payload = tok.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        claims = json.loads(base64.urlsafe_b64decode(payload))
        name, email, uid = claims.get("name",""), claims.get("email",""), claims.get("sub","")
except Exception:
    pass
try:
    me = json.loads(os.environ["ME_JSON"])
    name = name or me.get("displayName", "")
    email = email or me.get("email", "")
    uid = uid or me.get("userId", "")
except Exception:
    pass
creds = {
    "accessToken": os.environ["ACCESS_TOKEN"],
    "baseUrl": os.environ["BASE_URL"],
    "displayName": name,
    "email": email,
    "expiresAt": os.environ["EXPIRES_AT"],
    "refreshToken": os.environ["REFRESH_TOKEN"],
    "userId": uid,
}
path = os.path.expanduser("~/.lobehub-market/user-credentials.json")
with open(path, "w") as f:
    json.dump(creds, f, indent=2)
os.chmod(path, 0o600)
print(f"Authenticated as: {name} <{email}> (expires {os.environ['EXPIRES_AT']})")
EOF

# Optional sanity check via lhm if npx is available
if command -v npx >/dev/null 2>&1; then
  STATUS="$(npx -y @lobehub/market-cli auth status --output json 2>/dev/null \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['user']['status'])" 2>/dev/null || echo "unknown")"
  echo "lhm auth status: $STATUS"
fi
echo

if $DRY_RUN; then
  echo "DRY RUN: would update secret $SECRET_NAME in $REPO from $USER_CREDS"
  exit 0
fi

echo "=== Updating GitHub secret ==="
gh secret set "$SECRET_NAME" --repo "$REPO" < "$USER_CREDS"
echo "Secret $SECRET_NAME updated in $REPO."

if $RUN_PUBLISH; then
  echo
  echo "=== Triggering lobehub-publish workflow ==="
  gh workflow run lobehub-publish.yml --repo "$REPO"
  echo "Workflow dispatched. Watch with: gh run list --repo $REPO --workflow lobehub-publish.yml"
fi
