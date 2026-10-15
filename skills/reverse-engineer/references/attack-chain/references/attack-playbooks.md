# Attack Chain Playbook Quick Check

> Select the corresponding playbook according to the goal type. Each playbook defines a standard path from initial access to goal achievement.

---

## Playbook 1: External Web Application → Domain Control

```
1. Subdomain enumeration + port scanning
2. Web fingerprinting → Find known vulnerable components
3. Exploit the vulnerability to obtain Webshell/RCE
4. Intranet information collection (ipconfig/ifconfig, arp, net user)
5. Build tunnel (frp/chisel/ssh)
6. Intranet scanning (survival hosts, open ports)
7. Credential acquisition (mimikatz/hashdump/ configuration file)
8. Lateral movement (PTH/WMI/PsExec)
9. Domain information collection (BloodHound)
10. Domain privilege escalation (Kerberoasting/DCSync/ constrained delegation)
11. Obtain domain control permissions
```

**Key toolchain**: subfinder → httpx → nuclei → sqlmap/sstimap → frp → nmap → mimikatz → crackmapexec → bloodhound → certipy

---

## Playbook 2: Phishing → Intranet Penetration

```
1. Collection of target employee information (LinkedIn/Maimai)
2. Construct a phishing email (forged sender/legitimate subject)
3. Create payload (macro document/LNK/ISO/HTML smuggling)
4. Send phishing emails
5. Waiting for online (C2 beacon)
6. Local information collection + privilege escalation
7. Credential extraction
8. Lateral movement
9. Sustainability
10. Goal achieved
```

**Key toolchain**: theHarvester → gophish → msfvenom/cobalt-strike → mimikatz → bloodhound

---

## Playbook 3: Near-source penetration → Intranet

```
1. Physical checkpoints (WiFi signal, access control type, USB port)
2. WiFi attack (Fluxion fake hotspot/WPA cracking)
or BadUSB implant (Rubber Ducky keyboard injection)
or network implant (Raspberry Pi / LAN Turtle)
3. Obtain the intranet access point
4. Intranet scanning
5. Follow steps 5-11 as in Playbook 1.
```

**Key toolchain**: fluxion/aircrack-ng → rubber-ducky → frp → nmap → crackmapexec

---

## Playbook 4: Cloud Environment Penetration

```
1. Cloud asset discovery (subdomain name → CNAME → cloud service provider)
2. Bucket enumeration (S3/OSS/Blob public access)
3. SSRF → Cloud Metadata (169.254.169.254)
4. Obtain temporary credentials (AK/SK/Token)
5. Cloud API enumeration (IAM/EC2/Lambda/RDS)
6. Privilege escalation (PassRole/AssumeRole)
7. Lateral movement (cross-account/cross-region)
8. Data acquisition
```

**Key toolchain**: subfinder → nuclei(ssrf) → aws-cli → pacu → ScoutSuite

---

## Playbook 5: Bug Bounty / SRC quick fix

```
1. Asset collection (subdomain name + port + JS file)
2. Fingerprint identification → Quick verification of known vulnerabilities (nuclei)
3. Parameter discovery (arjun/paramspider)
4. Category-by-category testing:
- IDOR/override (change ID/change role)
- SSRF (intranet detection/cloud metadata)
- SQL injection (sqlmap)
   - XSS（xsstrike）
- File upload (bypass detection)
- Logic vulnerabilities (payment/verification code/password reset)
5. Write PoC + submit report
```

**Key toolchain**: subfinder → httpx → nuclei → arjun → sqlmap → xsstrike → burpsuite

---

## Playbook 6: AD CS Certificate Attack

```
1. Discover the AD CS service (certipy find)
2. Identify vulnerable templates (ESC1-ESC8)
3. Requesting a malicious certificate
4. Use the certificate to authenticate the target user
5. Get NTLM Hash or TGT
6. DCSync exports all credentials
```

**Key toolchain**: certipy → rubeus → mimikatz → secretsdump

---

## General decision matrix

| Current status | Next step priority |
|---------|-------------|
| Target domain name only | Subdomain enumeration → Port scan → Web fingerprinting |
| There are web vulnerabilities | Obtain shell → Intranet information collection |
| Have low-privilege shell | Privilege escalation → Credential extraction |
| There is an intranet machine | Build a tunnel → Intranet scan → Horizontal |
| With domain user credentials | BloodHound → Find attack paths |
| Domain managed Hash | DCSync → Golden Ticket |
| Youyun AK/SK | Enumerate permissions → Elevate privileges → Data acquisition |
| Phishing | Local privilege escalation → Credentials → Horizontal |
| Near-source access | Intranet scanning → Same as above |