# 02 — Provider driver contract

A provider driver adapts one provider account to the uniform interface below. This
document specifies the interface in prose: each operation's inputs, outputs, errors, and
invariants. It deliberately does not give a signature in any language.

## General obligations

**PRV-1** Every operation MUST be safe to call concurrently on the same driver instance.
The control plane serializes work per machine (`OPS-8`) but not per provider account.

**PRV-2** Every operation except *describe capabilities*, *get machine* and *refresh rescue
session* MUST have a
default implementation that fails with an `unsupported` error naming the operation and
the account. A driver opts in by overriding; it MUST NOT be possible to add an operation
to the interface and silently get a wrong default behaviour in every existing driver.
Of those three, *get machine* is MUST-implement (`PRV-3`); *describe capabilities* is not defaulted
either, but it carries no separate mandate and needs none — `PRV-4` and `DOM-15` make an undeclared
capability unusable, so a driver that declares nothing can do nothing. The third is the one operation
with an explicit non-failing default — `PRV-19` returns the session unchanged, which is safe
only because `PRV-20` forbids a refresh that downgrades one.

**PRV-3** *Get machine* MUST be implemented by every driver. It is the refresh primitive
the whole lifecycle depends on.

**PRV-4** A driver MUST NOT declare a capability it does not implement, and — for every
operation with a capability entry in `DOM-10`'s table — MUST NOT implement one whose capability
it does not declare (`DOM-15`). The three methods with no entry there — *describe capabilities*,
*get machine* and *refresh rescue session* — are outside the second clause; `PRV-2` and `PRV-3`
govern them.

**PRV-5** A driver MUST map provider transport failures to `network`, provider timeouts
to `timeout`, provider non-2xx responses to `provider` (or the more specific
`authentication`, `not_found`, `conflict`, `rate_limited` where the status warrants it),
and MUST attach the upstream HTTP status code to `details.status`. The lifecycle
classifier reads that field to decide whether a failure was ambiguous (`OPS-11`).

**PRV-6** A driver MUST NOT interpolate a caller-controlled value into a provider URL
path without encoding it. Path segments MUST be percent-encoded, and the driver MUST
additionally validate `external_id` against a provider-appropriate character set. An
`external_id` containing `/`, `.`, `?`, or `#` can otherwise redirect the request to a
different endpoint of the same authenticated account. See `DEF-2`.

**PRV-7** A driver MUST NOT expose a provider credential, a generated rescue password, or a
private key in a result, an error, a log or a persisted record; handing a rescue session to the
engine in-process (`DOM-11`) is not exposure. Where it captures a provider response into an
error, it MUST redact first (`DOM-18`).

## Operations

### Describe capabilities

**Input** — none.
**Output** — the descriptor (`PRV-44`).

Pure and synchronous; it MUST NOT perform network I/O. It is called on every capability
check and on every `GET /v1/providers`.

**PRV-44** The descriptor is a typed, immutable value: `account`, `kind`, `capabilities`,
`ordering_channels` (each with `correlator: operation_id | per_order_key | none`, `PRV-32`,
`PRV-33`, `PRV-38`, and `offer_is_resource: true | false`, `PRV-42`), `evidence_sources` per mutation kind in descending strength (`PRV-36`),
`visibility_window` `{declared_seconds, sample_size, measured_on | unmeasured}` (`PRV-36`),
`billing_stop_window` of the same shape (`PRV-13b`), `order_budget` `{limit, per}` (`PRV-40`),
`cancellation_bound` per offer (`PRV-31`) — which MAY be reported on the offer instead —
`rescue_address_family` (`RSC-45`), and `surviving_attachments` (the kinds that survive deletion,
each with `cleanup: api | manual`, `PRV-13a`). A field with nothing to declare says so explicitly.
**A value the engine reads MUST come from here and never from `08-provider-notes.md`**, which is
commentary on why a descriptor says what it says (`ADR-0018`). `WIR-29` exposes a subset of it.
`CNF-18` iterates its fields as it iterates capabilities: a declared value has a working code path
behind it.

### List offers

**Input** — none.
**Output** — offers (`DOM-9`).
**Capability** — `list_offers` (`DOM-22`); a driver that cannot enumerate offers does not
declare it, and the endpoint answers `unsupported` for that account.

May aggregate several provider endpoints (for example a standard catalog and an auction
market). Offers from different channels MUST be distinguishable by their identifier so
the create path can route on it.

### Create machine

**Input** — offer identifier, optional region, hostname, optional image, SSH public
keys, optional user data, labels, and a provider-options object.
**Output** — the created machine.
**Capability** — `provision_virtual` or `provision_bare_metal` per `DOM-10`.

**PRV-8** Create MUST require at least one SSH public key. The control plane MUST NOT
persist a provider-generated root password, so a machine created without a key would be
unreachable.

**PRV-9** Where the provider requires SSH keys to be registered as account-level
resources before they can be attached, the driver MUST create them, attach them, and
then remove them — but it MUST NOT remove them until the provider has actually consumed
the key material. For a synchronous create that copies key material at creation time,
cleanup immediately after the create call returns is correct. For an *asynchronous*
deploy that reads the key registration later, immediate cleanup produces a machine
nobody can log into. The driver MUST know which of the two its provider is, and the
adapter notes MUST record the answer. See `DEF-6`. **Every temporary key resource a driver
registers — for a create or for rescue — MUST carry the operation id as its provider-side name or
tag** (*added 2026-09-16, `pv-lld`*), so that `OPS-32`'s sweep can find one the engine did not
remove: a crash between registration and cleanup leaks the resource, the session's cleanup token
dies with the process (`DOM-11`), and `PRV-18`'s leaked-resource ids are attached only where the
driver itself saw the failure. The image import carries the correlator for the same reason
(`RSC-42`).

**PRV-10** For a provider that bills on order, create MUST reject the request unless the
request's provider options carry an explicit purchase acknowledgement, *and* the account
is configured to allow ordering. Both, not either.

**PRV-11** Ordering is generally not idempotent at the provider. Where create polls an
order transaction to completion, timing out MUST produce a `timeout` error whose message
states that the order may still be pending and MUST NOT be blindly repeated, and whose
details carry the transaction identifier.

### Get machine

**Input** — `external_id`.
**Output** — the machine as the provider currently reports it.

**PRV-12** Get machine MUST be read-only and free of side effects. It is called
opportunistically after other actions and during reconciliation.

*`PRV-28` — adoption as get-machine plus a local row — is withdrawn with adopt (`ADR-0020`). What
it said about attachment survives here because it is about resolution, not adoption:*
`OPS-27`'s resolved-observed outcome attaches a machine discovered by its correlator by reading it
(`PRV-12`) and writing the row, so attachment inherits `PRV-12`'s side-effect-free guarantee and
reconciliation cannot mutate anything (`OPS-28`) even by accident.

### Delete machine

**Input** — `external_id`.
**Output** — an action result.
**Capability** — `delete_machine`.

**PRV-13** Deletion semantics differ by provider and MUST be modelled, not assumed. Three
shapes exist:

| Shape | Behaviour | May declare `delete_machine` |
|---|---|---|
| Immediate destroy | Resource gone, billing stops | yes |
| Scheduled cancellation | API accepts a cancellation date, possibly bounded by a provider-reported earliest permitted date | yes, with the caveat below |
| Out-of-band process | Support ticket or contract negotiation, no API | no |

A driver in the second category MUST surface the effective cancellation date in its action
result, because "deleted" does not mean "billing stopped" there. A driver in the third
category MUST NOT declare `delete_machine`; modelling a contract termination as a synchronous
API call is a business error, not a missing feature.

**PRV-13a** Deleting a machine does not necessarily delete everything billable that was
attached to it. A driver MUST declare which associated resources — volumes, snapshots,
backups, reserved addresses — survive machine deletion and continue to bill, and MUST expose
cleanup for every such resource the provider's API can delete. **AMENDED 2026-09-08
(`ADR-0018`) — the declaration and the cleanup both had no carrier.** The kinds are declared in
the descriptor's `surviving_attachments` (`PRV-44`), each with `cleanup: api | manual`, and the
cleanup is `PRV-45`'s *release attachment*. Only resources the API cannot reach may be left to an
operator procedure, and those are the `manual` ones. A control plane that reports a machine
deleted while its storage continues to accrue cost is reporting a falsehood.

**PRV-13b** A system that resells a machine on prepaid terms MUST be able to bound its own
exposure before taking money. That requires, per product: an API path to stop the cost, a
**measured** worst-case delay before cost actually stops, and cleanup for every billable
attachment (`PRV-13a`, `PRV-45`). *"Measured" has a procedure (`F18`): the worst observed
request-to-billing-stop latency over at least twenty real deletions on that product, in seconds,
declared in the descriptor's `billing_stop_window` with its sample size and date (`PRV-44`) —
re-declared when the provider changes the API. Until twenty samples exist, the driver MUST carry a
declared conservative bound instead, marked as unmeasured.* The effective value is `PRV-36`'s
`max(declared, max(observed))` over `STO-53`'s `billing_stop` samples.

The reserve is computed **in the provider's billing currency** and converted once, when the
commitment is opened or re-sized, into the ledger unit:

```
reserve_native = setup_fee                              # at cost, no markup (ADR-0006)
               + requested_runway × customer_rate       # PRV-13d, customer-chosen
               + wind_down_cost                         # see below
               + billable_attachments                   # PRV-13a
               + cost_through_earliest_cancellation_date # exception branch only (PRV-13c)

commitment_sats = to_ledger_unit( reserve_native × (1 + conversion_haircut) )
```

*The `accrued_unbilled_usage` term was deleted from this formula on 2026-09-02.* Nothing produces
it: the sizing happens at create, where by construction no usage has accrued, and once the meter was
specified (`LDG-37`, `LDG-38`) consumption became a debit against the commitment rather than an
input to it. It is a survivor of the first version of the ledger — the one `12-billing-and-ledger.md`
opens by saying "consumed `accrued_unbilled_usage` in `PRV-13b`'s reserve formula and never said
what produced it". Deleted rather than tombstoned: nobody re-adds a zero term by accident.

**`customer_rate`, not provider cost.** The reserve must cover what the *customer* is committing
to spend, and since `customer_rate ≥ provider_rate` by construction, committing the customer
price also covers the operator's exposure. Using provider cost here would under-commit every
machine by exactly the margin. **The setup fee is committed at cost and debited only on confirmed
acceptance (`LDG-39`)**, because `ADR-0006` passes it through unmarked — the operator does not
profit from a fee it did not earn — and it is also the one term that is entirely lost once the
order lands, so it MUST be **fully committed before the order is placed**. *Both withdrawn
readings — "fully collected before the order" and "debited before the order is placed" — charged
the customer for a fee the operator never incurred whenever the provider rejected the order
outright or the create resolved absent.*

**`F18` fixed: there is one haircut and it belongs to the conversion, not to the sum.** The
earlier text trailed `× fx_haircut` after the formula without saying whether it multiplied the
whole reserve or only the foreign-currency part, and it conflated two different risks. They are
now separated:

- The **conversion haircut** covers the spread and the rate's staleness at the instant of
  conversion. It applies to the conversion, once.
- **There is no volatile-asset haircut**, because the reserve is no longer held in a volatile
  asset relative to its own liability. Under `ADR-0003` the ledger is denominated in satoshis
  and so is the customer's balance, so a bitcoin move re-prices the *customer's* purchasing
  power, not the operator's coverage. Movement is handled by re-deriving **`runway_until`** each
  period (`PRV-13e`, `LDG-33`) — *not by re-deriving the commitment, which `ADR-0011` withdrew* —
  and not by over-collateralising it once.

**`wind_down_cost` is conditional, and an earlier revision of this paragraph got it wrong in a way
worth recording.** That revision claimed `OPS-27` had reduced it from an on-call-rota figure
(24–72 hours) to minutes, because "a cancellation's true outcome is readable from provider
state." **The premise was false as stated.** `PRV-26`'s correlator is written by *create* and
identifies the create operation; a cancellation is a different operation with a different id and
nothing written provider-side, so there is no correlator to search for. That mistake mattered
because the claim was used to shrink a number every machine's reserve depends on — a
reconciliation error propagating into systematic under-reserving across the whole fleet.

What is actually true is narrower and is now stated as `PRV-29`: a cancellation's outcome is
recoverable **if and only if** the driver can read enough provider state to distinguish
*rejected*, *accepted-pending*, *scheduled for a future date* and *complete*. Where it can, size
`wind_down_cost` as **detection interval + measured confirmed-cancellation latency + margin**.
**Where it cannot, the pager-latency figure stands** — and `PRV-13c`'s exception branch is
exactly where it cannot, because a scheduled cancellation's cost runs to its effective date
regardless.

**PRV-29** **AMENDED 2026-08-31 — the test is bounded freshness of evidence, not richness of
state.** For any ambiguous mutation **other than create**, resolution MUST proceed by reading
authoritative, non-mutating provider evidence anchored to the machine's known `external_id` and,
where available, to the mutation attempt itself — the identifier is known, which is precisely what a
lost create reply lacks. `PRV-36` ranks the sources and bounds their freshness.

**A driver can resolve a non-create mutation if and only if it can bound the time after which its
evidence is truthful** — by a source that is truthful immediately (the write path's own report, the
provider's mutation history) or by `PRV-36`'s measured visibility window on a resource read. A
driver that can do neither declares so in the descriptor's `evidence_sources` (`PRV-44`), and its
machines MUST carry the unreduced `wind_down_cost`.

Where a provider genuinely has long-lived *scheduled* and *accepted-pending* states — the
robot-style cancellation with an effective date (`PRV-13c`, `DOM-19`) — the driver MUST additionally
separate *rejected*, *accepted-pending*, *scheduled with an effective date* and *complete*, because
there all four persist and look identical from outside.

*The withdrawn text demanded that richness from every driver and said a driver that can only answer
"the machine still exists" cannot resolve a cancellation. That was wrong in two directions at once.
**Too narrow on evidence:** it mandated a `PRV-12` machine read and thereby excluded the stronger
action-log and write-path sources `PRV-36` now ranks above it. **Too weak on freshness:** a naive
driver satisfies its letter — it reads state for a known id — and still concludes "the delete
failed" eight seconds after a successful delete, which is a confident wrong answer that an operator
verb can act on, and worse than "I do not know". And it was perverse in the reserve: on a cloud
provider that deletes immediately, the four states collapse to applied/not-applied plus an interval
the window bounds, so the old wording put the provider with the **fastest** deletes into the
**worst** `wind_down_cost` bucket — inflating, through `PRV-13b`, the commitment every customer must
post before buying anything.*

**Mutation complete, resource absent, and billing stopped are three different facts** and MUST be
evidenced separately. An action reporting `completed` does not establish that billing stopped, which
is `LDG-32`'s test and `PRV-13a`'s attachments' as well.

**AMENDED 2026-08-15 — `wind_down_cost` MUST include the time the cancellation spends waiting for
the machine.** Both sizings above measure from the moment the provider is *called*, and
neither accounts for reaching that moment. An exposure-reducing cancellation is an ordinary
operation: it holds the machine (`OPS-8`), and where a long-running operation already
holds it — an install — the cancellation is deferred with a short delay (`OPS-8`), not failed
and not escalated. The wait is therefore bounded by the deployment's longest
machine-holding operation, which on the dedicated product is a full rescue-and-install
(`06-rescue-install.md`), and it falls on exactly the machine being reinstalled when its funding
runs out.

The term is **the deployment's stated worst-case operation hold** — the longest an operation may
hold a machine under `OPS-8` — and it MUST be stated with the other deployment parameters
(`OVR-19`). Naming it rather than pre-empting the hold is deliberate: the exposure is one
machine's burn for one install's duration — bounded, priceable, and cheaper than a mechanism that
destroys an in-flight install to save it. `OPS-39`'s "pacing MAY delay such a cancellation
briefly" is what this term prices; *briefly* is the install's length, and the reserve must say so.

**Where billing is capped per period, that cap is a catastrophe bound worth having.**

**PRV-13d** A create MAY carry a caller-requested **runway** — how long the machine should be
guaranteed to run before an exhausted balance can cancel it. The deployment MUST enforce a floor
equal to `wind_down_cost`'s duration (`OVR-19`), below which the operator is not covered, and MUST reject a
create whose available balance cannot fund the resulting commitment. Making runway a caller input
rather than an operator constant matters because the caller is software that knows its own
intent: a two-hour scratch box and a machine meant to survive a month should not freeze the same
amount of a customer's balance.

**PRV-13e** **AMENDED twice the same day, and repeatedly since — the history is the lesson.**
Re-derivation MUST run at the deployment's stated **re-derivation interval** at the current rate,
and what it recomputes is **`runway_until`, not the
commitment** (`LDG-33`, `ADR-0011`). *Withdrawn 2026-09-25 (`ADR-0028`): "**It never writes
`machines.destroy_not_before`**, which is `STO-54`'s and runs on wall clock" — no machine carries a
deadline; the restore grace is `STO-56`'s `grace_ends_at`.* *Withdrawn 2026-09-23 (`ADR-0027`): the
duty to
maintain `machines.rate_confirmation_ref` — the reference itself is withdrawn, `LDG-16` keeps its
record, and what follows is the record of the forms its setter took.* *Amended 2026-09-21
(`ADR-0026`): the withdrawn form maintained one column, `machines.exhausted_since`, set to **the
derivation instant**, and an instant says when provisiond computed rather than which price it used —
two derivations an interval apart can consume the same observation (`CONTEXT.md`, **Derivation**).
Added 2026-09-05; it had no mechanism before, and every form it took before the reference is kept
here because each is re-layable (`README.md`): setting it on **any past date** delayed natural
expiry; a **past-only** form missed a jump landing just short of the next derivation; a
**horizon-only** form let one poisoned reading move a date from thirty minutes out to one minute
past with the column still null; and the disjunction of those two, with the horizon qualifying the
set while the clear stayed unqualified, left the horizon half unreachable from 2026-09-05 to
2026-09-21. Arming on every backward move of a date that stood in the future is what covered all of
them at once.*

**AMENDED 2026-09-02 — the interval is this requirement's own parameter, and it is not the billing
period.** The withdrawn wording was "each billing period", and `LDG-68` later defined that as the
**UTC calendar month** while explicitly claiming it had carried this cadence. **Nothing in the set
works monthly**, and four things break outright:

- `runway_until` is "the customer's whole visibility into repricing" (`LDG-15`) and would be up to a
  month stale, on a date the exhaustion sweep reads to decide whether to destroy a disk (`LDG-13`,
  `05-persistence.md`'s `runway_until` index);
- the rule `LDG-16` and this requirement then carried, "a deficiency MUST persist across more than
  one derivation" — then the control standing between a glitching price feed and a destroyed disk,
  withdrawn from `LDG-16` 2026-09-21 and retired here 2026-09-23 for `LDG-58`'s window (`ADR-0027`)
  — would have meant **two months**, during
  which an unfunded machine billed;
- `PRV-13c`'s "materially in the future", defined as *now + one re-derivation period + wind-down*,
  would swallow every cancellation date inside about thirty days into the ordinary path, deleting
  the `DOM-19`/`LDG-63` exception branch for exactly the products it was written for;
- `ADR-0003`'s footnote priced the derivation-count wait, retired 2026-09-23 (`ADR-0027`), at "a
  few extra hours" and `ADR-0011` speaks of "two derivation periods" inside one night. Both are
  describing hours; the requirement said a month.

**A deployment MUST state the interval with the other deployment parameters (`OVR-19`), and it MUST
be short enough that none of those still standing breaks.** *Hourly is the sensible default*, which
makes `PRV-13c`'s "materially in the future" a few hours plus wind-down, and `runway_until` never
more than an hour stale. The floor is the cost of the pass itself; the ceiling is a machine's
runway: **the interval MUST stay small against a machine's runway**, since a machine can drain its
whole commitment inside one interval and nothing would notice. **The interval is not the rate
window** (added 2026-09-23, `ADR-0027`). The window is `LDG-58`'s, which states its default, and is
the span the rate is taken over; the interval, hourly by default, is how stale `runway_until` may
be. They are two different spans, the bound above is on the interval alone, and a default window
(`LDG-58`) is longer than many runways. *Withdrawn 2026-09-23 (`ADR-0027`): the hourly default
"makes `LDG-16`'s persistence window a couple of hours", and "the ceiling is `LDG-16`'s window,
which MUST stay small against a machine's runway". Both called the interval `LDG-16`'s window; once
the rate is taken over `LDG-58`'s window, that name reads as the rate window, and the ceiling binds
the wrong span.*

**The billing period and the re-derivation interval are different quantities and MUST NOT be
derived from each other.** The period is a **boundary** for the meter's arithmetic
(`LDG-68`); this is a **staleness bound** on a price-derived date. `LDG-68` fused them in a sentence
about what a phrase had carried, and the fusion is withdrawn there as well. The commitment is fixed at open and exactly **two** paths
increase it: a caller action (`LDG-62`) and the scheduled-cancellation exception
(`LDG-63`) — the one automatic one (`ADR-0017` deleted the third). *Version one said a
higher re-derivation places "an additional hold" — stacking a second reservation, the double-count
`LDG-9` was amended to remove. Version two re-sized the single commitment upward automatically —
solving the operator's anxiety with the customer's money, and creating a freeze surface where one
bad rate reading grabs every tenant's available balance.* Where the recomputed runway has already
run out, the machine enters the same
balance-exhaustion path as a customer who simply ran out of money. **A price or rate movement
MUST NOT be a special case with its own machinery** — it is an ordinary way for a balance to
become insufficient. `LDG-16` says both that "no single rate observation moves the rate outside the
range the window's other observations carry" and that "a plausible price carried by half the window
can move the rate to itself" — both consequences of the rate being `LDG-58`'s lower median over its
window, and `LDG-16` owns the promise they keep.

*The per-tick increase cap that stood here is **withdrawn** with the resizing it governed
(`LDG-16`): under `ADR-0011` nothing increases per tick, so capping the increase capped nothing.
The note that followed, calling the derivation-count persistence rule "the control that matters",
is retired 2026-09-23 (`ADR-0027`): a count of derivations measured the wrong unit, and `LDG-58`'s
window median is that control now.*

**Where billing is capped per period, that cap is a catastrophe bound worth having.** If total
failure to cancel costs at most `setup_fee + one period cap` per machine, record it: the
reserve above is the expected case, and the cap is the provable upper bound.

**PRV-31** **A driver MUST declare, per offer and before any order, a worst-case cancellation
bound** — the latest `earliest_cancellation_date` a machine bought from that offer can carry —
and an offer with **no declared bound MUST NOT be sold on prepaid terms.** This closes `F26`'s
circularity: `PRV-13c` learns the per-machine constraint *after* ordering, while `LDG-12` forbids
the order before the commitment exists, so for an offer that hides its terms the commitment could
only be sized after the purchase it authorizes. The declared bound sizes the commitment at
create. **The machine's *actual* date, read after ordering, updates the
cost-through-earliest-cancellation-date term of `LDG-33`'s `protected_sats` — it MUST NOT
resize the commitment.** A shorter actual term therefore lengthens the customer's runway rather than
returning satoshis, which is the same money reaching the customer through the mechanism
`ADR-0011` sanctions instead of through an automatic resize it forbids. The bound is declared in
the descriptor's `cancellation_bound` (`PRV-44`), or reported on the offer. In practice the bound is trivial for the launch set — current Robot
dedicated servers have no minimum term and a new machine's date is normally today
(`08-provider-notes.md`). *A clause here said adoption never needs the bound because an adopted
machine's date is read before its commitment opens; adopt is withdrawn (`ADR-0020`), and the
clause was false while it stood, since the commitment opened at enqueue.*

**PRV-13c** **A deployment MUST NOT encode any provider's current commercial terms as
constants.** Minimum term, notice period, cancellation immediacy and billing granularity are
per-contract facts that change, differ between a provider's own product lines, and differ
between one contract and the next.

The required shape is read-and-branch: order, then **read** the provider's per-machine
cancellation constraint, and branch to the exception path when it is **materially in the
future** — defined (`F18`) as later than now plus one re-derivation period plus the product's
wind-down bound; anything nearer is indistinguishable from the ordinary exhaustion path and
needs no exception —
(`DOM-19`). A machine on the exception branch MUST either carry a machine-specific reserve of
cost-through-that-date, or not be sold on prepaid terms at all. **That cost is part of
`protected_sats` (`LDG-33`), not spendable runway** — the whole point of reading the date is that
the satoshis covering it are never advertised as runtime.

*This requirement exists because a specification, a reviewing model, and a researching model
each asserted a different set of terms for the same provider, and two of the three were wrong.
Assumptions about commercial terms do not survive review, and they do not survive the provider
changing them. Until 2026-09-08 this paragraph called adoption the main road onto the exception
branch; adopt is withdrawn from v1 (`ADR-0020`), and the branch stays specified because the
read-and-branch shape is what makes a machine with an inherited contract safe when it returns.*

### List attachments / Release attachment

**Input** — *list attachments*: `external_id`. *Release attachment*: an attachment's `kind` and
`external_id`.
**Output** — *list*: the attachments the provider still holds for that machine, each
`{kind, external_id, billable, cleanup: api | manual}`. *Release*: an action result with
delete's outcome classes.
**Capability** — `delete_machine`. No capability of their own: a driver that can delete a
machine can say what it left behind (`ADR-0018`).

**PRV-45** *List attachments* is read-only under `PRV-12`'s guarantee. The engine MUST call it on
every delete that succeeds with the resource gone and MUST write one `machine_attachments` row
(`05-persistence.md`) per attachment returned, in the same transaction as the delete's outcome.
*Release attachment* is its own operation kind, `release_attachment` (`WIR-10a`), one operation
per `machine_attachments` row: enqueued by the delete's terminal transaction for every `billable`
row whose `cleanup` is `api`, and by an operator against a row that still holds `STO-18`'s
tombstone gate open. It is a kind rather than a phase of the delete because a delete that succeeded
with the resource gone and a release that failed ambiguously are two facts, and one operation
cannot carry two statuses — the shape `ADR-0017` corrected on the episode. It holds the machine
under `OPS-8`, MUST be safe to call twice — a provider answering "already deleted" is reporting
the goal state, which `OPS-11` classifies as success — and its failures classify under `OPS-11`'s
delete row. A successful release writes the row's `released_at` in its terminal transaction; a
`manual` row is released only by an operator.

### Power

**Input** — `external_id`, one of power-on / power-off / reboot / hard-reset.
**Output** — an action result.
**Capability** — `power_control`, or `hard_reset` for the hard reset.

**PRV-14** A driver MUST distinguish a graceful reboot from an out-of-band hard reset,
and MUST return `unsupported` for hard reset rather than silently substituting a
graceful one. On bare metal these have very different consequences.

### Begin rescue

**Input** — `external_id`, and a rescue access request carrying a key name and a
freshly generated single-use public key.
**Output** — a rescue session (`DOM-11`).
**Capability** — `rescue_ssh`.

**PRV-15** Begin rescue MUST both activate the rescue environment *and* initiate the
reboot or reset needed to enter it. The rescue engine waits for SSH; it does not reboot.

**PRV-16** Begin rescue MUST populate the session's host keys with complete OpenSSH
public host keys whenever the provider exposes them. A driver MUST NOT return an empty
host-key list when the provider published keys the driver simply did not parse.

**PRV-17** Begin rescue SHOULD use the supplied ephemeral public key. A driver that uses
provider-generated password authentication instead MUST document why (the provider offers
no key-based rescue), because it forces the workflow onto a password that a
first-connection attacker can capture when host-key pinning is unavailable. It MUST NOT
accept the ephemeral key and then ignore it. See `DEF-7`.

**PRV-18** Begin rescue MUST clean up after itself on partial failure. If the rescue
environment is activated but the reboot fails, the driver MUST attempt to deactivate
rescue and remove any temporary key it registered. If that cleanup itself fails, the
driver MUST attach the identifiers of the leaked resources to the error's details so an
operator can find them. Where the engine dies instead, nothing attaches anything, and the
tagged key resource is `OPS-32`'s to remove (`PRV-9`).

### Refresh rescue session

**Input** — `external_id`, the current session.
**Output** — an updated session.

**PRV-19** Refresh MUST be safe to call repeatedly while waiting for the rescue system to
boot. Its purpose is to pick up metadata — most importantly host keys — that a provider
only publishes once the rescue environment is running. The default implementation returns
the session unchanged.

**PRV-20** Refresh MUST NOT downgrade a session: it MUST NOT clear an already-known host
key set, and MUST NOT replace key material with an empty value.

### End rescue

**Input** — `external_id`, the session.
**Output** — an action result.
**Capability** — `rescue_ssh`.

**PRV-21** End rescue MUST deactivate the rescue environment, reset or reboot into the
installed system, and remove any temporary credential it registered, using the session's
opaque cleanup token to find it. A credential this call never reached — the engine died first,
or the call was lost — is found by its operation-id tag and removed by `OPS-32`'s sweep (`PRV-9`).

**PRV-22** Failure of end rescue is *always* ambiguous — the machine may be in rescue, may
be rebooting into the new system, and a temporary credential may still be registered. The
driver MUST surface it as an error rather than swallowing it, so the lifecycle can route
the operation to reconciliation (`OPS-11`).

### Rebuild

**Input** — `external_id`, a catalog image, optional hostname, SSH keys, user data, and
provider options.
**Output** — an action result.
**Capability** — `native_rebuild`.

**PRV-23** Where the provider's rebuild API has no field for SSH keys and the driver
injects them through a first-boot script instead, this MUST be documented in the adapter
notes, because it silently depends on the target image running a first-boot agent, and it
conflicts with a caller-supplied first-boot payload. The driver MUST NOT quietly discard
either the keys or the caller's payload.

### Import a catalogue image, and build from it

**Input** — a URL provisiond serves (`RSC-39`), a `sha256`, a compression, a size bound, a
provider-side tag carrying the operation's correlator (`RSC-42`), and — for the build — an
`external_id` plus optional hostname, SSH keys, user data and provider options.
**Output** — an opaque provider-side image identifier, then an action result for the build, then an
acknowledgement of the delete.
**Capability** — `install_via_provider_catalogue`.

**PRV-37** **ADDED 2026-09-02 — the capability had no driver operation, which `DOM-15` calls a
defect.** `DOM-10` maps `install, provider_catalogue` to `install_via_provider_catalogue`, `ADR-0013`
and `RSC-39`–`RSC-43` specify the feature in full, and the only install-shaped operation in this
document was *Rebuild*, whose capability is `native_rebuild` — so a driver declaring the catalogue
capability had nothing to implement and `DOM-15`'s "declaration and implementation MUST agree" was
unsatisfiable in one direction. **The operation is three provider calls and MUST be exposed as
three**, because each fails independently and two of them cost money:

- **import** — submit the URL, then poll to a usable state, both **with the operation yielded**
  (`RSC-41`, `OPS-8`) and inside that requirement's stated maximum wait;
- **build** — the switch-over, holding the machine, re-validated first (`OPS-23`); this is where
  the driver may reuse whatever it uses for *Rebuild*, but the capability gate is the catalogue one
  (`DOM-10`), because the caller's promise is `DOM-28`'s and not `native_rebuild`'s;
- **delete the imported image** — called on settle and on entry to `needs_reconciliation`
  (`RSC-42`), and **it MUST be safe to call twice**: `OPS-32`'s sweep deletes orphans, and a
  provider that answers "already deleted" is reporting the goal state, which `OPS-11` classifies as
  success.

**The driver MUST declare the offer-level bound `RSC-40` enforces** (`max_image_bytes`, `WIR-30`)
and **MUST NOT declare this capability where it cannot delete an imported image through the API** —
an import it cannot remove is a copy of a customer's operating system left in the operator's account
after the deployment undertook to destroy it (`SEC-55`, `RSC-42`), which is the same shape `PRV-13`
refuses for a machine whose cost cannot be stopped.

### Set reverse DNS

**Input** — an IP address, a hostname.
**Output** — an action result.
**Capability** — `reverse_dns`.

**PRV-25** The caller-supplied IP MUST have been verified by the control plane to belong
to the machine before the driver is called (`API-16`). The driver MUST still encode it
into the request path safely (`PRV-6`).

### Carrying a correlator

This is not an operation. It is an obligation on **create**, and it is what makes automated
recovery from an ambiguous outcome possible at all.

**PRV-26** **This applies to create and to nothing else.** A create is the only mutation whose
target identifier is unknown when the reply is lost; every other operation names a machine whose
`external_id` the system already holds, and resolves by reading its state instead (`PRV-29`).
Stating the scope matters because an earlier revision quietly assumed correlators covered
cancellation too, and priced the reserve accordingly.

A create MUST carry the operation's identifier into the provider, using whatever
caller-controlled field that provider offers, and the driver MUST be able to find resources
bearing it afterwards. Every provider examined offers **either a free caller-controlled field or
a per-operation artifact that can serve as one** (`PRV-32`, `08-provider-notes.md`) — Hetzner
Robot is the second case, because its only free field is disqualified by `PRV-30`. A driver that
can find neither is asserting something unusual about its provider and MUST say so in its notes —
because it thereby forfeits automated reconciliation (`OPS-27`) and hands every ambiguous create
to a human.

Three constraints on what is written:

- **It MUST be opaque and unique per operation, and it is recorded once.** The
  operation UUID where the provider offers a free caller-controlled field; where it does not, a
  per-order artifact durably bound to the operation before the order is sent (`PRV-32`'s SSH key
  fingerprint is the live case). Nothing else. Whichever it is, the kind and the value MUST be
  recorded on the operation row — `operations.correlator_kind` and
  `operations.correlator_value` (`05-persistence.md`) — before the order is sent, because a
  create whose reply was lost has no machine row to carry them and reconciliation would
  otherwise have nothing durable to search for. It MUST NOT encode the
  tenant, a customer identifier, a hostname the customer chose, or anything else linkable to a
  person (`ADR-0005`). Anyone reading the operator's provider console sees an opaque token.
- **It MUST be written in the same request that performs the mutation**, never as a follow-up
  call. A correlator applied afterwards is absent in exactly the case it exists for — the
  request whose reply was lost.
- **It MUST survive the payload purge.** The correlator is a provider-side identifier, which
  `OPS-13` already requires be retained, so it outlives the request body it was derived from.

**A create has exactly one attempt and records exactly one correlator** (`ADR-0014`, `ADR-0017`).
`correlator_kind` and `correlator_value` are a single pair on the operation, written
before the order is sent. `OPS-27`'s search has one value to try. `OPS-38`'s cardinality check is
**not** thereby unnecessary: `API-51` makes a duplicate purchase reachable across two separate
operations under two idempotency keys, and a provider can produce two resources from one order, so
"more than one" remains a real finding — what is gone is the documented procedure inside a single
operation that used to produce it.

**PRV-27** **AMENDED — the original required something impossible.** It said the driver "MUST
record the provider's own transaction identifier **before** treating the outcome as ambiguous."
The ambiguity that matters is the one where the order's *reply was lost*, so the transaction
identifier was generated by the provider and never arrived. The requirement was satisfiable only
in the cases that did not need it, and `CNF-90` tested exactly the impossible case.

What the driver MUST actually do, where the caller-controlled field lives on an *order* rather
than on the resulting machine (the robot-style shape):

- **resolve by searching the provider's transaction listing for the correlator**, which answers
  "which orders did I place" directly rather than inferring it from which machines exist;
- record the transaction identifier **when it is observed** — on a successful response, or on a
  poll timeout that carries it (`PRV-11`) — as an accelerator, never as a precondition;
- treat the listing window as the horizon beyond which automatic resolution is impossible
  (`08-provider-notes.md`), and `OPS-31` as the only remaining road.

**PRV-30** **CONFIRMED IN WRITING 2026-08-13 — no longer `[verify]`, and it removes a field the
design was relying on.** A provider's caller-controlled field MUST NOT alter how the order is
processed, and **Hetzner Robot's order `comment` violates exactly that.** The `hrobot-rs` client
documents it on the field itself:

> `/// Comment for the order. Note that comments require manual provisioning,`
> `/// which can increase the processing time for the purchase request.`
> — `MathiasPius/hrobot-rs`, `src/api/ordering/models.rs`, `ProductOrder::comment`

The same caveat appears on the auction-market order. This is the written verification `CNF-148`
demanded.

**Confirmed first-party 2026-09-04.** The caveat is not only a client library's doc comment — it is
in Hetzner's own API parameter table, on **both** ordering endpoints: "comment — Order comment
(optional); Please note that if a comment is supplied, the order will be processed manually."
**[observed 2026-09-04]** The library was right and the provider says so itself. **The `comment` field MUST NOT be used as a
correlator, or for anything else, on a Robot order.** Using it would convert every dedicated order
into a human-latency order and invalidate the negative window (`OPS-33`) for the one product where
a lost reply is most expensive.

This is the second correlator premise to fail on inspection (`PRV-26`'s create-only scope was the
first), and the pattern is worth stating: **a caller-controlled field is only a correlator if
writing to it is free.** A driver MUST NOT adopt a field as a correlator without evidence that
carrying it changes nothing about how the provider handles the request — latency, routing, or
review. Absence of a documented side effect is not evidence.

**PRV-32** **The Robot correlator is a per-order throwaway SSH key, and it MUST be verified before
the Robot driver ships.** With `comment` unusable, the remaining caller-set field on a Robot order
that plausibly carries no processing side effect is the **authorized SSH key**: `PRV-9` already
requires the driver to register a temporary key per order, so making it **unique per order** costs
nothing and its fingerprint is a stamp the operator chose. Resolution then lists recent order
transactions (`08-provider-notes.md`) and matches on that fingerprint.

**Both conditions were verified against two client libraries on 2026-08-13, and against the live
API on 2026-09-04 — on the auction channel only; the standard channel remains open (`F37`).** *The
sentence read "verified 2026-08-13 and the hypothesis holds" until 2026-09-05, three lines above an
amendment recording that a library reading is not a live order and that only one of two channels
has had one.*

1. **The transaction listing returns the key, with its fingerprint.** Two independent client
   libraries agree: `hrobot-rs` deserializes a purchased product's
   `#[serde(rename = "authorized_key")] pub authorized_keys: Vec<InitialProductSshKey>`, where
   `InitialProductSshKey { name, fingerprint, algorithm, bits }`; and `appscode/go-hetzner`
   declares `Transaction.AuthorizedKey []struct{ Key *AuthorizedKey } \`json:"authorized_key"\``
   with `AuthorizedKey.Fingerprint`. Both the standard and the auction-market transaction carry
   it. **The match is therefore exact and server-side data, not an inference.**
2. **A distinct key per order changes nothing about handling.** `authorized_key[]` is not free
   text — it is one arm of the order's mandatory authorization choice
   (`AuthorizationMethod::Keys` versus `Password`), so every keyed order already supplies it and
   `PRV-8` already requires one. **Only `comment` carries a processing caveat**; no client
   documents any for the key field, and a differing *value* in a structured field has no mechanism
   by which to summon a human, where free text plainly does.

**The residual was empirical, not structural, and it is now closed on the auction channel by two
real orders.** *The withdrawn sentence said `PRV-34` "makes it free to close"; it does not, and
`F37` is why — a simulated order is never listed, so test mode cannot exercise the half that
matters.* Until a driver's own channel passes `CNF-180`, it MUST declare no correlator and `PRV-33`
governs.

**AMENDED 2026-09-04 — verified against the live API, and per-attempt discrimination is now an
observation rather than an argument.** Two throwaway ED25519 keys were registered and two auction
orders placed, one carrying each fingerprint. Both appeared in
`GET /order/server_market/transaction`, and **each fingerprint matched exactly one transaction**,
naming its own transaction id, server number and product. The first was matched while its
`server_number` was still `null`, which is the case `PRV-27` needs — it requires the driver
"resolve by searching the provider's transaction listing for the correlator, which answers 'which
orders did I place' directly rather than inferring it from which machines exist", and that is what
the listing did. Each order also entered ordinary `in process` handling rather than manual review,
which is two live data points for condition 2. **[observed 2026-09-04]**

That second result is the one `OPS-13` rests on: it requires that "Resolution uses the entry of the
attempt **whose correlator matched**", and on this provider two attempts genuinely carry
distinguishable correlators. It is the reason Hetzner Robot is outside `F36`.

**The correlator format is Hetzner's MD5-style colon fingerprint** — `29:07:2c:f3:97:3b:ad:70:0d:0f:94:be:9a:9b:ff:ce`,
47 characters — not the SHA-256 form `ssh-keygen -l` prints. A driver comparing the wrong
representation matches nothing, forever, and fails silently into `PRV-33`.

**Two residuals remain.** The **standard** channel's listing is unconfirmed with a real order —
only auction was bought, and standard is where the setup fees are (`08-provider-notes.md`) — and
the listing window is still `[verify]`.

**PRV-34** **Robot orders have a test mode, and the driver MUST use it for the order-request half
of conformance testing — `CNF-180`, `CNF-147` and `CNF-281` place real orders, because test mode
cannot reach the listing.** *`CNF-280` was named here until 2026-09-12; it was withdrawn on
2026-09-05 and the items that still order for real are the Robot gate, the dedicated money path
and the every-channel search (`F50`).* *The headline said "MUST use it in conformance testing" until 2026-09-05, unqualified,
directly above its own amendment explaining why that is impossible for the half that matters.*
The order request carries a `test` parameter; with `test=true` the API **simulates** the purchase
and returns a `Cancelled` transaction instead of buying anything. This is a genuinely valuable
provider fact and it was missed until 2026-08-13.

**AMENDED 2026-09-04 — the claim was too broad, and one live order disproved it (`F37`).** Test
mode exercises the **order request** path: shape, authorization, the acknowledgement gates, and
that a caller-set correlator is accepted and echoed in the response. It does **not** exercise the
transaction listing. A `test=true` order returns `201` with `status: "cancelled"` and is then
absent from `GET /order/server/transaction` **and** from `/order/server/transaction/{id}` for the
transaction just created. **[observed 2026-09-04]** The resolution half of `PRV-32` therefore
cannot be confirmed in test mode, and `CNF-180`'s fall-back — one real order — is the only road.
*The withdrawn sentence read: "it means the entire dedicated ordering path — request shape,
authorization, the transaction listing, and the correlator round-trip of `PRV-32` — can be
exercised against the **live** API without a setup fee or a server." It is kept here because `F37`
quotes it, and a finding about a false claim is worth nothing once the claim it names is gone.
"The transaction listing" and "the correlator round-trip of `PRV-32`" were the two items that were
wrong, and they were the two that mattered.*

A deployment MUST therefore: default its conformance runs to `test=true`; treat the *absence* of
an explicit spend intent as test mode rather than as a real order; and verify that a live purchase
sets `test=false` exactly once, at the point `API-15`'s acknowledgement and `PRV-10`'s
`allow_orders` both hold. **A driver whose test flag defaults to "real purchase" turns every
mistaken conformance run into a bought server**, which is the same money-out family as a duplicate
order.

**PRV-33** **Where a provider — or one of its ordering channels — offers no verified correlator,
an ambiguous create on that channel MUST resolve to an operator, never to a guess.** *"Or one of
its ordering channels" was added 2026-09-05: `PRV-32`'s live verification covered Hetzner Robot's
auction channel and not its standard one, so the correlator is a per-channel fact and a provider-wide
reading either forced manual resolution on a verified channel or automated it on an unverified
one.* The driver declares the absence as that channel's `correlator: none` in the descriptor's
`ordering_channels` (`PRV-44`), the deployment MUST surface
the recent-order listing to the operator as evidence, and attaching a discovered machine to a
tenant MUST be an operator action (`OPS-31`, `WIR-35`) — `OPS-29`'s prohibition on heuristic
matching by hostname and timing is not relaxed by the correlator being unavailable. **The
temptation runs the other way**: it is precisely when automatic matching is impossible that
timing-based matching looks reasonable, and a wrong match hands one customer another customer's
physical server.

The cost MUST be stated rather than hidden: for such a provider the `OPS-33` negative window is
bounded by **operator response time**, not by an automatic lookup, and `OPS-26`'s rota is what
determines how long a customer's balance stays committed behind a stuck order.

**PRV-35** **A driver MUST report a machine's network restriction where the provider exposes one,
and MUST declare that it cannot where the provider does not.** This is `DOM-27`'s status, refreshed
on the same path and with the same cache semantics as every other machine field (`DOM-8`), and it
is **not** part of `DOM-7`'s status mapping.

**Where it comes from, per launch driver — each `[verify]` against the live API before it is
relied on:**

| Driver | Signal | Confidence |
|---|---|---|
| Hetzner Cloud | `public_net.ipv4.blocked` and `public_net.ipv6.blocked` on the server object, separate from lifecycle `status` | **[verify]** — documented in the official client schema; high |
| Hetzner Robot | `locked` on each IP and subnet; server status stays `ready`/`in process` | **[verify]** — documented; high |
| DigitalOcean | a Droplet `locked` boolean exists, but is documented only as preventing user actions | **[verify]** — **do not map it**. Nothing official connects it to abuse networking, and reading it as a restriction would report every in-flight resize as a block |

**Where a driver has no signal the restriction is `unknown` until an operator records one**
(`WIR-47`), and `unknown` MUST NOT be rendered as `none`. A field that is silently false when
nobody looked is worse than no field: `none` is a claim, and only an observation can support it.
Where a driver *does* report, the provider is authoritative and an operator entry is the fallback
for a provider that cannot answer — not a competing current value.

*Added 2026-08-16, after `LDG-71` asserted that "nothing knows it is blocked" and a cross-model
check found that Hetzner Cloud and Robot both do. The `DOM-7` exclusion survived that discovery;
the reason written for it did not.*

**PRV-36** **Read-after-write. A read of provider state is not authoritative about a mutation the
driver issued until that provider's effective visibility window has elapsed.**

`OPS-33` already states half of this and states it for creates: absence within the negative window
is **not evidence** that nothing was created. This is the mirror, and it is the half that was
missing — presence within the visibility window is **not evidence** that a mutation did not happen.
One principle, two directions.

**It was measured, not theorised.** Against the live DigitalOcean API on 2026-08-31,
`DELETE /v2/droplets/{id}` returned `204`; a `GET` on the same id eight seconds later returned `200`
with `"status":"active"` and a live public address; it returned `404` only on the next poll. A
driver that reads "the machine still exists" as "the delete failed" therefore reports a successful
deletion as a failure, and the remedy for a failed delete is to perform it again.

**Per mutation kind it can be asked to resolve, a driver MUST declare its evidence sources in
descending strength** — the descriptor's `evidence_sources` (`PRV-44`):

1. **The mutation endpoint's own report that the goal state already holds.** Truthful immediately;
   it comes from the write path. *(The same measurement found `DELETE /v2/images/{id}` answers `422`
   `"Can not delete an already deleted image."` on a second call, while `GET` answers `404` at the
   same instant — the write path and the read path disagreeing about one resource.)*
2. **The provider's mutation history for the known `external_id`** — an action or transaction
   object. This is not a correlator and MUST NOT be described as one: `PRV-26` scopes correlators to
   create, where the identifier is *unknown*. Here it is known, and what is needed is a stronger
   place to read it from.
3. **A read of the resource**, interpreted only through the effective window below.

A stronger source, when consulted, overrides a weaker one. A weaker source never overrides a
stronger one.

**For the resource read the driver MUST declare a measured visibility window** in seconds, with
sample size and date, under `PRV-13b`'s procedure — the worst observed request-to-observation
latency over at least twenty real mutations — carrying a declared conservative bound marked
**unmeasured** until twenty samples exist. **AMENDED 2026-09-08 (`ADR-0018`) — the effective
window is a max, not the declaration.** The declared value lives in the descriptor's
`visibility_window` (`PRV-44`), immutable. The engine writes every ordinary mutation and every
resolution as an observed sample to `provider_observations` (`STO-53`), and the effective window
is `max(declared, max(observed))`. Widening by an observed sample that exceeds the declaration is
thereby automatic; narrowing is a human re-declaring and archiving the samples.

**Within the window, a read showing the pre-mutation state is no evidence and resolution stays
pending.** `OPS-27`'s resolution MUST NOT take its first read before the window has elapsed. **A
read showing the post-mutation state is evidence at any time, and MUST NOT be reverted by a later
contrary read** — reads flap in both directions, and a resolution already reached on absence is not
undone by a stale read. Beyond the window, a read still showing the pre-mutation state resolves
the mutation as *not applied*.

**Exceeding a declared window is a breach of the declaration, not a resolution.** It MUST be
surfaced, it widens future sizing through `STO-53`, and it MUST NOT authorize a replay — `OPS-12`
is untouched by this requirement.

**Visibility and billing-stop are separate measurements and MUST NOT be conflated.** `PRV-13b`'s
delete-to-billing-stop latency asks a different question, overlaps this one in time, and is still
owed for every launch driver. *The 2026-08-31 DigitalOcean sample is a visibility sample, n=1,
recorded as such in `08-provider-notes.md`; it is not a billing-stop sample.*

**PRV-38** **A provider with more than one ordering channel has more than one transaction listing,
and a search of one is not a search of the provider.** Hetzner Robot's standard catalogue and
auction market keep separate listings: with one live auction order outstanding,
`GET /order/server_market/transaction` returned it while `GET /order/server/transaction` answered
`404 no transactions found` in the same second. **[observed 2026-09-04]**

`OPS-27` requires a search over "**every correlator the operation recorded**". That is necessary and
not sufficient. **The union MUST also be taken over every ordering channel the driver can order
through**, and a driver declares its channels in the descriptor's `ordering_channels` (`PRV-44`).

The cost of getting it wrong is not a missed match. A resolution that searched one channel and found
nothing reaches `OPS-27`'s second row — "The provider's search is authoritative and returns nothing
for any of them, and the negative window has elapsed" — whose effect that table gives as "Closed and
released in full (`LDG-32`)". So the customer's balance is released and the operation closed while a
physical server bought on the other channel runs unrecorded at the operator's expense. `OPS-32`'s
account sweep MUST therefore cover every channel too; it is the only thing that would ever find it,
and that document states its interval as "the maximum time a customer can be billed for a machine
that no longer exists" — here it bounds the mirror case, a machine nobody is billed for at all.

**PRV-39** **A provider that answers an empty search with an error status MUST have that answer
translated into an empty result, never into an error kind.** Hetzner Robot returns
`404 {"error":{"code":"NOT_FOUND","message":"no transactions found"}}` for a transaction listing
with nothing in it — the same status and the same word as a genuinely missing resource.
**[observed 2026-09-04]**

`PRV-5` is where this is decided: it maps "provider non-2xx responses to `provider` (or the more
specific `authentication`, `not_found`, `conflict`, `rate_limited` where the status warrants it)",
and here the status does **not** warrant `not_found`. A driver that takes the obvious reading
converts `OPS-27`'s *resolved-absent* — whose effect is "Closed and released in full (`LDG-32`)",
the outcome that returns a customer's money — into an operation failure, and the balance stays
committed behind an order that provably never landed.

*This is the `OPS-11` amendment's defect on the search path. That amendment was written because
`DELETE /v2/images/{id}` answers `422 "Can not delete an already deleted image."` — a provider using
an error status to report a non-error — and its rule reaches only mutations, because it is phrased
as "A provider rejection whose meaning is "already in the target state" MUST classify `succeeded`."
Nothing is mutated here, so that rule does not reach it.*

**PRV-40** **A driver MUST declare its provider's ordering rate limit, and the deployment MUST
treat it as a capacity bound rather than discover it mid-order.** Hetzner Robot documents **20
requests per day** on each of its two order endpoints, and 200 per hour on cancellation.
**[observed 2026-09-04]**

This is a ceiling on how many machines the whole deployment can provision in a day, shared across
every tenant, and two things spend from it that nothing in this set counts: an ordinary create and
every conformance run that places an order, including a simulated one.

The limit is declared in the descriptor's `order_budget` `{limit, per}` (`PRV-44`); the deployment
MAY lower it and MUST NOT raise it (`OVR-19`). The deployment MUST refuse a create
deterministically, before any provider call, once the budget is exhausted. `OPS-11` requires that
shape: such a refusal is decided "before any driver call" and classifies `failed` for every
operation kind, so nothing ambiguous is created and no reconciliation is owed. **A limit first
encountered during an incident is encountered exactly when creates are being placed fastest.**

**PRV-41** **An authentication failure MUST NOT be retried against a provider that locks out on
repeated failures.** Hetzner Robot blocks the **source IP for ten minutes after three failed login
attempts**, across the whole API rather than the endpoint that failed. **[observed 2026-09-04]**

The blast radius is total and account-wide: `PRV-27`'s transaction listing, `OPS-32`'s account sweep
and every tenant's operations against that provider go dark together, from one deployment's address.
It lands at the worst moment, because a create sitting in `needs_reconciliation` is spending
`OPS-33`'s window while the lockout runs.

Nothing today forbids it. `DOM-17` requires every error to carry "a boolean `retryable`" that "describes
whether repeating the *same request* is safe and sensible", and `OPS-12` binds only the system's
retrying of ambiguous mutations. A driver MUST therefore treat an `authentication` failure as
terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an
operator (`OPS-26`). A rotated or mistyped credential is an operator problem; automating around it
converts it into a provider-wide outage.

*Authorization failures are not authentication failures. A namespace an account has not enabled
answers `401` without counting toward the lockout — four such responses on Robot's `/order/*` paths
left `/server` answering `200` immediately afterwards. **[observed 2026-09-04]** A driver that
conflates them will back off from a condition no backoff repairs.*

**PRV-42** **Where a provider's offer identifier *is* the resource identifier, resolution MUST be an
identity read rather than a search, and the correlator is unnecessary.** On Hetzner Robot's auction
channel the two are the same number: offer `3068756` provisioned as server `3068756` and offer
`3068758` as server `3068758`, each leaving the offer feed on purchase. **[observed 2026-09-04,
twice]** That market lists *specific physical machines*; the standard catalogue lists products, and
there the server number is unknown until the order is filled.

Where the identity holds, an ambiguous create resolves by reading the resource directly:

| Response | Outcome |
|---|---|
| the account owns it | `OPS-27`'s first row, "Exactly one resource across all of this operation's correlators", reached without a search and naming the machine exactly |
| absent, past `PRV-36`'s effective visibility window | `OPS-27`'s resolved-absent |

This is stronger than a correlator search on four counts: it is an identity lookup, so `OPS-29`'s
"A correlator match MUST be exact" is satisfied by construction; it is not bounded by a transaction
listing's retention, which removes `OPS-33`'s hardest limit on this channel; it needs no ordering
permission, which a webservice user may not hold (`08-provider-notes.md`); and **it supplies
per-attempt discrimination for free**, because a create has exactly one attempt (`ADR-0014`) and
its identity is known before the order is sent.

A driver MUST declare, per ordering channel, whether the offer identifier is the resource
identifier — the descriptor's `ordering_channels[].offer_is_resource` (`PRV-44`; the declaration
had no field to live in until 2026-09-08, while `CNF-285` already tested it) — and MUST prefer the
identity read where it is. **This does not reach a catalogue
channel**, where the offer is a product and `PRV-32`'s correlator remains the only road.

*The absence answer is `PRV-39`'s case: `404 SERVER_NOT_FOUND` is an answer, not an error. And the
identity rests on two observations of one provider — that it holds by rule rather than by
coincidence is `[verify]` before a driver depends on it.*

**PRV-43** **A correlator match proves an order landed. It is never evidence that the resource still
exists.** The transaction listing outlives the machine: after server `3068756` was cancelled and
destroyed — `GET /server/3068756` answering `404 SERVER_NOT_FOUND`, the account list back to its
prior contents — `GET /order/server_market/transaction` still reported that order as
`status: "ready", server_number: 3068756`. **[observed 2026-09-04]** The listing records what was
*ordered*; it makes no claim about what exists.

`OPS-27`'s first row instructs "**Resolved-observed.** Attach it and complete the operation as
though it had succeeded", and gives the effect on the commitment as "Becomes the machine's running
commitment". Applied to a destroyed machine that writes a `machines` row for something that is gone,
opens a commitment against it and starts the meter — which is the defect `OPS-32` was amended to
close, arriving by another road: "the meter reads the machine record, `DOM-8` refreshes that record
only on an explicit caller operation, and nothing in this set refreshes on a schedule — so a machine
the provider terminated went on draining its tenant's commitment until somebody happened to look."

**Resolution MUST therefore establish that the resource currently exists by reading the resource
itself, not the order that produced it**, and MUST interpret its absence through `PRV-36`'s declared
window rather than as an immediate negative, since a machine just delivered may not be readable yet.
Where the order reads landed and the resource is gone, the outcome is **not** resolved-observed:
there is nothing to attach, the customer owes nothing for it, and the operator has a destroyed
machine to account for.

*Reachable without anyone misbehaving. `OPS-33`'s window can be long, an exposure-reducing
cancellation or an operator action can destroy the machine inside it, and resolution then arrives at
a transaction that still reads `ready`.*

## Adding a driver

A new driver is expected to:

1. Declare only the capabilities it operationally supports (`PRV-4`).
2. Implement machine lookup (`PRV-3`).
3. Implement provider-specific rescue activation and exit (`PRV-15`, `PRV-21`), and reuse
   the generic rescue engine for everything between them (`OVR-8`).
4. Map provider status strings to normalized machine states, mapping the unrecognized to
   `unknown` (`DOM-7`).
5. Encode every path segment (`PRV-6`).
6. Declare, in the descriptor (`PRV-44`), every value the engine reads. The reasoning behind
   each — does key material get copied at create time or read later (`PRV-9`)? does the
   provider publish rescue host keys (`PRV-16`)? is deletion an API call or a contract process
   (`PRV-13`)? — is commentary and goes in `08-provider-notes.md`.
