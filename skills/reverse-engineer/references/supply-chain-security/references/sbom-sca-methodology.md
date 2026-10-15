# SBOM + SCA Methodology

## SBOM Standard Comparison

| Standard | Format | Ecology | Recommended Scenarios |
|------|------|------|---------|
| SPDX | JSON/YAML/tag-value | Linux Foundation, Yocto | License Compliance Priority |
| CycloneDX | JSON/XML | OWASP, Kubernetes | Security Analysis Priority |
| SWID | XML | ISO Standard | Enterprise Asset Management |

## SBOM Generation Toolchain

```bash
# cdxgen: Generate CycloneDX SBOM from source code
cdxgen -o bom.json -t cyclonedx

# Syft: Generate from container/filesystem
syft nginx:latest -o spdx-json > sbom.spdx.json

# SBOM-Tool: Microsoft Toolchain
sbom-tool generate -b ./build -bc ./src -pn MyApp -pv 1.0
```

## SCA Tool Comparison

| Tool | Free | Speed | Database | Accessibility |
|------|:--:|------|--------|:--:|
| OSV-Scanner | ✅ | Extremely Fast | OSV.dev | ❌ |
| Trivy | ✅ | Fast | Multi-source | ❌ |
| Dependency-Track | ✅ | Medium | NVD+OSV+GitHub | ❌ (requires plugin) |
| Snyk | ❌ | Medium | Proprietary | ✅ |
| CodeQL | ✅ | Slow | Code-level | ✅ |

## Vulnerability Priority Strategy

```
CVSS ≥ 9.0 + public PoC available + reachable → P0 immediate fix
CVSS ≥ 7.0 + has PoC + reachable → P1 fix this week
CVSS ≥ 7.0 + no PoC or unreachable → P2 fix in the next iteration
The rest → follow the regular procedure
```

## Three-Step Manual Verification Method

```bash
# 1. Confirm the version (do not blindly trust the SBOM fields)
# Inside the container: dpkg -l | grep <package>
# Node: cat node_modules/<pkg>/package.json | jq .version
# Python: pip show <package>

# 2. Confirm the vulnerability
# Search CVE: https://osv.dev / https://nvd.nist.gov
# View affected version range
# Find the GitHub Advisory / oss-security mailing list

# 3. Verify Impact
# Search public PoC: GitHub/Exploit-DB
# Analysis Usage Conditions: Whether Authentication/Local Access/Specific Configuration is Required
# Verify in an isolated environment: docker run --rm -it vulnerable-image bash
```

## Continuous Monitoring

```yaml
# Daily SBOM Update + Scan
schedule:
  - cron: "0 6 * * *"  # 每天早上 6 点
    steps:
      - cdxgen -o bom.json
      - osv-scanner scan --sbom bom.json
      - trivy fs --exit-code 1 --severity CRITICAL .
```

Source: OWASP CycloneDX, SPDX, Google OSV, CISA SBOM Guidance
