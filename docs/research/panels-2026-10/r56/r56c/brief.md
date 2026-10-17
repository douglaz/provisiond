# Panel brief r56c: pv-k4l, the restart exception when an error is already recorded, 2026-10-17

You are one of four independent reviewers, in a third round on pv-k4l. Your working directory is a
throwaway clone of the specification repository `provisiond-spec` at `16eaff1` (PR #7's tip). Read
`AGENTS.md` first. `br show pv-k4l` prints the bead. You MAY edit tracked files in this clone to test a
claim; write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a provider
API. Read nothing outside this clone except toolchain files. The gates exit 0 at `16eaff1`:
`nix develop --command bash tools/check-all.sh`, about 4 minutes; run it unpiped, redirecting to a file in
the clone, and read its exit code. Keep `TMPDIR` as set. Verify every fact below before relying on it. If
both options are wrong, say so in one line, then still pick. **Answer in at most 400 words.**

## Settled in rounds r56 and r56b (off-limits)

Everything r56 and r56b decided stands. `docs/research/panels-2026-10/r56/synthesis.md` and
`docs/research/panels-2026-10/r56/r56b/` hold the rounds. In particular, do not reopen:

- the column `operations.about_to_order_at`, written in `OPS-43` step 8 and read only when null;
- the new `OPS-15` restart exception (03:384-415): restart only, off while a restore record is open and on a
  store that may have lost committed writes, `failed`, released under `LDG-39`'s "Deterministic rejection
  before acceptance" row, not an `OPS-11` classification;
- for a create with **no** recorded error: an `internal` error naming the restart, with `retryable: true`
  on the error and on the operation view;
- `ADR-0042`, the Lean model, the migration backfill, and pv-s4m (promoted standby, a separate bead).

## The question: a create that already holds an error

The codex bot found that the exception's first wording ("MUST carry an `internal` error naming the restart,
with `retryable: true` on both the error and the operation view") collided with `OPS-16` (03:428: "MUST NOT
overwrite an error already recorded on the operation; it fills in an error only where none exists"), and
`CNF-358` (10:1465) tests a recorded error. Commit `d4e9bc5` fixed it as option (a).

The case: a create holds an error with `retryable: false`, is interrupted before step 8, and restarts.

- **Option (a), as at `16eaff1` (03:385-389):** the recorded error stays, and "The operation view's
  `retryable` MUST then equal that error's". The view says `retryable: false`. `CNF-358` asserts this.
- **Option (b):** the recorded error stays, but the view always says `retryable: true` after the restart.

The manager recommends (a). Its arguments, as claims to break:

1. **`OPS-16` decides only the error.** It keeps the recorded error whole, its `retryable` included, so
   only the view's value is open.
2. **`DOM-17` decides the view.** `DOM-17` (01:652-654): "`retryable` describes whether repeating the
   *same request* is safe and sensible." The restart shows only that nothing was ordered (safe). The
   recorded error is what says whether repeating is sensible, so the view follows it.
3. **`WIR-9b` (13:218-221) does not decide it.** "the operation view's `retryable` (`WIR-10`) is
   authoritative and the envelope's MUST equal it" binds the envelope to the view, not the view to the
   inner error (`WIR-10b`, 13:277).
4. **The case is reached only by `CNF-358`.** The manager found no path where a `running` create before step
   8 already carries an error: claim-time refusals settle `failed` at once (03:758-779), and an `OPS-8`
   defer's write is "`running` back to `queued` with `available_at` advanced" (03:201-203), naming no
   error.

## Questions

1. Pick (a) or (b), with your strongest reason.
2. Does any real path reach this state, other than `CNF-358`'s injected error? Name the requirement and
   the writes. If none does, should `CNF-358` keep the recorded-error case at all?
3. Should the answer differ by the recorded error's kind (for example `invalid_request` against
   `rate_limited` or `internal`)? If so, give the rule.
4. Break claims 1-4: which, if any, is false? Quote the text.
5. Make the strongest case for the option you did not pick, written as its advocate.
