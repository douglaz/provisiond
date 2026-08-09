# 09 — Known defects in the reference implementation

Every entry is a defect found by review and, where marked *verified*, reproduced. Each
is written as a prohibition so a reimplementation can be checked against it. Reference
file:line citations point at the discarded Rust implementation and exist only for
traceability — that code is deliberately not in this directory.

Identifiers are stable and cited from the other documents. They are grouped by theme
below but not renumbered.

## Tenancy and authorization

### DEF-1 — Adoption granted authority to anyone who could name an identifier — *verified*

`POST /v1/machines/adopt` validated only that `external_id` was 1–256 characters. Any
authenticated tenant could name any configured provider account and any external
identifier, and thereby take full lifecycle control — install, power, delete — of a
machine belonging to another tenant or to the operator. Machine uniqueness was scoped per
tenant, so two tenants could each hold a record for the same physical server. The
documented claim of "per-tenant machine isolation" held only for machines the system had
itself created.

**Prohibition** — adoption MUST require entitlement proof (`API-18`, `SEC-7`). Being able
to name a provider account MUST grant nothing (`DOM-3`, `SEC-6`).

*Reference: `crates/server/src/api.rs:120`, `crates/server/src/worker.rs:266`.*

### DEF-2 — Provider-side identifiers were interpolated raw into API paths — *verified*

`external_id` was formatted directly into provider URL paths. Verified against the same
URL parser the implementation used:

```
external_id = "1/../../boot/999999/rescue"  ->  request path "/boot/999999/rescue"
external_id = "1?foo=bar"                   ->  request path "/server/1", query "foo=bar"
```

The crafted identifier redirects the request to an unrelated endpoint of the same
authenticated provider account.

**Prohibition** — path segments MUST be percent-encoded and identifiers character-set
validated (`PRV-6`, `SEC-11`).

*Reference: `crates/providers/src/hetzner_robot.rs:43-47` and every `format!("/…/{external_id}")` call site.*

### DEF-3 — Redaction was applied to failure responses only — *verified by inspection*

The provider HTTP helper redacted response bodies on the non-2xx path. Bodies captured
from *successful* responses the driver could not interpret were attached to the error's
details unredacted, stored in the operation record, and served back to the tenant through
the operation-polling endpoint. Chained with `DEF-2` this is a working exfiltration path:
adopt an identifier that redirects to an account-wide listing endpoint, let interpretation
fail, read the raw body out of the operation error.

**Prohibition** — redaction MUST be applied on the write path to every captured provider
payload regardless of status (`DOM-18`, `SEC-4`).

*Reference: `crates/providers/src/http.rs:37-51` vs `hetzner_robot.rs:123-129`.*

### DEF-4 — Authentication ran after body validation

The install and delete handlers validated the request body before authenticating, so
unauthenticated callers received full validation error text and could make the server do
policy work.

**Prohibition** — authenticate first (`API-7`).

*Reference: `crates/server/src/api.rs:218-235`, `:256-279`.*

### DEF-10 — Capability enforcement had a hole at create

Every operation called a capability gate except create, which was gated only by each
driver's internal ordering flag. The capability model clients were told to rely on was
therefore not enforced for the one operation that spends money.

**Prohibition** — gate every operation, including create (`DOM-10`, `SEC-15`).

*Reference: `crates/server/src/worker.rs:249`.*

## Rescue and installation

### DEF-5 — Host-key wait deadline was a hard-coded constant unrelated to boot timeout

The loop waiting for a provider to publish rescue host keys gave up after a fixed 90
seconds, while the boot timeout defaulted to 600 and the provider interface's own
documentation said host keys "may only appear after the rescue system has booted". Bare
metal rarely POSTs and reaches a rescue environment inside 90 seconds, so pinned installs
on such providers would fail spuriously and land in `needs_reconciliation`.

**Prohibition** — derive the host-key deadline from the boot timeout (`RSC-9`).

*Reference: `crates/rescue/src/ssh.rs:54`.*

### DEF-6 — Temporary SSH keys were deleted before an asynchronous deploy could consume them

One adapter deleted the temporary account-level SSH keys immediately after issuing an
asynchronous deploy and an asynchronous rebuild. Where key material is read later rather
than copied at request time, this produces machines nobody can log into.

**Prohibition** — establish, per provider, when key material is consumed, and do not clean
up before then (`PRV-9`). Record the answer in `08-provider-notes.md`.

*Reference: `crates/providers/src/cherry.rs:398`, `:523`.*

### DEF-7 — A driver accepted an ephemeral key and silently ignored it

One adapter took the engine's freshly generated rescue public key as a parameter, ignored
it, and generated a root password instead. The key was created and, on failure, persisted
to the recovery directory for nothing. Because that provider also publishes no host keys,
the only available paths were first-use trust — handing a live root password to a
first-connection adversary — or out-of-band pinning the caller had no way to obtain.

**Prohibition** — a driver MUST NOT accept the ephemeral key and ignore it (`PRV-17`); a
deployment SHOULD refuse first-use trust for password-based rescue providers (`SEC-24`).

*Reference: `crates/providers/src/cherry.rs:439-477`.*

### DEF-9 — A credential-bearing type serialized to a form it could not deserialize — *verified*

The rescue session type derived both serialization and deserialization, but the password
variant skipped the secret field on the way out only:

```
serialized:   {"address":"1.2.3.4",…,"auth":{"type":"password"},…}
deserialized: Err("missing field `password`")
```

Nothing persisted the session, so it never fired. It is a trap laid for whoever adds
session resume across worker restarts, and it would fail at exactly the moment a session
needed recovering.

**Prohibition** — a serializable credential-bearing type MUST round-trip, or MUST NOT
derive deserialization at all (`DOM-12`).

*Reference: `crates/core/src/model.rs:116-124`.*

## Operations and API

### DEF-8 — Operators were told to monitor a state the API could not list

Both the README and the security policy instructed operators to monitor operations in
`needs_reconciliation`. There was no list endpoint. The only way to find them was to open
the database file.

**Prohibition** — provide `GET /v1/operations` with status filtering and pagination
(`API-23`, `OPS-26`).

*Reference: router in `crates/server/src/api.rs:23-59`.*

### DEF-11 — The sweeper ran on every idle poll iteration

The expiry sweep ran at the top of the worker loop, which polled every 750 ms when idle,
producing two write transactions per second forever against an embedded single-writer
database — for a condition that changes on the scale of the lease duration.

**Prohibition** — tie the sweep interval to the lease duration (`OPS-17`).

*Reference: `crates/server/src/worker.rs:30-40`.*

### DEF-17 — Requeue re-ran non-idempotent purchases with no additional gate

Requeue re-executed the original request verbatim. For a create against an order-billed
provider that is a second purchase, gated by nothing beyond the same tenant token that
placed the first one.

**Prohibition** — requeue is operator-only (`API-19`) and re-purchase MUST be explicit
(`OPS-20`).

*Reference: `crates/server/src/store.rs:437`.*

### DEF-18 — Queue ordering had no fairness and the log had no retention

Claiming was oldest-first with no per-tenant fairness and no rate limiting, so one tenant
could starve every other; and the operation table grew without bound.

**Prohibition** — `OPS-24`, `OPS-25`.

## Persistence

### DEF-12 — Connection-scoped pragmas were applied once, at migration time

Foreign-key enforcement and busy-timeout settings were issued inside the migration
script, so they applied to whichever single pooled connection happened to run it. The
system behaved correctly only because the database driver's defaults happened to match.

**Prohibition** — apply connection-scoped settings to every pooled connection (`STO-7`).

*Reference: `migrations/0001_init.sql:1-3` executed via `store.rs:27-38`.*

### DEF-13 — Migrations were applied by splitting a file on semicolons

The migration routine split the schema file on `;` and executed the pieces. There was no
version tracking, and the approach breaks on the first trigger body or string literal
containing a semicolon.

**Prohibition** — use a real migration runner with version tracking (`STO-12`).

*Reference: `crates/server/src/store.rs:27-38`.*

## Build, test, and process

Not architectural, but the reason the defects above survived to be found by reading. A
reimplementation that repeats these will accumulate the same class of bug.

### DEF-14 — The code had never been compiled — *verified*

Three independent build breaks, any one of which fails before a line of the crate
compiles:

1. an HTTP-client feature flag was named that does not exist in that library, so
   dependency resolution failed outright;
2. a structured-logging call required a feature that was not enabled;
3. a boxed error return pinned type inference to the concrete error type, cascading into
   four further type errors against the declared trait-object return type.

The bundled validation record was honest that no compiler was available in the
environment that produced it. The bundled CI would have caught all three on first run.

**Prohibition** — nothing may be described as a reference implementation until CI builds
it (`CNF-1`).

### DEF-15 — After fixing the build, the project's own CI gate still failed — *verified*

With the three breaks patched the workspace compiled clean, but produced three dead-code
warnings, and the bundled CI ran its linter with warnings-as-errors. The declared quality
gate did not pass on the code it shipped with.

**Prohibition** — the declared gate MUST pass on the declared source (`CNF-2`).

### DEF-16 — There were no tests at all — *verified*

Zero test functions across roughly 6,100 lines. The CI step that ran the test suite passed
vacuously, which is worse than having no step: it produced a green check.

**Prohibition** — see `10-conformance-checklist.md`. A green check on an empty suite is
how a system with a tenancy hole ships looking healthy.
