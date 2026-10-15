---
name: threat-hunting
description: Use for blue-team threat hunting, detection engineering with Sigma/YARA, SIEM query design, and incident detection validation.
---

# Threat Hunting & Detection Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Confirm Blue Team/Hunting authorization and data source scope (SIEM, EDR export)
2. `NOW`: Clearly define the hypothesis before checking the data, to avoid mindlessly triggering alerts
3. `NEXT`: Tools and Data Access Methods
4. `ACT`: Hypothesis → Query → Verification → Regularization

## Applicable Scenarios

- Threat Hunting (hypothesis-driven)
- Sigma / YARA Detection Project
- Alarm tuning and false alarm analysis
- With `malware-analysis/`: sample-side IOC → detection implemented in this skill
- With `digital-forensics/`: Case Phantasm → Lateral Hunting

## Workflow

### 1. Form a Hypothesis

```text
Example: The attacker uses living-off-the-land for lateral movement
→ Data sources: Sysmon 1/3/10, Windows Security 4624/4648
→ Success criteria: detecting abnormal parent processes or rare account log sources
```

### 2. Querying and Stacking

```text
□ Baseline: Normal administrator activity periods and hosts
□ Abnormal: New service, coding PowerShell, abnormal outbound
□ Association: Multiple hosts logging in briefly with the same account
```

### 3. Regularization

```yaml
# See Sigma framework in malware analysis; this skill emphasizes:
# - False Positive Surface
# - Data Source Field Mapping
# - Response playbook link
```

### 4. Verification

```text
□ Atomic testing (Atomic Red Team) only in authorized laboratories
□ Replay historical logs to verify recall
```

## Toolchain

| Tool | Purpose |
|------|------|
| Sigma CLI / sigmac | Rule Conversion |
| YARA | File/Memory |
| SIEM (ELK/Splunk, etc.) | Query |
| osquery | endpoint hunting |
| Atomic Red Team | Detection Verification (Laboratory) |

## References

- xKx0001xKx
- xKx0002xKx
- xKx0003xKx

## Routing Context

**Upstream**: MASTER R27
**Downstream**: Confirm intrusion → forensics; Malicious sample → malware analysis
**MUST NOT**: Run attack simulations in an unauthorized production environment

## Task Completion Self-Check

- [ ] Is there a clear hypothesis and conclusion?
- [ ] Does the rule specify false positives and data sources?
- [ ] Checklist?