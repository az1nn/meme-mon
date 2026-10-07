# Mememom Roadmap

The roadmap is ordered by dependency. SIGA should advance one verified unit at a time.

| ID | Workstream | Status | Exit condition |
|---|---|---|---|
| MM-01 | Product Foundation | DONE | Identity, vocabulary, boundaries and non-goals versioned |
| MM-02 | Alpha Duel Rules | DONE | Complete deterministic Alpha 0.1 rules contract |
| MM-03 | Card Schema & Balance Budget | DONE | Versioned card/deck/event schemas and legal power budget |
| MM-04 | Godot Duel Vertical Slice | DONE | Local duel with 20 test cards and deterministic bot |
| MM-05 | Deckbuilder & Collection | NEXT | 30-card validation, filtering, save/load |
| MM-06 | Meme Forge / Godot | PLANNED | Upload/crop/name/type/generated stats/private preview in Godot |
| MM-07 | UGC Provenance & Moderation | PLANNED | Rights metadata, reports and moderation state machine |
| MM-08 | Canon & Set Versioning | PLANNED | Immutable editions and format legality |
| MM-09 | Online Match Protocol | PLANNED | Authoritative intent/event protocol, reconnect and replay |
| MM-10 | Open Source Governance | PLANNED | Code/content licenses and contribution/card-review policy |

## Milestone A — Rules are a game

MM-01 -> MM-04

Target: a complete local duel can finish repeatedly with deterministic results and meaningful decisions.

## Milestone B — Cards become a product

MM-05 -> MM-06

Target: players can build decks and forge private meme cards in the Godot client; web delivery may use Godot Web export.

## Milestone C — Community becomes safe and reproducible

MM-07 -> MM-08

Target: community-created cards can move through provenance, moderation and immutable Canon.

## Milestone D — Competitive online

MM-09 -> MM-10

Target: server-authoritative online play with governance appropriate for an open-source community project.

## Rule

Do not pull MM-06 forward merely because the Forge is visually attractive. The Forge is valuable only when it feeds a proven duel loop.

## Current dependency edge

MM-04 proves the Alpha 0.1 contract as an executable Godot game slice: fail-closed contract ingestion, deterministic intent/event resolution, replayable RNG, legal data cards, trigger waves, bot-vs-bot termination, a local presentation scene and hardened headless CI.

MM-05 must now build deck construction and collection persistence on top of that proven duel boundary without moving rules truth into presentation code.
