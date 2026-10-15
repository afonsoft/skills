# [Seed] IoT Router Firmware Extraction + Getting Root via UART Serial Port

## Scene Classification
Firmware / IoT Security

## Overview of Goals
A mid-to-low-end home router, obtaining the firmware bin from the manufacturer's website, using binwalk to extract squashfs, then connecting to the device UART via serial port to get a root shell, and analyzing its web management interface and startup scripts.

## Complete Execution Chain

### Part 1: Firmware Analysis

1. Download the firmware file (manufacturer's official website / OpenWRT / dump the flash yourself)
2. Basic Recognition
   ```bash
   file firmware.bin
   binwalk firmware.bin                    # see LZMA / SquashFS / U-Boot
   binwalk -E firmware.bin                 # Use the entropy graph to determine if it is encrypted
   ```
3. Extract
   ```bash
   binwalk -e firmware.bin
   cd _firmware.bin.extracted/squashfs-root
   ```
4. Key Points of Static Analysis
   ```bash
   find . -name 'shadow' -exec cat {} \;          # default password hash
   find . -name '*.cgi' -o -name 'lighttpd*'      # Web services
   find . -name 'rcS' -o -name 'init.d'           # Startup scripts
   grep -r 'telnetd\|busybox' .                   # Suspicious backdoor
   strings $(find . -name 'httpd') | grep -i 'admin\|debug\|backdoor'
   ```
5. Get `/etc/shadow` offline crack:
   ```bash
   john --wordlist=rockyou.txt shadow
   ```

### Part 2: Hardware UART

1. Disassemble the device to look at the PCB → Find the 4-pin / 6-pin unoccupied connectors (usually not soldered or soldered with pins)
2. Identify with a multimeter
- GND (Ground connection copper pad)
- VCC (3.3V, stable at startup)
   - TX (more level changes at startup, outputting in the direction from UART → PC)
- RX (basically unchanged at startup)
3. Connect the USB-TTL converter (CP2102 / FT232)
- Route TX → USB-TTL RX
- Route RX → USB-TTL TX
   - Router GND → USB-TTL GND
- **Does not connect VCC** (device self-powered)
4. Open serial port listening on the host
   ```bash
   sudo screen /dev/ttyUSB0 115200
   # Or: minicom / picocom
   ```
5. Power on → Observe U-Boot output → Linux starts → Usually enter login prompt
6. Try default credentials / cracked shadow password → get root shell

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| After extraction with binwalk, it’s an empty directory | Some firmware uses a non-standard format (vendor proprietary header) | Manually extract by slicing and matching offsets with `dd`, or use `unblob` as a substitute for binwalk | 1h |
| binwalk -E shows entropy close to 1 | Fully encrypted | Find the decryption key used during firmware upgrades (usually hard-coded in the OEM tool) | Several hours |
| UART does not show any characters | Baud rate is incorrect | Try 9600 / 38400 / 57600 / 115200 / 460800 / 921600 | 30min |
| UART sees characters but they are garbled | TX/RX reversed / voltage level mismatch | 1) Swap TX RX 2) Confirm USB-TTL is 3.3V not 5V | 30min |
| login prompt but no password available | Not cracked + vendor default password changed | U-Boot stage key interrupt → `setenv bootargs ${bootargs} init=/bin/sh` → enter single user | 1.5h |
| U-Boot does not respond to key interrupts | Manufacturer disabled console / changed prompt | Look for `bootdelay` in the firmware, physically short the SPI flash to cause startup failure and let U-Boot enter interaction | Several hours |
| Got into root but telnetd doesn't work | No dropbear/telnetd in the image | Mount USB and copy a busybox-static in | 1h |

## Toolchain Discovery

- **unblob** is more powerful than binwalk (automatically recognizes more formats and won't get stuck on proprietary headers)
- **firmware-mod-kit** An old but still usable tool for unpacking/packing
- **firmwalker** automatically scans and extracts 'sensitive clues' (credentials/private keys/URLs/binary backdoors) from squashfs
- **EMBA** is an integrated firmware audit platform (automated version of firmwalker + binary CVE scanning + simulated boot)
- **FirmAE** uses QEMU to simulate the booting of IoT firmware, allowing dynamic analysis of the web interface without real hardware
- **ChirpStack USB-TTL** / **Bus Pirate** / **Tigard** all work, a cheap CP2102 is also enough

## Key Code/Commands

One-stop firmware audit:

```bash
# 1. Extract
unblob -k firmware.bin -o extracted/

# 2. Run firmwalker
git clone https://github.com/craigz28/firmwalker
./firmwalker.sh extracted/squashfs-root

# 3. Simulated Startup (if supported)
docker run -it --rm -v $(pwd):/firmware firmae:latest \
  /work/run.sh -d 1 /firmware/firmware.bin

# 4. Web has been simulated → Scan directly using nuclei / nikto / curl
```

UART automatically tries common baud rates:

```bash
for baud in 9600 19200 38400 57600 115200 460800 921600; do
    echo "--- $baud ---"
    timeout 3 sudo cat /dev/ttyUSB0 < <(stty -F /dev/ttyUSB0 $baud cs8 -cstopb -parenb)
done
```

U-Boot single-user bypass classic trick:

```text
# U-Boot stage key interrupt (usually by holding down the Space or Ctrl+C)
=> setenv bootargs "console=ttyS0,115200 root=/dev/mtdblock2 rootfstype=squashfs init=/bin/sh"
=> saveenv
=> boot
# Boot directly into sh after startup, no password required
```

## Suggestions for Improvement of This Package

- `reverse-engineering/platforms.md` already contains the firmware section, it is recommended to remove `references/iot-firmware-cheatsheet.md`
- Added `reverse-engineering/references/uart-debug.md` covering UART/JTAG/SWD basics
- bootstrap manifest added unblob / firmwalker

## Reusable patterns/script snippets

**IoT Security Testing 4 Stages**:

```text
Stage 1 — Software
· Manufacturer firmware download + binwalk/unblob extraction
· firmwalker run once
· grep default credentials / private keys / backdoor strings
· QEMU simulated boot running web vulnerability scanning

Stage 2 — Hardware
· Disassemble the device to find the UART/JTAG solder joint
· Multimeter identification GND/VCC/TX/RX
· USB-TTL wiring, confirm the level is 3.3V

Stage 3 — Debugging
· screen/minicom Monitoring
· Interrupt in U-Boot stage to enter interaction
· init=/bin/sh single-user password bypass

Stage 4 — Exploitation
· Get root → Check /etc/shadow offline crack
· Check the Web management interface CGI binaries → look for command injection / SSRF
· Check UPnP / mDNS / Bluetooth broadcast logic
```

**Default Credentials Quick Reference** (Common by Manufacturer):

```text
admin / admin
admin / password
root / root
root / 1234
support / support
ubnt / ubnt          # Ubiquiti
admin / 1234         # ZyXEL
```

## Evolution Actions
- [ ] Extract iot-firmware-cheatsheet.md
- [ ] Create uart-debug.md
- [ ] Add bootstrap-manifest to unblob / firmwalker

## Environmental Information
- Kali 2026.x (binwalk / unblob / squashfs-tools / firmwalker)
- USB-TTL Converter: CP2102 / FT232 (3.3V Level)
- Target: ARMv7 / MIPS routers (common in OpenWRT derived firmware)

## Desensitization Requirements
This entry is seed data, written based on publicly available IoT security testing methods, and does not involve any real manufacturers or models.