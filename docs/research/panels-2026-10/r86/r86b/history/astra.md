**Final picks: Q1-B and Q2-B.** These are votes for the printed forms, without repairs or combinations.

I read `notes.md` whole and verified HEAD at `3109b5b44eae17e288cf52aaa976993bd8c5626c`. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**. I found no premise-changing brief error requiring either question’s tally to be voided. The Q2-A omission below affects that candidate’s completeness, not the existence of Q2.

This is one reader’s ballot. Grok’s absence is not a vote; settlement remains the owner’s three-of-four fallback.

**Q1**

| Exact form | Verdict | Assessment |
|---|---|---|
| Q1-A | ACCEPT | Specifies both phases, with a substantive admission-policy cost, including operator retries. |
| Q1-B | ACCEPT | Preferred: specifies execution ordering while preserving admission access to cancellation decisions. |
| Q1-C | ACCEPT | Defensible explicit implementation latitude; it does not establish deterministic cross-implementation ordering. |

My preference is **Q1-B** because the worker has to check its own running descriptor anyway, and the cancellation decision can legitimately eliminate the need for provider support.

Applying the unchanged mapping in [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L522), A and B cover the requested operations as follows:

| Operation | Required checks under A/B |
|---|---|
| Power on/off/reboot; hard reset | `power_control`; `hard_reset`, respectively |
| `provider_native` + `catalog` install | `native_rebuild` |
| `rootfs_via_rescue` install | `install_rootfs_via_rescue`, then `rescue_ssh` |
| `raw_disk` install | `install_raw_disk_via_rescue`, then `rescue_ssh` |
| `provider_catalogue` install | `install_via_provider_catalogue` |
| Rescue inventory | `rescue_ssh` |
| Reverse DNS | `reverse_dns` |
| Delete/cancel; operator retry | `delete_machine`, subject to the cancellation-specific ordering |
| API-cleanable attachment release | `delete_machine`, for both operator requests and delete-enqueued releases |
| Manual attachment release; refresh | No added capability gate |

The rescue prerequisite does not imply an additional power or hard-reset gate: [PRV-15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L722) says begin rescue “MUST both activate the rescue environment *and* initiate the reboot or reset needed to enter it.”

For A, caller/operator requests receive admission and worker checks; internally enqueued children receive only the worker check. For B, both origins receive the worker check only. A suspension parent does not acquire per-machine admission checks in either form.

**Concrete phase difference.** Submit a valid hard-reset request while the API descriptor lacks `hard_reset`. A refuses without creating an operation. B accepts the operation; a worker still lacking the capability records `unsupported`, non-retryable, before dispatch. If the worker’s restarted descriptor now supplies it, B permits execution. C leaves this phase choice open. The base’s [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515) says “before the driver is called,” not “before admission”; A’s earlier refusal is a new observable obligation, not an existing requirement discovered in the text.

**Validation precedence.** A/B expressly prioritize caller-field validation, API-written-field validation, other local validation, then capability. Thus a malformed request or expired signed URL together with missing support receives the validation refusal first. This resolves previously unspecified combinations; it should not be described as preserving every implementation’s former first error. [OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018) requires validation repeated “before the driver is called”; [OPS-40](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L744) requires the claim-time URL failure “before any provider mutation and before rescue is entered.”

Machine eligibility remains separate: [DOM-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L401) says “The gate reads the machine’s own copy of that list.” Neither candidate turns an eligibility entry into a capability declaration. Catalogue installation also retains [RSC-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L503)’s later obligation: “On re-acquiring the machine the operation MUST re-validate before the rebuild.”

**Cancellation precedence.** Consider an exhaustion cancellation already queued when support disappears:

- Renewed funding: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L978) requires the worker to “make no provider call, settle the operation `succeeded`” when the re-derived runway is future. A/B take this branch without checking capability.
- Open restore grace: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L996) says the claim “defers, and writes no fence.” Missing support does not replace that defer with failure.
- Gone machine or closed episode: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1080) says “settles the attempt `succeeded`”; A/B preserve that no-call branch.
- Proceeding cancellation: capability follows the acknowledged fence transaction. Failure stalls the attempt’s episode without clearing its fence, matching [OPS-48](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1300)’s `failed` row: “`stalled`” and “**Unchanged**.”

A’s important additional cost is **operator retry admission**. Start with a never-fenced stalled episode, fund the machine, then retry while `delete_machine` is unavailable. A refuses before enqueue, so no worker reaches the funded no-call success. B allows that decision. This is a real restriction on access to the success path, even though A preserves its order once an attempt reaches execution. I accept A as an explicit admission-policy choice, not as observationally equivalent to B. I do not claim this alone falsifies [CNF-312](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2558), whose fixture specifies “no other admission refusal.”

**Same PTR and markers.** [PRV-25](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855) places comparison “After the ordinary authorization, capability and `API-16` validation.” Missing support therefore still prevents identical-PTR success; A/B do not newly delete that success’s prerequisite.

Capability refusal before rescue leaves the rescue marker null and produces `failed` with `rescue_exit: none`, preserving [CNF-302](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L3049). A survived stop before dispatch remains a different error: [OPS-21](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1805) says “The recorded error is a cut-off `conflict`.” The new checks do not authorize replacing that stop record with `unsupported`, setting markers early, or changing crash recovery.

The strongest argument for C is that the existing outer pre-driver gate already protects dispatch, while mandatory admission rejection adds little protection and prevents requests from benefiting from changed worker configuration. That is a policy argument for leaving placement open—not evidence that deterministic placement already exists.

**Q2**

| Exact form | Verdict | Assessment |
|---|---|---|
| Q2-A | CANNOT ACCEPT | Its disclosed absent-offer change also conflicts with an unchanged formal admission verdict; the complete form supplies no corresponding formal amendment. |
| Q2-B | ACCEPT | Preferred among the complete printed forms. Preserves early refusal by adding an explicit, consequential account-shape restriction. |

**Q2-A’s additional collateral change.** The relevant omission is in [Admission.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180). Its input is explicitly whether the account declares the create’s ordering capability. `undeclared_ordering_stops_before_tail` proves an unsupported refusal with no tail “regardless of the tail’s snapshot inputs.” [The composition’s documentation](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1203) explicitly includes offer absence and an empty offers set. `age_preserves_step_5d`, at line 1252, preserves that result at every age.

Concrete counterexample:

1. Neither provisioning capability is declared.
2. The account is healthy; no stored listing exists.
3. Other early checks pass.
4. The existing formal composition, with `orderingDeclared = false` and `offerSellable = false`, returns `unsupported`, with no tail.
5. Q2-A skips the capability check and returns the collected `offer_not_sellable` result.

Neither provisioning capability being declared makes the Boolean false whichever machine kind might be selected; this does not require guessing one from the offer ID. Passing `true` merely to reach the tail would change the documented meaning of the input.

This is broader than the explicitly disclosed CNF-55 fixture qualification. It changes a checked verdict and needs a substantive formal amendment. [AGENTS.md](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/AGENTS.md#L12) requires “Change the declaration and the Markdown together.” A’s exact landing text does not do that. I inspected these definitions; I did not run Lean.

This finding does **not** establish that the absent-offer policy is intrinsically wrong. Nor does it contradict the fixed panel-E settlements: A preserves collected-refusal ranking and keeps age after collection. It establishes that A is not complete as printed. I am not voting for an unprinted repair.

Apart from that blocker, A’s proposed behavior is coherent:

- Present offer: select its kind from the same stored snapshot, independent of age; only the matching provisioning capability matters.
- Absent offer/no listing: skip selection; collect absence, with unhealthy account first when applicable; suppress cap/balance.
- Restart: use retained kind before List offers. Missing/corrupt kind receives [OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2027)’s API-written-field result, `conflict`/`incomplete_record`, retryable.
- Live absence or changed kind: reject after List offers without price comparison or mutation. The mismatch rejection is an additional safety rule.
- Mixed account: supported without interpreting provider `kind` as machine kind.

**Q2-B’s behavior and cost.**

| Situation | B’s outcome |
|---|---|
| Matching capability absent; other capability present or neither present | Early unsupported refusal, including absent offer/no listing |
| Matching capability present; either alone or with both declared | Pass ordering gate; evaluate the existing tail |
| Healthy, fresh, present sellable offer | Eligible for admission if remaining checks pass |
| Unhealthy account, or absent offer, after passing ordering gate | Existing collected refusals and suppression |
| Old listing | Existing collected refusals retain precedence; stale refusal applies only after otherwise successful collection |
| Queued create; matching capability withheld before claim | Step-3 unsupported refusal, before List offers |
| `list_offers` withheld instead | Existing step-4 refusal |
| Live offer absent | Existing step-5 absent-offer refusal |
| Mixed account, invalid descriptor kind, retained identity changes kind | Configuration rejected before enabling |
| Live offer changes kind | Violates B’s explicit provider-output contract; B adds no separate runtime mismatch error |

Thus B preserves [CNF-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L340)’s “no provider request, including no List offers read,” and [CNF-364](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L140)’s distinct List-offers gate. Claim-time status and closure remain ahead of validation and capability because B replaces only step 3.

B’s restriction is **not already implied** by the current domain. [The provider-account definition](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L49) describes configured credentials and a stable identity; it does not require one machine kind. I accept B’s explicit restriction as the cost of a total early source, but not on the argument that current launch drivers happen to be single-kind. It is unnecessary in principle: A demonstrates another design direction, though its exact patch is incomplete.

No supplied narrower form preserves mixed-account support, an unconditional absent-offer early refusal, and a total owned kind source. Achieving that combination would require another complete proposal. The strongest argument for leaving Q2 alone is limited launch exposure; it supplies neither a total source nor a resolved refusal order.

**Combined choice:** Q1-B governs non-create execution; Q2-B governs create selection. Neither relocates replay/security/ceilings, purchase-tail refusal ranks, or stored-listing age handling. No source, tracker, Git state, or panel record was changed; no builds, gates, subagents, or background work ran.