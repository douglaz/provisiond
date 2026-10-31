My final picks are **Q1-A** and **Q2-B-cited**, exactly as printed. These are individual ballots, without conditions or an inferred panel settlement.

| Exact form | Verdict |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **CANNOT ACCEPT** |
| Q1-C0 | **ACCEPT** |
| Q2-A | **CANNOT ACCEPT** |
| Q2-B | **CANNOT ACCEPT** |
| Q2-A-prime | **CANNOT ACCEPT** |
| Q2-A-cited | **CANNOT ACCEPT** |
| Q2-B-cited | **ACCEPT** |

I verified the pin, read this brief and `notes.md` whole, and applied **notes.md rule 6 exactly as written; this prompt adds no void rule**.

For Q1, the correction changes my assessment of the no-edit option. C0 expressly preserves OVR-2’s “the server MUST NOT accept an operation a provider has not declared support for.” It grants no phase freedom contrary to that obligation. My historical rejection of C’s advertised latitude therefore does **not** carry over to C0. [OVR-2](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L22)

B remains unacceptable. The strongest concrete trace is the otherwise-valid hard reset without `hard_reset`: B expressly admits and enqueues it, whereas OVR-2 forbids acceptance. OPS-1’s “MUST respond `202 Accepted` with that record” confirms the observable acceptance involved. A correct later worker refusal cannot undo that admission violation. [OPS-1](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L17)

Astra’s funded retry distinction is real: a never-fenced stalled episode becomes funded, `delete_machine` is unavailable, and B’s newly admitted retry could close through the worker’s funding abort. But that is **a new operator request** facing OVR-2. It does not establish permission to admit missing support. A previously accepted or system-enqueued attempt still reaches its required no-call success under A.

I accept A’s API-64 ordering without requiring a wording repair. The strongest contrary argument is opus’s “`API-64`’s admissibility *is* that conditional write.” The actual requirement distinguishes the eligibility predicate—“admissible only on an episode in `stalled`”—from the transition “by a conditional write guarded on `(id, state = stalled)`.” [API-64](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1050)

A can satisfy both deterministically:

- Evaluate the endpoint’s state predicate before the capability check. A non-stalled episode receives `409 state`.
- For a stalled episode, check capability before the state-change/enqueue transaction. Missing support receives `unsupported`, with no endpoint-state write.
- If capability passes, retain the guarded conditional write. A concurrent close that makes that write affect no row receives `409 state`, with no enqueue.

The preliminary read does not replace the guarded write. An implementation relying exclusively on that write, without A’s preceding admissibility evaluation, would not implement A’s specified precedence.

A’s detailed local error order is a substantive amendment. I do not claim it preserves every implementation’s previous first error. Its admission prohibition is already required; its detailed placement and precedence add determinism.

The operation coverage follows DOM-10’s mapping table: power uses `power_control`; hard reset uses `hard_reset`; each install uses its strategy capability, with `rescue_ssh` additionally checked before a rescue-based install begins rescue; inventory uses `rescue_ssh`; PTR uses `reverse_dns`; delete/cancel and API-cleanable release use `delete_machine`. Manual release and refresh acquire no new gate. PRV-15 already requires begin rescue to “initiate the reboot or reset needed to enter it,” so no additional power/reset prerequisite is inferred. [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515), [PRV-15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L722)

The required exceptional paths remain intact:

- **Restore and cancellation decisions:** OPS-41’s restore claim “MUST defer,” and its gone/closed branch “settles the attempt `succeeded`.” A runs those decisions before capability. Renewed-funding success and the paused/no-rate deferrals likewise bypass the check. [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L995)
- **Proceeding cancellation:** capability follows the acknowledged fence transaction. OPS-48’s deterministic-failure row remains `stalled` with fence “**Unchanged**”; A authorizes neither fence clearing nor automatic retry. [OPS-48](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1295)
- **PTR:** PRV-25 places equality comparison “After the ordinary authorization, capability and `API-16` validation.” A preserves that order. [PRV-25](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855)
- **Install markers and survived stops:** the pre-rescue refusal retains the checklist’s `failed`, `rescue_exit: "none"` and null rescue marker. The survived-stop prefix retains “`failed` with cut-off `conflict`”; capability checking does not replace an already-required stop record. [CNF-302](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L3049), [CNF-312](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2558)

For Q2, the original A/B citation objection checks out. A targeted **in-memory** probe using the citation gate’s normalization confirmed that A removes the corpus sources for the quoted gate sentence and stored-listing sentence; B removes the quoted ordering-gate wording. Those quotations remain in the printed originals’ Lean docstrings. The gate’s EXISTS rule requires such quotations to remain supported by the corpus. I did not run the citations gate or claim a complete candidate build. [Citation rule](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/check_citations.py)

A-prime and A-cited repair quotation problems, but I still cannot accept their formal treatment. Fable’s strongest argument is that “`createPurchaseTail` takes a supplied Boolean,” with machine-kind selection outside the model. That observation is correct, but insufficient for the absence branch.

At the pin, the Boolean answers “whether the account declares the create’s ordering capability.” The theorem `undeclared_ordering_stops_before_tail` quantifies over **all** supplied sale inputs and produces:

```text
{ refusal := some .unsupported, tail := none }
```

`age_preserves_step_5d` carries that result through every age. The surrounding composition expressly includes absence and an empty offers set. [Definitions and theorem](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180), [Age preservation](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1251)

The strongest trace remains:

1. Neither provisioning capability is declared.
2. No listing exists; other early checks pass.
3. The pinned declaration, with `orderingDeclared = false`, returns early `unsupported`.
4. A collects `offer_not_sellable` instead.

No choice between virtual and bare metal makes a declaration exist in that trace. Supplying `true` for absence changes the Boolean’s semantic contract and removes this real absence case from the theorem’s application. The algebraic theorem continuing to prove does not preserve that checked instance.

I therefore regard A’s absence branch as a coherent **policy amendment requiring substantive formal representation**, rather than a previously unspecified selector lawfully completed through comments alone. This is the rule-3 loss: an existing checked absence/missing-support verdict becomes unreachable under the new input convention. The printed comment-only repairs contain no declaration amendment addressing it. ADR-0025’s guard-hypothesis exception does not supply an offer-presence exception: it says adding “any other hypothesis … or narrowing its conclusion” is a semantic weakening. [ADR-0025](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/docs/adr/0025-a-formalized-clause-lives-in-lean-and-the-markdown-renders-it.md#L175)

This objection does not deny A’s other useful behavior. Its retained kind supplies the pre-List-offers claim gate; missing/corrupt kind receives the API-written `incomplete_record` disposition; live absence or opposite kind refuses before ordering, releasing the commitment and exclusion. Its disclosed absent-offer precedence change also preserves the collected refusal ranks. Those facts do not complete the printed formal amendment.

I accept **B-cited**, deliberately accepting its domain and configuration cost.

The strongest fable/opus trace starts with “A descriptor declares `machine_kind: virtual` and only `provision_virtual`,” followed by a bare-metal offer. That driver violates B’s new duty: “Every offer returned for the account MUST have that machine kind.” It is **outside B’s conforming input contract**. I withdraw treating that trace as a conforming-input demonstration that B loses DOM-10.

DOM-10 independently requires an outer gate: “There MUST be no operation whose only gate is a driver-internal check.” B still supplies that gate in API-7 and OPS-43. Selecting its capability from a typed descriptor is not equivalent to relying on an internal ordering flag; the existing permissive-internal-flag fixture still exercises the external refusal. B does, however, provide no dedicated containment outcome for a driver violating its new homogeneity contract. I accept that limitation expressly. [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515), [CNF-19](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L137)

B’s configuration obligations are implementable and testable as behavioral requirements, although their mechanisms are unspecified. A concrete satisfying implementation can validate the driver/account’s configured sales domain before enabling it and preserve an immutable `account_id → machine_kind` binding across restarts in a named operational table. Its configuration test can enable kind A, retain that identity, restart with kind B, and assert refusal before enablement.

That is a feasibility example, **not additional landing text or a condition on my acceptance**. B requires real validation and remembered identity state; merely adding the descriptor field would not implement it. Describe capabilities’ “MUST NOT perform network I/O” does not prohibit separate configuration validation. STO-21’s “permitted and MUST live in named tables” does not establish that the current schema already stores this history, but neither does it prohibit implementing such operational state. A missing prescribed mechanism is not, by itself, a rule-3 contradiction. [Describe capabilities](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L71), [STO-21](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L684)

B-cited’s consequences are:

| Case | Result |
|---|---|
| Matching provision capability withheld | Early unsupported, including absent offer/no listing |
| Only the other provision capability declared | Same early refusal |
| Matching capability declared | Existing tail runs |
| Unhealthy account or absent offer after that gate | Existing collection, ranks and cap/balance suppression |
| Old listing | Early capability refusal remains; otherwise collected refusals precede the existing stale-listing refusal |
| Matching capability withdrawn before claim | Step-3 refusal before List offers |
| Only `list_offers` withdrawn | Existing step-4 refusal before the read |
| Live named offer absent | Existing step-5 refusal and pre-order release |
| Opposite-kind live offer | Driver-contract violation; no new mismatch error specified |
| Missing/invalid descriptor kind, mixed account, changed retained identity kind | Configuration refusal before enabling |
| Missing/corrupt existing API-written operation fields | Existing OPS-23 disposition |

These are substantive restrictions on future account shapes, not conclusions inferred from launch-driver homogeneity. No retained operation kind is introduced by B.

The requested leave-it-alone arguments are separate from my votes. For Q1, OVR-2’s admission prohibition, DOM-10’s pre-driver gate and OPS-23’s repeated validation already establish the essential protection; detailed error precedence could remain unresolved under C0. For Q2, leaving the latent launch-driver case alone avoids new configuration/history obligations, but leaves the general kind-source question unanswered.

Q1-A and Q2-B-cited compose across non-create and create paths. Replay, security and ceilings remain ahead of them. Claim-time status, closure, caller fields, API-written fields, ordering capability and `list_offers` retain their specified sequence. Neither changes the collected-refusal order, stored-listing age decision or checklist header default.

I broke **no new premise claim in this corrected packet** under rule 6. The original OVR-2 omission is corrected; candidate incompleteness and disputed policy costs do not create another void rule. I submit no alternative form and count no historical ballot forward.

The worktree remains clean. I ran no Nix gate, Lean command, build, subagent or background work.