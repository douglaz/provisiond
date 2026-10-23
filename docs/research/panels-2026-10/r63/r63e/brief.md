# Panel brief r63e: Q1 (pv-s4m) under synchronous replication, the LAST round. 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of `provisiond-spec`
at `dc5d40d`. Read `AGENTS.md` first. You MAY edit tracked files in the clone to test a claim. Write nothing outside
it. Never commit, push, call a provider API, or run `br`. **Run no gate and no `lake`.** Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft by minute 12. Web lookups are allowed only for
`postgresql.org/docs`, `github.com/postgres/postgres` or `raw.githubusercontent.com/postgres/postgres`, and
`patroni.readthedocs.io`. Quote what you use.

**This is the last round.** A span that doesn't converge here takes the fallback stated below, or goes to the owner.

## Settled (not for re-vote)

- **The owner's decision on Q1, verbatim: "I think we should just suppose synchronous replication".** Q2 is form F'
  (`/var/tmp/provisiond-panel-r63c/forms-final.md`, "Form F'"). Q3 is one Run. `STO-54`'s restore procedure stays
  for a restore from backup or point-in-time recovery.
- From r63d: E1, E2 and E3 are KEEP. RF is R. F' is UNCHANGED. Their texts appear below where they would land.
- **A correction to r63d's brief.** It said "Under strict settings, only a cancel or terminate reaches that
  state", meaning a commit visible before the standby has it. That was wrong: a primary restart also reaches it.
  26.2.8.4: "If primary restarts while commits are waiting for acknowledgment, those waiting transactions will be
  marked fully committed once the primary database recovers." A fast shutdown releases waiters too (26.2.8.1).
  Span RS answers this. Three r63d readers traced it: a deposit visible after the restart, then lost on promotion,
  breaks `05:867` and `04:830`.

## Facts r63d established (verified by the manager in the PostgreSQL source and docs)

- FA1: `statement_timeout` and `transaction_timeout` are disabled before a commit's wait, on the simple and the
  extended protocol (postgres.c `finish_xact_command`; xact.c:2414, before :2422).
- FA2: a backend waiting in `SyncRep` never notices that its client has gone. syncrep.c waits on `WL_LATCH_SET |
  WL_POSTMASTER_DEATH` with interrupts held, and has no `CHECK_FOR_INTERRUPTS`. It keeps its locks — xact.c:1605:
  "we have marked clog, but still show as running in the procarray and continue to hold locks" — and it keeps its
  connection slot.
- A transaction that wrote no WAL never waits (xact.c:1608 `if (wrote_xlog && markXidCommitted)`).
- FC1: under `ANY 1 (s1, s2)`, the standby that has flushed further holds every acknowledged commit, provided
  both report. Patroni: "compare its LSN with the LSN on at least one node".
- FC2: after a failover with two servers, every write waits until a standby streams from the promoted store.
- `ADR-0023:158-170` traced a client-side deadline under a stalled standby: "the retry re-commits and re-stalls
  until the bound exhausts, the engine exits, and the successor's startup pass — which writes — stalls the same
  way."

## Form S''' (base: two database servers, one standby)

The spans RS, DL, OC, WR and RL are new since r63d and are voted one by one. Everything else is CORE.
Items marked *(new)* are new text inside CORE.

**`STO-7`** (05-persistence.md)

- **CORE-1** replaces `05:147-153` ("**`synchronous_commit` is `local` … re-sends its key."). It is unchanged from
  r63d: "**Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit`
  is `local` on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every
  connection and `synchronous_standby_names` names the standby `OVR-19` names, so PostgreSQL acknowledges a commit
  only once that standby has flushed it to durable storage. The deployment MUST NOT let the primary commit without
  that standby: no connection lowers `synchronous_commit`, and the primary never serves with
  `synchronous_standby_names` empty. While the standby is unavailable every write waits, and `OVR-18` alarms it."
- **RS** follows CORE-1: "After any start of the primary, the deployment MUST NOT let a component connect to it
  until that standby has flushed the primary's WAL up to the end of the WAL the primary started with: a commit that
  was waiting for the standby when the primary stopped is "marked fully committed once the primary database
  recovers", whether or not the standby has it." *There is no fallback (see Settled).*
- E1, E2 and E3 follow as settled:
  - E1: "No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side
    deadline expires closes its connection, and the transaction's fate is the server's (`OPS-49`)."
  - E2: "The deployment MUST NOT cancel or terminate a primary backend while it waits for the standby (wait event
    `SyncRep`), other than by shutting the primary down."
  - E3: "A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not
    have been replicated to the standby." is not acknowledged: the component treats it as a lost reply
    (`OPS-49`)."
- **DL** replaces r63d's C1, which is withdrawn.
  - DL-1: `05:141-143` keeps its sentence, and gains after "(`OPS-49`).": "A commit's wait for the standby is the
    exception (*added 2026-10-23, `ADR-0045`*): it has no server-side timeout, and no client-side deadline cuts it
    short. A backend waiting there never notices that its client has gone, and would keep its locks and its
    connection slot outside every pool (`STO-55`). So the wait ends when the standby confirms or the primary shuts
    down, and a dead transport during it is found by the connection's TCP keepalives (`OVR-19`)."
  - DL-2: `03:1830` (`OPS-49`): "The bound covers connection, execution, commit, read-back and backoff together"
    becomes "The bound covers connection, execution, commit, read-back and backoff together, but not a commit's
    wait for the standby, which no client-side deadline cuts short (`STO-7`),".
  - DL-3: `OVR-19` gains the row "| Pooled-connection keepalives | `STO-7` | durations | yes |". `00:400` already
    has "Startup-lock connection keepalives".
  - Why: without DL, by FA2 and E1, each write whose client deadline expires during a stall leaves a backend
    outside every pool, still holding its locks. Then `05:189-193`'s "together fit inside `max_connections`" and
    C9's "a read still succeeds" stop holding, and `ADR-0023`'s crash loop follows. Under DL, `03:1841`'s "the
    only lost reply is a dead transport", `Types.lean:23` and `ADR-0022:23/:63` stay true as written.
  - *Fallback: to the owner, with r63d's C1 as the alternative.*

**`STO-54`** gains, after its posture bullets (CORE-2):

"- **Promoting the synchronous standby is a restart** (*added 2026-10-23, `ADR-0045`*). The standby `STO-7` names
holds every commit the primary acknowledged, so its promotion loses none, and the engine comes up on it under
`STO-5`'s restart rule**[OC]**. Before any component connects to the promoted store, the deployment MUST stop every
engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a component
again: it may hold commits the standby lacks ("Some transactions may not show as committed on the standby, even
though they show as committed on the primary"), so it rejoins only as a standby of the promoted store. **[WR]**
**[RL]**"

- **OC** at [OC]: ", unless a restore record (`STO-56`) is open there, in which case a process that starts is
  continuing that incident (below)". Why: `05:1522` says "a process that starts while a restore record is open is
  continuing that incident, not restarting". *Fallback: delete "and the engine comes up on it under `STO-5`'s
  restart rule".*
- **WR** at [WR]: "`OVR-19` then names the standby that is to stream from the promoted store, and the promoted
  store's `synchronous_standby_names` names it too; every write waits until it streams (`STO-7`)." Why: FC2, and
  `00:405`'s standby name is startup-validated. *Fallback: delete WR. C12 then loses "with a standby streaming
  from the promoted store" and "the successor's startup pass takes `OPS-15`'s restart branch".*
- **RL** at [RL] is R's sentence, with its list widened: "Any other promotion — of a standby `STO-7` does not name,
  or after the primary committed without it, served a component before it had caught up, or had a waiting backend
  cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and `STO-56`'s record is
  committed into the promoted store before either component is started." *Fallback: r63d's list, "of a standby
  `STO-7` does not name, or after the primary committed without it".*
- R's settled edits: `05:1319` "written into the restored store" becomes "written into the restored or promoted
  store". `CONTEXT.md`'s **Restore** (`:183-187`) gains ", or a promotion `STO-54` classes as one", and "a restore
  loses an interval" becomes "a restore may lose an interval".

**Conforming edits (CORE)**

- C2, `05:1474`: "The deployment runs asynchronous streaming replication" becomes "The deployment runs synchronous
  streaming replication (`STO-7`)".
- C3, `05:1480-1484`: the bullet "**Synchronous commit is bought for the two writes with no second truth.** …
  (`ADR-0023`)." is deleted.
- C4, `STO-5`'s note `05:83-84` gains at its end: "*Promoting the standby `STO-7` names is a restart; `STO-54` says
  what any other promotion is (`ADR-0045`).*"
- C5, `03:408-409` (`OPS-15`): ", nor on a store that may have lost committed writes, such as a promoted
  asynchronous standby" is deleted.
- C6, `00:338-339` (`OVR-18`): "and a stalled synchronous standby, which hangs the two money-in transactions
  `STO-7` commits synchronously and nothing else." becomes "and a stalled synchronous standby, on which every write
  waits (`STO-7`)."
- C7: the bullet at `05:186-188`, "**Synchronous-commit transactions are capped per replica** …", is deleted. So
  is `00:412`'s `OVR-19` row "Synchronous-commit concurrency cap per replica".
- C8, `05:199`: "`LDG-35`'s transaction-scoped locks, `STO-12`'s migrator lock and `SET LOCAL synchronous_commit`
  are compatible" becomes "`LDG-35`'s transaction-scoped locks and `STO-12`'s migrator lock are compatible".
- C9, `CNF-296` (`10:1057-1063`) becomes: "**Every write waits for the standby** (*amended 2026-10-23, `ADR-0045`;
  was "The two synchronous writes hang alone"*). Stall the named standby. Assert an engine write and an `api` write
  each block without the engine exiting, a read still succeeds, and `OVR-18`'s alarm fires. Release the standby
  and assert the caller's re-sent funding request returns the same deposit (`API-45`) and the rail's replayed
  settlement credits once (`STO-31`). Then assert `synchronous_commit` reads `on` on a freshly checked-out
  connection (`CNF-56`'s method). (`STO-7`, `STO-54`, `OVR-18`)" *(new: "without the engine exiting")*
- C10, `CNF-299` (`10:1078-1087`): two deletions.
  - *(new)* The title's ", and the pool keeps serving under a stalled standby".
  - The sentence "Then stall the standby (`CNF-296`'s method) with more funding requests than the
    synchronous-commit cap and assert no more than the cap's connections are occupied and a suspension request
    (`API-58`) is admitted."
- C11, `Restore.lean:28`: "What the model omits: the promoted-standby condition and the money release." becomes
  "What the model omits: the money release. Promoting the synchronous standby is a restart (`STO-54`), and any other
  promotion is a `RestoreTrace`."
- C12, new `CNF-365`: "**Promoting the synchronous standby is a restart** (`ADR-0045`). With both components
  running, let one create commit step 8 and order, and claim a second. Kill the primary and promote the named
  standby by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine
  and `api` process connected to the old primary has stopped before any component connects to the promoted store,
  and that the old primary serves no component; that both rows are on the promoted store; that no restore record is
  written; and that the successor's startup pass takes `OPS-15`'s restart branch. Then, with the standby stalled
  while a write waits, crash the primary, restart it in place, and assert no component connects to it until the
  standby has caught up. (`STO-5`, `STO-7`, `STO-54`, `OPS-15`)" *(new: the streaming standby, and the last
  check)*
- C13, new `ADR-0045`. It records the owner's decision verbatim. It amends three ADRs:
  - `ADR-0023`: its rejected option "Synchronous replication on every commit, recovery point zero" is adopted; the
    stall it rejected is accepted as writes that wait, and DL answers its crash loop.
  - *(new)* `ADR-0022`: `OPS-49`'s bound no longer covers the standby wait.
  - `ADR-0042`: C5's clause.

  It quotes the PostgreSQL sources, labelling the source code as such, and names Patroni's strict mode as an example
  deployment only. Its rejected options are S' (every promotion a restore), B, D and F. *(new)* `README.md`'s ADR
  index gains a `0045` row, and the `0023` row (`README.md:94`) gains "; its second half is amended by `0045`
  (2026-10-23)".
- C14 *(new)*, `CONTEXT.md:185`: "a restart loses no committed work" becomes "a restart loses no acknowledged
  commit".
- C15 *(new)*, `Claim.lean:318-319`: the docstring's "`committed false` is the durable commit whose reply died in
  transport, so the store moved and the worker learned nothing" gains "; a promotion can undo it if the standby had
  not yet flushed it, and every process restarts across that (`STO-54`)". The claim model has no promotion. FE1
  asks whether any theorem needs more than this docstring.

## N3: three database servers, two standbys (replaces these base spans if the owner picks three)

- N3-1, in CORE-1:
  - "`synchronous_standby_names` names the standby `OVR-19` names, so PostgreSQL acknowledges a commit only once
    that standby has flushed it" becomes "`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19`
    names, so PostgreSQL acknowledges a commit only once one of them has flushed it".
  - "without that standby" becomes "without one of them".
  - "While the standby is unavailable every write waits, and `OVR-18` alarms it" becomes "`OVR-18` alarms either
    standby being unavailable, and while both are, every write waits".
  - In RS, "until that standby has flushed" becomes "until one of them has flushed".
- N3-2, in CORE-2:
  - The heading becomes "**Promoting the standby that holds every acknowledged commit is a restart**".
  - Its second sentence becomes: "After every engine and `api` process connected to the old primary has stopped,
    both standbys `OVR-19` names report the end of the WAL each has flushed, and the one further ahead is promoted:
    every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence, so that one
    holds them all and its promotion loses none."
  - WR becomes "`OVR-19` then names the other standby and the rejoining old primary, and writes continue once the
    other standby streams from the promoted store."
  - RL's list gains, first, "without both standbys' report, or of the one not further ahead,".
- N3-3, elsewhere in the text:
  - `00:405`'s row "Synchronous standby name … identifier" becomes "Synchronous standby names … two identifiers".
  - C2 becomes "synchronous streaming replication to two standbys (`STO-7`)".
  - In C4, C11 and C12, "the standby `STO-7` names", "the synchronous standby" and "the named standby" become "the
    standby `STO-54`'s report puts further ahead".
- N3-4, in the checklist:
  - In C9, "Stall the named standby" becomes "Stall both named standbys", and C9 gains, before "Then assert": "Then
    stall one only and assert an engine write and an `api` write each succeed."
  - C12 gains: "With one standby unreachable, assert the procedure promotes neither as a restart."

## Answer

- **CORE:** ACCEPT or CANNOT ACCEPT. It covers everything except the five spans and N3.
- **RS, DL, OC, WR, RL:** KEEP or DELETE each.
- **N3:** ACCEPT or CANNOT ACCEPT, as the text for three servers.
- **NREC:** recommend 2 or 3 servers to the owner, with one line of reason. With two, one server's failure stops
  writes until a replacement standby streams. With three, a single failure doesn't stop writes.
- A CANNOT ACCEPT or DELETE names the normative content lost or made wrong (quote the MUST/SHOULD with file:line),
  or a trace that breaks it, and gives replacement text for that span only. Wording preferences aren't counted.
- **Ripple:** name only the spans S''' contradicts and misses, quoted with file:line.
- **Facts** (not votes), one or two lines each, with a quote:
  - FE1: does any theorem in `tools/formal/` rely on a `committed false` commit surviving a restart or a
    promotion? Name it, or say none.
  - FE2: under DL, does anything in the set still put a deadline on, or kill, a component whose write waits on a
    stalled standby (a supervisor probe, a liveness rule, a bound)? Quote it, or say none.
- List wrong facts under "Brief errors", with the grep or quote that shows each one.

**Total: at most 450 words.**
