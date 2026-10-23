# r63h tally (pv-s4m, panel C, what r63g left open). 2026-10-23 ~08:40Z

All four exited 0. Answers: fable.md, opus.md, sol.md, astra.md. astra.md is the re-run; the first run's records,
which failed with "model at capacity", are in failed-astra-1/. The `Final:` lines in opus's, sol's and astra's drafts
match their answers. fable.draft.md has no `Final:` line, and fable.md is its full answer. The rules
are in notes.md. **No further round is required.** Nothing below needs one, unless the owner wants FSW's third
shape (see FSW).

## Votes (every PICK and NOT ACC cites a quote or a trace, so all are valid under rule 1)

| Item | fable | opus | sol | astra | Outcome |
|---|---|---|---|---|---|
| NA′ | PICK | PICK | ACC | ACC | Qualifies: all four pick or accept it |
| NA-sol | NOT ACC (refuted, below) | ACC | PICK | PICK | Qualifies: the only NOT ACC doesn't survive verification |
| → NA | | | | | **NA′ CARRIES.** Rule 4 tie at 2-2 PICKs goes to NA′. **S3 coupling fires:** 4/4 say NA-sol is needed under S3-A, with traces, so NA-sol's text travels with option A |
| INV-ADR′ | PICK | PICK | PICK | PICK | **CARRIES 4-0** (rule 5: F4 stays anchored on the objective) |
| FSW (i): `STO-54` covers it | yes (contestable) | yes | yes | yes | |
| FSW (i): knowable after loss | no | no | no | no | **Not settled by reading. Owner question, saying both facts** |
| FSW-L | PICK | ACC | ACC | ACC | |
| FSW-N | ACC | PICK | PICK | PICK | **Panel pick FSW-N 3-1. Both are acceptable to all four.** The reviewer made no pick (the gap is r63g's) |
| T1 | PICK (replace) | PICK (replace) | PICK | PICK | **Carries 4-0. It replaces r63g's sentence** (4/4) |
| T2 | ACC | ACC | PICK | PICK | **Carries** |
| T3a / T3b | ACC / PICK | ACC / PICK | ACC / PICK | ACC / PICK | **T3b wins, 4-0** |
| T4a / T4b | ACC / PICK | ACC / PICK | PICK / ACC | PICK / ACC | **Both carry, tied 2-2: T4b wins (rule 7). It lands only if PA-2** |
| T5 | PICK | PICK | PICK | PICK | **Carries 4-0** |
| T6a / T6b | PICK / ACC | ACC / PICK | PICK / ACC | PICK / ACC | **T6a wins, 3-1** |
| T7 | PICK | NOT ACC | NOT ACC | NOT ACC | **Dropped.** It fails a conforming pool (verified) |

## Checks of dissent and new facts

- **Fable's NOT ACC on NA-sol: refuted on all three grounds.**
  - (a) "Under B′ the bound holds" is false strictly: see trace 1. Fable's own item 1 concedes "at most one per such
    event", with no bound on the number of events.
  - (b) "needs a `pg_stat_activity` read by pid, a privilege A does not otherwise grant" is false:
    `monitoring-stats.txt:117` "Ordinary users can only see all the information about their own sessions". The
    orphan belongs to the component's own role.
  - (c) "names no means": the text fails closed ("its budget remains charged, or the component process exits"), and
    (b) supplies a means. No failure trace.
  - **Not voided under rule 10.** The brief's §1 errors argued *against* NA-sol, and NA-sol qualifies anyway; r63g
    E5 is the precedent.
- **Trace 1 (sol, astra): VERIFIED in source, not measured.**
  - `18-xact.c`: `HOLD_INTERRUPTS` (~2358), then `RecordTransactionCommit` (~2381), then the local flush
    `XLogFlush` at `:1506`, then `SyncRepWaitForLSN` at `:1567`.
  - A COMMIT whose record isn't yet flushed when its transport is found dead is released by NA′. Its replacement
    samples an earlier target and passes while replication is healthy. Repeated, then frozen, the orphans wait
    outside the budget. Their number has no pool-derived bound; only the primary's connection slots bound it.
  - No check passes during the freeze: astra concedes it, and B′ fails when it "cannot see a standby's position".
  - So forms-r63h:72-73's "No new waiter can pile up behind a frozen standby" overclaims (sol, astra). Opus's "in
    practice at most the write budget" is not a bound.
  - Availability only → F2. Under A it is H-c, measured (17 abandoned clients, "remaining connection slots are
    reserved"). That is why NA-sol travels with A. Readers did not trace AB; it is open if the owner picks AB.
- **Opus: release needs a streaming or stopping walsender** (`18-syncrep.c:494`). A check can pass during catchup a
  moment before waiters are released. This is VERIFIED; it is brief and availability only, so it is not filed.
- **C9's "never" overclaims outside its step (4/4).** It holds within the step: live transports, no exit. The fix is
  a Run review point.
- **W1's conflict (fable, opus): VERIFIED.** `03:1829` "the engine MUST exit non-zero into its supervisor" is a
  process exit, which NA′ already excepts. Sol and astra saw no conflict. Fable's fix only deletes words, so it is a
  Run review point.
- **T7's NOT ACC (opus, sol, astra): VERIFIED.** NA′ holds the connection only "before the reply arrives", and
  neither NA′ nor `05:140-146` requires reuse after the reply.
- **INV-ADR′'s case:** opus re-checked `03:760`, `03:1422`, `03:1630-1635` and `04:829-831`. Astra's "lost
  protection" is `05:1555` ("an extension lost in Δ is not rebuilt"), which the restore already states. The broad form
  was rationale and enforced nothing, so nothing is lost (rule 11).
- **FSW (i):**
  - 4/4 say "had a waiting backend cancelled or terminated (`STO-7`)" covers step 6. Fable calls it contestable,
    since the list reads as violations.
  - 0/4 say the promoting party can know it. The evidence (the WARNING and the log) is on the lost primary, and both
    standbys report equal ends.
  - Opus: read literally, the clause has no time limit, and it reaches even a stop where a connected standby got
    everything (`warm-standby.txt:169`). → F4.
  - **Third shape, rule 6(ii) and rule 9.** Opus, sol and astra converge on an off-primary durable record of the
    primary's shutdown or end of WAL, consulted at promotion. Sol and astra add a fallback: classify as a restore
    when unknown. Fable's variant is "stopped while `OVR-18`'s both-standbys alarm was active".
    - It is a new deployment duty: opus says it "fails silently, which is the owner's worry".
    - It is not an option and not recommended, so no round is needed. The owner question mentions it in one line.
  - Sol and astra: a correct restore skips the index but "does not reconstruct a lost deposit".
- **FSW reach (4/4): deposits are not the only consequence.**
  - The revocation replay resurrects the token after a promotion classed a restart (4/4; `04:580-583` VERIFIED).
  - `OPS-32`'s deletes (4/4).
  - `API-11` and `API-53` (opus: recoverable).
  - `LDG-14` is disputed 2-2: fable and opus say it is behind `OPS-45`'s marker, while sol and astra point to a
    shown extension that is then lost.
  - So forms-r63h:205-206's "FSW joins it unless the owner closes FSW now" is wrong (sol, astra). F4 keeps the
    non-deposit consequences under N.
  - This doesn't void FSW: §3 stated "It covers deposit destinations only".
- **Destinations (4/4):** `WIR-14` `POST /v1/deposits`, including the `API-45` re-send (`13:566`), and `WIR-15`
  `GET /v1/deposits/{id}` (`13:592`). `WIR-42` returns a balance (fable, sol, astra).
- **Fable's trace corrections: VERIFIED. Both widen the trace, and neither refutes it.**
  - Step 5's "not yet signalled" should read "not yet acted on its signal": `die()` only sets `ProcDiePending` and
    the latch (`postgres18.c:3027-3050`).
  - Step 6 needs only that the primary never serves again before a promotion. Forms-final `STO-54`: "it rejoins
    only as a standby".
- **Q7 counter-argument (requested, not a vote).**
  - Fable and opus: the race is narrow. The postmaster's loop must be preempted between the waiter's signal and the
    reader's. Opus lists five conditions.
  - Opus concedes that the blocked re-sender is woken by the waiter's own lock release (`ProcArrayEndTransaction`
    ~2405, locks ~2454: VERIFIED), and that "if another tenant mints first, the payer's funds are credited to that
    tenant".
  - Fable's "repairable by a manual index skip" fails on (i): nobody can tell.
  - Fable's "an immediate stop has no window" is VERIFIED in source: `postmaster.c:2206` `TerminateChildren(SIGQUIT)`
    → `quickdie` `_exit(2)` (`postgres18.c:3019`), with no procarray end. It goes to the owner as information, with
    a configuration caveat.

## Brief errors (rule 10): verified; none voids an item

- forms-r63h:68: `18-syncrep.c:210/216` is the pre-wait early return, not the release (fable, opus). The release is
  at `:553-559`, with the wake loop at `:905-924`.
- forms-r63h:66: the local flush is `18-xact.c:1506` (opus). The `:1563-1567` quote is accurate.
- forms-r63h:72-73: an overclaim (above).
- forms-r63h:205-206: F4's scope (above).
- The owner draft's errors are below and fixed under rule 12.

## Owner-question fixes (rule 12, applied without a vote; none changes an option's behaviour)

- Intro: replace "Every hole … happens, and so do the reviewer's two new ones" with what the harness showed (sol,
  astra, fable).
- INV-ADR′ line: it contradicted itself (fable, opus).
- S2′: "that's now fixed" overstates NA′ (fable, sol, astra).
  - A's cost: add the pile-up from repeated stops (fable, sol; r63g STOP-B dissent).
  - B gains a misconfiguration line (all four; neutral wording).
- S3:
  - "no special server setting" → "one read permission and no special server setting" (opus).
  - B's cost: every new connection, not only restarts (opus, sol, astra).
  - "the service stops serving" → it can't open new connections (sol, astra).
  - "copying silently stops" is false (opus, sol, astra). `warm-standby.txt` says sync replication needs the list
    "set to a non-empty value"; H-d2 shows local acknowledgement. Streaming may continue.
  - A's slot: NA-sol's rule with its cost (coupling).
  - B gains the in-flight residue (trace 1).
- P:
  - Wait: "The service stays down, reads included" (opus).
  - Wait gains a misconfiguration line (opus, fable, astra).
  - Switch: "itself" adds an actor that `STO-56` doesn't name (sol, astra); `05:1316-1320` is passive. Add "doesn't
    bring back a lost deposit" (sol, astra).
- F:
  - "for an instant" → an unmeasured moment, for requests already connected (all four).
  - The bracket → "the draft calls it a restore, nobody can tell" (opus, sol, astra).
  - N gains its reach and permission (opus, sol, astra).
  - L gains "no runtime protection" (astra).
  - The immediate-stop line (fable, verified).
- Not adopted: readers' "left at its default" claims about deploy and failover tools are unverified.

## Run review points from r63h (unvoted unless marked; none changes behaviour)

- **NA′:**
  - Drop W1's "even when the worker exits (`OPS-49`) or `OPS-21`'s bound expires" (fable; opus flags the `OPS-49`
    half). Both are process exits. Keep E1's "except a sent COMMIT, which no deadline releases".
  - Make "neither a deadline nor the cancellation … releases its connection" normative. This replaces r63g's "MAY"
    point. Fable's r63h text is "… MUST NOT release"; worded without a double negative, that is "short of its
    process exiting, no deadline and no cancellation of the request or worker that sent it MAY release its
    connection …" (not voted).
- **C9:** scope the assertion to its step: "assert that, throughout this step, the primary holds no more…" (fable;
  sol and astra give equivalents).
- **NA-sol's C9 sentence, if A:** "unresolved backend waits" → "orphaned unresolved backend waits" (astra).
- **T1:** keep "both components" (4/4). Astra's text: prepend "For both components:".
- **T3b:** append "then repeat with the standbys' roles swapped" (opus; sol's is equivalent). A receive-LSN build
  can pass a tie by luck.
- **T4b:** holds only while the report stays unavailable (sol, astra).
- **T7's replacement** (sol, astra): "While each sent COMMIT remains unresolved and its transport remains live,
  assert its original connection and write checkout remain retained." (sol's text). Otherwise F5.
- **`ADR-0045`'s source citations:** release `18-syncrep.c:553-559`/`:905-924`; local flush `18-xact.c:1506`.
- **If FSW-L,** its ADR text: "that has not yet been signalled" → "that has not yet acted on its own signal". "If the
  primary is then lost before a standby has the commit" → "If the primary then never serves again before a standby
  is promoted". Append "An immediate-mode stop has no such window." (fable's text.)
- **If FSW-N:** `ADR-0045` records that it needs B′'s read and an uninterrupted session, and that under A it brings
  them in (sol, astra).

## Follow-ups (NOT filed; file `needs-triage` after the Run, no AI wording)

- **F1:** a WAL-history model in `tools/formal/` (r63g).
- **F2:** residual backends from exiting processes and dead database transports. It now includes trace 1's
  in-flight COMMITs under B′, which have no pool-derived bound, and repeated stops under STOP-A. Availability only.
- **F3:** run-time replication-config drift, plus pooler topology. Safety-relevant, 4-0 in r63g. The ADR states
  correct replication configuration as a trusted deployment assumption.
- **F4:** an audit of external actions against the objective. It covers:
  - `OPS-32`'s read-based deletes;
  - FSW's non-deposit consequences, kept even under N: the revocation replay, `OPS-32`, `API-11`, `API-53`, and
    `LDG-14` (disputed);
  - FSW in full under L;
  - `STO-54`'s terminated-waiter clause: no time limit, and no evidence that survives primary loss. The readers'
    off-primary-record shape is the input.
- **F5 (new, rule 7; only if the Run doesn't land T7's replacement):** no check catches a build that frees a sent
  COMMIT's connection on cancellation when B′ masks it in aggregate counts (sol, astra, fable).
