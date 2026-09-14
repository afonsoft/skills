#!/usr/bin/env bash
# Refresh the LobeHub Market user OAuth token and update the GitHub secret.
#
# The market-cli login flow is OAuth2 PKCE with a localhost callback, which
# cannot complete on headless machines (CI runners, SSH boxes, containers).
# This script bridges the gap:
#   1. Starts `lhm login` locally (callback server listens on localhost)
#   2. Prints the authorization URL — you open it in any browser
#   3. After authorizing, the browser redirects to a dead
#      http://localhost:<port>/callback?code=...&state=... URL
#   4. You paste that URL back here; the script replays it against the
#      local callback server, completing the token exchange
#   5. The fresh ~/.lobehub-market/user-credentials.json is pushed into
#      the LOBEHUB_USER_CREDENTIALS GitHub secret
#
# Prerequisites:
#   - Node.js >= 22 (npx)
#   - gh CLI authenticated with secret write access to the repo
#   - curl
#
# Usage:
#   ./refresh-lobehub-auth.sh              # refresh token + update secret
#   ./refresh-lobehub-auth.sh --dry-run    # stop before updating the secret
#   ./refresh-lobehub-auth.sh --run-publish # also trigger lobehub-publish.yml
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDS_DIR="$HOME/.lobehub-market"
USER_CREDS="$CREDS_DIR/user-credentials.json"
SECRET_NAME="LOBEHUB_USER_CREDENTIALS"
LHM=(npx -y @lobehub/market-cli)
DRY_RUN=false
RUN_PUBLISH=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --run-publish) RUN_PUBLISH=true ;;
    -h|--help)
      sed -n '2,25p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    *) echo "ERROR: unknown argument: $arg" >&2; exit 2 ;;
  esac
done

for cmd in npx gh curl python3 setsid; do
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

LOG="$(mktemp -t lhm-login.XXXXXX.log)"
LOGIN_PID=""

cleanup() {
  if [[ -n "$LOGIN_PID" ]]; then
    kill -- -"$LOGIN_PID" 2>/dev/null || true
  fi
  rm -f "$LOG"
}
trap cleanup EXIT

echo "=== Starting lhm login (callback server on localhost) ==="
setsid "${LHM[@]}" login >"$LOG" 2>&1 &
LOGIN_PID=$!

AUTH_URL=""
for _ in $(seq 1 60); do
  AUTH_URL="$(grep -oE 'https://[^ ]+/lobehub-oidc/auth\?[^ ]+' "$LOG" 2>/dev/null | head -1 || true)"
  [[ -n "$AUTH_URL" ]] && break
  if ! kill -0 "$LOGIN_PID" 2>/dev/null; then
    echo "ERROR: lhm login exited before printing the auth URL:" >&2
    cat "$LOG" >&2
    exit 1
  fi
  sleep 1
done

if [[ -z "$AUTH_URL" ]]; then
  echo "ERROR: timed out waiting for the auth URL from lhm login" >&2
  cat "$LOG" >&2
  exit 1
fi

PORT="$(printf '%s' "$AUTH_URL" | grep -oE 'localhost(%3A|:)[0-9]+' | grep -oE '[0-9]+' | head -1)"

cat <<EOF

>>> ACTION REQUIRED <<<

1. Open this URL in your browser and authorize with your LobeHub account:

   $AUTH_URL

2. The browser will redirect to a localhost URL that WILL NOT LOAD
   (the callback server is running here, not on your machine). Expected.

3. Copy the FULL URL from the address bar — it looks like:
   http://localhost:${PORT:-PORT}/callback?code=...&state=...

4. Paste it below and press Enter. (Ctrl+C to abort.)

EOF

read -r -p "Paste callback URL: " CALLBACK_URL

if [[ ! "$CALLBACK_URL" =~ ^https?://(localhost|127\.0\.0\.1):[0-9]+/callback\? ]] \
  || [[ "$CALLBACK_URL" != *code=* ]] \
  || [[ "$CALLBACK_URL" != *state=* ]]; then
  echo "ERROR: that doesn't look like the redirect URL. Expected http://localhost:<port>/callback?code=...&state=..." >&2
  exit 1
fi

echo
echo "=== Replaying callback against local server ==="
curl -sf -o /dev/null "$CALLBACK_URL" || {
  echo "ERROR: callback request failed — the login session may have timed out. Re-run this script." >&2
  exit 1
}

# Wait for the CLI to finish the token exchange and write credentials.
for _ in $(seq 1 15); do
  if ! kill -0 "$LOGIN_PID" 2>/dev/null; then break; fi
  sleep 1
done
kill -- -"$LOGIN_PID" 2>/dev/null || true
LOGIN_PID=""

if [[ ! -f "$USER_CREDS" ]]; then
  echo "ERROR: $USER_CREDS was not written — login did not complete" >&2
  cat "$LOG" >&2
  exit 1
fi

echo "=== Verifying authentication ==="
USER_STATUS="$("${LHM[@]}" auth status --output json 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['user']['status'])" || echo "unknown")"

if [[ "$USER_STATUS" != "authenticated" ]]; then
  echo "ERROR: user token still not valid (status: $USER_STATUS)" >&2
  exit 1
fi
echo "Authenticated."
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
