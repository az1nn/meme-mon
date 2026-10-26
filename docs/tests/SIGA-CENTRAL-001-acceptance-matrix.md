# SIGA-CENTRAL-001 — Acceptance matrix

All tests below are **NOT EXECUTED** as part of M1. Documentation approval does not imply runtime PASS.

| ID | Scenario | Pass condition |
|---|---|---|
| CA01 | ARTIST vs SIGA ART | Same orchestrated entrypoint and task policy |
| CA02 | Repository mismatch | No foreign repo mutation |
| CA03 | Specialist missing | Explicit fail-closed |
| CA04 | Handoff | Stable key, owner, evidence and next action persisted |
| CA05 | New chat | Resumes from repository without original conversation |
| CA06 | Auto-continue | Dispatches next safe owner |
| CA07 | Human gate | Stops and never auto-approves |
| CA08 | Two simultaneous claims | Exactly one owner wins in live independent clients |
| CA09 | Stale HEAD | Writer cannot publish |
| CA10 | Gate freeze | Branch mutation denied |
| CA11 | Independent tasks | Parallelism allowed with non-overlapping claims |
| CA12 | Audit discovery | Detects orphan and stale tasks |
| CA13 | Audit safety | No mutation or claim acquisition |
| CA14 | Derived registry | No override of live sources |
| CA15 | C01/C05 preservation | Approved art, sources and history intact |
| CA16 | PR #13/#15/#27 | No unauthorized changes or merges |
| CA17 | CI exact-head | Check SHA matches current PR HEAD |
| CA18 | Isolation | No cross-repository skill imports |
| CA19 | Expired lease | No automatic takeover without remote proof |
| CA20 | Stale owner release | Cannot release newer fenced claim |

Adversarial GOOD -> BAD -> RESTORE scenarios required for M4: concurrent acquire, stale release, simultaneous work-ref update, API error, timeout with active owner, human gate, and missing approved asset.
