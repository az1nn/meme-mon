# MM-05 — Deckbuilder & Collection

Status: DONE — VERIFIED (MM-05 code HEAD 0876e331; final documentation HEAD requires green CI)
Schema/rules version: alpha-0.1
Depends on: MM-01, MM-02, MM-03, MM-04
Unlocks: MM-06 Meme Forge / Godot

## 1. User value

A player can browse owned Mememom editions in the Godot client, search/filter a collection, assemble a competitive 30-card deck, see *why* a draft is illegal, save it locally, reopen it, and start a local duel using a legal selected deck.

## 2. Scope and authority

- Godot 4.x is the only client/runtime. No Three.js.
- Deck legality belongs to a renderer-independent domain validator; scenes may display validation results, but not recalculate rules.
- MM-03 DeckDefinition (schema_version/rules_version, deck_id, format_id, cards[{card_id,edition_id}]) is authoritative.
- The active Alpha 0.1 format_id is \`alpha-0.1\`; future formats require an explicitly versioned legality policy.
- Alpha test cards provide a local starter collection/fixture; they are **not** published Canon and are never automatically promoted.
- Collection ownership is local state, not proof of Canon publication or rights to media.
- Match startup consumes validated edition IDs; no scene should bypass a competitive deck validation gate.
- Existing deterministic duel mechanics and MatchEvent contract stay unchanged.

## 3. Functional requirements

**FR-01 Catalog/collection.** Load only known, MM-03-valid card editions; collection quantities are non-negative integers keyed by edition_id. Unknown editions are not displayable/playable as owned items. Distinguish owned count from the number selected in the draft.

**FR-02 Filtering.** Deterministic filtering by case-insensitive name/ID text, kind, type and tier. Stable order by card_id, then edition_id. Filtering never modifies ownership/decks.

**FR-03 Edit draft.** Add/remove exact edition references, show counters and legality errors; do not permit additions beyond owned quantity, and do not allow negative selected quantities. A draft need not be legal while being edited.

**FR-04 Validate deck.** Exactly 30 entries; at least 8 Mememom; no more than 2 copies by card_id (even across editions); no more than 2 Headliners; known card/edition pair; correct schema/rules version and legal format; all cards individually pass MM-03 validation. Provide stable failure codes \`UNKNOWN_SCHEMA_VERSION\`, \`RULES_VERSION_MISMATCH\`, \`SCHEMA_INVALID\`, \`DECK_SIZE_INVALID\`, \`DECK_MIN_MEMEMOM\`, \`DECK_COPY_LIMIT\`, \`DECK_HEADLINER_LIMIT\`, \`UNKNOWN_CARD_EDITION\`, \`FORMAT_ILLEGAL_CARD\`, and \`CARD_NOT_OWNED\` where applicable. Reject unsupported formats fail-closed.

**FR-05 Storage.** Deterministic JSON save/load of collection, multiple named decks and selected deck into Godot \`user://\`. Store a distinct versioned mutable profile envelope; never overwrite an invalid/corrupt/unsupported existing profile automatically. Unknown persisted versions are rejected, not silently migrated. Alpha 0.1 has no migration path yet; future migrations must be explicit and tested.

**FR-06 Godot UI.** Provide a navigable collection/deckbuilder scene with filter/search, counts, draft additions/removals, validation feedback, deck selection and save/reload. Keep view state separate from contracts.

**FR-07 Duel handoff.** Validate a selected deck before passing ordered edition IDs into DuelEngine.new_match; an invalid deck never starts a match. A deterministic local starter/opponent deck may be used for offline play.

**FR-08 Regression.** Extend headless CI for legal/illegal decks, cross-edition copy constraints, owned-quantity enforcement, filtering stability, disk round-trip, unsupported profile version, malformed JSON and absence of mutation after failed load.

## 4. Acceptance scenarios

1. 30 known owned legal entries with >=8 Mememom and <=2 Headliners are accepted.
2. 29 or 31 entries return DECK_SIZE_INVALID.
3. Seven Mememom returns DECK_MIN_MEMEMOM.
4. Third copy of one card_id, including a second edition, returns DECK_COPY_LIMIT.
5. Third Headliner returns DECK_HEADLINER_LIMIT.
6. Unknown edition/card mismatch and disallowed format fail closed.
7. Unsupported schema/rules versions fail closed.
8. Invalid or over-budget individual cards cannot join a competitive deck.
9. Owned count limits drafting and are rechecked when saving/selecting.
10. Search/kind/type/tier combinations preserve deterministic order.
11. Serialized profile can be loaded and saved identically, including selected deck.
12. Corrupt/future profile load does not change in-memory data or overwrite the file.
13. A Godot user can edit, save, reopen, select and start a legal deck.
14. Existing 194 MM-04 regression checks still pass with no deterministic-rule drift.
15. Godot import/parser, tests and main-scene boot pass for exact PR HEAD.

## 5. Success criteria / exit gates

- FR-01 through FR-08 functional and demonstrated by tests or scene smoke evidence.
- MM-04 invariants preserved.
- Required Godot 4.7.2 CI green on exact head; no masked parse/runtime failures.
- README and ROADMAP updated only upon proven completion; MM-06 must not advance early.
- Human acceptance only if a visual/product decision is genuinely needed.

## 6. Non-goals

Forge/upload/crop; online accounts/collection sync; purchases/rewards/economy; moderation/rights publication; migration from unknown future formats; other clients; elaborate art/animations.