# Panel brief r58b: pv-tst, the minimal shape of A, 2026-10-18

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `471be5a` (master `c8b7cbc` plus the r58 record). Read
`AGENTS.md` first, then `docs/research/panels-2026-10/r58/synthesis.md`, which holds r58's tally. `br show
pv-tst` and `br show pv-f7a` print the beads. You MAY edit tracked files in this clone to test a claim;
write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a provider API.
Read nothing outside this clone except toolchain files. The gates exit 0 at `471be5a`:
`nix develop --command bash tools/check-all.sh`, about 4 minutes; run it unpiped, redirecting to a file in
the clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything:
do the work yourself in this session. Have a draft answer by minute 30. Verify every fact below before
relying on it; the manager has been wrong in briefs before. **Answer in at most 450 words.**

## Settled (off-limits)

- **The owner's decision, 2026-10-18 (option A).** Any stop the engine survives MUST record the outcome
  before the engine exits. This covers every operation kind, not just create. pv-f7a is folded into the
  same change. `OPS-21`'s exception ("except for the create case below", 03:1706-1707) widens to install
  before the disk is touched, and to refresh. pv-9j6 stays separate.
- **What r58 settled:**
  - A over B and C.
  - A crash at the same instant still parks.
  - `OPS-49`'s retry loop and its exits (03:1730-1765).
  - Keep the phrase `CNF-361` quotes: "a cancellation of `execute` recorded before step 9 is the
    exception" (03:1710).
  - Do not reopen whether the create carve-out was redundant.
- pv-qga (`ADR-0043`) and pv-k4l (`ADR-0042`). The ADR home is not asked.

## Main question: the minimal shape of A

r58 split 2-2 on A's size. Rule on each item separately:

- **(a) The bound** on the record before exit: one attempt at the settle transaction; `OPS-49`'s full
  "Store-retry bound" (00:401); or a new `OVR-19` row.
- **(b) Lean:** a cancellation model composing `Claim` and `Tables`, with witnesses, or nothing.
- **(c) `ci.yml`:** new negative controls, or none.

Rule also on a conflict inside the smaller side. `OPS-49` says "A worker cancelled during the retry loop
stops retrying and exits" (03:1764). Suppose a worker is already cancelled and its settle write then
errors. Is it "cancelled during the retry loop" from that first error, so that (a) is one attempt
whatever A says?

**Claims for the smaller shape.** Break the ones you reject.

- **S1.** Every wait is already bounded by a registered value:
  - the driver call by the "Provider-call deadline" (00:379, 00:420), or it is abandoned at once
    (`OPS-21`: "A provider call abandoned mid-flight is exactly the uncertainty this design exists to
    represent");
  - the settle write by `OPS-49`'s bound.
  A new row would restate their sum.
- **S2.** The formal layer models recorded classification (`Failure.cutOff`, Tables.lean:98, 141), not
  process lifetime. A Lean "record before exit" model would prove what it assumes, and a `ci.yml`
  mutation of it would test the model, not an engine.
- **S3.** In r58 all four readers planted an unbounded "MUST be recorded ... before the engine exits", and
  every gate passed. Whatever the shape, only a running-system `CNF` case can catch a missing bound, so
  the `CNF` cases are the control.

**Claims for the larger shape.** Break the ones you reject.

- **L1.** `OVR-19`: "Every value the set says a deployment MUST state is listed here" (00:351-352). A's
  money benefit lands only if the supervisor waits for the record write. A deployment cannot set its stop
  timeout without a stated number, so the number belongs on the register. The register already holds a
  row that is "no — outside the process" (00:402).
- **L2.** The settle write runs after the cancellation that stopped `execute`. Unless the rule says the
  write runs outside that cancellation, a conforming engine can cancel the write too and record nothing,
  and S1's bounds never start.
- **L3.** `AGENTS.md`: "Green is evidence only because the workflow breaks a document on every run and
  asserts the gates reject it". A rule with no model and no control is a rule no gate can fail.

`CONTEXT.md`:199 bans "grace period" ("that is **runway**'s banned synonym"). A new row cannot be named
that.

## Tie-break: the suspension-job rule

Under the owner's decision a cancelled `suspend_tenant` parent records too. Leaving it to `OPS-15`'s
restart re-queue (03:418-421) is no longer an option. `OPS-11` gives it no settled failure state: "Never
`needs_reconciliation`, and never `failed` as a whole" (03:229). r58 split 2-2:

- **T1.** `OPS-49` already gives it the write: "returned to `queued` with `available_at` advanced — the
  same write as `OPS-8`'s defer, though nothing refused it" (03:1767-1769).
- **T2.** That bullet's trigger is "A suspension parent waiting on its children ... whose children are
  still queued" (03:1766-1767). A parent cancelled mid-fan-out is not one, so A needs its own sentence.

Does A need an explicit sentence? If it does, write it, in one sentence.

## pv-f7a's reason value

Under A every graceful stop records a cut-off `conflict` (`OPS-11`, 03:270-271). `WIR-9a`'s `conflict`
row (13:137) has no reason for it. r58's sol suggested `execution_cancelled`. Check it against:

- the existing `cancellation_committed` (`OPS-42`; 13:137 and 13:170);
- `CONTEXT.md`:467-471, "Use **cancel** whenever an end date is involved";
- every kind's cut-off, not just a create's: an install cut off past its marker parks.

`CNF-361`'s "Make no assertion about `details.reason`, neither its value nor its absence" (10:1517-1518)
changes with it. Name the value.

## Answer, in this order

1. A pick for (a), (b) and (c), each with your strongest reason, and your ruling on the 03:1764
   conflict.
2. The claims you break, each with the quote that breaks it.
3. For each pick, the single fact or test result that would change it.
4. The tie-break: yes or no, and the sentence if yes.
5. The reason value.
6. Plant the plausible bad edit for your pick, the one a careless implementer of your shape would make.
   Run the gates, and report which gate goes red, or that none does, and what should catch it. Revert
   it.
