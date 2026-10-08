# ART-002 — Mememom character-first visual direction

**Status:** PROPOSAL / HUMAN GATE PENDING  
**Owner:** ART (visual acceptance); SCENE (Godot presentation); ARCH (engine/implementation); SIGA (orchestration and merge gates).  
**Baseline:** master at `e93e542e7a4be3f38bb835d9ecb42ccad413aabb`; MM-05 merged; MM-06 NEXT.  
**Previous result:** ART-001 / "Internet Relics" explicitly **REJECTED**, PR #7 closed without merge. Do not reuse its UI, colors, card frame, SVG/PNG, or art as evidence.

## Direction — MEMEMOM: Meme Pop Arena

**Primary fantasy:** recognizable, expressive internet-native absurdity becomes an original competitive creature card game. Put **unique creature illustrations** and the playable card/duel fantasy at the center; a UI full of boxes without characters is insufficient.

This is an **original** cartoony arcade/game-show aesthetic, not Pokémon trade dress and not the discarded artifact/textured collage look.

### Three creative rules

1. **Characters first:** silhouette-readable, hilariously expressive creatures with improbable anatomy and bold outlines. First-party placeholder characters only. Each has a distinctive face, pose, and visual joke; generic empty abstract textures do not qualify as card art.
2. **Bright and inviting playfield:** light warm-cream base; saturated ocean blue, coral, sunflower, aqua, lilac for accents. Playful typography, simple flat/elevated UI and character-led cards. Not a black/lime tool dashboard. Do not recreate ART-001 layout.
3. **Gameplay legibility:** include visible **Trend** resource, **Hype** race-to-five, **Active**, **Queue**, player **Hand** and the current turn. Artwork may be silly, but type/cost/HP/attack and selected actions must be easy to read.

## First-art acceptance image

A **landscape 16:9 / 3:2 polished gameplay concept image** (not a code or SVG preview), showing:
- MEMEMOM game title, one absurd original Mememom card with actual illustrated creature, two additional smaller distinct original cards, and a playable-feeling Godot-style duel arena;
- player side, opponent side, clear Hype 0–5 and Trend numbers, combat focus and hand;
- card semantics reflect the actual alpha cards; invented concept names/imagery are **illustrative only** and must NOT be called an official legal card edition;
- game-world visual style (not file browser, settings panel, fake screenshot or unrelated projects);
- physical, mobile-readable on-screen hierarchy, large interaction targets and visible action states.

Recommended palette as exploration, not a standard: cream `#FFF4DC`, cobalt `#275CF5`, coral `#F76A55`, aqua `#48D9D0`, sunflower `#FFC74A`, dark ink `#212444`. These tokens are **non-binding until art approval**.

## Godot / scope contract

- Godot 4.x is the sole client/renderer. Do not add Three.js or UI rule duplication.
- ART produces and approves the visual language; SCENE implements it, ARCH checks the runtime/scene integrity, SIGA handles gates and merge.
- Match engine remains authoritative: PlayerIntent -> validation -> deterministic resolution -> MatchEvent -> visual rendering.
- Card kinds **mememom**, **reaction**, **format** differ; only Mememom cards show combat stats.
- Do not imply uploaded memes are legally licensed or any Sandbox preview is published Canon.
- MM-06 Forge remains a separate feature; art explorations may propose its look but must not preempt its spec or mutate the active product branch.
- Competing branches/PRs and ongoing SIGA execution own their affected files. ART-002 is **docs-only** until human approves a concrete visual reference.

## Gate

- [x] Reconcile repository and ART-001 reject.
- [x] Write distinct ART-002 concept contract on isolated branch.
- [x] Produce and display a **rendered PNG in chat**; previous SVG-on-GitHub failure must not recur. This is a chat attachment, **not** a GitHub binary asset or Godot screenshot. Manual render is the valid reference; an earlier off-scope automatic image was disqualified.
- [ ] Human approves/rejects/revises concept after seeing the image.
- [ ] Upon approval only: open bounded Godot SCENE/ART implementation spec, capture real runtime before/after screenshot, test controls, run exact-head CI.
- [ ] Do not merge the proposal as an adopted baseline before its human gate.

## Handoff

**CLASSIFY:** ART-001=REJECTED; ART-002=AWAITING VISUAL REVIEW.  
**NEXT:** the user judges the rendered concept; SIGA/SCENE remain free to advance MM-06 mechanical gates independently. No changes to game assets, scenes, schemas, RNG, persistence, or CI were authorized by this proposal.
