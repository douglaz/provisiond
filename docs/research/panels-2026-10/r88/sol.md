**Final: C-UNKNOWN.** I prefer sending that exact printed form for the later owner scope/cost decision. I also accept C-WITNESS and NEITHER as written, for the distinct reasons below. This is technical acceptance, not authorization to adopt or spend.

I reviewed against **3109b5b44eae17e288cf52aaa976993bd8c5626c**, including the whole notes, supplied row and bead. I found no verified premise-changing brief error; notes.md rule 6 does not void this answer.

1. **Exact-form acceptance**

| Printed form | Verdict | Decisive reason and pinned evidence |
|---|---|---|
| **C-WITNESS** | **ACCEPT** | It supplies a substantive recording, validation and refusal contract rather than treating missing records as clean history. That addresses the audit’s distinction: “a missing record cannot mean the condition did not occur.” Its completeness obligations remain deployment obligations, not an established implementation. [Audit, C-WITNESS](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/docs/research/promotion-action-history-audit-2026-10.md#L681) |
| **C-UNKNOWN** | **ACCEPT** | Its predicate distinguishes known disqualification from failure to establish eligibility, and gives the latter an explicit automatic-refusal/operator-restore boundary. This handles the pinned paired trace: “Equal reports do not reveal which occurred.” [Audit, T-WAIT](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/docs/research/promotion-action-history-audit-2026-10.md#L374) |
| **NEITHER** | **ACCEPT** | The existing obligation is satisfiable with additional deployment knowledge or prevention; it promises no survivor-only classifier. The retained rule says a primary that “had a waiting backend cancelled or terminated” makes the promotion “a restore.” Retention leaves the evidence gap unresolved rather than contradicting that rule. [STO-54](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1663) |

My preference for C-UNKNOWN is that it specifies the decision under uncertainty without mandating C-WITNESS’s particular infrastructure obligations. That preference does not establish which option has the lowest total operational cost.

2. **Same surviving equal reports, different event and knowledge states**

Assume genuine common ancestry, equal durable reports, no open incident, and all unrelated restart conditions satisfied.

| Actual history and procedure knowledge | C-WITNESS / C-UNKNOWN | NEITHER |
|---|---|---|
| No relevant termination; complete trustworthy clean evidence available | Either equal standby may be promoted automatically as a restart. The clean positive control passes. | The existing clean/equal restart control passes. |
| Individually cancelled/terminated waiter; valid event evidence available | Known restore condition; no automatic promotion. Only an operator starts the restore. Recording does not permit the forbidden act. | Same existing restore classification and operator boundary. |
| Shutdown terminates a waiter; valid event evidence available | Known restore condition; no automatic promotion. The shutdown exception permits the termination but does not remove its historical classification effect. | Same existing restore classification and operator boundary. |
| Termination occurred, independently observed by the test, but valid event evidence is unavailable to the procedure | Unknown eligibility, provided no other disqualifying fact is known. Automatic refusal and operator notice; operator may wait or authorize restore. The hidden test observation must not become procedure knowledge. | The actual event requires restore, but the survivors cannot establish it. Restart risks violating the existing classification rule. |
| No termination occurred, but coverage is missing | The same unknown-eligibility result. Actual innocence is insufficient evidence. | The actual clean history satisfies the positive rule, but the procedure cannot distinguish it from the preceding row using those survivors alone. |

The prohibition/classification distinction follows the owners’ different words: STO-7 prohibits waiter cancellation or termination “other than by shutting the primary down”; STO-54 still includes “had a waiting backend cancelled or terminated” in its restore arm. [STO-7](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L205), [STO-54](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1665)

A known disqualifying event remains known even when another fact is unavailable. Conversely, an event known only to the test does not justify a *known-event* verdict by the procedure.

Unknown loss-report endpoints are separate in every row. For an authorized restore, STO-54 says “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.” Neither candidate adds an endpoint-evidence hold. [STO-54](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1731)

3. **C-WITNESS: ordering, completeness and sound certificates**

The proposed ordering is meaningful: independently durable incarnation registration precedes component service, and acknowledged intent precedes a controlled signal. An intent acknowledges **possible effect**, not actual waiter termination.

Its failure cases have these consequences:

- **Abrupt primary, host or power loss:** the retained active-incarnation record identifies unfinished coverage. Without independent exclusion of waiter termination throughout that interval, eligibility remains unknown.
- **Independent-service failure:** an unacknowledged intent blocks the controlled signal. Missing registration blocks initial component service. Inaccessible or incomplete promotion evidence cannot support a clean certificate.
- **Privileged bypass:** the form requires coverage of privileged paths. A deployment with an unaccounted bypass cannot establish complete coverage. Authentication of the records it *did* capture does not repair omitted events.
- **Wrong database, incarnation or ancestry:** the assertion is inapplicable. Matching labels or larger positions cannot repair the binding.
- **Unclosed intent:** uncertainty remains unless continuously covered evidence establishes that no waiter was affected. A subsequent equal report or catch-up cannot resolve the historical question.

A sound clean certificate is possible under the specified trust boundary. For example, an independently enforced control could cover all relevant termination paths, retain the prior history status, and establish that no waiter could exist during a fenced final shutdown interval. An earlier absence observation alone would not suffice: admission must remain prevented throughout the interval being certified.

The form therefore supplies a contract, not an implementation. It expressly requires a named trusted issuer, validator, failure domains, ancestry binding and coverage. It does **not** establish that any existing issuer meets them. A signature proves provenance, not truthful completeness; a signed “clean” assertion from an incomplete observer fails the contract.

The remaining deployment-specific facts are substantial: the actual fencing boundary, enforcement boundary, record-integrity mechanism and coverage argument. If those cannot be established, the specified result is uncertainty—not an impossible certificate that must somehow be issued.

4. **C-UNKNOWN’s predicate, and NEITHER’s remaining obligation**

C-UNKNOWN’s predicate has a usable order:

- A known disqualifying condition invokes the existing restore classification.
- Otherwise, one unestablished applicable restart condition makes eligibility unknown.
- Established eligibility requires every applicable condition to be established and none disqualifying.
- Continuing an existing incident remains continuation.

Its allowed positive evidence is stronger than operator confidence but not logically impossible: an authenticated, completely covering event source, or an independently enforced no-event invariant with established uninterrupted coverage and non-bypass. A controlled clean fixture can establish such coverage through fencing without reconstructing a lost primary’s logs.

The text does not require a replication or topology drift controller: it expressly preserves “existing trusted deployment duties.” That is consistent with STO-7’s “no additional runtime replication-configuration drift check is required.” [STO-7](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L188)

It also supplies no historical reset. Its explicit treatment of inherited uncertainty prevents a fresh incarnation identifier from laundering an uncovered interval. Its endpoint paragraph preserves authorized restore progress independently of reporting bounds.

**The strongest objection to my preferred form is availability.** It defines a safe decision but supplies no evidence-producing mechanism. A deployment may consequently refuse automatic promotion repeatedly, including when no termination occurred. Inherited gaps may remain unresolved indefinitely. C-WITNESS may justify its greater infrastructure cost by making acceptable evidence obtainable more often; the packet establishes no measured comparison.

For NEITHER, the remaining deployment obligation is to make promotions satisfy the actual retained conditions, including historical ones. The operator boundary—“Only an operator starts a promotion that is a restore”—does not establish those facts. [STO-54](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1667)

No classifier receiving only identical survivors can correctly distinguish both mandated classifications. Additional knowledge, sound prevention, or abstention is necessary. Refusing promotion avoids an immediate misclassified promotion while leaving recovery unresolved. NEITHER does not newly authorize treating uncertainty itself as restore eligibility, and a permanently refusing implementation cannot claim to have passed CNF-365’s successful restart drill.

5. **Verdict changes, vacuity and false passes**

Both amendment candidates intentionally strengthen the specification: an actually clean history with inadequate evidence now requires automatic refusal; if promotion proceeds under operator authorization, it follows the restore procedure. This is substantive, not editorial.

C-WITNESS additionally changes controlled-signal and initial-service admission, evidence survival and validation obligations. Its tests exercise those additions. C-UNKNOWN tests the distinction between hidden actual events and procedure knowledge without prescribing that service.

The retained clean/equal verdict remains reachable under both forms with valid evidence. An implementation that always returns unknown cannot use that refusal to satisfy the positive control. Nor may a fixture merely stipulate a `clean=true` value: it must establish the candidate’s provenance, coverage and ancestry requirements.

A concrete **false pass under the current checklist** is a procedure that handles supplied known-event flags correctly but otherwise promotes from equal reports. It could pass the current known-event fixtures, qualified by “each made known to the deployment’s procedure,” yet misclassify the hidden-event trace. That is an existing coverage limitation, not a contradiction created by NEITHER. [CNF-365](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L1213)

The new paired fixtures address that limitation. Giving their hidden observation to the procedure would invalidate the test; equating an intent with actual termination would invalidate C-WITNESS’s known-event assertion.

No existing Lean verdict must change. WalHistory explicitly “models neither incident procedures nor permission to promote”; Restore “takes the classification as input.” The mathematical tied-prefix result is not a clean-history certificate or deployment attestation. [WalHistory](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/WalHistory.lean#L39), [Restore](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L33)

6. **Costs, remaining decisions and amendment scope**

- **C-WITNESS:** independent durable storage/service, authenticated provenance, ancestry binding, signal interposition, privileged-path coverage, retained continuity and validation. Service failure can block controlled shutdown or service admission as well as automatic promotion. Unresolved coverage can still require prolonged outage or operator restore.
- **C-UNKNOWN:** no prescribed new service, but evidence evaluation and incident handling remain work. Automatic availability depends on evidence the deployment can actually supply. Missing evidence can cause more operator restores even without acknowledged loss.
- **NEITHER:** no added normative or conformance burden. Knowledge/prevention costs remain deployment choices; abstention can still produce an unresolved outage.

Concrete restore consequences retain their existing owners: STO-54 requires queued create/install/rescue-inventory work to be “moved to `needs_reconciliation`,” says “every tenant’s credential generation is bumped,” and keeps the freeze until `grace_ends_at`. Those costs can therefore arise from conservative restores even when no acknowledged commit was lost. [STO-54](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1758), [credential generation](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1765), [freeze](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1735)

The owner still must choose whether to mandate the recording infrastructure, adopt uncertainty-based refusal without prescribing it, or retain the current obligation and gap. No additional owner or existing Lean amendment is required for my acceptance of these exact forms. No replacement or combination is proposed.

No source, Git, tracker or panel records were changed; no gates or Lean jobs were run. This reading establishes neither the unmeasured shutdown schedule nor a compliant acknowledged-commit loss.