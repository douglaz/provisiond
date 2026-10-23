References: `03` = `03-operation-lifecycle.md`; `05` = `05-persistence.md`; `forms` = r63e’s `forms-final.md`.

**S2 STOP — PICK A.** `03:1738`: “the engine MUST NOT wait for it past that bound.” A preserves this operational guarantee. I accept its cost: stopping leaves PostgreSQL backends holding locks and slots.

**OTHER: B ACCEPTABLE.** An indefinitely delayed stop is a defensible availability choice; I found no money-loss trace that makes it inherently unacceptable.

**MOVE:** Evidence that a bounded engine stop loses money despite compliance with CORE, RS and RL would move me to B.

**S2 LOCK — PICK A.** `03:1829` requires “the engine MUST exit non-zero”; `03:1847` says “A `lock_timeout` is a store error”. A accurately retains that behavior.

**OTHER: B NOT ACCEPTABLE as written.** A migrator commits DDL and waits in `SyncRep`, holding `ACCESS EXCLUSIVE`. An engine statement behind it repeatedly reaches `statement_timeout` first. B exempts only `lock_timeout`; `03:1826` still requires the component to “repeat the **whole transaction**”, and exhaustion mandates exit. C9’s no-exit assertion fails. FL3 additionally prevents reliably detecting another role’s waiter without privileges.

Replacement for B’s exemption:

> Time spent blocked, or retrying following `lock_timeout` or `statement_timeout`, because a blocking chain ends at a primary backend waiting in `SyncRep` does not consume the Store-retry bound. The deployment MUST provide visibility sufficient to identify that condition across engine, `api` and migrator roles. Other failures retain ordinary accounting. `OVR-18` alarms this exempted loop.

**MOVE:** That causal exemption, demonstrated against migrator locks, both timeout types and separate roles, would make B acceptable.

**P, under my picks:**

| Protection | STOP-A | LOCK-A |
|---|---|---|
| P1 | KEPT: engine exit does not cancel PostgreSQL’s transaction | KEPT |
| P2 | MOVED for direct standby waits to `OVR-18`; retained for errors | Same; contention retains bounded exit |
| P3 | KEPT | KEPT |
| P4 | LOST: contention can still produce the crash loop | LOST; its alarm remains |

**S3 — PICK S3-A.** It closes §1: backend crash → postmaster exit → ordinary restart → RS catch-up gate before access. `src/postmaster.c:3188` explicitly logs “shutting down because \"restart_after_crash\" is off”. I accept supervisor restart delay and blocked reads during catch-up.

**OTHER:**

- **S3-B ACCEPTABLE:** the connection check, including its pooler clause, blocks access to recovered commits until replication.
- **S3-AB ACCEPTABLE:** RS plus `off` closes the trace even when a pooler hides backend replacement.
- **S3-P NOT ACCEPTABLE:** default PostgreSQL reinitialization bypasses the external restart gate; Patroni supplies no equivalent connection barrier.
- **S3-N NOT ACCEPTABLE:** recovered mint → address returned → primary lost → address reissued violates `05:867`, “Allocated strictly increasing and never re-issued”.

**Ripple:**

- A’s orphaned backends escape `05:189–192`’s sizing account: “an operator reserve together fit inside `max_connections`”. Qualify that account and explicitly record possible exhaustion.
- STOP-B additionally needs synchronized clock descriptions in `tools/formal/Provisiond/StopRecord.lean:4–7` and `10-conformance-checklist.md:1602`: “measured from the stop, counts every repeat including serialization failures, and never resets”. Distinguish charged time from elapsed time.

**Brief errors:** C6’s merged “a stalled synchronous standby, on which every write waits” (`forms:72`) contradicts `forms:20`: “while both are, every write waits”. Replace C6 with “and either named standby being unavailable (`STO-7`)”. The N3/OC merge preserves the restore-record exception. No material error found in H1–H4 or §3’s S3 conclusion.