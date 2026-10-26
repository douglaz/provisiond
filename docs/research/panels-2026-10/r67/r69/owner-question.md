# Owner question — panel E r69

**TL;DR:** The panel picks a stored offer listing, **4 of 4**, for the cost/latency direction. Neither printed offer form is ready to apply: the stored form has a coverage gap and disputed amendments; the fresh-read form breaks surviving admission rules. Separately, all four accept keeping Robot's per-order fingerprint, with operator-only recovery on an unverified channel.

A customer sees an offer at **90 sats/hour at noon**. It rises to **120** before the customer creates at 12:04. With a sufficiently fresh stored listing, we admit using 90 and reserve balance based on that quote. At purchase time we read again: we fail if the new price exceeds what the reserve covers; a dropped offer also fails. With a fresh read for each create, we use 120 or refuse a missing offer before admitting. That adds provider latency and a read to each create. It still needs the later purchase-time check because prices can move after either admission method.

The stored choice needs a table, scheduled refresh traffic, and age/refresh settings. Busy accounts can share those reads; idle accounts still get refreshed. Missing or stale data refuses the create. The fresh choice avoids that stored dataset and routine refresh but spends provider time on customer requests, including some requests eventually refused for local reasons. The vote is about those costs; the panel did not measure traffic or latency.

For the separate recovery choice, suppose the provider accepts a server order, but its reply is lost. We keep the order's unique SSH-key fingerprint. A person still decides which discovered server belongs to the customer on the unverified channel. Later, after the old request record is removed, that fingerprint lets cleanup recognize that the server is still provisioning and retain all its temporary keys, including a different customer key. It grants no automatic matching authority. This also requires a unique generated key in every Robot order; the standard channel remains empirically unverified.

**One question, two parts: which offer direction do you choose, and should we apply the reviewed fingerprint form?**

1. **Offer direction — stored listing S (panel pick, 4/4), or fresh read F (0/4)?** S is the panel's cost/latency recommendation, not a settled decision or a recommendation of an unreviewed merged patch. Its printed form has **2 counted ACCEPT / 2 counted CA**, with no verified blocking loss under the panel's fixed gate. F has **0 counted ACCEPT / 4 CA** and verified blocking losses. Choosing S sends its exact wording/coverage candidate to a scoped whole-form read before application; choosing F sends a complete repair candidate to that read instead. No complete repaired F was supplied.
2. **Apply reviewed K1–K6 (ACCEPT 4/4), with the exact separately reviewed after-release assertion K-d (3 unconditional takes, 1 conditional take), or leave it?** The three takes carry the original conditional assertion. The fourth reader asked to add a completed-transaction fixture; that new amendment is held and is not part of the recommendation. An operator-confirmed order still in progress keeps its existing protection; this assertion does not authorize early release.

The reader positions behind these choices:

| Reader | Offer pick and strongest reason | Complete K verdict and strongest reason |
|---|---|---|
| fable | S; an admission read adds a round trip while purchase-time checking already protects the reserve. Its S verdict is AMEND; its process-placement change fails the wording-only check. | ACCEPT; retain cleanup evidence without giving it matching authority. |
| opus | S; keep local refusals before provider requests. Its S verdict is CA for the verified coverage regression. | ACCEPT; keep temporary-key cleanup working after request retention. |
| astra | S; bounded listing age buys admission independent of provider response time. S AMEND is a verified quotation repair. | ACCEPT; durable evidence, operator resolution. |
| sol | S; share reads across busy accounts. S AMEND is the same verified quotation repair. | ACCEPT; retain every tagged key while the machine is provisioning. |

Identifiers and exact reviewed texts: **pv-tcs**, S1–S6 versus F1–F10, in [brief.md](brief.md); **pv-ytv**, K1–K6 and the exact K-d there. S affects `API-7`, new `STO-60`/`OPS-51`, `OVR-17`/`OVR-19` and `CNF-166`. K affects `PRV-26`/`PRV-32`, `OPS-38`, `CNF-278`/`CNF-303`, new `CNF-371`, plus K-d. The preserved purchase rule is `OPS-43`: “where the provider's price has risen past what the reserve covers”; the operator rule is `PRV-33`: “attaching a discovered machine to a tenant MUST be an operator action”; the still-in-progress guard is `OPS-33`: “the negative window MUST NOT run against a matched order that is still in progress”. Exact defects, amendments, counts and source evidence: [tally.md](tally.md).
