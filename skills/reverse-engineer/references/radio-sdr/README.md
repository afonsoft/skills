---
name: radio-sdr
description: Use for authorized RF/SDR security research including signal identification, replay feasibility study in shielded labs, and wireless protocol analysis outside classic Wi-Fi.
---

# RF / SDR Security Research

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: **The spectrum and emissions are strictly regulated by law**; only authorized frequency bands/shielded rooms/experimental targets
2. `NOW`: scope specifies the device, frequency band, and whether transmission is allowed (default is receive-only)
3. `ACT`: Only receive recognition → demodulation analysis → laboratory reproduction evaluation

## Applicable Scenarios

- Wireless remote control/sensors and other non-Wi-Fi RF (licensed)
- ADS-B/remote control and other protocol research (legal reception)
- Division of labor with wifi-wireless: This skill focuses on **SDR general RF**; Wi-Fi offense and defense goes through R29

## Workflow

```text
□ Regulations and License Confirmation
□ Receive only: identification center frequency and modulation
□ GNU Radio / URH Analysis
□ Replay is only blocked in the room and allowed in writing
□ Conclusion Focus: Whether unauthorized control is possible / Hardening recommendations
```

## Toolchain

| Tool | Purpose |
|------|------|
| RTL-SDR / HackRF (Compliant) | Transceiving Hardware |
| URH / GNU Radio | Analysis |
| Inspectrum | Signal |

## References

- xKx0000xKx
- xKx0001xKx xKx0002xKx xKx0003xKx

## Routing Context

**Upstream**: MASTER R38
**MUST NOT**: Interfere with public communications, unauthorized transmissions

## Task Completion Self-Check

- [ ] Should it by default only receive and record regulatory boundaries?
- [ ] Checklist?