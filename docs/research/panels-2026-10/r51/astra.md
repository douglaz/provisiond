**Vote: NO-ALARM.** Qualify Q31’s Failure and Conformance bullets with “where its trigger applies” (`ADR-0037/Q31`).

Verified at `084cdd9`:

- `PRV-5`: “every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider account and request path, for reads and writes alike.”
- `ADR-0037/Q28`: “One alarm rule”; “Its home is `PRV-5`”. Rejected: “funding the tail; a local `/server` read budget or reserve; a separate alarm per requirement.”
- `ADR-0037/Q31`: “a failed read of any kind, `rate_limited` included, does not enter `OPS-11`’s classifier and does not change the create’s settlement.” Then: “The declared bound of `PRV-31` remains the priced term, `PRV-5`’s alarm is raised, and the read is not retried.” Conformance: “the alarm is raised”.
- `PRV-13c`: “Absorbing the failure MUST NOT suppress” the alarm “where its trigger applies”; `CNF-356`: “On the `403` case, assert the alarm names the provider account and request path.” Other-failure alarms are therefore **not required**, rather than prohibited.

I found no generic alarm, error counter or compulsory failure log covering this read. `API-28` governs “every log line emitted”; `SEC-32` audits “Every mutating request”. Neither requires this absorbed error. `STO-47` calls `driver_observation` “reserved and today unreachable”. `OPS-26` exposes “needs_reconciliation”, but `CNF-356` requires “no `needs_reconciliation`”. `OVR-18` alarms “the engine’s liveness”, not this failure.

The framing misses an existing signal: `WIR-11` exposes `"earliest_cancellation_date": null` through `WIR-25`’s “machine views”; `PRV-13c` says “the column MUST remain null until such a response supplies the date.” For a settled Robot create, null already reveals an unverified term; no second mark is needed. It reveals neither the cause nor the actual date.

Actual terms can remain unknown indefinitely: `PRV-13c` says “The post-order read MUST NOT be retried”. `PRV-31` excludes bounds “later than the provider’s local today”; Q25 retains the branch “for provider deviation”. My inference: missed protection can advertise unavoidable cost as runway (`LDG-33`: “MUST NOT be advertised as spendable runway”). `LDG-63` calls cost beyond the declared bound after deviation “operator-borne”.

Later, `PRV-13` requires the “effective cancellation date”; `PRV-13c` fills the column from a response “that carries the per-machine date”. `LDG-63` surfaces insufficient coverage “as a named deficiency”; `LDG-75` says “the invoice supplies anything missed”—money, not timely contract verification.

An alarm adds notifications for transient failures without establishing deviation (`CNF-356`). I read Q28’s rejection as avoiding duplicate alarm rules; a distinct verification-failure trigger would require a deliberate policy amendment.

**Strongest case for the other side (written on request)**

A transient failure permanently loses early verification. Q31’s rationale is “while the tenant’s committed satoshis can still cover it”; a passive null may go unread. One notification could prompt investigation before that opportunity disappears. This is not my position.

Both gate runs passed; tracked files unchanged.