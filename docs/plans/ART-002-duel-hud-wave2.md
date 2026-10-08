# ART-002 — Wave 2 implementation plan

Baseline master: `0dcbc375e1f0a096ebee577815dde3236ef26c8e` (headless and web artifact jobs both PASS). Owner: ART-002 #9. No open competing PRs at reconciliation.

1. Implement a standalone, presentation-only Godot `VBoxContainer` HUD that uses public `state` and catalog read-only to construct player boards, active cards, responsive hand/queue chips and turn/terminal summary.
2. In the duel scene replace the technical JSON/status view with the HUD. Retain a small error/status surface for validation failures, existing contextual action buttons and shared hamburger navigation.
3. Add a deterministic headless HUD test covering redaction of opponent hand identities, live Hype/Trend, legible active/hand fields, null active and terminal state; register it in required GitHub Actions headless workflow.
4. Verify exact branch head Godot import, all existing suites, both scenes, HUD suite and web artifact. Only merge after green exact-head checks and a fresh conflict check.
5. Keep #9 open: full illustrated creatures/cards, touch/manual viewport screenshots and final UI acceptance are not provided by this wave.

Do not alter `src/domain`, `src/data`, persistent profile schema, export presets or provider credentials. Do not re-approve ART style.
