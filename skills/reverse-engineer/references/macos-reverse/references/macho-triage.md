#Mach-O Triage

```bash
file ./app
otool -hv ./app
otool -l ./app | head
codesign -d --entitlements :- ./app
```

Pay attention to: `com.apple.security.*` entitlements, Library Validation, disable library injection related flags.