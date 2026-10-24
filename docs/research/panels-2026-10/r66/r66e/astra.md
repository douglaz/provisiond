## 1. ACCEPT

I **ACCEPT** the combined Form R and Fence G text against `d78085a89edfaa09d012bc6c8bc4ef94edd360ec`, under the stated acceptance gate. I found no conforming trace that admits a stale database write, wrongly refuses a current generation’s write, or breaks an otherwise-preserved MUST, conformance assertion, or theorem. There is one non-blocking documentation contradiction, described below.

The critical interleaving is closed by the combination of checking and holding the lock. `OPS-50` requires the transaction to read the generation “`FOR SHARE` as its first statement” and “hold that lock until it commits.” A transaction that passes before the advance therefore finishes before that advance can commit. A transaction checking afterward encounters the new value and cannot write under the old one. PostgreSQL documents both necessary facts: “A shared lock blocks other transactions from performing `UPDATE`” and “Row-level locks are released at transaction end.” [PostgreSQL 18, §13.3.2](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS)

The separate advance transaction also matters. The proposed `OPS-15` requires its commit to be acknowledged before “any other write transaction, the remainder of the pass, or any worker or periodic component.” Consequently, the sweep cannot take its snapshot before the earlier transactions that blocked the advance have finished. A timeout does not authorize a partially started successor: the required outcome is exit “having claimed nothing.” A lost advance-commit reply likewise prevents the engine from proceeding, even if the database committed the replacement.

The timeout explanation checks out. PostgreSQL says the lock timeout’s “time limit applies separately to each lock acquisition attempt”; the accompanying statement timeout bounds the replacing statement as a whole. The positive-duration amendment excludes the documented disabling value: “A value of zero (the default) disables the timeout.” [PostgreSQL 18, §19.11.1](https://www.postgresql.org/docs/18/runtime-config-client.html)

Form R resolves the bead’s ambiguity without disguising lock loss as supersession. Its decisive sentence is: “The loss is not a later stop.” With the generation unchanged, an already-pending record continues under its existing bound. A worker without a pending record receives the originating stop, with the stated cancellation, absorbed-read and parent-defer rules. `CNF-366` makes this distinction observable by refusing transactions until loss detection and then allowing them to succeed with time remaining. An implementation that immediately abandons the pending record cannot satisfy that drill.

The combined case is also coherent. Suppose a record attempt commits but loses its reply; the lock connection then disappears; a successor advances the generation before the original engine repeats. The new sentence explicitly allows the correct result: “A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost.” The original engine exits without demanding another write or treating refusal as proof that the earlier attempt rolled back. Span 23 adds the superseded exit to both relevant lists and updates their conformance quotation.

The proposed `StopRecord` change follows that distinction: lock loss is an originating stop or no new event, whereas `superseded` is a recording exit. Adding its disjunct to `finished_unrecorded_exit` states the newly permitted abandonment rather than silently claiming the old conclusion still holds. Retaining `exit_store`’s lost-reply alternative is necessary and is expressly required.

I accept the owner’s restore boundary. Span 26 says the deployment “MUST stop every engine and `api` process” before restoring and must await acknowledgment of the restore-record transaction before restarting either component. A surviving-process trace violates that premise. `CNF-370` now tests the supported procedure and the fresh choices; it does not purport to demonstrate protection during an unsupported online restore.

**Non-blocking defect — an omitted summary amendment.** The unchanged executive summary says “nothing refuses its writes.” That is false after G. It changes no checked verdict: the sentence is explanatory prose, and the operative requirements and drills specify the refusal. It should nevertheless be corrected in the Run.

Replace the passage beginning “**Two engines are out of scope and the set says so**” and ending with its `ADR-0019` citation with:

> For the single-engine deployment obligation, see `OPS-47`; for startup-generation fencing and its limits, see `OPS-50` and `STO-59` (`ADR-0047`).

## 2. Contradictions

**Yes: the executive summary retains an unqualified statement that contradicts G.**

The combined text, span 1:

> “Where two engines run, no write of the first commits once the second’s startup pass has committed a new `STO-59` generation (`OPS-50`)”

The surrounding text at [`executive-summary.md:250`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/executive-summary.md#L250):

> “**Two engines are out of scope and the set says so** (`OPS-47`): a startup lock refuses the second one’s *boot*, and nothing refuses its writes, because the epoch that claimed to was comparing a value against itself (`ADR-0019`).”

The contradiction is specifically “nothing refuses its writes.” Retaining the deployment’s single-engine obligation is compatible with adding a defense against a superseded engine. The replacement above removes the obsolete universal and leaves the rule and its limits with their owners.

I found no additional unresolved normative contradiction. The old no-fence statements targeted by the supplied spans are explicitly replaced or annotated. Likewise, the proposed weakening of `finished_unrecorded_exit` is disclosed, rather than hidden behind `ADR-0044`’s historical statement, “No existing theorem is weakened” ([line 95](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/docs/adr/0044-a-survived-stop-records-execute-within-a-bound.md#L95)).

## Brief errors

No demonstrably false repository quotation or anchor was found. A whitespace-normalized literal check found the supplied before-text and anchors in their named files. The HEAD, bead description, restore-record ordering, `steps_completed` range, and cited PostgreSQL passages also match the brief.

The executive-summary omission is an amendment-coverage defect, not an inaccurate quotation in the brief.

I could not independently corroborate the earlier panel votes or the r65b attribution: `rg --files docs/research/panels-2026-10 | rg 'r65|r66'` returned no paths. I did not rely on those historical claims for acceptance; their absence here does not establish that they are false.

No gates or `lake` were run, and no tracked files were changed. This verdict reviews the proposed text and its traces; it does not certify the unbuilt Lean amendments.