# MM-09 implementation plan

1. Obtain the operator, identity, transport, retention and abuse-policy decisions in the specification.
2. Define versioned protocol envelopes and contract fixtures around the existing deterministic domain engine.
3. Implement the authoritative service, session/deck lock and append-only event store.
4. Implement reconnect/replay verifier and negative authorization/ordering coverage.
5. Integrate Godot transport without moving rule truth into client presentation.
6. Run load, privacy/security and real-network acceptance before public release.

