# Mememom Roadmap

The roadmap is ordered by dependency. SIGA should advance one verified unit at a time.

## V1 release goal

V1 is the first public Mememom release in which a player can forge a private Sandbox card, build a legal deck, complete a reproducible duel, and move eligible community content through safe moderation into immutable Canon for authoritative online play. The detailed definition, non-goals and release gates are in [V1 — Community Card Game Release Goal](specs/V1-release-goal.md); its delivery sequence and task graph are in [the V1 plan](plans/V1-release-plan.md) and [V1 tasks](tasks/V1-release-tasks.md).

The current architecture assessment and verified next gate are recorded in the [V1 architecture check-up](reports/V1-architecture-checkup-2026-10-18.md).

| ID | Workstream | Status | Exit condition |
|---|---|---|---|
| MM-01 | Product Foundation | DONE | Identity, vocabulary, boundaries and non-goals versioned |
| MM-02 | Alpha Duel Rules | DONE | Complete deterministic Alpha 0.1 rules contract |
| MM-03 | Card Schema & Balance Budget | DONE | Versioned card/deck/event schemas and legal power budget |
| MM-04 | Godot Duel Vertical Slice | DONE | Local duel with 20 test cards and deterministic bot |
| MM-05 | Deckbuilder & Collection | DONE | 30-card validation, filtering, save/load |
| MM-06 | Meme Forge / Godot | IN REVIEW | Private Forge, constrained preview and local media work; human visual/touch acceptance remains |
| MM-07 | UGC Provenance & Moderation | IN REVIEW | Versioned snapshots, reports and fail-closed moderation reference; human/privacy acceptance remains |
| MM-08 | Canon & Set Versioning | IN REVIEW | Immutable editions, format legality and suspension reference; operator/public-content acceptance remains |
| MM-09 | Online Match Protocol | IN REVIEW | Tested authority reference for intent/event, reconnect and replay; hosted WebSocket and Godot transport remain |
| MM-10 | Open Source Governance | IN REVIEW | Closed-beta policies, DCO and accountability artifacts; public contact/asset-license gates remain |

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

MM-06 implementation is complete through automated domain, navigation, parser/import, scene-smoke and Web/PWA packaging gates. It remains **IN REVIEW** until human visual/touch acceptance confirms the Forge flow on supported targets. It produces private Sandbox previews using constrained MM-03 budgets without skipping MM-07 rights/provenance and moderation gates.

MM-07/MM-08 now provide versioned submission snapshots, moderator audit transitions, Canon publication, format legality and additive suspension records in deterministic reference models. MM-09 exercises authenticated session ownership, canonical deck locking, idempotency, reconnect/event recovery and deterministic replay in a reference authority. These do **not** claim a hosted public WebSocket service, public UGC, or a completed human/operations gate.

## Parallel infrastructure lane — INFRA-01

INFRA-01 provides **cost-aware Godot Web export and optional Cloudflare/Vercel publication** without changing the MM-06 -> MM-10 product dependency order. It is a delivery capability, not a new renderer or a substitute for browser acceptance. See [spec](specs/INFRA-01-smart-web-delivery.md), [plan](plans/INFRA-01-smart-web-delivery.md) and [tasks](tasks/INFRA-01-smart-web-delivery.md).
