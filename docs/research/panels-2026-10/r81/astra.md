**Final pick: B. Printed A: ACCEPT. Printed B: ACCEPT.** These are acceptances of exact proposed policy amendments, not findings that either is merely editorial or already authorized.

**1. The conflict at c824e4f is real.** PostgreSQL 18 defines `transaction_timestamp()` as equivalent to `CURRENT_TIMESTAMP`, whose value comes from the current transaction’s start and remains fixed within that transaction. A subsequent transaction can have a different timestamp. [Official PostgreSQL documentation](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT)

At [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1442), the operator “MUST select and retain one new incident id and restore instant per actual restore before attempting establishment, and reuse both on a lost-reply retry.” At [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636), “restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident.”

The traces separate as follows:

| First transaction | Later establishment using N |
|---|---|
| Aborts; no committed N | Retaining selected `t1` satisfies the retry requirement. Inserting at transaction timestamp `t2 ≠ t1` requires `t2`. Neither value satisfies both obligations. |
| Commits a compliant N at `t1`; reply lost | The repeat finds N and preserves `t1`. It performs no new insertion, so its own transaction timestamp does not redefine N’s event. Acknowledging the matching no-op permits startup. |

Selecting an instant does **not** itself prove equality with PostgreSQL’s first transaction timestamp. The contradiction survives even if we grant that equality for the first attempt. Conversely, claiming that every committed-record retry must stamp its new transaction time—or derive its expected predecessor from today’s open row—adds unsupported premises.

I verified that the event paragraph is unchanged from `7974839`, and that the landed supersession/retry paragraphs match printed P/C5 after formatting normalization. This is not an Implementer departure. The archived tally’s “An uncommitted first attempt instead establishes N once” addresses multiplicity without deciding which instant that insertion carries.

**Rule 6:** I found no verified brief error changing this question’s premise; there is no basis to void its tally.

**2. Both exact forms are acceptable; I prefer B.**

A1 explicitly chooses the selection event, including on a successful first attempt. A2 consistently moves the upper-bound recipe’s clock and stopping/fencing evidence to that event. A3–A8 synchronize the formal documentation; A9 records the departure from UO’s inserting-transaction definition. Together with the retained STO-56 paragraphs, they supply a coherent retained-instant policy. I found no additional mandatory replacement.

B’s complete paragraph supplies the missing distinction: absence permits insertion using the inserting transaction’s event; an existing committed record requires a guarded no-op. I prefer its precise database event anchor and preservation of the existing reporting recipe.

B’s surviving requirement—“A mismatch in the committed id’s restore instant or predecessor MUST be refused”—is coherent with the matching-repeat obligation. A genuine incompatible request must be refused; the mere existence of a later transaction is not such a mismatch. The expected-value comparison mechanics remain unspecified, as in the archived dissent. That limitation does not establish a contradictory obligation, and accepting B does not select R2 or invent a predecessor algorithm.

**Requested counterargument:** B relinquishes part of the expressly adopted P policy: “reuse both on a lost-reply retry.” A preserves a stable event across every attempt, including unsuccessful ones. With accurate clocks and suitable certificates, A can also produce an earlier, tighter reporting upper bound. Choosing B therefore requires acknowledging a substantive qualification of P, not presenting it as faithful reapplication.

**3. Behavior, requirements and check strength change differently.**

The replaced definition protected a precise relationship between the stored instant and the transaction that establishes the durable incident. The retained-instant requirement protected one event value across establishment attempts. When those events differ, both protections cannot remain intact.

Under A, selection at 100 followed by successful insertion at 200 persists 100. That deliberately loses the inserting-transaction equality. Under B, an aborted attempt at 100 followed by insertion at 200 persists 200. That deliberately loses precommit same-instant retention. Both preserve the committed record’s instant on a matching repeat.

Reporting can consequently differ without either report being false. With accurate clocks, valid evidence, lower bound 50, and no old-history acknowledgements after 100, the respective event-based upper bounds could be 100 and 200. B’s interval is wider although recovered history is identical. Clock evidence available for one event need not certify the other.

The collateral checks are:

- **Stopping/fencing and startup:** STO-54 requires “the deployment MUST stop every engine and `api` process” before restore and “MUST start neither component” before acknowledgement. Both forms retain that boundary. A additionally places selection after the existing stopping/fencing requirements and before establishment; it supplies no route to start early.
- **Certificate truth:** STO-54 retains “A non-null f MUST certify that no component acknowledged an old-history commit after f.” A2 changes the event to which the supporting clock and stopping evidence must apply; it does not waive that certificate. The lower-bound recipe and its inclusion obligation remain unchanged.
- **Unknown evidence:** STO-54 retains “A bound without valid evidence is unknown, not an invented recovery time” and “Missing reporting evidence does not hold incident creation.” An unavailable certificate produces an unknown endpoint under either policy.
- **Endpoint reuse:** STO-56 retains “The endpoints and reference MUST be written with the row; continuations MUST NOT recompute them.” After an aborted insertion there is no persisted endpoint to preserve. After a committed insertion, a later retry cannot replace endpoints or evidence merely because its transaction has a different clock.
- **Marker provenance and supersession:** STO-54’s establishment transaction “MUST set this column `true`” on the specified surviving operations. STO-56’s atomic supersession retains R and establishes N, and “no predecessor step mark satisfies a new step.” An abort commits none of those effects; successful establishment commits them together; a matching repeat adds no second supersession or provenance initialization.
- **Step marks, grace and continuation:** STO-54 retains “A marked step does not run again.” STO-56 still writes grace “as step (3)’s instant plus one re-derivation interval.” Neither clock choice moves that anchor, resets completed steps, changes ordinary close conditions, or turns an ordinary process successor into another actual restore.

The complete evidence-consumer inventory printed in the brief needs no replacement for either form. Its unknown-endpoint fixtures remain valid. Its certified-bound cases still require actual certification. In particular, CNF-295 requires grace to use “its own event, not b, f or restore_instant.” OVR-19’s generic evidence/provenance rows accommodate either event. WIR-9a’s provenance rendering has no event-clock dependency.

For **check strength**, neither printed form changes an existing conformance assertion, Lean declaration, theorem, guard hypothesis or negative control. In [Restore.lean](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L156), `now` is an arbitrary `Nat`; establishment transactions and their failures are absent. `RestoreTrace.store` assigns it to the record, `afterCrash` retrieves the persisted instant, and `completeProcedure` supplies the independent grace instant. A changes the interpretation documented for that input without requiring a changed declaration. This is consistent with ADR-0025’s “Authority is per clause.”

Thus A’s formal-documentation synchronization is editorial **relative to A’s substantive policy amendment**; it does not make the whole amendment editorial. B’s qualification is likewise substantive. No existing checked verdict was found changed, unreachable or vacuous.

E-KEEP’s source-clock recipe remains intact. Neither form imports a precision policy into it. The pv-kwuf input decision concerns the **Startup-lock wait bound**; neither option changes that setting, timeout serialization or timestamp precision.

**4. Separate CNF/gate answer: YES to a new CNF case; no new specification gate proposed.**

This is independent of both acceptance votes. The concrete failures are retaining an aborted attempt’s timestamp under B, rewriting an already committed timestamp on retry, and rewriting its reporting evidence. Existing gate success does not detect those interactions; the missing case is not itself a contradiction in the unchanged base.

For **B**, append the following to CNF-302 in `10-conformance-checklist.md`, after its supersession/lost-transaction-reply paragraph:

> **Establishment retry clock.** Exercise the following cases for one actual restore per run, retaining the same new incident id N throughout its establishment retries. Run each case with no inherited open incident and with an inherited open predecessor R whose ordinary close conditions are unmet. Use establishment transactions whose observed `transaction_timestamp()` values differ.
>
> In the first case, let the first establishment transaction have timestamp t1, force it to abort, and lose its reply. Verify that N is absent and none of its establishment effects committed. Retry in a newly begun transaction with timestamp t2. Assert that the committed N carries restore_instant=t2, not t1. Lose this transaction’s commit reply too. Keep both components stopped, repeat establishment in a transaction with timestamp t3, and assert a matching guarded no-op preserving t2, the predecessor, step marks, endpoint fields and history_evidence_ref. Acknowledge that repeat before either component starts.
>
> In a separate case, let the first establishment transaction commit N at t1 and lose its reply. Repeat in a transaction with timestamp t2 and assert the same preservation and acknowledgement behavior, with restore_instant still t1.
>
> Use null endpoint fields with retained unknown-endpoint reasons for the unknown-evidence runs. Repeat with certified upper-bound evidence using STO-54’s event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats. Assert no duplicate incident or additional supersession.

Both required unpiped gate invocations exited **0**, using an unchanged export under `/var/tmp/provisiond-panel-r81/tmp/astra/`. The review clone remains clean at the exact pin. No amendment, tracker change, panel-record change or follow-on work was performed.