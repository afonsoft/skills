---
name: digital-forensics
description: Use for authorized digital forensics including memory dumps, disk timelines, PCAP investigation, artifact triage, and IR evidence preservation.
---

# Digital Forensics & IR Artifacts

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` for context; confirm organize IR authorization instructions via scope.md
2. `NOW`: Confirm that it is **evidence collection/tracing** rather than offensive scanning
3. `NOW`: Create case; evidence read-only copy preferred (original media write-protected)
4. `NEXT`: tool-index; Volatility and other common manual methods
5. `ACT`: Preserve Hash → Timeline → Key Artifact

## Applicable Scenarios

- Memory dump analysis (Volatility 2/3)
- Disk / E01 / Landing File Timeline
- PCAP tracing and protocol reconstruction (can be combined with `protocol-reverse/`)
- Host Artifacts: Prefetch, Shimcache, Event Log, Browser History
- Emergency Response IOC Extraction (in collaboration with `malware-analysis/` / `threat-hunting/`)

## Workflow

### 1. Preservation

```text
□ Calculate SHA256; record timezone and collection command
□ Work on a copy; original is read-only
□ chain of custody notes entered in the timeline
```

### 2. Memory

```bash
vol -f mem.dmp windows.info
vol -f mem.dmp windows.pslist
vol -f mem.dmp windows.netscan
vol -f mem.dmp windows.cmdline
```

### 3. Host Artifacts

```text
□ Event Logs: Security / PowerShell / Sysmon
□ Persistence: Run key, services, scheduled tasks, WMI
□ Execution traces: Amcache, Prefetch, BAM
```

### 4. Network

```text
□ tshark statistics for sessions and DNS
□ Export suspicious traffic → protocol-reverse or malware C2 analysis
```

## Toolchain

| Tool | Purpose |
|------|------|
| Volatility 3 | Memory |
| Timeline Explorer / Plaso | Super Timeline |
| tshark | PCAP |
| Eric Zimmerman Toolkit | Windows Artifacts |
| Autopsy / FTK Imager | Disk |

## References

- xKx0000xKx
- xKx0001xKx xKx0002xKx xKx0003xKx

## Routing Context

**Upstream**: MASTER R25
**Downstream**: In-depth analysis of malicious samples → malware analysis; rules → threat hunting

## Task Completion Self-Check

- [ ] Preserve hash and replica strategy?
- [ ] Can the timeline be reviewed?
- [ ] Does the IOC have desensitization levels?
- [ ] Checklist?