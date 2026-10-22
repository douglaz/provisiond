**Q1 — AMEND A. Owner:** mandatory capability declaration and retry guidance are policy choices.

Keep A’s `DOM-16` amendment and `PRV-10` error sentence, including `retryable: false`. Replace its positioning sentences with “For admission and claim ordering, see `API-7` and `OPS-43`.”

Add to `API-7`:

> On create, after step 5c and before tail collection, check the ordering capability under `DOM-10`. Failure stops admission and is not collected.

Add to `OPS-43` step 3:

> Within this step, validate caller-supplied fields first, api-written admission fields second, and the ordering capability last.

After 5c preserves `API-7`’s “an equal fingerprint under the same `(principal, key)` returns the stored result”. A disabled configuration needs deliberate intervention; possible future reconfiguration does not compel `true`.

Touches: `DOM-16`, `PRV-10`, `API-7`, `OPS-43`, `CNF-55`.

**Q2 — REJECT; choose B with explicit retryability. Owner:** precedence and caller retry guidance require a choice.

Replace step 4 with:

> Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result. Gate failure carries `retryable: false` on both the error and the operation view.

The `credentials_rejected` account returns `conflict`/`state`, `true`, at step 1. Assuming healthy status, the closed-channel account returns `rate_limited`, `true`, at step 2. Neither reaches the capability gate. An otherwise passing account lacking `list_offers` gets `unsupported`, naming its provider account and `list_offers`, with `false`, matching Q1.

Unamended A supplies no winner among simultaneous step-3 failures; Q1’s subordering resolves that problem.

Touches: `OPS-43`, `CNF-342`, `CNF-278`.

**Q3 — REJECT; choose B with a narrower omission exception. Owner:** malformed generated data need not inherit missing-field recovery policy.

Add to `OPS-23`:

> At claim-time boundary validation, a present caller-supplied value rejected by validation fails `invalid_request` naming its field, with `retryable: false` on both the error and the operation view. A present value written by the api, worker or driver that fails this validation fails `internal`, with `retryable: false` on both. These checks use the missing-field checks’ timing and settlement.

Preserve `PRV-47`’s fixed caller sentence; append:

> A value written by the api, worker or driver that this validation rejects fails `internal`, with `retryable: false` on both the error and the operation view.

Engine-written kind: **`internal`**. Retryability: **`false`**. Missing API fields retain their fixed exception. Keep `CNF-342`’s coverage and distinguish writer origins.

Touches: `OPS-23`, `PRV-47`, `CNF-34`, `CNF-342`.

**Q4 — AMEND A. Owner:** deterministic field selection is a wire-contract choice.

Add to `WIR-9a`:

> An `invalid_request` naming a rejected request-body field MUST carry `details.field`, an RFC 6901 JSON Pointer identifying its location, including the intended location of a missing field. Nested fields retain their full paths. Within the failing validation stage, select the lexicographically least escaped pointer using unsigned UTF-16 code units; a shorter prefix sorts first. This selection does not reorder validation stages. Engine-written values do not carry `details.field`.

Replace `WIR-2`’s “first unknown field” with:

> unknown field selected by `WIR-9a`’s pointer order

The stored body preserves names, nesting and array positions; original object-member order is unnecessary. Q3’s engine errors have no request-body pointer.

Touches: `WIR-9a`, `WIR-2`, `CNF-34`, `CNF-175`, `CNF-342`.

**Q5 — ACCEPT A. Owner:** choose `state` for this synchronous assignment refusal.

This follows the adjacent `WIR-48` clause, “naming one not flagged assignable is `conflict` with `details.reason: "state"`”, and avoids expanding the synchronous use of `account_terminated`. Add a terminated-assignment fixture without changing the exclusions.

Touches: `WIR-48`, `CNF-248`.

**Q6 — Owner:** land pv-p3k/pv-009 together, pv-gpw/pv-ss4 together, and pv-7j3 separately; the last has no dependency on the claim-validation decisions.

**Against my picks — written on request**

- **Q1:** The operator can restore the flag without changing the request, supporting `true` by analogy with recoverable account status. A collected refusal would also expose independent purchase faults.
- **Q2:** Checking both capabilities together at step 3 is simpler and establishes all required capabilities before entering driver-related work.
- **Q3:** Fresh admission can repair malformed historical API-generated values just as it repairs omitted ones; `internal`/`false` may unnecessarily stop a recoverable purchase.
- **Q4:** Selecting the least pointer requires evaluating the whole failing stage. Naming any one rejected field permits simpler short-circuit validators.
- **Q5:** `account_terminated` conveys permanent loss directly; `state` makes callers obtain another observation to distinguish termination from assignability.
- **Q6:** One Run could update overlapping conformance fixtures once and demonstrate the combined behavior atomically.

**Brief errors:** None found. The checked quotations and negatives match `07bac41`. Read-only review; no files changed or gates run.