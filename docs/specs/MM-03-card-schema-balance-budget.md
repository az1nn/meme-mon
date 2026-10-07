# MM-03 — Card Schema & Balance Budget

Status: ACCEPTED FOR IMPLEMENTATION  
Schema version: alpha-0.1  
Rules version: Alpha 0.1  
Depends on: MM-01 Product Foundation; MM-02 Alpha Duel Rules  
Unlocks: MM-04 Godot Duel Vertical Slice

## 1. Purpose

Define portable, versioned data contracts for cards, decks, deterministic match fixtures, player intents and match events, plus a bounded balance model that can express MM-02 without moving competitive rule truth into Godot scenes.

The contracts in `contracts/schemas/` are normative machine-readable companions to this spec. Fixtures in `contracts/fixtures/` are normative examples.

## 2. Contract principles

- Competitive data is explicit, versioned and serializable.
- Published Canon editions are immutable.
- A card definition contains data and a constrained effect AST; it never contains executable script.
- Godot scenes render state and submit intents; they are not the source of rules truth.
- Unknown schema versions, effect primitives, trigger events or target selectors fail closed.
- Illegal intents have zero competitive side effects, consume no Trend and consume no RNG.
- All identifiers used by deterministic replay are stable strings.
- JSON object key order is never semantically significant; ordered arrays are significant.

## 3. Version identifiers

Every persisted competitive contract MUST carry the relevant version identifier.

- `schema_version`: `alpha-0.1`
- `rules_version`: `alpha-0.1`
- `rng_version`: `xorshift32-v1`

A reader MUST reject a major/unknown contract version it cannot interpret. Migration of mutable Sandbox data is allowed; published Canon editions are migrated only by producing a new edition.

## 4. Identity model

### 4.1 Card identity

- `card_id`: stable logical card identity, e.g. `mememom.classic.keyboard-cat`.
- `edition_id`: immutable published edition identity, e.g. `mememom.classic.keyboard-cat@alpha.1`.
- Sandbox drafts MAY omit `edition_id`.
- Competitive/Canon definitions MUST include `edition_id`.
- Deck copy limits use `card_id`, not `edition_id`.

### 4.2 Tier and Headliner

`tier` is one of:
- `standard`
- `headliner`

Headliner status is derived only from `tier == headliner`; no duplicate boolean is canonical. Deck validation enforces at most 2 Headliners.

## 5. CardDefinition

The canonical schema is `contracts/schemas/card-definition.schema.json`.

Common fields:
- schema/version identity;
- immutable IDs where applicable;
- `kind`: `mememom | reaction | format`;
- `type`: `classic | reaction | brainrot | surreal | wholesome`;
- `tier`;
- `trend_cost` from 0 to 5;
- display metadata;
- constrained effect data.

### 5.1 Mememom payload

A Mememom defines:
- `hp`;
- exactly one baseline `attack`;
- zero or more automatic `triggers`;
- zero or more `activated_abilities`.

An attack defines:
- `trend_cost`;
- base `damage`;
- optional deterministic effect primitives.

### 5.2 Reaction payload

A Reaction is a proactive Main-phase card in Alpha 0.1 unless represented by an automatic trigger in a future schema version. It defines a deterministic ordered list of effect primitives.

### 5.3 Format payload

A Format defines:
- effects applied while the Format is present;
- optional automatic triggers;
- no hidden executable behavior.

Only one Format may occupy a player's Format zone under MM-02.

## 6. Effect AST

Effects are ordered arrays. The Alpha 0.1 primitive set is deliberately small:

1. `deal_damage`
2. `heal`
3. `draw`
4. `gain_trend`
5. `modify_stat`
6. `force_switch`
7. `move_card`
8. `set_action_allowance`

No primitive may execute arbitrary code, evaluate user-authored expressions or recurse directly.

### 6.1 Target grammar

A target is data with:
- `side`: `self | opponent`;
- `zone`: `active | queue | hand | archive | format`;
- `selection`: `self | chosen | random | all`;
- optional `count`;
- optional filters for `kind`, `type` and `tier`.

Hidden-zone targeting is legal only when the primitive explicitly supports it. A `random` selector consumes the canonical RNG stream.

### 6.2 Trigger metadata

Automatic triggers declare:
- `event`;
- optional phase restriction;
- optional deterministic condition;
- ordered effects;
- optional `once_per_turn`.

Alpha 0.1 trigger events:
- `turn_started`
- `turn_ending`
- `card_drawn`
- `entered_play`
- `attack_declared`
- `damage_dealt`
- `mememom_ko`
- `switched_in`

Simultaneous trigger ordering follows MM-02 and is represented by explicit player ordering intents when a choice exists.

## 7. DeckDefinition

The canonical schema is `contracts/schemas/deck-definition.schema.json`.

A legal Alpha 0.1 deck MUST satisfy:
- exactly 30 card references;
- at least 8 Mememom cards;
- at most 2 copies of the same `card_id`;
- at most 2 Headliners;
- all referenced competitive editions exist and are legal for the declared format/rules version.

The 12–18 Mememom, 8–14 Reaction and 0–6 Format ranges remain playtest targets, not legality constraints.

## 8. PlayerIntent

The canonical schema is `contracts/schemas/player-intent.schema.json`.

Intent envelope:
- `intent_id`;
- `match_id`;
- `player_id`;
- `expected_event_seq`;
- `kind`;
- kind-specific payload.

Alpha 0.1 intent kinds:
- `mulligan`
- `select_active`
- `place_queue`
- `play_card`
- `switch_active`
- `activate_ability`
- `attack`
- `order_triggers`
- `choose_replacement`
- `pass`

An intent is accepted only if `expected_event_seq` matches authoritative state and all MM-02 legality checks pass.

## 9. MatchEvent

The canonical schema is `contracts/schemas/match-event.schema.json`.

Every gameplay event contains:
- `event_seq`, strictly increasing from 1;
- `event_type`;
- `actor_player_id` when relevant;
- deterministic payload;
- `rules_version`;
- optional RNG audit metadata.

Minimum event vocabulary:
- `TURN_STARTED`
- `CARD_DRAWN`
- `CARD_PLAYED`
- `TREND_SPENT`
- `ACTIVE_SWITCHED`
- `ATTACK_DECLARED`
- `DAMAGE_APPLIED`
- `HEAL_APPLIED`
- `MEMEMOM_KO`
- `HYPE_CHANGED`
- `TRIGGER_ORDERED`
- `REPLACEMENT_REQUIRED`
- `REPLACEMENT_CHOSEN`
- `RNG_RESULT`
- `TURN_ENDING`
- `TURN_ENDED`
- `MATCH_ENDED`

Rejected intents return a rejection result and MUST NOT produce gameplay events.

## 10. MatchState fixture contract

The canonical schema is `contracts/schemas/match-state.schema.json`.

A serializable match fixture includes:
- version identifiers and seed;
- `rng_state` and `rng_index`;
- active player, phase and turn;
- complete ordered zone contents for both players;
- Trend/Hype;
- per-turn markers;
- pending trigger descriptors;
- next `event_seq`;
- optional terminal result.

Fixtures may expose otherwise hidden zones because they are test artifacts, not player views.

## 11. Portable deterministic RNG

Alpha 0.1 freezes `rng_version = xorshift32-v1`.

### 11.1 State

- Internal state is one unsigned 32-bit integer.
- Seed is normalized to unsigned 32-bit.
- Seed 0 is remapped to hexadecimal `6D2B79F5`.
- After every operation, state is masked to 32 bits.

### 11.2 next_u32

Given state `x`:

    x = x XOR ((x << 13) AND 0xFFFFFFFF)
    x = x XOR (x unsigned-right-shift 17)
    x = x XOR ((x << 5) AND 0xFFFFFFFF)
    state = x AND 0xFFFFFFFF
    return state

Every produced `next_u32` value increments `rng_index`, including values discarded by bounded rejection sampling.

### 11.3 bounded(n)

For integer `n > 0`:
- `limit = floor(2^32 / n) * n`;
- consume `next_u32` until `value < limit`;
- return `value mod n`.

This avoids modulo bias.

### 11.4 shuffle

Canonical shuffle is Fisher–Yates from the last element down to index 1 using `bounded(i + 1)`.

A replay is compatible only when `rules_version`, `rng_version`, initial fixture and ordered intent stream match.

## 12. Balance budget

The V1 objective is bounded, inspectable power — not perfect balance before playtesting.

### 12.1 Mememom stat envelope

For Standard Mememom by `trend_cost`:

| Cost | HP min | HP max | Attack damage max | Ability points max |
|---:|---:|---:|---:|---:|
| 1 | 30 | 50 | 20 | 2 |
| 2 | 40 | 70 | 30 | 3 |
| 3 | 60 | 90 | 40 | 4 |
| 4 | 80 | 110 | 50 | 5 |
| 5 | 100 | 140 | 70 | 6 |

Headliner adds:
- +20 to legal HP maximum;
- +10 to legal baseline attack damage maximum;
- +1 ability point maximum.

The lower HP bound is unchanged. A Headliner still awards 2 Hype when KO'd.

### 12.2 Ability points

Effects consume points:

| Primitive | Cost |
|---|---:|
| deal_damage | 1 per 10 damage, rounded up |
| heal | 1 per 20 healing, rounded up |
| draw | 2 per card |
| gain_trend | 3 per Trend |
| modify_stat | 1 per 10 absolute stat delta, rounded up |
| force_switch | 2 |
| move_card | 2 per card |
| set_action_allowance | 3 |

Modifiers:
- automatic trigger overhead: +1;
- trigger on `card_drawn`, `damage_dealt` or `mememom_ko`: +1 additional complexity;
- random target: +1;
- `all` target: +2;
- once-per-turn restriction: -1, minimum total ability cost 1;
- explicit Trend cost on activated ability: -1 per Trend paid, minimum total ability cost 1.

The validator sums all ability/trigger effect costs. A card is illegal if it exceeds its maximum ability points or any stat envelope.

### 12.3 Reaction and Format budget

Reaction budget:
- cost 0: 1 point;
- cost 1: 3 points;
- cost 2: 5 points;
- cost 3: 7 points;
- cost 4: 9 points;
- cost 5: 11 points.

Format budget:
- same base table as Reaction;
- persistent static effects add +1 complexity per affected stat/allowance;
- triggered Format effects use the same trigger overhead as Mememom.

Headliner tier is invalid for Reaction and Format in Alpha 0.1.

## 13. Type identity

Types influence generation preference, not hidden rules exceptions. The validator MAY use these generation weights while legality remains budget-based:

- Classic: recovery/consistency preference.
- Reaction: switching/tempo preference.
- Brainrot: low-cost chains and bounded randomness preference.
- Surreal: transforms/rule-shaping preference.
- Wholesome: healing/protection/card-advantage preference.

A type never grants free power outside the same budget.

## 14. Validation order

Validation MUST be deterministic and fail closed:

1. parse JSON;
2. validate schema version;
3. validate JSON Schema;
4. resolve referenced editions;
5. enforce rules-version legality;
6. compute balance budget from effect AST;
7. validate deck aggregate constraints;
8. only then admit data to competitive simulation.

Validation errors use stable machine-readable codes.

Minimum codes:
- `UNKNOWN_SCHEMA_VERSION`
- `SCHEMA_INVALID`
- `UNKNOWN_EFFECT_PRIMITIVE`
- `UNKNOWN_TRIGGER_EVENT`
- `UNKNOWN_CARD_EDITION`
- `CARD_BUDGET_EXCEEDED`
- `CARD_STAT_OUT_OF_RANGE`
- `DECK_SIZE_INVALID`
- `DECK_MIN_MEMEMOM`
- `DECK_COPY_LIMIT`
- `DECK_HEADLINER_LIMIT`
- `FORMAT_ILLEGAL_CARD`

## 15. Normative fixtures

- `contracts/fixtures/mm-03-card-keyboard-cat.json`: legal Standard Mememom.
- `contracts/fixtures/mm-03-match-state.json`: deterministic fixture compatible with MM-04 tests.

MM-04 MUST be able to load the fixture data without scene-specific translation of competitive semantics.

## 16. Acceptance scenarios

MM-03 is accepted when the repository proves all of the following structurally:

1. CardDefinition is versioned and represents all three card kinds.
2. Headliner representation has one canonical source.
3. DeckDefinition can express and validate the MM-01 deck contract.
4. MatchState fixture captures every deterministic field required by MM-02.
5. PlayerIntent covers every Alpha 0.1 player choice.
6. MatchEvent can encode the MM-02 event stream.
7. Targeting is data-driven and bounded.
8. Trigger timing is explicit and non-ambiguous.
9. No schema permits arbitrary executable code.
10. Unknown primitives/versions fail closed.
11. xorshift32-v1 is specified bit-for-bit.
12. bounded random selection is unbiased through rejection sampling.
13. Fisher–Yates shuffle is reproducible.
14. Balance envelopes are machine-computable.
15. Headliner power and +2 Hype risk are explicit.
16. Reaction/Format budgets are bounded.
17. A legal sample card passes the stated budget manually.
18. A deterministic match-state fixture can seed MM-04 tests.
19. Godot remains presentation/client runtime, not schema authority.
20. No Three.js implementation path is introduced.

## 17. Non-goals

MM-03 does not implement:
- Godot duel scenes;
- networking;
- persistence service/database;
- moderation/provenance workflow;
- final production balance;
- scripting language for cards;
- user-authored formulas;
- cryptographically secure randomness.

## 18. Downstream contract

MM-04 MUST:
- load these contracts as data;
- implement domain-state transitions behind an intent/event boundary;
- implement xorshift32-v1 exactly;
- prove deterministic replay with fixtures;
- ship at least 20 test cards that all pass MM-03 legality checks;
- keep visual scenes free of duplicated competitive rule truth.
