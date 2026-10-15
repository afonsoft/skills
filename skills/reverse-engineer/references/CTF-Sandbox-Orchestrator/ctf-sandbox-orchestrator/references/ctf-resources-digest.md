# CTF Resource Essentials Quick Reference

> Selected from [awesome-ctf-resources](https://github.com/devploit/awesome-ctf-resources)] and [awesome-ctf](https://github.com/apsdehal/awesome-ctf)]
> Classified by CTF challenge type, only keep the most practical tools and resources.

---

## Comprehensive Framework

| Tool | Purpose | Link |
|------|------|------|
| Pwntools | Exploit Development Framework (Python) | https://github.com/Gallopsled/pwntools |
| ctf-tools | One-click installation of CTF toolset | https://github.com/zardus/ctf-tools |
| Ciphey | AI Automatic Decryption | https://github.com/ciphey/ciphey |
| CyberChef | Online Encoding/Decoding / Encryption/Decryption | https://gchq.github.io/CyberChef/ |

---

## Web Class

### Tools
| Tool | Purpose |
|------|------|
| Burp Suite | HTTP Intercept/Replay/Scan |
| SQLMap | SQL Injection |
| XSStrike | XSS Detection |
| dirsearch | Directory Discovery |
| JWT_Tool | JWT Attack |
| SSRFmap | SSRF Exploitation |

### Common Exam Points
- SQL Injection (Union Query / Blind Injection / Time-based Blind Injection / Stacked)
- XSS (Reflected/Stored/DOM)
- SSRF (Internal Network Detection / Cloud Metadata)
- File upload (bypassing suffix/MIME/content detection)
- Deserialization (PHP/Java/Python pickle)
- Template Injection (SSTI)
- JWT forgery/key confusion

### Payload Reference
- https://github.com/swisskyrepo/PayloadsAllTheThings
- https://book.hacktricks.wiki/

---

## Reverse Class

### Tools
| Tool | Purpose |
|------|------|
| IDA Pro / Ghidra | Decompilation |
| radare2 / r2 | CLI Analysis |
| angr | Symbolic Execution |
| Frida | Dynamic Hook |
| GDB + pwndbg | Debugging |
| uncompyle6 | Python Decompilation |
| jadx | Android decompilation |
| dnSpy | .NET Decompilation |

### Common Exam Points
- Algorithm restoration (encryption/encoding/custom)
- Anti-debugging/anti-virtual machine bypass
- Shell/Obfuscation (UPX/VMProtect/OLLVM)
- Solve constraints with symbolic execution
- Dynamic Hook bypass check
- Go/Rust Reverse (Symbol Recovery)

---

## Pwn Class

### Tools
| Tool | Purpose |
|------|------|
| Pwntools | Exploit Writing |
| GDB + pwndbg/GEF | Debug |
| ROPgadget | ROP Chain Construction |
| one_gadget | libc one-shot |
| checksec | Protection Check |
| LibcSearcher | libc version identification |

### Common Exam Points
- Stack Overflow (ret2text/ret2libc/ret2shellcode/ROP)
- Pile utilization (UAF/double free/tcache/fastbin)
- Formatted string (arbitrary read/write)
- Integer overflow
- Kernel Pwn (Privilege Escalation / Race Condition)
- Sandbox escape (seccomp bypass)

### Common payload modes```python
# ret2libc template
from pwn import *
elf = ELF('./vuln')
libc = ELF('./libc.so.6')
p = process('./vuln')
# leak libc base → calculate system/binsh → overwrite ret
```

---

## Crypto Class

### Tools
| Tool | Purpose |
|------|------|
| SageMath | Mathematical Computation |
| RsaCtfTool | RSA Automatic Attack |
| hashcat/john | Hash Cracking |
| CyberChef | Encoding and Decoding |
| z3 (SMT solver) | Constraint Solving |

### Common Exam Points
- RSA (small public key exponent/common modulus/Wiener/Coppersmith)
- AES (ECB/CBC padding oracle/bit flipping)
- Classical cipher (Caesar/Vigenere/ permutation)
- Hash length extension attack
- Elliptic Curve (ECDSA nonce reuse)
- Ge password (LLL/CVP)

---

## Forensics Class

### Tools
| Tool | Purpose |
|------|------|
| Volatility | Memory Forensics |
| Autopsy/Sleuth Kit | Disk Forensics |
| Wireshark | Traffic Analysis |
| binwalk | Firmware/File Extraction |
| foremost | File Recovery |
| exiftool | Metadata Extraction |

### Common Exam Points
- Memory dump analysis (process/password/malicious code)
- PCAP traffic analysis (HTTP/DNS/TCP reassembly)
- File System Analysis (Deleted File Recovery / Hidden Partition)
- Log Analysis (Web Logs/System Logs)
- Disk image analysis

---

## Misc/Stego Class

### Tools
| Tool | Purpose |
|------|------|
| StegSolve | Image Steganalysis |
| zsteg | PNG/BMP Steganography |
| steghide | JPEG Steganography |
| Audacity | Audio Analysis |
| strings/xxd | Basic Analysis |
| file/binwalk | File Type Identification |

### Common Exam Points
- LSB Steganography (Least Significant Bit of the image)
- File Header Repair/Merging
- QR Code/Barcode
- Audio Spectrogram Steganography
- ZIP pseudo-encryption / known-plaintext attack
- Code Identification (Base64/Hex/Morse/Braille)

---

## Online Platform

| Platform | Features | Link |
|------|------|------|
| CTFTime | Event Calendar + writeup | https://ctftime.org/ |
| HackTheBox | Practical Target Machine | https://www.hackthebox.com/ |
| TryHackMe | Guided Learning | https://tryhackme.com/ |
| PicoCTF | Beginner-Friendly | https://picoctf.org/ |
| pwnable.kr | Pwn Special | http://pwnable.kr/ |
| cryptopals | Crypto Special | https://cryptopals.com/ |
| OverTheWire | War Series Challenges | https://overthewire.org/ |
| Root-Me | Comprehensive Challenge | https://www.root-me.org/ |

---

## Writeup Resources

| Resource | Link |
|------|------|
| CTFTime Writeups | https://ctftime.org/writeups |
| 0xdf hacks stuff | https://0xdf.gitlab.io/ |
| LiveOverflow (YouTube) | https://www.youtube.com/c/LiveOverflow |
| John Hammond (YouTube) | https://www.youtube.com/c/JohnHammond010 |
| IppSec (HTB walkthrough) | https://www.youtube.com/c/ippsec |