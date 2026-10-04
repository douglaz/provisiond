# Purchase tails report all applicable refusals

**Status:** accepted (2026-10-04, `pv-gip.26`).

`API-7` owns the tail's collection, order and purity. `WIR-9a` owns the added detail keys,
`WIR-9b` retryability, and `LDG-62` the extension's admitting write. Conformance is `CNF-307`.

An autonomous caller benefits from learning the independent faults in one response. Keeping the
list in details fits the existing envelope and leaves one headline for ordinary HTTP handling.
The chosen order explains the resource before the pool, then pricing and spending; it does not
sort away the named resource's refusal merely because another fault needs caller action.
The early pipeline protects disclosure and replay semantics; it is a poor place to collect faults.

Rejected: returning only one refusal, which hides simultaneous faults; adding a fifth key to the
inner object, which changes an object also used by operation views; a list beside `error`, which
creates another envelope shape; applying collection to every non-2xx, including execution results
and security refusals; non-retryable-first ordering (the r12 opus alternative), which makes the
headline depend on a different fault than the resource the caller named. Pacing stays with the
headline; the earlier panel's greatest-delay suggestion was superseded by the owner's defaults.
