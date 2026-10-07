# Panel brief: who pays the rest of a provider's started billing unit? (2026-10-06)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `40c00cb` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may
write scratch files and run arithmetic (python3 is available) to test a claim. Search the Markdown
with whitespace normalised. This owner has repeatedly shown my framing wrong with a
first-principles question and dissolves machinery rather than tuning it; check this framing too,
and verify every fact I state below against the files before relying on it.

## Background you should read

- `docs/research/provider-verify-2026-10.md` §3 ("`PRV-13b` — when billing stops after deletion").
  Its quotes are verbatim from provider documentation retrieved 2026-10-06; its *conclusions* are a
  previous session's summary and are not evidence.
- `PRV-13b`, `PRV-13a`, `PRV-13c`, `PRV-29`, `PRV-44` (`02-provider-contract.md`); `LDG-37`,
  `LDG-38`, `LDG-72`, `LDG-74`, `LDG-28` (`12-billing-and-ledger.md`); `ADR-0006`, `ADR-0007`,
  `ADR-0018`, `ADR-0029` (Consequences); `F18` (`11-open-findings.md`); bead `pv-vwe.34` (closed:
  every exit from billable closes the increment in the exit write).

## The story

At 12:00 an agent buys a Hetzner Cloud machine; at 12:10 it deletes it.

- Hetzner bills the operator a whole hour. Billing FAQ: "We always round up the hourly usage of a
  server. If you create a server just for a few minutes, we will still bill you for one whole hour."
  Robot ("Billing system at Hetzner"): "We round up partial hours. The total cost is never more than
  the monthly price", and add-ons are billed "per day or part thereof". DigitalOcean bills per
  second with a 60-second / $0.01 minimum.
- provisiond's meter charges the agent ten minutes: `LDG-38`'s
  `exact_i = net_seconds_i × customer_rate_i`, cadence-independent by design.
- The operator pays fifty minutes nobody is charged for. `ADR-0007` names exactly this bursty,
  unattended pattern as the target market, so the loss sits on the core use case, and a
  create/delete loop multiplies it.

Things I found that bear on it, which you should check rather than trust:
- `PRV-13c` already lists "billing granularity" as a per-contract fact that MUST NOT be a constant.
- `ADR-0029`'s Consequences already accept "one more period" at a provider with a billing
  granularity, for a cancellation an outage delayed.
- `PRV-13b`'s `billing_stop_window` is a request-to-billing-stop latency in seconds, measured as the
  worst of ≥20 real deletions (`F18`). The research note says that measurement "cannot reveal" the
  rounding. My own reading: it would see it, as noise between zero and one unit depending on where in
  the unit each delete fell, so its maximum understates a value the provider documents exactly.
- `LDG-37` says the source of truth for elapsed billable time is the machine record's transitions
  "or the provider's usage API where one exists. Where the two disagree the provider wins, because
  the provider is what invoices the operator." `LDG-37`'s "partial period, rounded per `LDG-28`" is,
  as far as I can tell, satoshi rounding direction, not a provider unit.

## The question put to the owner

Who pays the remainder of the provider's started billing unit after a machine leaves billable?

- **A. The operator absorbs it.** Exact per-second billing stays; up to one unit per machine is a
  cost of business. Nothing in the meter changes.
- **B. The customer pays it as machine time, with margin.** Every exit from billable closes the last
  increment at the end of the provider's started unit, declared per product in the descriptor (hour
  for a Hetzner Cloud or Robot server, day for a Robot add-on, second for DigitalOcean). The reserve
  must hold one unit so exhaustion can pay it; `billing_stop_window` reverts to a pure latency.
- **C. As B, but the remainder is charged at cost** (no margin), like `ADR-0006`'s setup fee.

**My recommendation was B**, because `ADR-0007` says "Customer price is the provider's price plus a
configured percentage" and for a ten-minute machine the provider's price *is* one hour; per-second
exactness is a promise the provider does not keep, so under A the operator funds it from margin.

## What I want from you

1. Is the story true in this set? When does billable end relative to the delete (dispatch, gone
   write, provider billing stop)? Does anything already compensate the operator (margin,
   `wind_down_cost`, an `LDG-66` deficiency, `LDG-37`'s provider-wins rule)? Cite lines.
2. Where is B actively wrong? In particular: the provider's unit grid. Is Hetzner's hour anchored to
   the server's creation, to wall-clock hours, or computed as `ceil` of aggregated usage per invoice
   month? If the grid is unknown or aggregated, what does B charge, and does B then bill the customer
   for rounding the provider never applied? Month boundaries (`LDG-68`), the monthly cap, a machine
   that crosses `stopped`/`cancellation_scheduled`, a provider-terminated machine (`LDG-74`), a
   quarantined exit, an exit during a rate outage (`ADR-0029`, `LDG-64`), attachments.
3. Is there a third shape that is smaller or more honest? Candidates I have not evaluated: a minimum
   charge of one unit per billable span (DigitalOcean-style) instead of a remainder at every exit;
   charging the first unit at billable entry; declaring the unit only so the operator can set the
   margin to cover it (A plus a disclosed number); using `LDG-37`'s provider-wins source.
4. Argue the strongest version of A ("don't build this"). Quantify it: with a plausible margin, for
   what machine lifetimes does the operator lose money under A, and how big is the worst case per
   tenant given whatever rate limits on creates exist (search the set for them)?
5. Whatever the answer, what does `PRV-13b` / `F18` need? Does the reserve need a unit term under A
   as well as under B? Does `PRV-13c` permit a declared unit in the descriptor?
6. Does anything here contradict a decided ADR or a Lean theorem (`tools/formal/`, `Period`,
   `Meter`)? Name the declaration.

## Output

At most 900 words: your verdict (A, B, C or a named other) in one line; why, in one paragraph;
every defect in my framing above with `file:line`; and the requirement ids the chosen answer would
have to edit. No preamble.
