# r64b tally (panel D: pv-buc, pv-9j6). 2026-10-23

All four exited 0. Answers: fable.md, opus.md, astra.md, sol.md. Rules: notes.md (r63 rules 1-7, rule 3 = the gate,
plus the pre-registered second-engine rule). Every claim below that moves a tally was checked at `b90783d` (main
repo, HEAD = b90783d, clean). Line refs are `file:line` at b90783d (03 = 03-operation-lifecycle.md, 05 =
05-persistence.md, 10 = 10-conformance-checklist.md).

**Q1 (b). Q2 (a): M with [P], without [Q], 4-0.**

**Astra's shallowness check.** Astra finished in about 4 minutes, but its answer is not shallow, and it counts as
a vote. Its blocker (`OPS-21`'s absorbed-read MUST) comes with file refs and a trace, and I verified it. Sol found
the same blocker independently. Astra gives replacement text for the span, answers the owner's question with a
mechanism, what it amends and its cost, and gives a concrete counterexample for [Q]. Of its four brief errors, I
verified three as stated, and the fourth is correct. Its stderr is 535 KB of reading.

## Q1 (pv-buc): record first (R) or exit at once (E)?

### Votes

| Reader | R | E | Pick | Blocks? |
|---|---|---|---|---|
| fable | ACCEPT | ACCEPT | R | — |
| opus | ACCEPT | ACCEPT | R | — |
| astra | CANNOT ACCEPT | ACCEPT | R, with its repair | **yes, verified**: MUST + trace |
| sol | CANNOT ACCEPT | ACCEPT | R, with its correction | **yes, verified**: MUST + trace |

- **R as written: 2 ACCEPT, 2 blocking CANNOT ACCEPT. E: 4 ACCEPT. Picks: R 4-0, two of them conditional on a
  repair.**
- **The blocker (astra, sol), verified.**
  - `OPS-21` (03:1797): "A stop the engine survives after a create's settle-time confirming read succeeds, or
    after a delete's cancellation is accepted with an effective date, and before `execute` returns MUST NOT
    cancel `execute`."
  - `CNF-362`'s absorbed-read cases (10:1705-1716) assert "no `needs_reconciliation` and no `cut_off`".
  - R's `OPS-21` sentence says "For a worker in `execute` it is the cancellation being recorded".
  - Trace: the lock is lost during a verified create's post-order read. R makes the loss the cancellation, which
    gives a cut-off `conflict` and `needs_reconciliation`. That breaks the MUST.
  - The parent breaks R's universals too. A cancelled `suspend_tenant` parent records the defer, and "It
    records no error" (03:1784-1787, 03:1803). So R's Q1b ("each worker in `execute` is cancelled and records
    a cut-off `conflict`") is false, and so is `CNF-366`(i)'s "the `execute` case records a cut-off
    `conflict`".
  - E does not meet the MUST: the engine does not survive the loss.
- **The repair spans differ. They are reader text, not merged here:**
  - astra, `OPS-21`: "For a worker in `execute`, the loss follows this requirement's stop rules, including the
    case that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”. For one whose
    `execute` has returned, its settle write records it; the loss ends no record already pending."
  - astra, `CNF-366`: "Outside `CNF-362`'s absorbed-read and parent cases, assert the cut-off classification
    against the kind's row. Repeat those absorbed-read and parent cases with lock loss as the stop, asserting
    their respective outcomes."
  - sol, `OPS-21`: "For a worker still in `execute`, the cancellation, absorbed-read and parent rules below
    apply".
  - sol, `CNF-366`(i): "while a non-parent worker is in `execute`, outside `OPS-21`'s absorbed-read cases".
- **Fable, non-blocking, on R:** `OPS-47` keeps "hold it for its lifetime" (03:144) while the engine outlives
  the loss. Its replacement: "hold it until it begins to exit".
- **Strongest reasons for R:**
  - fable: the per-row guards already fence the write E forbids.
  - opus: no row ends worse under R.
  - astra and sol: R keeps verified outcomes through a recoverable store interruption.
  - Fable's and opus's reasons also lean on the false `correlator: none` story below. Astra and sol say their
    pick does not.

### Counter-arguments, written on request (not votes)

- **fable:** under R the engine knowingly writes, for a deployment-chosen bound, to a store whose lock it lost.
  Detection is itself a keepalive parameter. `ADR-0019` names the limit so the lock does not "grow back".
- **opus:** R turns a dropped idle connection into a stop that cuts off every `execute`. A misconfigured E2's
  boot answer stays wrong for up to one Stop-record bound longer. R costs more to prove: five `CNF-366` cases,
  plus the reconnection check counted against the bound.
- **astra:** R prolongs the overlap with a wrongly started successor. Row guards protect transactions, not
  exclusive execution. Running periodic work and outstanding provider calls remain, and the successor's pass
  can defeat the old worker's record.
- **sol:** the same overlap point. E2 can recover E1's rows before E1 records them, and existing periodic passes
  continue. E ends that extra activity on detection.

### The owner's question: a fail-closed check under R (evidence, not votes)

- **fable: none needed.**
  - `ADR-0019` (lines 52-54) says `OPS-15`'s pass, `STO-3`'s `status = running` term and `OPS-22`'s "log it
    loudly, leave the record alone, and exit" "handle a supervised restart end to end".
  - A lock-held check on the record write is Form E renamed. It amends `OPS-47`'s "no write is guarded on it".
  - A generation the pass stamps is `ADR-0019`'s rejected "Fix the predicate" (lines 78-81), which "buys a
    defence for the case this ADR puts out of scope". Its cost is a column, a guard term, a theorem, and the
    epoch's second life.
- **opus: none needed.** After detection, every write E1 makes is ordered by a guard:
  - Its first write is `OPS-22`'s guarded status write, which "short-circuits the rest" (`STO-3`, 05:29),
    money writes included.
  - E2's pass is guarded on `(id, status = running)` (03:354).
  - **Optional check if the owner wants one:** before its first record after the loss, E1 re-takes `STO-51`'s
    lock once, on a fresh connection, and holds it. If that is refused, or the lock is lost again, E1 exits at
    once.
  - Opus names what the check amends: `OPS-47`'s "once, at boot" and `STO-51`'s "fails a second engine's
    *startup*" (05:91).
  - **The manager adds:** the check gates a write on the lock, so it also amends `OPS-47`'s "The lock is not a
    fence" (03:146) and `ADR-0019`.
  - Its cost: after a network blip, E1's own unreaped session refuses the re-take. `ADR-0019` says a session
    lock "survives its holder when the holder dies without closing the connection" (line 69). So R falls back
    to E in the case R exists for, and the check starts `ADR-0019`'s "growing back".
- **astra: a fence, and it reopens `ADR-0019`.**
  - A separate "still held?" read races with the takeover.
  - The real fence is a shared generation, checked under a transaction lock in every claim and engine-write
    transaction. The takeover advances it, so it is not the deleted self-stamped epoch.
  - It amends `OPS-47`'s "no write is guarded on it", `STO-51`'s "guards no write" and the claim and write
    contracts. That amends "The lock is not a fence" and reopens `ADR-0019`'s scope decision. Astra says so.
  - Its cost: coordination, contention, and outcomes discarded after a takeover. It cannot retract a provider
    request already sent.
- **sol: the same shared-generation fence.**
  - It uses a row lock in share mode, quoting postgresql.org/docs/18: "A shared lock blocks other transactions
    from performing `UPDATE`".
  - It amends `OPS-47`'s two-engine scope and adds ownership machinery under `STO-51` and `STO-3`, with
    stale-owner exits in `OPS-21` and `OPS-22`. That reopens `ADR-0019` and amends "The lock is not a fence".
  - Its cost: coordination and lost stale outcomes. It cannot revoke provider calls already admitted.
- **All four agree on the window that matters most:**
  - No record-time check closes the window before E1 detects the loss. In it, E1 claims and calls providers.
  - That window is the same under both forms.
  - Its length is the keepalive setting (`OVR-19`, fable).
  - Only provider-side fencing or assured termination closes it (astra, sol).
- **Fable's misconfiguration trace adds one fact, which I verified. It is a cost of E in the owner's own case.**
  - Rows E1 claims after E2's pass stay `running` under E. The live E2 never sweeps them: `OPS-15` says
    "nothing but a restart can leave a `running` row with no worker behind it" (03:357).
  - Each such row holds its machine through the per-machine index, so E2's claims on that machine defer: "the
    conflicting work will finish" (03:189). That lasts until E2 restarts.
  - Under R, E1 records those rows.

### Verified checks and brief errors

**Voiding (rule 6): the `correlator: none` story is false.**
- The brief said that under E, on a `correlator: none` channel, "a person resolves by hand a create the provider
  already accepted", and implied that R avoids this.
- `OPS-27` (03:540-544) says: "**A create MUST NOT settle `succeeded` on the strength of the reply in hand
  alone.** … **After acceptance, zero or many resources, a failed search, or any non-authoritative search MUST
  leave the create in `needs_reconciliation`**". Its table row (03:516) says: "no verified correlator exists for
  the operation's ordering channel (`PRV-33`) | **Unresolved.** Escalate to an operator".
- `OPS-21` puts that search inside `execute` (03:1793).
- So on that channel the create reaches an operator under both forms. Reported by astra and sol.
- **It affects the case for R.** It inflated E's stated cost. With a correlator, E's cost for this create is
  a reconciliation detour that `OPS-27` resolves automatically, "as though it had succeeded" (03:513).
- Fable's and opus's strongest reasons cite it. This is the second round running in which the `correlator: none`
  line was wrong.

**Second-engine trace (notes.md's pre-registered rule, applied as written).**
- No reader broke `OPS-22`'s claim-number guard or `OPS-15`'s pass guard.
- Two points are verified corrections that leave the guard claim standing, so neither is a brief error under
  rule 6:
  - astra: a zero-row defer "moves on and does not exit" (`STO-3`, 05:39-41).
  - sol: `OPS-22`'s zero-row exit is "the worker"'s, not the whole engine's (03:1825-1828).
- The periodic-pass and outstanding-call costs of R's overlap (opus, astra, sol) and fable's stranded rows under
  E are answers the brief invited. **The void comes from the `correlator: none` story alone.**

**Non-voiding, verified:**
- E is missing an edit (opus). E changes `OPS-21`'s after-return list, which `CNF-362` quotes word for word
  (10:1672). `ADR-0044` (line 63) says "the citation gate fails an edit that drops or changes one", so
  `CNF-362`'s quote must change with it.
- E's `lockLost` needs more Lean (opus). `schedule` matches on `Event` (StopRecord.lean:51), and
  `schedule_bounded` (:130), `later_stop_exits` (:215) and `finished_unrecorded_exit` (:432) case-split on it.
  The new constructor needs arms in all four.
- "`ADR-0045`'s 'A sent COMMIT is never abandoned'" is misattributed (fable, opus). The sentence is `STO-7`'s
  (05:151, "added 2026-10-23, `ADR-0045`"). `ADR-0045`'s only "abandon" is "deadline-driven abandonment".
- Correction 5 overstates "ends unrecorded" (sol). An in-flight record transaction may have committed
  (`CNF-362`'s "Accept either outcome"). This does not separate R from E.
- "Under E … only its successor connects" (sol): before E1 detects the loss it can reconnect and retry, as the
  brief's own window says.
- Opus's claim that a pre-marker install settles `failed` under R and `needs_reconciliation` under E is
  consistent with the text. `OPS-15`'s exceptions are refresh, a null-column create and the parent
  (03:387-430), so an install has none. Under M the same holds for a pre-marker power, reverse-DNS, delete or
  release. This is a real separating case for the next brief.

**Rule 5 is not triggered.** The behaviour went from 2-2 (r64) to R 4-0 here. The two dissents name one defect,
and their fixes converge. A deletion is not on the table.

### Outcome: **(b) another reading round**

Three reasons:
- **Rule 6:** the `correlator: none` error voids the tally. It affected the case for R.
- **The gate:** R as written has two verified blocking CANNOT ACCEPTs.
- **The repair is an unreviewed merge:** astra's and sol's spans differ, and E's completion is unread.

The label stays owner. If the next round holds R at 3/4 or more, R goes to the owner as the panel's
recommendation, with this fail-closed evidence and the stranded-rows trace.

**The next brief must:**
- Drop the `correlator: none` story. State only the verified cases where R and E differ:
  - a create already verified on a correlator channel: R `succeeded`; E's detour is auto-resolved;
  - a pre-marker install: R `failed`, E `needs_reconciliation`. The same holds under M for the four last-row
    kinds;
  - the absorbed reads:
    - create: R `succeeded`;
    - delete: R `succeeded` as `cancellation_scheduled`. E's outcome is not yet verified, so verify it;
  - fable's stranded rows under a live E2.
- Merge astra's and sol's spans into one R text. It keeps `OPS-21`'s "MUST NOT cancel `execute`" and the
  parent's defer. Fix R's Q1b and `CNF-366`(i) to match. Add the absorbed-read and parent cases to `CNF-366`.
- Add fable's "hold it until it begins to exit" to R's `OPS-47` edit.
- Complete E: `CNF-362`'s quote at 10:1672, and `lockLost`'s arms in `schedule`, `schedule_bounded`,
  `later_stop_exits` and `finished_unrecorded_exit`.
- Correct the brief's text:
  - "A sent COMMIT is never abandoned" is `STO-7`'s.
  - The trace's zero-row exit is the worker's, and a zero-row defer moves on.
  - Correction 5 must say "may have committed".
  - E1 can reconnect before detection.
- Re-verify `CNF-365`'s flush-position quote before quoting it. My grep missed it, probably at a line wrap.
- Carry the four fail-closed answers as evidence, including the point all four agree on: the window before
  detection is the same under both forms.
- Ask each reader to vote ACCEPT or CANNOT ACCEPT on both exact forms, and to pick one.

## Q2 (pv-9j6): confirmation read of M

### Votes

| Reader | M | [P] | [Q] | Contradiction? |
|---|---|---|---|---|
| fable | ACCEPT | YES | NO | no |
| opus | ACCEPT | YES | NO | yes, only without [P] |
| astra | ACCEPT | YES | NO | no (with [P], without [Q]) |
| sol | ACCEPT | YES | NO | no (with [P]) |

- **M: 4-0 ACCEPT, no CANNOT ACCEPT. [P]: 4-0 YES, so it is in. [Q]: 0-4, so it is out.**
- **[P] reasons:** the Lean arm carries `!f.accepted`, and `accepted_never_failed` leaves the markers free. [P]
  makes the Markdown say what Lean says, and it meets the acceptance amendment's "MUST NOT classify that accepted
  mutation `failed`".
- **[Q] reasons:** its universal omits acceptance and rescue cleanliness. With `accepted = true` and the marker
  unset, M's Lean gives `needsReconciliation`, so [Q] is false (opus, astra, sol). The cases already have homes in
  `CNF-31b` and `CNF-362` (fable, opus).
- **Opus's contradiction, verified.** Without [P], M's "whatever its kind" meets the acceptance paragraph's "A
  later `rate_limited`, `not_found`, `authentication`, or provider 4xx error MUST NOT classify that accepted
  mutation `failed`" (03:279-280). No trace reaches it: `OPS-45` acknowledges the marker before the call, and
  `PRV-5` (02:46) requires "`details.accepted: false`" before any byte is sent. **[P], which is in, resolves it.**
  Nothing is left to fix before the Run.

### Verified brief errors (non-voiding)

- "Expects exactly one failing file" is imprecise (opus). The goal-state flip checks one error line,
  `test "$(grep -c '^error: Provisiond/' build.log)" -eq 1`, plus a `Witnesses.lean` `decide` error
  (ci.yml:335-336). M passes it, per the readers' source reading. The manager builds afterwards.
- Correction 6 overgeneralizes (astra). Ambiguity is by error kind (03:266-276). A request-building
  `invalid_request` with the marker set and not accepted is "otherwise `failed`", not ambiguous. M changes only
  the marker-unset side, so its premise stands.

### Fixes readers proposed. All four are verified, and none changes behaviour.

1. `CNF-31b` (10:227-228): "On … the last row, `OPS-11` says '`needs_reconciliation` if the failure is
   *ambiguous*, otherwise `failed`'" is now only the row's "Otherwise" branch. Say so (opus). This is wording;
   M's own `CNF-31b` edit already narrows the case.
2. `CNF-362` "Inside `execute`" (10:1661): "This item is the only check of this case" becomes "these cases",
   since M adds a second case before it (opus). This is wording.
3. `OPS-23` (03:1910): "Power and delete take its last row's 'otherwise `failed`'" should point at the marker
   clause (fable). This is the only fix that touches classification, and it changes no outcome. These
   missing-field failures are unaccepted and not cut off, so both the marker clause and "otherwise `failed`"
   give `failed`.
4. `Tables.lean`'s `Rules` doc comment (lines 116-118): `markerRule` quotes only the install row. Add the last row
   (fable). This is a doc comment.

They may ride into the Run without another round.

### Outcome: **(a) converged**

- **The form:** M exactly as in brief.md (§Q2), with [P] ", unless the mutation is known to have been accepted
  (`details.accepted` is `true`)" in `OPS-11`'s last row, without [Q], and with fixes 1-4.
- **The tally:** M 4-0 ACCEPT, [P] 4-0, [Q] 0-4.
- Under rule 2, the behaviour goes to the owner as the panel's recommendation, awaiting a yes. On a yes, a
  separate pv-9j6 rloop Run follows (r64 Q3, 4-0 for separate Runs). The manager builds Lean in that Run.
