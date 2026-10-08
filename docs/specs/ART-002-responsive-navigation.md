# ART-002 — Responsive navigation shell (Godot wave 1)

Status: IMPLEMENTING — independent of full visual-fidelity approval  
Authority: `docs/art/ART-002-mememom-character-first.md`; tracking: #9  
Owner: SCENE (UI), ARCH (technical), ART (fidelity), INSPECTOR (evidence), SIGA (gates)

## User value
Children and teens can enter the local duel, operate the contextual battle actions and navigate to their card collection on phones or desktop without a fixed global navigation bar taking battlefield space.

## Requirements
- A single global hamburger trigger appears in the shared header, **closed by default** in duel and collection.
- Drawer opens on demand, closes through explicit close, outside click/tap or Escape/back, and returns focus to its trigger.
- Drawer contains **only implemented routes** (duel, collection). Forge is described as coming later and not exposed as a working route.
- No global bottom tabs, permanent desktop sidebar or fixed top category navigation. Battle action buttons remain on the battlefield as contextual actions.
- One shared Godot Control shell provides the header, scrollable content, palette and overlay.
- Controls target at least 44x44 logical pixels. Adaptive wrapping prevents command groups from clipping at 360x640, 390x844, 768x1024, 1100x720.
- Existing Alpha duel/domain/deck/persistence semantics stay authoritative and unchanged. No new renderer, card legality rules or UGC.
- ART-002's **approved** character-first bright cartoon style remains binding; this shell is only a navigation/structural implementation wave. No claim of final art or runtime screenshot evidence.

## Scenarios
1. Start local duel: header shows menu trigger but no global nav strip; tap opens drawer; choosing collection navigates to collection scene.
2. In collection: selection/save/play buttons remain contextual; hamburger returns to duel; top search/filter/deck controls wrap instead of requiring horizontal page scroll.
3. Dismiss drawer via close, outside pointer/touch or Escape/back; focus returns to opener.
4. Resizing to mobile/tablet/desktop keeps drawer narrower than viewport and page scrollable.
5. Existing MM-04/MM-05 headless gates remain green.

## Acceptance boundaries
- Automated smoke for initial hidden state, route dispatch, dismissal, drawer widths and existing scenes.
- Real Godot **visual** screenshots for mobile open/closed and desktop open/closed, accessibility/manual checks, and final human review are separate open gates under issue #9.
- Exact PR-head CI required before merge. Do **not** mark issue #9 done from this wave alone.

## Out of scope
Creature art assets, card illustration overhaul, complete battle board UI, Forge MM-06, UGC, networking, final polished visual approval.