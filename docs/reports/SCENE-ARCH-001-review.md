# SCENE-ARCH-001 / CardVisualFrame review

**Review revision:** `34817e2` (`origin/pr/27`, `origin/feat/scene-arch-card-visual-frame-20261026`), reviewed on the local `ralph/v1-work` branch after the current merge base.

## Scope

This review covers the isolated `CardVisualFrame` component, its generated QA preview, and the component regression workflow. It does not approve artwork, integrate the component into duel/collection/Forge, or close the ART-002 visual/runtime gates.

## Local evidence

All commands below completed successfully against the reviewed worktree:

- `git diff --check`
- `bash -n ralph.sh scripts/lib/*.sh tools/ralph-merge.sh`
- `godot --version` → `4.7.2.stable.official`
- `godot --headless --path . --import`
- `godot --headless --path . --script res://tests/run_card_visual_frame_tests.gd`
  - `SCENE/ARCH-001 checks: 50, failures: 0`
  - `SCENE/ARCH-001 CARD FRAME GATES PASS`
- `godot --headless --path . res://scenes/qa/CardVisualFramePreview.tscn --quit-after 2`
- `npm test`
  - MM-04: 194 checks, 0 failures
  - MM-05: 94 checks, 0 failures
  - MM-06: 14 checks, 0 failures
  - MM-07/MM-08: 41 checks, 0 failures
  - MM-09: 18 checks, 0 failures
  - MM-09 server adapter: PASS
  - ART-002 navigation: 21 checks, 0 failures
  - ART-002 HUD: 19 checks, 0 failures
- `npm run build:pwa` → Web export and `PWA artifact PASS` on the clean exact-PR worktree; this is required before `npm run pwa:check` because generated `web/` output is intentionally ignored.
- `npm run pwa:check` → `PWA artifact PASS`

The Godot import emitted pre-existing duplicate UID warnings for mirrored web/Android icon files. No parser, script, scene, or runtime error was emitted, and the warnings are outside this isolated component's scope.

## Contract review

The implementation is independently reviewable and remains within the Godot-only contract:

- `Control` plus `TextureRect` only; no Three.js, shader, networking, domain state mutation, or gameplay/HUD integration.
- Configurable aspect ratio with a QA-only default, fail-closed invalid geometry, bounded non-negative safe inset, and contain-only `STRETCH_KEEP_ASPECT_CENTERED` rendering.
- Front and back share the same logical frame/safe bounds, and repeated face selection is idempotent with no duplicate `face_changed` signal.
- The regression suite covers the required target viewports, including the small viewport, verifies source texture dimensions remain unchanged, and rejects non-finite or non-positive geometry bounds before layout.
- The preview uses generated flat swatches and explicitly does not present recovered concept art as approved runtime art.

## Explicitly pending gates

These cannot be certified by the local headless checks and remain open as required by SCENE-ARCH-001 and ART-002:

- ARCH review of import settings, sampling, memory, and Web/mobile behavior with approved artwork.
- ART approval of real C01/C05 front/back silhouette and alignment; no such artwork is integrated here.
- SCENE ownership/integration decision for production screens.
- INSPECTOR fresh Godot runtime screenshots at the four target viewports, plus touch, keyboard/back, and face-switch interaction review.
- Final exact-head CI/review and merge authorization.

## Deferred, non-blocking findings

1. Godot import reports duplicate UIDs in mirrored web/Android assets. This predates and is unrelated to CardVisualFrame; track with packaging/import cleanup rather than blocking this isolated component review.
2. Runtime GPU memory/performance measurements and actual mobile/Web behavior require approved binary artwork and an external runtime/device gate.
3. The component intentionally has no production flip animation or engine event binding; adding either would exceed SCENE-ARCH-001's current scope.

## Verification refresh (2026-11-01)

The isolated component and repository gates were rerun on the current `ralph/v1-work` branch after the documentation-only follow-up commits:

- `godot --headless --path . --script res://tests/run_card_visual_frame_tests.gd` — 50 checks, 0 failures.
- `godot --headless --path . res://scenes/qa/CardVisualFramePreview.tscn --quit-after 2` — PASS.
- `npm test` — all listed MM-04 through MM-09, server, navigation and HUD gates pass with 0 assertion failures.
- `npm run build:pwa` — Web artifact PASS; `npm run pwa:check` — PWA artifact PASS.
- `git diff --check` and shell syntax checks — PASS.

The expected invalid-Canon server stderr, known ART-002 anchor warnings, and pre-existing mirrored-asset duplicate UID warnings remain non-failing diagnostics. No human artwork, browser/device, touch, or Inspector evidence was available, so the pending gates above remain open.

**Review conclusion:** local implementation and regression gates pass; the PR remains a candidate pending the human/art/runtime gates listed above. Do not mark PR-027-REVIEW or the ART-002 runtime acceptance complete solely from this report.
