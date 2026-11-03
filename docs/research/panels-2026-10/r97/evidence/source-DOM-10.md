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

