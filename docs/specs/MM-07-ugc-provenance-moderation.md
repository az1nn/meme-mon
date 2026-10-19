# MM-07 — UGC Provenance & Moderation

Status: IN REVIEW — deterministic reference implementation exists; authoritative deployment and human/privacy acceptance remain.  
Depends on: MM-06 private Sandbox records  
Unlocks: MM-08 Canon & Set Versioning

## User value

Creators can submit an explicitly selected Sandbox record for community consideration while preserving a safe, auditable boundary: unreviewed media stays private and no submission becomes competitive content automatically.

## Scope and authority

- MM-07 introduces a versioned submission record and moderation state machine; it does not create Canon editions, format legality or public card display.
- The submission snapshot is distinct from the mutable Sandbox record. Later Sandbox edits never mutate a submitted snapshot.
- Rights/provenance are creator declarations and review evidence, not a legal determination or transfer of rights.
- The authoritative implementation and storage boundary are deferred to the MM-09 service decision. Local-only mock moderation must never be presented as public moderation.

## Required state machine

```text
draft (private Sandbox only)
  -> submitted
  -> needs_information | under_review
  -> approved_for_canon | rejected | withdrawn
```

- Only `submitted` and `needs_information` may be withdrawn by the creator.
- Only authorized moderators may transition to `under_review`, `needs_information`, `approved_for_canon` or `rejected`.
- Every transition records actor, timestamp, prior state, new state and an optional bounded rationale.
- `approved_for_canon` is eligibility only. MM-08 creates the immutable edition and assigns format legality.
- Any unknown state, actor role, transition or record version fails closed.

## Functional requirements

**FR-01 Submission snapshot.** Capture Sandbox identity fields, copied media digest/reference, attribution, source reference, rights basis and exact Sandbox version in an immutable submission payload.

**FR-02 Validation.** Reject incomplete provenance, missing media, malformed versions, duplicate active submission IDs and invalid transitions without mutating stored data.

**FR-03 Auditability.** Preserve an append-only decision history; rejection/needs-information decisions require a category and bounded moderator rationale.

**FR-04 Privacy.** Do not expose private Sandbox records or media to any other player before a submission path and moderation authorization explicitly permit it. User deletion/retention rules must be specified before hosting public submissions.

**FR-05 Reporting.** Provide report categories for rights/provenance, impersonation, abusive/illegal content and other policy violations. Reports attach to a submission/edition identifier, never to arbitrary client-side URLs.

**FR-06 Trust boundary.** No MM-07 state makes a card a CardDefinition, a collection entry, a deck entry, a Canon edition or format-legal. MM-08 remains the sole Canon-promotion authority.

## Acceptance scenarios

1. A valid private Sandbox snapshot creates one versioned submission with complete provenance declarations.
2. Editing the original Sandbox record does not alter the submission snapshot or decision history.
3. Invalid/missing provenance and disallowed role transitions fail closed and preserve current state.
4. Moderator decisions are append-only and include required category/rationale where applicable.
5. `approved_for_canon` remains non-playable until MM-08 creates a specific immutable edition.
6. A reported item retains its identifier and audit trail according to the adopted retention policy.

## Decisões operacionais adotadas

- O beta fechado é operado por az1nn / Mememom, com retenção inicial de até 90 dias.
- Moderador e administrador operam revisão/apelação; o administrador faz o escalonamento.
- Abertura pública permanece bloqueada até existir contato privado verificável e relatório privado de vulnerabilidades habilitado.
- A taxonomia final de direitos, provedor de mídia/varredura e requisitos de evidência continuam gates da implementação pública.

## Non-goals

Legal advice or copyright adjudication; automatic content approval; public feed/search; Canon edition creation; competitive legality; payments; accounts beyond what MM-09 specifies.
