# The billing-stop window is withdrawn, and wind-down is sized to the gone-write

**Status:** accepted (2026-10-06, owner decision Q6 of the provider-research grill); amended 2026-10-09 (Q13, Q14), 2026-10-10 (Q18), 2026-10-11 (Q21, Q22, Q23, Q25) and 2026-10-12 (Q28). Amends `ADR-0035` (a release that carries an effective date) and
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

A four-reader panel (`docs/research/panels-2026-10/r22/`) agreed the window should go.
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

## Amendment — 2026-10-09: wind-down adds its sequential waits, and the window starts when the call's wait ends (owner decision Q13)

An rloop Manager blocked `pv-ucs.6` because Decision 2 did not say how `OVR-19`'s provider-call deadline
and `PRV-36`'s window compose. A four-reader panel (`docs/research/panels-2026-10/r29/`, unanimous)
found that taking the larger of the two under-reserves. The window is end-to-end, from dispatch to
the observed effect. A provider can accept as late as the deadline and still lag after it. And after
a lost reply, `PRV-36` forbids the first evidence read "before the window has elapsed", so that read
is a second provider call with its own deadline.

- **Wind-down's latency is the sum of the waits that happen in sequence, and `PRV-13b` names each
  one:**
  - the mutating call's wait (the deadline);
  - the visibility lag after it (the window);
  - the time until resolution reads (a stated cadence, a new `OVR-19` row);
  - that read's own wait (the deadline);
  - plus the detection, machine-wait and margin terms as before.

  `OVR-19` points to `PRV-13b` rather than restating the composition.
- **`PRV-36`'s window runs from the end of the call's wait, its reply or the deadline's expiry,
  not from dispatch.** Started at dispatch, a mutation the provider accepted late and that is still
  lagging could be read at once and resolved *not applied* ("Beyond the window, a read still showing
  the pre-mutation state resolves the mutation as *not applied*"). `OPS-32`'s create window, "measured
  from the dispatch of the create", takes the same correction.

Rejected: the larger of deadline and window (it under-reserves the late-accept and lost-reply traces);
the sum of only those two (it omits the evidence read).

## Amendment — 2026-10-09: a scheduled attachment release stops the meter at its date, and the sweep records it gone (owner decision Q14)

Decision 4 withheld `released_at` from a release that carries an effective date, but nothing then
ended the attachment's customer meter. `LDG-32` meters "until `released_at` is set", and no
automatic path ever set it. The same panel (`docs/research/panels-2026-10/r29/`, unanimous on the
first two points) found that Decision 3 had already decided the stop, "for a scheduled
cancellation, its effective date", and that it was never applied to attachments.

- **The effective date stops the customer's meter.** The attachment stores the provider's effective
  date, on a new `machine_attachments` column written by `PRV-45`'s terminal or resolution
  transaction where `released_at` is withheld. `WIR-35` carries it for `release_attachment` as it
  does for `delete_machine`. The meter closes at the earlier of that date and `released_at`, on its
  next tick inside the serialization. Nothing writes at the date and no operation waits on it, as
  `LDG-38` already clips a scheduled machine. "Future" is dropped from Decision 4: a date that has
  already passed is stored and clipped the same way.
- **`released_at` stays evidence that the attachment is gone, and the account sweep records it.**
  `OPS-32`, on every machine `STO-18` still holds, lists that machine's attachments (`PRV-45`'s list)
  and records a missing billable one gone on its own terms: a complete pass and a direct re-read.
  It writes `released_at` at the observation. That is what opens `STO-18`'s tombstone gate and lets
  `LDG-32` close the commitment. Stopping the meter is not tombstoning.
- The customer owes the attachment's rate through the effective date. The provider's part-day after
  it is an operator gap (`LDG-75`). A month-end date learned after ordering needs a bound declared
  per attachment kind at create, as `PRV-31` declares one for machines, or the shortfall meets
  `LDG-31`'s clamp.

Rejected: completion by the operator for v1; writing `released_at` at the date (a mark ahead of now
that opens the tombstone gate while the attachment may still bill); metering until the gone
observation (Decision 3 names the effective date).

## Amendment — 2026-10-10: posted entries behind the mark, day-only dates, and no attachment bound in v1 (owner decision Q18)

An rloop Manager blocked `pv-ucs.6` on two traces left by the Q14 amendment. Two four-reader panels
settled them: `docs/research/panels-2026-10/r34/` and a review of the proposed fix,
`docs/research/panels-2026-10/r35/` (4–0). The decisive fact is that **no attachment carries a customer
rate in v1**. `machine_attachments` has no rate column, `PRV-45`'s listing returns
`{kind, external_id, billable, cleanup: api | manual}`, and `LDG-24` applies the margin "to machine time only".
`RSC-45`'s IPv4 add-on is carried into the machine's price.

- **A provider date given as a calendar day only names the end of that day, UTC.** Robot's
  `cancellation_date` (`yyyy-MM-dd`) is one. A `now` release or cancellation never reads as a
  start-of-day instant. `PRV-45` and `WIR-35` state it.
- **A stop boundary learned behind a subject's mark leaves posted entries standing.** `LDG-38` states
  this once, for machines and attachments alike. It also states that the case cannot arise in v1, and
  names the conditions that would make it reachable: an attachment with its own customer price, or an
  offer whose cancellation can be scheduled for a future date (`PRV-13c`'s exception branch).
- **An automatic, idempotent corrective credit is a precondition of enabling either condition.** No
  manual operator correction step is specified.
- **v1 declares no attachment effective-date bound.** `PRV-44`'s `attachment_cancellation_bound` and
  `PRV-45`'s refusal without it are removed. The bound priced nothing: its only reserve use is "priced at
  that attachment's customer rate through its worst-case effective date", and no such rate exists. Its
  only consumer was a sale gate that checked it had been declared, and that gate refused every Robot
  offer, because Robot lists its additional IPs and subnets as possible `api` survivors. `PRV-13b`'s
  `billable_attachments` reserve term has no v1 value, and `LDG-33`'s term returns to "surviving billable
  attachments (`PRV-13a`)". The Q14 amendment's sentence "A month-end date learned after ordering needs a
  bound declared per attachment kind at create … or the shortfall meets `LDG-31`'s clamp" is withdrawn:
  without an attachment rate no customer shortfall is reachable. `LDG-32`, `PRV-13b`'s sale rule and
  `API-7` are unchanged.
- **Giving an attachment its own customer rate requires all three:** the automatic credit above; a
  worst-case effective-date bound for each kind; and a declaration, for each offer, of the kinds its
  order creates. The driver's descriptor is not that declaration: it names kinds per driver, and whether
  an instance bills is decided at deletion.
- **Robot offers that order the `primary_ipv4` add-on are sold now**, before batch B step 9 shows whether
  the address outlives the server. The customer is never charged for the address. A surviving one is
  operator rent until its `cleanup: api` cancellation, and `LDG-75` already names that gap ("Robot add-ons
  billed per day or part thereof"). That the add-on is billed per day is inferred, not documented
  (`docs/research/provider-verify-2026-10.md`). The panel split 2–2 on this, and the owner chose to sell.

Rejected: building the automatic credit now; a manual operator correction step; a mandatory bound per
kind with refusal (it refuses every Robot offer over a number nothing reads); scoping the refusal to the
kinds an order creates (no pre-create input says which); a zero bound for an immediate kind (Robot's
`now` returns a date, which names the end of that day); reading `LDG-32`'s "explicitly accepted and
capped" as `LDG-31`'s clamp (the clamp caps the customer, not the operator); and selling only IPv6-only
Robot offers until step 9.

## Amendment — 2026-10-11: an attachment the listing never saw, and what a Robot `now` delete settles as (owner decisions Q21, Q22)

`pv-ucs.4` found that `PRV-45` lists attachments only "on every delete that succeeds with the resource
gone". A failed listing, a machine the provider terminated, and a scheduled delete never list, and with
zero rows `STO-18` and `LDG-32` close over a survivor nobody recorded (panel
`docs/research/panels-2026-10/r38/`). The owner had it tested on a real Robot account first; panels
`r39/` and `r40/` reviewed the result.

**The live test (2026-10-11, `docs/research/panels-2026-10/r39/live-result.txt`).** An auction server was
ordered with `addon[]=primary_ipv4`. It was cancelled with `cancellation_date=now` and
`reserve_location=false`, and Robot answered `200` with `"cancellation_date": "2026-10-11"`. One second
later `GET /server/{n}` answered `404`, and the add-on IPv4 (the server's main address) was gone from
`GET /ip`. It stayed gone through a 45-minute watch. The included IPv6 /64 was gone from `GET /subnet` at
twenty seconds. Before the cancel, `GET /server/{n}` listed the server's `ip` and `subnet`.

- **Q21: no survivor machinery for the sold path; a precondition instead.**
  - Batch B step 9 is settled for the auction add-on. Robot's declared survivor kinds stay: "The
    declaration names kinds, not an assertion that every instance survives". Still untested: separately
    ordered IPs and subnets, the catalogue channel, provider-initiated termination, and the invoice.
  - Complete automatic discovery and cleanup is a precondition. It is required before any sold create
    path can leave a billable attachment that outlives its server: a separately ordered Robot IP or
    subnet, or Cloud and DigitalOcean on re-admission. It needs identities captured while the machine is
    present, a `release_attachment` enqueued at every gone-write, "never listed" told apart from
    "listed, none", and a machine that disappears before capture covered. No manual operator step.
  - The residual is accepted with its threat model. It is an accident only: no adversary can cause it.
    If Hetzner's own termination or a catalogue order ever left the add-on behind, the operator pays its
    rent with no end date (EUR 1.90 a month net, Robot's offer list of 2026-10-11). `ADR-0035`'s "Not
    covered here: a delete whose success is followed by a throttled attachment listing" is answered here.
  - Repair (4–0): `OPS-48`'s scheduled row says "that tombstone is the gone-write of the last row" and
    clears the fence "by the tombstone". `LDG-74` says stopping the meter and tombstoning "MUST NOT be
    collapsed". The scheduled episode closes, and its fence clears, at the gone-write (the last row). The
    tombstone follows when `STO-18` allows.
- **Q22: a `404` after the cancel records the machine gone.**
  - After an accepted cancellation that answers a date, the driver reads the machine once. The
    provider's mapped not-found (Robot's `SERVER_NOT_FOUND`) on the known account and server records it
    gone at that read, and the meter stops there. `PRV-36` already says "A read showing the post-mutation
    state is evidence at any time", and `DOM-19` allows "independently recorded gone before it".
  - A read that fails or still shows the server settles the attempt scheduled with the date. The cancel's
    acceptance is truthful, and the sweep records gone later. A throttle or authentication failure is
    never absence.
- **Q22: a day-only date ends in the provider's zone, not UTC.** The Q18 amendment's "names the end of
  that day, UTC" is corrected. A provider date given as a calendar day only names the end of that day in
  the zone the provider dates in, and the driver converts it. `PRV-13` owns the rule, and `PRV-45` and
  `WIR-35` cite it. The rule applies to effective dates only. `earliest_cancellation_date` is a date
  cancellation is permitted from, not a stop instant. Read as the end of the day, it would send nearly
  every order down `PRV-13c`'s exception branch. Robot dated a key `created_at "2026-10-11 05:47:37"` at
  03:47:37Z, consistent with `Europe/Berlin`. The zone of its cancellation fields is `[verify]`, by a
  read-only check across Berlin's midnight.

Rejected: building attachment discovery now; recording a machine gone only at the sweep after a `now`
delete (the customer pays up to one sweep interval that `PRV-13b`'s wind-down sum leaves out); a failed
read-back settling `needs_reconciliation`; a Robot-wide "`now` is immediate" constant; a descriptor field
for the zone.

## Amendment — 2026-10-11: a failed read-back's tail, the attachment cap, and the earliest date's instant (owner decisions Q23a–c)

A two-axis review of the branch found three questions the decisions above left open. A panel settled
them (`docs/research/panels-2026-10/r41/`); three readers answered after the fourth seat failed on its
usage limit.

- **Q23a: the tail after a failed read-back is accepted, with its threat model.**
  - After a read-back that fails or still shows the server, the attempt settles scheduled (Q22), and the
    meter runs to `LDG-38`'s stop boundary. Time past wind-down is `LDG-74`'s sweep-interval residual,
    ended no later than the stored date. Beyond the commitment, it meets `LDG-31`'s clamp.
  - The threat model: Robot destroyed the tested server within a second of `now`. Time past the
    read-back is therefore metered but not provider-billed. A clamp records an uncollectable charge for a
    machine that is gone, not operator money: `LDG-66` "records who bore a cost or exposure, not whether a
    provider is still owed".
  - Operator money is at stake only while the machine is still present, which is the exposure the present
    branch already carries.
  - A tenant can induce a failed read only if Robot's server-read counter is shared, which is unverified
    and settled by the live test. If it is shared, this is revisited.
- **Q23b: `PRV-49` is the one home for selling an offer with a survivable attachment, and its residual is
  uncapped.**
  - `LDG-32`'s "It MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless the
    operator has explicitly accepted and capped that exposure" becomes a pointer: whether an offer may be
    sold with a billable attachment that can outlive its machine is `PRV-49`'s.
  - The residual Q21 accepted has no cap: EUR 1.90 a month for each stray address until someone notices.
    It rests on Q21's threat model, an accident that no adversary can cause.
  - `PRV-13b`'s duty to bound an offer's own exposure is read with the same exception.
- **Q23c: a day-only `earliest_cancellation_date` names the start of that day in the provider's zone.**
  - It is stored as the start of that day in the zone the provider dates in (Robot: `Europe/Berlin`,
    unverified). A date equal to the provider's today has passed, so the machine takes the ordinary branch.
  - Cost through a future earliest date runs to that day's end, because a cancellation dated then ends
    there under `PRV-13`'s effective-date rule. `PRV-13` owns the rule.
  - `CNF-147`'s "Size the commitment from the machine's read" contradicts `PRV-31`'s "MUST NOT resize the
    commitment" and is reworded.

Rejected: funding the rest of the provider day in wind-down on every purchase; stopping the meter at a
failed read; an exception clause in `LDG-32` (a second home for the rule); withdrawing every `primary_ipv4`
offer until removal is proven on every path; a plain calendar date compared in every consumer.

## Amendment — 2026-10-11: v1 sells no offer whose earliest cancellation is after today (owner decision Q25)

An rloop Manager blocked `pv-ucs.10` on a gap between three rules:
- the exception-branch test reads a day-only earliest date's start;
- the purchase reserve adds its cost on that branch only;
- `LDG-33` protects cost through the day's end.

At 23:30 provider-local, an earliest day of tomorrow starts in thirty minutes, so it is ordinary and nothing
extra is reserved, yet it is protected through tomorrow's end. A four-reader panel
(`docs/research/panels-2026-10/r43/`) found that no v1 purchase can reach this.

- **v1 sells no offer whose declared or reported earliest-cancellation bound is later than the provider's
  today.**
  - Such an offer permits future-scheduled cancellation. `LDG-38` says enabling that "requires an
    automatic, idempotent corrective credit", which v1 does not post.
  - `PRV-31` owns the rule. `API-7`'s existing "not sellable under `PRV-13b` or `PRV-31`" refusal applies
    before any order, and `CNF-166` covers it.
- **Robot's declared bound for the launch set is the provider's today.** Hetzner's documentation says of
  dedicated servers "You can only cancel immediately". `08-provider-notes.md` records this; it is not a
  constant.
- **`PRV-13c`'s materiality test is not decided now.** The branch sentence returns to "when it is
  materially in the future", replacing the start-of-day wording `3b717a0` introduced. The test is
  settled when future-dated offers clear the corrective-credit gate.
- **The branch stays specified for provider deviation:** a date read back later than the declared bound,
  which `CNF-147` injects. Cost past the declared bound is operator-borne. `LDG-63`'s "bounded per machine
  by `PRV-31`'s declared worst case" holds only where the read date lies within that bound.

Rejected: judging a still-future earliest date by its day end now (it changes `PRV-13c` for a case no v1
offer reaches at purchase); a near-midnight conformance fixture; a deferred dispatch that waits for the
permitted-from instant.

*Verified 2026-10-12 (Q22's `[verify]`): Robot dates in `Europe/Berlin`. Three read-only reads of a
cancellable server's `earliest_cancellation_date` were taken on 2026-10-11:*
- *21:30:50Z, Berlin and UTC both on the 11th: `2026-10-11`.*
- *22:30:36Z, Berlin on the 12th, UTC on the 11th: `2026-10-12`.*
- *23:30:14Z, the same dates: `2026-10-12`.*

*The date rolled over at Berlin's midnight, not UTC's (`docs/research/panels-2026-10/r40/zone-check.txt`).*

## Amendment — 2026-10-12: Q23a after Robot's server-read counter proved account-wide (owner decision Q28)

Q23a said: "A tenant can induce a failed read only if Robot's server-read counter is shared, which is
unverified and settled by the live test. If it is shared, this is revisited." The live sessions of
2026-10-12 settled it, and a four-reader panel revisited it (`docs/research/panels-2026-10/r45/`).

**What the sessions showed.** After about 200 `GET /server/{n}` in an hour, Robot answered
`403 RATE_LIMIT_EXCEEDED` (`max_requests` 200, `interval` 3600) to all of these:
- `GET /server/{n}` for every server on the account, not only the one read;
- `GET /server`, the account list;
- `GET /server/{n}/cancellation`;
- reads sent from a second source address, over IPv6.

Unaffected were `GET /ip`, `GET /boot/{n}/rescue` and the cancellation itself
(`POST /server/{n}/cancellation`). Reads recovered about an hour after the first request.

So the `/server` read family shares one counter per account. Robot documents a single webservice user per
account, so per-user and per-account are the same here, and the counter is not per source IP.

**Q23a's money decision stands.** The tail is not funded, and no local read budget is built. As `ADR-0034`
Q19 found, "A local count cannot hold a reserve" against traffic outside provisiond.

**Its threat model is restated.** Tenants can add to the counter through provisiond in four ways:
- refreshes at the edge of a sweep, while the freshness window only equals the sweep interval;
- opportunistic reads after actions;
- deletes of a fleet held over several days, at two shared reads each while a cancellation pre-read
  exists;
- refresh loops that retry failed reads.

Any other user of the account's credential can add to it too. A blind sweep also cannot find a running
machine provisiond never recorded: that is operator cost after `OPS-33` releases a create's commitment
before the machine is attached. The tail on a destroyed server remains an uncollectable charge, not
operator money.

**Repairs.** The first is the one that removes operator-money exposure.
- **No pre-read on Robot deletes.** The driver posts `cancellation_date=now&reserve_location=false` without
  first reading `GET /server/{n}/cancellation`. With the pre-read, a blinded counter fails an exposure
  delete before acceptance, and it stalls (`OPS-48`) while the machine bills the operator. The
  reservation-possible branch stays unverified.
- **One alarm rule.** Every Robot `403 RATE_LIMIT_EXCEEDED` raises a monitorable alarm naming the account
  and request path. Its home is `PRV-5`; the alarms in `PRV-40` and `PRV-22` cite it.
- **`DOM-8`: the refresh freshness window is at least twice the account-sweep interval**, and startup
  refuses less. This closes the per-pass gap that `ADR-0034` Q20's "at no provider call whatever the fleet
  size" overlooked.
- **`PRV-12`: Robot makes no opportunistic `/server` read** outside `DOM-8`'s freshness check.
- **`OPS-32` on Robot reads attachments through `GET /ip` and `GET /subnet`**, never `GET /server/{n}`.
- **`08-provider-notes.md` records the observed scope.** Whether the window is fixed or rolling, and whether
  refused requests count, stay unverified.

Rejected: funding the tail; a local `/server` read budget or reserve; a separate alarm per requirement.

## Amendment — 2026-10-14: Robot's post-order cancellation read is one attempt, and its failure is absorbed (owner decision Q31)

Q28 removed the cancellation pre-read from Robot deletes and kept `PRV-13c`'s post-order read: "That separate
post-order read remains required." A branch review asked whether v1 should keep it at all: on every Robot
server observed it returns the provider's today, and `PRV-31` already refuses to sell an offer whose bound is
later. A four-reader panel weighed it (`docs/research/panels-2026-10/r48/`): three kept it, one dropped it.

**What the panel found.** The spec says "order, then **read**" but never says when the read runs or what its
failure does. Nothing writes `machines.earliest_cancellation_date`. If the read runs inside the accepted create,
`PRV-5`'s "Known acceptance MUST remain `true` on every later error" sends every delivered create to
`needs_reconciliation` during an hour the shared `/server` counter is spent. If it runs anywhere else, a failure
leaves the column null and `LDG-33`'s term prices nothing.

**Decision: keep the read, as one attempt with an absorbed failure.**
- **Where:** the driver reads the per-machine cancellation constraint once, when the create settles, after
  `OPS-27`'s confirming read.
- **Failure:** a failed read of any kind, `rate_limited` included, does not enter `OPS-11`'s classifier and does
  not change the create's settlement. The declared bound of `PRV-31` remains the priced term, `PRV-5`'s alarm
  is raised where its trigger applies (a Robot `403`), and the read is not retried. A later accepted
  cancellation's response (`PRV-13`) supplies the per-machine date.
- **Threat model:** Q28's list of what spends the account's `/server` counter gains these reads, one per
  delivered order. `ADR-0036` caps machine orders per endpoint per day with no hourly pacing, so a day's
  deliveries can land in one hour. Each follows an order whose first unit the tenant paid for.
- **Conformance:** `CNF-356` tests a failed post-order read.

*Clarified 2026-10-15 (owner decision, panel `docs/research/panels-2026-10/r51/`): no new alarm. Q28's one alarm
rule stands, so a non-`403` failure of this read raises none; on a settled Robot machine the null
`earliest_cancellation_date` in `WIR-11`'s machine view is what marks the term unverified.*

*Clarified 2026-10-15 (owner decision Q34, panel `docs/research/panels-2026-10/r52/`): "once" counts from the
settlement that commits.* The PR's review found that a crash between a successful read and the landed-order
commit leaves the result nowhere: `STO-55` keeps provider calls outside transactions, and `OPS-49` throws an
interrupted worker's outcome away. Recovery then reaches the read again and cannot tell a lost result from a
read never made. Decision:
- The pass whose landed-order transaction commits makes the one read, after its confirming read. An interrupted
  worker's read is discarded with the rest of its outcome, as its confirming read is, and the committing pass
  reads again. Once the machine row is stored, no resolution pass, refresh or sweep reads the constraint.
- A settlement with no confirming read (the operator's synchronous `observed` attach, `WIR-35`) makes no
  post-order read and stores the date as null.
- "The declared bound remains the priced term" gets its home in `LDG-33`'s formula: where the column is null,
  the cost-through-earliest-date term is priced from the offer's declared bound (`PRV-31`).

This changes the count from one read per delivered order to one per committing settlement: at most one extra
read for each create in flight at a crash, bounded by the worker count, beside the confirming read recovery
already repeats on the same counter. Rejected: a durable "attempt used" marker written before the read (it has
its own crash window, and a read, unlike `OPS-45`'s disk write, can simply be made again); treating a lost
result as a failed read without a marker (recovery cannot tell it from a read never made).

**Why keep it.** Only this read learns of a deviating contract while the tenant's committed satoshis can still
cover it. `PRV-31` forbids resizing the commitment, so the read can only move satoshis from advertised runway
into `protected_sats`, but that is the protection `PRV-13c` exists for. Dropping it for Robot would turn "Robot
cancels today" into the constant `PRV-13c` forbids.

Rejected: dropping the read for Robot and taking the date from the delete's cancellation response, since the
deviation would be learned only after its runtime was advertised; and keeping it with a failure that waits in
`needs_reconciliation`, since a spent hour would stall every delivered server.
