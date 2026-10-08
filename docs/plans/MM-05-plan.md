# MM-05 Implementation Plan

Status: ACTIVE. Spec: docs/specs/MM-05-deckbuilder-collection.md

## Technical boundaries

- \`src/domain/deck_validator.gd\`: pure MM-03 deck contract validation from CardDefinition catalog, with optional owned-quantity check. Do not put deck rules in UI.
- \`src/domain/collection_model.gd\`: pure owned catalog/filter/draft operations; use validator for legality.
- \`src/data/collection_store.gd\`: versioned local user:// JSON envelope; explicit load failure, no silent migration, deterministic serialization and round-trip.
- \`src/presentation/\`: Godot-only collection/deckbuilder scene. Presentation consumes domain verdicts, no competitive rule fork.
- \`tests/run_mm05_tests.gd\`: headless domain/persistence/contract regressions. Existing MM-04 suite remains a required gate.

## Delivery waves

1. **Specification lock**: constitutional reconciliation, MM-05 spec/plan/tasks.
2. **Domain**: catalog-backed legality by card_id/edition_id, format, Headliners, ownership; collection filtering and draft operations.
3. **Persistence**: local saved decks/collection, stable encoding, fail-closed load, round-trip tests.
4. **Godot UX and duel wiring**: browse, search/filter, edit, save/reload, select, and launch with a validated deck.
5. **Verify/close**: run CI, correct failures, test scene, update documentation and handoff, squash merge when gates permit.

## Risks and mitigations

- **Mixed editions bypass copy limits**: key limits by card_id rather than edition_id; dedicated test.
- **Sandbox/Canon confusion**: starter test collection remains local and non-Canon.
- **Unknown format/version**: fail-closed validation and profile ingestion.
- **Presentation rules drift**: all legality decisions in domain, only domain API consumed by scene.
- **Persistence corruption**: never replace current in-memory state on failed load; use isolated temp test paths.
- **Incomplete engine contract**: validate before match creation; MM-04 tests must continue passing.

## Definition of verified

Passing GitHub Actions on exact feature HEAD (Godot 4.7.2 headless tests, parser/import, smoke), no open failures/reviews/gates and evidence in docs/reports/MM-05-verification.md. Unverified code stays in PR, not merged.