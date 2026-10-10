# Panel brief: three owner questions blocking pv-ucs.5 (ADR-0036 Robot ordering), 2026-10-09

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `7d21478` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question and
dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Settled (do not re-litigate)

`ADR-0036` (read it whole, including its correction of 2026-10-09) and `ADR-0030`'s amendment of
2026-10-09 (tail order: account → offer not sellable → ordering channel closed → solvency, rate, cap,
balance). Panel records: `docs/research/panels-2026-10/r21/` and `r28/synthesis.md`.

## The blocker

Read `docs/research/panels-2026-10/r32/manager-blocker.md` (the Manager's own words: three questions with its
recommendations). The unaccepted implementation of pv-ucs.5 is in this clone's history as `869ee2b`.

**Q17a — what startup validates about `API-35`'s activation minimum.** The new `OVR-19` row says startup
validates it ("satoshis, large enough to purchase something", validated: yes); `API-35`: "The minimum MUST
be large enough to purchase something"; new `CNF-345`: "configure below the price needed to purchase
something: startup refuses each". Pricing a purchase at startup needs an offer and a live rate, so a rate
outage could stop the service from starting. My recommendation: startup validates a positive integer
only; purchase sufficiency stays the operator's configuration obligation.

**Q17b — does a closed ordering channel stop a create admitted before the throttle?** Create A is admitted
and queued; another create receives Robot's 403 and closes the account/channel; A reaches its first
provider call afterwards. `API-63` already makes the worker "repeat the admission check as a conditional
write" for account health before the ordering call. Manager's recommendation: recheck not-yet-sent
creates before their first provider call and fail them locally while closed.

**Q17c — what does a create that loses the one-in-flight-per-offer guard return?** ADR-0036's correction
makes it a conditional-write guard beside `API-63`'s and `LDG-62`'s; new `PRV-42` says "the create MUST
refuse with `conflict`/`state`, without a commitment, operation or receipt"; `WIR-9a` has no retryability
row for it. Manager's recommendation: an ordinary conditional-write `409 conflict`/`state`,
`retryable: false`, no rich refusal list.

## What I want from you

1. For each: is it a real behaviour question, and is the recommendation right? Trace the concrete case
   (17a: restart during a rate outage; 17b: A queued behind B's 403; 17c: two tenants racing for one
   auction offer).
2. 17a: is there any reason startup should price a purchase? What does `OVR-19` do for its other
   "validated" rows (do any need live data)?
3. 17b: what does failing A locally cost the tenant (commitment released, setup fee?), versus sending
   A into a closed channel (a wasted provider request, another 403, `ADR-0035`'s acceptance rule)? Is
   "fail locally" `OPS-11`-admission-only, and with which kind/`retry_after_ms`?
4. 17c: should the loser get `retryable: true` (the winner may fail and free the offer) or `false`?
   Ordinary error or the rich tail? Does `API-50`'s pacing promise apply?
5. Third shapes; the strongest "don't build this" for each; formal-layer impact.

## Output

At most 900 words, no preamble: a verdict line per question; why; every defect in my framing with
`file:line`; the edits.
