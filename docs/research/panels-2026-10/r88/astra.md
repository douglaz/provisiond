**Final: C-UNKNOWN.** I prefer its printed form for a later owner scope/cost decision. I also accept C-WITNESS and NEITHER as written, for the distinct reasons below. This is technical acceptance, not authorization to adopt any option.

I read `notes.md` whole, the supplied row/bead, and the relevant pinned sources; HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c`. No files or Git state were changed; no gates, Lean jobs, providers or subagents were run. Applying rule 6 exactly, I found no verified premise-changing brief error that voids this tally.

1. **Exact-form verdicts**

| Printed form | Verdict | Decisive reason and source |
|---|---|---|
| **C-WITNESS** | **ACCEPT** | It specifies an evidence-producing obligation without claiming every failure yields a certificate. Its “A failed or unacknowledged intent write MUST prevent that controlled signal” addresses ordering; “missing, failed, invalid, conflicting or incomplete historical evidence makes restart eligibility unknown” supplies the conservative failure result. This addresses the audit’s distinction: “A record of ‘shutdown requested’ without whether a waiter was affected is only conservative evidence” (`promotion-action-history-audit-2026-10.md:681–686`). |
| **C-UNKNOWN** | **ACCEPT** | Its predicate distinguishes known disqualification from insufficient knowledge: “Classify a known disqualifying condition under the existing restore rule even if another fact is unknown.” Otherwise, an unestablished applicable condition means unknown eligibility. This directly addresses T-WAIT’s “Equal reports do not reveal which occurred” (`…audit…:374–375`). |
| **NEITHER** | **ACCEPT** | Retention is technically coherent, although it leaves the knowability gap unresolved. The existing owner still classifies a promotion after a primary “had a waiting backend cancelled or terminated” as “a restore” (`05-persistence.md:1665`). It does not promise a survivor-only decision procedure. Failure to add an uncertainty rule is not itself a contradiction in those unchanged words. |

Acceptance of NEITHER does **not** mean identical surviving reports suffice, or that its existing tests demonstrate complete classification knowledge.

2. **Same equal reports, different histories and knowledge**

Assume matching actual ancestry, equal durable reports, no open incident, and satisfaction of the unrelated restart conditions. “Known” below means known to the procedure from admissible information, not merely to the test.

| Actual history / procedure knowledge | C-WITNESS | C-UNKNOWN | NEITHER |
|---|---|---|---|
| No termination; valid complete clean evidence | Either standby may restart automatically. | Either standby may restart automatically. | Existing clean/equal restart applies. |
| Individual waiting-backend termination, validly known | Known restore; no automatic promotion. Operator starts restore. | Same. | Same existing classification. |
| Shutdown-induced waiting-backend termination, validly known | Known restore; no automatic promotion. Operator starts restore. | Same. | Same existing classification. |
| Termination occurred, but evidence is lost/hidden and no other disqualification is known | Unknown eligibility; hold, notify operator. | Same. | Actual history requires restore, but the survivors do not establish that fact. |
| No termination occurred, but coverage is lost/incomplete | Unknown eligibility; hold, notify operator. | Same. | No new unknown classification. A survivor-only restart happens to be correct here, but the identical decision fails in the preceding history. |

The individual event violates STO-7’s “MUST NOT cancel or terminate a primary backend while it waits for a standby”; shutdown falls within “other than by shutting the primary down” (`05-persistence.md:205–206`). Both nevertheless meet STO-54’s quoted historical restore condition. Permission to shut down does not establish restart eligibility.

For either amendment, an operator may wait for adequate evidence or authorize a restore. Authorization does not manufacture clean history. NEITHER supplies no corresponding explicit unknown-to-restore rule; its operator boundary alone establishes no historical facts. Refusing to promote avoids misclassification while leaving recovery unresolved.

The original clean/equal control remains achievable in every form. The amendments add evidence prerequisites; they do not accept an actually clean but unestablished history as that positive control. CNF-365 already qualifies its restart assertion with “no open restore record and every other restart-promotion condition satisfied” (`10-conformance-checklist.md:1186`).

Unknown reporting endpoints are separate throughout. STO-54 says, “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied” (`05-persistence.md:1731–1733`). Neither amendment turns endpoint uncertainty into historical cleanliness or an additional startup hold.

3. **C-WITNESS: ordering, completeness and satisfiability**

The contract has meaningful failure behavior:

- **Abrupt process/host/power loss:** the surviving active-incarnation record prevents disappearance from looking like clean completion. An unresolved interval remains unless independent evidence covers it. A known termination still gives a restore classification even if other coverage remains incomplete.
- **Independent service failure:** an unacknowledged intent prevents controlled signalling. If evidence cannot be validated at promotion, it cannot support automatic restart. The operator-restore path remains available; service failure is not permission to erase inherited uncertainty.
- **Privileged bypass:** logging only the normal shutdown wrapper is insufficient. The form requires “every such path, including privileged administration.” An unmediated privileged signal defeats any completeness claim relying on that wrapper.
- **Wrong ancestry:** authenticated records about another history are insufficient. Authenticity establishes origin, not applicability.
- **Unclosed intent:** it proves a possible effect, not an actual termination and not its absence. Only the stated authenticated, continuously covered evidence can resolve it harmlessly.
- **Lost, deleted or substituted records:** loss must remain detectable as missing coverage. A valid signature on surviving entries does not establish that the collection is complete.

A clean certificate is logically possible. For example, complete evidence could establish no historical termination and independently enforced exclusion of new waiters throughout a final quiescent interval ending at fencing. That exclusion must cover every relevant admission path and survive primary loss. Earlier coverage and inherited status must also be established. Merely observing no waiters immediately before failure is insufficient.

This is a substantive contract, not just an instruction to consult an unnamed oracle: it requires naming the issuer, validation procedure and failure domains, plus coverage, ordering and ancestry binding. It is **not an implementation construction or attestation**. The deployment still owes a defensible meaning of complete coverage and proof that its privileged paths cannot silently bypass that coverage. If it cannot supply them, uncertainty remains; the contract does not require issuing an impossible certificate.

Authentication alone cannot rescue a dishonest or incomplete issuer. That is a remaining trust dependency, not a reason to infer cleanliness from silence.

4. **C-UNKNOWN and NEITHER**

C-UNKNOWN’s predicate is usable:

- A known disqualifying fact takes precedence over other unknown facts.
- With no such fact, any unestablished applicable restart condition makes eligibility unknown.
- Established eligibility requires all applicable conditions and no disqualifying fact.
- An already open incident remains continuation.

Its negative-evidence standard admits positive cases through complete authenticated event coverage or an independently enforced no-event invariant with established coverage and non-bypass. Neither route is satisfied by the issuer signing “clean” without substantiating coverage.

It does not require a drift controller. It expressly retains “existing trusted deployment duties,” consistent with STO-7’s “no additional runtime replication-configuration drift check is required” (`05-persistence.md:188`). That trust posture cannot be repurposed as an unsupported assertion about wait termination, because the candidate specifies a stronger standard for that negative fact.

It also expressly rejects expiry through “Time, new incarnation identifiers, equal reports or later catch-up.” A completed restore does not silently certify uncovered predecessor history. The resulting inherited uncertainty can be persistent; that is a substantial availability cost.

NEITHER’s remaining duty is actual compliance with the existing classification and operator boundary: “an automatic failover promotes only as a restart” (`05-persistence.md:1668`). From identical reports alone, a procedure cannot both take the clean positive path and distinguish the terminated-waiter case. Extra information or trustworthy prevention is necessary for reliable discrimination. Abstention avoids the bad automatic action but supplies neither a certificate nor a completed recovery.

5. **Changed verdicts, fixtures and formal limits**

Both amendments intentionally change a substantive verdict: **actually clean history with inadequate evidence can no longer receive restart classification**. C-WITNESS additionally changes pre-service and controlled-signal obligations. NEITHER changes neither requirements nor check strength.

The retained positive tests are not inherently vacuous. Their evidence can be complete, and their “every other restart-promotion condition satisfied” qualification accommodates the amendments. However, an implementation that cannot establish the required clean evidence cannot claim to pass by skipping the positive runs. Both candidate additions explicitly require successful clean/equal promotions.

Concrete false-pass risks are:

- **NEITHER:** a procedure that handles supplied known-event facts correctly but treats absent event records as clean could pass the current “each made known to the deployment’s procedure” fixtures (`10-conformance-checklist.md:1213`). It would misclassify the hidden-event trace.
- **C-UNKNOWN:** exposing the test’s hidden termination observation to the procedure could produce the right refusal for the wrong reason—known restore instead of unknown eligibility. The printed fixture explicitly forbids that shortcut.
- **C-WITNESS:** testing only through an instrumented administrative wrapper could falsely suggest complete privileged-path coverage. Likewise, treating an intent as proof of actual termination could falsely pass a restore assertion. The printed check expressly distinguishes possible effect from established event.
- **Either amendment:** accepting a synthetic “valid certificate” without checking its coverage could make the clean control prove only that the procedure trusts a label. The owner contracts require more than that fixture shortcut.

C-WITNESS’s check also expressly requires an operator notice in its known-event fixtures; its owner addition expressly mandates notice for unknown eligibility. That is an additional conformance expectation to cost and implement, not a contradiction or a weakening.

No existing Lean verdict needs changing for these forms. `WalHistory.lean` states that it “models neither incident procedures nor permission to promote” (lines 41–42). `equal_reports_allow_either` proves maximality for either tied report; `equal_maximal_protected` proves membership in its concrete tied state. Neither proves a deployed history free of terminated waiters. The amendments preserve those mathematical statements while adding deployment eligibility obligations.

I found no blocking loss of an existing positive control or theorem. I do not infer a reproduced fast-shutdown reader schedule: the pinned audit expressly says it “remains an unmeasured hypothesis” and establishes “No compliant restart loss of an acknowledged commit” (`…audit…:332–334`).

6. **Costs and later owner decision**

| Form | Infrastructure and operating costs |
|---|---|
| **C-WITNESS** | Independent durable storage/service, issuer authentication, continuity and ancestry validation, controlled-signal interposition, privileged-path coverage and evidence-survival testing. Evidence outages can block controlled shutdown signals as well as automatic promotion. Even this investment cannot guarantee automatic recovery after every failure. |
| **C-UNKNOWN** | No prescribed new service. It still requires evidence evaluation, retention of inherited uncertainty, operator notification and stronger conformance fixtures. Deployments without acceptable negative evidence incur unavailable automatic promotion and potentially repeated operator restores. |
| **NEITHER** | No new normative infrastructure or conformance burden. The deployment retains the cost of supplying knowledge or prevention adequate to its existing classification duty—or accepting unresolved recovery through abstention. |

Restore costs are concrete even without acknowledged loss. STO-54 requires that “every tenant’s credential generation is bumped” (`05-persistence.md:1766`); its quarantine moves “every `queued` create, install and rescue inventory” to `needs_reconciliation` (lines 1758–1759), and “the grace is written once per incident” (line 1809). Those consequences explain why uncertainty-driven restores are not costless.

The strongest argument against my C-UNKNOWN preference is its availability burden: declining to mandate evidence infrastructure may leave a deployment routinely unable to take automatic recovery, with persistent inherited uncertainty. C-WITNESS buys a required attempt to preserve that knowledge, though not guaranteed availability.

I identify no necessary amendment outside the printed owner/check blocks to make these contracts coherent. A later adoption would require its decision record after the rule; changing historical expiry, trusted deployment duties or formal claims would require a separately reviewed scope. I recommend the **printed C-UNKNOWN**, without an unreviewed combination or repair, for that later owner decision.