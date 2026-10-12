# Panel brief: which instant an operator's network-restriction record shows (pv-ucs.7), 2026-10-10

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `7d21478` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown
with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question; check this framing too, and verify every fact I state.

## Settled (do not re-litigate)

`ADR-0038` (read it whole, including its clarification of 2026-10-09, Q15): status `restricted |
unknown`; provider reading and operator record side by side, OR-combined; `source`/`observed_at` render
only beside `restricted` (the positive one's; `provider_api` where both); `unknown` renders null/null; four
nullable columns (provider reading + time, operator record time + `operator_ref`). Panel records:
`docs/research/panels-2026-10/r24/`, `r30/synthesis.md` (r30 opus defect 4 raised this exact point).

## The gap

Read `docs/research/panels-2026-10/r33/manager-blocker.md`. `WIR-47` today: "Recording a restriction takes
`{"status": "disabled", "observed_at": "2026-08-13T02:40:00Z"}`" — an operator-supplied instant. ADR-0038
Decision 2 names the operator record's time as "when it was recorded"; Q15's clarification says "the
operator's record time". Which instant does `observed_at` show for an operator-sourced `restricted`, and
what is stored?

## My recommendation

The operator-supplied observation instant (e.g. the time on Hetzner's lock notice): it answers what an
agent cares about, "since when is the network blocked". Refuse a future instant; default to the recording
time when omitted. The recording time is already in `SEC-32`'s audit record.

## What I want from you

1. Who reads `observed_at` beside `restricted` and what do they do with it (an agent; an operator chasing
   a stale record — ADR-0038's stated cost is "a stale `restricted` invites the customer to delete a
   working machine"; `operator_ref` follow-up)? Which instant serves them?
2. Where is my recommendation wrong: backdating, a past instant before the machine existed, clock skew, an
   instant earlier than a later provider reading, idempotent replays (`WIR-24`), a correction of a typo'd
   instant? Does the provider side use the provider's instant or our read time, and should the two agree?
3. A smaller shape (e.g. store the recording time only; drop the request's `observed_at`).
4. Edits (WIR-47, ADR-0038 note, 05-persistence columns, DOM-27, CNF-233/250) and formal impact.

## Output

At most 600 words, no preamble: verdict in one line; why; every defect in my framing with `file:line`; the
edits.
