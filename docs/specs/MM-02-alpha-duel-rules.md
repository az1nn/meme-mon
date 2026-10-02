# MM-02 — Alpha Duel Rules

Status: ACCEPTED FOR IMPLEMENTATION  
Rules version: Alpha 0.1  
Depends on: MM-01 Product Foundation  
Unlocks: MM-03 Card Schema & Balance Budget; MM-04 Godot Duel Vertical Slice

## 1. Purpose

Define a complete, deterministic 1v1 duel contract for the first playable Mememom ruleset.

This specification owns turn structure, legal actions, timing, win/loss checks and randomness semantics. Card data shapes and balance budgets belong to MM-03. Godot scenes and presentation belong to MM-04.

## 2. Binding invariants

- Deck size is exactly 30 cards.
- Deck construction follows MM-01.
- First player to 5 Hype wins.
- Normal Mememom KO grants 1 Hype; Headliner KO grants 2 Hype.
- Rules truth is renderer-independent.
- No free-form response stack or priority system exists in Alpha 0.1.
- Every random result is seedable, ordered and replayable.
- Game state changes only through validated intents and deterministic resolution.

Canonical resolution boundary:

```
intent
-> validate
-> pay/lock costs
-> resolve atomic effect
-> state-based checkpoint
-> emit events
-> collect/resolve triggers
-> state-based checkpoint
```

## 3. Match state

A match MUST track at minimum:

- `rules_version`
- `match_seed`
- `rng_version`
- active player
- turn number
- per-player deck, hand, Active, Queue, Archive and Format zones
- per-player Hype
- per-player current Trend and Trend cap
- per-turn action markers
- pending deterministic triggers
- monotonically increasing event sequence
- monotonically increasing RNG consumption index
- terminal result when one exists

Hidden zones remain hidden to the opponent unless an effect explicitly reveals information.

## 4. Match setup

1. Validate both decks before match creation.
2. Derive the match RNG stream from `match_seed + rng_version`.
3. Shuffle each deck through the canonical RNG stream.
4. Determine first player through the canonical RNG stream unless supplied by a test fixture.
5. Each player draws 5 cards.
6. Opening-hand repair:
   - if a hand contains no Mememom, reveal only the fact that repair is required;
   - return the full hand to the deck;
   - reshuffle through the same RNG stream;
   - draw 5 again;
   - repeat until the hand contains at least one Mememom.
7. Each player receives one voluntary mulligan:
   - choose 0–5 cards from hand;
   - chosen cards return to the deck;
   - shuffle through the canonical RNG stream;
   - draw the same number;
   - if this produces a hand with no Mememom, perform opening-hand repair.
8. Each player selects one Mememom from hand as Active.
9. Each player may place up to 3 additional Mememoms from hand into Queue.
10. Setup placements cost no Trend.
11. The remaining cards stay in hand.
12. Hype starts at 0.
13. Trend cap starts at 1 for each player.
14. Current Trend starts at 0.
15. Turn 1 begins with the selected first player.

No effects trigger during setup unless a later card schema explicitly marks an effect as `setup`.

## 5. Turn structure

Every turn has exactly four phases.

### 5.1 Start

Resolve in order:

1. clear expired "until your next turn" and per-turn markers owned by the active player;
2. increase that player's Trend cap by 1, to a maximum base cap of 5;
3. refill current Trend to that cap;
4. emit `TURN_STARTED`;
5. resolve Start-phase triggers;
6. run a state-based checkpoint.

Exception: on each player's first turn of the match, Trend cap remains 1 instead of increasing to 2.

### 5.2 Draw

1. active player attempts to draw 1 card;
2. if the deck is empty at the required draw, that player immediately loses by deck-out;
3. otherwise move the top card to hand and emit `CARD_DRAWN`;
4. resolve draw-derived triggers;
5. run a state-based checkpoint.

The first player DOES draw on turn 1.

### 5.3 Main

The active player may submit legal actions repeatedly until passing or making an attack.

Baseline legal actions:

- play a Mememom from hand to an empty Queue slot;
- play a Reaction card;
- play or replace a Format card;
- switch Active with a Queue Mememom;
- use an explicitly activated card ability;
- attack with the Active Mememom;
- pass.

General constraints:

- card-defined actions pay the Trend cost defined by MM-03 data;
- costs are validated and locked before resolution;
- an action that cannot fully pay its cost is illegal and produces no state change;
- baseline switch costs 1 Trend;
- baseline voluntary switch is limited to once per turn;
- baseline attack is limited to once per turn;
- an attack ends the Main phase after its full resolution;
- effects may explicitly override baseline limits;
- Reaction cards in Alpha 0.1 are proactive Main-phase actions unless their schema defines an automatic trigger; there is no opponent response window.

Playing a Mememom to Queue requires an empty Queue slot. Queue capacity is 3.

Playing a new Format while one is already present archives the old Format before the new Format enters play, unless an effect explicitly says otherwise.

### 5.4 End

Resolve in order:

1. emit `TURN_ENDING`;
2. resolve End-phase triggers;
3. run a state-based checkpoint;
4. clear "until end of turn" modifiers and active-player action markers;
5. emit `TURN_ENDED`;
6. if the match is not terminal, pass active-player control to the opponent.

## 6. Attack contract

A baseline attack requires:

- the active player has an Active Mememom;
- that Mememom is allowed to attack;
- the player has not already used the baseline attack this turn;
- its attack cost can be paid.

Unless an effect says otherwise, the target is the opposing Active Mememom.

Attack resolution:

1. validate attacker, target and cost;
2. lock/pay cost;
3. emit `ATTACK_DECLARED`;
4. compute damage and effect payload from authoritative state;
5. apply damage/effects atomically;
6. emit resulting damage/effect events;
7. run a state-based checkpoint;
8. resolve resulting triggers;
9. run a second state-based checkpoint;
10. mark baseline attack used;
11. proceed to End if match is not terminal.

Damage persists on a Mememom while it remains in play unless healed or an effect resets it.

## 7. Switching

A voluntary switch exchanges Active with one Queue Mememom.

Baseline rules:

- costs 1 Trend;
- once per turn;
- cannot occur if Queue is empty;
- damage and attached persistent state move with the Mememom;
- switching does not heal;
- switching is not an attack;
- effects may cause forced switches without consuming the baseline voluntary-switch allowance.

If an effect requires a switch but no legal Queue target exists, the switch portion fails without inventing a target. Other independently resolvable parts of the effect still resolve unless the effect declares the switch as a requirement/cost.

## 8. KO and replacement timing

A Mememom is KO-eligible when its remaining HP is 0 or less.

KOs are processed only at state-based checkpoints, never halfway through one atomic effect.

At a checkpoint:

1. identify all KO-eligible Mememoms simultaneously;
2. move them to Archive simultaneously;
3. emit one `MEMEMOM_KO` event per KO in stable event order;
4. award Hype to each opponent based on the KO'd card:
   - normal Mememom: +1;
   - Headliner: +2;
5. evaluate Hype terminal state;
6. if no terminal result exists, owners of an empty Active zone must replace;
7. resolve KO-derived triggers;
8. run another checkpoint.

### 8.1 Forced replacement

If Active is empty and the match is not terminal, the player MUST choose a replacement using this priority:

1. any Mememom already in Queue;
2. otherwise any Mememom in hand, placed directly into Active at no Trend cost.

If neither Queue nor hand contains a Mememom, that player loses by no-field.

A card still hidden in Deck does not count as immediately fieldable.

If both players must replace, the active player chooses first, then the non-active player.

Replacement choices are explicit intents/events so replay is deterministic.

## 9. Terminal checks and precedence

Terminal checks happen only at defined checkpoints or failed mandatory draws.

Precedence:

1. required draw from empty deck;
2. Hype threshold;
3. required-field failure;
4. explicit card effect that declares a win/loss condition.

Rules:

- if exactly one player reaches at least 5 Hype at the same checkpoint, that player wins;
- if both players reach at least 5 Hype in the same checkpoint, the match is a draw;
- if exactly one player fails a mandatory field requirement, that player loses;
- if both players fail the same mandatory field checkpoint, the match is a draw;
- once a terminal result is recorded, no further non-terminal triggers resolve.

Alpha 0.1 permits draws rather than inventing hidden tiebreakers.

## 10. Trigger ordering

There is no interrupt stack.

When an event creates automatic triggers:

1. collect all triggers eligible from that event;
2. active player orders their own simultaneously eligible triggers;
3. non-active player orders their own simultaneously eligible triggers;
4. resolve the active player's ordered triggers, then the non-active player's ordered triggers;
5. after each trigger resolution, run a state-based checkpoint;
6. newly created triggers are collected as the next trigger wave;
7. repeat until no triggers remain or the match becomes terminal.

Mandatory trigger-order choices are recorded as match intents/events.

A trigger may not recursively resolve itself without creating a new event that independently satisfies its condition.

MM-03 MUST provide trigger metadata sufficient to prevent ambiguous timing.

## 11. Randomness contract

All competitive randomness MUST use one match-scoped deterministic RNG service.

Requirements:

- seed supplied at match creation;
- explicit `rng_version`;
- monotonically increasing `rng_index`;
- no direct use of untracked scene/UI randomness for rules;
- shuffle uses deterministic Fisher–Yates driven by the match RNG;
- random target/choice operations consume the same ordered stream;
- every random decision emits enough metadata to replay and audit the result;
- test fixtures may pin seed, first player and exact deck order.

MM-03/MM-04 MUST select and freeze the concrete portable PRNG algorithm before competitive replay compatibility is claimed.

Changing the canonical RNG algorithm requires a new `rng_version`.

## 12. Illegal intent behavior

An illegal player intent:

- changes no competitive state;
- consumes no Trend;
- consumes no RNG value;
- does not advance event sequence for gameplay events;
- returns a machine-readable rejection reason to the client.

Examples include:

- insufficient Trend;
- Queue full;
- second baseline switch;
- second baseline attack;
- invalid target;
- action from the non-active player;
- action submitted outside its legal phase.

## 13. Deterministic examples

### Example A — Normal KO

- Player A has 4 Hype.
- A attacks B's normal Active Mememom.
- Damage reduces it to 0 HP.
- At checkpoint it moves to Archive.
- A gains 1 Hype and reaches 5.
- Match ends immediately with A as winner.
- B does not perform forced replacement.

### Example B — Headliner KO

- Player A has 3 Hype.
- A KOs B's Headliner.
- A gains 2 Hype and reaches 5.
- Match ends before KO triggers that are not terminal-state effects can continue.

### Example C — Simultaneous KO

- An atomic effect reduces both Active Mememoms to 0 HP.
- Both are archived in the same checkpoint.
- Each opponent receives Hype for the opposing KO.
- If neither reaches 5, active player chooses replacement first, then non-active player.
- Trigger processing resumes only after required replacement state is legal.

### Example D — No-field loss

- B's Active is KO'd.
- B has no Mememom in Queue and no Mememom in hand.
- B loses by no-field even if Mememoms remain hidden in B's Deck.

### Example E — Deck-out

- Start/trigger processing completes.
- A enters Draw with an empty Deck.
- A immediately loses by deck-out.
- No synthetic card or skipped draw is allowed.

### Example F — Trigger ordering

- One `CARD_DRAWN` event activates two A triggers and one B trigger.
- A explicitly orders A1 then A2.
- B has only B1.
- Resolution order is A1 -> checkpoint -> A2 -> checkpoint -> B1 -> checkpoint, unless a terminal state ends the match earlier.

### Example G — Replayable randomness

- A seeded effect requests one random Queue target.
- The rules engine consumes the next `rng_index`, selects the target and emits the chosen card identity plus RNG metadata.
- Replaying the same initial state, seed, rules version and intent stream produces the same target.

## 14. Acceptance scenarios

MM-02 is accepted when tests or executable fixtures can be derived unambiguously for all of the following:

1. legal match setup with deterministic shuffle and first-player selection;
2. no-Mememom opening-hand repair;
3. voluntary mulligan;
4. Trend progression from cap 1 to base maximum 5;
5. legal and illegal Queue play;
6. legal and illegal switch;
7. legal attack and one-attack baseline limit;
8. normal KO and Hype award;
9. Headliner KO and Hype award;
10. simultaneous KO;
11. forced replacement from Queue;
12. forced replacement from hand;
13. no-field loss;
14. deck-out loss;
15. reaching 5 Hype;
16. simultaneous Hype draw;
17. active/non-active trigger ordering;
18. trigger-generated trigger wave;
19. illegal intent with zero side effects;
20. seeded RNG replay producing identical events.

## 15. Non-goals

Alpha 0.1 does not define:

- a player-controlled interrupt/response stack;
- priority passing between every effect;
- sideboards;
- best-of-three match structure;
- ranked timer policy;
- spectator protocol;
- networking/reconnect;
- card schema fields or balance formulas;
- final PRNG implementation details;
- public UGC legality.

## 16. Downstream contract

MM-03 MUST encode enough data to express this ruleset without scene-specific logic, including:

- card kind/type/tier;
- Headliner identity;
- Trend costs;
- HP and attacks;
- trigger timing;
- activated abilities;
- targeting;
- deterministic effect primitives;
- version identifiers.

MM-04 MUST implement this rules contract behind a domain boundary and prove it with a local Godot duel, deterministic bot and replayable fixture suite.
