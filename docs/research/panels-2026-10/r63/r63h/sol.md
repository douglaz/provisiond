| Item | Vote | Quote or trace |
|---|---|---|
| NA′ | ACCEPTABLE | Correctly limits cancellation protection. |
| NA-sol | PICK | Trace 1 below defeats the budget bound even under B′. |
| INV-ADR′ | PICK | forms-r63h:90–91: “A restore can still lose acknowledged history.” |
| FSW-L | ACCEPTABLE | Explicit acceptance; retains the exposure risk. |
| FSW-N | PICK | Writer SIGTERM → unsignalled reader exposes deposit → primary lost; checking after the read blocks exposure. |
| T1 | PICK | forms-r63g:48–49: “the connection is closed unused, and nothing falls back to an unchecked one.” |
| T2 | PICK | forms-r63g:57: “No pooler in transaction mode fronts the pools”. |
| T3a | ACCEPTABLE | Equivalent history-selection coverage. |
| T3b | PICK | H-e: restarted receive positions tie although only one standby holds the acknowledged write. |
| T4a | PICK | forms-r63g:107: “an automatic failover promotes only as a restart”. |
| T4b | ACCEPTABLE | While the missing-report fault remains imposed. |
| T5 | PICK | forms-r63g:46: “up to”; H-f uses flush_lsn >= target. |
| T6a | PICK | Budget two, one waiter: cancellation leaves a spare checkout, so overload need not occur. |
| T6b | ACCEPTABLE | Equivalent setup. |
| T7 | NOT ACCEPTABLE | NA′ holds the connection “before the reply arrives” (forms-r63h:40–41); retiring it afterward is permitted. T7 can reject that conforming pool. |

1. B′ does not make NA-sol redundant for a strict budget bound. Budget one: send COMMIT; pause its backend after HOLD_INTERRUPTS but before its commit record/flush (18-xact.c:2358,2381,1506). Lose its transport; replacement samples an earlier flush target and passes while replication is healthy. Repeat with independent transactions, leaving each COMMIT unfinished; then freeze both standbys and schedule those commits. Those predecessors now wait outside the single checkout: their number has no pool-derived bound, only the primary’s available connection slots. B′ covers commits flushed before its sample, with eventual waiter release; it does not bound these in-flight predecessors. Under S3-A, yes, NA-sol is needed for that bound: repeatedly disconnect already-waiting writers and replace them during the freeze (H-c). C9 holds for its stated HTTP-cancellation experiment with live database transports, but “never” must not be advertised as unconditional. W1 and Fable’s normative MAY clarification agree with NA′.

2. The corrected case is accurate as an incomplete argument, not a proof of the objective: 03-operation-lifecycle.md:760 says “Step 9 MUST begin only after step 8's transaction is acknowledged”; OPS-32 remains outside that argument. No operative clause depends on the broader rationale. Its lost protection would forbid even acknowledged/exposed history being lost in a permitted restore: H-e’s acknowledging standby becomes unavailable and the operator promotes the laggard. The procedure accepts “the lost window” (05-persistence.md:1486).

3. Yes: forms-final:53 expressly includes “had a waiting backend cancelled or terminated”; STO-7’s shutdown permission is no exception to that classification. Existing text does not guarantee the promoter can know afterward: identical standby reports fit both a clean history and an unreplicated, shutdown-released commit. It needs durable evidence outside the lost primary recording the affected incarnation’s shutdown/cancellation history, or conservative restore classification whenever that history is unknown. Deposits are not the only concern. API-54 says “A read MUST NOT take a write transaction” (04:1291), enabling ungated reads. A shutdown-released receipt can yield API-11’s “409 Conflict” (04:937), then disappear; revocation replay can report “credential_already_replaced” (04:582) before loss resurrects the old token if misclassified; an observed revision can be reused despite “strictly increases” (04:1283–1284); a shown extension can disappear, followed by LDG-14’s “disk destroyed” (12:1929); OPS-32 can read a newly settled operation and delete its image/key before that settlement is lost (03:1630–1635). Correct restore handling mitigates several cases. FSW-N covers only destinations: POST /v1/deposits, including replays, and GET /v1/deposits/{id} (WIR-14/15, 13:566,592). Attribution returns the “credited tenant's balance view” (13:505–506).

4. T1 should replace the r63g sentence, exercised for both components. Pick T3b’s concrete history setup and T6a’s explicit waiting commits. T4b is acceptable only while a report remains unavailable: PA-2 says “until both standbys report or an operator decides” (forms-r63g:108). T7 either observes where the original write already ran or restricts permitted post-reply recycling. Replace it with an observation before the reply.

5. NA’s dropped claim protected live-process capacity; NA′ retains cancellation ownership, not the transport-loss bound. NA-sol restores that bound until process exit, sacrificing write availability while completion is unknown. Without it, trace 1 remains. INV-ADR’s narrowing accepts restore losses; restore safeguards remain. INV-STO never covered FSW: its checked-connection alternative permits the read, and read-only COMMIT certifies no replication (18-xact.c:1557–1567). Forgoing per-read checks leaves the exposures in 3. Dropping T1/T2/T3/T4/T6 respectively loses detection of fallback/write checks, hidden poolers, restarted receive-position ties, automatic restores, and premature checkout release with a full budget. T5 removes an erroneous strict-greater test. T7’s useful identity observation needs the replacement below; B′ can mask abandonment in aggregate counts. Unselected pair variants add no unique protection.

6. S2’s deploy-versus-request contrast is false; both can strand waits. S3’s core choice is accurate, but permissions, existing sessions and configuration drift need precision. P’s restore costs are accurate; both policies still depend on correct classification, and “itself” wrongly assigns the restore-record writer. F’s source-only status and local latency evidence are accurate; its “instant” is unbounded, and its scope omits non-deposit effects. Exact corrections follow; none changes the voted options.

7. The strongest counter-case succeeds against compliant address reuse: the shutdown terminated a waiter, so STO-54 requires a restore; 05:1518–1519 requires the index skip “before any deposit is minted.” Thus step 6’s restart classification violates the draft. Also, warm-standby.txt:169 says shutdown waits for transfer to “currently connected standby servers”; if one receives the commit, loss fails. Neither defeats the disconnected-standby schedule. Serial signalling permits, but does not guarantee, an unsignalled reader running before its signal. H-b proves the SIGTERM visibility ingredient, not that whole schedule. Correct restore classification still does not reconstruct a lost deposit binding.

8. Errors relied on: forms-r63h:72–73, “No new waiter can pile up behind a frozen standby,” overclaims by trace 1. Its :205–206, “FSW joins it unless the owner closes FSW now,” must retain non-deposit FSW even with N. Owner :56, “copying silently stops,” confuses synchronous acknowledgement with streaming; H-d2 demonstrates only that acknowledgement stops waiting. Owner :6–7, “Every hole … happens,” exceeds the harness’s demonstrated cases. I verified the cited errata against source/harness. Repository dc5d40d unchanged; no database starts. Artifact-writing gates omitted under the no-write instruction.

Exact fixes; all explanatory/test-only, with no runtime behaviour change:

- C9 prefix: “With database transports remaining live and the replica process remaining alive,”.
- T3b addition: “Repeat with standby roles exchanged and assert the durable-end reports distinguish their unequal histories.”
- Manager inference: “B′ blocks replacement use for commits already covered by its sampled target; unresolved in-flight COMMITs can escape that coverage.”
- T7 replacement: “While each sent COMMIT remains unresolved and its transport remains live, assert its original connection and write checkout remain retained.”
- F4: “Retain non-deposit fast-shutdown consequences in the audit even if FSW-N is adopted.”
- Owner introduction: “The harness demonstrated the crash, cancellation, abandoned-client and promotion failures. The fast-shutdown exposure is source analysis, not a reproduced result.”
- Owner NA/S2: “Request cancellation retains the write checkout. Process exits and dead database transports can still strand waits. Repeated stops can exhaust database slots.”
- S2 A cost: “Waiting backends remain until replication resumes or the primary shuts down.” B misconfiguration: “A supervisor that kills the process during its standby wait defeats B’s protection.”
- S3 B cost: “During a freeze every new database connection is unusable, including one opened by a process that never restarted.”
- S3 B permission: “Missing statistics permission blocks new connections; existing checked connections can keep serving.” Pooler: “Transaction pooling can silently reopen the hole; no required run-time check detects a pooler added later.”
- Common S3 availability: “Without NA-sol, dead transports can exceed a live process’s write budget under either option; with it, unknown completions keep capacity charged.”
- Common S3 risk: “An empty copy list lets writes be confirmed without a copy; streaming may continue. Correct replication configuration remains trusted.”
- P: “The deployment must classify the switch and commit its restore record before either component starts. Both choices trust that classification. Skipping addresses does not reconstruct a lost deposit.”
- F: replace “for an instant” with “during an unmeasured window”; replace its bracketed restart clause with “The draft requires a restore here; misclassifying it as a restart can re-issue an address.” Add: “N needs standby-statistics access and the same uninterrupted PostgreSQL session, including under S3-A. It leaves other shutdown-window consequences for F4.”

Final:  
NA′: ACCEPTABLE  
NA-sol: PICK  
INV-ADR′: PICK  
FSW-L: ACCEPTABLE  
FSW-N: PICK  
T1: PICK  
T2: PICK  
T3a: ACCEPTABLE  
T3b: PICK  
T4a: PICK  
T4b: ACCEPTABLE  
T5: PICK  
T6a: PICK  
T6b: ACCEPTABLE  
T7: NOT ACCEPTABLE