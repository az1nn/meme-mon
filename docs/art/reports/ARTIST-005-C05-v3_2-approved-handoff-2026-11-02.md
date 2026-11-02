# ARTIST-005 — C05 V3.2 · approved visual derivative (2026-11-02)

**State:** HUMAN_VISUAL_APPROVED / PNG_BINARY_UPLOAD_BLOCKED / GODOT_NOT_VERIFIED
**Owner:** ART (visual decision); SIGA (process); ARCH, SCENE, INSPECTOR (technical follow-up)
**PR:** [#32](https://github.com/az1nn/meme-mon/pull/32)

## Human decision

The owner explicitly approved a newly generated standalone card-back PNG for C05, with **visual fidelity taking precedence over the exact historical bytes**. This is a new derivative, not silent replacement of C05 V3, the C05 V3.1 adaptation presentation board, or the rejected FIT A candidate.

- Suggested immutable repo path: `docs/art/references/ARTIST-005-C05-V3_2-card-back-approved.png`
- Local generated filename: `carta_de_graffiti_com_patinha_dourada.png`
- PNG dimensions: **1086 × 1448**
- Encoding: RGB PNG (no true alpha channel)
- Local file size: **2,242,830 bytes**
- SHA-256 (generated output): `e199dc44364f1b00466cfec1df5d3f6ca7f3de189ecc19b608ce9bfc637c1775`

**Important:** The PNG is **not versioned in this PR** at the time of this report. The connected GitHub create-blob endpoint requires inlined base64 and cannot ingest the sandbox path or platform image reference. A temporary copy was also imported into the user's connected Canva asset library as a possible transfer bridge, but this does not constitute a GitHub commit. Do not label the asset IMPORTED without a verified PNG blob in the commit.

## Preserved history

- C01: human-approved base card frame, SVG imported as an unchanged Git blob in PR #32.
- C05 V1: REJECTED_BY_OWNER.
- C05 V2: ADJUST_REQUESTED.
- C05 V3: CONCEPT_APPROVED, original source to be preserved separately.
- C05 V3.1: ADAPTATION_BOARD_APPROVED, production sprite extraction not approved.
- FIT C01 A: REJECTED_BY_OWNER; never promote.
- C05 V3.2: HUMAN_VISUAL_APPROVED as an independent derivation, pending binary import and engine QA.

## Next verifiable work

1. Transfer the exact approved **V3.2 PNG bytes** to the isolated branch; `sha256sum` must equal `e199dc44364f1b00466cfec1df5d3f6ca7f3de189ecc19b608ce9bfc637c1775`.
2. Preserve V3.2 original RGB intact and derive a separately named RGBA technical sprite only after border/safe-area validation against C01.
3. Check C01 back/front silhouette, flip, downsampling, antialiasing on different backgrounds and real Godot Web/mobile screenshots. ARCH/SCENE/INSPECTOR gates remain open.
4. Run CI on exact PR head; no merge without explicit approval and completed gates.
5. Prepare **C06 — Active battle-card template** as a new *independent visual proposal*, not a production asset. Require human ART approval before integration.

## SIGA outcome

PARTIAL — visual approval recorded; exact-head PNG presence is blocked by connector transport. Do not misreport the file as uploaded, or the artwork as implemented.
