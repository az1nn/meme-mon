# MM-05 Tasks

Status: IN PROGRESS

- [x] T01 RECONCILE master, open PRs/issues, branch inventory, latest CI, constitution and canonical SIGA.
- [x] T02 CLASSIFY ADVANCE from verified MM-04 and create isolated MM-05 branch.
- [x] T03 Define MM-05 spec, implementation plan and verification task graph.
- [x] T04 Implement domain deck validation against MM-03 contracts and existing catalog.
- [x] T05 Implement owned collection filtering and editable deck draft model.
- [x] T06 Implement versioned, deterministic local profile save/load with fail-closed corruption/version handling.
- [x] T07 Add Godot collection/deckbuilder scene with edit/filter/status actions.
- [x] T08 Connect selected validated deck to duel entry; invalid decks cannot start matches.
- [x] T09 Add MM-05 headless tests and CI gate, keep all MM-04 regressions green.
- [x] T10 Verify exact PR HEAD (import/parser, headless tests, scene smoke), correct failures.
- [x] T11 Record verification, refresh README/ROADMAP and SIGA handoff, merge only with all gates green.

Constitutional invariants: Godot-only client, portable deterministic rules, versioned data, Sandbox/Canon separation, no masked failed gates.