# r63b tally (panel C confirmation read) — 2026-10-23, clones at dc5d40d

All four exited 0: fable 2430 B, opus 2753 B, astra 1574 B, sol 1442 B. No reader ran a gate or `lake`.
Rules: the brief's *Answer* section plus r63 `notes.md` rules 2-7 (fixed before r63 launched).

## S (pv-s4m): 3-1 ACCEPT

- fable ACCEPT (spans verified; S6 true since `RestoreTrace.delta : Nat` admits 0). Note, not a block: ADR-0045
  should quote 26.2.8.1's sentence whole.
- astra ACCEPT. sol ACCEPT.
- opus CANNOT ACCEPT, valid under rule 3 (quotes `03:408-409`, gives a trace): S narrows the deleted clause to "an
  asynchronous standby", but the set calls its one standby synchronous. Replacement: "any standby", `OVR-19`'s
  named standby included.
- Manager verified opus's premises at dc5d40d: `00-overview.md:338` "a stalled synchronous standby", `:405`
  "Synchronous standby name"; `05-persistence.md:147` (inside `STO-7`, which starts at `:132`)
  "`synchronous_commit` is `local` on every connection and `on` inside exactly two transactions", `:149-150`
  "against the standby `OVR-19` names"; but `05:1474` (`STO-54`) "The deployment runs asynchronous streaming
  replication". So it's an ambiguity: someone whose standby is the "synchronous" one can read S as not
  covering them. The fix deletes a word.
- S formally carries 3-1. It does not go to the owner as-is: a verified loophole, fixed by a one-word deletion,
  which r63c reads as S'.

## D: OMIT 4-0

- fable: the timeline read lags a fast promotion; `OPS-47` files this as a deployment obligation. opus: an unverified
  signal backing a MUST on both components. astra, sol: the timeline observation is unspecified.
- Brief error (fable, opus; verified): the brief cut opus's r63 quote. `/var/tmp/provisiond-panel-r63/opus.md:13` reads
  "D covers only the engine, and `api` is where the hole is", aimed at an engine-only D. Premise unchanged: opus
  omits D for a different reason. D goes into ADR-0045 under rejected options.

## F (pv-n98 + A1): 2-2 as written, 4-0 on behaviour

- fable ACCEPT, opus ACCEPT; astra CANNOT ACCEPT, sol CANNOT ACCEPT. Both valid: a trace plus replacement text.
- All three objections hit the same F6 bullet, "`step_quarantined_restore` is re-keyed to `stepTwoMarked`" (fable
  raised it too, as a proof note). After step (3) a fresh create is admitted: `stepTwoMarked = true`, a `queued`
  irreversible row exists, so `World.quarantined` (`Restore.lean:703`) is false. All three land on `World.safe`
  (`Restore.lean:506`, "No `queued` row of an irreversible kind has run"). Manager verified: `claim` sets
  `secondOrder := w.secondOrder || (irreversible o.kind && o.applied)` (`Restore.lean:440`), so `World.safe` is
  enough for the `secondOrder = false` conclusion. The restart path already proves it with `World.safe`
  (`:634-692`).
- This is converging, not a split. Nobody disputes F's behaviour, so it isn't put to the owner as a 2-2. r63c reads
  F' with the merged bullet.
- Non-blocking notes folded into r63c: opus, `03:1686-1688` worker pseudocode ("after a restore they wait ... and the
  queued irreversible kinds are quarantined") contradicts F3/F7 (new F8). astra (brief error, glossary),
  `CONTEXT.md:186` "a restore loses an interval" is false under S2's "whether or not the promotion lost a write";
  astra's fix: "a restore may lose an interval".

## Verified after the round

- postgresql.org warm-standby 26.2.8.1, whole sentences: "Users will stop waiting if a fast shutdown is requested.
  However, as when using asynchronous replication, the server will not fully shutdown until all outstanding WAL
  records are transferred to the currently connected standby servers."

## Next

r63c (`/var/tmp/provisiond-panel-r63c/`) reads S' and F'. Its outcome rules are in its `notes.md`, fixed before
launch.
