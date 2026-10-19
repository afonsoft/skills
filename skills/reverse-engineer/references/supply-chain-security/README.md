---
name: supply-chain-security
description: Use for software supply-chain security assessment covering SBOM, SCA, CI/CD pipelines, container images, build integrity, dependency provenance, and vulnerability reachability.
---
# Supply Chain Security Testing

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

> SBOM / SCA / CI/CD Pipeline / Dependency Traceability
> Regulation-driven: U.S. Executive Order SBOM, Chinese national standards, EU CRA

## Applicable Scenarios

- Software Supply Chain Security Assessment
- Open-source dependency vulnerability scanning and verification
- CI/CD Pipeline Safety Audit
- Container Image Security Analysis
- Third-party component compliance review
- Build product traceability and integrity verification

## Six-Level Supply Chain Governance Framework

```text
Layer 1: Source Code Trust Assessment → Review of Upstream Repositories/Maintainers/Release History
Layer 2: Build pipeline integration → CI/CD Security access control, signature verification
Layer 3: Product Distribution Integrity → Signatures, Checksums, SBOM Attachment
Layer 4: Runtime Protection → Container Scanning, Admission Control
Layer 5: Continuous Monitoring → Real-time CVE Tracking, Vulnerability Reachability Analysis
Layer 6: Incident Response → Supply Chain Attack Emergency Response and Rollback Strategy
```

## Workflow

### 1. SBOM Generation and Audit

```text
Generate SBOM:
□ CycloneDX Format: cdxgen → bom.json
□ SPDX format: sbom-tool generate
□ Syft: syft <image|dir> -o spdx-json

Audit key points:
□ Are there any unknown/unauthorized dependencies
□ Are there any deprecated/discontinued packages
□ License Conflict Detection
□ Direct dependencies vs transitive dependency list
□ Release timeline and maintainer status of each component
```

### 2. Software Composition Analysis (SCA)

```bash
# OSV-Scanner (Free, Maintained by Google)
osv-scanner scan -r . --format json

# OWASP Dependency-Track (Enterprise-Level Continuous Monitoring)
docker run -p 8080:8080 dependencytrack/apiserver
# → Upload SBOM → Automatically Match NVD/OSV/GitHub Advisory

# Snyk (Commercial)
snyk test --all-projects
snyk monitor  # 持续监控

# Trivy (Container + Dependencies + IaC)
trivy fs .          # 文件系统扫描
trivy image nginx   # 容器镜像
trivy config .      # IaC 配置
```

### 3. Vulnerability Accessibility Verification

```text
SCA alerts ≠ actual risks! Only about 15% of alerts from most SCA tools are actually attainable.

Verification steps:
1. Use Dependency-Track or Trivy to obtain a CVE list
2. Filter vulnerabilities with CVSS ≥ 7.0
3. Conduct reachability analysis on CVEs with PoC
- Code Property Graph Slicing: Tracking the path from user input to vulnerable functions
- DEPTEX Method: EPD (Execution Path Dominance) + LLM Semantic Verification
4. Validate the PoC in an isolated environment
5. Prioritize the repair of accessible vulnerabilities based on their actual impact
```

Tool Reference:
- CodeQL: GitHub code search → data flow analysis
- Snyk Code: Accessibility Mark
- DEPTEX: LLM-Assisted Context-Aware Risk Assessment

### 4. CI/CD Pipeline Safety

```text
Security checkpoint:
□ Code commit → pre-commit hook: gitleaks (secret scanning)
□ PR Phase → SCA Scan (Trivy/OSV-Scanner)
□ Build Stage → Artifact Signing (cosign)
□ Push phase → SBOM attachment (syft + attest)
□ Deployment Phase → Access Control (OPA/Kyverno + Image Scanning)
□ Runtime → Continuous Vulnerability Monitoring (Dependency-Track)

Pipeline self-safety:
□ Pipeline as Code Audit (GitHub Actions / GitLab CI Configuration Injection)
□ Runner Isolation (to prevent malicious builds from breaking out of the container)
□ Key Management (Actions Secrets / Vault, no hardcoding)
□ Third-party Action review (lock commit SHA, not tag)
```

### 5. Container Image Security

```bash
# Dockerfile Audit
hadolint Dockerfile

# Image Scanning (Multi-layer: OS + Application Dependencies + Configuration)
trivy image --severity HIGH,CRITICAL nginx:latest

# Minimal Base Image
# Priority: distroless → alpine → slim → avoid latest
docker scout quickview nginx:latest

# Mirror Signature
cosign sign --key cosign.key myimage:tag
cosign verify --key cosign.pub myimage:tag
```

### 6. Third-Party Dependency Review

```text
New Dependency Checklist:
□ Maintenance status: Has there been a submission in the past 6 months? Maintainer activity?
□ Security History: Has there ever been malicious code implanted in the past?
□ Dependency Tree: How many new transitive dependencies are introduced after adding it?
□ License: Compatible with project license?
□ Alternatives: Are there safer alternatives (Snyk Advisor / Socket.dev rating)?

Risk assessment matrix:
High maintenance × low dependency × compatible license → low risk
Low maintenance × high dependency × license conflict → high risk
```

## Toolchain

| Tool | Purpose | Acquisition |
|------|------|------|
| OWASP Dependency-Track | Enterprise-level Continuous SCA | `docker pull dependencytrack/apiserver` |
| OSV-Scanner | Free SCA (OSV.dev ecosystem) | `go install github.com/google/osv-scanner` |
| Trivy | Image + Dependencies + IaC Scanning | `apt install trivy` |
| Syft | SBOM Generation | `curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh` |
| cdxgen | CycloneDX SBOM generation | `npm install -g @cyclonedx/cdxgen` |
| Cosign | Container Signature | `go install github.com/sigstore/cosign/v2/cmd/cosign` |
| Gitleaks | Key/Credential Scanning | `go install github.com/gitleaks/gitleaks/v8` |
| Snyk | Commercial SCA + Accessibility | `npm install -g snyk` |
| CodeQL | Code Query + Data Flow | Built-in GitHub Actions |

## References

- `references/sbom-sca-methodology.md` — SBOM + SCA Methodology
- `references/cicd-pipeline-security.md` — CI/CD Pipeline Safety Audit


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?