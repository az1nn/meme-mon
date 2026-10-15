# SKILLS-001 — Plan

1. RECONCILE: confirm master SHA, open PR #13 draft, issue #9, canonical SIGA and constitution.
2. CLASSIFY: ADVANCE for independent skills-architecture work; isolated branch from exact master. Do not touch ARTIST-003 files.
3. Define owner/alias/route contract in docs/architecture/SKILLS-001-operating-model.md.
4. Integrate reporting into SIGA HANDOFF contract by reference, not copying SIGA skill. Preserve historical docs.
5. Implement durable atomic claims only after choosing an actual compare-and-swap store/API and validating it; until then use serialized SIGA dispatch and fail closed on contention.
6. Test two simultaneous acquisitions, renewal, stale release, expiration recovery, cross-domain review and exact-head CI.
7. Verify all open gates and PRs, request review, merge only after evidence and protections pass.
8. Persist compact handoff with remaining blockers and next action.

Risks: GitHub content API alone may not guarantee atomic acquisition; do not claim concurrency fixed until race tests pass. Parallel art PR can advance: reconcile before merge.
