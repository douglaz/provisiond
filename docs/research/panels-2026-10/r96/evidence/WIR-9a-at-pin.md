**WIR-9a** **`details` is machine-readable and its keys are defined per kind, not left to prose.**
The caller is software; routing a value through `message` (which `API-25` constrains) forces an
agent to parse English. Minimum keys:

| kind | `details` |
|---|---|
| `insufficient_balance` | `available_sats`, `required_sats` |
| `invalid_request` / `offer_not_sellable` on create | `reason: "offer_not_sellable"`; no cap or balance result or amount derived from the withheld offer's price |
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |
| `not_activated` | `activation_minimum_sats` |
| `rate_limited` | `retry_after_ms` |
| `ceiling_exceeded` | `ceiling` (which one, from `SEC-39`'s stated set), `limit`, `interval_seconds`, `retry_after_ms` (to the end of the current interval) |
| `halted` | `retry_after_ms`, `gate` (`"solvency"` \| `"rate_unavailable"`) |
| `overloaded` | `retry_after_ms` (`STO-55`; added 2026-09-12) |
| `gone` | `retained_until` — and the safe reaction is to read machines and balance, never re-issue (`DOM-21`) |
| `conflict` | `reason` (`"idempotency_mismatch"` \| `"state"` \| `"credential_already_replaced"` (`API-56`) \| `"suspension_in_flight"` (`WIR-41`) \| `"tenant_suspended"` (`API-58`) \| `"case_closed"` (`WIR-43`) \| `"signup_window_closed"` (`API-34`) \| `"deposit_already_attributed"` (`WIR-42`) \| `"cancellation_committed"` (`OPS-42`) \| `"price_moved"` (`OPS-43`; with `shortfall_native` and `currency`) \| `"account_terminated"` (`API-63`) \| `"incomplete_record"` (`OPS-23`) \| `"cut_off"` (`OPS-21`)) |
| `unsupported` | `provider_account`, `capability` (`DOM-10`) |
| `authentication` | `reason` (`"token"` \| `"unknown_principal"`) |
| `integrity` | `expected`, `observed` where disclosable (`SEC-16`) |

For this row, determine the rejected-field set before ordering its pointers. A rejected
value's own member is named, including when that required member is absent. A value of the
wrong JSON type names that member rather than hypothetical children. When several present
members violate an exactly-one or mutually-exclusive group, every present member of that
group is rejected; when a required exactly-one group has no member, the containing object
is rejected. If a discriminated union's discriminator is absent or invalid, that discriminator
is rejected, and no variant-member rejection is inferred merely from being unable to select
a variant. A member belonging to no variant remains an independent unknown-field rejection;
a member recognized by at least one variant is not unknown solely because the discriminator
is invalid. Other independent failures in the same validation step remain in the set.
An invalid array element names its indexed position, with a decimal index and no leading
zeroes; a failed constraint on the array as a whole names the array. For a rejected member
within an object element, use that member's pointer. Escape each pointer under RFC 6901 and
apply the row's existing order to the complete set. Do not add an ancestor pointer solely
because a selected descendant failed. These rules select fields within the
invalid_request category; they do not select between error kinds.

*Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): added the
`incomplete_record` conflict reason for missing api-filled admission fields.*

*Amended 2026-10-18 (`pv-tst`, `pv-f7a`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): added the cut-off conflict reason.*

**On create and extend-runway tail refusals** (*amended 2026-10-04, `ADR-0030`*), `details.refusals` is the ordered list of
`WIR-9` inner objects and `details.not_checked` is a list of `{check, because}` objects; `API-7`
owns refusal collection, refusal ordering and evaluation. `check` is exactly `commitment_cap` or `balance`;
`because` is exactly `rate_unavailable`, `provider_account_not_healthy` (create only),
or `offer_not_sellable` (create only).
An unsellable-offer refusal is HTTP `400`, kind `invalid_request`, with
`details.reason: "offer_not_sellable"`; it is not a cap refusal and carries no
cap or balance result. Its response MUST NOT publish cap or balance amounts derived
from the withheld offer's price, in either the headline details or a refusal entry.
Every genuinely skipped check MUST appear with every applicable reason; an absent refusal does
not imply that check passed. `commitment_cap` applies only when the request supplied
`max_commitment_sats`; without it there is no cap check to skip. Balance is always a check.
When no checks were skipped, the list MUST be empty. Entries MUST be in check order
`commitment_cap`, `balance`, then reason order `provider_account_not_healthy`,
`offer_not_sellable`, `rate_unavailable`.
Purchase-tail entries MUST use these `retryable` values, applying `DOM-17`'s "whether repeating
the same request is safe and sensible":

| Refusal | `retryable` | Reason |
|---|---|---|
| `halted` / `solvency` or `rate_unavailable` | `true` | The same purchase can succeed when the gate clears |
| `conflict` / `state` on a create account whose collection-snapshot `STO-47` status is `account_unreachable` or `credentials_rejected` | `true` | The named account can recover |
| `conflict` / `state` on a create account whose collection-snapshot `STO-47` status is `terminated` | `false` | The named account cannot recover |
| `invalid_request` / `offer_not_sellable` on create | `false` | The offer cannot be bought on the same request |
| `rate_limited` / closed ordering channel on create | `true` | The same create can be evaluated after the reported interval clears |
| `conflict` / `cancellation_committed` | `false` | Repeating does not revoke a committed cancellation (`API-68` is a separate decision) |
| `invalid_request` for `max_commitment_sats` | `false` | The caller must revise its spend bound |
| `insufficient_balance` | `false` | The caller must supply balance before purchasing |

*Amended 2026-10-04 (`pv-gip.11`): fence retryability retains false; keep is a separate operator decision.*

*Amended 2026-10-04 (`pv-gip.26`, S2): account retryability distinguishes permanent termination
from recoverable status; kind and reason remain unchanged.*
*Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): the offer refusal and
unchecked reason join create tails; cap and balance amounts are withheld for that offer.*
*Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment): a local closed-channel
entry carries `retry_after_ms` and is retryable when its interval can clear. Its
headline uses HTTP 429 and `WIR-4`'s `Retry-After`; `WIR-9b` still aggregates every
entry, including any earlier false account or offer refusal.*

**Only on the `max_commitment_sats` refusal**, `invalid_request` carries
`details.max_commitment_sats` (the supplied cap) and `details.required_sats` (the computed
commitment to open or additional satoshis to reserve); these keys are not required of other
`invalid_request` errors, including `offer_not_sellable`.

**On an `install` operation's error, `details.disk_effect` is required whatever the kind** (*added
2026-09-15, `pv-x8r`*): `none` where this operation is established to have written nothing to the
target disk — `OPS-45`'s write-started marker unset on `rootfs_via_rescue` or `raw_disk`, or a
`provider_native`/`provider_catalogue` rejection the provider did not act on;
`destructive_boundary_crossed` on `rootfs_via_rescue` or `raw_disk` once that marker is set, which
tells the caller not to assume its prior contents survived and does not assert that the install
completed; `unknown` after a `provider_native`/`provider_catalogue` dispatch whose effect nothing
established. It is rendered from the operation's marker columns and outlives the payload purge with
them (`OPS-45`). `status` alone never says which: `RSC-3`'s abort with the disk untouched and an
installer's rejection of a layout it had begun partitioning for both settle `failed`, and without
this key they are identical on the wire. `retryable` is `DOM-17`'s question about the same request,
not this one — a rejected layout re-sent unchanged is refused again, and `disk_effect` does not make
it sensible.

**On an `install` or `rescue_inventory` operation's error, `details.rescue_exit` is required whatever
the kind** (*added 2026-09-15*): `none` only where no rescue session was opened, `clean` where the
driver's end-rescue call returned success, `unknown` where it failed or the operation died before
reaching it — `OPS-45`'s second marker, rendered as `disk_effect` renders the first. With `unknown`
the error also carries `rescue_address` and `rescue_port` (`RSC-19`): the machine is the tenant's own
and its address is already on `WIR-11`. It never carries a recovery-key path; the file is named by
the operation id and the directory is the operator's (`RSC-20`).

**Restore marker provenance is durable (`STO-54`).** On an install or rescue-inventory operation's
error, `disk_effect` (install) and `rescue_exit` (both kinds) are rendered `unknown` where
`restore_markers_untrusted` is `true` or transitionally `null`, whatever the marker columns hold.
Where it is `false`, the ordinary marker rendering above applies. An `unknown` `rescue_exit` retains
the address-and-port requirements above; those fields are not replaced with `unknown`. Neither
incident closure nor an ordinary restart with no open restore record changes the provenance used for
rendering.

*Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed field-pointer form and validation ordering.*

