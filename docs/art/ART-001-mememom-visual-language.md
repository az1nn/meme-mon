# ART-001 — Mememom Visual Language (proposal)

**Status:** PROPOSED — not artist-approved / not runtime-verified  
**Owner:** ART (visual result); SCENE (Godot scene implementation); ARCH (technical integrity); ORCHESTRATOR/SIGA (workflow authority)  
**Baseline:** `master` after MM-04; independent of in-progress `feat/mm-05-deckbuilder-collection`.  
**Scope:** visual contract for the collection/deckbuilder and reusable Alpha card shell, without changing game mechanics.

## 1. Intent

Make **Mememom** feel like a native, original meme TCG: the tension of a collectible card, the personality of internet collage, and the clarity of a strategy interface. Build **one design language across Godot** (duel, collection, card preview, future Forge). No Pokémon-branded silhouettes, layouts, glyphs, card frames or characters; no Three.js.

The player must recognize at a glance: **card name**, **card kind**, **type**, **Trend cost**, **tier**, **owned quantity**, **draft quantity**, and whether a deck is **legal or incomplete**. Mechanics remain exclusively in the domain boundary.

## 2. Visual thesis — "Internet Relics"

- **Material:** collectible print ephemera: torn stickers, offset halftones, photocopier grain, digital compression motifs and small UI scanlines. These are decorative, not readability surfaces.
- **Shape language:** stacked, slightly offset *rectangular* panels with cut-corner notches and unorthodox asymmetrical highlights. Avoid imitating recognizable commercial TCG framing.
- **Tone:** witty, punchy, slightly chaotic **inside the card illustration**, disciplined and legible **around rules and controls**.
- **Player-authored memes:** use safe abstract first-party placeholder art for Alpha; do not display scraped/copyrighted meme images or represent local test fixtures as Canon art.
- **Motion (future):** restrained 120–220 ms hover/focus feedback; no forced flashing, jitter, or animation that obscures card text or prevents input. Respect reduced-motion preferences.

## 3. Initial design tokens (provisional, not constitutional)

| Role | Token | Hex |
|---|---|---|
| Workspace ground | ink-950 | `#0B1020` |
| Raised surface | ink-850 | `#182139` |
| Card paper | paper-100 | `#F3EFE4` |
| Primary dark text | ink-950 | `#0B1020` |
| Text on dark | fog-100 | `#F5F7FD` |
| Primary focus/CTA | trend-lime | `#CDFC5A` |
| Destructive/illegal | warning-coral | `#FF6579` |
| Informational | electric-blue | `#5DB8FF` |

**Type accent palette** (must always be paired with a text label or icon; never color-only):
- **classic** — ochre `#D6A654`;
- **reaction** — cyan `#55D9F1`;
- **brainrot** — acid-green `#A9E65D`;
- **surreal** — ultraviolet `#B594FF`;
- **wholesome** — mint `#77E4B5`.

Typography: native Godot sans with strong hierarchy; do not depend on an unlicensed remote font. Body/labels remain readable at intended viewport scale; implement visible keyboard focus and adequate contrast against both ground and card-paper surfaces.

## 4. Component anatomy

### A. Card shell (all three kinds)

- Target portrait ratio **2:3**, scalable without squashing the illustration.
- Top: **Trend cost** in a distinct chip, **name** on a stable text strip.
- Middle: illustration slot, **not** a rules source; placeholder may render a type-specific abstract collage.
- Bottom: independent text tokens for **kind**, **type**, **tier**, then stats/ability summary *only where defined by CardDefinition*.
- **Headliner** receives a distinct visual treatment while retaining the explicit `headliner` label.
- No invented health/attack for Reaction or Format cards.
- Card edition and provenance indication must not imply that local Alpha fixtures are community Canon.

### B. Collection / deckbuilder (MM-05-compatible)

- Header: Mememom / Collection / Deckbuilder, current selected deck, save/load state.
- Left/top filtering region: search + **kind**, **type**, **tier** filters.
- Owned card grid: visually distinct **owned N**, **in draft N** and disabled add state.
- Deck region: editable current draft, `N / 30`, selected entries, remove action, errors, save/reload/choose/duel affordances.
- A draft may be edited while invalid; **Start Duel** is disabled until the **domain** returns a legal verdict.
- Invalid-deck feedback: plain-language explanation plus exact domain code (e.g. `DECK_SIZE_INVALID`), not a red glow alone.
- Empty/search/loading/error states must remain navigable and distinct.
- 1100x720 current window is the baseline; ensure no clipped controls and keyboard navigation at this size. Responsive/export targets are separate acceptance gates when actually in scope.

### C. Duel visual contract (future presentation pass)

- Opponent public state / Hype / Queue above playmat.
- Active card and current Trend resource central; own hand/actions below.
- Hype is a visible **0–5 track**. Trend resource is labeled; the visual never computes its own competitive value.
- Event feed is visually secondary but accessible.
- A scene reads MatchState/events and emits player intents; it never modifies deterministic state.

## 5. Layer boundaries

```text
MM-03/MM-05 domain result -> view model -> Godot Control/Theme/Card render
       rules truth                               visual truth (ART)
```

No generated art, placeholder, control styling or animation may change card legality, RNG, hand ordering or event sequence. ART approves the visual result; SCENE/ARCH own engine implementation integrity; SIGA owns merge and execution gates.

## 6. Deliverables and measurable acceptance

1. A reusable Godot card UI with all mandatory labels readable for Mememom / Reaction / Format; no fabricated stats.
2. Collection/deckbuilder screenshot at current 1100x720 viewport demonstrating owned vs selected, filters, legal/illegal draft and selected deck.
3. Explicit empty, error, focus, disabled and long-name states.
4. Headliner treatment distinct without color-only semantics.
5. Before/after evidence generated from a **real Godot runtime** (one current screenshot per target scene); concept renders cannot substitute for runtime evidence.
6. Godot 4.7.2 import/parser, relevant UI interaction smoke and MM-04/MM-05 tests remain green on the exact head.
7. No new proprietary meme imagery, second rendering stack or changes to competitive contract.

## 7. Concurrency / adoption protocol

This document is **design guidance**, not a new implementation branch for MM-05. The active `feat/mm-05-deckbuilder-collection` branch owns its SCENE/ARCH files. Do not cherry-pick/merge partial scene code from ART into that branch or duplicate `src/presentation/` ownership.

After a verified, reviewed MM-05 scene exists, the ORCHESTRATOR may open a small visual-only follow-up. Reconcile exact HEAD and class ownership first. Keep visual changes separate from domain/persistence work.

## 8. Gate and handoff

- **Current visual gate:** PROPOSED. No Mememom art concept or runtime screenshot has been accepted.
- **Human decision:** approve/revise the "Internet Relics" visual thesis only if it is to become the binding visual baseline.
- **Safe next action:** complete MM-05 mechanical gates; then capture a real Godot screenshot and review against §6 before implementing/polishing art.
- **Explicitly rejected as evidence:** visuals/assets from Maricá Game, Growing-Rio, or other projects.
