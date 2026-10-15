#!/usr/bin/env bash
# check-tools.sh — read-only tool-readiness check for a reference module.
#
# Usage:
#   check-tools.sh <module> [module...]   check specific module(s)
#   check-tools.sh --all                  check every module in config/module-tools.json
#   check-tools.sh --list                 list known module names
#   check-tools.sh --json                 machine-readable output
#
# Never installs anything. Missing tools print the manifest entry name so the
# user can decide whether to bootstrap via scripts/bootstrap-reverse.sh.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAP="${MODULE_TOOLS_MAP:-$HERE/../config/module-tools.json}"
MANIFEST="${BOOTSTRAP_MANIFEST:-$HERE/bootstrap-manifest.json}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "check-tools: python3 is required" >&2
  exit 2
fi
if [[ ! -f $MAP ]]; then
  echo "check-tools: module map not found: $MAP" >&2
  exit 2
fi

MODE_JSON=0
modules=()
for arg in "$@"; do
  case "$arg" in
    --json) MODE_JSON=1 ;;
    --all)  mapfile -t modules < <(python3 -c 'import json,sys;print("\n".join(sorted(json.load(open(sys.argv[1])))))' "$MAP") ;;
    --list) python3 -c 'import json,sys;print("\n".join(sorted(json.load(open(sys.argv[1])))))' "$MAP"; exit 0 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) modules+=("$arg") ;;
  esac
done

if [[ ${#modules[@]} -eq 0 ]]; then
  echo "usage: check-tools.sh <module> [module...] | --all | --list" >&2
  exit 2
fi

REA_OK=0
if command -v rea >/dev/null 2>&1 || npx --no-install rea-agents --help >/dev/null 2>&1; then
  REA_OK=1
fi

python3 - "$MAP" "$MANIFEST" "$REA_OK" "$MODE_JSON" "${modules[@]}" <<'PY'
import json, shutil, sys

map_path, manifest_path, rea_ok, mode_json = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4] == "1"
modules = sys.argv[5:]

modmap = json.load(open(map_path))
try:
    manifest = json.load(open(manifest_path))
    cap_names = {c["name"] for c in manifest.get("capabilities", [])}
except Exception:
    cap_names = set()

# manifest name -> verify command (for bootstrap hint lookup)
try:
    verify = {c["name"]: c.get("verifyCommand") or c["name"] for c in manifest.get("capabilities", [])}
    verify_by_cmd = {v: k for k, v in verify.items()}
except Exception:
    verify_by_cmd = {}

report = {}
rc = 0
for mod in modules:
    if mod not in modmap:
        print(f"check-tools: unknown module '{mod}' (see --list)", file=sys.stderr)
        rc = 2
        continue
    entry = modmap[mod]
    groups = {}
    for kind in ("required", "optional"):
        rows = []
        for tool in entry.get(kind, []):
            present = shutil.which(tool) is not None
            hint = verify_by_cmd.get(tool) or (tool if tool in cap_names else None)
            rows.append({"tool": tool, "present": present, "bootstrap": hint})
        groups[kind] = rows
    report[mod] = groups
    missing_req = [r["tool"] for r in groups["required"] if not r["present"]]
    if missing_req and rc == 0:
        rc = 1

if mode_json:
    print(json.dumps({"rea": rea_ok, "modules": report}, indent=2))
else:
    print(f"REA (rea-agents): {'OK' if rea_ok else 'missing — run scripts/install-rea.sh'}")
    for mod, groups in report.items():
        print(f"\n[{mod}]")
        for kind in ("required", "optional"):
            rows = groups[kind]
            if not rows:
                continue
            for r in rows:
                mark = "ok" if r["present"] else "MISSING"
                hint = f"  (bootstrap: {r['bootstrap']})" if (r["bootstrap"] and not r["present"]) else ""
                print(f"  {kind:8s} {mark:7s} {r['tool']}{hint}")
        miss = [r["tool"] for r in groups["required"] if not r["present"]]
        if miss:
            print("  -> install via references/scripts/bootstrap-reverse.sh or the hint above (requires approval)")
sys.exit(rc)
PY
