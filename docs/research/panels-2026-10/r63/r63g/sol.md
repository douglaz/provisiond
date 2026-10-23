| Item | Vote | Quote or trace |
|---|---|---|
| NA | NOT ACCEPTABLE as written | “or the transport is found dead” releases capacity although its backend can remain in `SyncRep` (H-c; `18-syncrep.c:331`). Derived trace: a proxy closes transports; the live component replaces checkouts; repeat beyond the pool size. |
| STOP-A | ACCEPTABLE | Process exit is NA’s exception; the bounded record exit remains available. |
| STOP-B | PICK | Repeated orderly stops under A strand waiters outside pools (H-c). B’s supervisor wait gains “and any commit’s wait for the standby” (forms-final:169-170), avoiding that particular source. |
| S3-B′ | PICK | Closes H-a: every backend connection dies; recovered D cannot be returned through a new connection until a named standby flushes through its sampled target (forms-r63g:45-52). |
| S3-A | ACCEPTABLE | Closes H-a: `postmaster.c:3185-3189` exits with `off`; RS gates the next start. |
| S3-AB | ACCEPTABLE | Closes H-a through both safeguards; extra outage/configuration cost. |
| PT | PICK | H-e2: TL1’s numerically greater LSN lacks TL2’s commits. Comparing bare LSNs can select the wrong history. |
| PA-1 | ACCEPTABLE | Forms-final:52-54 explicitly classes the other promotion as “a restore: the procedure below runs on it”. |
| PA-2 | PICK | H-e: s1 acknowledges D, becomes unreachable; promoting s2 loses D. An operator should authorize that loss rather than an automatic controller. |
| INV-ADR | PICK | Rationale belongs in the ADR. `03-operation-lifecycle.md:760`: “Step 9 MUST begin only after step 8's transaction is acknowledged.” Qualify the principle for restores below. |
| INV-STO | NOT ACCEPTABLE | A checked connection can read D after fast shutdown releases D’s wait but before that reader receives SIGTERM; its “or on a connection … checked” permits exposing D. A later promotion can discard D. A read-only COMMIT also provides no certification (H-d2 edges). |

I reviewed forms-r63g over dc5d40d; result: FAIL as written. Individual votes stand above. Draft: [sol.draft.md](/var/tmp/provisiond-panel-r63g/sol.draft.md).

NA’s cancellation protection agrees with `OPS-21:1791`: “The settle write that records a stop after `execute` returns MUST NOT be cancelled or abandoned by that stop.” Its bound/later-stop exceptions remain (`:1795`): A exits at the bound; B excludes the standby wait. Holding a checkout need not keep a cancelled worker executing. **No MOVE:** STOP-B remains my preference; NA does not prevent process-exit orphans.

7. **Deleted safeguards.** RS protected post-start component access; B′ preserves that protection through physical connections. Neither text expressly gates arbitrary operator sessions or the separately invoked migrator (`STO-13:1385-1388`); do not claim otherwise. The startup-lock connection belongs to the engine even though outside its pool, so B′ must check it too. C7 protected capacity during stalls; separate write/read budgets replace its useful bound only after NA’s transport gap is repaired. Turning `restart_after_crash` off made reinitialization an externally observable stop; B′ makes observation unnecessary. Dropping transaction pooling closes hidden backend replacement, but removes supported deployment flexibility and its reassignment probe.

8. **Wrong builds.** (a) `CNF-365`’s withheld-position-read assertion catches a write-only checker if replication remains healthy during denial; add a direct no-write assertion. (b) The same refusal assertion catches fallback. (c) No assertion guarantees the blanket pooler ban: the crash assertion catches a pooler preserving frontend connections, but one that disconnects them can pass. (d) C9/`CNF-296`’s cancellation-plus-`overloaded` assertion catches released checkouts. (e) None requires restarting asymmetrically advanced standbys before ranking; C12’s retained-row assertion detects a wrong choice only if that situation is exercised. (f) PT’s `CNF-365` assertion explicitly rejects another timeline.

9. **Strongest deposit-only case.** Certify where an address escapes: read D and make a real logged write in the same transaction; expose nothing before acknowledged COMMIT. WAL ordering covers D, a dead session yields no acknowledgement, and H-d’s cross-server certification is impossible. Main worker mutations have claim/dispatch/marker writes; balance reads do not themselves authorize spending. OPS-32’s cleanup reads still need separate audit. This removes a global connection hook, stats privilege and crash-restart setting. But deposit GET directly breaks `API-54`, `04-api-contract.md:1291`: “A read MUST NOT take a write transaction.” Operation GET has another problem: read recovered terminal revision n; lose primary; promoted history has running n−1; startup writes reconciliation n. Different client-visible states reuse n, against `API-53:1283-1284`’s “strictly increases on each client-visible modification”. Those contracts need resolution; this is not a free substitution.

10. **Scope.** F1 is additional evidence; F2 concerns availability. F3 is safety-relevant if tolerating configuration drift is promised: H-d2 shows even the proposed transaction barrier cannot survive empty standby names. Otherwise correct configuration remains an explicit deployment assumption. F4’s already identified deposit/shutdown hole needs closure or explicit acceptance now; the broader audit can follow. INV-STO and redundant AB machinery are droppable. Neither S3 mechanism should disappear without deciding the replacement read contract.

11. **Owner questions.** S2 and S3 expose real choices, but their guarantees are overstated; exact replacements follow. P must explain that PA-2 waits whenever either report is missing, even if the reachable copy actually holds every acknowledged write. No current clause names a promotion initiator or prohibits automatic restore: `STO-56:1319-1320` says the record is “closed by the operator”, not opened by one. Q-R is missing despite verify.md referring to it; `API-53` makes the answer consequential. Keep mandatory deposit-destination durability separate from optional durability of informational reads.

12. **Brief errors.** Verify.md’s “Adding SET LOCAL would collide with C8” is false: deleting a compatibility explanation does not forbid redundant `SET LOCAL … = on`. “The flush position always terminates” needs eventual standby progress. “Every engine provider mutation already follows an acknowledged commit made after its authorizing reads” (forms:125; verify:147) overlooks OPS-32’s read-based key/image deletion (03:1630-1635), which does not require such an intervening write. Its “sub-millisecond window” is unmeasured and unbounded by the cited source. Forms-r63g:14’s claimed live-process bound has NA’s transport counterexample. The remaining facts used above match the supplied transcripts and source, including recovery visibility ([PostgreSQL 18](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION)). Gates were not run because the formal gate writes `.lake`, contrary to the no-write instruction.

Proposed exact fixes:

- **NA, behaviour change:** “A dead transport does not replenish the write-checkout budget while its server transaction may still be waiting. Until that backend is known to have finished, its budget remains charged, or the component process exits.” **C9 addition, behaviour check:** “Repeat transport failures while the replica remains alive; assert unresolved backend waits plus active write checkouts never exceed its write budget.”
- **Scope clarification, behaviour change for the migrator:** “Every provisiond store connection, including the migrator, schema-version reader and startup-lock connection, runs this check; arbitrary operator SQL is outside this component guarantee.”
- **C12, behaviour checks:** “Assert connection checks perform no writes. Assert the deployed connection topology contains no transaction-mode pooler. With the primary unavailable, restart both standbys, one holding an acknowledged write the other lacks; assert promotion as a restart selects the holder.”
- **F4, behaviour change:** “Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the result and repeat the whole read.”
- **ADR principle, accuracy only:** “A promotion treated as a restart must preserve database history supporting irreversible external consequences. A restore may lose history and runs STO-54’s recovery procedure.”
- **Owner copy, accuracy only:** “The harness reproduced the measured failures; the shutdown read race remains source analysis.” “NA protects request cancellation while the process and transport survive; process exits and transport failures remain.” “B keeps PostgreSQL’s default crash restart. Both choices still depend on correct replication and promotion configuration.”
- **P replacement, accuracy only:** “If either copy cannot report, may a controller promote the reachable copy as a restore and accept possible loss of acknowledged writes?”
- **Add Q-R, behaviour decision:** “Must balance and operation-status responses survive a promotion treated as a restart, even when the original writer received no commit acknowledgement?”
- **Verification corrections, accuracy only:** “SET LOCAL on is compatible but redundant.” “A fixed flush target avoids the page-header overshoot; passing still requires a standby to flush through it.” Replace “sub-millisecond” with “unmeasured”.

Final:

NA: NOT ACCEPTABLE as written.  
STOP: B PICK; A ACCEPTABLE.  
S3: B′ PICK; A and AB ACCEPTABLE.  
PT: PICK.  
PA: PA-2 PICK; PA-1 ACCEPTABLE.  
INV: ADR PICK; STO NOT ACCEPTABLE.