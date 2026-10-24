## 1. Objection

**I concede the objection.** Option 4 provides no application refusal before the restore-record transaction commits. If deployment admits a survivor early, it can write against rewound state; if the record is skipped, that exposure has no specified end.

A concrete trace is:

1. E advances the generation to g; the backup contains g and an exhausted machine.
2. An `api` transaction extends that machine’s runway. E observes neither that transaction nor any subsequent engine-write acknowledgement.
3. The backup is logically reloaded while E’s sessions survive.
4. Before the incident record commits, E reads g, claims a cancellation, reads no open restore record, and fences the machine using the restored commitment.

`OPS-41` says the worker “MUST read the restore record (`STO-56`) at each such claim”; an absent record supplies no warning. Its grace branch cannot protect this interval.

The PostgreSQL documentation supports the ingredients: `pg_restore` “restores archive contents directly into the database”, while a session advisory lock is “held until explicitly released or the session ends”. Preserving E’s sessions during the reload is the trace’s explicit condition. [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html), [advisory locks](https://www.postgresql.org/docs/18/explicit-locking.html#ADVISORY-LOCKS)

I also withdraw an unqualified reading of my earlier argument that **no application check is sound**. Options 1 and 3 offer useful detection of particular changes outside restored table contents. Option 2 can detect removal of an acknowledged engine write. Those are substantive protections.

My narrower argument survives: the observations these proposals check cannot distinguish every restore from permitted continued operation. In the logical-reload trace, the generation, server-start timestamp, session signature and remembered acknowledged chain row can all match their pre-restore values. None establishes that an unobserved API extension survived. A complete guard for that case needs another observation or control.

## 2. Vote

**Option 4, exactly as supplied, including its `STO-59` and glossary repairs. No hybrid.**

Its operative sentence is:

> Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process that survived the restore, from using the restored store.

That obligation must govern actual access, including surviving connections. Merely refraining from starting replacement processes would not satisfy “including a process that survived the restore”.

The owner’s preference for application enforcement counts against this choice. I nevertheless retain Option 4 because the alternatives’ remaining dependence on deployment must be weighed against their additional behavior and complexity.

Option 2 explicitly allows an engine that “acknowledged no write after the backup” to continue until the fresh generation commits. Without the deployment sentence, it admits the trace above.

Option 3 retains that sentence and acknowledges that its witness “does not detect a logical overwrite” preserving the session. It adds another connection, signature acquisition, transaction checks, connection accounting and an exit that “ends any pending stop record without another attempt”. Its extra detection is useful, but it does not replace the operational boundary.

Option 1 is smaller, and its S2 protects API writes against a changed start timestamp. However, its categorical coverage claim needs qualification, as described below. It also explicitly refuses stop records after an ordinary server stop and start.

That last cost matters to pv-buc. Consider its successful create with an uncommitted settle record, no successor engine, unchanged generation, and PostgreSQL returning within both recording bounds. Under R, “The loss is not a later stop”; the pending record can finish and preserve the outcome already known in memory. Option 4 preserves that result. Options 1 and 3 can force abandonment solely because the server restarted.

I do not treat their expressly specified restart cost as an accidental contradiction. It is a tradeoff. My vote gives greater weight to preserving R’s accepted behavior while keeping one complete access obligation for restoration.

## 3. ACCEPT / CANNOT ACCEPT

**ACCEPT Option 4 on top of the Base and both Appendices, read together.** I identify no blocking defect in that combined text and propose no replacement text.

The safety argument has distinct intervals:

- Before acknowledgement, the new deployment MUST prohibits the survivor’s access.
- After acknowledgement, span 19 has committed a fresh generation, and `OPS-50` requires comparison with the engine’s own startup value.

The first interval is operationally enforced. The second uses G. PostgreSQL documents that a “shared lock blocks other transactions from performing `UPDATE`”, supporting the ordering on which G’s generation replacement depends. [Row-level locks](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS)

The misconfigured trace in section 1 violates the new deployment MUST. It demonstrates a real failure mode and the absence of application mitigation, but it is not an execution admitted by the combined requirements. Calling it a conforming counterexample would erase the very sentence under review.

I accept F3’s `CNF-370` unchanged. Its assertion that the survivor’s next write “commits nothing” follows controlled admission after the restore has committed the record. It tests post-record refusal. It supplies no evidence that early admission is safe, and my acceptance makes no such claim.

The formal evidence must retain the same boundary. [`RestoreTrace.store`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/tools/formal/Provisiond/Restore.lean#L160) expressly constructs the restored store with its record already open:

> no run of the model has a window in which it is absent.

Consequently, those restore theorems cannot establish refusal during the pre-record window. Base F4’s parameterized generation check and its proposed on/off witness remain appropriate for G’s modeled comparison; they are not proof that deployment obeys the access restriction.

Option 4’s freshness repair also preserves the intended distinction. Reinstating backup bytes is not a new generation choice; startup advances and restore-record transactions must choose fresh values. This removes the apparent prohibition on restoring g without turning equality into ordering.

I ran no gate or `lake`, made no provider calls, and left the tracked files unchanged.

## Brief errors

1. **Option 1’s universal coverage exceeds its quoted PostgreSQL contract.** The brief says it covers shapes 1 and 2, and its draft says a survivor necessarily holds an instant “the restored server does not report”. PostgreSQL says only: “Returns the time when the server started.” It does not promise uniqueness across starts or servers. [System information functions](https://www.postgresql.org/docs/18/functions-info.html)

   As a counterexample, let the restored server report the same timestamp t as the original server, through equal clock readings on separate servers or a repeated reading after clock correction. The backup supplies g; E remembers `(g, t)`; the comparison passes before the record commits. This is an inference from the contract’s missing uniqueness guarantee, not a claim that ordinary restarts usually repeat timestamps. The brief’s unconditional “after any full PostgreSQL stop and start” refusal claim needs the same qualification for Option 1.

2. **Option 2’s ADR rationale, “no model carries a restore, so no theorem”, is false literally.** The clone contains [`structure RestoreTrace`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/tools/formal/Provisiond/Restore.lean#L154), `bootRestore`, and restore theorems. The narrower statement supported by inspection is that the existing models do not carry this surviving engine’s write-chain check across the pre-record window. The distinction matters: an omitted mechanism does not imply an absent restore model.

3. **The already-recorded quotation mismatch is confirmed.** [`05-persistence.md:1542`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/05-persistence.md#L1542) has “*Before the first claim:*”, including the colon inside the emphasis.

The r66b/r66c ballots, owner statements and earlier source-code observation are supplied history. Their underlying reports are absent from this clone, so I have not treated them as independently reverified facts.