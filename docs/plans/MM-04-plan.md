# MM-04 Implementation Plan

## Wave 1 — Spec and harness
- Freeze MM-04 scope and acceptance scenarios.
- Pin Godot 4.7.2 CI runtime.
- Bootstrap project and headless test runner.

## Wave 2 — Deterministic core
- Implement xorshift32-v1.
- Implement contract/card loader and MM-03 budget checks.
- Implement serializable duel state and event emission.
- Implement intent validation/resolution and state-based checkpoints.

## Wave 3 — Playable slice
- Add 20 legal Alpha test cards.
- Add deterministic bot.
- Add minimal local duel scene that consumes domain state.

## Wave 4 — Verification
- Encode MM-02/MM-03 regressions in headless tests.
- Prove replay identity and complete bot-vs-bot termination.
- Run GitHub Actions on exact PR head.
- Fix failures without weakening rules.
- Advance roadmap to MM-05 only after green exact-head evidence.
