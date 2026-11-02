# SCENE-ARCH-001 / PR #27 exact-head review

**Reviewed head:** `34817e2` (`origin/pr/27`)
**Review branch:** `ralph/pr-027-review`
**Scope:** CardVisualFrame isolated component and QA scene only
**Result:** locally verifiable gates pass; human visual/device and merge gates remain open

## Evidence executed against the exact PR head

| Gate | Command | Result |
|---|---|---|
| Godot import/parser | `godot --headless --path . --import` plus the workflow error-pattern check | PASS; Godot 4.7.2; no script/parse/runtime error pattern |
| Component regression | `godot --headless --path . --script res://tests/run_card_visual_frame_tests.gd` | PASS; `47` checks, `0` failures; `SCENE/ARCH-001 CARD FRAME GATES PASS` |
| QA scene smoke | `godot --headless --path . res://scenes/qa/CardVisualFramePreview.tscn --quit-after 2` plus workflow error-pattern check | PASS; scene launched without script/parse/runtime error pattern |
| Repository suite | `npm test` | PASS; MM-04 `194`, MM-05 `94`, MM-06 `14`, MM-07/MM-08 `39`, MM-09 `14`, server, navigation `21`, HUD `19`; all reported zero failures |
| PWA artifact | `npm run pwa:check` | PASS |
| Diff whitespace | `git diff --check` | PASS |

The import output contains pre-existing duplicate UID warnings for copied web/Android icon assets. They are warnings, not CardVisualFrame errors, and do not fail the workflow's error-pattern gate.

## Contract review

- `CardVisualFrame` remains isolated from duel HUD, domain rules, cards, and gameplay input.
- Front/back views use equal computed bounds and `TextureRect.STRETCH_KEEP_ASPECT_CENTERED`; source texture dimensions are not mutated.
- Aspect and safe-inset setters reject invalid values, and repeated face selection is idempotent.
- The preview uses generated color swatches only and explicitly does not claim approved C01/C05 art.
- No Three.js, shader, networking, or scene-only competitive rule path was introduced.

## Explicitly pending gates

The following cannot be certified by the local headless checks and remain open as required by SCENE-ARCH-001 and ART-002:

- ART approval of actual C01/C05 front/back silhouette and alignment; no approved artwork is integrated by this PR.
- INSPECTOR runtime screenshots and interaction/touch checks at 360x640, 390x844, 768x1024, and 1100x720 on supported targets, including any requested flip behavior.
- Texture import, memory, sampling, Web/mobile runtime review with approved artwork.
- Exact-head CI/reviewer approval and merge authorization.

This review therefore records the PR as independently reviewable and locally verified, but does **not** mark human, visual, device, licensing, or merge gates complete.
