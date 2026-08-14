# 05 — Persistence

## What the store must provide

The operation queue is the only part of the system with real transactional demands.

**STO-1** The store MUST provide an atomic claim: select-oldest-eligible and
mark-running-with-lease in one indivisible step (`OPS-5`). A read followed by a
conditional write in a separate statement is acceptable only if the write is guarded by
the row's prior state and the guard is checked by the engine, not by application code.

**STO-2** The store MUST provide an atomic conditional upsert for the machine lock:
insert-if-absent, or take-over-if-expired, or no-op-if-held-by-another (`OPS-9`).

**STO-3** **AMENDED.** Every settled-state write **made by a worker** MUST be guarded on
`(id, status = running, claimant = me)` and MUST report whether it affected a row (`OPS-22`).
**A worker moving its own operation into `needs_reconciliation` carries `STO-3`'s ordinary
`(id, status = running, claimant = me)` guard. The sweeper does not** — it moves operations whose
lease has *expired* (`OPS-14`), so it is by definition not the claimant, and its write is guarded
on `(id, status = running, lease_expires_at < now)` instead. Transitions *out* of the state are
guarded by `STO-19`'s write-once columns.
**Resolution transitions out of `needs_reconciliation` are not worker writes** (`OPS-3`): they are
guarded instead on `(id, status = needs_reconciliation, resolution IS NULL)`, which is `STO-19`'s
write-once rule expressed as the same kind of conditional write. *Unscoped, this requirement
forbade every transition `OPS-3` enumerates — the `status = running` guard can never hold for an
operation sitting in `needs_reconciliation`.*

**STO-4** The store MUST enforce uniqueness of `(tenant_id, idempotency_key)` (`API-10`).

**STO-5** The store MUST survive process restart with no loss of queued or running
operations.

### Engine choice

An embedded single-writer engine (SQLite and similar) satisfies all of the above for a
single-process deployment and was what the reference implementation used. It has two
consequences that MUST be accepted deliberately:

**STO-6** With an embedded single-writer store, the service is a single point of failure
and MUST NOT be run as multiple replicas against a shared file. Horizontal availability
requires replacing the store with a transactional server-based engine, and the claim and
lock primitives above are what a replacement must reproduce.

*Note for a future change feed (deferred 2026-08-12 — see `11-open-findings.md`): if one is ever
built, its cursor needs a per-tenant sequence allocated in the same transaction as each state
change. On this engine, commit order and allocation order coincide because there is one writer;
on a server engine they **decouple**, and a `since=seq` reader then silently skips changes that
committed after a higher sequence was already read. That primitive would join this list — recorded
now because `STO-27` exists precisely because a primitive was once left off it.*

**STO-7** Connection-scoped settings (foreign-key enforcement, busy timeout, write-ahead
logging) MUST be applied to *every* pooled connection, not once at migration time.
Applying them inside a migration affects only the connection that ran the migration, and
whether the system behaves correctly then depends on the driver's defaults. See `DEF-12`.

## Schema

Described as a specification, not as DDL to copy. Types are logical.

### `machines`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | primary key |
| `tenant_id` | text | not null |
| `provider_account` | text | not null |
| `external_id` | text | not null |
| `name` | text | not null |
| `kind` | enum | `virtual` \| `bare_metal` |
| `state` | enum | see `DOM-7` |
| `region` | text | nullable |
| `public_ips` | list of text | ordered; first entry is the rescue address |
| `metadata` | json | redacted (`DOM-6`) |
| `correlator` | UUID | the operation id written into the provider at create (`PRV-26`); nullable for adopted machines |
| `effective_cancellation_date` | timestamp | nullable; set when cancellation is accepted for a future date (`DOM-19`) |
| `earliest_cancellation_date` | timestamp | nullable; the provider's per-machine constraint, **read** not assumed (`PRV-13c`) |
| `reserve_sats` | integer | the currently held reserve |
| `reserve_native_minor`, `reserve_currency` | integer, text | the same reserve in the provider's billing currency (`LDG-2`) |
| `reserve_rate_num`, `reserve_rate_den` | integer | the exact rational used (`LDG-4`) |
| `reserve_computed_at` | timestamp | drives re-derivation (`PRV-13e`) |
| `runway_until` | timestamp | when funding expires (`PRV-13d`); readable by the caller (`LDG-15`) |
| `created_at`, `updated_at` | timestamp | |

Constraints: unique `(tenant_id, provider_account, external_id)`; index on
`(tenant_id, updated_at desc)`; index on `(correlator)` for reconciliation lookup (`OPS-27`);
index on `(runway_until)` for the exhaustion sweep (`LDG-13`).

**STO-17** `(provider_account, external_id)` MUST additionally be unique **across all tenants**,
not merely within one. `SEC-10` and `CNF-6` require that a provider machine belong to at most one
tenant, and the constraint written above — which includes `tenant_id` — permits exactly the
duplicate it was meant to prevent. Two tenants adopting the same machine would each be authorized
to destroy the other's server. This was `F15`.

### `machine_attachments`

Resources that survive machine deletion and keep billing (`PRV-13a`). Without this table there is
no way to represent "machine gone, storage still charging", and `PRV-13a`'s prohibition on
reporting such a machine deleted cannot be enforced.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | primary key |
| `machine_id` | UUID | not null |
| `kind` | enum | volume, snapshot, backup, reserved address, … |
| `external_id` | text | provider-side identifier |
| `billable` | boolean | whether it continues to accrue cost after machine deletion |
| `cleanup` | enum | `api` (the driver can delete it) \| `manual` (named operator procedure) |
| `released_at` | timestamp | nullable |

**STO-18** A machine MUST NOT be tombstoned while any `billable` attachment with a null
`released_at` remains. `STO-8` says tombstone when the resource is gone; `PRV-13a` says a machine
whose storage still bills is not gone. This constraint is where the two are reconciled.

**STO-8** Machines MUST be tombstoned, not deleted, when a provider deletion succeeds.
Operation records reference them, and an operator investigating a
`needs_reconciliation` record needs the machine row to still exist.

**STO-8a** "Succeeds" means the resource is gone. Where the provider only accepted a
*scheduled* cancellation, the machine MUST be recorded `cancellation_scheduled` with its
effective date (`DOM-19`) and MUST NOT be tombstoned until that date passes. Tombstoning at
acceptance hides a running, billing machine from every inventory query that filters out
deleted rows.

### `operations`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | primary key |
| `tenant_id` | text | not null |
| `idempotency_key` | text | not null |
| `kind` | text | operation type discriminator |
| `status` | enum | see `03-operation-lifecycle.md` |
| `machine_id` | UUID | nullable; set on completion for create |
| `provider_account` | text | nullable |
| `request` | json | caller payload — **live operations only**, purged on entry to any settled state **and to `needs_reconciliation`** (`ADR-0005`, `OPS-3`) |
| `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers (`OPS-13`) |
| `correlation_id` | text | not null; present in the record and in every log line for this request (`API-28`) |
| `result` | json | nullable, redacted |
| `error` | json | nullable, redacted |
| `resolution` | enum | nullable; `observed` \| `absent` \| `abandoned` (`OPS-27`, `OPS-31`) |
| `resolved_at`, `resolved_by`, `resolution_evidence` | timestamp, text, json | nullable; how a `needs_reconciliation` record was closed |
| `commitment_id` | UUID | nullable; the commitment opened in the same transaction as the enqueue (`LDG-11`). *Renamed from `hold_id` 2026-08-12* |
| `revision` | integer | strictly increases on every client-visible change (`API-53`); arbitrates out-of-order polls |
| `pending_fee_native_minor`, `pending_fee_currency` | integer, text | nullable; `LDG-67`'s parked setup fee in the **provider's** currency (`LDG-2`), since it is not yet a satoshi obligation. Cleared on resolution |
| `requested_by` | enum | `caller` \| `system` \| `operator` (`OPS-39`) |
| `system_reason` | text | nullable; set when `requested_by = system` — `exhausted`, `late_attach_cleanup`, `account_lost`, `tenant_suspended` (`API-58`), `rate_outage_bound` (`LDG-64`) |
| `system_trigger_id` | text | nullable; `OPS-39`'s durable episode identifier. Unique with `(machine_id, system_reason)` — the constraint that stops a per-minute sweep enqueueing a fresh cancel every minute |
| `attempts` | integer | incremented on claim |
| `available_at` | timestamp | earliest claim time; supports deferral |
| `claimed_by` | text | nullable; worker identity |
| `lease_expires_at` | timestamp | nullable |
| `created_at`, `updated_at` | timestamp | |

Constraints: unique `(tenant_id, idempotency_key)`; index on
`(status, available_at, created_at)` for the claim; index on `(tenant_id, created_at
desc)` for listing.

**STO-9** `request` contains caller secrets — signed image URLs, SSH keys, and up to 1 MiB of
post-install script. It MUST NOT be returned by the API (`API-21`), the volume MUST be encrypted
at rest (`OVR-12`), and **it MUST be purged when the operation reaches any settled state, and on entry to `needs_reconciliation` (`OPS-3`, which is resolution-pending rather than terminal but purges on entry)**,
including `needs_reconciliation` (`ADR-0005`). Encryption is not the control here; not having the
data is. `request_summary` is what an operator investigating a stuck record actually reads, and
`OPS-13` is satisfied by identifiers rather than secrets.

**STO-19** `resolution` and its evidence columns MUST be write-once. A `needs_reconciliation`
record that can be silently re-resolved is an audit trail that can be edited, and these records
exist precisely for the cases where money moved and nobody is sure.

**STO-10** An unrecognized `status` value read back from the store MUST be a hard error,
not a silent default. Corruption or a downgrade MUST NOT be interpreted as `queued`.

### `machine_locks`

| Column | Type | Notes |
|---|---|---|
| `machine_id` | UUID | primary key — one lock per machine |
| `operation_id` | UUID | holder |
| `worker_id` | text | holder |
| `lease_expires_at` | timestamp | not null |

**STO-11** The primary key MUST be the machine identifier alone. That is what makes the
lock exclusive.

### `operation_requeues`

| Column | Type | Notes |
|---|---|---|
| `operation_id` | UUID | |
| `idempotency_key` | text | |
| `reason` | text | not null; the operator's stated reason (`OPS-19`) |
| `previous_error` | json | not null; the error being requeued past, preserved before it is overwritten (`OPS-19`) |
| `created_at` | timestamp | |

Primary key `(operation_id, idempotency_key)`, giving requeue its idempotency
(`OPS-18`).

**STO-20** `reason` and `previous_error` are not optional. `OPS-19` requires requeue to preserve
an audit trail, and a table holding only the operation, the key and a timestamp cannot satisfy
it — the error it requeued past is overwritten by the next attempt and lost. This was `F9`.

### `tenants`

Required by `ADR-0002`: a self-serve tenant appears at runtime, so it must be a row rather than
an environment variable (`API-4` as amended).

| Column | Type | Notes |
|---|---|---|
| `id` | text | primary key; opaque, no personal data (`ADR-0005`) |
| `credential_digest` | text | not null; the **spending token** hash, never the credential itself (`API-3`). Replaced in place by `WIR-38` |
| `recovery_digest` | text | not null; the **recovery credential** hash (`API-55`). Minted with the row and never replaced by a spending-token revocation |
| `status` | enum | `pending` \| `active` \| `suspended` (`API-58`; a suspended tenant authorizes no *tenant* write, retains ledger and machine reads, and retains the maintenance actions of `API-7` step 2) |
| `pending_expires_at` | timestamp | nullable; unfunded enrolments are deleted at this time (`API-34`) |
| `created_at`, `activated_at` | timestamp | `activated_at` null until first funding (`API-35`) |

**STO-21** **AMENDED 2026-08-12 — the original forbade what the rest of the specification
requires.** It said "nothing beyond these columns may be stored about a tenant", while
`API-17b`/`SEC-43` require a provider-account assignment, `API-33` requires an enrolment handle,
`SEC-39` requires ceiling counters, and `LDG-25` requires operation meters. Read strictly,
enrolment was unbuildable; read loosely, it constrained nothing and `CNF-80` — the only privacy
conformance item in the set — was satisfiable by moving the column to another table.

The rule that carries the intent is a **prohibition on categories, not on columns**: no
information that could identify, locate or contact a natural or legal person, and no information
derived from the network path a request arrived on. Operational state a tenant needs in order to
function — account assignment, counters, meters, cached balance — is permitted and MUST live in
named tables. `CNF-80` tests the prohibition, not the column count.

`ADR-0005` remains a schema constraint. The place a privacy policy actually fails is still a
column somebody added because it seemed harmless — but a rule that forbids the whole system from
working gets deleted by the first engineer who needs it, and then nothing is enforced at all.

### `ledger_entries`

Contents are specified by `LDG-5`–`LDG-8`.

**STO-22** `ledger_entries` MUST be append-only at the storage layer, not merely by convention —
no update or delete path may exist for it. Corrections are new rows (`LDG-5`).

**STO-26** `ledger_entries` MUST NOT carry a foreign key to `tenants`. The ledger is append-only
and exempt from retention (`LDG-22`), while a pending tenant is deleted at its time-to-live
(`API-34`) — so a constraint between them makes one of the two rules unenforceable. Attribution
is by tenant identifier, and `LDG-43`'s unattributed state is what a deleted tenant's entry uses.

### `commitments`

The reservation record (`LDG-30`). **This table did not exist before 2026-08-12** — the previous
version named a `holds` table, delegated its contents to `12-billing-and-ledger.md`, and that
document specified only ledger entries. `operations.commitment_id` (then `hold_id`) was a foreign
key to nothing, and
`CNF-96` was a BLOCKING test that wrote to a table no document defined.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | primary key |
| `tenant_id` | text | not null |
| `machine_id` | UUID | nullable until the machine record exists |
| `operation_id` | UUID | the operation that opened it |
| `reserved_sats` | integer | **decreases** as consumption is debited (`LDG-31`) |
| `state` | enum | `open` \| `closed` |
| `version` | integer | for the conditional write in `LDG-34` |
| `opened_at`, `closed_at` | timestamp | |

Constraints: index on `(tenant_id, state)` for the availability computation; at most one `open`
commitment per machine.

**STO-23** A commitment and the operation that caused it MUST be written in one transaction
(`LDG-11`), which is why `operations.commitment_id` exists rather than a lookup by convention.

**STO-27** Computing available balance and opening a commitment MUST be serialized per tenant
(`LDG-35`). The store MUST provide a primitive for it — a per-tenant lock row, a serializable
transaction, or a conditional write against a versioned balance — and the deployment MUST record
which. **`STO-6` invites replacing the embedded single-writer engine and lists the primitives a
replacement must reproduce; this one was missing from that list**, so a deployment could move to
a server engine and silently lose the only thing preventing two creates from spending the same
balance.

**STO-28** Decrementing a commitment MUST be a conditional write on its `version` (`LDG-34`), and
posting a `usage_debit` MUST happen in the same transaction as the decrement (`LDG-31`).

### `deposits`

One row per funding request (`LDG-46`), carrying **both** destinations. This is the binding that
makes attribution possible without recording a payer (`LDG-49`, `ADR-0008`).

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | primary key |
| `tenant_id` | text | not null; exactly one tenant per deposit (`LDG-49`) |
| `requested_sats` | integer | the caller's stated intent (`API-44`) — **never** the credit (`LDG-47`) |
| `payment_hash` | text | the Lightning destination |
| `address` | text | the on-chain destination |
| `derivation_index` | integer | so the address is re-derivable from the operator's own key material rather than stored as the sole copy |
| `idempotency_key` | text | not null; re-sending a funding request returns this row (`API-45`) |
| `expires_at` | timestamp | not null. Enforced on Lightning, **disclosed** on-chain (`LDG-54`) |
| `created_at` | timestamp | |

Constraints: unique on `payment_hash`; unique on `address`; unique on `(tenant_id,
idempotency_key)`; index on `expires_at` for the watch set (`LDG-57`).

**There is no `credited_entry_id` and no settled flag**, because a deposit can be paid on both
rails (`LDG-55`) and a single-settlement column would encode the assumption `LDG-55` forbids.
Credits are `ledger_entries` rows keyed to the payment, per `STO-31`.

**STO-29** **`deposits` MUST NOT be deleted, and MUST NOT carry a foreign key to `tenants`.** An
address stays payable after expiry (`LDG-54`), so discarding the row converts a late payment from
*resolvable* into *unattributable by construction* — and `LDG-51` retains the binding precisely so
a payment brought to the operator's attention can still be credited. `API-34`'s time-to-live
deletes pending tenants; this table outlives them, and a payment for a departed tenant resolves
through `LDG-43` rather than through a lookup that no longer works.

**The retained row is cheap; the watch is not.** `LDG-57` bounds the *watch set* by expiry, and
that is the bound that matters. Retention here is storage, and storage is not what an attacker
minting free funding requests was ever able to threaten.

**STO-30** A settled payment MUST credit its ledger entry and record the payment in **one**
transaction. Two transactions permit a crash between them, and the recovery reads identically to
an uncredited payment — so the retry credits it twice, which is minting rather than double-billing
and is not caught by the solvency check (`LDG-17`) until the operator is already short.

**STO-31** Watching for settlement MUST be idempotent and MUST tolerate replay from the rail. Both
rails re-announce: a node replays invoice settlements on reconnect, and a chain re-scan re-reports
confirmed outputs. `LDG-8`'s per-entry idempotency key MUST therefore be derived from the
*payment* — the payment hash, or the outpoint — and never from the observation event, and never
from the deposit, which may legitimately produce two credits (`LDG-55`).

**STO-32** The **watch set MUST be derived by query, not maintained by hand** — the unexpired rows
of `deposits`, re-derived on start-up. A watch list assembled incrementally as deposits are minted
loses its contents on restart, and the failure is silent: payments to forgotten addresses simply
never arrive, and no error is raised by anything.

### `enrolments`, `idempotency_records`, `tenant_provider_accounts`

Three tables that requirements mandated and no schema defined — the `commitments` gap recurring
three times over. Both 2026-08-13 reviewers found all three.

**STO-34** **`enrolments`** — `handle` (unique), `tenant_id`, `issuable_at`, `created_at`,
`expires_at`. **The credential hashes live in `tenants` and nowhere else**: `API-3` and `WIR-5`
both say the customer token hash is read from the tenant row, and a second home would leave
`WIR-38`'s replacement rewriting an unstated one. `tenants.credential_digest` therefore stays
`NOT NULL` and is populated **at enrolment**, in the same transaction that mints the row — the
delay in `API-33` gates *usability* (`issuable_at`), not existence, so no null window is needed
and none is permitted. Both secrets are minted at enrolment and stored **hashed only**
(`API-33`, `API-55`); nothing recoverable is retained, which is why `API-56`'s revocation replaces
a token rather than recovering it.

**STO-35** **`idempotency_records`** — `scope_kind`, `scope_id`, `key`, `fingerprint`,
`resource_kind`, `resource_id`, `status`, `response_body`, `created_at`, `expires_at`, unique on
`(scope_kind, scope_id, key)`. **`response_body` MUST NOT contain a bearer secret.** `WIR-38`'s
success body carries a freshly minted spending token, and persisting that would defeat `API-3`'s
hash-only rule and make a database leak yield a live credential — so a replayed revocation
returns `409 conflict` with `details.reason: "credential_already_replaced"` rather than the stored
token — and `API-56` is worded to match, so "idempotent" there means *at most one replacement per
key*, not *a replayable body*. The owner re-revokes with the recovery credential, which is exactly what that credential
is for; the old token is already dead either way, so the replay cannot be silently swallowed. **One store for the whole protocol.** Operations, deposits and
runway extensions each had their own arrangement or none, and the two synchronous writes had a
mandated transactional guarantee with nowhere to keep it: `WIR-24` requires the extension and its
exact response body commit together, which is unimplementable without this row. The record MUST be
written in the same transaction as the write it guards, and retained for the horizon `STO-33`
states.

**STO-36** **`tenant_provider_accounts`** — `tenant_id`, `provider_account`, `assigned_at`,
`policy_version`, unique on `(tenant_id, provider_account)`. Populated in the activation
transaction (`API-57`). Without it `API-17b`'s "explicit assignment" had no home and `WIR-29`
returned an empty list to every customer forever.

**STO-37** **`operator_deficiencies`** — `id`, `subject_kind`, `subject_id`, `native_minor`,
`currency`, `absorbed_seconds`, `rate_num`, `rate_den`, `cause` (`clamp_overflow` | `exception_branch` | `rate_outage` | `account_loss` |
`late_attach_cleanup` (`OPS-36`'s wind-down shortfall) | `unrecoverable_setup_fee` (`LDG-39`)),
`idempotency_key` (unique), `opened_at`, `resolved_at`. `LDG-66`'s record. It is deliberately not
a `ledger_entries` row: every entry kind there moves tenant satoshis, and these move none.

**STO-33** **A terminal operation MUST remain readable at least as long as its idempotency record
can refuse a reused key, and the two horizons MUST be stated to callers as one number.** `STO-14`
deletes terminal operations; `STO-25` makes idempotency records outlive them. Misalign the two in
either direction and an autonomous caller is pushed toward a duplicate purchase: if the record
ages out first, a caller polling its id gets what looks like "never existed" and re-sends (now
softened to `gone` by `DOM-21`, but the horizon still matters); if the key ages out first,
`STO-25`'s own named failure occurs. The `operations` row also carries `revision` (`API-53`),
incremented in the same statement as any client-visible change.

## Migrations

**STO-12** Migrations MUST be applied by a real migration runner that tracks applied
versions. Splitting a schema file on statement separators in application code is fragile
— it breaks on the first trigger body, string literal, or `BEGIN…END` block — and it
provides no versioning. See `DEF-13`.

**STO-13** Migrations MUST be forward-only and MUST be safe to run concurrently with a
running instance of the previous version, or startup MUST take an exclusive lock.

## Retention and encryption

**STO-14** A retention job MUST remove **settled** operations older than a configured age;
`needs_reconciliation` is not settled (`OPS-3`) and is excluded (`OPS-25`).

**STO-24** Retention MUST NOT reach `ledger_entries` (`LDG-22`). A financial record outlives the
request that caused it; it contains no caller secrets to purge only because `LDG-21` kept them
out.

**STO-25** Idempotency records MUST outlive the operations they guard, or be replaced by a
tombstone that still refuses a reused key. `API-11` promises that reusing a key returns the
existing operation; `STO-14` deletes that operation; after which the same key performs the
mutation again — **a duplicate purchase, by design.** Either retention preserves the
`(tenant, key)` pair beyond the operation, or `API-11`'s promise must be given an explicit
expiry that the API states to callers. This was `F8`.

**STO-15** The database volume and the rescue recovery directory MUST be encrypted at
rest (`OVR-12`), and the recovery directory MUST be restricted to the service account
(mode `0700` or equivalent).

**STO-16** Backups of the operation store contain live signed image URLs and must be
treated as credential material.
