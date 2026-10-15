---
name: browser-automation
description: |
  统一自动化入口。覆盖浏览器自动化（Playwright）和 Windows 桌面应用自动化（OpenReverse）。
  浏览器场景：打开网页、点击、填表、爬取、截图、自动化登录、渗透页面交互。
  桌面场景：操作 IDA/x64dbg 等 GUI 工具、Windows UI Automation、视觉驱动交互、桌面应用网络抓包。
  触发关键词：浏览器自动化、桌面自动化、打开网页、填表、爬取、截图、自动化登录、Playwright、agent-browser、headless、OpenReverse、UIA、CUA、桌面操作、Windows 自动化。
---

# Automation (Desktop & Browser Automation)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm whether the current task hits the scope of application of this skill
2. `NOW`: Read `../tool-index.md`, verify tool availability and actual path
3. `NEXT`: Call bootstrap when tools are missing, don’t guess the path
4. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

## Scope of application

Use this skill when the task falls into the following scenarios:

### Browser scenario (Playwright/agent-browser)
- Open web pages and operate page elements (click, fill in forms, submit)
- Crawl page content or take screenshots
- Automated login process
- Interact with web pages during penetration testing (submit payload, trigger XSS)
- Automated processing of verification code pages
- Batch form submission

### Desktop application scenario (OpenReverse)
- Operate Windows desktop applications (IDA Pro, x64dbg, Wireshark, etc.)
- Requires visually driven interaction (CUA mode)
- Requires structured UI operations (UIA mode)
- Network traffic observation for desktop applications (built-in mitmproxy)
- Automated GUI operation of reverse engineering tools
- Black box testing desktop software

### Division of labor with other tools

| Scene | What to use |
|------|--------|
| Manipulate web pages (in-browser) | **Playwright/agent-browser** |
| Operating desktop application (Windows GUI) | **OpenReverse** |
| Packet capture analysis, HTTP request capture | anything-analyzer or OpenReverse network lane |
| JS breakpoints, Hooks, CDP debugging | jshookmcp |
| Locate signature algorithm, complement environment reproduction | js-reverse |

Simple judgment:
- Target is web page → Playwright
- Targets Windows desktop applications → OpenReverse
- Need both → use in combination

---

## Part 1: Browser Automation (Playwright/agent-browser)

### Core workflow

```bash
# 1. Open the page
agent-browser open <url>

# 2. Get interactive elements (return references @e1, @e2...)
agent-browser snapshot -i

# 3. Using References to Operate on Elements
agent-browser click @e1
agent-browser fill @e2 "text"

# 4. Close when finished
agent-browser close
```

### Command Reference

```bash
# Navigation
agent-browser open <url>
agent-browser close

# Page Snapshot
agent-browser snapshot        # 完整无障碍树
agent-browser snapshot -i     # 仅可交互元素（推荐）

# Interactions
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser type @e2 "text"
agent-browser press Enter
agent-browser scroll down 500

# Get Information
agent-browser get text @e1
agent-browser get title
agent-browser get url

# Waiting
agent-browser wait @e1
agent-browser wait 2000
agent-browser wait --load networkidle
```

### Notes
- `agent-browser close` must be executed, otherwise the process will leak
- Take a snapshot before operation, do not guess the element reference
- After submitting the form, use `wait --load networkidle` to stabilize the page.

---

## Part 2: Desktop Application Automation (OpenReverse)

### Overview

[OpenReverse](https://github.com/zhexulong/openreverse) is a desktop interaction and evidence collection framework for AI Agent, supporting:
- **UIA mode**: Windows UI Automation, structured desktop control operation
- **CUA mode**: Vision-driven interaction (Computer Use Agent), suitable for complex GUIs
- **Network Observation**: built-in mitmproxy proxy + local crawling

### Interactive mode selection

| Mode | Suitable for scene | Bottom |
|------|---------|------|
| UIA | Target application has standard Windows controls (buttons, text boxes, lists) | Windows UI Automation API |
| CUA | Target application UI complex or non-standard controls (IDA's disassembly view, custom rendering interface) | Visual recognition + mouse and keyboard |

### Network observation mode

| Mode | Suitable scene |
|------|---------|
| Proxy Lane | The target application can configure a proxy (recommended) |
| Local Lane | The target application cannot use the proxy and needs to be crawled locally |

### Installation and configuration

```bash
# 1. Clone Project
git clone https://github.com/zhexulong/openreverse.git
cd openreverse

# 2. Install dependencies
npm install

# 3. Connecting to the Agent Host (Claude Code / Codex / Zed)
npm run init:agents -- --target=all /path/to/project

# 4. Install CUA runtime (if visual driver mode is needed)
npm run install:cua-runtime
npm run doctor:cua-runtime

# 5. Install network monitoring dependencies (if packet capture is needed)
npm run install:mitmproxy
npm run doctor:network
```

### Common combinations

| Requirements | Configuration |
|------|------|
| Only operate desktop applications | UIA or CUA, not connected to the network lane |
| Operation desktop application + packet capture | UIA/CUA + proxy lane |
| Operation desktop application + local crawl | UIA/CUA + local lane |

### Reverse scenario example

```text
Scenario: Automated operation of IDA Pro for batch analysis

1. Open IDA Pro in OpenReverse CUA mode
2. Automatically load target binary
3. Wait for the analysis to complete
4. Export function list through UI operation
5. Also use network lane to observe IDA’s network behavior (such as Lumina requests)
```

```text
Scenario: Automated x64dbg debugging

1. Start x64dbg in OpenReverse UIA mode
2. Load the target program
3. Set breakpoints
4. Run and observe register/memory changes
5. Take screenshots to save evidence
```

---

##On-Demand Bootstrap

### Automation capability boundaries

| Tools | Automatic installation | Installation method | Instructions |
|------|-----------|---------|------|
| Playwright | ✓ | npm + npx playwright install | Browser automation engine |
| agent-browser CLI | ✓ | npm install -g agent-browser | Browser operation CLI |
| Node.js | ✓ | winget | Prerequisites |
| OpenReverse | ✗ | Manual clone + npm install | Experimental stage, heavy dependence |
| mitmproxy | ✗ | Manual installation | OpenReverse network observation dependency |

### Bootstrap trigger

- Browser operation missing Playwright → automatic bootstrap
- Desktop operation requires OpenReverse → guide users to install manually (given complete steps)

### OpenReverse manual installation guide

If AI detects a need for desktop application automation but OpenReverse is not installed:

```markdown
⚠️ **Requires OpenReverse for desktop application automation**

**Installation steps**:
1. `git clone https://github.com/zhexulong/openreverse.git`
2. `cd openreverse && npm install`
3. `npm run init:agents -- --target=all <你的项目路径>`
4. For visual mode: `npm run install:cua-runtime`
5. If you need network observation: `npm run install:mitmproxy`

**Verification**: `npm run doctor:cua-runtime` and `npm run doctor:network`
```

---

## Routing context

**Upstream entrance**: `references/README.md` (master control), `routing.md`
**Applicable scenarios**: Any task that requires automating a browser or desktop application
**Downstream Export**:
- The captured request needs to be analyzed → `anything-analyzer` or `js-reverse`
- Requires JS debugging/Hook → `jshookmcp`
- Need to restore signature algorithm → `js-reverse`
- Desktop application is a reverse engineering tool → `ida-reverse/`

**Sibling related modules**: `js-reverse` (JS may need to be analyzed after browser operation), `ida-reverse` (OpenReverse can automatically operate IDA GUI)


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?