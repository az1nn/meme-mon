# ADR-SC-006 — Read-only automated audit
Status: PROPOSED. G5=B. SIGA performs discovery on invocation and via recurring read-only audit. Detect missing artifacts, untracked tasks, stale CI, orphan claims and handoff drift. Auditor cannot claim, mutate, merge or release locks. Trade-off: improved observability with periodic API and maintenance cost; no automatic task theft.
