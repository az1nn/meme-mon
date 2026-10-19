# V1 release plan

Status: PLANNED  
Authority: `docs/specs/V1-release-goal.md`, `.specify/memory/constitution.md`, `docs/ROADMAP.md`.

## Delivery sequence

| Phase | Scope | Entry condition | Exit condition |
|---|---|---|---|
| 0 — Local Alpha | MM-01 to MM-05 | complete | Deterministic local duel and validated deck/collection are proven |
| 1 — Personal creation | MM-06 + INFRA-01 packaging acceptance | Phase 0 evidence remains green | Private Forge creates constrained Sandbox previews; supported Web/Android client acceptance passes |
| 2 — Community safety | MM-07, MM-08 | Sandbox identity and versioning exist | Provenance, moderation, immutable editions and format legality are enforced |
| 3 — Competitive release | MM-09, MM-10 | Canon trust boundary is proven | Authoritative online play, reconnect/replay and open-source governance are release-ready |
| 4 — Release candidate | V1 integration | Phases 1–3 complete | All V1 success criteria have exact-head automated and human evidence |

## Planning rules

1. Create a bounded Spec Kit specification, implementation plan and task graph for each unfinished MM workstream before code begins.
2. Complete one dependency-ordered product workstream at a time; INFRA-01 may support it but cannot substitute for product acceptance.
3. Add acceptance fixtures at the contract boundary before UI polish when a capability affects competitive truth or persistence.
4. Keep Web PWA and Android as package targets for Godot output. Do not duplicate Forge, deckbuilder or duel behavior in JavaScript.
5. Do not mark a phase complete from CI alone when its exit condition includes browser/mobile, visual, rights or moderation acceptance.

## Release decisions to make during the relevant workstream

- MM-06: supported image formats, local storage limit and private-card export policy.
- MM-07: provenance declaration, report categories, moderator roles, appeal/retention policy.
- MM-08: Canon identifier and format rotation policy.
- MM-09: account identity, hosting/operator, authentication and data retention policy.
- MM-10: code license, asset license, contribution license agreement/DCO and card-review governance.

These are deliberately deferred decisions, not implicit product behavior.

