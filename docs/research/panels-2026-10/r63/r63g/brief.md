# Reader brief r63g: provisiond-spec, panel C (pv-s4m, synchronous replication). Taking in an external review

You are one of four independent readers. Read, verify and vote. Your working directory is a clone of the spec
repository at `dc5d40d`, branch `panel-c`. **Write nothing in the repository. Do not start any database or
PostgreSQL instance: this is a production host, and the measurements are already done.** Don't hand work to
subagents or background tasks. By minute 35, write a draft answer to
`/var/tmp/provisiond-panel-r63g/<your working directory's name>.draft.md`. That is outside the repository, and it's
the only file you may write. Finish within 55 minutes.

## Files

- `/var/tmp/provisiond-panel-r63e/forms-final.md` ("forms-final"): the voted text so far, with two slots PENDING
  (S2-STOP and S3).
- `/var/tmp/provisiond-panel-r63g/forms-r63g.md`: **the items you vote on**, on top of forms-final.
- `/var/tmp/provisiond-panel-r63g/verify.md`: the manager's verification of the external review's claims against
  the spec, the PostgreSQL 18 docs and source, and the Patroni docs. Each claim is classed NEW, COVERED or WRONG.
- `/var/tmp/provisiond-pgharness/results.md`: a fault-injection harness of three real PostgreSQL 18.6 instances
  (primary + two standbys, `ANY 1 (s1, s2)`, `synchronous_commit = on`). It has a summary table and the verbatim
  transcripts. Cited as H-a … H-f.
- `/var/tmp/provisiond-panel-r63g/owner-questions-draft.md`: the owner questions as they would be asked.
- Sources: `/var/tmp/provisiond-panel-r63f/src/` (PostgreSQL 18 xact.c, syncrep.c, postmaster.c, walsender.c and
  docs; Patroni docs and ha.py) and `/var/tmp/provisiond-panel-r63g/src/` (xlog.c, the failover and timeline docs).
- `/var/tmp/provisiond-panel-r63f/tally.md` and `s3-analysis.md`: the previous round, where S3-A won 4-0 and STOP
  split 2-2.

## Settled, off limits

- Synchronous replication on every commit (owner).
- Three servers, `ANY 1` over two standbys (owner).
- pv-n98 is Form F'. One Run, one PR.
- LOCK-A, from r63f.
- Every forms-final text outside the PENDING slots, except where forms-r63g.md amends it.

The owner's concern for this round, verbatim: "I don't like to put to much responsability in a infra
configuration. what happens if there is a misconfiguration?" and "Both options involve infra. I don't like them.
are we using postgres in a wrong way?"

## Vote on each item

For each item, give PICK, ACCEPTABLE or NOT ACCEPTABLE.
- A PICK or a NOT ACCEPTABLE must quote the MUST it rests on (file:line), or the forms text, or give a trace.
  Otherwise it isn't counted.
- The outcome rules are fixed: a spec-internal item carries at 3 of 4 PICKs, or when all four pick it or accept
  it. A clause that doesn't carry is deleted.

1. **NA**, the sent-COMMIT rule plus its C9 assertion: PICK, ACCEPTABLE or NOT ACCEPTABLE. Check it for
   consistency with `OPS-21` (`03:1731-1795`), including "The settle write that records a stop after `execute`
   returns MUST NOT be cancelled or abandoned by that stop", and with STOP-A and STOP-B.
2. **STOP**: A or B, each one PICK, ACCEPTABLE or NOT ACCEPTABLE. Has NA changed your view? Give one MOVE line if
   it has.
3. **S3**: S3-B', S3-A or S3-AB, each one PICK, ACCEPTABLE or NOT ACCEPTABLE. To pick one, say whether it closes
   this trace (s3-analysis §1 and H-a): both standbys are down, a deposit mint waits, one backend crashes, the
   server reinitializes, the deposit is re-sent and shown, then the primary is lost.
4. **PT**, the timeline clause: PICK, ACCEPTABLE or NOT ACCEPTABLE.
5. **PA**: PA-1 or PA-2, each one PICK, ACCEPTABLE or NOT ACCEPTABLE. Also check: does any current spec text
   already say who starts a promotion, or forbid an automatic restore?
6. **INV**: INV-ADR or INV-STO, each one PICK, ACCEPTABLE or NOT ACCEPTABLE.

## Then answer these, briefly

7. **Deleted safeguards.** For each one below, say what it was protecting, and whether the replacing text still
   protects it. If something is lost, give a trace.
   - **RS's deployment gate.** S3-B' replaces it. Think about connections that aren't a component's: the migrator
     (`STO-12`), the startup-lock connection (`OPS-47`), an operator's session.
   - **C7's per-replica cap.** NA replaces it.
   - **`restart_after_crash = off`.** r63f's pick, which S3-B' drops.
   - **The transaction-mode pooler allowance,** and `CNF-56`'s "MUST force a backend reassignment where a pooler is
     present".
8. **Can the checks catch the plausible wrong builds?** For each build below, name the `CNF` assertion, as forms
   amend it, that goes red. Or say that none does.
   - (a) A connection check that commits a row instead of reading positions.
   - (b) A check that falls back to an unchecked connection on timeout.
   - (c) A transaction-mode pooler in front.
   - (d) An HTTP framework that drops the database task when the client disconnects mid-COMMIT.
   - (e) A promotion procedure that ranks standbys by `pg_last_wal_receive_lsn()`.
   - (f) A promotion that compares LSNs across timelines.
9. **Argue the strongest case** for dropping S3-B' and S3-A altogether. Instead, certify only the responses that
   show a deposit (`API-45`'s re-send, `GET /v1/deposits/{id}`) with a same-transaction barrier. That means reading
   it and writing a row in one transaction, and answering only after an acknowledged COMMIT (H-d2). Then name any
   read path that would lose money or break a quoted MUST under it. This is a requested counter-argument, not a
   vote.
10. **The scope split.**
    - Is anything in F1-F4 needed for safety in this change?
    - Is anything carried in pv-s4m droppable?
11. **The owner questions.** Is each one accurate and short? Is there a missing behaviour choice? For example,
    must a customer's read survive a failover, and does any text depend on the answer? Give exact wording fixes.
12. **Brief errors.** Check every fact in forms-r63g.md and verify.md that you rely on, against its source. Quote
    any error.

## Answer format (at most 1500 words)

Start with a vote table: item | vote | the quote or trace. Then 7-12, one short paragraph each. Then give any fix
you propose, as exact text, and say for each whether it changes behaviour. End with `Final:`, one line per item.
