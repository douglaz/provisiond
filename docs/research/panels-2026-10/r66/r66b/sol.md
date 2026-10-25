Reviewed the r66b merged proposal against `d78085a`: **FAIL for G; PASS for R.**

**Q1. CANNOT ACCEPT — one blocker: restore access precedes the fence.**

The proposed `STO-54` sentence says:

> “The transaction that commits that record MUST also write a fresh `STO-59` startup generation”

Its existing ordering condition is only “before either component is started”. That does not exclude access by the engine `CNF-370` explicitly keeps running.

Concrete trace:

1. Engine E holds generation `g`; the backup contains `g` and a running operation under E’s claim number.
2. Restore makes that database reachable. No new component has started, but the restore-record/fresh-generation transaction has not committed.
3. E reconnects, passes `STO-7`’s standby-position check, reads `g FOR SHARE`, and commits its pending settlement. Both its generation and worker guards pass.
4. The restore then commits the record and generation `h`, before starting either component.

E obeys `OPS-50`, yet `CNF-370`’s assertion that “the survivor’s next write is refused” fails. Requiring refusal at step 3 would reject a matching-generation write before any advance.

**Gate met:** a conforming engine can fail `CNF-370`. The record-transaction anchor needs an access barrier for surviving processes.

Replace only span 19’s added sentence with:

> The transaction that commits that record MUST also write a fresh `STO-59` startup generation. Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process that survived the restore, from using the restored store.

I therefore contest the completeness of the B3/B5 combination: the transaction anchor and surviving-engine fixture need this ordering. I found no other blocking counterexample to a **[took]** choice.

Other requested checks:

- **Write coverage:** `OPS-50`’s “every write transaction made in the engine process” closes the scope independently of its examples. I found no escaping engine writer.
- **Conformance:** no conforming-engine failure established for `CNF-367`, `CNF-368`, or `CNF-369` under their stated fixtures. `CNF-370` has the defect above.
- **Ids:** the proposed allocations agree with the definitions in `03-operation-lifecycle.md`, `05-persistence.md`, `10-conformance-checklist.md`, and `docs/adr/`. No additional missing behavior owner found.
- **Pointer-only list:** the proposed `CONTEXT.md` explanation of why the generation differs from the withdrawn epoch is rationale, rather than merely a pointer. Keep that argument in `ADR-0047`; this is non-blocking.
- **Nonreuse:** `STO-59` explicitly prohibits reuse, so a collision is a specification violation, not a conforming stale-write trace. But the named generator does not establish that obligation: PostgreSQL describes it only as “Generates a version 4 (random) UUID”. The formal argument must expose freshness as an assumption rather than claim to prove it from that function. [PostgreSQL UUID functions](https://www.postgresql.org/docs/18/functions-uuid.html)

**Lean names:** the cited existing declarations are present. Placing refusal at `Claim.engineStep`, outside `workerGuard`, preserves the distinction from `zeroRows`. When extending its inputs, retain `lost_claim_reply_exits` for the matching-generation case and account explicitly for refusal before a claim is sent. `superseded_never_commits` needs the stated guard witness pair and freshness boundary. The proposed `StopRecord` changes correctly preserve earlier lost-reply commits through `exit_store`; the new `finished_unrecorded_exit` disjunct is an expressly acknowledged weakening. These are textual assessments, not checked proofs.

**Q2. ACCEPT R as merged.**

No contradiction established with G or the surrounding requirements.

R says:

> “a record already pending when the loss is seen continues under its own Stop-record bound and exits.”

G says:

> “A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost.”

R’s new `OPS-21` paragraph quotes that exception explicitly. Thus lock loss alone preserves recording, while a subsequent generation mismatch ends it.

`CNF-366` keeps the generation unchanged, anchors its admission assertions to detection, and supplies sufficient remaining time under both bounds for its successful-record cases. Its absorbed-read and parent assertions follow the corresponding `CNF-362` cases. I found no detection-related MUST that its prescribed behavior breaks.

**Q3. (B).**

Deciding trace: newer E loses its lock unnoticed while retaining generation `g`; rollback starts an unchecked older engine, which neither advances nor checks the generation. E continues matching `g`, and both engines can write.

B preserves the newly adopted boundary across deployment changes. I accept its stated cost: recovery from a bad first release may require restore rather than redeploying the previous binary. Preventing old-engine reconnection must be enforced by deployment or connection admission; the old binary’s schema check cannot supply it, because `STO-13` requires it to serve a newer schema.

**Brief errors:** none verified in the quoted existing text or next-id claims. The r65/r66 reader attributions and tallies are absent from this revision; I did not rely on them.

No files changed; no gates or `lake` commands run.