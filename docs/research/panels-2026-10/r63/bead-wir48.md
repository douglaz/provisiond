> *Filed 2026-10-22 from the third review round of PR #22, on a read of the set at `e4871a8`.*

pv-7j3 made `WIR-48` refuse any non-`healthy` account: "Assigning a tenant to an account whose `STO-47` status is
anything but `healthy` is also `conflict` with `details.reason: "state"` (`STO-36`)". No checklist item drives it.

- `CNF-243` covers a successful re-assignment to a live account and the customer `404`.
- `CNF-248` drives each member of `WIR-9a`'s `conflict` union as a `409`, not this refusal per status.
- The reviewed form (`docs/research/panels-2026-10/r62/final-form.md`, pv-7j3) records the absence: "No CNF item
  drives `WIR-48`'s refusal reason; `CNF-243` tests only the successful re-assignment."

An engine that still refuses only `terminated` and accepts `account_unreachable` or `credentials_rejected` passes the
checklist. Candidate item: drive `assign-provider-account` against an account in each non-`healthy` `STO-47` status
and assert `409` `conflict` with `details.reason: "state"` and no assignment change.

Owners: `WIR-48`, `CNF-243`.
