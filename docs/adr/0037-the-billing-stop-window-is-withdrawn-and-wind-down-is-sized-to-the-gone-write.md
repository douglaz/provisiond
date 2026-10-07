# The billing-stop window is withdrawn, and wind-down is sized to the gone-write

**Status:** accepted (2026-10-06, owner decision Q6 of the provider-research grill). Amends
`ADR-0018`.

## Context

`PRV-13b` asked each driver to measure the worst request-to-billing-stop latency over twenty real
deletions and declare it as `billing_stop_window`. Its effective value was to be the maximum of that
declaration and `STO-53`'s `billing_stop` samples. `ADR-0018` said "The same shape serves
`PRV-13b`'s billing-stop window."

Nothing could ever write such a sample. `STO-53` writes a row "when a resolution (`OPS-27`)
establishes when a resource became visible, and when an ordinary mutation's effect is first read
back". Both of those are visibility, and `PRV-36` says "Visibility and billing-stop are separate
measurements and MUST NOT be conflated". A provider's billing stop shows only on its invoice, weeks
later, and on Hetzner in whole hours.

A four-reader panel (`/var/tmp/provisiond-panel-r22/`) agreed the window should go.
Three of them rejected the replacement first put to the owner, "billing stops when the provider
accepts the delete":
- No provider places the stop at acceptance. Hetzner Cloud's delete returns an action that can
  still fail, and Robot bills a product for as long as it exists.
- `PRV-29` already says "An action reporting `completed` does not establish that billing stopped".
- `ADR-0035`'s `accepted` is a flag on errors, not a timestamp.

The quantity the reserve needs is a different one. Wind-down funds the **customer's** meter, and
`LDG-74` says "Billing stops at the observation instant". Between acceptance and the gone-write the
meter keeps debiting, so a reserve sized to acceptance would run short. `LDG-31`'s clamp would then
turn the gap into an operator deficiency. That is the trap `PRV-29`'s section records: a premise
used to shrink a number every machine's reserve depends on.

## Decision

1. **`billing_stop_window` is withdrawn**, with `STO-53`'s `billing_stop` kind. `STO-53`'s `kind`
   column, left with one value, is dropped too.
2. **Wind-down's latency term is `PRV-36`'s effective visibility window**: dispatch to the recorded
   gone, which the engine already declares and samples. `PRV-29`'s "measured confirmed-cancellation
   latency" points there. `PRV-36` owns the twenty-sample procedure, since it already borrows it
   "under `PRV-13b`'s procedure". `OVR-19` gains a provider-call deadline, so the case where no
   reply ever comes is bounded too.
3. **Billing stopped stays a fact of its own (`PRV-29`), with named evidence**:
   - for a machine, the gone-write;
   - for an attachment, `released_at`;
   - for a scheduled cancellation, its effective date.
4. **A release whose result carries a future effective date writes no `released_at`** (`PRV-45`).
   Robot's IPs and subnets can be cancelled for a later date, and until then they bill.
5. **What the provider bills after the gone-write is the operator's**, and `LDG-75`'s accepted gaps
   name it:
   - `ADR-0033`'s final partial unit;
   - Robot add-ons billed per day or part thereof;
   - DigitalOcean's seconds between its delete reply and the destroy.

## Considered and rejected

- **Billing stops at acceptance, and wind-down runs from dispatch to acceptance.** It under-reserves,
  for the reasons above.
- **Rename the visibility window as a billing-stop window.** It is the same quantity under a second
  name, and it restores the conflation `PRV-36` forbids.
- **Measure from invoices.** Invoices are slow, aggregated per account and month by `LDG-75`, and on
  Hetzner dominated by the hour's rounding. They audit the operator's books. They do not size a
  reserve.

## Consequences

- `PRV-36`'s sentence that the billing-stop latency "is still owed for every launch driver" becomes a
  dated trap record. A visibility sample was nearly read as a billing stop once, and this decision
  removes the second measurement rather than measuring it.
- The live tests' invoice steps check the billing unit and how the provider counts it, not a
  latency.
- Edits owed: `PRV-13b`, `PRV-29`, `PRV-36`, `PRV-44`, `PRV-45`, `STO-53`, `OVR-19`, `LDG-75`,
  `CNF-292`, `F18` (a dated note), `ADR-0018` (its status and the "same shape" sentence),
  `08-provider-notes.md`, the README's note on the dropped column, and
  `docs/research/provider-verify-2026-10.md` §3. No Lean declaration encodes the window or the
  sample kind.
