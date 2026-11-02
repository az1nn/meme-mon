# LOOP-001 — Mememom chat-to-iteration roadmap specification

**Status:** DOCUMENTED / NOT EXECUTED
**Source:** Chat decisions consolidated on 2026-11-01 (America/Sao_Paulo), followed by the instruction to preserve all roadmap items as Spec Kit tasks for the existing Pi/Ralph environment.
**Authority:** .specify/memory/constitution.md; docs/ROADMAP.md; docs/specs/V1-release-goal.md; docs/specs/INFRA-01-smart-web-delivery.md.
**Companion artifacts:** docs/plans/LOOP-001-mememon-roadmap.md and docs/tasks/LOOP-001-mememon-roadmap.md.

## Problem and desired outcome

The project has deterministic game systems, a passing Godot Web artifact pipeline, and an existing Pi/Ralph execution structure, but lacks a validated, currently deployed Vercel game build and a unified, iteration-ready sequence for the player-visible milestones. A previous roadmap discussion selected deployment validation before additional game features.

**User decision:** Vercel build/playability is first priority, followed by gameplay features. All P0–P5 roadmap content must be documented for subsequent Pi/Ralph iterations through a skill named **loop**. The skill's ONLY responsibility is to transcribe supplied chat context into Spec Kit specs, plans and tasks; the existing Pi implementation must not be recreated.

**Planning effect:** We preserve the existing public V1 contract and add a sequence for an **interim offline-first playable Web milestone**. This is NOT a silent downgrade of the current public V1 goal, which also requires community operations and authoritative online play. Any formal release-scope change requires a separate approved decision/ADR.

## Evidence snapshot, not an execution claim

Recorded at the source reconciliation on 2026-11-01:
- GitHub master HEAD 4918a2f6f86c9ed4f67a93213a42523e5a41153d.
- Both Godot headless and Web export workflows completed successfully for that HEAD; Web delivery run: https://github.com/az1nn/meme-mon/actions/runs/41372697914.
- In that run, the Vercel deployment job was **SKIPPED**; no live deployment of this HEAD was confirmed.
- PR #25 (CI Godot), #26 (Vercel 404/preview delivery), #27 (CardVisualFrame component), and #28 (SIGA Central documentation) have merged. Merged component code is not proof of final art integration or human acceptance.
- Existing Vercel project meme-mon last showed a READY production deployment associated with old commit 153b171e0f1f64048d0ae0faa2e1403c78c7fe58, not the HEAD above; this is not evidence that the root loads the current game.
- docs/ROADMAP.md records MM-01 to MM-05 as DONE, MM-06 to MM-10 as IN REVIEW. Human acceptance, Android install, public provenance/moderation, hosted online infrastructure and release gates remain open.
- Current .agent/tasks.json contains PR-027 and PR-028 with passes=false even though both PRs are merged. The existing runtime queue must be reconciled by its owner in a separate authorized operation; this skill must not rewrite it.
- The earlier ART proposal FIT A was rejected; C01 and C05 V3/V3.1 approvals must be preserved. No assumption that missing approved PNG source binaries have been committed.

These facts are a dated snapshot, not a promise of current runtime/provider status. Future Pi execution must re-fetch the exact HEAD and external evidence.

## Requirements

| ID | Requirement | Milestone | Acceptance outcome |
|---|---|---|---|
| L-R01 | Make a preview of the current tested Godot artifact available through controlled Vercel publication | P0 | Unique preview URL, exact SHA match, correct HTML/JS/PCK/WASM, playable browser smoke |
| L-R02 | Validate one complete offline/local player loop in Web desktop and touch mobile | P1 | Legal deck -> local bot duel -> terminal result -> persistence/restart |
| L-R03 | Finish approved art-to-runtime integration, preserving rejected FIT A and original cartoon/graffiti direction | P2 | C01/C05 V3.1 fit, CardVisualFrame, responsive runtime captures and human ART acceptance |
| L-R04 | Complete human/touch acceptance of the already implemented private Meme Forge (MM-06) | P3 | Private Sandbox preview and local asset handling, preserved balance/provenance boundaries |
| L-R05 | Verify PWA install/update/offline and supported Web accessibility; track Android as a separate packaging lane | P4 | Browser-based acceptance evidence; Android remains a distinct gate of full public V1 |
| L-R06 | Progress through community safety, immutable Canon, online authority, security/governance only after offline experience is usable | P5 | MM-07 through MM-10 operational, hosting, privacy, licensing, human and exact-head gates |
| L-R07 | Provide iteration-sized work with dependency/acceptance traceability for existing Pi/Ralph | All | Every planned task has source, prerequisites, deliverable, evidence, stop criteria and ownership |

## Guardrails and non-goals

- One Godot 4.x game renderer; no duplicate React/Three.js client and no forked Android gameplay.
- Deterministic rules independent of presentation; no client-side competitive truth.
- Private Sandbox never auto-promotes to Canon.
- Do not overwrite accepted art, claim the rejected FIT A, or infer copyright clearance.
- The Vercel production environment stays approval-gated. A green workflow or GitHub artifact is not a published game; a READY deployment is not proof of browser acceptance.
- No automatic merge, public upload, online release or signed Android release through this documentation.
- Do not modify runner/provider/model/loop configuration, .agent/tasks.json or runtime implementation. The existing Pi/Ralph pipeline owns importing and executing tasks.

## Specification-level acceptance

1. P0 precedes the remaining player-visible work.
2. Every phase P0–P5 is captured without skipping or merging distinct human gates into automated tests.
3. Existing implemented capabilities are framed as verification/integration tasks where appropriate, not reimplementation.
4. All tasks have a stable ID, dependencies, observable deliverable and clear stop conditions.
5. Existing V1 commitments remain authoritative unless explicitly amended.
6. This work only creates documentation and the reusable chat-to-Spec-Kit skill.
