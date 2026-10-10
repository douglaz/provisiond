# Panel brief: two owner questions blocking pv-ucs.6 after Q14 (2026-10-10)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `33bb62f` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question and
dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Settled (do not re-litigate)

`ADR-0037` (read it whole, including both amendments of 2026-10-09: Q13 wind-down composition, Q14 a
scheduled attachment release — the effective date stops the customer's meter; `released_at` stays
evidence of absence, written by `OPS-32`'s automatic sweep). Panel record:
`docs/research/panels-2026-10/r29/synthesis.md`. The unaccepted implementation of pv-ucs.6 is in this
clone's history (`fbe613a`, `f86de91`).

## The blocker

Read `docs/research/panels-2026-10/r34/manager-blocker.md` (the Manager's own words; its two owner
questions first, then repairs that are NOT owner questions).

**Q18a — an effective date learned behind the meter's mark.** Trace: an attachment is metered at 1
sat/s and has been charged through t=20 (mark 20). An `applied` resolution then supplies effective date
t=10. `LDG-38`: "an increment whose end instant is at or before that mark MUST be discarded"; future ticks
clipped to 10 post nothing; the 10 sats charged for [10,20) remain. ADR-0037's Q14 amendment: "The
customer owes the attachment's rate through the effective date." `LDG-5`: "The ledger MUST be
append-only... A correction is a new entry naming the entry it corrects."
Options: (a) an automatic, idempotent corrective credit naming the affected usage entries (no edit, no
mark rewind) — the Manager's and my recommendation; (b) the operator corrects by hand with existing
machinery; (c) the posted debits stand (accepted overcharge).

**Q18b — admission for an attachment kind with no declared effective-date bound.** ADR-0037's Q14
amendment: "A month-end date learned after ordering needs a bound declared per attachment kind at create,
as `PRV-31` declares one for machines, or the shortfall meets `LDG-31`'s clamp." The implementation's new
`PRV-45` sentence instead says that without a declared bound "the offer MUST NOT be sold on prepaid terms"
(as `PRV-31` does for machines). Which: refuse sale, or sell and let the shortfall clamp (operator-borne)?
Note v1 sells only Robot unlimited-traffic dedicated servers (ADR-0039) and orders no extra IPs.

## What I want from you

1. Q18a: is the overcharge reachable in v1 (which drivers return an effective date for an attachment
   release; does Robot's IP cancellation do so; does any v1 offer carry such attachments)? Who would post
   (a)'s credit, in which transaction, under which serialization (`LDG-35`), with which key (`LDG-8`),
   in which billing period (`LDG-68`'s correction rule)? Does a commitment that already closed (`LDG-32`)
   change the answer — credit to available balance? Is (a) the existing `LDG-62`/`LDG-5` correction path
   or new machinery? Strongest "don't build".
2. Q18b: which reading does ADR-0037's sentence carry ("or the shortfall meets the clamp" reads as an
   accepted consequence, not a refusal)? Which is safer for the operator, given LDG-31's clamp makes the
   operator absorb it? Given v1's scope, is either needed now?
3. Is either question dissolved by scope: if no v1 offer has a scheduled-release attachment, should the
   spec say so and defer both?
4. Edits and formal impact.

## Output

At most 900 words, no preamble: a verdict line per question; why; every defect in my framing with
`file:line`; the edits.
