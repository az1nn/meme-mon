# Canon signing and retention policy

Version: 1.0-draft
Scope: closed-beta Canon state and competitive replay evidence

Canon sets may be signed with RSA-SHA256 through `CanonModel.sign_set`. The
private key is supplied by an external operator at signing time and is never
written into Canon state, match records, source control or client artifacts.
The headless authority accepts `MEMEMOM_CANON_PUBLIC_KEYS` as a JSON map of
`key_id` to public PEM and refuses to serve a Canon state when any signed set
cannot be verified.

Canon state records the set digest, signature, algorithm, key ID and signing
timestamp. A later key rotation does not rewrite historical set signatures;
the operator must retain the public verification material needed for any
historical replay or explicitly record a documented verification transition.

The model stores media and audit retention values in a versioned retention
policy. Historical match evidence is indefinite because replay traceability
must survive later rotation or suspension. The public media/audit retention
values and production key owner are still `PENDING_OPERATOR_DECISION`; until
they are selected, public Canon/UGC release remains blocked.
