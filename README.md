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

## Current workstream

MM-02 — Alpha Duel Rules is complete for Alpha 0.1. Next: MM-03 — Card Schema & Balance Budget.

See:
- `docs/specs/MM-01-product-foundation.md`
- `docs/specs/MM-02-alpha-duel-rules.md`
- `docs/ROADMAP.md`
