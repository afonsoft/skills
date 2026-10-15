# Quick Reference for Encryption/Decryption and Encoding/Decoding Tools

> Encryption/encoding/hash data is often encountered in reverse engineering and CTF. This document lists the most practical tools by scenario.

---

## Automatic Recognition + Decryption (when you don't know what encryption was used)

| Tool | Stars | Purpose | Link |
|------|-------|------|------|
| **Ciphey** | 18k+ | AI automatically identifies and decrypts (supports 50+ encodings/encryptions/hashes) | https://github.com/Ciphey/Ciphey |
| **CyberChef** | 29k+ | Online/Offline encoding and decoding Swiss Army knife (drag-and-drop operation) | https://github.com/gchq/CyberChef |
| **dcode.fr** | — | Online 900+ password/code/mathematics tools | https://www.dcode.fr/ |

### Using Ciphey

```bash
pip install ciphey
# Automatically detect and decrypt
ciphey -t "密文"
# Read from file
ciphey -f encrypted.txt
```

Ciphey supports: Base64/32/16, Caesar, Vigenere, XOR, AES (weak keys), Morse, Binary, Hex, URL encoding, HTML entities, hash recognition, etc.

### Using CyberChef

```text
Online version: https://gchq.github.io/CyberChef/
Offline version: Download the HTML file from the GitHub Release and open it directly

Common Recipe:
- From Base64 → Decode Base64
- XOR → XOR decryption (key can be brute-forced)
- AES Decrypt → AES Decrypt
- Magic → Automatically detect encoding type
```

---

## Hash Identification and Cracking

| Tool | Purpose | Link |
|------|------|------|
| **hashID** | Identify hash type (MD5/SHA/bcrypt, etc.) | https://github.com/psypanda/hashID |
| **hash-identifier** | Same as above, Python version | https://github.com/blackploit/hash-identifier |
| **haiti** | Modern hash identification tool (more accurate) | `gem install haiti` |
| **Hashcat** | GPU hash cracking | https://hashcat.net/ |
| **John the Ripper** | CPU Hash Cracking | https://www.openwall.com/john/ |
| **hashes.com** | Online hash lookup (rainbow table) | https://hashes.com/ |

```bash
# Identify Hash Types
hashid '5f4dcc3b5aa765d61d8327deb882cf99'
# Output: [+] MD5

# haiti (more accurate)
haiti '5f4dcc3b5aa765d61d8327deb882cf99'

# Hashcat Cracking
hashcat -m 0 hash.txt rockyou.txt  # MD5
hashcat -m 1000 hash.txt rockyou.txt  # NTLM
```

---

## RSA Attack

| Tool | Purpose | Link |
|------|------|------|
| **RsaCtfTool** | RSA automatic attack (20+ attack methods) | https://github.com/Ganapati/RsaCtfTool |
| **SageMath** | Mathematical computation (large number factorization / elliptic curves) | https://www.sagemath.org/ |
| **factordb.com** | Online Large Number Factorization Lookup | http://factordb.com/ |
| **yafu** | Local Large Number Factorization | https://github.com/bbuhrow/yafu |

```bash
# RsaCtfTool Automatic Attack
python RsaCtfTool.py --publickey pub.pem --private
python RsaCtfTool.py --publickey pub.pem --uncipherfile cipher.txt

# Supported Attacks:
# Wiener、Boneh-Durfee、Fermat、Pollard p-1、Williams p+1
# Common modulus, Small q, Hastads, Noveltyprimes, etc.
```

---

## XOR Analysis

| Tool | Purpose | Link |
|------|------|------|
| **xortool** | XOR key length guessing + known-plaintext attack | https://github.com/hellman/xortool |
| **CyberChef XOR** | Visual XOR Operation | Built-in to CyberChef |

```bash
# Guess XOR key length
xortool encrypted_file
# Decrypt using the guessed key length
xortool -l 4 -c 00 encrypted_file

# Known-plaintext attack (knowing part of the plaintext)
xortool-xor -f encrypted -s "known_plaintext"
```

---

## Classical Cryptography

| Password Type | Tool | Description |
|---------|------|------|
| Caesar | CyberChef / dcode.fr | Brute force 25 types of shifts |
| Vigenere | dcode.fr / Ciphey | Needs to guess key length |
| Substitution | quipqiup.com | Frequency Analysis Automatic Solver |
| Enigma | dcode.fr | Online Simulator |
| Rail Fence | dcode.fr / CyberChef | Rail Fence Cipher |
| Playfair | dcode.fr | requires key |
| Morse | CyberChef | Dots and Dashes to Text |
| Bacon | dcode.fr | Binary Steganography |
| ROT13/47 | CyberChef / `tr` | Simple Replacement |

---

## Encoding Recognition and Conversion

| Code | Identification Features | Decoding Method |
|------|---------|---------|
| Base64 | Ends with `=` or `==`, character set A-Za-z0-9+/ | `base64 -d` / CyberChef |
| Base32 | Uppercase letters + 2-7, ending with `=` | CyberChef |
| Base58 | No 0/O/I/l, commonly used in short identifier encoding | CyberChef |
| Hex | Only 0-9a-f, even length | `xxd -r -p` / CyberChef |
| URL encoding | `%XX` format | `urldecode` / CyberChef |
| HTML entities | `&#XX;` or `&amp;` format | CyberChef |
| Unicode escape | `\uXXXX` format | Python `decode('unicode_escape')` |
| JWT | `xxxxx.yyyyy.zzzzz` (three-part Base64URL) | jwt.io / CyberChef |
| Brainfuck | Only `><+-.,[]` eight characters | Online Interpreter |
| Ook! | Only `Ook.` `Ook!` `Ook?` | Online Interpreter |

---

## Encryption Recognition in Reverse Engineering

### Through Constant Recognition Algorithm

| Constant/Feature | Algorithm |
|-----------|------|
| `0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476` | MD5 |
| `0x6A09E667, 0xBB67AE85, 0x3C6EF372` | SHA-256 |
| `0x63, 0x7C, 0x77, 0x7B` (starting with S-Box) | AES |
| `0x243F6A88` (hexadecimal of π) | Blowfish |
| `0xB7E15163, 0x9E3779B9` | RC5/RC6/TEA |
| `0x61707865` ("expa") | ChaCha20/Salsa20 |
| `0xC6EF3720` | XTEA |

### Through Behavior Recognition

| Behavioral Characteristics | Possible Algorithms |
|---------|-----------|
| 256-byte lookup table + swap operation | RC4 |
| 16-byte block + multiple rounds of substitution | AES |
| Feistel structure (left-right swap) | DES/Blowfish/TEA |
| Large Number Multiplication/Modular Exponentiation | RSA |
| Elliptic Curve Point Operations | ECDSA/ECDH |
| Fixed 64-round cycle | TEA/XTEA |
| 32 rounds + delta constant | XTEA |

---

## Automated Password Analysis

| Tool | Purpose | Link |
|------|------|------|
| **FeatherDuster** | Automated Password Analysis Framework | https://github.com/nccgroup/featherduster |
| **PkCrack** | Known-plaintext attack on ZIP | https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html |
| **bkcrack** | ZIP known-plaintext attack (modern version) | https://github.com/kimci86/bkcrack |
| **z3** | SMT solver (constraint solving) | https://github.com/Z3Prover/z3 |
| **angr** | Symbolic execution (automatically solve inputs) | https://angr.io/ |

---

## Fast Decision Tree

```text
Received a piece of unknown data:

1. Look at the length and character set
- Only hex characters → possibly hex encoding or hash
- Ends with = → Base64
- Ellipsis → JWT
- 32/40/64 character hex → hash (MD5/SHA1/SHA256)

2. Automatically try with Ciphey
ciphey -t "data"

3. If Ciphey fails → use CyberChef Magic mode

4. If it is a hash → hashID identification type → Hashcat/John crack

5. If it is RSA → RsaCtfTool automatic attack

6. If it is XOR → use xortool to analyze the key

7. If it is traditional ZIP encryption → prioritize using `bkcrack` known-plaintext attack, do not start with an evidence-less password brute force

8. If it is custom encryption → IDA/Ghidra reverse algorithm → manually write decryption script
```

---

## Online Resources

| Resource | Link | Purpose |
|------|------|------|
| CyberChef | https://gchq.github.io/CyberChef/ | Universal Encoder/Decoder |
| dcode.fr | https://www.dcode.fr/ | 900+ password tools |
| quipqiup | https://quipqiup.com/ | Automatic substitution cipher solver |
| factordb | http://factordb.com/ | RSA large number factorization |
| jwt.io | https://jwt.io/ | JWT Decode/Verify |
| hashes.com | https://hashes.com/ | Hash Reverse Lookup |
| crackstation | https://crackstation.net/ | Online Hash Cracking |