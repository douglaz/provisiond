# During a price outage, a funding cancellation waits for the rate or the outage bound

**Status:** accepted (2026-10-01); amended 2026-10-02 by *An outage pauses the restore grace*
below (`pv-gip.29`). The requirement and checklist edits listed under *Consequences*
landed in `2997723` (`pv-gip.23`), and the formal-layer edits in `e739240` (`pv-gip.25`), where
the guard *Consequences* names `sweepContinuesWithoutRate` became `sweepRoutesNothingWithoutRate`.
Answers `pv-gip.23` by removing the branch it was about.
Overturns `LDG-40`'s sweep row, `LDG-65`'s mid-outage routing and `OPS-41`'s no-rate branch, and
answers the rejection `ADR-0026` gave this shape.

## The problem as found

`OPS-41` says "Where there is no rate, the cancellation proceeds." To keep a stale "no rate" read
from deleting a machine while the rate returns, the worker makes a conditional write on the
machine's `rate_outage` record (`STO-37`). Only the meter opens that record, at the subject's first
posting that computes no rate, so in the first minutes of an outage it does not exist. The write
affects no row, and `OPS-41` reads zero rows as the machine's meter having stopped: the cancellation
settles as the no-mutation case, the episode closes, and the sweep queues it again. Zero rows can
also mean a machine genuinely gone, because the re-check runs before the fence write, so the branch
could not be repaired by reading the record differently.

## The decision

The owner's words: "If there is a price outage we should just suspend all deletions that are
related to price." A **funding cancellation** (`CONTEXT.md`) waits while its machine's currency has
no rate, until the rate returns or the outage reaches `LDG-64`'s bound.

Why it holds:

- `LDG-64` says to "charge the customer nothing for that window", so no commitment is drawn down
  during an outage. A stored `runway_until` that passes mid-outage is a stale prediction, and
  deleting on it destroys a machine whose customer still has its satoshis.
- `LDG-41` says the rate "is the only external input that destroys customer data". Acting on a date
  the outage itself made stale is that input acting with no value at all.
- The argument for proceeding was `OPS-41`'s "failing the other way is an unfunded machine billing
  indefinitely". It is not indefinite: `LDG-64` says to "cancel machines at that bound if no rate
  has returned".
- `ADR-0026` rejected waiting as "cancelling nothing while the outage lasts, stranding the exposure
  `LDG-64` exists to cap". Under this decision the bound still fires, so nothing is stranded past
  it.

## The shape

**The sweep routes a funding cancellation only where the stored date has passed and the machine's
currency has a rate.** The sweep opens no new funding episode during an outage, so nothing it
routes piles up to be woken. `OPS-36`'s attach transaction is the exception: it enqueues a
late-attach cleanup outside the sweep, and what it does with no rate is `pv-gip.27`'s.

**The worker decides inside the fence transaction**, not on its claim snapshot, in this order:

1. The machine is recorded gone, or its episode is closed: settle as the no-mutation case, with no
   provider call.
2. The tenant is suspended now: the funding re-check does not apply, and the cancellation proceeds,
   as `OPS-41` already says.
3. A rate exists for the machine's currency: re-derive and apply the ordinary predicate, as today.
4. No rate, and the outage's deadline has not passed: defer by `OPS-8`'s ordinary short delay and
   write no fence.
5. No rate, and the deadline has passed: this is the bound. Make today's conditional write on the
   machine's `rate_outage` record and proceed; zero rows with a rate now in force re-derives, which
   is `CNF-218`'s existing restoration case. Zero rows with no rate also proceeds: step 1 has
   already settled a gone machine, so `OPS-41`'s reading of zero rows as "the machine's own meter
   stopped" is deleted, not carried into this step. For a machine with no record, nothing orders
   the worker against the rate returning at that instant; that is accepted, since it needs a
   machine the meter never posted for and a rate returning at the bound itself.

**The deadline is computed from history, not read from a record.** It is the outage's start plus
`LDG-64`'s maximum tolerated outage. `STO-37` already defines the start as "a function of that
history alone", replayed from `STO-49`, and `STO-49` keeps those rows so that "the snapshot it holds
survives to the close". Any writer computes the same instant, including for a machine the meter
never posted for, and a restart with unchanged parameters cannot move it. A restart that changes
the bound, or the staleness bound, window or quorum the start is replayed with, does move it; see
*The bound is the setting in force* below.

**The bound's cancellation reaches every machine priced in the currency**, not only "a machine
carrying such a record" (`OPS-41`). That is what lets a machine with no record, such as one under
`LDG-72`'s quarantine, still meet the bound.

**An extension halts with no rate.** `LDG-62` says "Extending runway is a caller write, authorized
like a purchase", and `LDG-40` says "With no rate for the machine's currency, an extension of
runway MUST halt as a create does". The original argument — "Under this decision no funding
cancellation proceeds before the bound, so no customer needs to extend mid-outage to keep a
machine" — missed the restore grace: the rate can return after the grace was spent unusably,
and the next claim cancels before the tenant can act. The dated amendment below answers that case.

## Considered options

- **Proceed as today.** Rejected: it deletes machines on stale dates, and it is the branch that
  produced `pv-gip.23`.
- **Park each cancellation until the deadline**, with explicit wake-ups when a suspension joins or
  the rate returns. Rejected: a parked attempt strands a suspension that joins its episode
  (`OPS-39` creates no second attempt) and a broke machine whose rate returns early. Short deferral
  re-decides at every claim and needs no wake-up.
- **Let the worker open the `rate_outage` record.** Rejected: `STO-37` refuses it, and the opening
  would need its own ordering against the rate's return.
- **One outage record per currency.** Rejected: the deadline is already a function of `STO-49`'s
  history, so a second record would be a second representation of one instant.

## Consequences

Accepted costs, decided by the owner on 2026-10-01:

- A machine already broke when the outage began runs on the operator's money until the rate returns
  or the bound fires.
- A flapping feed gives each outage its own deadline, so the cap holds per outage, not across them.
- A provider whose contract has a notice period or a billing granularity can charge one more period
  for a cancellation the outage delayed (`PRV-13c`).
- A bound reached inside the original wall-clock restore grace still waits to `grace_ends_at`.
  After that end, no-rate claims reach the ordinary short-delay or bound decision. Funding claims
  with a returned rate also observe the accumulated grace decided below; the original blanket
  description, "a cancellation waits for the later of the two", did not cover this composition.
- Added 2026-10-02: a price move across an outage arrives as one step when the rate returns; a
  thin-margin machine can re-derive into the past without a chance to react while the feed was
  dark. `LDG-16` says "A machine within one honest step of exhaustion can be pushed over by that
  step." This is that accepted risk magnified, not a new general grace.
- Added 2026-10-02: a machine inside a restore incident runs on the operator's money for the
  paused part of its grace.

Edits owed, each to land with its dated note (`pv-gip.23`):

- `LDG-40` (`12-billing-and-ledger.md:1049`): the sweep row, and a new row halting an extension.
- `LDG-65` (`12-billing-and-ledger.md:1214–1234`): "cancelled normally", and its 2026-09-23 note
  "no cancellation waits for a rate".
- `OPS-41` (`03-operation-lifecycle.md:755`, `:783–817`): the no-rate paragraph, the zero-row branch,
  and the bound's "only for a machine carrying such a record" at `:808`.
- `LDG-16` (`12-billing-and-ledger.md:1606`): "MUST route a machine where its stored
  `runway_until` has passed".
- `LDG-13` (`12-billing-and-ledger.md:1519`): "There is no unfunded grace period" names the outage
  as the one window it does not cover.
- `OPS-39` (`03-operation-lifecycle.md:675`): "nothing may deny it" names the outage wait.
- `STO-37` (`05-persistence.md:879–881`): the sweep "asks for no rate", and "reads an absent row its
  own way".
- `LDG-64` (`12-billing-and-ledger.md:1163`): the persisted deadline, against the computed one.
- `CNF-218` (`10-conformance-checklist.md:1720`): its no-rate case; `CNF-138` (`:702`): the
  continuing sweep. `CNF-184` (`:920`), the bound, stays.
- `ADR-0028`: "The sweep's predicate has one clause".
- `Provisiond.Fence`: `sweep`, `readRate`, `recheck`, `extend` and the `outageWrite` control row in
  `ci.yml`; `Provisiond.Admission`: the `sweepContinuesWithoutRate` guard and the theorem that no
  exposure-reducing action halts for want of a rate.

**The computed instant is the only deadline** (decided 2026-10-02). `STO-37`'s persisted
`outage_deadline` is deleted rather than kept as a copy: the stored value appears only after the
meter's first no-rate posting and never for a machine the meter does not post for, while the
computed one exists from the outage's first instant. `LDG-64` persisted the deadline so that "a
restart mid-outage does not reset the clock"; the computed instant meets that, since `STO-49` keeps
the rows its start is replayed from. The machine view's `rate_outage_deadline` shows the computed
instant. The record keeps its billing fields. Further edits this owes:

- `STO-37` (`05-persistence.md:851`, `:856`, `:895`): the column, and the sentence writing it in
  the record's insert.
- `LDG-64` (`12-billing-and-ledger.md:1163–1169`): "persist the outage's start instant and the
  exact computed deadline", and the restore that "loses the row", which becomes a restore that
  loses `STO-49`'s rows; `:1180`, the machine view's field.
- `LDG-38` (`12-billing-and-ledger.md:814`): its sentence naming `outage_deadline`.
- `CNF-99` (`10-conformance-checklist.md:454`, `:477`, `:485`): the assertions on
  `outage_deadline`, restated on the computed deadline.
- `STO-54` (`05-persistence.md:1336`): "`LDG-64`'s persisted outage start and deadline are lost
  with their `STO-37` row" becomes the loss of `STO-49`'s rows the start is replayed from.

**The bound is the setting in force** (decided 2026-10-02, after a four-model panel that voted for
it unanimously). When the operator changes the maximum tolerated outage, or the staleness bound,
window or quorum the outage's start is replayed with, the deadline uses the value in force when it
is computed, for open outages too. Lowering the bound below the time an outage has already run
makes its cancellations eligible at the restart that loads it, with no further notice; that is the
operator's own choice, since `LDG-64` calls the bound "the operator's own loss limit". The
disclosure is a notice of the mechanism, not a promise of the number: `LDG-64`'s harm is a trigger
"its owner was never told about", and `WIR-30`'s `binding: false` covers price only. Following
`ADR-0011`, which let the runway date float on condition that "the terms must say so", the offer
says so. Rejected: freezing the value per outage (it needs the setting's history stored, the record
this ADR declined) and a per-machine floor at the disclosed value (the create's offer snapshot does
not carry `max_rate_outage_seconds`, `STO-50` forbids writing it there, and `STO-14` deletes the
settled create anyway). The register row is one duration; `LDG-59`'s "one bound for each currency"
is read as each currency's outage running its own clock against that one value. Further edits:

- `OVR-19` (`00-overview.md:349–362`): one sentence owning the rule above, for the bound and the
  replay's parameters together.
- `WIR-30` (`13-wire-contract.md:922`): `max_rate_outage_seconds` is the operator's current limit,
  it can change during an outage, and the machine view's `rate_outage_deadline` is authoritative.
- `LDG-64` (`12-billing-and-ledger.md:1177–1183`): cites `OVR-19`'s sentence rather than restating
  it.
- `CNF-99`, `CNF-184` and `CNF-218`: a parameter changed mid-outage, including a lowering below the
  time already elapsed.


## An outage pauses the restore grace — 2026-10-02

The owner decided that a funding cancellation's restore grace is one re-derivation interval of
**rate-present time from step (3), summed across outages**. An outage pauses accumulation; a
return resumes the unspent portion, never a fresh interval. The normative owners are `OPS-41`
(claim and deferral), `STO-49` (history retention), and `STO-56` (stored end and incident closure).
`STO-54` keeps the procedure and freeze; `OPS-36` points its extension opportunity to `LDG-40`.

The reason is the defect this ADR missed. `ADR-0028` says "The grace is one interval from the
instant a tenant can first act" and rejects "A grace nobody could use". An outage covering the
available wall-clock interval recreates it because the extension halts. It happens when a restore
runs during an outage, including one the restore causes by losing rate-observation rows, and when
an outage begins inside an unfinished grace and outlasts its original end.

This is narrower than a general interval after recovery. `LDG-64` says "charge the customer
nothing for that window": a customer funded at outage start keeps the remaining commitment,
and the returned rate determines the re-derived runway, not a promise of the same seconds at a
different price. A customer already unpaid had the preceding runway in which to extend.
`OPS-36` offers survival "before the cleanup cancellation this transaction enqueued has written
`OPS-42`'s fence"; that is no guaranteed minimum opportunity even without an outage. Its pointer
to `LDG-40` qualifies admission; late attach gains no post-outage interval outside a restore.

Only funding cancellations gain the paused measure. The outage bound and a currently suspended
tenant keep the original wall-clock grace. A historical enqueue reason or episode reason cannot
convert either into a funding cancellation deferred indefinitely. The longer incident lifetime
keeps history available and the claim rule active; it does not extend the freeze and prevent the
bound canceller from running.

No new storage: step (3)'s transaction still writes `grace_ends_at` once. Subtract one
re-derivation interval to recover the starting instant and use retained currency history on the
same basis as the outage-start computation. `LDG-64` identifies the return as "the observation
with which `LDG-58`'s window produces a rate again". A first arrival can leave a thin window;
a subject's `absorbed_until` may be absent or precede the currency return at a meter stop.
Neither is the source. Raw `observed_at` values are not assumed monotonic in acceptance order.
Retention must span the whole open restore's needed history, including its left edge, even after
multiple returns move the ordinary outage snapshot forward. The Lean model abstracts replay as
effective outage spans; its proofs establish neither replay correctness nor retention.

Incident closure waits for the original wall-clock end and the other incident obligations, and
for each currency's accumulated grace to finish **or its outage to reach the bound**. The latter
exception prevents a never-returning currency from holding the record open forever: past that
bound no funding cancellation remains to protect. A finished currency cannot discharge another's
unfinished grace. `STO-56` is the close rule's single home, with a pointer from `STO-54`.

At each claim the original wall-clock grace still comes first, including the null-end short
deferral before step (3). In the additional portion, with a rate, an unfinished funding grace
returns the attempt to `queued` until the paused end computed at that claim, writing no fence and
making no provider call. With no rate after the wall-clock end, the worker takes the existing
short-delay path before the bound, or the bound/current-suspension path when applicable. It never
parks until an unknown return. Each later claim recomputes; neither accumulation nor a revised
end is persisted. Once grace no longer defers, the ordinary ordered funding re-check and fence
transaction run. The rule changes deferral, not settlement, and does not clear inherited fences.
