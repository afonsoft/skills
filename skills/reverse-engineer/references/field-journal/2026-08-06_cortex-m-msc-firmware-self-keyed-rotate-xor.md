# 2026-08-06 Cortex-M virtual disk upgrade firmware comes with mask rotation/XOR packaging

## Scene classification

Binary/firmware reverse engineering

## Goal Overview

Analyze a Cortex-M debug tool upgrade package to identify its custom packaging algorithm and differentiate between the application image in the upgrade package and the USB Mass Storage bootloader residing on the device.

## Scope Summary (Desensitization)

- auth_basis: own_system
- network_profile: authorized_target_only (actually a local offline sample)
- asset_types: [firmware_container, cortex_m_application, usb_msc_updater]

## Role

- lead_role: lead
- specialists: [cre, cce, doc]

## Complete execution link

1. Make statistics on the length, entropy, tail period and chunking of the original package and find that the file size is an integer multiple of 1 KiB and the tail has a 7-byte period.
2. Starting from Cortex-M vector table constraints, enumerate single-byte rotation/XOR relationships, restoring the first block first.
3. It is found that each 1 KiB block resets the rotation phase, and the first ciphertext byte of the block can be directly used as the XOR mask of the block.
4. Decode each block using `P[i] = ROR8(C[i], (3*i) mod 7) XOR C[0]` and use the inverse transform to reconstruct the original packet byte by byte.
5. Cross-verify with the second official firmware of the same series: the legal vector table, version string and readable code are recovered in the same format; all block first plaintext bytes are zero.
6. Use the vector target address and file offset to deduce the application base address and confirm that the upgrade package does not contain a pre-bootloader.
7. Combined with the official "Enter bootloader/simulating USB disk" instructions, reconstruct the external process of copying MSC files to Flash writing, and mark the internal details of the bootloader as inference.
8. Test common CRC, STM32 hardware CRC, Adler and accumulation on the tail 32-bit field, no match, left as unresolved integrity field.

## Evidence chain summary (desensitization)

| E-id | source_type | Reusable command pattern | Association Finding |
|---|---|---|---|
| E-001 | local_binary | Block entropy, period tail, vector constraints | F-001 |
| E-002 | derived_algorithm | Block header mask + ROR/XOR + round-trip | F-001 |
| E-003 | static_analysis | Vector, string, Thumb disassembly | F-002 |

## Finding / Path Summary

- top_finding: Some high-entropy firmware packages are simply obfuscated with the native mask ROR/XOR reset by 1 KiB and should not be prematurely classified as standard encryption.
- path_type: solve/callflow
- path_one_liner: cycle and block structure → vector table crib → first block recovery → block boundary reset → second firmware cross-validation → application/bootloader boundary → MSC upgrade external process.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|---|---|---|---|
| First use the "majority bytes after derotation" of each block as a mask, a few blocks still have garbled characters | The most common plaintext byte of text-dense blocks is not necessarily zero | Compare the first byte model of the block; the garbled characters disappear and reappear in the second firmware | Medium |
| Single full file XOR/rotation only works at the beginning | Rotation phase and mask reset every 1 KiB | Explicit chunking by `0x400` | Low |
| IDA and radare2 failed to start | There is no IDA path on this machine, the r2 bootstrap installer is abnormal | Use Python + Capstone to verify the Cortex-M entry | Medium |
| When seeing `firmware_crc32`, assume that the end is a standard CRC32 | The string is a metadata key and cannot prove the tail parameters and coverage | The system retains unknowns after excluding common families and does not force naming | Low |

## Toolchain discovery

- Python is suitable for bitwise transformation enumeration, round-trip and cross-sample invariant verification.
- Capstone is sufficient to verify Cortex-M vector entry and local control flow when IDA/Ghidra/radare2 is missing.
- String recovery quality is a strong signal for comparing candidate masking models, but must be combined with absolute pointers and disassembly to avoid relying solely on "looks readable".

## Key algorithm

```text
block_size = 0x400
mask = packed_block[0]
rotation(i) = (3 * i) mod 7
plain[i] = ROR8(packed[i], rotation(i)) XOR mask
```

Use `ROL8` for inverse transformation; the verification standard is that the encoding result is the same as the original packet byte by byte.

## Suggestions for improving this package

- Add a check of "whether the block boundary is reset period" in the container identification phase of firmware-pentest.
- When the heuristic zero-byte crib fails on a few blocks, give priority to testing self-describing masks at the beginning/end of the block.
- For the case of "upgrade package only contains applications", the report must separately mark the internal behavior of the bootloader and the inevitable behavior of the protocol layer.

## Reusable patterns

1. First check whether the cycle is reset according to common Flash/transfer block sizes (256, 512, 1024, 2048, 4096).
2. Use Cortex-M’s SRAM stack pointer and Thumb Reset Vector as strong crib.
3. Perform three verifications on each candidate model: full-file round-trip, second sample recurrence, and absolute address reference consistency.
4. When the tail field does not match common validations, do not use variable names or strings as algorithm evidence.

## Evolution action

- [x] Added field-journal record
- [x] Updated field-journal index
- [ ] Updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation

## Environment information

- OS: Windows
- Tool version: Python 3.12, Capstone 5.0.6
- Target platform/version: Cortex-M3 / F1 compatible MCU, application area firmware

## Desensitization check

- [x] No real domain name, IP, certificate, token, PII
- [x] No local absolute path
- [x] No sample file body and sample hash
- [x] Vendor, product and version information has been generalized