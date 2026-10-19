# Attack Chain Playbook Quick Check

> Select the corresponding assessment path according to the engagement goal.
> Each playbook defines a standard sequence of **phases** for planning —
> active steps are delegated to specialist modules and run only inside the
> approved `scope.md` contract.

---

## Playbook 1: External web application → directory service

```
1. Subdomain enumeration + port discovery on in-scope ranges
2. Web fingerprinting → identify known-vulnerable components
3. Validate findings (proof of exploitability, minimum action)
4. Assess what the validated access reaches (host-level visibility)
5. Identity/AD mapping (in-scope only — BloodHound-style collection)
6. Impact demonstration against in-scope systems
7. Report: Evidence chain + remediation mapping
```

**Phase tooling (delegated, in-scope only)**: subdomain/HTTP enumeration →
vulnerability scanning → validation → identity-path mapping → report.

---

## Playbook 2: Social-engineering assessment → internal reach

```
1. Confirm the authorization explicitly covers social engineering
   (many scopes exclude it — verify before planning)
2. Define approved lure themes and recipient groups with the client
3. Deliver the approved simulation through the client's chosen platform
4. Measure click/report rates — the metric is awareness, not payloads
5. If a foothold is in scope: continue with host-level assessment
6. Report: simulation metrics + validated findings
```

**Note**: lure design and delivery belong to the client's approved phishing
simulation platform; this skill only plans the phases and evidence.

---

## Playbook 3: Physical/wireless proximity → internal network

```
1. Confirm physical-access scope (badge/Wi-Fi/USB policy)
2. Wireless assessment of in-scope SSIDs only
3. Document reachable internal surface from the gained vantage
4. Continue with internal enumeration phases
5. Report
```

---

## Playbook 4: Cloud environment assessment

```
1. In-scope cloud asset discovery (tenants, subscriptions, storage)
2. Public-exposure review (open buckets, exposed services)
3. Identity and permission review (IAM paths, role chaining)
4. Validate misconfigurations with read-only evidence
5. Report: exposure inventory + remediation
```

---

## Playbook 5: Bug bounty / SRC triage

```
1. In-scope asset collection (program scope only)
2. Fingerprint identification → known-vulnerability checks
3. Parameter discovery
4. Category-by-category testing within program rules:
   - access control / IDOR
   - server-side request handling
   - injection classes
   - client-side issues
   - business-logic flaws (payment / verification / reset flows)
5. Write a minimal PoC + submit the report
```

---

## Playbook 6: Certificate-service (AD CS) review

```
1. Enumerate the certificate services in scope
2. Identify misconfigured templates (published ESC-class issues)
3. Demonstrate impact on a test/in-scope account
4. Report: misconfiguration list + hardening guidance
```

---

## General decision matrix

| Current status | Next step priority |
|---------|-------------|
| Domain names only | Enumeration → fingerprinting → exposure review |
| Validated web finding | Assess reachable impact → identity mapping |
| In-scope host access | Local review → what does it reach? |
| Identity credentials in scope | Path mapping → demonstrate in-scope impact |
| Cloud keys found | Enumerate permissions (read-only) → report |
