# ARTIST-003 — V1 visual baseline and battle-character grilling

**Status:** VISUAL BASELINE APPROVED; G1 CARD-FIRST + G2 HYBRID + G3 IMAGE/VIDEO + G4 IDLE-ONLY VIDEO + G5 HYBRID SEQUENCER + G6 MANUAL 0/1/2 VIDEO PROVISIONALLY SELECTED; G7 OPEN  
**Date:** 2026-10-08  
**Scope:** Mememom; Godot-only runtime; documentation/art-direction decision record.

## Approval matrix

| Surface | Decision | Scope |
| --- | --- | --- |
| Mobile-first menus, card layout, visual hierarchy, color and navigation | APPROVED V1 | The recent ARTIST contact sheet is the approved structural/style reference. Navigation should be hidden in an accessible hamburger menu; no fixed menu rail on phones. |
| Battle environment/composition and broad visual quality | APPROVED V1 BASELINE | Presentation layout only, not a rule-system replacement. |
| Characters, specific memes and creature identities appearing in the mockup | NOT APPROVED | Concept placeholders only; independently select legally usable and recognizably original combatants. |
| Mockup logo and any franchise-resembling branding | REJECTED AS FINAL BRANDING | Create a distinct Mememom wordmark, emblem, iconography and battle vocabulary; never reproduce Pokémon/Digimon/Pokémon Center trade dress or familiar proprietary symbols. |
| Battle character representation | G1 — PROVISIONAL: D / CARD-FIRST | Animated illustrated cards are the on-screen combatants. No 3D character models required in V1. This is not a final engine specification. |
| Card animation architecture | G2 — PROVISIONAL: D / HYBRID | Reusable modular animations are the default; special cards may have curated unique visual animations. No arbitrary gameplay code embedded in card assets. |
| Accepted animation media | G3 — PROVISIONAL: C / STILL + VIDEO | Still art plus curated GIF/video sources through validated conversion/optimization before Godot runtime use, always with still-frame fallback. |
| Runtime video use | G4 — PROVISIONAL: A / IDLE LOOP ONLY | Optional looping animation within the currently Active card; attack, hit, KO and special-action effects use Godot's shared animation/VFX system, not event-specific video clips. |
| Visual event synchronization | G5 — PROVISIONAL: C / HYBRID EVENT SEQUENCER | Critical combat beats are presented in canonical event order; lightweight idle loops and ambient UI can continue asynchronously. Visual playback never mutates or blocks deterministic game rules. |
| Idle-loop resource allocation | G6 — PROVISIONAL: D / MANUAL 0–2 | Player sets a maximum of 0, 1 or 2 simultaneous Active-card idle clips; no automatic quality-tier switching. Visual failure remains nonblocking and uses a static fallback. |

## Original generated reference asset

- Source: ARTIST image generated in the Mememom DEV conversation on 2026-10-08.
- Original filename: `a_vibrant_polished_cartoon_illustration_ui_concep.png`.
- Original dimensions: **1536 × 1024 PNG**.
- Original SHA-256: `cfcd814e930fa6924e211df6a2df31bd374797fa27262b21817329ec142135a5`.
- Intended repository path for the visual binary: `docs/art/references/ARTIST-003-v1-menus-battle.png`.
- **Binary import status: PENDING.** This record documents the source and approved elements; it does not misrepresent the reference PNG as committed. The asset must be uploaded without alteration or verified with the recorded SHA-256.

## Originality gate

Mememom is not a franchise imitation. Avoid direct references to proprietary battle-screen framing, creature designs, badge systems, capsule/ball icons, famous franchise wordmarks and branded healing-center motifs. Approve all new character designs and branded assets on original-expression grounds, even if a previous exploratory mockup included franchise-adjacent details.

## Meme asset admissibility (proposed for grilling)

Prefer:
1. independently verified public-domain works;
2. original first-party assets;
3. verified CC0 contributions where the licensor controls the relevant rights.

A viral meme or image found online is **not**, merely by popularity, public domain. CC0 only addresses copyright to the extent permitted; trademark, privacy and publicity/personality rights may still apply.

Require provenance metadata before an image is promoted from private Sandbox into a public/competitive asset:
`source_url`, `creator_or_rightsholder`, `copyright_status`, `license_and_version`, `evidence_url`, `trademark_screening`, `likeness_screening`, `reviewer`, `reviewed_at`, `canonical_asset_hash`.

Unknown, ambiguous or incompatible rights: REJECT for public Canon; do not imply open-source code licensing covers meme media. This is an asset policy proposal, not a legal opinion.

## Existing technical boundaries (do not discard)

- Constitution: Godot 4.x is the sole client renderer.
- MM-02/MM-03/MM-04: deterministic 1v1 duel with versioned intent → validate → resolve → event pipeline, replayable RNG and data-driven cards.
- MM-05: collection and deckbuilder implemented.
- Existing Alpha rules: 30-card decks, Active/Queue, Trend resource and Hype win condition.
- New battle presentation may animate **two visible Active characters** while respecting the existing underlying rules, Queue and deck semantics.
- Do not create a new graphics engine or duplicate game rules inside scenes. `Meme Battle Engine` should denote an original, bounded **battle character/presentation subsystem** over Godot, with any rule revisions first justified by Spec Kit and accepted by the user.

## Grilling starts here

**Gate G1 — How are the two active fighters represented on screen?**

A. 2D skeletal/cutout fighters with expressive animation, simple and fast to author.  
B. 2.5D: 2D meme fighters in a dynamic depth-aware battle arena, camera/VFX controlled by Godot.  
C. Simple original stylized 3D fighters with bespoke models and more expensive production.  
D. Card-first battle: illustrated cards act as combatants, with only limited avatar/VFX presentation.

This decision does not override MM-02 rules. Further gates: accepted media categories; animated assets; attack vocabulary; rigging/retargeting; combatant state machine and visual event mapping; mobile frame budget; model-factory pipeline; accessibility and trademark/content gates.

## Grilling decisions — tracked human gates

### G1 — Combatant representation (2026-10-08)

- **Answer:** D — Card-first.
- **State:** PROVISIONAL / accepted as current grilling direction, not a finalized implementation authorization.
- **Product intent:** Illustrated meme cards themselves represent the two Active duelists. Emphasize readable attack, hit, damage, KO and card-entry animation through reusable effects without mandatory 3D models or character rigs.
- **Engine boundary:** Godot scene/presentation subscribes to authoritative ordered `MatchEvent` stream and plays audiovisual sequences; competitive validation, RNG, hitpoints, Hype/Trend/KO and game-state mutation remain in the existing deterministic domain. The visible pair are the two Active cards, not a new independent two-character ruleset.
- **Explicit exclusions for G1:** Mandatory 3D fighter modeling; implementing bespoke attack logic in presentation; copying franchise-specific battle visual identity; assumption that illustrative mockup characters are final accepted assets.
- **Question asked (G2, answered D):** How much unique animation can an individual card define?
  - A: Uniform animation/VFX templates for every card; fastest and simplest.
  - B: Shared, data-driven modular animations (motion/timing/impact/VFX chosen by data), no per-card custom animation.
  - C: Bespoke visual animations for every card.
  - D: Hybrid — modular templates by default; curated unique visuals for special cards, without executing arbitrary gameplay scripts.
- **Resolution:** D selected provisionally on 2026-10-08; production budget and file/media contracts remain open.

### G2 — Animation architecture (2026-10-08)

- **Answer:** D — Hybrid.
- **State:** PROVISIONAL / user-approved for the current grilling, not yet an implementation specification or engine completion.
- **Default:** shared, configurable data-driven card animations for entrance, idle, attack, hit, KO, status and reveal where relevant. Reuse motion, timing and VFX presets to keep content scalable.
- **Exception:** selected special cards (rarity/title/status still to be specified) may receive authored unique animations and audiovisual identity. Such variants are visual-only and must not determine gameplay results.
- **Technical boundary:** Godot's presentation layer consumes authoritative `MatchEvent` data and drives animation sequencing. Card content must not supply arbitrary executable scripts that can mutate rules, RNG, damage, Trend, Hype or match state.
- **Accessibility / production guardrails (to be specified):** reduced motion, clear hit/KO readability, bounded asset/runtime cost and graceful fallback to common templates; the exact performance envelope is still open.
- **Not decided at G2:** specific special-card criteria, runtime conversion targets, asset budgets or final effects art; source-media direction is provisionally set by G3.

### G3 — Asset input contract (2026-10-08)

- **Answer:** C — Still images + prerecorded animated clips.
- **State:** PROVISIONAL / selected by user during grilling; not yet a frozen media specification or a claim of implemented support.
- **Accepted source-media direction:** PNG/WebP illustrations and curated GIF/video uploads, subject to source validation, provenance, applicable usage rights and publishing/moderation gates.
- **Import/packaging boundary:** Input GIFs and video files must be normalized/transcoded during a controlled import/build step into explicitly supported and tested Godot presentation resources. No assumption that every GIF, codec or container plays natively in Godot; no unreviewed runtime codec dependencies, network video streaming or arbitrary media execution in V1.
- **Runtime boundary:** Presentation-only media is started/stopped by Godot as the authoritative ordered `MatchEvent` stream changes Active card/state. G4 provisionally restricts videos to optional Active-card idle loops, not attack/KO event clips. It must not affect logical action resolution, random outcomes, hitpoints, Trend, Hype, timing of legality checks or replay determinism.
- **Failure/accessibility behavior:** A still-card fallback must remain available for unsupported, unavailable, corrupted or disallowed motion content, and for reduced-motion settings. Engine state must not wait on successful media decoding.
- **Not yet determined:** Specific output codec/runtime resource type, source limits, resolutions, idle-loop timing, preloading, performance budgets, audio policy, clip lengths or exact event-to-VFX orchestration; decide through later gates and verify mobile/web export compatibility before implementation acceptance.

### G4 — Idle card playback (2026-10-08)

- **Answer:** A — Idle card animation only.
- **State:** PROVISIONAL / selected by user during grilling. Not a claim of video-runtime support or implemented battle animations.
- **Behavior:** The currently Active card can display an optional lightweight looping clip **inside the card frame** while active. Inactive/queued cards do not require simultaneous loop playback. Static media and reduced-motion fallback remain mandatory.
- **Attack/hit/KO behavior:** Reusable Godot tweens, sprites, particles, shaders, HUD feedback and event-driven effects convey combat actions. No event-specific attack, damage or KO videos are required/authorized by this provisional V1 selection.
- **Coexistence with G2 Hybrid:** Curated special cards can have distinct **Godot-authored motions/VFX/presets** or unique idle loops, without requiring attack-event video clips; a custom effect does not modify deterministic gameplay rules.
- **Coexistence with G3 Still + Video:** GIF/video inputs remain allowable sources for optional idle loops after validation and compatible conversion; no assumption of direct native GIF or arbitrary codec playback in Godot 4.x.
- **Authority:** Active card identity and combat events derive from domain state and ordered `MatchEvent` emissions; the presentation independently runs/stops optional idle video and transient VFX. Decoding, animation duration, looping and visual errors must never block rule resolution.
- **Open engineering details:** Loop codec/texture path, initial poster frames, playback budgets, mobile/web compatibility, effect preset mapping, sound, reduced motion and transition handling.

### G5 — Visual event synchronization (2026-10-08)

- **Answer:** C — Hybrid event sequencer.
- **State:** PROVISIONAL / explicitly selected by user during grilling. This is a presentation contract direction, not a claim that the sequencer has been implemented.
- **Core causality:** The presentation consumes canonical, monotonically ordered `MatchEvent` events and stages critical attack → damage → KO → replacement beats in the same logical order, with stable event-to-effect mapping.
- **Concurrent presentation:** Card idle-loop video (G4), non-causal ambience and UI decoration may run asynchronously; they cannot preempt or reorder critical combat beats.
- **Logic authority:** Deterministic match resolution, RNG and state transitions remain entirely within the existing domain. The event presentation queue is not a second rule engine, must not generate authoritative events, and cannot block logical resolution on video decoding, tweens, particle systems or audio.
- **Accessibility/resilience:** Effects must have bounded duration, fast-forward or skip affordances, reduced-motion alternatives, still-card fallback, safe catch-up after delayed/unavailable assets, and clear readable KO/damage states. Exact durations and input-lock strategy remain open engineering details.
- **Rendering edge cases to specify and test:** simultaneous KOs and draw results, chained triggers, forced replacement, terminal results, replay seeking, out-of-date visual queues and app background/foreground interruptions. Never alter the canonical event order to make the effects look better.
- **Preserved decisions:** G1 D Card-first; G2 D Hybrid authored+shared VFX; G3 C image/video source inputs with conversion; G4 A video as optional idle animation only.

### G6 — Manual idle-loop count (2026-10-08)

- **Answer:** D — Manual quality setting only.
- **State:** PROVISIONAL / user-selected during grilling; not yet an implemented settings UI or an accepted performance certification.
- **Player-facing option:** Allow explicit selection of **0, 1 or 2 concurrent idle-video loops** in the game's graphics/accessibility settings. The value is an upper bound, not a guarantee that every card has a playable loop.
- **0 loops:** Both Active cards display approved static poster artwork; canonical combat effects and game logic are unchanged.
- **1 loop:** At most one of the two Active cards may play its optional idle loop; the other uses the static poster. **G7 will decide which card gets priority.**
- **2 loops:** Both Active cards may play optional idle loops where the source media is valid and the runtime supports playback.
- **Manual control:** No automatic capability-based quality tier switching or silent changes to the user's selected 0/1/2 setting. A playback failure, unsupported format, user-enabled reduced motion or missing media must gracefully display a static image without altering stored user preference, match logic or replay.
- **Runtime constraints:** Hard cap of two active video instances; cleanly start/stop/unload clips as Active identities change. Prevent queued cards or offscreen items from spawning idle-video decoders. Avoid blocking the ordered G5 event queue while media is loading/decoding.
- **Persistence and compatibility to spec:** Decide default, local preference versioning, cross-platform decode support, pause/resume behavior, testing budget and exact poster fallback during implementation planning. Verify on Godot desktop/web/mobile before marking this feature complete.
- **Preserved approvals:** G1 D Card-first; G2 D Hybrid animation templates + selected custom VFX; G3 C still image + GIF/video as import sources; G4 A video idle-only; G5 C hybrid sequencer.

### G7 — Priority when the manual setting is 1 video (OPEN)

**Question:** When the player configures exactly one simultaneous idle loop, which Active card gets that single animated slot?

- **A — Player's card:** Always prioritize the local player's own Active card; opponent stays on a static poster. If that card has no eligible video, the single slot remains unused unless a later rule explicitly allows fallback priority.
- **B — Current turn owner:** Animate the Active card of whichever player has the turn; switch the slot between sides when turn ownership changes.
- **C — Focused card:** Animate the currently selected/inspected Active card; when none is selected, prioritize the player's own card.
- **D — Player-selected side:** Include a second preference choosing self vs opponent (possibly adjustable mid-duel), with static fallback if no eligible loop.

**ARTIST + ARCH recommendation (NOT ACCEPTED):** A is predictable, accessible, inexpensive and avoids decoders switching sides every turn. If the user prefers dynamic attention cues, B is also feasible. No selection has been made for G7.

## References

- Constitution: `.specify/memory/constitution.md`
- Existing rules: `docs/specs/MM-02-alpha-duel-rules.md`
- Existing Godot duel: `docs/specs/MM-04-godot-duel-vertical-slice.md`
- Rights workstream: MM-07 on `docs/ROADMAP.md`
- CC0: https://creativecommons.org/publicdomain/zero/1.0/
- Wikimedia Commons reuse policy: https://commons.wikimedia.org/wiki/Commons:Licensing

## Verification

Documentation-only. G1–G6 were explicitly selected provisionally and documented; G7 and later grilling gates remain open. This does not establish implemented media playback or engine behavior. The binary import is still pending. No claim of image upload, accepted meme characters, battle-feature completion, or runtime-test result is made.
