# reverse-skill In-package security audit (executable side)

> 2026-09-03 Review: Expanded to Git objects, payload identities, symlinks, binary allowlist, GitHub Action pinning and Gradle Wrapper verification. See [Repository security review — 2026-09-03](SECURITY-REVIEW-2026-09-03.md) for details.

> Date: 2026-08-02
> Scope: `references/**/scripts`, `references/scripts`, `kali/scripts`, `burp-mcp-full` executable scripts and bootstrap manifests
> **Excludes**: `src-hunter` / payloader and other **teaching payload documents** (its DROP/injection samples are methodology and are not automatically executed)

## Conclusion (overall review)

| Level | Judgment |
|------|------|
| **Backdoor/Active database deletion/Format disk** | **Not found** |
| **Pipeline download execution (curl\|sh/IEX DownloadString)** | **Not found** |
| **Hardcoded Cloud Key/Private Key** | **Not Found** (`sk-` / `BEGIN RSA` in the documentation are detection examples) |
| **Supply Chain Residual Risk** | **Partially Hardened (Medium-Low → Low)**: Pinned `@latest`; GitHub download support **manifest SHA256 + API digest** |

**General comments: No embedded backdoor or "one-click library deletion" logic has been found in the executable skill script interface; dangerous deletions are limited to the tool reinstall temporary directory/case output directory. **

### 2026-07-18 Reinforcement (this submission)

| Item | Action |
|----|------|
| jshookmcp | `@latest` → `@0.3.4` |
| pentestswarm | `@latest` / docker `:latest` → `@v0.1.0` / `:v0.1.0` |
| jadx | pin `v1.5.6` + `assetSha256` |
| apktool | pin `v3.0.2` + `assetSha256` |
| bootstrap PS/sh | After downloading `Assert-DownloadedFileIntegrity` / `verify_sha256`; priority is manifest hash, followed by GitHub `digest`; failure to delete file and abort |
| release with unpinned hashes | still installs, but **WARN** and prints actual sha256 |

### 2026-08-02 Security fixes

| Item | Repair |
|----|------|
| Kali quick setup | Use `getent` to resolve sudo user home, remove `eval` |
| Frida process listing | Use `frida-ps` parameter array to remove inline Python code splicing |
| Burp MCP token | Use restricted temporary file atomic replacement, POSIX file permissions fixed to `0600` |
| Burp MCP bridge | Parse newline messages according to MCP and reconnect as needed after Burp starts |
| Anything Analyzer MCP | bootstrap enables bearer auth by default and registers credentials via optional hosting adapter |
| IDA MCP startup | End old processes one by one to avoid multi-PID parameter expansion errors |

## Scanning method

Retrieve executable extensions (`.ps1`/`.sh`/`.py`/`.js`/`.java`):

- `Invoke-Expression` / `IEX` / `FromBase64String` / `DownloadString`
- `curl|bash` / `wget|sh` pipeline execution
- `DROP DATABASE|TABLE`、`rm -rf /`、`Remove-Item ... C:\Windows`
- Rebound shell form (`/dev/tcp` abuse, `TcpClient` backlink)
- Hidden window startup (for review purposes)

Round 2: Manual reading of `bootstrap-reverse.ps1/.sh` download and deletion paths, `mcp-bridge.js`, charts/cryptography Python scripts.

## Discovery details

### 1. Deletion operations (all expected cleanup, not deletion of the database)

| Location | Behavior | Risk |
|------|------|------|
| `bootstrap-reverse.ps1` `Expand-ArchiveIntoDirectory` | Delete the target installation directory and reinstall; delete `%TEMP%\reverse-bootstrap-*` | Only the tool installation path, not the user business library |
| `bootstrap-reverse.ps1` anything-analyzer | on failure `Remove-Item node_modules` after `pnpm install` | limited clone tool repository |
| `apk-reverse/scripts/decode.*` | Clean up task output directory jadx/apktool out | Limit task root |
| `case-init.ps1` | Clean up the temporary directory | Temporary |
| `bootstrap-reverse.sh` | Similar temp / installation target cleanup | Same as left |

**Not Found** For `DROP`/`TRUNCATE` executable logic on `C:\`, system directory, any database connection string.

### 2. Network behavior (tool bootstrapping, not C2)

| Location | Behavior | Description |
|------|------|------|
| `bootstrap-reverse.ps1` | `api.github.com` pull release; `Invoke-WebRequest` download zip/jar | Warehouse name comes from **manifest whitelist** |
| `bootstrap-reverse.sh` | `curl` / `git clone` / `pipx` / `npm` | Same as above |
| `mcp-bridge.js` | `127.0.0.1:9876` only HTTP → Burp | Local loopback |
| `ToolDiscovery.ps1` | Probe `http://host:port/mcp` | Health Check |
| `kali/.../tool-discovery.sh` | `(echo >/dev/tcp/$host/$port)` | **Port detection**, non-bounce shell |

### 3. Hide window

| Location | Purpose |
|------|------|
| `bootstrap-reverse.ps1` `Start-Process ... -WindowStyle Hidden` | Background startup `pnpm dev` (anything-analyzer) |
| `ida-reverse/scripts/start.ps1` | Start IDA related processes (need to remain in the background) |

It is a service startup state, and no hidden malicious payloads were found.

### 4. "Danger words" in document/payload (not automatically executed)

`pentest-tools/src-hunter`, `attack-chain`, etc. **Markdown/JSON Teaching Materials** Contains SQL injection, `DROP` examples, log cleaning **Red Team Methodology**.
These **will not be automatically executed** by bootstrap or master-route; execution relies on AI/human selection under **authorized scope**.

For relevant constraints, see: `ops/scope-contract.md`, `ops/skill-supply-chain.md`, `field-journal/precedent-*.md`.

### 5. Residual risks in the supply chain (recommend subsequent reinforcement, not confirmed backdoor)

| Item | Risk | Recommendation |
|----|------|------|
| `bootstrap-manifest.json` Medium `@jshookmcp/jshook@0.3.4`, `pentestswarm@v0.1.0` | Tag Drift / Supply Chain Poison Surface | Pinned Version Number + Checksum |
| GitHub release zip **No SHA256 verification** | It is difficult to detect in time when the release is replaced | Add `assetSha256` to manifest and verify it in bootstrap |
| `npm install -g` / `pip` default source | Inherent risk of relying on the ecosystem | Only install manifest capability; use private source/lock for production environment |

## Executable script list (audit baseline)

```
references/scripts/*.ps1|*.sh + lib/ToolDiscovery.ps1
references/apk-reverse/scripts/*
references/radare2/scripts/*
references/ida-reverse/scripts/*
references/browser-automation/scripts/*
references/diagram-generator/scripts/*.py
references/case-review/scripts/*.py
kali/scripts/*
burp-mcp-full/mcp-bridge.js (+ Java extension source)
```

## Recommended ongoing checks

```powershell
# Quick Executable Surface Health Check (Example)
rg -n "Invoke-Expression|FromBase64String|DownloadString|rm -rf /|DROP DATABASE" references/scripts references/*/scripts kali/scripts burp-mcp-full -g "*.ps1" -g "*.sh" -g "*.py" -g "*.js"
```

You should run this list again before merging the **executable script** of the newly added skill; it is not mandatory to change only the Markdown methodology.

## Sign

- Audit execution: local static scan of warehouse + manual review of critical path
- Result: No backdoor/no automatic deletion; supply chain reinforcement is listed as a follow-up improvement item