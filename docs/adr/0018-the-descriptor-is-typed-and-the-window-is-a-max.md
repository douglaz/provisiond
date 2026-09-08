# A driver's declarations are a typed descriptor, and a measured window is the larger of what was declared and what was seen

**Status:** accepted (2026-09-07)

*Describe capabilities* returned an account id, a provider kind and a set of capability strings.
Eight other per-provider facts the engine's behaviour turns on — ordering channels (`PRV-38`),
channels with no correlator (`PRV-33`), evidence sources per mutation (`PRV-36`), the visibility
window (`PRV-36`), the order budget (`PRV-40`), the worst-case cancellation bound per offer
(`PRV-31`), the rescue address family (`RSC-45`) and the attachments that survive deletion
(`PRV-13a`) — were each "MUST declare" with no stated carrier, and three were routed to
`08-provider-notes.md`, which describes itself as illustrative and per-fact unverified. Separately,
`PRV-13a`'s "MUST expose cleanup" named no driver method, so `machine_attachments` was a fully
specified table that nothing populated and only account termination ever released.

## The decision

- **The descriptor is a typed, immutable value** returned by *describe capabilities* (`PRV-44`):
  the capability set plus every declaration above as a named field with a stated type. A driver
  that has nothing to declare for a field declares that explicitly. `08-provider-notes.md` becomes
  commentary on why a descriptor says what it says; it carries no value the engine reads. `WIR-29`
  stays a subset of it.
- **A measured window is two values with two owners, and the engine uses the larger.** The
  descriptor carries the *declared* bound with its sample size and date, immutable. The store holds
  *observed* samples (`STO-53`): one row per provider account per mutation, the dispatch instant and
  the first-observation instant, written as a by-product of work the engine already does. The
  effective window is `max(declared, max(observed))`. It can only grow, which is `PRV-36`'s "MUST
  NOT be narrowed except by re-measurement"; narrowing is a human re-declaring and archiving the
  samples. The same shape serves `PRV-13b`'s billing-stop window.
- **Two driver methods for attachments, under the existing `delete_machine` capability**
  (`PRV-45`): *list attachments* for a machine — kind, external id, billable, cleanup `api` or
  `manual` — and *release attachment*, returning delete's outcome classes. The engine calls list on
  every successful delete to populate `machine_attachments` and enqueues one `release_attachment`
  operation per `api`-cleanable billable row. **It is an operation kind, not a phase of the
  delete**: a delete that succeeded and a release that failed ambiguously are two facts, and one
  operation cannot carry two statuses — the shape `ADR-0017` corrected on the episode. No new
  capability: a driver that can delete a machine can say what it left behind.

## Why the window is not a constant

`PRV-36` says the window "MUST be widened by any observed sample that exceeds it". A constant in
driver source cannot widen itself; a human notices a metric, edits, deploys. In the gap between the
exceeding sample and the deploy, the sweep is using a window it has already observed to be too
short, and a lost create reply followed by an early read showing nothing resolves `absent`,
releases the commitment, and the machine arrives afterwards with nobody paying. That is the second
machine `OPS-27` exists to prevent, bought through configuration lag.

Keeping the declaration immutable and the observations append-only means nothing is ever
overwritten and the rule is one aggregate. A single mutable "current window" cell was rejected
because two writers — the driver's declaration and the engine's observation — would need a
precedence rule and a redeploy-with-a-smaller-constant rule, and both are exactly the kind of
unstated behaviour this set keeps finding it had.

## Consequences

- The 2026-09-07 review's §6.12 ask that visibility, billing-stop and negative windows "require live
  measurement" becomes a property of normal operation: samples accumulate from the first real
  mutation. A launch still needs the declared bound to be a real measurement, and `CNF-292` asserts
  the effective window widens on an exceeding sample without a redeploy.
- `CNF-18`'s table-driven capability test gains a row per descriptor field: a declared value has a
  working code path behind it, as a declared capability does.
- `STO-18`'s tombstone gate, `LDG-32`'s attachment meter and the `billable_attachments` term of the
  reserve formula now have a writer.
