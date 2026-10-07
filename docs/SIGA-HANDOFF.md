CAVEMAN HANDOFF v1

APP: Mememom
WORKSTREAM: MM-03 Card Schema & Balance Budget -> MM-04 Godot Duel Vertical Slice
STATE: Alpha 0.1 portable card/deck/intent/event/state contracts accepted and merged; repository ready for first executable Godot duel slice
MODE: ADVANCE
CANONICAL SOURCE: GitHub az1nn/meme-mon live state; .specify/memory/constitution.md; active specs; SIGA procedure from az1nn/cpxlabs-admin/.agents/skills/siga/SKILL.md

CURRENT VERSION / HEAD: c1bd714102e985865d808a33ed3a664d3eec1dce (MM-03 squash merge; this handoff commit follows)
BASE: master
BRANCH / ENV: master
PR / MR / TASK: PR #4 merged
SPEC / ADR: .specify/memory/constitution.md v1.0.0; docs/decisions/ADR-0001-godot-only-runtime.md; docs/specs/MM-01-product-foundation.md; docs/specs/MM-02-alpha-duel-rules.md; docs/specs/MM-03-card-schema-balance-budget.md

DONE:
- Reconciled live repository, PRs, HEAD, constitution, roadmap, MM-01, MM-02 and previous handoff before mutation.
- Classified ADVANCE with no open PR or blocker.
- Created and accepted MM-03 Card Schema & Balance Budget.
- Added JSON Schema contracts for CardDefinition, DeckDefinition, PlayerIntent, MatchEvent and MatchState.
- Defined constrained effect primitives, target grammar and trigger metadata; arbitrary executable card scripts remain forbidden.
- Made tier the sole Headliner source of truth.
- Defined deterministic balance envelopes and effect-point budgets for Mememom, Reaction and Format cards.
- Froze rng_version xorshift32-v1 with exact 32-bit operations, unbiased bounded rejection sampling and Fisher–Yates shuffle.
- Added legal card, semantic-invalid overbudget card and deterministic match-state fixtures.
- Advanced README and ROADMAP to MM-04.
- Squash-merged PR #4.

VERIFY:
- PR #4 exact head: 83f4cf0f62c3d1e7b7bb6a68116664e551a871e5.
- PR #4 squash merge commit: c1bd714102e985865d808a33ed3a664d3eec1dce.
- Feature branch was 12 commits ahead and 0 behind master before merge.
- Changed files: 11; additions: 1535; deletions: 4.
- All JSON schema/fixture files parsed successfully.
- Deterministic match fixture accounts for exactly 30 cards per player.
- Legal cost-2 Standard sample fits HP and attack envelopes.
- Invalid sample remains structurally valid data while exceeding the cost-1 stat envelope.
- README, ROADMAP and MM-03 agree that MM-04 is NEXT.
- No GitHub Actions workflow runs or commit statuses were configured for the exact PR head or merge commit.
- Godot remains the only client/rendering runtime; no Three.js path was introduced.

GATES:
- MM-03 specification/data-contract gate passed.
- PR mergeability gate passed.
- Documentation/fixture consistency gate passed.
- No CI gate exists yet.
- MM-04 introduces executable Godot code, so headless tests and deterministic replay fixtures become mandatory before its merge.

BLOCKERS:
- None.

INVARIANTS:
- Mememom remains an original meme TCG, not a Pokémon clone.
- Godot 4.x is the sole active client/rendering runtime for V1.
- Rules truth remains renderer-independent: intent -> validation -> deterministic resolution -> events.
- Competitive contracts use schema_version alpha-0.1 and rules_version alpha-0.1.
- Competitive RNG uses rng_version xorshift32-v1 until explicitly versioned forward.
- Cards use constrained data primitives, not arbitrary executable scripts.
- Headliner identity is tier == headliner.
- Sandbox content may be mutable/private; Canon editions remain immutable after publication.
- Players cannot directly author arbitrary competitive power.
- Constitution > active spec > roadmap/handoff > chat/memory when persistent sources conflict.

NEXT:
- Create MM-04 Godot Duel Vertical Slice.
- Bootstrap the Godot 4.x project/runtime if not already present.
- Implement contract loading/validation for MM-03 JSON data.
- Implement deterministic domain state behind PlayerIntent -> validation -> resolution -> MatchEvent.
- Implement xorshift32-v1 exactly and prove replay compatibility.
- Add at least 20 legal test cards passing MM-03 budget checks.
- Implement a deterministic bot and a complete local duel ending by Hype, deck-out or no-field.
- Add headless regression tests derived from MM-02 acceptance scenarios and MM-03 fixtures.
- Keep scenes/presentation free of duplicated competitive rule truth.

VERIFY-FIRST:
On next SIGA, fetch master HEAD, open PRs/issues/branches/checks, read .specify/memory/constitution.md, docs/SIGA-HANDOFF.md, docs/ROADMAP.md, ADR-0001 and MM-01/MM-02/MM-03, then classify exactly RESUME/WATCH/ADVANCE before creating MM-04 work.
