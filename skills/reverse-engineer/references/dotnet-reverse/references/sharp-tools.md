# Red Team Sharp* Tool Analysis & Tool Installation Matrix & dnSpy MCP

## Red Team Sharp* Tool Analysis

A large number of red team tools are written in C# (Sharp* series), and reversing them is a common scenario: understanding detection logic, changing features, and extracting embedded configurations.

### Common Sharp* Tools Quick Check

| Tools | Features | Reverse concerns |
|------|------|-----------|
| **Rubeus** | Kerberos attack (AS-REP roast / Kerberoast / S4U / pass-the-ticket) | Rubeus project structure is fixed, look for `Interop.*` P/Invoke section to see native call |
| **SharpHound** | BloodHound data collector | LDAP query logic, collected attribute collection |
| **SharpShell / SharpWS** | Remote execution, landscape orientation | WMI / WinRM calls, command obfuscation |
| **Seatbelt** | Information collection | Collection item list, judgment logic |
| **SharpRoast** | Kerberoasting | Ticket request/parsing |
| **Inveigh / SharpSploit** | Middleman / Universal Exploitation Framework | Reflective loading, API call chain |

### General analysis routines

```text
1. Open dnSpyEx (usually there is no confusion, a few teams will add ConfuserEx)
2. Look at Program.Main or entry command distribution (Rubeus is a switch(command) structure)
3. Find the implementation class/method of the target command
4. Look at the P/Invoke section (Interop.* namespace) - native API calls are here
5. Extract embedded resources (some tools embed configurations/templates)
6. If you need to change features (EDR avoidance): change command strings, API calls, and string constants
```

### Rubeus structure example

Rubeus uses command dispatch, one class per subcommand. Find Kerberoasting logic:

```text
Entry: Rubeus.CommandLineParser → parse args
Dispatch: switch(command) → "kerberoast" → execute Ask.TGS(...)
P/Invoke: Rubeus.Interop.Lsa* / Native.cs → native Kerberos API
Key: LsaCallAuthenticationPackage (KERB_RETRIEVE_TKT_REQUEST)
```

Change features (circumvention): Change the command string `"kerberoast"` to a custom name, change the `Rubeus` banner string, and change the calling sequence of P/Invoke.

### Embedded configuration extraction

Many loaders/tools embed C2, key, and certificate encryption in resources or fields:

```powershell
# Viewing Resources (Resource Tree) in dnSpyEx
# Or command line
powershell -c "[System.Reflection.Assembly]::LoadFile('target.exe').GetManifestResourceNames()"
# After finding the resource, right-click in dnSpyEx → Extract / Save
```

Runtime decryption configuration → Dynamically dump cleartext at decryption method return point (see `common-workflow.md`).

---

## Tool installation matrix

### Windows (preferred, dnSpyEx is GUI)

```powershell
# Method A: Chocolatey
choco install dnspy ilspy de4dot detect-it-easy

# Method B: Manually download the release (recommended, version controllable)
# dnSpyEx:    https://github.com/dnSpyEx/dnSpy/releases
# de4dot:     https://github.com/de4dot/de4dot/releases
# ILSpy:      https://github.com/icsharpcode/ILSpy/releases
# DIE:        https://github.com/horsicq/Detect-It-Easy/releases
# dnlib:      dotnet add package dnlib  (NuGet)
```

### Linux / macOS (without dnSpyEx GUI, use CLI)

```bash
# ILSpy CLI Decompile
dotnet tool install -g ilspycmd
ilspycmd target.exe -p -o outdir/         # 反编译到目录

# de4dot cross-platform (requires mono or dotnet)
# Download the .dll of de4dot from the release, run it with dotnet
dotnet de4dot.dll target.exe -o target-clean.exe

# dnlib (scriptable, requires dotnet SDK)
dotnet new console -o dnclean && cd dnclean
dotnet add package dnlib

# DIE CLI (diec)
# Linux: Install from https://github.com/horsicq/Detect-It-Easy
diec target.exe
```

### .NET runtime frontend

```bash
# Linux
sudo apt install dotnet-runtime-8.0        # 或 6.0/7.0 看目标
# macOS
brew install --cask dotnet-sdk
```

> dnSpyEx (with IL editor + debugger) is only available in Windows GUI version. To do .NET reverse engineering of Linux/macOS, you can only use `ilspycmd` decompilation + `dnlib` script patch, and there is no equivalent interactive debugging GUI. When you need to patch, go to Windows first.

---

## dnSpy MCP integration

There are already multiple dnSpy MCP projects in the community, which expose dnSpy's decompilation/IL inspection as MCP tools, which can be directly called by AI - completely consistent with the MCP philosophy of reverse-skill.

### Mainstream dnSpy MCP project

| Project | Features | Adaptation |
|------|------|------|
| **soufianetahiri/dnspy-mcp** | Core MCP Server, exposing decompile, IL inspection and other tools | Claude Code / Cursor |
| **AgentSmithers/DnSpy-MCPserver-Extension** | Runs as a dnSpyEx extension, deeply integrated GUI | Loaded within dnSpyEx |
| **malwarecakefactory/dnspy-mcp-extension** | 33 tools, covering the whole process of triage → deobfuscation | Full process automation |

### Register to Claude MCP configuration

After installing the dnSpyEx extension according to the corresponding project README, register it at `~/.claude/mcp.json` (the specific command/args is subject to the project README):

```json
{
  "mcpServers": {
    "dnspy": {
      "command": "dotnet",
      "args": ["path/to/dnspy-mcp.dll"]
    }
  }
}
```

The AI linkage path of this skill after registration: The user says "Analyze this .NET" → Route to `dotnet-reverse/` → Prioritize the `dnspy_decompile` / `dnspy_inspect_il` tool surface → If it fails, switch to the GUI.

> dnSpy MCP does not have the built-in bootstrap capability of reverse-skill, and users need to manually install the extension and register it according to the project README. You may consider adding `bootstrap-manifest.json` in the future.

---

## Community Resource Index

### Highly recommended

- **Washi Blog** — .NET Reverse Engineer: https://blog.washi.dev/posts/misconceptions-about-dotnet/
- Core point: **Don’t rely too much on dnSpy’s C# decompiler, be familiar with the IL editor** (consistent with the IL priority principle of this project)
- **dnSpyEx** — Active maintenance branch of dnSpy: https://github.com/dnSpyEx/dnSpy
- **de4dot** — .NET deobfuscation: https://github.com/de4dot/de4dot
- **dnlib** — metadata programming: https://github.com/dnlib/dnlib

### Practical tutorial

- Medium《De-obfuscating and reversing a .NET/C# spyware》— dnSpy + de4dot practical info-stealer deobfuscation
- YouTube "dnSpy Patch .NET EXEs & DLLs" — step-by-step patch + keygen
- Kanxue Forum .NET Reverse Section - Search ".net Reverse" / "dnSpy" / "ConfuserEx" There are a large number of practical posts, Nuitka reverse, and anti-kill discussions
- Guided Hacking "Top 5 .NET Reverse Engineering Tools" — dnSpy still ranks first
- StackExchange / Reverse Engineering — `DynamicMethod` Advanced issues such as debugging

### This warehouse already has .NET resources (linkage)

- `reverse-engineering/tools.md` `.NET Analysis` segment — dnSpy/ILSpy tool quick review + Codegate 2013 two-stage XOR+AES-CBC mode
- `reverse-engineering/field-notes.md` `.NET` segment — tool shorthand
- `reverse-engineering/awesome-re-resources.md` — de4dot Selected
- `field-journal/seed-014_unity-il2cpp-reverse.md` — Unity IL2CPP (native side, complementary to .NET managed layer)

.NET reverse in-depth content is unified into this module, and the quick search index can be retained in `reverse-engineering/`.