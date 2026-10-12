# Purchase tails report all applicable refusals

**Status:** accepted (2026-10-04, `pv-gip.26`).

`API-7` owns the tail's collection, order and purity. `WIR-9a` owns the added detail keys,
`WIR-9b` retryability aggregation, and `LDG-62` the extension's admitting write. Conformance is `CNF-307`.

An autonomous caller benefits from learning the independent faults in one response. Keeping the
list in details fits the existing envelope and leaves one headline for ordinary HTTP handling.
The chosen order explains the resource before the pool, then pricing and spending; it does not
sort away the named resource's refusal merely because another fault needs caller action.
The early pipeline protects disclosure and replay semantics; it is a poor place to collect faults.

Rejected: returning only one refusal, which hides simultaneous faults; adding a key to `WIR-9`'s
inner object, which changes an object also used by operation views; a list beside `error`, which
creates another envelope shape; applying collection to every non-2xx, including execution results
and security refusals; non-retryable-first ordering (the r12 opus alternative), which makes the
headline depend on a different fault than the resource the caller named. Pacing stays with the
headline; the earlier panel's greatest-delay suggestion was superseded by the owner's defaults.

**Amended 2026-10-04 (`pv-gip.26`).** Per-refusal retryability and skipped-check details
now have their home in `WIR-9a`; `API-7` keeps refusal purity and its snapshot. The residue
repair includes the canonical `WIR-9` fixture and the optional-cap case in `CNF-307`.

**Amended 2026-10-09 (owner decision Q12, `pv-ucs.5`/`pv-ucs.8`; panel
`docs/research/panels-2026-10/r28/`).** Two create refusals join the tail, placed by this ADR's
own rule. The caller names the account and the offer, and the ordering channel follows from the
offer and is shared by every tenant. So the order is: the account not `healthy`; the offer not
sellable (`ADR-0039`, and `PRV-31`'s offer with no declared bound); the offer's ordering channel
closed by the provider's throttle (`ADR-0036`, `rate_limited` with `retry_after_ms`, per account
and channel only); then solvency, rate, cap and balance. Every refusal that can co-occur has its
own rank.
- An unsellable offer is `400 invalid_request` with `details.reason: offer_not_sellable`, not
  retryable. Its precedent is `WIR-30`'s `invalid_request` for an install strategy the offer does
  not list.
- An unsellable offer skips the cap and balance checks, recorded in `not_checked` under a new reason
  `offer_not_sellable`. Price checks run only where a price is served: an unsellable offer is
  withheld from the listing, as an unhealthy account's offers are.
- Pacing comes from the headline. "A subordinate halted entry MUST NOT supply pacing" becomes "a
  subordinate entry".
- `API-50` says that a closed ordering channel can answer a well-paced caller's first create, since
  another tenant can close the shared channel.
Rejected: running cap and balance against an unsellable offer, because it reports a price the
listing withholds; `409 conflict`; a stage before the tail, which would hide the other refusals this
ADR exists to report.
