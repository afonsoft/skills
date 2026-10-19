# examples/ctf-demo — Complete process example

> This directory demonstrates the standard workflow of reverse-skill: **Routing → Authorization Access Control → Timeline → Evidence Chain → Report**.
> The content is a fictitious example (CTF range) and is only used to demonstrate how it works.

## Process Demonstration

```text
1. User task: "Analyze this CTF pwn question, stack overflow gets"
2. Route: master-route.ps1 -Hint "CTF pwn stack overflow" → PRIMARY R17 (pwn-chain)
3. Type:case-init.ps1 -Hint ... -CaseName ctf-demo -AuthGranted → scope.md
4. Execution: timeline append + evidence E-001/E-002 + workitems update
5. Output: report (docs-generator) + field-journal desensitization precipitation
```

## document

| Documentation | Description |
|------|------|
| `scope.md` | case scope (auth granted / target / network_profile) |
| `timeline.md` | Append time line |
| `workitems.md` | Work Items and Coverage |
| `evidence/` | Evidence record example (E-001 reproduction command, E-002 crash output) |
| `report/` | Final report structure example |

## Real use

```powershell
# Initialize real case (authorized target)
powershell -NoProfile -File references/scripts/case-init.ps1 `
  -Hint "你的任务" -CaseName my-case -AuthGranted -TargetUrl "https://target/" `
  -NetworkProfile authorized_target_only

# Additional Evidence
powershell -File references/scripts/append-evidence.ps1 -CaseRoot work\my-case `
  -Id E-001 -Title "..." -ReproCommand "..."
```

> Note: The real case should be placed in `work/<case>/` (gitignored, to prevent leaks); this example directory is kept in git for reference.