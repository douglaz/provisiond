# Panel brief r58c: pv-tst review, a stop during a store-retry loop inside `execute`, 2026-10-18

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `fcbd8f4` (branch `pv-tst-triage`: pv-tst's change plus
review wording fixes). Read `AGENTS.md` first, then `docs/research/panels-2026-10/r58/synthesis.md`
(sections "Owner decision", "Owner decision 2", "Owner decision 3", "The 03:1764 conflict"). `br show
pv-tst` prints the bead; its "## Agent Brief" comment is the contract the change implemented. You MAY
edit tracked files in this clone to test a claim; write nothing outside it (never `/tmp` or `/var/tmp`),
and never commit, push or call a provider API. Read nothing outside this clone except toolchain files.
The gates exit 0 at `fcbd8f4`: `nix develop --command bash tools/check-all.sh`, about 4 minutes; run it
unpiped, redirecting to a file in the clone, and read its exit code. Keep `TMPDIR` as set. Do not
delegate, background or wait on anything: do the work yourself in this session. Have a draft answer by
minute 30. Verify every fact below by grep before relying on it; the manager has been wrong in briefs
before. Read text by requirement id, not by line number. **Answer in at most 450 words.**

## Settled (off-limits)

- The owner's three decisions of 2026-10-18 (r58 synthesis): A (any stop the engine survives records
  the outcome before exit, every kind); the larger shape (the `OVR-19` Stop-record bound, shielding,
  the Lean model and `ci.yml` controls); the reason `cut_off`.
- `OPS-11`'s rows, `OPS-15`'s restart exceptions (`pv-k4l`, `ADR-0042`), `ADR-0043`'s worker position.
- A stop that lands after `execute` has returned, before or during the ordinary settle write: a
  separate bead. Do not rule on it.

## The story

A create is in `execute` at `OPS-43` step 8. Its transaction (the `STO-47` check plus
`about_to_order_at`) hits a store error, so the worker is repeating it under `OPS-49`'s whole-transaction
loop. Say the first attempt committed but its reply was lost. Now a deploy stops the engine, which
survives the stop.

- **X (exit).** The worker stops retrying and exits. On restart `OPS-15` finds the row `running` with
  the column set and moves it to `needs_reconciliation`; the commitment stays held and the correlator
  searches for an order nobody placed. (Had the first attempt not committed, the null column would
  settle it `failed` on the restart.)
- **Y (record).** The stop is a cancellation of `execute`, so the worker abandons step 8's loop and makes
  the shielded record write within the Stop-record bound: a cut-off `conflict` before step 9, so the
  create settles `failed` and releases now.

The same split applies to an `OPS-45` marker write repeating inside an install's `execute`.

The texts (verify each):
- `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine
  exits, for every operation kind, subject to the bounded abandonment and later-stop exits below." Its
  later-stop sentence is about the record's own loop: "A later stop during that loop is still an exit
  without worker classification".
- `OPS-49`'s bullet: "A worker cancelled during the retry loop stops retrying and exits. This means a
  stop arriving during the loop — for a stop's record, a later stop — rather than the cancellation
  being recorded."
- `CNF-361`: "cancel `execute` at each of steps 1-8 …, at step 8 outside `OPS-49`'s retry loop, where "A
  worker cancelled during the retry loop stops retrying and exits" and classifies nothing."
- pv-tst's brief, item 2: the bullet "means a stop arriving during the loop, not the cancellation an
  `OPS-21` record is recording." Owner decision 2: "`OPS-49`'s retry loop and its exits stay as settled."

## Question

Under the committed text, can two conforming engines take X and Y here? If yes, which should the text
say, X or Y? Name the decision or requirement text that settles it, or say that none does. Rule also on
the same stop arriving during the FIRST attempt of such an in-`execute` write, before any store error:
may that attempt finish? Does the install's marker write differ, since its row reads "while `OPS-45`'s
two markers say the disk is untouched"?

Then give: the minimal edit under your pick (requirement ids and the sentences, quoted), any gate a
plausible wrong edit of it would pass, the strongest argument for the other option (this is requested,
not your vote), and what would change your mind.
