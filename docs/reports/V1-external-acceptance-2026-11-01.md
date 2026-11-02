# V1 external acceptance preparation — 2026-11-01

## Scope and decision

This iteration audits the remaining V1 acceptance gates, records locally reproducible evidence, and keeps device, human, provider, licensing, and operational gates explicitly pending. This report does **not** declare V1 release-ready.

Owner for all currently unassigned release actions: **az1nn / Mememom**. A human reviewer or supported device operator must be named before the corresponding gate is accepted.

## Local evidence at current HEAD

Commands run from the repository worktree at exact HEAD
`cad30b3e8913f443c7f60add49942dd2e7468b0b`:

```text
npm test                         PASS
npm run test:release             PASS (same deterministic suites)
npm run build:pwa                PASS
npm run pwa:check                PASS
npm run test:infra               PASS (prior verified run)
git diff --check                 PASS
```

The generated `web/version.json` records the exact source commit and artifact
sizes: `index.wasm` 39,514,754 bytes, Brotli 7,996,785 bytes, gzip
10,153,810 bytes, and PCK 137,520 bytes. The export emitted duplicate-UID
warnings for mirrored web/Android assets, but the build and PWA validator both
passed; this warning remains worth reviewing before a release candidate.

`npm test` completed with zero failures:

| Suite | Checks |
|---|---:|
| MM-04 | 194 |
| MM-05 | 94 |
| MM-06 | 14 |
| MM-07/MM-08 | 41 |
| MM-09 | 18 |
| MM-09 server adapter | PASS |
| ART-002 navigation | 21 |
| ART-002 HUD | 19 |

The server negative fixture emits the expected refusal for an invalid Canon state before its valid fixture starts; this is expected fail-closed evidence, not a test failure. ART-002 emits known anchor warnings with zero assertion failures.

The prior [V1 verification report](V1-verification-2026-10-20.md) records the generated PWA artifact, service-worker offline reload, Chromium shell fetch, and Capacitor asset sync. Those results do not prove installation, update activation, touch acceptance, or human accessibility/visual review.

## Prompt-to-artifact gate checklist

| Requirement / named gate | Evidence or required action | State |
|---|---|---|
| Schema migration, replay fixtures, trust-boundary negatives | `npm test`; MM-07/MM-08 and MM-09 negative fixtures | **Locally verified** |
| PWA export and artifact validity | `npm run build:pwa`; `npm run pwa:check`; `web/version.json` records exact HEAD and artifact sizes | **Locally verified at `cad30b3`** |
| Browser install | Install generated `web/` artifact in the supported browser; record browser/OS, date, screenshot, install result | **Pending device/browser** |
| Browser offline launch | Existing Chromium offline reload evidence in V1 verification report; repeat on supported target | **Partial; target acceptance pending** |
| Browser update behavior | Serve version N, install, serve N+1, confirm service-worker activation and updated asset/version; record logs/screenshots | **Pending** |
| Touch navigation and responsive behavior | Exercise Forge, Collection, deck and duel flows on supported mobile/browser target; record device and screenshots | **Pending human/device** |
| Signed Android package | Provision Java + Android SDK; run `npm run android:debug` or release signing procedure; record APK checksum and signing/install output | **Blocked: toolchain/device unavailable** |
| Android smoke | Install signed APK with `adb`; complete launch, Forge, collection, deck and duel smoke; record API/device and logs | **Blocked: device/toolchain unavailable** |
| Accessibility/focus/contrast | Human review on browser and mobile targets, including keyboard focus order, touch target size, contrast and responsive layout; attach dated evidence and reviewer identity | **Pending human reviewer** |
| Original-brand review | Human reviewer confirms assets/content are original or licensed; record reviewer and source/rights evidence | **Pending human/licensing review** |
| Beta incident/privacy route | Confirm private participant route, vulnerability reporting and moderation/privacy contacts; record non-secret operational evidence | **Pending operator confirmation** |
| Deployment/retention/escalation | Record provider deployment, retention configuration and incident escalation without secrets | **Pending provider/operator evidence** |
| Final release package/tag | After all above pass, record exact commit, PWA/Android checksums, smoke outputs, and closed-beta status | **Blocked by open gates** |

## Required stop conditions

The release task must remain open while any row above is pending or partial. In particular, automated Godot/PWA checks cannot substitute for browser installation/update/touch, Android installation/smoke, accessibility, original-brand/licensing, or operational acceptance. No release tag or public launch should be inferred from this report.

## Reproduction commands

```bash
npm test
npm run test:infra
npm run build:pwa
npm run test:pwa
npm run android:debug   # only after Java/Android SDK/Gradle target is provisioned
```

The release accountability checklist remains the authoritative owner/action record; this report supplies the current local run evidence and maps each unchecked gate to a concrete next action. The local gates are current, but the release remains blocked by the explicitly pending browser, Android, human, licensing, and operations evidence above.
