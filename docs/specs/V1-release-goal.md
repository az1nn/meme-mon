# V1 — Community Card Game Release Goal

Status: PLANNED  
Scope: Release definition and acceptance gates for the first public Mememom V1.  
Depends on: MM-01 through MM-10; INFRA-01 for supported Web delivery.

## Product goal

**Mememom V1 lets a player create a private meme card in the Godot client, build a legal deck, complete a reproducible duel, and participate in a safe, moderated community path from Sandbox to Canon.**

V1 is a playable community card-game release, not merely an engine demo or card renderer. Its end-to-end player loop is:

```text
forge private Sandbox card -> collect -> build legal deck -> duel -> submit eligible content
-> moderation/provenance review -> immutable Canon edition -> legal online play
```

## Release outcomes

### O1 — A complete client loop

- The Godot client runs on desktop and supported mobile Web/Android delivery surfaces.
- A player can create and persist a private Sandbox card using image, name, type, flavor/tags and attribution/source metadata.
- System-owned MM-03 constraints, not player-authored combat values, determine the card’s legal budget and preview.
- A player can browse their collection, construct a legal 30-card deck, and start a duel only after deterministic validation.

### O2 — Reproducible competitive truth

- Every competitive deck, card edition, rule version, player intent, match event and replay is versioned and validated fail-closed.
- A completed duel has deterministic seed/event evidence sufficient to reproduce its outcome.
- Online matches use an authoritative service boundary: clients submit intents and receive validated events; reconnect and replay behavior is specified and tested.

### O3 — Safe community progression

- Sandbox content remains private/mutable unless explicitly submitted.
- Submission records required provenance/rights assertions and enters a moderation state machine.
- Only approved, immutable, balance-valid editions can enter Canon or a competitive format.
- Reports, moderation decisions and format legality are auditable; rejected or unresolved content is never competitive-legal.

### O4 — Operable public release

- The supported Web build is a reproducible Godot export with an installable PWA shell; Android packages wrap that same verified output rather than creating a second renderer.
- Release candidates pass exact-head deterministic, parser/import, export/package and browser/mobile acceptance gates.
- The repository declares code, content, contribution and card-review policies before accepting public community contributions.

## V1 success criteria

V1 is ready only when all of the following are demonstrated on a tagged release candidate:

1. MM-06 through MM-10 exit conditions are met, with no unapproved exception.
2. A fresh player can complete the V1 loop in a supported browser and Android package, including touch navigation and an install/launch check.
3. A forged Sandbox card cannot bypass MM-03 budget validation or become competitive-legal without the MM-07/MM-08 gates.
4. Two independent runs of a recorded match seed and intent sequence yield the same final state and event sequence.
5. An online reconnect and replay acceptance scenario succeeds against the authoritative protocol implementation.
6. A production candidate passes privacy, rights/provenance, moderation and original-branding review.
7. Exact-head automated checks, Web/PWA export verification, Android package verification and human accessibility/visual acceptance are recorded.

## Explicit V1 non-goals

- real-money economy, paid randomized packs, trading marketplace or crypto assets;
- ranked ladder, tournament operations or global matchmaking beyond the specified online protocol;
- unrestricted public uploads or automatic Canon promotion;
- a renderer other than Godot for gameplay, collection or Forge;
- cross-platform account/social features beyond what MM-09 explicitly specifies.

## Architecture and trust boundaries

The constitution remains binding. Godot is the sole client/rendering runtime; Web and Android delivery are packaging targets for that client. Domain rules remain deterministic and renderer-independent. Sandbox, Canon and code/content licensing remain separate trust domains.

## Traceability

| V1 outcome | Governing workstreams | Release evidence |
|---|---|---|
| Complete client loop | MM-04, MM-05, MM-06 | Forge/collection/duel acceptance and mobile smoke evidence |
| Reproducible play | MM-02, MM-03, MM-04, MM-09 | versioned contracts, replay fixtures, authoritative-protocol tests |
| Safe community path | MM-07, MM-08 | provenance/moderation/edition/format test evidence |
| Operable release | INFRA-01, MM-10 | exact-head exports/packages, policy documents, release checklist |

