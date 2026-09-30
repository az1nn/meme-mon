# MM-01 — Product Foundation

Status: ACCEPTED FOR IMPLEMENTATION  
Phase: Pre-production  
Scope: Product identity, vocabulary, core loop, constraints and non-goals.

## 1. Problem

Traditional TCGs provide collection, deckbuilding and strategic combat, but user-generated meme culture is usually external to the game. Mememom turns that content pipeline into the product: players can forge memes into cards while a rules system preserves fairness, provenance and deterministic play.

## 2. Product statement

**Mememom is an open-source, community-driven creature card game where memes become collectible cards.**

The project may borrow genre conventions such as deckbuilding, card zones, creature combat and turn order, but must maintain original terminology, card frames, rule expression, progression and branding.

## 3. Product pillars

1. **Forge anything into a card** — image + name + type is enough to create a Sandbox card.
2. **Power is system-controlled** — users choose identity, not arbitrary combat strength.
3. **Community Canon** — eligible cards can graduate from Sandbox to immutable canonical editions.
4. **Fast matches** — target session length: 6–12 minutes.
5. **Data-driven rules** — cards are serialized definitions, not bespoke scenes.
6. **Provenance-aware UGC** — source, rights basis and moderation state are first-class data.

## 4. Player fantasy

> Turn internet culture into a living card collection, then duel with it.

The emotional loop is:
**recognize meme -> forge identity -> collect -> build deck -> duel -> share -> canonize**.

## 5. Alpha vocabulary

### Match resource
**Trend** — temporary action resource that refills every turn.

### Score
**Hype** — public victory track. First to 5 Hype wins.

### Board zones
- **Active** — current fighting Mememom.
- **Queue** — up to 3 reserve Mememoms.
- **Hand** — private cards.
- **Deck** — hidden draw pile.
- **Archive** — defeated/discarded cards.
- **Format** — persistent player modifier.
- **Hype Track** — public score.

### Card kinds
- **Mememom** — creature/unit card.
- **Reaction** — one-shot effect.
- **Format** — persistent player-side modifier.

### Initial types
- **Classic** — consistency/recovery.
- **Reaction** — tempo/switching/counters.
- **Brainrot** — cheap chains and bounded volatility.
- **Surreal** — transforms and rule-bending.
- **Wholesome** — protection/healing/card advantage.

## 6. Alpha deck contract

- Exactly 30 cards.
- At least 8 Mememoms.
- Maximum 2 copies of the same card ID.
- Maximum 2 Headliners.
- No dedicated resource cards.
- Target composition:
  - 12–18 Mememom.
  - 8–14 Reaction.
  - 0–6 Format.

These numbers are playtest defaults, not permanent balance guarantees.

## 7. Match objective

A duel is 1v1.

- Normal Mememom KO: +1 Hype.
- Headliner KO: +2 Hype.
- First to 5 Hype wins.
- A player also loses when required to field a Mememom and none is available, or when required to draw from an empty deck.

## 8. Sandbox and Canon

### Sandbox
- immediate creation;
- private/local/custom-room legality;
- may contain unverified provenance;
- may change while unpublished.

### Canon
- immutable edition/version;
- provenance/moderation requirements satisfied;
- balance validation passed;
- legal in competitive formats;
- content-addressed identity.

This separation is mandatory. Competitive play must never depend on mutable user-authored stats.

## 9. Forge contract

The creator may choose:
- image;
- name;
- type;
- flavor/tags;
- attribution/source metadata.

The creator must **not** directly set competitive HP, attack or unrestricted effect power.

A versioned balance system maps:

`type + tier + cost band + ability complexity -> legal stat/effect budget`

## 10. Architecture boundary

### Godot
Godot 4.x is the single client/rendering runtime and owns:
- duel scenes;
- local simulation;
- input/game feel;
- event animation;
- bot/playtest harness;
- Forge UI;
- card preview;
- collection/binder;
- foil/parallax/reveal presentation;
- browser delivery through Godot Web export when required.

Three.js is explicitly outside the active V1 architecture. A second renderer requires a future explicit architecture/constitution amendment.

### Shared contract
Cards, decks and match events use versioned schemas.

The simulation follows:

`player intent -> validation -> deterministic rule resolution -> emitted events -> client animation`

No renderer is allowed to become the source of rule truth.

## 11. Open-source and content boundary

Code licensing and content licensing are separate concerns.

- Repository code may use an OSI-approved license.
- First-party art/audio/UI may use a separate asset license.
- User-uploaded media retains its own rights status.
- Public Canon requires compatible provenance/permission policy.
- Public branding must remain original and must not depend on Pokémon names, card frames, symbols or characters.

## 12. Non-goals for the first playable

The first playable does **not** include:
- real-money economy;
- randomized paid packs;
- peer-to-peer trading;
- ranked matchmaking;
- public UGC ingestion;
- complex response stack/priority;
- full cross-platform account system.

## 13. First success criteria

MM-01 is satisfied when the repository clearly defines:
- what Mememom is;
- its core player fantasy;
- original vocabulary;
- Alpha deck/match assumptions;
- Sandbox vs Canon boundary;
- the Godot-only client/rendering boundary;
- what is explicitly postponed.

## 14. Downstream dependencies

MM-01 unlocks:
- MM-02 Alpha Duel Rules;
- MM-03 Card Schema & Balance Budget;
- MM-04 Godot Duel Vertical Slice.

Any later spec that contradicts these foundations must explicitly revise MM-01 rather than silently drifting.
