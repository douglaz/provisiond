# 05 — Persistence

## What the store must provide

The operation queue is the only part of the system with real transactional demands.

**STO-1** The store MUST provide an atomic claim: select-oldest-eligible and
mark-running-with-lease in one indivisible step (`OPS-5`). A read followed by a
conditional write in a separate statement is acceptable only if the write is guarded by
the row's prior state and the guard is checked by the engine, not by application code.

**STO-2** The store MUST provide an atomic conditional upsert for the machine lock:
insert-if-absent, or take-over-if-expired, or no-op-if-held-by-another (`OPS-9`).

**STO-3** Every terminal-state write MUST be guarded on `(id, status = running, claimant
= me)` and MUST report whether it affected a row (`OPS-22`).

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
| `created_at`, `updated_at` | timestamp | |

Constraints: unique `(tenant_id, provider_account, external_id)`; index on
`(tenant_id, updated_at desc)`.

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
| `request` | json | full request payload (`OPS-2`) |
| `result` | json | nullable, redacted |
| `error` | json | nullable, redacted |
| `attempts` | integer | incremented on claim |
| `available_at` | timestamp | earliest claim time; supports deferral |
| `claimed_by` | text | nullable; worker identity |
| `lease_expires_at` | timestamp | nullable |
| `created_at`, `updated_at` | timestamp | |

Constraints: unique `(tenant_id, idempotency_key)`; index on
`(status, available_at, created_at)` for the claim; index on `(tenant_id, created_at
desc)` for listing.

**STO-9** `request` contains caller secrets — signed image URLs above all. It MUST NOT be
returned by the API (`API-21`) and the volume MUST be encrypted at rest (`OVR-12`).

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
| `created_at` | timestamp | |

Primary key `(operation_id, idempotency_key)`, giving requeue its idempotency
(`OPS-18`).

## Migrations

**STO-12** Migrations MUST be applied by a real migration runner that tracks applied
versions. Splitting a schema file on statement separators in application code is fragile
— it breaks on the first trigger body, string literal, or `BEGIN…END` block — and it
provides no versioning. See `DEF-13`.

**STO-13** Migrations MUST be forward-only and MUST be safe to run concurrently with a
running instance of the previous version, or startup MUST take an exclusive lock.

## Retention and encryption

**STO-14** A retention job MUST remove terminal operations older than a configured age,
excluding `needs_reconciliation` (`OPS-25`).

**STO-15** The database volume and the rescue recovery directory MUST be encrypted at
rest (`OVR-12`), and the recovery directory MUST be restricted to the service account
(mode `0700` or equivalent).

**STO-16** Backups of the operation store contain live signed image URLs and must be
treated as credential material.
