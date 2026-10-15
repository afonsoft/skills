# reverse-skill v1.0.0

**First formal release** — 2026-07-18

AI-powered skill router for authorized reverse engineering, penetration testing, and security research.

## Highlights

| Area | What you get |
|------|----------------|
| **PRIMARY path** | `MASTER-ROUTING.md` + `master-route.ps1` → correct skill in one hop |
| **Ops contracts** | Scope / auth gate, Evidence→Finding→Path, roles, timeline |
| **Case tooling** | `case-init` · `case-guard` · `append-evidence` · `smoke` · `verify-routing-coherence` |
| **Skill matrix** | 20+ modules (APK, IDA, r2, JS, .NET, pwn, firmware, pentest, LLM, …) |
| **Bootstrap** | On-demand toolchain install from `bootstrap-manifest.json` |
| **Knowledge loop** | `field-journal` + docs-generator completion checklist |
| **Platforms** | Windows primary; Linux / macOS / Kali supported paths |

## Install (quick)

```bash
git clone https://github.com/zhaoxuya520/reverse-skill.git
cd reverse-skill
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File references/scripts/refresh-tool-index.ps1
# Linux / macOS
bash references/scripts/refresh-tool-index.sh
```

Point your AI client at `RULES.md` / `README_AI.md`. See [README.md](../README.md).

## Verify

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File references/scripts/smoke.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File references/scripts/verify-routing-coherence.ps1
```

## Breaking / intentional product boundary

- This pack is a **skill router + bootstrap + journal**, not a full host security platform.
- Local tool paths live only in generated `tool-index` (not shipped in the tag content as absolute machine paths).

## Full changelog

See [CHANGELOG.md](../CHANGELOG.md#100--2026-07-18).

## License

MIT — see [LICENSE](../LICENSE).
