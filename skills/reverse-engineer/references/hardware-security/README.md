---
name: hardware-security
description: Use for authorized hardware and embedded interface security research including UART/JTAG discovery, debug pad triage, secure boot overview, and offline firmware extraction support.
---

# Hardware / Embedded Interface Security

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Confirm **physical contact authorization** and device ownership
2. `NOW`: ESD/Power Safety; Default Read-Only Detection
3. `NEXT`: Conduct image analysis jointly with firmware-pentest
4. `ACT`: Shell and debug interface identification → consoles → extraction

## Applicable Scenarios

- UART / JTAG / SWD Debug Port Discovered
- Boot log, root shell, boot interruption
- Assist with disassembling the device to extract the Flash
- Feasibility assessment of secure boot/encrypted Flash (non-destructive approach preferred)

## Workflow

```text
□ Disassemble the authorized device; take photos and mark the test points
□ Multimeter finds GND/VCC/TX/RX; logic level 1.8/3.3/5V
□ USB-TTL read-only log; record baud rate
□ JTAG: Enumerate IDCODE; evaluate whether it is locked
□ Extract image → Handover firmware-pentest / ghidra
```

## Toolchain

| Tool | Purpose |
|------|------|
| USB-TTL / logic analyzer | UART |
| J-Link / CMSIS-DAP | Debug |
| bus pirate / flipper (laboratory) | multi-protocol |
| binwalk / flashrom | extract |

## References

- xKx0000xKx
- xKx0001xKx xKx0002xKx

## Routing Context

**Upstream**: MASTER R34
**MUST NOT**: Unauthorized disassembly/damage to others' devices

## Task Completion Self-Check

- [ ] Record the interface levels and pin diagram?
- [ ] Is the mirror hash-protected?
- [ ] Checklist?