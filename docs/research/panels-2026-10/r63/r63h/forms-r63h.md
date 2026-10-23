# Forms r63h (pv-s4m, panel C): what r63g left open. 2026-10-23

Base: /var/tmp/provisiond-panel-r63e/forms-final.md ("forms-final"), amended by
/var/tmp/provisiond-panel-r63g/forms-r63g.md ("forms-r63g") as r63g settled it, with the errata below. Line numbers are
at `dc5d40d`. The harness is /var/tmp/provisiond-pgharness/results.md (H-a … H-f). r63g's tally is
/var/tmp/provisiond-panel-r63g/tally.md.

## Settled in r63g, not re-voted here

- STOP: A, 3-1, acceptable to all four. Goes to the owner, A recommended.
- S3: B′, 4-0. Goes to the owner, B′ recommended.
- PA: PA-2, 4-0. Goes to the owner, PA-2 recommended.
- PT: carried 4-0.
- INV-STO: deleted, 0-4.

## Errata: lines in r63g's files that are void (verified by quote in r63g's tally)

- **E1.** forms-r63g:125 "Every engine provider mutation already follows an acknowledged commit made after its
  authorizing reads" and verify:143/147 "every provider-facing step is behind a guarded write" are false. `OPS-32`,
  `03:1630-1635`, deletes imported images and temporary keys from reads: "so it is **deleted** rather than reported".
- **E2.** "sub-millisecond" (forms-r63g:132, verify:128) was never measured, and the source doesn't bound it. The
  window's length is unmeasured.
- **E3.** NA's "so a live process never has more backends waiting for a standby than its pool holds" (forms-r63g:14),
  "bounded per live process" (forms-r63g:33-34) and the r63g owner draft's "no longer strands a database connection"
  are false with a dead database transport. `18-syncrep.c:331` waits on `WL_LATCH_SET | WL_POSTMASTER_DEATH`, with no
  socket event, and H-c measured a backend still in `SyncRep` after 30 s, with `client_connection_check_interval=1s` and
  1 s keepalives.
- **E4.** verify:94 "Adding `SET LOCAL` would collide with C8" is wrong: it is compatible but redundant.
- **E5.** forms-r63g:111 "a controller may promote the other at once" overstates PA-1. Forms-final says "the primary
  never serves with `synchronous_standby_names` empty". The restore procedure takes the public listener down
  (`05:1485`) and bumps "every tenant's credential generation" (`05:1516`).
- **E6.** verify:114 "The flush position always terminates" needs "given eventual standby progress".

## 1. NA′: the narrowed sent-COMMIT rule (spec-internal)

**NA′'s text.** It goes where NA went: `STO-7`'s "Two rules about the connection" (`05:140-145`), after "…or the next
checkout inherits an aborted transaction.":

> "**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, neither a
> deadline nor the cancellation of the request or worker that sent it releases its connection before the reply
> arrives or the transport is found dead. Cancellation alone does not release that write checkout. Dead database
> transports and process exits can leave waiting backends outside the pool's accounting. A request that finds the
> write checkouts taken is refused at checkout (`STO-55`)."

- **What changed from NA.** NA's "so a live process never has more backends waiting for a standby than its pool
  holds (`STO-55`), and" is removed. Astra's two sentences take its place, verbatim: "Cancellation alone does not
  release that write checkout. Dead database transports and process exits can leave waiting backends outside the
  pool's accounting." The manager re-split the last clause into its own sentence. Nothing else changed.
- **C9** (`CNF-296`) keeps NA's assertion, unchanged: "Cancel every `api` request whose write waits, its client
  disconnecting, and assert the primary never holds more of that replica's backends than its pool, a further write
  request is refused `overloaded`, and a read still succeeds."
- **The term.** `05:184` says "Read and write checkouts are budgeted separately".

**NA-sol, the alternative.** This is sol's behaviour change, verbatim. It is NA′ plus:

> "A dead transport does not replenish the write-checkout budget while its server transaction may still be
> waiting. Until that backend is known to have finished, its budget remains charged, or the component process
> exits."

C9 also gains sol's: "Repeat transport failures while the replica remains alive; assert unresolved backend waits plus
active write checkouts never exceed its write budget."

**The claim that B′ makes NA-sol unnecessary** (opus, r63g items 7 and 8d). This is the manager's check of it, from
source. Verify it or refute it with a trace.

- A commit is flushed locally before it waits. `18-xact.c:1563-1567`: "Note that at this stage we have marked clog,
  but still show as running in the procarray", then `SyncRepWaitForLSN(XactLastRecEnd, true)`.
- A waiter is released when a standby's position reaches its LSN: `18-syncrep.c:210/216`, `lsn <= WalSndCtl->lsn[mode]`.
- B′'s check: a new connection is unused "until one of the standbys `OVR-19` names has flushed the primary's WAL up to
  the flush position the primary reports on that connection".
- So under B′, a replacement for a dead transport passes only once a standby has flushed past every commit flushed
  before the check sampled its target, and that releases every such waiter. No new waiter can pile up behind a
  frozen standby.
- **Open: an in-flight COMMIT.** The transport dies, the replacement samples its target, and only then does the
  server process the orphaned COMMIT. Is the excess bounded, and by what?
- Under S3-A, new connections aren't checked, so the replacement serves at once and the pile-up H-c measured
  returns. NA-sol, or a stated cost, would travel with option A.

**Carried from r63g as Run review points (one reader's text, not voted).** Flag them only if they're wrong or conflict
with NA′.

- Opus W1: after "short of its process exiting,", add "even when the worker exits (`OPS-49`) or `OPS-21`'s bound
  expires". Draft E1 gains "except a sent COMMIT, which no deadline releases".
- Fable: "neither a deadline nor the cancellation … releases its connection" → "… MAY release its connection".

## 2. INV-ADR′: the design objective (spec-internal; rationale only, no normative text)

**Text.** Astra's, verbatim. It goes in C13's `ADR-0045` as rationale:

> "Design objective: irreversible external consequences must not depend on history a promotion classified as a
> restart may discard. A restore can still lose acknowledged history."

**What it narrows.** r63g's INV-ADR read "No irreversible external consequence may depend on database history that an
allowed failover could discard". "An allowed failover" includes restores. Forms-final's `STO-54` says "Any other
promotion — … — is a restore", and the restore procedure states a lost window (`05:1485-1486`: "the lost window `T − Δ` is stated as a number"). So the r63g form was
false as stated.

**The case, corrected for E1 and E2.** It claims no completeness.

- The writes are acknowledged. The deposit mint and the credit are writes, and under forms-final's `STO-7` "PostgreSQL
  acknowledges a commit only once one of them has flushed it".
- The audited provider mutations are behind an acknowledged commit:
  - `OPS-43`, `03:760`: "Step 9 MUST begin only after step 8's transaction is acknowledged";
  - `OPS-45`, `03:1422`: "The engine MUST persist a write-started marker on the operation".
- **Known counterexample:** `OPS-32`'s sweep acts on reads (`03:1630-1635`). It is listed for F4.
- The deposit re-send (`API-45`, `04:829-831`: "re-sending one MUST return the **same** deposit") is covered by the S3
  fix, except in the fast-shutdown window (item 3).
- Forms-final's `STO-54` stop rule keeps a process from spanning two histories: "Before any component connects to the
  promoted store, the deployment MUST stop every engine and `api` process that was connected to the old primary".

## 3. FSW: the fast-shutdown window (owner question; panel pick first)

**Trace.** "Measured" means the harness showed it; "source" means it was read in PostgreSQL 18's code and not
reproduced.

1. Both standbys are down (a freeze), and a deposit mint's COMMIT waits in `SyncRep`.
2. The primary gets a fast shutdown. Forms-final's `STO-7` allows this: "The deployment MUST NOT cancel or terminate a
   primary backend while it waits for the standby (wait event `SyncRep`), other than by shutting the primary down."
3. The fast-shutdown path sends SIGTERM to backends: `postmaster.c:2993`, `SignalChildren(SIGTERM, targetMask)`. It
   signals them one at a time: `postmaster.c:3482`, `dlist_foreach(iter, &ActiveChildList)` … `signal_child(bp,
   signal)`. (source)
4. The waiter stops waiting, and its commit becomes visible before it exits.
   - `18-syncrep.c:297-308`: "We do NOT reset ProcDiePending, so that the process will die after the commit is
     cleaned up."
   - `warm-standby.txt:169`: "Users will stop waiting if a fast shutdown is requested."
   - H-b measured the same SIGTERM sent by `pg_terminate_backend`: "canceling the wait for synchronous replication and
     terminating connection due to administrator command", then `3|T` visible, still during the freeze. (measured)
5. A backend on an already-checked connection, not yet signalled, reads the deposit and returns it. An example is the
   customer's `API-45` re-send on another replica, which was blocked on the mint's key and is now unblocked. (source;
   the window's length is unmeasured)
6. The primary's storage is lost before a standby has the commit, and a standby is promoted without it. If that
   promotion is classed a restart, `05:867`'s "never re-issued" fails: the next mint takes the same derivation index,
   and so the same address.

Under either S3 option, no new-connection check runs in this trace.

**The text this turns on.** Forms-final's draft `STO-54`, quoted in full on this point: "Any other promotion — without
both standbys' report, or of the one not further ahead, of a standby `STO-7` does not name, or after the primary
committed without it, served a component before it had caught up, or had a waiting backend cancelled or terminated
(`STO-7`) — is a restore".

**(i) Reading question, from r63g.** Does "had a waiting backend cancelled or terminated (`STO-7`)" already make step
6's promotion a restore, given that `STO-7` allows the termination step 2 causes? If it does, can the party starting
the promotion know it once the primary is lost, using text that already exists? That is the controller, or under PA-2
an operator. If it can't, what exactly would it need?

**(ii) The two forms.**

- **FSW-L: accept the window for v1.** `ADR-0045` gains this, and F4 owns the window. It has no normative text.

  > "**Accepted for v1: the fast-shutdown window.** A fast shutdown of the primary ends every wait for a standby
  > ("Users will stop waiting if a fast shutdown is requested"), and a commit that was waiting becomes visible before
  > its backend exits. The postmaster signals backends one at a time, so a backend on an already-checked connection
  > that has not yet been signalled can read such a commit and return it. If the primary is then lost before a standby
  > has the commit, the promotion that follows can discard it. This is source analysis: it was not reproduced, and the
  > window's length is unmeasured. The follow-up audit of external actions owns it."

- **FSW-N: close it now.** Sol's text, verbatim. It lands as a sentence of `STO-7`, after S3-B′'s new-connection
  check, and `ADR-0045` records why.

  > "Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a
  > target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the
  > result and repeat the whole read."

  - **Its cost.** Every response that exposes a deposit destination waits for a standby. During a freeze, that wait
    can't pass: with both standbys down, the check "cannot see a standby's position" (S3-B′), so the response fails.
    H-f measured the check reaching its target in about 10 ms.
  - **Its reach.** It covers deposit destinations only. FSW-N leans on S3-B′'s check, its privilege included (H-f).
    Under S3-A it would bring that check in.

## 4. Test texts (Run review points if they carry; each is one reader's exact words)

Each item names where it goes. **Pairs** are alternatives: PICK at most one of each pair.

- **T1** (astra; C12, `CNF-365`). Replaces forms-r63g's "Withhold the read of the standbys' positions and assert both
  components refuse every new connection.":
  "With healthy replication, withhold position-query results through the connection-attempt deadline. Assert closure
  without use or fallback, no check-issued writes, and no check-created `SyncRep` backend."
- **T2** (astra; C12): "Inspect the deployed topology for transaction-mode pooling."
- **T3a** (astra; C12): "Repeat promotion with unequal durable histories after restarting both standbys without the
  primary; assert selection of the complete history."
- **T3b** (fable; C12): "Stop one standby, make an acknowledged write, stop the other, lose the primary, restart both
  standbys, and assert the procedure promotes the one holding that write."
- **T4a** (astra; C12; only if the owner picks PA-2): "With one report unavailable, assert automatic failover performs
  no promotion."
- **T4b** (opus W6; C12; only if PA-2): C12's "promotes neither as a restart" gains "and none until an operator
  decides".
- **T5** (astra; C12): in forms-r63g's "assert no component uses a connection before a standby has flushed past the
  flush position it reported", replace "past" with "at or past". (S3-B′'s MUST says "up to"; the harness checked
  `flush_lsn >=`.)
- **T6a** (astra; C9, before NA's "Cancel every `api` request…"): "First fill the replica's write-checkout budget with
  waiting commits."
- **T6b** (opus W3; C9): NA's step begins "Fill one replica's write checkouts with waiting writes, cancel every one…".
- **T7** (opus W3; C9, at the end of NA's step): "and after release assert its writes run on the backends it held
  before the stall".

Astra's full C12 line (r63g astra.md:32) is T1 + T2 + T3a + T4a + T5.

## 5. Follow-ups, as r63g's tally lists them (not voted; flag errors only)

- **F1:** a WAL-history model in `tools/formal/`.
- **F2:** residual backends from exiting processes and from dead database transports. Availability only.
- **F3:** replication-config drift at run time. Safety-relevant. The ADR states correct replication config as a
  trusted deployment assumption. Pooler topology is folded in.
- **F4:** an audit of external actions against the objective, which includes `OPS-32`'s read-based deletions. FSW
  joins it unless the owner closes FSW now.
