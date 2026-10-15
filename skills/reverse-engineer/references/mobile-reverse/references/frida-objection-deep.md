# Frida + Objection in-depth usage

## Frida Core API

### Java Runtime (Android)

```javascript
Java.perform(function() {
// Get class instance
    var String = Java.use("java.lang.String");

// Hook static method
    var System = Java.use("java.lang.System");
    System.getProperty.overload('java.lang.String').implementation = function(key) {
        console.log("System.getProperty: " + key);
        return this.getProperty(key);
    };

// Hook constructor
    var File = Java.use("java.io.File");
    File.$init.overload('java.lang.String').implementation = function(path) {
        console.log("File opened: " + path);
        return this.$init(path);
    };

// Enumerate loaded classes
    Java.enumerateLoadedClasses({
        onMatch: function(className) { console.log(className); },
        onComplete: function() {}
    });

// Modify return value
    var RootDetector = Java.use("com.app.security.RootDetector");
    RootDetector.isDeviceRooted.implementation = function() {
        return false;
    };
});
```

### Native layer (Android + iOS)

```javascript
// Hook export function
Interceptor.attach(Module.findExportByName(null, "open"), {
    onEnter: function(args) {
        this.path = Memory.readUtf8String(args[0]);
    },
    onLeave: function(retval) {
        console.log("open(" + this.path + ") = " + retval);
    }
});

// Hook any address (via offset)
var base = Module.findBaseAddress("libnative.so");
var target = base.add(0x12345);
Interceptor.attach(target, {
    onEnter: function(args) {
        console.log("Function called from: " + Thread.backtrace(this.context, Backtracer.ACCURATE)
            .map(DebugSymbol.fromAddress).join('\n'));
    }
});

// Modify return value
Interceptor.attach(Module.findExportByName(null, "strcmp"), {
    onLeave: function(retval) {
        if (retval.toInt32() === 0) return; // strings equal, skip
        // Force match
        retval.replace(0);
    }
});
```

### ObjC Runtime (iOS)

```javascript
// Hook ObjC method
var hook = ObjC.classes.ViewController["- viewDidLoad"];
Interceptor.attach(hook.implementation, {
    onEnter: function(args) {
        console.log("viewDidLoad called");
    }
});

// Enumerate all classes
ObjC.enumerateLoadedClasses({
    onMatch: function(className) { console.log(className); },
    onComplete: function() {}
});

// Call ObjC method
var NSString = ObjC.classes.NSString;
var str = NSString.stringWithString_("Hello from Frida");
```

## Objection command quick review

### General

```bash
objection -g "com.app" explore           # 启动
objection -g "com.app" explore -q        # 静默启动（只注入不等待）
objection patchapk --source app.apk      # 自动注入 Frida Gadget
objection signapk --source app.apk       # 仅签名

# File System
env              # 应用数据目录
ls               # 列出文件
file download /path/to/file  # 下载文件
file upload local.txt /remote/path  # 上传文件

# SQLite
sqlite connect /path/to/db.sqlite
.tables          # 列出表
select * from users;  # 查询
```

### Android only

```bash
android root disable              # 绕过 Root 检测
android sslpinning disable        # 绕过 SSL Pinning
android hooking list classes      # 枚举类
android hooking list class_methods com.app.Main  # 枚举方法
android hooking watch class com.app.Main  # Hook 所有方法
android intent launch_activity com.app.MainActivity  # 启动 Activity
android heap search instances com.app.User  # 堆搜索
android keystore list             # Keystore 条目
```

### iOS only

```bash
ios jailbreak disable             # 绕过越狱检测
ios sslpinning disable            # 绕过 SSL Pinning
ios keychain dump                 # 导出 Keychain
ios nsuserdefaults get            # NSUserDefaults
ios nsurlcache dump               # HTTP 缓存
ios cookies get                   # 读取 Cookies
ios pasteboard monitor            # 监听剪贴板
ios ui dump                       # UI 层次结构
ios plist cat Info.plist          # 读取 plist
```

## Root/jailbreak-free deployment

### Android — Frida Gadget injection

```bash
# 1. Unpack APK
apktool d app.apk -o app_unpacked

# 2. Download frida-gadget and put it into the lib directory
cp frida-gadget-17.x.x-android-arm64.so \
   app_unpacked/lib/arm64-v8a/libfrida-gadget.so

# 3. Inject System.loadLibrary("frida-gadget") in smali
# Modify the onCreate or attachBaseContext of the main Activity

# 4. Rebuild and Sign
apktool b app_unpacked -o app_patched.apk
uber-apk-signer -a app_patched.apk

# 5. Objection Automation
objection patchapk --source app.apk --skip-resources
```

### iOS — Frida Gadget injection

```bash
# 1. Decrypt App Store IPA
python3 frida-ios-dump.py -u -p com.app.target

# 2. Inject FridaGadget.dylib
# Modify Mach-O Load Commands, add @executable_path/FridaGadget.dylib

# 3. Re-signature
codesign -f -s "Apple Development" Payload/App.app

# 4. Install via Xcode sideload or AltStore
```

## SSL Pinning bypass advanced

### Multi-layer bypass (Android)

```javascript
// 1. OkHttp CertificatePinner
var CertificatePinner = Java.use("okhttp3.CertificatePinner");
CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function() {};

// 2. Custom TrustManager
var TrustManagerImpl = Java.use("com.android.org.conscrypt.TrustManagerImpl");
TrustManagerImpl.verifyChain.implementation = function() { return []; };

// 3. WebView SSL Error
var SslErrorHandler = Java.use("android.webkit.SslErrorHandler");
SslErrorHandler.proceed.implementation = function() { return this.proceed(); };

// 4. Network Security Config
// Need to modify AndroidManifest.xml → android:networkSecurityConfig="@xml/network_security_config"
// Add trusted user certificate in XML
```

### Multi-layer bypass (iOS)

```javascript
// 1. NSURLSession
var SecTrustEvaluate = Module.findExportByName("Security", "SecTrustEvaluate");
Interceptor.replace(SecTrustEvaluate, new NativeCallback(function(trust, result) {
    Memory.writeU32(result, 1); // kSecTrustResultProceed = 1
    return 0; // errSecSuccess
}, 'int', ['pointer', 'pointer']));

// 2. Alamofire
// Hook ServerTrustManager.evaluate → Always returns success
```

Source: Frida docs, Objection wiki, OWASP MSTG
