# Panel brief r65b (panel D): R vs E double-checked, Fence G and Fence A for a lost startup-lock connection — pv-buc. 2026-10-24

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `b90783d` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**:
the manager builds the chosen form afterwards. Keep `TMPDIR` as set. Do not delegate, background or wait on
anything. Have a draft answer by minute 25. A web lookup is allowed only for postgresql.org documentation, quoted.

**Where this stands.** Round r65 read a merged R (record first) and a completed E (exit at once). Its votes: R 3
ACCEPT, 1 CANNOT ACCEPT (blocking, verified, repaired in one span); E 4 ACCEPT; pick R 4-0. Fence G was called sound
4-0, Fence A 3-1. The tally then found twelve errors in r65's brief (listed below; none voided it). The owner was
asked and answered, verbatim:

- On R vs E: "double check it again"
- On Fence G: "call the panel to double check this"
- On Fence A: "try to get a consensus here"

The owner's standing preference (2026-10-23, verbatim): "I don't like to put to much responsability in a infra
configuration. what happens if there is a misconfiguration?"

So this round has three questions. **Q1** re-reads R and E whole, with r65's fixes applied (the confirmation read
for those fixes). **Q2** asks whether to ADOPT Fence G. **Q3** asks for a consensus on Fence A. Every quote was
grepped at `b90783d`, but the manager has been wrong in briefs before: **check every claim this brief makes before
you rely on it**, and report each error under "Brief errors". Read text by requirement id, not by line number (line
refs below are hints).

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the form
flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and requirement id)
together with a trace that breaks it. Give replacement text for that span only. A CANNOT ACCEPT that names none is
recorded but does not block. Wording you dislike is not counted.

For Q2 and Q3 the vote is ADOPT or DON'T ADOPT, plus soundness. "Unsound" counts only with a trace in which the
fence admits a stale write or refuses a record it should admit.

## Corrections to r65's brief (verified at `b90783d`)

1. **r65's correction 4 is withdrawn.** It said "`OPS-22`'s zero-row exit is the worker's, not the whole
   engine's". The text supports both readings; see "The `OPS-22` inconsistency" below.
2. **"'Below' is right" was wrong.** The classification paragraph (03:1749-1761) and the in-`execute` transaction
   rule (03:1743-1747) sit above the insertion point. R's `OPS-21` sentence now says "this requirement's
   cancellation rules apply" (fix 2).
3. **"confirmed-read" appears nowhere.** `CNF-362` says "absorbed-read" (10:1611). Fixed in `CNF-366`(i) (fix 4).
4. **R's insertion point** separated "The sent transaction's fate is the server's" (03:1767) from the later-stop
   sentence it refers back to (03:1766). R's sentence now goes after 03:1770 (fix 3).
5. **`CNF-366`(vi) drove only a waiting parent.** `CNF-362` drives it "at successive fan-out positions"
   (10:1624). Fixed (fix 5).
6. **"A kill or a failover records nothing under both"** repeated r64b's correction 5 error: `CNF-362` says "Accept
   either outcome" (10:1645). Fixed in the line before S1.
7. **S1's E row "stays `running`"** holds only if the repeating write had not committed (03:1842). Fixed in S1.
8. **S1/S2's "a detour, not a person"** was too strong (`OPS-27`'s table, 03:516). Fixed in S1 and S2.
9. **S5's "each holds its machine"** was too broad: the index is `WHERE status = 'running' AND yielded_at IS NULL`
   (05:94). Fixed in S5.
10. **"A cut-off during a provider call ends `needs_reconciliation` under both"** was too broad: a create before
    step 9 settles `failed` (03:232; `OPS-15`). Fixed in the line before S1.
11. **Fence A's "only records it refuses … end better"** was overstated: it also refuses records whose outcome equals
    the sweep's, for example refresh, "Always `failed`" (03:228). Fixed in Q3.
12. **E's Lean list was incomplete:** the three `selection` splits and the 282 docstring; and E weakens
    `finished_unrecorded_exit`, against `ADR-0044`:95. Fixed (fixes 8, 9).

r65's fix to R's `CNF-366` fixture (fix 1) comes from the verified blocking CANNOT ACCEPT: with Store-retry bound 5,
Stop-record bound 60 and a store refusing until t=6, a conforming engine exits at t=5 (`OPS-21`: "whichever ends
first ends the record"; `CNF-362`: "the engine exits when the first bound ends"), so the old fixture's "exits only
after the records land" could not hold.

## Settled (not for re-vote)

- Q1's label is **owner** (r64, 4-0): may losing the lock cost an outcome already in hand?
- `OPS-21`'s Stop-record bound, its expiry exit, the later-stop exit, the Store-retry exhaustion exit and the
  supervisor's wait stand, except where a form adds to them. `STO-7`'s "A sent COMMIT is never abandoned" and
  `STO-54` stand. `OPS-47`'s supervisor posture stands.
- **Neither form guards a write on the lock.** `OPS-47`: "**The lock is not a fence**: no write is guarded on it,
  holding it proves nothing about the past, and losing it invalidates nothing already written." Fences G and A (Q2, Q3) are separate add-ons that would amend this.
- pv-9j6 (the last-row marker rule) converged in r64b and is not in this round.

## Q1 (pv-buc): R vs E, double-checked

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

Every create below is on a channel **with** a verified correlator; on a `correlator: none` channel nothing separates the forms (r64b's correction 1, `OPS-27`). A cut-off during a provider call ends `needs_reconciliation` under both forms, except a create before step 9,
which settles `failed` (03:232; `OPS-15`), also under both. A kill or a failover may leave a record transaction
in flight that may have committed (`CNF-362`: "Accept either outcome"); that too is the same under both.

- **S1. A create whose `execute` returned success.** A deploy stops the engine; the settle write is repeating under
  `OPS-49` because PostgreSQL is restarting in place, which also drops the lock connection. **R:** the settle write
  lands once the store is back, within the Stop-record bound: `succeeded`, money posted once, then exit. **E:** the
  engine exits on seeing the loss; if the repeating write had not committed, the row stays `running` (if it had,
"the row is already written, the money already posted once" (`OPS-49`, 03:1842), and R and E agree); at the next start `OPS-15` moves it to
  `needs_reconciliation`, and `OPS-27`'s correlator search resolves it "as though it had succeeded". A detour, unless the search escalates: `OPS-27`'s table (03:516) has "the listing window has expired …
  **Unresolved.** Escalate to an operator".
- **S2. A loss during a create's post-order read, after its confirming read succeeded.** **R:** the stop "MUST NOT
  cancel `execute`"; the read ends as a failed read, which `PRV-13c` says "MUST NOT change the create's settlement":
  `succeeded` with only `earliest_cancellation_date` null, no `cut_off` (`CNF-362`). **E:** as S1's E: parked, then resolved by the correlator search at restart, or by an operator where it
  escalates.
- **S3. A loss during a delete's direct read, after the provider accepted its cancellation with an effective date.**
  **R:** `succeeded` as `cancellation_scheduled` with that date, no `cut_off` (`CNF-362`, `PRV-13`). **E:** the row
  stays `running`; `OPS-15` moves it to `needs_reconciliation`. Resolution then proceeds by `PRV-29`'s "authoritative,
  non-mutating provider evidence anchored to the machine's known `external_id`", which for a dated cancellation
  "MUST additionally separate *rejected*, *accepted-pending*, *scheduled with an effective date* and *complete*"
  (`PRV-29`), falling back to `OPS-31`'s operator choices where the driver cannot (`OPS-45`). **Verified after r65:** 03:95-96 says "Resolution transitions out of `needs_reconciliation` are made by no worker
  — by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb"; `OPS-27`'s sweep searches by a create's correlator
  (03:505-508), and `PRV-29` (02:423) names no writer but the operator. So under E, S3 ends with an operator,
  unless the spec gains a resolver it lacks today. Under R it is `succeeded`, `cancellation_scheduled`, no person.
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
  a `running` row with no worker behind it"), and each one with `yielded_at` null holds its machine through the per-machine index (05:94:
  `WHERE status = 'running' AND yielded_at IS NULL`), so E2's
  claims on that machine defer ("the conflicting work will finish") **until E2 restarts**; the
  others stay `running` without blocking. **R:** E1 claims nothing more and records those rows within the Stop-record bound, under the worker reading
  of `OPS-22`; see the inconsistency below for the engine reading. Rows E1 held *before* E2's pass are decided by the
  guards: E1's record is guarded "on that operation still being `running` under the worker's claim number"
  (`OPS-22`), E2's pass "guarded on `(id, status = running)`" (`OPS-15`); whichever commits first wins, and a zero-row record makes that worker (under the engine reading, the engine)
  log loudly and exit. Under R, for up to the Stop-record bound, E2's boot answer
  ("nobody else is here") is wrong, and periodic passes already running and provider calls outstanding continue.


### The `OPS-22` inconsistency (not for vote here; trace S5 under both readings)

What exits on a zero-row record, the worker or the engine? Master says both.
- **Engine reading:** `ADR-0022`:41: "B's settle then affects zero rows and the engine exits under `OPS-22`".
  `CNF-290` (10:1505): "the old process's late settled-state write affects **no row** and exits it".
- **Worker reading:** `OPS-22` (03:1826-1828): "the worker MUST log it loudly, saying what it observed rather than
  asserting a restart, leave the record alone, and exit". Contrast `STO-3`'s defer (05:41): "the worker moves on
  and does not exit".
- **Ambiguous:** the pseudo-code at 03:1726-1727, `exit()  # a restart, or a later claim (OPS-22)`.

The manager's traces of S5 under R (check them):
- **Worker reading:** each post-pass row E1 claimed gets recorded; a zero-row record ends only that worker.
- **Engine reading:** E1's first zero-row record (a row E2's pass already swept) exits E1, so the post-pass rows
  still unrecorded at that moment stay `running`, as under E. R is never worse than E; only the size of R's S5 gain
  depends on the reading.

### Form R (record first), merged, with r65's fixes 1-7

- `OPS-47` keeps master's "hold it for its lifetime" (fix 7). Replace "where the connection
  carrying it is lost it MUST exit." with: "where the connection carrying it is lost, the engine MUST claim nothing
  more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each
  under `OPS-21` within its Stop-record bound and exits, and then exit non-zero. The loss is not a later stop: a
  record already pending when the loss is seen continues under its own Stop-record bound and exits."

- `OPS-21`, after "…`OPS-15` classifies the row as interrupted”." (03:1770, fix 3): "A loss of the connection carrying `OPS-47`'s startup lock is not a later
  stop: `OPS-47` says “treat the loss as a stop of every worker not already recording one”. For a worker still in
  `execute`, this requirement's cancellation rules apply, including the stop that “MUST NOT cancel `execute`” and the parent's
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
  non-parent worker is in `execute`, outside `CNF-362`'s absorbed-read cases; (ii) with no stop pending, while a
  create's after-return settle write repeats under `OPS-49`; (iii) while an earlier stop's cut-off record repeats
  under `OPS-49`. For cases (i)–(iii) and (vi), arrange that the record can land before either the
  Stop-record bound or the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses
  its transactions until lock-loss detection and then accepts writes with sufficient time remaining under both
  bounds. Assert: no claim and no periodic pass begins after the loss; case (i) records a cut-off
  `conflict` classified against its row (`OPS-11`); the settle write and the earlier record land, the create
  `succeeded` with its money posted once; the engine exits non-zero only after the records land. (iv) Deliver a stop
  after the loss, before a record lands: assert `CNF-362`'s later-stop assertions, including “Accept either
  outcome”. (v) With every transaction refused after the loss, assert exit within the Stop-record bound measured
  from the stop being recorded (the loss as the engine sees it, or the earlier stop), the loud log, and `OPS-15` at restart, including its
  exceptions. (vi) Repeat `CNF-362`'s cases for a create past its confirming read, a delete past its accepted dated
  cancellation, and a `suspend_tenant` parent at successive fan-out positions and waiting on its children, with the loss as the stop and no stop pending, asserting
  their `CNF-362` outcomes: no `needs_reconciliation` and no `cut_off` for the reads, the defer with no error for
  the parent, and exit only after the settle write or defer lands."

**Dropped since r65 (fix 7):** the edit "hold it until it begins to exit" (`OPS-47`) and "holds until it begins to
exit" (`STO-51`). Master's "for its lifetime" stands in both. Reasons: r63's rule 5 prefers deletion over
rewording; "begins to exit" could release the lock at an ordinary deploy stop while records are pending, letting a
successor sweep them; and R's loss clause already covers the case where the lock is lost. One reader's alternative,
"until it exits or the connection carrying it is lost", is open for you to argue for.

### Form E (exit at once), completed, with r65's fixes 8-9

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
  decision and notes its relation to `ADR-0044`'s decision 1. It also states (fix 9) that E
  weakens `finished_unrecorded_exit` by one disjunct, against `ADR-0044`:95's "No existing theorem is weakened".
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
  - `finished_unrecorded_exit`'s inner `selection` lemma (fix 8): its three
    `rcases h with ack | bound | store | later | redelivery` splits (StopRecord.lean:435, 453, 468) gain a
    `lockLost` pattern after `later`, and their `Or.inr` chains, written for five disjuncts, take the sixth.
  - `money_posts_at_most_once`'s docstring (282, fix 8): "serialization and both stop events never touch the store"
    becomes "serialization and the stop events, `lockLost` included, never touch the store".
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
  startup pass stay `running`, and those with `yielded_at` null block their machines, until that engine restarts.

**Open point for E (not fixed):** E's `OPS-21` sentence also goes "after the later-stop sentence", the same split as
correction 4 (03:1766 / 03:1767). Say whether it should go after 03:1770 too.

### r65's fixes, as applied above (this round is their confirmation read)

R: (1) `CNF-366`'s fixture sentence; (2) "the cancellation rules below apply" → "this requirement's cancellation
rules apply"; (3) R's `OPS-21` sentence after 03:1770; (4) "confirmed-read" → `CNF-362`'s "absorbed-read";
(5) `CNF-366`(vi) drives the parent at successive fan-out positions and waiting; (6) `CNF-366`(v) measures "from the
loss as the engine sees it"; (7) the "begins to exit" edits dropped. E: (8) the Lean `selection` splits and the 282
docstring; (9) `ADR-0046` states the weakening. Each was meant to change no behaviour. Say for each: right, or wrong
with replacement text.

## Q2: Fence G (shared generation): ADOPT or DON'T ADOPT?

**The panel's finding (r64b, 4-0):** no check made at record time closes the window between the server dropping
E1's session and E1 noticing, under either form. In that window E1 claims and calls providers. Its length is set by
the keepalive row (`OVR-19`). Only provider-side fencing or assured termination of E1 closes it. R and E differ only
after detection (S5).

r65 called G sound 4-0, with one point contested: is G `ADR-0019`'s rejected option? `ADR-0019`:78: "**Fix the
predicate — guard the claim itself on `engine_epoch = mine`.**" `ADR-0019`:80-81: "Correct, and cheap. Rejected
because it buys a defence for the case this ADR puts out of scope, and keeps a column, a counter and a guard term
alive to do it". One reader held that a generation stamped by the pass is that option; two held that a shared
generation the takeover advances is not the deleted self-stamped epoch. **This round votes on adoption.** There is
no full spec text yet: judge the sketch.

**The sketch (the manager's; check it).**
1. One row holds a generation number.
2. `OPS-15`'s startup pass advances it in its first transaction. That `UPDATE` waits on every other engine's
   transaction that holds the row `FOR SHARE` (PostgreSQL 18: "A shared lock blocks other transactions from
   performing `UPDATE`").
3. Every claim (`OPS-5`) and every engine write transaction reads the row `FOR SHARE` and compares it with the value
   its own pass wrote.
4. On a mismatch the transaction rolls back and the engine exits non-zero.
5. So the old engine's outcomes after the advance are discarded. The rows it held are swept by the new engine's
   pass and go through `needs_reconciliation`.
6. The old engine can claim nothing after the advance, so S5's stranding is gone under both R and E.

**Ids it amends (the manager's list; check it).** `OPS-47` ("**The lock is not a fence**"), `ADR-0019`, `STO-51`,
`STO-3` (the claim and write contracts), and new stale-generation exits in `OPS-21` and `OPS-22`. Probably also
`OPS-15` (the advance) and `OPS-5` (the claim's read): **this pair is the manager's guess, unverified.**

**The second engine by mistake, with and without G.** A deployment wrongly starts E2 while E1 runs. E2's boot check
is refused and it retries within the startup-lock wait bound. PostgreSQL restarts in place; E1's lock session ends;
E2 takes the lock and runs `OPS-15`'s pass. E1 has not yet noticed the loss (`OVR-19`'s keepalive row sets how
long). E1's pool reconnects and it carries on: it claims a queued `create` and is about to write that create's
pre-order marker.
- **Without G, under E:** E1 exits when it notices. The row it claimed after E2's pass stays `running` under a live
  E2 until E2 restarts (S5).
- **Without G, under R:** E1 records that row within the Stop-record bound. Until then two engines write side by
  side, and E2's boot answer ("nobody else is here") is wrong.
- **With G:** if E1's claim transaction ran after E2's advance, it reads the new generation, rolls back and E1
  exits, so there is nothing to strand. If it committed before the advance, E2's pass sweeps the row; E1's next
  write for it (the marker) mismatches, rolls back and exits, so no order is placed. A provider call E1 dispatched
  before the advance cannot be retracted; its row goes through `needs_reconciliation`.

**Costs to weigh.**
- A hot-row share lock taken in every engine transaction.
- A takeover that waits on the old engine's open transactions. How long, if E1 is partitioned rather than dead?
- Outcomes discarded after a takeover, even correct ones.
- New exits, new `CNF` cases and Lean work.
- Reopening `ADR-0019`'s scope: "Naming the limit is what keeps it from growing back into the thing this ADR
  deletes, which is how the leases got their second life."

**G and the owner's preference.** The manager's claim, for you to check: G rests only on the shared database, the
same thing that makes two engines collide, so no infrastructure setting has to be right for it to hold.

**G and the R/E pick.** G removes S5 (two readers' reason for R in r65) and fences R's overlap writes. It leaves S1-S4,
and S4 needs no misconfiguration.

Answer:
- (a) Is any provider mutation dispatched after the advance without a guarded write before it in the same worker?
  One reader says a create's step 8 and `OPS-45`'s markers precede every dispatch. Check it, including a guarded
  write that committed just before the advance.
- (b) How long can the takeover wait on E1's open `FOR SHARE` transactions, and what bounds it?
- (c) Does G rest only on the shared database?
- (d) Is G `ADR-0019`'s rejected "Fix the predicate"?
- (e) Does G change your R/E pick?
- (f) Is the id list right? Name what is missing or wrong.

## Q3: Fence A (re-acquire before recording, R only): a consensus

  exits at once. It also amends `OPS-47`'s "It answers one question, once, at boot". Costs as proposed: after a
  network blip E1's own unreaped session refuses it (`ADR-0019`: "A session advisory lock survives its holder when
  the holder dies without closing the connection"), so R falls back to E in the case R exists for; the records it refuses are ones that would end better than E2's sweep, or the same as it (refresh is
  "Always `failed`", 03:228; r65 error 11); and it is a second checkpoint, the start of the
  "growing back".

**The r65 answers, side by side (verbatim; "S1" and "S5" are the cases above).**
- **Against (one reader, sound NO):** "Every record it refuses is guarded already by `OPS-22`'s claim number and
  status, so the only records it blocks are correct ones (S5's, which E2 then strands), and after a blip E1's own
  unreaped session refuses it, turning R into E in S1. Cost: a second checkpoint against "once, at boot", for no
  write it prevents that the guards would not."
- **For (three readers, sound YES):**
  - "It guards no write and never ends worse than E. **Cost:** it succeeds only after an in-place restart with no
    second engine. After a blip, E1's own unreaped session refuses it (`ADR-0019`: "A session advisory lock survives
    its holder…"); in S5, E2 refuses it. So R falls back to E exactly where R gains most, and "once, at boot"
    becomes twice."
  - "sound YES, as a reacquisition checkpoint only. Cost: another connection/lock decision and possible rejection
    by E1’s unreaped session; it does not fence pre-detection claims or provider calls."
  - "YES, as a recording checkpoint. Cost: another connection/checkpoint, refusal by E1’s unreaped session, and lost
    recording opportunities; it provides no protection for earlier claims or transactions already sent."

**The manager's reading (check it).** The NO says, in effect, "it refuses only correct records"; correction 11 adds
that it also refuses records equal to the sweep's outcome. The two sides may differ only in the baseline: against R
without A, A refuses records R would land; against E, A never ends worse. Say which baseline soundness should use,
and whether A prevents any write that `OPS-22`'s and `OPS-15`'s guards would not.

**If G is adopted, is A still needed, or moot?** A applies with R only.

## Answer

**Total: at most 1,000 words, not counting replacement text.**

**Q1.**
- **R:** ACCEPT or CANNOT ACCEPT. **E:** ACCEPT or CANNOT ACCEPT. **Pick, without G:** R or E, with your strongest
  reason.
- **Fixes 1-9:** "all right", or each wrong one with replacement text. **E's placement (open point):** right or
  wrong.
- **S5 traced under the worker reading and under the engine reading:** how the post-pass rows end under R and under
  E. At most two lines each.
- **Against my pick (written on request):** at most 60 words.

**Q2.** **ADOPT or DON'T ADOPT G.** **Sound:** YES, or NO with a trace. Answers to (a)-(f), a line or two each.

**Q3.** First, the strongest argument against your own position on A, and your answer to it (at most 80 words).
Then **ADOPT or DON'T ADOPT A**; **sound:** YES, or NO with a trace; **under G:** still needed, or moot.

**Brief errors:** each wrong fact, with the grep or quote that shows it. Check S1-S5, the `OPS-22` traces and the G
sketch especially.
