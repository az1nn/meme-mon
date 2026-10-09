# ARTIST-003 — V1 visual baseline and battle-character grilling

**Status:** CARTOON-FIRST BATTLE MOCKUP APPROVED 2026-10-09; G1–G9 PRESERVED; G10 OPEN; IMAGE BINARY IMPORT PENDING  
**Date:** 2026-10-08  
**Scope:** Mememom; Godot-only runtime; documentation/art-direction decision record.

## Approval matrix

| Surface | Decision | Scope |
| --- | --- | --- |
| Mobile-first menus, card layout, visual hierarchy, color and navigation | APPROVED V1 | The recent ARTIST contact sheet is the approved structural/style reference. Navigation should be hidden in an accessible hamburger menu; no fixed menu rail on phones. |
| Battle environment/composition and broad visual quality | APPROVED V1 BASELINE | Presentation layout only, not a rule-system replacement. |
| Cartoon refinement / graffiti restraint | APPROVED 2026-10-09 | Current visual baseline: polished cartoon shapes, cleaner colorful stage, restrained graffiti accents. Approval covers visual reference, not final character rights or implemented UI. |
| Characters, specific memes and creature identities appearing in the mockup | NOT APPROVED | Concept placeholders only; independently select legally usable and recognizably original combatants. |
| Mockup logo and any franchise-resembling branding | REJECTED AS FINAL BRANDING | Create a distinct Mememom wordmark, emblem, iconography and battle vocabulary; never reproduce Pokémon/Digimon/Pokémon Center trade dress or familiar proprietary symbols. |
| Battle character representation | G1 — PROVISIONAL: D / CARD-FIRST | Animated illustrated cards are the on-screen combatants. No 3D character models required in V1. This is not a final engine specification. |
| Card animation architecture | G2 — PROVISIONAL: D / HYBRID | Reusable modular animations are the default; special cards may have curated unique visual animations. No arbitrary gameplay code embedded in card assets. |
| Accepted animation media | G3 — PROVISIONAL: C / STILL + VIDEO | Still art plus curated GIF/video sources through validated conversion/optimization before Godot runtime use, always with still-frame fallback. |
| Runtime video use | G4 — PROVISIONAL: A / IDLE LOOP ONLY | Optional looping animation within the currently Active card; attack, hit, KO and special-action effects use Godot's shared animation/VFX system, not event-specific video clips. |
| Visual event synchronization | G5 — PROVISIONAL: C / HYBRID EVENT SEQUENCER | Critical combat beats are presented in canonical event order; lightweight idle loops and ambient UI can continue asynchronously. Visual playback never mutates or blocks deterministic game rules. |
| Idle-loop resource allocation | G6 — PROVISIONAL: D / MANUAL 0–2 | Player sets a maximum of 0, 1 or 2 simultaneous Active-card idle clips; no automatic quality-tier switching. Visual failure remains nonblocking and uses a static fallback. |
| One-slot video priority | G7 — PROVISIONAL: B / TURN OWNER | When set to 1, the current turn owner's Active card gets the optional idle-video slot, switching on authoritative turn change, with static fallback. |
| Initial idle-video preference | G8 — PROVISIONAL: A / ZERO VIDEOS | New profiles initialize with zero idle-video loops; the player can explicitly enable one or two via the manual setting. Shared Godot attack/hit/KO VFX remain available. |
| Starter meme catalog policy | G9 — PROVISIONAL: D / PRIVATE FIRST | No public meme starter pack at first. Use neutral, internally controlled playtest fixtures and private Forge/Sandbox; curate a public catalog only after MM-07 rights and moderation gates. |

## Approved cartoon refinement — 2026-10-09

**Human gate:** APPROVED — latest cartoon-first MemeMon battle mockup after explicitly rejecting the prior over-graffiti version.

**Approval scope:** visual art direction, composition reference, cartoon polish and overall battle-screen readability. This replaces the graffiti-heavy **rendering direction** with a cleaner cartoon emphasis; it does **not** revoke the prior approved mobile-first information architecture or the G1–G9 gameplay/presentation decisions.

### Visual contract for future ARTIST work

- **Primary look:** polished playful **2D cartoon**, strong clear outlines, warm rounded volumes, readable expressions, intentional highlights and bright but controlled palette. Game UI feels premium, approachable and friendly for children/teens.
- **Graffiti is accent, not the visual foundation:** at most sparing paint splashes/stickers/brush accents for brand character. Avoid wall-to-wall tags, busy textures, high-noise backgrounds and gratuitous street-art ornament.
- **Stage environment:** simplified colorful urban rooftop / tropical Rio-inspired setting in painterly cartoon form; reserve uncluttered negative space around the Active cards and interaction controls. Environment should not overpower the combatants.
- **Cards:** high-contrast readable silhouettes, expressive art, restrained frames, meaningful color distinctions and stable readability over backgrounds. Preserve G1 D Card-first.
- **Controls:** large touch targets, unmistakable states and concise Portuguese labels. Player navigation is **hamburger-menu driven on mobile**; the approved wide mockup is a conceptual battle composition, not permission to ship a fixed visible navigation rail on phone.
- **Runtime:** Godot-only V1 browser-local / in-memory. Idle-card video is optional, OFF by default (G8 A); common Godot attack/hit/KO effects follow the G5 C hybrid sequencer. Do not imply the image depicts implemented interactions.
- **Originality and asset rights:** Characters/names, specific meme likenesses, iconography and the provisional logo in the illustration are still **concept art**, not independent content-licensing, trademark clearance, final mascot acceptance or permission for a public V1 meme catalog. G9 D private-first and MM-07/MM-08 gates remain binding.

### Exact approved visual reference

- **Source:** latest MemeMon cartoon revision generated and explicitly approved in the conversation on **2026-10-09** (following user feedback "exagerou no graffiti, vamos para mais cartoon").
- **Source PNG filename:** `batalha_mememon_no_terraço_tropical.png`.
- **Image size:** **1672 × 941** pixels; RGB PNG.
- **Source SHA-256:** `6a7bebaf11705e8b42614813faf04169a121b6a9c640055824c9f8feea44c2b3`.
- **Target repository file:** `docs/art/references/ARTIST-003-v2-cartoon-battle-approved.png`.
- **Binary import state: PENDING.** The exact image exists in the conversation attachment, but has **not** been committed to the GitHub branch. Avoid implying it is already versioned or replacing source bytes with unverified substitutes.
- **Older references:** Keep the initial approved structural/style contact sheet provenance below for audit; the newer approved cartoon variant **supersedes graffiti-heavy rendering** as the current artistic direction without automatically settling brand/character rights.

### Next ARTIST verification

A final battle implementation must be reviewed on **actual mobile portrait viewport and responsive web**, not just the 1672×941 landscape composition, and must respect Godot performance, accessible hit targets, reduced-motion settings and the private-only V1 meme catalog. No runtime/art implementation is approved by recording this art gate.

## Original generated reference asset

- Source: ARTIST image generated in the Mememom DEV conversation on 2026-10-08.
- Original filename: `a_vibrant_polished_cartoon_illustration_ui_concep.png`.
- Original dimensions: **1536 × 1024 PNG**.
- Original SHA-256: `cfcd814e930fa6924e211df6a2df31bd374797fa27262b21817329ec142135a5`.
- Intended repository path for the visual binary: `docs/art/references/ARTIST-003-v1-menus-battle.png`.
- **Binary import status: PENDING.** This record documents the source and approved elements; it does not misrepresent the reference PNG as committed. The asset must be uploaded without alteration or verified with the recorded SHA-256.

## V1 deployment/runtime boundary — offline browser and in-memory (2026-10-08)

**Decision from product owner:** V1 starts **offline in browser or in-memory**. Treat this as a cross-cutting launch constraint, not an extra G10 vote or a request to implement a second client.

- **Primary playable target:** Godot 4.x Web export loaded into a browser. All required duel state, rule resolution, deterministic local-bot decisions, event sequencing and card presentation execute client-side. A fully in-memory match is valid without account, network APIs or persistent storage.
- **No service in the V1 critical path:** Do not require authentication, online matchmaking, cloud profile sync, remote databases, centrally hosted UGC, media-stream endpoints, ranking services or moderation APIs to start and finish a local duel. An optional hosting/CDN endpoint can deliver a built game but cannot own gameplay truth.
- **Persistence:** Keep existing local Godot `user://` profile support when available. Browser storage persistence is an optional enhancement/fallback path, not a precondition for playing. If storage is unavailable, deny persistent save clearly while allowing an in-memory match; do not silently claim saves survive refresh.
- **Browser offline semantics:** A first navigation to a deployed web URL may require a network request to fetch the Godot bundle. Finishing a loaded match with the network disabled is an acceptance target. Cold-start/reopen while physically offline needs a separately specified and verified cache/service-worker packaging contract and is **not** claimed complete by this decision.
- **Asset behavior:** Required rules, fixtures, posters and presentation templates belong in the packaged client; user-imported local media remains local by default. Video idle loops are optional per G3/G4/G6/G8 and must not require remote playback or delay the duel.
- **Roadmap alignment:** MM-06 implements a private local Forge; MM-07/MM-08 public rights review and Canon publication remain future gates; MM-09 online match protocol is not needed for V1 offline play. INFRA-01 Cloudflare/Vercel is optional delivery infrastructure, not an authoritative game server.
- **Testable future gates:** Godot Web can start and complete a local duel against the bundled bot with service endpoints unavailable; rule/event replay remains deterministic; absence of storage does not prevent a match; local media never uploads silently; browser compatibility is measured and reported before claiming completion.
- **Authority:** `docs/decisions/ADR-0002-browser-local-first-v1.md` records this product direction alongside the existing Godot-only and deterministic-domain constitution. This ARTIST record does not modify G1–G9 or answer G10.

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
- **1 loop:** At most one of the two Active cards may play its optional idle loop; the other uses the static poster. **G7 provisionally selects the current turn owner's Active card for that slot.**
- **2 loops:** Both Active cards may play optional idle loops where the source media is valid and the runtime supports playback.
- **Manual control:** No automatic capability-based quality tier switching or silent changes to the user's selected 0/1/2 setting. A playback failure, unsupported format, user-enabled reduced motion or missing media must gracefully display a static image without altering stored user preference, match logic or replay.
- **Runtime constraints:** Hard cap of two active video instances; cleanly start/stop/unload clips as Active identities change. Prevent queued cards or offscreen items from spawning idle-video decoders. Avoid blocking the ordered G5 event queue while media is loading/decoding.
- **Persistence and compatibility to spec:** G8 provisionally fixes the unset-profile default at **0 videos**. Local preference schema/versioning, cross-platform decode support, pause/resume behavior, testing budget and exact poster fallback remain implementation decisions. Verify on Godot desktop/web/mobile before marking this feature complete.
- **Preserved approvals:** G1 D Card-first; G2 D Hybrid animation templates + selected custom VFX; G3 C still image + GIF/video as import sources; G4 A video idle-only; G5 C hybrid sequencer.

### G7 — Current turn video priority (2026-10-08)

- **Answer:** B — Current turn owner.
- **State:** PROVISIONAL / user-selected during grilling. This is an ARTIST presentation behavior decision, not implemented runtime support.
- **Rule for user setting 1:** At most one optional Active-card idle video plays: the Active card belonging to the authoritative **current turn owner**, regardless of whether that owner is local player or opponent. The other Active card displays its poster frame.
- **Switching:** On a canonical domain turn-owner change (`MatchEvent` / `MatchState`), stop/release the previous side's idle animation, present its static poster and only then start the new turn owner's eligible idle animation. Avoid overlapping decoders that would violate the selected one-video cap.
- **Fallback:** If the turn owner's card has no eligible/decodable loop, it stays static; do not silently animate the non-turn owner's card. Playback errors never modify state, event order or persistent quality preference.
- **Other G6 settings unchanged:** 0 means no idle videos; 2 allows both Active cards to run approved idle loops. G7 only governs the **1-video** setting.
- **Separation of concerns:** Video priority is derived from validated rule state but cannot write back to turn ownership, turn timing, RNG, legal intents or any competitive data. G5 critical visual beats remain ordered and functional without video.
- **Accessibility / performance:** Preserve static fallback and reduced-motion overrides. No automatic quality-tier selection or automatic rewriting of the user's 0/1/2 setting.
- **Preserved decisions:** G1 D Card-first; G2 D Hybrid; G3 C still image + animated video inputs; G4 A idle video only; G5 C hybrid event sequencer; G6 D manually selected 0/1/2 concurrent loops.

### G8 — Default idle-video count (2026-10-08)

- **Answer:** A — 0 idle videos by default.
- **State:** PROVISIONAL / explicitly selected by user during grilling; not yet an implemented settings screen or video decoder.
- **First run / unset profile:** Initialize the graphics preference to **0 concurrent idle-video loops**. Both Active cards present approved still/poster images, without requiring a first-launch prompt or a playback capability check.
- **Manual opt-in:** Players may explicitly choose **1** or **2** loops in settings per G6. For **1**, G7 still assigns priority to the current turn owner's Active card; for **2**, both Active cards are eligible if they have valid media. The choice persists using a future versioned preference contract; an unset profile is not equivalent to an explicit prior choice.
- **Animation semantics:** Disabling **idle video** does **not** disable standard event-driven Godot attack/hit/KO animations from G2/G5. Reduced-motion accessibility must be handled separately and can suppress motion as required.
- **No auto override:** Do not automatically change a saved 0/1/2 preference based on device heuristics. Failed media falls back to static without altering the selected setting or competitive events.
- **Implementation gates:** Specify schema/storage location, default migration behavior, full Godot Web/mobile decode fallback and player-facing labels before claiming feature completion.
- **Preserved decisions:** G1 D Card-first; G2 D Hybrid animations; G3 C image/video import; G4 A idle-video-only; G5 C hybrid event sequencing; G6 D manual 0/1/2 control; G7 B one-slot priority follows turn owner.

### G9 — Deferred public starter catalog (2026-10-08)

- **Answer:** D — No public meme starter pack initially.
- **State:** PROVISIONAL / user explicitly selected D during grilling; not a published content-policy implementation.
- **Initial playable content:** Use only neutral, internally controlled fixture art sufficient for the existing deterministic duel, collection and upcoming Godot Forge tests. Fixture cards are not public meme Canon, rights-approved public assets, community releases, or evidence that any recognizable external meme may be shipped.
- **Private-first creation:** Follow the existing MM-06 intent: local/private Sandbox Forge supports meme media import/crop, name, type and constrained preview without automatic public sharing or competitive Canon promotion. A private upload is not proof of copyright ownership or lawful onward redistribution.
- **Public catalog gate:** Do not seed or advertise an official public meme pack until MM-07 provenance and moderation procedures and MM-08 immutable Canon/versioning gates are satisfied as appropriate, with documented sources/licenses, review of trademarks/likeness and distribution/adaptation permissions.
- **What 'collecting suggestions' means:** Candidate media and submissions remain non-public and unapproved; opt-in collection/central submission are **not** silently authorized by this decision. G10 will determine when/how much rights information a private Forge asks for.
- **Privacy/security:** No external image fetch/upload or central publication is implied by simply importing local art. Treat unknown rights as non-publishable; do not assume that CC0/claimed public domain clears trademark or publicity rights.
- **Preserved decisions:** G1 D Card-first; G2 D hybrid motion/VFX; G3 C images + imported GIF/video sources; G4 A idle-only video; G5 C event-sequenced critical effects; G6 D manual 0/1/2 loops; G7 B turn-owner priority for one loop; G8 A default zero videos.
- **Implementation boundary:** Documentation/ARTIST direction only. MM-06 (Forge), MM-07 (provenance/moderation) and MM-08 (Canon/editions) preserve their separate dependency gates.

### G10 — Provenance collection timing in the private Forge (OPEN)

**Question:** At which stage should the private Meme Forge request source and usage-rights information for an imported meme? A user creating private artwork should not accidentally publish it.

- **A — From first import (strict):** The private Forge requires source URL/creator, license or rightsholder declaration and supporting evidence before accepting any image. Strong provenance from day one; more friction.
- **B — Only when submitted for review:** The local private Forge accepts an import without provenance; publishing/submitting to an official moderation queue requires all rights/evidence fields first.
- **C — Only at Canon approval:** No provenance input in private Forge or candidate submission; reviewers obtain complete evidence later before Canon publication. Easiest early flow but generates moderation rework.
- **D — Progressive capture:** At local import request lightweight origin/rights indication (including 'unknown'; still allowed **privately**); detailed source, permissions, evidence and screening become mandatory **before** any candidate enters the future official public review pipeline. Unknown/unverified entries can never be promoted automatically.

**ARTIST + DESIGN + ARCH recommendation (NOT ACCEPTED):** D — fast private creativity, early provenance hints, and a firm fail-closed legal gate before public review or Canon. This does not authorize a public submission service in MM-06; workflow gating remains MM-07/MM-08 scope.

## References

- Constitution: `.specify/memory/constitution.md`
- Existing rules: `docs/specs/MM-02-alpha-duel-rules.md`
- Existing Godot duel: `docs/specs/MM-04-godot-duel-vertical-slice.md`
- Rights workstream: MM-07 on `docs/ROADMAP.md`
- CC0: https://creativecommons.org/publicdomain/zero/1.0/
- Wikimedia Commons reuse policy: https://commons.wikimedia.org/wiki/Commons:Licensing

## Verification

Documentation-only. The latest 2026-10-09 cartoon-first battle artwork has explicit visual approval, independently from the older structural reference. G1–G9 were selected provisionally and documented; G10 and later grilling gates remain open. Neither approved reference PNG binary is yet committed. This does not establish implemented media playback or engine behavior. No claim of image upload, accepted meme characters, battle-feature completion, or runtime-test result is made.
