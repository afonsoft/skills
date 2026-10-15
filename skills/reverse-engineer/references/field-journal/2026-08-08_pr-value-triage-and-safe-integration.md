# 2026-08-08 Open PR value classification and security integration

## Scene classification

Others / Warehouse Maintenance / Contribution Review

## Goal Overview

Synchronize the upstream mainline while retaining uncommitted content of the work tree, review multiple open PRs, and safely integrate low-risk, high-reuse value contributions into the local mainline.

## Complete execution link

1. Check the remote end, branch lag and work tree changes.
2. Use stash to isolate user changes, fast-forward to the latest mainline, restore and verify.
3. Pull open PR refs and compare commits, file ranges, and three-way merge results.
4. Classify contributions containing only desensitized field-journal as low-risk candidates.
5. Check the conflict files, change scale and mainline duplication for core script PR.
6. Merge 4 journal PRs, correct the index uniformly, and run smoke and routing coherence.

## Trampling on pit records

| Problem | Cause | Solution |
|---|---|---|
| Pulling the mainline will overwrite local index modifications | Upstream and working trees modify `_index.md` at the same time | Stash isolation, recovery after fast-forward |
| Index statistics of old PRs overwrite each other | Multiple PRs are based on the same old baseline | Unified recalculation of indexes after merging content files |
| Large PR seems to be of high value but cannot be merged directly | The mainline has evolved and the core script has content conflicts | Suspended, requiring rebase and special testing |

## Reusable mode

- First layer by "document/execution code", and then sort by reuse value, conflict surface and test evidence.
- For journal-only PRs, content merging and index coordination can be processed separately.
- For Core Infrastructure PRs where the conflict is not a simple textual matter, behavioral equivalence should be re-validated.

## Verification results

- smoke: All passed.
- routing coherence: all passed.
- User working tree content: full recovery, no conflicts.

## Desensitization review

Does not include credentials, private destinations, user identities, or internal URLs.