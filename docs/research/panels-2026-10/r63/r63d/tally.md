# r63d tally: panel C, form S'' under synchronous replication (pv-s4m). 2026-10-23

All four exited 0 (fable.md 3488, opus.md 2691, astra.md 3243, sol.md 3310 bytes). Rules: notes.md, fixed before launch.

| Item | fable | opus | astra | sol | Result |
|---|---|---|---|---|---|
| CORE | ACCEPT | CANNOT | CANNOT | CANNOT | **1-3, falls short** (rule 2): r63e reads the merge |
| E1 | KEEP | KEEP | KEEP | KEEP | **KEEP 4-0** |
| E2 | KEEP | KEEP (its shutdown carve-out "safe only with" the restart gate) | KEEP | KEEP | **KEEP 4-0** |
| E3 | DELETE (recorded; names no content lost or made wrong, so it doesn't count, rule 1) | KEEP | KEEP | KEEP | **KEEP 3-1** |
| RF | R | R | R | R | **R 4-0**: the panel's pick (rule 4). Not an owner question |
| F' | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | **UNCHANGED 4-0** |

## CORE's objection (opus, astra, sol; converging; verified)

The trace: a write waits in `SyncRep` on a partitioned standby. The primary crashes or shuts down and restarts in place.
26.2.8.4: "those waiting transactions will be marked fully committed once the primary database recovers". A reader
or an idempotent replay now sees the row. A read never waits: xact.c:1608 waits only `if (wrote_xlog &&
markXidCommitted)`. Before recovery the waiter was invisible: xact.c:1605-1606 says "at this stage we have marked
clog, but still show as running in the procarray and continue to hold locks". The primary is then lost, and CORE-2
promotes the standby as a restart, which loses the row. Content broken: `05:867` "Allocated strictly increasing and
never re-issued" (opus), `04:829-830` `API-45` "MUST return the **same** deposit" (astra), and `04:209-210` `API-7`
5a "returns the stored result" (sol).

The three replacement texts converge on a gate: no component connects to a restarted primary until the standby
has flushed through the WAL the primary started with. The merge takes opus's scope, "any start". The other two cover
crash recovery only, but 26.2.8.1 says waiters are also released by a fast shutdown, and that is E2's carve-out.
This becomes span RS in r63e.

Sol's second objection is a lone dissent, checked and verified. CORE-2's "comes up on it under `STO-5`'s restart
rule" contradicts `05:1522`: "a process that starts while a restore record is open is continuing that incident, not
restarting". A promotion during an open restore has the record replicated. This becomes span OC in r63e.

## Brief error (opus, astra, sol; verified)

The brief said "Under strict settings, only a cancel or terminate reaches that state". A primary restart also
reaches it (26.2.8.4, above).

**Ruling under r63 rule 6:** the error is about whether CORE plus E1-E3 is complete, and that is CORE's question,
which r63e re-asks corrected. It doesn't change whether each E clause closes its own route. The three readers who
found the error voted KEEP on E1 and E2 with it in view. E1-E3, RF and F' stand. r63e's brief carries the corrected
Why. If RS fails in r63e, E2's carve-out goes to the owner with it.

## E3's lone dissent (fable), checked: harmless, not a gap

E3 is inert. Under E1, E2 and FA1, nothing produces the warning commit. A terminate sets
`whereToSendOutput = DestNone`, so no warning reaches the client. A lost reply's repeat reads the row and "has seen
its earlier attempt land, and moves on" (`03:1834-1835`), which is what an acknowledgement does. Opus also calls E3
"not load-bearing (FA1)". It stays under rule 3, and is recorded as harmless.

## Facts (not votes; each verified by the manager against the source, 2026-10-23)

- **FA1, no (4-0).** `statement_timeout` is off before the commit on the extended protocol as well.
  `exec_execute_message` calls `finish_xact_command()` for a transaction-control statement, and otherwise calls
  `disable_statement_timeout()` after Execute (postgres.c:2335-2371). `PqMsg_Sync` calls `finish_xact_command()`,
  whose first statement is `disable_statement_timeout();` (postgres.c:2913-2920). `transaction_timeout` is
  disabled before `RecordTransactionCommit()` (xact.c:2414, :2422). So no mandatory timeout cancels the wait, and
  E3 isn't load-bearing.
- **FA2, no (4-0).** The loop tests `syncRepState`, `ProcDiePending` and `QueryCancelPending`, and waits on
  `WaitLatch(MyLatch, WL_LATCH_SET | WL_POSTMASTER_DEATH, -1, ...)` (syncrep.c:341) with interrupts held
  (`Assert(InterruptHoldoffCount > 0)`, syncrep.c:158). There's no `CHECK_FOR_INTERRUPTS` anywhere in syncrep.c.
  A backend whose client has gone keeps waiting, and keeps its locks and its connection slot.
- **FC1 (4 agree in substance).** Under `ANY 1 (s1, s2)`, the standby with the greater flushed WAL position holds
  every acknowledged commit, but only when both report. Patroni: "we need to compare its LSN with the LSN on at
  least one node ... among node2 and node3". `pg_last_wal_receive_lsn()` gives "received and synced to disk", and
  returns NULL before streaming starts. CORE-2 would need that comparison, a set in `OVR-19` and fencing first.
- **FC2, confirmed (4-0).** Patroni strict mode is "blocking all client write requests until at least one
  synchronous replica comes up".

## Ripple (each span verified by quote)

- `05:189-193` "together fit inside `max_connections`" and C9's "a read still succeeds" (fable, opus). By FA2 and
  E1, every write whose client deadline expires during the wait leaves a backend outside every pool, still holding
  its locks. `ADR-0023:158-170` already names the crash loop that follows: "the retry re-commits and re-stalls
  until the bound exhausts, the engine exits, and the successor's startup pass ... stalls the same way". The fix
  needs new words, so it goes to r63e as span DL. Fable's text is the base. "Keepalives" in it means the client's
  side: a server-side waiter never sees them (FA2).
- `03:1841` ("the only lost reply is a dead transport"), `Types.lean:23` (quotes it) and
  `ADR-0022:23/:63` (astra, sol). r63d's C1 would contradict all three. Under DL they stay true, so DL replaces C1.
- `CONTEXT.md:185` "a restart loses no committed work" (opus): a promotion loses waiting commits. Goes to r63e
  as C14.
- `README.md:94`, the `0023` index row (opus, astra), plus the missing `0045` row (fable). Folded into C13 in r63e.
- `10:1079`, `CNF-299`'s title "the pool keeps serving under a stalled standby" (astra). The fix is
  deletion-only. It's folded into C10 so r63e reads it.
- C12/`CNF-365` and CORE-2 (fable, using FC2). After a promotion every write waits until a standby streams, and
  `OVR-19`'s standby name is startup-validated (`00:405`). Goes to r63e as span WR.
- Manager additions (not from a reader):
  - R's list must also cover a breach of RS. Goes to r63e as span RL.
  - `Claim.lean:318`'s docstring "the durable commit whose reply died in transport, so the store moved" needs
    checking. Goes to r63e as C15, with fact FE1.

## Next

r63e (/var/tmp/provisiond-panel-r63e/) reads S''': CORE with the new spans, a three-server variant N3, and a 2-or-3
recommendation. The FA/FC answers were facts, not votes, so the 2-or-3 owner question has no tally until r63e.
