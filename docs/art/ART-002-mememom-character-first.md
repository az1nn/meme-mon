# ART-002 — Mememom character-first visual direction

**Status:** V1_PROVISIONAL_VISUAL_DIRECTION_APPROVED — POLISH_REQUIRED; implementation/runtime acceptance PENDING  
**Owner:** ART (visual acceptance); SCENE (Godot presentation); ARCH (engine/implementation); SIGA (orchestration and merge gates).  
**Baseline:** master at `e93e542e7a4be3f38bb835d9ecb42ccad413aabb`; MM-05 merged; MM-06 NEXT.  
**Previous result:** ART-001 / "Internet Relics" explicitly **REJECTED**, PR #7 closed without merge. Do not reuse its UI, colors, card frame, SVG/PNG, or art as evidence.

## Direction — MEMEMOM: Meme Pop Arena

**Human decision (2026-10-08):** “Gostei da ideia, mas falta muito polimento, aceito como V1 provisória.” Approval is of the creative direction only, **not** final art, screenshot fidelity, production readiness, or runtime implementation. Work to implement and polish is tracked in [ART-002 issue #9](https://github.com/az1nn/meme-mon/issues/9).

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

Recommended palette as exploration, not a standard: cream `#FFF4DC`, cobalt `#275CF5`, coral `#F76A55`, aqua `#48D9D0`, sunflower `#FFC74A`, dark ink `#212444`. These exploratory tokens remain **provisional**, not a pixel-perfect frozen palette; the human approved the broad direction and requested substantial polish.

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
- [x] Human **approved direction as provisional V1** on 2026-10-08 with substantial polish outstanding. This **does not approve the specific mockup as runtime evidence**.
- [x] Open bounded implementation/polish intake issue: [#9](https://github.com/az1nn/meme-mon/issues/9).
- [ ] ORCHESTRATOR/SIGA reconcile current MM-06 state/ownership; implement bounded Godot SCENE/ART work, capture runtime before/after screenshot, test controls, run exact-head CI.
- [x] Provisional human concept gate passed. The docs-only baseline PR may be reviewed/merged via SIGA, but **visual runtime implementation and final polish acceptance remain independent, mandatory gates**.

## Handoff

**CLASSIFY:** ART-001=REJECTED; ART-002=V1_PROVISIONAL_APPROVED / POLISH_REQUIRED / RUNTIME_NOT_VERIFIED.  
**NEXT:** SIGA reconcile exact HEAD and MM-06 ownership, then execute [issue #9](https://github.com/az1nn/meme-mon/issues/9) in small waves: readable card/duel/collection presentation, original character art, Godot runtime screenshots, regression and human final polish review. The proposal alone does **not** imply code/UI assets were changed, a game was visually validated, or that P0 polish is complete.
  
**Preview caveat:** The concept image is illustrative, not a Godot screenshot or a normative pixel-perfect layout. Reject wrong title spelling (must be **Mememom**), unrelated overworld/exploration content and any unlicensed third-party meme likenesses. Preserve the card-TCG intent, not accidental details of image generation.
