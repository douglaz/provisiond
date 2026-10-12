STATUS: blocked

Selected and claimed `pv-ucs.5` (ADR-0036: Robot order budget), the first open ticket in the caller's prescribed sequence. It remains `in_progress`, awaiting the specification owner's clarification. The same-requirement gap is recorded in `br` comment 255; no new bead was created. No implementation brief is authorized yet, and this blocked pick does not authorize advancing to `pv-ucs.6`.

The missing decision is the new refusal's position in the purchase tail. That position changes the public HTTP response and pacing, so it is specification behavior rather than a gate-tooling or wording choice.

Relevant passages, read in the current checkout:

- `docs/adr/0036-the-robot-order-budget-is-closed-by-the-providers-throttle-and-not-shared-out.md`, Decision 1: “The refusal is `rate_limited` with `retry_after_ms`, and it joins `OPS-11`'s admission-only list.” Its Consequences calls for editing “`API-7`'s tail”. Neither passage places the new entry relative to the existing refusals.
- `docs/research/panels-2026-10/r21/synthesis.md`, Edits: “(`rate_limited` with `retry_after_ms`) on OPS-11's admission-only list and API-7's tail; alarm.” The synthesis also leaves that position unspecified. The ADR's provider-throttle choice supersedes the synthesis's split over counting; that settled choice is not being reopened.
- `04-api-contract.md`, `API-7`, Rich purchase tails: “`details.refusals` (`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension); `halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`); `insufficient_balance`.” Line breaks are normalized here.
- The same `API-7` passage: “Entry 0 is the headline: HTTP status, `kind`, `message` and per-kind details MUST match it”; “Pacing belongs to the headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and `WIR-4`”.
- `01-domain-model.md`, `DOM-17`, error table: `rate_limited` is “Caller or provider throttled” with HTTP `429`; the `halted` row carries HTTP `503` and “Refused while a solvency halt is in force or a rate is unavailable”.
- `docs/adr/0030-purchase-tails-report-all-applicable-refusals.md`: “The chosen order explains the resource before the pool, then pricing and spending”. This gives a rationale but does not explicitly classify or position the new order-budget refusal.

The distinguishing case is a create against a healthy provider account whose ordering channel is closed after Robot's throttle, while the solvency halt is also active. Assume the rate is available and the spending checks pass. The readings below are alternative extensions of the existing ordered list, not existing normative text:

| Reading | Collected refusals in this case | Observable headline |
|---|---|---|
| Put the new channel refusal after the account/resource refusal and before solvency | `rate_limited`, then `halted` / `solvency` | HTTP 429, with the ordering-channel delay |
| Preserve solvency precedence over the new refusal, inserting it later | `halted` / `solvency`, then `rate_limited` | HTTP 503, with solvency pacing |

Both readings collect the applicable refusals and preserve the existing entries' relative order. They disagree on what the caller receives. Updating `tools/formal/Provisiond/Admission.lean`'s `TailRefusal.rank` would encode that policy decision; it would not turn it into an implementation detail.

Owner clarification requested: **Where exactly does the order-budget `rate_limited` refusal belong in `API-7`'s ordered create tail?**

Recommendation, not adopted: put it immediately after the account/resource refusal and before solvency, treating the named ordering channel as a resource constraint under ADR-0030's rationale. Record the owner's chosen order in the amendment, then carry it through the Markdown, formal tail, per-refusal retryability and conformance cases, including simultaneous refusals with different pacing. Scope the admission-only addition to this pre-provider budget refusal; do not classify every provider-emitted `rate_limited` error as admission-only.

No adviser Consultation was run. The caller reserves an unanswered specification-behavior question to the owner, so adviser votes cannot settle this question. No advisers were listed as out of quota, none were skipped for quota, and none were called; there are no call durations or answers to record.

Repository guidance read: `AGENTS.md`, `README.md` including Requirement conventions, `docs/agents/`, and `CONTEXT.md`; neither `CLAUDE.md` nor `CONTRIBUTING.md` exists here. Reviewed the system orientation, current affected requirements, wire contract, conformance, formal admission model, epic and selected ticket. Read ADR-0036 before its cited panel synthesis. The current checkout includes amendments from earlier Runs even where their tickets remain open, so ticket status and historical line numbers were not treated as specification text.

On resumption, every Implementer and Reviewer must receive the caller's record-layer requirements: append-only identifiers; dated amendments naming the ADR; retained withdrawn wording only for traps and README registration for withdrawn identifiers; exact source words for claims about another requirement; and CNF coverage for each new MUST without raising the baseline. The selected ticket and ADR Consequences remain the scope source. Keep all other tickets out of this Run, and route further same-requirement gaps into this ticket's comments.

