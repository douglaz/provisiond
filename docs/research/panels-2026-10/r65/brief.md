# Panel brief r65 (panel D): one merged record-first form and one completed exit-at-once form for a lost startup-lock connection — pv-buc. 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `b90783d` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**:
the manager builds the chosen form afterwards. Keep `TMPDIR` as set. Do not delegate, background or wait on
anything. Have a draft answer by minute 25. A web lookup is allowed only for postgresql.org documentation, quoted.

Round r64b (four readers) picked R 4-0, but two readers blocked R as written with the same verified defect, and the
tally was voided by a false story in the brief (correction 1). This round reads **one merged R**, carrying both
blocking readers' repairs, and **one completed E**. **No reader has read either whole. That is this round's job.**
Every quote was grepped at `b90783d`, but the manager has been wrong in briefs before: **check every claim this
brief makes before you rely on it**, and report each error under "Brief errors". Read text by requirement id, not by
line number (line refs below are hints).

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the form
flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and requirement id)
together with a trace that breaks it. Give replacement text for that span only. A CANNOT ACCEPT that names none is
recorded but does not block. Wording you dislike is not counted.

## Corrections to r64b's brief (verified)

1. **The `correlator: none` story was false.** r64b said that under E such a create, already accepted by the
   provider, goes to an operator, implying R avoids it. `OPS-27`: "**A create MUST NOT settle `succeeded` on the
   strength of the reply in hand alone.** … **After acceptance, zero or many resources, a failed search, or any
   non-authoritative search MUST leave the create in `needs_reconciliation`**", and its table row: "no verified
   correlator exists for the operation's ordering channel (`PRV-33`) | **Unresolved.** Escalate to an operator".
   `OPS-21` puts that search inside `execute`. So on that channel no create reaches a verified outcome inside
   `execute`, and it reaches an operator **under both forms**. Nothing separates R from E there.
2. **R as written broke a MUST.** Its `OPS-21` sentence "For a worker in `execute` it is the cancellation being
   recorded" made a loss during a verified create's post-order read a cut-off `conflict`. `OPS-21`: "A stop the
   engine survives after a create's settle-time confirming read succeeds, or after a delete's cancellation is
   accepted with an effective date, and before `execute` returns MUST NOT cancel `execute`." `CNF-362`'s cases for
   these reads assert "no `needs_reconciliation` and no `cut_off`". R's Q1b and `CNF-366`(i) also said every worker
   in `execute` records a cut-off `conflict`, but a cancelled `suspend_tenant` parent records the defer, and "It
   records no error". The merged R below repairs all three.
3. **"A sent COMMIT is never abandoned" is `STO-7`'s** ("added 2026-10-23, `ADR-0045`"), not `ADR-0045`'s.
4. **r64b's second-engine trace:** `OPS-22`'s zero-row exit is the worker's, not the whole engine's; and a zero-row
   defer "moves on and does not exit" (`STO-3`). Neither changes the guard claim.
5. **r64's failover point (r64b correction 5)** overstated "ends unrecorded". A record transaction in flight may have
   committed (`CNF-362`: "Accept either outcome"). A failover still does not separate R from E.
6. **"Under E that engine exits and only its successor connects" was wrong.** Before E1 detects the loss it can
   reconnect and retry like any engine.
7. **E was incomplete.** It changed `OPS-21`'s after-return list, which `CNF-362` quotes word for word, and
   `ADR-0044` says "the citation gate fails an edit that drops or changes one". Its new `Event` constructor also
   needs arms in four Lean definitions. The completed E below adds both.
8. `CNF-365`'s quote, re-verified: "each time assert no component uses a connection before a standby has flushed at
   or past the flush position it reported."

## Settled (not for re-vote)

- Q1's label is **owner** (r64, 4-0): may losing the lock cost an outcome already in hand?
- `OPS-21`'s Stop-record bound, its expiry exit, the later-stop exit, the Store-retry exhaustion exit and the
  supervisor's wait stand, except where a form adds to them. `STO-7`'s "A sent COMMIT is never abandoned" and
  `STO-54` stand. `OPS-47`'s supervisor posture stands.
- **Neither form guards a write on the lock.** `OPS-47`: "**The lock is not a fence**: no write is guarded on it,
  holding it proves nothing about the past, and losing it invalidates nothing already written." The optional fences
  in "Misconfiguration" are separate add-ons that would amend this.
- pv-9j6 (the last-row marker rule) converged in r64b and is not in this round.

## Q1 (pv-buc): when `OPS-47`'s lock connection drops, record first or exit at once?

**Governing text.** `OPS-47`: "Before any claim the engine MUST take `STO-51`'s session-scoped advisory lock on a
connection outside the pool and hold it for its lifetime. Where the lock is refused it MUST retry for the stated
bound (`OVR-19`) and then exit non-zero having done no work; where the connection carrying it is lost it MUST
exit." … "It answers one question, once, at boot — is somebody else already here". `OPS-21`: "A cancellation of
`execute` that the engine survives MUST be recorded before the engine exits, for every operation kind, subject to
the bounded abandonment and later-stop exits below." Its later stop: "A later stop, one arriving after the stop
being recorded and before that record lands, ends the record as an exit without worker classification at any
point". `OPS-49`: "**A worker cancelled during the retry loop stops retrying and exits.**" No sentence today orders
`OPS-47`'s exit against `OPS-21`'s record.

**Precedent by rationale (`ADR-0044`), quoted neutrally.** Owner decision 1: "Any stop the engine survives MUST
record the outcome before the engine exits. This covers every operation kind". Rejected there: "**C: must not
record.** Rejected: it discards worker knowledge and substitutes crash recovery even when the process and store can
complete the record". Under Form E the engine does not survive the loss, so whether decision 1 reaches it is the
owner's scope call. `ADR-0019`: "If a deployment ever runs two engines, this system has no defence".

### Where R and E behave differently (the verified cases only)

Every create below is on a channel **with** a verified correlator; on a `correlator: none` channel nothing separates
the forms (correction 1). A cut-off during a provider call ends `needs_reconciliation` under both forms; a kill or a
failover records nothing under both.

- **S1. A create whose `execute` returned success.** A deploy stops the engine; the settle write is repeating under
  `OPS-49` because PostgreSQL is restarting in place, which also drops the lock connection. **R:** the settle write
  lands once the store is back, within the Stop-record bound: `succeeded`, money posted once, then exit. **E:** the
  engine exits on seeing the loss; the row stays `running`; at the next start `OPS-15` moves it to
  `needs_reconciliation`, and `OPS-27`'s correlator search resolves it "as though it had succeeded". A detour, not a
  person.
- **S2. A loss during a create's post-order read, after its confirming read succeeded.** **R:** the stop "MUST NOT
  cancel `execute`"; the read ends as a failed read, which `PRV-13c` says "MUST NOT change the create's settlement":
  `succeeded` with only `earliest_cancellation_date` null, no `cut_off` (`CNF-362`). **E:** as S1's E: parked, then
  auto-resolved at restart.
- **S3. A loss during a delete's direct read, after the provider accepted its cancellation with an effective date.**
  **R:** `succeeded` as `cancellation_scheduled` with that date, no `cut_off` (`CNF-362`, `PRV-13`). **E:** the row
  stays `running`; `OPS-15` moves it to `needs_reconciliation`. Resolution then proceeds by `PRV-29`'s "authoritative,
  non-mutating provider evidence anchored to the machine's known `external_id`", which for a dated cancellation
  "MUST additionally separate *rejected*, *accepted-pending*, *scheduled with an effective date* and *complete*"
  (`PRV-29`), falling back to `OPS-31`'s operator choices where the driver cannot (`OPS-45`). **The manager found no
  rule specific to a parked, already-accepted dated cancellation: check whether it resolves without a person.**
- **S4. A loss before an install's marker write** (no stop pending, nothing dispatched). **R:** cancelled in
  `execute`, a cut-off record classified against the install row with the marker unset: `failed`. **E:**
  `OPS-15` has no install exception (its exceptions are refresh, a null-column create and the parent), so
  `needs_reconciliation`. *If pv-9j6's merged form lands (it is not text at `b90783d`), the same holds for a
  pre-marker power, reverse-DNS, delete or release.*
- **S5. The misconfigured second engine: rows E1 claims after E2's pass.** A deployment wrongly starts E2 while E1
  runs; E2's boot check is refused and it retries within the startup-lock wait bound; PostgreSQL restarts in place,
  E1's lock session ends, E2 takes the lock, runs `OPS-15`'s pass and starts claiming. Before E1 detects the loss it
  runs as normal: it may claim queued rows and call providers. **E:** E1 exits on detection; the rows it claimed
  after E2's pass stay `running` under a live E2 that never sweeps them (`OPS-15`: "nothing but a restart can leave
  a `running` row with no worker behind it"), and each holds its machine through the per-machine index, so E2's
  claims on that machine defer ("the conflicting work will finish") **until E2 restarts**. **R:** E1 claims nothing
  more and records those rows within the Stop-record bound. Rows E1 held *before* E2's pass are decided by the
  guards: E1's record is guarded "on that operation still being `running` under the worker's claim number"
  (`OPS-22`), E2's pass "guarded on `(id, status = running)`" (`OPS-15`); whichever commits first wins, and a
  zero-row record makes that worker log loudly and exit. Under R, for up to the Stop-record bound, E2's boot answer
  ("nobody else is here") is wrong, and periodic passes already running and provider calls outstanding continue.

### Form R (record first), merged

**The merge.** Two readers gave repair spans for R's `OPS-21` sentence and `CNF-366`.
- Repair 1 replaced the whole rest of the sentence: "For a worker in `execute`, the loss follows this requirement's
  stop rules, including the case that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”.
  For one whose `execute` has returned, its settle write records it; the loss ends no record already pending." For
  `CNF-366` it added: "Repeat those absorbed-read and parent cases with lock loss as the stop, asserting their
  respective outcomes."
- Repair 2 swapped one clause: "For a worker still in `execute`, the cancellation, absorbed-read and parent rules
  below apply". For `CNF-366`(i) it narrowed: "while a non-parent worker is in `execute`, outside `OPS-21`'s
  absorbed-read cases".
- **Chosen for `OPS-21`: Repair 2's span, because it changes less** (one clause; R's other clauses stay). "Below"
  is right: the sentence is inserted after the later-stop sentence, above the parent paragraph and the "MUST NOT
  cancel" sentence. One change to it: "absorbed-read" is `CNF-362`'s label and appears nowhere in `OPS-21`, so the
  span names the two rules by Repair 1's quotes instead.
- **Chosen for `CNF-366`: Repair 2's narrowing of (i), plus Repair 1's repeat as a new case (vi).** Repair 2 alone
  only excludes those cases; nothing would then assert them under a lock loss.
- **Also:** one reader's non-blocking fix, "hold it until it begins to exit" (`OPS-47` otherwise keeps "hold it for
  its lifetime" while the engine outlives the loss), and the matching `STO-51` edit.

**Judge whether this merge is right.**

- `OPS-47`: "hold it for its lifetime" becomes "hold it until it begins to exit". Replace "where the connection
  carrying it is lost it MUST exit." with: "where the connection carrying it is lost, the engine MUST claim nothing
  more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each
  under `OPS-21` within its Stop-record bound and exits, and then exit non-zero. The loss is not a later stop: a
  record already pending when the loss is seen continues under its own Stop-record bound and exits."
- `STO-51`: "holds for its lifetime" becomes "holds until it begins to exit".
- `OPS-21`, after the later-stop sentence: "A loss of the connection carrying `OPS-47`'s startup lock is not a later
  stop: `OPS-47` says “treat the loss as a stop of every worker not already recording one”. For a worker still in
  `execute`, the cancellation rules below apply, including the stop that “MUST NOT cancel `execute`” and the parent's
  defer, which “records no error”; for one whose `execute` has returned, its settle write records it; it ends no
  record already pending. A stop that arrives after the loss and before that record lands is a later stop."
- `OPS-49`, its retry-loop bullet gains: "`OPS-47` says of a lost lock connection “The loss is not a later stop”: a
  worker repeating a record when the loss is seen keeps repeating it."
- `ADR-0019`'s restatement takes `OPS-47`'s new words with a dated note. A new ADR (next free id at landing,
  `ADR-0046` today) records the decision.
- `StopRecord.lean`: no new constructor. `Event`'s doc comment gains: "A lost lock connection is the originating
  stop or no event: `OPS-21` says it “is not a later stop”."
- **Q1b, stated by the text:** with no stop pending, the loss is a stop the engine survives for each worker in
  `execute`. A non-parent worker is cancelled and records a cut-off `conflict` under its row (`OPS-11`), except a
  create past its confirming read and a delete past its accepted dated cancellation, which the stop "MUST NOT
  cancel" and which settle as `CNF-362`'s read cases do. A cancelled `suspend_tenant` parent records the defer, with
  no error.
- New `CNF-366`: "**A lost startup-lock connection is a stop of every worker, not a later stop.** `OPS-47` says
  “The loss is not a later stop”. Terminate the lock connection's backend: (i) with no stop pending, while a
  non-parent worker is in `execute`, outside `OPS-21`'s confirmed-read cases; (ii) with no stop pending, while a
  create's after-return settle write repeats under `OPS-49`; (iii) while an earlier stop's cut-off record repeats
  under `OPS-49`. Where a write repeats, the store refuses it until the loss and accepts writes again within the
  Stop-record bound. Assert: no claim and no periodic pass begins after the loss; case (i) records a cut-off
  `conflict` classified against its row (`OPS-11`); the settle write and the earlier record land, the create
  `succeeded` with its money posted once; the engine exits non-zero only after the records land. (iv) Deliver a stop
  after the loss, before a record lands: assert `CNF-362`'s later-stop assertions, including “Accept either
  outcome”. (v) With every transaction refused after the loss, assert exit within the Stop-record bound measured
  from the stop being recorded (the loss, or the earlier stop), the loud log, and `OPS-15` at restart, including its
  exceptions. (vi) Repeat `CNF-362`'s cases for a create past its confirming read, a delete past its accepted dated
  cancellation, and a waiting `suspend_tenant` parent, with the loss as the stop and no stop pending, asserting
  their `CNF-362` outcomes: no `needs_reconciliation` and no `cut_off` for the reads, the defer with no error for
  the parent, and exit only after the settle write or defer lands."

### Form E (exit at once), completed

- `OPS-47`: replace "where the connection carrying it is lost it MUST exit." with: "where the loss of the
  connection carrying it is detected, it MUST exit non-zero at once, whether or not a stop or its record is pending,
  without beginning a stop's record or waiting for one."
- `OPS-21`, its first sentence: "subject to the bounded abandonment and later-stop exits below" becomes "subject to
  the bounded abandonment, later-stop and lock-loss exits below". After the later-stop sentence: "A loss of the
  connection carrying `OPS-47`'s startup lock ends a pending record as an exit without worker classification at any
  point: before the record's first transaction, during it, or while `OPS-49` repeats it. After the loss is seen the
  worker MUST NOT begin or repeat a record transaction; a transaction already sent is the server's to decide, and a
  row still `running` goes to restart recovery (`OPS-15`, including its exceptions)." The after-return list becomes
  "The Stop-record bound and its expiry exit, the later-stop exit, the lock-loss exit, the Store-retry bound's
  exhaustion exit, the lost-reply case and the supervisor's wait apply to …".
- **New: `CNF-362`'s quote of that list** ("`OPS-21` says "The Stop-record bound and its expiry exit, the later-stop
  exit, the Store-retry bound's exhaustion exit, …"") takes the identical insertion, "the lock-loss exit", after "the
  later-stop exit".
- `STO-7`'s "short of its process exiting" already permits this exit with a COMMIT in flight.
- `ADR-0019`'s restatement takes `OPS-47`'s new words with a dated note. A new ADR (`ADR-0046` today) records the
  decision and notes its relation to `ADR-0044`'s decision 1.
- `StopRecord.lean` (**new arms; unbuilt — the manager builds after the round**):
  - `Event` gains `| lockLost`, doc comment: "`lockLost` is the loss of `OPS-47`'s lock connection; it ends the
    record as `laterStop` does."
  - `schedule`: `| .laterStop => {}` becomes `| .laterStop | .lockLost => {}`.
  - `schedule_bounded`: `| laterStop => simp [schedule]` becomes `| laterStop | lockLost => simp [schedule]`.
  - `later_stop_exits` (its prefix case split): `| laterStop => simp [schedule]` becomes
    `| laterStop | lockLost => simp [schedule]`. New `lock_lost_exits` beside it, the same statement with
    `.lockLost` in place of `.laterStop`.
  - `finished_unrecorded_exit`: the disjunct `events[plan.elapsed]? = some .laterStop ∨` (in the statement and in the
    proof's restatement) becomes `events[plan.elapsed]? = some .laterStop ∨ events[plan.elapsed]? = some .lockLost ∨`;
    its arm `| laterStop => simp [schedule, halt]` becomes `| laterStop | lockLost => simp [schedule, halt]`.
- **Q1b, stated by the text:** with no stop pending, the engine exits at once. That is a crash for each worker in
  `execute` (`OPS-15`).
- New `CNF-366`: "**A lost startup-lock connection is an exit.** `OPS-47` says “it MUST exit non-zero at once”.
  Repeat `CNF-362`'s later-stop cases with the loss of `OPS-47`'s lock connection in place of the later stop:
  before the record's first transaction, while it is in flight, and while `OPS-49` repeats it, for the cut-off
  record of a cancellation of `execute` and for the settle-write record of a stop after `execute` returns. Assert
  the engine begins or repeats no record transaction after the loss, and exits. For a transaction in flight, accept
  either outcome, as `CNF-362` does: it committed, so the row is as that record writes it, with its effects
  committed once; or it did not, so the row is still `running` and `OPS-15` classifies it at restart, including its
  exceptions. Separately, terminate the lock connection with no stop while a worker is in `execute`: assert exit at
  once, no cut-off record, and restart recovery for any row still `running`."
- **E's cost in the misconfiguration case (verified):** S5's stranded rows. Rows claimed after the second engine's
  startup pass stay `running`, and block their machines, until that engine restarts.

## Misconfiguration (the owner's question: "what happens if there is a misconfiguration?")

**The panel's finding (r64b, 4-0):** no check made at record time closes the window between the server dropping
E1's session and E1 noticing, under either form. In that window E1 claims and calls providers. Its length is set by
the keepalive row (`OVR-19`). Only provider-side fencing or assured termination of E1 closes it. R and E differ only
after detection (S5).

**Optional add-ons, separate from R and E.** The owner will be asked about these separately. **Judge only whether
each is sound and what it costs.** Each amends `OPS-47`'s "**The lock is not a fence**: no write is guarded on it",
`STO-51`'s "It carries no row and guards no write: it fails a second engine's *startup*", and reopens `ADR-0019`'s
scope ("Naming the limit is what keeps it from growing back into the thing this ADR deletes").

- **Fence G (shared generation).** One row holds a generation. The engine that takes over (`OPS-15`'s pass) advances
  it exclusively; every claim and every engine write transaction reads it under a share lock (PostgreSQL 18:
  "A shared lock blocks other transactions from performing `UPDATE`") and compares it with its own; a stale
  engine's transaction refuses and that engine exits. It also amends the claim and write contracts (`STO-3`) and
  needs stale-owner exits in `OPS-21` and `OPS-22`. Costs as proposed: coordination and contention on every engine
  transaction, and stale outcomes discarded after a takeover. It cannot retract a provider request already sent.
  **Contested:** one reader holds that a generation stamped by the pass is `ADR-0019`'s rejected "Fix the
  predicate" ("it buys a defence for the case this ADR puts out of scope, and keeps a column, a counter and a guard
  term alive to do it"); two hold that a shared generation the takeover advances is not the deleted self-stamped
  epoch. Does it hold, and does it reach any of the pre-detection window (claims) or none?
- **Fence A (re-acquire before recording, R only).** Before its first record after the loss, E1 takes `STO-51`'s lock
  again, once, on a fresh connection, and holds it until exit. If that is refused, or the lock is lost again, E1
  exits at once. It also amends `OPS-47`'s "It answers one question, once, at boot". Costs as proposed: after a
  network blip E1's own unreaped session refuses it (`ADR-0019`: "A session advisory lock survives its holder when
  the holder dies without closing the connection"), so R falls back to E in the case R exists for; the only records
  it refuses are ones that would end better than E2's sweep; and it is a second checkpoint, the start of the
  "growing back".

## Answer

- **R (merged):** ACCEPT or CANNOT ACCEPT. **E (completed):** ACCEPT or CANNOT ACCEPT. **Pick:** R or E, with your
  strongest reason. **The merge:** right or wrong, one line (a wrong merge needs replacement text).
- **Against my pick (written on request):** at most 60 words.
- **Fence G:** sound YES or NO, and its cost in one line. **Fence A:** sound YES or NO, and its cost in one line.
- **Brief errors:** each wrong fact, with the grep or quote that shows it. Check S1-S5 especially.

**Total answer: at most 600 words, not counting replacement text.**
