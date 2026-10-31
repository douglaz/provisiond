# Q4 evidence and adjudication — r83b, 2026-10-30

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Source reads used the r83b reader clones and `git show` at this pin. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

## Ballot integrity and scope

`tally-output-audit.json` records the substantive canonical answers, actual exit files, byte sizes, final selections, empty Claude stderr, Codex answer/stdout equality and completed Codex stop hooks. No draft answer exists. The answers are substantive votes rather than session-limit messages. Grok is missing: this round's `grok-probe.txt` records HTTP 402, and main supplied its still-402 one-word check at 21:35Z. No new probe, reader, consensus round or other model job was launched by this tally.

`tally-exactness.json` proves each complete A/B/C/D file occurs verbatim in the packet, and each copied r83 answer matches its parent's answer and occurs verbatim in the packet. `tally-inputs.json` freezes the packet, notes, candidates and current answers before this audit. The current votes, rather than r83's preferences, determine this tally.

Owner decision item 3 says **"Stop before buying (Recommended)"**, with the option: "At pickup the worker sees the customer is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles the exact error and race guard." Every printed form implements that first-pickup refusal and retains the already-authorized-order residue. None proposes buying a create first picked up under suspension. This audit does not reopen that policy or owner items 13 and 14.

## Shared mechanics, checked against their owners

The numbered source extracts are in `tally-source-excerpts.json`; the complete owning source files are in `tally-pinned-sources.json`. The candidate files are the complete proposed amendments, not landed requirements.

| Reader premise | Owning words at the pin | Result |
|---|---|---|
| The flag exists before pickup in the owner's example. | API-58, `04-api-contract.md:618`: "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**". | Verified. A/B/D read the tenant after account refusal; C reads it after channel closure. All forbid provider requests after their tenant refusal. |
| A plain early read cannot replace the dispatch guard. | OPS-43, `03-operation-lifecycle.md:776`: "This is a plain read, not a conditional-write guard"; API-63, `04-api-contract.md:1406`: "contend with admission on the account row itself". | The proposed tenant-row conditional write explicitly contends with the suspension flag on that same row. Both suspension/dispatch orders, lost acknowledgement and original operation ownership are stated in every form. No model execution is claimed. |
| A known refusal with an already-set column still fails deterministically. | OPS-11, `03-operation-lifecycle.md:249`: "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind"; "this rule MUST NOT read `about_to_order_at`". | Verified. The forms preserve the recorded timestamp/correlator after a lost reply and do not add a null-column settlement term. |
| The refusal releases rather than charges. | OPS-11, same create row: "The commitment is released in full" and "with no setup-fee or first-unit debit". LDG-39, `12-billing-and-ledger.md:1221`: "only when the order is known to have landed and the create settles"; line 1226 says "the prepaid first billing unit follows every row of this table". | Verified. A/B/C/D preserve the full-release outcome for known pre-step-9 failure. |
| The worker must keep its claim and use a legal error kind. | OPS-11, same create row: "every write that worker makes to the operation MUST carry `claim_number = mine`"; lines 261–262: admission-only kinds "MUST NOT be emitted by a worker or a driver". WIR-9a, `13-wire-contract.md:141`, includes `"tenant_suspended"`. | Verified. All forms use `conflict`/`tenant_suspended` and preserve the worker guard and origin, rather than emitting the admission-only `suspended` kind. |
| A serialization failure and a status refusal differ. | OPS-49, `03-operation-lifecycle.md:1927`: "MUST repeat the **whole transaction** — never the last failed statement, and never the provider call". | Verified. Each form applies this whole-transaction path rather than inventing a tenant refusal from a store failure. |
| Provider work remains outside the money hold. | LDG-69, `12-billing-and-ledger.md:465–467`: "While it is held, an implementation MUST NOT wait on" ... "any provider call". LDG-35, line 440, selects "per-tenant advisory locks". | Verified. Acknowledged dispatch authorization can precede suspension while the provider call follows it. Neither an earlier lock nor a call held inside the money transaction is an accepted substitute. |
| A suspended attachment is cancelled, including late resolution. | OPS-27, `03-operation-lifecycle.md:642`: "Where the machine's tenant is suspended at the moment of the attach, that same transaction also enqueues a system cancellation"; line 646: "This applies at **all three** entry points". | Verified. The forms retain this path and do not extend create refusal to installs, power or system cancellations. |
| Retry advice and error precedence remain real contract choices. | DOM-17, `01-domain-model.md:656–660`: "whether repeating the *same request* is safe and sensible" and "never authorization for an automatic service retry". OPS-43, `03-operation-lifecycle.md:830`: "The first failing check stops subsequent checks". WIR-41, `13-wire-contract.md:550`, is "operator-only" and line 556 says "Resume MUST be refused" while the parent is unsettled. | Verified facts; the disputed inference that only false can meet DOM-17 is a reader judgment, not an independently fixed value. B does not authorize buying during suspension. D's added combined-failure fixtures test its chosen account → tenant → channel order; C chooses account → channel → tenant. |

The fable/opus lock-order paragraphs support the limited observation that the new write is account row → tenant row and the suspension flag itself does not take the account row. The sources do not prove their broader categorical claim that no database deadlock can ever form. This audit does not adopt that universal, and it supplies no vote's decisive reason. The ordering/refusal/lost-ack duties in the exact candidates remain independently readable.

## The public-promise trace against A/B/C

The complete API-58 disclosure at `04-api-contract.md:731–734` is:

> **A suspension is not a promise that the fleet is gone; it is a promise that every machine has been accounted for and that nothing further can be bought.** The terms and the operator documentation MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.

All candidate dispatch replacements permit this case: at 10:00 the active tenant's step-8 transaction commits and is acknowledged; at 10:01 suspension commits; at 10:02 the provider accepts the order. The replacement calls it "potentially dispatched" and says "MUST be allowed to settle". Attachment then takes the quoted OPS-27 path. Cancellation cannot undo the purchase.

The trace is real. Fable and opus also correctly identify it as reachable at the unchanged pin: API-58 step (2), lines 623–625, already says "a create claimed before the suspension landed MUST be allowed to settle rather than abandoned mid-order". The candidate guard narrows that eligibility to a transaction that won while active. Astra and sol correctly identify a separate obligation: the quoted public words remain compulsory in A/B/C. Whether the existing detailed exception qualifies those words is precisely the disputed interpretation; it is not silently converted into a new runtime impossibility requirement. The record preserves both readings.

The public words are not an existing CNF assertion or a theorem of the tenant dispatch guard. `tally-disclosure-search.json` records the scan of root Markdown and ADRs: no other owner supplies the removed positive fleet-warning duty. Missing automated coverage does not remove a normative MUST from notes rule 3. Independently of adjudicating A/B/C's disclosure objection, none reaches three current acceptances; see `../tally.md`'s ballot table.

## Opus's complete dissent against D: verified blocking loss

The context immediately preceding the pinned disclosure is about an existing machine, not only a newly completed order. API-58 at `04-api-contract.md:712–725` expressly gives `authentication` after credential rotation as a deterministic cancellation failure. It then says:

> "the parent settles `succeeded` while a machine of a suspended tenant may still be running."

and:

> "A `failed` attempt moves its episode to `stalled`"

D item 5 retains "A suspension is not a promise that the fleet is gone" inside the specification's bold sentence. Its external-document duties instead say:

> "The terms and operator documentation MUST explain that an order authorized for dispatch before suspension may still reach the provider and complete afterwards, and that its resulting machine is subject to cancellation."

and:

> "They MUST NOT promise that suspension recalls such an order or that cancellation has already succeeded."

Opus's witness is therefore valid:

1. Machine M existed before suspension; its cancellation fails `authentication`, leaving its episode `stalled` while the parent succeeds.
2. The terms disclose the preauthorized-order exception and say the resulting machine is subject to cancellation. They promise neither recall nor successful cancellation.
3. They say nothing about whether the pre-existing fleet has stopped or whether every machine is accounted for.
4. They satisfy D's replacement external-document duties. They fail the old API-58 duty to publish the quoted whole fleet/accounting promise "in those words".

The changed verdict is the acceptability of that external documentation. A prohibition on promising successful cancellation does not require positively warning about a still-running pre-existing fleet. The warning's survival in the specification does not impose its publication once its publication duty is removed. No other requirement found in the recorded source scan restores that duty.

This verifies a normative loss under notes rule 3, with its MUST, owner, file and complete trace. Fable explicitly notices the change from exact words to explanation and the dropped rationale, but its claim that the purpose is preserved through the bold spec sentence and the negative promise does not defeat this witness. Astra and sol discuss truthful post-authorization disclosure; neither restores the positive fleet-warning publication duty. The brief openly labels D's disclosure change substantive; it never asserts that this particular duty may be weakened under item 3.

D has a numerical three-reader preference and acceptance. It fails rule 2's separate condition "no verified blocking loss under rule 3". This is not a veto created by a dissenting vote, not an extra void rule, and not a numerical 2–2 preference tie. It is an unresolved question after the one authorized consensus round.

## Rule 6 and other drafting observations

No verified brief error changes Q4's premise, and no tally is void. The full mandatory public wording is accurately supplied at the top of this packet. The forms' defects are candidate defects, not errors in that factual premise. The no-contradiction preflight does not establish candidate acceptability.

Fable/opus correctly identify A/B/C's loose "marker" wording: STO-8, `05-persistence.md:521`, calls the timestamp "not a correlator or one of `OPS-45`'s markers". Their step-(2) replacement anchor also begins inside the bold span; D makes its complete span explicit. The reader votes treat these as landing-format observations rather than substantive acceptance conditions. No edited A, repaired D, partial combination, or add-on disclosure has been made a ballot option. Backticks and quote formatting still require the ordinary landing pass; these unlanded text proposals have not been gate-tested.

The fable vocabulary concern about "authorization" is not used to block D: the relevant CONTEXT.md avoidance is about payment-commitment terminology, whereas these proposed words describe dispatch permission. Follow-ups on the administrative path's retry value, WIR-9a's emitter citation, store inventories and resource-exclusion assertions remain reader follow-ups, not authorized additions to either exact form.

## Formal scope and disposition

The source and actual statements were read. `Restore.lean:35` says "`Live` has no step 8"; `Claim.lean:17` omits "`API-58`'s fan-out transition"; `AccountStatus.lean:13–15` omits the recording transaction and its admission contention; `Reconcile.lean:2` concerns "one create". The API-58 tags are `Funding.reap_refuses_active` and `Fence.suspend`, not a proof of this new dispatch protocol. `Tables.create_before_step9_failed` and `Ledger.close_releases_exact_remainder` retain their classification and arithmetic statements. No formal declaration, guard, fixture or negative control was edited or weakened. No proof of the new guard is claimed.

No form settles. D would additionally need owner approval even without its blocking loss, because replacing an existing public-disclosure duty goes beyond the item-3 delegation of "the exact error and race guard". A/B/C cannot be promoted by extracting a shared mechanics subset that the panel did not select as a separate exact form.

Return the reviewed exact A/D choice to main for the owner under notes rule 4 and the owner's "a tie comes to you" instruction. There is no settled panel recommendation and no further consensus round. Items 13/14 stand; Q1's landing dependency on Q4 remains. This turn changes no tracker status and does not implement any candidate.
