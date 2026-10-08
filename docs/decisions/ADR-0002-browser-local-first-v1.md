# ADR-0002 — V1 browser-local / in-memory runtime

**Status:** Proposed in ARTIST-003 draft PR — product direction accepted, implementation verification pending  
**Date:** 2026-10-08  
**Scope:** Mememom V1, Godot Web, local duel, local Forge and storage

## Context

The product owner clarified that the initial MemeMon V1 must start **offline in browser or in-memory**. The current Godot-only client constitution already gives the local deterministic domain authority over rules, but a deployment using Cloudflare/Vercel or later online features must not accidentally introduce runtime services as prerequisites for core play.

## Decision

1. The initial player experience is **browser-first and locally executed**, delivered as Godot 4.x Web export. The active game state may reside entirely in memory. The Godot client contains the deterministic local duel engine, seeded RNG, events, local bot, test/starter fixture data and V1 presentation.
2. **The user can play and finish a local match without sign-in or a gameplay backend.** Authentication, cloud account/profile sync, multiplayer servers, leaderboards, remote persistence, public catalog APIs and moderation endpoints cannot be required by the offline V1 core loop.
3. Existing local collection/deck persistence via `user://` remains supported where browser storage permits; a volatile/in-memory session is a valid, explicitly communicated fallback when storage is denied or unavailable. No implication that an in-memory session survives reload.
4. MM-06 private Forge is browser/local-first: local image/media intake, crop, naming, type and Sandbox preview must not silently upload or share user media. The private Forge's exact data contract and rights prompts remain specified through MM-06 and the open ARTIST-003 G10.
5. G1–G9 battle presentation decisions remain intact: Card-first, shared/curated VFX, static + imported animated source media, idle-only videos, hybrid critical-event sequencer, manual 0/1/2 loops, turn-owner priority with one loop, default 0, and no public starter meme pack initially.
6. Cloudflare/Vercel are **optional static artifact hosts**, not gameplay servers. The packaged build must contain all required core play resources. Optional online features must be strictly isolated from the offline game path.

## Terminology / non-claims

- **Runtime offline:** After game assets are available and loaded, local gameplay must continue without backend/network calls.
- **Cold-start completely offline:** Reopening a hosted site without network may require service worker/PWA installation or validated caching; this ADR does not promise it, and a separate spec/verification gate is required if demanded as an acceptance criterion.
- **Persistence:** Session-memory gameplay must work without persistence; browser-managed local saves are best-effort until storage behavior and quota handling are verified. The current `user://` data contract is not silently replaced.
- **Online backlog:** MM-07/MM-08 governance and MM-09 online match protocol remain later dependency workstreams, not V1 startup blockers. No remote publication is approved by this ADR.

## Acceptance gates for implementation (future, not yet proven)

- Local Godot Web build loads and starts a bot duel without login, token, backend bootstrap or remote storage.
- With game assets loaded, disabling connectivity does not interrupt turns, legal-intent validation, determinism, attacks, KO and terminal win/loss.
- Storage-unavailable mode can complete a match entirely in memory and tells the user that progress will not be saved.
- The local Forge can work with user-selected local media without remote submission.
- Required V1 images, effects, rules and fixtures are local to the shipped artifact; optional videos are gracefully replaced with still posters if playback fails.
- Any claimed completely offline reload/cold-start behavior is verified with a separate explicit browser caching/export gate, never inferred from a successful online page load.

## Compatibility and impact

- Compatible with Constitution v1.0.0 (Godot-only renderer; renderer-independent, deterministic rules).
- Clarifies the primary V1 delivery target; does not create a second renderer or override the already implemented MM-02 through MM-05 logic.
- Update roadmap/spec acceptance before runtime work, and keep ARTIST-003 G10 open until the user answers it.
- This ADR is a **draft repository decision record** until its PR is reviewed/merged; its offline product direction is explicitly user-stated.
