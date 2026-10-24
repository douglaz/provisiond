# Panel brief r64b (panel D): two exact forms for a lost startup-lock connection, and a confirmation read of the last-row marker rule — pv-buc, pv-9j6. 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `b90783d` (master). Read `AGENTS.md` first. `br show pv-buc pv-9j6` prints the two
beads (if `br` fails, `.beads/issues.jsonl` holds them). You MAY edit tracked files in this clone to test a claim.
Write nothing outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and
no `lake`**: the manager builds the chosen form afterwards. Keep `TMPDIR` as set. Do not delegate, background or
wait on anything. Have a draft answer by minute 25. A web lookup is allowed only for postgresql.org documentation,
quoted.

Round r64 (four readers) split 2-2 on Q1 and agreed on Q2's behaviour. Its Q1 tally was voided by a brief error
(correction 1 below). The forms here merge the readers' own texts with every fix the tally verified. **No reader has
read them whole. That is this round's job.** Every quote was grepped at `b90783d`, but the manager has been wrong in
briefs before: **check every claim this brief makes before you rely on it**, and report each error under "Brief
errors". Read text by requirement id, not by line number.

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the form
flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and requirement id)
together with a trace that breaks it. Give replacement text for that span only. A CANNOT ACCEPT that names none is
recorded but does not block. Wording you dislike is not counted.

## Corrections to r64's brief (verified)

1. r64's story said that after a crash exit "the correlator resolves" the parked create. **Wrong on one channel.**
   `PRV-33`: "Where a provider — or one of its ordering channels — offers no verified correlator, an ambiguous
   create on that channel MUST resolve to an operator, never to a guess." The driver declares that channel
   `correlator: none`.
2. r64 said the "Startup-lock connection keepalives" parameter "exists only to detect that loss". **Wrong.**
   `ADR-0019`: "A session advisory lock survives its holder when the holder dies without closing the connection
   … the keepalive requirement is the actual cure". Option C (delete the exit) drew no picks and is off the ballot.
3. r64 said "No `CNF` item drives a lost lock connection". **Wrong in letter.** `CNF-365` runs "Kill the primary"
   and "crash the primary, restart it in place" while components run, which drops `OPS-47`'s connection. It asserts
   nothing about a stop's record.
4. r64's Q1b said "Under A the engine exits at once". **Wrong.** `OPS-47` says only "it MUST exit", with no timing.
   Form E below states the timing.
5. r64's failover variant: a delivered `STO-54` stop is a later stop under `OPS-21`, but `STO-54` requires only
   that processes have stopped, and `OPS-21` says "A kill or crash records nothing". A failover ends unrecorded
   under both forms, so it does not separate them. Only the in-place restart or network blip does.
6. Q2: "pre-dispatch" is not "marker unset". `OPS-45` writes the marker "before that phase runs", and for these
   kinds the phase is "the provider call is dispatched". A driver that fails while building the request has
   already passed the marker, and that failure stays ambiguous. The `internal` case below is the engine's own
   failure before the marker write.

## Settled (not for re-vote)

- Q1's label is **owner** (r64, 4-0): may losing the lock cost an outcome already in hand?
- `OPS-21`'s Stop-record bound, its expiry exit, the later-stop exit, the Store-retry exhaustion exit and the
  supervisor's wait stand, except where a form adds to them. `STO-54` and `ADR-0045`'s "A sent COMMIT is never
  abandoned" stand. `OPS-47`'s supervisor posture stands.
- **Neither form guards a write on the lock.** `OPS-47`: "**The lock is not a fence**: no write is guarded on it,
  holding it proves nothing about the past, and losing it invalidates nothing already written." This binds the two
  forms. It does **not** bind your answer to the owner's question in Q1: there you may propose a check that
  amends it, provided you say what it amends.
- Q2's behaviour (4-0): `OPS-45` governs a failure recorded with the marker unset, through arms guarded on
  `!f.accepted`, with goal-state precedence. D (4-0). No new `retryable` rule (4-0). `Rescue.lean`'s `governs`
  unchanged (4-0). Separate Runs for the two beads (4-0).

## Q1 (pv-buc): when `OPS-47`'s lock connection drops, record first or exit at once?

**Governing text.** `OPS-47`: "Before any claim the engine MUST take `STO-51`'s session-scoped advisory lock on a
connection outside the pool and hold it for its lifetime. Where the lock is refused it MUST retry for the stated
bound (`OVR-19`) and then exit non-zero having done no work; where the connection carrying it is lost it MUST
exit." … "It answers one question, once, at boot — is somebody else already here". `OPS-21`: "A cancellation of
`execute` that the engine survives MUST be recorded before the engine exits, for every operation kind, subject to
the bounded abandonment and later-stop exits below." Its later stop is "one arriving after the stop being recorded
and before that record lands", and it "ends the record as an exit without worker classification at any point".
`OPS-49`: "**A worker cancelled during the retry loop stops retrying and exits.**" No sentence today orders `OPS-47`'s
exit against `OPS-21`'s record.

**Precedent by rationale (`ADR-0044`), quoted neutrally.** Owner decision 1: "Any stop the engine survives MUST
record the outcome before the engine exits. This covers every operation kind". Rejected there: "**C: must not
record.** Rejected: it discards worker knowledge and substitutes crash recovery even when the process and store can
complete the record" (no owner-decision number); its option X, an exit, because "Exiting parks a create nobody ordered,
and the outcome would turn on whether the store error came before the stop"; another because "it throws away an
outcome in hand". Under Form E the engine does not survive the loss, so whether decision 1 reaches it is the
owner's scope call. `ADR-0019`: "If a deployment ever runs two engines, this system has no defence".

**The story both forms answer.** A deploy stops the engine. A create's `execute` has returned success: the provider
accepted the order. Its settle write is repeating under `OPS-49` because PostgreSQL is restarting in place. The
restart also drops the lock connection.
- **Form R (record first):** the settle write lands once the store is back, within the Stop-record bound:
  `succeeded`, money posted once. Then the engine exits.
- **Form E (exit at once):** the engine exits on seeing the loss. The row stays `running`. At the next start
  `OPS-15` moves it to `needs_reconciliation`. On a channel with a correlator, `OPS-27` resolves it. **On a
  `correlator: none` channel, `PRV-33` sends it to an operator**: a person resolves by hand a create the provider
  already accepted, for every such create in hand at each in-place restart or network blip.
- `CNF-365`'s in-place restart is the existing drill that drops the lock. Under R, the old engine's reconnecting
  record writes get no exemption from its assertion that "no component uses a connection before a standby has
  flushed at or past the flush position it reported"; waiting on it counts against the Stop-record bound. Under E
  that engine exits and only its successor connects.

**The misconfigured second engine, in plain terms (the manager's trace: verify it).** A deployment wrongly starts a
second engine, E2, while E1 runs. E2's boot check is refused, so it retries for the startup-lock wait bound. Inside
that wait, PostgreSQL restarts in place. E1's lock session ends, E2 takes the lock, runs `OPS-15`'s startup pass and
starts claiming.
- **Both forms:** from the moment the server ends E1's session until E1 sees the loss, E1 runs as normal. It may
  claim and call providers. Neither form closes this part.
- **Form E:** once E1 sees the loss, it exits. A transaction it already sent is the server's to decide.
- **Form R:** once E1 sees the loss, it claims nothing more. But it keeps sending record writes for up to the
  Stop-record bound while E2 is live, so for that long E2's boot answer ("nobody else is here") is wrong.
- What guards a row in that overlap: E1's record is a worker write, which `OPS-22` guards "on that operation still
  being `running` under the worker's claim number". E2's pass moves `running` rows "guarded on `(id, status =
  running)`". Whichever commits first wins the row. If E2's pass wins, E1's write affects no row, and `OPS-22`
  says E1 "MUST log it loudly … leave the record alone, and exit". If that reading holds, the overlap writes no
  row twice. What else the overlap can cost is part of your answer.

**The owner's preference (2026-10-23, verbatim):** "I don't like to put to much responsability in a infra
configuration. what happens if there is a misconfiguration?" Answer it openly for Form R:
- Is there a fail-closed check inside the app that closes the second-engine window under R? For example, can the
  stop's record write itself refuse if this engine no longer holds the lock, or some fence?
- What would that check cost?

No mechanism is prescribed. "None needed" is an answer if you give the reason. A check that guards a write on the
lock amends `OPS-47`'s "The lock is not a fence". It must also face `ADR-0019`: "Naming the limit is what keeps it
from growing back into the thing this ADR deletes, which is how the leases got their second life." Say which
requirement it amends. This answer is evidence for the owner, not a vote.

### Form R (record first)

- `OPS-47`: replace "where the connection carrying it is lost it MUST exit." with: "where the connection carrying
  it is lost, the engine MUST claim nothing more and begin no periodic pass, treat the loss as a stop of every worker
  not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit
  non-zero. The loss is not a later stop: a record already pending when the loss is seen continues under its own
  Stop-record bound and exits."
- `OPS-21`, after the later-stop sentence: "A loss of the connection carrying `OPS-47`'s startup lock is not a later
  stop: `OPS-47` says “treat the loss as a stop of every worker not already recording one”. For a worker in
  `execute` it is the cancellation being recorded; for one whose `execute` has returned, its settle write records
  it; it ends no record already pending. A stop that arrives after the loss and before that record lands is a later
  stop."
- `OPS-49`, its retry-loop bullet gains: "`OPS-47` says of a lost lock connection “The loss is not a later stop”: a
  worker repeating a record when the loss is seen keeps repeating it."
- `ADR-0019`'s restatement takes `OPS-47`'s new words with a dated note. A new ADR (next free id at landing)
  records the decision.
- `StopRecord.lean`: no new constructor. `Event`'s doc comment gains: "A lost lock connection is the originating
  stop or no event: `OPS-21` says it “is not a later stop”."
- **Q1b, stated by the text:** with no stop pending, each worker in `execute` is cancelled and records a cut-off
  `conflict` under its row (`OPS-11`).
- New `CNF-366`: "**A lost startup-lock connection is a stop of every worker, not a later stop.** `OPS-47` says
  “The loss is not a later stop”. Terminate the lock connection's backend: (i) with no stop pending, while a worker
  is in `execute`; (ii) with no stop pending, while a create's after-return settle write repeats under `OPS-49`;
  (iii) while an earlier stop's cut-off record repeats under `OPS-49`. Where a write repeats, the store refuses it
  until the loss and accepts writes again within the Stop-record bound. Assert: no claim and no periodic pass begins after the loss; the `execute`
  case records a cut-off `conflict` classified against its row (`OPS-11`); the settle write and the earlier record
  land, the create `succeeded` with its money posted once; the engine exits non-zero only after the records land.
  (iv) Deliver a stop after the loss, before a record lands: assert `CNF-362`'s later-stop assertions, including
  “Accept either outcome”. (v) With every transaction refused after the loss, assert exit within the Stop-record
  bound measured from the stop being recorded (the loss, or the earlier stop), the loud log, and `OPS-15` at
  restart, including its exceptions."

### Form E (exit at once)

- `OPS-47`: replace "where the connection carrying it is lost it MUST exit." with: "where the loss of the
  connection carrying it is detected, it MUST exit non-zero at once, whether or not a stop or its record is pending,
  without beginning a stop's record or waiting for one." ("Non-zero" is the manager's addition, for parity with
  Form R.)
- `OPS-21`, its first sentence: "subject to the bounded abandonment and later-stop exits below" becomes "subject to
  the bounded abandonment, later-stop and lock-loss exits below". After the later-stop sentence: "A loss of the
  connection carrying `OPS-47`'s startup lock ends a pending record as an exit without worker classification at any
  point: before the record's first transaction, during it, or while `OPS-49` repeats it. After the loss is seen the
  worker MUST NOT begin or repeat a record transaction; a transaction already sent is the server's to decide, and a
  row still `running` goes to restart recovery (`OPS-15`, including its exceptions)." The after-return list ("The
  Stop-record bound and its expiry exit, the later-stop exit, …") gains "the lock-loss exit".
- `STO-7`'s "short of its process exiting" already permits this exit with a COMMIT in flight.
- `ADR-0019`'s restatement takes `OPS-47`'s new words with a dated note. A new ADR (next free id at landing)
  records the decision and notes its relation to `ADR-0044`'s decision 1.
- `StopRecord.lean`: `Event` gains `lockLost`, which ends the record as `laterStop` does. A theorem
  `lock_lost_exits` sits beside `later_stop_exits`, and `finished_unrecorded_exit`'s exit disjunction gains the
  lock-loss exit.
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

## Q2 (pv-9j6): confirmation read of one merged form, M

The story. A stop cuts a delete off before its write-started marker is written. The worker records a cut-off
`conflict` with `write_started_at` null and no rescue session. Today `OPS-45` says `failed`, but `OPS-11`'s last row
and `classify` say `needs_reconciliation`: an operator resolves a delete the provider never saw. A second case is an
`internal` the engine raises before the marker write.

Two optional clauses are marked **[P]** and **[Q]**. Answer each separately.

**`OPS-11`'s last row** becomes: "| power, reverse-DNS, delete, release attachment | Subject to the goal-state
success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session
was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns
the rule)**[P]**. Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a
delete of a smaller thing (`PRV-45`) and classifies exactly as one. |"
- **[P]**, the explicit acceptance guard (r64 split 2-2): ", unless the mutation is known to have been accepted
  (`details.accepted` is `true`)". Without [P], the text relies on `PRV-5`: "A failure before any byte of the
  mutating request was sent MUST report `details.accepted: false`". Note the acceptance amendment's "MUST NOT
  classify that accepted mutation `failed`" when you answer.

**`OPS-21`'s pointer list** becomes: "The other classification pointers are `OPS-11`'s install row, "while `OPS-45`'s
two markers say the disk is untouched and no rescue session was left open", rescue inventory's "Same rows as
`install`", the last row's "any failure the worker records while `OPS-45`'s write-started marker is unset", and
refresh's "Always `failed`"." Its next sentences stand. "Where the row reads `OPS-45`'s markers, the record MUST
classify against the markers its own transaction reads" then reaches the four kinds.

**D, `05-persistence.md`'s `write_started_at` row:** delete ", and with the column below makes the failure
deterministic rather than ambiguous (`OPS-11`)". It then reads "Null means the mutation provably did not begin — but
**non-null does NOT mean `not_applied` is unrecordable**…".

**`Tables.lean`, `classify`:**

```lean
  | .power | .deleteMachine | .releaseAttachment =>
      some (if goalState r f then .succeeded
            else if r.markerRule && !m.writeStarted && m.rescueClean && !f.accepted then .failed
            else mutationRow r f)
  | .reverseDns =>
      some (if r.markerRule && !m.writeStarted && m.rescueClean && !f.accepted then .failed
            else mutationRow r f)
```

Beside `accepted_never_failed`, a theorem. The `goalStateHeld = false` field is required: with it free, a
`provider` rejection read as "already in the target state" gives `succeeded` for power, delete and release, and
`decide` fails.

```lean
/-- `OPS-11`'s last row: "any failure the worker records while `OPS-45`'s write-started marker
is unset … MUST settle `failed`, whatever its kind", below the goal-state success rule. -/
@[req "OPS-11"]
theorem last_row_marker_unset_failed :
    ∀ (k : Kind) (e : ErrorKind) (c : Bool) (u : Upstream) (b : Bool),
      k.lastRow = true → k ≠ .createMachine →
        classify currentRules k ⟨e, c, u, false, false, b⟩ ⟨false, true⟩ = some .failed := by decide
```

In `Witnesses.lean`, beside `host_key_abort_witness`, a witness with its negative. It stays green under ci.yml's
goal-state flip, which expects exactly one failing file: a cut-off `conflict` is not a goal-state failure.

```lean
/-- `pv-9j6`: a delete cut off before its write-started marker records a cut-off `conflict`.
Under the marker rule it settles `failed`; without it the last row read it as ambiguous and sent
it to an operator. With the marker set it stays `needs_reconciliation`. -/
@[req "OPS-11"]
theorem predispatch_cutoff_delete_witness :
    let cut : Failure := ⟨.conflict, true, .unrecorded, false, false, false⟩
    classify currentRules .deleteMachine cut ⟨false, true⟩ = some .failed ∧
    classify { currentRules with markerRule := false } .deleteMachine cut ⟨false, true⟩ =
      some .needsReconciliation ∧
    classify currentRules .deleteMachine cut ⟨true, true⟩ = some .needsReconciliation := by decide
```

**`CNF-31b`:** its pre-send case becomes "assert that a pre-send `network` failure (for create, from a step-9 call;
on the last row, inside a dispatched call with the write-started marker set) yields `needs_reconciliation` despite
`details.accepted: false`". It gains: "On the last row, for each of power, reverse DNS, delete and release
attachment, assert that a cut-off `conflict` and an engine `internal` recorded before the write-started marker write
settle `failed`."

**`CNF-362`:**
- In the per-kind list, after "an install past the marker enters `needs_reconciliation`;" insert "power, reverse
  DNS, delete and release attachment cut off before their write-started marker write settle `failed`;".
- In **Inside `execute`**, before "This item is the only check of this case": "Stop a delete while `OPS-49` repeats
  its write-started marker write, with the store working again before the Stop-record bound ends. After a first
  attempt that committed with its reply lost, assert `needs_reconciliation`; after one the store refused, assert
  `failed`. In both, assert no provider call is dispatched."
- In **Control**, delete "Make no assertions about power, reverse DNS, delete or release attachment stopped before
  dispatch (`pv-9j6`)." The paragraph then ends "a kill at the same instant writes nothing; a create with
  `about_to_order_at` set enters `needs_reconciliation` on restart."
- "Make no assertion about `retryable` for the other cases" stands and covers the new `failed` cases.

**[Q]**, `CNF-31a` gains (r64: 1 for, 3 against): "For power, reverse DNS, delete and release attachment assert both
directions: with the marker set, an ambiguous failure is never `failed`; with it unset, no recorded failure is
`needs_reconciliation`."

A dated note on `OPS-11`'s last row. A new ADR (next free id at landing) records the decision.

## Answer

- **Q1:** **R:** ACCEPT or CANNOT ACCEPT. **E:** ACCEPT or CANNOT ACCEPT. **Pick:** R or E, with your strongest
  reason. Then:
  - **Against my pick (written on request):** at most 60 words.
  - **The owner's question:** the fail-closed check under R and its cost, or "none needed" with the reason.
  - At most 400 words for Q1, not counting replacement text.
- **Q2:** **M:** ACCEPT or CANNOT ACCEPT. **[P]:** YES or NO. **[Q]:** YES or NO. One line of reason each.
  - **Read whole, does M contradict anything around it?** A yes needs a quote of each side.
  - At most 200 words.
- **Brief errors:** each wrong fact, with the grep or quote that shows it.

**Total answer: at most 800 words.**
