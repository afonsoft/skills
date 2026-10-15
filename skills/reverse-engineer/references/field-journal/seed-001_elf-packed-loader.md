# [seed] ELF self-extracting loader reverse engineering

## Scene classification
binary analysis

## Goal Overview
Analyze an ARM64 ELF self-extracting loader disguised as a .sh script and restore its decompression algorithm and payload injection process.

## Complete execution link

1. `file` command to confirm the real type (ELF, not shell script)
2. `readelf -l` View the program header → found that the 3rd PHDR is deliberately damaged (0x0a padding)
3. `rabin2 -I` gets the architecture (AArch64), entry point, and compiler information
4. IDA/Ghidra loading → start analysis from the entry point
5. Identify LZSS decompression loop (bit stream operation + sliding window copyback)
6. Identify the injection process of mmap → decompression → mprotect → jump
7. Rewrite the decompressor in Python and dump the payload
8. Analyze the payload content (including /proc/self/exe reference, indicating that it is a process injector)

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| readelf error report cannot be parsed | The third PHDR is deliberately filled with 0x0a | Ignore the damaged PHDR and only look at the first 2 LOAD segments | 10min |
| IDA decompilation result is unreadable | ARM64-bit operations are intensive and Hex-Rays is not well optimized | Switch to the disassembly view for manual analysis | 30min |
| The output of the decompressor Python implementation is wrong | The pop_bit refill path return value is wrong (adcs vs adds) | Check the assembly carefully, the bit31 of the newly loaded word is returned during refill | 2h |
| Unsure of the payload entry offset | The meaning of the entry_offset field in the data table is unclear | Trace the `br mmap_base + 0x14` of the loader function and confirm that the entry is at +0x14 | 20min |

## Toolchain discovery

- `file` command is the first step, never trust file suffix
- `rabin2 -I` is more fault tolerant than `readelf` (can handle corrupt PHDR)
- ARM64-bit operation-intensive code, the decompiler is not as good as looking at the assembly directly
- Python struct module + handwritten decompressor is the standard way to analyze custom compression

## Key code/command

```bash
# Confirm File Type
file LinYuDriverLoader4.9.sh
# ELF 64-bit LSB executable, ARM aarch64

# View program header
readelf -l binary 2>/dev/null | head -20

# Extract Compressed Data
dd if=binary bs=1 skip=$((0xa6a24)) count=1981 of=compressed.bin

# Calculate file offset
# vaddr 0x3d66bc → file_offset = 0x3d66bc - 0x330000 = 0xa66bc
```

```python
# LZSS Decompressor Core (Simplified)
def decompress(data):
    shift_reg = 0x80000000
# ... bitstream reading + literal/match branches
```

## Suggestions for improving this package

- `elf-analysis.md` should add more features of "custom compression algorithm identification"
- The ARM64 syscall table should contain instructions for cache maintenance instructions (dc cvau / ic ivau)
- It is recommended to add a general methodology of "How to rewrite assembly algorithms in Python"

## Reusable patterns/script snippets

**Standard mode for recognizing self-extracting ELF**:```text
Entry point → A small amount of initialization → Call the decompression function → mmap(RW) → Decompress to the mmap area → mprotect(RX) → Jump
```

**Common mode for ARM64 bitstream reading**:```text
lsl w4, w4, #1 # Shift left (extract the highest bit to carry)
cbz w4, refill # If empty, load new 32-bit from input
```

## Evolution action
- [x] Updated sub-skill documentation (elf-analysis.md has been added)
- [ ] No need to update routing matrix
- [ ] No need to update bootstrap-manifest

## Environment information
- OS: Linux/Android ARM64 target
- Tool version: IDA Pro / Ghidra + radare2
- Target platform: Android ARM64 (AArch64)

## Desensitization requirements
This article is seed data, written based on public technical models, and does not involve real goals.

---
<!-- [Community Contribution] Seed data, no PR required -->