---
name: cloud-k8s
description: Use for authorized cloud, container, and Kubernetes security assessment including metadata SSRF, IAM misconfig, container escape paths, and cluster RBAC review.
---

# Cloud / Container / Kubernetes Security

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` — **Cloud/K8s testing must require written authorization**
2. `NOW`: case-init + scope; clarify account boundaries and prohibit destructive operations
3. `NOW`: Confirm that it is cloud metadata/container/K8s/IAM, not an ordinary web scan (the latter `pentest-tools/`)
4. `NEXT`: tool-index; kubectl/aws/gcloud, etc. are mostly installed manually.
5. `ACT`: Starting from "Identity and Exposure", disable network-wide scanning by default

## Applicable scenarios

- Cloud Metadata SSRF (169.254.169.254/IMDS)
- IAM excessive permissions, public buckets, wrong security groups
- Docker/containerd Escape path evaluation
- Kubernetes RBAC, Secrets, Admission, supply chain image
- Container image vulnerability (can be linked to `supply-chain-security/`)

## Workflow

### Phase 1 — Identity and Boundaries

```text
□ Current identity: Cloud AK/SK, K8s SA, node SSH?
□ Scope: single account/single cluster/single namespace
□ Network file: authorized_target_only
```

### Phase 2 — Cloud control plane

```bash
# Example (Replace by vendor; MUST be within authorized account)
aws sts get-caller-identity
aws s3 ls
# Azure / GCP corresponding identity commands
```

```text
□ Public bucket/error ACL
□ Metadata: IMDSv1 vs v2; SSRF chain
□ Role playable (PassRole) and horizontal
```

### Phase 3 — Container

```text
□ Whether privileged / hostPath / hostNetwork
□ capabilities (SYS_ADMIN, etc.)
□ Writable host path → escape candidate
□ Image history and known CVEs → Trivy
```

### Phase 4 — Kubernetes

```bash
kubectl auth can-i --list
kubectl get pods,secrets,svc -A
kubectl get clusterrolebindings
```

```text
□ SA token mounting and permissions
□ Danger admission webhook missing
□ etcd/dashboard exposed
□ Is the network policy allowed by default?
```

## Toolchain

| Tools | Usage | Bootstrap |
|------|------|------|
| kubectl | Cluster interaction | Manual |
| trivy | mirror/IaC | bootstrap `trivy` if available |
| kube-bench/kubeaudit | CIS/config | manual |
| pacu/scoutsuite | Cloud Audit (Authorization) | Manual |
| nuclei | known cloud vulnerability template | bootstrap nmap/nuclei ecology |

## Reference

- `references/k8s-cloud-checklist.md`
- CTF control: `../../CTF-Sandbox-Orchestrator/competition-agent-cloud/`
- `../supply-chain-security/` `../pentest-tools/`

## Routing context

**Upstream**: MASTER R23
**Downstream**: Get node shell → `attack-chain` / `windows-ad`; mirror vulnerability → supply-chain
**MUST NOT**: Unauthorized scanning of other public cloud tenants

## Task completion self-check

- [ ] Is it limited to authorized accounts/clusters?
- [ ] Does the discovery include recurrence and impact?
- [ ] Avoid destructive operations?
- [ ] report/journal?