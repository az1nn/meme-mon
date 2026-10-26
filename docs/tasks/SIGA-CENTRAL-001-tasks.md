# SIGA-CENTRAL-001 — Tasks

- [x] G1=A G2=A G3=A G4=B G5=B G6=B consolidated.
- [x] M0 live repository reconciliation performed; PR #15 closed/unmerged; issue #24 open.
- [x] M1 isolated branch and draft PR claim established; post-claim overlap checked.
- [x] M1 spec/plan/ADR/contract/test documents proposed.
- [ ] Review M1 documentation and exact-head CI; preserve draft.
- [ ] Inventory every real skill consumer and entrypoint, including external/unindexed agents.
- [ ] Implement alias composition without copying other repositories' skills.
- [ ] Build derived Engineering Graph and persistent handoff validation.
- [ ] Prove live CAS + fencing with two independent writers and no bypass paths (issue #24).
- [ ] Add expiry/recovery, stale owner release, head drift and gate freeze adversarial tests.
- [ ] Add read-only audit and deterministic orphan classification.
- [ ] Test cross-session automatic continuation and human-gate stop.
- [ ] Verify all relevant CI on exact PR head and protected merge policy.
- [ ] Request separate merge/cutover approval; never merge in M1.

M1 docs cannot be marked production-ready by a green documentation CI.
