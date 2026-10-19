# MM-06 — Meme Forge / Godot

Status: READY FOR IMPLEMENTATION  
Depends on: MM-01 through MM-05  
Unlocks: MM-07 UGC Provenance & Moderation

## User value

A player can create, preview, edit and persist a private Sandbox Mememom in the Godot client. The player supplies its identity and provenance declaration; the system derives any preview combat envelope from fixed Alpha 0.1 budget rules.

## Scope and authority

- Godot 4.x is the only Forge UI/runtime. Web and Android package the same Godot output.
- A Forge record is `sandbox-1`, local, private and mutable. It is not a CardDefinition, edition, owned competitive card or Canon submission.
- Sandbox data is persisted separately from the MM-05 `local-1` competitive collection profile. A corrupt/unknown Sandbox store must fail closed and must never be overwritten automatically.
- Forge accepts a local image reference only; no upload, network transfer, public sharing, OCR, image moderation or server account is introduced in MM-06.
- The creator may set image reference, name, type, flavor, tags, attribution/source and rights basis. They cannot set HP, attack, cost, tier, effects, edition or legality.

## Functional requirements

**FR-01 Draft validation.** Reject empty/overlong name, invalid type, overlong flavor/source fields, invalid/duplicate tags, empty rights basis and invalid media reference. Return stable error codes without mutating saved records.

**FR-02 Constrained preview.** Produce a deterministic non-competitive preview envelope from the validated name/type and fixed Alpha 0.1 standard-Mememom budget. The preview is validated by `CardValidator`; no editable user field maps directly to combat strength.

**FR-03 Private persistence.** Create/update/delete local records using a versioned `sandbox-1` envelope. Stable IDs are generated locally. Loading/importing is atomic; malformed, future-version or semantically invalid records are rejected.

**FR-04 Provenance declaration.** Each record includes source attribution, source URL/reference and a rights-basis declaration. The UI states that the declaration does not grant publication and that Sandbox is not Canon.

**FR-05 Godot workflow.** From global navigation a player can open Forge, enter all creator-owned fields, choose a local image reference, preview generated card properties, save a private record, reopen it and delete it. The preview clearly displays Sandbox/private/not competitive status.

**FR-06 Trust boundary.** Forge output never appears in `CollectionModel.catalog`, `owned`, a selected deck, a duel, or a competitive CardDefinition fixture. There is no submit/publish control.

## Acceptance scenarios

1. A valid named Mememom with type, tags and provenance saves and reloads identically.
2. Changing creator flavor/tags does not change generated HP, attack, cost or tier for the same name/type.
3. A forged preview passes the MM-03 validator, while its record is not selectable for a competitive deck.
4. Empty name, invalid type, duplicate tag, empty rights basis, invalid media reference and oversized values are rejected atomically.
5. Corrupt or unsupported Sandbox storage neither mutates memory nor is overwritten by save.
6. The Forge scene can create, edit, reopen and delete a record; the existing MM-04/MM-05 suites remain green.

## Non-goals

Crop/transform image pixels, upload/server sync, public submission, reports/moderation, Canon creation, player-authored effects/stats, deck use, accounts, sharing and licensing adjudication.

## Exit gates

- FR-01 through FR-06 are covered by deterministic MM-06 tests and Forge scene smoke evidence.
- Existing competitive profile and deck validation behavior remains unchanged.
- Godot parser/import and all MM-04/MM-05/MM-06 headless suites pass on exact head.
- Roadmap moves MM-06 only after all gates have evidence.

