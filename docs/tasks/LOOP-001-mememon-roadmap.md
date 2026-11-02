# LOOP-001 — Pi/Ralph-ready Spec Kit tasks for Mememom

**Status:** DOCUMENTED / NOT IMPORTED / NOT EXECUTED
**Spec:** docs/specs/LOOP-001-mememon-roadmap.md
**Plan:** docs/plans/LOOP-001-mememon-roadmap.md
**Source:** User chat roadmap, 2026-11-01.
**Rule:** This is the task **definition** ledger for the native Pi loop. Activation/import is performed by the runtime owner. The loop must use the circuit-breaker rules below and must not repeat an unchanged external blocker.

Each task below has one bounded outcome. Status defaults to PLANNED; operator/human tasks may be WAITING_HUMAN when real evidence is missing. Never mark PASS from chat context alone.

## P0 — Deployable, tested Web preview (L-R01)

### LOOP-P0-01 — Reconcile deployment source and target
- **Status:** COMPLETE (reconciled, not published); **depends:** none; **gate:** AUTO (read-only).
- **Deliverable:** dated HEAD/CI/deployment evidence comparing current GitHub SHA with actual Vercel project deployment SHA, flags and preview policy.
- **Verify:** GitHub workflow jobs (build vs deploy), Vercel project/deploy records, expected artifact files. Preserve evidence URLs.
- **Done:** exact tested source and whether it has truly been published are recorded; no false READY-to-play claim. Evidence: `docs/reports/LOOP-001-P0-01-deployment-reconciliation-2026-11-02.md`.
- **Out of scope:** modifying deployment/provider configuration.

### LOOP-P0-02 — Prepare controlled preview execution
- **Status:** BLOCKED (provider credentials and operator authorization unavailable); **depends:** LOOP-P0-01; **gate:** PROVIDER / DECISION. Evidence: `docs/reports/LOOP-001-P0-02-preview-execution-2026-11-02.md`.
- **Deliverable:** validated preview-only dispatch parameters, existing project identity and secret-presence checklist (never reveal secret values).
- **Verify:** workflow_dispatch contract, prerequisites and current operator approval for the preview.
- **Done:** permission to publish preview is explicit and constraints are checked; otherwise BLOCKED with next owner action.
- **Out of scope:** production deploy, enabling native Git deployments, creating another pipeline.

### LOOP-P0-03 — Publish preview via existing workflow
- **Status:** BLOCKED (authorization/provider access unavailable); **depends:** LOOP-P0-02; **gate:** PROVIDER. Evidence: `docs/reports/LOOP-001-P0-03-preview-dispatch-2026-11-02.md`.
- **Deliverable:** unique preview URL and exact HEAD deployment evidence produced by the existing Web workflow.
- **Verify:** source_commit in version.json; HTTP /, index.html, JS, PCK, WASM MIME; provider run/summary.
- **Done:** all remote artifact checks pass at the deployed SHA; a 404 is a failure.
- **Out of scope:** production aliases and build-stack redesign.

### LOOP-P0-04 — Browser acceptance of preview
- **Status:** WAITING_HUMAN; **depends:** LOOP-P0-03; **gate:** HUMAN.
- **Deliverable:** captured desktop + mobile browser evidence showing Godot canvas, menus, deck selection and local duel start.
- **Verify:** real browser/touch navigation, not headless export alone.
- **Done:** a reviewer can open the preview and actually start gameplay; defects are recorded.
- **Out of scope:** full card illustration polish.

## P1 — Local offline playable loop (L-R02)

### LOOP-P1-01 — Audit existing local gameplay against the journey
- **Status:** COMPLETE (AUTO audit; browser/device acceptance excluded); **depends:** LOOP-P0-04; **gate:** AUTO. Evidence: `docs/reports/LOOP-001-P1-01-local-journey-audit-2026-11-02.md`.
- **Deliverable:** journey trace for MM-04, MM-05, ART-002 and any gaps, avoiding reimplementation.
- **Verify:** relevant deterministic tests and evidence from current code.
- **Done:** precise gameplay acceptance gaps are identified.

### LOOP-P1-02 — Close one blocking user-journey defect
- **Status:** COMPLETE (no-change proof; no blocking defect found); **depends:** LOOP-P1-01; **gate:** AUTO. Evidence: `docs/reports/LOOP-001-P1-02-no-change-proof-2026-11-02.md`.
- **Deliverable:** smallest required fix for deck selection -> bot duel -> victory/defeat -> persistence, if defect exists; otherwise explicit no-change proof.
- **Verify:** affected Godot suite and replay/persistence regression; exact-head CI.
- **Done:** the journey has no known blocking functional gap; one task/iteration, split again if multiple defects are found.

### LOOP-P1-03 — Real offline-play acceptance
- **Status:** WAITING_HUMAN; **depends:** LOOP-P1-02; **gate:** HUMAN.
- **Deliverable:** dated desktop/mobile game-session evidence including 30-card legal deck, final duel result and reload/persistence.
- **Verify:** real player flow, touch, hidden opponent hand, correct Hype/Trend.
- **Done:** tester signs off the full local journey or records reproducible blockers.

## P2 — Approved art and card integration (L-R03)

### LOOP-P2-01 — Reconcile approved assets and CardVisualFrame
- **Status:** BLOCKED (approved C01/C05 V3.1 source unavailable); **depends:** LOOP-P1-03; **gate:** AUTO / HUMAN. Evidence: `docs/reports/LOOP-001-P2-01-art-reconciliation-2026-11-02.md`.
- **Deliverable:** provenance/hash/fit inventory for C01 and C05 V3.1, missing files, PR #27 component and issue #23.
- **Verify:** original asset hash, source dimensions and approval state, no FIT A substitution.
- **Done:** integration inputs are proven; absent source remains WAITING_HUMAN.

### LOOP-P2-02 — Integrate one approved art slice
- **Status:** PLANNED; **depends:** LOOP-P2-01; **gate:** AUTO.
- **Deliverable:** bounded Godot CardVisualFrame visual/interaction integration with responsive front/back and animation, using approved assets.
- **Verify:** import, unit/scene tests, Web/mobile behavior, stable layout and no domain-rule changes.
- **Done:** integration functions technically and does not replace approved baseline; split additional effects into later tasks.

### LOOP-P2-03 — ART + INSPECTOR runtime acceptance
- **Status:** WAITING_HUMAN; **depends:** LOOP-P2-02; **gate:** HUMAN.
- **Deliverable:** authentic browser/mobile captures and ART/SCENE/INSPECTOR decision.
- **Verify:** alignment against C01/C05 V3.1, safe area, touch/flip, legibility, original cartoon/graffiti style; track issue #9.
- **Done:** explicit review PASS or documented changes required.

## P3 — MM-06 Forge human acceptance (L-R04)

### LOOP-P3-01 — Verify implemented private Forge and trust boundaries
- **Status:** PLANNED; **depends:** LOOP-P2-03; **gate:** AUTO.
- **Deliverable:** spec-linked Forge verification, local media behavior, Sandbox persistence, fail-closed budget/provenance evidence.
- **Verify:** existing MM-06 and MM-07/MM-08 deterministic suites and Web scene smoke.
- **Done:** remaining gaps are reported without inventing a new Forge.

### LOOP-P3-02 — Forge visual/touch approval
- **Status:** WAITING_HUMAN; **depends:** LOOP-P3-01; **gate:** HUMAN.
- **Deliverable:** desktop/mobile user acceptance of create -> private preview -> save/reopen flow.
- **Verify:** actual touch/visual behavior; private Sandbox cannot skip Canon gates.
- **Done:** approved evidence or explicit unresolved acceptance tasks.

## P4 — PWA and intermediate playable release (L-R05)

### LOOP-P4-01 — PWA install/offline/update acceptance
- **Status:** PLANNED; **depends:** LOOP-P3-02; **gate:** AUTO / HUMAN.
- **Deliverable:** browser-target evidence for installability, restart offline, cache update, version match and clean rollback/recovery behavior.
- **Verify:** exact-head artifact validation plus real supported browser tests.
- **Done:** reproducible PWA acceptance, no confusion with a shell-only HTTP smoke.

### LOOP-P4-02 — Accessibility, identity and touch review
- **Status:** WAITING_HUMAN; **depends:** LOOP-P4-01; **gate:** HUMAN.
- **Deliverable:** focus/contrast/responsiveness/brand and touch acceptance evidence.
- **Verify:** genuine visual checks on supported targets, preserve approved art and non-infringing brand identity.
- **Done:** reviewer records PASS or tracks individual blockers.

### LOOP-P4-03 — Interim offline Web milestone checkpoint
- **Status:** PLANNED; **depends:** LOOP-P4-02; **gate:** DECISION.
- **Deliverable:** tested SHA, preview evidence, release checklist for offline Web playable milestone and outstanding full-V1 gates.
- **Verify:** exact-head CI, P0–P4 evidence, explicit release authorization before a production rollout.
- **Done:** candidate is documented; not automatically published to production or labeled full public V1.
- **Note:** Android build/install and signed APK remain separate full-V1 acceptance gates under issue #18.

## P5 — Community and online V1 scope (L-R06)

### LOOP-P5-01 — Reconcile MM-07 provenance/moderation operations
- **Status:** PLANNED; **depends:** LOOP-P4-03; **gate:** HUMAN / DECISION.
- **Deliverable:** moderation/privacy/reporting operator checklist against current reference model and issue #19.
- **Done:** explicit rights/provenance, moderation and retention gates have owners and verifiable evidence.

### LOOP-P5-02 — Reconcile MM-08 immutable Canon legality
- **Status:** PLANNED; **depends:** LOOP-P5-01; **gate:** AUTO / HUMAN.
- **Deliverable:** immutable editions, approved promotion and format-legal evidence with safeguards against unreviewed Sandbox publication; issue #20.
- **Done:** no public Canon claim without moderator/operator review.

### LOOP-P5-03 — Host and validate MM-09 authority
- **Status:** PLANNED; **depends:** LOOP-P5-02; **gate:** PROVIDER / AUTO.
- **Deliverable:** approved hosted service integration and reconnect/replay validation with real Godot transport; issue #21.
- **Done:** verified authoritative gameplay, not merely an in-memory protocol reference.

### LOOP-P5-04 — Full V1 governance and release gate
- **Status:** WAITING_HUMAN; **depends:** LOOP-P5-03; **gate:** HUMAN / DECISION.
- **Deliverable:** MM-10 security/privacy/contact/license proof, Android full-V1 install/signed candidate evidence, final audit and release decision; issues #16, #18, #22.
- **Done:** all original docs/specs/V1-release-goal.md criteria are evidenced or release remains BLOCKED.
- **Out of scope:** automatic public release, UGC promotion and production deploy.

## Circuit breaker and iteration hygiene

- A task blocked by credentials, provider, browser/device, human approval, missing asset or external decision is marked `WAITING_EXTERNAL` with owner, exact action and evidence timestamp.
- The same task must not be retried until new evidence changes the blocker state.
- Rechecking an unchanged blocker is not progress and must not consume another iteration.
- If no independent task is safe, stop with `BLOCKED:<motivo>` and wait for the owner instead of looping.
- A task may only be marked complete with its deliverable and validation evidence; a report that says "still blocked" is not a completed implementation task.

## Traceability and import boundary

| Requirement | Iteration IDs | Primary reference |
|---|---|---|
| L-R01 | LOOP-P0-01..04 | INFRA-01, PR #26 |
| L-R02 | LOOP-P1-01..03 | MM-04, MM-05, ART-002 |
| L-R03 | LOOP-P2-01..03 | SCENE-ARCH-001, ART-002, issues #9/#23 |
| L-R04 | LOOP-P3-01..02 | MM-06 |
| L-R05 | LOOP-P4-01..03 | INFRA-01, issue #18, V1 release goal |
| L-R06 | LOOP-P5-01..04 | MM-07..MM-10 and V1 release goal |
| L-R07 | Every LOOP-P* task | Existing Pi/Ralph task consumer |

**Handoff:** The existing Pi/Ralph task system should reconcile stale task records and independently decide how to import/activate these tasks. This document does not modify or execute .agent/tasks.json.
