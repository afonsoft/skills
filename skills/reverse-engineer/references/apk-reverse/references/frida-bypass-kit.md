# Frida Bypass Kit — Universal security bypass framework for Android

> Source: [FridaBypassKit](https://github.com/okankurtuluss/FridaBypassKit) (2025)
> Applicable scenarios: APK dynamic analysis needs to bypass root detection, SSL pinning, simulator detection, and anti-debugging

## Overview

FridaBypassKit is a Frida script that integrates four major bypass capabilities. It does not need to be customized for a specific APP and can be used out of the box.

## Four major bypass capabilities

### 1. Root detection bypass

- Hook `File.exists()` hide su binary
- Intercept root check call for `Runtime.exec()`
- Hide root related packages (Magisk, SuperSU, etc.) from PackageManager
- Modify system properties to make the device appear to be unrooted

### 2. SSL Pinning Bypass

- Hook `TrustManagerImpl.verifyChain()`
- Hook `TrustManagerImpl.checkTrustedRecursive()`
- Bypass certificate chain verification
- Return an empty certificate chain to avoid verification
- Compatible with OkHttp, Retrofit and custom implementations

### 3. Emulator detection bypass

- Fake TelephonyManager return value
- Return fake phone number and carrier name
- Modify Build properties

### 4. Anti-debugging bypass

- Hook `Debug.isDebuggerConnected()`
- Prevent debugger detection
- Bypass anti-debugging checks

## How to use

```bash
# Prerequisites
pip install frida-tools
adb push frida-server /data/local/tmp/
adb shell chmod 755 /data/local/tmp/frida-server
adb shell su -c /data/local/tmp/frida-server &

# Inject Target APP
frida -U -f com.example.app -l FridaBypassKit.js
```

## Other recommended Frida bypass scripts

| Projects | Features | Links |
|------|------|------|
| httptoolkit/frida-interception-and-unpinning | MitM all HTTPS traffic directly | [GitHub](https://github.com/httptoolkit/frida-interception-and-unpinning) |
| 0xCD4/SSL-bypass | Generic non-custom SSL bypass | [GitHub](https://github.com/0xCD4/SSL-bypass) |
| incogbyte/ssl-bypass gist | Bypassing common SSL pinning methods | [Gist](https://gist.github.com/incogbyte/1e0e2f38b5602e72b1380f21ba04b15e) |
| Zero3141/Frida-OkHttp-Bypass | Specifically for OkHttp CertificatePinner | [GitHub](https://github.com/Zero3141/Frida-OkHttp-Bypass) |

## Integration with this package

In the `apk-reverse` workflow, use when the following situations are encountered:

1. APP detects root and refuses to run → enable Root Detection Bypass
2. The clear text of the HTTPS request cannot be seen when capturing packets → Enable SSL Pinning Bypass
3. The APP detects that the emulator refuses to run → enable Emulator Detection Bypass
4. APP crashes after attaching Frida → Enable Debug Detection Bypass

Recommended combination use: Run the complete FridaBypassKit first, and then make targeted adjustments.