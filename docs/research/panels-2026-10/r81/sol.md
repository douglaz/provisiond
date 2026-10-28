Reviewed **c824e4fa4d612b231110bc5deb3e88b3b3e90f92**. **The pin has a blocking conflict. Final pick: B exactly as printed. A: ACCEPT. B: ACCEPT.** These are review judgments, not adoption authority.

1. **The conflict is real in the uncommitted-attempt case.**

   PostgreSQL documents `transaction_timestamp()` as the current transaction’s start time; its value stays fixed within that transaction. I checked the official [PostgreSQL 18 documentation](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT).

   At [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1442), the operator must “select and retain one new incident id and restore instant per actual restore” and “reuse both on a lost-reply retry.” [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636) defines the instant as “transaction_timestamp() of the newly begun transaction inserting this incident.”

   - **First attempt aborts:** grant the favorable case that the retained instant equals the first transaction’s start, `t1`. Nothing commits; N is absent. A later transaction starts at distinct `t2` and inserts N. Persisting `t1` violates the inserting-transaction definition; persisting `t2` violates unconditional retained-instant reuse. This remains one actual restore.
   - **First attempt commits, reply lost:** N already contains `t1`. The retry at `t2` performs the required “guarded no-op,” preserving the “original restore instant.” The transaction that inserted N remains the first transaction. Its timestamp need not become the no-op transaction’s timestamp.

   Thus, applying the inserting-transaction definition to every retry transaction would be an unsupported premise. Applying it to the transaction that first successfully inserts N exposes the actual conflict.

   I verified that the landed retry paragraph matches P/C5 after formatting normalization, and that the event-clock paragraph is unchanged from `7974839`. This is not an Implementer departure. The archived statement “An uncommitted first attempt instead establishes N once” resolves neither clock.

   **Rule 6:** I found no verified brief error changing this question’s premise; there is no basis to void it.

2. **Exact-form judgments and preference.**

   | Printed option | Judgment |
   |---|---|
   | A, including A1–A9 and unchanged STO-56 paragraphs | **ACCEPT** |
   | B, including its complete replacement retry paragraph | **ACCEPT — final preference** |

   I checked A1–A9 against their pinned replacement ranges and the dependencies in the supplied inventory. A1 changes the event definition; A2 moves the upper-bound recipe’s evidence anchor to that event. A3–A8 synchronize the formal descriptions, and A9 records the replacement of UO’s original definition. I found no additional forced replacement.

   B explicitly distinguishes absence from a committed record. In the question’s abort trace, it requires **`restore_instant = t2`**, the successful inserting transaction’s start. In the committed-first trace, it preserves `t1`.

   B’s surviving mismatch obligation remains coherent. A committed row found by id can supply its original timestamp and predecessor; an actual conflicting assertion must be refused. B requires preservation of the “original restore instant,” so computing the no-op transaction’s current timestamp does not itself establish a mismatch. Nor does the text require deriving the expected predecessor from today’s open row. The comparison mechanics remain underexplained, as in P; I found no forced contradictory outcome requiring the excluded predecessor algorithm.

   I prefer B because it preserves the precise database event definition and confines the policy qualification to establishment retries.

   **Requested counterargument:** B withdraws P’s explicit same-instant protection across an aborted attempt. A preserves a stable event for the actual restore even when establishment takes hours or several attempts. B can place the recorded event much later and, when using the event-clock reporting recipe, produce a later upper bound. That is a substantive cost of B.

3. **Substance, protections, and collateral effects.**

   **A changes substance.** The original definition protected an exact relationship between the persisted event and the inserting transaction. A replaces that relationship even on a successful first attempt: selection can precede transaction start. It also replaces “The transaction begins after the existing stopping/fencing requirements are satisfied” with a selection-after-stopping/fencing condition. The explicit transaction-start qualification is no longer retained in A1.

   A2 preserves the reporting protection by requiring evidence that “no old-history acknowledgement follows that selection.” For example, with selection at `t1`, an aborted attempt, and insertion at `t2`, A permits its recipe to use `t1 + e_event` only with evidence for the selected event and its stopping boundary. Evidence solely about the inserting transaction’s clock cannot automatically certify the selected clock. This can change the available bound or leave it unknown.

   **B changes substance.** It replaces P’s unconditional “reuse both” obligation with reuse of the id and preservation of the instant once committed. The abort trace changes from retained `t1` to insertion time `t2`. The protection lost is precommit timestamp stability; committed-record stability remains explicit.

   The remaining checks support acceptance of either form:

   - **Stopping and startup:** STO-54 still requires stopping every component before restore and says “MUST start neither component until the transaction that commits `STO-56`’s record … has been acknowledged.” Neither candidate permits startup during uncertain establishment.
   - **Certificate truth and unknowns:** STO-54 retains “A non-null f MUST certify that no component acknowledged an old-history commit after f” and “A bound without valid evidence is unknown, not an invented recovery time.” A changes which event its recipe references; neither option makes an uncertified finite endpoint valid. The lower-bound recipe is unchanged.
   - **Endpoint persistence:** STO-56 retains “The endpoints and reference MUST be written with the row”; STO-54 retains “Continuations reuse the persisted endpoints and evidence unchanged.” Before N exists, no persisted N endpoints exist to reuse. After insertion, neither option authorizes recomputation on a no-op or continuation.
   - **Provenance and supersession:** STO-54’s establishment transaction still “MUST set this column `true`” on the specified surviving rows. STO-56 still requires the distinct successor record, and “no predecessor step mark satisfies a new step.” An aborted transaction leaves those effects uncommitted; successful establishment performs them atomically. A committed repeat preserves N rather than establishing another incident.
   - **Marks, grace, and ordinary continuation:** STO-54 retains “A marked step does not run again.” STO-56 still anchors grace “as step (3)’s instant plus one re-derivation interval.” Changing the establishment clock therefore does not move grace, spend paused grace, clear fences, or make a process successor a new actual restore.

   In the formal model, `RestoreTrace.now` and `Record.restoreInstant` are arbitrary `Nat` values; `RestoreTrace.store` assigns the former to the latter, `afterCrash` reads the persisted value, and `step_three_writes_grace` uses its independent completion instant. Establishment attempts, SQL timestamp selection, and reporting certificates are absent. A changes those inputs’ documented interpretation without changing a declaration, assignment, theorem, or guard hypothesis. No additional paired declaration amendment is forced by this clock choice, and compilation establishes neither policy’s retry protocol.

   Neither printed option changes a conformance assertion or negative-control strength. I checked the complete consumers identified by the supplied `check/source-inventory.json`; their evidence fields and generic certificate obligations remain compatible. WIR-9a has no event-clock definition. WIR-1’s second-precision emission rule supplies no stored-event precision amendment.

   **E-KEEP remains intact:** neither option broadens source clock-error wording into a quantization policy. **pv-kwuf remains independent:** its adopted “Whole milliseconds” input domain concerns the Startup-lock wait bound, not incident timestamps.

4. **SEPARATE CNF/GATE ANSWER: YES — add a CNF case.**

   This is independent of my acceptance votes. The missing case can catch an implementation that persists an aborted attempt’s timestamp under B, or replaces a committed timestamp with the no-op retry’s timestamp. I propose a conformance addition, not a new specification gate.

   Exact proposed addition to **CNF-295**, for B:

   > Exercise establishment for one actual restore with incident id N, for backup restore and separately for restore-class promotion. Begin the first establishment transaction at t1, lose its connection/reply, and establish that it did not commit; assert N is absent. Retry the same actual restore with the same id in a newly begun transaction at t2 distinct from t1. Assert N is inserted once with restore_instant equal to t2. Repeat with an open predecessor and assert atomic supersession.
   >
   > Separately let the first establishment transaction commit at t1 but lose its reply. Retry at distinct t2 and assert a guarded no-op preserving N’s original restore instant, predecessor, step marks, grace end, endpoints and evidence reference, without creating another incident. Neither component starts before establishment or its matching no-op is acknowledged.
   >
   > Use null endpoint fields with a non-null incident-keyed evidence reference retaining the unknown-endpoint reasons. Also exercise the event-clock upper-bound recipe with certified evidence for the transaction that inserted N; assert it uses the persisted incident instant rather than an uncommitted attempt’s instant or the no-op transaction’s timestamp.

   The current passing gates do not establish this interaction. The absence of this additional runtime case does not itself contradict the unchanged base.

The required unpiped gate command exited **0 initially and 0 finally**, on an exact pinned snapshot under my permitted temporary directory. The reviewed clone remains clean at the pin. No adoption, tracker change, PR action, or follow-on work was performed.