# Agent Skill Supply Chain Security (Features of this package)

> Comprehensive sources: OWASP Agentic Skills Top 10 (AST10), Anthropic Agent Skills security recommendations, public poisoning incidents (such as ClawHavoc, see AST10 timeline)
> Search date: 2026-07-17
> Applicable: When installing/writing/merging **any** skill, MCP, bootstrap scripts

The **executable script side** of this package is static audit (backdoor/library deletion/pipeline execution): [`docs/PACKAGE-SECURITY-AUDIT.md`](../../docs/PACKAGE-SECURITY-AUDIT.md).

## 1. Why does reverse-skill need to manage this separately?

This package will:

- Guidance AI **execute commands and bootstrap downloads**
- Contact local and network through MCP
- write to field-journal/report

Malicious skills can lead to: credential theft, persistent prompts, and supply chain backdoors.
We use **Document Latch + Tool Truth Source** instead of building another skill app store.

## 2. Threat comparison (simplified AST10 idea)

| Risk category | Performance | This package control |
|--------|------|----------|
| Malicious/poisoning skill | Inducing exfil, writing memory/backdoor | Only trust this repository + external sources authorized by the user in writing; external sources must manually read README.md and scripts first |
| Excessive permissions | No difference `curl \| bash`, full disk read | bootstrap only manifest capability; scope `network_profile` |
| Dependency poisoning | pip/npm malicious package | Prioritize official release; record version to tool-index |
| MCP blind faith | Unaudited MCP server | tool-index registration status + port detection; remote MCP is not trusted by default |
| MCP/CLI automatically executes poisoning | Warehouse `.env` changes to `CODEX_HOME`, etc., causing malicious MCP to be executed upon startup (HackTricks/CVE type case) | Do not trust the default MCP configuration in the warehouse; check the env and MCP list before starting the Agent |
| Prompt injected into skill | SKILL hidden instructions hidden in text | Review diff; prohibit "execution instructions hidden in HTML comments" without user permission |
| Scope drift | Skill induces expanded scanning / "Automatically penetrate a domain name" | ops/scope-contract: out_of_scope + auth; prohibit scanning without in_scope |
| Skill stack overload | Mounting too many skills at the same time results in missed reports (public evaluation observation) | Only load PRIMARY + necessary secondary (MASTER-ROUTING) |

## 3. MUST list for installing external skills

```text
□ Source: official org / audited list (such as ToB curated) / user-owned
□ Read all README.md + scripts/* + package dependencies
□ No mysterious external connections, no default steps for reading ~/.ssh/browser library
□ When conflicting with the routing of this package: The MASTER-ROUTING + scope of this package shall prevail.
□ Do not copy into monorepo unless CONTRIBUTING and desensitization are used
□ Update references/references/community-security-skills.md record source date
```

## 4. Boundary to bootstrap / MCP

| Action | Allow | Disable |
|------|------|------|
| `bootstrap-reverse.ps1 -Capability X` | X ∈ bootstrap-manifest.json | Any new name without changing the manifest |
| Register MCP | User confirmation + tool-index refresh | Silently write global MCP pointing to unknown URL |
| Run community Python one-click pentest | Authorize lab + after reading source code | Direct production target + unknown script |

## 5. Author/contributor of this package

- New skill: CONTRIBUTING + ACTION REQUIRED + Complete self-test
- Quote community content: mark URL + date (this document / community-security-skills.md)
- If suspicious behavior is found: stop execution, inform the user, and do not automatically "try to bypass"

## 6. Quick self-check (before each merge of external materials)

```powershell
# List the script extensions to be imported
Get-ChildItem -Recurse -Include *.ps1,*.sh,*.py,*.js | Select-Object FullName
# Rough Search Danger Mode (Manual Review, Not Exhaustive)
# Execute in external directory: Select-String -Pattern 'Invoke-WebRequest|curl .\||wget .\||~/.ssh|exfil'
```

## 7. Related

- Identity: `IDENTITY.md`
- External directory: `../references/community-security-skills.md`
- License: `scope-contract.md` + `field-journal/precedent-auth.md`