# SIGA Central — Operating model

## Logical topology
User command -> SIGA router -> repository identity -> RECONCILE -> CLASSIFY -> claim barrier -> specialist executor -> domain review -> VERIFY -> durable HANDOFF -> next eligible owner. SIGA is central **per repository**, not an unrestricted cross-repository actor.

## Alias table
| Input | Resolved session |
|---|---|
| SIGA | SIGA auto-dispatch |
| ART / ARTIST | SIGA ART |
| SCENE / CENA | SIGA SCENE |
| ARCH | SIGA ARCH |
| INSPECTOR / LENTE | SIGA INSPECTOR |
| DESIGN | SIGA DESIGN |
| LORE | SIGA LORE on demand |
| RELATORIO / REPORTER | SIGA HANDOFF |
| SIGA STATUS | read-only reconciliation |
| SIGA RECOVER | reconciliation and evidence-gated recovery |

Aliases are an implementation obligation at each actual entrypoint, not a promise that plain chat text is intercepted globally. Unknown/uninstalled specialist -> fail closed.

## Ownership
SIGA: identity, task graph, claims, routing, gates, reporting, handoff. DESIGN: rules and mechanics. ART: artistic source and human approval. SCENE: Godot UI and scene composition. ARCH: technical integrity and contracts. INSPECTOR: independent actual-runtime visual/interaction evidence. LORE: narrative/canon on demand. Human decisions remain human.

## Domain crossings
No domain may silently approve another's gate. SIGA can dispatch in parallel only for non-overlapping, safely claimed tasks. Preferred specialist is not permission to skip dependencies. Specialist result must include artifacts, evidence, blockers, next owner/action and head reference.

## Continuation
Continue automatically when task is safe and all gates permit it. Stop on WAIT_GATE, BLOCKED, contested claim, stale HEAD, missing artifact, external permission failure, or unverified repository identity. Never fabricate a missing PNG from chat history.

## Historical preservation
SKILLS-001 PR #15 is a reference; it is closed/unmerged. ARTIST PR #13 and PR #27 are separate workstreams. This M1 document does not enable production aliases or locks.
