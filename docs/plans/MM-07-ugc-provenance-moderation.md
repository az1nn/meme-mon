# MM-07 implementation plan

1. Confirm the operator/policy decisions listed in the MM-07 specification.
2. Define versioned submission, decision and report contracts with state-transition fixtures.
3. Implement an authoritative persistence/service boundary, not client-owned public moderation truth.
4. Add role, transition, snapshot, audit and privacy-boundary tests.
5. Integrate private submission UI only after the authority and policy gates are demonstrably configured.
6. Hand only approved eligibility snapshots—not mutable Sandbox data—to MM-08.

