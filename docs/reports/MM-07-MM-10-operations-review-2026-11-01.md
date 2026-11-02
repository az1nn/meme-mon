# MM-07 to MM-10 operational and policy review — 2026-11-01

## Decision

The deterministic implementation slice is independently reviewable, but MM-07 through MM-10 are **not operationally accepted**. No hosted service, public UGC program, public release, or contributor/release-process walkthrough is claimed. The remaining external gates have explicit owners and evidence actions below.

**Owner:** az1nn / Mememom. The operator must assign/confirm beta moderators and incident coverage before opening the closed beta, and must retain dated evidence with the release package.

## Exact-head local evidence

Reviewed exact current HEAD: `b7e0e8591bfa5fed0fc6b10a12925196a1de98a1` on `ralph/v1-work` (2026-11-01). This is a documentation-only refresh after the source/test commit; no implementation changes are hidden by the review.

Commands:

- `npm test` — PASS at the exact current HEAD: MM-04 194/0, MM-05 94/0, MM-06 14/0, MM-07/MM-08 41/0, MM-09 18/0, MM-09 server adapter PASS, ART-002 navigation 21/0, ART-002 HUD 19/0.
- `npm run pwa:check` and `npm run test:infra` — PASS (`PWA artifact PASS`; Node syntax checks clean).
- `git diff --check` — PASS.
- `bash -n ralph.sh scripts/lib/*.sh tools/ralph-merge.sh` — PASS.

A concurrent/rapid repeat of the server fixture once encountered port `19080` still busy; no listener remained afterward and a clean serial rerun passed. This is recorded as an environment/test-harness flake, not suppressed as a product failure.

## Prompt-to-artifact checklist

| Requirement | Evidence | State |
|---|---|---|
| MM-07 provenance, moderation transitions, reports and audit | `src/domain/submission_moderation_model.gd`, `src/domain/submission_store.gd`, MM-07/MM-08 headless suite | Locally verified; privacy/abuse workflow still human |
| MM-08 immutable Canon publication and fail-closed legality | `src/domain/canon_model.gd`, `src/domain/canon_deck_validator.gd`, MM-07/MM-08 and MM-09 suites | Locally verified; operator/public-content release still pending |
| MM-09 protocol/replay/reference authority and fail-closed adapter | `src/domain/authoritative_match_service.gd`, `server/authoritative_websocket.gd`, MM-09 suite and server fixture | Reference implementation verified; hosted operations/client transport/load acceptance pending |
| MM-10 governance, reporting and closed-beta policy artifacts | `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `docs/policies/`, `.github/ISSUE_TEMPLATE/content-report.yml`, accountability checklist | Files present; contributor/report/release walkthrough pending |
| Privacy, retention and moderation/appeal decisions | `docs/policies/closed-beta-operating-policy.md`, MM-07 task graph | Policy baseline exists; named beta contacts, retention confirmation and human workflow evidence pending |
| Service identity, hosting, incident owner and deployment evidence | `docs/tasks/MM-09-online-match-protocol.md`, release accountability checklist | **Pending operator decision and deployment evidence** |
| First-party asset licensing and public contact routes | `LICENSE`, `SECURITY.md`, release checklist | **Pending explicit asset/license and verifiable moderation/privacy contact confirmation** |
| Android/browser/accessibility/runtime acceptance | V1 external acceptance report and release checklist | **Pending supported device/browser and human reviewer; not inferred from CI** |

## Required external actions

1. **MM-07 privacy and abuse safety — owner: az1nn + assigned moderator.** Confirm retention/deletion duration, abuse escalation, appeal handling, and a dated moderation walkthrough using representative submission/report cases. Store the evidence without personal data.
2. **MM-08 operator/public content — owner: az1nn + Canon operator.** Confirm signer/rotation authority, suspension and retention procedures, and review a publish/withdraw/suspend drill against an immutable edition and replay reference.
3. **MM-09 service operations — owner: az1nn.** Name identity/hosting/incident owners, deploy only to a controlled closed-beta environment, document retention/log handling and reconnect/load/security smoke evidence. Do not claim hosted readiness from the reference fixture.
4. **MM-10 contributor/report/release process — owner: az1nn + maintainer.** Walk through a contribution, content report, security report and release rollback/escalation using the repository templates; record dates and participants. Adopt/confirm first-party asset licensing before public distribution.
5. **V1 external gates — owner: az1nn + human reviewer.** Keep PWA install/update/offline/touch, Android signed install, accessibility/visual review, public contacts, deployment and release checksum/tag evidence open until dated artifacts exist.

## Non-blocking follow-up findings

- The reference WebSocket adapter is intentionally not a hosted service and has no Godot client transport/reconnect UI; implementing those is a separate MM-09 delivery task, not a reason to mislabel this review.
- A stale 2026-10-18 reference report listed 38 MM-07/MM-08 and 14 MM-09 checks. This review records the current exact-head counts (41 and 18).
- The transient port contention should be made more robust in a later test-harness cleanup if it recurs; it does not change the fail-closed product result.

Until the dated actions above are complete, MM-07/MM-08/MM-09/MM-10 remain technically evidenced but operationally pending, and V1 release closure must remain open.
