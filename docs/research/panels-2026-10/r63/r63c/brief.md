# Panel brief r63c: last read of panel C's two forms (pv-s4m, pv-n98). 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of `provisiond-spec`
at `dc5d40d`. Read `AGENTS.md` first. You MAY edit tracked files in the clone to test a claim. Write nothing outside
it. Never commit, push, call a provider API, or run `br`. **Run no gate and no `lake`.** Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft by minute 10. A web lookup is allowed only for
postgresql.org documentation, quoted.

Round r63b read forms S and F (answers: `/var/tmp/provisiond-panel-r63b/{fable,opus,astra,sol}.md`; tally:
`/var/tmp/provisiond-panel-r63b/tally.md`). S was accepted 3-1, F 2-2, and D was omitted 4-0. Below are the two
forms as amended by those answers. Spans that changed since r63b are marked **[r63c]**. Read each form whole: it
is the text the owner will be asked to approve.

## Settled (not for re-vote)

- Q1: a promotion is a `STO-54` restore, a planned switchover included. The record is committed before any
  component process connects. `OPS-15`'s ", nor on a store that may have lost committed writes, such as a
  promoted asynchronous standby" is deleted. There will be a new `CNF-365` and a new `ADR-0045`. D (a timeline
  check) is omitted.
- Q2: `OPS-15`'s pass over `running` rows runs at every startup. Step (2)'s mark keeps only step (2) from running
  again. While the record is open, the create exception stays off. Q2b: once the freeze has lifted for the
  exception, a parent found `running` is returned to `queued`.

## Why S changed (r63b, opus; verified at dc5d40d)

- S said "the promotion of an asynchronous standby", but the set calls its one standby synchronous:
  `00-overview.md:338` "a stalled synchronous standby"; `:405` "Synchronous standby name".
- `05-persistence.md:147` reads "`synchronous_commit` is `local` on every connection and `on` inside exactly two
  transactions", and `:149-150` "against the standby `OVR-19` names".
- `05:1474` reads "The deployment runs asynchronous streaming replication".
- Opus's trace: a create commits step 8 under `local`, then the named standby is promoted. Someone reads S as
  covering only "an asynchronous standby", treats the boot as a restart, and the create settles `failed` with
  its commitment released while the provider holds the order.
- S' deletes "asynchronous".

## Why F changed (r63b, astra and sol; fable as a note; verified)

- F6 re-keyed `step_quarantined_restore` to `stepTwoMarked`. But `World.quarantined` (`Restore.lean:703`) is
  false once a fresh create is admitted after step (3).
- `World.safe` (`:506`) holds there. `claim` sets `secondOrder := w.secondOrder || (irreversible o.kind &&
  o.applied)` (`:440`).
- F8 is opus's non-blocking note on `03-operation-lifecycle.md:1686-1688`.

## Form S' (pv-s4m)

- S1, `STO-5`'s note becomes: "*A restore from backup is not a restart and is not covered by this sentence, and
  neither is the promotion of a standby, a planned switchover included: a restore loses an interval, a promotion
  may, and `STO-54` is what governs bringing the engine up on either (`ADR-0023`, `ADR-0045`).*" **[r63c:
  "asynchronous" deleted]**
- S2, `STO-54` gains, after its posture bullets: "- **The promotion of any standby is a restore, the standby
  `OVR-19` names and a planned switchover included**, and the procedure below runs whether or not the promotion
  lost a write. **[r63c: bold sentence]** The deployment MUST stop every engine and `api` process that ran against
  the old primary, and MUST keep the supervisor (`OPS-47`) and every `api` process from connecting to the promoted
  store until the restore record (`STO-56`) is committed into it; only a process started after that commit
  connects, since `STO-56` says “The startup read above is taken once per process”. The restore instant is one
  the deployment can evidence: `pg_last_xact_replay_timestamp()` read on the promoted store before it is first
  restarted, where it is not null, and otherwise an earlier instant the store is shown to hold, such as a verified
  backup's. Without one, both components stay stopped."
- S3, `STO-56`: "written into the restored store before either component is started" becomes "written into the
  restored or promoted store before either component is started".
- S4, `OPS-15`: the deletion settled above.
- S5, `CONTEXT.md`'s **Restore**: "Bringing the store back from a backup, landing at some instant before the
  failure." becomes "Bringing the store back from a backup, landing at some instant before the failure, or
  promoting a standby, which may (`STO-54`)." **[r63c: "asynchronous" deleted]** S5b **[r63c, new]**:
  `CONTEXT.md:186`'s "a restore loses an interval" becomes "a restore may lose an interval".
- S6, `Restore.lean`'s module doc: "What the model omits: the promoted-standby condition and the money release."
  becomes "What the model omits: the money release. A promoted standby is a `RestoreTrace` (`STO-54`)."
- S7, `ADR-0045` records the decision and amends `ADR-0042`, which quotes the deleted clause. It quotes the
  PostgreSQL sources. It records two rejected options. B: a planned switchover proven lossless is a restart.
  It quotes 26.2.8.1's sentences whole **[r63c]**: "Users will stop waiting if a fast shutdown is requested.
  However, as when using asynchronous replication, the server will not fully shutdown until all outstanding
  WAL records are transferred to the currently connected standby servers." D: the timeline check **[r63c]**.
- S8, new `CNF-365`: "**A promoted standby is a restore** (`ADR-0045`). **[r63c: "asynchronous"
  deleted]** With both components running, cut the standby off the replication stream; let one create commit
  step 8 and order, and let a second be claimed and order, so the standby lacks the first's step-8 write and the
  second's claim; drive `CNF-295`'s lost-interval witnesses; kill the primary and promote the standby by the
  deployment's procedure. Race a supervisor restart of the engine and an existing `api` pool's reconnect against
  the promotion: assert neither connects to the promoted store before the record commits, and every process that
  does was started after it. Assert the record's restore instant is the one the procedure evidenced; both creates
  are `needs_reconciliation` with their commitments open, neither `failed` nor ordered again; and `CNF-295`'s
  restore assertions hold. Repeat as a planned switchover through the same procedure. (`STO-5`, `STO-54`,
  `STO-56`, `OPS-15`)"

## Form F' (pv-n98 with A1)

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
  - **[r63c, replaces "`step_quarantined_restore` is re-keyed to `stepTwoMarked`"]** `step_quarantined_restore`'s
    invariant `w.passDone = true → w.quarantined` becomes `w.stepTwoMarked = true → w.safe` (`World.safe`,
    `Restore.lean:506`). It is proved over the extended event set, fresh admission and provider application
    included. A fresh admission takes an unused operation id with `applied = false`. Its `secondOrder = false`
    conclusion is unchanged. `passOp_restore_quarantines` stays as step (2)'s own quarantine result.
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
- F8 **[r63c, new]**, `03-operation-lifecycle.md:1686-1688`: the comment on `run_startup_pass` ("suspend_tenant ->
  queued on restart; after a restore they wait, STO-54, and the queued irreversible kinds are quarantined") becomes
  "suspend_tenant -> queued on restart, and on a restore once STO-54's freeze has lifted for it (until then they
  wait); the queued irreversible kinds are quarantined only while step (2) is unmarked, STO-54", reflowed to the
  block's columns.

## Answer

- **S':** ACCEPT or CANNOT ACCEPT. **F':** ACCEPT or CANNOT ACCEPT. Nothing else is counted. This is the last
  round.
- A CANNOT ACCEPT names the normative content the form loses or makes wrong (quote the MUST/SHOULD with
  file:line), or a trace that breaks it, and gives replacement text for that span only. A CANNOT ACCEPT that
  names neither is recorded but does not block. Wording preferences are not counted.
- List wrong facts under "Brief errors", with the grep or quote that shows each one.

**Total: at most 250 words.**
