# Android advanced reverse reference

> Covers Native SO analysis, Frida advanced usage, SSL Pinning bypass, Root detection and countermeasures, hardened unpacking, Flutter/React Native reverse engineering.

---

## Native SO Reverse

### Analysis process

```text
1. Extract the .so file from the APK
   unzip app.apk lib/arm64-v8a/*.so -d extracted/

2. Confirm the architecture and basic information
   file libxxx.so
   rabin2 -I libxxx.so

3. Find the JNI entry
- Search for JNI_OnLoad (dynamic registration)
- Search Java_com_xxx_yyy (static registration)
   - nm -D libxxx.so | grep -i java

4. IDA/Ghidra loading analysis
- Import JNI header file (jni.h type)
- Annotate JNIEnv* parameters
- Find the RegisterNatives call (dynamically registered function table)

5. Position key logic
- Tracing from Java layer native method name
- Cross-referencing from strings (keys, URLs, error messages)
- Call trace from crypto library function (AES/MD5/SHA)
```

### JNI function registration

```c
// Static registration: function name = Java_packageName_className_methodName
JNIEXPORT jstring JNICALL Java_com_example_app_Security_getSign(
    JNIEnv *env, jobject thiz, jstring input) { ... }

// Dynamic registration: Call RegisterNatives in JNI_OnLoad
static JNINativeMethod methods[] = {
    {"getSign", "(Ljava/lang/String;)Ljava/lang/String;", (void*)native_getSign},
};

JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    vm->GetEnv((void**)&env, JNI_VERSION_1_6);
    jclass clazz = env->FindClass("com/example/app/Security");
    env->RegisterNatives(clazz, methods, sizeof(methods)/sizeof(methods[0]));
    return JNI_VERSION_1_6;
}
```

### Tips for analyzing JNI in IDA

```text
1. Import the JNI type library
   File → Load File → Parse C Header → jni.h

2. Mark the first parameter as JNIEnv*
Right-click parameters → Set type → JNIEnv*
In this way, calls such as env->FindClass / env->GetMethodID will automatically recognize

3. Find RegisterNatives
Search for calls to JNIEnv vtable offset 0x35C (ARM64)
→ The third parameter is the JNINativeMethod array
→ Extract all native function addresses from the array
```

---

## Frida advanced usage

### Hook Native function

```javascript
// Hook libc function
Interceptor.attach(Module.findExportByName("libc.so", "open"), {
    onEnter: function(args) {
        this.path = args[0].readUtf8String();
        console.log("[open] " + this.path);
    },
    onLeave: function(retval) {
        if (this.path.includes("su") || this.path.includes("magisk")) {
            console.log("[open] Blocked root check: " + this.path);
            retval.replace(-1);  // 返回失败
        }
    }
});

// Hook functions in custom SO
var base = Module.findBaseAddress("libsecurity.so");
var targetFunc = base.add(0x1234);  // 偏移地址
Interceptor.attach(targetFunc, {
    onEnter: function(args) {
        console.log("arg0: " + args[0].readUtf8String());
    },
    onLeave: function(retval) {
        console.log("return: " + retval.readUtf8String());
    }
});
```

### Hook Java method

```javascript
Java.perform(function() {
// Hook instance method
    var Security = Java.use("com.example.app.Security");
    Security.getSign.implementation = function(input) {
        console.log("[getSign] input: " + input);
        var result = this.getSign(input);  // 调用原方法
        console.log("[getSign] output: " + result);
        return result;
    };

// Hook constructor
    Security.$init.overload('java.lang.String').implementation = function(key) {
        console.log("[Security.<init>] key: " + key);
        this.$init(key);
    };

// Hook override method
    Security.encrypt.overload('java.lang.String', 'int').implementation = function(data, mode) {
        console.log("[encrypt] data=" + data + " mode=" + mode);
        return this.encrypt(data, mode);
    };
});
```

### Memory search and modification

```javascript
// Search for a string in memory
Process.enumerateModules().forEach(function(module) {
    if (module.name === "libtarget.so") {
        Memory.scan(module.base, module.size, "48 65 6C 6C 6F", {  // "Hello"
            onMatch: function(address, size) {
                console.log("Found at: " + address);
            }
        });
    }
});

// Modify memory (patch instruction)
var addr = Module.findBaseAddress("libsecurity.so").add(0x5678);
Memory.patchCode(addr, 4, function(code) {
    var writer = new Arm64Writer(code, {pc: addr});
    writer.putNop();  // 替换为 NOP
    writer.flush();
});
```

---

## SSL Pinning Bypass

### General solution (recommended)

```javascript
// Frida general SSL Pinning bypass
// Source: https://github.com/0xCD4/SSL-bypass
Java.perform(function() {
// 1. TrustManager bypass
    var TrustManager = Java.registerClass({
        name: 'com.custom.TrustManager',
        implements: [Java.use('javax.net.ssl.X509TrustManager')],
        methods: {
            checkClientTrusted: function(chain, authType) {},
            checkServerTrusted: function(chain, authType) {},
            getAcceptedIssuers: function() { return []; }
        }
    });

// 2. Replace SSLContext
    var SSLContext = Java.use('javax.net.ssl.SSLContext');
    var sslContext = SSLContext.getInstance("TLS");
    sslContext.init(null, [TrustManager.$new()], null);

// 3. OkHttp CertificatePinner bypass
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function() {};
    } catch(e) {}
});
```

### Each framework bypasses

| Framework | Bypass method |
|------|---------|
| OkHttp3 | Hook `CertificatePinner.check` returns empty |
| Retrofit | Same as OkHttp (the bottom layer uses OkHttp) |
| Volley | SSL Factory for Hook `HurlStack` |
| Flutter | Hook `SecurityContext` for `dart:io` (requires special script) |
| React Native | Hook `OkHttpClientProvider` |
| WebView | Hook `WebViewClient.onReceivedSslError` |

### Flutter special project

```javascript
// Flutter SSL Pinning Bypass (need to find the ssl_verify_peer_cert function)
var flutter_lib = Module.findBaseAddress("libflutter.so");
// Search for the signature code of ssl_verify_peer_cert
var pattern = "FF 03 05 D1 FD 7B 0F A9";  // ARM64 特征
Memory.scan(flutter_lib, Module.findModuleByName("libflutter.so").size, pattern, {
    onMatch: function(address) {
        Interceptor.replace(address, new NativeCallback(function() {
            return 0;  // 返回成功
        }, 'int', []));
    }
});
```

---

## Root detection bypass

### Common detection methods

| Detection methods | Bypass methods |
|---------|---------|
| Check `/system/app/Superuser.apk` | Hook `File.exists()` return false |
| Check `su` command | Hook `Runtime.exec()` intercept su call |
| Check `/proc/self/mounts` | Hook file reading, filter magisk related |
| SafetyNet/Play Integrity | Magical Hide / Zygisk + Shamiko |
| Check Magisk package names | Randomize Magisk package names |
| Check `/data/adb/` | Hook `opendir`/`access` |

### Frida Universal Root Bypass

```javascript
Java.perform(function() {
    // Hook File.exists
    var File = Java.use("java.io.File");
    File.exists.implementation = function() {
        var path = this.getAbsolutePath();
        var blacklist = ["su", "Superuser", "magisk", "busybox", "xposed"];
        for (var i = 0; i < blacklist.length; i++) {
            if (path.toLowerCase().includes(blacklist[i])) {
                return false;
            }
        }
        return this.exists();
    };

    // Hook System.getProperty
    var System = Java.use("java.lang.System");
    System.getProperty.overload('java.lang.String').implementation = function(key) {
        if (key === "ro.debuggable" || key === "ro.secure") {
            return "1";
        }
        return this.getProperty(key);
    };
});
```

---

## Reinforcement/shell identification and shelling

### Common reinforcement manufacturers

| Reinforcement | Identification features | Shelling method |
|------|---------|---------|
| 360 Reinforcement | `libjiagu.so`, `com.stub.StubApp` | FART / Frida dump dex |
| Tencent Legu | `libshell*.so`, `com.tencent.StubShell` | FART / BlackDex |
| Bangbang reinforcement | `libDexHelper.so`, `com.secneo.apkwrapper` | FART |
| Love Encryption | `libexec.so`, `s.h.e.l.l` | Frida dump |
| NetEase Yidun | `libnesec.so` | Frida dump |
| Naga | `libnaga.so` | Frida dump |

### General shelling method

```text
Method 1: FART (ART environment unpacking)
- Flash FART ROM or use Frida version of FART
- Automatically dump all dex loaded by ClassLoader

Method 2: Frida DEX Dump
- frida -U -f com.target.app -l dex_dump.js
- Hook at DexFile::OpenMemory and dump dex in memory

Method 3: BlackDex
- Root-free unpacking tool
- Install BlackDex APK directly and select the target application to unpack

Method 4: Manual dump
- Use Frida to enumerate all ClassLoaders
- Find the application's ClassLoader → Get the DexFile object
- Read the dex memory area and save it
```

### Frida DEX Dump Script

```javascript
Java.perform(function() {
    Java.enumerateClassLoaders({
        onMatch: function(loader) {
            try {
                var dexFiles = loader.getDexFileList();
                console.log("ClassLoader: " + loader);
                console.log("  DEX files: " + dexFiles);
            } catch(e) {}
        },
        onComplete: function() {}
    });
});
```

---

## React Native / Flutter reverse engineering

### React Native

```text
1. Unzip APK → assets/index.android.bundle (JS code)
2. Format JS → Search API address, key, signature logic
3. If there is Hermes bytecode (.hbc file) → decompile with hermes-dec
4. Hook: ReactBridge using Frida hook Java layer
```

### Flutter

```text
1. Flutter code is compiled into libapp.so (Dart AOT)
2. Cannot be directly decompiled into Dart source code
3. Analysis method:
- reFlutter tool: patch libflutter.so to get snapshot
- Doldrums: parse Dart snapshot recovery class/function information
- Frida hook key functions in libflutter.so
4. Network analysis: Flutter does not use system proxy and requires special processing of SSL
```

---

## Tool Quick Check

| Tools | Purpose | Installation |
|------|------|------|
| jadx | Java decompilation | Already in bootstrap |
| apktool | unpack/repack | Already in bootstrap |
| Frida | Dynamic Hook | `pip install frida-tools` |
| Objection | Frida package (easier to use) | `pip install objection` |
| MobSF | Automated mobile security analysis | Docker deployment |
| BlackDex | Root-free unpacking | APK installation |
| FART | ART unpacking | Flash ROM or Frida version |
| hermes-dec | Hermes bytecode decompilation | npm installation |
| reFlutter | Flutter reverse assistance | pip installation |
| Magisk + Shamiko | Root Hide | Flash In |

---

## Reference resources

| Resources | Description | Links |
|------|------|------|
| OWASP MASTG | Mobile Security Testing Guide | https://mas.owasp.org/ |
| FridaBypassKit | Universal bypass framework | https://github.com/okankurtuluss/FridaBypassKit |
| SSL-bypass | Universal SSL Pinning bypass | https://github.com/0xCD4/SSL-bypass |
| awesome-frida | Frida resource collection | https://github.com/dweinstein/awesome-frida |
| Android Security Awesome | Android Security Resources | https://github.com/ashishb/android-security-awesome |