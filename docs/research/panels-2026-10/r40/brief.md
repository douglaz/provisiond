# Panel brief: what a Robot `now` delete settles as, and Robot's date zone (Q22), 2026-10-11

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `dec039f`. Read `AGENTS.md` first. Do not edit
tracked files; write scratch files only inside this clone (never `/tmp`); you may run the gates
(`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

Read `docs/research/panels-2026-10/r39/synthesis.md`, the live result
`docs/research/panels-2026-10/r39/live-result.txt`, and the owner's decision
`docs/research/panels-2026-10/r40/q21.txt`. On a real Robot account, `POST /server/3084954/cancellation`
with `cancellation_date=now` answered `200` with `"cancelled": true, "cancellation_date": "2026-10-11"`;
`GET /server/3084954` answered `404` one second later, and stayed `404`. Robot stamps local time: a key
uploaded at 03:47:37Z reads `created_at "2026-10-11 05:47:37"`. Settled: ADR-0037 with its 2026-10-10
amendment (Q18a: "A provider date given as a calendar day only names the end of that day, UTC. Robot's
`cancellation_date` (`yyyy-MM-dd`) is one. A `now` release or cancellation never reads as a start-of-day
instant."); `LDG-38`'s stop boundary for a scheduled machine is "the earlier of its
`effective_cancellation_date` and any gone observation"; Q20: the refresh window is no shorter than the
sweep interval and a complete sweep records every machine present.

## The question (panel r39 split 2–2)

- **Scheduled (fable, opus):** the driver surfaces the day (`PRV-13`: "MUST surface the effective
  cancellation date"); end of that day; `cancellation_scheduled` (`DOM-19`, `OPS-48`'s scheduled row);
  the sweep's gone-write closes it; `LDG-38`'s earlier-of stops the customer's meter at the sweep's
  observation. "Robot `now` is immediate" as a rule breaks `PRV-13c`'s per-contract facts; a read inside
  `PRV-36`'s (unmeasured) window is not evidence.
- **Gone when seen gone (astra, sol):** a day-only date does not prove a live scheduled machine; once the
  delete's direct read answers `404`, take `OPS-48`'s gone row and stop at that observation; a still-present
  server takes the dated scheduled path; a failed read stays `needs_reconciliation`.

I lean "gone when seen gone" because it hard-codes nothing (it follows the observation), bills to the
disappearance, and lets `PRV-45`'s listing run on Robot deletes. Check that against `OPS-11`'s goal-state
rules, `PRV-29`, `PRV-36`'s window semantics (is a `404` after a delete "contrary" or "goal" evidence; is
one read enough, or does `OPS-32`'s absence rule demand more), `OPS-48`, `DOM-19`, `PRV-13`/`PRV-13c`,
and `LDG-38`/`LDG-74`.

## Questions

1. Which reading, and why? What does each cost the customer and the operator (Robot bills the server
   hourly, per `08`), and which requirements change?
2. Is one direct `404` read right after the cancel enough to record gone, given `PRV-36` and `OPS-32`'s
   "A missing machine MUST be re-read directly"? If not, the smallest evidence rule.
3. **The zone.** Robot's day is local (CEST/CET), not UTC. What should Q18a's rule say: the end of that day
   in the provider's zone (declared per driver, e.g. `Europe/Berlin`), or something else? Does it matter
   for v1 once (1) is decided (immediate cancels; catalogue servers whose `earliest_cancellation_date` is
   later)? Where does the rule live (it sits in `PRV-45` and `WIR-35`; opus found no machine owner)?
4. The strongest "don't build", the exact edits, and what CNF/Lean must show.

## Output

At most 800 words, no preamble: a one-line verdict per question; why; every defect with `file:line`; the
edits.
