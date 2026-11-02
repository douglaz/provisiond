01-domain-model.md
**DOM-20** Five rows in the table above were added after the original taxonomy was written:
`insufficient_balance`, `not_activated` and `halted` by this requirement, `gone` by `DOM-21`, and
`suspended` by `API-58`. `DOM-17`'s set is closed and `API-24`
forbids a handler choosing a status independently, so before the first three existed **four
conformance items asserted a rejection this taxonomy could not express** — `CNF-95` (insufficient
balance), `CNF-78` (tenant still pending), `CNF-69` (ceiling), `CNF-101` (solvency halt) — and
every one of them would have arrived at the caller as `invalid_request` / 400.

That distinction matters more here than in an ordinary API. The caller is an autonomous agent,
and **"top up" and "fix your request" are different actions.** Collapsing them means a correctly
formed create that merely needs money is indistinguishable from a malformed one, so the agent's
only recovery is to mutate its request and retry — which is how a retry loop becomes a duplicate
purchase.

**AMENDED 2026-09-02 — a sixth row, `ceiling_exceeded`, because the taxonomy was extended for three
of those four items and not for the fourth.** `SEC-39` requires server-side ceilings per principal —
machines destroyed, machines created, images
written, rescue entries, power cycles, spend, and for an operator principal retries (`API-64`), resolutions,
suspensions and re-assignments — and **this taxonomy had nothing that could express refusing one**,
while `API-24` forbids a handler choosing a status independently. `CNF-69` is the ceiling item named
in the list above; it has stood throughout, against a set of kinds that could not carry its
rejection.

**It is not `rate_limited`, and the difference is exactly the argument this requirement already
makes.** Both say "not now", and an agent's response to each is genuinely different: a rate limit is
about *capacity* and its delay follows the source of the throttle, including a provider-shared
ordering channel whose interval the deployment does not control (`PRV-40`); a ceiling is about
*authority* over a stated interval — an hour by default — and
clears only when the interval rolls, however gently the caller asks. Collapsing them means an agent
that has hit its destruction ceiling retries a delete every few seconds for an hour, and an operator
reading `429` cannot tell a busy server from a principal that has spent its budget. "Wait a moment"
and "you are out of allowance" are different actions in the same way "top up" and "fix your request"
are. The HTTP status is shared with `rate_limited` because 429 is what both mean to an
intermediary; the **kind** is what the agent branches on, which is the whole point of `DOM-17`
carrying one.

*Amended 2026-10-09 (`ADR-0036`): the capacity delay may come from the
provider-shared channel and is not necessarily controlled by the deployment.*

**ADDED 2026-09-12 — a seventh row, `overloaded`, and it is not `rate_limited` either.** `STO-55`
makes the connection pool the bound on `api` concurrency and refuses a request that obtains no
connection within the checkout bound. That refusal is about the *replica's* capacity, not the
caller's rate. `API-50` says "Every `429` MUST identify an exhausted principal allowance as `ceiling_exceeded`", and `503` was
chosen over that because an intermediary reads `429` as the caller's doing and `503` as the
server's, which is what this is; and it is not `halted`, which `WIR-9a` reserves for the solvency
and rate gates. It is admission-only (`OPS-11`): nothing was written and the refusal leaves no
`STO-35` receipt, so a re-send is judged against whatever an earlier send left.

