# SCENE-ARCH-001 implementation plan

1. RECONCILE master, issue #23, PR #13 (closed), current open PRs #25 and #26. Work exclusively on a fresh isolated branch with single atomic commit guarded by expected branch SHA. No assertion of a repo-wide distributed lease.
2. SCENE creates `src/presentation/card_visual_frame.gd` with two equal face bounds, ratio-aware centered fit, configurable safe inset, and contain textures. Adds an isolated preview scene using generated placeholder swatches.
3. ARCH creates deterministic Godot tests, standalone scoped PR workflow, and ADR for layout authority. Explicitly do not edit HUD or source art.
4. VERIFY local static checks and CI on the **exact PR HEAD**, review UI/ART constraints, preserve the source PNG provenance and rejected FIT A.
5. HANDOFF: ART owns C01/C05 face alignment decisions; SCENE wires component into gameplay **only after** ART, ARCH and INSPECTOR gates. No merge automatically.
