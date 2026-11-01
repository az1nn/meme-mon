# SCENE-ARCH-001 — Isolated CardVisualFrame

Status: IMPLEMENTATION_CANDIDATE / ART_NOT_APPROVED / RUNTIME_UNVERIFIED
Owner: SCENE (component), ARCH (contract and tests), SIGA (reconcile and handoff)
Tracking: issue #23; ART-002 issue #9; historical PR #13 CLOSED/NOT MERGED.

## Problem

Current `src/presentation/duel_hud.gd` renders responsive *textual* PanelContainer chips. It does **not** implement a front/back sprite card, card aspect contract or flip. C01's historical SVG contains a decorative reference rect 684×1122, not a Godot-accepted geometry. C05 V3.1 recovered board (and pixel-equivalent operational conversions) are concept approvals only. The FIT A composite was explicitly rejected by the owner and is forbidden as an asset baseline.

## Goal

Introduce an isolated, reusable, testable front/back **render container** without changing duel/collection/Forge, mechanics, existing approved art or gameplay input semantics. No mockup dimensions silently become runtime standards.

## Decisions

- Render with Godot 4 Control + TextureRect only, no Three.js, shaders, networking or domain state mutation.
- Aspect ratio is explicitly provided by the owner/scene; 3:4 default is **QA-only**, not a global design decision. The container never stretches the source images; its `STRETCH_KEEP_ASPECT_CENTERED` can letterbox if face texture and frame differ.
- Both faces share the same logical frame bounds and optional inset. Switching visibility is instant/deterministic; **no production flip animation** or engine event binding yet.
- Safe inset is 0–25% of the frame per axis, and cannot be negative. Defaults to zero; no fabricated bleed guide or forced card crop.
- Transparent pixels are kept; renderer uses rectangular clipping only, not a simulated rounded approved silhouette. Final C01/C05 silhouette/alpha belongs to ART.
- QA preview uses colored placeholders, never recovered image binaries or the rejected FIT A. No backend and no player cards.
- Existing card schema, DeckValidator, MatchState and HUD remain authoritative/untouched.

## Acceptance criteria

- CA01: `CardVisualFrame` supports configurable ratio, same-size front/back bounds, optional safe insets, and contain-only rendering.
- CA02: 360×640, 390×844, 768×1024, 1100×720 and a small viewport show no geometry overflow.
- CA03: invalid geometry inputs fail closed, repeat face-switch does not emit duplicate transition event.
- CA04: face source texture identities and dimensions are not mutated; actual geometry equals computed geometry.
- CA05: standalone QA scene imports and launches in Godot 4.7.2; automated regression emits `SCENE/ARCH-001 CARD FRAME GATES PASS` on zero failures.
- CA06: main game scenes, assets, gameplay rules and HUD remain untouched. No merge until exact-HEAD CI on PR and reviews.
- CA07: ART approves future actual C01/C05 front/back matching; INSPECTOR verifies real Godot screenshots/touch/flip at target viewports. CA07 is explicitly **open**.

## Non-goals

No C05 sprite integration, brand approval, C06, final texture atlas, animation playback, click behavior modification, gameplay data binding, or acceptance of the rejected FIT A.

## Technical risks

- `TextureRect.STRETCH_KEEP_ASPECT_CENTERED` can letterbox a face; this is correct safe behavior but not proof that two artistic outlines match.
- No exact runtime GPU memory/profile measurement until actual binary source and ART acceptance.
- Godot script parser/runtime and Web/mobile verification require CI/runner; source inspection alone is not an acceptance gate.
