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
For a `usage_debit` the key MUST be `(machine, billing period, kind)`, so that two workers
metering the same period cannot both post it.

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

**LDG-31** **Consumption MUST debit the ledger and decrement the commitment by the same amount,
in one transaction.** This is the requirement whose absence broke the first version. Its effect
is that ordinary consumption leaves `available` **unchanged** — which is correct, because
spending what you already committed neither frees nor freezes anything:

| event | Σ entries | reserved | available |
|---|---:|---:|---:|
| `topup` +72,000 | 72,000 | 0 | 72,000 |
| commitment opened, 72,000 | 72,000 | 72,000 | 0 |
| one hour consumed: `usage_debit` −100, commitment → 71,900 | 71,900 | 71,900 | 0 |
| machine deleted, commitment closed | 71,900 | 0 | 71,900 |

**LDG-32** A commitment MUST be closed, and its remaining amount released in full, on **every**
terminal outcome: the machine stops billing; the create fails deterministically; the create is
resolved absent (`OPS-27`); the operation is abandoned (`OPS-31`); or the provider account is
lost (`SEC-46`). **A terminal path with no close rule strands a customer's satoshis
permanently** — there is no withdrawal (`ADR-0004`), no expiry, and under `ADR-0005` no identity
to appeal with, so an ordinary retry loop against a contended offer would otherwise render a
balance unusable forever.

**LDG-33** Re-derivation (`PRV-13e`) MUST compute the required reservation from **remaining**
runway, not from the runway originally requested, and MUST adjust the commitment in **both**
directions. A re-derivation that can only increase is not a correction, it is a ratchet.

**LDG-34** A commitment adjustment MUST be a conditional write on the commitment's current
amount — a compare-and-swap or equivalent — so two workers re-deriving the same machine in the
same period cannot both apply the delta.

**LDG-10** A balance MUST NOT go negative, and `available` MUST NOT go negative. Any operation
that would do either MUST fail rather than proceed, including a re-derivation that raises a
commitment — which routes to the exhaustion path rather than borrowing.

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

**LDG-38** A `usage_debit` MUST be idempotent per `(machine, billing period, kind)` (`LDG-8`), and
posting one MUST decrement the machine's commitment in the same transaction (`LDG-31`).

**LDG-39** **The setup fee MUST be debited when the order is placed, not reserved.** It is
non-refundable at the provider the instant the order lands, so modelling it as a reversible
reservation makes a create-then-delete cycle cost the tenant almost nothing and the operator the
entire fee — repeatable indefinitely for the price of one machine's balance. `PRV-13b` requires
it be fully collected before the order; collected means **debited**.

## The rate

**LDG-40** **A rate source MUST be named, and its trust model, staleness bound and unavailable
behaviour stated.** Every commitment, every re-derivation and every price depends on a
satoshi-to-provider-currency rate, and the first version of this document specified none — a
load-bearing external dependency with no requirements and no threat model.

A deployment MUST state: the source; the maximum age at which a rate may still be used; and, for
each of the following, whether it proceeds on a stale rate or halts — **create** (MUST halt: it
is a purchase priced at an unknown rate), **re-derivation** (MUST halt rather than under-reserve,
and the halt MUST NOT itself trigger exhaustion), **the exhaustion sweep** (MUST continue: it
reduces exposure), and **the solvency check** (MUST fail closed).

**LDG-41** A rate MUST be treated as attacker-influenced input. A manipulated or erroneous rate
under-reserves the entire fleet simultaneously, so `PRV-13e`'s per-tick cap and multi-derivation
persistence rule (`LDG-16`) are security controls, not smoothing.

## Money in

**LDG-42** **A funding path MUST exist and MUST be specified.** The first version gated tenant
activation on "a payment has been credited" (`API-35`) and made a payment notification a BLOCKING
conformance item (`CNF-94`) while specifying no endpoint that takes money — the only path that
turns a stranger into a customer was missing entirely.

**AMENDED — this requirement previously listed what a deployment must decide; `ADR-0008` decided
it.** `LDG-46`–`LDG-53` are the decisions. What survives as a deployment obligation is narrower:
the confirmation depth of `LDG-48`, the per-rail floors of `LDG-52`, the invoice expiry of
`LDG-51`, and the channel-balance treatment of `LDG-53` are all deployment parameters, and each
MUST be stated rather than left to an implementer's judgement.

**LDG-46** **Two rails ship: Lightning primary, on-chain fallback** (`ADR-0008`). A deployment
MUST offer both. Lightning has a ceiling the customer cannot see — a top-up exceeding inbound
capacity presents as a payment that simply does not route — so a funding request whose amount
cannot be invoiced MUST be answered with an on-chain destination rather than an error, and the
caller MUST be told which rail it was given. **A rail is a property of the funding request, not of
the tenant**: the same tenant funds over Lightning on Monday and on-chain on Tuesday.

**LDG-47** **Credit what arrived, never what was intended.** One rule, both rails. On-chain the
payer bears the network fee, so the credit is the received output value; on Lightning the invoice
amount is exact and routing is paid by the payer on top. An overpayment MUST be credited in full
— refusing it would strand money `ADR-0004` forbids returning. An underpayment MUST also be
credited at its received value, and simply fails to activate a pending tenant if it does not
clear `LDG-52`'s floor. **A credit derived from the requested amount rather than the settled
amount mints the difference**, and does so silently, on every partial payment.

**LDG-48** **Finality is per-rail and both MUST be stated.** On Lightning, credit MUST NOT be
posted before the invoice is settled and its preimage is known to the operator's node; an
accepted-but-held HTLC is not a payment. On-chain, credit MUST NOT be posted before a stated
confirmation depth, and **zero-confirmation credit MUST NOT be offered on any rail or for any
amount** — a replaceable transaction would buy a machine whose setup fee is already
non-refundable the instant the order lands (`LDG-39`), which is a self-funding attack rather than
a risk to be priced.

**LDG-49** **Attribution is by destination, never by payer.** A funding request MUST mint a
destination bound to exactly one tenant — a payment hash on Lightning, a derived address
on-chain — and the credit MUST be posted against that binding. Destinations MUST NOT be shared
between tenants. The destination-to-tenant map is the operator's own record and identifies no
counterparty, so it satisfies `LDG-21` and `ADR-0005` while doing the work that knowing the payer
would otherwise be needed for.

**LDG-50** **A fresh on-chain address per funding request.** Reusing one address per tenant
publicly links every top-up that tenant ever makes, on a ledger that is permanent and worldwide.
That is a larger privacy harm than anything `ADR-0005` prevents by not writing logs, and it is
inflicted by the operator's own address policy rather than by the customer's choice.

**LDG-51** **Expiry ends payability, not the binding.** A Lightning invoice MUST carry an expiry
after which it can no longer be paid. **An on-chain address has no such property** — anyone may
pay a derived address forever, and nothing the operator does can prevent it. Therefore the
destination-to-tenant binding MUST be retained beyond the lifetime of the funding request that
created it, and a payment arriving at an expired destination belonging to a live tenant MUST be
credited normally. A payment arriving for a tenant that no longer exists is governed by `LDG-43`
and is the one case the two rails genuinely differ on, because only the on-chain rail can receive
one.

**LDG-52** **`LDG-44`'s minimum is per-rail, and the on-chain floor is higher.** It MUST exceed
the cost of eventually spending the output the payment creates. A top-up smaller than its own
future sweep fee reduces the satoshis the operator holds while increasing the float, so it does
not underfund a tenant — it moves `LDG-17` in the wrong direction, and does so more the more
often it happens.

**LDG-53** **Solvency counts both rails** (`LDG-17`). Satoshis actually held MUST include channel
balances and confirmed on-chain outputs. A channel balance is encumbered by channel state and a
force-close returns it on a timelock, so a deployment MUST state whether the solvency check
counts a channel balance at face value — and if it does, that a fully-drained inbound position
can be solvent on paper while unable to fund a withdrawal it is in any case forbidden from
making (`ADR-0004`).

**LDG-43** A payment that cannot be attributed to a live tenant MUST be recorded as unattributed
and MUST NOT be silently dropped, and a tenant MUST NOT be deleted while a payment attributable
to it is in flight (`API-34`). The ledger is append-only and never purged (`LDG-22`), so an
entry against a deleted tenant can never be cleaned up — and `ADR-0004` forbids a refund while
`ADR-0005` forbids retaining the means to find the payer. **Keeping a stranger's money with no
way to return it is the one outcome this specification must not permit by accident.**

**LDG-44** Activation MUST require a **minimum funding amount** sufficient to purchase something.
`API-35` graduated a tenant on any credited payment, so a single satoshi produced a permanent
row that `API-34`'s time-to-live could never reclaim.

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

**LDG-26** **AMENDED.** The offers endpoint MUST return customer prices. It MUST NOT return the
operator's own cost as a *field* — but `DOM-9`'s offer carries the provider's price and raw
metadata, so a deployment MUST either strip those on the customer-facing path or accept that cost
is disclosed. The previous text prohibited returning provider cost while the offer type it
returns is defined as containing it.

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
no email.

**LDG-16** A rate or price movement MUST NOT have its own cancellation machinery; it reaches the
machine through `PRV-13e`'s re-derivation and then this same path, with a per-tick cap and a
deficiency that must persist across more than one derivation.

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

The two requirements were written the same day and neither noticed the other. **A deployment MUST
NOT publish the invariant until counsel has ruled on it**, and this — not the refund question —
is the first item to put to a lawyer, because `ADR-0003`'s entire defence is that a custody
characterisation is answerable by drafting, and `LDG-19` was requiring publication of the
substance the drafting exists to deny.

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
