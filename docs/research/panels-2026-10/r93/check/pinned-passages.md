### `AGENTS.md:29–32` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
```

### `AGENTS.md:34–38` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Cite the owner.** One rule, one home; everywhere else points at it.
`07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
of a second copy drifting until an amendment shipped claiming to have applied while the requirement
said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
a second normative copy gets written, because you cannot explain a rule without restating it.
```

### `AGENTS.md:45–46` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
```

### `00-overview.md:22–24` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**OVR-2** Capability MUST be discoverable at runtime (`GET /v1/providers`). Clients
MUST NOT be required to infer support from a provider's name, and the server MUST NOT
accept an operation a provider has not declared support for. See `DOM-10`.
```

### `01-domain-model.md:515–541` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**DOM-10** Every operation with a capability MUST be gated on it before the
driver is called, **including create**; the driver methods with no capability entry are the ones
`PRV-4` names. There MUST be no operation whose only gate is
a driver-internal check. A capability check failure MUST return an "unsupported" error
naming the provider account and the capability, with `retryable: false` on both the error and the operation view where there is one.

Mapping from operation to required capability:

| Operation | Required capability |
|---|---|
| create machine, `kind = virtual` | `provision_virtual` |
| create machine, `kind = bare_metal` | `provision_bare_metal` |
| refresh | none — every driver MUST implement machine lookup |
| power on/off/reboot | `power_control` |
| hard reset | `hard_reset` |
| install, `provider_native` + `catalog` | `native_rebuild` |
| list offers | `list_offers` |
| rescue inventory | `rescue_ssh` (`RSC-38` boots rescue to read the inventory) |
| install, `rootfs_via_rescue` | `install_rootfs_via_rescue` |
| install, `raw_disk` | `install_raw_disk_via_rescue` |
| install, `provider_catalogue` | `install_via_provider_catalogue` |
| reverse DNS | `reverse_dns` |
| delete | `delete_machine` |
| release attachment | `delete_machine` — a driver that can delete a machine can release what it left behind (`PRV-45`) |

*Amended 2026-10-22 (`pv-009`, `pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): every capability check failure carries `retryable: false`, which is how the `pv-p3k` ruling "MUST, not retryable" reaches `API-7`'s step 5d and `OPS-43`'s claim-time gates.*

```

### `04-api-contract.md:207–214` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
4. authorize the target resource against the tenant;
5. deserialize and validate the body;
5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`. This step
    needs the parsed body, which is why it cannot live at step 3;
5b. **reject with `suspended`** if the tenant is suspended and this is not a maintenance action
    (`API-58`, `DOM-20`). **This is the only step that rejects for suspension** — step 2 passes a
    suspended tenant through on purpose. It sits *after* 5a deliberately: a write replayed from
```

### `04-api-contract.md:1102–1115` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**API-65** **ADDED 2026-09-08 — the operator's half of `PRV-45`, which had no route.**
`GET /v1/machines/{id}/attachments` (`WIR-52`) is **operator-only** (`WIR-34`) and lists the
machine's `machine_attachments` rows. `POST /v1/machines/{id}/attachments/{attachment_id}/actions/release`
(`WIR-52`) is **operator-only** and admissible only on a row whose `released_at` is null; otherwise
it is refused `409` `conflict` with `details.reason: "state"`. On a row whose `cleanup` is `api` it
enqueues one `release_attachment` operation with `requested_by: operator` and answers `202` with
the operation view — the same kind, and the same driver call, the delete's terminal transaction
enqueues on its own. On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation, and is in `API-48`'s
list for that reason. A release the delete's terminal transaction enqueues carries the delete's own
`requested_by` and `system_reason`, so `WIR-10a`'s set gains no member for it. The `202` form is
idempotent as any operation is (`API-11`); the `200` form, returning no operation, commits the
`released_at` write and its idempotency record together under `WIR-24`'s one-transaction rule.
For the release's exit write, see `LDG-38`.
```

### `03-operation-lifecycle.md:2018–2034` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**OPS-23** Validation that was performed at the API boundary MUST be repeated in the
worker before the driver is called. The record may have been written by an older version
of the service, or edited in the store. Validation is cheap; a wrong install is not. **A field a
previous-release `api` may not have written is a deterministic failure in the worker, never a
passed check** (added 2026-09-12, `ADR-0024`): a create admitted without `OPS-43`'s accepted-price
fields fails before dispatch rather than dispatching at whatever the offer says now.

For create, install, power and delete, a missing required field MUST fail as follows:

- A field the `api` itself writes when it admits the operation fails `conflict`, with
  `details.reason: "incomplete_record"` and `retryable: true` on both the error and the operation
  view. The accepted-price fields above are such fields; the worker-written correlator is not.
- A field the caller must supply fails `invalid_request` naming the field, with
  `retryable: false` on both the error and the operation view.

A field that is present but fails this repeated validation fails as its writer's bullet above says, on both the error and the operation view, and settles as these missing-field failures do.

```
