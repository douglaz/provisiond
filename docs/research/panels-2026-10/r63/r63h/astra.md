| Item | Vote | Quote or trace |
|---|---|---|
| NA′ | ACCEPTABLE | Cancellation retention without the false transport-loss bound. |
| NA-sol | PICK | “Until that backend is known to have finished, its budget remains charged”; trace 1 below. |
| INV-ADR′ | PICK | “A restore can still lose acknowledged history.” |
| FSW-L | ACCEPTABLE | Explicit acceptance, not proof that exposed history survives. |
| FSW-N | PICK | “target sampled after that read” includes the exposed commit’s WAL. |
| T1 | PICK | forms-r63g:48–49: “connection is closed unused”. |
| T2 | PICK | forms-r63g:57: “No pooler in transaction mode fronts the pools”. |
| T3a | ACCEPTABLE | Same adversary as T3b, less concrete. |
| T3b | PICK | H-e: restarted standbys report equal receive positions despite unequal histories. |
| T4a | PICK | forms-r63g:107: “Only an operator starts a promotion that is a restore”. |
| T4b | ACCEPTABLE | Applies while the report remains unavailable. |
| T5 | PICK | S3-B′: “up to”; equality satisfies it. |
| T6a | PICK | Empty slots → cancellation → another write admitted; saturation is necessary. |
| T6b | ACCEPTABLE | Equivalent with commits actually waiting. |
| T7 | NOT ACCEPTABLE | Reply arrives → pool legitimately retires connection → next write uses a checked replacement; T7 rejects this conforming execution. |

Locations use the brief’s shorthand; votes concern forms-r63h.md over `dc5d40d`.

1. **NA.** B′ does not make NA-sol unnecessary for a strict budget. With budget one, delay backend A after `HOLD_INTERRUPTS` but before its commit record (`18-xact.c:2358–2381`); lose its transport. Replacement B checks an earlier flush target successfully. Repeat while replication works, then stop both standbys and let the orphaned commits flush: multiple waits share one replenished slot. No pool-derived bound exists; server connection capacity bounds this accumulation. Once both standbys are down, new checks fail, so this does **not** demonstrate unlimited replacement admission during that freeze. The manager’s WAL-prefix argument is correct for commits already flushed (`18-xact.c:1506,1567`), not later commits or backend completion. Under A, **yes**, charging is needed for that bound: H-c’s transport-loss/replacement loop proceeds without checks. C9 holds in a clean cancellation-only fixture; its unqualified “never” overclaims beyond it.

2. **INV.** The corrected case is accurate and partial: `OPS-43` requires “only after step 8’s transaction is acknowledged” (`03:760`); `OPS-45` requires persistence “before that phase runs” (`03:1422–1423`). No normative rule depends on the broader rationale; F4’s audit scope must follow the narrowed objective.

3. **FSW.** **Yes**, draft `STO-54` includes “had a waiting backend cancelled or terminated”; its cross-reference supplies no shutdown exception to classification. **No guaranteed knowledge** survives primary loss: require a primary-incarnation-specific record, durable elsewhere before signalling, identifying possible wait termination; absent trustworthy evidence, classify conservatively as restore. Deposits are not the only consequence. `API-54`’s “A read MUST NOT take a write transaction” (`04:1291`) is a barrier constraint. FSW can expose `API-11`’s “409 Conflict” (`04:937`), revocation’s “credential_already_replaced” (`04:582`), or a revision promised to “strictly increase” (`04:1283–1284`); losing that history allows key acceptance, resurrected credentials, or revision reuse. Show extended runway, lose its extension, then `LDG-14`’s “disk destroyed” (`12:1929`) can follow. `OPS-32` can read settlement and delete an image before losing that settlement: “deleted rather than reported” (`03:1632`). N addresses none of these. Destination responses are WIR-14’s POST, including API-45 replay, and WIR-15’s GET (`13:566–604`); attribution returns a balance (`13:505–506`).

4. **Tests.** Replace the old sentence with T1, retaining explicit coverage of both components. Pick T3b’s concrete setup, T4a’s automatic-promotion assertion, and T6a’s explicit waiting commits. T7 needs an ownership assertion during the wait, not mandated subsequent reuse.

5. **Losses.** NA’s deleted assertion claimed resource containment; NA′ retains cancellation protection, B′ only partially covers transport loss, and without NA-sol trace 1 remains. Broad INV-ADR claimed protection even across restores; nothing retains that guarantee: an acknowledged extension can disappear, and `05:1555` says it “is not rebuilt”. INV-STO never covered FSW: its “or on a connection STO-7 checked” admits the trace; read-only COMMIT certifies nothing (H-d2). Forgoing N leaves deposit exposure and potentially uncreditable payments even with a correctly classified restore. Without T1/T2/T3/T4/T6, respectively, write checks, forbidden pooling, receive-position ties, automatic restores, or unsaturated fixtures can escape detection. T5 prevents false failures at equality. Dropping the unpicked pair alternatives loses nothing; T7’s replacement catches abandonment masked by B′.

6. **Owner questions.** The choices are understandable, but not yet accurate enough. S2 understates residual accumulation; S3 confuses synchronous acknowledgement with copying and understates connection-check costs; P omits unreconstructed deposits and assigns implementation to the controller unnecessarily; F understates its scope and infrastructure assumptions. Exact corrections follow; none changes an option’s behaviour.

7. **Strongest counter-case.** A conforming promotion is a restore, so address skipping defeats the claimed reuse. Shutdown also drains WAL to “currently connected standby servers” (`warm-standby.txt:169`), and available archived WAL is replayed before promotion (`:85`). Neither excludes the trace with disconnected standbys and no recoverable archive copy. Scheduling might signal the reader first, but `postmaster.c:3482–3501` provides no guarantee. Correct restore classification still cannot reconstruct a lost deposit.

8. **Brief errors.** Owner “Every hole … happens” exceeds the measurements; “copying silently stops” is false (H-d2 disables synchronous waiting, not streaming). “the controller must … write the restore record itself” adds an actor requirement absent from the forms. Forms-r63h:205–206’s “unless the owner closes FSW now” overstates N’s deposit-only reach. Its manager argument does not establish NA’s budget. The errata are supported; I found no conflict in the carried W1/Fable wording.

Exact fixes:

- **C9:** “With no prior orphaned backends and healthy database transports, first fill the write budget with waiting commits. Cancel those requests; assert waiting backends remain within that budget, a further write is refused overloaded, and a read succeeds.” Replace T7 with: “While replication remains stalled, assert cancellation retains ownership of each original database session.” In NA-sol’s test, use “orphaned unresolved backend waits” to avoid double-counting owned waits. **Test changes only.**
- **T1:** prepend “For both components:”. **Test clarification.**
- **F4:** “Audit non-deposit consequences of the fast-shutdown window even if FSW-N is adopted.” **Scope correction.**
- **Owner introduction:** “The harness records measured cases H-a–H-f and labels source-only claims separately.”
- **Owner INV-STO:** replace “the check it allowed proves nothing” with “a read-only COMMIT proves no replication, and its checked-connection alternative adds nothing beyond B′.”
- **Owner NA/S2:** “After COMMIT is sent, request cancellation retains its checkout until reply or transport failure. Process exits can leave waits behind; transport failures do too unless NA-sol keeps their budget charged. NA-sol can refuse writes until completion is established or the process exits.”
- **S2 costs/misconfiguration:** “A can leave waits until a standby catches up or the primary shuts down. B can delay shutdown indefinitely. Killing earlier than the selected stop rule permits violates it.”
- **S3 B cost/misconfiguration:** “Every new component connection needs the check, even without a process restart. Missing read permission refuses new connections; existing checked sessions can still read. B still trusts replication configuration and the absence of transaction pooling.”
- **S3:** replace “It needs no special server setting” with “It needs statistics-read permission; existing replication settings remain trusted.”
- **S3 common warning:** “Emptying the synchronous standby list stops commits waiting for copies; asynchronous copying may continue. No runtime configuration check detects this change.”
- **P:** “The promotion procedure must classify the switch and commit its restore record before either component starts. Skipping addresses prevents reuse but does not reconstruct lost deposits. Under Wait, automatic promotion with a missing report violates the option.”
- **F:** replace “instant” with “window” and its bracketed condition with “If this restore is misclassified as a restart, the address can be re-issued.” Add: “The draft does not require classification evidence that survives primary loss. N protects deposit destinations only; the broader audit remains.”
- **F-L cost:** “L adds no runtime protection; a returned deposit may be lost even when the subsequent promotion correctly runs the restore procedure.”
- **F-N cost/misconfiguration:** “Store-read destination replies require another check and fail while neither copy can report. H-f measured about 10 ms, not a latency bound. Missing permission fails closed; replication correctness and an uninterrupted PostgreSQL session remain required.”

**Owner-copy fixes above change no behaviour.** Mandating the external evidence described in answer 3 would add deployment behaviour. No repository writes or database starts; artifact-writing gates were not run under the read-only instruction.

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