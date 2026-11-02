# Pi loop work-reporting standard

## Purpose

Pi/Ralph iterations must leave a human-readable work report, not a pile of
unstructured Markdown files. The report is the operator-facing summary; code,
tests and durable task documents remain the source of truth for implementation.

## Canonical files per loop

Each active loop package contains:

```text
.ralph/tasks/<loop>/
├── RALPH.md
├── TASKS.md
├── WORK_REPORT.md       # human-readable append-only report
├── RALPH_PROGRESS.md    # short machine/next-iteration memory
└── OPEN_QUESTIONS.md    # only unresolved external questions/blockers
```

Individual evidence files may be created only when they are linked from
`WORK_REPORT.md` and necessary for auditability. Do not create one unexplained
`.md` file per iteration.

## Work report format

`WORK_REPORT.md` starts with a current status block:

```markdown
# <Loop name> — Work report

**Status:** IN_PROGRESS | BLOCKED | WAITING_HUMAN | COMPLETE
**Last updated:** YYYY-MM-DD HH:MM timezone
**Current task:** <ID> — <title>
**Next action:** <one concrete action>
**Owner:** <person or role>

## Executive summary
<short paragraph a human can understand without reading transcripts>

## Progress overview
| ID | Task | Status | Evidence | Next action |
|---|---|---|---|---|

## Iteration log
### Iteration N — YYYY-MM-DD HH:MM — <task ID>
**Result:** DONE | PARTIAL | BLOCKED | WAITING_HUMAN | NO_CHANGE

#### What changed
- ...

#### Evidence
- Commands: `...` — PASS/FAIL/BLOCKED
- Files/commits: `...`
- External evidence: links or `not available`

#### Decisions and findings
- ...

#### Blockers
- None, or: blocker / owner / exact next action / recheck condition

#### Next step
<single concrete next action>

## Open gates
| Gate | Owner | Required evidence | State | Recheck condition |
|---|---|---|---|---|

## Deferred findings
| Finding | Why deferred | Follow-up task | Does it block current work? |
|---|---|---|---|
```

## Writing rules

- Start every iteration with one status line and one result; do not bury the
  outcome in prose.
- Use short bullets and tables. Link detailed evidence instead of duplicating
  it.
- State negative results plainly: `BLOCKED`, `NOT RUN`, `NO CHANGE`, or
  `WAITING_HUMAN`.
- Every blocker must name an owner, next action and condition for rechecking.
- Every successful validation must name the exact command and result.
- Every iteration ends with exactly one next action.
- Do not call a report `complete` when only an audit or no-change proof exists.
- Do not create repeated reports for an unchanged blocker; append a single
  recheck entry only when new evidence exists.

## Completion

A loop is report-ready when `WORK_REPORT.md` has:

1. a current status and next action;
2. a progress table covering every task;
3. one readable entry for every executed iteration;
4. explicit open gates and deferred findings; and
5. exact validation commands for completed implementation work.
