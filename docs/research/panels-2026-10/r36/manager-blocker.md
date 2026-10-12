STATUS: blocked

I reviewed `4830cd02890fa37aea205dd8cd0e2b4e8a1f9876..bd737c97fc3a8737c4ed113452924a4fe68dd9e3`; the result is FAIL pending specification-owner clarification. No second implementation round was commissioned. ADR-0034's Q10 refresh decision remains settled; comment 250 is not reopened.

## Blocking question: reserved capacity versus admitted continuations

Document: `docs/adr/0034-tenant-traffic-cannot-spend-the-providers-request-budget-the-system-needs.md`, Decision 3 and Consequences, read together with its 2026-10-08 amendment.

Passages:

- Decision 3: “The deployment spends it before any provider call” and “may lower it but never raise it.”
- Decision 3: “A stated share of it is reserved” for the named system paths.
- Decision 3: “Admission is decided once per operation, before its first provider call. A later request of an admitted operation is never refused locally”.
- Consequences: “It never reaches the system's own deletes.”
- Implemented `PRV-46`, in `02-provider-contract.md`: “The named system paths MUST retain access to that reserve” and “A later request of an admitted operation MUST NOT be refused locally by this budget; each such request still spends budget before dispatch.”

The implementation selects unconditional dispatch for admitted continuations. `tools/formal/Provisiond/ProviderTraffic.lean` computes remaining capacity as declared limit minus spent requests, then bypasses the reserve check for any admitted operation. Its model explicitly covers one period without refill. `smallBudget` in `tools/formal/Provisiond/Witnesses.lean` has limit 2 and reserve 1. `continuedOperation` dispatches the same tenant operation three times; the current-policy witnesses prove three calls and three spent requests. After the first call only the reserve remains; after the second none remains; after the third accounting is negative. The subsequent system path can still pass the local dispatch predicate, but that is not reserved provider capacity. The system witness exercises system access immediately after the first tenant call, before the continuations consume the reserve. `CNF-338` explicitly asks for continuation “when total available capacity is exhausted.”

Readings with different observable behavior:

1. “Never refused” prevents a failed settlement or renewed admission decision, while dispatch can wait for tenant capacity or use capacity already secured at admission. System capacity remains reserved.
2. “Never refused” permits immediate continuation dispatch even through the reserve and beyond the limit. The reserve protects only against new admissions, and the stated system-capacity guarantee has a further residual exception.

The ADR and Q10 do not choose between these continuation semantics. Its exclusion of the provider's throttled-poll defect does not expressly authorize locally spending the system reserve. This is a question about what the specification promises, not just a choice of Lean representation.

Recommended clarification: preserve real reserved capacity, and explicitly state whether admitted tenant continuations wait without failure when only the reserve remains, including how any wait interacts with operation deadlines. If the owner instead accepts reserve consumption by admitted continuations, state that residual explicitly. An alternative that secures capacity at initial admission also needs a defined bound for multi-request operations. I have not selected or implemented any of these answers. After the owner settles it, the model and conformance should exercise tenant admission, continuation depletion, and then system work in the same sequence.

## Additional owner questions from the review

**Operator-origin eligibility.** `PRV-46` names “tenant-initiated” operations for refusal and reserves capacity for funding cancellations, other system-detected episodes, automatic resolution and account sweep. `WIR-10a` separately defines `requested_by` as `{caller, system, operator}`. `API-64` stamps a retry “`requested_by: operator`, with its non-null `episode_id`”; `API-65` enqueues a release “with `requested_by: operator`”. An episode retry can plausibly be classified by its system-detected episode rather than its initiating principal, but a standalone operator attachment release has no explicit mapping to either named class. The new formal `Origin` omits an operator case.

The readings are classification by initiating actor, versus classification by the exposure-reducing/evidence path irrespective of actor. They differ at reserve-only capacity. Recommendation: state eligibility for operator episode retries and standalone operator releases explicitly, preserving the separate operator ceilings. Do not infer that all operator traffic receives reserve access or that none does.

**Refusal surface.** `PRV-46` says “before its first provider call” and “refused deterministically with `rate_limited`”, without naming the stage or observable response. `API-7`'s applicable endpoint row says “enqueue an operation, then `202`”; `API-50` says “Every `429` anywhere MUST itself carry `Retry-After`”. The competing readings are a synchronous HTTP rejection before creating an operation versus an asynchronous failed operation before dispatch. Recommendation: explicitly identify the stage and response, preserving the existing asynchronous operation surface for requests already enqueued. This question is narrower than Fable's claim: error details are not missing. `WIR-9a` requires `retry_after_ms` for `rate_limited`, and `WIR-10b` says operation errors are “exactly `WIR-9`'s inner object”; that requirement already reaches worker-settled errors.

These questions are recorded in pv-ucs.2 comment 270. No new beads were created. No adviser consultation was run: these are specification-owner questions, and an adviser vote cannot settle them.

## Panel disposition

- **Sol:** accept the reserve/continuation blocker, supported by the concrete current-policy witness above.
- **Fable:** retain the operator-eligibility and refusal-surface questions in the narrowed form above. Reject the assertion that worker errors escape the required pacing detail, because the wire error contract already supplies it. Reject adding a duplicate scope-validation requirement: `PRV-46` already says “the period and scope remain the declaration's.” An operator's recorded evidence can satisfy the new PTR rule only if it establishes provider state; a bare assertion is not newly authorized by the phrase “authoritative resolution.” No additional defect was demonstrated there.
- **Astra:** reported no findings. Its clean gate evidence is compatible with the behavioral gap; green gates do not resolve the owner question.
- **Opus:** `REVIEWER FAILED (exit 124)`; no substantive review. A timeout is not agreement or disagreement. No reviewer had a `REVIEWER NOT RUN` file.

Cosmetic suggestions are listed once and dropped: glossary additions/terminology tightening for request reserve and scope; narrowing the placement of the new hypothesis in `only_the_override_is_uncapped`; replacing the historical ceiling-list copy in `DOM-20`; refining the combined guard record's requirement tag; and tightening the PTR-resolution wording. None is filed as a separate issue or grounds for another round.

Fable reports using and deleting `/tmp/pv-ucs2-review-20261008`, contrary to the explicit repository-only scratch restriction. I did not reproduce or access that path. The Implementer's report describes one in-repository copy restored between controls and deleted afterward; its scratch directory is absent. No `rejected-*` artifacts were present in this run.

## Work, verification, history and tracker state

The Implementer committed the refresh cache and Q10 cases, nullable machine observation field, reverse-DNS ceiling and established-value no-op, request-budget declaration and admission model, conformance obligations, CI controls and verification report. The refresh/failure distinction and existing order-budget behavior are preserved in the reviewed change. The reserve implementation is not accepted as task completion; its already-existing commit remains in history unchanged.

I ran `nix develop --command bash tools/check-all.sh` unpiped before review and again before this report. Both completed with exit 0. I inspected the workflow changes, witnesses and `docs/verification/pv-ucs.2-2026-10-08.md`; I did not independently rerun the negative-control matrix. The Implementer's report records the initial failures, repairs and successful final affected-control rechecks. No runtime conformance is claimed.

History:

- Run base: `4830cd02890fa37aea205dd8cd0e2b4e8a1f9876`.
- Implementer's existing commit: `bd737c97fc3a8737c4ed113452924a4fe68dd9e3`, `spec: apply ADR-0034 provider traffic controls (pv-ucs.2)`.
- Current HEAD: `4cd2b9389b14a785baa316e01c28efacd18b67d2`, `beads: record blocked ADR-0034 review (pv-ucs.2)`.

The Manager's only tracked change was the accepted review record on pv-ucs.2, exported through `br` and committed with ordinary Git, without bypassing hooks/signing or rewriting history. No specification, model or gate code was edited by the Manager. Git's working tree is clean; this ignored rloop report is the only new run artifact.

Branch A explicitly required closing the tracker task even for a blocked outcome. Accordingly pv-ucs.2 is **closed with a blocked reason**, not marked successfully implemented: its close reason and comment 270 say that owner clarification is outstanding and this is administrative run closure, not acceptance. Reopen this same ticket after the owner answers; do not create another bead. No other ticket changed.
