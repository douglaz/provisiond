# The commitment is fixed; the runway floats

## Context

`F27` was the audit's arithmetic objection to `ADR-0003`: that ADR sells the satoshi denomination
on "matched at all times," while `PRV-13e` deliberately throttled how fast a commitment could
grow after a price move — so on the −49% night the ADR itself cites, the fleet would be
under-reserved for at least two derivation periods. The apparent question was how fast
commitments should widen, and three rounds of design went into widening speed: symmetric caps,
asymmetric grow-fast-shrink-slow, race scenarios where a customer's agent reallocates available
balance before the operator reacts.

**The interviewee dismantled the framing with one observation: every authorization is priced at
the current rate, so nothing can be overcommitted at stale prices.** Following that through the
ledger dissolved the problem. Usage is debited at spot each period, so after a crash a machine's
fixed satoshi commitment simply drains faster — the runway date moves earlier. The crash is
absorbed by the customer's purchasing power, which is precisely the deal a sats-denominated
balance is. The operator stays whole without widening anything, provided one invariant holds:
**cancel while the remaining commitment still covers wind-down at the current rate.** Automatic
widening was solving the operator's anxiety with the customer's money.

## Decision

**A commitment is sized once, at open, and is never re-sized upward by a rate move alone** —
which is the decision — with one exception the requirements name. Three paths grow it: a caller's
`extend-runway` (`LDG-62`) and an operator requeue of a create, which reprices at the current rate
rather than reusing a stale size (`OPS-20`), both **deliberate acts**; and the scheduled-cancellation
branch, where billing runs to an effective date the operator cannot exit and `LDG-63` tops it from
available or records the shortfall as the operator's. That branch is **the one automatic
exception** — `LDG-33`'s words, kept verbatim so the two cannot drift apart again. It runs off
periodic re-derivation with no caller and no operator, and it is admissible because it is bounded:
the end date it funds to is already fixed.

*The original said "without a caller action", which was true when written and became too narrow as
the operator surface grew — an operator requeue grows a commitment too. What this ADR abolished is
the **unbounded** case: a rate move reaching into a customer's available balance with nobody
deciding and no fixed end to what it can take. `LDG-63`'s branch is the bounded one, and it is
named here rather than denied.*

It decays as usage is debited (`LDG-31`). Outside that one branch re-derivation does not resize it
— re-derivation recomputes `runway_until` from the fixed remaining commitment at the current rate,
in both directions. The customer's runway date floats with the price; the caller can read it at any time
(`LDG-15`) and extend it with an explicit, separately-authorized action if it wants more.

The exhaustion trigger becomes the invariant that actually protects the operator: a machine is
routed into the exhaustion path when its remaining commitment no longer covers wind-down (plus
any cost-through-effective-date, on the scheduled-cancellation branch) **at the current rate** —
with cancellation still gated on the deficiency persisting across derivations, so a single bad
rate reading can move a date but can never destroy a disk.

## Consequences

- **The freeze attack disappears structurally.** Three questions were spent on how a manipulated
  rate could grab customers' available balances via forced widening. Nothing widens
  automatically, so there is nothing to trigger. A manipulated rate can shorten a runway *date*,
  which persistence and the median-of-sources rule (`LDG-58`–`LDG-60`) already guard.
- **`ADR-0003`'s "matched at all times" is amended to name its real exceptions**, all
  bounded and priceable: the persistence window (a real crash gets a few extra hours of
  partially-covered burn on machines already at the edge — hours, because `PRV-13e` re-derives on
  its own stated interval rather than per billing period), the scheduled-cancellation branch,
  where billing cannot be stopped before the effective date and a commitment that cannot be
  topped from available leaves the gap with the operator — bounded per machine by `PRV-31`'s
  declared worst case — **and every other cause `LDG-66` enumerates**, since an operator deficiency
  *is* a gap the operator absorbs rather than one the arithmetic closes. *Amended 2026-09-02: this
  bullet said "two exceptions" and `LDG-66` counted six, having grown twice since. The requirement
  is the list; this ADR cites it, which is the only arrangement that cannot drift again.*
- **The runway guarantee changes meaning, and the terms must say so.** "Guaranteed until
  `runway_until`" is now a promise whose date moves with the price of bitcoin. That is not a
  weakening slipped in — it is the honest reading of a satoshi-denominated prepayment, and hiding
  it behind an auto-widening mechanism would have made the balance *feel* fiat-stable while
  silently confiscating the customer's spare balance to fake it.

## Rejected

**Asymmetric auto-widening** (grow instantly on drops, shrink slowly on rises) — the recommended
option for two full rounds. Preserves the runway date, at the cost of customers' spare balance
being grabbable by one price reading, which is an attack surface with the whole fleet behind it.

**Symmetric gentle widening with the gap priced** — the status quo ante. Keeps both the lag *and*
the freeze surface; the costs of each design and the clarity of neither.
