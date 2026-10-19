# MM-08 — Canon & Set Versioning

Status: IN REVIEW — deterministic Canon/legality reference exists; release/operator acceptance remains.  
Depends on: MM-07 approved eligibility snapshots  
Unlocks: MM-09 Online Match Protocol

## User value

Players can trust that a competitive card keeps the same identity, provenance and game behavior for every replay and match. Creators can see exactly which reviewed submission became which immutable Canon edition.

## Scope and authority

- MM-08 is the only workstream allowed to create Canon editions from an MM-07 `approved_for_canon` eligibility snapshot.
- A Canon edition is immutable. Correction, balance or rights action creates a new edition or changes format legality; it never rewrites historical edition data.
- Competitive clients resolve card behavior by exact `card_id` and `edition_id` under a versioned format. Names, images and mutable Sandbox IDs are not sufficient references.
- MM-08 does not implement moderation decisions, matchmaking, player accounts, trading or a public browsing feed.

## Functional requirements

**FR-01 Immutable edition.** Produce a canonical edition with a stable `edition_id`, source submission ID, schema/rules version, content digest, provenance snapshot, CardDefinition payload and publication timestamp. Reject any update that changes protected edition fields.

**FR-02 Canon publication gate.** Create an edition only from an exact MM-07 approved snapshot whose provenance and MM-03 budget validation still pass. Unknown versions, withdrawn/rejected records, missing media digest or invalid CardDefinition fail closed.

**FR-03 Set/version lifecycle.** Group editions into explicit sets and formats. A set/version definition names allowed exact editions and the applicable rule/schema versions. Rotation, suspension and retirement are additive, dated legality records rather than edition mutation.

**FR-04 Legality resolution.** Resolve legality from a requested `(format_id, card_id, edition_id, rules_version)` tuple with stable failure codes. An unknown, suspended, retired, mismatched or unlisted edition is not legal.

**FR-05 Traceability and replay.** Retain source-submission, edition and format references in all competitive deck and match records. A historical replay uses the edition/format rule versions captured at match start.

**FR-06 Rights safety.** A rights concern may suspend an edition from every active format immediately, but must preserve audit references. A new rights decision does not erase historical match evidence.

## Acceptance scenarios

1. An approved MM-07 snapshot with a valid MM-03 payload produces one immutable edition and stable content digest.
2. Repeating publication with altered name, media, provenance or effects is rejected rather than mutating the edition.
3. A standard 30-card deck accepts only editions listed in its specified active format.
4. A suspended/retired or unknown edition fails deck validation even if its card ID is known.
5. A replay references the exact edition and format versions used in the match, after later set rotations occur.
6. An MM-07 approval alone never makes an item playable before a valid MM-08 publication/legality record exists.

## Decisões operacionais adotadas

- O beta usa rotação semestral e permite suspensão emergencial por segurança/direitos.
- Nome/versionamento de sets, digest imutável, retenção de mídia e gestão de chaves continuam requisitos explícitos antes de publicação pública.

## Non-goals

Card sales/packs, trading, player economy, client-side edition mutation, automatic balancing, ranked ladders, global search/discovery and online transport.
