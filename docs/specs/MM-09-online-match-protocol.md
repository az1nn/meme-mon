# MM-09 — Online Match Protocol

Status: IN REVIEW — deterministic authority reference exists; hosted WebSocket service, client transport and operations acceptance remain.  
Depends on: MM-08 versioned Canon/format legality  
Unlocks: V1 competitive release

## User value

Players can play a fair online match that survives a transient disconnect and can be reproduced from authoritative, versioned intents and events.

## Scope and authority

- The server is authoritative for identity/session authorization, deck legality, seed generation, intent validation, rule resolution, event sequence, reconnect state and replay records.
- Godot remains the sole client/rendering runtime. It submits intents and renders authoritative events; it never decides online competitive truth.
- MM-09 uses only exact MM-08 legal edition/format references. It accepts neither mutable Sandbox records nor an approval status as a deck card.
- Matchmaking, ranked ladders, payments, trading, social feeds and voice/chat are outside this workstream.

## Protocol invariants

```text
authenticated session -> legal deck lock -> authoritative match seed
-> intent(expected_event_seq) -> validation/resolution -> append-only events
-> acknowledged event sequence / reconnect snapshot -> replay
```

- Every command carries a match ID, authenticated player identity, idempotency key and expected authoritative event sequence.
- Stale, duplicate, cross-player or malformed intents are rejected without mutating match state.
- The server assigns the RNG seed and records the exact rules, format, card edition and engine version at match start.
- Reconnect supplies an authenticated snapshot plus events after its acknowledged sequence; the client cannot select its own state.

## Functional requirements

**FR-01 Session and deck lock.** Authenticate the player/session under the selected operator model and validate a canonical 30-card deck before creating a match.

**FR-02 Ordered intent/event contract.** Use the MM-03 PlayerIntent/MatchEvent contracts extended only by explicitly versioned transport envelopes. Persist a monotonic event sequence and idempotent intent result.

**FR-03 Reconnect and timeout.** Define bounded reconnect, turn-timeout and abandonment behavior. Reconnection replays authoritative state/events and never permits an event gap or hidden-information leak.

**FR-04 Replay.** Store the match seed, locked deck edition IDs, rules/format versions, accepted intents and emitted events. A deterministic verifier must reproduce the terminal state or identify the first divergent event.

**FR-05 Abuse and operations.** Rate-limit session/intents, log authorization/transport failures safely, and define service health, incident response and player-support boundaries before public release.

## Acceptance scenarios

1. A legal deck locks exact Canon editions and starts an authoritative seeded match.
2. A stale, duplicated or opposing-player intent is rejected with no event/state mutation.
3. Disconnect followed by authorized reconnect yields the same visible state and event sequence as an uninterrupted client.
4. A saved replay reproduces its terminal state in an independent deterministic verifier.
5. Unknown engine/rules/format/edition versions fail closed before match start or replay execution.

## Decisões operacionais adotadas

- Beta fechado: operador az1nn / Mememom; conta por e-mail; servidor autoritativo; WebSocket; região inicial Brasil; retenção inicial de até 90 dias.
- Escala/SLO/custo, regras de timeout/abandono, limites de abuso e canal público de suporte continuam gates antes da abertura pública.

## Closed-beta transport adapter

`server/authoritative_websocket.gd` is a headless Godot WebSocket adapter for the deterministic authority reference. It fails closed unless the operator supplies a valid Canon state path and an out-of-band JSON map of opaque closed-beta session tokens through environment variables. It is not a public identity provider, matchmaking service, deployment configuration, or authorization to expose an online endpoint.

## Non-goals

Ranked matchmaking, anti-cheat claims beyond authority and auditability, voice/text chat, payments, friend systems, trading and decentralized/P2P authority.
