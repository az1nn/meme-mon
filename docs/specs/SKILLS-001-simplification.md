# SKILLS-001 — Simplificação da arquitetura de skills

Status: APPROVED_BY_OWNER / IMPLEMENTATION_IN_PROGRESS
Baseline: master cc6924acd61eb44ce796fb80779e0b4824219875 (reconcile live before merge).
Approval: owner explicitly approved six active owners, LORE on demand, REPORTER absorbed by SIGA.

## Goal
Remove duplicate orchestration and weak routing while preserving domain authority, Spec Kit, art approvals, open work, and concurrent executions.

## Target operating model
Six active owners: SIGA (orchestration), DESIGN (gameplay), ARCH (engineering), ART (visual direction), SCENE (Godot presentation), INSPECTOR (independent runtime/visual inspection).
LORE is loaded only for narrative/canon work; it is not an always-on worker.
REPORTER is not a separate owner: its reporting obligation is part of SIGA HANDOFF.
Aliases: ARTIST -> ART; CENA -> SCENE; LENTE -> INSPECTOR; RELATORIO -> SIGA/HANDOFF.
GRILLING is an elicitation workflow within the relevant domain, not a separate task owner.
VERIFY, CI and Spec Kit are processes/evidence, not parallel task owners.

## Authority boundaries
- SIGA: reconcile -> classify -> claim -> dispatch -> verify -> handoff. Canonical protocol remains az1nn/cpxlabs-admin/.agents/skills/siga/SKILL.md; do not copy or modify it here.
- DESIGN: rules, economy, progression, experience intent; no unilateral domain-code ownership.
- ARCH: Godot implementation integrity, deterministic contracts, tests, persistence, security, performance, CI.
- ART: approved visual baselines, assets, variants and human art gates.
- SCENE: Godot UI composition, responsive navigation, HUD, interactions; cannot redefine match rules.
- INSPECTOR: independent actual-runtime evidence, touch, contrast, fidelity and accessibility; cannot self-approve human gates.
- LORE: narrative and fictional canon only when explicitly requested; content-rights/provenance gates still apply.

## Safety invariants
- No change to MM-02–MM-05 deterministic rules, MM-06–MM-10 roadmap ordering, Godot-only constitution, browser-local/in-memory V1, rights/provenance or navigation requirements.
- Preserve ART-002 #9 OPEN and PR #13 draft; do not merge or rewrite their files. Preserve ARTIST-003/004/005, C01 approval, C05 V1 rejection, C05 V3 and V3.1 approvals, rejected references, source checksums and historical gates.
- No renaming/deleting historical docs. Aliases are read-compatible, not competing executors.
- One exclusive task claim per work unit. Claims must be scoped by repository + workstream + task ID; record owner, run ID, base/head SHA, state and expiration. Acquisition/renewal/release require atomic compare-and-swap or equivalent GitHub conditional write; on conflict return WATCH, never steal or force-unlock an active claim. Expired claims require fresh remote reconciliation and explicit recovery evidence before takeover.
- Each specialist returns artifacts/evidence to SIGA. Cross-domain changes require affected domain approval. Human gates never auto-waived.

## Acceptance criteria
1. Six active owners and LORE-on-demand documented without a duplicate SIGA implementation.
2. REPORTER responsibilities included in SIGA handoff; aliases documented as compatibility mapping.
3. Domain conflicts and routing are unambiguous, no specialist may create a second claim for a claimed task.
4. Simulated simultaneous claims: exactly one succeeds; the other WATCHes. Stale owner cannot release/overwrite a newer claim. Expired recovery reconciles remote PR/CI first.
5. ART-002 #9, PR #13 and all approvals remain intact.
6. Spec/plan/tasks and evidence reviewed; exact-head checks required before protected merge. Documentation alone does not establish executable concurrency safety.

## Non-goals
No rewrite of canonical SIGA, gameplay, art assets, CI workflow, PR #13, or branch protections. No claim that a GitHub-only textual convention is an atomic lock.
