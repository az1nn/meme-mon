# INFRA-01 — Smart, cost-aware Godot Web delivery

Status: PREVIEW_PIPELINE_READY_FOR_PROVIDER_INTEGRATION (preview publishing requires configured Vercel credentials; live URL remains unverified).

## Intent and user value

Deliver the existing Mememom Godot client to web hosting via one reproducible, tested artifact, avoiding unnecessary provider builds. Growing-rio is a technical pattern reference only; this is a Mememom-specific implementation and decision.

## Requirements

- R1: Preserve Godot 4.7.2 as the sole renderer and use a single-threaded Web export, no parallel JS client.
- R2: Preserve the existing MM-04 and MM-05 headless tests, compile/import and scene smoke gates before publishing.
- R3: Produce index.html/js/wasm/pck for an exact Git SHA; verify nonzero files and HTML-declared wasm/pck sizes.
- R4: Build once in GitHub Actions; both providers consume the identical tested artifact. Never push generated binary exports to the source branch.
- R5: Auto-trigger export only for relevant runtime/build changes; documentation-only commits do not use hosting deployments.
- R6: Cloudflare Worker Static Assets serves pre-compressed WASM with correct Content-Encoding, Content-Type, Vary and no-cache semantics; must fail closed on assets over the 25 MiB per-file limit.
- R7: Vercel native Git auto-deployment stays disabled. Trusted same-repository PRs automatically publish a *prebuilt* Build Output API v3 preview from GitHub Actions after exact-head CI gates; no Godot build runs on Vercel. Repository secrets VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID are mandatory. External forks never receive deployment credentials.
- R8: Cloudflare production auto-deploy is **off** until repository variable CLOUDFLARE_AUTO_DEPLOY=true is explicitly set. Manual dispatch also requires credentials. No unauthenticated deployment.
- R9: Never copy game assets, business rules, lore, or product decisions from growing-rio.
- R10: Concurrent PR builds may publish isolated preview URLs only after a verified build job, on a same-repository PR and with provider credentials. No PR modifies the production alias.
- R11: A PR deploy or a manual Vercel deployment defaults to an isolated **preview** (`vercel deploy --prebuilt` without `--prod`); pushes to master never publish Vercel automatically. Preview URLs appear in the Actions summary and are posted to the PR once HTTP checks pass.
- R12: Production Vercel requires both explicit `vercel_target=production` and `confirm_vercel_production=true` on `master` (no implicit promotion).
- R13: Successful Vercel deploys must expose the URL in the GitHub Actions summary, verify the remote `version.json.source_commit` matches the tested exact-head SHA, and check HTML and WASM HTTP response/MIME; separate browser/touch acceptance remains required.

## Acceptance

1. A trusted same-repo PR changing Godot/delivery sources runs headless tests, exports and validates the Web artifact, then publishes a Vercel preview if credentials are configured. Fork PRs publish nowhere.
2. A docs-only push to master launches no new Web export workflow.
3. The output of the same commit can be published via explicit manual workflow dispatch to Cloudflare, Vercel, or both; one export is reused.
4. A mismatched index.pck/index.wasm metadata value, missing artifact, oversize Cloudflare asset, or missing credential fails the job.
5. Cloudflare /index.wasm negotiates br or gzip; unsupported clients receive a clear 406 rather than broken binary content.
6. Vercel Build Output API v3 includes raw wasm and an explicit WASM MIME type.
7. Site runtime browser validation (navigation, screen sizes, accessibility, network response, correct version.json) is a separate release gate; headless export alone is not visual acceptance.
8. All PR Vercel deploys are Preview; manually requested Vercel deploys also default to Preview. An unconfirmed production selection or non-master source fails closed.
9. On deployment, record the Vercel URL, assert the served exact-head manifest, root `/` HTML, JS/PCK HTTP availability and WebAssembly Content-Type (including protected previews); comment the verified link on same-repository PRs.

## Non-goals

- No Vercel/Cloudflare account creation, secret extraction, DNS change, domain cutover, purchasing a plan, UGC services, Worker KV/R2, or game feature changes.
- No guarantee of zero cost after provider limits/terms change. No promise of unlimited Worker or Vercel quotas.

## Risk

- Godot wasm over 25 MiB cannot upload raw to Cloudflare Free static assets; compressed representations mitigate this. If compressed payload or pck still exceeds the cap, stop publishing instead of auto-purchasing services.
- A GitHub artifact-only green check is not a playable browser smoke test.
- Version pin changes need a dedicated PR and regeneration of checksum/template cache key.
