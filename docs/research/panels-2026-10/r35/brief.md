# Panel brief: review the proposed fix for Q18b (an attachment kind with no declared bound), 2026-10-10

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `8c3087e` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question and
dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

The previous round's synthesis is `docs/research/panels-2026-10/r34/synthesis.md` (read it). The owner
has since decided Q18a (`docs/research/panels-2026-10/r35/q18a.txt`): day-only provider dates mean the END of
that day UTC; an overcharge behind the mark is stated as unreachable in v1 with the conditions that would
make it reachable (attachments gaining their own customer price; offers whose cancellation can be
scheduled for a future date); an automatic credit is a precondition of enabling either; no manual
operator step. Settled: ADR-0037 with both 2026-10-09 amendments; ADR-0039 (v1 sells only Robot
unlimited-traffic offers).

## The proposed fix under review (Q18b)

The implementation (`f86de91`, live in HEAD) added to `PRV-45`: "For each billable attachment kind that can
return an effective date after create, a driver MUST declare a worst-case effective-date bound before
create in `PRV-44`'s descriptor; without it, the offer MUST NOT be sold on prepaid terms." r34 found this
duplicates `LDG-32` ("It MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless
the operator has explicitly accepted and capped that exposure") and, keyed on kinds, would stop all v1
sales (Robot declares additional IP and subnet `api` survivors for every descriptor).

Proposed: (1) `PRV-45`'s sentence becomes a pointer to `LDG-32`; (2) scoped to attachment kinds the
ORDER creates (not every kind the driver describes); (3) a kind whose release is immediate declares a
zero bound ("A field with nothing to declare says so explicitly"); (4) refusal uses `API-7`'s existing
`invalid_request`/`offer_not_sellable`; (5) ADR-0037's "or the shortfall meets `LDG-31`'s clamp" is
recorded as `LDG-32`'s operator carve-out (accept and cap), not a refusal.

## What I want from you

1. Does the fix actually leave v1 sellable? Trace a Robot auction order with and without the
   `primary_ipv4` add-on (`RSC-45`): which attachments does the order create, are they `billable`, what
   bound do they need, and does any of it reach `offer_not_sellable`?
2. Is "attachment kinds the order creates" well-defined before create (the descriptor is per offer; the
   survivors list is discovered at deletion by `PRV-45`'s listing)? Does it leave a hole: an attachment the
   tenant adds later, or one the provider attaches unasked, that then survives with a scheduled date?
3. Does it agree with Q18a's decision (an overcharge is unreachable in v1; the automatic credit is a
   precondition)? Is the reserve sized for a bounded attachment (count × rate × bound) — and since no
   attachment rate exists, is the bound even meaningful yet?
4. Is `LDG-32`'s operator carve-out ("explicitly accepted and capped") specified anywhere (a register
   row, a cap)? If not, is pointing to it pointing at nothing?
5. A smaller shape; the strongest "don't build this".

## Output

At most 800 words, no preamble: accept / amend / reject in one line; why; every defect with `file:line`;
the edits.
