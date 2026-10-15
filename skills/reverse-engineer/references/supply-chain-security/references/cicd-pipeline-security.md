# CI/CD Pipeline Safety Audit

## Pipeline Attack Surface

```text
Threat Model (STRIDE):
□ Deception: Forging construction/signature/source
□ Tampering: Modifying source code/build artifacts/dependencies
□ Deny: Malicious operations without audit logs
□ Information leakage: pipeline logs/build artifacts leaking keys
□ Denial of Service: Exhaust CI resources / disrupt builds
□ Privilege escalation: Runner escape/key theft
```

## Audit Checklist

### 1. Pipeline as Code Configuration

```yaml
# Key Points for GitHub Actions Auditing
# ❌ Danger Mode
on:
  pull_request_target:  # 可访问 secrets 的 PR 触发
    types: [opened]

# ❌ Script Injection
- run: echo "${{ github.event.issue.title }}"  # 用户输入 → shell

# ❌ Unrestricted token permissions
permissions: write-all

# ✅ Safe Mode
on:
  pull_request:  # 无 secrets 访问
    types: [opened]

# ✅ Pin to SHA
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683

# ✅ Minimum Privileges
permissions:
  contents: read
```

### 2. Key Management

```bash
# Scan for keys in historical commits
gitleaks detect --source . --verbose
trufflehog git file://. --only-verified

# Check Actions Secrets Usage
gh secret list
# Confirmation: No hard-coded keys, regular rotation, least privilege

# Runtime Key Injection
# ✅ Using OIDC to Replace Long-Term Keys
# ✅ Secrets are exposed to specific steps only when needed
```

### 3. Constructing Integrity

```bash
# Build Traceability
# Generate Immutable Build Records (SLSA L2+)
slsa-provenance generate --source . --output provenance.json

# Product Signature
cosign sign-blob --key cosign.key artifact.tar.gz

# Verification
cosign verify-blob --key cosign.pub --signature artifact.tar.gz.sig artifact.tar.gz
```

### 4. Runner Safety

```text
□ Use GitHub-hosted runner? (Recommended, brand new environment each time)
□ Self-hosted runner: Is it running in an isolated VM/container?
□ Have you ever run a fork PR? (The risk is extremely high for self-hosted runners)
□ Does the Runner have network outbound restrictions?
□ Is it possible for build caches to leak across builds?
```

### 5. Dependency Pull Security

```text
□ npm: Should package-lock.json be committed? Prohibit --force / --legacy-peer-deps
□ pip: Is the version in requirements.txt frozen? Prohibit pip install <unverified sources>
□ Docker: Is FROM fixed to a digest? Prohibit the latest tag
□ Go: Should go.sum be submitted?
□ Private package: Does registry authentication use short-term tokens?
```

## Automated Pipeline Check

```yaml
# .github/workflows/supply-chain.yml
name: Supply Chain Security
on: [push, pull_request]

jobs:
  sca:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: SBOM Generate
        run: |
          npm install -g @cyclonedx/cdxgen
          cdxgen -o sbom.json
      
      - name: OSV Scan
        run: |
          go install github.com/google/osv-scanner/cmd/osv-scanner@latest
          osv-scanner scan --sbom sbom.json --format sarif > osv-results.sarif
      
      - name: Trivy Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          severity: CRITICAL,HIGH
          exit-code: 1
      
      - name: Secret Scan
        run: |
          docker run --rm -v $PWD:/src ghcr.io/gitleaks/gitleaks:latest \
            detect --source /src --verbose
      
      - name: Dependency-Track Upload
        run: |
          curl -X POST https://dtrack.example.com/api/v1/bom \
            -H "X-Api-Key: ${{ secrets.DTRACK_API_KEY }}" \
            -F "autoCreate=true" -F "project=myapp" -F "bom=@sbom.json"
```

Source: SLSA Framework, OWASP CI/CD Top 10, GitHub Security Lab
