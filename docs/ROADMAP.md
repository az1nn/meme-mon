# Mememom Roadmap

The roadmap is ordered by dependency. SIGA should advance one verified unit at a time.

| ID | Workstream | Status | Exit condition |
|---|---|---|---|
| MM-01 | Product Foundation | DONE | Identity, vocabulary, boundaries and non-goals versioned |
| MM-02 | Alpha Duel Rules | DONE | Complete deterministic Alpha 0.1 rules contract |
| MM-03 | Card Schema & Balance Budget | DONE | Versioned card/deck/event schemas and legal power budget |
| MM-04 | Godot Duel Vertical Slice | DONE | Local duel with 20 test cards and deterministic bot |
| MM-05 | Deckbuilder & Collection | DONE | 30-card validation, filtering, save/load |
| MM-06 | Meme Forge / Godot | NEXT | Upload/crop/name/type/generated stats/private preview in Godot |
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

MM-05 builds on the Alpha 0.1 Godot duel. Deck legality is a domain contract, with correct card_id/edition_id references, format validation, deterministic search, local ownership and versioned saved decks. The native Godot collection/deckbuilder screen can select a legal saved deck for a local duel without moving rules into UI code.

MM-05 was validated against Godot 4.7.2 by 194 MM-04 regression checks and 94 new MM-05 checks with 0 failures, plus import/parser and both scene smoke gates (code HEAD 0876e331; final PR documentation-head CI passed at run 37782362544).

MM-06 is the next dependency unit: add a Godot-only meme Forge that produces private Sandbox previews using constrained MM-03 budgets, without skipping MM-07 rights/provenance and moderation gates.
