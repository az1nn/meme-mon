# ART-002 — Mememom character-first visual direction

**Status:** ART_STYLE_APPROVED (definitive visual-language approval) / RESPONSIVE_NAVIGATION_REWORK_REQUIRED / GODOT_RUNTIME_NOT_VERIFIED / FINAL_UI_ACCEPTANCE_PENDING  
**Owner:** ART (visual acceptance); SCENE (Godot presentation); ARCH (engine/implementation); SIGA (orchestration and merge gates).  
**Baseline:** master at `e93e542e7a4be3f38bb835d9ecb42ccad413aabb`; MM-05 merged; MM-06 NEXT.  
**Previous result:** ART-001 / "Internet Relics" explicitly **REJECTED**, PR #7 closed without merge. Do not reuse its UI, colors, card frame, SVG/PNG, or art as evidence.

## Direction — MEMEMOM: Meme Pop Arena

**Human decisions (2026-10-08):** The first concept was accepted as a provisional V1, with polish required. After the mobile/desktop mockup iteration, the owner **explicitly approved the art style in full** while agreeing to **reject the navigation architecture** (fixed bottom bars on mobile and permanently exposed nav/sidebars on desktop). These are independent gates: `ART_STYLE_APPROVED` and `NAVIGATION_REWORK_REQUIRED`. The artistic style is not provisional; scene fidelity, UX, runtime, and final implementation acceptance remain pending. Work is tracked in [issue #9](https://github.com/az1nn/meme-mon/issues/9).

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

Recommended palette as visual reference, not a frozen numerical token set: cream `#FFF4DC`, cobalt `#275CF5`, coral `#F76A55`, aqua `#48D9D0`, sunflower `#FFC74A`, dark ink `#212444`. The exact hexadecimal tokens, asset geometry and mockup typography are implementation references, not pixel-perfect constraints. **The expressive, saturated character-first visual language itself is approved and must be preserved**, even while the UX/layout is rebuilt.

## Frozen visual language — ART_STYLE_APPROVED

The latest playful mobile+desktop duel mockup is a **conceptual art-language reference**, not a Godot scene screenshot and not approval of its navigation. Preserve the visual style when implementing UI:

- **Character-first original creatures:** chubby, expressive mascots with distinctive silhouettes, readable faces, playful poses and high-quality illustrated card art. Avoid copied third-party characters and unintended collectible-game trade dress.
- **Color and form:** saturated cyan/cobalt/coral/pink/yellow/lilac, warm cream content surfaces, dark blue ink and strong clean cartoon/comic outlines; generous corner rounding, controlled shadows and tactile card depth.
- **Atmosphere:** lively arcade and graffiti-inspired city motifs, simple stars/stickers, lighthearted motion and approachable, youth-friendly tone; avoid dense visual noise behind interactive text.
- **HUD/card identity:** clearly differentiated card variants, cost badges, Hype/Trend and active duel state; illustrations remain the hero without sacrificing legibility. Preserve card silhouette/icon language consistently in thumbnails, hand and detail panels.
- **Polish, not replacement:** improve alignment, typographic integrity, contrast, focus states, icon coherence and spacing. Do **not** revert to ART-001 or redesign the approved mascot/visual aesthetic to fix layout.

**Approval boundary:** full approval of *style* does not mean the sample's literal logo lettering, invented sample card data, precise pixels, bottom toolbar, permanent side navigation or final Godot visuals are approved. New iterations should retain style while fixing usability.

## Navigation and responsive UX — mandatory rework

**Mobile-first default:** the battle view is primary. Global navigation is **closed/hidden** until a clearly labeled, reachable **hamburger menu** is activated. Do not add a fixed bottom tab bar or persistent side navigation; the global menu pattern must also be used on desktop/web. In-duel *actions* (e.g., choose card, attack, confirm) remain context-specific visible controls and are not global navigation.

### Acceptance contract (SCENE + ART + INSPECTOR)

1. **One navigation entry:** persistent hamburger trigger in the header, with accessible name (e.g. "Abrir menu"); the same navigation structure is available in Godot desktop/web and mobile. Do not simultaneously show a top navigation strip, left sidebar or mobile tab bar as a second global navigation system.
2. **On demand:** open a single overlay/drawer showing Início/Duelo, Coleção/Deckbuilder, Forge (only when MM-06 exists), Perfil/Configurações (only when implemented). Unsupported entries must not pretend to work. The overlay may scroll; it must not permanently consume duel viewport width.
3. **Clear dismissal:** explicit close button, outside tap/click and back/Escape where supported; focus/selection returns to the trigger. Visible interaction states for opened/closed, focused, selected and disabled elements. No trapped or off-screen navigation.
4. **Touch first:** interactive targets >= 44 x 44 logical px where layout permits, comfortable spacing, readable captions, contrast and non-color-only indicators; no hover-only actions. Test tap accuracy and keyboard/gamepad path supported by Godot.
5. **Responsive:** ensure readable layouts at 360 x 640, 390 x 844, 768 x 1024 and 1100 x 720 (logical viewport targets). Battle/hand/actions remain accessible without overflow or invisible controls. Desktop may adapt columns/cards but **not** reintroduce permanent global nav.
6. **Real state:** no static mockup rule values. Bind duel and collection views to the authoritative domain state; loading, empty, invalid-deck and long-name states are legible. No scene-only legality logic.
7. **Evidence:** one fresh **Godot runtime** screenshot each for mobile battle/menu closed, mobile menu open, desktop battle/menu closed and desktop menu open, all against exact revision; automate scene/control checks and separately request final UX human review.

**Owner gates:** ART approves fidelity to the frozen style; DESIGN validates player flows; SCENE implements Godot layouts; ARCH validates technical integrity; INSPECTOR checks responsive screenshots and interactions; SIGA owns conflict/CI/handoff. The user has **not** approved any fixed navigation UI, including the fixed nav visible in earlier concept generations.

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
- [x] Human **approved the character-first style definitively** on 2026-10-08. First concept approval was provisional, but the subsequent full-style approval supersedes its provisional style status. The layout, interaction, asset production and runtime still require validation.
- [x] Human rejected fixed navigation patterns: hamburger-only global navigation is mandatory on mobile and desktop.
- [x] Open bounded implementation/polish intake issue: [#9](https://github.com/az1nn/meme-mon/issues/9).
- [ ] ORCHESTRATOR/SIGA reconcile current MM-06 state/ownership; implement bounded Godot SCENE/ART work, capture runtime before/after screenshot, test controls, run exact-head CI.
- [x] Provisional human concept gate passed. The docs-only baseline PR may be reviewed/merged via SIGA, but **visual runtime implementation and final polish acceptance remain independent, mandatory gates**.

## Handoff

**CLASSIFY:** ART-001=REJECTED; ART-002=ART_STYLE_APPROVED / NAVIGATION_REWORK_REQUIRED / GODOT_RUNTIME_NOT_VERIFIED.  
**NEXT:** SIGA reconcile exact HEAD and MM-06 ownership, then execute [issue #9](https://github.com/az1nn/meme-mon/issues/9) in small waves: readable card/duel/collection presentation, original character art, Godot runtime screenshots, regression and human final polish review. The proposal alone does **not** imply code/UI assets were changed, a game was visually validated, or that P0 polish is complete.
  
**Preview caveat:** The concept image is illustrative, not a Godot screenshot or a normative pixel-perfect layout. Reject wrong title spelling (must be **Mememom**), unrelated overworld/exploration content and any unlicensed third-party meme likenesses. Preserve the card-TCG intent, not accidental details of image generation.
