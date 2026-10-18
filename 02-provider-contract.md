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
classifier uses `OPS-11`'s ambiguity rule.

**Amended 2026-10-08 (`ADR-0035`): every driver error MUST carry `details.accepted`.**
It is `true` once the provider answered successfully to the request performing this operation's
mutation, and `false` where the driver establishes that request was not accepted (including a
read-only operation with no mutation). For create this is the ordering request associated with
its correlator (`PRV-26`), never a preceding key upload. Other mutations need no correlator:
`PRV-26` says "This applies to create and to nothing else."
A failure before any byte of the mutating request was sent MUST report `details.accepted: false`.
A driver that cannot determine acceptance MUST report `details.accepted: null` with the mutating
request's own failure mapped as above (`network`, `timeout`, or `provider` with its status), using
`internal` only where no mapping applies. It MUST NOT report a later request's failure in place
of the mutating request's own, omit `details.accepted`, or substitute `false` for unknown
acceptance. Known acceptance MUST remain `true` on every later error, whatever its kind.
Robot's `403 RATE_LIMIT_EXCEEDED` MUST map to `rate_limited`, retaining `details.status: 403`.
**Amended 2026-10-12 (`ADR-0037`, Q28): every Robot `403 RATE_LIMIT_EXCEEDED` MUST
raise a monitorable alarm naming the provider account and request path, for reads and
writes alike.** An absorbed read-back failure still raises this alarm; it does not change
the accepted mutation's outcome.
The status and redaction obligations above and in `PRV-7` still apply.

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
`PRV-33`, `PRV-38`, `offer_is_resource: true | false` (whether the offer names one machine, `PRV-42`), and
`order_budget: {limit, per}`, `PRV-40`), `evidence_sources` per mutation kind in descending strength (`PRV-36`),
`visibility_window` `{declared_seconds, sample_size, measured_on | unmeasured}` (`PRV-36`),
`cancellation_bound` per offer (`PRV-31`) — which MAY be reported on the offer instead —
`traffic_bound` per offer (`ADR-0039`) — `unlimited`,
`{allowance_bytes, headroom_bytes}` with nonnegative integer allowance bytes and
`0 < headroom_bytes ≤ allowance_bytes`; the resulting limit is
`allowance_bytes − headroom_bytes`, or explicit `null` where no bound is
declared. Like `cancellation_bound`, it MAY be
reported on the offer instead —
`billing_unit` per offer (`ADR-0033`, added 2026-10-08) — `{seconds, native_floor}`: the provider's
smallest charged span of machine time, in seconds — zero exactly where the provider charges exact
elapsed time with no minimum, a unit of no length under which the arithmetic is unchanged: nothing
is prepaid for time, `first_unit` is the floor alone or nothing (`PRV-13b`), and a machine's first
seed writes its mark at the seed instant (`LDG-38`) — and the money minimum on its price, a string
in the offer's currency as `DOM-9` carries every price and null where the offer has none; it is the
per-contract fact `PRV-13c` lists as billing granularity, and like the bound it MAY be reported on
the offer instead —
`rescue_address_family` (`RSC-45`), and `surviving_attachments` (the kinds that survive deletion,
each with `cleanup: api | manual`, `PRV-13a`). A field with nothing to declare says so explicitly.
**A value the engine reads MUST come from here and never from `08-provider-notes.md`**, which is
commentary on why a descriptor says what it says (`ADR-0018`). `WIR-29` exposes a subset of it.
`CNF-18` iterates its fields as it iterates capabilities: a declared value has a working code path
behind it.
*Amended 2026-10-08 (`ADR-0037`): the billing-stop window is withdrawn.
Amended 2026-10-09 (`ADR-0039`): the per-offer traffic bound is added. An allowance
declaration alone does not make an offer sellable; the live-evidence condition is below.*
*Amended 2026-10-09 (`ADR-0036`): `order_budget` is declared within each
`ordering_channels[]` entry, not once at descriptor top level.*

### List offers

**Input** — none.
**Output** — offers (`DOM-9`).
**Capability** — `list_offers` (`DOM-22`); a driver that cannot enumerate offers does not
declare it, and the endpoint answers `unsupported` for that account.

May aggregate several provider endpoints (for example a standard catalog and an auction
market). Offers from different channels MUST be distinguishable by their identifier so
the create path can route on it.

**PRV-50** The driver's List offers MUST be read-only under `PRV-12`'s guarantee:
"Get machine MUST be read-only and free of side effects".

*Added 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): made the List offers read-only guarantee explicit.*

### Create machine

**Input** — offer identifier, optional region, hostname, optional image, SSH public
keys, optional user data, labels, and a provider-options object.
**Output** — the created machine.
**Capability** — `provision_virtual` or `provision_bare_metal` per `DOM-10`.

**PRV-8** Create MUST require at least one SSH public key. The control plane MUST NOT
persist a provider-generated root password, so a machine created without a key would be
unreachable.

**PRV-9** **Amended 2026-10-09 (`ADR-0040`); amended 2026-10-11 (`ADR-0040`, Q24); amended 2026-10-12 (`ADR-0040`, Q26).** Where the provider
requires SSH keys to be registered as account-level resources before they can be attached, the driver
MUST register and attach them as temporary provider-side resources. **A tagged temporary key still
registered at the provider MUST be deleted by `OPS-32`'s sweep when, and only when, its operation
has settled or its record has vanished, and no machine that operation produced still reads `provisioning`, whether or not an
order was accepted. After acceptance, or after settlement without acceptance, the driver MUST NOT
delete that key; the sweep is its only deleter.** On failure before acceptance, the
driver MUST delete only a temporary key that its own operation successfully registered. A
duplicate-fingerprint refusal or an indeterminate registration reply gives the driver no ownership
evidence and MUST NOT trigger deletion by fingerprint. A post-acceptance `needs_reconciliation` operation
retains its key until resolution settles it. A vanished operation record satisfies only the settlement
condition; the sweep MUST still check the provisioning condition against retained `machines` rows.
For an operation that produced a machine, its `machines.correlator_value` is the operation UUID on
Hetzner Cloud and DigitalOcean, or its per-order correlator-key fingerprint on Robot. Every temporary
key tagged with that operation id, including a caller key distinct from Robot's correlator key, has
the same eligibility. The provider-side
registration may contain a caller's create public key or a freshly generated rescue/correlator public
key; it is distinct from the persisted recovery private key (`RSC-19`).

**Every temporary key resource a driver registers — for a create or for rescue — MUST carry the operation id as its provider-side name or tag**, so the sweep can find one left by a crash or failed cleanup. A provider that rejects duplicate fingerprints blocks the caller's next same-key create on that account while any registration survives, until the sweep deletes it. The refusal precedes acceptance and sends no order. Cloud and Robot document this refusal (`08-provider-notes.md`); Robot reproduced it on 2026-10-12 (`docs/research/panels-2026-10/r45/live-session2.txt`), while Cloud has not been reproduced live. See `DEF-6`.

**PRV-10** For a provider that bills on order, create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account
is configured to allow ordering. Both, not either.

**PRV-47** **Added 2026-10-09 (`ADR-0036`).** Before any provider mutation for a create,
the driver MUST validate every value it forwards to the provider, including provider options,
and MUST reject invalid values without any provider mutation for that create, including a
per-order key upload or order request. This validation is in the
driver, after the API's body validation, because the driver knows the provider's accepted values.

*Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): validation now
precedes any provider mutation for the create, including key upload.*

**PRV-11** Ordering is generally not idempotent at the provider. Where create polls an
order transaction to completion, timing out MUST produce a `timeout` error whose message
states that the order may still be pending and MUST NOT be blindly repeated, and whose
details carry the transaction identifier. *Amended 2026-10-08 (`ADR-0035`): after acceptance this
is an instance of `OPS-11`'s "the operation's mutating request was accepted by the provider",
with `details.accepted` from `PRV-5`.*

### Get machine

**Input** — `external_id`.
**Output** — the machine as the provider currently reports it.

**PRV-12** Get machine MUST be read-only and free of side effects. It is called
after other actions and during reconciliation. **Amended 2026-10-12 (`ADR-0037`, Q28):
Robot MUST run `DOM-8`'s claim-time freshness check ("When a worker claims a refresh,
it MUST check the machine's current `state_observed_at`") before every opportunistic
`GET /server/{n}` after an action, and MUST NOT send that GET when the check can
reuse a fresh observation.** Required confirmation and absence reads follow their own
evidence rules; cached presence proves neither a mutation nor absence. A read failure, including
throttling, authentication rejection, a network error or deadline expiry, MUST remain distinct
from provider-mapped absence of the known machine on the known provider account. A generic HTTP
error or a response for another identity is not evidence that this machine is gone.
*Amended 2026-10-11 (`ADR-0037`, Q22).*

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

**Amended 2026-10-11 (`ADR-0037`, Q22).** After an accepted cancellation returns an effective
date, the driver MUST read that machine once on its known provider account and external identity.
Provider-mapped absence, such as Robot `SERVER_NOT_FOUND`, records the machine gone at this read;
the gone outcome stops its meter through `LDG-74` and closes any open episode under `OPS-48`.
If the machine remains present, or this read fails for any reason including throttle,
authentication, network error or deadline expiry, the accepted attempt settles `succeeded` as
`cancellation_scheduled` with its effective date. Read failure does not turn the accepted dated
cancellation into `needs_reconciliation` or establish absence. `PRV-36` owns the evidence rule;
no second confirmation read is required. This result requires known acceptance and its date;
`OPS-11` still classifies an unknown or failed mutation response.

**Amended 2026-10-12 (`ADR-0037`, Q28).** On Robot the driver MUST send
`POST /server/{n}/cancellation` with `cancellation_date=now&reserve_location=false`
and MUST NOT issue `GET /server/{n}/cancellation` as a pre-read in that cancellation
dispatch path. `PRV-13c` says "The required shape is read-and-branch: order, then **read**
the provider's per-machine cancellation constraint." That separate post-order read remains
required. The direct machine read after an accepted dated cancellation above still occurs; its failure, including
`rate_limited`, retains the accepted `cancellation_scheduled` success and stored date.
The reservation-possible branch remains `[verify]` (`08-provider-notes.md`).

**Amended 2026-10-11 (`ADR-0037`, Q23a).** After a failed or present read-back, the meter
runs to `LDG-38`'s stop boundary. Time beyond the funded wind-down is `LDG-74`'s
sweep-interval residual, which the stored effective date ends no later than that date;
any amount beyond the commitment meets `LDG-31`'s clamp. A failed read supplies no
absence evidence and does not stop the meter.

A calendar-day-only **effective** date names the end of that day in the zone the provider dates
in; the driver MUST convert that local end-of-day instant to UTC. An explicit timestamp retains
its instant. A `now` request is not evidence of a start-of-day stop. **Amended 2026-10-11 (`ADR-0037`, Q23c).** A provider's
`earliest_cancellation_date` is a permitted-from date, not an effective stop instant: a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone. A date equal to the provider's today has passed and takes the ordinary branch. For a future earliest date, cost through that date runs to the end of its provider-local day; this pricing does not change the stored permitted-from instant or resize the commitment (`PRV-31`). Robot dates in
`Europe/Berlin` (`docs/research/panels-2026-10/r40/zone-check.txt`; `ADR-0037`'s 2026-10-12 verification note).

**PRV-13a** Deleting a machine does not necessarily delete everything billable that was attached to it. A driver MUST declare associated resources that survive deletion and may continue to bill, and MUST expose cleanup for every such resource the provider's API can delete. **Amended 2026-09-08 (`ADR-0018`):** the kinds are declared in the descriptor's `surviving_attachments` (`PRV-44`), each with `cleanup: api | manual`; cleanup is `PRV-45`'s *release attachment*. Only resources the API cannot reach may be left to an operator procedure as `manual`.

**Amended 2026-10-09 (`docs/research/provider-verify-2026-10.md`, V17 and §3, retrieved 2026-10-06).** The descriptor MUST declare these potentially surviving kinds for the applicable provider, with their cleanup classification:

| Provider | Kinds and `cleanup` declarations |
|---|---|
| Hetzner Cloud | Primary IP `api`; Floating IP `api`; Volume `api`; Snapshot `api` |
| Hetzner Robot | Additional IP `api`; subnet `api` |
| DigitalOcean | Reserved IP `api`; floating IP `api`; snapshot `api`; volume `api`; volume snapshot `api`; backup `manual` |

The declaration names kinds, not an assertion that every instance survives. Hetzner Cloud's read-back `auto_delete: true` is evidence that an individual Primary IP is deleted with its server; the descriptor remains unchanged. On 2026-10-11 an auction order's `primary_ipv4` add-on and included /64 were absent after its `now` cancellation; this settles batch B step 9 (`docs/research/provider-verify-2026-10.md` §5) only for that order, not separately ordered Additional IPs or subnets. Robot's possible-survivor declarations remain. DigitalOcean backup billing after Droplet destruction remains `[verify]`. The provider evidence and outstanding checks are in `08-provider-notes.md` and `docs/research/provider-verify-2026-10.md`.

A DigitalOcean driver MUST NOT set `backups: true` on create, because retained backups have no documented deletion API. A control plane that reports a machine deleted while its storage continues to accrue cost is reporting a falsehood.

**PRV-49** **Enabling attachment cleanup.** Before
enabling a sold create path that can leave a billable attachment outliving its machine, the
system MUST provide complete automatic discovery and cleanup for that path. It MUST capture
attachment identities while the machine is present, enqueue `release_attachment` at every
gone-write for billable survivors, distinguish an attachment list never completed from a
completed list finding none, and cover disappearance before identity capture. Cleanup MUST NOT
depend on manual operator recovery. This precondition applies to separately ordered Robot IPs
and subnets, and to Cloud and DigitalOcean on re-admission. Current Robot offers that order
the `primary_ipv4` add-on remain sold across Robot ordering channels. The observed absence is
limited to the tested auction order; catalogue orders and provider termination retain the
accepted accident-only residual recorded in `ADR-0037`, Q21. This precondition does not require a runtime refusal API for those current offers. The accepted residual
for catalogue orders or provider termination is an accident that no adversary can cause: a stray address
costs EUR 1.90 per month until noticed, with no operator cap (`ADR-0037`, Q23b).

**PRV-13b** A system that resells a machine on prepaid terms MUST be able to bound its own
exposure before taking money, subject to `PRV-49`'s accepted residual: "an accident that no
adversary can cause: a stray address costs EUR 1.90 per month until noticed, with no operator
cap". *Amended 2026-10-11 (`ADR-0037`, Q23b).* That requires, per product: an API path to stop the cost, a bound
on the time until the customer's meter stops, and cleanup for every billable attachment
(`PRV-13a`, `PRV-45`); `PRV-49` is the enabling precondition for paths that can leave one
outliving its machine. Traffic overage is operator exposure too. Under `ADR-0039`, an offer
with `traffic_bound: unlimited` is sellable on this dimension; an allowance-bearing offer
MUST NOT be sold until a live test establishes counter freshness and bounds traffic after
the last reading through deletion under `ADR-0033`'s "priced, not amplified" criterion.
An offer with no declared traffic bound MUST NOT be sold. An allowance-bearing offer
that passes the live gate declares allowance less headroom; see `WIR-30` for the
before-purchase disclosure. Crossing it would open an exposure-reducing cancellation
with future reason `traffic_allowance` beside `rate_outage_bound` (`OPS-39`, `STO-52`);
this path is deferred until re-admission, and no active reason or Fence branch is
created by this amendment. Wind-down funds the customer's meter through the gone-write. Its
latency allowance adds the waits in sequence: **`LDG-37`'s metering cadence + the mutating
provider call's deadline + `PRV-36`'s effective visibility window + `OVR-19`'s resolution-read
cadence + that read's own provider-call deadline + the worst-case machine-operation hold +
time margin**. `OVR-19` owns the deadline: "The deployment MUST state and enforce a finite, positive
provider-call deadline". Every term MUST enter the reserve at the customer rate, even when one
bound exceeds another. The visibility window begins at the end of the mutating call's wait,
whether a reply arrived or its deadline expired. `STO-53`'s dispatch-to-observation samples
widen the effective window; their stored timestamps do not move its start back to dispatch.
The provider's unit remainder is a different cost, absorbed by the operator under
`ADR-0033`; the accepted accounting gaps belong to `LDG-75`. *Amended 2026-10-08 (`ADR-0037`).
Amended 2026-10-09 (`ADR-0037`, Q13):
sequential wind-down waits. Amended 2026-10-09 (`ADR-0039`): traffic exposure, the sale gate
and conditional re-admission.*

The reserve is computed **in the provider's billing currency** and converted once, when the
commitment is opened or re-sized, into the ledger unit:

```
reserve_native = setup_fee                              # at cost, no markup (ADR-0006)
               + first_unit                             # the prepaid first billing unit, at the
                                                        # customer rate (ADR-0033; defined below)
               + requested_runway × customer_rate       # PRV-13d, customer-chosen
               + wind_down_cost                         # see below
               + billable_attachments                   # PRV-13a
               + cost_through_earliest_cancellation_date # exception branch only (PRV-13c)

commitment_sats = to_ledger_unit( reserve_native × (1 + conversion_haircut) )
```

The `billable_attachments` term has no v1 value: no attachment has its own customer rate.
Enabling one requires an automatic, idempotent corrective credit for a stop learned behind the
subject's mark (`LDG-38`), a worst-case effective-date bound per attachment kind, and a
per-offer declaration of the kinds that an order creates. `PRV-44` describes
`surviving_attachments` as "the kinds that survive deletion"; this per-driver descriptor is
not an individual order's declaration.
*Amended 2026-10-10 (`ADR-0037`, Q18).*

*The `accrued_unbilled_usage` term was deleted from this formula on 2026-09-02.* Nothing produces
it: the sizing happens at create, where by construction no usage has accrued, and once the meter was
specified (`LDG-37`, `LDG-38`) consumption became a debit against the commitment rather than an
input to it. It is a survivor of the first version of the ledger — the one `12-billing-and-ledger.md`
opens by saying "consumed `accrued_unbilled_usage` in `PRV-13b`'s reserve formula and never said
what produced it". Deleted rather than tombstoned: nobody re-adds a zero term by accident.

**`customer_rate`, not provider cost.** The reserve must cover what the *customer* is committing
to spend, and since `customer_rate ≥ provider_rate` by construction, committing the customer
price also covers the operator's time-price exposure on sellable offers; the traffic sale gate
above is separately required. Using provider cost here would under-commit every
machine by exactly the margin. **The setup fee is committed at cost and debited at successful
settlement after acceptance** (amended 2026-10-08, `ADR-0035`; `LDG-39`: "an accepted but unresolved
create MUST take the `needs_reconciliation` pending-obligation row"), because `ADR-0006` passes it
through unmarked — the operator does not
profit from a fee it did not earn — and it is also a term that is entirely lost once the order
lands (the prepaid first unit, below, is another; *reworded 2026-10-08, `ADR-0033`*), so
it MUST be **fully committed before the order is placed**. *Both withdrawn
readings — "fully collected before the order" and "debited before the order is placed" — charged
the customer for a fee the operator never incurred whenever the provider rejected the order
outright or the create resolved absent.*

**The prepaid first billing unit is at the customer rate, where the fee is at cost** (`ADR-0033`,
added 2026-10-08). `first_unit` is the greater of `billing_unit.seconds` at the offer's recurring
price and `native_floor` (`PRV-44`), with the margin `LDG-24` applies — "The margin is a percentage
applied to machine time only (`ADR-0007`)" — because it is machine time; `ADR-0033`: "**Why the
customer rate and not cost.** The customer receives that hour." Like the fee it is entirely lost
once the order lands, so it MUST be **fully committed before the order is placed**, and like the fee
it is debited at successful settlement after acceptance (amended 2026-10-08, `ADR-0035`), as its own
kind and for the satoshi amount authorized here (`LDG-39`, `LDG-67`). On a floor-priced offer the floor
prices the unit and moves no instant:
`LDG-38` places an eligible first seed at "the seed instant plus the `billing_unit.seconds` the
machine's own row carries". A customer whose unit was debited and whose machine outlives `seconds` but not
what the floor's money bought at the provider pays the floor and then its metered seconds; the
difference is bounded by the floor and falls on the customer, never on the operator, so it is
priced and not amplified.

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

The criterion is `PRV-29`'s "bound the time after which its evidence is truthful". Where the
driver can, size `wind_down_cost` from the sequential allowance above. **Where it cannot, the
pager-latency figure stands.** Scheduled-cancellation protection
remains the reserve formula's `cost_through_earliest_cancellation_date` (`PRV-13c`); see that
requirement for the exception branch.

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
evidenced separately. For the customer's meter, the billing-stop evidence is the gone-write for
a machine or `released_at` for a completed attachment release; a stored effective date stops
the corresponding scheduled machine or attachment meter while the resource may remain present.
Meter boundaries remain with `LDG-38` and `LDG-74` ("Billing stops at the observation instant").
An action reporting `completed` does not establish that billing stopped.
*Amended 2026-10-08 (`ADR-0037`): wind-down sizing above uses the effective visibility window;
billing-stop evidence is named here. Amended 2026-10-09 (`ADR-0037`, Q14): the attachment date
stops its customer meter separately from absence evidence.*

**AMENDED 2026-08-15 — `wind_down_cost` MUST include the time the cancellation spends waiting for
the machine.** The provider call cannot begin until the machine is available; a pager-latency
fallback measured from that call must cover the earlier hold too. The sequential allowance above
includes it explicitly. *Amended 2026-10-09 (`ADR-0037`, Q13): the visibility wait begins when
the call's wait ends, so the old description of both paths starting at the call was incomplete.*
An exposure-reducing cancellation is an ordinary operation: it holds the machine (`OPS-8`),
and where a long-running operation already
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
deadline; see `OPS-41` for restore grace.* *Withdrawn 2026-09-23 (`ADR-0027`): the
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

**For a sellable offer billed with a per-period cap, if total failure to cancel
costs at most `setup_fee + one period cap` per machine, record that established
catastrophe bound:** the reserve above is the expected case, and the stated formula
is the provable upper bound. *Amended 2026-10-09 (`ADR-0039`): this conditional
exposure bound applies to sellable offers.*

**PRV-31** **A driver MUST declare, per offer and before any order, a worst-case cancellation
bound** — the latest `earliest_cancellation_date` a machine bought from that offer can carry —
and an offer with **no bound declared in either the descriptor or the offer MUST NOT be sold on
prepaid terms.** In v1, an offer MUST NOT
be sold on prepaid terms if either its descriptor-declared bound or its offer-reported bound is
later than the provider's local today. This closes `F26`'s
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
clause was false while it stood, since the commitment opened at enqueue.* A missing declared
cancellation bound in both the descriptor and the offer is an unsellable offer. Its pre-order refusal is
`API-7`'s create-tail "`invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`". This does not move a provider failure or a term
learned after ordering into admission. *Amended 2026-10-09 (`ADR-0039`, Q12).*
*Amended 2026-10-12 (`ADR-0037`, Q25): the v1 sale bound is provider-local today.*

**PRV-13c** **A deployment MUST NOT encode any provider's current commercial terms as
constants.** Minimum term, notice period, cancellation immediacy, billing granularity,
traffic allowance and traffic overage price are
per-contract facts that change, differ between a provider's own product lines, and differ
between one contract and the next. Billing granularity is declared per offer as `PRV-44`'s
`billing_unit` (`ADR-0033`, 2026-10-08).
The driver MUST report an allowance offer's `traffic_bound` from current provider terms in List offers (`PRV-44`). If an allowance offer is re-admitted, its current overage price is read with those terms at re-admission; the immutable descriptor performs no network I/O and carries no overage-price field; `08-provider-notes.md` is evidence, not runtime
configuration. *Amended 2026-10-09 (`ADR-0039`).*

The required shape is read-and-branch: order, then **read** the provider's per-machine
cancellation constraint. `PRV-13` says "a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone" and "For a future earliest date, cost through that date runs to the end of its provider-local day". Branch to the exception path when it is **materially in the
future** — defined (`F18`) as later than now plus one re-derivation period plus the product's
wind-down bound; anything nearer is indistinguishable from the ordinary exhaustion path and
needs no exception —
(`DOM-19`). A machine on the exception branch MUST either carry a machine-specific reserve of
cost-through-that-date, or not be sold on prepaid terms at all. **That cost is part of
`protected_sats` (`LDG-33`), not spendable runway** — the whole point of reading the date is that
the satoshis covering it are never advertised as runtime.
This post-order discovery is distinct from the Robot cancellation request.
`PRV-13` says "MUST NOT issue `GET /server/{n}/cancellation` as a pre-read in that cancellation
dispatch path."

*Amended 2026-10-14 (`ADR-0037`, Q31).*
*Amended 2026-10-15 (`pv-sgj`): the cancellation-response writer sentence gained its MUST keyword.*
*Amended 2026-10-15 (`ADR-0037`, Q34).*
For a settlement that makes a confirming read, the driver MUST read the per-machine cancellation
constraint once, when the create settles, after `OPS-27`'s confirming read. `OPS-27` says "the first row
MUST be confirmed by a direct read before it attaches anything".
A failed post-order read of any kind, `rate_limited` included, MUST NOT enter `OPS-11`'s
classifier and MUST NOT change the create's settlement.
For pricing a null column, `LDG-33` says "or, where `machines.earliest_cancellation_date` is null, through `machines.declared_cancellation_bound`".
*Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).*
Absorbing the failure MUST NOT suppress `PRV-5`'s "raise a monitorable alarm naming the
provider account and request path" where its trigger applies.
Here a settlement pass means the execution reaching any entry point in `OPS-27`'s
landed-order transaction paragraph. The settlement pass whose landed-order transaction commits
MUST make the one post-order read, after its confirming read. Within a settlement pass the
post-order read MUST NOT be repeated. Its result MUST be retained through whole-transaction repeats:
`OPS-49` says "with the provider's outcome retained in memory".
On interruption by engine exit or crash (`OPS-15`), the worker's read MUST be discarded with
the rest of its outcome; `OPS-49` says "the outcome in hand is thrown away".
If the store does not hold the machine row, a later settlement pass that makes a confirming
read MUST read the constraint again after that confirming read.
Once the store holds the machine row, a resolution pass, a refresh and the sweep MUST NOT
read that machine's cancellation constraint. For reads on a cancellation's own path, see `PRV-13`.
A settlement with no confirming read — the operator's synchronous `observed` attach
(`WIR-35`'s "attaches a discovered resource (`OPS-27`)") — MUST make no post-order read and
MUST store the date as null; this is the exception to the committing settlement pass's read.
The landed-order transaction MUST write the date of a successful read the committing pass holds,
otherwise null, in `machines.earliest_cancellation_date` with the machine row.
The system MUST record the date of the committing pass's successful post-order read in `machines.earliest_cancellation_date`.
An accepted cancellation's response (`PRV-13`) that carries the per-machine date MUST supply it
to that column. After the committing pass's failed post-order read, the column MUST remain null
until such a response supplies the date.

*This requirement exists because a specification, a reviewing model, and a researching model
each asserted a different set of terms for the same provider, and two of the three were wrong.
Assumptions about commercial terms do not survive review, and they do not survive the provider
changing them. Until 2026-09-08 this paragraph called adoption the main road onto the exception
branch; adopt is withdrawn from v1 (`ADR-0020`), and the branch stays specified because the
read-and-branch shape is what makes a machine with an inherited contract safe when it returns.*

### List attachments / Release attachment

**Input** — *list attachments*: machine `external_id`. *Get attachment*: attachment `kind` and
`external_id`. *Release attachment*: an attachment's `kind` and `external_id`.
**Output** — *list*: the attachments the provider still holds for that machine, each
`{kind, external_id, billable, cleanup: api | manual}`. *Get attachment*: authoritative
non-mutating presence or absence for that attachment identity, with `rate_limited` and other
read failures distinct from absence. *Release*: an action result with delete's outcome classes
and optional `effective_cancellation_date`.
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
delete row. A successful completed release with no effective date MUST write the row's `released_at`
in its terminal transaction, including the resolution transaction when resolved `applied`
(`OPS-31`). A successful release, including one resolved `applied`, whose result carries an
effective date MUST store that date on the attachment row in the same terminal or resolution
transaction and MUST NOT write `released_at` merely from that result, whether the date is future
or already passed. `PRV-13` owns conversion of day-only effective dates and the distinction
from a `now` request and `earliest_cancellation_date`.
A prior direct gone observation and its `released_at` MUST be preserved.
Neither outcome changes the machine's gone state or schedules its episode. An unresolved release
or one resolved `not_applied` or `abandoned` MUST NOT write either field as an applied release.
`OPS-32` says "The sweep MUST also visit attachments of every machine still retained by
`STO-18`" and owns the complete-pass, direct-read and observation transaction. Its
`released_at` observation is distinct from an operator's initiation of `manual` provider
cleanup. `LDG-38` owns the exit write, `LDG-32` commitment release and `STO-18` the
tombstone gate.
`PRV-49` is the enabling precondition for sold paths with outliving billable attachments.
*Amended 2026-10-08 (`ADR-0035`): successful resolution has the same attachment-row effect as
ordinary success; it does not record the machine gone. Amended 2026-10-09 (`ADR-0037`, Q14): date storage and
automatic direct-read absence confirmation. Amended 2026-10-10 (`ADR-0037`, Q18): day-only dates.
Amended 2026-10-11 (`ADR-0037`, Q21/Q22): enabling precondition and date-owner pointer.*

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

**Amended 2026-10-09 (`docs/research/provider-verify-2026-10.md`, V4/V10, retrieved 2026-10-06):** On Hetzner Cloud the driver MUST read `rescue_enabled` and disable an existing rescue activation before re-enabling it, then reset within the documented 60-minute auto-disable interval. On Hetzner Robot it MUST read `active` with `GET /boot/{n}/rescue` and disable an active rescue with `DELETE /boot/{n}/rescue` before re-enabling. Repeated-enable behavior remains `[verify]` for Cloud; Robot accepted a second activation for the next boot on 2026-10-12 (`docs/research/panels-2026-10/r45/live-session2.txt`). The disable-before-enable procedure remains required.

**Amended 2026-10-13 (`ADR-0041`, Q29).** On Robot, before activation, begin rescue MUST read `GET /boot/{server-number}/rescue/last` and retain its `boot_time` string as the baseline for this session, or no baseline when no record exists. Any other failure of this read MUST fail begin rescue before activation, with nothing to clean up. The baseline is driver refresh state in the in-memory session, never host-key pin material or durable state (`DOM-11`). The active-read and disable-before-enable procedure above still applies.

**PRV-16** **Amended 2026-10-12 (`ADR-0041`).** Begin rescue MUST populate the session's
host-key pins with complete OpenSSH public host keys whenever the provider exposes
complete keys, and with published SHA256 fingerprints when it exposes only fingerprints.
A driver MUST NOT return an empty pin set when the provider published usable pins the
driver simply did not parse. Robot's activation exposes no host keys or fingerprints:
begin rescue returns an empty pin set marked *awaiting provider keys*, never a statement
that this provider has no pinning support. A fingerprint is a pin, not a fabricated
complete public key.

**PRV-17** Begin rescue SHOULD use the supplied ephemeral public key. A driver that uses
provider-generated password authentication instead MUST document why (the provider offers
no key-based rescue), because it forces the workflow onto a password that a
first-connection attacker can capture when host-key pinning is unavailable. It MUST NOT
accept the ephemeral key and then ignore it. See `DEF-7`.

**PRV-18** **Amended 2026-10-09 (`ADR-0040`, Q16); amended 2026-10-11 (`ADR-0040`, Q24).** Begin rescue MUST clean up after itself on partial failure. If the rescue environment is activated but the reboot fails, the driver MUST attempt to deactivate rescue. Before acceptance, the driver MUST attempt deletion only of a temporary key its own operation successfully registered (`PRV-9`). After acceptance, `OPS-32`'s sweep deletes it when eligible; the driver does not. If rescue deactivation fails, the driver MUST attach the identifier of the rescue environment left behind to the error's details. If an owned pre-acceptance key deletion fails, it MUST attach the identifier of the key left behind to those details. A key deliberately retained while deletion is ineligible or registration ownership is unknown is not a failed cleanup. Where the engine dies instead, nothing attaches anything, and the tagged key resource is `OPS-32`'s to remove when eligible (`PRV-9`).

### Refresh rescue session

**Input** — `external_id`, the current session.
**Output** — an updated session.

**PRV-19** Refresh MUST be safe to call repeatedly while waiting for the rescue system to
boot. Its purpose is to pick up metadata — most importantly host keys — that a provider
only publishes once the rescue environment is running. The default implementation returns
the session unchanged.
**Amended 2026-10-12 (`ADR-0041`).** Robot refresh MUST read
`GET /boot/{server-number}/rescue/last` and accept its SHA256 fingerprint pins only
when the record contains at least one fingerprint and a non-null `boot_time` string
different verbatim from this session's pre-activation baseline. With no baseline record,
the first record satisfying both conditions is eligible. The driver MUST NOT parse
`boot_time` as an instant, compare it with reset, or use a changed fingerprint set as
the freshness detector. An unchanged record, no record, no fingerprints, or a null or
missing `boot_time` leaves the session awaiting pins. Activation and
`GET /boot/{n}/rescue` supply none. Later responses remain subject to `PRV-20`'s
"Refresh MUST NOT downgrade a session".

**PRV-20** Refresh MUST NOT downgrade a session: it MUST NOT clear an already-known host-key
pin set, and MUST NOT replace pin material with an empty value.
**Amended 2026-10-12 (`ADR-0041`).** The same rule protects fingerprint pins. Once
accepted, Robot pins MUST NOT be replaced by a later differing record, cleared by an
empty response, or downgraded on retry or timeout. An
awaiting Robot session cannot become eligible for first-use trust, even with the
caller's explicit first-use opt-in. If eligible pins have not arrived by `RSC-9`'s
deadline ("The deadline for waiting on driver-published host keys MUST be derived from the boot
timeout"), connection fails `integrity`; a presented key whose SHA256 fingerprint
and algorithm match none of the accepted pins MUST be refused before authentication.
The engine MUST pin the matching presented full key for the connection. Robot never falls back
to first-use trust, including when caller keys are supplied. The presented-key match
is what makes the connection safe (`ADR-0041`); record selection determines when to try it.

### End rescue

**Input** — `external_id`, the session.
**Output** — an action result.
**Capability** — `rescue_ssh`.

**PRV-21** **Amended 2026-10-09 (`ADR-0040`, Q16); amended 2026-10-11 (`ADR-0040`, Q24).** End rescue MUST deactivate the rescue environment, reset or reboot into the
installed system, and leave any temporary credential it registered for `OPS-32`'s sweep to remove when `PRV-9` permits deletion. The sweep finds it by its operation-id tag, including a credential this call never reached because the engine died first or the call was lost. The session's opaque cleanup token does not authorize a separate post-acceptance deletion.

**PRV-22** Failure of end rescue is *always* ambiguous — the machine may be in rescue, may
be rebooting into the new system, and a temporary credential may still be registered. The
driver MUST surface it as an error rather than swallowing it, so the lifecycle can route
the operation to reconciliation (`OPS-11`).
**Amended 2026-10-12 (`ADR-0037`, Q28).** A Robot throttled end-rescue call raises
`PRV-5`'s "every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the
provider account and request path" alarm. The alarm does not settle the call or
change its ambiguous error outcome.

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
- **build** — the switch-over, holding the machine, re-validated again first (`OPS-23`, whose
  "before the driver is called" already put a check before the import); this is where
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

After the ordinary authorization, capability and `API-16` validation, the worker MUST compare
the requested PTR value with the machine's recorded value for that address under `OPS-8`'s
serialization. An identical established value MUST settle `succeeded` without a provider call.
Result shape: `WIR-10`. A missing or unknown value is not equality.

The machine's `reverse_dns` map records provider-established values by address. Drivers MUST
report those values when their machine read observes them, and the engine MUST store them;
unknown or unobserved values are absent. A confirmed completed write or authoritative resolution
MUST also record the established value. Enqueue, dispatch and acceptance alone MUST NOT establish it.
Before dispatching a differing write, the engine MUST invalidate the prior entry; uncertainty
MUST NOT leave that entry eligible for the no-op. Only provider evidence re-establishes it.
An address removed from `public_ips` loses its entry. For a request that reaches the provider,
classification remains under `OPS-11`: "On failure, the system MUST classify the error". *Amended 2026-10-08 (`ADR-0034`).*

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
bearing it afterwards. A Cherry Servers driver MUST page through the project server list and filter returned `tags` client-side; no server-side tag filter is documented (`docs/research/provider-verify-2026-10.md`, V21, retrieved 2026-10-06). Every provider examined offers **either a free caller-controlled field or
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

**Amended 2026-10-09 (`docs/research/provider-verify-2026-10.md`, V7):** Robot-WS documents both order-channel listings as covering "within the last 30 days" [observed — Robot-WS, 2026-10-06]. For the automatic-recovery horizon, see `OPS-33`; a by-id fetch does not replace fingerprint search when a lost reply withheld the transaction id.

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
the documented listing horizon's rolling versus calendar alignment remains unspecified (`PRV-27`).
For the automatic-recovery horizon, see `OPS-33`.

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

A create failure recorded before step 9 is not an ambiguous create here: it settles `failed`
under `OPS-11`'s create row and never waits for an operator.
*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): scoped the ambiguous create to the create row.*

**PRV-35** **A driver MUST report positive network-restriction evidence where the provider exposes
it.** Its reading updates only `machines.provider_restricted` and `machines.provider_observed_at`
through the normal refresh path (`DOM-8`), without replacing an operator record. Operator writes
are specified by `WIR-47`. This is not part of `DOM-7`'s status mapping. On a successful read of
mapped flags, the driver MUST report whether any is positive, including a false result when none
is positive; the refresh path stores that combined result and when provisiond read the flags.
Before a reading, both provider columns remain null. A false reading supplies no evidence of an
unrestricted network.

**Where it comes from, per launch driver — each `[verify]` against the live API before it is
relied on:**

| Driver | Signal | Confidence |
|---|---|---|
| Hetzner Cloud | `public_net.ipv4.blocked` and `public_net.ipv6.blocked` on the server object, separate from lifecycle `status`; a true flag is positive even if the other address family is null. A false flag with a null family establishes no unrestricted network. `server.locked` remains unmapped pending a written provider answer | **[verify]** — address flags documented in the official client schema; positive evidence only |
| Hetzner Robot | `locked` on each IP and subnet; server status stays `ready`/`in process` | **[verify]** — mapping retained, but its documented “Status of locking” does not establish coverage of whole-machine locks; reduced confidence |
| DigitalOcean | a Droplet `locked` boolean exists, but is documented only as preventing user actions | **[verify]** — **do not map it**. Nothing official connects it to abuse networking, and reading it as a restriction would report every in-flight resize as a block |

`unknown` MUST NOT be rendered as `none`. A false or unavailable provider signal cannot establish
an unrestricted network. A clear read MUST preserve both operator columns.

*Amended 2026-10-10 (`ADR-0038`, including Q15 and Q15b).*

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
sample size and date: the worst observed request-to-observation latency over at least twenty real
mutations, re-declared when the provider changes the API — carrying a declared conservative bound
marked **unmeasured** until twenty samples exist. *Procedure owned here from 2026-10-08
(`ADR-0037`).*
**AMENDED 2026-09-08 (`ADR-0018`) — the effective
window is a max, not the declaration.** The declared value lives in the descriptor's
`visibility_window` (`PRV-44`), immutable. The engine writes every ordinary mutation and every
resolution as an observed sample to `provider_observations` (`STO-53`), and the effective window
is `max(declared, max(observed))`. Widening by an observed sample that exceeds the declaration is
thereby automatic; narrowing is a human re-declaring and archiving the samples.

**Within the window, a read showing the pre-mutation state is no evidence and resolution stays
pending.** `OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from
the end of the mutating call's wait: its reply, or the provider-call deadline's expiry when no
reply arrives. **A read showing the post-mutation state is evidence at any time, and MUST NOT be
reverted by a later
contrary read** — reads flap in both directions, and a resolution already reached on absence is not
undone by a stale read. Beyond the window, a read still showing the pre-mutation state resolves
the mutation as *not applied*.

*Amended 2026-10-09 (`ADR-0037`, Q13): the visibility clock starts when the mutation call's
wait ends, including the lost-reply deadline, while `STO-53` retains its dispatch-to-observation
sample timestamps.*

**Exceeding a declared window is a breach of the declaration, not a resolution.** It MUST be
surfaced, it widens future sizing through `STO-53`, and it MUST NOT authorize a replay — `OPS-12`
is untouched by this requirement.

*Trap retained 2026-10-08 (`ADR-0037`, accepted 2026-10-06): this paragraph formerly required a
second measurement, delete-to-billing-stop latency, "still owed for every launch driver". That
obligation is withdrawn. The 2026-08-31 DigitalOcean observation in `08-provider-notes.md` is a
visibility sample, n=1; it did not establish when the provider stopped billing. Reading it as a
billing-stop sample was the trap; removing the second measurement does not change what the
observation established.*

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
and `LDG-74` says "The stated interval bounds only the scheduled wait to a pass; a complete pass and successful direct confirmation then establish absence" — here it bounds the mirror case, a machine nobody is billed for at all.

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

**PRV-40** **Amended 2026-10-09 (`ADR-0036`).** A driver MUST declare the provider's
ordering limit in each ordering-channel descriptor entry (`PRV-44`). Robot documents 20
requests per day on each of `server`, `server_market` and `server_addon`; its
`403 RATE_LIMIT_EXCEEDED` reports `max_request` and `interval` (`08-provider-notes.md`).
The declaration documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises
`PRV-5`'s "every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the
provider account and request path" alarm. It MUST NOT be used
as a locally counted substitute for Robot's accounting, whose credential scope, window
reset and treatment of rejected or test requests are unverified.

After Robot reports `403 RATE_LIMIT_EXCEEDED` for an account and ordering channel,
the deployment MUST retain a closure for the reported `interval` and refuse subsequent
creates on that account and channel before any provider call, with `rate_limited` and
`retry_after_ms` for the remaining interval. `PRV-5` says "every Robot
`403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider account and
request path"; that alarm may
include the ordering channel. A closure on one account or channel MUST NOT alone
close another. This local isolation is a choice for admission, not a claim about Robot's
undocumented upstream counter scope. A provider throttle encountered after an accepted
mutation remains subject to `OPS-11`'s acceptance rule.

**Amended 2026-10-10 (`ADR-0036`).** For a create already admitted and queued, the
worker MUST read the stored closure for that account and ordering channel when it claims
the operation (`OPS-5`), before any provider request, including a per-order key upload.
If the channel is closed at that read, the worker MUST make no provider request and
settle the existing operation `failed` with `rate_limited`,
`details.retry_after_ms` equal to the remaining closure, and operation-view
`retryable: true`. Its commitment MUST be released in full under `LDG-39`'s
"Deterministic rejection before acceptance" case; no setup or first-unit charge is
debited for an order the provider never accepted. A retry after expiry is a new
operation, not an automatic requeue or another attempt by this operation. This is a
plain read, not a conditional-write guard: if a closure commits after the read,
the provider's own `403 RATE_LIMIT_EXCEEDED` may settle the create the same way.
See `OPS-11` for classification after a provider has accepted a mutation.

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

**PRV-42** **Amended 2026-10-09 (`ADR-0040`).** An `offer_is_resource` offer names one machine; the descriptor field records that property and does not select a resolution method. Hetzner Robot auction offer `3068756` provisioned as server `3068756` and offer `3068758` as server `3068758`, each leaving the feed on purchase. **[observed 2026-09-04, twice]** Equality of those numbers is an observation, not a prerequisite for resolution. A lost-reply auction create MUST be resolved through its per-order fingerprint on every ordering channel (`OPS-27`, `PRV-38`); the matched transaction supplies the delivered `server_number`, which is then read directly to confirm the machine. A read of the offer number that returns `not_found` cannot prove the order absent, and a positive read alone cannot prove this order produced the machine.

**Amended 2026-10-09 (`ADR-0036`).** At most one create may be in flight per
`offer_is_resource` offer, across tenants. The create's admitting transaction MUST acquire
a conditional-write claim on the account, channel and offer before opening a commitment
or operation; a snapshot read alone does not enforce this. An unresolved create retains
the claim until its outcome is known. If the claim fails, the create MUST use
`API-7`'s "ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no
`details.refusals`, no synthesized pacing or `Retry-After`, and no commitment,
operation or receipt" resource-offer guard response.
Catalogue products do not take this claim.

For every create, including catalogue products
and `offer_is_resource` offers, the driver MUST confirm that the named offer is still
listed before sending the order request; a missing offer MUST NOT be ordered. This
is a dispatch check, not a provider lookup during `API-7`'s read-only tail collection.

*Trap retained 2026-10-09 (`ADR-0040`): the withdrawn identity-resolution rule preferred an offer-number read and treated its absence past the visibility window as resolved-absent. That could release a commitment while a matched order was still in progress. The fingerprint search supplies order attribution and the delivered number.*

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
close, arriving by another road. `DOM-8` now says "`OPS-32`'s account sweep reads each provider account independently of any caller and MUST write what it saw (state, and `machines.state_observed_at`, `STO-48`)"; `OPS-32` writes present observations and confirmed absences.

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
   each — what is known about key-consumption timing (`PRV-9`)? does the
   provider publish rescue host keys (`PRV-16`)? is deletion an API call or a contract process
   (`PRV-13`)? — is commentary and goes in `08-provider-notes.md`.

**PRV-48** **Added 2026-10-09 (`docs/research/provider-verify-2026-10.md`, V16, retrieved 2026-10-06; `pv-ucs.9`).** A DigitalOcean driver MUST encode correlator tags in lowercase using only its documented characters and `:` or `_` as a separator, within the 255-character limit. It MUST NOT call `DELETE /v2/droplets?tag_name=` with a correlator tag: the endpoint deletes every Droplet carrying that tag. Resolution uses the read-only tagged listing and any eventual deletion targets a verified individual Droplet id (`OPS-27`).
