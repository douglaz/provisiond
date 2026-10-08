# Panel brief: should `billing_stop_window` exist? (2026-10-06)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `e43f42c` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may write
scratch files, run the gates, and fetch public provider documentation. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question
and dissolves machinery rather than tuning it; check this framing too, and verify every fact I state
before relying on it.

## Settled today (do not re-litigate)

`ADR-0033` (first billing unit prepaid; the operator absorbs the final partial unit after it as an
accepted residual), `ADR-0034` (provider request budget with a system reserve), `ADR-0035` (a failure
after the provider accepted a mutation is ambiguous; drivers report `details.accepted`), `ADR-0036`
(Robot order budget). Background: `docs/research/panels-2026-10/r18/synthesis.md` — the first panel
found `STO-53`'s `billing_stop` sample conflates visibility with billing stop.

## The question

`PRV-13b` requires "the worst observed request-to-billing-stop latency over at least twenty real
deletions on that product, in seconds, declared in the descriptor's `billing_stop_window`", with a
conservative bound "marked as unmeasured" until then; "The effective value is `PRV-36`'s
`max(declared, max(observed))` over `STO-53`'s `billing_stop` samples." (`F18` gave the procedure.)

My argument that it should be withdrawn:
- The engine cannot observe a billing stop. `STO-53`'s `observed_at` is "when the engine first
  observed its effect" — absence or visibility — and `PRV-36` says "Visibility and billing-stop are
  separate measurements and MUST NOT be conflated". The only billing evidence is the invoice, weeks
  later, in whole units.
- For the immediate shape the set already says when billing stops: `PRV-13`'s table, "Immediate
  destroy | Resource gone, billing stops". Providers: Hetzner Cloud "We will bill you for your servers
  until you delete them"; DigitalOcean "Billing begins when you create the Droplet and ends when you
  destroy it"; Robot `cancellation_date=now` cancels immediately (quotes in
  `docs/research/provider-verify-2026-10.md` §3).
- What remains after acceptance is the started unit's remainder, which `ADR-0033` owns as a residual.
  A twenty-sample maximum would measure Hetzner's rounding phase, not a latency.

## Options put to the owner

- **(a) Withdraw** `billing_stop_window`, `STO-53`'s `billing_stop` kind and `F18`'s twenty-deletion
  procedure (with a dated trap record). For the immediate shape billing stops when the provider
  accepts the delete — a declared shape (`PRV-13`) the engine observes through `ADR-0035`'s
  `accepted`. `wind_down_cost`'s "measured confirmed-cancellation latency" becomes the engine-observed
  dispatch→accepted latency. `PRV-29`'s "billing stopped" is evidenced by the declared shape at
  acceptance and audited by `LDG-75`'s invoice true-up.
- **(b) Redefine** it as dispatch → gone observation (what `STO-53` actually samples) — `PRV-36`'s
  visibility window under a second name.
- **(c) Keep** it, measured from invoices.

My recommendation: (a).

## What I want from you

1. **Who reads it?** Trace every reader of `billing_stop_window`, its effective value and `STO-53`'s
   `billing_stop` samples (`PRV-13b`, `PRV-29`, `wind_down_cost` at `02-provider-contract.md:217-275`,
   `PRV-44`, `CNF` items, `08-provider-notes.md`, Lean). Does anything size money from it? What breaks
   if it goes?
2. **Is billing really stopped at acceptance for each launch product?** Check the providers' own
   words for Hetzner Cloud (async `DELETE /servers` returning an action — does billing stop at the
   request, the action's success, or the server's disappearance?), Robot (`cancellation_date=now`,
   and the add-ons and IPs that "may need to be cancelled separately"), DigitalOcean. Is there any
   documented post-acceptance billing that is not the started-unit remainder? Attachments that
   survive (`PRV-13a`) are a separate billing stop — does (a) leave them covered?
3. **What does `wind_down_cost` actually need?** With (a), is "dispatch→accepted latency" the right
   term, and is it measured or declared? Does `PRV-29`'s evidence-freshness rule or `OPS-27` need
   anything a billing-stop window supplied? Does the scheduled-cancellation shape (`PRV-13c`,
   `DOM-19`) depend on it?
4. **Where is (a) wrong?** Does it reintroduce something the set withdrew (search the README's
   withdrawn table and dated trap records about billing stop, `F18`, `ADR-0018`)? Does it contradict
   `ADR-0018` ("the descriptor is typed and the window is a max")? Is "billing stops at acceptance" an
   assumption the set's rule against encoding commercial terms as constants (`PRV-13c`) forbids?
5. **A third shape?** Including deleting more than I proposed (e.g. `PRV-29`'s third fact).
6. **Formal layer:** any declaration that encodes the billing-stop window or `STO-53` kinds.

## Output

At most 900 words, no preamble: verdict (a), (b), (c) or a named other in one line; why in one
paragraph; every defect in my framing with `file:line` or source URL; the requirement ids,
conformance items and declarations the chosen answer edits.
