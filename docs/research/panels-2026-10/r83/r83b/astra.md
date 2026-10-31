**Preferred exact form: Q4-D, unchanged as printed.** I accept D without substantive repair.

I read notes.md whole, every printed alternative, and all verbatim r83 answers. I verified HEAD as `3109b5b44eae17e288cf52aaa976993bd8c5626c` and checked the relevant pinned source. No files or records changed; no builds, gates, Lean execution, subagents or background tasks ran.

| Exact form | Verdict | Strongest reason and condition |
|---|---|---|
| **A** | **CANNOT ACCEPT** | Its dispatch mechanics permit a purchase after suspension while retaining API-58’s mandatory unqualified public promise. Acceptance would require a substantive disclosure amendment, making it a different form. D already supplies that complete alternative. |
| **B** | **CANNOT ACCEPT** | The same disclosure contradiction independently blocks B. I prefer false retry advice, but do not claim B’s true value itself reverses the owner policy. Correcting disclosure would require a separately reviewed form; this is not conditional acceptance of printed B. |
| **C** | **CANNOT ACCEPT** | The same disclosure contradiction blocks C. Its channel-before-tenant precedence still prevents purchase and is not an independent blocker. Acceptance requires a substantive disclosure amendment. |
| **D** | **ACCEPT — preferred** | It combines the required pickup refusal and same-row dispatch guard with an explicit, truthful public disclosure of the already-authorized-order exception. No additional substantive condition. |

**The disclosed trace is a verified blocking loss under rule 3 for A/B/C.**

The owner of the conflicting obligation is **API-58**, [04-api-contract.md:731](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L731):

> “A suspension is not a promise that the fleet is gone; it is a promise that every machine has been accounted for and that nothing further can be bought.”

Its following sentence requires:

> “The terms and the operator documentation MUST say so in those words”

The concrete breaking trace is:

1. **10:00:** An otherwise valid create passes step 8 while its tenant is active. The transaction commits and is acknowledged. No step-9 request has occurred.
2. **10:01:** Suspension commits. API-58 step (1) marks the tenant suspended “in the admission transaction, before the `202` is returned” ([04-api-contract.md:618](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L618)).
3. **10:02:** Step 9 sends the order and the provider accepts it. The purchase occurs after suspension, although dispatch authorization preceded suspension.
4. The resulting machine attaches while its tenant remains suspended. **OPS-27** requires that “that same transaction also enqueues a system cancellation” ([03-operation-lifecycle.md:642](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L642)).
5. Cancellation is enqueued. That does not make the accepted purchase never have happened.

Against amended **step (2)**, this trace passes: A/B/C expressly say that an order between the acknowledged transaction and its provider call is “potentially dispatched” and must be allowed to settle.

Against the unchanged **public-disclosure obligation**, it fails: something further was bought after suspension, yet the terms and operator documentation must still publish the quoted absolute promise.

I therefore disagree with Sol’s conclusion that the detailed exception sufficiently qualifies the mandatory wording. The replacement explains the operational exception, but neither changes the prescribed public sentence nor requires that exception to accompany it publicly. Reading “bought” as “newly authorized at the dispatch guard” silently changes the promise’s meaning. That distinction needs the explicit normative edit D supplies.

This is a disclosure contradiction, **not a demand for a provider-call boundary with no intervening race**. The trace concerns authorization while active; it does not disprove the owner’s first-pickup-under-suspension policy. Nor does it depend on missing runtime coverage or an unproved theorem.

**D makes the substantive change visible and preserves the policy.**

D replaces the compulsory “nothing further can be bought” assertion with:

> “It stops new purchase authorization at OPS-43’s tenant dispatch guard”

It then requires the terms and operator documentation to explain that an earlier-authorized order may reach the provider and complete afterwards, with its machine subject to cancellation.

The changed normative verdict is explicit: **the public contract no longer promises zero purchases completing after suspension; it promises a stop on new dispatch authorization and disclosure of outstanding authorized purchases.** D also prohibits promises that suspension recalls such an order or that cancellation has already succeeded.

That is a substantive disclosure amendment, not editorial cleanup. It preserves the purpose of the original disclosure—explaining what suspension actually accomplishes and accounting for machines—while retaining the fixed refusal for first pickup under suspension. It does not expand dispatch eligibility beyond A/B/C or remove their guard to clear review.

The collateral differences are also substantive where they affect results:

- **First-failure precedence:** D’s OPS-43 insert orders account → tenant → channel → boundary validation. For a healthy account, suspended tenant and closed channel, D selects `tenant_suspended`; C selects the earlier channel refusal. D’s CNF-202 additions explicitly test its chosen precedence.
- **Retry advice:** D requires `retryable: false` on both error and operation view, whereas B requires true. I prefer false for a deliberate suspension. **DOM-17** calls this whether repeating “the same request is safe and sensible” and says it is “never authorization for an automatic service retry” ([01-domain-model.md:655](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655)). Thus B’s advice is a meaningful contract difference, but not permission to bypass suspension.
- **Fixture precision:** D’s CNF-202 text supplies healthy-account, open-channel and otherwise-valid prerequisites for its isolated suspension case. Its separate combined-failure cases reject an implementation that silently swaps account/tenant or tenant/channel precedence.
- **Disclosure obligations:** D replaces the exact-words mandate and adds explicit explanation and prohibited-promise requirements. Those must be reviewed and landed as obligations in their own right.

**The mechanics in D remain coherent across the relevant races.**

For otherwise passing inputs, first pickup under suspension fails before List offers, temporary-key registration, ordering or debit. It records `conflict` with `details.reason: "tenant_suspended"`, preserves origin, and releases the commitment.

When the early read sees active but suspension wins before step 8, D requires a conditional write on the **same tenant row** as suspension’s flag write. The losing dispatch transaction rolls back; no step-9 request begins. An early read or early lock does not substitute for that write.

When step 8 commits and is acknowledged first, the order is potentially dispatched. D expressly retains settlement and suspended-attach cancellation for the disclosed trace. **LDG-69** says an implementation holding the money primitive “MUST NOT wait on” any provider call ([12-billing-and-ledger.md:463](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L463)); D does not move the call inside that transaction.

A lost acknowledgement is different from acknowledged authorization followed by dispatch. D repeats the whole transaction and rechecks the tenant guard. If suspension defeats that repeat, the worker records a known pre-step-9 failure, retaining any previously committed `about_to_order_at` and correlator. **OPS-11** requires such failures to “settle `failed`, whatever its kind” and says classification “MUST NOT read `about_to_order_at`” ([03-operation-lifecycle.md:249](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249)). D preserves the worker claim guard and adds no null-column condition to settlement.

I found **no breaking trace for D**. Its refusal remains scoped to create; it does not introduce suspension refusals for installs, power operations or system cancellations. OPS-27’s suspended-attach cancellation remains intact, including late attachment after the suspension parent settles.

**Formal scope and rules 6–7.**

The new tenant dispatch protocol sits outside the current formal model. I read the relevant scope statements and declarations: `Restore.lean` expressly says “`Live` has no step 8”; `Claim.lean` omits API-58’s fan-out transition. `Funding.reap_refuses_active` concerns reaping an active tenant, while `Fence.suspend` sets suspension and enqueues cancellation. Neither proves the proposed dispatch race guard.

`Tables.create_before_step9_failed` retains its existing classification statement, and `Ledger.close_releases_exact_remainder` retains its release arithmetic. I identify no declaration requiring amendment for D and require no new formalism as a condition of acceptance. No theorem, guard hypothesis or existing negative control is weakened by this verdict.

Applying **notes.md rule 6 exactly as written**, I found no verified brief error that changes Q4’s premise. **No tally is voided.** The disclosure conflict is a candidate defect under rule 3. D addresses it through an expressly reviewed disclosure change while preserving the fixed policy and accounting purpose required by rule 7.

This is my individual vote. The historical A majority does not establish settlement in the presence of the verified block. The packet supplies no current Grok answer or outage determination, so I infer neither a vote nor eligibility for the fallback.

Final Q4: Q4-D exactly as printed; acceptability A CANNOT ACCEPT, B CANNOT ACCEPT, C CANNOT ACCEPT, D ACCEPT.