# meme-mon

Open-source, community-driven meme TCG built with Godot.

## Product thesis

Mememom is not a clone of Pokémon. It is an original digital card game where memes become collectible creatures through a player-facing Forge. Players choose identity and flavor; the game enforces legal power budgets, versioned rules, provenance and competitive legality.

## Core loop

1. Collect or forge Mememom cards.
2. Build a 30-card deck.
3. Duel for Hype using Trend as the turn resource.
4. Earn/unlock cards and improve the collection.
5. Submit eligible Sandbox creations for Community Canon.

## Alpha rules snapshot

- 1v1 duel.
- First player to 5 Hype wins.
- Normal KO: +1 Hype.
- Headliner KO: +2 Hype.
- 30-card decks.
- Max 2 copies of the same card ID.
- Zones: Active, Queue, Hand, Deck, Archive, Format, Hype.
- Resource: Trend, base cap progresses from 1 to 5 and refills each turn.
- Queue capacity: 3.
- Baseline voluntary switch: 1 Trend, once per turn.
- Baseline attack: once per turn and ends Main after resolution.
- Required draw from an empty Deck loses immediately.
- An empty Active with no Mememom in Queue or hand loses by no-field.
- Automatic triggers resolve deterministically without a free-form response stack.
- Competitive randomness is seeded, versioned and replayable.
- Card kinds: Mememom, Reaction, Format.
- Types: Classic, Reaction, Brainrot, Surreal, Wholesome.

## Data contract snapshot

MM-03 freezes the Alpha 0.1 portable competitive contract:

- JSON Schema contracts for CardDefinition, DeckDefinition, PlayerIntent, MatchEvent and MatchState.
- Card effects are a constrained data AST; arbitrary executable card scripts are not allowed.
- Headliner status is represented only by `tier: headliner`.
- Balance legality is computed from cost-band stat envelopes and effect complexity points.
- Canonical RNG is `xorshift32-v1` with rejection-sampled bounded values and Fisher–Yates shuffle.
- Normative fixtures live in `contracts/fixtures/`.

## Architecture direction

- **Godot 4.x is the single client/rendering runtime**.
- Godot owns duel, Forge, card previews, collection/binder and visual effects.
- Browser delivery, if required, uses Godot Web export.
- **Three.js is not part of the active V1 architecture.**
- Backend/services remain free to use an appropriate independent stack.
- Rules boundary: clients submit intents; domain logic validates and emits deterministic events.

## Spec Kit authority

- `.specify/memory/constitution.md`
- `docs/decisions/ADR-0001-godot-only-runtime.md`

## Executable Alpha slice

MM-04 turns the frozen Alpha 0.1 rules into an executable Godot 4.7.2 vertical slice:

- deterministic `xorshift32-v1` domain RNG;
- fail-closed MM-03 contract ingestion under `src/data/`;
- authoritative intent -> validation -> resolution -> event flow under `src/domain/`;
- 20 legal data-driven Alpha test cards;
- Queue, Reaction, Format, activated ability, attack, KO, Hype, replacement and terminal flows;
- deterministic trigger waves and replay checks;
- deterministic local bot and a minimal playable Godot scene;
- hardened headless CI that fails on parser/compiler/runtime script errors.

Run the regression suite with:

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Current workstream

MM-05 — Deckbuilder & Collection is implemented and headless-verified. Next: MM-06 — Meme Forge / Godot.

MM-05 adds:
- DeckDefinition alpha-0.1 validation: exactly 30 cards, minimum 8 Mememom, maximum 2 copies per card ID across editions, maximum 2 Headliners, and format/version/owned-edition checks.
- A local collection with stable search/filters, editable named decks, selection and persistence in `user://mememom/profile.json`.
- A native Godot collection screen accessible from the duel via **Collection / Deckbuilder**. Choose **Play selected deck** to persist/validate a legal deck for the local duel.
- Explicit rejection of corrupt or unsupported local profiles. Alpha fixture cards remain local test content, not Canon.
- Headless regression suite `tests/run_mm05_tests.gd`, required alongside the original MM-04 suite.

See:
- `docs/specs/MM-01-product-foundation.md`
- `docs/specs/MM-02-alpha-duel-rules.md`
- `docs/specs/MM-03-card-schema-balance-budget.md`
- `docs/specs/MM-04-godot-duel-vertical-slice.md`
- `docs/specs/MM-05-deckbuilder-collection.md`
- `docs/reports/MM-05-verification.md`
- `contracts/schemas/`
- `contracts/fixtures/`
- `docs/ROADMAP.md`
