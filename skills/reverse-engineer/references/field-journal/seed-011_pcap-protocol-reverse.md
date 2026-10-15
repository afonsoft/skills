# [Seed] PCAP Custom Binary Protocol Reverse Engineering

## Scene Classification
Packet Analysis / Protocol Reverse Engineering

## Overview of Goals
A certain IoT xKx0000xKx client uses a custom TCP binary protocol (not HTTP). A PCAP was captured, and it's necessary to restore the frame structure, field meanings, encryption layer (if any), and write a local xKx0001xKx reproduction.

## Complete Execution Chain

1. Open the PCAP with Wireshark and first do basic statistics
   - xKx0002xKx Check xKx0003xKx pair
   - xKx0004xKx check the data rhythm
2. Identify the actual application-layer traffic (strip away standard layers like TLS)
3. On a certain TCP stream → xKx0005xKx → switch to RAW mode → export
4. Binary-level observation: Are the first few bytes of each frame a fixed xKx0006xKx field?
   xKx0007xKx`bash
   xxd dump.bin | head -20
   xKx0008xKx`
5. Use hex mode to find patterns: fixed header, length, TLV, CRC
6. Write a Python parser (struct + scapy) to parse frame by frame
7. Synchronously reverse-lookup protocol fields from binary decompilation (check the struct around xKx0009xKx in IDA / Ghidra)
8. Verification: Send a frame from the client by yourself → server responds consistently

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| Wireshark does not recognize the protocol, only shows 'Data' | It is a private protocol, no parser | Write a Wireshark Lua dissector or directly analyze offline with Python | 30min |
| Looks irregular, each frame is different | Has compression or encryption layer | Use entropy analysis (xKx0010xKx) to determine if encrypted; locate xKx0011xKx field | 1h |
| The length field is calculated incorrectly | The length may be little-endian / big-endian / xKx0012xKx itself | Find several frames of different lengths, set up a system of equations to solve it | 40min |
| TLS captured but cannot be decrypted | Client does not keep SSLKEYLOGFILE | Capture plaintext by hooking at the client process level (Frida captures xKx0013xKx) | 1.5h |
| Data is correct but the server does not respond | Protocol carries an incrementing xKx0014xKx, replay is rejected | Figure out how seq is calculated (usually the hash of the previous frame or an incrementing counter) | 50min |

## Toolchain Discovery

- **Wireshark Lua Dissector** 用 < 100 行就能把私有协议变成 Wireshark 可视化
- **scapy** 写 Python parser 时定义 `Packet` 子类即可
- **Kaitai Struct** 用 YAML 描述协议结构，能生成多语言 parser（Python/Java/C++/JS），适合长期复用
- **NetworkMiner** 比 Wireshark 更适合"事后取证"（自动重组文件、识别凭证）
- **ent / binwalk -E** 看熵，>7.5 几乎肯定加密

## Key xKx0017xKx

Scapy custom protocol example (TLV):

```python
from scapy.all import *

class MyMsg(Packet):
    name = "MyProto"
    fields_desc = [
        StrFixedLenField("magic", b"\xab\xcd", 2),
        ByteField("version", 1),
        ByteField("type", 0),
        LenField("length", None, fmt="H"),     # H = uint16 BE
        XIntField("seq", 0),
        StrLenField("payload", "", length_from=lambda p: p.length - 8),
        XShortField("crc", 0),
    ]

# Analyzing PCAP
pkts = rdpcap('dump.pcap')
for p in pkts:
    if TCP in p and p[TCP].dport == 9527 and p.payload:
        msg = MyMsg(bytes(p[TCP].payload))
        msg.show()
```

Kaitai Struct YAML (preferred for long-term projects):

```yaml
# myproto.ksy
meta:
  id: myproto
  endian: be
seq:
  - id: magic
    contents: [0xab, 0xcd]
  - id: version
    type: u1
  - id: type
    type: u1
  - id: length
    type: u2
  - id: seq_no
    type: u4
  - id: payload
    size: length - 8
  - id: crc
    type: u2
```

Entropy Analysis:

```bash
binwalk -E dump.bin             # 熵图
ent dump.bin                    # 数值
```

## Suggestions for Improvement of This Package

- `reverse-engineering/platforms.md` added the chapter 'Four Steps to Reverse Engineer Custom Protocols'
- Added `reverse-engineering/references/kaitai-cheatsheet.md` quick search
- Added scapy (pip) and binwalk to the bootstrap manifest

## Reusable Patterns/Scripts Snippets

**Custom Protocol Reverse Engineering in 4 Steps**:

```text
1. Follow the rhythm (I/O diagram + Conversations to find conversation boundaries)
2. Find frame boundaries (magic / length / terminator)
3. Parse fields (fixed header, length, payload, checksum)
4. Verify encryption (entropy + find nonce + binary reverse lookup of the send function)
```

**Tips for Finding Frame Length**:

Export all PSH packets in the same stream → check the total length of each TCP segment, and see if the length field (try positions i, i+1, i+2) can determine the segment length.

## Evolution Actions
- [ ] reverse-engineering/platforms.md Add a chapter on protocol reverse engineering
- [ ] Add scapy / binwalk to bootstrap-manifest
- [ ] Add Kaitai Struct quick reference

## Environmental Information
- Kali / Ubuntu, Wireshark 4.x, Python 3.10+, scapy 2.5
- Target protocol: Custom TCP binary (including TLV / length prefix)
- Encryption layer: depends on the situation (commonly AES-CTR / ChaCha20)

## Desensitization Requirements
This entry is seed data, written based on reverse-engineering methods of public protocols, and does not involve real products.