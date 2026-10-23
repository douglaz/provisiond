# Form S''' final (pv-s4m, panel C, after r63e). 2026-10-23

This is the voted text, with the change markers stripped. Tallies are in r63d/tally.md and r63e/tally.md.
**S1 is applied** (owner, 2026-10-23: "Three servers (Recommended)"): N3, ACCEPT 4-0, is merged into the text
below, and the N3 section at the end is kept as the record. r63f (/var/tmp/provisiond-panel-r63f/tally.md) settled S2's LOCK half: **LOCK-A carries** (all four pick or
accept it). It is filled in below. S2's STOP half (2-2, both acceptable to all four) and S3 (S3-A 4-0) wait on the
owner, and are marked **PENDING S2-STOP** and **PENDING S3**. r63c's Q2 (pv-n98) is Form F',
unchanged 4-0 in r63d: see /var/tmp/provisiond-panel-r63c/forms-final.md, "Form F'". r63c's Q3 is one Run, one PR.

## STO-7 (05-persistence.md)

**`05:141-143`** keeps its sentence. What it gains is **PENDING S2-STOP** (see "S2 texts" below).

**`05:147-153`** ("**`synchronous_commit` is `local` … re-sends its key.") becomes:

"**Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is `local`
on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every connection and
`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so PostgreSQL acknowledges a commit
only once one of them has flushed it to durable storage. The deployment MUST NOT let the primary commit without one
of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names`
empty. `OVR-18` alarms either standby being unavailable, and while both are, every write waits. **PENDING S3 (panel pick S3-A, 4-0):** *"The deployment turns
`restart_after_crash` off, so a backend crash stops the primary."* After any start of the primary, the deployment
MUST NOT let a component connect to it until one of them has flushed the primary's WAL up to the end of the WAL the
primary started with: a commit that was waiting for the standby when the primary stopped is "marked fully committed
once the primary database recovers", whether or not the standby has it.

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
  report the end of the WAL each has flushed, and the one further ahead is promoted: every acknowledged commit was
  flushed by one of them, and both hold a prefix of one WAL sequence, so that one holds them all and its promotion
  loses none. The
  engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
  continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
  every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
  component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
  standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
  store. `OVR-19` then names the other standby and the rejoining old
  primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
  without both standbys' report, or of the one not further ahead, of a standby `STO-7` does not name, or after the primary committed without it, served a component before it had caught
  up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
  `STO-56`'s record is committed into the promoted store before either component is started."

*S1 merge note (not spec text): N3-2 replaced the first half of this bullet's second sentence; OC's clause follows as
its own sentence. r63f readers confirmed it keeps the meaning.*

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
- C8, `05:199`: "`LDG-35`'s transaction-scoped locks, `STO-12`'s migrator lock and `SET LOCAL synchronous_commit` are
  compatible" becomes "`LDG-35`'s transaction-scoped locks and `STO-12`'s migrator lock are compatible".
- C9, `CNF-296` (`10:1057-1063`) becomes the text below. `[S2]` is LOCK-A's text (r63f).

  "**Every write waits for the standby** (*amended 2026-10-23, `ADR-0045`; was "The two synchronous writes hang
  alone"*). Stall both named standbys. Assert an engine write and an `api` write each wait in `SyncRep`, a read still
  succeeds, and `OVR-18`'s alarm fires. Exercise a contending engine write and assert `OPS-49`'s bounded retry and
  exit. Release the standby and
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
  crash the primary, restart it in place, and assert no component connects to it until the standby has caught up. With one standby unreachable, assert the
  procedure promotes neither as a restart. (`STO-5`, `STO-7`, `STO-54`, `OPS-15`)"
- C13, new `ADR-0045`. It records the owner's decision verbatim, "I think we should just suppose synchronous
  replication", and the owner's answers to S1-S3 (S1: "Three servers (Recommended)"). It amends three ADRs:
  - `ADR-0023`: its rejected option "Synchronous replication on every commit, recovery point zero" is adopted, and
    the stall it rejected is accepted as writes that wait; DL removes deadline-driven abandonment during the standby
    wait; lock-contention exhaustion can still restart the engine (LOCK-A, r63f).
  - `ADR-0022`: `OPS-49`'s bound no longer covers the standby wait.
  - `ADR-0042`: C5's clause.

  It quotes the PostgreSQL sources, labelling the source code as such, and names Patroni's strict mode as an example
  deployment only. Its rejected options are S' (every promotion a restore), B, D and F (forbid), two servers (S1), plus whatever
  loses S2 and S3. `README.md`'s ADR index gains a `0045` row, and the `0023` row (`README.md:94`) gains "; its second
  half is amended by `0045` (2026-10-23)".
- C14, `CONTEXT.md:184-185`: "a restart loses no committed work" becomes "a restart loses no acknowledged commit".
- C15, `tools/formal/Provisiond/Claim.lean:318-319`: the docstring's "`committed false` is the durable commit whose
  reply died in transport, so the store moved and the worker learned nothing" gains "; a promotion can undo it if the
  standby had not yet flushed it, and every process restarts across that (`STO-54`)". FE1 is none, 4-0, so no
  theorem changes.

- C16 (N3-3), `00:405`: the `OVR-19` row "Synchronous standby name … identifier" becomes "Synchronous standby names
  … two identifiers".

## S2 texts: the engine during a standby stall

r63f split S2 into STOP and LOCK. **LOCK-A carried**: `OPS-49`'s `lock_timeout` rule is unchanged, and C9 and C13
take LOCK-A's sentences, already filled in above. **STOP is PENDING S2-STOP** (owner): option A below keeps
`OPS-21` as it is, and option B amends it. The `OPS-49` `lock_timeout` append and the C9/C13 sentences under
Option B below are superseded by LOCK-A.

(r63e history: DL 2-2; CORE's objection.)

Both options keep, 4-0 in substance, the standby wait outside the store-call deadline and outside `OPS-49`'s
Store-retry bound, and they keep DL-3: `OVR-19` gains "| Pooled-connection keepalives | `STO-7` | durations | yes |".

**Option A, "stay stoppable"** (astra, sol; read only by its proposers):

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

**Option B, "wait it out"** (opus fully; fable on the `OPS-21` part):

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

## N3: three servers (APPLIED above, S1 = three; ACCEPT 4-0). Kept as the record

- In `STO-7`:
  - "`synchronous_standby_names` names the standby `OVR-19` names, so PostgreSQL acknowledges a commit only once that
    standby has flushed it" becomes "`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so
    PostgreSQL acknowledges a commit only once one of them has flushed it".
  - "without that standby" becomes "without one of them".
  - "While the standby is unavailable every write waits, and `OVR-18` alarms it" becomes "`OVR-18` alarms either
    standby being unavailable, and while both are, every write waits".
  - "until that standby has flushed" becomes "until one of them has flushed".
- In `STO-54`:
  - The heading becomes "**Promoting the standby that holds every acknowledged commit is a restart**".
  - Its second sentence becomes: "After every engine and `api` process connected to the old primary has stopped,
    both standbys `OVR-19` names report the end of the WAL each has flushed, and the one further ahead is promoted:
    every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence, so that one
    holds them all and its promotion loses none."
  - The `OVR-19` sentence becomes "`OVR-19` then names the other standby and the rejoining old primary, and writes
    continue once the other standby streams from the promoted store."
  - The list of other promotions gains, first, "without both standbys' report, or of the one not further ahead,".
- Elsewhere:
  - `00:405`'s row "Synchronous standby name … identifier" becomes "Synchronous standby names … two identifiers".
  - C2 becomes "synchronous streaming replication to two standbys (`STO-7`)".
  - In C4, C11 and C12, "the standby `STO-7` names", "the synchronous standby" and "the named standby" become "the
    standby `STO-54`'s report puts further ahead".
- In the checklist:
  - In C9, "Stall the named standby" becomes "Stall both named standbys", and C9 gains, before "Then assert": "Then
    stall one only and assert an engine write and an `api` write each succeed."
  - C12 gains: "With one standby unreachable, assert the procedure promotes neither as a restart."

## Run review points

- From r63f (each verified; tally.md):
  - `STO-13` `05:1398-1401`: "so that the time `api` queues behind a migration is bounded" gains ", except while
    that DDL's commit waits for a standby (`STO-7`)" (fable's text, not voted; no behaviour change).
  - `05:189-192`: record that, during a stall, backends left waiting by an exited process hold slots outside the
    `max_connections` account (astra, sol; no behaviour change).
  - C6 becomes "and either named standby being unavailable (`STO-7`)" (astra), to match N3's `STO-7`.
  - If STOP-B: the Run also updates every quote of the `OPS-21` sentences B rewrites: `ADR-0044:46-49`,
    `10-conformance-checklist.md:1602`, `tools/formal/Provisiond/StopRecord.lean:4-5` and `:118-119`. C13 also
    amends `ADR-0044`. DL-1's "no client-side deadline cuts it short" gains "The standby wait itself has no deadline;
    `OPS-49`'s contention-exhaustion exit remains applicable." (sol's text, not voted).
  - If S3-B: `05:195`'s "MAY front the pools only on two conditions" gains S3-B's pooler condition.
- S1 merge, single-standby wording left in voted text. These are wording only, with no behaviour change; fix them to
  the `ANY 1` sense in the Run:
  - STO-54's "after the primary committed without it" becomes "without one of them";
  - C9's "Release the standby", after "Stall both named standbys", becomes "Release both";
  - C12's "with the standby stalled while a write waits" becomes "with both standbys stalled";
  - CORE-1's heading and RS's "waiting for the standby … whether or not the standby has it" become "a standby";
  - E2's "while it waits for the standby" becomes "a standby".

- Locations: C14's phrase starts at `CONTEXT.md:184`. The Lean files are under `tools/formal/Provisiond/`. The
  ids `CNF-365` and `ADR-0045` are free at dc5d40d.
- S2 option B: `03:1738`'s Stop-record clock ("never resets") must say it pauses during a commit's wait for the
  standby.
- S3 option A: `CNF-365` also crashes a single backend (not the whole primary) while a write waits, and asserts no
  component reads the recovered commit before the standby has it.
- From r63c, still owed to the Run instruction (see /var/tmp/provisiond-panel-r63c/owner-questions.md):
  - the supervisor wording;
  - provider-apply on running rows;
  - `CNF-365` claim-before-cut, to be checked against this `CNF-365`.
