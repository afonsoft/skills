# 2026-09-03 Multi Issue/PR Security Boundary Integration

## Scene

Maintaining a public security skills router repository: The local main working tree contains a large number of user changes and is behind the remote, requiring simultaneous review of multiple open PRs, resolution of historical issues, feature additions, security re-audits, and ensuring GitHub status and cross-platform CI closure.

## Reusable Patterns

1. **Dirty worktree isolation:** First fetch from the remote, then create an independent worktree from `origin/main`; all PR merges, conflict resolutions, testing, and commits are done in the isolated directory.
2. **Preserve PR Ownership:** Merge the accepted PR head as the parent commit of the merge commit into the integration branch; after finally fast-forwarding and pushing to main, GitHub automatically marks the corresponding PR as merged/closed.
3. **State Freezing:** Record the head SHA of each PR before merging; refetch before pushing, requiring that the remote main still equals the review baseline, and verify that the head of all accepted PRs is an ancestor of the final HEAD.
4. **Review under AV isolation:** For payload documents that may be quarantined by Defender, do not rely on working tree files; use `git show :path` / Git index blob for hash, link, and content boundary checks.
5. **Reference/Executable Layering:** The passive Markdown/JSON payload can be retained, but executable scripts must not reference it; CI fixed corpus hash, binary allowlist, symbolic links, dangerous mode, and GitHub Action full-SHA.
6. **Functional PRs should not be blindly merged:** In addition to running the original PR tests, you should also check cross-instance states, path/port isolation, and new constraints in the mainline. This time, it was found that the IDA keepalive file was not isolated by port, and it was fixed in the merge commit.
7. **Issue clearance must have a basis:** Each issue should first arrive at a traceable conclusion, then be closed with completed / duplicate / not_planned; do not omit explanations on the grounds of 'batch cleanup'.

## Pitfalls

| Problem | Cause | Handling |
|---|---|---|
| PR shows as mergeable on GitHub, but there are still semantic conflicts when merged into the latest mainline | PR base is behind, and multiple PRs modify the same CI/router files | Simulate merge locally, resolve according to the latest SSoT, and then rerun the full set of tests |
| AV deletion of payload working tree files causes normal scans to miss detections | File extension Markdown can also hit feature signatures | Read from Git index blob, prohibit 'skip if unreadable' |
| Binary Ninja MCP source can easily be mistaken for official | MCP project is a community GPL plugin, not an official Vector 35 component | Clearly indicate the source in skill, review commits, bridge version, and loop binding |
| Git Bash cannot equivalently simulate Linux Python→bash subprocess | Windows CreateProcess prioritizes parsing system `bash.exe`/WSL | Running Bash syntax and direct contracts locally, ultimately based on Ubuntu/macOS CI |

## Verification

- Route regression: 175/175
- Windows PowerShell 5.1 and PowerShell 7: P0, coding, Evidence, IDA, smoke all passed
- Python: case review, documentation links, repository security all passed
- Bash: Syntax, case workflow, new Binary Ninja routing pass
- GitHub: Windows, Ubuntu, macOS, Gradle Wrapper Validation all passed
- Remote open Issues / PRs: all 0

## Environment

- OS: Windows
- Git: isolate worktree + PR head ancestor verification
- CI: Windows, Ubuntu, macOS
- Data processing: Only disclose repository metadata and records of desensitization methods