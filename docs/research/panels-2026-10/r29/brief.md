# Panel brief: two owner questions blocking pv-ucs.6 (ADR-0037), 2026-10-09

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `0b28621` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files, run arithmetic and the gates. Search the
Markdown with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state before relying on it.

## Settled (do not re-litigate)

`ADR-0037` (read it whole): `billing_stop_window` is withdrawn; wind-down's latency term is `PRV-36`'s
effective visibility window (dispatch to the recorded gone); `OVR-19` gains a provider-call deadline "so
the case where no reply ever comes is bounded too"; a release whose result carries a future effective
date writes no `released_at`. Panel record: `docs/research/panels-2026-10/r22/synthesis.md`. ADR-0033
(prepaid first unit) and ADR-0035 (acceptance) are also settled.

## The blocker

Read `docs/research/panels-2026-10/r29/manager-blocker.md` (the Manager's own words, including two record
items at its end). The unaccepted implementation of pv-ucs.6 is in this clone's history as `fbe613a`
(read `git show fbe613a`).

**Q13 — how the deadline enters wind-down.** `PRV-13b` (as amended in fbe613a) sizes `wind_down_cost` as
"detection interval + `PRV-36`'s effective visibility window + margin, subject to the provider-call
deadline in `OVR-19` and the machine-wait term below"; `OVR-19` says sizing "MUST cover this bound as well
as the effective visibility window"; `CNF-329`: "including when either is larger". Maximum or sum? With a
600 s deadline and a 30 s window: 600 vs 630, versus 30 read literally.
My recommendation: the maximum, where both run from the same mutation dispatch and overlap; any later
call that adds a sequential wait must be named explicitly. PRV-13b owns the composition; OVR-19 registers
the parameter and points to it; CNF-329 demonstrates the exact rule.

**Q14 — when a scheduled attachment release stops customer metering.** ADR-0037 Decision 4: "A release
whose result carries a future effective date writes no `released_at`" (Robot IPs/subnets can be cancelled
for a later date). `LDG-32`: "MUST meter each billable attachment on its own identity until `released_at`
is set". `LDG-38`: for an attachment release the stop boundary "is `released_at`". `CNF-328`: "This case
asserts no transition at the future date." So after a successful scheduled release nothing ever writes
`released_at`: the attachment is metered forever and the commitment/tombstone gate never opens.
Readings: (i) the known effective date ends customer metering, with later evidence completing release
bookkeeping; (ii) metering runs until evidence that the attachment is gone; (iii) mirror the machine's
scheduled-cancellation rule (`DOM-19`, `LDG-74`: "the earlier of its `effective_cancellation_date` and
the observation").
My recommendation: (iii) — reuse the machine's existing rule for the attachment: billing stops at the
earlier of the effective date and an authoritative gone observation; something must write that stop
(name the writer); `LDG-32`'s tombstone gate opens on it.

## What I want from you

1. Q13: do the deadline and the window really overlap (both from dispatch), or can the window start only
   after a reply that the deadline bounds (sequential)? Trace a Hetzner Cloud delete and a Robot
   `cancellation_date=now` through PRV-29, PRV-36, OVR-19, OPS-27 and LDG-74. Is "max" safe, or does it
   under-reserve the case where the reply arrives at the deadline and visibility lag starts then?
2. Q14: which reading matches the rest of the set? Who writes the attachment's stop at the effective date
   when no operation is running (the sweep `OPS-32` does not cover attachments)? Does (iii) reintroduce
   anything ADR-0037 or ADR-0028/0029 withdrew (a clock comparison in a guard; a per-row deadline)? What
   does the customer actually owe for a Robot IP cancelled for month end?
3. Third shapes and the strongest "don't build this" for each.
4. The record items at the end of the Manager's text (API-65's tombstone claim; ADR-0035's release rule
   amendment): real, and what is the smallest fix?
5. Formal layer: which declarations change.

## Output

At most 1000 words, no preamble: a verdict line per question; why; every defect in my framing with
`file:line`; the requirement ids, CNF items and declarations each chosen answer edits.
