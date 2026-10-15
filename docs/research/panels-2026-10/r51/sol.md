**Vote: NO-ALARM.** Qualify both `ADR-0037/Q31` alarm assertions with “where its trigger applies”; retain `PRV-5`, `PRV-13c` and `CNF-356`.

Verified at `084cdd9`:

- `PRV-5`: “every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider account and request path, for reads and writes alike.”
- `ADR-0037/Q28`: “One alarm rule”; “Its home is `PRV-5`”; “Rejected: funding the tail; a local `/server` read budget or reserve; a separate alarm per requirement.”
- `ADR-0037/Q31`: “a failed read of any kind, `rate_limited` included”; “`PRV-5`'s alarm is raised”; Conformance: “the alarm is raised.”
- Built `PRV-13c`: “MUST NOT change the create's settlement” and “where its trigger applies”; `CNF-356`: “On the `403` case, assert the alarm names the provider account and request path.”

I found no generic provider-read alarm, metric or mandatory failure log. `API-28` governs “every log line emitted”; `SEC-32` audits mutation “outcome”; `STO-47`: “`driver_observation` is reserved and today unreachable”. `OPS-26` lists “operations by status”, which cannot distinguish this failed read within the “same `succeeded` status” (`CNF-356`). Health supplies “Liveness” (`04-api-contract.md:7`).

The framing overstates silence: `WIR-11` exposes `"earliest_cancellation_date": null`; `WIR-33` provides `X-Provisiond-Tenant` for an “operator bearer token holding the admin flag”. For this settled Robot machine, null already means unverified. `PRV-13c` says: “An accepted cancellation's response (`PRV-13`) that carries the per-machine date supplies it to that column.” The view carries no read-error cause or timestamp (`WIR-11`). No new mark is needed.

Until that response, the actual date/deviation can remain unknown throughout the funded life: `PRV-13c` says “The post-order read MUST NOT be retried”. `PRV-31` refuses bounds “later than the provider's local today”; `CNF-356` prices the fallback contribution as “zero”. Thus additional term exposure requires deviation; missing it can advertise coverage as runway (`PRV-13c`: “never advertised as runtime”). `LDG-63` says “cost beyond it after a provider deviation is operator-borne”: the declared bound cannot cap that loss. Later, `PRV-13` “MUST surface the effective cancellation date”; `LDG-63` surfaces unfunded coverage “as a named deficiency”; `LDG-75`: “the invoice supplies anything missed”. Invoice cost need not diagnose the contract mismatch.

An alarm per transient failure adds noise without obtaining the date. I interpret Q28’s “a separate alarm per requirement” as rejecting duplicated throttle rules; a distinct uncertainty trigger remains a policy choice.

**Strongest case for the other side (written on request)**

Q31 says “Only this read learns of a deviating contract while the tenant's committed satoshis can still cover it.” Transient failure creates lasting uncertainty because retries are forbidden (`PRV-13c`). Polling a nullable field may never attract attention; an alarm could prompt investigation before protection is spent.

Both unpiped gate runs passed. Tracked files untouched; no provider API called.