CAVEMAN HANDOFF v1

APP: Mememom
WORKSTREAM: MM-02 Alpha Duel Rules -> MM-03 Card Schema & Balance Budget
STATE: Alpha 0.1 deterministic duel contract accepted and merged; repository ready for MM-03
MODE: ADVANCE
CANONICAL SOURCE: GitHub az1nn/meme-mon live state; .specify/memory/constitution.md; active specs; SIGA procedure from az1nn/cpxlabs-admin/.agents/skills/siga/SKILL.md

CURRENT VERSION / HEAD: 27a98a8a63f7e367f7a49ca21f515defeea56208 (MM-02 squash merge; this handoff commit follows)
BASE: master
BRANCH / ENV: master
PR / MR / TASK: PR #3 merged
SPEC / ADR: .specify/memory/constitution.md v1.0.0; docs/decisions/ADR-0001-godot-only-runtime.md; docs/specs/MM-01-product-foundation.md; docs/specs/MM-02-alpha-duel-rules.md

DONE:
- Reconciled live repository before mutation.
- Confirmed Godot-only architecture was already ratified; no duplicate architecture work created.
- Created MM-02 Alpha Duel Rules and accepted it for implementation.
- Defined deterministic setup, opening-hand repair and voluntary mulligan.
- Defined Start / Draw / Main / End phases.
- Froze Trend base-cap progression from 1 to 5 and turn refill semantics.
- Defined Queue capacity, baseline switching and baseline attack limits.
- Defined attack resolution, persistent damage, KO checkpoints and forced replacement.
- Defined Hype scoring, deck-out, no-field losses and terminal precedence.
- Defined deterministic automatic-trigger ordering without a free-form response stack.
- Defined seeded/versioned RNG requirements and zero-side-effect illegal intents.
- Added 20 acceptance scenarios sufficient to drive MM-03 contracts and MM-04 fixtures.
- Updated README and ROADMAP.
- Squash-merged PR #3.

VERIFY:
- PR #3 exact head: 34f25b924c85018f45fa263c180e04b0376ad372.
- PR #3 squash merge commit: 27a98a8a63f7e367f7a49ca21f515defeea56208.
- Feature branch was 4 commits ahead and 0 behind master before merge.
- Changed files: README.md, docs/ROADMAP.md, docs/specs/MM-02-alpha-duel-rules.md.
- No GitHub Actions workflow runs or commit statuses were configured for the exact feature head.
- Documentation was checked against constitution v1.0.0 and MM-01 boundaries.
- Godot remains the only client/rendering runtime; no Three.js implementation path was introduced.

GATES:
- MM-02 documentation gate passed.
- No CI gate exists yet because the repository remains documentation-only.
- Code/testing gates become relevant when MM-03/MM-04 introduce executable contracts/implementation.

BLOCKERS:
- None.

INVARIANTS:
- Mememom remains an original meme TCG, not a Pokémon clone.
- Godot 4.x is the sole active client/rendering runtime for V1.
- Rules truth is deterministic and renderer-independent: intent -> validation -> resolution -> events.
- Alpha 0.1 has no free-form opponent response stack.
- Trend base cap progresses 1 -> 5 and refills at Start.
- Queue capacity is 3.
- Baseline voluntary switch costs 1 Trend and is once per turn.
- Baseline attack is once per turn and ends Main after resolution.
- Normal KO grants 1 Hype; Headliner KO grants 2 Hype; first to 5 Hype wins.
- Required draw from an empty deck loses immediately.
- Empty Active with no Mememom in Queue or hand loses by no-field.
- Competitive randomness must be seeded, versioned and replayable.
- Sandbox content may be mutable/private; Canon editions are immutable and competitively legal only after required gates.
- Players cannot directly author arbitrary competitive power.
- Constitution > active spec > roadmap/handoff > chat/memory when persistent sources conflict.

NEXT:
- Create MM-03 Card Schema & Balance Budget.
- Define versioned schemas for CardDefinition, DeckDefinition, MatchState snapshot/fixture, PlayerIntent and MatchEvent.
- Define effect primitives sufficient to express MM-02 without scene-specific rule logic.
- Define type/tier/cost-band -> legal stat/effect budget.
- Freeze Headliner representation, attack/ability costs, targeting grammar and trigger metadata.
- Select and freeze the portable deterministic PRNG implementation/rng_version.
- Add validation examples and schema fixtures that MM-04 Godot tests can consume.

VERIFY-FIRST:
On next SIGA, fetch master HEAD, open PRs/issues/branches/checks, read .specify/memory/constitution.md, docs/SIGA-HANDOFF.md, docs/ROADMAP.md, ADR-0001, MM-01 and MM-02, then classify exactly RESUME/WATCH/ADVANCE before creating MM-03 work.
