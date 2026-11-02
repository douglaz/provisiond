13-wire-contract.md
**WIR-10b** **`result` and `error` shapes.** `error`, when non-null, is exactly `WIR-9`'s inner
object (`kind`/`message`/`retryable`/`details`), without the envelope and **without a
`correlation_id`** — the view's own is the one that applies. `result`, when non-null, is
per kind and redacted (`API-22`, `DOM-18`): `create_machine` →
`{"machine_id": "0198c1e0-3a2b-7c4d-8e9f-1b3d5f7a9c20"}`;
`rescue_inventory` and the two **rescue-entering** install strategies →
`{"inventory": {"devices": [{"identifier": "eui.002538b111223344",
"path": "/dev/nvme0n1", "wwn": "eui.002538b111223344", "serial": "S4EVNF0N123456",
"size_bytes": 1024209543168, "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme"},
{"identifier": null, "path": "/dev/sda", "wwn": null, "serial": null,
"size_bytes": 500107862016, "model": "Virtual Disk", "type": "disk"}],
"uefi": true, "inventory_fingerprint":
"774651ea4106f48eeb2c3168486b267d5f773ccc77d10d8f489842eaff5419c9"}}`
(`RSC-33`, `RSC-38`, `RSC-46`); **an `install` whose strategy enters no rescue — `provider_native` and
`provider_catalogue` — returns `{}`** (**AMENDED 2026-09-02**: the withdrawn text made *every*
`install` result carry an `inventory`, which neither of those two can ever produce — nothing boots
rescue, so nothing reads a disk — and a client written against it would treat two shipping
strategies as permanently malformed. `RSC-33` requires the report "before writing anything", which
is a rescue-engine obligation and does not reach a path where the provider does the writing);
`suspend_tenant` →
`{"cancellations": ["0198c2a0-1b2c-7d3e-8f40-5a6b7c8d9e01"]}` (`WIR-39`), one entry per machine;
`power`/`reverse_dns`/`delete_machine`/`release_attachment`/`refresh` → `{}`.

`RSC-26` says "Every disk reported by the rescue environment MUST remain in the inventory and in
the fingerprint, including a disk with no identifier." Device identifier fields: `RSC-46`.

**`install` is the one kind whose result shape depends on something other than the kind, and a
client MUST NOT have to guess which.** The operation view carries `kind` and not `strategy`, and the
request is purged on settle (`OPS-2`), so a caller polling `kind: "install"` cannot tell an
`inventory` shape from an empty one — which under `WIR-2`'s strict-response discipline is a client
that either breaks on a valid body or accepts anything. **A machine's `last_install.strategy`
(`DOM-29`, `WIR-11`) is the field that answers it**, it survives the purge and outlives the
operation, and the operation view already carries `machine_id`. *Named 2026-09-02: `result` is
documented "per kind" and this one is per strategy, which is a discriminator a client cannot see
from the object it is holding.*

**An ambiguous outcome records provider identifiers in the operation's `error` details, not in
`result`** (`OPS-13`, `DOM-17`). *Amended 2026-09-02: this sentence said `result`, and `OPS-13` puts
the surviving evidence — provider-side identifiers, whether a recovery credential was retained
— in the error details, which is also where `CNF-45` looks for it. A `needs_reconciliation`
operation has an `error`; whether it has a `result` at all is exactly what nobody knows.*

*Amended 2026-10-22 (`pv-6p8`, panels r61–r61f; owner decision 2026-10-22): added WWN and serial
to the device example, retained an anonymous device, and added the identifier-form pointer.*

