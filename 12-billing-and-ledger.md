# 12 — Billing and the ledger

This document did not exist until 2026-08-11, and its absence was the largest hole in the set:
`API-17b` requires a deployment to define its spending authority, and nothing defined it. The
decisions it records live in `ADR-0002` (prepaid balance is the only spending authority),
`ADR-0003` (the float is denominated in satoshis) and `ADR-0004` (the perimeter).

**The ledger is not an accounting convenience. It is the authorization system.** Under `ADR-0002`
a balance is the *only* thing that permits spending, so a ledger bug is an authorization bug, and
the transaction that commits funds is the same transaction that authorizes a purchase.

> **Rewritten 2026-08-12 after two independent audits.** The first version modelled reservations
> as **holds** — a card-payments primitive: authorize once, capture once, against a discrete
> purchase of known size. Machine time is not that. It is continuous consumption against a
> prepaid claim, and a hold that never shrinks drives the available balance negative **in the
> ordinary happy path, one hour into the first machine's life**. Six further defects were
> downstream of the same mistake. The primitive is now a **commitment that decays as it is
> consumed**, and the consumption half of the ledger — the meter — is specified rather than
> assumed. Withdrawn requirements are marked in place, per the README's append-only rule.

## Units and arithmetic

**LDG-1** Every monetary quantity in the **ledger** MUST be a signed integer of satoshis. No
floating point, no decimal strings parsed late. A balance comparison is integer arithmetic with
no conversion in it — which is the point of `ADR-0003`'s denomination choice.

This does not reach provider prices. `DOM-9` requires an offer's price be carried as the exact
string the provider returned, and that remains correct: an offer is not money owed, it is a
quotation. **The conversion from that string to integer minor units MUST happen exactly once,
at the boundary where a price becomes an obligation** (`LDG-27`), and the string MUST NOT be
parsed into floating point at any point on that path.

**LDG-2** Provider-side amounts MUST be recorded in the provider's own billing currency alongside
the satoshi amount, as a separate integer of that currency's minor units, with an explicit
currency code — even while only one provider currency is in use. Without it, "what did this
machine actually cost me at the provider" is unanswerable for all history predating the second
currency, and is not reconstructable later.

**LDG-3** Adding two amounts with different currency codes MUST be an error, not an implicit
conversion.

**LDG-4** Every conversion MUST record the rate as an exact rational (numerator and denominator),
its source, its observation time, the haircut in basis points, and the rounding rule version —
denormalised onto the entry, so it remains self-explanatory after any rate table is pruned.

**LDG-28** **Rounding is specified per direction and applies everywhere, not only to
conversions.** Debits round up, credits round down, and a commitment's required amount rounds up.
Releasing a commitment returns **the exact satoshi amount still reserved** and performs no
conversion — a reservation is a quantity of satoshis once created, not a claim re-priced at
release. Without this rule a commitment opened at one rate and closed at another silently changes
the balance of a ledger whose whole purpose is exact integer arithmetic.

**LDG-29** The margin (`LDG-24`) MUST be expressed in basis points and applied as integer
arithmetic with a stated rounding direction. A percentage stored as a decimal fraction
reintroduces the float that `LDG-1` exists to exclude.

## Entries

**LDG-5** The ledger MUST be append-only. No update, no delete. A correction is a new entry
naming the entry it corrects. **Balance is the sum of entries** and nothing else.

**LDG-6** Every entry MUST carry: a stable id; the tenant; a per-tenant monotonic sequence number;
a kind; the signed satoshi amount; the running balance after it; and the ids of whatever caused
it — operation, machine, commitment, and the provider-side settlement reference once known.
Provider-denominated entries additionally carry `LDG-2`'s native amount and `LDG-4`'s conversion
evidence.

**LDG-7** **AMENDED.** Entry kinds are exactly: `topup`, `usage_debit`, `setup_fee_debit`,
`operation_fee_debit`, and `correction`. **Every entry moves real money.** The previous list
included `hold`, `hold_adjustment`, `hold_release` and `expiry`; the first three are withdrawn
because a reservation is no longer a ledger entry (`LDG-30`), and `expiry` is withdrawn because
the closing section of this document prohibits the only behaviour it could have described.

A setup fee MUST be its own kind and MUST NOT be folded into usage, because it is the one
non-refundable component and a caller asking "why did I not get that back" deserves a row that
answers it.

**LDG-8** Every entry MUST carry an idempotency key unique within the tenant. For a `topup` that
key MUST be **derived from the payment's own identity at the rail** — not generated by the
receiving code — or a redelivered payment notification credits twice under two different keys.
For a `usage_debit` the key MUST be **`(subject, billing period, kind, increment end)`**, where
*subject* is the machine or an individual billable attachment and *increment end* is the instant
the metered increment closes (`LDG-38`). **The key is derived from the thing being billed, never
from a count of what has already been posted** — a redelivered or crash-replayed increment then
derives the *same* key and conflicts, while a cadence that subdivides a period still posts every
increment under a distinct one.

*A "posting index" counted from the ledger was the withdrawn form, and it cannot deduplicate at
all: a second run reads one more prior debit, derives the next index, and its insert succeeds —
double-charging the tenant and double-decrementing the commitment. Serializing the allocation does
not help, because the two runs were never trying to claim the same number.* *The withdrawn `(machine, billing period, kind)` admitted exactly one posting per
period, which deduplicated away every cumulative posting after the first and stopped the
commitment decaying.*

## Commitments

**LDG-30** A **commitment** is a reservation of satoshis against a specific machine. It is **not
a ledger entry**; it is a separate record with an amount that **decreases as consumption is
debited against it**. The ledger records money that moved; a commitment records money that is
promised and has not moved yet. Conflating the two is what made the first version of this
document double-count every reservation.

A commitment MUST carry: the tenant, the machine, the operation that opened it, the satoshi
amount **still reserved**, its state (`open` or `closed`), and the timestamps of both.

**LDG-9** **AMENDED.** A tenant's **available** balance is:

```
available = Σ(ledger entries) − Σ(reserved amount of open commitments)
```

The spending authority check is `available ≥ required_commitment`, and it is the only
authorization a create or an adopt receives (`ADR-0002`, `API-17b`).

**LDG-31** **AMENDED — every debit against a machine, not only consumption.** Posting **any**
debit attributable to a machine **with an open commitment** — `usage_debit`, `setup_fee_debit`,
`operation_fee_debit` — MUST decrement that commitment by the same amount, in one transaction.
**The one exception is `LDG-39`'s late setup fee**: where the create's own commitment was already
released by `OPS-33`, the fee is debited without a decrement, and a wind-down commitment `OPS-36`
opened afterwards is a different operation's authority and is not what it pairs with.

*The withdrawn text said "consumption", and `LDG-38` named only `usage_debit`. `PRV-13b` puts the
setup fee **inside** the commitment while `LDG-39` debits it, so on the ordinary funded dedicated
create the ledger sum fell, the reservation did not, and `available` went negative by exactly the
setup fee — violating `LDG-10`, which then requires the fee-post itself to fail. **This is the
2026-08-12 double-count reintroduced through the one entry kind the pairing rule forgot to
name**, and both independent reviewers found it.*

**The decrement clamps at zero and the excess is the operator's.** Where a debit exceeds the
commitment's remaining amount — reachable through the wind-down window, `LDG-16`'s persistence
delay and a resolved-observed setup fee against a still-open commitment (`LDG-39`) — the commitment decrements to zero, the tenant is debited
only up to the authority it granted, and the remainder is recorded as an **operator deficiency**
in the manner of `LDG-63`. It MUST NOT be taken from available balance: that would be the
automatic seizure `ADR-0011` exists to forbid, arriving through the meter instead of through
re-derivation.

Its effect on the ordinary path is unchanged — consumption leaves `available` **unchanged**,
because spending what you already committed neither frees nor freezes anything:

| event | Σ entries | reserved | available |
|---|---:|---:|---:|
| `topup` +72,000 | 72,000 | 0 | 72,000 |
| commitment opened, 72,000 | 72,000 | 72,000 | 0 |
| one hour consumed: `usage_debit` −100, commitment → 71,900 | 71,900 | 71,900 | 0 |
| machine deleted, commitment closed | 71,900 | 0 | 71,900 |

**LDG-32** **AMENDED.** A commitment MUST be closed, and its remaining amount released in full,
on **every** terminal outcome: the machine stops billing **and every billable attachment it left
behind has stopped billing** (`PRV-13a`, `STO-18`); the create fails deterministically; the create
is resolved absent (`OPS-27`); or the operation is abandoned (`OPS-31`).

**Attachments keep the commitment open, and metering follows them.** `PRV-13a` models volumes,
snapshots and reserved addresses that survive machine deletion and keep costing money; `PRV-13b`
reserves for them; but the meter (`LDG-37`) was machine-only, so a released commitment left them
billing against nothing. A deployment MUST meter each billable attachment on its own identity
until `released_at` is set, and MUST NOT sell an offer whose attachments have no bounded automatic
cleanup unless the operator has explicitly accepted and capped that exposure.

**Losing a provider account is not evidence that billing stopped** — see `SEC-46`, amended for the
same reason. **A terminal path with no close rule strands a customer's satoshis
permanently** — there is no withdrawal (`ADR-0004`), no expiry, and under `ADR-0005` no identity
to appeal with, so an ordinary retry loop against a contended offer would otherwise render a
balance unusable forever.

**LDG-33** **AMENDED (`ADR-0011`), with the formula now stated** — it was missing, and the
obvious reading was wrong in the operator's disfavour. Re-derivation (`PRV-13e`) MUST recompute
**`runway_until`** from the machine's fixed remaining commitment at the current rate, in **both**
directions — and MUST NOT resize the commitment.

```
protected_sats = at the current rate, rounded up:
                   wind_down_cost
                 + surviving billable attachments (PRV-13a)
                 + cost through any effective cancellation date (DOM-19)
                 + cost through any earliest cancellation date not yet passed (PRV-13c)
usable_sats    = max(0, reserved_sats − protected_sats)
runway_until   = now + floor(usable_sats / current_customer_rate)
```

**The two date terms are not additive.** Where both an effective cancellation date (`DOM-19`) and
an earliest cancellation date still in the future (`PRV-13c`) apply to the same machine, the
protected cost runs to the **later** of the two and is counted once. The earliest date is a
minimum-term constraint that exists from create (`PRV-31`), not something a cancellation creates,
so the cost of running to it is unavoidable from the moment the machine exists and MUST NOT be
advertised as spendable runway while it is still in the future.

**Exhaustion begins when `usable_sats` reaches zero, not when the commitment does.** Dividing the
*whole* commitment by the usage rate — which is what the fixture and the absent formula together
implied — advertises the wind-down reserve as runnable time and guarantees the operator is short
at the exact moment of cancellation, on every ordinary exhaustion rather than only on a crash.
`LDG-16`'s invariant ("still covers wind-down at the current rate") is satisfiable only with
`protected_sats` subtracted first. A commitment is sized once at open, decays as usage is debited
(`LDG-31`), and **is never increased without a caller action** (`LDG-62`; the scheduled-
cancellation branch is the one exception, `LDG-63`). *The withdrawn text resized the commitment
to preserve the runway date, which spent three design rounds on widening speed before the
interviewee's observation dissolved it: every authorization prices at the current rate, usage
debits at spot, so a price move belongs to the runway date — the customer's purchasing power —
not to an automatic grab of their available balance.*

**LDG-34** A commitment adjustment MUST be a conditional write on the commitment's current
amount — a compare-and-swap or equivalent — so two workers re-deriving the same machine in the
same period cannot both apply the delta.

**LDG-10** A balance MUST NOT go negative, and `available` MUST NOT go negative. Any operation
that would do either MUST fail rather than proceed, including a runway extension (`LDG-62`) or
an exception-branch top-up (`LDG-63`) that available cannot fund — which route to the exhaustion
path and the operator-deficiency ledger respectively, never to borrowing.

**LDG-35** **The authorization read and the commitment write MUST be serialized per tenant.**
Computing `available` and opening a commitment in one transaction is not sufficient: two
transactions can each read the same balance and each commit, leaving twice the balance reserved
and one machine unfunded. This is write skew, and it commits without error under both READ
COMMITTED and SNAPSHOT isolation. A deployment MUST use a per-tenant lock, a serializable
transaction, or a conditional write against a versioned balance row, and MUST state which.
`STO-1` and `STO-2` specify exactly this kind of primitive for the queue and the machine lock;
money needs one too, and did not have one.

**LDG-11** Opening the commitment and enqueuing the operation MUST be one transaction. A
commitment without an operation silently freezes a customer's money; an operation without a
commitment spends the operator's. This is the requirement `ADR-0001` was decided on.

**LDG-12** No provider mutation that can incur cost may begin before its commitment is committed
— and this includes **adopt** (`LDG-36`), not only create.

**LDG-36** **Adopt MUST place a commitment and pass the same authorization check as create.**
Adoption brings an already-billing machine under management, and `PRV-13c` names it as the main
road onto the branch where cost *cannot* be stopped quickly. An adopted machine MUST also be
given a runway and a `runway_until`, or it never enters the exhaustion sweep and consumes
unstoppable billable compute against a balance nobody checked.

## The meter

**LDG-37** **Usage MUST be metered from a stated source at a stated cadence.** The first version
of this document consumed `accrued_unbilled_usage` in `PRV-13b`'s reserve formula and never said
what produced it — the authorization side was fully specified and the consumption side did not
exist. A deployment MUST define, and record:

- **the source of truth for elapsed billable time** — the machine record's own state transitions,
  or the provider's usage API where one exists. Where the two disagree the provider wins, because
  the provider is what invoices the operator;
- **the cadence** at which a `usage_debit` is posted, which is the granularity at which
  exhaustion can be detected and therefore an input to `wind_down_cost` (`PRV-13b`);
- **which machine states are billable.** `stopped` **is billable** — powering a machine off does
  not stop provider billing on either the cloud or the dedicated products (`LDG-13`). So is
  `cancellation_scheduled`: `DOM-19` states the machine is still running and still billing until
  its effective date, and a meter that stops at cancellation acceptance under-bills for exactly
  the window `DOM-19` was written to make visible;
- **the treatment of a partial period**, rounded per `LDG-28`.

**LDG-38** **AMENDED.** A `usage_debit` MUST be idempotent per **`(subject, billing period, kind,
increment end)`** (`LDG-8`), and posting **any** machine-attributable debit MUST decrement that
machine's commitment in the same transaction (`LDG-31`).

**Rounding MUST be applied to the cumulative charge, never per tick.** `LDG-28` rounds debits up;
applied to each posting, that makes a customer's price depend on how often the meter happens to
run — a deployment that meters every minute charges more than one that meters hourly, for
identical consumption. The rule is therefore:

```
billable_seconds = elapsed billable time for this SUBJECT and period
                 − Σ(absorbed_seconds on its deficiency records, LDG-66)

already_charged  = the MAGNITUDE already charged for this SUBJECT and period
                 = − Σ(signed amounts of the previous **usage** debits for this SUBJECT
                       and period, plus every correction naming one of them,
                       LDG-5, LDG-7)

posted_debit     = ceil(cumulative_exact_charge over billable_seconds)
                 − already_charged
```

with the exact charge carried as a rational (`LDG-4`). **Deficiency-absorbed time is subtracted in
seconds, before conversion — never as a satoshi amount.** An outage deficiency accrues precisely
while no rate exists (`LDG-64`), so there is no rate at which it could be converted; removing the
time it absorbed needs none, and the units never mix.

**What is subtracted is a magnitude, because `LDG-1` makes a debit negative.** The signed sum of
the prior usage debits is a negative number — the worked table above posts `usage_debit` −100 for
the first hour — so negating it is what turns it into the amount already charged. Subtracting that
signed sum *unnegated* would add it back: a second tick whose cumulative charge is 200, against a
prior debit of −100, would post `200 − (−100) = 300` and the period would collect 400 for 200 of
consumption, over-charging by the running total on every tick after the first. `posted_debit` is a
magnitude for the same reason, and the entry `LDG-6` writes for it carries `LDG-1`'s debit sign.

**Corrections net against the debits they name.** `LDG-5` makes a correction a new entry rather
than an edit, so the corrected `usage_debit` row survives unchanged and a gross subtraction cannot
see it. The next posting would then re-charge whatever a correction added, or hand back a second
time whatever it refunded — the customer paying twice, or the operator, for a row that exists
precisely because the first figure was wrong. The subtraction is therefore over the **net**: the
prior usage debits for that subject and period, plus every `correction` (`LDG-7`) naming one of
them. A correction naming an entry of any other kind is not part of this sum.

**A correction carries its own sign, and the netting must respect it.** A correction that
*reduces* a charge is a positive entry: it moves the negative net toward zero and therefore
**lowers** `already_charged`, so the next tick posts more, not less. A correction that *increases*
a charge is negative and raises `already_charged`. Netting the signed amounts and negating once,
as the formula does, is what makes both directions come out right; taking the absolute value of
each entry before summing would make a refund add to the amount already charged and re-charge the
customer for money handed back.

**The subject's high-water mark is the greatest `increment end` already posted for it** — derived
by reading its own `usage_debit` rows, whose idempotency key carries that instant (`LDG-8`). It is
a query over the ledger, not a stored column, and this requirement adds no schema. **An increment
whose end instant is at or before that mark MUST be discarded, not posted** — a re-meter after
restart re-observes elapsed time it has already charged, and without the mark the deduplication key
protects only exact replays, not overlapping ones. **The mark, the cumulative sum and the insert
MUST occur in one serialized transaction** (`LDG-35`): computing them outside it lets two
concurrent runs both read the same prior total and both post. **Observation cadence is an
operational choice; it MUST NOT be a pricing input.**

**`LDG-8` owns the key**; this requirement does not restate it. *A restatement here said `(subject, billing period, kind, posting index)` — the form `LDG-8` withdrew as unable to deduplicate — which is the duplication habit this set keeps paying for.*

**LDG-39** **AMENDED — the setup fee has a lifecycle, not a single moment.** It is committed at
create as part of `PRV-13b`'s sizing, and it becomes a debit **only when the order is known to
have landed**, at which point `LDG-31` decrements the commitment by the same amount so
`available` does not move. The full table, because every row was previously either wrong or
unstated:

| Outcome | Setup fee |
|---|---|
| Order accepted by the provider | **Debited**, commitment decremented in the same transaction |
| Deterministic rejection before acceptance | **Never debited**; released with the commitment (`LDG-32`) |
| Ambiguous — `needs_reconciliation` | **Remains reserved in the commitment**, and is *additionally* recorded as a pending fee obligation on the operation (`LDG-67`). The record exists because `OPS-33` releases the commitment in full at the negative window while the operation stays open — so the obligation must survive that release, not replace the reservation before it |
| Resolved *observed* (`OPS-27`) | **Debited — and the source depends on whether the commitment is still open.** `OPS-27` can resolve *before* `OPS-33`'s negative window elapses, in which case the commitment is still open and still holds the fee: debit against it, decrementing per `LDG-31`. Once the window has elapsed and `OPS-33` has closed it, the fee is debited from available balance **without a commitment decrement**, which is the one debit `LDG-31`'s pairing rule does not cover — there is no commitment left **for this create** to pair with. Where `OPS-36`'s late-attach branch has since opened a wind-down commitment on the same machine, that commitment belongs to a different operation and MUST NOT be decremented by this fee — it was sized to end the exposure, not to carry the create's obligations. Any shortfall is an operator deficiency (`LDG-66`). *Asserting one source was the defect: it double-counted the fee on early resolution, or invented a deficiency that did not exist* |
| Resolved *absent* | **Released in full**; no fee was incurred at the provider |
| Resolved *abandoned* (`OPS-31`) | **Never debited to the customer.** The commitment is closed and released in full (`LDG-32`), the parked obligation is cleared, and the fee becomes an **operator deficiency** (`LDG-66`, `LDG-67`) — the operator gave up establishing whether the order landed, and charging a customer for an outcome nobody established is not defensible |
| Operator requeue out of `needs_reconciliation` (`OPS-3`, `OPS-4`) | **Never debited for the superseded attempt.** The parked obligation is cleared and the fresh attempt commits and settles its own setup fee through the rows above (`LDG-67`); keeping the old one alive would bill one machine's setup twice |

*Two defects are fixed here.* The withdrawn text debited the fee **before** the provider call, so
a deterministic rejection or a resolved-absent create left the customer paying a non-refundable
fee the operator never incurred — the operator keeping money for nothing, which `ADR-0006`'s
at-cost pass-through forbids and which an autonomous retrying caller reaches repeatedly. And
debiting without decrementing is `LDG-31`'s double-count.

**The original concern still holds and is still answered:** the fee must not be a *reversible*
reservation on the accepted path, or a create-then-delete cycle costs the tenant nothing and the
operator the whole fee. Acceptance is the trigger; reversal happens only where the provider never
charged.

## The rate

**LDG-40** **AMENDED — the source is now specified as a construction (`LDG-58`–`LDG-61`), not
left to be named.** What remains a deployment obligation is the trust model, the staleness bound,
the quorum and the unavailable behaviour below. Every commitment, every re-derivation and every
price depends on a satoshi-to-provider-currency rate, and the first version of this document
specified none — a load-bearing external dependency with no requirements and no threat model.

A deployment MUST state: the maximum age at which a source's price may still be used (`LDG-59`);
and, for each of the following, the behaviour when no rate is available — **create** (MUST halt:
it is a purchase priced at an unknown rate), **re-derivation** (MUST halt rather than
under-reserve, and the halt MUST NOT itself trigger exhaustion), **the exhaustion sweep** (MUST
continue: it reduces exposure), and **the solvency check** (MUST fail closed).

**The fifth row — metering — was missing, and it is the one that costs money** (`LDG-64`).

*The withdrawn wording asked whether each of these "proceeds on a stale rate or halts", which
`LDG-59` removes as a choice — there is no proceeding on a stale rate. The matrix is now about
having no rate at all, and its four answers are unchanged.*

**LDG-41** **AMENDED.** A rate MUST be treated as attacker-influenced input. A manipulated or
erroneous rate mis-prices the entire fleet simultaneously, so `LDG-16`'s **multi-derivation
persistence rule** is a security control, not smoothing. *The per-tick cap this requirement used
to name alongside it is withdrawn with the commitment resizing it governed (`ADR-0011`,
`PRV-13e`): nothing increases per tick, so capping the increase capped nothing.*

**And past those controls it is the only external input that destroys customer data.** A rate that
understates the satoshi makes solvent customers look exhausted; `LDG-14` then cancels the machine
and destroys its disk. Every other external dependency in this specification can at worst cost the
operator money or stop the service. This one reaches the customer's data.

**LDG-58** **The rate MUST be the median of at least three independent sources.** *Independent*
means not sharing a venue, an operator or an upstream feed — two front-ends onto the same order
book are one source, and counting them as two produces a quorum that a single venue controls. The
count MUST be odd, so the median is an observed price rather than an average of two.

**LDG-59** **Each source MUST carry a staleness bound, and a stale source MUST be excluded rather
than used.** A deployment MUST state a **quorum**: the minimum number of live, non-excluded
sources below which there is **no rate**, at which point `LDG-40`'s per-operation behaviour
applies — create halts, re-derivation halts without triggering exhaustion, the exhaustion sweep
continues, the solvency check fails closed. **Falling back to the last known rate MUST NOT
happen.** A stale rate is not a degraded rate; it is a number that was true once and is now being
used to price a purchase, which is exactly the condition `LDG-40` makes create halt for.

**LDG-60** **A source deviating from the median by more than a stated band MUST be excluded**, and
exclusion MUST reduce the count for `LDG-59`'s quorum test rather than being silently tolerated.
Repeated exclusion of the same source MUST be visible to the operator — this is operational data
about a price feed, not information about a customer, so `LDG-21` does not restrict it.

**LDG-61** **The source set MUST be fixed at deployment and MUST NOT be settable at runtime by any
API path, tenant input or database write.** This mirrors `SEC-50` for the same reason: an attacker
who can add a source can move the median, and moving the median moves every reserve, every price
and every exhaustion decision in the fleet at once. A rate feed the process can be told to trust
is not a control, it is a second front door.

**LDG-64** **A rate outage is operator-borne, time-bounded, and never billed retroactively.**
While there is no rate (`LDG-59`), a machine keeps running and the provider keeps charging, but
usage cannot be converted to satoshis. A deployment MUST:

- **meter in the provider's own currency** for the duration, recording elapsed billable time and
  its native cost (`LDG-2`), attributed to the machine;
- **charge the customer nothing for that window.** The native accrual is an **operator
  deficiency** in the manner of `LDG-63`. **Deferred satoshi debits at a later rate MUST NOT be
  posted** — a customer would be billed for hours at a price that did not exist while it was
  consuming, uncapped and unforeseeable, which `WIR-17`'s `max_commitment_sats` cannot protect
  against because the commitment was already open;
- **persist the outage's start instant and the exact computed deadline** (not the duration, which
  a restart would re-apply from a fresh start), so a restart mid-outage does not reset the clock
  and quietly extend the exposure past the bound. The deficiency record (`STO-37`) is where they
  live;
- **keep the outage deficiency native-only: it is never converted, at any later rate.** Its
  `rate_num`/`rate_den` stay null for good (`LDG-66`), because there was no rate while it accrued
  and stamping it with the first one to return would price those hours at a number that did not
  exist during them — the retroactive bill this requirement exists to forbid. The meter still has
  to know the window was paid for, and it does that in time rather than in satoshis: `LDG-38`
  subtracts the **elapsed time** the deficiency absorbed (`absorbed_seconds`), which needs no rate
  at any point;
- **state a maximum tolerated outage**, chosen against how much exposure the operator will carry,
  and **cancel machines at that bound** if no rate has returned. **The bound MUST be disclosed
  before purchase (`WIR-30`'s offer) and the live deadline exposed on the machine view as
  `rate_outage_deadline`, null when no outage is in progress (`WIR-11`)**: otherwise a machine whose advertised `runway_until` is months away is destroyed for a
  reason its owner was never told about and cannot act on — `LDG-14` promises destruction at
  runway exhaustion and this is a second, undisclosed trigger. The bound is the operator's own
  loss limit, and it MUST be stated with the other deployment parameters (`LDG-42`).

**LDG-66** **An operator deficiency is a durable record of its own, and it is NOT a ledger
entry.** `LDG-7`'s entry kinds are closed and every one of them moves *tenant* satoshis, so the
native-currency accruals this specification now creates in **six** places — `LDG-31`'s clamp overflow, `LDG-63`'s
exception branch, `LDG-64`'s rate outage, `SEC-46`'s unconfirmed account loss, `OPS-36`'s
unfunded wind-down and `LDG-39`'s unrecoverable setup fee —
have nowhere legal to live — six sources, not the four an earlier draft counted. A deployment
MUST persist them in a separate record (`STO-37`)
carrying the machine or attachment, the provider-native amount and currency (`LDG-2`), **the
elapsed billable time it absorbed** — without which the meter cannot remove that window from the
charge at all (`LDG-38` subtracts it in seconds) — the cause, and an idempotency key; they MUST
feed provider payables in the solvency check (`LDG-17`) and MUST NOT alter any tenant balance.
**Nothing here is billable to a customer** — that is the whole point of calling it the operator's.

**The rate is nullable and is required only for a cause that had one.** Where a rate existed when
the deficiency was opened — the clamp overflow, the exception branch, an account loss, an unfunded
wind-down, an unrecoverable setup fee — the record MUST carry it as `rate_num`/`rate_den` (`LDG-4`),
because that is what the operator's loss was worth at the moment it was taken. A rate-outage
deficiency (`LDG-64`) opens precisely when there is no rate, so it carries none, ever, and nothing
in this specification converts it: `absorbed_seconds` alone is what the meter needs.

**LDG-65** **The exhaustion sweep continues during an outage on the last derived
`runway_until`** (`LDG-40` requires it keep running), which remains correct because `LDG-33`
recomputes the date only when a rate exists. A machine whose runway expires mid-outage is
cancelled normally; what is suspended is *pricing*, not *protection*.

**Why there is no ADR for this.** Two of the three tests fail. The trade-off is real and the
alternatives were considered — a single named exchange, a published reference index, and
abandoning the rate entirely by pricing in satoshis — but **the decision is cheap to reverse**:
swapping the median for an index, or adding and removing sources, is a contained change behind
`LDG-40`'s interface. What is *not* cheap to reverse is `LDG-40`'s halt matrix and `LDG-59`'s
refusal to fall back, and those are recorded as requirements because they are product-visible
availability behaviour, not implementation.

## Money in

**LDG-42** **A funding path MUST exist and MUST be specified.** The first version gated tenant
activation on "a payment has been credited" (`API-35`) and made a payment notification a BLOCKING
conformance item (`CNF-94`) while specifying no endpoint that takes money — the only path that
turns a stranger into a customer was missing entirely.

**AMENDED — this requirement previously listed what a deployment must decide; `ADR-0008` decided
it.** `LDG-46`–`LDG-57` are the decisions. What survives as a deployment obligation is narrower:
the confirmation depth of `LDG-48`, the per-rail floors of `LDG-52`, the **deposit expiry** of
`LDG-54`, and the channel-balance treatment of `LDG-53` are all deployment parameters, and each
MUST be stated rather than left to an implementer's judgement. The expiry is the load-bearing one:
it is simultaneously the customer's deadline, the operator's disclosure (`LDG-54`) and the bound
on the watch set (`LDG-57`), so choosing it short to save work shortens the customer's window and
choosing it long to be generous grows an obligation the operator cannot shed.

**LDG-46** **AMENDED. A deposit is one object with two ways to pay it.** A funding request MUST
mint a single **deposit** carrying an **amount** and an **expiry**, and MUST return *both* a
Lightning destination and an on-chain destination for it. **The deployment MUST NOT select the
rail; the payer selects it at payment time.**

*The withdrawn text made the rail an operator choice at mint, answering on-chain whenever the
amount exceeded inbound capacity. That is wrong in two ways. It forces a guess about liquidity
that can be stale by the time the customer pays, and it makes the awkward case — the large
first top-up — the one where the operator's guess is load-bearing. Offering both moves the choice
to the party who knows their own constraints.*

**LDG-54** **The deposit's expiry governs both rails, and on-chain it is a promise rather than a
mechanism.** A Lightning invoice enforces its own expiry: after it, the payment cannot be made. An
address does not and cannot — it stays payable forever, and nothing the operator does changes
that. So on the on-chain rail the expiry means only that **the operator stops watching**, and that
distinction MUST be disclosed to the caller at mint, in those terms. **An address that still looks
payable but is no longer watched is the trap this requirement exists to prevent**, and it is the
one place in the funding design where a customer can lose money by doing something that looks
correct.

**LDG-55** **Settlement on one rail MUST NOT stop watching the other before expiry.** Both
destinations are live for the deposit's whole life, so a customer may pay both — most plausibly by
paying on-chain, waiting, losing patience, and paying over Lightning. Each payment MUST be
credited on its own terms (`LDG-47`); the deposit is not a receivable that closes on first
settlement. Treating first settlement as closure strands the second payment, which is `LDG-43`'s
forbidden outcome reached through an optimisation.

**LDG-56** **Paying a deposit twice credits twice, and there is no refund.** This follows from
`LDG-47` and `ADR-0004` and is stated separately because it is the one consequence a customer
will experience as surprising. It MUST be disclosed alongside `LDG-54`'s expiry disclosure. The
alternative — refusing or holding the second payment — would strand money the operator is
forbidden from returning, which is worse.

**LDG-57** **The active watch set is bounded by the expiry, and this is what makes on-chain
funding affordable.** A deployment MUST watch only unexpired deposits' addresses, so the set is
bounded by *mint rate × expiry window* regardless of how long an attacker persists. Retaining the
expired binding is a storage question and a cheap one (`STO-29`); **watching is the expensive
obligation, and the expiry is what bounds it.** An implementation that watches every address ever
issued has re-created an unbounded, un-reclaimable commitment minted by a free action.

**LDG-47** **Credit what arrived, never what was intended.** One rule, both rails. On-chain the
payer bears the network fee, so the credit is the received output value; on Lightning the invoice
amount is exact and routing is paid by the payer on top. An overpayment MUST be credited in full
— refusing it would strand money `ADR-0004` forbids returning. An underpayment MUST also be
credited at its received value; whether it activates a pending tenant depends on the tenant's
**cumulative** credited balance reaching `LDG-44`'s activation minimum (`LDG-52`, `API-35`), not
on this single payment clearing anything. **A credit derived from the requested amount rather than the settled
amount mints the difference**, and does so silently, on every partial payment.

**LDG-48** **Finality is per-rail and both MUST be stated.** On Lightning, credit MUST NOT be
posted before the invoice is settled and its preimage is known to the operator's node; an
accepted-but-held HTLC is not a payment. On-chain, credit MUST NOT be posted before a stated
confirmation depth, and **zero-confirmation credit MUST NOT be offered on any rail or for any
amount** — a replaceable transaction would buy a machine whose setup fee is already
non-refundable the instant the order lands (`LDG-39`), which is a self-funding attack rather than
a risk to be priced.

**LDG-49** **Attribution is by deposit, never by payer.** Each of a deposit's two destinations —
the payment hash and the derived address — MUST resolve to exactly one deposit and therefore to
exactly one tenant, and the credit MUST be posted against that binding. Destinations MUST NOT be
shared between deposits or between tenants. The destination-to-deposit map is the operator's own
record and identifies no counterparty, so it satisfies `LDG-21` and `ADR-0005` while doing the
work that knowing the payer would otherwise be needed for.

**LDG-50** **A fresh on-chain address per deposit.** Reusing one address per tenant publicly links
every top-up that tenant ever makes, on a ledger that is permanent and worldwide. That is a larger
privacy harm than anything `ADR-0005` prevents by not writing logs, and it is inflicted by the
operator's own address policy rather than by the customer's choice.

**LDG-51** **AMENDED. Expiry ends watching; the binding outlives it.** A payment arriving at an
expired deposit's address, for a live tenant, MUST be credited if it is observed at all — the
binding is retained (`STO-29`) precisely so that a late payment brought to the operator's
attention can still be attributed rather than being unrecoverable by construction. What expires is
the obligation to *notice* it (`LDG-57`), not the ability to resolve it. A payment for a tenant
that no longer exists is governed by `LDG-43`.

*The withdrawn text said "expiry ends payability, not the binding" and treated an address's
permanent payability as the anomaly. Under `LDG-54` the anomaly is named directly and the
consequence is split in two: watching stops, resolution does not.*

**LDG-52** **AMENDED twice — a rail floor is not the activation minimum, and conflating them
stranded customers.** The two are separate parameters doing different jobs: **`LDG-44`'s
activation minimum** is a threshold on the tenant's **cumulative credited balance**, and
**activation MUST occur atomically the moment that cumulative total reaches it** — two credited
payments of 60,000 against a 100,000 minimum activate the tenant, where the withdrawn per-payment
reading left it pending forever holding 120,000 non-refundable satoshis. A **rail floor** is an
economic and disclosure parameter only (`WIR-14`) and gates nothing.

The on-chain floor MUST exceed the cost of eventually spending the output the payment creates. A top-up smaller than its
own future sweep fee reduces the satoshis the operator holds while increasing the float, so it
does not underfund a tenant — it moves `LDG-17` in the wrong direction, and does so more the more
often it happens.

**Because a deposit is payable over either rail (`LDG-46`), the floor cannot be enforced at
mint.** A deposit whose amount clears the Lightning floor but not the on-chain floor MUST still be
mintable; what the deployment MUST do is disclose the on-chain floor with the destination, and
credit an under-floor on-chain payment at its received value (`LDG-47`) rather than refusing it.
**Refusing it would strand it**, since `ADR-0004` forbids sending it back.

**LDG-53** **Solvency counts both rails** (`LDG-17`). Satoshis actually held MUST include channel
balances and confirmed on-chain outputs at addresses derived from the operator's key material. A
channel balance is encumbered by channel state and a force-close returns it on a timelock, so a
deployment MUST state whether the solvency check counts a channel balance at face value — and if
it does, that a fully-drained inbound position can be solvent on paper while unable to fund a
withdrawal it is in any case forbidden from making (`ADR-0004`).

**The check MUST be computable watch-only** (`SEC-48`). Counting what is held is a read, so the
invariant this whole design rests on needs no key that can spend — which is the property that
made `ADR-0009` affordable. An implementation that reaches for a spending key to answer "am I
solvent" has either misunderstood the question or acquired a capability `SEC-48` forbids.

**LDG-43** A payment that cannot be attributed to a live tenant MUST be recorded as unattributed
and MUST NOT be silently dropped, and a tenant MUST NOT be deleted while a payment attributable
to it is in flight (`API-34`). The ledger is append-only and never purged (`LDG-22`), so an
entry against a deleted tenant can never be cleaned up — and `ADR-0004` forbids a refund while
`ADR-0005` forbids retaining the means to find the payer. **Keeping a stranger's money with no
way to return it is the one outcome this specification must not permit by accident.**

**LDG-44** Activation MUST require a **minimum funding amount** sufficient to purchase something.
`API-35` graduated a tenant on any credited payment, so a single satoshi produced a permanent
row that `API-34`'s time-to-live could never reclaim.

**LDG-67** **A pending fee obligation is a record, not an entry.** `LDG-39`'s ambiguous row parks
the setup fee on the operation until resolution, and that needs a home: `operations` carries
`pending_fee_native_minor` and `pending_fee_currency` (`05-persistence.md`), in the provider's
currency because the fee is not yet a satoshi obligation. Alongside the native figure it carries
`pending_fee_sats`, the **satoshi amount authorized at create**, so a late resolution debits what
the customer actually authorized rather than a re-conversion at whatever the rate has since
become.

All three columns are cleared when the fee is debited (resolved-observed) or dropped
(resolved-absent, deterministic rejection), and on resolved-observed the clear MUST happen inside
`OPS-27`'s single resolution transaction rather than as a follow-up write. **On `abandoned`
(`OPS-31`) the fee is an operator
deficiency** (`LDG-66`): the operator gave up establishing whether the order landed, and charging
a customer for an outcome nobody established is not defensible. **On an operator requeue**
(`OPS-3`'s `needs_reconciliation → queued`, `OPS-4`) **the parked fee is cleared and nothing is
debited for it**: the requeue re-executes the order, and the fresh attempt commits and settles its
own setup fee under `LDG-39`, so keeping the old obligation alive would bill one machine's setup
twice. It moves no satoshis while it sits there, so it is not a `LDG-7` entry kind — the same
reason `LDG-66`'s deficiencies are not.

## Pricing

**LDG-23** Customer price MUST be a derived value, never the provider's price string passed
through. One function maps an offer to a customer price and every caller goes through it.

**LDG-27** The conversion from a provider price string to integer minor units happens **once**,
at the point a price becomes an obligation — opening or adjusting a commitment, or posting a
debit. Offers carry the provider's exact string (`DOM-9`); obligations carry integers (`LDG-1`).

**LDG-24** The margin is a percentage applied to machine time only (`ADR-0007`), expressed in
basis points (`LDG-29`). Setup fees pass through at cost (`ADR-0006`). It MUST be configuration,
resolvable per provider account or product class, and MUST NOT be a constant in code.

**LDG-25** Privileged operations — custom-image installs, rescue sessions, reimages — are free in
v1 but MUST be metered from the first release. A price cannot be introduced later for something
that was never counted.

**LDG-26** **AMENDED twice.** The offers endpoint MUST return customer prices. It MUST NOT return
the operator's own cost as a *field* — and because `DOM-9`'s offer carries the provider's price
and raw metadata, a deployment MUST **strip** them on the customer-facing path. `WIR-30` says the
same at the wire: the provider's currency, price string and raw metadata MUST NOT appear.
*The first text prohibited returning provider cost while the offer type it returns is defined as
containing it. The second offered a choice — strip, or accept that cost is disclosed — which
`WIR-30` does not permit; the choice is withdrawn.*

## Exhaustion

**LDG-13** A machine whose funding fails MUST be cancelled, and cancellation is the only effective
remedy — powering a machine off does not stop provider billing. There is no unfunded grace
period, because `PRV-13d`'s runway is the grace period and it is committed in advance.

**LDG-45** The runway is **committed**, not prepaid, and `LDG-13`'s justification MUST be read
that way. A committed reservation is released if unused (`LDG-32`); a prepayment would not be.
The first version used both words and they mean different things to a customer reading the terms.

**LDG-14** **AMENDED.** At end of runway the machine MUST be cancelled and its disk destroyed
with it, and this MUST be stated plainly in the terms and the API documentation. **Where the
provider cannot cancel immediately** (`PRV-13`'s scheduled-cancellation shape, `DOM-19`), the
machine keeps running and keeps billing until its effective date, and the deployment MUST hold a
commitment covering that whole window or MUST NOT sell that machine on prepaid terms
(`PRV-13c`). The previous text made immediate destruction unconditional, which is unexecutable
on exactly the branch where cost cannot be stopped.

**LDG-15** Remaining runway MUST be readable from the machine view, so a caller can act on it. A
caller that is software will act on a number long before it would act on an email, and there is
no email. **`runway_until` floats with the price** (`LDG-33`): the read is the customer's whole
visibility into repricing, which is why it is a MUST and not a nicety.

**LDG-62** **Extending runway is a caller write, authorized like a purchase.** It increases the
machine's commitment — **or opens one where the machine has none**, which is `OPS-36`'s
deficiency-funded late-attach branch — from available balance at the **current** rate, under `LDG-35`'s per-tenant
serialization and `LDG-10`'s no-negative rule, in one transaction. **A commitment *opened* by an
extension MUST be sized `requested runway × current customer rate + protected_sats` (`LDG-33`)**,
the same shape a create uses: sized at the requested runway alone it would advertise as runnable
time the satoshis wind-down and any cancellation date already need, which is exactly the error
`LDG-33` exists to prevent. It is the only way a
commitment grows outside `LDG-63`, and it MUST be idempotent per `API-8` — two concurrent
extends must not reserve twice.

**LDG-63** **The scheduled-cancellation branch is the exception, because the operator cannot
exit.** For a machine whose billing runs to an effective date regardless (`DOM-19`, `PRV-13c`),
re-derivation MUST top the commitment from available so it covers cost through that date at the
current rate; where available cannot fund it, the shortfall is **operator-borne** — there is no
customer action to wait for and no faster cancellation to route to — and MUST be surfaced to the
operator as a named deficiency, bounded per machine by `PRV-31`'s declared worst case. This is
one of the two exceptions `ADR-0003`'s amended matching claim names.

**LDG-16** **AMENDED (`ADR-0011`).** A rate or price movement MUST NOT have its own cancellation
machinery; it reaches the machine by moving `runway_until` (`LDG-33`) into this same exhaustion
path. A machine MUST be routed into that path while its remaining commitment still covers
wind-down **at the current rate** — that invariant, not commitment widening, is what keeps the
operator whole — and cancellation MUST still require the deficiency to persist across more than
one derivation, so a single bad rate reading can move a date but can never destroy a disk. *The
per-tick cap on commitment adjustment is withdrawn with the adjustment itself.*

## Solvency

**LDG-17** **AMENDED — wording is load-bearing here.** The operator MUST maintain satoshi reserves
at least equal to the float plus provider payables already incurred. Customer float is not
operating capital and MUST NOT be spent on operating costs, and the operator's own margin MUST be
distinguishable in the ledger from customer balances — which requires an operator account in the
ledger model, since `LDG-6` otherwise attributes every entry to a tenant.

**LDG-18** The float MUST NOT be pledged, lent, or posted as collateral (`ADR-0003`).

**LDG-19** **AMENDED — and this correction is the important one.** The previous text said the
solvency invariant SHOULD be published, on the reasoning that publishing converts a later breach
into actionable misrepresentation. **That reasoning collides with `ADR-0004` §4**, which forbids
describing balances as "held", "backed", "reserved" or "segregated" — because publishing "the
operator holds satoshis equal to the sum of customer balances" *is* that description, and a
maintained one-to-one asset-to-claim ratio is what safekeeping on behalf of clients looks like
from outside, whatever the contract says.

The two requirements were written the same day and neither noticed the other.

**SETTLED 2026-08-13 by operator decision: the invariant MUST NOT be published, ever — not
pending advice.** The reasoning was not legal caution but plainness: *any* public statement in
this area is confusing to the reader, because the true position ("we hold enough, and you still
have only a contractual claim") requires a customer to hold two apparently opposed ideas at once,
and every shorter phrasing of it drifts toward the custody words `ADR-0004` §4 bans. **A statement
a reader will misunderstand is worse than silence**, and the enforceability benefit the original
text chased is not worth buying with a sentence that misleads.

**What is given up, stated plainly:** the original reasoning was sound on its own terms —
publishing converts a later breach into actionable misrepresentation, which was the only
enforcement the perimeter otherwise supplies. That protection is now absent, and the customer's
recourse if the operator fails is ordinary unsecured creditor status and nothing more. `ADR-0004`
is amended to record the reversal.

**LDG-19a** **Silence about the invariant is not silence about the arrangement, and the two MUST
NOT be conflated.** `LDG-19` prohibits publishing the solvency *ratio*; `ADR-0004` §4 continues to
**require** the terms to state that a balance is an **unsecured claim** and that funds are used in
the business. Saying nothing at all would leave a customer to assume their money is safeguarded —
which is the misrepresentation `ADR-0004` §4 exists to prevent, arrived at by omission instead of
by wording. The rule is therefore: **publish no assurance, and publish the disclaimer.**

The internal obligation is untouched: `LDG-17` still requires the satoshis actually be held,
`LDG-18` still forbids pledging them, and `LDG-20` still gates operations on the solvency check.
**This decision changes what is said, not what is done** — the operator remains fully reserved and
simply declines to advertise it.

**LDG-20** **AMENDED.** Solvency MUST be checked against stress: the provider-currency pair
adverse by 15%, an inaccessible venue for seven days, no new top-ups, and every existing balance
consumed with maximum provider cost through cancellation. An asset counts only if it can reach
the provider's account before the liability falls due.

**On failure the system MUST halt top-ups first**, then refuse every bill-increasing operation,
while continuing to permit cancellation and deletion. The previous version halted sales and left
funding open — so a customer could pay for a claim the operator had just computed it could not
honour, which is precisely the misrepresentation `LDG-19` warns of. The operations that *reduce*
exposure MUST never be gated by the check that fires because exposure is too high.

*(The previous stress set opened with "bitcoin down 50%", which is a no-op against a float
denominated in satoshis and reserves held in satoshis — a test that cannot fail on its own first
parameter. The exposure that survives `ADR-0003` is the provider-currency leg, and that is what
this now stresses.)*

## Privacy constraints on the ledger

**LDG-21** The ledger MUST NOT record anything identifying beyond the tenant identifier
(`ADR-0005`). No caller addresses, no payment counterparty information. Payment references are
retained only as far as reconciling a top-up requires, and MUST NOT include a spendable secret —
no ecash token, no preimage. **This is not hygiene: the ledger is append-only and exempt from
retention (`LDG-22`), so a bearer secret written here is a secret no cleanup job may ever
remove.**

**LDG-22** Ledger retention is not subject to the operation payload purge (`ADR-0005`). A
financial record outlives the request that caused it, and contains no caller secrets to purge
only because `LDG-21` kept them out.

## What deliberately does not exist here

There is no withdrawal, no transfer between tenants, no fiat refund, and no balance expiry that
credits the operator. Each is prohibited by `ADR-0004`, each for more than one independent
reason, and adding any of them changes the regulatory position of the whole business rather than
adding a feature.
