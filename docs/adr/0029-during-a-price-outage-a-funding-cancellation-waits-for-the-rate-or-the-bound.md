# During a price outage, a funding cancellation waits for the rate or the outage bound

**Status:** accepted (2026-10-01); amended 2026-10-02 by *An outage pauses the restore grace*
below (`pv-gip.29`), with the placement corrected 2026-10-03 (`pv-gip.35`, `pv-gip.36`) and
incident closure corrected by *Close on grace spent or machine disposition — 2026-10-03*
(`pv-gip.37`); amended 2026-10-03 by *A solvency check that cannot be computed has not failed*
below (`pv-gip.31`), overturning `LDG-40`'s solvency row. The
requirement and checklist edits listed under *Consequences*
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
  `LDG-64` exists to cap".

## The shape

**The sweep routes a funding cancellation only where the stored date has passed and the machine's
currency has a rate.** The sweep opens no new funding episode during an outage, so nothing it
routes piles up to be woken. `OPS-36`'s attach transaction is the exception: it enqueues a
late-attach cleanup outside the sweep, and what it does with no rate is `pv-gip.27`'s.

**The original 2026-10-02 worker order**, before the paused-grace amendment below; `OPS-41`
owns the current order. The decision was inside the fence transaction, not on its claim snapshot:

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
(claim gate and fence-transaction deferral), `STO-49` (history retention), and `STO-56` (stored end
and incident closure).
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
keeps history available and the grace rule active; it does not extend the freeze and prevent the
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

**Withdrawn 2026-10-03**, by *Close on grace spent or machine disposition* below:

> Incident closure waits for the original wall-clock end and the other incident obligations, and
> for each currency's accumulated grace to finish **or its outage to reach the bound**. The latter
> exception prevents a never-returning currency from holding the record open forever: past that
> bound no funding cancellation remains to protect. A finished currency cannot discharge another's
> unfinished grace. `STO-56` is the close rule's single home, with a pointer from `STO-54`.

### Placement corrected — 2026-10-03

The first landing (`ad6e2d9`) put the paused check at the claim and wrote availability at a
computed paused end. Both choices broke the decision:

- A claim at 200 saw no rate after an outage starting at step (3), 80; the original end was 140.
  A qualifying return before the fence transaction left zero rate-present time accumulated, but
  the transaction cancelled the unfunded machine. `pv-gip.35` and the model's historical placement
  witness carry that interleaving.
- A paused deferral parked the attempt until its computed end. A later outage could reach its
  bound earlier, or a suspension could join the episode, while that attempt was still ineligible.
  `OPS-6` says "The claim MUST select the oldest `queued` operation whose availability time has
  passed." `OPS-39` says "a sweep MUST enqueue nothing against a machine whose episode under that
  key is open". Neither event supplied an eligible attempt (`pv-gip.36`).

The caller identified the computed-end instruction as their error: it contradicted *Considered
options* above, which rejected parking because "a parked attempt strands a suspension that joins
its episode" and chose "Short deferral re-decides at every claim and needs no wake-up."

The correction lands in `OPS-41`'s ordered step 3, after re-derivation, with the ordinary short
delay. Re-derivation comes first so an extension or a price cut that funds the machine settles
its existing no-mutation outcome at the next eligible claim, before paused grace finishes.
Only an otherwise cancelling funding decision checks the unspent grace. The direct rate-return
path and the return observed through the conditional write use that same step. The original
null/future wall-clock claim gate is unchanged. No storage, wake-up, settlement row or fence-clear
path is added; `OPS-41` is the rule's home.

The bound and suspension queue traces belong to `10-conformance-checklist.md`: the Lean claim
model writes `available_at` but does not read it. A hand-scheduled claim at the bound would not
refute parking. The new placement witness proves the claim-to-transaction interleaving, and its
guard's off position reinstates the old placement and destruction.

This correction was evaluated while the restore record remained open. It left the incident-close
paragraph above unchanged at that landing. The pending-cancellation question was tracked as
`pv-gip.37`, resolved by *Close on grace spent or machine disposition* below.


### Setting-in-force extension — 2026-10-03

The caller extended the setting rule to the paused measure; `OVR-19` owns that rule and
`OPS-41` points to it. This extends the application of the owner's 2026-10-02 decision,
*The bound is the setting in force*, above; it is not a new decision attributed to that owner.

Accepted cost: raising the staleness bound or window during an open restore incident can
retroactively count outage time as rate-present time, spending paused grace. As with the
bound, this is the operator's own parameter change. Freezing replay settings per incident
was not requested. The mid-incident regression case is in `CNF-218`; it keeps the record open
and tests history replay, which the Lean effective-outage-span model does not establish.

The same review restored the re-check converse over worlds with an open restore record,
including the direct and step-5 paused-deferral cases, and qualified Admission's description.
It also made the funding-order defect independently refutable:
`Provisiond.Witnesses.funded_during_paused_grace_witness` keeps the price cut and unchanged
commitment, comparing settlement against premature deferral, under the `rederiveFirst` control.
`OPS-41` retains the actual withdrawn computed-end sentence; `LDG-13` points to `OPS-41`
for restore grace alongside its outage exception. The incident-close question on `pv-gip.37`
was outside that amendment; *Close on grace spent or machine disposition* below records its
subsequent resolution.

### Close on grace spent or machine disposition — 2026-10-03

The owner chose to preserve the worker's behavior and replace the incident-close alternative.
`STO-56` is the single home of closure: for each currency, "either its accumulated rate-present
time since step (3) has reached one re-derivation interval (`OPS-41`) or every machine priced in
that currency is recorded gone or fenced". Its limits remain explicit: "A finished currency does
not discharge another's obligation" and "The gone-or-fenced alternative requires no outage-bound
crossing and discharges only that currency's grace obligation, not the wall-clock or other
incident obligations."

The deadline makes cancellation eligible; it does not itself cancel. `LDG-64` says "The bound's
cancellation reaches every machine priced in the outage's currency, whether or not the meter
opened a `rate_outage` record for it". That includes funded machines. For the returned-rate path,
`OPS-41` step 3 says "If funded, it performs the no-mutation abort and settlement above".
Preserving the restore victim's opportunity gives it the same outcome available to a funded
machine when the rate returns before cancellation. Even past the bound, step 5 sends a return to
step 3: "the worker takes step 3 at that returned rate, including its re-derivation first and
paused check on the returned currency history" (`OPS-41`).

The withdrawn premise fails on `pv-gip.37`'s close-then-return trace: the wall-clock end passed,
a no-rate funding attempt short-deferred, the bound passed before its next eligible claim, and
closing the record discarded its unspent grace before the rate returned. `OPS-41` says "With no
open restore record there is no restore-grace deferral." The replacement tests machine disposition
instead of assuming it. Conformance: `CNF-218` for the worker regressions, `CNF-295` for closure.
`Provisiond.Witnesses.paused_grace_conditional_return_witness` also refutes the premise: at time
200 after deadline 180, the returned rate leaves the unfunded attempt short-deferred with the
episode open and no new fence. That is evidence about the worker interleaving, not a closure
proof. The model's omissions in `Fence.lean` and `Restore.lean` remain unchanged.

The expected progress paths are continued no-rate step-5 processing that fences or settles the
currency's machines, or a returned rate that allows accumulated time to finish. The no-rate create
premise is `LDG-40`'s "**create** (MUST halt: it is a purchase priced at an unknown rate)".
These paths are not unconditional process liveness. Late attach with no rate remains undecided
in `pv-gip.27`; this decision does not establish that a later attach cannot introduce a live
unfenced machine after the disposition condition held. That interaction is recorded on that task.

Rejected alternatives:

- **End grace irrevocably at the bound (option A).** The 2026-10-02 decision above says "a
  return resumes the unspent portion, never a fresh interval". Irrevocable expiry would need a
  stored latch: `OVR-19` uses "the value in force when `LDG-64`'s deadline is computed, for an
  outage already open too", so raising the maximum can make a previously reached bound no
  longer reached. This amendment adds no latch.
- **Nothing protected still queued (option B as originally framed).** A later sweep can route a
  cancellation and an operator retry can enqueue a new attempt; an empty queue does not establish
  machine disposition. `LDG-16` says the sweep "MUST route a machine where its stored
  `runway_until` has passed and its currency has a rate"; `API-64` says it "enqueues a fresh
  `delete_machine` attempt under it, both in one transaction".
- **Recorded gone only.** A provider refusing deletion could hold the restore record open
  indefinitely although the existing fence has already ended the extension opportunity.
  `ADR-0028` says "A machine already fenced when the grace begins gets no extension from it".
  `LDG-62` requires an extension to "conditional-write the machine row guarded on
  `machines.destroy_committed IS NULL`" and on refusal to leave "opening or growing no
  commitment and moving no balance". The fence, not a failed attempt by itself, supplies this
  alternative; no new stored disposition is introduced.

**Provenance corrected.** The withdrawn bound exception came from the **caller's** `pv-gip.29`
work order, `/var/tmp/provisiond-gates/gip29.md`: "or for that currency's outage to reach
`LDG-64`'s bound (after which no funding cancellation is left to protect)". The owner's
2026-10-02 comment on `pv-gip.29` instead said "STO-56's close rule and STO-54's close list wait
for the paused grace's end". The original `pv-gip.37` description attributed the work order to
the owner; that attribution was wrong. The owner's 2026-10-03 decision, recorded on `pv-gip.37`,
resolves it with the rule quoted above.

## A solvency check that cannot be computed has not failed — 2026-10-03

The owner accepted the valued-term check on `pv-gip.31` (comment 128). `LDG-40` is the
normative home; its amended solvency row replaces the withdrawn "**the solvency check** (MUST
fail closed)". This changes the treatment of an unavailable currency leg, not the reserve
obligation, and establishes neither whole-pool solvency while that leg is unknown nor a public
assurance. The formal admission matrix records the row, not the monetary calculation.

The reasons:

- `LDG-20` explains its halt because "a customer could pay for a claim the operator had just
  computed it could not honour". A missing rate computes no such insolvency. The withdrawn
  reading invoked "Cancel unsettled Lightning invoices on unexpired deposits" and made the
  deposit read report `gate: "solvency"` for what that requirement calls "a declared
  insolvency". `LDG-19`'s standard applies: "A statement a reader will misunderstand is worse
  than silence".
- Nothing still allowed during the outage changes the unrated term through customer spending.
  `LDG-40`'s create row says "MUST halt: it is a purchase priced at an unknown rate", and its
  extension sentence says "an extension of runway MUST halt as a create does". `LDG-64` says
  "charge the customer nothing for that window". A top-up adds the same satoshis to held and
  float, leaving the margin unchanged. The outage removes knowledge of whether the pool was
  already short, not money. This is a statement about customer spending, not an assertion that
  provider liabilities cannot accrue: the operator's native accrual remains part of the cost below.
- The computable terms still matter. `LDG-17` requires "satoshi reserves at least equal to the
  float plus provider payables already incurred"; `LDG-20`'s stress includes "the
  provider-currency pair adverse by 15%". Held satoshis and float need no currency rate.
  Omitting non-negative payables can only make that inequality easier to satisfy, so a shortfall
  even without them is evidence for the existing halt. The asset basis remains `LDG-53`'s
  "channel balances and confirmed on-chain outputs", subject to `LDG-20`'s "An asset counts
  only if it can reach the provider's account before the liability falls due."

Rejected alternatives:

- **Deployment-wide fail-closed, the withdrawn policy.** It stops healthy-currency business over
  one window and contradicts `LDG-59`'s "a USD quorum loss halts nothing priced in EUR". It
  hands whoever can starve one currency's window a deployment-wide halt plus invoice
  cancellation. `ADR-0027` rejected a per-pass halt because it "handed whoever can disrupt one
  pass a halt they never had"; expanding the blast radius does not answer that objection.
- **A currency-scoped failure.** There is one pool and one verdict, with no subject to scope it
  by. `05-persistence.md` says "a create and the solvency check have no subject to open one for".
- **A last-known or estimated valuation of the unrated leg.** `LDG-59` says "Falling back to the
  last known rate MUST NOT happen." `ADR-0027`'s "One rate, one home" still includes "the
  solvency check. One rate, one home"; this decision does not create another estimator.

**Accepted cost:** for as long as a currency has no rate, a shortfall lying wholly in that
currency's leg (a move of the pair beyond the stress's 15%, plus the outage's native accrual under
`LDG-64`) goes undetected, and top-ups taken meanwhile cannot be refunded (`ADR-0004`: "No
withdrawal of the balance in any form" and "no refunds, ever"). **It lasts as long as the outage,
which the bound does not end: the bound cancels machines, it does not value payables.** `LDG-64`'s
words are "cancel machines at that bound if no rate has returned". The earlier panel suggestion
that this blind spot lasted only until the cancellation bound was not the accepted decision.

**Single-currency consequence:** a deployment whose only currency has no rate checks held
satoshis against the float alone, so top-ups continue through a rate outage; until now they halted.
A shortfall against that float still causes the computed-failure halt. That is a behavior change,
not an assurance that the unknown leg is covered.

The API write table gains a solvency pointer on `extend-runway`: `LDG-62` calls it "authorized
like a purchase". Refusal ordering remains `pv-gip.26`'s question. `CNF-138` holds the outage
conformance cases. The admission guard's off position retains the withdrawn solvency row, and
`.github/workflows/ci.yml` holds its regression control. Neither the matrix proof nor those
conformance requirements are evidence about a running system. Provider-payable resolution
(`pv-gip.39`) and the deposit-read schema (`pv-gip.40`) remain separate work.
