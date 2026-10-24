# Reader in seat Option 1 (opus), panel r66d: vote for Option 1, CANNOT ACCEPT until two one-clause fixes are made

I ran no gate, used no `lake` and committed nothing. This answer is also saved untracked in the clone as `answer-r66d-opus.md`.

## 1. Objection

r66c's objection: "after **any** PostgreSQL restart, R's stop records are refused and `OPS-15` classifies the rows, so pv-buc's create-settle example ends `needs_reconciliation`".

**I concede the core.** Until `STO-56`'s record commits, two servers look the same to the engine: one that was stopped and started, and one restored from a backup taken after E's startup pass. Both hold the same row. So a stop record that reaches a server after a full stop and start is refused. The create, whose `about_to_order_at` is set, goes to `needs_reconciliation` under `OPS-15`. Option 1's own (b) says so.

The objection covers less than it says, and the loss has a limit:

- **R's own drill still passes.** `CNF-366`'s fixture is "Terminate the lock connection's backend". The postmaster stays up, so `pg_postmaster_start_time()` does not change, and (ii)'s "the create `succeeded` with its money posted once" holds under Option 1. The same holds when the lock connection is lost to:
  - a network drop,
  - a pooler restart,
  - an operator killing the backend,
  - an OOM kill of one backend.
- **A crash-restart reinit keeps the start instant.** This comes from an earlier round reading the PostgreSQL source, not from postgresql.org. `docs/research/panels-2026-10/r63/r63f/s3-analysis.md`:53-57 (H4) says `PgStartTime` "is assigned only in `PostmasterMain` … The reinit path doesn't touch it." So "any restart" really means a full stop and start of the postmaster.
- **What is lost is what `d78085a` already does.** Master's `OPS-47` says "where the connection carrying it is lost it MUST exit". That is pv-buc's Engine A, which ends in `needs_reconciliation` through `OPS-15`. On a full stop and start, Option 1 gives back R's gain and does no worse than master. It fails toward `OPS-27`, which "establishes what happened rather than doing it again", never toward a stale write.
- **Admitting R's record after a full restart means admitting it after a physical restore.** That is the owner's misconfiguration case. None of the alternatives avoids this:
  - Option 3 refuses after a restart too ("An ordinary PostgreSQL restart also destroys the witness").
  - Option 2 can tell a restart from a restore only when the survivor acknowledged a write after the backup.
  - PostgreSQL's only restore-specific signal is the timeline: "Whenever an archive recovery completes, a new timeline is created" (postgresql.org 18, 25.3.6). r63 rejected reading it 4-0: "the timeline read lags a fast promotion" (`r63b/tally.md`:25).
- **Promotion loses nothing.** `STO-54` already says "Before any component connects to the promoted store, the deployment MUST stop every engine and `api` process that was connected to the old primary". Option 1 enforces that rule instead of trusting it.

The objection's second half is Option 1's (d): a restore that starts no server, before the record commits. Every option has a gap there:
- Option 3 misses "a logical overwrite of the same database while that session and its advisory locks survive".
- Option 2 misses idle survivors.
- Option 4 has no check in the application at all.

So the scoped deployment rule is a floor every option shares. Option 1 limits it to the one shape that no value the server reports can detect.

## 2. Vote

I vote for **Option 1, as written, S2 included.**

- It is the only option that passes the misconfiguration test by refusing the survivor in every shape that starts a server, `api` included.
- It adds no state: one more value in a statement G already runs.
- S2 closes the `api` hole for shapes 1 and 2. This seat's r63 objection was that "`api` is where the hole is" (`r63b/tally.md`:28).

## 3. CANNOT ACCEPT: two defects, each fixed by one clause

With both replacements below applied, I ACCEPT.

**Defect A: `CNF-367` fails for a conforming engine.**
- `OPS-50` (b) now says: "the engine MUST log loudly which of the two differed and exit non-zero at once".
- The Appendix's `CNF-367`, which Option 1 leaves unchanged, asserts: "the engine logs "superseded" and exits non-zero".
- An engine that logs "generation differed" conforms to the new `OPS-50` and fails `CNF-367`.
- The word "superseded" also names this exit in F1 ("superseded (`OPS-50`) exits"), in span 20 ("an engine's superseded exit") and in `StopRecord.lean`'s `| superseded`.
- **Gate:** a `CNF-367` assertion becomes false for a conforming implementation.
- **Replacement** for (b)'s first After: "the engine MUST log loudly that it was superseded, naming which of the two differed, and exit non-zero at once". Option 1's `CNF-370` ("it logs which value differed") then holds.

**Defect B: `CNF-366`'s headline assertion can become unreachable.**
- `CNF-366` says: "Keep the startup generation unchanged throughout these cases; no successor or out-of-band writer advances it."
- It also has "the store refuses its transactions until lock-loss detection" without saying how the harness stages that.
- **Trace:** a harness stages the refusal by stopping and starting the server. Option 1 then refuses (ii)'s settle write, so "the create `succeeded` with its money posted once" cannot be reached.
- **Gate:** a `CNF-366` assertion becomes unreachable under a fixture the item permits.
- **Replacement:** "Keep the startup generation and the server's start instant (`OPS-50`) unchanged throughout these cases; no successor or out-of-band writer advances the generation, and no case stops and starts the server."

**Non-blocking notes:**
- `CNF-365`'s in-place restart does not flip: `STO-7`'s connection check still runs first. But every engine, and with S2 every `api` process, now exits at its first write after such a restart. `ADR-0047`'s restart-cost item should name both components and `OVR-18`'s alarm.
- In `CNF-370` (iv), "refuse the engine's store connections" should be read as also cutting the connections already open.

## Brief errors

1. **The Against quote is too broad.** It says "after **any** PostgreSQL restart". The brief's own verified fact says "full PostgreSQL stop and start", which is correct, because a crash-restart reinit keeps `PgStartTime` (r63f `s3-analysis.md`:53-57).
2. **"Only if the start time survives a reinit" is already answered in the repo.** The source reading at r63f `s3-analysis.md`:57 says "The reinit path doesn't touch it."
3. **The inference about Option 3's witness was not left unchecked.** r63f H2 (`s3-analysis.md`:45) records "all server processes terminated; reinitializing", so every session ends on a reinit, the witness's included.
4. **Option 3's `OVR-19` Before text will not match.** It drops the backticks around `OPS-47` that `00-overview.md`:400 has, so `grep -F` fails to find it.

Everything else I checked matched:
- `d78085a` lines: 05:89-90, 03:950-951 (inside `OPS-41`), 05:1507-1508, 05:1340, 05:1542, 03:1741-1742, 03:1807, 10:1682, ADR-0019:80-81, ADR-0025:64-67 and :118-119, README:304-306, CONTEXT:108 and :524, 00-overview:316 and :399, 02:142.
- Research: `r63b/tally.md`:25-26.
- Every postgresql.org 18 quote the brief uses.
