# ADR-0003 — Runtime card geometry is not sourced from concept-sheet pixels

Status: PROPOSED / SCENE-ARCH-001
Date: 2026-10-26

## Context
C01's ARTIST SVG has a decorative rectangle at 684×1122. C05 V3.1 derived asset had aspect 669×890. FIT A tried to force the artwork into C01 reference geometry by adding a new exterior matte; the owner rejected this candidate.

The live Godot HUD currently contains responsive PanelContainer text chips and no approved card-sprite geometry. Thus the reference SVG is **not** evidence of a production card frame contract.

## Decision
A reusable Godot `CardVisualFrame` establishes a configurable logical frame with equal front/back bounds, optional safe inset and aspect-preserving TextureRect presentation. It does not dictate universal card ratio, modify artwork, crop approved source images, or implement an unapproved background/silhouette. The standalone default aspect is a QA fixture, not a design token.

## Consequences
- Positive: geometry, visibility and responsive bounds become testable independently of copyrighted/user-generated artwork, combat state or the rejected matte.
- Tradeoff: letterboxing may occur until ART selects approved front/back silhouettes and texturing policy.
- Explicitly deferred: runtime card ratio selection, true rounded mask/alpha edges, animations, Web/mobile performance measurements and ART approval.
- Existing duel rules, source files, UI HUD and PRs are untouched.

This ADR becomes ACCEPTED only after ARCH and ART review; current status is PROPOSED.
