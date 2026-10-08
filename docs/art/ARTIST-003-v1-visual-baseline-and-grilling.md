# ARTIST-003 — V1 visual baseline and battle-character grilling

**Status:** VISUAL BASELINE APPROVED; G1 CARD-FIRST PROVISIONALLY SELECTED; G2 OPEN  
**Date:** 2026-10-08  
**Scope:** Mememom; Godot-only runtime; documentation/art-direction decision record.

## Approval matrix

| Surface | Decision | Scope |
| --- | --- | --- |
| Mobile-first menus, card layout, visual hierarchy, color and navigation | APPROVED V1 | The recent ARTIST contact sheet is the approved structural/style reference. Navigation should be hidden in an accessible hamburger menu; no fixed menu rail on phones. |
| Battle environment/composition and broad visual quality | APPROVED V1 BASELINE | Presentation layout only, not a rule-system replacement. |
| Characters, specific memes and creature identities appearing in the mockup | NOT APPROVED | Concept placeholders only; independently select legally usable and recognizably original combatants. |
| Mockup logo and any franchise-resembling branding | REJECTED AS FINAL BRANDING | Create a distinct Mememom wordmark, emblem, iconography and battle vocabulary; never reproduce Pokémon/Digimon/Pokémon Center trade dress or familiar proprietary symbols. |
| Battle character representation | G1 — PROVISIONAL: D / CARD-FIRST | Animated illustrated cards are the on-screen combatants. No 3D character models required in V1. This is not a final engine specification. |

## Original generated reference asset

- Source: ARTIST image generated in the Mememom DEV conversation on 2026-10-08.
- Original filename: `a_vibrant_polished_cartoon_illustration_ui_concep.png`.
- Original dimensions: **1536 × 1024 PNG**.
- Original SHA-256: `cfcd814e930fa6924e211df6a2df31bd374797fa27262b21817329ec142135a5`.
- Intended repository path for the visual binary: `docs/art/references/ARTIST-003-v1-menus-battle.png`.
- **Binary import status: PENDING.** This record documents the source and approved elements; it does not misrepresent the reference PNG as committed. The asset must be uploaded without alteration or verified with the recorded SHA-256.

## Originality gate

Mememom is not a franchise imitation. Avoid direct references to proprietary battle-screen framing, creature designs, badge systems, capsule/ball icons, famous franchise wordmarks and branded healing-center motifs. Approve all new character designs and branded assets on original-expression grounds, even if a previous exploratory mockup included franchise-adjacent details.

## Meme asset admissibility (proposed for grilling)

Prefer:
1. independently verified public-domain works;
2. original first-party assets;
3. verified CC0 contributions where the licensor controls the relevant rights.

A viral meme or image found online is **not**, merely by popularity, public domain. CC0 only addresses copyright to the extent permitted; trademark, privacy and publicity/personality rights may still apply.

Require provenance metadata before an image is promoted from private Sandbox into a public/competitive asset:
`source_url`, `creator_or_rightsholder`, `copyright_status`, `license_and_version`, `evidence_url`, `trademark_screening`, `likeness_screening`, `reviewer`, `reviewed_at`, `canonical_asset_hash`.

Unknown, ambiguous or incompatible rights: REJECT for public Canon; do not imply open-source code licensing covers meme media. This is an asset policy proposal, not a legal opinion.

## Existing technical boundaries (do not discard)

- Constitution: Godot 4.x is the sole client renderer.
- MM-02/MM-03/MM-04: deterministic 1v1 duel with versioned intent → validate → resolve → event pipeline, replayable RNG and data-driven cards.
- MM-05: collection and deckbuilder implemented.
- Existing Alpha rules: 30-card decks, Active/Queue, Trend resource and Hype win condition.
- New battle presentation may animate **two visible Active characters** while respecting the existing underlying rules, Queue and deck semantics.
- Do not create a new graphics engine or duplicate game rules inside scenes. `Meme Battle Engine` should denote an original, bounded **battle character/presentation subsystem** over Godot, with any rule revisions first justified by Spec Kit and accepted by the user.

## Grilling starts here

**Gate G1 — How are the two active fighters represented on screen?**

A. 2D skeletal/cutout fighters with expressive animation, simple and fast to author.  
B. 2.5D: 2D meme fighters in a dynamic depth-aware battle arena, camera/VFX controlled by Godot.  
C. Simple original stylized 3D fighters with bespoke models and more expensive production.  
D. Card-first battle: illustrated cards act as combatants, with only limited avatar/VFX presentation.

This decision does not override MM-02 rules. Further gates: accepted media categories; animated assets; attack vocabulary; rigging/retargeting; combatant state machine and visual event mapping; mobile frame budget; model-factory pipeline; accessibility and trademark/content gates.

## Grilling decisions — tracked human gates

### G1 — Combatant representation (2026-10-08)

- **Answer:** D — Card-first.
- **State:** PROVISIONAL / accepted as current grilling direction, not a finalized implementation authorization.
- **Product intent:** Illustrated meme cards themselves represent the two Active duelists. Emphasize readable attack, hit, damage, KO and card-entry animation through reusable effects without mandatory 3D models or character rigs.
- **Engine boundary:** Godot scene/presentation subscribes to authoritative ordered `MatchEvent` stream and plays audiovisual sequences; competitive validation, RNG, hitpoints, Hype/Trend/KO and game-state mutation remain in the existing deterministic domain. The visible pair are the two Active cards, not a new independent two-character ruleset.
- **Explicit exclusions for G1:** Mandatory 3D fighter modeling; implementing bespoke attack logic in presentation; copying franchise-specific battle visual identity; assumption that illustrative mockup characters are final accepted assets.
- **Next question (G2):** How much unique animation can an individual card define?
  - A: Uniform animation/VFX templates for every card; fastest and simplest.
  - B: Shared, data-driven modular animations (motion/timing/impact/VFX chosen by data), no per-card custom animation.
  - C: Bespoke visual animations for every card.
  - D: Hybrid — modular templates by default; curated unique visuals for special cards, without executing arbitrary gameplay scripts.
- **Recommendation for discussion, NOT ACCEPTED:** D for expressiveness with predictable cost; exact budget and permitted media formats remain open.

## References

- Constitution: `.specify/memory/constitution.md`
- Existing rules: `docs/specs/MM-02-alpha-duel-rules.md`
- Existing Godot duel: `docs/specs/MM-04-godot-duel-vertical-slice.md`
- Rights workstream: MM-07 on `docs/ROADMAP.md`
- CC0: https://creativecommons.org/publicdomain/zero/1.0/
- Wikimedia Commons reuse policy: https://commons.wikimedia.org/wiki/Commons:Licensing

## Verification

Documentation-only. G1 was explicitly selected provisionally and is documented; G2 and later grilling gates remain open. The binary import is still pending. No claim of image upload, accepted meme characters, battle-feature completion, or runtime-test result is made.
