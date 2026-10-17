1. **C2 overclaims.** `OPS-23` says “A field a previous-release `api` may not have written”; it does not promise the new API can reconstruct that field from unchanged input. Counterexample: a future release requires new caller consent, analogous to `API-14`’s acknowledgement, which “is not satisfied … by having sent one previously.” Repeating the old body cannot supply consent. Also, `API-11` says same-key resubmission “MUST return the existing operation”: proceeding requires a fresh key, not replay.

   **C3 needs a scope qualification.** `OPS-11` says `suspend_tenant` is “never `failed` as a whole.” Your conclusion holds for the initial, pre-provider failure of the create/install/power/delete operations discussed here.

2. **Pick: 1′ for reconstructible fields; a field-specific retry rule for the general case.** Use `conflict` / `incomplete_record`, settle `failed`, and set `retryable: true` when fresh admission can populate the missing data from unchanged caller input; otherwise `false`, with machine-readable identification of the required input change. Strongest argument: `DOM-17` asks whether repeating the request is “safe and sensible”; absence from storage establishes neither reconstructibility nor caller fault.

3. **True is honest mid-roll for the reconstructible case.** It need not promise immediate success: `WIR-9a` already justifies true with “The same purchase can succeed when the gate clears.” Another old replica can refuse again without invalidating that guidance. Explicitly distinguish fresh admission from `API-11` replay.

   The same rule works for install, power and delete before their first provider call. `OPS-11` gives install `failed` for “any failure at all” with untouched disk and no open rescue session; power/delete use “otherwise `failed`.” Install errors retain `WIR-9a`’s `disk_effect: none` and `rescue_exit: none`. Reconstructibility must be established separately for each missing field.

4. **Add the reason.** `state` fits `DOM-17`’s broad “State or idempotency conflict,” but cannot distinguish this remedy from `API-63`’s recoverable-account refusal. Extend `WIR-9a`’s closed list with `incomplete_record`.

5. **Land on `OPS-23`, `WIR-9a`, `CNF-34`.** Preserve `WIR-9b`’s rule that the envelope’s retryability “MUST equal” the operation view’s.

   **CNF-34:** Inject previous-release records missing required fields; assert the specified conflict, matching retryability, `failed`, and zero provider calls. Exercise reconstructible and caller-input-required cases across create/install/power/delete; assert create commitment release without debit (`LDG-39`: “Never debited”).

6. **Strongest case for the other side (written on request)**

   `internal` names the ownership accurately: `DOM-17` calls it “Defect in this system.” An explicit pre-dispatch `OPS-11` exception could preserve deterministic settlement while keeping deployment incompatibility out of the state-conflict category.