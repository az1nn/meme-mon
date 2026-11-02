# LOOP-001 — Mememom iteration plan

**Status:** DOCUMENTED / NOT EXECUTED
**Spec:** docs/specs/LOOP-001-mememon-roadmap.md
**Task graph:** docs/tasks/LOOP-001-mememon-roadmap.md
**Existing execution system:** Pi + Ralph; no modifications, replacement, setup, or invocation are part of this plan.

## Sequencing

P0 **Verified Web preview on Vercel** -> P1 **Playable offline loop** -> P2 **Art/runtime polish** -> P3 **Meme Forge human acceptance** -> P4 **PWA acceptance and playable Web release candidate** -> P5 **Community/Canon/online authority and governance**.

This is a prioritization and interim offline Web milestone; it does not redefine the repository's formal V1 public release goal. Android build/install may proceed independently after its artifact prerequisites and is still required for the full current V1 release acceptance.

## P0 — Browser preview first

- Re-read the current master HEAD, GitHub Actions workflow and deployed Vercel project before acting. Confirm whether GitHub's build/export run actually published or skipped deployment.
- Prefer the existing controlled workflow with workflow_dispatch, publish=vercel, vercel_target=preview. Do NOT turn on Vercel Git auto-deploy, alter production aliases or use --prod.
- Check required secrets VERCEL_TOKEN, VERCEL_ORG_ID and VERCEL_PROJECT_ID exist without displaying their values; missing provider credentials are an operator BLOCKED gate.
- Verify the deployed version.json source_commit, /, index.html, JS, PCK, and application/wasm Content-Type. Then verify a real Godot canvas, navigation and a test duel in desktop/touch browser.
- If Vercel returns 404, fix only the verified cause and re-test the same release lane. Do not rearchitect Web delivery to fix a provider-configuration issue.
- No publish action is authorized by merely transcribing this plan. Separate operator authorization is necessary at execution time.

## P1 — First complete playable loop

- Use the existing MM-04 deterministic duel, MM-05 collection/deckbuilder and ART-002 navigation/HUD. First audit what already works instead of recreating the systems.
- User-facing path: open Web -> select a legal saved 30-card deck -> play against deterministic bot -> receive Hype/Trend feedback and terminal result -> reload and retain local collection/deck state.
- Test desktop and touch/mobile navigation, hidden opponent hand, legal moves, defeat/victory and persistence. Record runtime evidence separate from automated regression evidence.
- Block progress on game-breaking defects, not noncritical ideas for unrelated features.

## P2 — Approved ART/SCENE/ARCH integration

- Treat PR #27 as a merged isolated CardVisualFrame component, not as accepted final art integration.
- Recover and verify approved C01/C05 V3.1 assets as needed; preserve missing-source blocker in issue #23 until hashes and dimensions are verified.
- Keep FIT A rejected. Align card geometry, front/back visuals, input/flip response, responsive layout and modest battle feedback with the approved cartoon-first visual concept.
- Capture genuine Godot Web mobile/desktop screenshots; require human ART and INSPECTOR gate before calling final visual integration complete. Issue #9 remains relevant.

## P3 — MM-06 private Forge

- Validate existing MM-06 Godot Forge, local image handling, constrained Sandbox preview, preview navigation and touch affordances; do not rebuild implemented behavior.
- Verify persistent/local data and separation of private Sandbox from competitive Canon. Preserve MM-03 system-owned power budget.
- Distinguish automated suite PASS from human visual/touch approval. Record every outstanding issue with owner and evidence.

## P4 — PWA and playable Web release candidate

- Validate install, offline restart, update behavior, accessibility/focus/contrast and visual/brand acceptance on supported browsers.
- Preserve the same tested Godot export as the source of the PWA and Capacitor Android wrapper.
- Keep Android build/install/signed-release, physical-device testing, provider release and public V1 launch as separate gates; they are not automatically complete when a Web PWA is usable.
- Interim offline Web acceptance does NOT authorize public UGC, online match hosting or closure of full V1.

## P5 — Community/Canon/online

- Reconcile MM-07 moderation and provenance, MM-08 immutable Canon/legality, MM-09 hosted authoritative WebSocket/transport and replay, MM-10 public security/privacy/governance and asset-licensing.
- Prefer validation and integration of existing deterministic reference implementations before creating new services.
- Public submission, online gameplay and V1 release remain blocked until the relevant external, human, operator, security and legal gates have evidence.

## Tasking and iteration contract

1. Each item in the task document is deliberately small: one outcome with prerequisites and gates.
2. Task IDs are stable (LOOP-P0-01, etc.) and names are unique; reference existing issues/specs rather than duplicating closed PR work.
3. The downstream Pi/Ralph agent must reconcile master/PRs/CI and current tasks before choosing any task. This document does not mark current queue items complete.
4. Only one atomic task per iteration; if blocked by credentials, human approval, provider or legal acceptance, report BLOCKED/WAITING_HUMAN instead of retrying infinitely.
5. Apply a circuit breaker: verify the same external blocker at most once per task. Mark the task WAITING_EXTERNAL with owner/action and skip it or stop if no independent task is safe. Reopen only after new evidence exists.
6. No completion without exact-head and task-appropriate evidence. A provider PREVIEW deployment is not production permission.
6. The existing queue's stale PR-027/PR-028 records are an explicit reconciliation concern for its owner, not a justification for this skill to edit the queue.
7. No runner, scripts, Pi settings, model/provider, branch protection or deployment configuration changes within LOOP-001.

## Dependency graph

- LOOP-P0-01 -> LOOP-P0-02 -> LOOP-P0-03 -> LOOP-P0-04.
- LOOP-P0-04 -> LOOP-P1-01 -> LOOP-P1-02 -> LOOP-P1-03.
- LOOP-P1-03 -> LOOP-P2-01 -> LOOP-P2-02 -> LOOP-P2-03.
- LOOP-P2-03 -> LOOP-P3-01 -> LOOP-P3-02.
- LOOP-P3-02 -> LOOP-P4-01 -> LOOP-P4-02 -> LOOP-P4-03.
- LOOP-P4-03 -> LOOP-P5-01 -> LOOP-P5-02 -> LOOP-P5-03 -> LOOP-P5-04.

These are **planning dependencies**, not claims that all iterations must be sequential. Independent preparatory work may be done in parallel only under the existing SIGA concurrency/claim rules. Provider/human approvals can be scheduled separately while preserving dependent gates.

## Validation for this documentation-only change

- Inspect paths and consistency across spec/plan/tasks.
- Assert each requirement L-R01 through L-R07 has mapped tasks and acceptance.
- Assert every task ID is unique and every dependency refers to a defined task.
- Confirm no runtime, CI, task queue or provider settings were changed.
- Document open decisions instead of silently editing the constitution or V1 release definition.
