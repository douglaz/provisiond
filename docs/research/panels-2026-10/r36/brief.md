# Panel brief: pv-ucs.2's three owner questions on the provider request budget (ADR-0034), 2026-10-10

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `16f9db8` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files inside this clone and run the gates
(`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and
dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

`ADR-0034` (read it whole, with its 2026-10-08 amendment): tenant traffic cannot spend the provider
request budget the system needs. Hetzner Cloud allows 3600 requests/hour per project, refilling one per
second. Decision 3: each driver declares the limit (`PRV-44` `request_budget`); a stated share is
reserved for funding cancellations and other system-detected episodes (`OPS-39`), automatic resolution
(`OPS-27`) and the account sweep (`OPS-32`); a new tenant-initiated operation is refused before its
first provider call once only the reserve remains; "Admission is decided once per operation, before its
first provider call. A later request of an admitted operation is never refused locally, or the budget
would recreate the throttled poll after an accepted order that the same panel found."

The unaccepted implementation is in history (`bd737c9`): `PRV-46` in `02-provider-contract.md`,
`tools/formal/Provisiond/ProviderTraffic.lean`, witnesses `smallBudget`/`continuedOperation` in
`Witnesses.lean`, CNF-331..339. An rloop Manager blocked it; its report is
`docs/research/panels-2026-10/r36/manager-blocker.md` (read it). Settled elsewhere: v1 sells only Robot
unlimited-traffic offers (`ADR-0039`); Robot's own limits are per endpoint, and its order capacity is
`PRV-40`'s, not this budget.

## The three questions

**Q19a — continuations versus the reserve.** A tenant create is admitted with tenant capacity left. Other
tenants then spend the tenant share. The create's next request (a poll after the order was sent) finds
only the reserve. "Never refused locally" and "The named system paths MUST retain access to that reserve"
now conflict; the witness dispatches three tenant requests at limit 2, reserve 1. Candidate answers:
(1) the continuation waits for tenant capacity (refill), never fails locally — then what about the
operation's deadlines (`OPS-33`'s create window, `PRV-36`'s visibility window, `OVR-19`)?; (2) capacity
for the whole operation is secured at admission — needs a per-operation request bound, and polling has
none I know of; (3) continuations may spend the reserve, and the reserve guards only against new
admissions — state the residual and its bound. Which, and why? Is there a smaller shape (for example: is
a locally counted budget even the right model for a bucket that refills every second and that requests
outside provisiond also spend; what does the reserve buy over the provider simply throttling)?

**Q19b — operator-origin traffic.** `WIR-10a`'s `requested_by` is `{caller, system, operator}`. `API-64`'s
episode retry is stamped "`requested_by: operator`, with its non-null `episode_id`"; `API-65`'s release
enqueues "with `requested_by: operator`" outside any episode. `PRV-46` refuses "tenant-initiated"
operations and reserves capacity for named system paths; the formal `Origin` has no operator case. Is
eligibility by initiating actor or by path (exposure-reducing/evidence)? Which operator operations may
spend the reserve, and may an operator operation ever be refused by this budget?

**Q19c — the refusal surface.** A new tenant operation refused at reserve-only: a synchronous HTTP `429`
before any operation exists (`API-50`: "Every `429` anywhere MUST itself carry `Retry-After`"), or a `202`
then an operation that fails `rate_limited` before dispatch (`WIR-9a`'s `retry_after_ms`, `WIR-10b`)? Note
the Q10 amendment moved the refresh cache check to when a worker CLAIMS the refresh, not at enqueue —
does budget admission belong at claim time too, and what does that imply for the surface?

For each: the answer, the strongest "don't build this", and what the Lean model and CNF items must then
show (the Manager asks for tenant admission, continuation depletion, then system work, in one sequence).

## Output

At most 900 words, no preamble: for Q19a, Q19b, Q19c a one-line verdict, then why, every defect with
`file:line`, and the edits.
