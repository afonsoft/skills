# Quick Reference for APK Security Testing

> Compiled based on OWASP MASTG (Mobile Application Security Testing Guide).
> Covers six major dimensions: static analysis, dynamic analysis, network communication, data storage, authentication and authorization, and code protection.

---

## Static Analysis Checklist

### Manifest Audit

```text
□ android:debuggable="true" → Debuggable (should not appear in production environment)
□ android:allowBackup="true" → Data can be backed up and extracted
□ Components with android:exported="true" → exposed Activity/Service/Receiver/Provider
□ Custom permission protectionLevel → whether it is normal (should be signature)
□ scheme in intent-filter → whether custom deeplinks can be hijacked
□ android:usesCleartextTraffic="true" → Allows cleartext HTTP
□ minSdkVersion is too low → may lack security features
```

### Key Points of Code Audit

```text
□ Hardcoded keys/Token (search for "key", "secret", "password", "api_key")
□ Insecure random numbers (java.util.Random instead of SecureRandom)
□ Unsafe encryption (ECB mode, DES, MD5 used for passwords)
□ WebView Configuration (setJavaScriptEnabled + addJavascriptInterface = RCE Risk)
□ SQL Injection (rawQuery concatenating user input)
□ Path traversal (ContentProvider's openFile does not validate the path)
□ Log leakage (Log.d/Log.i outputs sensitive information)
□ Clipboard leakage (ClipboardManager stores sensitive data)
□ Implicit Intent leak (sendBroadcast without specifying package name)
```

### Third-Party Library Audit

```text
□ Outdated OkHttp/Retrofit version (known vulnerabilities)
□ Outdated WebView kernel
□ SDKs with known vulnerabilities (check CVE)
□ Scope of Advertising SDK Data Collection
□ Push SDK Configuration (Whether the token is leaked)
```

---

## Dynamic Analysis Checklist

### Frida Hook Priority Target

| Goal | Hook Point | Purpose |
|------|---------|------|
| Login Authentication | `LoginActivity.login()` | Observe Credential Processing |
| Signature Generation | `*Sign*`, `*sign*`, `*encrypt*` | Restore Signature Algorithm |
| SSL Pinning | `CertificatePinner.check` | Bypass Packet Capture |
| Root Detection | `*root*`, `*su*`, `*magisk*` | Bypass Detection |
| Encryption Operation | `javax.crypto.Cipher` | Extract Key/IV |
| Token Storage | `SharedPreferences.getString` | Monitor token read/write |
| Network Request | `OkHttpClient.newCall` | Observe Request Construction |

### Common One-Line Frida Commands

```bash
# Track all encryption operations
frida-trace -U -f com.target.app -j '*Cipher*!*'

# Track all HTTP requests
frida-trace -U -f com.target.app -j '*OkHttp*!*'

# Tracking SharedPreferences Read and Write
frida-trace -U -f com.target.app -j '*SharedPreferences*!*'

# Track all native function calls
frida-trace -U -f com.target.app -i 'Java_*'
```

### Objection Quick Command

```bash
# Connection
objection -g com.target.app explore

# Common Commands
android hooking list activities
android hooking list services
android sslpinning disable
android root disable
android clipboard monitor
env                              # 查看应用目录
sqlite connect <db_path>         # 连接数据库
```

---

## Network Communication Security

### Packet Capture Configuration

```text
Method 1: System Proxy + Burp/mitmproxy
- Set WiFi proxy → Burp listening address
- Install CA certificate to the device
- Android 7+ requires network_security_config or Frida bypass

Method 2: VPN Mode (Recommended)
- Use HttpCanary / Packet Capture
- No root required, no proxy configuration needed
- But unable to decrypt SSL Pinning traffic

Method 3: Frida + r2frida
- Intercept network calls directly within the process
- Not restricted by proxy/VPN
```

### Checklist

```text
□ Whether to use HTTPS (all API calls)
□ Is there SSL Pinning (certificate binding)?
□ Verify whether the certificate is correct (self-signed certificates are not accepted)
□ Is there a Certificate Transparency (CT) check
□ Whether the API key is transmitted in plaintext in the request
□ Does the token have an expiration mechanism?
□ Is there a request for signature tamper-proofing?
□ Is there protection against replay attacks (nonce/timestamp)
□ Is WebSocket encrypted
□ Is there sensitive data in the URL parameters (which will be recorded in logs)
```

---

## Data Storage Security

### Check Location

| Location | Risk | Check Command |
|------|------|---------|
| SharedPreferences | Stores token/password in plain text | `adb shell cat /data/data/pkg/shared_prefs/*.xml` |
| SQLite Database | Unencrypted Sensitive Data | `adb pull /data/data/pkg/databases/` |
| External storage | Readable by any app | `adb shell ls /sdcard/Android/data/pkg/` |
| Application Log | Leaking Debug Information | `adb logcat \| grep pkg` |
| Backup file | allowBackup=true | `adb backup -f backup.ab pkg` |
| Keyboard Cache | Input History | Check if `inputType` is `textPassword` |
| Screenshot Protection | Sensitive pages can be screenshotted | Check `FLAG_SECURE` |

### Comparison of Encrypted Storage Solutions

| Plan | Safety | Description |
|------|--------|------|
| SharedPreferences in plain text | ❌ | Read directly after rooting |
| EncryptedSharedPreferences | ✓ | AndroidX Security library |
| SQLCipher | ✓ | Encrypted SQLite |
| Android Keystore | ✓✓ | Hardware-level key protection |
| Custom AES Encryption | ⚠️ | Depends on Key Management |

---

## Authentication and Authorization

### Common Vulnerabilities

| Vulnerability | Testing Method |
|------|---------|
| Weak password policy | Attempts like 123456, password, etc. |
| No locking mechanism | Brute force login interface |
| Token does not expire | Replay old token after logout |
| Unauthorized access | Modify the user_id in the request |
| SMS verification code can be brute-forced | 4/6 digits with no frequency limit |
| OAuth configuration error | redirect_uri can be tampered with |
| Biometric Authentication Bypass | Hook BiometricPrompt |
| Device Binding Bypass | Modify device_id |

### Test Payload

```bash
# Unauthorized Test
curl -H "Authorization: Bearer USER_A_TOKEN" \
     "https://api.target.com/users/USER_B_ID/profile"

# Token Replay
# 1. Normal login to obtain token
# 2. Log Out
# 3. Request with an old token → should return 401

# SMS Verification Code Brute Force
for code in $(seq 0000 9999); do
    curl -X POST "https://api.target.com/verify" \
         -d "phone=13800138000&code=$code"
done
```

---

## Code Protection Assessment

| Protective Measures | Detection Methods | Bypass Difficulty |
|---------|---------|---------|
| ProGuard Obfuscation | Use jadx to check if the class name is a/b/c | Low (just renaming) |
| String Encryption | Search for Decryption Functions, Hook to Obtain Plaintext | Medium |
| Anti-Debugging | Attempt to attach debugger | Medium (Can be bypassed with Frida) |
| Root Check | Run on root device | Medium (Generic Script Bypass) |
| Emulator Detection | Running on Emulator | Low-Medium |
| Integrity Check | Install After Modifying APK | Medium (patch check function) |
| Protection/Shell | Examine entry classes and .so files | Medium-High (requires unpacking) |
| Native Protection | Core logic in .so | High (requires IDA analysis) |
| VMP Virtualization | Code is executed in a virtualized manner | Extremely high |

---

## Quick Test Procedure (30 Minutes)

```text
1. [5min] Unpacking + Manifest Audit
   apktool d app.apk
Check debuggable/allowBackup/exported/cleartext

2. [10min] Quick Code Audit
   jadx -d out app.apk
Search: password, key, secret, token, http://

3. [5min] Network Test
Configure proxy → Operate APP → Check for plaintext/weak encryption

4. [5min] Storage Check
adb shell → Check shared_prefs and databases

5. [5min] Dynamic Verification
Frida hook key function → Confirm discovery
```
