I choose **D3 at CNF-302**, unchanged, and prefer **REPLACE** for Q2. KEEP remains acceptable. I found no verified brief error that changes either question’s premise under notes.md rule 6.

**Q1 — exact-form acceptability, separate from preference**

| Draft and proposed landing | Verdict | Required repair |
|---|---|---|
| D1; CNF-302 after its supersession paragraph | **CANNOT ACCEPT as printed** | Explicitly distinguish transaction timestamps and verify the first attempt’s noncommit before retrying. |
| D2; CNF-302 after its supersession paragraph | **ACCEPT** | None. |
| D3; CNF-302 after its supersession/lost-reply paragraph | **ACCEPT — preferred** | None. |
| D4; CNF-295 | **ACCEPT** | None. |

For D1, the exact repair I would require is to replace its opening failure-injection sentence with:

> Separately drive establishment for one actual restore with one retained id in each of two runs. In the first run, force the first establishment transaction to abort, lose its reply, and verify that the retained id is absent and none of its establishment effects committed before retrying. In the second run, let the first establishment transaction commit and lose its reply. Use establishment transactions whose observed `transaction_timestamp()` values differ, and make any pre-attempt captured instant distinct from the retry’s timestamp.

That is requested criticism and repair guidance, **not my final selected form**. D1’s comparison against an instant captured *before* the first attempt does not itself ensure that the first transaction’s timestamp differs from the retry’s. Without that distinction, an implementation reusing the aborted transaction’s timestamp could pass. Its transport wording also should not substitute for establishing noncommit. D2 explicitly supplies that outcome through “so that no record with the retained id exists”; I accept that as a fixture condition, not a general guarantee about disconnects.

My exact insertion point is in [CNF-302](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L3078), immediately after:

> A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks.

Insert before the table headed `Install case after successor pass`. Complete selected text, **D3 unchanged**:

```text
**Establishment retry clock.** Exercise the following cases for one actual restore per run, retaining the same new incident id N throughout its establishment retries. Run each case with no inherited open incident and with an inherited open predecessor R whose ordinary close conditions are unmet. Use establishment transactions whose observed `transaction_timestamp()` values differ.

In the first case, let the first establishment transaction have timestamp t1, force it to abort, and lose its reply. Verify that N is absent and none of its establishment effects committed. Retry in a newly begun transaction with timestamp t2. Assert that the committed N carries restore_instant=t2, not t1. Lose this transaction’s commit reply too. Keep both components stopped, repeat establishment in a transaction with timestamp t3, and assert a matching guarded no-op preserving t2, the predecessor, step marks, endpoint fields and history_evidence_ref. Acknowledge that repeat before either component starts.

In a separate case, let the first establishment transaction commit N at t1 and lose its reply. Repeat in a transaction with timestamp t2 and assert the same preservation and acknowledgement behavior, with restore_instant still t1.

Use null endpoint fields with retained unknown-endpoint reasons for the unknown-evidence runs. Repeat with certified upper-bound evidence using STO-54’s event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats. Assert no duplicate incident or additional supersession.
```

The concrete wrong results this catches are an aborted attempt’s `t1` surviving insertion at distinct `t2`; a committed incident being retimed to `t3` or refused solely because `t3` differs; and a matching repeat changing the recorded recovery state or creating another incident. Adopted B supplies the decisive words: “an instant selected for an earlier attempt that did not commit is not reused” and “a guarded no-op … preserving its step marks and original restore instant.”

D3 adds coverage, not another normative obligation or gate. Its additional fixtures have existing owners:

- **Clock and start prerequisites:** [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636) says “restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident” and “The transaction begins after the existing stopping/fencing requirements are satisfied.” Distinct observed timestamps are a test fixture, not a new production monotonic-clock guarantee.
- **Inherited predecessor:** [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1432) says “the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R in `supersedes_incident_id`”. D3’s predecessor runs exercise that existing transaction boundary.
- **Endpoint preservation:** [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1450) says “The endpoints and reference MUST be written with the row; continuations MUST NOT recompute them.” It also makes the reference “non-null even when both bounds are unknown.”
- **Unknown and certified evidence:** [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1660) says a verified event-clock upper error bound, with the specified retained stopping/fencing evidence, “can supply f=restore_instant+e_event”, and “If either endpoint cannot be certified, persist null for it and say that endpoint is unknown.”

The recipe runs deliberately exercise that permitted recipe; they do not require every deployment to derive its upper bound that way. Likewise, D2’s provenance assertion has an existing owner: [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1712) says the establishing transaction “MUST set this column `true` on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`”.

I find no substantive overreach in D2–D4 under these fixtures. Successful-start assertions must retain the existing prerequisites; they are not unconditional availability guarantees. D3 also selects no timestamp-comparison or predecessor-comparison algorithm.

**Q2 — preference and acceptability**

| Exact alternative | Verdict |
|---|---|
| KEEP: “finds no committed matching record” | **ACCEPT** |
| REPLACE: “finds no committed record with that id” | **ACCEPT — preferred** |

My separate judgments are **behaviour change NO; requirement change NO; check-strength change NO**. These concern the operative obligations read together, not whether the textual wording changes.

The relevant traces are:

| Trace | KEEP, read with B’s other clauses | REPLACE |
|---|---|---|
| First attempt aborts; N absent; retry starts at distinct `t2` | Insert N using the inserting transaction’s instant. | Same. |
| N committed at `t1`; otherwise matching repeat starts at distinct `t2` | Preserve `t1` and step marks through the matching no-op. | Same. |
| Committed N has an actually incompatible restore-instant or predecessor assertion | Refuse with both components stopped. | Same. |

The refusal remains explicit in both alternatives:

> A mismatch in the committed id's restore instant or predecessor MUST be refused with both components stopped.

The matching-repeat duty also remains:

> Repeating establishment with that id when a committed matching record exists MUST affect that record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant.

Consequently, replacing the insertion condition does not authorize accepting an incompatible record. Nor does either alternative authorize comparing a no-op transaction’s new timestamp against the stored instant as though the no-op inserted the incident: STO-54’s quoted definition applies to the transaction “inserting this incident.”

The original phrase protects the boundary between insertion and preservation of an existing matching incident. REPLACE retains that protection while making the insertion condition explicitly about absence of the retained id. The preserved refusal clause continues to protect against incompatible reuse.

The historical full-payload interpretation would make “no committed matching record” true even when N exists with an incompatible predecessor, creating the alleged insert/refuse overlap. The supplied checked verdict establishes that interpretation as a **conditional ambiguity**, not an unavoidable obligation. I therefore prefer removing the ambiguity without claiming a verified normative or conformance verdict changes. No lost check, weakened guard, theorem change or collateral flip is identified.

Verification and procedural disclosure: both unpiped gate invocations exited **0**, and final tracked/index diffs were empty. However, my initial invocation generated ignored Lean artifacts in the reader clone, violating the temporary-file restriction; the final invocation used the permitted temporary directory. A broad process listing also surfaced unrelated process arguments, which I excluded from the analysis. Neither deviation is a brief error or a basis for a rule-6 void finding.

Final Q1: D3; CNF-302; immediately after “A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks.” and before the install-case table  
Final Q2: REPLACE; behaviour change NO; requirement change NO; check-strength change NO