# DPAPI Credential Chain Checklist

> Analyst-side checklist for an authorized CTF/lab artifact: map a
> DPAPI-protected secret to the context that unwraps it and to the
> sandbox-internal service that accepts it. Recovered secrets are challenge
> evidence — never reuse or replay them outside the sandbox.

## First Pass

- Blob source, masterkey path, SID, protector scope, profile path, store name, wrapper metadata
- Secret locations: Credential Manager, Vault, browser Login Data, cookies, Wi-Fi profiles, app storage
- Acceptance targets: browser session replay, SMB, RDP, WinRM, app login, data decryption

## Chain To Reconstruct

1. Protected artifact is identified
2. Matching masterkey or unwrap context is found
3. Plaintext secret is recovered
4. Accepting service or dataset is confirmed
5. Resulting capability or access is reproduced

## Evidence To Keep Together

- Source side: blob path, store, SID, profile, machine or user scope
- Unwrap side: masterkey source, backup key use, wrapper details, plaintext type
- Acceptance side: target service, target host, unlocked data, resulting session or privilege

## Common Pitfalls

- Treating DPAPI decryption as the end instead of proving an accepting service or dataset
- Mixing user and machine scope without recording which protector actually matches
- Ignoring application-specific wrapping around browser or vault secrets
