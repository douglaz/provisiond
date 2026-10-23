# Forms final (pv-s4m, panel C, after r63h). 2026-10-23

This is the voted text for pv-s4m, with the change markers stripped. It is r63e's forms-final with these applied:
- S1 (owner: "Three servers (Recommended)"; N3's record stays in r63e's copy);
- LOCK-A (r63f);
- PT (r63g, 4-0);
- NA′ and INV-ADR′ (r63h).

r63h's carried tests (T1, T2, T3b, T5 and T6a; T4b under PA-2) are written into C9 and C12, not listed as review
points. Tallies are in r63d-r63h's tally.md.

Four slots wait on the owner, each with its options' texts, panel pick first (r63h/owner-questions.md):
**PENDING S2-STOP**, **PENDING S3**, **PENDING PA** and **PENDING FSW**. pv-n98 is Form F', in
/var/tmp/provisiond-panel-r63c/forms-final.md, "Form F'". It is one Run and one PR (r63c Q3).

## STO-7 (05-persistence.md)

**`05:141-143`** keeps its sentence. What it gains is **PENDING S2-STOP** (see "S2 texts" below).

**`05:140-145`** ("Two rules about the connection"), after "…or the next checkout inherits an aborted transaction.",
gains:

"**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, neither a
deadline nor the cancellation of the request or worker that sent it releases its connection before the reply
arrives or the transport is found dead. Cancellation alone does not release that write checkout. Dead database
transports and process exits can leave waiting backends outside the pool's accounting. A request that finds the
write checkouts taken is refused at checkout (`STO-55`)."

**`05:147-153`** ("**`synchronous_commit` is `local` … re-sends its key.") becomes:

"**Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is `local`
on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every connection and
`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so PostgreSQL acknowledges a commit
only once one of them has flushed it to durable storage. The deployment MUST NOT let the primary commit without one
of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names`
empty. `OVR-18` alarms either standby being unavailable, and while both are, every write waits. **[PENDING S3: the
sentences here, then PENDING FSW. See "S3 texts" and "FSW texts".]**

No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side deadline
expires closes its connection, and the transaction's fate is the server's (`OPS-49`).

The deployment MUST NOT cancel or terminate a primary backend while it waits for the standby (wait event `SyncRep`),
other than by shutting the primary down.

A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not have been
replicated to the standby." is not acknowledged: the component treats it as a lost reply (`OPS-49`)."

## STO-54 (05-persistence.md)

STO-54 gains this, after its posture bullets:

"- **Promoting the standby that holds every acknowledged commit is a restart** (*added 2026-10-23, `ADR-0045`*).
  After every engine and `api` process connected to the old primary has stopped, both standbys `OVR-19` names
  report the end of the WAL each has flushed on the old primary's timeline, and the one further ahead is promoted: every acknowledged commit was
  flushed by one of them, and both hold a prefix of one WAL sequence, so that one holds them all and its promotion
  loses none. The
  engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
  continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
  every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
  component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
  standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
  store. `OVR-19` then names the other standby and the rejoining old
  primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
  without both standbys' report, with a report on another timeline, or of the one not further ahead, of a standby `STO-7` does not name, or after the primary committed without it, served a component before it had caught
  up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
  `STO-56`'s record is committed into the promoted store before either component is started. **[PENDING PA: see
  "PA texts".]**"

R's edits elsewhere:

- `05:1319`: "written into the restored store" becomes "written into the restored or promoted store".
- `CONTEXT.md`'s **Restore** (`:183-187`): it gains ", or a promotion `STO-54` classes as one", and "a restore loses
  an interval" becomes "a restore may lose an interval".

## Conforming edits

- C2, `05:1474`: "The deployment runs asynchronous streaming replication" becomes "The deployment runs synchronous
  streaming replication to two standbys (`STO-7`)".
- C3, `05:1480-1484`: the bullet "**Synchronous commit is bought for the two writes with no second truth.** …
  (`ADR-0023`)." is deleted.
- C4, `05:83-84` (`STO-5`'s note): it gains at its end "*Promoting the standby `STO-54`'s report puts further ahead is a restart; `STO-54`
  says what any other promotion is (`ADR-0045`).*"
- C5, `03:408-409` (`OPS-15`): ", nor on a store that may have lost committed writes, such as a promoted
  asynchronous standby" is deleted.
- C6, `00:338-339` (`OVR-18`): "and a stalled synchronous standby, which hangs the two money-in transactions `STO-7`
  commits synchronously and nothing else." becomes "and a stalled synchronous standby, on which every write waits
  (`STO-7`)."
- C7: the `05:186-188` bullet "**Synchronous-commit transactions are capped per replica** …" is deleted, and so is
  `00:412`'s `OVR-19` row "Synchronous-commit concurrency cap per replica".
- C8 (under S3-A or AB only; S3-B′ replaces the whole bullet), `05:199`: "`LDG-35`'s transaction-scoped locks, `STO-12`'s migrator lock and `SET LOCAL synchronous_commit` are
  compatible" becomes "`LDG-35`'s transaction-scoped locks and `STO-12`'s migrator lock are compatible".
- C9, `CNF-296` (`10:1057-1063`) becomes the text below.

  "**Every write waits for the standby** (*amended 2026-10-23, `ADR-0045`; was "The two synchronous writes hang
  alone"*). Stall both named standbys. Assert an engine write and an `api` write each wait in `SyncRep`, a read still
  succeeds, and `OVR-18`'s alarm fires. Exercise a contending engine write and assert `OPS-49`'s bounded retry and
  exit. First fill the replica's write-checkout budget with waiting commits. Cancel every `api` request whose write
  waits, its client disconnecting, and assert the primary never holds more of that replica's backends than its
  pool, a further write request is refused `overloaded`, and a read still succeeds. **[PENDING S3: under A, NA-sol's
  C9 sentence goes here.]** Release the standby and
  assert the caller's re-sent funding request returns the same deposit (`API-45`) and the rail's replayed settlement
  credits once (`STO-31`). Then stall one only and assert an engine write and an `api` write each
  succeed. Then assert `synchronous_commit` reads `on` on a freshly checked-out connection
  (`CNF-56`'s method). (`STO-7`, `STO-54`, `OVR-18`)"
- C10, `CNF-299` (`10:1078-1087`): two spans are deleted.
  - The title's ", and the pool keeps serving under a stalled standby".
  - The sentence "Then stall the standby (`CNF-296`'s method) with more funding requests than the
    synchronous-commit cap and assert no more than the cap's connections are occupied and a suspension request
    (`API-58`) is admitted."
- C11, `tools/formal/Provisiond/Restore.lean:28`: "What the model omits: the promoted-standby condition and the money
  release." becomes "What the model omits: the money
  release. Promoting the standby `STO-54`'s report puts further ahead is a restart (`STO-54`), and any other promotion is a `RestoreTrace`."
- C12, new `CNF-365`:

  "**Promoting the standby `STO-54`'s report puts further ahead is a restart** (`ADR-0045`). With both components
  running, let one create
  commit step 8 and order, and claim a second. Kill the primary and promote the standby `STO-54`'s report puts further ahead by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine and `api` process connected
  to the old primary has stopped before any component connects to the promoted store, and that the old primary
  serves no component; that both rows are on the promoted store; that no restore record is written; and that the
  successor's startup pass takes `OPS-15`'s restart branch. Then, with the standby stalled while a write waits,
  **[PENDING S3: the crash sentence; see "S3 texts".]** With one standby unreachable, assert the
  procedure promotes neither as a restart **[PENDING PA]**. With one standby on another timeline, assert the
  procedure promotes neither as a restart. Stop one standby, make an acknowledged write, stop the other, lose the
  primary, restart both standbys, and assert the procedure promotes the one holding that write. (`STO-5`, `STO-7`,
  `STO-54`, `OPS-15`)"
- C13, new `ADR-0045`. It records the owner's decision verbatim, "I think we should just suppose synchronous
  replication", and the owner's answers to S1, S2′, S3, PA and FSW (S1: "Three servers (Recommended)"). It amends
  three ADRs:
  - `ADR-0023`: its rejected option "Synchronous replication on every commit, recovery point zero" is adopted, and
    the stall it rejected is accepted as writes that wait; DL removes deadline-driven abandonment during the standby
    wait; lock-contention exhaustion can still restart the engine (LOCK-A, r63f).
  - `ADR-0022`: `OPS-49`'s bound no longer covers the standby wait.
  - `ADR-0042`: C5's clause.

  It quotes the PostgreSQL sources, labelling the source code as such, and names Patroni's strict mode as an example
  deployment only. It also records:
  - **The design objective** (INV-ADR′, rationale only): "Design objective: irreversible external consequences must
    not depend on history a promotion classified as a restart may discard. A restore can still lose acknowledged
    history." Known counterexample: `OPS-32`'s sweep acts on reads (`03:1630-1635`). Follow-up F4 audits against
    it.
  - **Why the report is per timeline** (PT): it is what each standby holds, not `receive_lsn`. After a restart with
    the primary dead, both standbys reported `pg_last_wal_receive_lsn() = 0/4000000`, whatever they held (H-e). An
    old primary started as a standby without `pg_rewind` reported a TL1 position ahead of s2's TL2 position, yet
    lacks every TL2 commit (H-e2).
  - **Correct replication configuration is a trusted deployment assumption.** An emptied
    `synchronous_standby_names` makes every commit local, and nothing in provisiond sees it (H-d2; follow-up F3).
  - Source citations: waiters are released at `18-syncrep.c:553-559` and `:905-924`; the commit is flushed locally
    at `18-xact.c:1506`. Any window it mentions is "unmeasured".

  Its rejected options are S' (every promotion a restore), B, D and F (forbid), two servers (S1), INV-STO ("Nothing
  irreversible rests on an unacknowledged commit", 0-4), plus whatever loses S2-STOP, S3, PA and FSW.
  `README.md`'s ADR index gains a `0045` row, and the `0023` row (`README.md:94`) gains "; its second
  half is amended by `0045` (2026-10-23)".
- C14, `CONTEXT.md:184-185`: "a restart loses no committed work" becomes "a restart loses no acknowledged commit".
- C15, `tools/formal/Provisiond/Claim.lean:318-319`: the docstring's "`committed false` is the durable commit whose
  reply died in transport, so the store moved and the worker learned nothing" gains "; a promotion can undo it if the
  standby had not yet flushed it, and every process restarts across that (`STO-54`)". FE1 is none, 4-0, so no
  theorem changes.

- C16 (N3-3), `00:405`: the `OVR-19` row "Synchronous standby name … identifier" becomes "Synchronous standby names
  … two identifiers".

## S2 texts: PENDING S2-STOP (panel pick A, 3-1 in r63g; the reviewer picks A; both acceptable to all four)

**LOCK-A carried** (r63f): `OPS-49`'s `lock_timeout` rule is unchanged, and C9 and C13 take LOCK-A's sentences,
already filled in above. Option A below keeps `OPS-21` as it is, and option B amends it. The `OPS-49`
`lock_timeout` append and the C9/C13 sentences under Option B below are superseded by LOCK-A.

Both options keep, 4-0 in substance, the standby wait outside the store-call deadline and outside `OPS-49`'s
Store-retry bound, and they keep DL-3: `OVR-19` gains "| Pooled-connection keepalives | `STO-7` | durations | yes |".

**Option A, "stay stoppable"** (panel pick):

- `05:141-143` gains sol's text: "A standby wait has no server-side timeout and is excluded from that call's
  store-call and Store-retry deadlines. `OPS-21`'s stop bounds still apply." It also keeps DL-1's clause "a dead
  transport during it is found by the connection's TCP keepalives (`OVR-19`)" (a Run review point).
- `03:1830` (`OPS-49`): "The bound covers connection, execution, commit, read-back and backoff together" becomes
  "… together, but not a commit's wait for the standby (`STO-7`),". This is DL-2 with its contradicted words
  deleted.
- C9's [S2], sol's text: "Assert an engine write and an `api` write each wait in `SyncRep`," followed after the
  alarm by "Exercise a contending engine write and assert `OPS-49`'s bounded retry and exit."
- C13's sentence, astra's text: "DL removes deadline-driven abandonment during the standby wait; lock-contention
  exhaustion can still restart the engine."
- Known limit (sol): every exit during a stall leaves backends waiting outside the pools. In a long stall,
  `05:191`'s "fit inside `max_connections`" stops holding.

**Option B, "wait it out"**:

- DL-1 at `05:143`, after "(`OPS-49`).", read by all four: "A commit's wait for the standby is the exception
  (*added 2026-10-23, `ADR-0045`*): it has no server-side timeout, and no client-side deadline cuts it short. A
  backend waiting there never notices that its client has gone, and would keep its locks and its connection slot
  outside every pool (`STO-55`). So the wait ends when the standby confirms or the primary shuts down, and a dead
  transport during it is found by the connection's TCP keepalives (`OVR-19`)."
- DL-2 at `03:1830`, read by all four: "The bound covers connection, execution, commit, read-back and backoff
  together, but not a commit's wait for the standby, which no client-side deadline cuts short (`STO-7`),".
- `OPS-21`, `03:1765-1772` (opus; fable's text is equivalent):
  - After "backoff together", insert ", but not a commit's wait for the standby (`STO-7`)".
  - The supervisor's wait ("MUST wait at least the Stop-record bound after a stop before it kills the engine")
    gains "and any commit's wait for the standby".
  - `00:402`'s row follows (fable).
- `OPS-49`, `03:1846-1850` (opus), appended: "A `lock_timeout` while a primary backend waits with wait event
  `SyncRep` (`STO-7`) does not consume the bound; `OVR-18`'s stalled-standby alarm is that loop's alarm."
- C9's [S2], as read by all four: "Assert an engine write and an `api` write each block without the engine
  exiting,".
- C13's sentence: "and DL answers its crash loop."

## S3 texts: PENDING S3 (panel pick B′, 4-0 in r63g; the reviewer picks B; A and AB acceptable to all four)

**S3-B′ (panel pick).**

- `STO-7`'s slot gets this sentence and nothing else: no `restart_after_crash` sentence and no start gate.

  "**A component checks each new connection before using it** (*added 2026-10-23, `ADR-0045`*): it MUST NOT use a
  new store connection until one of the standbys `OVR-19` names has flushed the primary's WAL up to the flush
  position the primary reports on that connection, which it learns by reading the standbys' reported positions,
  never by committing a write. A check that errors, cannot see a standby's position, or has not passed is a failed
  connection attempt: the connection is closed unused, and nothing falls back to an unchecked one. Every
  connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is
  checked: a commit that was waiting for a standby when the primary stopped is "marked fully committed once the
  primary database recovers", whether or not a standby has it."

- `05:195-201`, the bullet "**A pooler in transaction mode MAY front the pools only on two conditions.** … where a
  pooler is present.", is replaced by the bullet below. This supersedes C8.

  "- **No pooler in transaction mode fronts the pools** (*amended 2026-10-23, `ADR-0045`; until then one "MAY front
  the pools only on two conditions"*): behind one, a crash of the primary ends its backends but not the component's
  connection to the pooler, so `STO-7`'s new-connection check would never run."

- `CNF-56`'s "MUST force a backend reassignment where a pooler is present" is deleted.
- C12's crash sentence: "crash the primary, restart it in place, then separately crash one backend while a write
  waits, and each time assert no component uses a connection before a standby has flushed at or past the flush
  position it reported. With healthy replication, withhold position-query results through the connection-attempt
  deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend.
  Inspect the deployed topology for transaction-mode pooling."
- C13's `ADR-0045` records the following (as rationale, not as a MUST):
  - **The privilege** (H-f). Without `pg_read_all_stats`, a role sees only pid, usesysid, usename and
    application_name in `pg_stat_replication`. So the deployment grants it, or provides a SECURITY DEFINER function
    owned by a role that holds it. A missing grant fails closed: no connection is ever used.
  - **The flush position, not the insert position** (H-f, xlog.c:9488). The insert position can sit past a page
    header that no standby's flush reaches on an idle primary. A flush target is safe because no connection is below
    `local`.
  - **A read, not a write.** A write check leaves one `SyncRep` waiter per attempt during a stall (H-f: 3 of 3).
  - **Rejected for v1:** re-admitting a transaction-mode pooler with a per-transaction check.
- `11-open-findings.md:438` (F51's record) stays as a record. Its resolution line gains "amended by `ADR-0045`".

**S3-A.**

- `STO-7`'s slot: "The deployment turns `restart_after_crash` off, so a backend crash stops the primary. After any
  start of the primary, the deployment MUST NOT let a component connect to it until one of them has flushed the
  primary's WAL up to the end of the WAL the primary started with: a commit that was waiting for the standby when
  the primary stopped is "marked fully committed once the primary database recovers", whether or not the standby
  has it."
- **NA-sol travels with A** (r63h, S3 coupling). After NA′'s text at `05:140-145`: "A dead transport does not
  replenish the write-checkout budget while its server transaction may still be waiting. Until that backend is
  known to have finished, its budget remains charged, or the component process exits." C9's slot: "Repeat transport
  failures while the replica remains alive; assert unresolved backend waits plus active write checkouts never
  exceed its write budget."
- C12's crash sentence: "crash the primary, restart it in place, and assert no component connects to it until the
  standby has caught up." `CNF-365` also crashes a single backend (not the whole primary) while a write waits, and
  asserts no component reads the recovered commit before the standby has it.
- `05:195`'s pooler bullet stays, and C8 applies.

**S3-AB.** It is r63f's (`/var/tmp/provisiond-panel-r63f/brief.md:221`): "S3-A's sentence, with RS kept as it is,
plus S3-B's sentence without its pooler clause." Whether NA-sol is needed under AB was not traced: readers
answered the coupling for A only, and AB's check blocks the measured pile-up much as B′ does. It is open if the
owner picks AB.

## PA texts: PENDING PA (panel pick PA-2, 4-0 in r63g; the reviewer picks PA-2; PA-1 acceptable to all four)

**PA-2.**

- Draft `STO-54` gains, after the "Any other promotion … is a restore" sentence: "Only an operator starts a
  promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
  without a primary until both standbys report or an operator decides."
- C12's "With one standby unreachable, assert the procedure promotes neither as a restart" gains "and none until an
  operator decides".

**PA-1 (the draft).** No text. C12 is unchanged.

## FSW texts: PENDING FSW (panel pick FSW-N, 3-1 in r63h; both acceptable to all four; the reviewer made no pick)

**FSW-N.**

- `STO-7` gains this sentence after S3's new-connection check. Under S3-A, it brings that check and its read in.

  "Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a
  target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the
  result and repeat the whole read."

- `ADR-0045` records the window as the reason, and that it covers deposit destinations only. These are `WIR-14`'s
  POST, including `API-45`'s re-send, and `WIR-15`'s GET. The non-deposit consequences stay with follow-up F4.

**FSW-L.** It has no normative text. `ADR-0045` gains the paragraph below, and follow-up F4 owns the window:

> "**Accepted for v1: the fast-shutdown window.** A fast shutdown of the primary ends every wait for a standby
> ("Users will stop waiting if a fast shutdown is requested"), and a commit that was waiting becomes visible before
> its backend exits. The postmaster signals backends one at a time, so a backend on an already-checked connection
> that has not yet been signalled can read such a commit and return it. If the primary is then lost before a standby
> has the commit, the promotion that follows can discard it. This is source analysis: it was not reproduced, and the
> window's length is unmeasured. The follow-up audit of external actions owns it."

## Run review points

- **From r63f** (each verified; r63f/tally.md):
  - `STO-13` `05:1398-1401`: "so that the time `api` queues behind a migration is bounded" gains ", except while
    that DDL's commit waits for a standby (`STO-7`)" (fable's text, not voted; no behaviour change).
  - `05:189-192`: record that, during a stall, backends left waiting by an exited process or a dead transport hold
    slots outside the `max_connections` account (astra, sol; no behaviour change).
  - C6 becomes "and either named standby being unavailable (`STO-7`)" (astra), to match N3's `STO-7`.
  - If STOP-B:
    - The Run also updates every quote of the `OPS-21` sentences B rewrites: `ADR-0044:46-49`,
      `10-conformance-checklist.md:1602`, `tools/formal/Provisiond/StopRecord.lean:4-5` and `:118-119`.
    - C13 also amends `ADR-0044`.
    - DL-1's "no client-side deadline cuts it short" gains "The standby wait itself has no deadline; `OPS-49`'s
      contention-exhaustion exit remains applicable." (sol's text, not voted).
    - `03:1763`'s Stop-record clock ("never resets") must say it pauses during a commit's wait for the standby.
      r63e cited it as `03:1738`.
- **S1 merge.** Single-standby wording is left in the voted text. These are wording fixes only, with no behaviour
  change; fix them to the `ANY 1` sense in the Run:
  - STO-54's "after the primary committed without it" becomes "without one of them";
  - C9's "Release the standby", after "Stall both named standbys", becomes "Release both";
  - C12's "with the standby stalled while a write waits" becomes "with both standbys stalled";
  - under S3-A, CORE-1's heading and RS's "waiting for the standby … whether or not the standby has it" become "a
    standby";
  - E2's "while it waits for the standby" becomes "a standby".
- **Locations.** C14's phrase starts at `CONTEXT.md:184`. The Lean files are under `tools/formal/Provisiond/`. The
  ids `CNF-365` and `ADR-0045` are free at dc5d40d.
- **From r63c,** still owed to the Run instruction (see /var/tmp/provisiond-panel-r63c/owner-questions.md):
  - the supervisor wording;
  - provider-apply on running rows;
  - `CNF-365` claim-before-cut, to be checked against this `CNF-365`.
- **From r63h** (r63h/tally.md; unvoted wording, no behaviour change):
  - NA′:
    - From r63g's opus W1, keep only E1's "except a sent COMMIT, which no deadline releases". Drop "even when the
      worker exits (`OPS-49`) or `OPS-21`'s bound expires": both are process exits, which NA′ already excepts
      (`03:1829` "the engine MUST exit non-zero"; fable, opus).
    - Make NA′'s release clause normative, with no double negative: "no deadline and no cancellation of the
      request or worker that sent it MAY release its connection …" (fable). This replaces r63g's "MAY" point.
  - C9:
    - Scope the assertion to its step: "assert that, throughout this step, the primary holds no more…" (fable; sol
      and astra give equivalents).
    - Give "the replica" an antecedent, such as "one `api` replica" (opus).
    - Under S3-A, write "orphaned unresolved backend waits" in NA-sol's sentence (astra).
  - C12:
    - Under S3-B′, T1 names both components: prepend "For both components:" (4/4; astra's words).
    - T3b's sentence gains "then repeat with the standbys' roles swapped" (opus; sol's is equivalent).
    - Under PA-2, T4b's assertion holds only while the report stays unavailable (sol, astra).
  - C9 or C12, in place of the dropped T7: "While each sent COMMIT remains unresolved and its transport remains
    live, assert its original connection and write checkout remain retained." (sol's text). If it doesn't land,
    file F5.
  - If FSW-L, its paragraph:
    - "that has not yet been signalled" becomes "that has not yet acted on its own signal";
    - "If the primary is then lost before a standby has the commit" becomes "If the primary then never serves
      again before a standby is promoted";
    - append "An immediate-mode stop has no such window." (fable's text; verified in source).
  - If FSW-N: `ADR-0045` says it needs S3-B′'s read permission and an uninterrupted session (sol, astra).

## Follow-up beads (NOT filed; file `needs-triage` after the Run, with no AI wording)

- **F1:** a WAL-history model in `tools/formal/`.
  - Prove `BarrierAck ∧ SameHistory ⇒ Replicated`.
  - Exhibit counterexamples without `SameHistory` (H-d) and with a lagging promotion (H-e).
- **F2:** residual backends during a stall, from:
  - exiting processes, and repeated stops under STOP-A;
  - dead database transports, including COMMITs still in flight under S3-B′. Their number has no pool-derived bound
    (r63h trace 1, from source).

  Remedies: a supervisor backoff, or a budget across restarts and rollouts (`05:189-192`). Availability only.
- **F3:** replication-configuration drift at run time.
  - An emptied `synchronous_standby_names` plus a reload makes every commit local, and nothing in provisiond sees it
    (H-d2). `CNF-296` checks only a fresh connection.
  - It also covers a transaction-mode pooler added later.
  - Safety-relevant (4-0 in r63g); file it with priority.
- **F4:** an audit of every externally visible action against `ADR-0045`'s objective. It covers:
  - `OPS-32`'s read-based deletes of images and temporary keys;
  - the fast-shutdown window's non-deposit consequences, even under FSW-N: the replayed revocation (a token live
    again after a promotion classed a restart), `OPS-32`, `API-11`'s 409, `API-53`'s revision, and `LDG-14`'s
    runway (disputed 2-2);
  - under FSW-L, the window in full;
  - `STO-54`'s "had a waiting backend cancelled or terminated" clause. It has no time limit, and no evidence of it
    survives the primary's loss. The readers' shape (a durable off-primary record of the primary's shutdown, or a
    conservative restore classification when it's unknown) is the input. It is a deployment duty, so state its
    misconfiguration.
- **F5** (only if the Run doesn't land T7's replacement): no check catches a build that frees a sent COMMIT's
  connection on cancellation when S3-B′ masks it in aggregate counts.
