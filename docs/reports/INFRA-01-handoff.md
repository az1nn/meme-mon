# INFRA-01 handoff (Mememom only)

STATE: READY_FOR_PROVIDER_INTEGRATION

RECONCILE: `az1nn/meme-mon`; Godot 4.7.2; Web export is now available. MM-06 remains NEXT in the product roadmap.

CLASSIFY: ARCH/Web delivery code VERIFIED; external live delivery WATCH until authorized Cloudflare/Vercel connections are configured.

DONE: One source-to-Web artifact on GitHub Actions, path-based triggers, cached Godot templates, original MM-04/MM-05 regression gates, WASM Brotli/gzip compression, Cloudflare Worker Static Assets, Vercel prebuilt output and Vercel Git auto deploy disabled.

VERIFY: run 37829809965 completed successfully for code HEAD 7bb4115711af281d8270fd588275b04763100367. See INFRA-01-verification.md. No provider deployment occurred.

HUMAN GATES:
- Cloudflare: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`; optionally enable `CLOUDFLARE_AUTO_DEPLOY=true` when master auto-production is actually desired.
- Vercel: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`; publish only through manual `workflow_dispatch` selection.
- Verify deployed URLs/browser gameplay/mobile UX before moving a public domain.

DO NOT:
- Automatically buy a paid plan, introduce R2, switch engine, copy growing-rio content, or declare live delivery green based only on CI.
- Re-enable Vercel Git deploy and thus spend quota for docs-only changes.

NEXT: Merge after green exact PR-head checks; configure one provider only when authorized; deploy from Actions then perform live smoke. Continue MM-06 as the separate product workstream.
