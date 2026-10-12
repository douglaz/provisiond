# Panel brief: a still-future earliest cancellation day near midnight (Q25), 2026-10-11

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `12a1c89` (branch `pv-ucs-impl`; the pv-ucs.10
review-residue round 1 is applied). Read `AGENTS.md` first. Do not edit tracked files; write scratch files
only inside this clone (never `/tmp`); you may run the gates (`nix develop --command bash
tools/check-all.sh`, unpiped). Search the Markdown with whitespace normalised. This owner repeatedly shows
my framing wrong with a first-principles question and dissolves machinery rather than tuning it; check this
framing too, and verify every fact I state.

## Context

An rloop Manager blocked pv-ucs.10; read its report, `docs/research/panels-2026-10/r43/manager-blocker.md`
(the first section). Settled: ADR-0037 with every amendment — read the Q22 and Q23a–c amendments whole
(Q23c: "a day-only `earliest_cancellation_date` names the start of that day in the provider's zone … A date
equal to the provider's today has passed, so the machine takes the ordinary branch. Cost through a future
earliest date runs to that day's end"). Also `PRV-13`, `PRV-13b`, `PRV-13c` ("materially in the future …
later than now plus one re-derivation period plus the product's wind-down bound"), `PRV-31` (the declared
bound sizes the commitment at create; the actual date "MUST NOT resize the commitment"), and `LDG-33`.

## The gap

At local Oct 30 23:30 (Europe/Berlin, `2026-10-30T22:30:00Z`), a server whose earliest day is Oct 31: its
stored start is 30 minutes away (ordinary branch, nothing reserved at purchase), but `LDG-33` protects cost
through Oct 31's end (~24.5 h). Readings: (1) judge a still-future earliest day by its priced-through end,
so it takes the exception reserve at purchase from the declared bound; ordinary once its start passes; no
post-order resize (the Manager's recommendation); (2) keep the start-based test and accept the
near-midnight under-reserve, stating what absorbs it.

Check first principles: is the "end of day" pricing right for a permitted-from date at all (Q23c says cost
through a future earliest date runs to its end because a cancellation dated that day ends there — but does
provisiond ever schedule a cancellation for a future earliest date in v1, or does PRV-13c's exception branch
refuse such offers on prepaid terms)? Is any v1 path able to reach this (Robot: "You can only cancel
immediately", `research` V12; CNF-147: "no launch product reaches the branch by default")? Is the smallest
answer to make the reachable set empty and say so, rather than tune the threshold?

## Output

At most 700 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits; the
strongest "don't build".
