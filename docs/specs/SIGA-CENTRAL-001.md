# SIGA-CENTRAL-001 — Central orchestration and composed specialists

Status: PROPOSED / DOCUMENTATION ONLY. Pilot: MemeMon. Decisions: G1=A G2=A G3=A G4=B G5=B G6=B.

## Problem
Independent ART/SCENE/ARCH sessions can leave untracked work, incomplete assets, stale approvals and no durable next action. Existing SKILLS-001 work in closed unmerged PR #15 is a design/prototype, not proof of a distributed ownership coordinator (issue #24).

## Requirements
- FR01: SIGA is the mandatory orchestration boundary for specialist invocations. ARTIST/ART -> SIGA ART; CENA/SCENE -> SIGA SCENE; ARCH -> SIGA ARCH; LENTE/INSPECTOR -> SIGA INSPECTOR; LORE on demand. REPORTER belongs to SIGA handoff.
- FR02: RECONCILE -> CLASSIFY (RESUME/WATCH/ADVANCE) -> CLAIM -> EXECUTE -> VERIFY -> HANDOFF, verify-first.
- FR03: A single composed session retains domain ownership: SIGA manages lifecycle, specialists manage technical/creative decisions; human gates never auto-waived.
- FR04: Continue automatically across owners until verified DONE, legitimate WAIT_GATE, BLOCKED or WATCH.
- FR05: Recover abandoned work only with repository-backed evidence, fresh remote reconciliation and safe claim ownership; elapsed time alone is insufficient.
- FR06: Derive Engineering Graph from specs, tasks, PRs, CI, branches, artifacts and handoffs; caches are disposable.
- FR07: Discover tasks during SIGA and via read-only automated audit. Audit never acquires claims or mutates code.
- FR08: Prevent concurrent writers with proven compare-and-swap, fencing, exact-head and post-claim barrier. Issue #24 remains the prerequisite; simulated tests alone are not proof.
- FR09: Repo-local skills only. Do not silently copy global/canonical skills. Alias resolution requires verified installation at each entrypoint.
- FR10: Preserve C01/C05 approvals, historical ARTIST records, PR #13, #15, #27, issue #9/#23/#24, Godot-only constitution and roadmap.
- FR11: M1 is docs only, draft PR, no merge, no runtime activation.

## User scenarios
1. User invokes ARTIST in a fresh session: repository identified, SIGA reconciles, ART receives an eligible task; artifacts and next action persist before declaring done.
2. User invokes SIGA later: reconstruct from durable sources and route to SCENE/ARCH without original chat.
3. Two concurrent sessions select same task: exactly one claim wins or both WATCH pending trustworthy proof; no stolen task.
4. An approved image exists only in chat: classify MISSING_ARTIFACT, do not fabricate recovery or mark integrated.
5. A task awaits human visual approval: stop at WAIT_GATE, do not auto-approve.

## Non-goals
No merged coordinator, production distributed lock, new backend, UI/gameplay change, assets, deployment, rewriting canonical SIGA, reopening historical PRs, or merging.

## Acceptance
See docs/tests/SIGA-CENTRAL-001-acceptance-matrix.md. This document records design intent, not implemented behavior.
