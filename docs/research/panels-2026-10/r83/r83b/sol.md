**Preferred exact form: Q4-D, as printed, without substantive repair.** I withdraw my r83 acceptance of A/B/C. The full mandatory public-disclosure sentence defeats my earlier argument that step (2)’s detailed exception sufficiently qualifies the promise.

I read `notes.md` whole, every printed alternative and every supplied r83 answer. HEAD matches `3109b5b44eae17e288cf52aaa976993bd8c5626c`. I changed no files or records and ran no builds, gates, Lean, subagents, background tasks or external contacts.

| Exact form | Verdict | Strongest reason and condition |
|---|---|---|
| **A** | **CANNOT ACCEPT** | Its mechanics permit provider acceptance after suspension while retaining the mandatory public statement that “nothing further can be bought.” Acceptance requires a substantive disclosure amendment; that would be a changed form. D supplies the complete acceptable alternative. |
| **B** | **CANNOT ACCEPT** | The same disclosure contradiction blocks it. Its `retryable: true` choice is secondary: I still regard that advice as defensible for safe reissuance after authorized resume, rather than an independent blocker. A truthful public-disclosure amendment is required. |
| **C** | **CANNOT ACCEPT** | The same disclosure contradiction blocks it. Channel-before-tenant precedence still prevents purchase when the channel refusal wins, so that placement is not my blocking reason. The public promise must change substantively. |
| **D** | **ACCEPT — preferred** | It combines the required pickup refusal and dispatch guard with an explicit, truthful disclosure of purchases authorized before suspension. No substantive repair is required. My acceptance covers the complete printed bundle, including its public-disclosure replacement and precedence fixtures. |

**The disclosed trace is a verified block against A/B/C under rule 3.**

The owning obligation is **API-58**, [04-api-contract.md:731](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L731):

> “it is a promise that every machine has been accounted for and that nothing further can be bought.”

The following sentence prescribes the external representation:

> “The terms and the operator documentation MUST say so in those words”

This satisfies rule 3’s requirement for a quoted MUST, an owner, a file and a concrete trace. It does not depend on a missing runtime test or an inferred provider-call boundary.

The breaking trace, with otherwise passing inputs, is:

1. **10:00:** The active tenant’s create passes the tenant dispatch guard. Step 8 commits and is acknowledged; `about_to_order_at` and the applicable correlator are persisted. The provider has not yet received the order.
2. **10:01:** Suspension commits. The tenant flag changes, but the create remains running under its worker’s claim.
3. **10:02:** Step 9 reaches the provider, which accepts the purchase. A/B/C expressly authorize this treatment through their step-(2) replacement: “treat that residue as the potentially dispatched case.”
4. The create follows ordinary settlement and attachment. If the tenant remains suspended, **OPS-27** supplies: “that same transaction also enqueues a system cancellation” ([03-operation-lifecycle.md:642](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L642)). Later evidence-based attachment uses that same protection.
5. The cancellation accounts for the machine. It cannot make the already accepted purchase cease to have happened.

Against **step (2)**, this trace is permitted and correctly retained: authorization occurred while active, and abandoning the order would risk losing its record. Against the **mandatory public promise**, a purchase accepted after suspension contradicts “nothing further can be bought.”

That distinction resolves the disagreement. The detailed exception explains the engine’s behavior; it does not change the words the terms and operator documentation are expressly required to say. Even presenting those words beside the exception leaves conflicting assurances. My earlier qualification argument was insufficient.

This is not a demand to recall the provider request or hold a transaction open across it. **LDG-69** expressly prohibits waiting on “any provider call” while the primitive is held ([12-billing-and-ledger.md:463](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L463)). The required repair is truthful disclosure of the permitted authorization boundary.

**D resolves that block and preserves the fixed pickup policy.**

D’s public replacement says:

> “It stops new purchase authorization at OPS-43’s tenant dispatch guard”

and requires disclosure that an order authorized before suspension:

> “may still reach the provider and complete afterwards”

Those statements accurately describe the trace. D also retains the accounting obligation and requires disclosure that the resulting machine is subject to cancellation, without promising cancellation has already succeeded.

D’s mechanics cover the relevant paths:

- **First pickup while suspended:** Its step-1 insertion says “Make no provider request, including List offers or a per-order key upload,” and specifies `failed`, `conflict`, `tenant_suspended`, `retryable: false`, full release and no setup-fee or first-unit debit.
- **Active early read, suspension before dispatch authorization:** Its step-8 insertion requires the writes to “contend on that same row.” Suspension winning causes rollback and refusal before step 9. The earlier plain read is not substituted for this guard.
- **Authorization wins:** D expressly retains the “potentially dispatched case,” with settlement and suspended-attach cancellation. This is the disclosed trace, handled truthfully.
- **Lost acknowledgement:** D requires the repeat to recheck suspension while keeping previously committed `about_to_order_at` and correlator unchanged. A resulting known refusal follows **OPS-11**: “Any create failure the worker records before any step-9 request … MUST settle `failed`, whatever its kind” ([03-operation-lifecycle.md:249](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249)). The timestamp does not become a null-column condition on settlement.
- **Worker ownership:** D retains “the operation-row claim guard and acknowledgement-before-step-9 rules.” Its refusal cannot authorize a stale worker to settle or dispatch.
- **First-failure precedence:** D’s fixtures explicitly require the account-status refusal to win over suspension, and `tenant_suspended` to win over channel closure with a healthy account. This agrees with **OPS-43**: “The first failing check stops subsequent checks” ([03-operation-lifecycle.md:830](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L830)).

I found no breaking trace for D in these cases. Its create-only insertion does not extend the refusal to installs, power operations or system cancellations.

**D’s disclosure change is substantive and must be recorded as such.**

The changed normative verdict is the externally prescribed promise: the old exact-word assurance of no further buying becomes a guarantee against new dispatch authorization, together with mandatory disclosure of earlier authorization completing later. I accept that change because it preserves the fixed pickup refusal and machine-accounting purpose while describing the acknowledged transaction-to-provider interval accurately. It is not editorial cleanup.

The other observable distinctions remain explicit: D chooses false retry advice rather than B’s true, and tenant-before-channel precedence rather than C’s ordering. Its CNF-202 append adds the corresponding race, lost-acknowledgement and precedence assertions, with otherwise-passing fixture prerequisites. It appends to existing coverage rather than replacing the held-power case. I identified no existing checked verdict made unreachable or vacuous by D; I did not execute checks.

No affected existing Lean declaration was identified for the new tenant dispatch protocol. **Restore.lean** explicitly states “`Live` has no step 8” ([Restore.lean:35](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L35)); **Claim.lean** lists “`API-58`’s fan-out transition” among its omissions ([Claim.lean:15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Claim.lean#L15)). The existing `Tables.create_before_step9_failed` statement remains applicable and unchanged. I claim no existing proof of the proposed guard and require no new formalism for acceptance.

**Rule 6:** I found no verified brief error changing Q4’s premise. The disclosure conflict is a candidate-bundle defect against accurately supplied pinned text. It does not void the tally under rule 6.

This is my individual consensus-round verdict. The supplied record contains no Grok vote or verified down status, so I neither count one nor assume the fallback applies. Earlier A preferences cannot be transferred to D, and this answer alone does not establish rule 2’s settlement threshold.

Final Q4: Q4-D exactly as printed; acceptability A CANNOT ACCEPT, B CANNOT ACCEPT, C CANNOT ACCEPT, D ACCEPT.