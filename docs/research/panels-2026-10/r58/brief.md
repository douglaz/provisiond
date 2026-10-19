# Panel brief r58: pv-tst, must a cancelled `execute` record its outcome?, 2026-10-18

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `c8b7cbc` (master). Read `AGENTS.md` first. `br show pv-tst`,
`br show pv-f7a` and `br show pv-9j6` print the beads. You MAY edit tracked files in this clone to test a
claim; write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a provider API.
Read nothing outside this clone except toolchain files. The gates exit 0 at `c8b7cbc`:
`nix develop --command bash tools/check-all.sh`, about 4 minutes; run it unpiped, redirecting to a file in
the clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything:
do the work yourself in this session. Have a draft answer by minute 45. Verify every fact below before
relying on it; the manager has been wrong in briefs before. **Answer in at most 600 words.**

## Settled (off-limits)

- pv-qga (`ADR-0043`, panel r57): `OPS-11`'s create row (03:232) classifies a failure **the worker records**
  before any step-9 request as `failed`, by worker position, never by reading `about_to_order_at`. The
  owner chose that a recorded cancellation keeps the cut-off `conflict` kind (not `internal`).
- pv-k4l (`ADR-0042`): `OPS-15`'s restart-only exception (03:387-411) settles a `running` create whose
  column is null `failed`; a set column takes the ordinary path to `needs_reconciliation`.
- `OPS-49`'s whole-transaction retry loop and its exits (03:1730-1765). Inside the loop the store is failing,
  so nothing can be recorded there.

## The question (confirmed)

`OPS-21` (03:1706-1712): "`execute` MUST be cancellable, and cancellation MUST be treated as an ambiguous
outcome, except for the create case below." Its second paragraph covers "a cancellation of `execute`
recorded before step 9". No sentence says a cancellation must be recorded, or may not be.

Story: a create is claimed; step 8 commits and is acknowledged (column set); the engine is stopped before
the worker invokes step 9. Nothing was ordered.
- Engine A records the cancellation: `failed`, commitment released at once.
- Engine B exits without a write: on restart `OPS-15` sees the set column, so `needs_reconciliation`, the
  correlator searches for an order never placed, and the money stays held until `OPS-33`'s negative window.

Size of the stake, as the manager reads it (break it if wrong):
- Before step 8 commits, A and B both settle `failed` and release; only the kind differs (cut-off `conflict`
  vs `OPS-15`'s `internal` "naming the restart").
- Money differs only when the column is set and step 9 has not begun: the gap after step 8's acknowledgement,
  or a cancellation during step 8's first attempt whose commit landed.
- A crash at the same instant always parks (`CNF-361`'s restart control, 10:1523-1525). No rule can force a
  write on a kill, so "must record" can bind only a cancellation the process survives.
- The spec names no trigger for a cancellation. `API-58` says a create claimed before a suspension "MUST be
  allowed to settle rather than abandoned mid-order" (04:620-621). `05-persistence.md` mentions "a cancelled
  worker" (05:143). The codex bot that raised this on PR #8 called it "shutdown cancellation".

## Options

- **A. Must record.** A cancellation the process survives MUST be recorded and classified under `OPS-11`
  before the engine exits, outside `OPS-49`'s loop, probably within a stated drain bound (an `OVR-19`
  parameter, 00:351).
- **B. May exit, said explicitly.** Either is conforming; an exit is `OPS-15`'s. `CNF-361` already tests only
  the recorded case (10:1508-1510).
- **C. Must not record (the manager's lean).** A cancellation is an interruption: the worker writes no
  outcome, the engine exits, and `OPS-15` classifies the row at the next start, exactly as after a crash.

## The manager's case for C, as claims to break

1. A cannot remove the two-outcome split in that gap (a crash still parks); it moves only graceful stops.
2. `OPS-45` already draws this line for install and rescue inventory: "This rule classifies a failure a
   worker recorded; an operation interrupted rather than classified is `OPS-15`'s, whatever the markers
   hold" (03:1444-1446). So no rule here is create-only, and pv-9j6's example (a cancelled delete) is the
   same split.
3. Pre-existing: for a recorded install cancellation before the marker, `OPS-21`'s "treated as an ambiguous
   outcome, except for the create case" contradicts the install row's "`failed` ... for any failure at all
   while `OPS-45`'s two markers say the disk is untouched" (03:231). `Tables.installRow`
   (Tables.lean:165-168) says `failed`.
4. Under C no cut-off `conflict` exists anywhere. The OPS-11 bullet (03:270-271), the create row's cut-off
   sentences (03:232), `OPS-21`'s second paragraph, `CNF-361`'s cancellation cases and `Failure.cutOff`
   (Tables.lean:98, 141) are withdrawn, and pv-f7a (no `WIR-9a` reason for it) closes as moot.
5. C requires cancellation to end the process: `OPS-15` says "nothing but a restart can leave a `running`
   row with no worker behind it" (03:356-357), and `OPS-5` (03:158-159).
6. `OPS-49`'s "`OPS-15` gives the same answer either way once the process is gone" (03:1764-1765) is still
   true after pv-qga.
7. Under A, a `suspend_tenant` parent has no recordable outcome (`OPS-11`: "Never `needs_reconciliation`,
   and never `failed` as a whole", 03:229); under C `OPS-15` re-queues it (03:418-421).

## Questions

1. Pick A, B, C or a fourth shape, with your strongest reason.
2. Break claims 1-7. Quote the text that breaks each.
3. Does the bead's premise hold that engine B conforms today? Check the worker algorithm (03:1681-1695: every
   `execute` outcome goes to `classify`), `OPS-22` and `OPS-5`.
4. Should pv-tst be decided together with pv-f7a, pv-9j6, both or neither? Why?
5. List every edit your pick owes: requirements, CNF items, ADR home (amend `ADR-0043`, or new), Lean,
   `ci.yml`.
6. Plant the plausible wrong edit for your pick in your clone (for C, for example, delete `cutOff` or the
   OPS-11 bullet; for A, a MUST with no bound). Report whether any gate goes red and what a negative control
   should catch.
7. Make the strongest case for each option you did not pick, written as its advocate and labelled so.
