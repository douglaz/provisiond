# Panel brief: the codex bot's crash-recovery finding on Robot's one-shot post-order read (PR #3), 2026-10-15

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `74ad5f7` (branch `robot-live-2026-10-12`, PR #3). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`).
You may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Never call a provider API.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves machinery rather
than tuning it; check this framing too, and verify every fact stated below before relying on it.

## Context

`ADR-0037`'s 2026-10-14 amendment (Q31) made Robot's post-order cancellation read (`PRV-13c`) one attempt at
create settlement: "a failed read of any kind ... does not change the create's settlement", "the read is not
retried", and a later accepted cancellation's response supplies the per-machine date. As applied, `PRV-13c`
(02-provider-contract.md) says the read "MUST NOT be retried; a resolution pass, a refresh and the sweep MUST NOT
read that machine's cancellation constraint again", "The system MUST record a successful post-order read's date
in `machines.earliest_cancellation_date`", and "After a failed post-order read, the column MUST remain null";
`OPS-27` (03-operation-lifecycle.md) puts the column write, date or null, in the landed-order transaction with
the machine row, at all three entry points; `CNF-356` tests it.

The PR's codex review bot has found one new P1 per round for four rounds (each fixed so far). Round four, on
`02-provider-contract.md`'s `PRV-13c`:

> **Make the one-shot read crash-recoverable.** If the process crashes after the post-order constraint read
> succeeds but before the landed-order transaction commits, the returned date has no durable home—the only
> specified destination is the machine row written by that later transaction. Recovery therefore cannot
> distinguish an already-issued successful read from one not yet attempted: it must either repeat the read in
> violation of this prohibition or write null despite the requirement to record a successful result,
> potentially omitting the protected cancellation term. Specify a durable attempt/result record or another
> crash-safe protocol for this window.

My proposed fix (two lines, no new machinery): in `PRV-13c`, "a read whose result is lost before the
landed-order transaction commits is a failed read" — column null, no re-read, the cancellation response
supplies the date later — plus one `CNF-356` line.

## What I need from you

1. Is the finding real? Trace what the spec says happens on a crash in that window today: how does the create
   resume (`OPS-27`, `OPS-36`, `STO-55`, `LDG-69`, any crash/restart rule), does it reach the read again, and
   does any requirement already settle it?
2. Compare the fixes: (a) mine — a lost result is a failed read; (b) a durable attempt/result record; (c)
   allowing exactly one re-read when recovery finds no committed result (what bounds the cost on Robot's
   shared `/server` counter?); (d) anything simpler the spec already supports. Which is consistent with Q31's
   decision and the owner's preference for less machinery? Does (a) need an owner decision, or does Q31's
   "a failed read of any kind" already cover it?
3. The ratchet: four rounds, one new valid P1 each, all on text this branch added. Sweep the branch's new or
   changed text for Q31 (`PRV-13c`, `OPS-11`, `OPS-27`, the `earliest_cancellation_date` column row,
   `CNF-147`/`CNF-356`) for any OTHER defect of the same weight a careful reviewer would raise next, so it can
   be fixed in one pass. List only real defects, with the text that fails and why.
4. Your recommendation for the PR: fix this (and anything from 3) then merge on the next clean gate; or record
   it as a follow-up and merge now; or something else — with the reason.
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   recommendation. It is not your position.

Under 600 words. Cite `file:line` or identifiers for every claim.
