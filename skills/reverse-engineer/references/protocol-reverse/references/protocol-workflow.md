# Protocol reverse quick reference

> Applicable: `protocol-reverse` skill · 2026-07-18

## Common Layout Patterns

| Mode | Features | Tips |
|------|------|------|
| Fixed-length header + body | First 2/4 byte length | Note whether the header length is included |
| Magic Number | Fixed `0xDEAD` etc. | Convenient for stream resynchronization |
| TLV | type-length-value repetition | type enumerates the message dictionary |
| Protobuf | Field number varint | `protoc --decode_raw` |
| Encrypted frame | High entropy, no plaintext URL | First look for nonce/IV neighborhood |

## Minimal Python Skeleton

```python
import struct
def parse_frame(buf: bytes):
    magic, length, msg_type = struct.unpack_from(">IHI", buf, 0)
    body = buf[10:10+length]
    return {"magic": magic, "type": msg_type, "body": body}
```

## Extract TCP payload from PCAP

```bash
tshark -r cap.pcap -Y "tcp.port==4433" -T fields -e tcp.payload | head
```