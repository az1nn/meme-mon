# ART-002 — Implementation plan (wave 1)

- Baseline: master 49a38cdea4794d5e1135d313d280823c46ef27b5, CI PASS.
- Ownership: `src/presentation/navigation_shell.gd`, `main.gd`, `collection.gd`, navigation test, CI and wave docs.
- Build one navigation shell with presentation-only route signal; route handling stays in existing scenes.
- Keep domain state, intents, deck legality and persistence untouched.
- Move collection access behind hamburger on the duel; remove redundant back-to-duel navigation from collection; retain Play as contextual action.
- Wrap action/filter/deck button groups using Godot HFlowContainer and scroll the content vertically.
- Verification: Godot 4.7.2 import/parse, 194 MM-04 + 94 MM-05 checks, navigation regression, two smoke scenes. Full screenshot and visual signoff require interactive Godot later.
- No direct edits to MM-06 branches, no merge before exact-head CI and conflict verification.
