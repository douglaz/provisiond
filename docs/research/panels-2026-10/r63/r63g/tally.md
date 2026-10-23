# r63g tally (pv-s4m, panel C, external-review intake). 2026-10-23 ~06:30Z

All four exited 0. Answers: opus.md, astra.md, sol.md, fable.draft.md (fable.md is a summary). Rules: notes.md.
The manager stopped at the context limit after this tally. **r63h is NOT drafted and NOT launched.** Next steps are at
the end.

## Votes (every PICK / NOT ACCEPTABLE below cites a quote or a trace, so all are valid under rule 1)

| Item | opus | astra | sol | fable | Outcome |
|---|---|---|---|---|---|
| NA | PICK | NOT ACC | NOT ACC | PICK | **2-2: doesn't carry. Not deleted (rule 9). Goes to r63h as NA′** |
| STOP-A | PICK | PICK | ACC | PICK (MOVE from B) | **A 3-1, acceptable to all 4. Owner, A recommended. The reviewer also picks A** |
| STOP-B | ACC | ACC | PICK | ACC | |
| S3-B′ | PICK | PICK | PICK | PICK | **B′ 4-0. A and AB acceptable to all 4. Owner, B′ recommended. The reviewer also picks B** |
| S3-A / S3-AB | ACC / ACC | ACC / ACC | ACC / ACC | ACC / ACC | |
| PT | PICK | PICK | PICK | PICK | **CARRIES 4-0. Settled, reported to the owner, not asked** |
| PA-2 | PICK | PICK | PICK | PICK | **PA-2 4-0, PA-1 acceptable to all 4. Owner, PA-2 recommended. The reviewer also picks PA-2. Trade text corrected (E5)** |
| PA-1 | ACC | ACC | ACC | ACC | |
| INV-ADR | PICK | NOT ACC | PICK | PICK | **3-1, but VOIDED under rule 5 (E1, E2). Goes to r63h as INV-ADR′** |
| INV-STO | NOT ACC | NOT ACC | NOT ACC | NOT ACC | **0-4: DELETED.** One line to the owner: "it forbade nothing under B′ and certified nothing via a read-only COMMIT" |

## Dissent and new-fact checks

- **NA: dead transport (astra, sol; opus concedes it in his item 12). VERIFIED.**
  - syncrep.c:331 `WaitLatch(MyLatch, WL_LATCH_SET | WL_POSTMASTER_DEATH, …)` has no socket event.
  - H-c measured the backend still in `SyncRep` after 30 s, with `client_connection_check_interval` and 1 s keepalives.
  - So NA's "a live process never has more backends waiting … than its pool holds" is false.
  - **Not deleted.** NA replaces C7's cap, and dropping it brings back H-c's 17-waiter exhaustion from plain cancellation (rule 9, and the reviewer's Finding 1).
  - Under S3-B′ the gap closes by construction: a replacement connection's target is the primary flush position, which is past the stuck commit, so it can't pass during a freeze (opus 7 and 8d). The bound fails only under S3-A. So the narrowing in astra's text, which changes no behaviour, is enough. Sol's charged-budget text (below) is one reader's behaviour change, needed only under A.
  - Fold dead transports into F2.
- **STOP-B (sol): H-c orphans from repeated stops. Availability only, no money.** Fable's MOVE rests on "B would make the supervisor's wait unbounded, an infra duty", not on NA's per-process bound. The tally stands.
- **INV-ADR (astra): VERIFIED.** "An allowed failover could discard" includes restore promotions. Draft `STO-54`: "Any other promotion … is a restore", and the restore accepts loss. So the universal is false as stated (AGENTS.md: one counterexample retires a universal). Sol, who picked it, also asks to qualify it.
- **PA, current text:** all four agree that nothing says who starts a promotion, and nothing forbids an automatic restore. Verified: `05:1316-1320` `STO-56` is "written into the restored store before either component is started and closed by the operator", which covers closure, not initiation.
- **Q9 counter-case (barrier-only): refuted 4-0.** This was a requested counter-argument, not a vote. Verified quotes:
  - `04:1291` `API-54` "A read MUST NOT take a write transaction" (astra, sol);
  - `04:936-938` `API-11` "Re-sending it with a different request MUST fail `409 Conflict`" (astra);
  - `04:580-584` the revocation replay returns `409` `credential_already_replaced`, against `04:560-561` "A revocation invalidates the current token immediately" (opus);
  - sol adds `API-53`'s revision reuse, and fable `LDG-14`'s runway destroy.
  - The per-connection check covers a class that per-endpoint barriers miss.
- **Deleted safeguards (Q7): rule 9 doesn't fire.**
  - RS gated only "a component". All four say nothing is lost against RS. Operator sessions and the separately invoked migrator were never covered (astra, sol: "do not claim otherwise"). The `OPS-47` lock connection is a component's new store connection, so B′ covers it.
  - C7 "never bounded abandoned waiters" (opus): `05:143` freed the slot on abandonment. The transport gap exists with or without C7.
  - `off` is unneeded under B′.
  - The pooler allowance and `CNF-56`'s reassignment have nothing left to protect once no pooler is allowed.
- **Wrong builds (Q8):**
  - (a) C12's withhold step catches it only with a standby streaming (astra, sol, fable).
  - (b) Caught only if the withhold outlasts the check's timeout (opus, astra).
  - (c) A pooler: no assertion guarantees a catch (opus, astra, sol). One that drops frontends passes the crash drill, and nothing catches one added later.
  - (d) C9 catches it only if it first fills the write budget (astra, sol). Under B′ it is masked (opus).
  - (e) Ranking by `pg_last_wal_receive_lsn()`: **no assertion catches it, 4-0**.
  - (f) PT's C12 sentence catches it, 4-0.
- **Q-R reduces to the fast-shutdown window (FSW).** Under either S3 option, only FSW and a restore let an unreplicated read escape (opus, fable).
  - Trace (astra 10, sol INV-STO). A fast shutdown during a freeze ends a waiter (E2 allows "shutting the primary down"). Its commit becomes visible. A checked reader returns D before its own SIGTERM lands (postmaster.c:3482-3501 signals children one at a time). The primary is lost, and the promotion is classed a restart.
  - Money: `05:867`'s address is re-issued.
  - Scope split 2-2: astra and sol want it closed or explicitly accepted now; opus ("only if the owner wants Q-R") and fable ("not needed") say later.
  - **Open reading question for r63h:** does draft `STO-54`'s "or had a waiting backend cancelled or terminated (`STO-7`)" already make that promotion a restore? And can an automatic controller know it once the primary is lost?
- **F3, config drift:** all four call it safety-relevant to the owner's misconfiguration concern. An emptied `synchronous_standby_names` makes every acknowledgement local, and nothing notices (H-d2 edges). None asks for it in this change: fable says "file with priority", astra and sol say "only if stated as a trusted deployment assumption", and opus says "tell the owner".

## Brief errors (rule 5): verified

- **E1.** forms-r63g:125 and verify:143/147 claim "Every engine provider mutation already follows an acknowledged commit made after its authorizing reads" and "every provider-facing step is behind a guarded write". That is false: `03:1630-1635` `OPS-32` deletes imported images and temporary keys from reads ("so it is **deleted** rather than reported") (astra, sol). → Voids INV. Add to F4.
- **E2.** "sub-millisecond" (forms-r63g:132, verify:128) is unmeasured (astra, sol). → Write "unmeasured" everywhere.
- **E3.** NA's "a live process never has more backends … than its pool holds" (forms-r63g:14) is false; see above. The same overclaim is at forms-r63g:33-34 ("bounded per live process") and in the owner draft ("no longer strands a database connection").
- **E4.** verify:94, "Adding `SET LOCAL` would collide with C8", is wrong (astra, sol). The conclusion stands: it's redundant ("compatible but redundant").
- **E5.** forms-r63g:111 and the owner draft say PA-1 lets a controller "promote the other at once". That overstates it (opus):
  - forms-final:20 says "the primary never serves with `synchronous_standby_names` empty";
  - `05:1485` and `05:1516` take the public listener down and bump every tenant's credential generation.
  - So PA-1 gains only the time until a copy streams from the promoted one, on top of a restore. The error favoured PA-1, which no reader picked, so PA's 4-0 stands. Fix the trade text.
- **E6.** verify:114 "The flush position always terminates": add "given eventual standby progress" (sol).
- **Minor fixes:**
  - The "Two rules" span is `05:140-145`.
  - forms-final's "`03:1738`'s Stop-record clock" is at `03:1763` (fable): a Run review point.
  - The xlog.c quote "where the first xlog record…" is from `XLogBytePosToEndRecPtr`'s comment (fable).

## r63h scope (draft its brief and outcome rules BEFORE launch; reuse r63g's scripts)

Don't re-vote STOP, S3, PA or PT. Readers review:

1. **NA′.** NA with its "so a live process never has … than its pool holds, and" inference replaced by astra's text:
   "Cancellation alone does not release that write checkout. Dead database transports and process exits can leave
   waiting backends outside the pool's accounting."
   - This changes no behaviour.
   - The alternative is sol's behaviour change, "A dead transport does not replenish the write-checkout budget while its server transaction may still be waiting. Until that backend is known to have finished, its budget remains charged, or the component process exits."
   - Ask whether B′ makes sol's text unnecessary.
2. **INV-ADR′.** Astra's text, verbatim: "Design objective: irreversible external consequences must not depend on history a promotion classified as a restart may discard. A restore can still lose acknowledged history."
   - Its case is corrected for E1, so `OPS-32` is listed for F4. No normative text.
3. **FSW.**
   - (i) The STO-54 reading question above.
   - (ii) A vote between FSW-L, which accepts the window for v1, has `ADR-0045` record it, and leaves it to F4, and FSW-N, which is sol's text verbatim: "Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the result and repeat the whole read."
4. **Test texts.** Each is one reader's exact words. Run review points if accepted:
   - C12, astra: "With healthy replication, withhold position-query results through the connection-attempt deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend."
   - C12, fable: "Stop one standby, make an acknowledged write, stop the other, lose the primary, restart both standbys, and assert the procedure promotes the one holding that write."
   - C12, opus W6, if PA-2: "promotes neither as a restart" gains "and none until an operator decides".
   - C9, astra: "First fill the replica's write-checkout budget with waiting commits."
   - C9, opus W3: "and after release assert its writes run on the backends it held before the stall."
5. **The four owner questions as they'll be asked** (STOP, S3, PA, FSW), with the misconfiguration lines below.

## Owner-question fixes (rule 8, applied without a vote; r63h reads the result)

- **S2′:** drop "no longer strands a database connection".
  - Use opus's "a web request that gives up mid-save keeps its database connection until the save finishes, so the service refuses new saves instead of exhausting the database".
  - Add astra's "process exits and broken database transports can still leave waiting backends".
  - Fable's reason for A belongs in it: B makes the deploy tool wait without limit, which is a duty on infrastructure.
- **S3:**
  - Story's last line: "At 11:00 the copies return, but the main server dies before either catches up" (opus).
  - Add "Its address can later be handed to another customer" (fable).
  - Drop "Partly, yes" and "only a read permission" (astra).
  - B's cost: "While both copies are down, a restarting server process can't connect, even to read" (opus).
  - A's cost: "A crash of one database process stops the whole database until restarted" (opus).
- **PA:**
  - Replace "at once" per E5.
  - PA-2's cost: "it waits whenever either copy can't report, even if the reachable one holds everything" (sol).
  - Switch: "every customer's token is revoked, as after any restore" (fable).
  - PA-1: "Switching automatically is safe only if the switching tool also runs our restore steps" (opus).
- **Misconfiguration lines (required):**
  - **B′:** a missing read permission is loud, because the service stops serving. A connection pooler in transaction mode silently reopens the hole, and no check reliably catches one added later.
  - **A:** leaving `restart_after_crash` at PostgreSQL's default, or skipping the start gate, silently reopens the hole.
  - **Both:** if the copy list is emptied, copying silently stops and nothing in the service notices (F3).
  - **PA-1:** the controller must classify the promotion and write the restore record itself. If it doesn't, the engine restarts on a restored store and re-issues addresses.
- **Settled lines:** PT (4-0), INV-STO deleted (0-4), NA′ and INV-ADR′ per r63h.

## Follow-up beads (NOT filed; file `needs-triage` after the Run, with no AI wording)

- **F1:** a WAL-history model in `tools/formal/`.
- **F2:** residual backends from exiting processes **and from dead database transports** (astra, sol). Availability only.
- **F3:** run-time replication-config drift. Safety-relevant, 4-0. File it with priority, and the ADR states correct replication config as a trusted deployment assumption.
- **F4:** an audit of external actions against the invariant. Add `OPS-32`'s read-based image and key deletions (E1) and FSW, unless the owner closes FSW now.
- **Pooler topology** (astra, sol): no CNF catches a transaction-mode pooler added later. Fold this into F3, since it is the same class of run-time configuration check.
