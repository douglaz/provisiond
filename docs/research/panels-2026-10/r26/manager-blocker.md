## Owner clarification: a failed refresh does not freshen the cache

The governing passage is `docs/adr/0034-tenant-traffic-cannot-spend-the-providers-request-budget-the-system-needs.md`, Decision 1:

> A refresh of a machine whose `state_observed_at` falls within the deployment's stated freshness window (`OVR-19`) settles without a provider call. At most one provider read per machine per window then reaches the provider, however fast a caller loops.

The relevant existing requirements and schema are:

- `01-domain-model.md`, `DOM-8`: “A reader MUST take the staleness bound from `state_observed_at` rather than from the fact of a caller having asked.”
- `05-persistence.md`, `machines.state_observed_at`: “when `state` was last established by an authoritative read of the provider”. The row also says “Null where nobody has read the provider since the row was created”.
- `03-operation-lifecycle.md`, `OPS-11`, refresh failure row: “Always `failed`. It is read-only; a failure changed nothing.”
- `03-operation-lifecycle.md`, `OPS-8`: “At most one `running` operation that is not yielded may name a machine at a time”. This serializes overlapping operations; it does not establish a cooldown after a settled failure.

Concrete counterexample, using a hypothetical 60-second freshness window rather than proposing a default:

1. A machine's last authoritative state observation is older than 60 seconds.
2. At time t, a caller's refresh reaches the provider and fails without establishing state. The operation settles failed; the observation timestamp remains stale.
3. At t + 1 second, a new caller operation requests refresh. There is still tenant request capacity above the system reserve, and the preceding operation has finished.
4. The stated cache predicate is still false. Applying only that predicate permits another provider read within the same window.

This concerns distinct caller operations, not an automatic retry of the failed operation or the post-mutation ambiguity change assigned to a later ticket. It also occurs with sequential requests, without a race or a second engine. The aggregate request budget eventually limits consumption but does not establish the ADR's per-machine bound while tenant capacity remains.

## Readings with different behavior

**Observation-only caching.** The cache predicate is the entire rule. A failed read leaves the machine eligible for another provider read immediately. The at-most-one statement must then be qualified to successful observations; the failed-read loop remains a residual that the owner must explicitly accept.

**An unconditional per-machine read bound.** Failed dispatched refresh reads count toward the window too. A new refresh inside that window must avoid the provider even though the cache is stale. This needs an additional rule for that operation's outcome: local failure, waiting until eligible, or settlement using stale state. Those outcomes are observably different. Decision 1 does not specify which one applies, and an unsuccessful attempt cannot be recorded as an authoritative observation merely to make the freshness predicate true.

The question for the owner is: **Does the per-machine refresh bound include failed reads? If it does, what must a new refresh do during the remaining window when no fresh observation exists?**

I recommend preserving the unconditional bound: count dispatched refresh reads toward a separate per-machine cooldown, preserve the true observation timestamp, and deterministically fail a new refresh locally while that cooldown remains. The owner should settle that behavior and its error/pacing contract before implementation. This is a recommendation only; no requirement or formal declaration has been amended to select it. The representation of cooldown state can then remain an implementation choice.

