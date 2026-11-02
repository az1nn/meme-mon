# Pi/Ralph execution package — LOOP-001 origin remediation

**Status:** PREPARED / NOT RUN  
**Created:** 2026-11-02  
**Repository:** `az1nn/meme-mon`  
**Audited baseline:** `origin/master@1f465f9c7654499b16cd3dc01ba43a2d882fd1c5`  
**Canonical source:** [LOOP-001 remediation tasks](../../tasks/LOOP-001-origin-pendencias-2026-11-02.md) (18 IDs), [original Spec Kit roadmap](../../tasks/LOOP-001-mememon-roadmap.md), [existing Pi guide](../../../PI-LOOP.md).

## Handoff

A portable ZIP named `mememon-ralph-loop-001.zip` was generated for local extraction at the repository root. The ZIP contains:
```text
INSTALL.md
.ralph/tasks/loop-001-origin-remediation/
  RALPH.md
  TASKS.md
  WORK_REPORT.md
  RALPH_PROGRESS.md
  OPEN_QUESTIONS.md
  README.md
```

The `.ralph/` directory is intentionally ignored by Git; the package is delivered separately, and this manifest is the versioned handoff. **Do not add `.ralph-runner` states, credentials or local logs to Git.** Avoid extracting over an active session folder.

**Archive SHA-256:** `289a84d35f58f77d86a27bf941639bb810d8863fddbc5c7685355cf45ed62c92`  
**Config:** `@lnilluv/pi-ralph-loop`, `max_iterations: 16`, `timeout: 600`, `items_per_iteration: 1`, `reflect_every: 4`, `completion_promise: LOCAL_SLICE_DONE`, `completion_gate: optional`.

## Eligible autonomous units

R01 (reconcile) → R02 (MM-09 audit) → R05 (test/release scripts) → R03 (durable events) → R04 (restart rehydration/replay) → R18 (reporting); dependencies are explicitly constrained. Tasks R06–R17 remain gated by Vercel authorization, original art bytes, human browser/device reviews, operations, or hosted service. The package does not change their status to DONE.

The completion gate is intentionally `optional` because the full roadmap contains unresolved P0/P1 **external** blockers; an extension-level required gate would prevent honest completion of the autonomous *local slice*. `LOCAL_SLICE_DONE` never means V1, PWA, Vercel or full-roadmap acceptance.

## Run from the Pi UI (not Bash)

```text
/ralph --path ./.ralph/tasks/loop-001-origin-remediation
```

Reconcile origin, worktrees, parallel SIGA/Pi claims and active branches before any edit. The package guards block Git push/merge and deploy commands; no automatic release, preview dispatch, image substitution or human acceptance. Every iteration must verify changed code/tests, update a single cumulative `WORK_REPORT.md`, and finish with `git diff --check` plus a single next action.

## Local generation verification

- YAML parsed successfully and `max_iterations`, `items_per_iteration`, gate and promise were inspected.
- ZIP CRC verification passed; all seven expected files were present.
- `TASKS.md` includes six locally eligible parent tasks and twelve external/blocked parent tasks, each mapping to a unique LOOP-R ID in the canonical backlog.
- **No real Pi execution or Godot test occurred during packaging**; those results must be collected by the operator from the local Pi runtime.
- This PR remains draft and is not a request to merge or run the loop automatically.
