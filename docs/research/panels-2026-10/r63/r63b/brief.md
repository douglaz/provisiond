# Panel brief r63b: confirmation read of panel C's two forms (pv-s4m, pv-n98). 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of `provisiond-spec`
at `dc5d40d`. Read `AGENTS.md` first. You MAY edit tracked files in the clone to test a claim. Write nothing outside
it. Never commit, push, call a provider API, or run `br`. **Run no gate and no `lake`.** Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft by minute 12. A web lookup is allowed only for
postgresql.org documentation, quoted.

Round r63 (four readers, `/var/tmp/provisiond-panel-r63/{fable,opus,astra,sol}.md`, tally in `tally.md` there)
agreed in substance on both questions. The forms below merge their texts. No reader has read them whole. That is
this round's job.

## Settled (not for re-vote)

- Q1: every promotion of an asynchronous standby, a planned switchover included, is a `STO-54` restore; the record
  is committed before any component process connects; `OPS-15`'s ", nor on a store that may have lost committed
  writes, such as a promoted asynchronous standby" is deleted; a new `CNF-365`; `ADR-0045`. (4-0.)
- Q2: `OPS-15`'s pass over `running` rows runs at every startup; step (2)'s mark keeps only step (2) from running
  again; while the record is open the create exception stays off. (4-0.) Q2b: A1, a parent found `running` after
  the freeze has lifted for the exception is returned to `queued`. (4-0.)
- Facts verified on postgresql.org (current docs): `pg_last_xact_replay_timestamp()` "If no transactions have been
  replayed during recovery, the function returns `NULL`", "If recovery has completed then this will remain static
  at the time of the last transaction applied during recovery", "When the server has been started normally
  without recovery, the function returns `NULL`"; 26.2.8: "If the primary server crashes then some transactions
  that were committed may not have been replicated to the standby server, causing data loss".

## Form S (pv-s4m)

- S1, `STO-5`'s note becomes: "*A restore from backup is not a restart and is not covered by this sentence, and
  neither is the promotion of an asynchronous standby, a planned switchover included: a restore loses an
  interval, a promotion may, and `STO-54` is what governs bringing the engine up on either (`ADR-0023`,
  `ADR-0045`).*"
- S2, `STO-54` gains, after its posture bullets: "- **The promotion of an asynchronous standby is a restore, a
  planned switchover included**, and the procedure below runs whether or not the promotion lost a write. The
  deployment MUST stop every engine and `api` process that ran against the old primary, and MUST keep the
  supervisor (`OPS-47`) and every `api` process from connecting to the promoted store until the restore record
  (`STO-56`) is committed into it; only a process started after that commit connects, since `STO-56` says “The
  startup read above is taken once per process”. The restore instant is one the deployment can evidence:
  `pg_last_xact_replay_timestamp()` read on the promoted store before it is first restarted, where it is not
  null, and otherwise an earlier instant the store is shown to hold, such as a verified backup's. Without one,
  both components stay stopped."
- S3, `STO-56`: "written into the restored store before either component is started" becomes "written into the
  restored or promoted store before either component is started".
- S4, `OPS-15`: the deletion settled above.
- S5, `CONTEXT.md`'s **Restore**: "Bringing the store back from a backup, landing at some instant before the
  failure." becomes "Bringing the store back from a backup, landing at some instant before the failure, or
  promoting an asynchronous standby, which may (`STO-54`)."
- S6, `Restore.lean`'s module doc: "What the model omits: the promoted-standby condition and the money release."
  becomes "What the model omits: the money release. A promoted standby is a `RestoreTrace` (`STO-54`)."
- S7, `ADR-0045` records the decision and amends `ADR-0042`, which quotes the deleted clause. It quotes the
  PostgreSQL sources. Under rejected options it records B (a planned switchover proven lossless is a restart; 26.2.8.1:
  "the server will not fully shutdown until all outstanding WAL records are transferred to the currently
  connected standby servers"), and D if this round rejects it.
- S8, new `CNF-365`: "**A promoted asynchronous standby is a restore** (`ADR-0045`). With both components
  running, cut the standby off the replication stream; let one create commit step 8 and order, and let a second
  be claimed and order, so the standby lacks the first's step-8 write and the second's claim; drive `CNF-295`'s
  lost-interval witnesses; kill the primary and promote the standby by the deployment's procedure. Race a
  supervisor restart of the engine and an existing `api` pool's reconnect against the promotion: assert neither
  connects to the promoted store before the record commits, and every process that does was started after it.
  Assert the record's restore instant is the one the procedure evidenced; both creates are
  `needs_reconciliation` with their commitments open, neither `failed` nor ordered again; and `CNF-295`'s
  restore assertions hold. Repeat as a planned switchover through the same procedure. (`STO-5`, `STO-54`,
  `STO-56`, `OPS-15`)"
- Left out, to be filed for later triage and not voted here: astra's "A candidate containing an open restore
  record MUST remain unavailable to both components" (a second loss while a record is open).

**D (one reader of four, an add-on to S):** "The engine records the store's timeline in the store at each start;
where the timeline it reads differs from the one recorded and no restore record is open, it MUST exit non-zero
having done no work. `api` MUST refuse the same way at its startup read, and MUST exit when a connection it opens
reports a timeline other than that read's." Verified: 25.3.6 "Whenever an archive recovery completes, a new
timeline is created". Not verified: that page does not say a promotion creates one. Its proposer notes that
`pg_control_checkpoint()` can still show the old timeline just after a fast promotion. Opus voted against it ("D
covers only the engine"). Astra and sol did not take it up.

## Form F (pv-n98 with A1)

- F1, `OPS-15`'s record paragraph gains: "**The pass over `running` rows runs at every startup, the record open
  or not.** `OPS-5` says a `running` operation "stays claimed until it settles, defers under `OPS-8`, or the
  startup pass finds it (`OPS-15`)", and a dead worker does neither of the first two. A marked step (2) keeps only
  its own work from running again (`STO-54`). While the record is open the create exception stays off, so a
  create found `running` goes to `needs_reconciliation`, and a `suspend_tenant` parent follows the restore rule
  above."
- F2, `OPS-15`'s restore paragraph: "And the `suspend_tenant` exception below does not fire on a restore:" becomes
  "And the `suspend_tenant` exception below does not fire on a restore while `STO-54`'s freeze holds it off:".
  After that sentence ("… may have been reversed inside the interval."), add: "Once that freeze has lifted for
  the exception, a parent found `running` is returned to `queued` with no second confirmation."
- F3, `OPS-15`'s parent paragraph: "*on a restart; after a restore it waits, above (`STO-54`)*" becomes "*on a
  restart, and on a restore once `STO-54`'s freeze has lifted for the exception; until then it waits, above
  (`STO-54`)*".
- F4, `API-58`: "*after a restore it waits for one (`STO-54`, `OPS-15`)," becomes "*after a restore it waits for
  one while `STO-54`'s freeze holds the exception off (`STO-54`, `OPS-15`),".
- F5, `STO-54`'s step (2) gains at its end: "Its mark keeps this step from running again; it never suppresses
  `OPS-15`'s pass over `running` rows, which runs at every startup."
- F6, `Restore.lean`:
  - `World.stepTwoMarked` is the record's mark, which `afterCrash` keeps. `passDone` becomes this process's pass,
    which `afterCrash` clears.
  - `startupPass` runs the `running` arms once per process, and the `queued` quarantine only while step (2) is
    unmarked, then marks it.
  - `permits.claim := w.locked && w.passDone && (!w.fault.isRestore || w.stepTwoMarked)`.
  - `completeProcedure` and `confirmParents` read `stepTwoMarked`.
  - `passOp`'s `suspendTenant` arm reads `(permits p w).run .suspendTenantException`.
  - `step_quarantined_restore` is re-keyed to `stepTwoMarked`.
  - New events admit fresh work after step (3) and apply it at the provider, so a create admitted after the
    restore is expressible. `quarantine_before_first_claim`'s conclusion is kept, and its doc becomes true.
  - A guard `Params.passEveryStartup`, a theorem `successor_sweeps_running` (after `.crash, .lock,
    .startupPass`, no row is `running` but a parent the freeze holds), a witness refuting it with the guard off
    (a power operation claimed after step (2), then a crash), and its `ci.yml` control (`DEF-16`).
- F7, `CNF-295`'s second kill (after step (3)) gains: "Before it, claim a create and a power operation. Assert the
  successor, before any claim, moves both to `needs_reconciliation` and leaves a create queued after step (3)
  `queued`, and that a delete queued on the power operation's machine is then claimed. Again after
  `grace_ends_at`, with every waiting parent confirmed, kill the engine with a confirmed parent claimed: the
  successor returns it to `queued` and it resumes with no second confirmation."

## Answer

- **S:** ACCEPT or CANNOT ACCEPT. **D:** ADD or OMIT. **F:** ACCEPT or CANNOT ACCEPT. Nothing else is counted.
- A CANNOT ACCEPT names the normative content the form loses or makes wrong (quote the MUST/SHOULD with file:line),
  or a trace that breaks it, and gives replacement text for that span only. A CANNOT ACCEPT that names neither is
  recorded but does not block. Wording preferences are not counted.
- For D, one line of reason.
- List wrong facts under "Brief errors", with the grep or quote that shows each one.

**Total: at most 350 words.**
