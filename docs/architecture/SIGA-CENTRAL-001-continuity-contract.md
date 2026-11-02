# SIGA Central — Continuity and derived graph contract

## Stable identity
A task key is repository + workstream + task ID. Source of truth is live GitHub + ratified constitution + active specs, then handoffs; chat is non-authoritative.

## Proposed handoff schema
```yaml
schema: siga.continuity/v1
repository: az1nn/meme-mon
task_key: SIGA-CENTRAL-001:M1
orchestrator: SIGA
owner: ARCH
mode: RESUME
status: WAIT_GATE
claim:
  pr: "<verified-number>"
  branch: "<verified-branch>"
  expected_head_sha: "<verified-sha>"
  lease_id: "<opaque-lease>"
  fence_generation: "<monotonic-generation>"
evidence:
  artifacts: []
  checks: []
  decisions: []
gates:
  human: PENDING
next_owner: INSPECTOR
next_action: "<bounded-verifiable-action>"
```
Example fields are not assertions of actual runtime claims.

## State machine
READY -> CLAIMED -> RUNNING -> VERIFY -> DONE, WAIT_GATE, BLOCKED or RECOVERABLE. RECOVERABLE is derived only after checking remote owner activity, PR/CI, lease fencing and artifact availability; timeout is a signal, not takeover permission. SUPERSEDED must preserve historical claim lineage.

## Graph
Spec/task -> PR/claim -> owner/run -> branch/commit -> artifact -> gate/CI -> next action -> task. Recompute from sources; any cache is disposable and must not become authoritative.

## Audit
Read-only checks: UNCLAIMED, UNTRACKED, STALE_HANDOFF, GATE_STALE, CLAIM_CONFLICT, MISSING_ARTIFACT, UNVERIFIED_DONE, WAIT_GATE. Emit evidence-backed report. Audit never claims, closes PRs, releases leases or merges.

## Concurrency
GitHub REST GET+PATCH is not proven atomic CAS. SKILLS-001 design suggests GraphQL updateRefs beforeOid/afterOid for claim ref and work ref in one atomic batch, but issue #24 requires independent live contention tests and enforcement for every writer. On API uncertainty, conflict or stale HEAD -> WATCH. No force-unlock, stale release or auto merge.
