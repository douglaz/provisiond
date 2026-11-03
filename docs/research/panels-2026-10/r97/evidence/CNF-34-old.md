- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
