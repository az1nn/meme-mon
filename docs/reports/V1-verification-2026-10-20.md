# V1 verification report — 2026-10-20

## Exact revision

- Commit: `35593b237d0b964ea88dc7855f9f60412318cfbf`
- Engine: Godot `4.7.2.stable.official.ed1daf0bf`
- Scope: local automated gates and generated Web/PWA/Capacitor artifacts

## Automated results

| Gate | Result |
|---|---:|
| MM-04 deterministic duel | 194 checks, 0 failures |
| MM-05 collection/deckbuilder | 94 checks, 0 failures |
| MM-06 private Forge | 14 checks, 0 failures |
| MM-07/MM-08 moderation and Canon | 39 checks, 0 failures |
| MM-09 authoritative reference | 14 checks, 0 failures |
| MM-09 WebSocket fail-closed/listen smoke | PASS on port 19080 |
| ART-002 navigation | 21 checks, 0 failures |
| ART-002 HUD | 19 checks, 0 failures |
| Main, Collection, Forge scene smoke | PASS |
| Godot Web export and PWA validator | PASS |
| Capacitor Android asset sync | PASS |
| Chromium PWA shell fetch smoke | PASS for required HTTP assets |

The Web artifact records 39,514,754 raw WASM bytes, 7,996,785 Brotli bytes,
10,153,810 gzip bytes, and 130,576 PCK bytes in `web/version.json`. The same
metadata is present under `android/app/src/main/assets/public/` after sync.

Chromium 149 fetched `index.html`, `index.js`, `index.pck`, `index.wasm`, the
manifest, service worker, icon, and audio worklets from a local HTTP server with
HTTP 200 responses. The Godot page did not produce a screenshot within the
30-second headless window, so this is only a shell-serving result, not proof of
runtime rendering, installability, offline behavior, or visual acceptance.

## Gates not proven here

- Android APK compilation/install/smoke is blocked in this workspace because no
  Java runtime, Android SDK, or `adb` is installed.
- Browser install, offline launch/update behavior, and touch/device acceptance
  still require a supported browser or Android target.
- Human visual, accessibility, focus, contrast, and original-brand review is
  still pending; headless checks do not substitute for that acceptance.
- Cloudflare/Vercel live deployment and public moderation/security routes were
  not exercised or enabled.

This report is evidence for the implementation gates only. It does not declare
the V1 release ready or close the linked human, device, or operational issues.
