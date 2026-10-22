# INFRA-01 technical plan

## Architecture

```text
Godot source + spec/CI checks
      |
      v
GitHub Actions (source path filter + exact commit; MM-04/MM-05 regression)
      |
      v
Godot 4.7.2 single-thread Web export -> web/index.{html,js,pck,wasm}
      |
      v
Validate metadata, compress wasm, 25 MiB gates, version.json
      |
      +--> Verified GitHub Actions artifact (1-day retention)
              |
              +--> Cloudflare Worker + Static Assets (primary, optional auto)
              |       |- raw wasm excluded
              |       |- br/gzip negotiated at /index.wasm
              |
              +--> Vercel Build Output API v3 (trusted PR preview + manual dispatch)
                      |- raw wasm copied as static
                      |- prebuilt PREVIEW by default (unique URL; no production alias)
                      |- PRODUCTION only on master + explicit confirmation
                      |- verify remote SHA, /, index.html, JS/PCK, WASM Content-Type
                      |- Git auto deploy disabled
```

## Build ownership and intelligent triggers

- The existing headless workflow continues its own independent PR/master quality gate.
- The Web delivery workflow is selected by Godot/infra path filters, not docs, and uses concurrency grouping.
- The export artifact is not committed; the deploy jobs download the same validated artifact.
- Cache the **matching** Godot 4.7.2 export templates; verify editor download via pinned SHA-256.
- The Worker handles only /index.wasm; other routes go directly to Static Assets.
- Cloudflare production auto-deploy is a deliberate repo variable, default off. Vercel native Git auto-deployment stays off; GitHub Actions publishes previews on trusted same-repo PRs only after export/tests. Forks cannot access provider secrets. Pushes to master do not publish to Vercel.

## Human-only integration gate

Set Cloudflare Secrets CLOUDFLARE_API_TOKEN/CLOUDFLARE_ACCOUNT_ID. For automated master publish, additionally set repository Variable CLOUDFLARE_AUTO_DEPLOY=true. The Worker name defaults to `mememom` and can be changed only through a dedicated reviewed change.

For Vercel, create/link a project (Framework: Other) and set repository secrets VERCEL_TOKEN, VERCEL_ORG_ID and VERCEL_PROJECT_ID; keep native Git deployments disabled. Every trusted same-repository PR that triggers the Web delivery workflow automatically receives an isolated Vercel Preview after its exact-head build passes; a verified URL is written to the Actions summary and PR. Forks do not publish. To publish a manual preview, use GitHub Actions → **Godot Web artifact and controlled delivery** → **Run workflow** (`master`), set `publish=vercel` and leave `vercel_target=preview`. To publish Production, explicitly choose `vercel_target=production` **and** `confirm_vercel_production=true` on `master`. Credentials/account setup cannot be inferred from CI-only runs. Missing credentials fail visibly rather than returning a misleading green preview status.

## Verification

1. Inspect YAML, JSON and JS syntax.
2. Run exact-head Godot tests, export, metadata check, compression and packaging in CI.
3. Check isolated Preview publication on same-repository PRs only; no publication on forks or PR production aliases.
4. Manual or PR Preview deployment publishes a unique URL into GitHub Actions summary; PRs also receive an idempotent preview comment. `vercel curl` validates deployed `/version.json` against exact checkout HEAD, `/`, `/index.html`, `/index.js`, `/index.pck` and WASM `Content-Type: application/wasm`. This supports protected previews via Vercel's CLI authorization.
5. Verify mobile portrait/landscape touch, navigation, deckbuilder and duel **in browser** as a distinct human gate; CI HEADLESS PASS is insufficient.
6. Production requires deliberate target and confirmation on master. Never use `--prod` for default Preview deployment.
