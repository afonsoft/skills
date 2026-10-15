# Detailed Explanation of .NET Obfuscator Deobfuscation

Recognition, unpacking, and anti-tamper bypass of mainstream .NET obfuscators. Core tools: **de4dot** (automatically recognizes most packs) + **dnSpyEx** (manual patching) + **dnlib** (scripting).

## Master Decision Table

| Obfuscator | de4dot type | Typical Features | Automatic Unpacking | Manual Key Points |
|--------|-------------|---------|---------|---------|
| ConfuserEx 1.x/2.x | `cfze` | anti-tamper, control flow obfuscation, string encryption, anti-debugging | ✅ Mostly automatic | New version requires patching anti-tamper first |
| ConfuserEx 3.x / privately modified | `cfze` | same as above + custom protector | ⚠️ partially | dump at runtime / dnlib |
| SmartAssembly | `sa` | String encoding, resource compression, method call hiding | ✅ Automatic | Resource decompression |
| Babel.NET | `babel` | Method body encryption, control flow, strings | ✅ Automatic | — |
| Eazfuscator.NET | `eaz` | String/Resource Encryption, Expression Obfuscation | ⚠️ Partial | String Decrypter |
| .NET Reactor | `reactor` | necrobit (code segment encryption) + anti-tamper | ⚠️ New version is difficult | dump + rebuild metadata |
| Themida .NET | — | Shell + Virtualization | ❌ de4dot doesn't work | Dump memory, follow native approach |
| Agile.NET / CliSecure | `agile` | Method Body Encryption | ✅ Automatic | — |

## Standard Usage of de4dot

```powershell
# Automatic recognition (sufficient in most cases)
de4dot target.exe -o target-clean.exe

# Explicitly specify type (automatic recognition failed)
de4dot --type cfze target.exe -o target-clean.exe

# First, detect the shell type
de4dot --detect target.exe

# Batch
de4dot *.exe

# Only decode strings, do not touch control flow (minimal intervention)
de4dot --strtyp delegate --strtok METHOD_TOKEN target.exe
```

de4dot's `--strtyp` / `strtok` modes: only decrypt string decryptors (specify the decryption method token), while keeping the original control flow. Suitable for scenarios where you 'only want to see the plaintext strings but don't want to touch anti-tamper'.

---

## ConfuserEx (most common)

### Feature Recognition

- Entry module `<module>` class with `[MethodImpl(NoInlining)]` anti-tamper check
- A large number of `Dictionary<string, T>` string decoder calls
- Control flow flattening (switch dispatch + state variable)
- `.cmp` embedded in the resources, compressed resources
- dnSpyEx C# view: class names/method names are garbled (`\uXXXX` or meaningless characters), the method body is full of `int num = ...; switch(num)`

### Shelling Process

```powershell
# 1. Standard Shell Removal
de4dot target.exe -o target-clean.exe

# 2. If de4dot reports "unknown" or cannot open after unpacking → New version / privately modified ConfuserEx
#    First confirm anti-tamper:
dnSpyEx 打开 → 找 Module .cctor 或 Main 里的完整性校验
```

### Anti-tamper Bypass (Common in the New Version of ConfuserEx)

ConfuserEx's `anti tamper` will check the method body hash at runtime and crash if modified. de4dot can usually handle older versions, but newer versions require manual handling:

```text
Method A — Directly patch the verification function with dnSpyEx:
1. Find the anti-tamper verification method (usually called in the static constructor of <module>)
2. IL Edit: Change the body of the verification method to ret (direct return)
3. Save → Feed to de4dot again

Method B — Runtime dump:
1. Use MegaDumper / ExtremeDumper to run and dump the assembly in memory
2. The dumped output has already been decrypted, then use de4dot to clean up the residues
```

### After Control Flow Restoration

de4dot will restore the flattened switch dispatch back to a normal if/while. If it is not completely restored (seeing a leftover state machine), you can run de4dot again or manually follow the IL.

---

## SmartAssembly

```powershell
de4dot --type sa target.exe -o target-clean.exe
```

Features:
- Strings are encoded using the `SmartAssembly.Runtime.Strong` series
- Resource compression (`{assembly}.Resources`)
- Method call hiding (`ProcessCaller` / indirect call)

de4dot has the best compatibility with SmartAssembly, basically one-click to get it done.

---

## .NET Reactor（necrobit）

`.NET Reactor`'s **necrobit** encrypts the real method body and stores it in resources, decrypting and injecting it at runtime. The original method body is a shell. de4dot works for older versions, but often fails on newer versions (4.x+).

```text
When de4dot fails:
1. Run the program (dotnet target.exe or just double-click)
2. MegaDumper / ExtremeDumper dump process memory → export decrypted assembly
3. Use de4dot to clean up the residual obfuscation from dump products
4. If the metadata is damaged, rebuild it with dnlib (see common-workflow.md)
```

---

## String Decrypter Manual Extraction

The obfuscator encrypts the string, and at runtime, it calls the decryption method to restore it. de4dot can automatically recognize most decrypters; if recognition fails, do it manually:

```text
1. Use dnSpyEx to find the decryption method (usually the signature is fixed: static string Decrypt(int) or Decrypt(string, int))
- Feature: Called frequently, parameters are numeric constants, returns a string
2. Note down the method token (such as 0x06000012)
3. de4dot Specify decoder:
   de4dot --strtyp delegate --strtok 0x06000012 target.exe -o target-clean.exe
```

If even the decryption method itself is obfuscated (control flow flattening), you need to first de-obfuscate the control flow before locating the decryptor.

## Common anti-debug techniques

| Technique | Location | Bypass |
|------|------|------|
| `Debugger.IsAttached` Check | Any method | IL change `ldc.i4.0; ret` or patch getter |
| `Debugger.IsLogging` | — | Same as above |
| Time Check (`DateTime.Now` Difference) | Method Entry | Patch to remove difference comparison |
| `CheckRemoteDebuggerPresent` P/Invoke | — | nop call removal |
| Exception-driven control flow (try/catch path selection) | Main logic | Cannot simply nop, need to analyze the real path of the catch block |

> .NET anti-debugging is simpler than native — mostly involves managed API calls, and in dnSpyEx IL you can change just one line.

## Backup Plan When de4dot Fails

1. **de4dot --detect** Check the recognition results and compare them with the above table
2. **Runtime dump** (MegaDumper / ExtremeDumper / Process Hacker export module)
3. **dnlib script** manual decoding (see the dnlib section in common-workflow.md)
4. **Dynamic priority**: Set breakpoints at decryption points while running, directly view the plaintext, and obtain information without unpacking.

Community references: Washi blog 'misconceptions-about-dotnet' (common misconceptions in IL analysis), Kanxue .NET reverse engineering section, Guided Hacking 'Top 5 .NET RE Tools'.