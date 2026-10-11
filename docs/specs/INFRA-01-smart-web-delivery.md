# INFRA-01 — Smart, cost-aware Godot Web delivery

Status: READY_FOR_PROVIDER_INTEGRATION (CI verified, no live deployment; does not reorder MM-06).

## Intent and user value

Deliver the existing Mememom Godot client to web hosting via one reproducible, tested artifact, avoiding unnecessary provider builds. Growing-rio is a technical pattern reference only; this is a Mememom-specific implementation and decision.

## Requirements

- R1: Preserve Godot 4.7.2 as the sole renderer and use a single-threaded Web export, no parallel JS client.
- R2: Preserve the existing MM-04 and MM-05 headless tests, compile/import and scene smoke gates before publishing.
- R3: Produce index.html/js/wasm/pck for an exact Git SHA; verify nonzero files and HTML-declared wasm/pck sizes.
- R4: Build once in GitHub Actions; both providers consume the identical tested artifact. Never push generated binary exports to the source branch.
- R5: Auto-trigger export only for relevant runtime/build changes; documentation-only commits do not use hosting deployments.
- R6: Cloudflare Worker Static Assets serves pre-compressed WASM with correct Content-Encoding, Content-Type, Vary and no-cache semantics; must fail closed on assets over the 25 MiB per-file limit.
- R7: Vercel Git auto-deployment disabled. Vercel publish is manual from prebuilt Build Output API v3, with no Godot build on Vercel.
- R8: Cloudflare production auto-deploy is **off** until repository variable CLOUDFLARE_AUTO_DEPLOY=true is explicitly set. Manual dispatch also requires credentials. No unauthenticated deployment.
- R9: Never copy game assets, business rules, lore, or product decisions from growing-rio.
- R10: Concurrent PR validation must not silently publish; separate deploy jobs require a verified build job and platform credentials.
- R11: A manual Vercel deployment defaults to an isolated **preview** (`vercel deploy --prebuilt` without `--prod`); no PR/push may publish Vercel automatically.
- R12: Production Vercel requires both explicit `vercel_target=production` and `confirm_vercel_production=true` on `master` (no implicit promotion).
- R13: Successful Vercel deploys must expose the URL in the GitHub Actions summary, verify the remote `version.json.source_commit` matches the tested exact-head SHA, and check HTML and WASM HTTP response/MIME; separate browser/touch acceptance remains required.

## Acceptance

1. A PR changing Godot sources runs headless tests, Web export and artifact integrity checks, but publishes nowhere.
2. A docs-only push to master launches no new Web export workflow.
3. The output of the same commit can be published via explicit manual workflow dispatch to Cloudflare, Vercel, or both; one export is reused.
4. A mismatched index.pck/index.wasm metadata value, missing artifact, oversize Cloudflare asset, or missing credential fails the job.
5. Cloudflare /index.wasm negotiates br or gzip; unsupported clients receive a clear 406 rather than broken binary content.
6. Vercel Build Output API v3 includes raw wasm and an explicit WASM MIME type.
7. Site runtime browser validation (navigation, screen sizes, accessibility, network response, correct version.json) is a separate release gate; headless export alone is not visual acceptance.
8. A manually requested Vercel deploy with default inputs uses Preview, never Production; an unconfirmed production selection or non-master source fails closed.
9. On deployment, record the Vercel URL and check the served exact-head manifest, HTML availability and WebAssembly Content-Type, including protected previews when provider permits.

## Non-goals

- No Vercel/Cloudflare account creation, secret extraction, DNS change, domain cutover, purchasing a plan, UGC services, Worker KV/R2, or game feature changes.
- No guarantee of zero cost after provider limits/terms change. No promise of unlimited Worker or Vercel quotas.

## Risk

- Godot wasm over 25 MiB cannot upload raw to Cloudflare Free static assets; compressed representations mitigate this. If compressed payload or pck still exceeds the cap, stop publishing instead of auto-purchasing services.
- A GitHub artifact-only green check is not a playable browser smoke test.
- Version pin changes need a dedicated PR and regeneration of checksum/template cache key.
