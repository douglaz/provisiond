1. **C2 is too broad.** `OPS-23` says “A field a previous-release `api` may not have written”; it does not limit that field to server-derived data. Counterexample: a future release requires a new caller acknowledgement. `API-14` illustrates that obligation: “Absent or false MUST fail `400`.” Finishing the roll cannot supply missing caller intent.

2. **Pick: a better shape—1′ with field-specific retryability.** Use `conflict`/`incomplete_record`, settling `failed` before any driver call. State in `OPS-23`: `retryable: true` when an upgraded API can populate the omission from unchanged caller inputs; `false` when the caller must change those inputs. Each release introducing such a field must specify which applies, equally on error and operation view.

   The strongest argument is `DOM-17`’s actual question: whether repeating “the *same request* is safe and sensible.” The accepted-price example qualifies for `true`; the generic future-field rule does not establish that universally (`OPS-23`, `OPS-43`).

3. **Mid-roll:** `true` can honestly permit another submission without promising immediate success. `WIR-9a` already assigns `true` because an account “can recover,” rather than because it has recovered. Use a fresh idempotency key: `API-11` says the same key “MUST return the existing operation.”

   This shape covers install, power and delete before dispatch. `OPS-11` gives install `failed` for “any failure at all” with untouched disk and no open rescue session; its mutation row gives the others `failed` absent ambiguity. Preserve required install details (`WIR-9a`: `disk_effect` and `rescue_exit`, both `none` here). Release only the create commitment: `LDG-32` says “an install or a delete opens none.”

4. **Reason:** `"state"` fits `DOM-17`’s “State or idempotency conflict,” but use new `"incomplete_record"` for the requested distinction from account refusal. `WIR-9a` requires details to be “machine-readable”; its existing reason list supplies no specific record-completeness discriminator.

5. **Lands on:** `OPS-23`, `WIR-9a`, `CNF-34`. No classifier exception: `OPS-11` makes `conflict` ambiguous when it arose from being “cut off mid-flight.”

   **Proposed `CNF-34`:** Inject previous-release omissions into create, install, power and delete; assert `failed`, `conflict`/`incomplete_record`, matching error/view retryability, no driver invocation, and full create-commitment release without fee or first-unit debit (`LDG-39`: “Never debited”). Exercise both reconstructible omissions (`true`) and newly required caller inputs (`false`).

**Strongest case for the other side (written on request)**

`internal` identifies the responsible boundary more directly: `DOM-17` calls it “Defect in this system.” A narrowly scoped pre-dispatch `OPS-11` exception could preserve that attribution while expressing the known deterministic outcome.