# Reader brief r63h: provisiond-spec, panel C (pv-s4m, synchronous replication). What r63g left open

You are one of four independent readers. Read, verify and vote.

- Your working directory is a clone of the spec repository at `dc5d40d`, branch `panel-c`. **Write nothing in the
  repository.**
- **Do not start any database or PostgreSQL instance.** This is a production host, and the measurements are already
  done.
- Don't hand work to subagents or background tasks.
- By minute 35, write a draft answer to `/var/tmp/provisiond-panel-r63h/<your working directory's name>.draft.md`.
  That is outside the repository, and it's the only file you may write.
- Finish within 55 minutes. **Your final message must be the full answer, not a summary or a pointer to the draft.**

## Files

- **`/var/tmp/provisiond-panel-r63h/forms-r63h.md`: the items you vote on.** It opens with an errata block. The lines
  it lists in r63g's files are void: don't rely on them.
- `/var/tmp/provisiond-panel-r63h/owner-questions-draft.md`: the four owner questions as they would be asked.
- `/var/tmp/provisiond-panel-r63e/forms-final.md` ("forms-final"): the voted base text.
- `/var/tmp/provisiond-panel-r63g/forms-r63g.md`: r63g's forms. S3-B′, PT and PA-2 come from here.
- `/var/tmp/provisiond-panel-r63g/tally.md`: r63g's result, with the readers' quotes and the verified dissents.
- `/var/tmp/provisiond-panel-r63g/{opus,astra,sol}.md` and `fable.draft.md`: r63g's four answers. Read them only to
  check a quote.
- `/var/tmp/provisiond-panel-r63g/verify.md`: the claims of the external review, checked. Mind the errata.
- `/var/tmp/provisiond-pgharness/results.md` (repository copy: `docs/research/panels-2026-10/r63/pgharness/results.md`): a PostgreSQL 18.6 harness with a primary and two standbys,
  `ANY 1 (s1, s2)`. It is cited as H-a … H-f.
- Sources:
  - `/var/tmp/provisiond-panel-r63f/src/`: PostgreSQL 18 `18-xact.c`, `18-syncrep.c`, `postmaster.c`, `walsender.c`
    and docs, including `warm-standby.txt`, plus the Patroni docs;
  - `/var/tmp/provisiond-panel-r63g/src/`: `18-xlog.c` and the failover docs.

## Settled, off limits

- Synchronous replication on every commit. Three servers, with `ANY 1` over two standbys (owner).
- From r63g, not re-voted here: STOP A (3-1), S3 B′ (4-0), PA-2 (4-0), PT (carried 4-0), and INV-STO (deleted 0-4).
  STOP, S3 and PA still go to the owner. Comment on them only to report a factual error.
- Every forms-final and forms-r63g text that forms-r63h doesn't amend.

The owner's concern, verbatim: "I don't like to put to much responsability in a infra configuration. what happens if
there is a misconfiguration?"

## Vote

Give each item PICK, ACCEPTABLE or NOT ACCEPTABLE. A PICK or a NOT ACCEPTABLE must quote the MUST it rests on
(file:line), or the forms text, or give a trace. Otherwise it isn't counted. The outcome rules are fixed. In
particular, a spec-internal item carries at 3 of 4 PICKs, or when all four pick it or accept it.

1. **NA′ and NA-sol** (forms-r63h §1). Vote on each.
   - Under S3-B′, is NA-sol unnecessary? Check the manager's source argument, and trace the open in-flight-COMMIT
     case.
   - Under S3-A, is NA-sol needed? Answer yes or no, with a trace.
   - Does C9's unchanged assertion "the primary never holds more of that replica's backends than its pool" still hold
     under NA′, or does it now overclaim?
2. **INV-ADR′** (§2). Vote. Is the corrected case accurate? Does anything in the spec or the forms depend on the
   broader r63g form?
3. **FSW** (§3).
   - **(i)** Answer the reading question, with a quote: does draft `STO-54` already class step 6's promotion as a
     restore, and can the party that starts it know so once the primary is lost? If not, give exactly what it would
     need.
   - **(ii)** Vote FSW-L and FSW-N.
   - Are deposit destinations the window's only irreversible consequence? Check the r63g Q9 candidates (tally.md):
     `API-54`, `API-11`'s 409, the revocation replay, `API-53`'s revision reuse, `LDG-14`'s runway destroy, and
     `OPS-32`'s deletions. FSW-N covers deposits only.
   - Which responses expose a deposit destination?
4. **Test texts T1-T7** (§4). Vote on each. In a pair, PICK at most one. For T1, say whether it should replace the
   r63g sentence or be added beside it.
5. **What each narrowing gives up.** For each one below, say what it was protecting, and whether anything left still
   protects it. If something is lost, give a trace.
   - NA's dropped claim "so a live process never has more backends … than its pool holds".
   - INV-ADR's broader "an allowed failover could discard".
   - INV-STO's deletion: did it cover FSW?
   - The per-read check that FSW-L forgoes.
   - NA-sol's charged budget, if it isn't adopted.
   - Each test that might be dropped.
6. **The owner questions.** Is each one accurate, plain and short? Check every fact in it against the forms or the
   harness. Is any option's cost or misconfiguration line wrong or missing? Give exact wording fixes, and say for each
   whether it changes what an option does.
7. **Argue the strongest case that the FSW trace can't happen as written,** or that it is harmless. This is a
   requested counter-argument, not a vote.
8. **Brief errors.** Check every fact in forms-r63h.md and the owner draft that you rely on, against its source.
   Quote any error.

## Answer format (at most 1500 words)

1. Start with a vote table: item | vote | the quote or trace.
2. Then answer 1-8, one short paragraph each.
3. Then give each fix you propose as exact text, and say whether it changes behaviour.
4. End with `Final:`, one line per voted item.
