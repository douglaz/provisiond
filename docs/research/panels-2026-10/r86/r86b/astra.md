**Final picks: Q1-A and Q2-B-cited.** These are unconditional votes for the printed forms. I also accept Q1-C0.

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

I read the brief, all embedded prior answers, and `/var/tmp/provisiond-panel-r86/r86b/notes.md` whole, and verified HEAD at `3109b5b44eae17e288cf52aaa976993bd8c5626c`.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule**

I found no additional premise-changing error in this corrected packet. The earlier admission-latitude premise was false; the correction addresses it. Candidate incompleteness discussed below does not independently void this round. These are my individual assessments, not a panel tally.

**Q1: why my previous preference changes**

Sol’s strongest counterexample is decisive: an otherwise valid hard reset, with `hard_reset` undeclared, is expressly enqueued by B and answered `202`. [OVR-2](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L22) says “the server MUST NOT accept an operation a provider has not declared support for.” [OPS-1](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L17) supplies the acceptance connection: “MUST respond `202 Accepted` with that record.”

My previous acceptance of B, and description of C as permitting either phase, were therefore wrong. A worker’s later refusal does not repair the prohibited acceptance.

My earlier funded-retry trace remains a real behavioral difference:

> A never-fenced stalled episode becomes funded; the operator retries while `delete_machine` is unavailable. A refuses admission; B can enqueue an attempt that closes through funded no-call success.

But this is a **new operator request**. Its potential eventual no-call result does not exempt admission from OVR-2. An already accepted or system-enqueued attempt reaching the cancellation decision is different. That distinction changes my preference to A.

C0 correctly preserves the prohibition without claiming phase freedom. I accept it, although A gives implementers useful additional ordering.

**Q1-A and API-64’s guarded write**

I consider the printed placement implementable and deterministic. It requires this sequence:

1. Perform the endpoint’s read-side admissibility check. An episode observed outside `stalled` gets the state refusal.
2. Check `delete_machine`; failure performs no endpoint-state write.
3. If both pass, execute the state-change/enqueue transaction with its existing conditional write. A lost guard gets the state refusal.

[API-64](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1050) explicitly anticipates “a gone-write closed the episode after the operator read it,” and retains the write “guarded on `(id, state = stalled)`.” Thus the read-side check and authoritative write guard are distinct. A’s phrase “after … admissibility checks” does not authorize replacing that guard with the preliminary read.

For simultaneous faults already visible at the read, state precedes capability. If state changes after that read, an unsupported request stops before attempting the write; a supported request can lose the guard. Different concurrent histories can produce different refusals without leaving their execution order unspecified. This interpretation requires no textual repair and is not a condition on my vote.

**Q1-A’s preserved paths and substantive additions**

The operation-to-capability choices remain those in [DOM-10’s mapping](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515). A supplies admission and worker checks for caller/operator operations, while system children remain claim-gated. Its rescue-strategy check followed by `rescue_ssh` adds no separate power/reset requirement.

I checked these boundaries:

- **Cancellation decisions:** [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1075) says “the first step that applies decides.” Its gone/closed branch “settles the attempt `succeeded`”; its funded branch performs the “no-mutation abort.” A preserves those outcomes and the restore/no-rate deferrals without capability checks.
- **Proceeding cancellation:** A checks after the acknowledged fence transaction. [OPS-48’s table](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1295) gives deterministic failure `stalled` with fence “**Unchanged**.” A preserves that disposition and permits no automatic retry.
- **PTR equality:** [PRV-25](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855) places comparison “After the ordinary authorization, capability and `API-16` validation.” A preserves that prerequisite.
- **Install markers:** [OPS-45](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1493) requires rescue `false` to be written “before begin rescue … is dispatched.” A’s refusal precedes that marker. The worker-refusal fixture remains reachable after capability withdrawal between admission and claim.
- **Survived stops:** [OPS-21](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1805) says “The recorded error is a cut-off `conflict`.” A does not replace that record or crash recovery with a new capability result.
- **Release and suspension:** Manual release has no capability gate; operator API-cleanable release checks at admission and claim; delete-enqueued release checks at claim. Suspension’s parent takes no per-machine admission check.

A’s ordering of caller fields, API-written fields, other local validation and capability is a **substantive precedence amendment**. I do not repeat the earlier assertion that it preserves every implementation’s old first error.

**Q2: citation defects are independently verified**

I exercised the existing citation checker’s `EXISTS` function in memory against the relevant API-7 substitutions and Admission docstrings. No source files changed.

| Form’s relevant substitutions | Missing Admission quotations |
|---|---|
| Base | None |
| Original A | The early-refusal sentence, old capability-gate phrase, and old stored-listing sentence |
| Original B | The old capability-gate phrase |
| A-prime / A-cited | None |
| B-cited | None |

This confirms Fable’s objection to the original forms. It is a focused citation check, **not** a whole-candidate gate run or Lean build. The cited forms also restore the selected OPS-43 quotations. My earlier acceptance of original B overlooked its citation defect; B-cited addresses that defect.

**Why A-prime and A-cited still need a substantive formal amendment**

Fable’s strongest argument is that “Machine-kind selection and descriptor construction are outside this model,” so the new absent-offer behavior can enter through the supplied Boolean. That omission does permit choosing a kind outside Lean. It does **not** make the Boolean’s documented meaning interchangeable with “skip the check.”

[Admission.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180) defines it as whether the account declares the create’s ordering capability. `undeclared_ordering_stops_before_tail` quantifies over every sale Boolean and proves early `unsupported`, with no tail. The composition explicitly includes absence and no listing in the sale verdict; `age_preserves_step_5d` preserves the early result at every age.

The decisive trace remains:

> Neither provisioning capability is declared; the account is healthy; no listing exists; other early checks pass.

At the pin, `orderingDeclared = false`, `offerSellable = false` gives early `unsupported`, no collection. A’s forms skip the gate and collect `offer_not_sellable`, suppressing cap and balance. With an unhealthy account, A instead produces the collected account headline.

Selecting a kind cannot turn either undeclared capability into a declaration. Supplying `true` for absence therefore changes the abstraction’s meaning. It also removes this real request from the false-input cases covered by the unchanged theorems. The existing negative-control witness uses a sellable offer, so retaining its green/red behavior would not establish preservation of the absent-offer property.

The repairs openly document the new convention, but they do not amend a declaration or theorem to express it. [ADR-0025](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/docs/adr/0025-a-formalized-clause-lives-in-lean-and-the-markdown-renders-it.md#L175) says adding another hypothesis or narrowing a conclusion “is the weakening `AGENTS.md` describes.” Offer presence is an input condition, not a guard hypothesis covered by its allowance.

Accordingly, this is a changed formalized verdict, not merely an editorial repair. It is also not an argument that A’s policy is intrinsically unacceptable. A presence-aware amendment could be assessed as a substantive departure, explicitly retaining the present-offer protection and disclosing the absent-offer loss. I submit no additional exact form and count no prospective repair as accepted.

**Why I accept B-cited despite the actual dissent**

Opus’s strongest trace is:

> Descriptor `machine_kind: virtual`, only `provision_virtual`; stored/live offer `bare_metal`; both descriptor-selected gates pass and the order proceeds.

That offer violates B’s express obligation: “Every offer returned for the account MUST have that machine kind.” It is **outside B’s conforming input contract**. I do not describe that driver as conforming.

This does not erase DOM-10’s independent outer gate. For conforming B inputs, descriptor kind and offered machine kind coincide; the API and worker must independently check the corresponding capability. A permissive internal ordering flag cannot bypass those checks. B’s added fixture also checks that declaring only the *other* capability does not pass.

The violating-driver trace identifies a useful defensive check that B does not prescribe. It does not establish that B’s only capability gate is driver-internal: B expressly requires external checks. I therefore do not accept it as a rule-3 contradiction. B does not promise A’s dedicated mismatch refusal under corrupted provider output.

**Configuration completeness and cost**

B’s before-enable rejection and retained-identity immutability are implementable and testable behavioral requirements, although they leave the detection and storage mechanisms to implementation.

Describe capabilities says “MUST NOT perform network I/O”; this limits that method, not every deployment-validation activity. Mixed-kind rejection can be established during configuration validation outside it. Identity-change rejection requires retained evidence or a configuration mechanism that makes the binding immutable; a fresh process cannot infer the old kind from the new descriptor alone.

I acknowledge that the pin supplies **no existing machine-kind-history record**. [STO-21](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L684) permits operational state and says it “MUST live in named tables”; it does not provide the missing record or prohibit an implementation from supplying one. A test can retain an account identity, restart with the opposite kind, and assert refusal without prescribing the internal table layout. These are real implementation obligations, not already available mechanisms.

I therefore accept B’s contract as specified. I deliberately accept its domain cost: mixed-kind accounts are excluded, changing kind requires a distinct identity, and retained bindings need enforcement across restarts. Launch-driver homogeneity is not my justification.

**Q2 case coverage**

| Case | Assessment |
|---|---|
| A: present offer, capability withdrawn | Retained kind selects the step-3 refusal before List offers. |
| A: retained kind missing/corrupt | API-written-field failure applies. OPS-23 names `conflict`/`incomplete_record`, `retryable: true`. |
| A: live opposite kind | New step-5 unsellable refusal, before price comparison or mutation; commitment/exclusion released. |
| B-cited: matching capability absent | Early unsupported, including absent offer/no listing; the other capability cannot substitute. |
| B-cited: matching capability present | Existing tail evaluates status, sale and remaining refusals. |
| B-cited: capability withdrawn before claim | Step-3 refusal remains before List offers. |
| Either: only `list_offers` withdrawn | Existing step-4 gate remains distinct. |
| Either: live offer absent | Existing step-5 absence refusal remains. |
| B-cited: live opposite kind | Contract violation; no new dedicated mismatch result is specified. |
| Either: old listing | Present-offer capability refusal stays early; collected refusals precede age; otherwise-clean stale admission is refused. |

**Strongest leave-it-alone arguments, separate from my votes**

For Q1, C0 preserves the essential admission prohibition, outer driver gate and repeated validation without adding detailed local-error ordering. That is sufficient reason to accept C0, although I prefer A’s additional precision.

For Q2, avoiding persistence or configuration expansion for a latent launch case is the strongest argument. It does not supply the missing general kind source or settle absent-offer precedence.

**Composition and verification limits**

Q1-A governs non-create placement; Q2-B-cited supplies create’s kind source. Their API insertions compose without moving replay, suspension, ceilings, claim-time status/closure, field validation or the separate List-offers gate. Purchase-tail ranks, the unhealthy-account-before-age settlement, stored-listing admission without a provider call, and the Form H header default remain fixed.

No source, Git, tracker or panel record was edited. No Nix gate, Lean command, build, subagent or background work ran. The final worktree status was clean.