# MM-04 — Godot Duel Vertical Slice

Status: DONE — VERIFIED
Runtime: Godot 4.7.2 stable
Rules version: Alpha 0.1
Schema version: alpha-0.1
RNG version: xorshift32-v1
Depends on: MM-01, MM-02, MM-03
Unlocks: MM-05 Deckbuilder & Collection

## 1. Purpose

Turn the frozen Alpha 0.1 rules and MM-03 contracts into the first executable Godot game slice without moving competitive truth into scenes.

The slice must prove that Mememom is a playable deterministic game before deckbuilder, Forge, UGC, networking, or presentation polish advance.

## 2. User value

A player can launch the Godot project, start a local duel against a deterministic bot, make legal Alpha 0.1 actions, and reach a terminal result. The same seed plus the same ordered intent stream must reproduce the same gameplay event stream.

## 3. Architectural boundary

The runtime is split into:
- `src/domain/`: deterministic rules, state, RNG, validation and bot decisions;
- `src/data/`: contract loading and legality checks;
- `src/presentation/`: Godot scene/UI that renders state and submits intents only;
- `tests/`: headless acceptance and replay regression tests.

Scenes MUST NOT:
- mutate competitive state directly;
- generate competitive random values;
- contain duplicated attack/KO/Trend/win rules;
- interpret arbitrary executable card scripts.

## 4. Functional requirements

### FR-01 Project/runtime
A Godot 4.7.2 project MUST boot headlessly and interactively.

### FR-02 Contract loading
The runtime MUST load MM-03 card and match fixtures as JSON data and fail closed for unsupported schema/rules/RNG versions.

### FR-03 Card legality
At least 20 Alpha test cards MUST be data-driven and pass the MM-03 stat/effect budget validator.

### FR-04 Deterministic RNG
The domain MUST implement xorshift32-v1 exactly, including zero-seed remap, unsigned 32-bit masking, unbiased bounded rejection sampling, monotonically increasing rng_index, and Fisher–Yates shuffle.

### FR-05 Intent boundary
Competitive state changes MUST enter through `PlayerIntent`-shaped commands. Illegal intents MUST produce stable rejection codes with zero state, Trend, event-sequence, and RNG side effects.

### FR-06 Event boundary
Accepted actions MUST emit ordered MatchEvent-shaped dictionaries with monotonically increasing `event_seq`.

### FR-07 Duel loop
The executable slice MUST support setup, Start, Draw, Main and End phases; Queue play; voluntary switch; Reaction play; Format replacement; activated abilities; attacks; pass; KO; Hype; forced replacement; deck-out; no-field; and terminal match state.

### FR-08 Deterministic bot
A local bot MUST choose only from authoritative legal actions and MUST make identical choices from identical state.

### FR-09 Replay
Given the same initial fixture/seed and ordered intent stream, replay MUST produce byte-equivalent normalized event data and identical terminal state.

### FR-10 Presentation
A minimal local duel scene MUST display both players' public state, hand controls for the human player, recent events, and terminal result. Presentation may be intentionally plain; correctness precedes art.

## 5. Acceptance scenarios

Headless regression coverage MUST prove at least:
1. xorshift32-v1 known sequence;
2. deterministic bounded selection and shuffle;
3. zero-seed normalization;
4. legal MM-03 sample card accepted;
5. overbudget MM-03 sample rejected;
6. all 20 Alpha test cards legal;
7. deterministic setup from a seed;
8. opening-hand Mememom repair;
9. Trend cap progression 1 -> 5;
10. legal Queue placement;
11. illegal Queue placement has zero side effects;
12. legal voluntary switch;
13. second voluntary switch rejected;
14. legal attack;
15. attack ends Main;
16. normal KO grants 1 Hype;
17. Headliner KO grants 2 Hype;
18. forced replacement from Queue;
19. forced replacement from hand;
20. no-field terminal loss;
21. deck-out terminal loss;
22. first-to-5-Hype terminal win;
23. simultaneous 5-Hype checkpoint produces draw;
24. deterministic trigger ordering;
25. trigger-generated trigger wave;
26. illegal intent consumes no RNG/event sequence;
27. same replay input yields identical events/state;
28. deterministic bot repeats the same decisions;
29. a complete bot-vs-bot duel terminates;
30. Godot scene boots without parser/runtime errors in headless mode.

## 6. Success criteria

MM-04 is DONE only when:
- all automated headless tests pass on the exact PR head;
- the project boots under Godot 4.7.2;
- at least 20 legal data cards exist;
- deterministic bot-vs-bot simulation reaches a terminal result;
- replay regression is green;
- repository docs advance MM-05 to NEXT;
- no Three.js/client duplication is introduced.

## 7. Non-goals

MM-04 does not include:
- polished card art or final UI;
- online multiplayer;
- accounts;
- deckbuilder/collection;
- Forge;
- public UGC;
- moderation/provenance;
- Canon publication workflow;
- production balance tuning.

## 8. Verification gate

Required merge gates:
- Godot headless parser/import succeeds;
- `tests/run_tests.gd` exits 0;
- exact PR head is green;
- no unresolved human gate remains.

## 9. Verification evidence

The implementation was verified in GitHub Actions with the hardened `Godot headless gates` workflow on Godot 4.7.2.

Verified code-head evidence before documentation closure:
- import/parser gate: PASS;
- headless suite: 194 checks, 0 failures;
- main-scene smoke boot: PASS;
- CI rejects masked GDScript parser/compiler/runtime errors;
- MM-03 CardDefinition and MatchState fixtures are accepted;
- unknown contract/RNG versions fail closed;
- runtime MatchEvent and exported MatchState boundaries carry the Alpha 0.1 contract fields;
- deterministic bot-vs-bot duel terminates;
- replay and trigger-wave regressions are green.

The PR is mergeable only after the final documentation HEAD repeats the same automated gate successfully.
