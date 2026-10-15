# Community Safety Skill Ecology Comparison (2026-07)

> Source Retrieval Date: **2026-07-17**
> Purpose: To let reverse-skill **know what exists outside**, borrow as needed, and **not** incorporate external massive libraries entirely into this package.
> This package identity: routing + tool bootstrap + evidence/scope contract + field-journal (see `ops/IDENTITY.md`).

## 1. External High-Value Repositories (Can be Learned, Do Not Install Blindly)

| Warehouse | Scale/Positioning | Value to this package | Risk |
|------|-----------|------------|------|
| [trailofbits/skills](https://github.com/trailofbits/skills) | ToB Security Research Claude Plugin Market | Audit/Vulnerability Analysis/RE Plugin Quality Benchmark | Must be installed according to the ToB market; do not trust non-curated copies by default |
| [trailofbits/skills-curated](https://github.com/trailofbits/skills-curated) | Reviewed Plugin List | Takes precedence over any community skill | Same as above |
| [Orizon-eu/claude-code-pentest](https://github.com/Orizon-eu/claude-code-pentest) | 6 pentest lifecycle skills + pure Python scripts | Reconnaissance → Exploitation → Reporting pipeline can benchmark our `attack-chain` + `pentest-tools` | Authorization boundaries need self-check; scripts must be sandboxed |
| [trilwu/secskills](https://github.com/trilwu/secskills) | 16 skills + 6 expert subagents | Multi-role division can be benchmarked against `ops/role-map.md` | Plugin form, different from the monorepo of this package |
| [Masriyan/Claude-Code-CyberSecurity-Skill](https://github.com/Masriyan/Claude-Code-CyberSecurity-Skill) | ~15–19 domain skills (including RE/OT/CSOC) | Domain coverage checklist | Depth not as high as single-domain skills in this package |
| [mukul975/Anthropic-Cybersecurity-Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills) | **800+** skills · ATT&CK/NIST mapping | **Framework mapping** and domain directory can be referenced, not suitable to rely on the entire database | Too large in volume, maintenance and attack surface are huge |
| [Eyadkelleh/awesome-skills-security](https://github.com/Eyadkelleh/awesome-claude-skills-security) | SecLists packaged as agent skills | Dictionary/payload entry | Overlaps with seclists bootstrap |
| [securityfortech/awesome-security-skills](https://github.com/securityfortech/awesome-security-skills) | Security Skill Selected List | Index for Discovering New Skills | List Type, Requires Individual Review |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1000+ cross-vendor skill index | Discover official/community skills | Not for security use |
| [anthropics/claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | PR Security Review GitHub Action | Can benchmark our docs/report side 'Change Audit' scenario | CI product, not RE routing |
| [agentskills.io](https://agentskills.io) | Agent Skills Open Standard | frontmatter/Table of Contents Convention Alignment | The standard itself contains no offense or defense content |

### 1.1 Second Round Retrieval Supplement (Re-searched on 2026-07-17)

| Warehouse / Resources | Location | This package drop point |
|-------------|------|----------|
| [trailofbits/skills](https://github.com/trailofbits/skills) Plugin: `audit-context-building` `differential-review` `semgrep-rule-creator` `sharp-edges` `dwarf-expert` `burpsuite-project-parser` | Audit context, differential security review, dangerous APIs, DWARF, Burp project analysis | Refer to `ida-reverse`/`docs-generator`/audit workflow; **do not** merge the entire repository |
| [HexRaysSA/ida-claude-code-plugins](https://github.com/HexRaysSA/ida-claude-code-plugins) | Official IDA Claude Plugin (includes domain automation, marks unsafe) | `ida-reverse` MCP path mapping; unsafe plugins are not enabled by default |
| [P4nda0s/reverse-skills](https://github.com/P4nda0s/reverse-skills) | IDA-NO-MCP: Export after decompilation for further analysis; rev-frida/dex-dump/u3d | Complementary to 'Offline Export When MCP Is Unavailable' |
| [2389-research/binary-re](https://github.com/2389-research/binary-re) | triage→static(r2/Ghidra)→dynamic(QEMU/GDB/Frida)→synthesis | `reverse-engineering` stage gate latch see `re-agent-workflow.md` |
| [incogbyte/android-reverse-engineering-claude-skill](https://github.com/incogbyte/android-reverse-engineering-claude-skill) | APK unpacking, endpoint extraction, adaptive Frida bypass | Refer to `apk-reverse`; dynamic scripts require scope |
| [OwenPawl/cerberus-re-skill](https://github.com/OwenPawl/cerberus-re-skill) | Apple to Ghidra+LLDB+Frida three loops | Can refer to macOS/iOS dynamic loop |
| [ljagiello/ctf-skills](https://github.com/ljagiello/ctf-skills) | CTF reverse/pwn; Install tools as needed | Refer to CTF-Sandbox + `pwn-chain` |
| [shuvonsec/claude-bug-bounty](https://github.com/shuvonsec/claude-bug-bounty) | /recon→/hunt→/validate→/report | Compare `recon-pipeline.md` + scope door |
| [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) | Web payload + Prompt Injection Chapter | `pentest-tools/payloads` Priority; LLM see `llm-security` |
| [HackTricks](https://hacktricks.wiki/) | Penetration Methodology + **AI/MCP Abuse** | See skill-supply-chain MCP section |
| [appsecsanta AI pentesting agents 2026](https://appsecsanta.com/research/ai-pentesting-agents-2026) | 39+ open-source AI penetration agent architecture classifications | Multiple agents ≠ necessary; we use role-map |
| Snyk evaluation: 'More skills ≠ better' | Skill stacking may reduce audit quality | Strengthen the 'deep skill + routing' strategy |

## 2. Safety Standards and Threats (2025–2026)

| Source | Key Points | Focus of This Package |
|------|------|----------|
| [OWASP Agentic Skills Top 10](https://owasp.org/www-project-agentic-skills-top-10/) | Malicious skills, supply chain, privilege abuse, memory poisoning, etc. | `ops/skill-supply-chain.md` |
| [Anthropic Agent Skills Engineering Doc ](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | Install only trusted sources; audit scripts and dependencies | Same as above + bootstrap forbids guessing paths |
| ClawHavoc and other poisoning activities (recorded in AST10) | Batch malicious skills in the registry | Prohibit one-click installation from unknown registry into this package |

## 3. Existing in this package vs external 'wide' coverage

| Field | reverse-skill | Commonly external, the reason we don't fully integrate into the repository |
|------|---------------|--------------------------------|
| APK/JS/IDA/r2/ firmware/pwn | **deep** skill + script | maintain deep connection with tool-index |
| Penetration/Attack Chain/SRC | pentest-tools + attack-chain + src-hunter | Orizon-like methodology reference |
| LLM/Agent Security | llm-security | AST10 Enhanced skill self-security |
| Evidence/scope/role | **ops/** (features) | Most skill packages do not have case contracts |
| OT/ICS / Pure GRC / Fraud F3 | No independent skill | Route not hit → Suggest adding or external link, do not force in |
| 800+ micro skills | No copying | Replace fragmentation with MASTER routing + domain skills |

## 4. Reference Rules (MUST)

```text
1. It is forbidden to use git submodule to pull the entire repository of 800+ skills as runtime dependencies
2. When referencing: extract the 'phase/checklist/command pattern' and write it into this package's references or existing skill
3. External scripts: First check dependencies and network behavior in an isolated environment, then consider bootstrap-manifest
4. New scenario: Add a new skill in CONTRIBUTING, and update routing + RULES keywords
5. Annotate source URL + retrieval date (this file format)
6. Pre-installation/merging ops/skill-supply-chain.md Checklist
7. At runtime, only load the PRIMARY of MASTER-ROUTING (+ necessary secondary) to avoid skill stack overload
```

## 4.1 The "Reference Products" Already Accumulated in This Package (Non-External Library Dependencies)

| Product | Path |
|------|------|
| RE Four Stages | `reverse-engineering/references/re-agent-workflow.md` |
| Authorized Reconnaissance | `pentest-tools/references/recon-pipeline.md` |
| Attack Chain Latch | `attack-chain/references/lifecycle-checklist.md` |
| Skill Supply Chain | `ops/skill-supply-chain.md` |
| Domain Coverage | `references/domain-coverage-map.md` |

## 5. Recommendation Priority (Subsequent Iterations)

| Priority | Action |
|--------|------|
| P0 completed | ops contract, MASTER routing, skill supply chain security documentation |
| P1 | Compare Orizon/ToB, supplement pentest phase checklist to attack-chain references |
| P2 | Optional "external link skill whitelist" configuration, does not follow the default path |