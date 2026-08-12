# The customer float is denominated in satoshis

**Status:** accepted (2026-08-11) — with a recorded dissent, see below

Customers pay in bitcoin; providers invoice in EUR and USD. The question was how to back a
customer balance. We inverted it: rather than denominating the balance in fiat and then
acquiring fiat to back it, **the balance is denominated in satoshis**, matching the liability to
the asset actually held.

A customer deposits 100k sats and holds 100k sats of credit. Machines are priced in sats at spot
each billing period. The operator holds sats and owes sats, and is matched at all times¹. Sats are
sold only at the moment consumption creates a provider invoice.

## Why this beats the alternatives

Denominating in EUR requires the operator to *make* the match, by one of three routes, all of
which were analysed and rejected:

- **Convert on receipt.** Zero market risk and the cleanest legal story, but it puts a KYB'd
  exchange and a bank on the critical path of every customer payment — and pseudonymous
  Lightning/Fedimint merchant proceeds are precisely what those counterparties freeze. It trades
  market risk for concentrated regulated-rail risk and abandons bitcoin denomination.
- **Hold sats and hedge with a short.** Requires building and operating a hedging subsystem
  (target notional, drift, margin, funding) inside the process that holds provider credentials,
  against a custodial venue where deposited BTC is a contractual claim with no deposit
  protection.
- **Borrow stablecoins against the BTC.** Not a hedge at all — it leaves the operator fully long
  BTC *and levered*. At Ledn-like terms (50% initial LTV, call at 70%, liquidation at 80%) a
  **28.6%** fall is a margin call and **37.5%** is liquidation, arriving while EUR liabilities
  are unchanged. Borrowing the full float would need twice the float in BTC, half of it the
  operator's own capital. Cost is 6–16% APR recurring against ~0.3–0.7% one-time for simply
  selling. Rejected outright.

Sat denomination needs none of them.

## Consequences

- **The customer bears bitcoin volatility on their prepaid balance.** Relative to their real
  alternative — holding the sats themselves — this is neutral, but it is a product property that
  must be stated in the terms and in the API documentation, not discovered.
- Residual operator exposure narrows to one bounded case: a running machine whose customer's
  balance has fallen below its reserve. That routes into the balance-exhaustion path
  (`ADR-0002`), and immediate provider cancellation bounds the gap to hours.
- The internal ledger unit is the integer satoshi, so balance comparisons stay integer
  arithmetic with no rounding policy.
- **`ADR-0004`'s prohibitions are what make this safe.** They are not separable from it.

## Recorded dissent

One of three independent analyses recommended a **EUR-denominated** balance instead, on the
ground that a balance denominated in BTC and held "for" the customer is the single clearest
MiCA custody trigger (Art. 3(1)(17), "safekeeping or controlling, **on behalf of clients**, of
crypto-assets") — ranking it above every refund variant on its severity scale.

We accepted sat denomination anyway, for two reasons. First, the exposures are not symmetric:
EUR denomination makes the operator **structurally insolvent on a −49% move that has already
happened in living memory**, whereas sat denomination makes a custody *characterisation*
arguable — and an arguable characterisation is answerable with drafting. Second, the unit of
account is not the asset: if title to the bitcoin passes on receipt and the customer's claim is
contractual — to compute, priced in satoshis — then no crypto-asset is held on anyone's behalf.
A gym membership priced in grams of gold is not gold custody.

That defence rests entirely on `ADR-0004`'s absolute no-refund rule, because refunding in BTC is
the natural refund form under sat denomination and would make the custody reading materially
stronger. **This is the first question to put to a lawyer**, and this dissent is recorded rather
than resolved.

---

¹ **Amended by `ADR-0011` (2026-08-12).** "At all times" has two bounded exceptions, recorded
rather than papered over: the persistence window (cancellation requires a deficiency to survive
more than one derivation, so a real crash gets a few extra hours of partially-covered burn on
machines already at the edge), and the scheduled-cancellation branch (`LDG-63`), where billing
cannot be stopped before its effective date and a commitment that available cannot top leaves the
gap with the operator, bounded per machine by `PRV-31`. Everywhere else the matching is delivered
by `ADR-0011`'s mechanism — usage debits at spot, a fixed commitment, and a runway date that
floats — not by re-sizing reservations after the fact. `F27` was the finding; this footnote is
its closure.
