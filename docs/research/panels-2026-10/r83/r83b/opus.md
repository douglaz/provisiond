# r83b Panel D, opus: Q4 only

I confirmed the pin with `git rev-parse HEAD` (`3109b5b44eae17e288cf52aaa976993bd8c5626c`), and the clone is clean. I read notes.md and the whole packet, including all four r83 answers.

I checked these against the pin:
- API-58 at lines 617–650 and 728–734. The disclosure extract matches line for line, including `not.* **A` on line 731.
- OPS-43 steps 1–8 and OPS-27's suspended-attach paragraph.
- API-63's termination residue at lines 1404–1445.
- WIR-9a, WIR-9b, DOM-17 and LDG-35.

A grep found that no CNF item, CONTEXT.md entry or other normative document quotes the disclosure sentence. Only the r60 research records and the pv-kv2 bead quote it. I wrote, built and ran nothing, and started no subagent.

## The disagreement: does step (2) qualify the promise, or must the promise change?

**My ruling: Sol is right.** API-58's detailed exception qualifies the promise. A leaves the MUST at least as true as the pin does. Astra's trace is not a verified block under rule 3.

1. **The pin already requires this trace.**
   - Pinned step (2) says: "a create claimed before the suspension landed MUST be allowed to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep".
   - Pinned OPS-43 never reads tenant status.
   - So at the pin, this sequence is required: claim at 09:59, step 8 at 10:00, suspension at 10:01, provider accepts at 10:02. It already sits beside the same "nothing further can be bought" and the same "MUST say so in those words".
   - Rule 3 asks for a *loss*: "a checked verdict changed, made unreachable or vacuous … or quote a MUST/SHOULD with file, owner and trace". Astra quotes the MUST and a trace, but whether the MUST is true on that trace is the same before and after A. At most this is a tension that already exists. A does not cause it.

2. **A removes the one trace that actually made the words false.**
   - At the pin, a create queued before the suspension and first claimed after it can be bought. That is pv-kv2's own title, and the bead quotes "nothing further can be bought" against it.
   - Under A, a purchase can reach the provider after the suspension commits only if its step-8 tenant write committed first, because the two writes "MUST contend on that same row".
   - So "further" now has an exact meaning: nothing authorized after the suspension commits. The in-flight set shrinks from "claimed before" to "passed the dispatch guard before".

3. **The promise has to be read as part of API-58.**
   - The sentence closes the same requirement whose step (2) lets in-flight creates settle. The requirement's later text expects machines to arrive after suspension: "**A create that has produced no machine yet passes the re-sweep's test**, so settlement here is not the last guard".
   - The spec already handles this shape in API-63: "a create admitted after a termination is impossible rather than merely unlikely". The same requirement then says: "A create already dispatched to the provider when the termination commits is not reachable by any lock … That is the honest end for it".
   - So an "after the event" claim is about authorization, with the residue stated alongside it.
   - Under the strict reading (no request reaches the provider after the commit), no design could satisfy the words, because LDG-69 forbids holding the primitive while waiting on "any provider call". That is the impossible boundary the packet sets aside, so it can't be a defect specific to A.

4. **The MUST doesn't force a false public statement.** It requires the words to appear. Nothing in API-58 stops the terms from also explaining step (2), so the terms can satisfy it truthfully under A.

**What Astra gets right:** a customer who reads only the terms sees no in-flight qualifier. That disclosure is worth adding. But the gap already exists at the pin, and it isn't "the exact error and race guard" the owner gave Panel D. The only printed form that closes it, D, breaks something else (below). I treat it as a follow-up, not a block.

## Full trace under A, against step (2) and the disclosure

- **09:59.** The create is admitted while the tenant is active: API-7 step 5b reads `active`, and API-63's account write succeeds. The commitment opens and the create is `queued`. A worker claims it. Step 1 finds the account `healthy`, and the new tenant read finds `active`. Steps 2–7 pass.
- **10:00.** The step-8 transaction runs:
  - OPS-50's generation check.
  - The STO-47 guard affects 1 row.
  - The tenants-row guard affects 1 row.
  - `about_to_order_at` and the correlator are written.
  - The transaction commits and is acknowledged.
- **10:01.** Suspension admission sets the tenants row to `suspended`. Step 8 has already committed, so nothing contends. The `202` is returned and the parent is enqueued.
- **10:02.** Step 9 sends the key upload and the order, and the provider accepts.

Checking the outcome:
- **A's step (2):** the create "passed OPS-43's tenant dispatch guard before the suspension landed … MUST be allowed to settle". Step (4)'s administrative write can't reach it, because the create is `running`.
- **At attach:** OPS-27 says "that same transaction also enqueues a system cancellation", and this "applies at **all three** entry points". If the parent hasn't settled yet, the re-sweep finds that episode open. API-58 then says it "MUST instead **append `tenant_suspended` to that episode's `reasons` set (`DOM-31`) and name its `current_operation_id`**". The setup fee and first unit are debited at settlement, and the cancellation follows.
- **Against the disclosure:** "every machine has been accounted for" holds. "Nothing further can be bought" holds: the purchase was authorized at 10:00, and nothing was authorized after 10:01. The pin produces the same outcome.

Variants:
- **Suspension commits just before step 8.** The tenants guard affects 0 rows. Under READ COMMITTED it re-evaluates to 0 rows. Under snapshot isolation it raises a serialization failure, the whole transaction is repeated under OPS-49, and then it affects 0 rows. Either way: roll back, record `tenant_suspended`, settle `failed`, release in full, no step 9.
- **The step-8 acknowledgement is lost and suspension lands before the repeat.** The repeat fails the guard, the column stays set, and OPS-11's create row applies: "Any create failure the worker records before any step-9 request … MUST settle `failed`, whatever its kind". There is no speculative dispatch.
- **Crash between 10:00 and 10:02.** OPS-15 moves the set-column create to `needs_reconciliation`. OPS-27's resolution finds nothing ordered.
- **Lock order:** step 8 takes the account row and then the tenants row. Suspension takes only the tenants row. LDG-35's primitive is "per-tenant advisory locks", which step 8 does not take. There is no cycle.

**Breaking trace for A: none found.**

## Q4-D: CANNOT ACCEPT

D's items 1–4 and 6 are A's mechanics with real improvements. Item 5, though, deletes an existing obligation to disclose, and does not say so.

The pin says, at `04-api-contract.md:733–734` (API-58): "The terms and the operator documentation MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not." The word "so" covers "not a promise that the fleet is gone" and "every machine has been accounted for".

D keeps "not a promise that the fleet is gone" only inside the bold spec sentence, which nothing now requires the terms to repeat. D's only obligations on the terms are:
- "MUST explain that an order authorized for dispatch before suspension may still reach the provider and complete afterwards, and that its resulting machine is subject to cancellation."
- "They MUST NOT promise that suspension recalls such an order or that cancellation has already succeeded."

**Breaking trace for D:**
1. A tenant owns machine M, and the tenant is suspended.
2. Step (3)'s delete for M fails with `authentication` after a credential rotation, and its episode goes `stalled`.
3. The parent settles anyway. API-58 says: "the parent settles `succeeded` while a machine of a suspended tenant may still be running".
4. Suppose the terms read: "Suspension stops new purchases. An order authorized before suspension may still complete; its machine is subject to cancellation; suspension does not recall it."

Those terms meet every D MUST and MUST NOT, because saying nothing promises nothing. Yet a customer reads "suspended" as "stopped" for M, which is exactly the misreading the pinned rationale exists to prevent. At the pin, those terms fail API-58.

That is a changed normative verdict, and D doesn't disclose it. Rule 3 says "Disclose collateral flips", and rule 7 says "Preserve its purpose and name any changed normative/tested verdict". D also replaces a fixed-wording requirement with "explain". The repair is substantive: restore the positive disclosure and its fixed-words requirement, then add the in-flight sentence. So I reject D rather than repair it here.

A smaller point, not blocking on its own: "It stops new purchase authorization at OPS-43's tenant dispatch guard" leaves out API-7 step 5b, which refuses most new purchases at admission.

## A, B and C

- **A: ACCEPT, preferred.**
  - *Strongest reason:* the step-1 read handles the owner's pickup story before any provider request. The same-row write closes the race where the worker reads `active` and suspension then commits. A keeps the account-first order and OPS-27 for dispatched orders.
  - *Conditions, all editorial:*
    - The landing keeps the step-(2) bold markers closed. A's replacement starts inside `**fences work already in flight**`, which D's anchor makes explicit.
    - A's "marker" means `about_to_order_at`. STO-8 says that column is "not a correlator or one of `OPS-45`'s markers", so the landed text should name the column.
    - The Q1 forms land with or after this one.
- **B: ACCEPT.**
  - *Reason:* B's mechanics are identical to A's. `true` is defensible under DOM-17's "safe and sensible", and it parallels API-63's recoverable `state` → `true`, which is also a condition an operator clears.
  - *Not preferred:* while the tenant stays suspended, the same request meets a 403 `suspended`. API-51 makes the value "normative for callers", and A's `false` describes the request truthfully.
- **C: ACCEPT.**
  - *Reason:* C still stops before buying.
  - *Not preferred:* with a suspended tenant and a closed channel, C answers `rate_limited` with `retry_after_ms`. That invites a resend that step 5b will refuse. It is also further from the owner's "at pickup the worker sees the customer is suspended".

## Rules 3 and 6, and formal scope

- **Rule 3:** the disclosed trace is **not a verified block** for A, B or C. The MUST and the trace are quoted, but the verdict is the same at the pin and under each form, so nothing is lost.
- **Rule 6:** no premise error. The extract, the line numbers and the claim "This concerns authorization while active, not first pickup under suspension" all check out.
- **Formal scope:** the mechanics sit outside the current model.
  - `Restore.lean:35` says "`Live` has no step 8".
  - `Claim.lean:17` omits "`API-58`'s fan-out transition".
  - `Tables.lean:210`, `create_before_step9_failed`, applies unchanged.
  - No Lean change is needed, and I demand no new formalism.

## Follow-ups (not conditions)

1. **Disclosure, for the owner.** The version that weakens nothing keeps the pinned sentence and its "in those words" requirement. It then adds that an order already authorized for dispatch before the suspension may still complete, that its machine is cancelled under OPS-27, and that suspension doesn't recall it.
2. **Step (4)'s `retryable`.** API-58 step (4)'s administrative `tenant_suspended` failure states no `retryable`. Align it with Q4's value.
3. **WIR-9a's reason list.** It credits `tenant_suspended` to API-58 alone; add OPS-43.
4. **Store primitives.** List the step-8 tenants-row write among the STO-6 and STO-27 primitives.
5. **CNF-202 coverage.** Add D's otherwise-passing fixture prerequisites and its first-failure precedence cases, plus STO-58's exclusion release.

Final Q4: Q4-A; acceptability A ACCEPT, B ACCEPT, C ACCEPT, D CANNOT ACCEPT (item 5 drops the pinned requirement that the terms say in fixed words that the fleet may not be gone; collateral weakening not disclosed); the disclosed trace is not a verified rule-3 block; no rule-6 premise error.
