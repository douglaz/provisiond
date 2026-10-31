My final preferences are **Q1-A** and **Q2-B**. **Q1 needs a corrected re-ask under notes.md rule 6**: the brief omits an existing admission obligation that changes its premise. The assessments below are my individual answers, not a panel settlement.

I verified HEAD as `3109b5b44eae17e288cf52aaa976993bd8c5626c`, read notes.md and the supplied historical verification packet, and made no changes or build invocations.

**Q1 exact-form assessments**

| Form | Assessment |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **CANNOT ACCEPT** |
| Q1-C | **CANNOT ACCEPT as the offered phase-discretion resolution** |
| Final preference | **Q1-A**, subject to the corrected re-ask |

The premise-changing omission is **OVR-2**: “the server MUST NOT accept an operation a provider has not declared support for.” [00-overview.md:22](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L22). The HTTP acceptance interpretation is supported by **OPS-1**’s “MUST respond `202 Accepted` with that record.” [03-operation-lifecycle.md:17](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L17).

Concrete Q1-B counterexample: an authenticated, otherwise valid hard-reset request names a provider account without `hard_reset`. B expressly enqueues it despite that missing capability, returns `202`, and later fails it in the worker. That violates OVR-2 before the otherwise-correct worker refusal occurs. This is a quoted normative blocking loss, not a missing new test.

Consequently, the question cannot treat admission refusal and claim-only refusal as equally permitted by the pinned set. **Rule 6 requires voiding Q1’s tally and re-asking with OVR-2 included.** My objections to B and C rest on this verified omission.

C’s literal no-edit action preserves OVR-2 and causes no new regression. I cannot accept its advertised resolution—leaving admission versus execution to implementations—because that freedom is already constrained. A corrected no-change argument acknowledging OVR-2 would be a different answer; I am not submitting it as an alternative form.

A supplies useful placement and precedence while retaining the outer gate required by **DOM-10**: “There MUST be no operation whose only gate is a driver-internal check.” [01-domain-model.md:515](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515).

The operation coverage below follows DOM-10’s mapping table at that location:

| Operation | Assessment of A’s proposed treatment |
|---|---|
| Power on/off/reboot; hard reset | `power_control` and `hard_reset`, respectively; admission check and worker recheck use their running descriptors. |
| `provider_native` + `catalog` | `native_rebuild`; no rescue prerequisite is invented. |
| `rootfs_via_rescue`; `raw_disk` | Their respective strategy capability, then `rescue_ssh`, before rescue. No separate power/reset capability is inferred: PRV-15 says begin rescue must “initiate the reboot or reset needed to enter it.” [02-provider-contract.md:722](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L722) |
| `provider_catalogue` | `install_via_provider_catalogue`; the added check does not eliminate yielding during import. RSC-41 still requires import and polling “while **yielded**” and revalidation upon reacquisition. [06-rescue-install.md:503](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L503) |
| Rescue inventory | `rescue_ssh`; refusal precedes its rescue marker. |
| Reverse DNS | `reverse_dns`, after local validation and before equality settlement. |
| Delete/cancel | `delete_machine`; exposure-reducing attempts retain the special ordered path discussed below. |
| Operator retry | Admission checks `delete_machine`; its fresh attempt repeats the worker gate if cancellation actually proceeds. |
| Attachment release | An operator’s API-cleanable request checks before admission and at claim. A delete-enqueued release checks at claim, without an enqueue gate. A manual release checks neither. A release does not inherit cancellation’s no-call exemption merely because its machine is gone. |

A changes the explicitly described API tail by adding a pre-enqueue refusal. A service returning `202` for already-known missing support, however, was already inconsistent with OVR-2. A also newly fixes local-check precedence: caller fields, API-written fields, other applicable validation, then capability. It preserves earlier validation refusals rather than replacing them with `unsupported`.

For an operator retry of a funded, null-fence episode with missing delete support, A rejects admission before a worker could close the episode through a funding abort. That observable difference must be disclosed. It concerns a new operator request; it does not replace an accepted system attempt’s required claim-time success.

The critical worker paths remain intact:

- **Restore grace:** OPS-41 says a claim under null/future grace “defers, and writes no fence.” A’s capability check follows that decision, so missing support cannot turn this defer into terminal failure. [03-operation-lifecycle.md:997](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L997)
- **Gone/closed and renewed funding:** OPS-41’s first applicable step decides; its gone/closed branch “settles the attempt `succeeded`,” and its funded branch performs the “no-mutation abort.” Both bypass A’s capability check. The paused-grace and no-rate deferrals likewise remain deferrals. [03-operation-lifecycle.md:1075](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1075)
- **Proceeding cancellation:** only after an acknowledged fence transaction can missing support fail the attempt. OPS-48’s deterministic-failure row gives `stalled` and fence “**Unchanged**”; A preserves that disposition and authorizes no timer retry. [03-operation-lifecycle.md:1295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1295)
- **Stopped before dispatch:** CNF-312’s survived-stop prefix still requires “`failed` with cut-off `conflict`” before the fence; its crash prefix still requires startup `needs_reconciliation`. Capability placement does not replace either prefix. [10-conformance-checklist.md:2558](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2558)
- **Same PTR:** PRV-25 places equality comparison “After the ordinary authorization, capability and `API-16` validation.” A preserves the supported no-call success; missing capability remains a refusal. [02-provider-contract.md:855](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855)
- **Install markers:** OPS-45 requires rescue `false` “before begin rescue … is dispatched.” A refuses before that write, preserving CNF-302’s capability-refusal outcome: `failed`, `rescue_exit: "none"` and a null rescue marker. [03-operation-lifecycle.md:1493](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1493), [10-conformance-checklist.md:3049](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L3049)

A keeps system enqueue distinct, including suspension children and delete-generated attachment releases. It adds no non-purchase money gate.

**Q2 exact-form assessments**

| Form | Assessment |
|---|---|
| Q2-A | **CANNOT ACCEPT as the complete printed form** |
| Q2-B | **ACCEPT** |
| Final preference | **Q2-B** |

A’s stored-kind design handles present offers and queued restarts coherently. Its absent-offer exception nevertheless changes a formalized verdict beyond the expressly named CNF-55 fixture amendment.

The checked model defines the supplied Boolean as whether the provider account declares the create’s ordering capability. Its theorem **`undeclared_ordering_stops_before_tail`** returns `{ refusal := some .unsupported, tail := none }` for **every** tail input. [tools/formal/Provisiond/Admission.lean:1180](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180). The same file expressly includes offer absence and no stored listing in those supplied sale inputs: “There is no separate no-row refusal or presence policy here.” [Admission.lean:1203](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1203). **`age_preserves_step_5d`** preserves that early result at every age. [Admission.lean:1251](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1251)

Concrete trace: a healthy provider account declares neither provisioning capability, and no listing is stored. A skips the ordering check and reaches collected `offer_not_sellable`; the pinned formal composition returns early `unsupported` without collection. With an unhealthy account, A instead makes the account refusal the collected headline.

This does not permit a purchase or spend money. It **does bypass the early-refusal guard’s checked precedence**. A needs a substantive presence-aware model amendment and corresponding theorem changes. AGENTS.md requires “Change the declaration and the Markdown together.” [AGENTS.md:14](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/AGENTS.md#L14). The printed form supplies none. Reinterpreting `orderingDeclared` as automatic success for absence would also change its documented meaning.

Thus A’s absent path has an additional formal collateral change, beyond its disclosed fixture/phase amendment. I do not classify this candidate incompleteness as another premise-changing error that voids Q2.

A’s remaining proposed outcomes are sound in isolation: retained-kind loss/corruption becomes the API-written `incomplete_record` failure before provider requests; capability withdrawal remains before List offers; live absence fails after the read; opposite live kind newly fails before price comparison or mutation. That consistency refusal is a substantive addition needed to avoid dispatching using a different kind from the one whose capability was checked.

B preserves the existing early result using an explicit new source. Its proposed descriptor restriction is a real domain cost, which I accept deliberately—not an existing prohibition inferred from launch drivers.

| Case | B’s proposed result |
|---|---|
| Present offer; both capabilities | Select only the capability matching descriptor `machine_kind`; proceed to the existing tail. |
| Only matching capability | Same gate result. |
| Only the other capability, or neither | Early `unsupported` naming the matching capability. |
| Absent offer/no stored listing | The same capability gate still runs; after it passes, ordinary absent-offer collection applies. |
| Unhealthy account | Missing capability still stops before collection; otherwise the account refusal leads the tail. |
| Old listing | Missing capability still refuses early. After a passing gate, collected refusals retain precedence; an otherwise clean stale purchase gets the existing retryable `provider` refusal. |
| Mixed-kind account; invalid/missing descriptor kind; changed kind under retained identity | Configuration refusal before enabling that provider account. |
| Restart before claim with matching capability withheld | Step 3 refuses before List offers, preserving CNF-55. |
| Live offer absent | Existing step-5 refusal and pre-order release apply. |
| Live offer changes kind | A successful opposite-kind List offers result is forbidden by B’s proposed PRV-44 contract. B does not specify A’s dedicated mismatch error for a driver breaching that contract. |

The pinned claim ordering remains “caller-supplied fields … then … fields the `api` wrote … then the capability gate,” followed by “Gate on `list_offers`.” [03-operation-lifecycle.md:788](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L788). B changes the kind source without moving those gates, status or channel closure.

B also retains the stored-listing policy and header default. API-7’s age refusal applies only “If the tail has collected no refusal”; neither an unhealthy-account refusal nor an absent-offer refusal is displaced by age. [04-api-contract.md:264](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L264).

**Requested counterarguments, separate from my votes:** For leaving Q1 alone, the strongest argument is that OVR-2’s admission obligation, DOM-10’s pre-driver obligation and OPS-23’s repetition obligation already establish the essential safety requirements; detailed non-create failure ordering could remain unspecified. For leaving Q2 alone, the strongest argument is avoiding persistence/configuration expansion for a latent launch-driver case. That leaves the general contract gap unresolved; it supplies no total mixed-account or absent-offer kind source.

I see no complete smaller form preserving mixed-account support **and** unconditional capability-first absence behavior using only the quoted existing sources. It must amend absence precedence, add an owned total kind source, or restrict provider-account shape. I submit no alternative landing text.

Together, **Q1-A + Q2-B** apply to separate operation classes. Their API changes compose without moving replay, security or ceilings, and without changing purchase-tail ranks or the stored-listing age decision. My acceptability sets are **Q1 `{A}`**, pending the corrected re-ask, and **Q2 `{B}`**. No other reader’s vote or panel settlement is inferred.