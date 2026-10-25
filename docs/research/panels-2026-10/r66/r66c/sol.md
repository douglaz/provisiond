**Q1 — Reason in place of items 1–5**

I cannot give a sound **engine-local** check for the unrestricted restore contract as written. A remembered watermark can detect a rewind past something the engine observed. It cannot establish that no unobserved state was lost. PostgreSQL recovery indicators can narrow that gap for particular restore methods, but the specification does not restrict restores to those methods.

This is a limit of the present observation boundary, not a claim that application-enforced rollback protection is impossible with a broader architecture.

Consider this trace:

1. E completes startup. Its generation is g; any remembered store watermark is n. Take backup B.
2. Pause E before its next store observation.
3. An API transaction extends a machine’s runway. Even if that transaction increments a store-wide counter, E has not observed the new counter.
4. Restore B. Before the restore-record transaction commits, the store again contains g, n and the earlier runway.
5. Resume E. Its remembered generation and watermark match. The restore-record read finds no open incident. E can make a claim or cancellation-fence write into the rewound state.

The lost API write matters here. Appendix `OPS-50` explicitly says, “Writes made in the api process are not checked.” Comparing a restored counter with E’s last observation therefore does not establish continuity of the store.

The normal counterpart is E resuming against B’s unchanged state, without the intervening extension and restore. The proposed generation, watermark and restore-marker observations are the same. Refusing that counterpart would also refuse ordinary work.

The candidate mechanisms have these limits:

- **A monotonic watermark:** a separate ordered counter would reopen Appendix `STO-59`’s choice, “It is not a counter and is never compared for order.” Updating it on every engine transaction still misses the API trace above. Updating it on every store transaction does not help unless E learns about those transactions through a protocol that cannot miss their effects before a restore.
- **An externally held restore epoch:** this works only if something necessarily changes it before the survivor can write. An epoch assigned by the restore procedure repeats the original omission problem: before that assignment, or if it is omitted, the old value still passes. Moving the value outside the backup does not itself supply that necessary event.
- **Reading the restore record in every transaction:** before its transaction commits, the new record is absent. That is also the ordinary state outside an incident. Rejecting every transaction with no open record would reject normal operation.

PostgreSQL does provide useful method-specific evidence. Its archive-recovery procedure says, “Stop the server, if it's running,” and its timeline description says, “Whenever an archive recovery completes, a new timeline is created.” Those statements concern physical archive recovery. They do not establish a universal restore identifier. [PostgreSQL 18: continuous archiving](https://www.postgresql.org/docs/18/continuous-archiving.html)

For logical restoration, `pg_restore` “connects to that database and restores archive contents directly into the database”; with `--data-only`, “Table data, large objects, and sequence values are restored”. From that documented SQL restoration path, I infer that a restore need not restart the destination server or terminate an otherwise idle advisory-lock session. A server-restart or archive-timeline test therefore needs an explicit restriction on supported restore methods. [PostgreSQL 18: pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html)

A synchronous witness outside the restored state, involved in every relevant writer’s commit protocol, could change the conclusion. That would need API participation, defined handling of uncertain commits, and a restore-method contract explaining when the witness becomes authoritative. I would rate that architecture **large**: it changes write coordination and failure handling, rather than adding a comparison. `ADR-0019`’s rejected cost—“keeps a column, a counter and a guard term alive to do it”—would substantially understate it.

The required boundary answers are:

- **Physical in-place restore:** R can detect the lost lock connection and begin recording stops. Without a changed generation or another reliable observation, those record transactions can still match the restored g before the restore record commits.
- **Another server behind the same address:** as stipulated in the brief, while both databases remain writable this is outside F7’s “one writable database history” guarantee. If the old database has instead ceased to be writable, the remaining writable restored database still needs protection; F7’s exclusion cannot establish continuity there.
- **Trace (b):** a survivor with no worker need send no write. Its non-zero exit is a valid outcome; a conformance assertion must not require a nonexistent “next write”.
- **Trace (c):** restoring bytes and choosing a new generation must be distinguished. The current “written twice” formulation should be reworded.
- **Promotion classified as a restore:** keep the existing stop rule. `STO-54` says, “Before any component connects to the promoted store, the deployment MUST stop every engine and `api` process that was connected to the old primary”. Nothing in the engine-local proposals above replaces that rule.
- **Surviving API:** G supplies no protection for its writes. A barrier through the record’s commit also does not itself make a surviving API process rerun startup or satisfy the remaining restore procedure.

My `CNF-370` is **F3 unchanged**. Its held worker makes a record write reachable, and its controlled admission places that write after the fresh generation commits. A conforming G implementation can pass it. It supplies no evidence for refusal before that commit.

For the separate freshness ambiguity, I would make this exact repair relative to Appendix `STO-59`:

> **Before, heading:** “the startup generation is one row, and no value is written to it twice.”
>
> **After:** “the startup generation is one row, and generation choices are fresh.”
>
> **Before:** “A value MUST NOT be written to the row twice, including across a restore from backup:”
>
> **After:** “Every startup advance and restore-record transaction MUST choose a random UUID distinct from the values chosen by earlier startup advances and restore-record transactions, including choices whose effects a restore removed. Reinstating a backed-up value is not a new generation choice.”

The following restore-transaction explanation remains. Apply the same distinction to the Appendix’s `CONTEXT.md` entry, replacing “never written twice” with “freshly chosen by each startup advance and restore-record transaction”. This repairs terminology; it does not close the window.

Misconfiguration remains consequential. Omitting the restore record or its fresh generation can leave equality passing indefinitely. An older backup is rejected when its generation differs, but a backup from the survivor’s own generation can match despite lost API work. Wall-clock correctness does not repair that missing observation. A backup containing a different generation is refused regardless of its nominal age.

**6. Deployment barrier**

**Still needed under the current contract.** I select Reader Z’s text:

> “Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process that survived the restore, from using the restored store.”

This closes the particular pre-record access interval for both components. It does not replace the promotion stop rule, the restore procedure, or the need to make a surviving API process obey that procedure before service resumes. It also does not revoke provider calls already licensed before the fence changed.

**Q2 — F1–F9**

- **F1: ACCEPT.** The original `OPS-21` opening names “bounded abandonment and later-stop exits”; its after-return sentence lists the bound, later-stop, exhaustion and lost-reply cases. Adding the superseded exit to both, and to `CNF-362`’s quotation, makes the closed lists agree with Appendix `OPS-50`: “A refused generation check ends recording without another attempt”.
- **F2: ACCEPT.** “Within its Stop-record bound, subject to its exits” accurately preserves both the duration and the permitted exits. It does not change R’s treatment of an already pending record.
- **F3: ACCEPT.** The fixture supplies an in-flight worker, keeps the bounds from ending the record during the controlled interval, and admits the survivor after the restore-record transaction commits. Its distinctness assertion concerns advances and restore-record transactions, avoiding the original assertion about every physical reinstatement of a value. The remaining `STO-59` ambiguity needs the separate repair above.
- **F4: ACCEPT.** `generationCheck : Bool` supplies the switch required by `ADR-0025`: “Every guard that a dated amendment added is a parameter of the model that carries it”. The named on/off theorem pair addresses that obligation. This acceptance concerns the proposed model contract; no proof was built or verified.
- **F5: ACCEPT.** The option continues through `ADR-0019`:81. Its rejection expressly includes “keeps a column, a counter and a guard term alive to do it”. The new note and ADR wording correctly remove “only on scope” and place the note after the complete option.
- **F6: ACCEPT.** The replacement removes the false exclusion. Span 12 already allows the late write to be refused by `OPS-50` “once the generation has moved”. Pointing to dedicated drills makes no contradictory claim about what `CNF-290` exercises.
- **F7: ACCEPT.** “Its guarantee covers one writable database history” states G’s actual boundary without attributing a general two-copy prohibition to the promotion-specific quotation. It does not claim protection against a rewind within that boundary.
- **F8: ACCEPT.** The retained quotation, “a deployment obligation”, occurs in the amended `OPS-47`. The removed portion would no longer occur there after span 1.
- **F9: ACCEPT.** The dated note makes the historical quotation’s status explicit. It does not remove the surrounding modelling rule that external assumptions appear as hypotheses or the requirement to state a model’s omissions.

**Contradictions: none found among the F-items, or between their resulting text and the applicable Appendix/repository provisions.** F3’s controlled post-record fixture is compatible with the unresolved pre-record window. Acceptance of that fixture does not endorse a deployment barrier.

**Q3 — Dropped transition clause**

**None found beyond D1–D4.** I searched the root requirements, README, glossary, relevant ADRs and formal claim/stop-record text for `STO-13`, rollback, previous-release binaries, unchecked engines, the withdrawn epoch, and the proposed G identifiers.

The repository’s general migration rule remains independent:

> “Rollback is the previous binary against the current schema”.

The existing about-to-order backfill also independently says:

> “rollback past this release is inadmissible.”

Neither sentence depends on a transition from an engine lacking `OPS-50`; neither should be stripped with D1.

**D4: nothing.** Omit that sentence from `ADR-0047`. It is consistent with the owner’s answer, and README’s introductory history describes the reference implementation as “unbuilt, untested”. But the absence of an earlier product build need not become part of G’s enduring safety argument. The initial conforming implementation simply includes the check.

**Brief errors**

1. **“Nothing makes a surviving E read it again” is too broad.** `OPS-41` already says:

   > “A worker claiming **any** exposure-reducing cancellation MUST read the restore record (`STO-56`) at each such claim”.

   See [OPS-41](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/03-operation-lifecycle.md#L949). This does not close the window: before the record commits, that reread can still find no open incident. It also does not perform the startup procedure.

2. **“An in-place restore kills the lock connection” needs a physical-restore qualification.** The documented logical restoration path described above operates against a running destination database. “Physical in-place restore that shuts down PostgreSQL” supports the connection-loss premise; “in-place restore” generally does not.

The checked repository quotations and identifier reservations otherwise matched `d78085a`. The Appendix’s scope-only description of `ADR-0019` is already corrected by F5.

No tracked files changed. No gates or Lean commands ran.