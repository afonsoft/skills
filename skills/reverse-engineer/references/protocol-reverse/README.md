---
name: protocol-reverse
description: Use for authorized reverse engineering of custom binary protocols, Protobuf/gRPC, WebSocket frames, and PCAP-driven protocol recovery.
---

# Protocol Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm authorization and regular operation boundaries
2. `NOW`: Confirm whether the task is **protocol/traffic/serialization format** reverse engineering (not purely web parameter signing → go to `js-reverse/`)
3. `NOW`: If there is interaction with the target network → `../scripts/case-init.ps1` complete scope; `auth` if not granted, prohibit actions on the target ACT
4. `NEXT`: Read `../tool-index.md`; missing tool bootstrap (tshark/wireshark and others may need to be done manually)
5. `ACT`: Enter workflow Phase 1, produce draft frame layout or message dictionary

## Applicable Scenarios

- Custom TCP/UDP binary protocol
- Protobuf / gRPC / FlatBuffers / MessagePack
- WebSocket / MQTT / Private RPC
- PCAP / PCAPNG Restore Fields and State Machine
- Client-server verification, serial number, encrypted frame header

## Not Using This Skill

| Situation | Where to go |
|------|------|
| HTTP parameter signature / JS encryption only | `js-reverse/` |
| Only TLS certificate issues | `pentest-tools/` or browser proxy |
| In-depth exploration of the firmware protocol stack + simulation | `firmware-pentest/` then recover the skill |

## Workflow

### Phase 1 — Collection and Triage

```text
□ Obtain samples: PCAP / proxy export / client logs / binaries
□ Direction marker: C→S / S→C; whether there is handshake, heartbeat, reconnection
□ Fixed header? Magic number? Length field? TLV? Fixed length?
□ Whether to compress (zlib/gzip/lz4) or encrypt (AES/ChaCha within the frame)
□ tshark -r cap.pcap -T fields -e frame.number -e ip.src -e tcp.payload
```

### Phase 2 — Frame Layout Restoration

```text
□ Align multiple similar messages, find unchanged bytes / increment sequence numbers
□ Length field: big-endian/little-endian, including header/not including header
□ Verification: CRC16/32, checksum, HMAC position
□ Draw the state machine: Connect → Auth → Ready → Request/Response → Close
□ Tools: Wireshark custom dissector draft / ImHex / 010 Editor template / Kaitai Struct
```

### Phase 3 — Serialization and Encryption

```text
□ Protobuf: .proto restoration (blackboxprotobuf / pbtk / protoc --decode_raw)
□ gRPC：HTTP/2 headers + protobuf body
□ Encryption: Find key derivation (client so/dll/JS) → Combined ida-reverse / js-reverse / apk-reverse
□ Replay: Only within the authorized scope; non-sensitive fields first, then sensitive operations
```

### Phase 4 — Products

```text
MUST Output:
- Message type table (name / opcode / fields)
- At least one reproducible decoding command or script
- Evidence: Original hex excerpt + decoded result (anonymized)
```

## Toolchain

| Tool | Essential | Purpose | Bootstrap |
|------|------|------|------|
| tshark / Wireshark | Strongly Recommended | PCAP Analysis | Manual / winget |
| Python3 | is | decoding script | system |
| blackboxprotobuf | Optional | Unknown protobuf | pip |
| ImHex / 010 | Optional | Structure Template | Manual |
| IDA / r2 / Ghidra | As needed | Client-side serialization functions | See corresponding skill |

## References

- `references/protocol-workflow.md` — Frame Layout and Protobuf Quick Reference
- Related: `../ida-reverse/` `../js-reverse/` `../firmware-pentest/` `../pentest-tools/`

## Routing Context

**Upstream**: `MASTER-ROUTING` R21 · `routing.md`
**Downstream**: Requires client-side algorithm → `ida-reverse`/`js-reverse`; Requires replay → `pentest-tools`/`api-security`
**Same level**: `malware-analysis` (C2 protocol), `digital-forensics` (traffic forensics)

## Task Completion Self-Check

- [ ] Has the message layout or state machine been restored (rather than just pasting hex)?
- [ ] Is there a reproducible decoding command?
- [ ] Are the scope / desensitization being followed?
- [ ] Whether to write back to the field-journal / report Checklist?