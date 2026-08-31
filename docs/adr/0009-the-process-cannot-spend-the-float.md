# The process cannot spend the float

## Context

`ADR-0008` gave every deposit an on-chain destination, which means the deployment derives
addresses, which means it holds key material. That turns `F13` from a structural worry into a
specific key on a specific disk.

`F13` has been open since the first audit and got worse, not better, with every decision since:
`ADR-0001` put customer-facing code and provider credentials in one process, and `ADR-0002` added
the ledger to the same one. The finding's own words are that one compromise takes the machines
*and* the float. This ADR is the first requirement that makes the second half untrue.

The relevant asymmetry is that **this business may never need to spend on-chain**. The operator
owes customers compute, not bitcoin; `ADR-0004` forbids paying anyone out; provider invoices are
settled with the operator's ordinary business money. An exchange cannot go cold because it must
process withdrawals. This design has no withdrawals by construction, so the usual reason to keep a
hot wallet does not apply to it.

## Decision

**The process holds watch-only key material for the on-chain float and nothing more.** It derives
addresses and observes payments; it cannot construct a spend. The key that can move on-chain funds
lives outside the deployment and is used by a human.

**Lightning is hot, because channels leave no alternative**, so it is bounded instead: the
deployment states a ceiling on satoshis held in channels and sweeps the excess to a cold
destination that is compiled in, not configured at runtime.

A remote compromise therefore costs the machines and whatever is under the ceiling. That is a bad
day with a stated size, rather than every satoshi any customer ever deposited.

**AMENDED 2026-08-31 — the number was understated, and "watch-only" was doing work it cannot do.**
Two corrections, both from research against current tooling:

- **The ceiling covers the channel balance *plus* the node's own on-chain wallet** (`SEC-49`).
  Opening and closing channels are on-chain spends, so the node holds a spending key for a wallet of
  its own and a closed channel's balance lands there. Counting only the channels understated the
  radius this decision is sold on.
- **A node's watch-only-plus-remote-signer mode does not make the receiving host unable to spend.**
  The signer signs what the watch-only node asks it to, so the key material is off the box and the
  spend authority is not. What is achievable, and what `SEC-48` now requires, is the boundary that
  actually matters here: the process holding provider credentials reaches Lightning only through a
  credential scoped to creating and observing invoices, on a separate host. Receiving Lightning is
  inseparable from being able to spend it — there is no Lightning analogue of an extended public
  key — so the Lightning host's exposure is bounded rather than removed, and the sweep that bounds
  it is a manual operator action.

## Considered options

**One hot key for everything** was rejected. It automates channel refilling and removes an
operator step, at the price of making a single RCE on a box that already holds root on every
customer machine also final and total for the money. There is no insurance, no chargeback and no
reversal behind it.

**A hot key restricted to the operator's own channels** was rejected for a subtler reason: the
restriction would live inside the process the attacker has already taken. Making it real requires
an external signer enforcing the destination — which is most of the work of cold storage, for less
of the benefit.

**A third-party custodian for both rails** was rejected as self-defeating. It hands one company
the entire float and a complete record of every customer payment, contradicting `ADR-0005`
outright, and it recreates precisely the custodial relationship `ADR-0004` is built to avoid, with
the operator now on the wrong side of it.

## Consequences

- **Refilling channels is a manual action and MUST stay one** (`SEC-51`). Anything that automates
  it is a path from the process to the cold key.
- **Running out of inbound capacity is not an outage**, and this is the decision's luckiest
  interaction. Because `ADR-0008` gives every deposit both destinations, a customer who cannot be
  paid over Lightning simply pays the address. What would otherwise be "funding is down until the
  operator wakes up" degrades to "funding is slower."
- **Solvency verification needs no spending key** (`LDG-53`). Checking that satoshis held cover
  the float is a read, so the invariant that matters most is fully computable watch-only.
- **The watch-only key is not a secret but leaking it is still a breach** (`SEC-52`). An extended
  public key reveals every address ever derived from it, so it exposes the operator's entire
  deposit history with every customer's payments linked — which is the outcome `ADR-0005` exists
  to prevent, reached without any credential being stolen.
- **Losing the cold key destroys the float with no recovery** (`SEC-53`). This ADR moves risk from
  *compromise* to *custody*, and the second one is not smaller by default — it is only smaller if
  the backup procedure exists and has been tested before the first customer pays.
