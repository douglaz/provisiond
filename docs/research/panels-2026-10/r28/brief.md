# Panel brief: placing two new create refusals in the purchase tail (2026-10-08)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `023ed3f` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown
with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state before relying on it.

## Settled (do not re-litigate)

- `ADR-0030` (purchase tails report all applicable refusals), `ADR-0036` (Robot order budget closed by
  the provider's throttle; the local refusal is `rate_limited` with `retry_after_ms` on `OPS-11`'s
  admission-only list), `ADR-0039` (an offer with a traffic allowance is not sold on prepaid terms; the
  purchase tail refuses an unsellable offer). Read all three.

## The gap (rloop Managers blocked two tickets on it)

Read `docs/research/panels-2026-10/r28/manager-blocker-pv-ucs8.md` and `manager-blocker-pv-ucs5.md` (the
Managers' own words). `API-7`'s "Rich purchase tails" orders `details.refusals`: "the request's own
resource refusal (`conflict`/`state` for create against a provider account not `healthy`, or
`conflict`/`cancellation_committed` for extension); `halted`/`solvency`; `halted`/`rate_unavailable`; the
commitment-cap refusal (`WIR-17`, `WIR-24`); `insufficient_balance`". "Entry 0 is the headline: HTTP
status, `kind`, `message` and per-kind details MUST match it." "The cap and balance checks MUST NOT run
without a rate, nor for create against an unhealthy account". `WIR-9a`'s `not_checked` reasons are
closed: "`because` is exactly `rate_unavailable` or `provider_account_not_healthy` (create only)".
`Provisiond.Admission` models `purchaseTail`, `tailAdmitted` and refusal ranks.

Two new create refusals need a position: (A) the offer is not sellable (ADR-0039); (B) the Robot order
budget is closed by the provider's throttle (ADR-0036).

## My recommendation (the owner asked for this panel before deciding)

Both join the first group (the request's own resource refusal), ordered: account not healthy, offer not
sellable, order budget closed. Where the offer is not sellable, the commitment-cap and balance checks are
skipped and recorded as `not_checked` with a new reason `offer_not_sellable` (amending `WIR-9a`'s closed
set).

## What I want from you

1. Is the ordering a real behaviour question? What does the headline change (HTTP status, `kind`,
   `retry_after_ms`, a caller's pacing under `API-50`/`WIR-9a`)? Which headline helps an agent act: a
   permanent "can't buy this offer" or a transient "try later"?
2. Where is my recommendation wrong? Concrete cases: unhealthy account + unsellable offer; unsellable
   offer + closed budget; healthy, sellable, closed budget + insufficient balance; unsellable offer +
   no rate; a standard (non-auction) offer when only the auction endpoint is throttled. Does skipping
   the price checks for an unsellable offer hide information an agent needs, or report noise?
3. Is a new `not_checked` reason needed, or does an existing rule already skip those checks? Is an
   unsellable offer filtered out of `WIR-30`'s listing so a create naming it is already an error of a
   different kind (`not_found`? `invalid_request`?) rather than a tail refusal at all?
4. Is (B) a tail refusal at all, or an admission-stage refusal before the tail (like `ceiling_exceeded`)?
   Compare where `SEC-39` ceilings and `API-41` shedding sit relative to the tail.
5. A smaller shape; the strongest "don't build this".
6. Formal layer: what `Provisiond.Admission` declarations change under the chosen shape.

## Output

At most 900 words, no preamble: verdict (accept / amend / a named other) in one line; why in one
paragraph; the case table from item 2; every defect in my framing with `file:line`; the requirement ids,
CNF items and declarations the chosen answer edits.
