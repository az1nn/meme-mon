---
name: loop
description: Transcribe decisions and context supplied from a chat into traceable Spec Kit specifications, plans, and atomic task graphs for an existing Pi/Ralph iteration system. Use /skill:loop when the user asks to turn a discussion or roadmap into planned iterations.
disable-model-invocation: true
---

# loop — Chat context -> Spec Kit -> iteration-ready tasks

## Single responsibility

This skill is a **documentation translator**, not a runner, agent orchestrator, runtime adapter, backlog executor, or merge assistant.

Convert explicitly supplied chat context (decisions, roadmap, handoff, constraints, trade-offs) into the repository's existing Spec Kit document conventions. The output is a set of well-scoped, traceable planning artifacts that the **already installed** Pi/Ralph system may consume later.

Never install, replace, configure, invoke, or modify Pi, Ralph, provider/model settings, shell runners, CI, or deployment as part of this skill. Never start implementation or update the active runtime queue merely because a plan was transcribed.

## Inputs and authority

1. Read the chat text or handoff explicitly provided to this invocation. Do not claim access to another chat that was not provided.
2. Inspect the actual repository and its existing Spec Kit directory names and established task format, when available.
3. Reconcile precedence: live repository and checks > ratified constitution > active specs/plans/tasks > repository handoffs > chat/memory.
4. Attribute each requirement as USER_DECISION, VERIFIED_REPO_FACT, PROPOSAL, ASSUMPTION, or OPEN_DECISION. Preserve exact wording for critical decisions without altering intent.
5. When chat and ratified specifications conflict, document the conflict and requested change. Do not silently supersede a constitution or release contract.

## Transformation procedure

### 1. Extract

Create a short context ledger with source, date when known, commitments, rejected options, non-goals, open decisions and known blockers. Preserve approved art and architecture gates, human acceptance, external credentials and production constraints. Never infer DONE from a statement about intent.

### 2. Specify

Use the repository's existing Spec Kit conventions (in Mememom: docs/specs/). Include problem, goal and measurable outcome, scope and non-goals, functional requirements, constraints, risks, validation scenarios and explicit success criteria. Reference the source context and higher-authority specifications.

### 3. Plan

Use the existing plan directory (in Mememom: docs/plans/). Define incremental milestones, dependencies, integration boundaries, affected existing components and verification strategy. Distinguish implementation activity from operator/human/external gates. Do not invent a second architecture.

### 4. Break into iteration-sized tasks

Use the existing task document directory (in Mememom: docs/tasks/). Every task needs:

- stable ID and milestone;
- source requirement/spec and prerequisite task IDs;
- one bounded deliverable appropriate to a single iteration;
- explicit in-scope/out-of-scope boundaries;
- expected artifact or evidence;
- validation commands only if verified to exist;
- definition of done and gate classification: AUTO, HUMAN, PROVIDER, DECISION;
- an initial state: PLANNED, READY, BLOCKED or WAITING_HUMAN, grounded in evidence.

Prefer one independently verifiable action per iteration. Split tasks that mix implementation, deployment, human approval and release authorization. A BLOCKED gate is not a passing task. A verified existing implementation may still have pending acceptance.

### 5. Reconcile and hand off

Check for duplicates with current specs and the existing iteration queue. If a task already exists, link/reconcile it instead of re-creating the work. Include a concise mapping of chat requirement -> spec criterion -> plan milestone -> task ID -> acceptance evidence. Explain next eligible task and blocked dependencies.

Do not write to .agent/tasks.json, .agent/PROMPT.md, .agent/STEERING.md, .ralph/, ralph.sh, scripts/lib/, .pi/, build workflows, production settings, or GitHub PR state unless separately and explicitly authorized. Spec Kit documents and this skill are the deliverables, not queue activation.

## Output contract

- Produce or update a SPEC, PLAN and TASKS document (or their exact repo equivalents), using existing paths and naming conventions.
- Clearly mark transcription status as DOCUMENTED / NOT_EXECUTED.
- Use evidence links and exact SHAs when known, and 'not verified' otherwise.
- Never mark human, visual, touch, legal, rights, provider or production gates PASS without corresponding evidence.
- Leave the task execution, task import/activation and iteration scheduling to the existing Pi/Ralph environment.
- At end, give a brief handoff naming artifact locations, open decisions, blockers, and the first task eligible for a later execution session.

## Example invocation

/skill:loop Transcribe the following chat decisions and roadmap into Spec Kit spec/plan/tasks, without implementing or modifying the current Pi/Ralph runtime: [paste context].

For the Mememom roadmap transcribed on 2026-11-01, see:
- docs/specs/LOOP-001-mememon-roadmap.md
- docs/plans/LOOP-001-mememon-roadmap.md
- docs/tasks/LOOP-001-mememon-roadmap.md
