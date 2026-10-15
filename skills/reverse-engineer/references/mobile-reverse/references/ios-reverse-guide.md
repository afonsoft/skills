# iOS reverse engineering project

## IPA acquisition and decryption

```bash
# Download from the App Store
ipatool search "Target App"
ipatool purchase -b com.target.app
ipatool download -b com.target.app -o app.ipa

# Extract Installed Apps from Device
# Jailbroken Devices
scp root@device:/private/var/containers/Bundle/Application/*/Target.app .

# Decryption (App Store binaries are in encrypted FAT format)
# frida-ios-dump (recommended)
python3 dump.py com.target.app -o decrypted.ipa

# Clutch
Clutch -i  # 列出已安装
Clutch -d 1  # 解密第 1 个

# dumpdecrypted
DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /path/to/App
```

## Mach-O Analysis

```bash
# Basic Information
otool -l TargetBinary | grep crypt    # 加密状态
otool -L TargetBinary                 # 动态库依赖
otool -hv TargetBinary                # 头部信息
jtool2 --pages TargetBinary           # 内存页信息

# Fat Binary Slimming
lipo -info TargetBinary
lipo TargetBinary -thin arm64 -output TargetBinary_arm64

# Symbol Analysis
nm -g TargetBinary                    # 导出符号
nm -a TargetBinary                    # 全部符号
swift-demangle <mangled_name>         # Swift 符号还原

# class-dump
class-dump -H TargetBinary -o headers/
# Export ObjC class and method declarations to the headers/ directory
```

## Objective-C runtime analysis

```text
Message passing mechanism:
objc_msgSend(id self, SEL op, ...) → dynamic method dispatch
  ↓
Find at runtime:
1. Class method list cache
2. Class method list
3. Level-by-level parent class search
4. +resolveInstanceMethod / +resolveClassMethod
5. forwardingTargetForSelector
6. methodSignatureForSelector + forwardInvocation
```

### Frida ObjC Hook

```javascript
// Hook instance method
var hook = ObjC.classes.ClassName["- instanceMethod:"];
Interceptor.attach(hook.implementation, {
    onEnter: function(args) {
        // args[0] = self, args[1] = selector, args[2+] = method args
        console.log("self: " + new ObjC.Object(args[0]));
        console.log("arg: " + args[2].toInt32());
    }
});

// Hook class methods
var hook = ObjC.classes.ClassName["+ classMethod:"];
Interceptor.attach(hook.implementation, { ... });

// Call ObjC method
var NSString = ObjC.classes.NSString;
var str = NSString.stringWithString_("test");
console.log(str.UTF8String());
```

## Swift Reverse

```text
Swift name mangling:
$s10ModuleName5ClassC6method3argSi_tF
│ │ │ │ │ │ │ └─ Parameter type
│ │ │ │ │ │ └───── Return type
│ │ │ │ │ └──────── Parameter name
│ │ │ │ └──────────────── Method name
│ │ │ └──────────────── Class name (length + name)
│ │ └────────────────────── Module name
│ └──────────────────────────────── Identifier
└─────────────────────────────────── Global logo

Tools: swift-demangle, Hopper (automatic restoration)
```

## Jailbreak detection bypass

```text
Detection method classification:

1. File system check:
   □ /Applications/Cydia.app
   □ /var/lib/apt/
   □ /bin/bash
   □ /usr/sbin/sshd
   → Hook NSFileManager.fileExistsAtPath:

2. Sandbox escape detection:
□ Whether fork() is successful (forbidden in sandbox)
□ system() call
→ Hook fork → return -1

3. Dyld injection detection:
□ _dyld_get_image_count > limit value
→ Limit the return value to a reasonable range

4. Scheme detection:
   □ cydia:// URL Scheme
   → Hook UIApplication.canOpenURL:

5. sysctl detection:
   □ CTL_KERN/KERN_PROC/KERN_PROC_PID → kinfo_proc
→ Hook sysctl → Clear p_flag P_TRACED bit
```

### Frida unified bypass script

```javascript
// File detection bypass
var NSFileManager = ObjC.classes.NSFileManager;
var defaultManager = NSFileManager.defaultManager();
Interceptor.attach(defaultManager["- fileExistsAtPath:"].implementation, {
    onLeave: function(retval) {
        var path = ObjC.Object(args[2]).toString();
        if (path.includes("Cydia") || path.includes("apt") || 
            path.includes("sshd") || path.includes("bash")) {
            retval.replace(0); // false
        }
    }
});

// fork bypass
Interceptor.replace(Module.findExportByName(null, "fork"), 
    new NativeCallback(function() { return -1; }, 'int', []));

// dyld bypass
var _dyld_get_image_count = Module.findExportByName(null, "_dyld_get_image_count");
Interceptor.attach(_dyld_get_image_count, {
    onLeave: function(retval) {
        if (retval.toInt32() > 200) retval.replace(200);
    }
});
```

## Critical protection bypass list

| Protection | iOS Bypass Methods |
|------|-------------|
| App Store Encryption | frida-ios-dump / Clutch |
| SSL Pinning | Objection `ios sslpinning disable` / SSL Kill Switch 2 |
| Jailbreak Detection | Objection `ios jailbreak disable` / Custom Frida Hook |
| Anti-Debugging (PT_DENY_ATTACH) | Frida post-startup injection / debugserver |
| Integrity Check | Hook MAC Check/Code Signature Verification |
| Back-injection | Modify Mach-O to remove __RESTRICT section |
| Swift obfuscation | swift-demangle + LLM assisted semantic recovery |
| Screenshot Protection | Hook UIScreen.mainScreen.snapshotViewAfterScreenUpdates |

Source: OWASP MSTG, frida-ios-dump, The iPhone Wiki
