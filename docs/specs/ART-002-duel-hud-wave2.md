# ART-002 — Wave 2: data-bound duel HUD (Godot)

Status: IMPLEMENTING; not final ART sign-off. Issue: #9. Parent visual authority: `docs/art/ART-002-mememom-character-first.md`.

## User value
A young player can understand the current duel from readable card surfaces and public match indicators, rather than a JSON/status dump. Mobile-first, with the approved saturated cartoon palette and hamburger-only global navigation intact.

## Functional requirements
1. Replace the human-facing status dump with a Godot HUD derived only from `DuelEngine.state` and versioned card definitions. No new rule calculations, mutations or extra renderer.
2. Show turn number, active side, phase, current player and opponent Hype (out of 5), Trend current/cap, active card name/type/HP, Queue count, and local Hand with name/kind/Trend cost. Enemy Hand is count-only (no private card identities).
3. Display active/hand cards using responsive, wrapping, legible Godot panels/chips in the approved coral/cyan/yellow/ink visual foundation. Alpha fixture art is still pending and must be identified as test content, not Canon.
4. If Active is absent, show a clear empty-state label. If the match ends, expose terminal state text. Present the last few event names in a readable compact log rather than dumping raw payloads.
5. Keep the existing duel intent buttons, collection route, global hamburger shell and MM-04/MM-05 rules unchanged. No Forge, networking, upload, Canon, arbitrary meme rights claims or permanent global nav.
6. Make every card/HUD item readable at target 360x640, 390x844, 768x1024 and 1100x720 via vertical scrolling and wrapping; full viewport screenshots/manual touch and contrast inspection remain separate gates.

## Acceptance
- Headless Godot import/parser and MM-04/MM-05/ART-002 navigation regressions pass on exact head.
- New HUD smoke proves authoritative Hype/Trend values, active card name, card cost/hand rendering, opponent hand privacy and terminal/empty states.
- Main and Collection scene headless smoke plus Web artifact remain green.
- Real Godot runtime screenshots and user approval still pending; #9 stays OPEN.
- Screenshots must not be fabricated from image concepts.

## Owners / concurrency
SCENE implements `src/presentation/duel_hud.gd` and minimal integration in `main.gd`; ARCH checks read-only domain use, test regressions and CI; ART owns fidelity gate; INSPECTOR owns runtime screenshots; SIGA owns exact-head gate/merge and persistent handoff. MM-06 remains a separate NEXT product workstream.
