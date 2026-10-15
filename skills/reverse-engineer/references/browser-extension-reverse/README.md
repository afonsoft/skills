---
name: browser-extension-reverse
description: Use for authorized reverse engineering of browser extensions (Chrome/Firefox) including manifest analysis, background workers, and extension-based credential or traffic logic recovery.
---

# Browser Extension Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that the target is a **browser extension** (crx/xpi/ decompression directory), not an ordinary web page JS (ordinary → `js-reverse/`)
3. `NEXT`: Decompress extension; read manifest
4. `ACT`: Permissions → Background script → Network/storage hook

## Applicable scenarios

- Chrome/Edge MV2/MV3 Extended analysis
- Firefox extension
- Malicious extension IOC, supply chain extension poisoning investigation
- Extended implementation of signature/encryption/proxy logical restoration

## Workflow

### 1. Package body

```text
□ crx decompress / get extension directory from profile
□ manifest.json：permissions、host_permissions、background、content_scripts
□ Evaluate excessive permissions (<all_urls>, webRequest, debugger)
```

### 2. Logic

```text
□ service_worker / background entrance
□ content_script injection point and world (isolated)
□ chrome.storage/IndexedDB key
□ Same as `js-reverse`: Observe Networking and Messaging (runtime.sendMessage)
```

### 3. Dynamic

```text
□ Developer mode loads and decompresses the directory
□ chrome://extensions check for errors
□ DevTools additional service worker
□ Frida/browser CDP (jshookmcp) if necessary
```

## Toolchain

| Tools | Purpose |
|------|------|
| Unzip/jq | manifest |
| Chrome DevTools | worker debugging |
| js-reverse tool chain | Deep JS |
| YARA | Malicious Extension Rules |

## Reference

- `references/extension-analysis.md`
- field-journal extension restores related entries
- `../js-reverse/` `../malware-analysis/`

## Routing context

**Upstream**: MASTER R30
**Downstream**: Complex obfuscated JS → `js-reverse`; poisoning investigation → supply-chain / malware

## Task completion self-check

- [ ] Are permission planes and entry scripts listed?
- [ ] Restore critical data flows?
- [ ] Checklist？