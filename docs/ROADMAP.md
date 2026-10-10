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

## V1 deployment constraint — browser-local / in-memory

**Product decision (2026-10-08):** V1 starts as a **Godot Web game that runs locally in the browser, or entirely in session memory**. Neither authentication nor any gameplay API/database/server is allowed to gate initial solo play or completion of a match. See [ADR-0002](decisions/ADR-0002-browser-local-first-v1.md).

- **V1 core:** local deterministic rules, bundled bot, deck/collection UI, private Sandbox Forge and Card-first ARTIST presentation.
- **Runtime state:** session-memory play is valid; existing `user://` local profile persistence is optional, with graceful volatile fallback where browser storage is unavailable. Never claim in-memory saves survive reload.
- **Network boundary:** delivery from a hosted URL may need network to fetch assets. Once loaded, the playable core must not need network. Entirely offline cold-start/reload requires a separately verified caching/export contract.
- **Feature deferrals:** no mandatory login, online PvP, ranking, cloud sync, remote media upload, public UGC submission or public starter meme catalog for V1. Public rights/moderation/Canon workflows remain separate post-local-play dependencies.
- **Build/CI gate to add:** verify the Godot Web export can finish a bundled local duel while disconnected after initial asset load; verify in-memory play when storage is unavailable; no silent remote upload.
- **Infrastructure:** INFRA-01 hosts a static web artifact on Cloudflare/Vercel when configured. These platforms do not become gameplay backends.
- **ARTIST:** G1–G10 decisions live in ARTIST-003. G10 D (provisional) requires lightweight origin/rights indication at private import (including 'unknown') and verified provenance **before** any future public review submission. No upload/publication is authorized in MM-06. The separately approved ARTIST-004 screen concept is a visual baseline only; its source PNG is not yet committed.

## ARTIST V1 — asset approval lane (parallel, non-blocking to MM-06)

- **ARTIST-003:** cartoon-first / tropical rooftop art direction APPROVED; G1–G10 decisions preserved (G10 D provisional); illustrated card-first battle; browser-local/in-memory V1.
- **ARTIST-004:** screen-system contact sheet CONCEPT_APPROVED; original reference PNG import remains pending.
- **ARTIST-005:** [asset production/validation ledger](art/ARTIST-005-v1-asset-ledger.md) created with 74 proposed reusable asset/component entries, explicit individual human gates, rights and runtime verification boundaries. **T01 mobile duel CONCEPT_APPROVED** (source SHA recorded, PNG GitHub import pending); **T02 menu overlay 1:1 COMPOSITION_APPROVED** (1254×1254 PNG, exact SHA256 in ledger; original GitHub binary import pending); **T03 desktop/web duel NEXT**. T02 action/route semantics and runtime remain pending independent gates.
- **Gate rule:** concept acceptance is not automatic character/branding approval, actual Godot scene screenshot, feature implementation or release signoff. Later assets advance one-by-one without changing MM-06 → MM-07 → MM-08 product dependencies.

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

## Parallel infrastructure lane — INFRA-01

INFRA-01 provides **cost-aware Godot Web export and optional Cloudflare/Vercel publication** without changing the MM-06 -> MM-10 product dependency order. It is a delivery capability, not a new renderer or a substitute for browser acceptance. See [spec](specs/INFRA-01-smart-web-delivery.md), [plan](plans/INFRA-01-smart-web-delivery.md) and [tasks](tasks/INFRA-01-smart-web-delivery.md).
