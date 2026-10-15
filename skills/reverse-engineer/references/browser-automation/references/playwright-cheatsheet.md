# Browser and Desktop Automation Quick Check

> Covers common commands and patterns for Playwright (browser automation) and OpenReverse (Windows desktop automation).
> For penetration testing, reverse engineering, and automated collection scenarios.

---

## Playwright / agent-browser command quick review

### Navigation and life cycle

```bash
# Open the page
agent-browser open "https://target.com/login"

# Wait for the page to load
agent-browser wait --load networkidle

# Close the browser (must be executed, otherwise there will be a process leak)
agent-browser close
```

### Page snapshot

```bash
# Complete Accessibility Tree (For Debugging)
agent-browser snapshot

# Interactive elements only (recommended, return references like @e1, @e2...)
agent-browser snapshot -i
```

### Element interaction

```bash
# Click
agent-browser click @e1

# Fill in the text box
agent-browser fill @e2 "admin"

# Character-by-character input (suitable for input boxes with JS listeners)
agent-browser type @e2 "password123"

# Key
agent-browser press Enter
agent-browser press Tab
agent-browser press Escape

# Scroll
agent-browser scroll down 500
agent-browser scroll up 300
```

### Information acquisition

```bash
# Get element text
agent-browser get text @e1

# Get the page title
agent-browser get title

# Get the current URL
agent-browser get url
```

### Waiting strategy

```bash
# Waiting for the element to appear
agent-browser wait @e1

# Wait for a fixed time (milliseconds)
agent-browser wait 2000

# Waiting for network idle
agent-browser wait --load networkidle

# Waiting for navigation to complete
agent-browser wait --load domcontentloaded
```

---

## Common modes for penetration testing

### Automated login

```bash
agent-browser open "https://target.com/login"
agent-browser snapshot -i
agent-browser fill @username "admin"
agent-browser fill @password "password123"
agent-browser click @login_button
agent-browser wait --load networkidle
agent-browser get url                    # 确认是否跳转到后台
```

### XSS Payload Injection

```bash
agent-browser open "https://target.com/search"
agent-browser snapshot -i
agent-browser fill @search_input "<script>alert(1)</script>"
agent-browser click @search_button
agent-browser wait --load networkidle
agent-browser snapshot                   # 检查 payload 是否被渲染
```

### Form batch submission (with script)

```powershell
$payloads = @("' OR 1=1--", "<img src=x onerror=alert(1)>", "{{7*7}}")
foreach ($p in $payloads) {
    agent-browser open "https://target.com/form"
    agent-browser snapshot -i
    agent-browser fill @input "$p"
    agent-browser click @submit
    agent-browser wait --load networkidle
    agent-browser snapshot              # 检查响应
}
agent-browser close
```

### Cookie / LocalStorage extraction

```bash
# Using Playwright API (Node.js Script Mode)
# agent-browser does not directly expose cookies and requires script mode
```

```javascript
// playwright-extract.js
const { chromium } = require('playwright');
(async () => {
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto('https://target.com');
    
// Extract cookies
    const cookies = await context.cookies();
    console.log(JSON.stringify(cookies, null, 2));
    
// Extract localStorage
    const storage = await page.evaluate(() => JSON.stringify(localStorage));
    console.log(storage);
    
    await browser.close();
})();
```

### Screenshot evidence collection

```bash
# agent-browser mode
agent-browser open "https://target.com/admin"
agent-browser wait --load networkidle
# The screenshot feature depends on the agent-browser version
```

```javascript
// playwright script mode
await page.screenshot({ path: 'evidence.png', fullPage: true });
```

---

## Playwright Node.js API Quick Check

### Basic template

```javascript
const { chromium } = require('playwright');

(async () => {
    const browser = await chromium.launch({
        headless: true,           // 无头模式
// proxy: { server: 'http://127.0.0.1:8080' }  // Use Burp proxy
    });
    const context = await browser.newContext({
        ignoreHTTPSErrors: true,  // 忽略证书错误
        userAgent: 'Mozilla/5.0 ...',
    });
    const page = await context.newPage();
    
    await page.goto('https://target.com');
// ... operation ...
    
    await browser.close();
})();
```

### Commonly used selectors

```javascript
// CSS Selector
await page.click('#login-btn');
await page.fill('input[name="username"]', 'admin');

// Text Selector
await page.click('text=Submit');
await page.click('button:has-text("Login")');

// XPath
await page.click('xpath=//button[@type="submit"]');

// Combine
await page.click('form >> input[type="submit"]');
```

### Network interception

```javascript
// Intercept request
await page.route('**/api/**', route => {
    console.log('API call:', route.request().url());
    route.continue();
});

// Modification request
await page.route('**/api/auth', route => {
    route.continue({
        headers: { ...route.request().headers(), 'X-Admin': 'true' }
    });
});

// Intercept response
await page.route('**/api/user', async route => {
    const response = await route.fetch();
    const json = await response.json();
    json.role = 'admin';  // 篡改响应
    route.fulfill({ response, json });
});
```

### Waiting and assertion

```javascript
// Wait for element
await page.waitForSelector('#result');
await page.waitForSelector('.error', { state: 'visible' });

// Waiting for network request
const [response] = await Promise.all([
    page.waitForResponse('**/api/login'),
    page.click('#login-btn'),
]);
console.log(response.status(), await response.json());

// Waiting for navigation
await Promise.all([
    page.waitForNavigation(),
    page.click('a[href="/admin"]'),
]);
```

---

## OpenReverse Desktop Automation Quick Check

### Mode selection

| Mode | Command Prefix | Suitable Scenario |
|------|---------|---------|
| UIA | `openreverse uia ...` | Standard Windows controls (buttons, text boxes, lists) |
| CUA | `openreverse cua ...` | Complex/non-standard GUI (IDA disassembly view, custom rendering interface) |

### UIA mode (structured control operations)

```bash
# Launch Application
openreverse uia launch "C:\Tools\x64dbg\x64dbg.exe"

# Get window tree
openreverse uia tree

# Click the button
openreverse uia click "Button:Open"

# Fill in the text box
openreverse uia fill "Edit:FilePath" "C:\sample.exe"

# Select Menu
openreverse uia menu "File > Open"

# Get control text
openreverse uia get-text "Edit:Output"
```

### CUA mode (visual-driven interaction)

```bash
# Screenshot the current screen
openreverse cua screenshot

# Click screen coordinates
openreverse cua click 500 300

# Double Click
openreverse cua dblclick 500 300

# Input Text
openreverse cua type "search string"

# Key
openreverse cua key "ctrl+g"    # IDA: Go to address
openreverse cua key "F5"        # IDA: Decompile
openreverse cua key "F9"        # x64dbg: Run
```

### Network observation (mitmproxy)

```bash
# Start proxy mode observation
openreverse network start --mode proxy --port 8888

# Enable local capture mode
openreverse network start --mode local --filter "target.exe"

# Get captured requests
openreverse network list

# Export as HAR
openreverse network export har output.har

# Stop Observing
openreverse network stop
```

---

## Automated combination of reverse engineering tools

### IDA Pro automation (OpenReverse + ida-reverse)

```text
Scenario: Batch analysis of multiple samples

1. openreverse cua launch "ida64.exe"
2. For each sample:
a. openreverse cua key "ctrl+o" # Open file dialog box
   b. openreverse uia fill "Edit:FileName" "sample_N.exe"
   c. openreverse uia click "Button:Open"
d. Wait for analysis to complete (polling the IDA title bar)
e. Extract results through ida-reverse MCP tool
f. openreverse cua key "ctrl+w" # Close the database
```

### x64dbg automated debugging

```text
Scenario: Automated breakpoint setting and data collection

1. openreverse uia launch "x64dbg.exe"
2. openreverse cua key "F3" # Open the file
3. openreverse uia fill "Edit:FileName" "target.exe"
4. openreverse uia click "Button:Open"
5. openreverse cua key "ctrl+g"           # Go to address
6. openreverse cua type "0x401000"
7. openreverse cua key "F2" # Set breakpoint
8. openreverse when key "F9" # Enter
9. openreverse cua screenshot # screenshot save status
```

---

## Frequently asked questions and solutions

| Problem | Cause | Solution |
|------|------|------|
| agent-browser unresponsive | process leak | `agent-browser close` first, then open again |
| Element reference invalid | Page refreshed | Re-`snapshot -i` Get new reference |
| Invalid form filling | JS listens to input event | Use `type` instead of `fill` |
| HTTPS certificate error | Self-signed certificate | Playwright: `ignoreHTTPSErrors: true` |
| Page loading timeout | Slow network/many resources | Increase timeout or use `domcontentloaded` |
| UIA cannot find control | Application uses self-drawn control | Switch to CUA mode |
| CUA click offset | Resolution/DPI mismatch | Take a screenshot to confirm the coordinates first |

---

## Installation and dependencies

### Playwright

```powershell
# Install Node.js (if not already installed)
winget install OpenJS.NodeJS.LTS

# Install Playwright
npm install -g playwright
npx playwright install          # 下载浏览器引擎

# Install agent-browser CLI
npm install -g agent-browser
```

### OpenReverse

```powershell
git clone https://github.com/zhexulong/openreverse.git
cd openreverse
npm install
npm run init:agents -- --target=all <项目路径>

# Optional: CUA Runtime
npm run install:cua-runtime
npm run doctor:cua-runtime

# Optional: Network Observation
npm run install:mitmproxy
npm run doctor:network
```

---

## Related resources

| Resources | Description | Links |
|------|------|------|
| Playwright Official Documentation | API Reference | https://playwright.dev/docs/intro |
| OpenReverse | Desktop automation framework | https://github.com/zhexulong/openreverse |
| mitmproxy | HTTP/HTTPS proxy | https://mitmproxy.org/ |
| Windows UI Automation | UIA Documentation | https://learn.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32 |