# Universal Scope contract (hard threshold for task startup)

> **MUST**: Any security/reverse/penetration tasks land `scope.md` at `work/<case>/` of the current user analysis project before **ACT**.
> No scope → Only allowed to read documents/routes, **prohibited** from actively scanning, hooking, and exploiting targets.
> The template can be copied; field names remain in English to facilitate script verification.

## How to initialize

Windows：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File references\scripts\case-init.ps1 -Hint "<任务一句话>" -CaseName "my-case"
# Default output: work/<case>/scope.md of the current analysis project
# When calling a skill from another directory, explicitly specify: -ProjectRoot "C:\path\to\analysis-project"

# Legal local offline sample: auth granted + offline + explicit sample → ready_for_act=true
powershell -NoProfile -ExecutionPolicy Bypass -File references\scripts\case-init.ps1 `
  -Hint "offline apk" -CaseName "my-sample" -Preset offline-sample -Sample ".\app.apk"
```

Linux / macOS / Kali：

```bash
bash references/scripts/case-init.sh --hint "<任务一句话>" --case-name "my-case"
# Default output: caller current analysis project's work/<case>/scope.md etc.
# When calling from other directories, explicitly specify: --project-root "/path/to/analysis-project"

# Legal Local Offline Samples
bash references/scripts/case-init.sh \
  --hint "offline apk" --case-name "my-sample" \
  --preset offline-sample --sample ./app.apk
```

`-PackageRoot` / `--package-root` are reserved as compatibility parameters; new processes should use `ProjectRoot` / `--project-root` to represent the case artifact's owning project.

## scope.md complete template

```markdown
# Case Scope

## meta
- case_id: {YYYYMMDD-short}
- created: {ISO-8601}
- operator: {name or local}
- project_root: {caller analysis project}
- primary_skill: {from master-route}
- lead_role: lead   # see ops/role-map.md
- specialist_roles: []  # e.g. cie, cpe, cre

## auth
- status: granted | pending | denied
- basis: written_contract | bug_bounty_scope | ctf_public | own_system | lab_only
- evidence_of_auth: {ticket/path or "CTF public" or "owner-operated"}
- MUST NOT proceed if status != granted

## in_scope
- assets: []          # hosts, domains, APK paths, binaries, URLs
- surfaces: []        # web, mobile, binary, network, api
- activities: []      # recon, reverse, exploit_validate, report

## out_of_scope
- assets: []
- activities: []      # e.g. DoS, phishing real users, data exfil

## network_profile
- mode: offline | lab_only | authorized_target_only | unrestricted_lab
- notes: |
offline = no external outsourcing (pure static/local samples)
lab_only = only lab/VM IP
authorized_target_only = only in_scope assets
- MUST NOT use unrestricted against production without written auth

## deliverables
- report: true
- field_journal: true
- diagrams: true
- timeline: true

## constraints
- timebox: {}
- stealth: low | medium | high
- data_handling: anonymize | no_user_pii

## signoff
- ready_for_act: false
- checklist:
  - [ ] auth.status = granted
  - [ ] in_scope.assets non-empty OR offline sample path set
  - [ ] network_profile.mode chosen
  - [ ] out_of_scope reviewed
```

## Routing hooks (required for AI)

```text
RULES / MASTER-ROUTING / SKILL:
  1) master-route → PRIMARY
2) Platform native case-init or handwritten scope.md
3) auth is not granted → STOP, only additional authorized materials are allowed
4) ready_for_act = true → open PRIMARY README.md → ACT
```

`case-guard -Force` / `case-guard --force` are compatible parameters and MUST NOT bypass `auth.status`, legal scope, network profile or `ready_for_act` hard doors.

## network_profile quick check

| mode | allow | disallow |
|------|------|------|
| `offline` | Static analysis, local files, simulation | Any external connection, public network RPC |
| `lab_only` | lab/CTF target network segment | Production/unauthorized IP |
| `authorized_target_only` | in_scope list | assets outside the list |
| `unrestricted_lab` | Isolation Experiment Network (written) | Internet Production |

## feature

- Pure Markdown, **no database**
- Orthogonal to `tool-index` / bootstrap: scope controls "whether it can be beaten", tool-index controls "what to use"