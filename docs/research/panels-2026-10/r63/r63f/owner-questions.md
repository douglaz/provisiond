# Owner questions after r63f (pv-s4m, synchronous replication). 2026-10-23

Already settled:
- S1 is three servers, as you chose. It is merged into the final text.
- **Settled by the panel:** half of S2, the "locked row" part. All four readers accept it.
  - During a freeze, if an engine write keeps hitting a row that a frozen write has locked, the engine gives up after
    its retry limit and restarts, exactly as today. The freeze alarm is already ringing.
  - No money is at risk. Two readers wanted the engine to keep waiting instead, but no version of that rule held up:
    PostgreSQL's two time-outs and its permissions both defeated it.

Two questions are left.

## S2'. During a freeze, does a deploy's stop still finish on time?

**TL;DR:** If both copies are down and you deploy, either the engine stops on time and leaves its frozen writes
behind in the database (A), or the stop waits until a copy is back (B). Neither loses money. **The panel split
2-2, and all four said they'd accept either.**

Story:
- At 10:00 both database copies stop answering, and every write freezes.
- At 10:05 you deploy, which stops the engine.
  - **Under A,** the engine stops within its usual stop limit. Its frozen writes stay in the database, each holding
    a connection, and they finish by themselves when a copy returns.
  - **Under B,** the stop waits until a copy returns, say at 11:00. The deploy hangs that long.
- With three servers, this needs both copies down at once.

- **A, stop on time.**
  - Votes: opus (who moved from B) and astra.
  - Opus's reason: B only saves the engine's own connections. An `api` restart during a freeze leaves its frozen
    writes behind anyway, and the engine can already restart over a locked row.
  - Cost: in a long freeze, leftover writes can use up the database's connections.
  - Lands on:
    - `STO-7` `05:141-143`;
    - `OPS-49` `03:1830`;
    - `CNF-296`;
    - `ADR-0045`.
  - `OPS-21` is unchanged.
- **B, wait for the copy.**
  - Votes: fable and sol (who moved from A).
  - Reason: no leftover writes from a stop.
  - Costs:
    - a deploy can hang for the whole outage;
    - the supervisor must be told to wait. Under systemd the engine can extend its own stop time.
  - Lands on:
    - `STO-7` `05:143`;
    - `OPS-49` `03:1830`;
    - `OPS-21` `03:1763-1773` and its row `00:402`;
    - the quotes of `OPS-21` in `ADR-0044`, `10:1602` and `StopRecord.lean`;
    - `CNF-296`;
    - `ADR-0045`.

## S3. Turn off PostgreSQL's self-restart after a crash?

**TL;DR:** The hole is real. When one database process crashes, PostgreSQL silently restarts itself, and our
"wait until a copy catches up" rule never fires. **The panel picks turning the self-restart off, 4-0.** The cost is
a short full outage on each crash.

Story:
- At 10:00 both copies are unreachable, and a deposit is saved on the main server, waiting for a copy.
- At 10:01 a memory cap kills one database process. PostgreSQL restarts all its processes within seconds, without
  ever stopping, and the deposit becomes visible.
- The customer asks again, gets that deposit's address, and pays it.
- At 11:00 the main server dies, and we switch to a copy that never got the deposit. Later the same address goes to
  someone else.
- With healthy copies the window is milliseconds. When both copies are unreachable, it's the whole outage.

The analysis, in plain terms:
- From outside, the self-restart doesn't look like a restart at all. Even the server's recorded start time stays
  the same. So nothing we run can notice it and apply the catch-up rule.
- Patroni doesn't fix this either. It neither sets nor recommends the setting, and its own docs describe this leak.
- The full write-up is /var/tmp/provisiond-panel-r63f/s3-analysis.md.

- **A, turn the self-restart off (recommended, 4-0).**
  - A crash then stops the server, and the restart goes through the catch-up rule.
  - Cost: each process crash is a full database outage until the server is restarted and a copy has caught up.
    Writes would wait for the copy anyway, so the extra outage falls mostly on reads.
  - Lands on:
    - `STO-7` (one sentence before the catch-up rule);
    - `CNF-365` (crash a single process);
    - `ADR-0045`.
  - Opus also suggests adding ", and the deployment restarts it". Only opus has read that clause. It needs one
    short reading round if you want it.
- **B, check each connection instead.** Before the engine or `api` uses a new connection, it waits until a copy
  has caught up. All four readers accept it.
  - Cost:
    - a check in both components;
    - a monitoring permission;
    - a rule for the optional connection pooler.
  - Lands on:
    - `STO-7` (it replaces the catch-up rule's sentence);
    - `STO-55` `05:195`;
    - `CNF-365`;
    - `ADR-0045`.
- **Both A and B.** All four readers accept it. It carries both costs.
- **Leave it out, or rely on Patroni.** All four reject this, 4-0: a deposit shown to a customer can be lost and
  its address re-issued.
