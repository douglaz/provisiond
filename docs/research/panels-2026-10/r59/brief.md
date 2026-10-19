# Panel brief r59: pv-zbp review, a stop during a provider read whose failure is absorbed, 2026-10-19

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `647ed9b` (branch `pv-zbp-triage`: pv-zbp's change,
review wording fixes and three new beads). Read `AGENTS.md` first, then
`docs/research/panels-2026-10/r58/synthesis.md`, sections "Owner decision, 2026-10-18" and "Owner
decision 4, 2026-10-18: Y". `br show pv-zbp` prints the bead: its "## Agent Brief" comment, as amended
by "## Agent Brief amendment (2026-10-19)", is the contract the change implemented. `br show pv-ilb`
prints a related bead. `git diff 67967f3..647ed9b -- '*.md'` shows the change. You MAY edit tracked
files in this clone to test a claim; write nothing outside it (never `/tmp` or `/var/tmp`), and never
commit, push or call a provider API. Read nothing outside this clone except toolchain files. The gates
exit 0 at `647ed9b`: `nix develop --command bash tools/check-all.sh`, a few minutes; run it unpiped,
redirecting to a file in the clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate,
background or wait on anything: do the work yourself in this session. Have a draft answer by minute
30. Verify every fact below by grep before relying on it; the manager has been wrong in briefs before.
Read text by requirement id, not by line number. **Answer in at most 450 words.**

## Settled (off-limits)

- The owner's decisions of 2026-10-18 (r58 synthesis), in particular decision 1: "Any stop the engine
  survives MUST record the outcome before the engine exits. This covers every operation kind, not just
  create."
- pv-zbp's direction: a stop the engine survives after `execute` returns is recorded by the worker's
  settle write, shielded and within the Stop-record bound (`OPS-21`).
- A stop during `OPS-27`'s settle-time correlator search or its confirming read is `OPS-21`'s
  cancellation of `execute`, recorded as a cut-off `conflict`. That agrees with `OPS-27`'s "a failed
  search" and "a failed confirming read likewise cannot establish success".
- `PRV-13c`'s rules for the post-order read and `PRV-13`'s rule for the read after an accepted dated
  cancellation (both `ADR-0037`, owner decisions Q22 and Q31).

## The story

A Robot create's order is accepted. Its settle-time search finds exactly one machine and the confirming
`GET /server/{n}` succeeds. The driver now makes `PRV-13c`'s one post-order read,
`GET /server/{n}/cancellation`. A deploy stops the engine during that read, and the engine survives.

- **The branch says cut-off.** `OPS-21` now says "For a create, the worker's settle-time verification
  is inside `execute`: `OPS-27`'s correlator search and its confirming read, and `PRV-13c`'s post-order
  read in that settlement pass, so a stop during any of them is the cancellation being recorded." The
  record is a cut-off `conflict`, so the create enters `needs_reconciliation`. `CNF-362`'s Placement
  control asserts exactly that for the post-order read.
- **PRV-13c says the settlement stands.** It says "A failed post-order read of any kind, `rate_limited`
  included, MUST NOT enter `OPS-11`'s classifier and MUST NOT change the create's settlement."
  `CNF-147`'s Q31 amendment asserts `succeeded`, with only `earliest_cancellation_date` null, when the
  same read fails with a network error.

The same shape, predating pv-zbp, is `pv-ilb`: `PRV-13`'s direct read after an accepted dated
cancellation, where "this read fails for any reason" settles `succeeded`.

The options:
- **(a) Absorbed.** The stop cuts the read short, and the read counts as a failed post-order read.
  `execute` returns the verified success with a null date, and the settle write records the stop as a
  stop after `execute` returns.
- **(b) Cut-off.** Keep the branch text. Either `PRV-13c`'s "of any kind" does not reach a read cut
  short by a stop, or `PRV-13c` gains an exception (which amends an owner-decided rule).
- **(c) Drop.** Remove the post-order read from that `OPS-21` sentence and from the Placement control,
  and leave the case open in a bead.
- **(d)** A shape none of these is.

## Questions

1. Does the text at `647ed9b` contradict itself here (`OPS-21` against `PRV-13c`, `CNF-362` against
   `CNF-147`)? Quote both sides.
2. Pick (a), (b), (c) or (d), and give your strongest argument. Name the sentences your option adds,
   changes or removes. Watch for any sentence or Lean docstring that quotes them.
3. The manager's claim: `OPS-21`'s sentence "`execute` returns only once the outcome its settle write
   records is final, so every provider call that outcome depends on is made inside `execute`" does not
   reach the post-order read, because `PRV-13c` says its failure cannot change the settlement. Is that
   right? Is `earliest_cancellation_date` part of "the outcome its settle write records"?
4. Under (a): is the date null, given `PRV-13c`'s "The landed-order transaction MUST write the date of a
   successful read the committing pass holds, otherwise null"? Does any `PRV-13c` sentence collide with
   it: the discard on "interruption by engine exit or crash", "Within a settlement pass the post-order
   read MUST NOT be repeated", or `PRV-5`'s alarm?
5. Does your answer also decide `pv-ilb`? If not, what separates the two reads?
6. Make your option's edit in your clone and run the gates. Then plant the reversal of its deciding
   sentence and report whether anything goes red, and what. If nothing does, say which `CNF` item is
   the only check.
7. Labelled as written on request: the strongest argument against your own pick.
