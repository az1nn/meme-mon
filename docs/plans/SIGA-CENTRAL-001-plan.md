# SIGA-CENTRAL-001 — Migration plan

Status: PROPOSED. Pilot: az1nn/meme-mon. No merge authorized.

- M0 RECONCILE: inspect master, constitution, roadmap, PRs, claims, skills and handoffs. DONE as documentary inventory, not exhaustive of external consumers.
- M1 SPEC KIT: publish bounded spec, plan, tasks, architecture/continuity contracts, seven proposed ADRs and acceptance matrix on isolated draft PR. No runtime changes.
- M2 ENTRYPOINTS: inventory all real agents/CLI/chat entrypoints; prove ARTIST and SIGA ART resolve to same orchestrated execution. Fail closed where aliases cannot be intercepted.
- M3 DERIVED GRAPH: discover tasks from specs, PRs, CI and persisted handoffs. No mutable second source of truth.
- M4 CONCURRENCY: issue #24 must prove live multi-client CAS, fencing, stale release rejection, claim recovery and protection of every writer. No REST read-then-write mutex claims.
- M5 CONTINUITY: implement next-owner dispatch and safe recovery across fresh sessions; preserve human gates.
- M6 AUDIT: read-only scheduled discovery, drift/stale-gate/orphan reports, no automatic claim mutation.
- M7 REGRESSION: verify ART/SCENE/ARCH/INSPECTOR, C01/C05, PR #13/#27, exact-head CI, accessibility and human visual gates where relevant.
- M8 CUTOVER: separate explicit authorization, protected merge after all checks and handoffs.

Dependencies: M2-M6 cannot claim production readiness until M4 and adoption by all actual writers. PR #15 remains closed/unmerged and may be mined for design only. Issue #24 is blocking. Each phase is an independently reviewable unit with evidence and rollback.
