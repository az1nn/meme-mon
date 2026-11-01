# AFK development loop

The repository uses the external [Ralph Loop](https://ralphloop.sh/blog/ralph-loop-with-opencode/)
with OpenCode for bounded unattended work. The official Ralph v2.7.0 shell
runtime is checked in as `ralph.sh` with its supporting `scripts/` library.

## Operating mode

WSL defaults to direct OpenCode execution because `opencode` is available in the
host environment. Set `RALPH_DIRECT_MODE=0` to use Docker Sandboxes when `sbx`
is installed and authenticated.

```bash
./ralph.sh --agent opencode --once
./ralph.sh --agent opencode --max-iterations 8
```

The merge gate is explicit and Git-only:

```bash
RALPH_ALLOW_DRAFT_MERGE=1 tools/ralph-merge.sh 27 --allow-draft
```

It requires a clean `master`, fetches the current PR head, checks that it is
based on `origin/master`, runs `git diff --check` and `npm test` in a detached
worktree, then creates a non-fast-forward merge and pushes `master`. It does
not inspect GitHub review metadata; the owner's draft authorization and local
exact-head validation are the merge contract for this unattended environment.

Every iteration receives a fresh OpenCode context and may complete one task
only. The task list is `.agent/tasks.json`; detailed acceptance criteria live
under `.agent/tasks/`. Progress is persisted in `.agent/logs/` and
`.agent/history/`. `.agent/STEERING.md` is the live operator steering channel.

## Merge policy

The repository owner authorizes merging draft PRs. Draft status is therefore not
a blocker, but the loop must still require:

- exact-head tests and `git diff --check` passing;
- a clean merge with current `origin/master`;
- no unresolved implementation or acceptance blocker;
- no force-push or history rewrite;
- no production deployment or issue closure.

For PR work, the loop fetches `refs/pull/<number>/head`, works in isolation,
publishes through the SSH `origin`, then merges with Git only after the merge
gate passes. A failed check, branch-protection rejection or missing external
device/human gate stops the loop with `BLOCKED` rather than being reclassified.

## Completion signals

The agent must emit one of Ralph's semantic tags:

- `<promise>TASK-{ID}:DONE</promise>`
- `<promise>COMPLETE</promise>`
- `<promise>BLOCKED:reason</promise>`
- `<promise>DECIDE:question</promise>`

The loop is bounded by `--max-iterations`; it is never an infinite process.
