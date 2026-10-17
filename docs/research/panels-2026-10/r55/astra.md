1. **Category: bug, with a framing correction.** `OPS-23` already requires validation “before the driver is called”; only the sale re-test has an explicit exception (`03-operation-lifecycle.md:1671–1681`). Thus its missing-field check must precede step 2, not merely step 5. Its “deterministic failure” lacks a named kind. `API-63` requires the account guard in the correlator transaction and failure “with no provider mutation,” forcing it before step 5 but not before List offers. `PRV-47` requires rejection “without sending that order request,” leaving key-upload timing unspecified. For absence, `OPS-43` says “MUST NOT perform any other step-5 provider mutation”; its settlement paragraph begins “If the re-test finds the offer unsellable,” leaving absence unresolved.

   Additional checks: `PRV-10` requires both “an explicit purchase acknowledgement” and an account “configured to allow ordering”; `OPS-40` requires signed-URL validation “at claim” and “before any provider mutation.” Both need placement.

2. **My proposed order:** retain `OPS-43`’s settled sequence; insert `OPS-23` immediately after closure and before List offers, including required-field and acknowledgement validation. Put applicable `OPS-40` validation there too. After price comparison, run driver validation (`PRV-47`) and both `PRV-10` conditions, then `API-63`’s guarded correlator transaction, then mutation.

   Choose **after step 4**, without an additional account read. This keeps the authoritative account decision adjacent to dispatch, matching `API-63`’s “last write before the ordering call”; earlier offer or price failures win. Qualify its “will fail at it” sentence to cover attempts that reach that check.

   Name missing-field failure `invalid_request`, with a diagnostic identifying the missing field; classify deterministically and release. Using `internal` would contradict that intent: `OPS-11` calls “`network`, `timeout`, or `internal`” ambiguous.

   Precedence should be **first failing check stops subsequent checks; its owning classification governs disposition**. Avoid “first failure settles”: `OPS-11` permits `needs_reconciliation`, and `pv-qga` owns the read-failure question.

3. **Proposed absence outcome:** `invalid_request`, `details.reason: "offer_not_sellable"`, `retryable: false` on error and operation, deterministic `failed`, full commitment release and no setup/first-unit debit (`OPS-43`; `LDG-39`: “Never debited”; `LDG-32`: “released in full”).

   Admission has no explicit absent-offer outcome that I found. `API-7` limits its existing verdict to “not sellable under `PRV-13b` or `PRV-31`”; `DOM-9`’s “remembered ID” sentence does not resolve disappearance. Make **`API-7` the shared verdict’s home**, explicitly extending it to absence in admission’s offer input, with `OPS-43` referencing it for claim-time settlement. Add no provider lookup to the tail (`PRV-42`: “not a provider lookup during … read-only tail collection”). This is a policy amendment, not an inference that absence already means unsellability.

4. **Dependencies:** make `pv-qga` depend on `pv-14b` so its classification cases use the settled sequence; keep it separate because failed-read classification remains necessary regardless of account-check placement (`pv-qga`). `pv-nd6` and `pv-2s6` are independent of this ordering decision, though related to each other through their source-selection questions.

5. **Draft `CNF-278`, fourth barrier:** “Arrange for all preceding claim checks to pass, then commit termination before the guarded correlator transaction; assert `failed`, `conflict`/`account_terminated`, full release, and no provider mutation—the completed List offers read is permitted. Termination after the correlator entry remains potentially dispatched, without administrative failure or release (`API-63`).”

   **Draft `CNF-342`:** “Exercise invalid forwarded values and each failed `PRV-10` condition; assert refusal before any key upload or order request. For auction and catalogue absence in the claim-time List offers result, assert the proposed absent-offer outcome and full release, with no provider mutation (`OPS-43`).”

**Strongest case for the other side (written on request)**

A step-1 account read avoids requests against known-bad credentials; `PRV-41` warns authentication failures can lock out the provider account. Absence also fits `DOM-17`’s “Named resource does not exist” better than unsellability; catalogue reappearance challenges `WIR-9a`’s “cannot be bought on the same request” rationale.