## 1. Objection

**I concede Option 3’s restart and recording cost.** Its separate witness preserves Form R when only the startup-lock connection fails. It cannot preserve that behaviour through a full PostgreSQL restart.

Concrete trace: a create has returned success; its settlement attempts have committed nothing; PostgreSQL stops and starts without restoring anything. The witness disappears. Option 3 says, “This exit ends any pending stop record without another attempt.” The surviving engine therefore cannot record the success it still remembers. At engine restart, the still-`running` create with its order marker set reaches `needs_reconciliation`. That is a real loss relative to R alone.

The separation nevertheless matters. Terminate only the startup-lock backend, leaving the witness alive: R continues recording within its bounds. Option 3’s `CNF-366` amendment explicitly says, “Keep the store-session witness alive and its signature present throughout these cases.” The original bead’s settlement outcome remains reachable in that fixture.

I also concede the connection, inspection and additional failure-path costs. PostgreSQL confirms that session advisory locks are “held until explicitly released or the session ends.” A witness-only connection failure therefore causes an exit even when the database contents remain sound. [PostgreSQL advisory locks](https://www.postgresql.org/docs/18/explicit-locking.html#ADVISORY-LOCKS)

The performance objection is supported, but its magnitude is unmeasured: PostgreSQL says inspecting `pg_locks` “could have some impact on database performance if this view is very frequently accessed.” I cannot turn that warning into either a demonstrated throughput problem or a claim that the cost is negligible. [PostgreSQL `pg_locks`](https://www.postgresql.org/docs/18/view-pg-locks.html)

## 2. Vote

**Option 3, exactly as supplied**, including its introductory instruction to append Reader Z’s sentence to span 19. No hybrid and no omitted amendments.

I retain this vote because the witness tests something the restored data cannot reproduce: the engine’s original live session. Its rule that the check and licensed transaction use “the same uninterrupted PostgreSQL backend” makes the physical-restore and server-switch arguments concrete.

Option 1 is substantially simpler, and S2’s protection of surviving `api` writers is an advantage. However, its unconditional identification of a server incarnation with a timestamp is stronger than the cited documentation supports; the counterexample appears under Brief errors. Option 3 also detects a logical restore that destroys the witness session while leaving the postmaster running. Option 1 explicitly leaves that case to deployment control.

Option 2’s own exception is decisive: “An engine that acknowledged no write after the backup” can continue. An API extension followed by a restore can erase safety-relevant state without changing anything the idle engine remembers. Adding an engine write chain does not distinguish that history.

Option 4 supplies the necessary operating rule but no application refusal before the incident transaction. Its misconfigured, record-skipped execution is precisely the owner’s concern.

Option 3 does not eliminate that concern universally. Its scope expressly says it “does not detect a logical overwrite of the same database while that session and its advisory locks survive” and “does not check writes made in `api`.” I accept those stated limits alongside the deployment rule. I am voting for the witness’s specific additional enforcement, not claiming complete restore detection.

## 3. ACCEPT / CANNOT ACCEPT

**ACCEPT Option 3 over the Base and both Appendices.** I found no blocking defect in that combined text. This is a specification verdict; no gates or Lean commands were run, and no tracked files were changed.

The relevant executions remain distinguishable:

- **Physical restore before the incident record:** the original witness is gone. Detection of connection loss exits the engine; if detection has not arrived, the checked transaction finds no signature and rolls back. Restoring generation `g` does not restore the witness.
- **Restored server behind the same address:** the old witness may remain alive on the original server. The check nevertheless runs on the backend executing the transaction. A transaction reaching the restored server finds no matching witness there. Writes remaining on the original server are outside F7’s expressly limited “one writable database history.”
- **Logical reload preserving the witness:** the application check alone admits the survivor before the generation changes. The included deployment sentence owns this residual: “Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process that survived the restore, from using the restored store.”
- **Ordinary replacement of a pooled connection:** the dedicated witness remains present, so replacing that connection does not itself refuse a valid write.

The revised `CNF-370` deliberately preserves both dedicated sessions and delays pooled transactions until the incident transaction is acknowledged. Consequently, its refusal still exercises G’s generation comparison. It does not become a test that passes merely because witness loss exited the engine first. Conversely, `CNF-371` withholds the incident transaction and preserves the backed-up generation, making the witness responsible for refusal.

The recording change is explicit. Option 3 extends both `OPS-21` exit lists and the `CNF-362` quotation, and its ADR says, “The formal stop-record conclusion gains a store-session-loss disjunct in addition to Fence G’s superseded disjunct.” I accept that declared weakening of [`finished_unrecorded_exit`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/tools/formal/Provisiond/StopRecord.lean#L395). This is not a claim that the existing theorem already proves the amended behaviour.

The sent-transaction exception remains essential: “A transaction already sent retains its server-decided fate, including a commit whose reply was lost.” Acceptance therefore does not require undoing committed money or treating an unobserved acknowledgement as proof that nothing committed.

## Brief errors

**1. Option 1’s unconditional server-incarnation claim is unsupported.** Its text concludes that a survivor holds “an instant the restored server does not report,” and the table consequently promises refusal in shapes 1 and 2. PostgreSQL documents only: “Returns the time when the server started.” It does not promise uniqueness across servers or successive starts. [System information functions](https://www.postgresql.org/docs/18/functions-info.html)

Counterexample permitted by the proposed text: E remembers `(g, t)`; a backup contains `g`; a restored server starts with its clock reporting the same `t`; the incident transaction is withheld. E’s next transaction compares `(g, t)` with `(g, t)` and passes. This is an inference from the comparison, not an experimentally reproduced PostgreSQL trace. The specification supplies no distinct-start-time prerequisite. Its existing [`API-53`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/04-api-contract.md#L1288) even acknowledges that clock reads “step backwards under NTP,” although that paragraph concerns operation revisions.

**2. The universal reconciliation outcome needs a lost-reply qualification.** The brief says the create-settle example ends `needs_reconciliation` and R loses that outcome “whenever” lock loss came from a full restart. That holds when no settlement committed. It does not hold when a prior attempt committed and lost its reply.

`rg -n -F 'the row is already written, the money already posted once' 03-operation-lifecycle.md` finds [`OPS-49`:1847](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/03-operation-lifecycle.md#L1847), followed by “the startup pass finds nothing `running` to classify.” A full restart without restore can refuse the retry while the create remains `succeeded`. This qualification does not rebut the genuine pending-record loss conceded above.

**3. Option 2’s “no model carries a restore” is false literally.** [`Restore.lean`](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/tools/formal/Provisiond/Restore.lean#L154) defines `RestoreTrace`; line 541 defines `bootRestore`. Its opening description explicitly models “a store `Δ` steps behind it with the provider’s facts unchanged.” The narrower defensible statement is that this model does not carry the proposed write-chain check or the live-survivor window.

**4. The r63 unanimity concerned omission, not one shared reason.** The brief describes the timeline read as rejected unanimously “because” it lagged promotion. The [`r63b tally`:25](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/docs/research/panels-2026-10/r63/r63b/tally.md#L25) attributes that reason to fable; opus cited “an unverified signal,” and astra and sol cited an unspecified observation. The unanimous outcome is accurately reported; the unanimous rationale is not.