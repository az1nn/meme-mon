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
              +--> Vercel Build Output API v3 (manual backup only)
                      |- raw wasm copied as static
                      |- prebuilt deploy; Git auto deploy disabled
```

## Build ownership and intelligent triggers

- The existing headless workflow continues its own independent PR/master quality gate.
- The Web delivery workflow is selected by Godot/infra path filters, not docs, and uses concurrency grouping.
- The export artifact is not committed; the deploy jobs download the same validated artifact.
- Cache the **matching** Godot 4.7.2 export templates; verify editor download via pinned SHA-256.
- The Worker handles only /index.wasm; other routes go directly to Static Assets.
- Cloudflare production auto-deploy is a deliberate repo variable, default off; Vercel backup is never automatically triggered by a push.

## Human-only integration gate

Set Cloudflare Secrets CLOUDFLARE_API_TOKEN/CLOUDFLARE_ACCOUNT_ID. For automated master publish, additionally set repository Variable CLOUDFLARE_AUTO_DEPLOY=true. The Worker name defaults to `mememom` and can be changed only through a dedicated reviewed change.

For Vercel, create/link a project (Framework: Other), set secrets VERCEL_TOKEN, VERCEL_ORG_ID and VERCEL_PROJECT_ID; keep native Git deployments disabled. Trigger the workflow's `publish=vercel` input only for an intentional backup deployment.

## Verification

1. Inspect YAML, JSON and JS syntax.
2. Run exact-head Godot tests, export, metadata check, compression and packaging in CI.
3. Check no publication on PR.
4. Enable only credentials/destination needed, confirm deployed `/version.json` SHA, `/index.wasm` response headers and browser game loop before any production alias/domain change.
