# Next.js CDK Order Center Contract Fidelity Local Rebuild

> Date: 2026-08-01
>
> Scene: Web / API / JS Reverse Engineering and Local Reconstruction
>
> Desensitization: Use standard placeholders for target domain names and ports; only retain categories for credentials, CDK, order identifiers, and private paths, without recording the original values

## Scene Classification

Web / API / JS Reverse Engineering

## Overview of Goals

For a Next.js single-page order center, establish a four-source evidence chain of 'entry snapshot, static bundle, runtime page, public OpenAPI,' and, without connecting to real payment, worker, and inspection services, reconstruct a runnable local project with the same information architecture, the same browser request patterns, the same response projections, and the same order status semantics.

## Scope Summary (Desensitized)

- auth_basis: The user provides the entry and requests analysis along with the local implementation of the same type
- network_profile: Public access and public OpenAPI read-only review; both build and acceptance point to the loopback address
- asset_types: [web, frontend_js, public_openapi, screenshot, local_source]
- fixture_profile: Synthetic CDK, synthetic credential, synthetic payment link, deterministic worker/check/payment adapter

## Characters

- lead_role: lead
- specialists: [cre, doc]

## Complete Execution Chain

1. Solidify entry HTML, response headers, public OpenAPI, and SHA-256, and reuse existing static packages and browser forensics.
2. Extract routes, request body fields, headers, storage keys, polling intervals, conditional rendering, and status vocabulary from the main page bundle.
3. Separate the internal legacy API from the public v1 API in the page, create respective serializers, and avoid sharing DTOs to prevent field drift.
4. Capture full-page screenshots at runtime, calculate desktop geometry from DOM and CSS, handle mobile breakpoints, card hierarchy, control states, and text baseline.
5. Establish a canonical domain model, CDK ledger, and deterministic state machine; external capabilities are handled through `CHECK_FN`, `PAYMENT_PROVIDER`, and `WORKER_GATEWAY` fixture adapters.
6. Immediately reduce credential and payment links in the request phase to summary, type, and security hints; the persistent model does not set original text slots.
7. Perform contract testing on single transactions, batch transactions, details, cancellations, resubmissions, pagination, dual authentication, and OpenAPI documentation.
8. Use desktop and mobile browser screenshots to verify visuals; use production builds, API smoke tests, secret scanning, and decompression rechecks to form delivery evidence.

## Evidence Chain Summary (De-identified)

| E-id | source_type | Reusable Command Pattern | Related Conclusion |
|------|-------------|----------------|----------|
| E-001 | network/file | `curl -D headers -o page https://{target_domain}/<entry>; shasum -a 256 page` | Framework Entry and Timestamp Baseline |
| E-002 | frontend_js/openapi | `rg 'sessionStorage|/api/|productType|customerToken' {formatted_chunk}`; `jq '{info,paths,securitySchemes}' openapi.json` | legacy requests, status, browser storage, and v1 contracts |
| E-003 | runtime_visual/local_qa | `chromium --headless ...; screenshot + DOMRect`；`npm test && npm run build && BASE_URL=... npm run smoke` | Desktop/Mobile Geometry, Conditional Rendering, and Local Contract Closed Loop |

## Finding / Path Summary

- top_finding: The internal page legacy API and the public v1 API share business semantics, but the request fields, authentication entry points, and response projections are different. When rebuilding, 'one domain model, two boundary serializers' are needed.
- path_type: callflow
- path_one_liner: Form input -> page field mapping -> legacy Route Handler -> canonical service -> fixture adapter/ledger -> legacy serializer -> polling rendering.

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| Creating interfaces solely based on route names still causes page fields to be blank | The response fields of legacy and v1 are not the same DTO | Deduce the serializer from the bundle's properties and perform contract testing on both boundaries separately | ~45 min |
| Initial page state and bound state mixed together | Multiple cards, prompts, buttons, and lists are conditionally rendered | First solidify the unbound baseline, then create the interaction matrix according to CDK/order status | ~30 min |
| Batch interfaces need to express partial success and ledger consistency at the same time | Elevating individual errors to a whole-batch exception will lose the per-item result semantics of the original page | First parse item by item, then produce created/duplicate/failed sequentially in a single store mutation, and finally verify the ledger and commit atomically | ~35 min |
| Ambiguity exists between required fields in the document and property names | OpenAPI and internal page calls evolve independently | Retain standard fields, while recognizing aliases for compatibility at boundaries; report separately with judgment basis | ~15 min |
| Visually seems close, but vertical errors continue to accumulate | Small deviations in card padding, line-height, and gaps add up | Using full page height, main column width, and key DOMRect as constraints, perform section-by-section regression screenshots | ~40 min |
| Fixture prompt copy breaks the same style first screen | Implementation instructions are directly mixed into the product UI | UI maintains the evidence collection baseline, fixture instructions are placed in README; input still uses deterministic examples | ~15 min |

## Toolchain Discovery

- The property read points of a static bundle are more suitable for restoring response DTOs than the interface path itself.
- legacy/v1 serializer layering allows both page compatibility and public API stability to be maintained simultaneously.
- `fullPage` Screenshots need to take into account the viewport width, the total page height, and the DOMRect; simple pixel similarity can be magnified by font anti-aliasing.
- Batch orders should retain individual created/duplicate/failed; deduplication, capacity deduction, and ledger verification are placed in the same mutation, with only a single atomic file replacement performed in the end.
- Secret scanning should cover source code, runtime stores, test logs, and the extracted directories of final compressed packages, not just scan the Git working tree.

## Key Code/Commands

```bash
# Static Call Plane and State Fields
rg -n 'customerToken|productType|upiExpiresAt|customerResubmitCount|sessionStorage' {formatted_chunk}

# Public API Structure
jq '{openapi,info,paths:(.paths|keys),security:.components.securitySchemes}' openapi.json

# Local Quality Gate
npm run lint
npm test
npx tsc --noEmit
npm run build
BASE_URL=http://127.0.0.1:{port} npm run smoke
```

## Suggestions for Improvement of This Package

1. `js-reverse` add a checklist for 'legacy UI API and public API dual serializer'.
2. Add 'Visual Baseline Geometry Table' and 'Initial/Bind/Order Status Matrix' to the report template.
3. The QA template adds batch partial success and atomic persistence, dual authentication OR, OpenAPI schema/actual response consistency, and delivery package expansion scanning.

## Reusable patterns/script snippets

1. **Four-Source Intersection**: Entry snapshot locates version, static bundle restores call surface, runtime restores conditional rendering, OpenAPI restores public contract.
2. **Single Core Dual Projection**: The canonical domain maintains consistency with the ledger, and the legacy/public serializer preserves boundary fidelity.
3. **Initial state first, then state matrix**: First lock the unbound first screen, then verify bound, created, in progress, completed, canceled, and resubmitted.
4. **Request Period Reduction**: After the original input enters the service, it is immediately converted into SHA-256, type, and mask, and the logs and store only receive the reduced results.
5. **Secondary inspection of the delivery package**: Unzip the compressed package to a new directory, reinstall, test, and build to avoid issues being hidden by leftover files in the working directory.

## Evolution Actions

- [ ] Updated the routing matrix
- [ ] Updated tool-index
- [ ] Updated bootstrap-manifest
- [ ] Updated the sub-skill documentation
- [x] Added pitfalls record
- [ ] No update needed

## Environmental Information

- OS: macOS
- Tool versions: Node.js 24, Next.js 16.2.12 App Router, React, TypeScript 5.9.3, Chrome/Playwright
- Target Platform/Version: Next.js App Router / React / OpenAPI 3.1

## Final Acceptance Record

- ESLint, TypeScript 5.9.3, Next.js 16.2.12 production build: passed.
- Node test: 8/8 passed.
- HTTP smoke: 15 contract groups passed.
- Playwright: 11 status/viewport screenshots, 10 sets of assertions passed, browser console and page errors are both empty.
- The initial page at 1440 px has the same baseline dimensions of 1440×1294; RGB MAE is 2.301148, and the proportion of pixels within the threshold per channel is 0.945085.

## Desensitization Review

- [x] Replace the target domain name with `{target_domain}`
- [x] CDK, order number, token, cookie, JWT, and payment link were not written in the original text
- [x] Real IP, port, and local private path not written
- [x] Run the command using `{port}` with placeholders
- [x] Delivery experience retains only methods, structures, and validation patterns

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. -->