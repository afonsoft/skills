# 2026-08-08 Open PR value evaluation and merger report

## in conclusion

8 open PRs based on latest `origin/main` review. This round merges #59, #19, #22, #29; suspends #43, #37, #36, #23. The merged smoke and routing coherence checks both pass.

## Evaluation results

| PR | Value | Risk/Status | Decision |
|---|---|---|---|
| #59 | Rust cdylib differential reproduction method is complete and highly reusable | Only journal and index, no executable code | Merge |
| #19 | Windows 24H2 tool chain compatibility experience covers wide | journal and index only | merge |
| #22 | Electron/Bytenode/ update chain analysis method complete | only journal and index | merge |
| #29 | Next.js dual API serializer and contract reconstruction experience complete | journal and index only | merge |
| #43 | Routing single source of truth, regression baseline, CI and version fixation are of high value; client access can only be used as an optional adaptation layer | 38 files, conflicts with 4 key files of the main line, the original proposal contains OpenCode-specific configuration | Suspended, special review after rebase is recommended; the core must not be bound to OpenCode |
| #37 | evidence graph/case review can complete the delivery audit | conflicts with the main line routing checksum document | suspended, it is recommended to rebase and then run its single test |
| #36 | MCP/bootstrap security reinforcement is in the right direction | 6 key files conflict, some capabilities have been absorbed by the recent mainline | Suspended, do differential deduplication |
| #23 | Bash parity and display materials have ecological value | 92 files, many display assets, 2 script conflicts | Suspended, recommended to split PR |

## Decision diagram

```mermaid
flowchart TD
    A[开放 PR] --> B{仅文档与脱敏 journal?}
    B -->|是| C{内容完整且方法可复用?}
    C -->|是| D[合并并统一索引]
    C -->|否| E[要求补充]
    B -->|否| F{核心脚本冲突或变更面过大?}
    F -->|是| G[暂缓并要求 rebase/拆分]
    F -->|否| H[隔离运行测试后再决定]
```

## verify

- `references/scripts/smoke.ps1`: ALL PASS (9 script parsing, 8 routing use cases).
- `references/scripts/verify-routing-coherence.ps1`: ALL ROUTING COHERENCE CHECKS PASSED。
- The user's original uncommitted journal is saved and restored through stash isolation during synchronization and merging.

## Follow-up suggestions

1. Prioritize rebase #43 to the current `main`, focusing on reviewing JSON routing equivalence, supply chain pin gate and cross-platform paths.
2. Let #37 rebase alone and run `references/case-review/tests/test_review_case.py`.
3. File-by-file comparison of #36 with merged security fixes, extracting only tests or boundary treatments not yet covered.
4. Split #23 into three independent PRs: Bash parity, plug-in metadata, and demo assets.