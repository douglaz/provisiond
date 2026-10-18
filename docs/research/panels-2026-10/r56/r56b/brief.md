# Panel brief r56b: pv-k4l, where the step-8 "about to order" record lives, 2026-10-17

You are one of four independent reviewers, in a second round. Your working directory is a throwaway clone
of the specification repository `provisiond-spec` at `96ce45c` (master `1292174` plus bead comments). Read
`AGENTS.md` first. `br show pv-k4l` prints the bead, `br comments pv-k4l` its comment. You MAY edit tracked
files in this clone for question 4; write nothing outside it (never `/tmp` or `/var/tmp`), and never commit,
push or call a provider API. Read nothing outside this clone except toolchain files. The gates were green
at `96ce45c` in a fresh clone: `nix develop --command bash tools/check-all.sh`, about 4 minutes. Run it
unpiped, redirecting to a file in the clone, and read its exit code (`echo $?`). Keep `TMPDIR` as set.
Verify every fact below before relying on it. This owner often breaks a framing with a first-principles
question; if both options are wrong, say so in one line, then still pick.

## Settled in round one (4-0, off-limits)

- pv-k4l gets fixed: step 8's transaction (`OPS-43` step 8, `API-63`'s correlator transaction) writes a
  record that a create is about to order. Only its **unset** case is read, at startup, on a normal restart.
- A new exception in `OPS-15`, beside `refresh` (03:375-380). It settles the create `failed`, with `internal`
  naming the restart and `retryable: true`; `OPS-16` keeps an earlier error. The commitment is released
  under `LDG-39`'s "Deterministic rejection before acceptance" row. It is not an `OPS-11` classification
  (03:1385-1387: "an operation interrupted rather than classified is `OPS-15`'s").
- It is off during an open restore incident (`STO-54`) and must stay off on a standby promotion that lost
  committed writes (05:1443: "asynchronous streaming replication").
- `OPS-6` already guards every worker write with the claim number (03:165-166).
- Both shapes must meet all seven conditions. (1) The record is written on every channel. (2) It is
  write-once and survives the payload purge. (3) Step 9 starts only after step 8 is acknowledged. (4) Step
  8's write is guarded on status `running` plus the claim term, and zero rows means no step 9. (5) The
  startup pass tests "unset" inside its own conditional write, together with the release (`LDG-35`). (6) It
  fires on a restart only. (7) Rows claimed before the record existed stay conservative.
- pv-qga and pv-k4l are decided together and stay two beads.

## The question: where the record lives

- **Option 1, a new column** on `operations`: a write-once, nullable timestamp, null on every other kind.
  `API-63`'s entry test moves to it.
- **Option 2, no new column:** step 8 always writes `correlator_kind`. On a `PRV-33` channel, which is Robot's
  standard channel today, it writes the descriptor's `none` (02:79), as `('none', NULL)`. A null pair means
  step 8 never committed. That `none` pair is never searched and never copied to a machine row.

Round one split 2-2. Each side's strongest arguments follow, as claims to break.

**Claims for option 1:**

- **A1.** The pair is read as a provider fact, so every one of these readers must special-case `none`:
  - `CONTEXT.md` 308: "Whatever a create writes or leaves behind at the provider".
  - `OPS-38`: "every correlator the operation recorded" (03:625-626).
  - `PRV-26`: "It MUST be opaque and unique per operation" (02:866); "`OPS-27`'s search has one value to
    try" (02:884).
  - The machine row's same-named pair is "what was actually written into the provider at create". Its null
    already means "a machine that bore none when adopt returns" (05:267).
  - "index on `(correlator_value)` for reconciliation lookup" (05:301).
- **A2.** The set has already paid for one column with two meanings. `OPS-45` says: "Recorded 2026-09-04
  because a single column carrying two meanings was read as carrying the first one everywhere"
  (03:1402-1403).
- **A3.** Under option 1, what step 8 puts in the pair on a `none` channel stops mattering for dispatch.
  Under option 2 it decides dispatch, and the text is unsettled on it today:
  - `PRV-32` says an unverified channel "MUST declare no correlator and `PRV-33` governs" (02:963-964);
  - `PRV-9`'s per-order key is still uploaded at step 9;
  - 05:382 says "`ssh_key_fingerprint` on Robot" with no channel scope.

  Verify this. Does option 2 write `('none', NULL)` and lose the fingerprint as operator evidence, or write
  a fingerprint kind on a `none` channel that `OPS-38` would then count?

**Claims for option 2:**

- **B1.** The fact already has a home. `API-63` says "the correlator entry is what tells the termination
  which case it is: a claimed create with no entry has not passed the conditional-write check and does not
  dispatch" (04:1423-1425). Option 2 makes that true on every channel. Option 1 leaves two records written
  in one transaction that must never disagree.
- **B2.** `none` is not a new sentinel; it is the descriptor's own word (02:79). With it, `OPS-38`'s "A
  create that recorded none has no count" (03:627) becomes literal.
- **B3.** Option 1 adds a column, a write-once rule and a `COALESCE` for a fact the pair can carry. It also
  leaves the pair's step-8 content on a `none` channel undefined. Verify this: does `API-63` (04:1414-1431)
  or `PRV-26` still owe a fix under option 1?

## Answer in this template, under 500 words

1. **Pick:** 1 or 2, one sentence.
2. **Claims:** for each claim on the side you did not pick, say "broken" with the quote that breaks it, or
   "stands". Then name the claim that decided your pick.
3. **What would change your mind:** one checkable sentence, such as a quote that would have to exist or a
   gate result.
4. **Plant:**
   1. Write your pick's minimal normative edit and run the gates. Record the exit code and any red gate.
   2. Then plant the most plausible bad edit that a later author makes to your shape, and run the gates
      again.
   3. Save both edits with `git diff > r56b-plant.diff`, untracked, in this clone.
   4. Report each edit in one line, with both exit codes and which gate went red, or "nothing red". If
      nothing went red, say in one sentence what would have caught it.

   `OPS-15` is formalized: `@[req "OPS-15"]` at `tools/formal/Provisiond/Restore.lean` 243 and 335. Check
   whether your edit belongs in Lean too.
5. **ADR, tie-break.** Round one split 2-2:
   - a new ADR (it amends `ADR-0016`'s startup pass, the question differs) with a dated pointer in
     `ADR-0035`'s rejected bullet "A durable dispatch marker on create" (adr/0035:59-61);
   - or an amendment to `ADR-0035` (that bullet rejected the idea by name).

   Pick one and cite the repo's own convention (`README.md`'s ADR index uses "Amends `00NN`"; ADR-0035 has
   inline amendment sections). Say whether your answer depends on the shape. Check that `0042` is free in
   that index.
6. **pv-qga, tie-break.** Should pv-qga take a `br` blocking dependency on pv-k4l, so that pv-k4l must close
   before pv-qga can be worked? Round one split 2-2:
   - yes: if pv-qga settles a pre-send read failure `failed`, this record is its evidence;
   - no: recovery and a recorded failure are different paths.

   Say yes, no, or "only if pv-qga settles `failed`", and which way you expect pv-qga to go.
