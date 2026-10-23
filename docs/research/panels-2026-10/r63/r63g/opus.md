My answer is below, 1,492 words. The same text is saved in `/var/tmp/provisiond-panel-r63g/opus.draft.md`. I wrote nothing in the repository (git status is clean) and started no database.

# r63g — opus

| Item | Vote | Quote or trace |
|---|---|---|
| NA | **PICK** as written (W1 is a Run point) | Precedent `03:1791`: "The settle write that records a stop after `execute` returns MUST NOT be cancelled or abandoned by that stop." NA generalises it. Under STOP-A ("`OPS-21`'s stop bounds still apply"), the bound's expiry is `03:1767-1768` "the worker MUST abandon the record, and the engine MUST log loudly … and exit", which is covered by NA's "short of its process exiting". STOP-B takes the standby wait out of that bound. |
| STOP-A | **PICK** | As in r63f: B "saves only the engine's connection slots". LOCK-A can still exit: "lock-contention exhaustion can still restart the engine" (C13). NA now bounds `api`. No money trace either way. |
| STOP-B | ACCEPTABLE | No MOVE: NA strengthens A's reason. |
| S3-B' | **PICK** | Closes the trace. The reinit kills every backend, the mint's included (H-a). A new connection's target is the primary's flush position, which is past D's record (redo `0/40085C8`, T `0/4008668`). No named standby is at T, so the re-send gets no connection. The check passed only once s1 returned holding `1\|D`. A missing grant fails closed. |
| S3-A | ACCEPTABLE | It closes the trace when configured, but it is unsafe at the default: "`restart_after_crash` … When set to on, which is the default". RS can't see a reinit (s3-analysis H4). A deployment that does nothing reopens the hole silently. |
| S3-AB | ACCEPTABLE | S3-A's cost for no closure that S3-B' lacks. |
| PT | **PICK** | H-e2: the old p reported `0/47B2898` on TL1 against s2's `0/4004658` on TL2, yet it lacks s1's TL2 barrier. "both hold a prefix of one WAL sequence" is false without the timeline term. |
| PA-2 | **PICK** | Draft `STO-54`: "`STO-56`'s record is committed into the promoted store before either component is started". **Trace:** a controller that promotes on lag rather than quorum takes the lagging standby (H-e) and writes no `STO-56` row. The components take the restart branch, which "*performs* destructive actions" (`05:1467-1468`): a deposit index is re-issued (`05:867`), and "a token revoked in Δ is live again" (`05:1470`). Under PA-1 a conforming deployment must automate all of step (1) and the `STO-56` row; under PA-2, only stock quorum behaviour (verify §7). |
| PA-1 | ACCEPTABLE | Consistent, but its safety rests on controller automation of `STO-54` step (1). |
| INV-ADR | **PICK** | Rationale only; F4 audits. |
| INV-STO | **NOT ACCEPTABLE** | Forms text: "or on a connection `STO-7` checked". Under S3-B' every component connection is checked, so it forbids nothing and is a second home for S3's rule ("One rule, one home"). Under S3-A it points at nothing. Its closed list also misses Q9's revocation replay. |

**PA, current text:** nothing says who starts a promotion, and nothing forbids an automatic restore. `STO-56` assigns only "closed by the operator" (`05:1320`). Step (1)'s "published to the operator" informs; it assigns nothing. `ADR-0023` is silent.

**7. Deleted safeguards.**
- **RS:** it gated "a component" only. S3-B' covers every component pool connection. The migrator's commits wait, so their acknowledgement certifies what they read. An operator's session was never covered. The `OPS-47` lock connection reads no rows, and a reinit kills it ("where the connection carrying it is lost it MUST exit"). Nothing is lost.
- **C7's cap:** it never bounded abandoned waiters. `05:143` licensed abandonment "by a timeout, a cancelled worker", and that freed the cap's slot. NA bounds strictly more. **Residual under S3-A:** a dead transport (a partition, or a NAT or LB reset). The backend stays in `SyncRep` unnoticed (H-c: 30 s with keepalives), and the pool replaces the connection. Under S3-B' the replacement can't pass the check while any commit waits.
- **`off`:** it existed to turn a reinit into a start that RS gates. S3-B' needs no start. Nothing is lost, and the full-outage cost goes.
- **The pooler allowance and `CNF-56`'s reassignment** protected role-level settings under transaction pooling. They're unneeded without one.

**8. Catching the wrong builds.**
- (a) C12's "Withhold the read … refuse every new connection" goes red: a write check doesn't need the read.
- (b) The same step goes red, but only if the withhold outlasts the check's timeout (W2).
- (c) C12's crash-in-place goes red only if the tested deployment has the pooler. Nothing catches one added later.
- (d) NA's C9 step goes red under S3-A. Under S3-B' it is masked: no replacement connection passes while a commit waits, so the broken build also shows backends ≤ pool and gets `overloaded`. Harmless there (W3).
- (e) Nothing catches it. C12's standbys are healthy, so `receive_lsn` ranks correctly by luck (W5).
- (f) PT's C12 sentence goes red.

**9. Counter-case.** Barrier-only uses PostgreSQL as it promises: only an acknowledged commit is durable (H-d2). It needs no grant, no pooler ban and no setting. It closes the fast-shutdown window, which neither S3 option does. The engine is covered already (`03:760`, "Step 9 MUST begin only after step 8's transaction is acknowledged"). **The miss:** every `API-11` re-send reads a receipt. **Trace:**
1. The owner revokes a stolen token. The revocation waits in `SyncRep`, and a reinit makes it visible.
2. The re-send gets `409` "credential_already_replaced" (`04:581-583`).
3. A restart-promotion loses the revocation. That breaks `04:560-561`, "A revocation invalidates the current token immediately".

The deposit list is also hand-kept: a later endpoint that shows a destination reopens `05:867`. A per-connection check covers the class.

**10. Scope.** F1: no. F2: availability only. F3: an emptied `synchronous_standby_names` silently voids everything (H-d edge). Its MUST exists; tell the owner it's undetected. F4: needed only if the owner wants Q-R. Droppable: INV-STO.

**11. Owner questions.**
- "no longer strands a database connection" is wrong. Replace with: "a web request that gives up mid-save keeps its database connection until the save finishes, so the service refuses new saves instead of exhausting the database."
- S3's TL;DR: add "One setup mistake still opens B's hole silently: a connection pooler in front. A's hole is open if the setting is left at PostgreSQL's default."
- B's cost: "While both copies are down, a restarting server process can't connect, even to read. After a switch, nothing serves until the other copy streams."
- A's cost: "A crash of one database process stops the whole database until restarted."
- The story: replace "At 11:00 the main server dies, and the copy we switch to never had it." with "At 11:00 the copies return, but the main server dies before either catches up."
- P: add "Switching automatically is safe only if the switching tool also runs our restore steps."
- P's "switch to copy 2 at once" overstates it (item 12). Add: "Switching still leaves saves down until another copy is rebuilt from copy 2."
- **Missing:** Q-R (verify.md:139 "Open → owner question Q-R"). Under either S3 option only the fast-shutdown window and a restore (PA-1) remain. Also add: "If the list of copies is emptied, copying silently stops, and nothing in our service notices (F3)."

**12. Brief errors.**
- verify.md:20 "the only bound there was" and forms-r63g:23 "the one existing bound" are misleading (item 7).
- NA's "never has more backends … than its pool holds" is false under S3-A with a dead transport.
- forms-r63g:111 "promote the other at once" overstates PA-1. The promoted store waits for a standby (forms-final `STO-7` "never serves with `synchronous_standby_names` empty"), so PA-1 gains only the time until a copy streams from it.
- Line numbers: "Two rules" is `05:140-145`, not 141-144 or 142-144.

## Fixes

- **W1** (no behaviour change). In NA, after "short of its process exiting,", add "even when the worker exits (`OPS-49`) or `OPS-21`'s bound expires". "so a live process never has" becomes "so, apart from a backend whose transport died, a live process never has". Draft E1 gains: "except a sent COMMIT, which no deadline releases".
- **W2** (test only). C12: "Withhold the read … for longer than the check's own timeout and assert…".
- **W3** (test only). In C9's NA step, use "Fill one replica's write checkouts with waiting writes, cancel every one…". It gains "and after release assert its writes run on the backends it held before the stall".
- **W5** (test only). C12 gains: "With one standby lagging and both restarted after the primary is lost, assert the procedure promotes the one holding the last acknowledged commit". It also gains, back from forms-final: "assert neither `API-45`'s re-send nor `GET /v1/deposits/{id}` returns the waiting deposit before a standby has it."
- **W6** (test only, if PA-2). C12's "promotes neither as a restart" gains "and none until an operator decides".

Final:
- NA: PICK
- STOP: A PICK, B ACCEPTABLE
- S3: B' PICK, A ACCEPTABLE, AB ACCEPTABLE
- PT: PICK
- PA: PA-2 PICK, PA-1 ACCEPTABLE
- INV: INV-ADR PICK, INV-STO NOT ACCEPTABLE
