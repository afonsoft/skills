---
name: ot-ics
description: Use for authorized OT/ICS security assessment covering Purdue model zoning, PLC/SCADA exposure, industrial protocol discovery, and safe passive-first evaluation.
---

# OT / ICS Security

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` — **Improper operation in an industrial control environment may cause physical harm**
2. `NOW`: The written authorization must clearly state: site, network segment, and whether active scanning/writing to registers is allowed
3. `NOW`: case-init; default **passive-first**; writing operations to PLC are prohibited before `ready_for_act`
4. `NEXT`: tool-index; most industrial control tools need to be manually connected to an isolated experimental network
5. `ACT`: Asset and zone identification → Attack surface → Read-only verification

## Applicable Scenarios

- Industrial Control/SCADA/DCS Security Assessment (Authorized)
- Purdue Model Segmentation and Cross-Zone Channels
- Modbus/DNP3/S7/EtherNet/IP and other protocols exposed
- Engineer Station, HMI, Historical Database, Jump Host
- IT/OT Integration boundary (firewall rules, one-way gate)

## Safety Rules (MUST)

```text
MUST NOT when not explicitly permitted:
- Write coil/register to PLC
- High-speed scanning of production OT across the entire network
- Interrupt the paths related to the Safety Instrumented System (SIS)
Priority: Read-only recognition, traffic mirroring, offline firmware/configuration analysis
```

## Workflow

### Phase 1 — Zoning and Assets

```text
□ Purdue L0–L5 Sketch: Field Devices → Control → Supervision → Site DMZ → Enterprise
□ Asset List: PLC/RTU/HMI/ Engineer Station/History Library/Jump Host
□ Protocol and Port Baseline (Authorized Network Segments Only)
```

### Phase 2 — Passive and Read-Only

```text
□ SPAN/Mirrored PCAP → protocol-reverse / Wireshark Industrial Control Analyzer
□ Configuration and engineering file offline audit (exporting TIA/RSLogix, etc.)
□ Default passwords and plaintext protocols (Modbus without authentication) are recorded as Findings, no configuration changes are made
```

### Phase 3 — Restricted Active (Authorized Only)

```text
□ Low-speed recognition, maintenance window
□ Read-only function code priority
□ Evidence at each step; stop immediately and report if abnormal
```

### Phase 4 — Firmware/Patch Side

```text
□ Controller firmware version → CVE mapping (do not blindly flash firmware)
□ Collaborate with firmware-pentest to perform offline image analysis
```

## Toolchain

| Tool | Purpose | Notes |
|------|------|------|
| Wireshark Industrial Control Dissectors | Passive Analysis | Mirrored Traffic |
| Nmap NSE (Restricted) | Identification | Rate and Time Window |
| Claroty/Nozomi etc. | Asset Discovery | Commercial/On-Site |
| PLC Vendor Engineering Software | Configuration Audit | Offline First |
| binwalk / Ghidra | firmware | offline |

## References

- xKx0001xKx
- xKx0002xKx xKx0003xKx xKx0004xKx via pentest-tools

## Routing Context

**Upstream**: MASTER R28
**Downstream**: Firmware deep dive `firmware-pentest`; Protocol `protocol-reverse`; IT horizontal `windows-ad`/`attack-chain`
**Peers**: Don't use ordinary web to scan default parameters for OT

## Task Completion Self-Check

- [ ] Is it passive/read-only by default and records the authorization boundary?
- [ ] Is writing to the control circuit avoided (unless explicitly allowed)?
- [ ] Does the finding include an explanation of physical/process impacts?
- [ ] Checklist / journal?