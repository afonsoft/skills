# [SEED] APK Frida Bypass OkHttp SSL Pinning

## Scene classification
APK reverse engineering/mobile security testing

## Goal Overview
For an Android application using OkHttp + custom CertificatePinner, Frida is used to dynamically bypass certificate verification so that Burp can obtain plaintext traffic.

## Complete execution link

1. Install Frida + frida-server, start the target App, and confirm the process name
```bash
adb shell "ps -A | grep com.target.app"
frida-ps -U | grep target
```
2. Use Burp to capture the packet and try to get a certificate error, indicating that Pinning is enabled.
3. Use jadx to open APK and decompile → search for `CertificatePinner` or `checkServerTrusted`
4. Confirm whether OkHttp comes with `CertificatePinner` or customized `X509TrustManager`
5. Write Frida script hook key checkpoints
6. Start Frida injection: `frida -U -f com.target.app -l bypass.js --no-pause`
7. Capture the packet again → Burp can see plain text HTTPS

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Frida startup error `unable to connect to remote frida-server` | The server is not started or the port is occupied | `adb forward tcp:27042 tcp:27042` + Start the server | 10min |
| Hook does not take effect | App starts too fast, Frida is injected late | Use `-f` parameter spawn mode, cooperate with `--no-pause` | 15min |
| Some requests still have SSL errors after Hook | The application uses both OkHttp and native HttpsURLConnection | Add hooks `X509TrustManager.checkServerTrusted` and `HostnameVerifier.verify` | 20min |
| Anti-detection: App detects Frida and exits | App self-check frida-server port / `/data/local/tmp/re.frida.server` | Use frida-gadget instead (inject .so into APK) or magisk + zygisk-frida | 30min+ |
| The class name cannot be found after ProGuard obfuscation | The class name becomes `a.b.c` short name | Use `Find Usages` in jadx to check who instantiated OkHttpClient.Builder | 25min |

## Toolchain discovery

- **objection** Built-in `android sslpinning disable` can handle 80% of scenes with one command, no need to write Frida script yourself
- **frida-multiple-unpinning** (GitHub: WithSecureLabs) covers OkHttp 3/4, Retrofit, HttpsURLConnection, Conscrypt, Cordova, universal script
- **MEDUSA** framework comes with various Android bypass modules, which is faster to use than bare Frida

## Key code/command

Minimal usable OkHttp Pin bypass script:

```javascript
Java.perform(function () {
// 1. OkHttp 3/4 built-in CertificatePinner
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function (host, peers) {
            console.log('[+] OkHttp CertificatePinner.check bypassed: ' + host);
            return;
        };
    } catch (e) {}

// 2. Custom X509TrustManager.checkServerTrusted
    try {
        var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl.verifyChain.implementation = function (untrusted, holdHost, host, clientAuth, ocspData, tlsSctData) {
            console.log('[+] TrustManagerImpl.verifyChain bypassed: ' + host);
            return untrusted;
        };
    } catch (e) {}

// 3. HostnameVerifier passes all
    var HostnameVerifier = Java.use('javax.net.ssl.HostnameVerifier');
// Complete using objection's built-in template...
});
```

One-click command (recommended):

```bash
objection --gadget com.target.app explore -s "android sslpinning disable"
```

## Suggestions for improving this package

- `apk-reverse/references/` should have a dedicated `ssl-pinning-bypass.md`, and merge the four mainstream scenarios of OkHttp 3/4, Conscrypt, custom TrustManager, and Flutter (boringssl) into a quick check
- Add `objection` to bootstrap manifest (pip package)

## Reusable patterns/script snippets

**Universal Bypass Process**:

```text
1. Capture the packet → see what type of error it is (CertPin/Hostname/TrustManager)
2. jadx search key class (CertificatePinner/X509TrustManager/HostnameVerifier)
3. Prioritize objections with one click → If it doesn’t work anymore, frida-multiple-unpinning → If it doesn’t work anymore, handwrite
4. If there is anti-Frida detection → cut frida-gadget or zygisk
5. Flutter application is processed separately (hook ssl_verify_peer_cert of libflutter.so)
```

## Evolution action
- [x] routing matrix overwritten (apk-reverse + Frida)
- [x] frida status in tool-index checked
- [ ] It is recommended to add ssl-pinning-bypass.md quick check

## Environment information
- Kali / Windows + adb + frida-tools 16.x
- Target Android: 8-14 (TrustManagerImpl paths are different in different versions)
- Injection method: USB debugging + frida-server / or zygisk-frida hidden

## Desensitization requirements
This article is seed data, written based on public technical models, and does not involve real goals. The package name `com.target.app` is a placeholder.