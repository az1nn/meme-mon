# SCENE-ARCH-001 — tasks and gates

- [x] Trace current production HUD to PanelContainer chips, not sprite card component.
- [x] Preserve FIT A REJECTED, C01 and C05 V3/V3.1 history unchanged.
- [x] Implement isolated configurable CardVisualFrame and QA preview (candidate code).
- [x] Define same-frame front/back, safe area and fail-closed geometry APIs.
- [x] Add deterministic tests and separate CI workflow (tests **not claimed passed** until runner executes).
- [x] Godot 4.7.2 import/parser and tests on exact PR head: evidence recorded in [SCENE-ARCH-001 review](../reports/SCENE-ARCH-001-review.md) (`34817e2`, local head matching `origin/pr/27`).
- [ ] ARCH review texture import, memory, sampling and Web/mobile constraints using approved artwork.
- [ ] ART approve silhouette and visual front/back alignment against C01/C05 V3.1, not FIT A.
- [ ] SCENE integrate only after ownership/claim check, no takeover of other feature branches.
- [ ] INSPECTOR capture real Godot Web/mobile screenshots, test input and flip behavior.
- [ ] Approve exact-head checks; merge only after all required gates.
