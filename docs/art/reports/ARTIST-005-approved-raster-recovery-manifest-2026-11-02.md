# ARTIST-005 — Approved raster asset inventory (2026-11-02)

> **Important:** This is a recovery manifest, NOT a claim that PNG files have been committed. The approved PNG bytes are stored in the downloadable backup ZIP attached to the ChatGPT conversation. GitHub binary import is still required.

| Version | Source filename in backup ZIP | Dimensions | SHA-256 | Gate |
|---|---|---|---|---|
| C05 V3.2 | `C05-V3.2-approved.png` | 1086×1448, RGB | `e199dc44364f1b00466cfec1df5d3f6ca7f3de189ecc19b608ce9bfc637c1775` | ART approved |
| C06 V1.1 | `C06-V1.1-approved.png` | 1086×1448, RGB | `fe603cca1fb841a6dd53d1030e5c2fd8691c446db900c23476a3437a29bd7a63` | ART approved |
| C05 V3.1 | `C05-V3.1-technical-candidate.png` | 669×890, RGBA | `b142ac0c3788de42dac21c62cd5596cb427dfa3e00f8b9a974c8f4f0ab4e169b` | Candidate, not runtime-approved |

## Recovery procedure

1. Download `MemeMon_ARTIST-005_approved_art_backup_2026-11-02.zip` from the ChatGPT conversation, then unpack it.
2. Verify the SHA-256 hashes against the table and `manifest.json` inside the archive.
3. Add the images under `assets/art/approved/ARTIST-005/` on a dedicated branch, preserving filenames and existing historical versions.
4. Validate file decoding, aspect ratio, alpha expectations, Godot import, mobile readability, and CI exact-head before merging.

## Scope

- C01 approved SVG already imported into PR #32; C01 PNG is not in this ZIP.
- C05 FIT A remains rejected. C06 V1 SVG remains rejected as a corrupted preview and is **not** the approved V1.1 PNG.
- PR #32 and PR #33 are drafts; **no automatic merge**.
