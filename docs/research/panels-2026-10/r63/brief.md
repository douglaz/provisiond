# Panel brief r63 (panel C): a store that may have lost writes, and the startup pass inside an open restore — pv-s4m, pv-n98. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the specification
repository `provisiond-spec` at `dc5d40d` (master `48287ec` plus one bead). Read `AGENTS.md` first. `br show
pv-s4m pv-n98` prints the two beads (if `br` fails, `.beads/issues.jsonl` holds them). You MAY edit tracked files
in this clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a
provider API. **Run no gate and no `lake` this round**: the host takes at most two Lean builds at once, and the
manager builds the chosen form afterwards. Keep `TMPDIR` as set. Do not delegate, background or wait on anything:
do the work yourself in this session. Have a draft answer by minute 25. A web lookup is allowed only to cite a
PostgreSQL primary source (postgresql.org documentation), and you must quote what you cite.

Every quote below was grepped at `dc5d40d`. The manager has still been wrong in briefs before, so check any fact
you rely on and report each error under "Brief errors". Read text by requirement id, not by line number.

## Settled (off-limits)

- `STO-54`'s posture stays asynchronous: "Synchronous commit on every write was rejected because PostgreSQL has no
  server-side timeout for the standby wait". `ADR-0023`: "The engine's write path never waits." No option may
  make a write `OPS-43` or `api` performs wait on a standby.
- `STO-54`: "The number is not the safety argument: a create dispatches in one second, a deposit mints in one, an
  extension lands in one. The procedure's order below is." An option keyed to replication lag must answer this.
- `OPS-15`'s create exception: "**It does not fire while a restore record is open** (`STO-54`, `STO-56`)" and "This
  restriction lasts for the whole open incident, independently of the freeze's end." (pv-k4l, owner.) What is in
  play is only the clause between them: "nor on a store that may have lost committed writes, such as a promoted
  asynchronous standby".
- `STO-54`'s procedure, its three steps, the record and its close rule (`STO-56`) stand as written, except where a
  draft below amends them.

## Governing text (verbatim)

- `STO-5`: "The store MUST survive process restart with no loss of queued or running operations. *A restore from
  backup is not a restart and is not covered by this sentence: it loses an interval, and `STO-54` is what governs
  bringing the engine up on it (`ADR-0023`).*"
- `STO-54`: "A store restored from backup lands at some instant `T − Δ` before the failure"; "The deployment runs
  asynchronous streaming replication and continuous WAL archiving"; synchronous commit "inside the deposit mint
  and `STO-30`'s payment-credit transaction, against a named standby, and `local` everywhere else".
- `STO-54`'s step (1) begins "*Before the startup lock:* the public listener is down; the lost window `T − Δ` is
  stated as a number and published to the operator". Step (2): "every `queued` create, install and rescue
  inventory is moved to `needs_reconciliation`", and "a `suspend_tenant` parent found `running`, or `queued` and
  unsettled (`OPS-49`'s waiting parent is `queued`), waits for operator confirmation instead of resuming". Step
  (3): "every tenant's credential generation is bumped — the restored store cannot know which tenants revoked
  inside Δ, so every spending token dies and each customer re-issues through the recovery credential (`API-56`)".
- `STO-54`, the record: "a process that starts while a restore record is open is continuing that incident, not
  restarting"; "It resumes at the first step the record does not mark"; "**A marked step does not run again**";
  "The operator closes the record only under `STO-56`'s close rule …, after which a process that starts is an
  ordinary restart." The freeze covers "`OPS-15`'s `suspend_tenant` exception", and "the freeze lifts at
  `grace_ends_at` …, except the exception, whose own later condition stands on top: it stays off until the
  operator has confirmed or cancelled every waiting parent".
- `STO-56`: the record is "written into the restored store before either component is started and closed by the
  operator"; "Both components read the open row before anything else they do"; "The startup read above is taken
  once per process".
- `OPS-15`: "at startup, before any claim, the engine MUST move every `running` operation to
  `needs_reconciliation`"; "nothing but a restart can leave a `running` row with no worker behind it"; "So on a
  restore (`STO-54`) the pass additionally moves every `queued` create, install and rescue inventory to
  `needs_reconciliation`"; "And the `suspend_tenant` exception below does not fire on a restore"; "the successor
  of a process that died inside the procedure takes the restore branch, with the rest of the procedure it
  inherits".
- `OPS-5`: "a `running` operation stays claimed until it settles, defers under `OPS-8`, or the startup pass finds
  it (`OPS-15`)". `OPS-8`: a claim the per-machine index refuses "MUST return the operation to `queued` with a
  short delay rather than fail it — the conflicting work will finish."
- `OPS-47`: "The engine MUST run as exactly one process under an external supervisor that restarts it and never
  runs two", and of the lock's connection, "where the connection carrying it is lost it MUST exit."
- `Restore.lean`: `passDone` is "`OPS-15`'s pass run: step (2) done, a mark of the record"; `permits` gives
  `claim := w.locked && w.passDone`; `startupPass` runs only `if w.locked && !w.passDone`; `afterCrash` sets only
  `fault`, `now` and `locked := false`. The doc of `quarantine_before_first_claim` says "a successor that comes
  up while the record is open repeats the pass before it claims". The module doc says "What the model omits: the
  promoted-standby condition and the money release."
- `CNF-295` kills the engine "once after the record is committed and before step (2)'s mark commits, and once
  after step (3)'s" and asserts of the second "that it repeats no marked step". `CNF-358`'s restore control
  repeats "after a crash before the startup pass, and after the freeze lifts while the record remains open".

## Facts the manager checked

- `promot` appears in the requirement files only in `OPS-15`'s off-switch above (and `ADR-0042` quotes it).
  pv-s4m's body predates that clause. So the gap is not that an engine *would* fail the create: the text already
  says the exception does not fire on such a store, but no engine can recognise one, so the clause has no input,
  no checklist item, and no end.
- No rule makes `api` exit, or re-read the record, when it loses a store connection. Only the engine exits
  (`OPS-47`). So an `api` replica whose pool reconnects to a promoted store serves on it having read no record.
- A `running` row stranded with no worker holds its commitment and, through `OPS-8`, defers every later claim on
  its machine, a delete included: "the conflicting work will finish" never happens.
- Next free ids: `CNF-365`, `ADR-0045`.

## Questions

For each, answer **ACCEPT A**, **AMEND A** (give the exact replacement text and say "behaviour unchanged" or
"behaviour changed"), or **CANNOT ACCEPT A** (name the option you pick, or give your own form). A CANNOT ACCEPT
names the normative content A loses or makes wrong, or a trace that breaks it. Then list the ids your pick touches
and label the question **mechanics** or **owner** (a scope or product call), with one line of reason. **At most
150 words per question**, not counting drafted text. Drafted citations that hold a straight-quoted value use curly
outer marks (“…”).

**Q1 (pv-s4m): is a promoted asynchronous standby a restore, and what opens the incident?**
A concrete case: at 10:00:01 a create commits step 8 with `local` commit; at 10:00:02 the order goes out; at
10:00:03 the primary dies before the standby received step 8, and the standby is promoted. On the new primary the
create is `running` with a null `about_to_order_at`, or `queued` if the claim was lost too. Read as a restart, the
`queued` one orders a second time, which is `STO-54`'s own example, and an engine that fires the create exception
fails a create whose order the provider holds.
Draft A:
- `STO-5`'s note becomes: "*A restore from backup is not a restart and is not covered by this sentence, and
  neither is a store promoted from an asynchronous standby after its primary failed: each may lack writes the
  primary committed, and `STO-54` is what governs bringing the engine up on it (`ADR-0023`, `ADR-0045`).*"
- `STO-54` gains, after its posture bullets: "**A promoted asynchronous standby is a restore.** Under `local`
  commit a standby promoted after its primary failed may lack writes the primary committed, the loss of a
  backup's interval by another route; its restore instant is the commit time of the last transaction it
  replayed. The deployment MUST commit the restore record (`STO-56`) into the promoted store before any process of
  either component connects to it. `STO-56` says “The startup read above is taken once per process”, so an `api`
  replica whose pool reconnects across the promotion, or an engine its supervisor (`OPS-47`) restarts against the
  promoted store first, runs on it as a restart."
- `OPS-15` deletes ", nor on a store that may have lost committed writes, such as a promoted asynchronous
  standby": such a store has an open record, which ends under `STO-56`'s close rule.
- A checklist item drives it: `CNF-295` repeats its rehearsal on a promoted standby, or a new `CNF-365` does
  (say which, and what it asserts).
- Cost, stated: every promotion, a planned switchover included, runs the whole procedure. The listener is down
  until step (3), queued creates, installs and rescue inventories are quarantined, and every spending token dies.

Alternatives:
- B: A, except that a promotion is a restart where the deployment establishes that the promoted store holds every
  write the old primary committed. If you pick B, name the mechanism with a PostgreSQL primary source, quoted,
  and say how a checklist item drives both branches.
- D (an add-on to A or B): the engine refuses to start, exiting non-zero having done no work, on a store whose
  identity changed since it last ran, unless a restore record is open. If you pick D, name the signal with a
  primary source, quoted, and say what a restore from backup and a planned switchover each do to it.

Also say: is "the commit time of the last transaction it replayed" a usable restore instant, given step (1)'s
"stated as a number"? And does A's "before any process of either component connects" ask for something a
deployment can do, given `OPS-47`'s automatic restart?

**Q2 (pv-n98): on a startup while the record is open and step (2) is marked, does `OPS-15`'s pass over `running`
rows run?**
A concrete case: after step (3) the freeze lifts and the record stays open. A create and a power operation are
claimed; the engine crashes mid-order. The successor continues the incident. Engine A runs the pass. Engine B reads
step (2) as marked and skips it, so both rows stay `running` with no worker: the create's commitment stays held,
and the machine's later delete defers under `OPS-8`.
Draft A:
- `OPS-15` gains, in its record paragraph: "**The pass over `running` rows runs at every startup, the record open
  or not.** Only `STO-54`'s step (2) quarantine of `queued` rows is the step a mark keeps from running again:
  nothing but this pass moves a `running` row a crash left behind (`OPS-5`). While the record is open the pass
  takes the restore branch: a create found `running` goes to `needs_reconciliation`, and a `suspend_tenant` parent
  found `running` waits for operator confirmation while `STO-54`'s freeze holds the exception off."
- `STO-54`'s step (2) gains: "The quarantine is the step; `OPS-15`'s pass over `running` rows is not part of it and
  runs at every startup."
- `Restore.lean`: `World` gains `stepTwoMarked`, the record's mark, which `afterCrash` keeps, while `passDone`
  becomes this process's pass, which `afterCrash` clears. `permits.claim` needs both. `passOp`'s `queued` arm
  quarantines only while step (2) is unmarked. The doc at `quarantine_before_first_claim` is then true.
- `CNF-295`'s second kill (after step (3)) gains: before it, claim a create and a power operation; assert the
  successor moves both to `needs_reconciliation`, and leaves a create queued after step (3) `queued`.

Alternatives:
- B: step (2)'s mark covers the whole pass, which is the model's current reading. A successor with the mark set
  runs no pass, and a `running` row a crash left behind waits for the first restart after the record closes.
- C: `afterCrash` clears `passDone`, so the whole pass, quarantine included, runs at every startup while the
  record is open. This re-runs a marked step and parks a create queued after step (3) with an error naming the
  restore.

**Q2b (a sub-vote under A): a `suspend_tenant` parent found `running` by such a pass after the freeze has lifted
for it** (`grace_ends_at` passed and every waiting parent confirmed). A1: it is returned to `queued`, because the
exception is no longer frozen. A2: it waits for the operator while the record is open, because `OPS-15` says the
exception "does not fire on a restore". Pick one, and say which text then needs an edit. A's parent clause is
written as A1; picking A2 amends it, and that AMEND counts here, not against Q2's A.

**Q3.** Should pv-s4m and pv-n98 land in one Run? Answer in one line.

**Against my picks (written on request).** For each question, give the strongest argument against your own pick,
in at most 60 words, labelled as written on request.

**Brief errors.** List any fact above that is wrong, with the grep that shows it.

**Total answer: at most 900 words.**
