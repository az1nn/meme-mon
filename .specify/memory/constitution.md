# Mememom Engineering Constitution

**Version:** 1.0.0  
**Ratified:** 2026-09-30  
**Project:** Mememom (`az1nn/meme-mon`)

This constitution governs Spec-Driven Development in this repository. It defines binding engineering constraints for specifications, plans, tasks and implementation.

## I. Repository Reality Is Authoritative

Every engineering session MUST reconcile the live repository before mutation: repository identity, default branch, exact working/base state, open pull requests, CI/checks, relevant specs, architecture decisions and repo-local handoffs.

Trust order:

```text
LIVE REPOSITORY / CI
> RATIFIED CONSTITUTION
> ACTIVE FEATURE SPEC + PLAN + TASKS
> REPOSITORY HANDOFFS / ROADMAP / ADRs
> CHAT OR MODEL MEMORY
```

Stale conversation context MUST NOT override live repository state.

## II. Feature Work Is Spec-First

A new product capability MUST have a bounded specification before implementation begins.

A feature specification MUST define:
- user value;
- functional requirements;
- acceptance scenarios;
- success criteria;
- non-goals;
- affected architectural boundaries.

Implementation work MUST trace back to the active specification and its task graph.

Defect fixes may use a smaller path only when they restore already-specified behavior without adding a new capability.

## III. Godot Is the Single Client and Rendering Runtime

For the current product architecture, **Godot 4.x is the sole client runtime and rendering environment for Mememom**.

This principle applies to:
- duel scenes;
- card rendering;
- Forge UI;
- collection/binder presentation;
- animations, foil/parallax/reveal effects;
- desktop/mobile client targets;
- browser delivery through Godot Web export when a web target is required.

**Three.js is not part of the active architecture.** No parallel Three.js renderer, Forge, collection viewer or duplicated browser client SHOULD be introduced.

Rationale:
- the project now has sufficient Godot capability to implement the intended interaction and presentation directly;
- one runtime reduces duplicated rendering logic, asset pipelines, UI behavior and debugging surface;
- card presentation and duel presentation remain visually and technically coherent;
- a single client technology lowers maintenance cost during the V1 learning and iteration phase.

A future renderer or client technology MAY be introduced only through an explicit constitution amendment or architecture decision that demonstrates a concrete capability Godot cannot reasonably satisfy.

This rule does not prohibit a backend/API, database, build tooling or non-rendering service implemented with another suitable technology.

## IV. Rules Truth Is Deterministic and Renderer-Independent

Game rules MUST live behind deterministic domain logic and MUST NOT be encoded only in scene/UI behavior.

The canonical interaction boundary is:

```text
player intent
-> validation
-> deterministic rule resolution
-> emitted events
-> Godot presentation/animation
```

Scenes MAY render state and submit commands, but MUST NOT duplicate competitive rule truth.

Randomness, when introduced, MUST be seedable and replayable.

## V. Cards and Competitive State Are Data-Driven and Versioned

Competitive cards, decks, rules versions and match events MUST use explicit schemas or equivalent versioned contracts.

Published competitive card editions MUST be immutable.

User-facing content creation MAY change flavor and identity, but competitive power MUST remain constrained by system-owned balance rules rather than unrestricted player-authored stats.

Persistent schema changes MUST be versioned and migration-aware.

## VI. Sandbox and Canon Are Separate Trust Domains

Sandbox content MAY be mutable, private and provenance-unverified.

Canon content used in competitive formats MUST satisfy the project-defined gates for:
- immutable edition identity;
- provenance/rights metadata;
- moderation;
- balance validation;
- format legality.

No feature may silently promote mutable Sandbox data into competitive Canon.

## VII. Open Source Code and Meme Content Are Separate Licensing Domains

Repository code licensing MUST NOT be assumed to relicense uploaded images, memes, audio or other third-party content.

Specifications involving user-generated content MUST preserve explicit provenance and rights metadata.

Public branding and presentation MUST remain original and MUST NOT depend on Pokémon names, characters, proprietary card frames, symbols or other protected branded expression.

## VIII. Verification Gates Completion

A unit of work is not complete because files exist.

Completion requires evidence appropriate to the change:
- spec/document consistency for documentation-only work;
- relevant automated tests for code;
- Godot headless tests where applicable;
- deterministic rule regression coverage;
- export/build verification when the affected feature targets packaged or web delivery;
- exact-head verification before merge.

Failed validation MUST NOT be masked or reclassified as success.

## IX. Small Coherent Waves Over Parallel Architectures

Prefer the smallest independently reviewable capability that advances the roadmap.

Do not introduce a second implementation path merely for optionality. Architectural alternatives belong in research/decision records until explicitly selected.

When scope or architecture materially changes, update the constitution/spec/roadmap instead of allowing implementation to drift.

## Governance

- Amendments require an explicit repository change with rationale.
- Breaking changes to binding principles increment the major version.
- New binding principles or materially expanded obligations increment the minor version.
- Clarifications that do not change obligations increment the patch version.
- SIGA MUST reconcile this constitution before selecting RESUME, WATCH or ADVANCE.
- Active specifications MUST conform to this constitution; where they conflict, the constitution wins until the specification is amended.
