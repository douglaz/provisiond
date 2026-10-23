# Owner questions after panel C r63e (pv-s4m, synchronous replication). 2026-10-23

Already decided: synchronous replication (your words: "I think we should just suppose synchronous replication"),
plus r63c's Q2 = A and Q3 = A. These new questions are labelled **S1-S3** so they don't collide with those.
Everything else in the form passed the panel; the full text is in forms-final.md there.

## S1. Two database servers or three?

**TL;DR:** With two servers, if either one dies, no write goes through until a replacement copy is built. That
means no payments and no extensions, and the engine can't cancel unpaid machines or suspend a tenant while they
keep billing. With three, one failure doesn't stop writes. **Panel: three, 4-0.**

Story: every write is now saved on the main database server and on a copy before we say "done". With two servers,
the copy is the only one. If it dies at 10:00, the main server can't confirm any write until someone builds a new
copy, say at 14:00. For those four hours nobody can pay, and an unpaid machine due to be cancelled at 11:00 keeps
running and billing. With a third server, the other copy keeps confirming, and only two failures at once stop
writes. Opus's reason: `STO-6` (`05:104-107`) accepts "the supervisor's restart window" as the outage of the
mechanisms that stop billing, and two servers turn any single failure into a longer one.

- **B, three servers (recommended, 4-0; text reviewed 4-0).** The cost is one more database server to run and pay
  for. Lands on:
  - `STO-7` (`ANY 1` over two standbys);
  - `STO-54` (promote the copy that's further ahead);
  - the `OVR-19` row `00:405` (two names);
  - `CNF-296`, the new `CNF-365`, and the new `ADR-0045`.
- **A, two servers.** Same ids, with the single-standby text. A single failure stops writes until a replacement
  copy streams.

## S2. While writes are frozen, may the engine still quit?

**TL;DR:** When the copy is stuck, writes wait. A: the engine still stops or gives up on time, but each quit leaves
frozen sessions holding database connections. B: it waits the freeze out, so deploys and restarts hang. On stopping,
the panel split 2-2; on giving up over a locked row, 2-1 for A. No money risk was found, and with three servers
this needs both copies down.

Story: the copy stops answering at 10:00, and every write waits. At 10:05 something makes the engine quit. Either a
deploy stops it, or one of its writes keeps hitting a row that a frozen write has locked and gives up after its
retry limit.

- Under A the engine quits on time and comes back. The frozen write it left behind stays in the database, holding a
  connection, until the copy returns. Enough of those and the database runs out of connections, so reads fail too.
- Under B the engine doesn't quit, and the deploy waits until the copy is back.
- Either way, everything frozen finishes once when the copy returns.

- **A, stay stoppable.**
  - Tally: stopping, astra and sol. Locked rows, astra and sol: this is the panel's fix under rule 2, read only by
    its proposers.
  - Stops and retry limits keep their time bounds.
  - Lands on: `STO-7`, `OPS-49` `03:1830`, a new `OVR-19` keepalive row, `CNF-296`, `ADR-0045`.
  - Known limit: `05:191`'s connection budget doesn't hold in a long freeze.
- **B, wait it out.**
  - Tally: stopping, fable and opus. Locked rows, opus alone; fable didn't address it.
  - A stop, and the supervisor's kill, wait for the copy. Lock time-outs during a freeze don't count toward the
    retry limit.
  - Costs:
    - A stock supervisor (systemd, Kubernetes) kills on a fixed timeout and can't see the wait, so the deployment
      needs its own stop logic.
    - `03:1738`'s stop clock, which "never resets", needs a Run fix saying it pauses during the wait.
  - Lands on: `STO-7`, `OPS-21` `03:1738-1772` with its row `00:402`, `OPS-49` `03:1830` and `:1847`, a new
    `OVR-19` keepalive row, `CNF-296`, `ADR-0045`.
- Nobody backed the original form, in which a write's own time-out still applies to the wait.

## S3. Turn off PostgreSQL's self-restart after a crash?

**TL;DR:** When one database process crashes, PostgreSQL restarts itself silently. Our rule "don't serve after a
restart until the copy has caught up" never sees that restart. So a customer can be shown a deposit that's later
lost, and its address can go to someone else. The fix is to turn the self-restart off. It's one reader's text,
checked against PostgreSQL's docs.

Story: at 10:00 a deposit is being saved while the copy is unreachable, so the main server holds it, waiting. At
10:01 one database process is killed, for example by a memory cap like ours on 2026-10-21. PostgreSQL restarts
itself within seconds, and the deposit becomes visible. The customer asks again, gets that deposit's address and
pays it. At 11:00 the main server dies for good and we switch to the copy, which never got the deposit. Later the
same address is handed to another customer. With `restart_after_crash` off, the crash stops the server instead,
and the deployment restarts it under the catch-up rule. PostgreSQL's docs name this use: "when PostgreSQL is being
invoked by clusterware". The cost is that a crashed process keeps the database down until the deployment restarts
it.

- **A, add the setting now** (recommended by opus, who found it; the manager verified it against the docs). It adds
  "The deployment turns `restart_after_crash` off, so a backend crash stops the primary." to `STO-7`'s catch-up
  rule, recorded in `ADR-0045`.
  - The catch-up rule itself was kept 3-1. The other three readers didn't vote on this sentence.
  - Run review point: `CNF-365` should also crash a single database process.
- **B, one more reading round on that sentence before the Run.**
- Leaving it out keeps the hole open.
