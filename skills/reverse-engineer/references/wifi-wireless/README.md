---
name: wifi-wireless
description: Use for authorized wireless security assessment including Wi-Fi capture, WPA handshake analysis, rogue AP detection research, and lab-only deauth testing.
---

# Wi-Fi / Wireless Security

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read precedent-pentest for context (not authorization); **Wireless attacks carry high legal risks**, written authorization and physical scope are required
2. `NOW`: scope specifies the target SSID/BSSID/ site; scanning neighbors' networks is prohibited
3. `NEXT`: Confirm adapter listening mode capability
4. `ACT`: Reconnaissance → Collection → Analysis (Laboratory First)

## Applicable Scenarios

- Authorized Wi-Fi Security Assessment
- WPA/WPA2 Handshake Collection and Offline Evaluation
- Rogue AP / Phishing Hotspot Detection Research
- Enterprise Wireless Isolation and Portal Security

## Workflow

```text
□ iwconfig / airmon-ng enter monitor (legal environment)
□ airodump-ng lock target BSSID channel
□ Handshake or PMKID capture (target only)
□ hashcat/aircrack Offline Evaluation Password Policy
□ Report: Encryption Type, Isolation, Portal Bypass, Recommendations
```

## Toolchain

| Tool | Purpose |
|------|------|
| aircrack-ng suite | Collection/Evaluation |
| hcxdumptool / hcxtools | PMKID |
| hashcat | Password Evaluation |
| Wireshark | Management Frame Analysis |

## References

- `references/wireless-lab-rules.md`
- `../pentest-tools/` `../attack-chain/` (closely related chapters)

## Routing Context

**Upstream**: MASTER R29
**MUST NOT**: Unauthorized deauth, operations on non-target customer networks

## Task Completion Self-Check

- [ ] Strictly lock onto the target BSSID?
- [ ] Are reinforcement suggestions provided in the report?
- [ ] Checklist?