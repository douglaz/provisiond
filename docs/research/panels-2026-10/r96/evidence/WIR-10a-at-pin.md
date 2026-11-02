**WIR-10a** **The closed enums**, so two strict parsers agree: `kind` ∈ {`create_machine`,
`refresh`, `rescue_inventory`, `power`, `install`, `reverse_dns`, `delete_machine`,
`release_attachment`, `suspend_tenant`} (*`adopt_machine` was a member until `ADR-0020`
withdrew adopt from v1; removing a value a server never emits breaks no client*); `status` ∈ {`queued`,
`running`, `succeeded`, `failed`, `needs_reconciliation`} (`OPS-3`); `requested_by` ∈ {`caller`,
`system`, `operator`} (`OPS-39`); and **`system_reason` ∈ {`exhausted`, `late_attach_cleanup`,
`tenant_suspended`, `rate_outage_bound`}, null unless `requested_by` is `system`**
(`OPS-39`, `05-persistence.md`). *`account_lost` was a fifth member until 2026-09-05 and no
requirement ever produced it — `SEC-46` cancels nothing on the two credential states and `API-63`
enqueues nothing on a termination — so a strict client carried a value the server could never
emit. Removing a value a server never emits breaks no client.*

*`system_reason` was added to this list on 2026-08-31. It reaches the caller in every operation
view and its value set was stated in two other documents, but this document wins over prose
elsewhere — so a strict parser had no enum for a field it receives.*

