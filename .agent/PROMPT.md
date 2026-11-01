> ONE TASK PER INVOCATION. Complete one task from `.agent/tasks.json`, verify it,
> commit it, emit `<promise>TASK-{ID}:DONE</promise>`, and stop.

## Mission

Work on Mememom, an open-source Godot 4.7.2 card game. The repository's live
state, constitution, active specs, plans, tasks and CI are authoritative. Read
`.agent/STEERING.md` and the selected task before editing anything.

## Required reconciliation

1. Run `git status --short --branch`, `git remote -v` and inspect the current
   branch before mutation.
2. Read `.specify/memory/constitution.md`, `docs/ROADMAP.md` and the task's
   linked spec/plan.
3. Never discard existing user work. Stop with `<promise>BLOCKED:dirty worktree</promise>`
   when unrelated changes prevent an isolated implementation.

## Architecture rules

- Godot 4.x is the only client and rendering runtime. Do not add React or
  Three.js rendering paths.
- Competitive truth stays in deterministic, versioned domain logic outside UI.
- Sandbox content must not silently become Canon.
- Code and first-party/user media have separate licensing boundaries.
- New product capability requires spec/plan/task alignment before code.

## Task flow

1. Pick the highest-priority task whose `passes` is `false`.
2. Read `.agent/tasks/TASK-{ID}.json` completely.
3. Implement only that task. Do not start another task in this invocation.
4. Add or update proportional tests and documentation evidence.
5. Run the task's `validation` commands. For code changes, run at least the
   relevant Godot suite; run `npm test` for cross-cutting changes.
6. Run `git diff --check` and inspect the final diff.
7. Set the task's `passes` to `true`, prepend an entry to `.agent/logs/LOG.md`,
   and commit with a Conventional Commit message and `-s`.
8. End the response immediately with `<promise>TASK-{ID}:DONE</promise>`.

## Pull request work

PR tasks may be draft. Draft status is not a blocker because the repository
owner authorized merging drafts. Failing checks, conflicts, missing acceptance
evidence, or an incomplete implementation are still blockers.

When a PR task is selected:

- inspect its exact head with `git fetch origin refs/pull/{number}/head`;
- keep work isolated from `master`;
- never force-push or rewrite published history;
- run exact-head validation before publishing;
- merge only through the loop's explicit merge gate after checks pass.

## Stop signals

- `<promise>BLOCKED:reason</promise>` for missing credentials, hardware,
  unavailable services, failing external gates, or unsafe repository state.
- `<promise>DECIDE:question</promise>` for a product or architecture choice.
- `<promise>COMPLETE</promise>` only when every queued task passes.

Do not claim human visual, device, licensing, security, provider or operator
acceptance from automated tests alone.
