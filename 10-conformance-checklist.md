# 10 — Conformance checklist

What an implementation must demonstrate before it touches a real provider account. Each
item names the requirement it proves and is written so it can become a test.

The reference implementation shipped with a CI job that ran a test suite containing zero
tests, and a green check next to it. Treat any unchecked box below as that same green
check.

**Every item gates, and there are no tiers** (2026-09-12, `F50`). From the first commit on
2026-08-09 to 2026-09-12 each item carried a launch tier — BLOCKING, PRE-SCALE or DEFERRED — chosen
by a three-question rule about whether the operator could undo, would notice, or a bot could
trigger the failure, with paragraphs of reasons and graduation triggers beside the items; from
2026-09-09 the tier was a tag on the item line and a gate refused an untiered one. It was withdrawn
whole. An item is a property the system has or does not have; *when* to
demonstrate which is a question for whoever plans a launch, and answering it here produced a second
document inside this one — the reasons drifted from the items (`F16`, `F30`, `F50`), the count went
stale four times, and the last review found two readers disagreeing on what the rule's own third
question meant. `11-open-findings.md`'s `F50` holds the withdrawal; the panel's per-item verdicts
argued tiers and are not kept. `tools/check_ids.py` now refuses a tag on an item. Nothing an item
asserts was changed by the cut.

**Seeds in the items below** (2026-10-08, `ADR-0033`): eligibility and seed value belong to
`LDG-38`: "A machine's first seed is eligible for an offset only if its first unit was actually
debited to the customer". An item that
seeds a machine at an instant and asserts its mark or its first increment there, without specifying
a debit-eligibility case, runs on an offer
whose `billing_unit.seconds` is zero — `PRV-44`'s exact-elapsed-time offer, a unit of no length,
under which nothing is prepaid for time — or on a seed that is not the machine's first; the first
seed under a unit of some seconds is `CNF-318`'s.

## Build and gate

- [ ] **CNF-1** — CI builds the project from a clean checkout, with no network-dependent
      manual steps. (`DEF-14`)
- [ ] **CNF-2** — The declared lint gate passes on the declared source at the declared
      strictness. If the gate is warnings-as-errors, there are no warnings. (`DEF-15`)
- [ ] **CNF-3** — The test suite fails when a test is deliberately broken — verified once,
      by hand, so that "tests passed" means something. (`DEF-16`)

## Architecture boundary

`ADR-0001` chose the single-component form of `OVR-10`, so these always apply. They replace the
network isolation the withdrawn separate-service form would have provided, which is why they are
not optional hardening — they are the only structural defence there is.

- [ ] **CNF-71** — A provider credential cannot be read from `api` or from `ledger`, and the
      guarantee is enforced by the code rather than by convention. Prove it the way the
      language allows: in Rust, the credential-owning type is private to `engine` and
      reachable only through a trait that does not expose it, demonstrated by a **compile-fail
      test** asserting that code in either other module referencing it does not build. A comment
      saying "do not use this here" is not a proof. *`ledger` joined this item on 2026-09-02: it is
      a module `engine` depends on, so a credential reachable from it is a credential reachable from
      the money code.* (`OVR-10a`, `OVR-9`)
- [ ] **CNF-72** — A static tripwire fails CI when a new import, re-export, or `pub` visibility
      change makes the credential type reachable from `api` or `ledger`. The boundary
      must fail closed as the code grows; the compile-fail test of `CNF-71` proves today's
      state, this proves tomorrow's. (`OVR-10a`)
- [ ] **CNF-73** — **REWRITTEN 2026-09-02 — it asserted the thing `OPS-27` requires.** `api` holds no
      provider credential, and `engine` holds no customer credential and no **payment-rail**
      material — no Lightning or on-chain credential, no destination derivation, no settlement
      subscription (`STO-30`–`STO-32`, `SEC-48`). It **does** write ledger entries and commitments,
      through `ledger`, because `OPS-27` requires a worker to commit the setup-fee debit and the
      commitment decrement in the same transaction as the machine row — a transaction `store`
      opened and the worker passed in (`OVR-9`). Assert on the types each module's constructors
      accept, and on the dependency edges (`CNF-251`), not on runtime values.
      *Withdrawn text:* the lifecycle layer holds no customer credential **or payment material** —
      which, read against the module table, made the product's terminal money write illegal in every
      module that could perform it. (`OVR-10b`, `OVR-9`, `OPS-27`)
- [ ] **CNF-74** — Operator-only routes — `WIR-34`'s list; `retry` above all, since it re-dispatches
      a delete (`API-64`) — are not served on the customer-facing listener. (`API-27`)
## Tenancy and authorization

- [ ] **CNF-4** — Tenant A cannot read, refresh, power, install on, or delete tenant B's
      machine; every attempt returns `404`, never `403`. (`API-17`, `SEC-8`)
- **CNF-5** — **WITHDRAWN 2026-09-08 (`ADR-0020`)** with adopt. It tested the operator adopt
      against the entitlement assignment, after a 2026-09-02 rewrite retired its tenant-facing
      form. Identifier retained rather than reused; `DEF-1` keeps the defect, and the item returns
      with the verb. (`DEF-1`, `STO-17`)
- **CNF-6** — **MERGED INTO `CNF-107` 2026-09-02.** It read "two tenants cannot both hold a record
      for the same external machine"; `CNF-107` reads "two tenants cannot both hold the same
      `(provider_account, external_id)`, enforced by the store, not by application code" — the same
      control, tested twice and counted twice in the BLOCKING total. `CNF-107` is the survivor
      because it names the constraint that enforces it. Identifier retained rather than reused, and
      not a checkbox: like `CNF-31`, it is a marker rather than an item.
- [ ] **CNF-7** — A non-admin token's tenant-override header is ignored, not honoured.
      (`API-5`, `SEC-9`)
- [ ] **CNF-8** — An unauthenticated request to every write endpoint is rejected before any
      body validation error can be observed. (`API-7`, `DEF-4`)
- [ ] **CNF-9** — `POST /v1/episodes/{id}/actions/retry` and both episode reads are refused for a
      tenant token — `404`, never `authentication`. (`API-64`, `WIR-51`, `WIR-34`)

## Injection

- [ ] **CNF-10** — An `external_id` of `1/../../other/endpoint` produces a request to the
      intended endpoint path, or is rejected outright. Assert on the constructed URL, not
      on the response. (`PRV-6`, `DEF-2`)
- [ ] **CNF-11** — An `external_id` containing `?` or `#` does not inject a query string or
      truncate the path. (`PRV-6`)
- [ ] **CNF-12** — Hostname, device path, digest, image URL, key material, and post-install
      script each containing shell metacharacters produce a remote script in which those
      values appear only base64-encoded. Assert on the generated script text. (`RSC-15`,
      `SEC-12`)
- [ ] **CNF-13** — Installer-config fields containing CR, LF, NUL, or whitespace are
      rejected. (`RSC-23`, `SEC-13`)

## Redaction

- [ ] **CNF-14** — A provider payload containing keys named `password`, `secret`,
      `private_key`, `token`, `api_key`, `authorization`, and `credential` — nested inside
      objects and arrays — is redacted before storage. (`DOM-6`)
- [ ] **CNF-15** — A **successful** provider response that the driver cannot interpret is
      redacted before it reaches the operation error. (`DOM-18`, `SEC-4`, `DEF-3`)
- [ ] **CNF-16** — No log line, operation result, or operation error in the whole test suite
      contains a rescue password or a private key. Assert by scanning captured output.
      (`SEC-3`)
- [ ] **CNF-17** — Debug formatting of the rescue session type does not reveal the
      credential. (`DOM-11`)

## Capability model

- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
- [ ] **CNF-20** — Every operation on a driver that declares nothing returns `unsupported`,
      not a panic and not a wrong default — except `PRV-2`'s three named exceptions, each
      asserted for its own stated behaviour instead: describe capabilities and get machine are
      implemented (`PRV-3`), and refresh rescue session returns the session unchanged (`PRV-19`).
      (`PRV-2`)

## Idempotency

- [ ] **CNF-21** — Same key, byte-equivalent body, twice: one operation, both responses
      identical. (`API-11`)
- [ ] **CNF-22** — Same key, different body: `409`, and no second operation exists.
      (`API-11`)
- [ ] **CNF-23** — Same key, different tenants: two independent operations, neither
      observable by the other, and no internal error. **Same key, a tenant and an operator; and
      same key, two operator identities: the same three assertions** (2026-09-05 — operator
      writes carry the key and had no scope). (`API-10`, `STO-4`, `STO-35`)
- [ ] **CNF-24** — Semantically identical bodies differing only in JSON key order do not
      produce a spurious conflict. (`API-12`)
- [ ] **CNF-25** — `retry` with the same key twice enqueues one attempt and returns the same
      episode view. (`API-64`, `WIR-24`)

## Operation lifecycle

- [ ] **CNF-26** — Two workers racing to claim one queued operation: exactly one wins.
      (`OPS-5`)
- [ ] **CNF-27** — Two operations on one machine: the second is deferred back to `queued`,
      not failed, and runs after the first releases — and the deferral is the store's refusal
      (`STO-51`'s index), not an application-level check. **Then the claim-number case** (added
      2026-09-12, `ADR-0022`): with an operation deferred by its first execution, let a second
      execution claim it, then replay the first execution's defer write carrying its old
      `claim_number`, and assert it affects **no row** and the second execution's operation is
      still `running`; assert that the same write with only the claim term removed *does* affect
      the row, which is the evidence the term is doing work. (`OPS-8`, `OPS-6`, `STO-51`, `STO-3`)
- [ ] **CNF-29** — **AMENDED 2026-09-08 (`ADR-0016`) — the sweep has no deadline; the startup pass
      is the sweep.** Every operation found `running` when the engine starts is, subject to the
      exceptions below, moved to `needs_reconciliation` — never back to `queued`, except a
      `suspend_tenant` parent, which `OPS-15` says "MUST be returned to `queued`" on a restart —
      and the count is logged. Kill the engine
      with an operation of each dispatching kind `running`, restart, and assert each one — **except
      a `refresh`, which settles `failed`** (`ADR-0020`): assert its row is `failed` with an
      `internal` error and that `WIR-35`'s resolve refuses it by kind — **and a create whose
      `about_to_order_at` is null**, which settles `failed` on a restart with full commitment
      release and resource-offer exclusion freed; for its error, `OPS-15` says "Where no error is
      recorded, it MUST carry an `internal` error naming the restart, with `retryable: true` on
      both the error and the operation view". A set column stays `needs_reconciliation`; the null
      exception stays off while a restore record is open.
      (`OPS-15`) *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the create exception and qualified the startup outcome, naming the `suspend_tenant` return to `queued` the summary had missed; the exclusion control uses an open restore record; `ADR-0042`.*
- [ ] **CNF-30** — The startup pass does not overwrite an error already recorded. (`OPS-16`)
- **CNF-31** — **SPLIT 2026-08-09** into `CNF-31a` and `CNF-31b`. The original conflated two
      different stakes: rows where a misclassification causes a repeated provider mutation, and
      rows that only need covering for exhaustiveness. They belonged in different launch tiers
      under the classification then in force (withdrawn 2026-09-12), and the undivided item was
      consequently listed in two of them; the split stands on the two stakes. Identifier retained rather than
      reused, per the append-only convention in the README.
- [ ] **CNF-31a** — The rows of `OPS-11` where a misclassification causes a repeated provider
      mutation. **Amended 2026-10-08 (`ADR-0035`):** a create rejected by a provider 4xx
      before acceptance is `failed`; after acceptance a provider 4xx failure is
      `needs_reconciliation`. The former blanket 4xx assertion required the defect.
      A create failure recorded after step 9 begins with a provider 5xx, a network error, or a timeout is
      `needs_reconciliation`, including without known acceptance; every install
      failure that is not a deterministic caller error **and that `OPS-45`'s markers do not clear**
      is `needs_reconciliation`. Getting these
      wrong invites the caller to retry a mutation that already happened. **AMENDED 2026-09-02 —
      the install clause was unconditional and `OPS-45` narrowed it**: a failure with the disk
      untouched and the rescue session closed cleanly is deterministic, and classifying it ambiguous
      is the defect that made `RSC-3`'s host-key abort an operator-resolved loss. The clause matters
      in both directions, so assert both: an install past the write marker, with a kind on the
      row's `needs_reconciliation` list, is never `failed`, and one short of it with a clean exit
      is never `needs_reconciliation`. *Scoped 2026-09-14: unscoped, the first assertion read
      wider than the row it tests, which sends a deterministic caller error to `failed` past the
      marker.*
      *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): scoped the create transport and 5xx cases to step 9 onward.*
- [ ] **CNF-31b** — The remaining rows of `OPS-11`, for exhaustiveness — including that the table
      is *total*: every error kind in `DOM-17` has a defined classification for every operation
      kind, with no implicit default; exercise the create row on both sides of its step-9 boundary. **Amended 2026-10-08 (`ADR-0035`):** vary known acceptance
      across both Boolean values for driver errors, and exercise unknown acceptance as null with
      the mutating request's own mapped failure kind (`CNF-322`). On the create row after step 9 begins and on the last row, `OPS-11` says
      "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`"; assert that a
      pre-send `network` failure (for create, from a step-9 call) yields `needs_reconciliation` despite `details.accepted: false`;
      null supplies no extra classifier condition. Admission-only inputs remain pre-provider,
      with acceptance false. At admission, a local `PRV-40` closure is a pre-provider refusal
      with no operation to classify; at claim it settles the queued operation `failed`
      (`CNF-283`); a driver-emitted `rate_limited` remains in the classifier,
      including after accepted mutation, except the accepted dated cancellation read-back
      and post-order read (`PRV-13`, `PRV-13c`; `OPS-11`'s exception paragraph).
      *Amended 2026-10-09 (`ADR-0036`): local closure is a refusal occurrence without an operation.*
      *Amended 2026-10-14 (`ADR-0037`, Q31).*
      *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): covered the create boundary and retained step-9 pre-send ambiguity.*
- [ ] **CNF-32** — Nothing in the system retries an ambiguous mutation. Assert by counting
      driver invocations across a failure scenario. (`OPS-12`, `SEC-27`)
- [ ] **CNF-33** — An operation is executed correctly after a full process restart between
      enqueue and claim. (`OPS-2`, `STO-5`)
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller
      field assert `invalid_request` naming the field and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert the same `invalid_request` naming the field and `retryable: false`
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

- [ ] **CNF-35** — `GET /v1/operations?status=needs_reconciliation` returns them, paginated.
      (`API-23`, `DEF-8`)

## Rescue and installation

- [ ] **CNF-36** — Every row of the host-key decision table in `RSC-3` is covered, including
      the two abort cases: no keys and no opt-in; and caller keys that do not overlap
      driver keys. Where caller keys overlap driver pins, a presented key that matches a
      driver pin but is not one of the caller's keys is refused before authentication. (`RSC-3`)
- [ ] **CNF-37** — A pinned connection is never downgraded to first-use trust, including
      when the driver returns an empty key set on a later refresh. (`RSC-5`, `PRV-20`)
- [ ] **CNF-38** — Host-key comparison is canonical: the same key with a different comment,
      a leading host pattern, or extra whitespace compares equal; a different key does
      not. (`RSC-6`)
- [ ] **CNF-39** — The host-key wait deadline scales with the configured boot timeout.
      (`RSC-9`, `DEF-5`)
- [ ] **CNF-40** — A rescue password never appears in a command line. Assert on the spawned
      process's argument vector. (`RSC-11`)
- [ ] **CNF-41** — For each applicable generated installer, assert the installed system does not inherit the ephemeral rescue credential. For Robot installimage, inspect the generated config: it contains `SSHKEYS_URL` for the caller's keys and `TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS no`, and does not copy rescue authorized keys into the installed system. This is a generated-config check; the deployed script was inspected on 2026-10-12, but no end-to-end installation or exact upstream commit match was tested. (`RSC-12`, `RSC-13`; Robot directive observed in `docs/research/provider-verify-2026-10.md` V11, 2026-10-06)
- [ ] **CNF-42** — A rootfs install with no authorized keys is rejected; a raw-disk install
      *with* authorized keys is rejected. (`RSC-13`, `RSC-14`)
- [ ] **CNF-43** — A digest mismatch on the rootfs path aborts before the installer runs.
      (`RSC-25`)
- [ ] **CNF-44** — A digest mismatch on the raw-disk path produces an `integrity` error and
      routes to `needs_reconciliation` **in single-pass mode, where verification completes only
      after the overwrite has begun** (`RSC-29`) — which is what sets `OPS-45`'s write marker. **In
      `RSC-30`'s two-pass mode the same mismatch is caught in scratch with nothing written, so the
      marker is unset and the operation settles `failed`.** Both, and the difference is the point:
      the two modes make different claims about the disk and must not report the same outcome.
      *Amended 2026-09-02; stated unconditionally it failed the mode `RSC-30` says SHOULD be the
      default.* (`RSC-29`, `RSC-30`, `OPS-11`, `OPS-45`)
- [ ] **CNF-45** — **AMENDED 2026-09-15.** On a failed rescue exit the recovery key is persisted at
      `<recovery directory>/<operation id>`, and the error carries `rescue_exit: "unknown"` with
      `rescue_address` and `rescue_port`; **the directory's configured value appears nowhere in the
      operation view, the listing or `request_summary`** — grep all three for it. Then a clean exit:
      `rescue_exit: "clean"` and no file. *It read "its path, with the rescue address and port,
      appears in the operation error" — a path under a key no document named.* (`RSC-19`, `RSC-20`,
      `WIR-9a`, `STO-50`)
- [ ] **CNF-46** — The recovery directory is created owner-only. (`RSC-20`)
- [ ] **CNF-47** — The inventory report is attached to the operation result **for every operation that
      enters rescue, and only for those** — the two rescue-entering install strategies and
      `RSC-38`'s inventory pass; a `provider_native` or `provider_catalogue` install returns `{}`,
      since neither boots anything and neither can read a disk (`RSC-33`, `WIR-10b`). An
      unparseable report is captured raw rather than dropped. (`RSC-33`, `RSC-34`, `WIR-10b`)
## Image policy

- [ ] **CNF-49** — A non-HTTPS URL is rejected unless insecure HTTP is explicitly enabled.
      (`API-13`, `SEC-18`)
- [ ] **CNF-50** — URLs with embedded credentials or a fragment are rejected. (`SEC-18`)
- [ ] **CNF-51** — `*.example.com` matches `a.example.com` but not `example.com`, and
      matching is case-insensitive. (`SEC-20`)
- [ ] **CNF-52** — An empty allowlist logs a loud startup warning. (`SEC-19`)
- [ ] **CNF-53** — A redirect from `https` to `http` is refused by the remote fetch itself.
      (`RSC-17`)

## Acknowledgements

- [ ] **CNF-54** — Install without the destructive acknowledgement is rejected; delete
      without it is rejected. (`API-14`)
- [ ] **CNF-55** — Create against an order-billed provider is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. (`API-15`,
      `PRV-10`)

## Persistence

- [ ] **CNF-56** — Connection-scoped settings are asserted on a freshly checked-out pooled
      connection, not on the one that ran migrations. (`STO-7`, `DEF-12`)
- [ ] **CNF-57** — Migrations are version-tracked and re-running them is a no-op. **Then the
      release drill** (added 2026-09-12, `ADR-0024`): with release N−1's engine and `api` running,
      apply release N's migrations through the `migrate` entry point and assert no `api` write is
      refused and no engine write exits; start two runners at once and assert one waits on
      `STO-12`'s key while the engine's startup lock is untouched; start N−1 binaries against the N
      schema and assert they serve, then start a binary against a schema older than the version it
      requires and assert it exits non-zero before its listener opens or, for the engine, before
      the startup lock; and, for a release not declared stop-everything, run an N−1 `api`
      extension against an N engine cancellation and a settlement replay across the pair.
      **Then the concurrent index step** (added 2026-09-12): kill the runner mid-build of a
      `CONCURRENTLY` index on `operations` and assert the version is unrecorded and the index is
      `INVALID`; re-run and assert the invalid index is dropped, rebuilt valid, and the version
      recorded once — and assert the runner refuses a migration that places that statement inside
      a transaction with any other.
      **Then the about-to-order contract step:** leave legacy creates `running`, including one
      whose order reached the provider on a `correlator: none` channel. Stop all previous-release
      components before the backfill; assert no new component starts until it completes. Read
      each stored row: null becomes the migration instant, a set value stays unchanged, and every
      running create is covered. Restart on the migrated store and assert `needs_reconciliation`,
      never `failed` with a released commitment. Re-run the migration and assert no value changes;
      assert the backfill migration declares its stop-everything order and records that rollback
      past this release is inadmissible. (`STO-12`, `STO-13`)
      *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the conservative backfill drill with declaration checks; retained the concurrent-migration release drill; `ADR-0042`.*
- [ ] **CNF-58** — An unrecognized status read from the store is a hard error. (`STO-10`)
- [ ] **CNF-59** — A deleted machine is tombstoned, and operations referencing it still
      resolve. (`STO-8`)
- [ ] **CNF-60** — The operation view never contains the stored request payload. (`API-21`)

## Deletion semantics

- [ ] **CNF-63** — **Amended 2026-10-11 (`ADR-0037`, Q22/Q23c).** For an accepted dated
      cancellation, assert the driver surfaces its effective date and performs exactly one
      read of the known machine on the known provider account. Return mapped absence (including
      Robot `SERVER_NOT_FOUND`) and assert the gone outcome at that read, not at the date or
      sweep. Return a present machine and assert `succeeded` with the accepted date as
      `cancellation_scheduled`. Return throttle, authentication, network error and deadline
      expiry on that read and assert the same scheduled success, never absence or
      `needs_reconciliation`. A generic HTTP error and a mismatched identity establish no
      absence. Separately lose the mutation's acceptance or date and assert no scheduled
      success is inferred. Convert a day-only effective date in the provider's date zone to
      its end-of-day UTC wire instant; retain an explicit timestamp's instant and convert a day-only permitted-from `earliest_cancellation_date=2026-10-31` to the stored start `2026-10-30T23:00:00Z` in an isolated Europe/Berlin fixture. At provider-local noon on October 31, the date has passed, so take the ordinary branch; infer no meter stop from that field. In a separate future-day fixture, price cost through the end of the earliest date's provider-local day while keeping the stored permitted-from start distinct. Robot's date zone is verified by `docs/research/panels-2026-10/r40/zone-check.txt`.
      (`PRV-12`, `PRV-13`, `OPS-11`,
      `PRV-36`)
- [ ] **CNF-64** — **Amended 2026-10-11 (`ADR-0037`, Q21/Q22/Q23a).** After a dated
      cancellation whose read-back finds the machine present, assert `cancellation_scheduled`
      remains visible in inventory. Repeat with throttle, authentication, network and
      deadline failures on that read: the attempt succeeds as scheduled with its stored
      date, the episode stays `scheduled`, and its fence stays set. Advance beyond a stored
      date already passed at acceptance in both the present and failed-read traces, as
      isolated fixtures rather than newly enabled v1 sales: the
      meter stops at the date, but the episode and fence remain, no gone-write or tombstone
      is produced by the clock, and inventory still shows the scheduled machine. If the
      mark already passed that date, `LDG-38`'s posted entries and mark stay unchanged;
      no later increment posts beyond the stop. In a
      second isolated trace, record mapped post-cancellation absence inside the visibility
      window before the effective date: stop the customer meter at that observation, close
      the episode `resource_gone` and clear the fence in the gone-write. In another isolated
      future-date trace, let the cancellation read-back find the machine present, leaving it
      scheduled; repeat with a failed read-back. Before the stored effective date, run a
      complete `OPS-32` account pass after the create visibility window: omit the machine
      from the listing and confirm its absence by direct read. In each trace, assert the
      gone-write stops the customer meter at this earlier observation, closes the episode
      `resource_gone` and clears the fence. In a late-sweep trace, keep the machine present
      through the effective date and record authoritative gone
      on a later complete sweep pass: leave the customer stop at the stored date, with no debit
      between that date and the observation; the later gone-write closes the episode
      `resource_gone` and clears the fence without advancing the stop. Follow the present and
      failed-read traces with a later evidenced gone-write: both close `resource_gone` and
      clear the fence then. Exhaust the commitment in a failed-read scheduled trace before the stored stop date: assert `LDG-31` records `clamp_overflow`, takes nothing from available, and clips metering at the date even if no gone-write has yet arrived. The failed read supplies no absence evidence. In a third trace, record gone while
      a known billable
      attachment lacks release evidence: the episode closes and fence clears at the
      gone-write, while the machine remains untombstoned until the retention gate permits.
      Resolve a retained attempt afterward and assert the close stays closed. (`DOM-19`,
      `STO-8a`, `STO-18`, `OPS-48`, `LDG-31`, `LDG-38`, `LDG-74`, `PRV-13`)
- [ ] **CNF-65** — **AMENDED 2026-09-08 (`ADR-0018`) — the cleanup path now has a method.** After
      every delete that succeeds with the resource gone, the engine calls *list attachments*
      (`PRV-45`) and writes `machine_attachments`; a release is enqueued for every row whose kind
      the descriptor declares `cleanup: api` and which is billable, and the kinds declared
      `cleanup: manual` in `surviving_attachments` (`PRV-44`) are the only ones left for the
      operator. Assert against a delete that leaves one of each. (`PRV-13a`, `PRV-44`, `PRV-45`)

## Ceilings for autonomous callers

- [ ] **CNF-69** — A principal that sets every acknowledgement flag on every request still cannot
      exceed its destruction, creation, imaging or spend ceiling. Drive it with a loop that
      acknowledges everything and assert the ceiling stops it. **AMENDED 2026-09-02 — assert the
      refusal, not only the stop.** The rejection is kind `ceiling_exceeded` (`DOM-17`), never
      `rate_limited` and never `halted`, and carries `details.ceiling`, `details.limit`,
      `details.interval_seconds` and `details.retry_after_ms` (`WIR-9a`). It happens at `API-7`
      step 5c: **after** the idempotency fingerprint, so a replay returns its stored result rather
      than spending a slot twice, and **before** any commitment opens or anything is enqueued.
      Assert the exemption. An exposure-reducing system cancellation is not refused by a
      principal's destruction ceiling (`OPS-39`), or a tenant that hit its limit keeps machines the
      operator pays for. *Until 2026-09-02 this item sat on the checklist against a taxonomy that
      could not express its rejection and a pipeline that never performed its check.* (`SEC-39`, `DOM-17`, `API-7`,
      `WIR-9a`, `OPS-39`)
- [ ] **CNF-70** — The deployment has recorded *where* ceilings are enforced and what each integer
      is. Under `ADR-0001` that is this control plane — there is no front service to defer to,
      which is why the front-service variant of this rule was swept. (`SEC-39`)

## Audit

- [ ] **CNF-61** — Every mutating request produces an audit record with correlation id,
      identity, admin-override target if any, operation id and kind, machine, and outcome.
      (`SEC-32`)
- [ ] **CNF-62** — Audit records go to a destination separate from the operation store.
      (`SEC-33`)

## Enrolment and credentials

- [ ] **CNF-76** — **REWRITTEN 2026-09-02** — it tested `issuable_at`, which `API-33` withdrew: the
      delay no longer sits after issuance, so "no usable credential before the delay elapses" is
      false of a conforming build. It now tests the gate that replaced it: `POST /v1/enrol` is
      refused `invalid_request` with no admission token, with an expired one, with an unknown one,
      and with one already spent — and the four refusals are **indistinguishable** to the caller, so
      the endpoint is not a free oracle for tuning the attack it exists to slow. The credential
      returned by a successful enrolment works immediately. *Withdrawn text:* Enrolment returns no
      usable credential before the configured delay elapses, and the not-yet response does not
      disclose the remaining time precisely. (`API-33`, `WIR-49`, `WIR-12`)
- [ ] **CNF-77** — An unfunded pending tenant is deleted at its TTL together with its credential.
      Verified by clock advance, not by reading the code. It is the storage bound that makes
      unauthenticated enrolment safe at all, and `CNF-123` exercises its second half. (`API-34`)
- [ ] **CNF-78** — **REWRITTEN 2026-08-14** — the old item tested a rule two amendments had
      replaced, and no implementation could satisfy it and `CNF-125` at once: it predates
      `API-43`'s allowlist, and "until a payment has been credited" is the per-payment trigger
      `API-35` withdrew on 2026-08-13. It now tests: a pending tenant performs **no action outside
      `API-43`'s allowlist** — every other authenticated endpoint answers `not_activated` — and it
      **remains pending until its cumulative credited balance reaches the configured minimum**,
      so two credited payments that each fall short but together clear the minimum activate it.
      *Withdrawn text:* A pending tenant can perform no authorized action of any kind until a
      payment has been credited. (`API-35`, `API-43`, `DOM-20`)
- [ ] **CNF-79** — Enrolment rate-limiting state is never persisted — no caller address reaches
      the store or the logs. (`API-36`, `ADR-0005`)
- [ ] **CNF-80** — **REWRITTEN 2026-08-13** — testing "no column beyond those specified" now fails
      every *conforming* implementation, since `STO-34`'s handle, issuance and assignment state
      must exist. It tests the prohibition instead: **no column in any table holds anything that
      could identify, locate or contact a person, or that derives from the caller's network path**
      (`ADR-0005`). **AMENDED 2026-08-16 — one carve-out, with its bounds named:**
      `abuse_statements.body` and the `abuse_cases.sent_statement` derived from it are
      caller-supplied free text the deployment MUST NOT inspect (`WIR-43`), and may therefore
      contain what a tenant volunteered. They are bounded by `WIR-43`'s size cap, `STO-42`'s purge,
      `STO-43`'s age, and `STO-40`'s rule that the content MUST NOT be used to identify, contact or
      authenticate anyone or copied anywhere else. *Named rather than left implicit: this item
      already had to be rewritten once for being unsatisfiable against the rest of the set, and a
      conformance test every correct build fails is one that gets ignored entirely rather than
      argued with.* *Withdrawn text:* The `tenants` table holds no column beyond those specified. Asserted by a schema
      test that **fails when a column is added**, because the way a privacy policy dies is one
      harmless-looking column. (`STO-21`)
- [ ] **CNF-81** — Operator credentials still come only from the environment, and no runtime-issued
      customer credential can become one. (`API-4`)

## Reconciliation and correlators

- [ ] **CNF-82** — A create writes its correlator into the provider — the operation id where a free field exists, otherwise the per-operation artifact `PRV-32` defines — and records it against the operation before the order is sent
      **in the same request that performs the mutation** — verified against a recorded provider
      request, not against a follow-up call. (`PRV-26`)
- [ ] **CNF-83** — The correlator carries no tenant identifier, customer-chosen hostname, or other
      linkable value. Anyone reading the operator's provider console learns nothing. (`PRV-26`,
      `ADR-0005`)
- [ ] **CNF-84** — Resolution attaches a resource only on an **exact** correlator match. A machine
      matching on hostname, offer and creation window but carrying no correlator is left
      unresolved, not attached. (`OPS-29`)
- [ ] **CNF-85** — Resolution performs no mutation. A driver whose search path mutates fails this
      item. (`OPS-28`)
- [ ] **CNF-86** — A sweep does not attach a resource whose operation is still `running` and not
      yielded (`OPS-8`). (`OPS-30`)
- [ ] **CNF-87** — A commitment is closed and its reserved satoshis returned once the negative
      window elapses, even though the operation remains open, and the sweep keeps searching
      afterwards. (`OPS-33`)
- [ ] **CNF-88** — The account-wide sweep reports an unrecorded machine to the operator and attaches
      it to no tenant. (`OPS-32`)
- [ ] **CNF-89** — Resolution columns are write-once; a second resolution of the same record is
      refused. (`STO-19`)
- [ ] **CNF-90** — **REWRITTEN 2026-08-13** — the old item tested the case `PRV-27` calls
      impossible (recording a transaction identifier the provider never returned because the reply
      was lost). It now tests: the identifier is recorded **when the provider returned one**, and
      resolution succeeds **without** it via the durable correlator (`PRV-32`, `OPS-27`).
      *Withdrawn text follows.* An order-shaped driver records the provider's transaction identifier **before**
      the outcome can be classified ambiguous. (`PRV-27`)

## Ledger and money

- [ ] **CNF-91** — No floating-point type appears anywhere in a money path. Asserted at the type
      level, not by inspection. (`LDG-1`)
- [ ] **CNF-92** — Adding two amounts with different currency codes is refused — never silently
      converted. (`LDG-3`)
- [ ] **CNF-93** — The ledger has no update or delete path at the storage layer. Attempting one
      fails; convention is not the control. (`LDG-5`, `STO-22`)
- [ ] **CNF-94** — A replayed top-up notification carrying the same idempotency key credits exactly
      once. (`LDG-8`)
- [ ] **CNF-95** — A create whose available balance is one satoshi short is rejected and **no
      provider call is made**. (`LDG-9`, `LDG-12`)
- [ ] **CNF-96** — A commitment and its operation are written in one transaction: killing the
      process between them leaves neither. (`LDG-11`, `STO-23`)
- [ ] **CNF-97** — No sequence of concurrent operations can drive a balance negative. (`LDG-10`)
- [ ] **CNF-98** — Remaining runway is readable from the machine view before exhaustion.
      (`LDG-15`)
- [ ] **CNF-99** — One adverse rate observation keeps to `LDG-16`'s bound — `LDG-16` says "no single
      rate observation moves the rate outside the range the window's other observations carry" — and
      a window that cannot produce a rate halts instead of pricing. **Asserted through the
      mechanism, not the outcome** (2026-09-05; rewritten 2026-09-21 for `ADR-0026` and 2026-09-23
      for `ADR-0027`, with the sub-quorum and ageing-out cases added the same day for its two
      amendments, the steady-state and silent-feed cases for `LDG-59`'s two clocks, and the
      two-subjects, thin-start and preserved-row cases 2026-09-25 for `STO-37`'s opening rule, and
      the crossing and concurrent-guard cases the same day for `ADR-0027`'s replayed start, and
      the deadline assertions restated 2026-10-02 on `LDG-64`'s computed deadline, with the
      no-record, restart and changed-parameter cases, for `ADR-0029`):
      assert the rate itself, not only whether a disk survived. **One poisoned pass among honest ones**, in
      three shapes, each asserting that the rate lies inside the range the remaining honest
      observations carry: fill a window with five honest observations at distinct prices and replace
      any one with a print far below them all; fill it again and replace any one with a print far
      above them all; and fill a window with honest observations at 100, 103 and 104, replace the
      103 with 101.5, and assert the rate reads 101.5 — a price no honest pass accepted, inside the
      honest range. **A print carried by half the window**: fill a window with four observations,
      two of them at one print below every honest price, and assert the rate is that print. **A
      window with no fresh observation**: let every observation inside the window age past the
      staleness bound and assert there is no rate, observed as `CNF-138` observes it from dead
      sources. **A thin window**: leave two fresh observations inside it and assert there is no
      rate, the same way. **Steady state at a window of exactly three passes never drops the rate
      between passes** (added 2026-09-23, `ADR-0027`, with the next case, for `LDG-59`'s two
      clocks): configure the window to hold exactly three passes — cadence × 3 = window length —
      with a staleness bound longer than the cadence plus the read-to-acceptance lag — the
      interval from `observed_at` to `accepted_at` — and negligible publication delay in this
      fixture (*amended 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*) — and run in steady state, so the oldest
      observation ages out just before each new one arrives, each accepting pass running strictly
      after the oldest has aged out, so that a continuous count would read two in between; assert
      that at every instant between passes there is a rate and it is the one the last accepting pass
      computed, and that the count of observations inside the window is not re-tested between
      passes. **A feed silent for longer than the staleness bound is no rate before any pass accepts
      an observation**: with a window that produces a rate, stop every source, or otherwise ensure
      no pass accepts an observation, and let the wall clock advance past the staleness bound
      measured from the newest observation's `observed_at` with no pass having accepted anything
      since; assert that at that instant there is **no rate** — a create is refused and
      re-derivation halts without cancelling (`LDG-40`) — before any pass accepts an observation,
      and that the opening of the `LDG-64` outage does not wait for a pass to notice (`STO-37`).
      **Two subjects' meters posting after one outage began** (added 2026-09-25, `ADR-0027`, for
      `STO-37`'s opening rule): with the feed silent past the staleness bound as above, let two
      machines in one currency each post through the meter after the outage began, each finding no
      open row for itself, and assert two `STO-37` `rate_outage` rows, one per machine, each
      `absorbed_from` equal to the newest observation's `observed_at` plus the staleness bound — the
      two equal to each other and to neither posting's wall clock — and each machine's view
      (`WIR-11`) showing `rate_outage_deadline` equal to that instant plus `LDG-64`'s bound. **A
      machine with no record shows the same deadline**: assert that a third machine priced in that
      currency, under `LDG-72`'s quarantine so that its meter posts nothing and it has no
      `STO-37` row, shows that same `rate_outage_deadline`, that a machine priced in a currency with a rate
      shows null, and that no `STO-37` row stores a deadline. Then, past that deadline, let the
      worker's `OPS-41` contend run on the third machine, which has no record, and assert the
      third machine still has no `STO-37` row — `STO-37`: "Nor does the worker's `OPS-41` contend
      open one"; a build whose worker inserts where it finds no row, or upserts, fails here and
      passes on a machine that already has one. **A thin window's outage
      starts at the pass that found it thin** (added 2026-09-25, `ADR-0027`): with a window that
      produces a rate, and a staleness bound longer than the gap between its last accepted
      observation and the pass that finds it thin, so that observation is still fresh when the
      window is found thin, let the window come to hold fewer than three observations as of an
      accepting pass — passes below `LDG-59`'s quorum accept nothing while older observations leave
      the window — so that pass finds it thin; post the meter for one machine metered in that
      currency and assert that the `STO-37` row it opens carries `absorbed_from` equal to that
      ~~pass's `observed_at`~~, not the newest observation's `observed_at` plus the staleness bound,
      which lies in the future. *Amended 2026-10-04 (`pv-gip.28`, Q13): the struck-through
      2026-09-25 boundary is withdrawn; assert the pass's `accepted_at` under `LDG-58`
      instead, including when observation precedes acceptance.* **An open row is preserved**: then let the newest observation age
      past the bound — a staleness computation would now yield a later start — post the meter again
      for the same machine, and assert that the row's `absorbed_from` did not move and no second row
      opened. **The clocks cross inside one outage** (added 2026-09-25, `ADR-0027`, for the replayed
      start): with a staleness bound `b` shorter than the pass cadence `c`, a window of length `3c`
      and `LDG-64`'s bound `M` longer than `3c`, let passes at `t0−2c`, `t0−c` and `t0` each accept
      an observation, so that at `t0` the window holds three, the newest (`observed_at = t0`) is
      fresh, and there is a rate; the case starts from the pass at `t0` and asserts nothing before
      it — any rows an earlier flap opened were closed at or before `t0` by `LDG-64`'s closer, the
      "observation with which `LDG-58`'s window produces a rate again".
      *Amended 2026-10-04 (`pv-gip.28`, Q13): that 2026-09-25 quotation is historical,
      superseded wording. Use `accepted_at = observed_at` for these passes and close earlier
      flap rows under current `LDG-64`; the quotation supplies no observation-time instruction.*
      Keep machines A and B in that currency continuously billable from `t0` through the last
      tested posting, within one billing period. Each has an open increment starting at its seed
      or prior high-water mark at `t0`, with no intervening posting before its specified posting
      below. Let the feed go silent, so
      that at `t0+b` the newest observation is stale and there is no rate, with no pass running
      (`LDG-59`). Post machine A's meter at some `tA` in `(t0+b, t0+c)`; it finds no open row for A
      and opens A's row: assert `absorbed_from = t0+b` and, on A's view, `rate_outage_deadline =
      t0+b+M`. Let the
      passes at `t0+c` and `t0+2c` fall below `LDG-59`'s quorum, accepting nothing and writing no
      `STO-49` row, and after each assert that A still has its one open outage row, no duplicate
      has appeared, and `absorbed_from` remains `t0+b`. At `t0+3c` let a pass accept one observation
      (`accepted_at = observed_at = t0+3c`): as of that pass the window holds at most two observations — `t0−2c`
      and `t0−c` are outside it and `t0` is at its edge — so on either side of that edge the window
      is thin, and there is still no rate although the new observation is fresh. Accept no further
      observation before the tested postings finish. Post machine B's meter at some `tB` with
      `t0+3c < tB < t0+b+M`; it finds no open row for B and opens B's row: assert
      `absorbed_from = t0+b`, equal to A's and not `t0+3c` (what the per-writer thin formula would
      give), `rate_outage_deadline = t0+b+M` on B's view, one deadline for both machines, and that
      `[t0+b, t0+3c)` lies inside both B's posting span and its absorbed window, so B's `LDG-38`
      apportioning charges nothing for it. Assert also that B's write read no sibling row. For
      that independence check, rerun with A's posting delayed until after B's but before `t0+b+M`,
      or omitted, keeping B's billable span and starting mark unchanged: B's result is identical.
      **A restart does not move the deadline, and a changed parameter does**
      (added 2026-10-02, `ADR-0029`): mid-outage, restart the engine with every `OVR-19` value
      unchanged and assert each machine's `rate_outage_deadline` is the instant it was; restart it
      with the maximum tolerated outage changed to `M′` and assert each reads the outage's start
      plus `M′`, without changing the absorbed window. (*Amended 2026-10-04, `pv-gip.28`.*)
      **Stamped rows preserve the outage across settings changes.** Use a populated window,
      newest observation at 12:00 stamped with a 20-minute bound, and a silent feed. A was
      billable before 12:20 and posts at 12:25: its row starts at 12:20, with null end and zero
      stored absorbed seconds. At 12:30 load a 60-minute bound and post A again and first-post B,
      also billable before 12:20, later: both starts stay 12:20 and neither closes. No duplicate
      row or already-granted relief is lost; both deadlines remain 12:20 plus the maximum.
      A third subject seeded at 12:35 clips its start to 12:35. At 12:50 an accepting pass with
      sufficient retained observations actually yields a rate: closures are at 12:50 with
      1800/1800/900 seconds respectively. Each subject subtracts its own row's overlap.
      Reverse A/B posting order and omit A entirely: B's outcome is identical.
      **Loading a larger window cannot end a thin verdict.** Retain observations at 11:40,
      11:50 and 12:00 with a 30-minute window and 20-minute stamped bound; the 12:00 pass
      produces a rate. Accept nothing until 12:50, whose pass is thin under that window and
      stores null. The outage starts at 12:20. With seed/mark 12:00 and enough authority, post
      at 12:25: row [12:20, null), stored seconds zero. Load a two-hour window at 12:55 and
      accept nothing before posting at 13:00. The row remains open from 12:20; loading the
      window supplies no return. With customer rate 1/5 sat/s before the outage, no price or
      margin changes and initial `r = 0`, the two postings charge 1200 × 1/5 = 240 sats total,
      none for [12:20,13:00), final `r = 0`, mark 13:00. Repeating the posting adds nothing.
      A subject first posted at 13:00 gets the same outage start, clipped to its own seed.
      At 13:05 accept a pass with enough retained observations to yield customer rate 2/5:
      close at 13:05 with 2700 absorbed seconds. Posting through 13:10 then adds 300 × 2/5 =
      120 sats (360 total), never charging the absorbed interval. In a separate run, make the
      subsequent accepting pass thin too: no closure until a later pass actually yields a rate.
      **Setting changes alone leave the verdict and stamped staleness unchanged.** Raise and
      lower window length while a rate is held and while its latest verdict is null: neither
      action changes the verdict or historical spans. A newest 12:00 observation stamped with
      a 60-minute bound still supplies freshness at 12:30 after loading a 20-minute bound at
      12:10 without a pass; it expires at 13:00. New observations use the new bound. Conversely
      raising a bound never revives a stale observation. After shrinking a window, let the next
      accepting pass find it thin while the newest observation is fresh: the outage starts at
      that pass, not at configuration load. Prune everything now eligible under `STO-49`, then
      first-post a subject seeded before that outage and assert the same start and relief.
      Enlarge again: only retained observations enter future computations; no invented rows or
      changed historical verdicts. Exercise an accepting row observed earlier than a prior row:
      its acceptance order selects the verdict, but freshness uses the newest observation's
      own stamp, not the latest accepted row's bound. Restart over unchanged stamped rows and
      verify the held verdict, start and all historical spans survive.
      **Acceptance-time replay** (*added 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*).
      Previous newest observation 10:50, stamped bound one hour; a non-thin pass reads at
      11:45 and is accepted at 11:55. Post one subject at 11:52 and another only after
      acceptance, both seeded before 11:50. Each row starts at 11:50 and closes at 11:55;
      reverse posting order and omit the early posting: starts and charges are unchanged.
      Acceptance cannot erase [11:50,11:55). For a delayed thin verdict, keep old evidence
      fresh through acceptance, read at 11:45 and accept null at 11:55: the outage starts
      at 11:55, not 11:45. Before 11:55 the earlier accepted non-null verdict still holds.
      Repeat with a latest-accepted observation older than a previously accepted one:
      acceptance order selects the verdict and observation order selects freshness, using
      only rows accepted by the queried instant. With the previous `accepted_at = 11:55`,
      roll the transaction clock back to 11:50: the next row is stamped 11:55 and a larger
      acceptance order. At that tied timestamp use the later verdict; at 11:54 it has no
      effect. Prune all eligible rows and restart, retaining the prior accepted row for
      the clamp and the predecessor/freshness inputs for an open increment and an open
      restore across repeated returns. Replay all tested boundaries unchanged, including
      a delayed row whose `observed_at` is before an increment's left edge but whose
      `accepted_at` is inside it. `CNF-277` owns the delayed-return billing/deadline cases;
      `CNF-218` owns the usable-grace case.
      **Quorum changes acceptance, not replay.** With the needed history retained, raise
      the quorum from three to five while holding staleness and window fixed. Assert that
      recorded observations accepted from three sources remain replay inputs, and replayed
      outage boundaries and existing rows are unchanged. A new pass with three live,
      non-excluded sources accepts nothing and writes no observation; a later pass with
      five accepts one, whose effect on the window is then replayed normally.
      **Two concurrent postings
      of one subject open one row** (added 2026-09-25,
      `ADR-0027`): let two concurrent postings of one subject both compute no rate and both find no
      open row for it, and assert exactly one `rate_outage` row for that subject, both postings
      continuing against it, and its `absorbed_from` the replayed instant. **A sub-quorum pass with
      a fresh window**: with a window that produces a rate, run one pass below `LDG-59`'s quorum and
      assert that creates and re-derivations proceed at the rate in force, that no `LDG-40` halt
      fires and no `LDG-64` outage opens, and that the next accepting pass recomputes the rate. **An
      observation ageing out mid-increment**: fill a window with observations at 104, 100, 102, 106
      and 108, oldest first, so the rate is 104; let the oldest age out between two passes inside an
      open increment — recomputed then, the four left would give 102 — and assert that the rate does
      not move and the increment is not split before the next accepting pass recomputes; let that
      pass observe 110 inside the same increment and assert that the rate becomes 106 — with the
      oldest still inside the window it would have stayed 104 — that the change splits the increment
      at that pass's `STO-49` row, and that the age-out changed nothing charged: the increment the
      split closes is debited at 104 for all of its time, the stretch after the oldest aged out
      included, and only the one it opens is priced at 106 (`LDG-38`). **Then, with a rate in
      force, let a runway expire
      with no rate movement at all and assert the machine is routed on the very next sweep** — a
      build that holds every past date for a second look runs each ordinary exhaustion one interval
      into the wind-down reserve. **A gone machine is not routed again:** retain a past
      stored date after recording a machine gone and closing its episode `resource_gone`.
      With a rate present, the next exhaustion sweep opens no episode and enqueues no attempt.
      With no rate, at and after the outage deadline, the bound canceller likewise opens no
      episode and enqueues no attempt. Contrast a live machine without an outage record,
      including a quarantined one: at the bound it is enqueued. A live scheduled cancellation
      is not a gone record. **Then the restore edge** (added 2026-09-12, `ADR-0023`; rewritten
      2026-09-25, `ADR-0028`, to measure from step (3)): with a rate continuously in force,
      an active tenant, sufficient available balance and otherwise satisfied extension admission
      conditions, with the requested runway extending beyond the tested re-claim, restore a store
      in which a machine's stored
      `runway_until` is past, run `STO-54`'s procedure, and assert that the record's `grace_ends_at`
      (`STO-56`) is step (3)'s instant plus one re-derivation interval and that the exhaustion sweep
      does not route the machine before it — the freeze holds; take a queued delete re-run by step
      (2) and claimed before step (3), and assert it defers by a short delay, writes no fence
      (`machines.destroy_committed` stays null) and makes no provider call; take one claimed after
      step (3), and assert it is returned to `queued` with `available_at = grace_ends_at`, writes no
      fence and makes no provider call (`OPS-41`); extend the machine inside the grace, and assert
      the extension is admitted — no fence refuses it — and that at the re-claim after
      `grace_ends_at` the worker aborts and closes the episode `funded` (`OPS-48`'s no-mutation
      row), the machine never routed again for that lapse; and take a machine already fenced when
      the grace begins, and assert an extension is refused `cancellation_committed` throughout the
      grace and that its retry's claim waits for `grace_ends_at` like every claim. Repeat with
      a restore-caused loss of `STO-49` rows leaving no rate: exercise `CNF-218`'s paused
      cases and assert the single original end is never rewritten (`STO-56`). *The per-tick cap
      clause is withdrawn with the construct it tested (`ADR-0011`). Until 2026-09-05 this item
      tested a behaviour with no column, no predicate and no reader behind it, and a build that
      routed on the date alone passed it by never being fed a poisoned reading.* (`PRV-13e`,
      `LDG-16`, `LDG-38`, `LDG-58`, `LDG-59`, `LDG-64`, `STO-37`, `STO-49`, `STO-54`, `STO-56`, `OPS-41`,
      `OVR-19`, `WIR-11`)
- [ ] **CNF-100** — At end of runway, with a rate in force, the machine is cancelled and its disk
      destroyed — and the terms and API documentation state both that destruction and the outage
      wait owned by `LDG-65` in words. (`LDG-13`, `LDG-14`, `LDG-65`)
- [ ] **CNF-101** — Under a failing solvency check, every bill-increasing operation is refused
      while cancel and delete continue to work. **The operations that reduce exposure are never
      gated by the check that fires because exposure is too high.** (`LDG-20`)
- [ ] **CNF-102** — The ledger contains no caller address, payment counterparty, preimage or ecash
      token. (`LDG-21`)
- [ ] **CNF-103** — Retention never deletes a ledger entry. (`LDG-22`, `STO-24`)
- [ ] **CNF-104** — Customer price is produced by exactly one function; no call site reads a
      provider price string directly. (`LDG-23`)
- [ ] **CNF-105** — Privileged operations are metered although they are free. (`LDG-25`)
- [ ] **CNF-106** — The reserve commits **customer** price for machine time — the prepaid first
      billing unit included, since it is machine time (2026-10-08, `ADR-0033`) — and the setup fee
      **at cost** — a reserve computed from provider cost under-commits by exactly the margin.
      (`PRV-13b`, `LDG-24`)

### The prepaid first billing unit (2026-10-08, `ADR-0033`)

A machine's first provider billing unit is prepaid machine time at the customer rate, on the setup
fee's lifecycle, and the meter starts where it ends. One item per new MUST; the items that assert
the fee's shape were amended the same day to stay true for both obligations.

- [ ] **CNF-313** — **The billing unit is declared per offer, floor or no floor.** Each launch
      driver's descriptor declares `billing_unit` `{seconds, native_floor}` per offer, or reports
      it on the offer: Hetzner Cloud and Robot an hour and a null floor, DigitalOcean 60 seconds
      and a `"0.01"` floor carried as a string. The engine reads the unit from the descriptor or
      the offer and from nowhere else: a build that takes it from `08-provider-notes.md` or from
      a constant fails, and so does one that sells an offer whose field is missing. (`PRV-44`,
      `PRV-13c`, `DOM-9`)
- [ ] **CNF-314** — **The unit is disclosed beside the setup fee, with no native figure.**
      `GET /v1/providers/{account}/offers` carries `first_unit_sats` and `billing_unit_seconds`
      on every offer: the first is the greater of `billing_unit.seconds` at the offer's recurring
      price and `native_floor`, margined and converted as the recurring price is; the second is
      `seconds`. Assert on a floor-priced offer that `first_unit_sats` is the floor's price with
      the margin, and on every offer that neither `native_floor`, the native rate nor a currency
      string appears. (`DOM-9`, `WIR-30`, `LDG-26`, `PRV-13b`)
- [ ] **CNF-315** — **The unit is committed at the customer rate before the order is placed.**
      Create against an offer with a non-zero unit: the commitment includes `first_unit` at the
      customer rate and the setup fee at cost. Kill the process between the commitment's open and
      the order: no order is placed (`LDG-12`). With a balance that covers every other term but
      not the unit, the create is refused before any provider call. On a floor-priced offer the
      term is the floor with the margin, not `seconds` at the rate. On an offer whose `first_unit`
      is zero — zero `seconds` and a null floor, or a zero recurring price and a null floor — the
      commitment carries no unit term and the ambiguous row parks nothing for the unit
      (2026-10-08, `ADR-0033`). (`PRV-13b`, `PRV-44`,
      `LDG-12`, `LDG-24`, `LDG-39`)
- [ ] **CNF-316** — **Successful settlement after acceptance debits the authorized amount as its
      own kind, paired with the decrement.** Move the rate
      between the create and the provider's acceptance. The entry is a
      `first_unit_debit`, never a `usage_debit`, for exactly the satoshi amount
      `operations.request_summary` carries as authorized and not a re-conversion; the commitment
      is decremented by the same amount in the same transaction (kill the process between them
      and neither survives); `available` does not move. A machine that lives ten seconds has paid
      the whole unit, and the meter has posted nothing for it. Accept an order on an offer whose
      `first_unit` is zero: no `first_unit_debit` and no entry of any kind is posted for the unit,
      and no deficiency is ever recorded for it (2026-10-08, `ADR-0033`). Assert the machine
      reference identifies its own nonzero debit on paid settlement and remains null on the
      zero case. Inject failure between debit, decrement, reference and same-transaction seed:
      all or none persist; replay creates no duplicate. Repeat with settlement by resolution
      and with a delayed first seed after purging the operation: eligibility still reads the
      retained reference and entry, never the purged operation or the live offer. (`LDG-39`, `LDG-67`,
      `LDG-31`, `LDG-7`, `LDG-38`, `STO-45`)
- [ ] **CNF-317** — **The unit follows every row of `LDG-39`'s table, as a record of its own.**
      Drive each row with a setup fee and a prepaid unit on the same create. Deterministic
      rejection and resolved-absent release both in full. Ambiguous parks both on the operation,
      each with its native amount and its authorized satoshis (`LDG-67`). Resolved-observed before
      `OPS-33`'s release debits both against the commitment as two entries of their own kinds;
      after the release each becomes its own operator deficiency — `unrecoverable_setup_fee` and
      `unrecoverable_first_unit`, two records with distinct `idempotency_key`s, the unit's
      `native_minor` its provider-native cost including the floor and without the margin, its
      opening rate the one in force when the record opened, as the fee's is — null only where no
      rate existed then, `CNF-308`'s case (`LDG-66`) — absorbed seconds zero, `provider_account`
      copied from `operations.provider_account`, `subject_kind: operation` where no machine row
      exists — both in `OPS-27`'s single resolution transaction (kill between them and neither
      survives), and a wind-down commitment `OPS-36` opened is decremented by neither. On
      resolved-absent with a provider transaction showing the fee charged and not the unit, only
      the fee's record is produced; showing the unit charged and not the fee, only the unit's;
      showing both, both. Abandoned produces both records and clears both parked obligations. No
      row debits available balance: a paired debit leaves it unchanged, a release raises it by
      exactly the commitment's remaining amount (`LDG-32`, `LDG-9`), and a deficiency moves it not
      at all. (`LDG-39`, `LDG-67`, `LDG-66`, `STO-37`, `LDG-75`, `OPS-27`, `OPS-31`, `OPS-33`,
      `OPS-36`, `LDG-31`, `LDG-32`, `LDG-9`)
- [ ] **CNF-318** — **A paid first seed is offset by the unit, and nothing inside the unit is
      metered.** On an offer with a 60-second unit at 1/5 sat/s, actually debit the first unit
      at settlement, then record the machine billable at 30: its mark is 90,
      no entry was written by the seed and `r` is unchanged. A tick at 60 and an exit at 80
      each post nothing and move nothing — no entry, no decrement, no deficiency, `r` and the mark
      where they were — and the prepaid debit stands. Re-enter at 85, inside the unit: the mark
      stays 90. Tick at 120: the increment is priced over 90–120 under the key of the increment
      ending at 120, six satoshis. Exit at 150 and re-enter at 200: the mark is 200, with no
      offset and no second prepaid debit. Seed a billable attachment of the same machine: its mark
      is its seed instant. Repeat the first seed on a floor-priced offer: the mark is still the
      seed plus `seconds`. Re-list the offer with a 3600-second unit between a create accepted at
      60 seconds and the machine's first seed: the mark is still 90, read from
      `machines.billing_unit_seconds`, the copy written with `offer_id` at create or at attach,
      and never from the live offer; remove the settled create under `STO-14` before the seed and
      the mark is still 90; null the copy and the mark is the seed instant, never the live offer's
      unit (2026-10-08, `ADR-0033`). With positive seconds but zero `first_unit`, assert a null
      `first_unit_debit_id`, mark 30 and no prepaid interval; also assert no offset where the
      create commitment was released and only a provider charge or parked obligation exists.
      With zero seconds and a paid money floor the mark is still 30. The wrong builds: one that seeds at
      the instant charges the customer the unit and the seconds; one that offsets every seed hands
      the customer a unit on each re-entry; one that offsets an attachment meters nothing it
      should; one that reads the live offer at the seed meters a unit nobody prepaid, or prepays
      one it never meters; one that reads the snapshot at the seed has nothing to read once
      `STO-14` has run. (`LDG-38`, `STO-45`, `LDG-72`, `PRV-44`, `LDG-67`, `WIR-30`, `STO-14`)
- [ ] **CNF-319** — **Every runway writer uses the mark.**
      Take the writer inventory from `05-persistence.md`'s `machines.runway_until` row; exercise
      every listed writer under its own preconditions. On independent copies of a machine whose
      first unit was actually debited and whose first seed at 0 wrote mark 3600, derive at 100
      with ten seconds of usable runway: each writer stores 3610. For an ordinary past mark 50,
      each stores 110; an attachment's mark is never read. Arrange the extension's resulting
      commitment to have those ten usable seconds and a null destruction fence. For the abort,
      queue a funding cancellation on an earlier stored date, then let the re-check read these
      funded inputs; assert no provider mutation and the corrected stored date. For the keep,
      use an operator request on a genuinely stalled episode with its own fence, a valid rate,
      and no concurrent winner: it closes `kept`, clears the fence and writes the date atomically
      with the receipt, leaving commitment and balance unchanged. A paid future mark may coexist
      with a stall caused independently of funding. Before any seed, each admissible writer
      derives 110 from now; create the stalled state independently for that keep case, without
      inventing a funding gate. Assert the sweep does not route the paid future-mark fixture
      before 3610. (`LDG-33`, `LDG-72`, `API-68`, `LDG-16`)
- [ ] **CNF-320** — **An outage row starts no earlier than the subject's latest mark.** Begin a
      currency outage at 10 for a machine whose 60-second first unit was actually debited,
      seeded at 30, and tick at 60 and at
      120 with no rate: the tick at 60 opens nothing; the tick at 120 opens the subject's
      `rate_outage` row with `absorbed_from` 90, never 30 or 10; an attachment seeded at 30 in
      the same outage opens one from 30. Return the rate at 200: the close is
      `max(accepted_at, the subject's mark)` as before and absorbs 90–200 for the machine.
      Separately, exit at 80 and re-enter at 85, inside the unit and still without a rate, then
      tick at 120: the row the re-entry can open has `absorbed_from` 90, never 85 — the re-entry
      wrote no mark, and the subject's latest is the unit's end. No deficiency carries the unit's
      time in these paid cases. Repeat with the create commitment released and no customer
      unit debit: attach at 30 with declared duration 60, assert mark 30; the tick at 60 opens
      a row from 30 and the return at 200 absorbs 30–200, with no pre-attach time. Repeat with
      positive seconds and zero `first_unit`: the same unoffset mark and clipped start. Where
      a provider charge became a first-unit deficiency, assert cost enters accrual only once
      under the existing attribution rule. (`STO-37`, `LDG-38`, `LDG-72`, `LDG-64`, `LDG-75`)
- [ ] **CNF-321** — **The rounding past the first unit is an accepted gap, not an alarm.** On an
      hourly provider, run a machine for 61 minutes and delete it; record the invoice showing two
      hours. Local charges hold one `first_unit_debit` and sixty seconds of `usage_debit`; the
      second hour's remainder is absent from local charges until the invoice supplies it, enters
      accrual once, writes no deficiency and raises no alarm. Repeat with a life that straddles
      the provider's grid boundary and costs two units: the same. (`LDG-75`, `LDG-38`)

## Funding

Added 2026-08-12 with `ADR-0008`. Every item here is a way to mint satoshis that do not exist or
to strand satoshis that do.

- [ ] **CNF-116** — A payment settling for less than the requested amount credits the **settled**
      value. A credit derived from `deposits.requested_sats` is the defect — assert it
      at the call site, not by reading the number back. (`LDG-47`, `STO-29`)
- [ ] **CNF-117** — An overpayment is credited in full and is never refused or truncated. (`LDG-47`)
- [ ] **CNF-118** — No credit is posted for an unconfirmed on-chain transaction at any amount, and
      an RBF replacement that lowers the value before the stated depth results in the lower credit
      or none — never the original. (`LDG-48`)
- [ ] **CNF-119** — An accepted-but-unsettled Lightning HTLC posts no credit. A held invoice that is
      later cancelled leaves the balance untouched. (`LDG-48`)
- [ ] **CNF-120** — Two funding requests never produce the same destination on either rail, and two
      tenants never share one. (`LDG-49`)
- [ ] **CNF-121** — Two funding requests from one tenant produce two distinct on-chain addresses;
      the same request retried with the same idempotency key produces **one deposit** — same
      invoice, same address. Both halves must hold — the first is the privacy rule, the second is
      the double-payment rule. (`LDG-50`, `API-45`)
- [ ] **CNF-122** — A payment observed at an expired deposit's address, for a live tenant, is
      credited rather than refused. Expiry ends watching, not resolution. (`LDG-51`, `LDG-54`)
- [ ] **CNF-123** — Deleting a pending tenant at its time-to-live leaves its deposits intact, and a
      later payment to one of them is recorded as unattributed rather than lost or dropped.
      (`STO-29`, `LDG-43`, `API-42`)
- [ ] **CNF-124** — Killing the process between crediting the ledger and marking the destination
      settled leaves the payment credited exactly once after recovery — not twice, not zero times.
      Replaying the rail's settlement stream produces no second entry. (`STO-30`, `STO-31`)
- [ ] **CNF-125** — A pending tenant can reach exactly `POST /v1/deposits`, `GET /v1/deposits/{id}`
      for its own deposit, the unauthenticated enrolment handle, and `POST /v1/recovery/revoke`
      — **unconditionally**, since `API-33` withdrew `issuable_at` and the token is live from the
      enrolment response (`API-43`) — and **nothing else**; every
      other authenticated endpoint answers `not_activated`. The deposit-read half is what lets a
      tenant that paid below the activation minimum see what happened to unrefundable money.
      (`API-43`, `API-52`, `DOM-20`)
- [ ] **CNF-126** — The solvency check counts channel balances and confirmed on-chain outputs, and
      the deployment's stated treatment of an encumbered channel balance is the one implemented.
      (`LDG-53`, `LDG-17`)
- [ ] **CNF-127** — An on-chain payment below the floor that covers spending its own output is
      **credited at its received value, not refused** — and the floor was disclosed with the
      destination. A deposit is payable over either rail, so the floor cannot gate the mint.
      (`LDG-52`, `LDG-47`)
- [ ] **CNF-128** — One deposit paid on **both** rails credits **both** payments. Settling the
      invoice does not stop the address being watched before expiry. This is the test that catches
      an implementation which closes a deposit on first settlement. (`LDG-55`, `LDG-56`)
- [ ] **CNF-129** — The watch set survives a restart: deposits minted before the process died are
      still being watched after it comes back, and a payment to one of them is credited. Asserted
      by killing the process, not by reading the start-up code. (`STO-32`)
- [ ] **CNF-130** — The watch set contains no expired deposit. Minting deposits at the rate limit
      for longer than the expiry window leaves the set bounded rather than growing. (`LDG-57`)
- [ ] **CNF-131** — The funding response states, in words a customer would understand, that an
      expired address still accepts payments the operator will not see, and that paying twice
      credits twice with no refund. **The disclosure is the control** — there is no mechanism
      behind it. (`LDG-54`, `LDG-56`, `API-44`)

## Key custody

Added 2026-08-12 with `ADR-0009`. These are the first items that make `F13`'s "one compromise
takes the machines *and* the float" partly false.

- [ ] **CNF-132** — **AMENDED 2026-09-02 — it asserted the clause `SEC-48` withdrew.** No spending key
      or seed is reachable from the process — not in its environment, its configuration or its
      filesystem — and **no service it can call will construct a spend for it**: with the Lightning
      credential in hand, paying an invoice, sending keysend, sending on-chain, opening or closing a
      channel and signing an arbitrary message or PSBT each fail. Asserted by attempting them and
      failing. **Type-level absence is not the test**;
      `CNF-71`'s weakness was proving visibility rather than reachability, and repeating it here
      would prove nothing about the money. *Withdrawn clause:* "**nor any service it can call**"
      taken absolutely — `SEC-48` concedes that receiving Lightning is inseparable from spending it,
      so the node it calls *can* spend and the testable property is what the process's credential is
      permitted to make it do. Cancelling an unsettled invoice and reading the two balances are
      permitted and MUST succeed; a build where they fail cannot run `LDG-20`'s halt or
      `LDG-53`'s solvency check. (`SEC-48`, `LDG-20`, `LDG-53`, `F13`)
- [ ] **CNF-133** — Address derivation and payment observation both work with watch-only material
      only. Removing everything but the extended public key breaks nothing in the funding path.
      (`SEC-48`, `LDG-50`, `LDG-57`)
- [ ] **CNF-134** — The solvency check completes with no spending key present. (`LDG-53`, `LDG-17`)
- [ ] **CNF-135** — **AMENDED 2026-09-02 — it tested an automatic, channel-only sweep, and `SEC-49`
      requires neither.** The stated ceiling covers **both pots** — the channel balance *plus* the
      Lightning node's own on-chain wallet — and the sweep is a **manual operator action** whose
      mechanism (a cooperative close, or a swap) the deployment has stated. What is asserted
      mechanically is the part that is mechanical: the sweep destination cannot be changed by any
      runtime input — configuration, API, environment or database write — and where the sweep is
      signed on the Lightning host, **the signer rejects any transaction whose outputs are not the
      pinned cold destination**. That refusal is what makes the ceiling a mechanism rather than a
      habit; an item asserting an automatic sweep asserts a control this design does not have.
      *Withdrawn clause:* "Channel balance above the stated ceiling is swept to cold". (`SEC-49`,
      `SEC-50`, `ADR-0009`)
- [ ] **CNF-136** — With inbound capacity fully exhausted, a funding request still succeeds and the
      resulting deposit is payable on-chain. **This is the test that makes `SEC-51`'s manual
      refill survivable** — without it, an operator asleep is an operator not selling. (`SEC-51`,
      `LDG-46`)
- [ ] **CNF-137** — The cold key's recovery procedure has been executed end to end, from backup to a
      signed spend, by someone other than whoever wrote it. Before the first customer payment.
      (`SEC-53`)
- [ ] **CNF-295** — **The restore rehearsal** (added 2026-09-12, `ADR-0023`). Before the
      first customer payment, by someone other than whoever wrote the procedure: keep a rate in
      force for the no-outage run below, with separate active tenants for the re-extension machines,
      sufficient available balance, requested runway beyond the tested re-claim and otherwise
      satisfied admission conditions; with a `suspend_tenant` parent for another tenant unsettled — once `running`, once `queued` under `OPS-49`'s defer —
      take a backup, then in the lost interval extend a machine's runway from balance, revoke a
      spending token, let a `queued` create order and a `queued` raw-disk install write, and let
      the parent settle and the tenant resume; restore, and run `STO-54`'s procedure in its stated
      order, killing the engine twice: once after the record is committed and before step (2)'s mark
      commits, and once after step (3)'s (added 2026-09-20, `ADR-0023`). Assert of the first
      successor that it continues the incident — it takes the restore branch of the pass and
      quarantines the executed create, and `api` serves nothing until step (3) is marked; of the
      second, that it repeats no marked step — the listener is not taken down again, the token a
      tenant re-issued after step (3) still authenticates, and the record's `grace_ends_at` is not
      rewritten (*amended 2026-09-25, `ADR-0028`*);
      and that once the operator closes the record a restart is an ordinary one, leaving `queued`
      rows alone. Assert: no worker makes a
      provider mutation and nothing writes a disk before the first
      claim (`OPS-32`'s deletion of an orphaned imported image is the one provider call the freeze
      does not stop); the extended machine is not routed into exhaustion before the record's
      `grace_ends_at` passes, and its re-extension is admitted and leaves `grace_ends_at` as written
      (`OPS-41`; *amended 2026-09-25, `ADR-0028`*) — and a second machine extended in the lost
      interval and **not** re-extended is routed once the interval ends, with the extension's
      satoshis back in its tenant's balance and its `runway_until` reading the restored date
      throughout (added 2026-09-12: the grace is one interval, not a repair); the old token authenticates nothing and the
      recovery credential issues a new one (`API-56`); the create and the install are
      `needs_reconciliation`, never claimed, and `OPS-27` resolves the create `observed` where its
      correlator was written before the backup and otherwise leaves it to the operator; the
      `suspend_tenant` parent, in either state, does not resume without operator confirmation; the
      sweep's first pass records no absence and
      its second may; and the operator report names `T − Δ` and every unrecorded machine per
      account. Repeat across an outage starting inside grace and a restore-caused outage:
      after the wall-clock end the actors in `STO-54`'s freeze run, but unfinished funding grace
      still short-defers unfunded attempts in `OPS-41`'s fence transaction. Kill and restart after
      multiple qualifying returns;
      assert recomputation from retained `STO-49` history preserves the unspent time and the
      step-(3) mark and original end remain unchanged. Finish currency A's grace while B has
      unspent grace and a live unfenced machine: closing is refused. Leave B without a rate
      through its bound: closing is still refused until every machine priced in B is recorded
      gone or fenced (`machines.destroy_committed` non-null). Drive `CNF-218`'s no-return
      disposition trace, including its funded machine with no queued attempt, absent outage
      record and provider refusal; assert B ceases to block despite its unspent rate time.
      The refused deletion does not block B's discharge merely because the machine is not
      recorded gone: check its fence, not just the failed attempt. In a separate run, make every
      B machine gone or fenced before its outage bound and assert B's grace obligation is discharged then.
      Then resolve one fenced B machine's episode `abandoned` (`OPS-48`; its fence clears and the
      machine stays live) and assert close is refused again until that machine is gone or fenced
      once more: the discharge is read at close, never latched. In each run, refuse close while any other prerequisite in `STO-56` remains unsatisfied;
      exercise the wall-clock end and the other incident obligations independently, including
      a run with all machines already gone or fenced before the wall-clock end. Only when every
      prerequisite is satisfied close and verify ordinary restart behavior. `CNF-218` carries
      the refused-close/returned-rate worker regressions. *Amended 2026-10-03 (`ADR-0029`):
      withdrawn — "Leave B without a rate through its bound: B ceases to block closure".*
      (`STO-54`, `STO-56`, `STO-49`, `OPS-15`, `OPS-41`, `LDG-16`,
      `LDG-64`, `API-56`, `OPS-27`, `OPS-32`)
- [ ] **CNF-296** — **The two synchronous writes hang alone** (added 2026-09-12,
      `ADR-0023`). Stall the named standby. Assert a deposit mint and a payment credit block, every
      engine write and every other `api` write proceeds, and `OVR-18`'s alarm fires. Release the
      standby and assert the caller's re-sent funding request returns the same deposit (`API-45`)
      and the rail's replayed settlement credits once (`STO-31`). Then assert `synchronous_commit`
      reads `local` on a freshly checked-out connection (`CNF-56`'s method) and `on` only inside
      those two transactions. (`STO-7`, `STO-54`, `OVR-18`)
- [ ] **CNF-297** — **The derivation index never goes backwards** (added 2026-09-12,
      `ADR-0023`). Mint deposits, take a backup, mint more, restore, run `STO-54`'s skip-forward,
      and assert the next index allocated exceeds every index a rolled-back row held, and that no
      address is ever handed to two deposits (`LDG-49`). (`STO-54`, `LDG-49`)
- [ ] **CNF-298** — **One transaction at a time, and never across the network** (added
      2026-09-12, `F51`). With the engine's pool sized exactly to `STO-55`'s count, run every
      periodic component and a full worker set against a fleet larger than one sweep batch and
      assert no component ever waits for a second connection; instrument every provider, rail and
      rescue-host call and assert none is made while that component holds an open transaction —
      the instrumentation is the check, since a quick call inside a transaction trips no timeout;
      then hold a transaction open past `idle_in_transaction_session_timeout` and assert the server
      kills it, which is the bound on a violation the instrumentation would otherwise catch. Then,
      with the three `ledger` components running in the engine process (`OVR-17`), assert an `api`
      replica runs none of them. (`STO-55`, `STO-7`, `OVR-17`)
- [ ] **CNF-299** — **`overloaded` is refused before any transaction, and the pool
      keeps serving under a stalled standby** (added 2026-09-12, `F51`). Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, that
      the same key re-sent after capacity returns succeeds as a first send, and that a read still
      succeeds under the separate read budget; then repeat with a key whose first send committed
      before its reply was lost, and assert the re-send after the refusal returns the existing
      operation (`API-11`). Then stall the standby (`CNF-296`'s method) with more funding requests than the
      synchronous-commit cap and assert no more than the cap's connections are occupied and a
      suspension request (`API-58`) is admitted. Then let the meter fall behind its cadence by more
      than one interval and assert the alarm fires. (`STO-55`, `DOM-17`, `API-50`, `LDG-37`)

## The rate

Added 2026-08-12. Past the window median (`LDG-58`), a wrong rate is the only
external input in this specification that reaches a customer's disk (`LDG-41`, `LDG-14`).

- [ ] **CNF-138** — **No rate is not a computed solvency failure.** Use otherwise admissible
      requests with fresh idempotency keys: no unrelated suspension, cancellation fence, spending
      shortfall or restore grace explains a refusal or deferral. Before each fault, mint an
      unexpired deposit with an unsettled Lightning invoice. In both the single-currency and
      USD-unrated/EUR-rated cases, choose deposit and invoice expiries after the covered-outage
      observations and the corresponding induced-shortfall cancellation check. Keep the invoice
      unsettled until that check deliberately cancels it: verify it remains live and payable
      throughout the covered observations, and observe cancellation while it is otherwise payable
      and before either expiry. Remove the affected currency's rate
      sources for longer than the staleness bound and verify that its window yields **no rate**;
      one below-quorum pass is insufficient (`CNF-99`). Observe the sweep and worker cases before
      the outage bound. In the covered cases below, keep adequate assets after `LDG-53`'s asset
      treatment and `LDG-20`'s stress, including through the admitted purchases.

      **Only currency, covered float.** In a deployment billing in only that currency, held
      satoshis cover the float. Assert that a deposit mints, no unsettled invoice is cancelled,
      and the deposit read reports `gate: null` and `lightning.cancelled: false`.
      From the same fault, assert that a create is refused, re-derivation halts **without**
      cancelling anything, and the exhaustion
      sweep enqueues no cancellation and opens no episode for a machine whose stored
      `runway_until` passes during the outage. An `extend-runway` is refused `halted` with
      `gate: "rate_unavailable"` and moves no balance and no commitment. Once the rate returns,
      the sweep routes a machine whose stored date has passed.

      **Only currency, short float.** Keep that outage and make held satoshis fall short of the
      float. Assert the computed-failure halt: deposit minting is refused `halted`, the unsettled
      Lightning invoice is cancelled, the deposit read reports `gate: "solvency"` and
      `lightning.cancelled: true` with `expired: false`, and every
      bill-increasing operation is refused. Caller cancellation and deletion remain permitted.
      `CNF-307` owns combined extension-refusal expectations.

      **USD unrated, EUR covered.** Start independently with no halt in force and a fresh
      unsettled invoice; do not inherit the preceding short-float halt. No complete check was short
      before the outage. Bill in USD and EUR, remove only USD's rate, and keep EUR's window yielding
      its rate. Held satoshis cover the float plus stressed EUR payables. Only after USD's window
      yields no rate, arrange USD payables so that valuing them at the last pre-outage rate would
      make the check short.
      Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled
      invoice is cancelled, and the deposit read reports `gate: null` and
      `lightning.cancelled: false`. For EUR, assert
      that the sweep routes a machine whose stored `runway_until` has passed and the worker
      claiming that cancellation decides on the re-derived date without deferring (`OPS-41`).
      For USD, repeat the no-rate create, re-derivation, sweep and extension assertions of the
      covered-float case. This rejects both deployment-wide failure from the missing rate and
      last-rate fallback, as well as a sweep or worker that halts across currencies.

      **USD still unrated, valued terms short** (*amended 2026-10-04, `pv-gip.39`: exercise
      payables rather than float*). With EUR still rated, increase recorded EUR payables
      beyond held coverage. Assert the deployment-wide computed-failure halt: EUR
      create and `extend-runway` are refused `halted` with `gate: "solvency"`, deposit minting is
      refused `halted`, the unsettled Lightning invoice is cancelled, and the deposit read reports
      `gate: "solvency"` and `lightning.cancelled: true` with `expired: false`.
      Caller cancellation and deletion remain permitted. The EUR requests
      have no competing refusal; see `CNF-307` for combined refusals.

      (*Amended 2026-09-23, `ADR-0027`: a pass below quorum halts nothing (`LDG-59`), so the fault
      must outlast the bound; `CNF-99` holds the single pass.* *Amended 2026-10-02, `ADR-0029`;
      `LDG-40`'s note holds the sweep's withdrawn row.* *Amended 2026-10-03, `ADR-0029`
      (`pv-gip.31`): until then the case asserted that "the solvency check fails closed";
      `LDG-40` keeps that withdrawn row.* *Amended 2026-10-04 (`pv-gip.42`, `ADR-0030`):
      isolate the no-prior-halt trace and defer combined refusal assertions to `CNF-307`.*)
      (`LDG-40`, `LDG-59`, `LDG-16`, `LDG-17`, `LDG-20`, `LDG-53`, `LDG-62`, `LDG-65`,
      `OPS-41`, `WIR-15`, `WIR-24`)
- [ ] **CNF-306** — **An incomplete pass cannot lift a computed halt.**
      (*Amended 2026-10-04, `pv-gip.39`: payment uses the recording verb.*) With every leg
      valued, induce a short check: top-up minting halts and an unexpired unsettled invoice is
      cancelled. Remove a currency's rate until its window yields no rate. Make the valued terms
      covered, separately by adding satoshis and by recording a payment (`WIR-53`). Assert the
      incomplete passing check retains the halt: a fresh deposit request
      is refused and the existing deposit read still reports `gate: "solvency"` and
      `lightning.cancelled: true`. Restore the rate, post to close every open outage row in that
      currency, and cover the full stressed check (*amended 2026-10-04, `pv-gip.39`, S3*); only then
      does the halt lift, a fresh deposit mint succeed, and the old read report `gate: null`
      while `lightning.cancelled` remains `true`. Also keep a complete-but-short check halted.
      Repeat independently with no prior halt: first remove the rate, then make the valued terms
      short, starting a halt during the outage. Cover those terms while the rate remains absent;
      assert the same retained halt and deposit results until every leg is valued and a complete
      check passes. This rejects remembering only a short complete check or only the current
      shortfall. `CNF-138` owns no-rate-alone with no prior halt. See `CNF-310` for
      quarantine closure without posting (*pointer added 2026-10-04, `pv-gip.39`, S1*).
      (*Amended 2026-10-04, `pv-gip.42`.*)
      (`LDG-40`, `LDG-20`, `WIR-15`)
- [ ] **CNF-307** — **Rich purchase-tail refusals.** Exercise create and extend-runway after
      the common pipeline, with a fresh key each time. For each fault alone assert a singleton
      `details.refusals` whose singleton is exactly a `WIR-9` inner object, matching
      the headline and its HTTP status: unhealthy create account or fenced extension `409`
      `conflict` (reason `state` or `cancellation_committed`); unsellable create offer
      `400` `invalid_request` (`reason: offer_not_sellable`, no cap or balance amount);
      closed create ordering channel `429` `rate_limited` (`retry_after_ms`);
      solvency halt or absent rate `503`
      `halted` (gate `solvency` or `rate_unavailable`); cap exceeded `400` `invalid_request`
      (`max_commitment_sats`, `required_sats`); balance short `402` `insufficient_balance`
      (`available_sats`, `required_sats`). Assert `WIR-9a`'s per-refusal retryability and required pacing, including each
      recoverable account status (`true`) and a terminated account (`false`), each from the
      collection snapshot. For the sellable-offer unhealthy-account combinations below,
      repeat with `account_unreachable`, `credentials_rejected` and `terminated`:
      the first two account entries are retryable and retain envelope `retryable: true`
      when all other entries are retryable; termination makes the envelope
      `retryable: false`.
      (*Amended 2026-10-04, `pv-gip.26`, S2.*)
      No entry contains a nested list, no check/refusal repeats, and every refusing tail writes
      no commitment, balance, machine, operation or receipt and makes no provider call.

      A closed create ordering channel alone is `429 rate_limited` with
      `retry_after_ms` in its entry and headline, `Retry-After`, and retryable true;
      the same request/key re-evaluates after the closure clears. The stored closure
      adds no `not_checked` reason and does not withhold a price. Combine a healthy,
      sellable create with closure, solvency halt, absent rate, optional cap and short
      balance: require channel before solvency/rate; `rate_unavailable` skips both
      cap and balance when a cap is supplied, and balance alone when no cap is
      supplied. Retain any
      other applicable skip reasons in their defined order.
      With an available rate,
      exercise channel + solvency + cap + balance and channel + balance. Vary subordinate
      delays: a longer halt delay under a channel headline never replaces the channel's
      own pacing. The closure never affects an extension or early-pipeline refusal.

      Fence + solvency + absent rate: HTTP `409`, entries fence/solvency/rate in that order;
      with a supplied cap, cap and balance each unchecked because `rate_unavailable`; headline has no synthesized
      pacing. Solvency + short balance with a rate: HTTP `503`, envelope `retryable: false`,
      entries solvency (`retryable: true`) then balance (`retryable: false`), with the balance's
      amounts only in the balance entry; solvency's own pacing appears at the top level and in
      the solvency entry. Give the subordinate
      rate entry a longer delay in a solvency+rate case and assert headline pacing is unchanged.
      Cap + short balance: HTTP `400`, cap before balance, envelope false and `not_checked: []`.
      An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency, cap and balance
      unchecked because `provider_account_not_healthy`; repeat with no rate as well and require
      the rate refusal and both reasons for each skipped check. A skipped check never appears
      as a priced refusal or as passed. A fenced extension with a rate still evaluates cap and
      balance; empty `not_checked` proves they ran even though the resource refused.

      On an unsellable create with a healthy account and available rate, assert a
      singleton offer refusal, false retryability, and both priced checks skipped for
      `offer_not_sellable` when a cap is supplied. Omit the cap and assert only balance
      is skipped. Even if cap and balance would fail at a hidden price, neither
      priced refusal nor cap or balance amount derived from that price may appear
      in the headline details or a refusal entry. Combine a recoverable account, unsellable offer,
      solvency halt and absent rate: order account, offer, solvency, rate; headline
      `409`/`state`, retryable account entry but false envelope retryability, and every applicable skip reason
      appears once per present check in account, offer, rate order. Repeat with
      healthy and terminated accounts, rate available and absent, and a supplied and
      omitted cap. A priced extension retains its existing checks; the create-only
      sale guard never refuses it or adds an `offer_not_sellable` skip reason.

      Add the closed channel to that account + offer + solvency + absent-rate case:
      order account, offer, channel, solvency, rate, each once. The false offer entry
      makes envelope retryability false even though a recoverable account and channel
      are retryable; a terminated account also makes it false. A longer channel delay
      under either account or offer headline MUST NOT supply headline pacing.
      Repeat with a sellable offer and recoverable/terminated accounts to show a
      channel entry can be subordinate to the account without hiding independent faults.

      Repeat the sellable-offer absent-rate and unhealthy-account cases without `max_commitment_sats`: only balance
      appears in `not_checked`, with every applicable reason and no cap refusal. With a rate and
      healthy account and sellable offer, omitting the cap leaves balance evaluated and
      `not_checked: []`.
      (*Amended 2026-10-04, `pv-gip.26`, `ADR-0030`.*)

      *Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): the
      create-only offer refusal and its skipped price checks qualify the
      account, rate and optional-cap combinations above.*
      *Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment):
      the create-only channel entry and its headline/subordinate pacing join the combinations.*

      Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal
      left no replay receipt. Check singleton/no-rate `not_checked` as well as the empty list
      when priced checks ran. Authenticate, authorize, validate body/key, replay, suspend and
      exhaust the ceiling independently before the tail: retain the first early result with no
      rich list or extra ceiling slot. Deposit refusals and operation-view errors retain their
      existing shape. Race admission against the existing account/fence conditional-write guards;
      rich collection must not weaken either guard. (`API-7`, `API-63`, `WIR-9`, `WIR-9a`,
      `WIR-9b`, `WIR-4`, `WIR-17`, `WIR-24`, `WIR-30`, `PRV-13b`, `PRV-31`,
      `LDG-35`, `LDG-62`, `STO-35`, `OPS-11`)
- [ ] **CNF-309** — **Operator recording is idempotent accounting** (*added 2026-10-04,
      `pv-gip.39`, `ADR-0031`*). Record an invoice, payment and void through `WIR-53`; assert
      synchronous `200`, no operation/provider call/payment execution, and row plus exact result
      receipt commit atomically. Lose each response and replay the same request/key: exact stored
      body/status and one row. Change the fingerprint: `409` `conflict`/`idempotency_mismatch`.
      Re-import the same `(provider_account, kind, provider_ref)` under a fresh key, also
      concurrently and after void: `409` `conflict`/`state`, no duplicate cost. Corrected recording
      with a distinct reference and the original provider reference in `operator_ref` succeeds.
      Customer requests see `404` on either listener; neither record nor read is served on the
      public listener or carries customer CORS headers. Record while the pool is halted and
      without a currency rate: it succeeds, with no tenant balance or commitment change.
      A fresh-key duplicate void fails `409` `conflict`/`state`; voiding a void or a target in
      another account/currency fails `invalid_request`. Originals remain byte-identical and
      storage refuses update/delete. Exercise `WIR-53`'s invoice/void fixtures, a positive payment,
      a documentless zero invoice with an operator-made reference, and a negative credit note;
      reject invalid field/null combinations and non-positive payments. (`API-66`, `API-67`,
      `WIR-53`, `WIR-54`, `WIR-34`, `STO-57`, `STO-35`, `LDG-75`)
- [ ] **CNF-310** — **Month coverage and derived accrual** (*added 2026-10-04, `pv-gip.39`,
      `ADR-0031`*). With January cost 100 and February cost 180, record February's invoice 200
      first: B is 300, January stays in `accrued_months`, and the true-up is +20. Then record
      January's invoice 90: B is 290, January leaves accrual, and its true-up is −10. Reverse
      arrival order and require the same final B and coverage. A documentless month's cost 50
      stays accrued until a zero invoice covers it, with true-up −50; voiding that invoice
      restores 50 and distinguishes withdrawn coverage from authoritative zero cost.

      Post September usage in October: September's invoice covers it, while an October-only
      invoice leaves it accrued. A later signed correction carries September's cost period and
      account/currency, and follows the same coverage. An entry with no period follows its
      `created_at` month. Non-outage deficiencies follow their `opened_at` month.
      Concurrent invoices of 120 and 130 for one uncovered month with cost 100 produce true-ups
      summing to 150 (20+130 or 120+30), B=250 and one covered month. Replay either after further
      records: its stored true-up is unchanged. No arrival order removes accrual twice.

      Void an invoice: its amount disappears and, absent another non-negative invoice, accrual
      returns. With cost 100, a lone credit note −20 leaves B=80 and no coverage; adding invoice
      90 covers the month and makes B=70. Void that invoice and B returns to 80. Void a payment
      of 60 and B increases by 60, only once. Exercise permanent references and invalid voids
      under `CNF-309`.

      Close an outage spanning month end with 50 native units in each month: `native_minor` is
      written as 100, with non-zero positive cost, and January's invoice 60 leaves only February's
      50 accrued (B=110). Repeat by inserting an already-closed row and on a repeated posting;
      no duplicate cost or changed closure. Choose fractional native costs to verify each month's
      upward rounding. In a separate run, let cancellation stall across month end after the
      outage bound. Neither the bound nor the stalled attempt closes the row or finalizes its
      native cost. Hold a solvency halt and probe a rated check snapshot whose outage row is still
      open: the currency stays omitted and the halt remains. This can be a seeded check fixture
      if return and close commit atomically. Finalize on a qualifying return (or, in another run,
      an earlier valid meter stop), verify the full
      absorbed span split by month, and only then allow a complete passing check to lift the halt.
      Do not bound the absorbed span by the cancellation deadline.
      **Invoice before closure** (*added 2026-10-04, `pv-gip.39`, S4*): record the invoiced
      month while this account/currency's outage row is still open and touches that month.
      The receipt returns `true_up_minor: null`, the invoice covers its month immediately,
      and B follows the recorded invoice. Close/finalize the row, then replay recording with
      the same key: the exact stored response still contains null. No deferred invoice or
      recomputed response appears.
      **Quarantine mid-outage** (*added 2026-10-04, `pv-gip.39`, S1*): with a halt in force,
      open an outage row, then quarantine its subject and preserve mark/rounding-credit evidence.
      Accept a qualifying rate return under `LDG-58` with no posting and no exit: the existing
      row closes under `LDG-64`, finalizing seconds/native cost with no debit, commitment
      decrement, meter repair, new cost writer or quarantine removal. With all other outage
      rows closed, the currency becomes valued again; a complete passing stressed check lifts
      the halt. Then choose held satoshis sufficient for float/other legs/stress but short only
      when this currency's positive payable is included: the complete check fails, proving
      the leg was not silently omitted.
      Repeat with an earlier valid stop: it remains the end, never overwritten by the return.

      Exercise each cause in `LDG-75`'s table: included clamp remainder, closed outage cost,
      unrecoverable setup fee and unrecoverable first unit (each on its observed, absent and
      abandoned-estimate branches, as separate records; `ADR-0033`, 2026-10-08); excluded
      exception-branch coverage, account-loss exposure and late-attach floor. Realize excluded
      exposure through subsequent entries/incurred deficiencies and then invoice; it never counts
      both as reserved exposure and actual cost. A computed 100-sat debit with 30 sats remaining
      and 70 native cost produces native entry 21 plus deficiency 49, total 70; a full clamp
      carries all native cost in the deficiency, with no zero ledger row. Fee and attachment
      attribution reach the correct account. For each absent-but-charged and abandoned-estimate
      setup-fee and first-unit branch, create no machine row, check the producer copied
      `operations.provider_account` into each deficiency, then delete the settled operation under
      `STO-14` retention. Read/check accrual: the fee and the unit each still belong to that
      account/currency via their own rows; an unrelated account receives none. No invented machine or surviving-operation join is permitted.
      (*Amended 2026-10-04, `pv-gip.39`, J2.*) Record an invoice replacing outage cost and payment
      covering it: no phantom payable, resolution flag or customer backcharge. Also pay accrued
      outage cost before invoicing, then invoice it: the replacement leaves no phantom payable.

      Demonstrate the accepted gaps in `LDG-75`: invoice authority supplies locally absent free
      operation, quarantine and untracked-resource costs; provider local-month boundaries can
      misplace cost up to the UTC offset; a later-dated deficiency can be missed while an earlier
      invoice is unrecorded behind a later one; recording only one of a month's two invoices
      already covers that month; and the provider's rounding past the prepaid first unit is
      supplied by the invoice (`CNF-321`). These are limitations, not alarms or new cost writers.
      (`LDG-75`, `LDG-31`, `LDG-2`, `LDG-39`, `LDG-63`, `LDG-64`, `LDG-66`, `LDG-74`,
      `OPS-36`, `SEC-46`, `STO-37`, `STO-57`, `WIR-53`, `WIR-54`)
- [ ] **CNF-311** — **Separate payable floors, omission and pay/record/draw** (*added
      2026-10-04, `pv-gip.39`, `ADR-0031`*). Give one account credit −100 and another debt +60 at
      one satoshi per minor unit: the payable leg is 60, never zero. Repeat across currencies.
      Use held 200, float 100, payable 60 and additional stress 20: headroom is 20. Drawing 60
      first leaves 140 against required 180 and fails the check. In an independent run, pay 60
      from business money, record it, then draw 60: required is now 120 and remaining held 140
      passes. A paid-but-unrecorded amount remains payable; no fiat or provider credit is an
      asset. Partial payment reduces only its own account/currency balance. The read's `coverage`
      matches the same check and its headroom limits, independent of row pagination; reading
      another account reports the same deployment pool, not additional draw capacity. An unrated
      currency is omitted, never valued at its last rate; `complete` is false and the omitted
      currency is named. Repeat with a rated currency carrying an open outage row, even if other
      accounts in that currency have finalized costs: the currency remains omitted. Incomplete
      headroom is not whole-pool assurance. See `CNF-306` for the existing-halt case.
      (*Pointer amended 2026-10-04, `pv-gip.39`, T4.*)
      **No prior halt, incomplete cost with a rate** (*restored 2026-10-04, `pv-gip.39`, V1*):
      in an independent run give both EUR and USD a fresh rate, but leave a USD outage-cost
      row open. Seed this check snapshot if qualifying return and closure are atomic, as in
      `CNF-310`. Keep the USD leg omitted, with `complete: false` and USD named as omitted.
      Set held satoshis to 200, float to 100, finalized EUR payable to 60 sats at its current
      rate, and additional valued EUR stress to 20 sats, with no other valued legs. Run the
      check: required valued terms are 180, so no halt starts. A fresh deposit mint succeeds;
      an existing unexpired deposit with an unsettled Lightning invoice still reports
      `gate: null` and `lightning.cancelled: false`.
      Keep the same USD incomplete-cost condition and held/float/stress, but raise the
      independently finalized EUR payable to 100 sats. Run the check again: required valued
      terms are 220, while float plus stress alone is only 120. Assert a deployment-wide halt:
      fresh deposit minting is refused, the existing invoice is cancelled and its deposit read
      reports `gate: "solvency"` and `lightning.cancelled: true`; bill-increasing operations
      are refused while cancellation and deletion remain admitted. An on-chain payment to an
      already-issued address and any Lightning payment settling concurrently with cancellation
      are still credited. The open USD row is unchanged in both arms; no missing rate or prior
      halt supplies either outcome. `LDG-40` says "An incomplete cost alone, like a missing rate
      alone, MUST NOT start a solvency halt" and "A shortfall on the valued terms is a computed
      failure and MUST trigger `LDG-20`'s deployment-wide consequences". (`LDG-75`, `LDG-17`, `LDG-20`, `LDG-40`, `LDG-53`, `WIR-53`,
      `WIR-54`, `STO-57`)
- [ ] **CNF-139** — No code path uses a rate past its newest observation's stamped bound
      (*amended 2026-10-04, `pv-gip.28`*), and there is no
      last-known-good fallback anywhere. Asserted by removing every source for longer than the
      staleness bound and confirming the system reports *no rate* rather than a number. (*Amended
      2026-09-23, `ADR-0027`, as `CNF-138`.*) (`LDG-59`)
- [ ] **CNF-140** — One source returning an extreme price does not move the rate, and that source is
      excluded rather than averaged in. (`LDG-60`)
- [ ] **CNF-141** — Exclusions count against the quorum: with three sources, one stale and one
      outlying, the pass accepts no observation — not one derived from the single survivor. **This
      is the item that catches an implementation which degrades quietly to one source.** (*Amended
      2026-09-23, `ADR-0027`: a pass below quorum is not **no rate** (`LDG-59`).*) (`LDG-59`,
      `LDG-60`)
- [ ] **CNF-142** — The source set cannot be changed by any API call, tenant input, or database
      write. Attempting each fails. (`LDG-61`, and `CNF-135` for the same property applied to the
      sweep destination)
- [ ] **CNF-143** — Two sources that are front-ends onto the same venue are configured, and the
      deployment's quorum treats them as one. **Independence is a claim about the world that no
      code can check**, so this is a review item against the configured list, not a runtime test.
      (`LDG-58`)

## The launch set

Added 2026-08-12 with `ADR-0010`. These test that three drivers made the contract *more* general
rather than acquiring a default.

- [ ] **CNF-144** — No module under `core` names a provider, branches on one, or contains a constant
      that is any provider's commercial term. Asserted against the source, not by inspection of
      behaviour. (`OVR-14`, `OVR-15`, `PRV-13c`)
- [ ] **CNF-145** — Removing the DigitalOcean driver from the build leaves the other two compiling
      and passing, and removing **both** Hetzner drivers leaves DigitalOcean compiling and
      passing. The second half is the real test — it is where an assumption shared by two drivers
      of one house style shows up as a dependency. (`OVR-15`)
- [ ] **CNF-146** — `GET /v1/providers` reports three distinguishable capability sets, and a caller
      that acts only on what it reports never invokes an operation a provider does not have.
      (`OVR-16`, `OVR-2`)
- [ ] **CNF-147** — **Amended 2026-10-11 (`ADR-0037`, Q22/Q23c): a permitted-from date is
      not evidence that cancellation completed.** Exercise the dedicated path end to end
      against a real Hetzner Robot machine: commit the setup fee and prepaid first billing
      unit before ordering — Robot's hour, with no floor (`ADR-0033`) — debit them at
      accepted successful settlement (`ADR-0035`), and assert the machine's first meter
      seed writes its mark at the seed plus 3600 seconds. At create, size the commitment from `PRV-31`'s declared offer bound. After ordering, read the machine's actual `earliest_cancellation_date` and price the cost-through-earliest-date term in `LDG-33`'s protected satoshis without resizing the commitment (`LDG-39`, `LDG-38`, `PRV-13c`). Where that date is
      today, assert the outcome from the actual accepted cancellation result and its single
      read-back: mapped gone records the observation and stops the meter; presence or read
      failure settles scheduled with the returned effective date. Separately inject a
      machine whose permitted-from date is materially in the future and exercise both a
      rejection followed by scheduling and provider auto-scheduling; assert the returned
      date and subsequent evidence govern the same branches. Do not encode a Robot-wide
      immediacy constant. The old unconditional scheduled-only fixture remains withdrawn;
      it did not fit the ordinary current Robot product. (`PRV-12`, `PRV-13`, `PRV-13b`,
      `PRV-13c`, `DOM-19`, `STO-8a`, `PRV-31`)
- [ ] **CNF-148** — **The Robot order `comment` field is never populated, by any code path** —
      Hetzner routes commented orders to manual processing (`PRV-30`, confirmed). Asserted against
      the outbound request, not by reading the driver.
- [ ] **CNF-180** — **AMENDED 2026-09-04 — the `test=true` route does not reach this, and the
      fall-back clause is now the whole item (`F37`).** `PRV-32`'s correlator round-trip is
      confirmed against the live Robot API before the driver ships: an order carrying a unique SSH
      key is placed, the transaction is fetched from the listing, and the returned
      `authorized_key[].fingerprint` matches the key sent. **A simulated order cannot satisfy this**
      — `PRV-34` as amended records that a `test=true` transaction is absent from the listing and
      from its own id — so it takes a **real** order, which the auction channel makes cost about
      €0.08 because its `price_setup` is `0.0000` (`08-provider-notes.md`). Failing that, the driver
      declares no correlator (`PRV-33`). **Satisfied on the auction channel 2026-09-04; the standard
      channel remains open**, and it is the one that carries the setup fee. (`PRV-32`, `PRV-34`)
- **CNF-280** — **WITHDRAWN 2026-09-05** — it tested that two attempts of one create are told
      apart by their correlators, and `ADR-0014` means a create has one attempt. *The provider
      property it asserted was observed to hold on Hetzner Robot's auction channel on 2026-09-04 and
      is recorded in `PRV-32`; what is gone is any operation that needs it.* The surviving
      cardinality obligation is `OPS-38`'s, whose live source of duplicates is now a caller
      re-issuing under a fresh key (`API-51`), tested by `CNF-165`. *Checkbox removed 2026-09-08:
      a withdrawn item is a marker, not a box anyone can tick.* (`PRV-32`, `OPS-38`, `ADR-0014`)
- [ ] **CNF-289** — **`request_summary` carries nothing outside its enumeration.**
      Submit a create and an install whose bodies carry a caller-chosen hostname, SSH keys, user
      data, a post-install script, a signed image URL and a disk layout; drive each to a state that
      purges the payload; then assert `request_summary` contains **none** of them. Asserted by
      reading the stored record, not the API response — `API-21` already hides `request`, so a
      summary that quietly retained the payload would pass every surface test. This is `ADR-0005`
      enforced where it is actually enforceable: the purge is only as good as the list of what
      survives it. (`STO-50`, `STO-9`, `ADR-0005`, `OPS-13`)
- [ ] **CNF-290** — **AMENDED 2026-09-08 (`ADR-0019`) — the restart drill, and the
      startup lock in place of a fence that was not one.** Kill the engine between a dispatch and
      its reply; restart it; assert the interrupted operation is `needs_reconciliation` (`OPS-15`)
      and that the old process's late settled-state write affects **no row** and exits it
      (`STO-3`, `OPS-22`). Then start a second engine against the same store while the first holds
      the lock, and assert it does no work and exits non-zero after the stated bound (`OPS-47`,
      `OVR-19`); release the first and assert the second then starts. Then, with one non-yielded
      `running` operation on a machine, attempt a second claim against the same machine directly
      at the store and assert `STO-51`'s index refuses it **and that the refused operation's
      `claim_number` did not advance** (`OPS-6`, added 2026-09-12). *The withdrawn middle half asserted a
      stale `engine_epoch` write to a machine row affected no row, against a table that had no
      such column and a guard that held by construction (`ADR-0019`). What this drill must not be
      read to prove is that a second engine cannot write: `OPS-47` says "where two engines run,
      nothing here refuses the second, and both will work the queue".* (`OPS-47`,
      `STO-51`, `OPS-15`, `STO-3`, `ADR-0019`)
- [ ] **CNF-358** — **A create interrupted around step 8 has a distinct restart outcome.**
      With an auction-channel descriptor and again with a standard-channel (`correlator: none`)
      descriptor, kill during step 4's List offers read, after step 7, and while step 8's
      transaction is in flight before commit. Read the stored record and assert
      `about_to_order_at` is null at each kill. Restart: assert `failed`, a restart-naming
      `internal` error, `retryable: true` on both error and operation view, commitment closed and
      released in full, no setup-fee or first-unit debit, and the resource-offer exclusion freed
      where the create holds one. Assert no step-9 request reached the provider: no per-order key upload and no order;
      the List offers read is permitted. Repeat with an injected recorded error carrying
      `retryable: false`, written to the stored row before the restart, since `CNF-30` says "The
      startup pass does not overwrite an error already recorded": assert the error survives
      unchanged and the operation view carries `retryable: false`.
      Kill after step 8 commits but before step 9, and again after the order: assert the stored
      column is set and unchanged after restart, and the operation `needs_reconciliation`,
      with its commitment still open. No resolution or correlator matching runs for the failed cases.
      **Restore control:** take a backup after claim and before step 8, let the provider receive
      the order, restore that backup with an open restore record and start the engine. The stored column
      is null, but the operation stays `needs_reconciliation`; repeat after a crash before the
      startup pass, and after the freeze lifts while the record remains open. These cases reject
      a missing step-8 write, a write delayed into step 9, and an exception applied on a restore.
      (`OPS-15`, `OPS-16`, `OPS-43`, `LDG-32`, `LDG-39`, `STO-58`)
      *Added 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the kill-timing and restore controls; `ADR-0042`.*
- [ ] **CNF-359** — **The about-to-order column survives payload purge.** Drive a create past
      step 8 into a settled state and a separate create into `needs_reconciliation`. Record the
      column before each transition. Assert by reading each stored record that `request` is
      purged and `about_to_order_at` is unchanged. This rejects clearing the column with the
      request payload. (`STO-9`, `OPS-43`, `OPS-15`)
      *Added 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the stored-record purge check; `ADR-0042`.*
- [ ] **CNF-360** — **Step 8 waits for acknowledgement, repeats, and respects both guards.**
      Commit step 8 and drop its reply: assert no step-9 request before an acknowledged
      whole-transaction repeat, which affects one operation row, leaves `about_to_order_at` and
      `updated_at` unchanged and advances `revision` no further.
      Refuse its status guard, then its claim-number guard: assert no column commit, no step 9,
      and worker exit. Refuse the separate `STO-47` check: assert deterministic `conflict`, full
      release, and no column commit. For the restart settlement, kill between the status write
      and the commitment release: assert neither survives the rollback, then restart and assert
      both commit together. Force the null-guarded write to affect no row: assert no money is
      released, and a still-running create is moved by the ordinary startup write to
      `needs_reconciliation`. These cases reject speculative dispatch, a null-only worker guard,
      and a release outside the guarded status transaction. (`OPS-43`, `OPS-49`, `STO-3`,
      `API-63`, `OPS-15`, `LDG-35`)
      *Added 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added lost-reply and atomicity checks; `ADR-0042`.*
- [ ] **CNF-361** — **A recorded create failure before step 9 releases the purchase.**
      `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
      On both an auction channel and a standard channel (`correlator: none`), inject each of
      `network`, `timeout`, `internal`, `provider` with a 5xx and `provider` without a status
      at step 4's List offers read. Also cancel `execute` at each of steps 1-8 on each channel.
      At step 8 do so three more ways: while its first transaction is in flight, letting it
      commit; and while `OPS-49` repeats it, once after a first attempt the store refused and
      once after one that committed with its reply lost. `OPS-21` says "A stop that arrives while a store transaction inside `execute` is in flight or repeating under `OPS-49`, such as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation being recorded."
      In the two repeat cases the store works again before the Stop-record bound ends; in all
      three, assert that no step-8 transaction starts after the stop. No formal model reaches them, since its stop
      schedule starts at the record write; this item is their only check. `OPS-21` says "a cancellation of
      `execute` recorded before step 9 is the exception"; exercise each cancellation with the
      engine surviving the stop and a store that works for the record, and assert its record lands before exit. For every
      case assert `failed`, the reported error kind,
      `retryable: true` on both the error and the operation view, full commitment release with
      no setup-fee or first-unit debit, the resource-offer exclusion freed where the create holds one,
      no step-9 request (no per-order key upload and no order), and no `OPS-27` search. The List offers read is
      permitted (`PRV-50`: "The driver's List offers MUST be read-only"). For each cancellation
      the error kind is `conflict` with `retryable: true` on error and view; every other assertion
      in this item still applies. Assert `details.reason: "cut_off"` for every cancellation case.
      Stop after step 8 is acknowledged and before step 9: assert one guarded settle write
      before exit, `failed` with the column set, full commitment release, no fee or unit debit,
      and no `OPS-27` search.
      **Controls:** the same timeout on the order request still enters `needs_reconciliation`;
      an ambiguous key-upload failure still enters `needs_reconciliation`. For each of a null-column
      snapshot taken before step 9 and a stale or cached null `about_to_order_at` read made after
      step 9 begins, record a timeout after step 9 begins and assert `needs_reconciliation`:
      neither null authorises `failed`. After step 8 is acknowledged but before step 9, record
      a failure and assert `failed` with the column set; a restart in that same window instead
      enters `needs_reconciliation`. Finally commit step 8 and lose its reply, then commit an
      account-status write recording `terminated` before the whole-transaction repeat. Assert
      that the repeat's `STO-47` check affects no row and the create settles `failed` with the
      column set, full release, no fee or unit debit, the resource-offer exclusion freed where the
      create holds one, no step-9 request and no correlator search. Exercise the ordinary worker guard without a null-column term and
      atomic status/release order. (`OPS-11`, `OPS-21`, `OPS-43`, `PRV-50`, `LDG-32`, `LDG-39`,
      `STO-58`, `STO-3`, `LDG-35`, `OPS-49`, `API-63`, `STO-47`, `OPS-22`, `WIR-9a`)
      *Added 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): added the recorded-failure cases and boundary controls. The cancellation cases cover only a recorded cancellation; whether one must be recorded is `pv-tst`'s.*
      *Amended 2026-10-18 (`pv-tst`, `pv-f7a`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): required survived-stop recording, its reason and the acknowledged-step-8 case.*
      *Amended 2026-10-18 (`pv-tst`; panel r58c, `docs/research/panels-2026-10/r58/r58c/`; `ADR-0044`): replaced the step-8 retry-loop exclusion with in-flight and in-loop cases.*

- [ ] **CNF-362** — **A stop the engine survives from a worker's `execute` until its settle write lands gets a bounded record.**
      `OPS-21` says "The worker MUST NOT pursue the record past the Stop-record bound (`OVR-19`), and the engine MUST NOT wait for it past that bound."
      For each operation kind, stop the engine while its worker is in `execute`, with a working
      store. Assert the cut-off `conflict`'s classification against the kind's row (`OPS-11`),
      with `details.reason: "cut_off"` on every record write of a cancellation of `execute` but the parent's defer: a create before step 9, and an
      install or rescue inventory before the write-started marker with no rescue session open,
      settle `failed`; refresh settles `failed`; an install past the marker enters
      `needs_reconciliation`; power, reverse DNS, delete and release attachment stopped during
      their provider call after dispatch enter `needs_reconciliation`.
      Assert the create before step 9 carries `retryable: true` on error and view, and each
      `needs_reconciliation` case carries `retryable: false` (`API-51`: "An operation in
      `needs_reconciliation` MUST be delivered with `retryable: false`").
      Make no assertion about `retryable` for the other cases. For each stopped operation no
      `running` row remains while the process lives, and the engine exits only after the record lands.
      `OPS-21` says "A cancelled `suspend_tenant` parent MUST be returned to `queued` with `available_at` advanced at any point in its fan-out, subject to the same Stop-record bound and exits."
      Stop that parent at successive fan-out positions and assert the guarded defer leaves it
      `queued` with `available_at` advanced; its next claim resumes and enqueues no child twice.
      **Shielding:** `OPS-21` says "The record write MUST NOT be cancelled by the cancellation that stopped `execute`."
      Deliver the original stop's cancellation to the record write's first transaction and
      assert it still lands.
      **Bound:** `OPS-21` says "The Stop-record bound is measured from the stop, counts every repeat including serialization failures, and never resets."
      With every transaction refused, and separately with every transaction a serialization
      failure, assert exit within that bound measured from the stop. Assert the row stays `running` and is
      named in the loud log; assert that `OPS-15` classifies the row at restart, including
      its exceptions. Alternate serialization failures and store errors and assert exit within
      the same bound from the stop, with no reset. With each of the Stop-record and Store-retry
      bounds in turn the shorter, assert the record ends and the engine exits when the first
      bound ends. A later stop during the record's whole-transaction loop exits at once.
      `OPS-21` says "A stop that arrives after a stop has cancelled `execute`, before that cancellation's record lands, is a later stop under that record's rules, not a stop after `execute` returns."
      Also commit the last repeat before the Stop-record bound expires but lose its reply: assert
      the row is already written and money posted once, and restart finds no `running` row to classify.
      **Inside `execute`:** stop a `provider_native` install while `OPS-49` repeats its
      write-started marker write, with the store working again before the Stop-record bound ends.
      `OPS-21` says "Where the row reads `OPS-45`'s markers, the record MUST classify against the markers its own transaction reads, since a marker write whose reply was lost may have committed."
      After a first attempt that committed with its reply lost, assert `needs_reconciliation`;
      after one the store refused, assert `failed`. In both, assert no rebuild call is dispatched.
      This item is the only check of this case; no formal model reaches it.
      **Validation:** startup refuses a missing, zero, negative or non-finite Stop-record bound;
      verify the supervisor allows at least that duration after the stop.
      **Control:** a kill at the same instant writes nothing; a create with `about_to_order_at`
      set enters `needs_reconciliation` on restart. Make no assertions about power, reverse DNS,
      delete or release attachment stopped before dispatch (`pv-9j6`).
      **After `execute` returns:** in each case the engine survives the stop and the store
      works before the Stop-record bound ends, unless the case says otherwise.
      `OPS-21` says "A stop the engine survives that arrives after `execute` returns and before the worker's settle write lands MUST be recorded by that settle write, under the shielding below, and the Stop-record bound and exits that apply to a recorded cancellation."
      `OPS-21` says "The settle write that records a stop after `execute` returns MUST NOT be cancelled or abandoned by that stop."
      `OPS-21` says "The record of a stop after `execute` returns is the guarded write the worker would have made without the stop, settling the outcome in hand with that outcome's own error, if it has one, and with a failure classified under `OPS-11`; it is not a cut-off `conflict`."
      `OPS-21` says "The Stop-record bound and its expiry exit, the later-stop exit, the Store-retry bound's exhaustion exit, the lost-reply case and the supervisor's wait apply to the record of a stop after `execute` returns as they do to a recorded cancellation; the cut-off classification and its reason do not, nor does the rule against repeating a transaction already sent."
      Stop a create whose order was accepted and whose settle-time search and confirming read
      found exactly one machine, so that `execute` returned success: once before its settle
      write's first transaction, and separately during that transaction. Assert `succeeded`,
      the landed-order transaction's effects committed once, with the setup fee and first
      unit debited once, no `cut_off`, no `running` row while the process lives, and engine exit
      only after the settle write lands.
      Stop the same create while `OPS-49` repeats its settle write: once after a first
      transaction the store refused, and once after a first transaction that committed with
      its reply lost. Assert `succeeded`, money posted once and no `cut_off`.
      Stop after `execute` returns a create failure before step 9: use a `timeout` at step 4's
      List offers read. Assert `failed` with the reported kind `timeout` and `retryable: true`
      on error and view, full commitment release, no setup-fee or first-unit debit, and no
      `cut_off`. Separately stop after `execute` returns a post-dispatch provider `timeout`
      from a power action. Assert `needs_reconciliation` with kind `timeout`, `retryable: false`
      and no `cut_off`.
      Deliver a later stop between repeats of the settle write that records a first stop after
      `execute` returns, with the store refusing every transaction until after that later stop:
      assert exit at once with the row still `running`, and restart classification under `OPS-15`.
      With every transaction refused and the Stop-record bound shorter than the Store-retry
      bound, assert exit when the Stop-record bound expires, measured from the stop, with the
      loud log naming the operation; assert `OPS-15` classifies the row at restart.
      **After-return control:** a kill after `execute` returns and before the settle write
      lands writes nothing; assert `OPS-15` classifies the row at restart.
      **Placement control:** stop a create after step 9 during its settle-time correlator
      search, separately during its confirming read, and separately during its post-order
      read. Assert a cut-off `conflict` with `details.reason: "cut_off"`,
      `needs_reconciliation` and `retryable: false` (`API-51`).
      This item is the only check of these after-return cases; no gate or formal model
      decides whether a first stop after `execute` returns is recorded by the settle write or exits.
      (`OPS-21`, `OPS-11`, `OPS-49`, `OVR-19`, `WIR-9a`, `WIR-9b`, `OPS-15`, `OPS-22`,
      `STO-3`, `OPS-8`, `OPS-39`, `OPS-6`, `OPS-43`, `OPS-45`, `API-51`, `API-58`, `OPS-27`,
      `PRV-13c`, `LDG-32`, `LDG-39`)
      *Added 2026-10-18 (`pv-tst`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): added stop recording, shielding, duration, parent, validation and crash controls.*
      *Amended 2026-10-18 (`pv-tst`; panel r58c, `docs/research/panels-2026-10/r58/r58c/`; `ADR-0044`): kept the cut-off reason off the parent's defer; added the install stopped inside its marker write's loop.*
      *Amended 2026-10-19 (`pv-zbp`; `ADR-0044`): added settle-write recording cases, defending quotations and the create verification placement control; pinned the store in the later-stop case; scoped the heading to a worker's `execute` and settle write.*

- [ ] **CNF-294** — **The lost-reply drill** (added 2026-09-12, `ADR-0022`). For a
      settled-state write and an `OPS-45` marker write: let the transaction commit and drop the
      reply before the client sees it, let the worker repeat the whole transaction under `OPS-49`,
      and assert the repeat affects one row, changes no column, advances `revision` no further,
      and the worker continues — never exits. For an `OPS-8` defer repeated the same way, assert
      the repeat affects **no row** and the worker moves on, since the row is already `queued`
      (`STO-3`). Then make the store refuse the write with a server-side `statement_timeout` and
      assert the repeat finds the row still `running` and lands normally. Then hold the store
      unavailable past the stated store-retry bound (`OVR-19`) and assert the engine exits
      non-zero, logging loudly, never re-issuing the provider call (`OPS-12`); on restart `OPS-15`
      classifies the row. Then hold `LDG-35`'s primitive on a tenant past `lock_timeout` and
      assert the meter's write — a periodic component in the engine process — repeats as a whole
      transaction against the same bound rather than looping outside it.
      Then drop the reply to a *claim* and assert the engine exits rather than claiming again.
      Asserted with `STO-7`'s client deadline set no shorter than the server timeouts, and with an
      abandoned connection reset before reuse. (`OPS-49`, `OPS-22`, `STO-3`, `STO-7`, `OPS-6`)
- [ ] **CNF-291** — **The episode outlives its attempts, and there is one of it.**
      Open a `delete` episode on a machine and attempt to insert a second open `(machine_id,
      delete)` episode directly at the store: `STO-52`'s index refuses it. Then let the first
      attempt settle `failed`, run retention past `STO-14`'s horizon so the attempt row is gone,
      and assert the episode is still `stalled`, `destroy_committed` still holds its id, `LDG-62`'s
      extend-runway is still refused `conflict`, and `retry` (`API-64`) enqueues a second attempt
      whose `episode_id` is the same id. **The failure this catches is the one `ADR-0017` was
      written for**: a fence pointing at a deleted row, a machine that bills forever behind a
      permanent `conflict`, and a test that passed inside the retention window. (`STO-52`,
      `DOM-31`, `OPS-48`, `API-64`, `LDG-62`, `STO-14`)
- [ ] **CNF-292** — **An observed sample widens the window without a redeploy.** With a
      driver whose descriptor declares a visibility window of *n* seconds, dispatch a create whose
      resource first appears in the listing at *n + k* seconds and assert a `provider_observations`
      row is written with that `dispatched_at` and `observed_at` (`STO-53`); then dispatch another
      create, lose its reply, and assert resolution takes no read until *n + k* has elapsed
      **after the second create call's deadline expiry** — the effective window is
      `max(declared, max(observed))`, and the process was not restarted between
      the two. Assert the descriptor value itself is unchanged. A build that reads the window from
      driver source resolves the second create `absent`, releases the commitment, and the machine arrives with
      nobody paying. *Amended 2026-10-08 (`ADR-0037`): billing-stop-window assertion withdrawn.*
      (`PRV-36`, `PRV-44`, `STO-53`, `ADR-0018`)
- [ ] **CNF-293** — **An operator can release an attachment through a route; the completed
      release writes the evidence that opens the tombstone gate.** Delete a machine on a driver whose descriptor
      declares a surviving attachment kind and whose *list attachments* returns one `billable: true`,
      and assert one `machine_attachments` row per returned attachment (`PRV-45`). For an `api` row: assert the delete's terminal transaction
      enqueued a `release_attachment` carrying the delete's own `requested_by` and `system_reason`;
      settle it `failed`, then call `POST .../attachments/{id}/actions/release` as an operator and
      assert a `202` with a fresh `release_attachment` operation, `requested_by: operator`, whose
      completed-release success with no effective date writes `released_at`, after which
      `STO-18` no longer forbids the tombstone and
      `LDG-74`'s "the row is tombstoned when `STO-18` allows" is what performs it. For a `manual`
      row: assert the same route answers `200` synchronously with `released_at` set and no operation
      minted (`API-48`). Assert a second release of either row is `409` `state`, and that
      `GET .../attachments` shows every row with its `cleanup` and `released_at`. A build without
      the route leaves every machine with a `manual` attachment un-tombstoned forever. (`API-65`,
      `WIR-52`, `PRV-45`, `STO-18`, `LDG-74`) *Completed-release premise qualified 2026-10-08
      (`ADR-0037`).*
- [ ] **CNF-288** — **AMENDED 2026-09-08 (`ADR-0017`) — the verb it tested is deleted,
      so the item asserts its absence.** **No settled operation of any kind re-enters `queued`.**
      For every operation kind, drive an operation to each failure outcome `OPS-11`'s table can
      produce for it — `failed` and `needs_reconciliation` for the dispatching kinds, `failed`
      alone for `refresh`, which is "Always `failed`", and neither for `suspend_tenant`, which is
      "Never `needs_reconciliation`, and never `failed` as a whole" and settles `succeeded` once its
      children have — (*scoped 2026-09-12, `F50`; until then the item asked for two states two
      kinds cannot reach, and `OPS-11` classifies failures, so a kind's success is not in its
      table*) — and
      assert there is no route — no endpoint on either listener, no operator verb, no sweep — that
      moves it back to `queued` (`OPS-4`). **A restore is the route this item did not enumerate**
      (added 2026-09-12, `ADR-0023`): it returns a settled row to `queued` by rewriting the store.
      For create, install and rescue inventory `STO-54` stands in its way — `CNF-295` asserts it;
      for the goal-state kinds the row *does* re-enter `queued` and re-runs, and `OPS-11`'s
      "already in the target state" rule is what makes that a success rather than a second
      mutation, so this item's universal holds for the kinds whose repeat is a purchase or a disk
      write and not for every kind. **Then assert the recovery that replaced it is scoped to the episode**: `retry` (`API-64`) on a
      `stalled` episode enqueues a **fresh** `delete_machine` attempt under the same episode id and
      leaves the failed attempt's row untouched; `retry` on an episode in any other state is `409`
      `state`; and no episode ever carries a `create_machine`, `install`, `power`
      or `reverse_dns` attempt, so none of those kinds has a second attempt by any path. A build
      that re-runs a settled create buys a machine the customer holds no credential on with the
      customer's satoshis (`ADR-0014`); one that re-runs an install lets an operator choose the
      bytes written to a customer's disk and the host-key decision `SEC-22` reserves for the caller.
      (`OPS-4`,
      `OPS-48`, `API-64`, `ADR-0014`, `ADR-0017`)
- [ ] **CNF-281** — **Resolution searches every ordering channel.** Order on one channel, resolve with
      a driver configured to query only the other, and assert the outcome is **not** resolved-absent.
      A driver that declares more than one channel and searches one fails. Without it a customer's
      balance is released in full while a physical server bought on the unsearched channel runs
      unrecorded — money out, and the operator learns of it from an invoice. (`PRV-38`, `OPS-27`,
      `OPS-32`)
- [ ] **CNF-282** — **An authoritative-empty search is an empty result, not an error.** Present the
      driver with the provider's empty-listing response — for Robot a `404` carrying
      `no transactions found` — and assert it reaches `OPS-27`'s resolved-absent and releases the
      commitment, and is never surfaced as `DOM-17`'s `not_found`. Both failures end with a
      customer's satoshis committed behind an order that never landed — which `OPS-31`'s `absent`
      verb undoes, so the operator can recover it and would see it in the listing. (`PRV-39`,
      `OPS-27`, `LDG-32`)
- [ ] **CNF-283** — **Robot's reported throttle closes the local channel.** Return
      `403 RATE_LIMIT_EXCEEDED` with `interval` on one account's auction order request.
      During the reported interval, each subsequent create there is refused by the
      `API-7` tail before any provider call, with `rate_limited`, `retry_after_ms`, no
      commitment, balance change, machine, operation or receipt. Assert the initial upstream
      Robot throttle raises `PRV-5`'s "every Robot
      `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider
      account and request path" alarm. The alarm may include the ordering channel.
      Subsequent local refusals make no provider
      request and need no new provider-throttle alarm. Re-evaluate after the interval;
      do not treat the descriptor limit as a local counter. A closed auction channel alone does not
      refuse a standard-channel create or another account's create. For a mutation
      accepted before a provider throttle, assert the `OPS-11` classification. Admit
      and queue create A before the closure, then close A's
      account/channel before its worker claims it. At claim, assert A's existing
      operation settles `failed`; its operation-view `error` obeys `WIR-9`'s
      "exactly `kind`/`message`/`retryable`/`details` and nothing else" object shape,
      with `kind: rate_limited`, `retryable: true`, `details.retry_after_ms` equal
      to the remaining closure, and no `details.refusals`. Its `message` obeys
      `API-25`. The operation view's own `retryable` is true;
      no per-order key upload, order request or other provider call occurs. Its commitment is
      released in full with no setup or first-unit debit. A retry after expiry
      opens a new operation; A is not automatically requeued or attempted again.
      Repeat after engine restart and across API replicas to prove the closure is
      shared and retained through its reported interval. Then commit a closure
      just after A's plain claim-time channel-closure read (`OPS-43`'s step 2, "Read the stored
      channel closure"): no conditional-write channel recheck
      blocks dispatch, and Robot's own `403 RATE_LIMIT_EXCEEDED` settles the
      unaccepted order the same way, raising the upstream throttle alarm above.
      (`PRV-40`, `PRV-5`, `STO-58`, `API-7`, `OPS-5`,
      `OPS-11`, `LDG-39`, `WIR-9a`)
      *Amended 2026-10-09 and 2026-10-10 (`ADR-0036`): provider-reported closure
      replaces local daily counting and reaches queued creates at worker claim. Amended
      2026-10-13 (`ADR-0037`, Q28): the alarm follows `PRV-5`.*
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      identified the channel-closure read in the after-read barrier.*

- [ ] **CNF-284** — **An authentication failure is attempted once.** Give a driver a bad credential
      and assert it makes exactly one attempt and escalates, with no scheduled re-attempt. Asserted
      by counting requests, not by reading the code. On a provider that locks out on repeated
      failures the retry loop takes every tenant's operations offline with it — an outage the
      operator sees and the provider's support desk undoes. (`PRV-41`, `OPS-26`)
- [ ] **CNF-285** — **Auction resolution proves attribution before attachment** (amended 2026-10-09, `ADR-0040`). Lose the reply to an auction order and assert the per-order fingerprint is searched on every ordering channel. A read of the offer number returns absent while the matched order remains in progress: the operation and commitment stay unresolved, with `OPS-33`'s matched-order qualification intact. Deliver a `server_number` different from the offer number: resolution uses the matched transaction's delivered number, then confirms that machine by direct read before attachment. Return two fingerprint matches and assert no automatic attachment. Make the confirming read error or become unavailable and assert no success or settled absence; separately return authoritative `not_found` after the effective visibility window and assert resolved-absent when no matched order remains in progress. Expire the transaction listing before a match and assert operator escalation under `OPS-31`, with `OPS-33`'s release rule and the account sweep still active. A positive offer-number read alone does not establish attribution. Assert `offer_is_resource` still enforces `PRV-42`'s admission claim. (`PRV-42`, `PRV-44`, `PRV-38`, `OPS-27`, `OPS-33`, `PRV-36`)
- [ ] **CNF-286** — **A landed order is not attached without confirming the resource
      exists.** Resolve a create whose order record reports success and whose resource has since been
      destroyed, and assert the outcome is **not** resolved-observed: no `machines` row, no
      commitment, no meter. Without it the system bills a customer for a machine that is gone, which
      is the defect `OPS-32` was amended to close reached through the resolution path instead of
      through drift. (`PRV-43`, `OPS-27`, `PRV-36`)
- [ ] **CNF-287** — **The rescue path can reach a machine as ordered.** Assert the
      driver either orders an address the deployment can route to, with its cost carried into the
      offer price, or declares `rescue_address_family` IPv6-capable in its descriptor (`PRV-44`) —
      and that a create is refused rather than placed where neither holds. A machine bought and
      unreachable bills and drains runway with delete as the only remedy: an autonomous caller
      reaches a provider mutation whose product it cannot use, with no human in the loop. (`RSC-45`,
      `PRV-44`, `PRV-13b`)
- [ ] **CNF-184** — A rate outage bills the customer **nothing** for the window: no deferred
      satoshi debit is posted when the rate returns, the native accrual appears as an operator
      deficiency, and machines are cancelled at the stated maximum outage if no rate comes back.
      **The bound reaches a machine with no record** (added 2026-10-02, `ADR-0029`, with the next
      two cases): a machine priced in the outage's currency for which the meter opened no
      `rate_outage` record is cancelled at the bound like one that has a record. **The bound is the
      setting in force**: mid-outage, lower the maximum tolerated outage below the time the outage
      has already run and restart; assert that every machine's `rate_outage_deadline` is now in the
      past and that cancellations are enqueued and proceed from that restart, with no further
      wait; raise it instead and assert that nothing is cancelled before the new deadline — a
      `rate_outage_bound` attempt already enqueued under the old bound included, which defers like
      any other while the new deadline has not passed, since `OPS-41`'s order holds "whatever
      reason the attempt was enqueued under"; a build that special-cases the reason fails. **The
      cap is per outage**: let the rate return before the deadline and fail again, and assert the
      second outage's deadline is its own start plus the bound. (`LDG-64`, `LDG-65`, `OPS-41`,
      `OVR-19`)
- [ ] **CNF-185** — **AMENDED 2026-09-02 (twice in one day; read the note).** Metering the same period
      at one-minute and one-hour cadence produces the **identical** total charge — **at a constant
      rate and under a moving one alike**. Rounding is cumulative rather than per tick (`LDG-28`),
      and every increment is priced at a rate that held for the whole of it, because `LDG-38` splits
      an increment at each rate change; any finer subdivision of a rate-homogeneous span sums to the
      same product. A property test over **arbitrary subdivision and arbitrary rate movement**. A
      meter that does not split fails it: at 7 sats/hour doubling to 14 at the half hour, an unsplit
      hourly meter charges 14 where every splitting cadence charges 11.
      *Two withdrawn wordings, and the pair is the lesson. The first was an unconditional "identical
      total charge" sitting beside a formula that re-priced the whole period at the latest rate —
      under a moving rate it was satisfiable **only** by that defect, so the item appeared to endorse
      what it should have caught. The second, written hours later, retreated to a bound: the totals
      "may differ" by the sum over increments of `net_seconds_i × |rate movement across increment
      i|`. That was true, and it was worse, because a bound wide enough to admit the wrong answer
      certifies it — an unsplit meter passes. The fix belonged in `LDG-38`, not here: make the
      increments rate-homogeneous and the original unconditional claim becomes both true and
      demanding. When a conformance item has to be weakened to stay true, suspect the requirement.*
      (`LDG-38`, `LDG-28`, `LDG-4`, `PRV-13e`)
      **Exit between ticks:** within one billing period, start at second 0, use 1/5 sat/s through
      second 7 and 2/5 afterwards, and delete at 14. Compare no intervening tick with ticks at
      3, 6, 9 and 12: both total 5 sats for exact consumption 21/5, end with `r = 4/5`, and
      mark 14. Repeat over arbitrary subdivisions and stop instants, with sufficient authority.
      Include a closing increment spanning a period boundary: seed Jan 31 23:59:30Z, no tick,
      exit Feb 1 00:00:30Z, rate 1/5 sat/s before midnight and 2/5 after. Expect January's debit
      6 and February's debit 12, keys ending at midnight and the stop respectively, both credits
      zero. (`LDG-38`, `LDG-68`)
- [ ] **CNF-186** — Two credited payments each below the activation minimum, summing above it,
      activate the tenant atomically. (`LDG-52`, `API-35`)
- [ ] **CNF-187** — A machine deleted while a billable attachment survives keeps its commitment
      open until its `released_at` is recorded; a scheduled meter stop alone leaves it open.
      The priced attachment below is an isolated accounting fixture: v1 has no attachment
      customer-rate source and this fixture does not authorize a sale. (`LDG-32`, `PRV-13a`, `STO-18`)
      **Close each subject before releasing authority.** With 30 sats remaining, machine seed 0,
      no tick, 1/5 sat/s and gone delete at 7, assert debit 2, machine mark 7 and `r = 3/5`,
      then 28 still committed while the retained attachment is seeded at 7. Release it at 11
      at 1/5 sat/s with no attachment tick: its own debit is 1, mark 11, `r = 1/5`, and only
      then is the remaining 27 released. Repeat with an `api` attachment through `PRV-45`'s
      terminal release, and a `manual` attachment through `API-65`'s synchronous release.
      With two retained attachments, releasing one must leave the commitment open for the other.
      **Release while the machine runs:** use the same retained-row setup, then a fixture driver
      authoritatively reports that same, untombstoned machine running again at 9 (`DOM-8`),
      before releasing the attachment at 11. For the `api` case, first let the delete's automatic
      release attempt settle as a deterministic failure without releasing the attachment; the
      refresh can then run, followed by the operator's fresh release. This is a re-entry of the
      existing machine, not a new row or reused identifier. Assert its seed at 9 and unchanged
      machine credit; the
      attachment still posts its own 1 sat at release, leaving 27 committed for the running
      machine. Exercise both release writers. A fixture starting with a running machine and no
      retained attachment row cannot exercise either writer. Finally repeat the gone-delete
      case with only 1 sat remaining: its computed 2 clamps to a debit/decrement of 1 and a
      `clamp_overflow` of 1; attachment consumption with zero authority uses the ordinary clamp,
      never available balance. (`LDG-38`, `LDG-31`, `PRV-45`, `API-65`)
- [ ] **CNF-188** — An unreachable provider account or rejected credentials leave commitments
      **open**, with the carried exposure recorded as an **operator deficiency** (`LDG-66`); only
      confirmed termination closes them and returns their reserved satoshis to available. A queued
      create claimed meanwhile still fails and releases its own (`OPS-43`'s step 1, `API-63`). Run it
      against `07-security-requirements.md` itself, because that amendment was written on
      2026-08-13, failed to apply, and shipped as prose claiming it had. *Absorbed `CNF-114` and
      `CNF-195`, which each tested the same table.* (`SEC-46`, `LDG-66`, `LDG-32`)
- [ ] **CNF-189** — The enrolment response carries both secrets **once**, they are stored hashed
      only, both work from that moment, and neither is ever returned by the handle poll. Losing the
      response loses the credentials — and the tenant is unfunded, so nothing of value is stranded.
      *"Both work from that moment" replaced an `issuable_at` window on 2026-09-02 (`API-33`).*
      (`API-33`, `API-55`, `STO-34`, `WIR-12`)
- [ ] **CNF-190** — The recovery credential revokes the spending token and issues a fresh one; the
      **spending token cannot revoke or rotate itself**. Both halves — the second is what stops a
      thief locking the owner out. (`API-56`, `WIR-38`)
- [ ] **CNF-191** — A freshly activated tenant has at least one assigned provider account,
      recorded durably — **where a healthy account exists; where none does, it activates
      unassigned, and kill the process after an account is recorded `healthy` and before the
      assignment lands: on restart the reconciling pass assigns it with no event to prompt it**
      (2026-09-05) — and successive tenants are spread across accounts rather than filling one.
      (`API-57`, `STO-36`, `SEC-43`, `STO-47`)
- [ ] **CNF-192** — An install naming a device identifier absent from a freshly re-read inventory,
      or carrying a stale `inventory_fingerprint`, aborts `integrity` **with no bytes written**.
      Verified by mutating the inventory between the rescue-inventory pass and the install.
      (`RSC-26`, `RSC-38`)
- [ ] **CNF-193** — A pending tenant's signup time-to-live exceeds the deposit expiry plus the
      finality window; a deposit minted at the last moment expires early enough that its own
      finality window still closes before the signup is reaped; and no tenant is deleted while a
      deposit of its own is inside that window.
      (`API-34`, `API-42`, `LDG-54`)
- [ ] **CNF-194** — Suspending a tenant blocks every **tenant-authorized** write while leaving the
      maintenance actions reachable (`CNF-209`), enqueues one deduplicated cancellation
      per machine, leaves ledger and machine reads working, and reports per-machine outcomes
      including any `needs_reconciliation`. (`API-58`, `OPS-39`, `SEC-45`)
- **CNF-195** — **MERGED INTO `CNF-188`.** Both tested `SEC-46`'s retained-commitments table
      and both were counted BLOCKING, double-counting one control. `CNF-188` is the survivor and
      gains this item's second half: the carried exposure MUST appear as an operator deficiency
      (`LDG-66`), and the test MUST be run against `07-security-requirements.md` itself, because
      that amendment was written on 2026-08-13, failed to apply, and shipped as prose claiming it
      had. *The checkbox was removed 2026-09-02: the blocking count already described this item as
      "correctly absent — a split and merge marker, not an item", while it was still a live
      checkbox anyone could tick.*
- [ ] **CNF-196** — Enrolment ignores an `Idempotency-Key`: two signups presenting the same key
      receive **different** handles and different credentials. The withdrawn rule returned the
      same handle, and the handle's response carries both secrets. (`API-40`, `WIR-12`)
- [ ] **CNF-197** — A resolution transition out of `needs_reconciliation` succeeds with **no worker**
      — by sweep and by operator verb, guarded on `(id, status = needs_reconciliation, resolution
      IS NULL)` and no claim term —
      while a *worker* write against an operation moved by something else affects no row, **and a
      worker's repeat of its own settled-state write affects one row and changes nothing**
      (corrected 2026-09-12, `ADR-0022`: the item read "against an operation no longer `running`",
      which the repeat-admitting branch makes false for the worker's own outcome). Three halves:
      the guards are different predicates (`STO-3`), a build that applies the worker's to
      resolution can never resolve anything, and a build without the repeat branch exits on every
      lost reply. (`OPS-3`, `STO-19`, `STO-3`, `OPS-22`)
- [ ] **CNF-198** — Metering a period at a cadence that subdivides it posts every increment: no
      posting is deduplicated away by the idempotency key, and two billable attachments on one
      machine do not collide. (`LDG-8`, `LDG-38`)
- [ ] **CNF-308** — **Late attach with no rate** (*added 2026-10-04, `pv-gip.27`*).
      Release the create's commitment, then produce a correlator match during a currency outage,
      with available balance above any plausible wind-down floor. Assert attachment, no commitment,
      unchanged available balance, a native `late_attach_cleanup` deficiency with null rate and
      zero absorbed seconds, and the applicable `unrecoverable_setup_fee` and
      `unrecoverable_first_unit` records (`ADR-0033`, 2026-10-08) with the same
      null-rate/zero-seconds shape. Attach, deficiency records, fee settlement/parked-fee clearing
      and cleanup enqueue are atomic: inject failure between effects and observe all or none.
      Before the bound the cleanup short-defers with no fence or provider call; extension is
      refused by the rate gate. With declared duration 60, attach at 30 without any customer
      first-unit debit: assert `first_unit_debit_id` null and mark 30. The meter charges nothing;
      a no-rate tick at 60 opens an outage row from 30, absorbing eligible post-attach time and
      no pre-attach time. `STO-37` owns the start: "The subject row starts at
      `max(currency outage start, the subject's latest mark)`".

      Return the rate at 60. In one ordering, extend before the cleanup fence: a commitment
      opens, `runway_until` is re-derived (*amended 2026-10-04, `pv-gip.39`: no deficiency-resolution
      bookkeeping*) and the cleanup aborts without provider mutation; the machine survives.
      In the other ordering, make no extension: with zero usable sats and a valid rate,
      `max(60, 30) + 0 = 60`, which is not strictly in the future. Cleanup proceeds through
      the existing fence, absent an existing independent deferral; there is no automatic survival
      to 90. Repeat with a rate present at attach and re-check at 60: the same mark and result.
      Pair this with a machine whose first-unit customer debit actually landed before its seed
      at 30: mark 90, and at 60 the re-derived date 90 permits the funding abort. This paid
      fixture is a separate settlement path, not a debit manufactured after release. Keep
      `CNF-318`'s duration/null cases. The opening rates on the native-only wind-down, setup-fee
      and first-unit records remain null after the outage case's return. *Amended 2026-10-08,
      `ADR-0033`: the unpaid inside-unit abort expectation is withdrawn.*
      Separately keep the outage through its bound and
      exercise cancellation, including an attach after the bound. Repeat under current suspension
      and under an open restore to check the existing worker precedence.

      With an open restore, satisfy its other close conditions and leave this currency's
      rate-present grace unspent. First establish that all its machines are gone or fenced, then
      attach before the close: close is refused while the new machine is live and unfenced.
      Fence it, record it gone, or spend the remaining rate-present grace; each independently
      permits that currency's close condition. Reverse the ordering: close first, then attach;
      the incident stays closed and the cleanup receives no restore deferral. Check both
      orderings at the close transaction, not just against a previously read inventory.
      (`OPS-36`, `OPS-41`, `OPS-42`, `LDG-40`, `LDG-62`, `LDG-64`, `LDG-66`, `STO-37`, `STO-56`)
- [ ] **CNF-199** — A late-attach cleanup on a tenant whose balance is **below** the wind-down floor
      opens **no commitment at all**, carries the **whole** wind-down as an operator deficiency
      rather than a shortfall against a partial one, still executes the cancel, and never drives
      available negative. (`OPS-36`, `LDG-10`, `LDG-66`)
- [ ] **CNF-200** — A rootfs install naming a drive by unstable device path is rejected; the layout
      carries stable identifiers checked against the inventory fingerprint, exactly as raw-disk
      does. (`RSC-26`, `RSC-22`, `WIR-20`)
- [ ] **CNF-201** — A rescue-inventory run carries a trust policy and is capability-gated on
      `rescue_ssh`; a failure whose rescue exit **also** failed classifies like an install, not like
      a refresh — the machine can be left in rescue — while one whose exit succeeded is `failed`,
      since the pass writes nothing to a disk and `OPS-45`'s first marker is never set for it. Both
      halves; classifying every inventory failure as ambiguous fills an operator's queue with runs
      that ended cleanly. (`WIR-40`, `DOM-10`, `OPS-11`, `OPS-45`)
- [ ] **CNF-202** — Suspending a tenant returns a `suspend_tenant` operation whose children are
      readable through `GET /v1/operations`; resume is synchronous and restores no machines.
      (`WIR-39`, `WIR-41`, `API-58`)
- [ ] **CNF-203** — A replayed revocation returns `409` and no stored bearer token appears anywhere
      in `idempotency_records`. Grep the table for the token value. (`STO-35`, `WIR-38`, `API-3`)
- [ ] **CNF-206** — A disk identifier matching **two** devices aborts `integrity` with no write, and
      an offer whose devices expose no unique identifier is unsellable for rescue installs.
      (`RSC-26`)
- [ ] **CNF-207** — A rootfs install body round-trips `partitions`, `raid.level` and per-drive
      identifiers through the parser. This fixture was silently broken by a fix in the previous
      pass, which is what a fixture is for. (`WIR-20`, `RSC-22`)
- [ ] **CNF-208** — **AMENDED 2026-09-02 — one instant, because the other no longer exists.** The
      enrolment status poll never returns `expires_at`; only the enrolment response does, and the
      poll's status enum is exactly `pending` | `active` | `suspended` — the third added 2026-09-02,
      since `tenants.status` admits it and a suspended tenant's handle had no legal answer without it.
      Publishing the signup's deadline on an
      unauthenticated, handle-addressable endpoint yields its creation instant by subtraction from
      `API-34`'s stated time-to-live. *`issuable_at` was the other half of this item and was
      withdrawn with the field (`API-33`).* (`WIR-13`, `API-33`, `API-34`)
- [ ] **CNF-209** — A suspended tenant can still revoke its spending token. Gating maintenance on an
      active tenant locks the owner out exactly when revocation matters. (`API-7`, `API-56`)
- [ ] **CNF-210** — An orphaned deposit is credited to a named tenant exactly once through the
      operator attribution endpoint; a second call naming a different tenant is `409`. (`WIR-42`,
      `API-34`)
- [ ] **CNF-211** — **REWRITTEN 2026-09-02 — it tested the seizure `LDG-31` forbids.** An ambiguous
      create that resolves *observed* **while its commitment is still open** debits the setup fee
      and the prepaid first unit against that commitment, as two entries of their own kinds
      (`ADR-0033`, 2026-10-08), and decrements it by both in the same transaction. Resolving
      *after* `OPS-33` released it debits the customer **nothing**: each becomes its own operator
      deficiency (`LDG-66`, causes `unrecoverable_setup_fee` and `unrecoverable_first_unit`),
      `LDG-67`'s parked obligations are cleared in the same resolution transaction, available balance does not move, and a wind-down commitment
      `OPS-36` opened on the same machine is **not** decremented. Both halves, and the second is the
      one three requirements disagreed about. (`LDG-39`, `LDG-67`, `LDG-31`, `LDG-66`, `OPS-33`)
- [ ] **CNF-212** — **AMENDED 2026-09-08 (`ADR-0017`) — the dedup is a row, not a JSON entry.** Two
      consecutive exhaustion sweeps over the same machine open **one** episode and enqueue **one**
      cancellation: the second finds the open `(machine_id, delete)` episode and enqueues nothing.
      Opening a second episode per sweep is the failure, and `STO-52`'s index is what refuses it —
      assert the refusal is the store's, by attempting the second insert directly. `CNF-291` carries
      the retention half. (`OPS-39`, `OPS-48`, `STO-52`)
- [ ] **CNF-213** — Attributing an orphaned deposit posts **one `correction` pair per settled
      payment** — never a second `topup`, which would mint satoshis the original settlement already
      credited — and `operator_ref` holds no name, address or contact string. A deposit paid on
      both rails produces two pairs. (`WIR-42`, `LDG-5`, `LDG-55`, `ADR-0005`)
- [ ] **CNF-183** — No customer-facing surface — terms, API documentation, error text, marketing —
      states or implies that satoshis are held, backed, reserved or segregated against a balance,
      **and** the terms do state that a balance is an unsecured claim. Both halves: silence about
      the ratio, disclaimer about the arrangement. (`LDG-19`, `LDG-19a`, `ADR-0004` §4)
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
- [ ] **CNF-181** — On a channel with no verified correlator — Robot's **standard** channel — an
      ambiguous create failure recorded after step 9 begins ends in `needs_reconciliation`
      awaiting an operator, the recent-order
      listing is surfaced as evidence, and **no automatic attach occurs on any hostname or timing
      similarity**. The negative window still releases the commitment in full. **And the same
      create on the auction channel of the same account resolves automatically through
      `CNF-180`'s path** — correlation is per channel, and a build that switches it on or off
      provider-wide fails one half (2026-09-05). (`PRV-33`, `OPS-29`, `OPS-33`, `PRV-32`)
      *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): scoped the ambiguous create to step 9 onward.*
- [ ] **CNF-214** — A machine and one of its billable attachments, both metered in the same period,
      carry **separate** `meter_totals` rows: charging the attachment does not move the machine's
      rounding credit or high-water mark, and neither does the reverse. Asserted against the stored
      subject, not against `machine_id`. *Said "separate `already_charged` sums" until 2026-09-02;
      the quantity is renamed but the failure is the same one — a shared row bills two subjects as
      one.* (`STO-38`, `LDG-8`, `LDG-38`, `LDG-32`)
- [ ] **CNF-215** — **A correction is never clawed back, and the meter is not involved.** Post a
      `correction` naming a `usage_debit`, then meter at least one more increment and assert the
      period's total is **stable**: the next tick posts neither the corrected amount back nor a
      compensating credit. Assert the mechanism, because it is what makes the guarantee cheap —
      the subject's `rounding_credit` is **byte-identical before and after** the correction
      (`LDG-38`). Assert across a full metering interval, not just the posting. A correction is
      still filed under the period of the entry it **names**, not the period it was posted in.
      *Two withdrawn forms, and the pair is the record. The original tested the claw-back as
      correct behaviour — "a `correction` that reduces a charge makes the next tick post more" —
      which described a credit being reclaimed within one tick. Its 2026-08-31 rewrite required the
      correction to carry `corrected_seconds` and asserted that `already_charged` and `exact_total`
      moved together. Both were true of a meter whose state was what-has-been-charged. Under the
      rounding credit the correction cannot reach the meter at all, `LDG-73` is withdrawn, and the
      seconds it required are gone from the schema.* (`LDG-38`, `LDG-5`, `LDG-7`, `STO-38`)
- [ ] **CNF-235** — The meter's cost per tick does not grow within a period. Meter one subject for a
      full period at a cadence that subdivides it, and assert the storage reads per posting are
      constant rather than proportional to the number of prior postings — asserted at the storage
      layer over the suite's traffic in the manner of `CNF-157`, not by reading the code. The
      running total and the entry commit together: kill the process between them and neither
      survives. **Then two zero-debit increments** (2026-09-05): one that **rounds** to nothing
      commits the meter row alone, with no ledger entry; one that **clamps** to nothing commits the
      meter row and its `STO-37` deficiency together — kill the process between those two and
      neither survives. A build that cannot write meter state without an entry, or writes it
      without the deficiency, fails one of the two. (`LDG-72`, `STO-45`, `LDG-35`, `LDG-31`)
- [ ] **CNF-257** — **The install gate reads the create's retained copy, and nothing tested it before
      this item.** Resolve an ambiguous create and assert the attached machine's
      `install_strategies` is the snapshot from its `request_summary` — **not the offer as it stands
      now**. Then assert an install naming a strategy absent from that copy is refused before
      enqueue. *Amended 2026-09-05: this said "the **matched attempt's** copy … not the latest
      attempt's", which `ADR-0014` made unreachable — a create has one attempt. The offer-drift half
      is the whole of the test now, and it was always the half every provider could reach.* **No conformance item anywhere mentioned
      `install_strategies` before this one**, and `05-persistence.md` calls it a safety gate: get it
      wrong and a disk-wiping install is authorized on a machine that cannot take one.
      **AMENDED 2026-09-03 — the caller must be able to read the gate's input** (`DOM-30`): the
      machine view returns that same copy, the key is present on **every** machine, and a
      machine whose stored list is null renders `[]` rather than
      omitting the key or echoing the account's capabilities. Assert an agent can tell a permitted
      strategy from a refused one **without sending an install** — the gate authorizes wiping a disk,
      so discovering it by attempting it is `CNF-150`'s probe-by-purchase with a destructive verb.
      (`OPS-13`, `WIR-30`, `DOM-13`, `DOM-30`, `WIR-11`)
- [ ] **CNF-259** — **Idempotency still works after the payload is purged.** Re-send a key whose
      operation has settled and whose `request` is gone: a byte-equivalent body returns the stored
      result, a different one is `409`. Asserted against the canonical digest, since the payload it
      would otherwise compare against no longer exists — which is the case `API-38` was written for
      and `CNF-21` cannot reach. Both failures end in a duplicate purchase. (`API-38`, `API-11`,
      `ADR-0005`)
- [ ] **CNF-260** — **A machine never has two open commitments.** Attempt every path that opens one
      against a machine that already has one — create, `LDG-62`'s extend on a machine with none,
      `OPS-36`'s wind-down — and assert the store refuses. `LDG-31`'s "that machine's commitment"
      rests on this and it was stated only as a storage constraint. (`LDG-30`, `STO-23`)
- [ ] **CNF-262** — **Two re-derivations of one machine do not both apply.** Concurrent commitment
      adjustments against the same row: one succeeds, the other's conditional write on `version`
      affects no row and is retried or refused. This is the primitive `LDG-34` exists for and it had
      no test. (`LDG-34`, `STO-28`)
- [ ] **CNF-263** — **The write target is verified to be a block device at run time.** A resolved
      identifier pointing at a regular file, a partition, or anything that is not a whole block
      device aborts before any write. `CNF-192` covers identity; this covers what the identity
      resolves to. (`RSC-27`, `RSC-26`)
- [ ] **CNF-264** — **A PTR may only be set on an address the machine actually holds.** A
      reverse-DNS request naming an address absent from the machine's recorded list is refused
      before the driver is called, including an address belonging to another machine in the same
      provider account. (`API-16`, `PRV-25`)
- [ ] **CNF-265** — **Catalogue install verifies in transit and never interprets.** The caller's image
      is fetched by provisiond, its digest verified as it streams, and a mismatch aborts before
      anything reaches the provider; the caller's own URL is never sent to the provider; an image
      exceeding the offer's `max_image_bytes` aborts the transfer rather than completing it; and the
      declared `compression` is taken on trust — asserted by supplying a
      deliberately mislabelled image and confirming provisiond does not inspect it. *`format` was
      named here until 2026-09-02 and this path's body cannot carry one: its source is `raw_disk`,
      which has `url`, `sha256` and `compression` (`WIR-20`).* (`RSC-39`,
      `RSC-40`, `SEC-21`, `WIR-20`)
- [ ] **CNF-266** — **The import runs with the machine yielded, and is bounded.** During the import
      the operation's `yielded_at` is set and the machine is free — a concurrent exposure-reducing
      cancellation takes it and runs — and the machine is re-acquired only for the switch-over,
      which re-validates first; while the cancellation holds the machine the re-acquire is refused
      by `STO-51`'s index and deferred, not failed (`OPS-23`, `OPS-8`).
      An import exceeding the stated maximum wait
      aborts the operation and deletes the imported image. **And the driver exposes `PRV-37`'s three
      calls separately** — import, build, delete — with the delete safe to call twice and an
      "already deleted" rejection read as success (`OPS-11`); a driver that cannot delete an
      imported image MUST NOT declare the capability, which is `DOM-15` applied to the one
      capability that had no driver operation at all until 2026-09-02. (`PRV-37`, `RSC-41`, `OPS-8`,
      `DOM-15`, `PRV-13b`)
- [ ] **CNF-267** — **Both image copies are purged, and an orphan is swept.** On settle and on entry
      to `needs_reconciliation`, the operator's re-hosted copy and the provider's imported one are
      both gone. Then the case that matters: lose the provider-side delete's reply and assert the
      account sweep deletes the image on its next pass, treating an "already deleted" rejection as
      success. A copy of a customer's operating system left in the operator's account is the
      failure, not the storage charge. (`RSC-42`, `OPS-32`, `OPS-11`, `ADR-0005`)
- [ ] **CNF-268** — **A catalogue install settles on the provider's word and says so.** With an image
      that boots unreachable, the operation still settles `succeeded`, provisiond makes no
      reachability probe, the machine's `last_install` reports
      `bytes_verified_by_provisiond: false`, and the offer carried non-null `guest_requirements`.
      **The absence of the probe is the assertion** — a caller's image may legitimately ship no SSH
      daemon. (`RSC-43`, `DOM-29`, `WIR-30`, `OVR-1`)
- [ ] **CNF-269** — **`last_install` outlives the operation that wrote it.** Install a machine, let
      retention delete the settled operation (`STO-14`), and assert the machine still reports the
      strategy, the verification flag and the instant. A machine that outlives the record of how it
      came to be is the defect `STO-43`'s ages were moved onto this row to avoid, and the one
      `ADR-0017` gave the episode a row of its own to avoid. (`DOM-29`, `STO-14`)
- [ ] **CNF-270** — **An imported image is not reachable by another tenant, and does not outlive its
      install.** No caller-supplied input reaches the provider's image identifier — a caller can
      name a URL and nothing else — so no tenant can build from another's image through this system.
      The image is gone once the operation settles, and the deployment has stated how many tenants
      share one provider account (`SEC-43`). Assert the first clause against the request surface,
      not by reading the driver. (`SEC-55`, `RSC-42`, `API-17`, `SEC-43`)

### Added 2026-09-02 (the two-reviewer pass that returned NOT BUILDABLE)

- [ ] **CNF-271** — **AMENDED 2026-09-08 (`ADR-0017`) — the episode is the unit, and `failed` is a
      fact about an attempt.** Walk `OPS-48`'s transitions against a real row. Drive an
      exposure-reducing cancellation whose provider call fails after the fence is written — once
      with a 5xx, once with `authentication`, and once with `rate_limited` — both before
      and after acceptance. Assert: 5xx is `needs_reconciliation`/`uncertain` in either case;
      the other kinds are `failed`/`stalled` before acceptance and
      `needs_reconciliation`/`uncertain` after acceptance (amended 2026-10-08, `ADR-0035`); in both, the episode stays open, `destroy_committed` still holds its id,
      `LDG-62` is still refused `conflict`, and the `stalled` episode appears in the operator
      listing `OPS-26` requires. `retry` on the `stalled` one enqueues a fresh attempt that **runs
      the provider call again** rather than aborting into a false `succeeded`, and the episode is
      `attempting` with `current_operation_id` naming the new attempt. Then the closing rows: an
      attempt that succeeded **with the resource gone** closes the episode `resource_gone` and clears
      the fence in the same transaction; an operator `abandoned` on an **`uncertain`** episode's
      attempt (`OPS-31`) closes it `abandoned` and clears the fence so a later sweep may open a
      fresh one — there is no such verb on a `stalled` one; a machine **recorded gone** (`API-63`,
      `LDG-74`) closes an episode in any open state `resource_gone` and clears the fence in that
      write, and a later `OPS-31` resolution of its retained attempt leaves the closed episode
      closed; and **no timer ever moves a `stalled` episode** — run the clock out and assert it is still `stalled` with one
      attempt, including a `rate_limited` refusal before acceptance (`ADR-0035`; `F48` retains the deferral history). **Then the row a reader
      will get wrong**: a cancellation the provider merely *scheduled* (`DOM-19`) settles
      `succeeded`, the episode is `scheduled`, and it and the fence both **stay** while the
      machine is present, even after the effective date. Only an evidenced gone-write closes
      the episode and clears its fence; tombstoning waits for the retention gate. Closing at
      the date lets the next exhaustion sweep open
      a fresh episode and place a second cancellation against a machine already scheduled, which
      `OPS-39` warns can alter or repeat the first's mutation. **The failure this catches is a
      sweep loop that settles `succeeded` forever while the machine bills forever.** (`OPS-48`,
      `DOM-31`, `OPS-42`, `OPS-39`, `OPS-26`, `API-64`, `LDG-62`)
      **Added 2026-10-04 (`pv-gip.11`, `ADR-0032`): rate-funded stalls and explicit keep.**
      After a deterministic failed delete, accept a favorable rate and re-derive future runway.
      Sweep repeatedly: same stalled episode and attempt, same fence, extension refused. Let
      that date lapse and sweep again: no new attempt. Retry the price-funded episode with a
      fresh key and observe the provider call, not a funding abort; also try no rate before the
      outage bound. The retry still defers under an open restore record with null/future original
      grace end; once claimable, it uses the retry branch. A gone-write or permanent close before
      its fence transaction still prevents the call. An ordinary funded attempt still aborts.
      On a separate stalled fixture, keep: in one transaction observe `closed`/`kept`, cleared
      fence, re-derived date, authenticated `kept_by` and the submitted `operator_ref` in
      `keep_evidence`, and the durable receipt; no new operation, provider call or money movement.
      An extension now succeeds with other admission conditions satisfied. Kill/restart at the
      transaction boundary and after response loss: either no effects or all effects, and exact
      receipt replay repeats none. Retire the old attempt under `STO-14`: episode evidence remains.
      Use a new key on that closed episode, and exercise attempting, uncertain and scheduled
      states: `409` state, unchanged. Race keep against retry and against a gone-write in both
      orders; the losing conditional write cannot overwrite a close or clear the retry's fence,
      and a gone-write after keep does not re-close the old episode. Replay keep after a new
      episode opens: the original view returns and the new fence remains. Keep an unfunded
      machine: no funds are added and the next sweep opens a fresh episode under the existing
      predicate. With no rate keep retains the stored date; the sweep waits for rate under
      `LDG-16`. Keep remains operator-only (customer/recovery cannot reach it), is synchronous,
      and is not a spending or retry-ceiling verb. (`API-68`, `WIR-55`, `STO-52`, `WIR-24`)
      **Added 2026-10-05 (Q14):** `CNF-312` covers the interrupted, never-fenced prefix and
      its extension/fence orderings; retain this item's fenced, timer and keep controls.
- [ ] **CNF-312** — **Interrupted cancellation before its fence (2026-10-05, `pv-gip.43`, Q14).**
      Exercise `OPS-41` step 2 and `OPS-42` ordering on independent instances with an
      available rate, a healthy provider account and no other admission refusal. Each starts
      unfunded with an active tenant; the suspended row below changes that tenant's state.
      For Orders A and B, provide sufficient available balance and choose an extension that
      funds the machine at the deciding rate. The other rows use a favorable rate and
      re-derivation to fund it, without an extension.
      **Route 1 prefix:** let the sweep enqueue the cancellation and the worker claim it, then
      kill the worker before its fence transaction. Restart: `OPS-15` requires "move every
      `running` operation to `needs_reconciliation`" and "MUST NOT move them back to `queued`".
      Assert that operation state and episode `uncertain`. Resolve `not_applied` as operator:
      assert the attempt `failed`, episode `stalled`, null `destroy_committed`, null
      `write_started_at`, and zero provider calls throughout the prefix. Drive the actual
      lifecycle; manually seeded stalled rows and startup requeue do not satisfy this case.
      `OPS-45` says "This rule classifies a failure a worker recorded"; it orders no such failure
      before this fence write.

      `OPS-23`'s "before the driver is called" establishes no such ordering either. Therefore
      drive route 1 alone. Do not inject a store error as a separate
      failed route: `OPS-49` requires "repeat the **whole transaction**" and on bound exhaustion
      "the engine MUST exit non-zero".
      Orders A and B and the suspended/null-fence row each start from a fresh instance of
      that route-1 stalled/null-fence prefix. The fenced rows use their own prefixes below.
      Instrument the deciding fence transaction's read/commit boundary:
      retry enqueue alone establishes neither transaction order.

      **Fenced, undispatched prefix:** drive a real cancellation through its unfunded fence
      transaction and wait for commit, then kill the worker **before the dispatch-marker
      write and provider call**. `OPS-42` says the worker "releases it before the provider
      call".

      `OPS-45`'s delete marker row says "the provider call is dispatched". Assert the
      marker is still null at the injection boundary; a kill merely before the call does
      not establish that. Restart through the same startup classification, then resolve
      `not_applied` as operator. `OPS-45` says "an operation interrupted rather than classified
      is `OPS-15`'s, whatever the markers hold"; `OPS-48`'s resolved-not-applied row is
      `stalled` with the fence "**Unchanged**". Assert the original attempt `failed`, episode
      `stalled`, fence still holding that episode's id, original attempt's `write_started_at`
      null, and zero provider calls throughout this prefix.

      **Suspension fan-out:** from the route-1 prefix, suspend the tenant. `API-58` says the
      pass "MUST NOT enqueue" for an already-open delete episode, and must "append
      `tenant_suspended` to that episode's `reasons` set" and "name its `current_operation_id`
      in `cancellations`". Assert the same episode and its current failed attempt account for
      the machine, the reason is appended, the parent terminates, and the fan-out enqueues
      no new cancellation attempt.

      | Case | Required observations |
      |---|---|
      | Order A: extend, then retry | Extension admits and commits before the retry's fence transaction. The attempt settles `succeeded` with a no-mutation result; episode `closed`/`funded`; fence null; provider call count remains zero. The extension's commitment is kept: reconcile any legitimate metering independently and assert no cancellation-driven commitment release. |
      | Order B: retry's fence transaction commits unfunded, then extend | Observe the fence holding the episode id before submitting the extension; it returns `409` / `cancellation_committed`, with no balance movement or commitment growth attributable to that refused extension. The provider is called. |
      | Fenced control | Use `CNF-271`'s provider-failed stall after fencing, accept a favorable rate and re-derive future runway without clearing that fence. Retry still calls the provider again and does not close `funded` through a funding abort. |
      | Fenced, undispatched control | Use the fenced, undispatched prefix above. Accept a favorable rate and re-derive funded runway without clearing the fence. Retry the same episode: observe a provider call and no funding-abort close to `funded`. The original attempt's `write_started_at` remains null; distinguish it from the fresh retry attempt's own initially unset marker. |
      | Suspended, null fence | Use the route-1 prefix and suspension fan-out above. Accept a favorable rate and re-derive funded runway while suspension remains current; do not extend. Retry as operator and observe that the deciding transaction reads a null fence and a currently suspended tenant. Observe a provider call and no funding-abort close to `funded`. |

      These assertions discriminate unconditional retry bypass (Order A), a funding re-check
      on every retry (fenced control), and a missing extension fence (Order B).
      The **fenced, undispatched control** fails a build that keys retry bypass on the
      **previous attempt's `write_started_at`** instead of the episode fence: it re-checks
      funding and closes `funded`, violating both the provider-call and no-funding-abort
      assertions. That build passes Order A and the dispatched/provider-failed controls.
      The **suspended, null-fence row** fails a build that branches to the null-fence funding
      path **before considering current suspension**: it closes the funded machine's episode
      and omits the provider call, violating the same assertions. `OPS-41` step 2 instead
      says "A retry reading the fence null decides from step 3 unless the tenant is suspended
      now." Preserve `CNF-271`'s timer and keep controls and `CNF-272`'s fenced/resume controls.
      These new rows specify implementation observations, not additional model results:
      the existing Fence model's interrupt handles only the pre-fence holding phase and
      carries no persisted dispatch-marker history.
      **Restore scope, inspected rather than rehearsed here:** `OPS-41` says "A claim made while
      a restore record is open and its `grace_ends_at` is null or in the future defers, and writes
      no fence" and "The rule applies whichever path enqueued the cancellation — a delete
      re-run by step (2), an operator's retry". That claim gate precedes this item's decision;
      after it, step 2's null-fence path uses the same ordered funding decision as a re-run
      delete, including step 3's "Only if the predicate would cancel" paused-grace check.
      `STO-54` directs goal-state kinds to "re-run, since `OPS-11` classifies ‘already in the
      target state’ as `succeeded`". Text inspection finds no retry/first-attempt exception when
      the provider already deleted but restore rolled the fence back: both retain the claim
      gate and ordered decision; a dispatched delete uses that existing goal-state result.
      A funded abort can precede dispatch on either path while the restored row still says
      present. This item does not drive route 2 or establish restore conformance; that remains
      with `CNF-218` and `CNF-295`. (`OPS-15`, `OPS-31`, `OPS-41`, `OPS-42`, `OPS-48`, `API-64`,
      `LDG-62`, `STO-54`)
- [ ] **CNF-272** — **A suspension terminates even when a child cannot delete.** Suspend a tenant
      while the provider account's credential is rejected, so every child cancellation fails
      `authentication` — deterministic, and `OPS-11` sends it to `failed` rather than to
      `needs_reconciliation`. Assert the fan-out **terminates** — a later pass enqueues nothing for
      those machines, because an open episode exists for each — the parent settles `succeeded` with
      that child named in `WIR-39`'s `cancellations`, `WIR-41`'s resume becomes available, each
      machine's episode is `stalled` and listed for the operator, and `retry` on it (`API-64`) is
      admitted although the tenant is suspended — every operator verb skips `API-7` step 5b. **Then
      run the clock out and assert that nothing automatic cancels the machine**: it stays in the
      operator listing and the exhaustion sweep enqueues nothing, because the open episode it would
      need is the same one that made the fan-out terminate. **Then suspend a tenant one of whose
      machines already has an open exhaustion episode**, and assert the fan-out terminates: the pass
      appends `tenant_suspended` to that episode's `reasons`, names its current attempt in
      `cancellations`, and enqueues nothing new — and that `OPS-41`'s re-check treats that delete as
      a suspension cancel even though the operation itself carries `exhausted`. **Then resume that
      tenant (`WIR-41`), retry the funded stalled episode, and assert a provider delete is called**.
      Assert the episode fence remains set; that fenced retry does not re-check funding,
      including after resume. In a separate ordinary-attempt
      arm, resume before its first claim and give it future runway: it aborts funded, so current
      suspension still wins over historical episode reasons for that branch.
      *Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`): withdraw retry-driven survival.*
      The operator paths are in `OPS-48`; its table supplies no timer retry. *Corrected 2026-09-04: this item said "the machine keeps draining runway so
      `LDG-13` reaches it unaided", one clause after asserting that a later pass enqueues nothing
      for exactly these machines. Both cannot hold, and a build could satisfy the item by
      implementing either.* Three wrong answers fail this item: a fan-out that never settles, one
      that settles while nothing at all accounts for the machine, and one that quietly re-enqueues
      a delete the credential cannot perform. (`API-58`, `OPS-48`, `OPS-39`, `API-7`, `API-64`,
      `LDG-13`)
- [ ] **CNF-273** — **A settled payment is findable afterwards, by the only handle anyone kept.**
      Settle a deposit on both rails, reap its tenant at `API-34`'s time-to-live, and then attribute
      the deposit to a fresh tenant: the two payments are enumerated from `payments` by
      `deposit_id`, each `correction` pair names that payment's own credit entry, **both entries of
      each pair insert under the key `correction:` plus the payment reference** — keyed on the bare
      reference the negative entry collides with the source tenant's own `topup` and the whole
      attribution fails on its ordinary input (2026-09-05) — and every entry
      carries the `deposit_id`. Assert the storage shape too, because it is what makes the rest
      possible: a payment row and its `topup` commit in one transaction (kill the process between
      them and neither survives), `payment_ref` is unique so a replayed settlement credits once, and
      a credit whose tenant identifier matches no live row is reported unattributed **by the join**
      rather than by a stored flag. **The failure this catches is a stranger's money the operator
      has made itself unable to return** — `LDG-43` calls it the one outcome the specification must
      not permit by accident, and until today the deposit binding, the payment record and the
      enumeration it needs were three MUSTs pointing at each other with no column underneath.
      (`STO-46`, `STO-30`, `STO-31`, `LDG-43`, `WIR-42`)
- [ ] **CNF-274** — **A rate move never re-prices time already billed — within an increment or
      across one.** Meter one subject across a period, move the rate **up** between two increments,
      and assert the second posting charges only the second increment's seconds at the new rate.
      Move it **up mid-increment** and assert the increment **splits** at `STO-49.accepted_at`, so the
      seconds before the move are charged at the old rate (`LDG-38`); an implementation that prices
      the whole increment at the closing rate fails here and is the defect `CNF-185` also catches.
      **Then the same mid-increment move followed by a process kill before the tick**: on restart
      the increment still splits at the recorded `accepted_at`, read from `STO-49`'s
      `rate_observations` — a build that keeps the accepted rate in memory prices the whole
      increment at whichever rate restart finds first (2026-09-05).
      Make `observed_at` precede `accepted_at`, with a posting between them: until acceptance
      the old rate holds, including on replay after restart. The ledger retains observation
      time as evidence. (*Amended 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13.*)
      Then move the rate **down** and assert the posting is a smaller positive figure and **never
      negative**: a positive `usage_debit` is undefined (`LDG-7`) and `LDG-31` would take it as a
      debit to pair with and **grow** the commitment, which is the automatic widening `ADR-0011`
      abolished. **Then the clamp**: drive a posting that exceeds the remaining commitment and
      assert the ledger entry carries only what the tenant's authority covered, the remainder is an
      `operator_deficiencies` row whose `clamped_sats` states it in satoshis, and the subject's
      rounding credit advances as though the full computed debit had been posted. *The withdrawn
      form asserted that `already_charged` advances by the full computed debit rather than the
      clamped entry — a rule that existed because the meter's state was what-has-been-charged, and
      that `LDG-38`'s own formula contradicted for a day. The recurrence no longer names the entry,
      so there is nothing left to get wrong in that direction.* (`LDG-38`, `LDG-72`, `STO-45`,
      `LDG-31`, `ADR-0011`)
- [ ] **CNF-275** — **Re-derivation runs on its own clock, not the billing period's.** The deployment
      states a re-derivation interval separately from `LDG-68`'s period; `runway_until` on a live
      machine is never staler than that interval; and `PRV-13c`'s "materially in the future" test —
      *now + one interval + wind-down* — still puts a cancellation date a week out on the
      **exception** branch. Assert the last one against a machine whose `earliest_cancellation_date`
      is days away, since a monthly interval swallows it into the ordinary path and silently deletes
      the `DOM-19`/`LDG-63` branch. (`PRV-13e`, `LDG-68`, `PRV-13c`, `OVR-19`)
- [ ] **CNF-276** — **The catalogue fetch cannot be pointed at the inside.** Drive `RSC-39` with a URL
      resolving to loopback, to `169.254.169.254`, to an RFC 1918 address, and to an IPv4-mapped
      IPv6 wrapper around each: every one is refused before a byte is sent. Then the three that a
      naive implementation passes — a name whose **second** resolution answers with a private
      address (rebinding: the connection must go to the address that was validated, or revalidate at
      connect), a public host that redirects to a private one (revalidated per hop, with the hop
      count capped), and a public host that redirects to a **scheme** change — which `RSC-44` holds
      itself, since `RSC-17` binds the rescue host's fetch tool and not this one. Assert every
      refusal is kind `invalid_request` (`API-24` forbids a handler choosing) and carries no
      resolved address, status or body size, so a refused fetch is not a port
      scanner with an oracle. And assert `SEC-19`'s three moments: with an empty allowlist the
      deployment **refuses to serve catalogue install at startup**; a request naming a host
      outside a configured list is rejected **before enqueue** (`API-13`); and **an allowlisted host
      that redirects to a host outside the list is refused at the hop**, with the redirect target
      resolving to an ordinary public address so no address-class rule can account for the refusal.
      *That third case was added 2026-09-04 and is the one a build passes by accident: the two
      redirect cases above it both turn on something about the address or the scheme, so an
      implementation checking the allowlist once at request time satisfies every one of them.*
      **This is an SSRF primitive inside
      the process holding every provider credential and root on every customer machine** — `RSC-40`
      put the hostile input there on purpose and bounded only what is done with the bytes.
      (`RSC-44`, `RSC-39`, `SEC-19`, `RSC-17`, `OVR-10a`)
- [ ] **CNF-277** — **A machine the provider destroyed stops being billed without anyone asking.**
      Delete a machine at the provider behind the system's back and then run **only** `OPS-32`'s
      sweep — no refresh, no caller request, no operator action. Assert the sweep **writes** the
      observation to the machine row, the meter posts nothing for time after that instant, and the
      commitment closes once every billable attachment has release evidence (`released_at`)
      (`LDG-32`, `STO-18`); a stored effective date alone does not close it. Then the
      halves that are easy to get wrong. Nothing is credited for the window **before** the
      observation, since provisiond polls rather than watches and the earlier instant is not
      knowable. **A `cancellation_scheduled` machine stops at its `effective_cancellation_date`, not
      at the sweep pass that later observes it gone** — advance the clock one full sweep interval
      past the date before the pass runs and assert no debit lands in that interval (`LDG-38`,
      `DOM-19`; added 2026-09-05, when a build that billed to the observation passed this item
      either way). Under `SEC-46`'s `account_unreachable` or `credentials_rejected` the meter
      **keeps running**, because the machines are still there and still billing the operator. A
      machine in `DOM-7`'s **`failed`** keeps being metered — it is broken, not gone, and a failed
      dedicated machine is still allocated and still invoiced. A machine with an unreleased billable
      attachment stops its **own** meter and is **not** tombstoned (`STO-18`), while the attachment
      is metered on its own subject only through `LDG-38`'s earlier applicable effective date or
      `released_at`. And a sweep pass that **yields to `rate_limited` part
      way records no absence at all** — the half-listing must not close a whole account's
      commitments. **A machine created inside `PRV-36`'s effective visibility window and not yet in
      the provider's listing records no absence either**, and its meter keeps running: seed a listing
      that omits a machine created seconds ago, assert the sweep writes nothing, then re-run past
      the window with the machine present and assert it is still metered and still committed.
      Repeat with a create whose reply arrives at its provider-call deadline, and with one whose
      reply is lost: a complete listing and direct `not_found` read after the dispatch-based
      window would have elapsed, but before the window measured from the reply or deadline
      expiry has elapsed, MUST write no absence.
      Only the reply or deadline expiry starts that visibility wait. *Amended 2026-10-09
      (`ADR-0037`, Q13).*
      Assert the window used is `PRV-36`'s and **not** `OPS-33`'s negative window — a build wired to
      the longer one passes this seeding and bills a terminated machine for hours. Assert too that a
      **late-attached** machine (`OPS-36`) records an absence on the first pass, having no create to
      measure from. **And assert no absence is recorded without a direct re-read**: seed a listing
      that is *complete* and still omits a live machine — page churn, an offset listing where a
      deletion ahead of it slides it onto a page already fetched — and assert the sweep re-reads
      `(provider_account, external_id)`, finds it, and writes nothing. *A build that trusts a
      complete listing passes every other half of this item and stops a live machine's meter.* *Added 2026-09-04 — without it a build that stopped the meter and released the
      commitment on a live machine passed every other half of this item.* Run the first half on a machine created and never refreshed — **aged past its
      visibility window before the external delete**, or a conforming sweep skips it while this item
      waits for an absence write — that is the
      ordinary machine, and binding the stop to a caller's refresh leaves it draining forever.
      On a retained machine already recorded gone, verify the same automatic pass lists its
      attachments and directly re-reads a missing billable attachment before writing its
      `released_at`; an interrupted pass or a direct read that finds it writes no absence.
      (`LDG-74`, `OPS-32`, `STO-48`, `LDG-37`, `DOM-7`, `DOM-8`, `STO-18`, `SEC-46`)
      **No tick during a short life:** configure a 60-second meter interval and a fixture
      provider whose effective visibility window is one second. Record the machine billable at
      second 10, with `r = 0`, 30 sats committed and customer rate 1/5 sat/s; record it gone at
      14 with no intervening tick. Expect priced interval [10,14), debit/decrement 1, `r = 1/5`,
      mark 14, and release of 29 only after that posting. Drive the gone write separately through
      the complete sweep and direct re-read, explicit refresh, an operation's authoritative
      driver read, and successful delete settlement (`OPS-48`'s gone-write row).
      **Race the tick:** let a tick read billable at 13 and wait outside serialization; commit
      the exit at 14, then resume the tick, and also submit a tick after the exit. Assert the
      re-read clips to 14 and discards: no debit, decrement, credit change or false deficiency.
      Observe tenant serialization on each exit, including the sweep, with provider enumeration
      and direct re-read outside it. Repeat on a zero-entry closing increment: tick at 7 on a
      seed at 0 and rate 1/5 posts 2, then exit at 9 posts no entry, leaves `r = 1/5` and mark 9;
      neither late tick moves anything despite there being no entry key ending at 9.
      **Outage exit:** seed 0 with `r = 0` and sufficient commitment; use 1/5 sat/s until a
      history-derived outage start at 7, stop at 14. Expect total debit/decrement 2 for [0,7),
      `r = 3/5`, mark 14 and one native-only `rate_outage` row with `absorbed_from = 7`,
      `absorbed_until = 14`, `absorbed_seconds = 7`. Exercise a first no-rate posting at 10
      that opens the row before exit with `absorbed_seconds = 0` and `absorbed_until = null`,
      then repeat without an intervening tick so the exit conditionally inserts and closes it
      itself. There is never a duplicate, no satoshi debit for [7,14), and a later
      rate return posts no catch-up debit. Repeat through the attachment release writers.
      **Rate returns before exit:** mark 12:00, outage 12:20–12:30, exit 12:40, within one
      period. First run with a no-rate posting at 12:25 to open the row while the outage is live;
      the pass observed at 12:27 and accepted at 12:30 closes it at 12:30
      (*amended 2026-10-04, `pv-gip.6`, Q13*). Across that posting and the exit, price
      [12:00,12:20) and [12:30,12:40) at their respective rates, absorb only [12:20,12:30),
      and leave `absorbed_until = 12:30` after exit, with mark 12:40. With `r = 0`, sufficient
      authority, 1/5 sat/s before the outage and 2/5 after it, expect total debit/decrement 480
      and final `r = 0`. The row was opened while the outage was live, so this checks its
      end independently of historical no-row replay; assert `absorbed_seconds = 600`.
      **Delayed acceptance during an outage** (*added 2026-10-04, `pv-gip.28`, `pv-gip.6`,
      Q13*): seed/mark 13:00, outage starts 13:20, `r = 0`, sufficient authority, customer
      rate 1/5 sat/s before it. A pass reads at 14:00 and accepts at 14:10 with a still-fresh
      non-null verdict giving 2/5 sat/s. Post through 14:20, once with an intervening 14:05
      posting and once without: both debit 240 + 240 = 480 sats, final `r = 0`, one outage
      row [13:20,14:10), `absorbed_seconds = 3000`, finalized native cost and null opening
      rate. [14:00,14:10) is never priced retroactively; repeat and restart replay change
      nothing. Check the no-row run's insertion already closed as well as closure of the
      row opened at 14:05. In a separate no-restore run put the outage deadline at 14:05
      and execute its cancellation then: the decision stands after acceptance at 14:10,
      and replay still shows the deadline reached. Its valid meter stop at 14:05 closes
      that subject's row there; the later return overwrites nothing.
      Accept the 14:00 evidence only after its stamped bound has expired: no returned-rate
      interval, no new outage or restarted deadline, no customer charge during the ongoing
      outage. Finally hold the acceptance transaction after it stamps 14:10 while a no-rate
      posting advances the subject mark to 14:12 (or seed these closing inputs if the
      implementation serializes away that interleaving): on closure retain relief through 14:12,
      `absorbed_until = 14:12`, 3120 absorbed seconds, and no retroactive debit. Repeat with
      a valid stop at 14:11 and with a clipped billable-span seed; retain the earlier stop
      and compute only billable overlap. Native finalization and per-increment/period
      apportionment use the resulting window; an already-closed row is never rewritten.
      **Finished outage discovered at posting:** within one period, mark/seed 12:00,
      initial `r = 0`, sufficient authority, customer rates 1/5 sat/s before the history-derived
      12:20–12:50 outage and 2/5 afterwards. Retain the history for replay and post nothing
      during the outage. Run independent ordinary-tick and exit fixtures at 13:00. Both
      conditionally insert one subject row already closed, `absorbed_from = 12:20`,
      `absorbed_until = 12:50`, `absorbed_seconds = 1800`, null rate fields (*amended
      2026-10-04, `pv-gip.39`: remove the obsolete deficiency-resolution field*).
      Assert debit/decrement 240 for [12:00,12:20), none for [12:20,12:50), and 240 for
      [12:50,13:00), total 480, final `r = 0`, mark 13:00; the exit releases only after
      posting. Repeat the tick and replay the exit: no extra row, debit, seconds or relief.
      **Delayed gone observation:** with the same history and mark, a scheduled stop at
      12:40 and gone writer at 13:00 inserts [12:20,12:40), `absorbed_seconds = 1200`.
      Assert debit/decrement 240 for [12:00,12:20), none after 12:20, mark 12:40 and
      `r = 0`. Run a matched tick at 13:00 clipped to the same scheduled stop: identical
      row, charge and mark. Its later gone write discards the already closed increment;
      neither it nor a repeat tick moves the row's end to 12:50 or 13:00.
      **Increment begins inside the finished outage:** first post at 12:30 to open the
      [12:20, null) row and advance the mark to 12:30; assert zero seconds while open.
      The return closes it at 12:50 with 1800 seconds. The 13:00 tick subtracts only
      [12:30,12:50), 1200 seconds, from its increment, charging 240 for [12:50,13:00).
      Earlier charged time is untouched and the total remains 480. Repeat with no prior
      outage row and a subject seeded at 12:30: its first posting at 13:00 inserts
      [12:30,12:50) with 1200 seconds and charges only the same 240. Exercise these
      historical cases for attachment subjects as well; `CNF-216` and `CNF-305` hold
      the period and billable-span cases. (`LDG-38`, `LDG-35`, `LDG-64`, `STO-37`,
      `LDG-8`)
- [ ] **CNF-278** — **An account can actually be recorded lost, and the right thing happens.** Drive
      `POST /v1/provider-accounts/{account}/actions/record-status` across all four statuses, **on
      independent account fixtures** — `terminated` is write-once (`API-63`), so a single account
      cannot be walked through the four and any `healthy` assertion made after it on the same account
      is unreachable rather than passing. *Corrected 2026-09-04: this item said "through all four
      statuses", which is a sequence the endpoint refuses.* The four:
      `account_unreachable` and `credentials_rejected` **retain** every commitment on that account's
      machines **and keep metering them**, `terminated` closes and releases them all in **one**
      transaction, and `healthy` on an account that was **`account_unreachable`** — the reachable
      recovery, not the forbidden one — restores nothing and re-derives normally. **Seed the two tenant lists so
      that neither contains the other** — one tenant re-assigned away that still has machines here,
      one assigned here that owns none — and assert `affected_tenants` holds exactly the first and
      `assigned_tenants` exactly the second, plus whatever tenant is in both (`WIR-50`). *A single
      list, or a fixture where the two sets coincide, passes the build this item exists to reject.*
      **On the `terminated` case, assert the whole ordered transaction and then run the clock out.**
      Each machine carries a gone state and `state_observed_at` at the recording instant, every
      unreleased billable attachment carries a `released_at`. For each non-quarantined subject,
      the closing increment and mark reach its stop boundary before commitment release. Assert a
      final ledger entry only when the computed posting is positive and the commitment permits it;
      during an outage its priced prefix ends at the outage start, while the mark reaches the stop.
      Use the 10-to-14 short-life fixture of `CNF-277` on
      different tenants: each posts 1 before releasing its remaining 29. Include a scheduled
      machine with effective date 12, seed 10, rate 1/5 and termination at 14: its debit is 1,
      mark 12 and `r = 3/5`, never a charge for [12,14). Include a quarantined subject using
      `CNF-236`'s delete fixture: stop is recorded, no debit/decrement or meter-state write;
      its commitment is released by termination. Exercise `CNF-277`'s outage fixtures too.
      **Zero-entry termination:** within one billing period, seed at 0 with `r = 0`, rate
      1/5 sat/s and commitment 30. Tick at 7: debit/decrement 2, mark 7, `r = 3/5`, remaining
      commitment 28. Record account termination at 9: the closing increment [7,9) costs exactly
      2/5, so `ceil(2/5 − 3/5) = 0`. Assert no extra debit or usage decrement, mark 9 and
      `r = 1/5` before release of the remaining 28; the last ledger debit still ends at 7.
      Resume a tick that read billable before termination and submit another after it: neither
      posts nor changes the mark or credit, despite there being no entry key ending at 9.
      Assert all affected tenants' primitives are acquired in ascending identifier order,
      in the one account transaction, with stop → `LDG-38` exit → `LDG-32` release. Then advance
      past at least one metered increment and assert **nothing
      further posts**, for any machine in that account or any attachment it left behind. Finally
      assert the exhaustion sweep mints **no** delete for those machines: a build that stops the
      meters and leaves the rows in inventory floods the operator listing with one permanently-open
      episode per machine (`LDG-13`, `OPS-48`). **Seed one episode in each open state before the
      termination** — `attempting` with a queued attempt, `uncertain` with a retained
      `needs_reconciliation` attempt, `stalled`, `scheduled` — and assert every one is `closed`
      `resource_gone` with its fence cleared in the recording transaction, the queued attempt is
      `failed` `account_terminated`, the `needs_reconciliation` attempt is still retained, and an
      operator's later `not_applied` on it leaves the episode closed (`OPS-48`, `ADR-0021`).
      **Queued operator retry** (*added 2026-10-04, `pv-gip.11`, V3*): stall a delete,
      invoke `API-64`, and stop before its fresh attempt is claimed. Verify the new attempt
      has `requested_by: operator` and non-null `episode_id`; terminate its provider account.
      In that transaction the retry becomes `failed`, `conflict`,
      `details.reason: "account_terminated"`, and its episode closes `resource_gone` with
      the fence cleared. The settled old attempt is unchanged. A queued retry on a different
      account and an unrelated queued operator operation remain unchanged by the cancellation
      failure write. Race the new retry's claim against termination in both orders: termination
      first prevents the claim; claim first defeats the administrative failure write, leaving
      settlement to the worker under the closed episode with no provider call if its fence
      transaction follows the close. Also short-defer a claimed retry to `queued` before
      termination: its nonzero claim number excludes it from this never-claimed write.
      *Added 2026-09-04: the release was asserted and the
      stop was not, so a build that closed the commitments and went on metering into the tenant's
      free balance passed this item.* **Then assert the account stops being sellable**: `GET
      /v1/providers` omits it for an assigned tenant, and a create naming it is `409` `state` —
      including a create issued against a catalogue read taken **before** the termination, since the
      listing is advisory. Assert the refusal on **all three** unhealthy statuses and on **both**
      catalogue routes — the collection and `/providers/{account}/offers` (`WIR-30`).
      **Barrier case, and it is the one a lock alone fails**: hold a meter tick
      that has already read the machine as billable, commit the termination, then release the tick —
      it must post nothing, because `LDG-38` re-reads billability inside the serialization rather
      than trusting what it read before. **Second barrier**: admit a create that passes the health
      check, commit the termination before its commitment opens, and assert the create is refused —
      the create **conditional-writes** `STO-47`'s row guarded on `healthy` in the transaction that opens
      the commitment, and a mere read there is not enough under snapshot isolation. **Third**: leave
      a create `queued` and unclaimed naming the account, commit the termination, and assert it is
      `failed` with `details.reason: "account_terminated"` and its commitment released — a worker
      that claims it afterwards dispatches against revoked credentials and freezes the customer's
      money for `OPS-33`'s window. **Fourth**: claim a create, commit the termination before its
      step-8 transaction commits (`about_to_order_at` still null), and assert it fails `account_terminated` with no provider mutation;
      the List offers read is permitted;
      then commit the termination *after* step 8 commits (`about_to_order_at` set) and before the call, and assert the
      termination treats that attempt as potentially dispatched — neither failed nor released, and
      resolved through `OPS-36`'s late attach.
      **Account-read cases:** admit a create and leave it `queued` and unclaimed, record
      `credentials_rejected` before claim, then claim it. Assert `OPS-43`'s step 1, "Read the
      provider account's stored status", fails it `conflict` with `details.reason: "state"`,
      `failed`, no provider request and full commitment release. On a fresh account, claim a
      create, let the List offers read complete, then commit termination before step 8 commits (`about_to_order_at` null). Assert `conflict`, `details.reason: "account_terminated"`, `failed`, full commitment
      release, and no provider mutation: no per-order key upload and no order request.
      Repeat the step-8 barriers and account-read cases with an auction-channel descriptor and
      a standard-channel (`correlator: none`) descriptor; assert the column's null/set test on
      both, making no assertion about the correlator pair on the latter.
      **Fifth**: reload configuration over the `terminated` row and assert it stays `terminated`.
      **Then activate a
      fresh tenant while that account is terminated and assert it is never assigned to it**
      (`STO-36`, `API-57`); with **every** assignable account unhealthy, assert activation still
      succeeds with no assignment and emits the event `API-57` requires, rather than leaving the
      tenant `pending` for `API-34` to reap — **and that recording one account `healthy` afterwards
      assigns that tenant automatically, with no operator verb**; and that a re-assignment cannot leave a tenant with no
      healthy assignment — the failure is a tenant that lands on a dead
      account at activation, reads an empty catalogue, and holds a balance `ADR-0004` forbids
      refunding, having appeared in no `record-status` response because it did not yet exist. *Also 2026-09-04. `STO-47` had one writer and no reader at all, while
      `API-62` cited "`WIR-29` returns it nothing it can buy from" as the reason its re-assignment
      verb exists; the create reached a driver holding revoked credentials.*
      Then the three refusals: recording a status the driver itself reports is `409` `state` —
      asserted against a **stubbed** driver observation, since no launch driver reports one and
      `driver_observation` is reserved (`STO-47`), and the test MUST say which it used — moving
      an account **out of** `terminated` is `409` `state`, and a customer-authenticated request is
      `404`. Assert the event is emitted with principal, account, before, after and reason. **Until
      today `SEC-46`'s three states had no verb and no column at all**, so `CNF-188` and
      `CNF-243` each fault-injected a transition nothing could perform — as did `CNF-114`, before it
      was merged into `CNF-188` as the duplicate it was. (`API-63`, `WIR-50`,
      `STO-47`, `SEC-46`, `LDG-32`, `API-62`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      permitted List offers in the pre-entry barrier and added the account-read
      refusal and post-listing termination cases.*

      *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): re-keyed the dispatch barriers to step 8 and the all-channel column; `ADR-0042`.*

- [ ] **CNF-279** — **An install that wrote nothing and left nothing in rescue is not a mystery.**
      Drive an install against a
      machine whose pinned host key does not match: `RSC-3` aborts **before connecting**, the
      write-started marker is unset, the rescue exit closes the session cleanly, and the
      operation settles **`failed`** — not
      `needs_reconciliation`, and not an operator's problem. **Then the same abort with the rescue
      exit failing: `needs_reconciliation`**, because the machine may be sitting in rescue with a
      temporary credential registered (`PRV-22`), and an untouched disk is not the same fact. Both
      halves, or the item passes an implementation that reads only one marker. `OPS-40`'s claim-time
      URL gate, which fires before rescue is entered at all, is `failed`.
      Then set the write marker — mismatch the digest mid-stream on the raw-disk path (`RSC-29`) — and
      assert `needs_reconciliation`, that `applied` and `not_applied` are both offered where
      `observed`/`absent` are not, that `not_applied` is **refused** `409` `state` while the marker
      is set, and that both are refused on a create. **Then the same verb on a `delete_machine`
      whose provider call was dispatched and whose response was lost — and table-drive the same
      assertion across **every** dispatch-marked row of `OPS-45`'s table**: `provider_native` install,
      `provider_catalogue` install, power, reverse DNS, delete and release attachment (*the last added
      2026-09-16; the row had five names for a six-member row*). The marker is set on all of them and
      `not_applied` is `200`, not `409` — there the marker records a dispatch, not a written disk
      (`OPS-45`), and the operator has read the provider. **The markers are per operation and
      nothing clears them** (`OPS-45`): a `retry` (`API-64`) enqueues a fresh attempt whose markers
      start unset, and the resolved attempt's markers are unchanged afterwards. *Added 2026-09-04: the refusal was unscoped, so `not_applied` was rejected on every kind
      whose marker is set at dispatch, which is every such operation that ever reaches an operator —
      and this item asserted only the raw-disk half, where the refusal is right. Naming two of the
      five would pass an implementation that special-cased them.* Assert the marker survives the payload purge.
      **The failure this catches is the differentiator's own safety abort resolving only as
      `abandoned`**, which is what happened when three create-shaped verbs were the only ones there
      were. (`OPS-45`, `OPS-11`, `OPS-31`, `WIR-35`, `RSC-3`)
- [ ] **CNF-300** — **A `failed` install says what it did to the disk, and the state never carries
      it** (added 2026-09-15, `pv-x8r`). Drive a `rootfs_via_rescue` install whose installer starts
      and then rejects the layout, with the rescue exit succeeding and the engine reporting
      `invalid_request`: assert the operation settles `failed`, `terminal: true`, `retryable` is
      what `DOM-17` gives that kind, and the error carries `details.disk_effect:
      "destructive_boundary_crossed"`. Then `CNF-279`'s pinned-key abort: `failed` with
      `disk_effect: "none"`. Then a `provider_native` rebuild the provider rejects `not_found`
      before acting: `failed` with `disk_effect: "none"`. Then `CNF-279`'s failed rescue exit: `needs_reconciliation`,
      `retryable: false`, `disk_effect: "none"` (it aborted before writing) and `rescue_exit:
      "unknown"`; and an ambiguous `provider_native` dispatch: `disk_effect: "unknown"`,
      `rescue_exit: "none"` (*corrected 2026-09-16; the first draft paired the abort with
      `destructive_boundary_crossed`*). Assert every install error carries
      the key, and that the two `failed` rescue installs differ on nothing but it — or the item
      passes an implementation whose callers cannot tell an untouched disk from a partitioned one.
      (`OPS-3`, `OPS-11`, `OPS-45`, `API-51`, `WIR-9a`)
- [ ] **CNF-301** — **`on_failure` is gone from both rescue-entering bodies** (added 2026-09-15,
      `RSC-18`). An install or rescue-inventory body carrying it is rejected `invalid_request`
      naming the field (`WIR-2`, `WIR-20`, `WIR-40`). A `rootfs_via_rescue` install whose digest
      mismatches before the installer runs exits rescue and settles `failed` with `disk_effect:
      "none"` and `rescue_exit: "clean"`; the same with the exit failing is `needs_reconciliation`
      with `rescue_exit: "unknown"`, the address and port, and a key file named by the operation id.
      Every install and rescue-inventory error carries `rescue_exit`. (`RSC-18`, `RSC-19`, `RSC-25`,
      `OPS-11`, `OPS-45`, `WIR-9a`)
- [ ] **CNF-302** — **`rescue_exit: "none"` is a fact, and the column is written before the session,
      not after the exit** (added 2026-09-16). Drive an install refused before begin rescue —
      `OPS-40`'s claim-time URL gate, or a `rescue_ssh` capability refusal (`DOM-10`) — and assert
      `failed`, `rescue_exit: "none"`, no `rescue_address`, and `rescue_exited_cleanly` **null** in
      the row and in `request_summary`. Then kill the engine after the pre-dispatch write commits
      and before the begin-rescue dispatch (*step added 2026-09-20, `pv-v1f`*): no begin-rescue call
      reaches the provider, `OPS-15` moves the operation to `needs_reconciliation`, the column is
      **false** over a machine that was never rebooted into rescue, the error carries
      `rescue_exit: "unknown"` with the `rescue_address` and `rescue_port` that `OPS-15`'s pass
      renders from the machine row (`RSC-19`), and no key file exists. Then kill the engine between
      the begin-rescue dispatch and the end-rescue call: `OPS-15` moves the operation to
      `needs_reconciliation`, the error carries `rescue_exit: "unknown"` with `rescue_address` and
      `rescue_port`, the column is **false**, and no key file exists (`RSC-19`: a crash persists
      nothing, and `unknown` never implies a file). Then `CNF-301`'s clean exit: **true**. Then
      repeat the pre-dispatch write after a simulated lost reply and assert it affects one row and
      changes nothing (`ADR-0022`, `STO-3`). Then restore from a backup taken before the dispatch
      and assert the quarantined row renders both keys `unknown` whatever the restored columns hold
      (`WIR-9a`). Three distinct column values, or the item passes an implementation that writes the
      marker only at the exit — which renders a crashed session as `none`, the one lie the column
      exists to prevent. The pre-dispatch kill is the step that separates the required write from
      one made at the dispatch instead: `OPS-45` states "false, written before begin rescue … is
      dispatched", and an implementation that waits for the dispatch renders that row `none`.
      (`OPS-45`, `OPS-15`, `RSC-19`, `WIR-9a`, `STO-50`, `STO-54`)
- [ ] **CNF-303** — **The sweep deletes every eligible tagged key still registered.**
      *Amended 2026-10-12 (`ADR-0040`, Q24/Q26).* Kill the
      engine after registering a tagged caller key for an accepted create and a tagged rescue key; the
      sweep retains each while its operation is `needs_reconciliation`, `queued` or `running`. After
      successful settlement, keep the create's machine in `provisioning`; let retention remove its
      settled operation row and assert the sweep retains every key that operation tagged, including
      distinct caller and Robot correlator keys. Read the guard through retained
      `machines.correlator_value`: operation UUID for Cloud and DigitalOcean, per-order correlator-key
      fingerprint for Robot. Once a later observation clears `provisioning`, assert the sweep deletes
      every surviving eligible registration with the row still absent. Before that sweep, retry
      a create with the same caller fingerprint: Cloud and Robot refuse the duplicate before acceptance,
      with no order request or charge. The successful create's driver makes no prompt deletion. On a pre-acceptance failure, delete
      only a key successfully registered by that operation; a failed owned deletion reports its
      identifier in begin-rescue error details and the sweep subsequently removes it. Return Robot `409
      KEY_ALREADY_EXISTS`, and separately lose the registration reply: in both cases assert the driver
      neither deletes by fingerprint nor sends an order, since it cannot establish registration
      ownership. In the lost-reply case, the provider has registered and tagged the key; settle the
      operation without an order while retaining its row. A same-key create is refused before an
      order while that registration survives; once eligible, the sweep deletes the retained key.
      Also remove a tagged orphan whose operation row is absent and which produced no recorded machine.
      For an accepted rescue activation followed by reboot failure, keep the operation
      unresolved and its key registered while begin rescue attempts deactivation; exercise successful
      and failed deactivation and its error details. After eligibility, the sweep removes the retained
      key. Verify operation-id tags, and keep provider-side public registrations distinct from persisted
      recovery private keys. These are implementation obligations; Robot reproduced a live duplicate refusal on 2026-10-12 (`docs/research/panels-2026-10/r45/live-session2.txt`), while Cloud has not.
      (`PRV-9`, `PRV-18`, `PRV-21`, `OPS-32`, `DEF-6`)
- [ ] **CNF-251** — **The credential boundary is a module edge, not a comment.** `api` does not depend
      on `providers` or `rescue`, depends on `engine` only through a trait whose signatures mention
      no credential type, and `engine` does not depend on `api`. **AMENDED 2026-09-02 — the money
      edge is asserted too**: `ledger` depends on `core` and `store` and nothing else, both `api`
      and `engine` depend on it, and `OPS-27`'s terminal write executes **in a worker** — one
      transaction carrying the machine row, the setup-fee debit and the commitment decrement,
      proved by killing the process between them and finding neither. **That transaction is
      `store`'s** (2026-09-08, `OVR-9`): `store` is the only module that opens one, `ledger`'s and
      `engine`'s write-side functions take it as a parameter, and the trait between `api` and
      `engine` may name the transaction type and still no credential type — asserted on the
      signatures. A build where `ledger` can name a driver, where any module but `store` opens a
      transaction, or where the credential-owning type becomes reachable from `api` or `ledger`,
      fails to compile.
      **And every component in `OVR-17`'s table lives in the module named there** — asserted against
      the dependency graph, since a sweep in the wrong module is a credential or a rail secret in
      the wrong module. (`OVR-9`, `OVR-10a`, `OVR-17`, `OPS-27`, `ADR-0001`)
- [ ] **CNF-252** — **Rescue entries and power cycles are capped.** A principal that sets every
      acknowledgement flag on every request still cannot exceed its rescue-entry or power-cycle
      ceiling; the rescue-entry ceiling counts the inventory pass and rescue-entering installs
      together. Drive it with a loop that acknowledges everything. (`SEC-39`, `RSC-38`)
- [ ] **CNF-253** — **The operator principal is capped and observed.** An operator principal exceeding
      its stated retry, resolution, suspension, re-assignment **or provider-account
      status-recording** ceiling is refused; the override
      path works and is itself recorded; and every operator verb emits a monitorable event naming
      principal, target and reason. The failure this catches is a looping operator agent buying
      duplicate servers or attaching a machine to the wrong tenant — strictly more power than any
      customer holds, previously uncapped. **AMENDED 2026-09-03 — the fifth ceiling was missing.**
      `SEC-39` added status recordings on 2026-09-02 and named the reason: confirming a termination
      releases every affected tenant's commitments (`API-63`, `SEC-46`), which is the largest single
      money movement any operator verb performs — so the one ceiling this item omitted guards more
      money than the four it tested. *A closed list extended in the requirement and not in the item
      that tests it is this set's most-repeated defect; here it left the biggest member untested.*
      **AMENDED 2026-09-04 — assert the operator principal traverses the write pipeline at all.**
      Drive **every** operator-only verb (`WIR-34`'s list) end to end with an operator credential and
      assert none is rejected for **the principal's own** tenant state at `API-7` step 2 or 5b — an
      operator has no tenant to be pending or suspended. **Then assert the steps still run**: every
      operator write still takes its `Idempotency-Key` through steps 3 and 5a and its ceiling at 5c.
      *Until `ADR-0020` withdrew adopt, this item also asserted the one converse — an `adopt`
      against a suspended target tenant rejected at 5b — and it returns with the verb.* **And
      assert no operator verb is refused on its target's state**: `WIR-42`'s attribution to a
      **`pending`** target is admitted, `retry`
      against a suspended tenant's episode is admitted (`CNF-272`), and every abuse-case verb,
      restriction recording and deadline revision against a **suspended** target is admitted — *a
      repair of 2026-09-04 read "wherever a tenant is named" and refused all of those.* *Read
      literally, the pre-amendment pipeline refused the entire operator surface except the four
      verbs its carve-out named; a first repair then exempted operators from 5b outright.*
      (`SEC-39`, `SEC-32`, `API-62`, `API-63`, `API-7`, `API-58`, `API-64`)
- [ ] **CNF-254** — **The credential-holding process cannot move the float.** Its Lightning credential
      permits exactly `SEC-48`'s six operations — create, look up, list, subscribe, **cancel an
      unsettled invoice**, and **read the channel and on-chain wallet balances** — and nothing else:
      attempting a payment, a keysend, an on-chain send, a channel open or close, an arbitrary
      message or PSBT signature, a peer addition or a configuration change each fail. Both halves
      are required: **a build where the cancel or the balance reads fail cannot execute `LDG-20`'s
      halt or `LDG-53`'s solvency check**, which is the failure the withdrawn four-verb scope
      guaranteed. Asserted by attempting them, not by reading the
      credential's configuration — `CNF-132`'s rule that reachability is the test, not visibility.
      (`SEC-48`, `LDG-20`, `LDG-53`, `ADR-0001`)
- [ ] **CNF-255** — **The stated ceiling covers both pots and the sweep destination is pinned.**
      Channel balance plus the node's on-chain wallet is what the ceiling measures; a sweep whose
      outputs are not the pinned cold destination is rejected by the signer; and the destination
      cannot be changed by any runtime input. `CNF-135` tests the last clause for the sweep
      destination — this adds the wallet to the arithmetic `ADR-0009` is sold on. (`SEC-49`,
      `SEC-50`, `ADR-0009`)
- [ ] **CNF-256** — **A signup slot costs a held connection.** `POST /v1/enrol` without a valid,
      unexpired, unused token is refused; a token is obtained only from `POST /v1/enrol/token`,
      which answers after the stated delay; a token is single-use; and issuing one writes nothing to
      the store. **A token request abandoned before the delay elapses leaves nothing collectable
      afterwards** — that is what keeps the cost a held connection rather than a free request. Then
      the test that matters: a caller cannot hold more concurrent token requests than the proxy's
      stated per-source limit, and no caller address is persisted anywhere while enforcing it. **At
      the global ceiling, enrolment sheds with `rate_limited` and a `retry_after_ms` rather than
      failing bare** (`API-41`). (`API-33`, `WIR-49`, `WIR-12`,
      `API-36`, `API-41`, `ADR-0005`)
- [ ] **CNF-241** — **A create is refused rather than bought at a price nobody authorized.** With the
      offer's provider price raised between accept and claim so the open commitment no longer covers
      `PRV-13b`'s reserve, and with the offer still sellable, the worker fails the operation
      deterministically **with no provider mutation and no ordering request**, `conflict` with
      `details.reason: "price_moved"`, and the error names the shortfall. With the offer still
      sellable and the price unchanged or lower, it proceeds. **With the offer still sellable, the provider's
      price unchanged and the satoshi rate moved — in either direction — it proceeds**: that is the
      case a build comparing satoshi reserves refuses, and under a falling market it refused every
      resubmission (added 2026-09-05). **Restart the process between API acceptance and claim and
      assert the gate still runs**, from the attempt entry's recorded native price — a build that
      keeps it in memory cannot compare anything after a restart.

      **Sale re-test at claim.** Run cases (a) and (b), the order-of-checks case and the control
      below, in every variant each names, on a `correlator: per_order_key` ordering channel
      (`PRV-44`: "each with `correlator: operation_id | per_order_key | none`"). A per-order key
      upload is then on the order path (`PRV-32`: "`PRV-9` already requires the driver to
      register a temporary key per order"), so the no-key-upload assertion can fail.
      Admit a create at the API and leave it `queued` and unclaimed.
      With the provider's price unchanged, change the terms before claim (`OPS-5`):

      - (a) Re-declare the descriptor's `cancellation_bound` later than provider-local today
        across a restart: restart the process with that descriptor while the create is still
        `queued` and unclaimed.
      - (b) With the descriptor's `traffic_bound` for the named offer explicit `null`
        (`PRV-44`: "or explicit `null` where no bound is declared"), the offer reports
        `traffic_bound: unlimited` at API acceptance. Before claim (`OPS-5`), change the
        offer-reported value to an allowance, once without a restart and once across a restart
        while the create is still `queued` and unclaimed. Leave the descriptor unchanged in
        both variants.

      In each case assert the operation settles `failed`, with `invalid_request`,
      `details.reason: "offer_not_sellable"`, and `retryable: false` on both the error and the
      operation view. Its error obeys `WIR-9`'s "exactly
      `kind`/`message`/`retryable`/`details` and nothing else" inner-object shape, embedded under
      `WIR-10b`, with no `details.refusals` or `details.not_checked` and no cap or balance result
      or amount derived from the offer's price. Assert no provider mutation: no per-order key
      upload and no order request; the List offers read is permitted. The commitment is released
      in full, with no setup-fee or first-unit debit. These cases catch a build re-testing the
      `request_summary` snapshot, which passes the old terms and orders in (a) and (b), and an
      admission-only build, which also orders. The no-key-upload assertion catches a build that
      uploads a key before the re-test.

      **Order of checks.** In another create admitted and left `queued` and unclaimed, raise
      the provider's price past what the reserve covers and make the offer unsellable before
      claim. Assert the failure and release asserted above, with `offer_not_sellable` and not
      `price_moved`; a build comparing price first yields `price_moved` instead. **Control.** A still-sellable offer with unchanged terms
      and an unchanged provider price proceeds to the order, both without and across a restart.
      Each restart in this item occurs while the create is `queued` and unclaimed, between API
      acceptance and claim; it is not a restore or an interruption after claim.
      No commitment grows in any case. (`OPS-43`, `PRV-13b`, `PRV-31`, `PRV-40`, `PRV-44`,
      `PRV-32`, `LDG-39`, `LDG-32`, `WIR-9`, `WIR-9a`, `WIR-10b`, `OPS-11`, `OPS-5`, `ADR-0011`,
      `LDG-2`)

      *Amended 2026-10-16 (`pv-hsm`; panel r54, `docs/research/panels-2026-10/r54/`): added
      claim-time sale-re-test failures, ordering and control cases, including queued restarts,
      run on a `per_order_key` channel; the price case now bars a provider mutation rather than
      any provider call, because `OPS-43`'s step 4, "Obtain the current driver List offers
      result", reads the provider.*
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      updated the List offers step reference to the claim order.*

- [ ] **CNF-242** — **A solvency halt stops what it can and says so about what it cannot.** Under a
      failing check: minting is refused `halted`; unsettled Lightning invoices on unexpired deposits
      are cancelled and a payment attempted against one fails back with the payer's funds intact; an
      on-chain payment arriving at an already-issued address is still **credited**, not held; and the
      deposit read reports the halt with `gate: "solvency"` and `lightning.cancelled: true`
      before a caller pays. Set both expiries after this check and assert `expired: false`,
      preserving the invoice and existing credit fields. Before the halt assert `gate: null`
      and `lightning.cancelled: false` on that same live, payable invoice; after the halt clears,
      assert `gate: null` and `lightning.cancelled: true`. On an independent uncancelled deposit,
      let expiry pass and assert `expired: true` and `lightning.cancelled: false`. (`LDG-20`,
      `LDG-55`, `LDG-47`, `LDG-51`, `WIR-15`)
- [ ] **CNF-243** — **A tenant is not stranded on a dead provider account.** After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and a create
      against it succeeds. Every use of the verb emits a monitorable event naming principal, tenant,
      before and after, and reason. A customer token calling the route gets `404`. (`API-62`,
      `WIR-48`, `SEC-46`, `STO-36`)
- [ ] **CNF-244** — **Suspension is effective when the call returns.** A write issued by the tenant
      immediately after `POST .../suspend` returns `202` — and before any worker has claimed the
      parent — is rejected `suspended`. Asserted with the worker pool stopped, which is the state the
      withdrawn wording left permissive. (`API-58`, `API-7`, `WIR-39`)
- [ ] **CNF-245** — **The account sweep has a budget.** It paginates the provider listing rather than
      assuming one response, yields on `rate_limited` instead of retrying into it, does not delay
      caller-initiated work, and reads by `(provider_account, external_id)` against the index
      `STO-17`'s constraint supplies. An imported image whose operation has settled is **deleted** by
      the same sweep, while an unrecorded machine is only reported. (`OPS-32`, `STO-17`, `ADR-0013`)
- [ ] **CNF-246** — **The balance poll does not grow with the fleet.** `GET /v1/balance` returns the
      totals and `earliest_runway_until` with no per-commitment array; `?commitments=true` returns it
      cursor-paginated, and on the full listing `committed_sats` equals the sum of `reserved_sats`.
      Asserted against a tenant with more machines than one page holds. (`WIR-16`, `WIR-32`,
      `API-49`, `LDG-9`)
- [ ] **CNF-247** — **A tenant identifier is minted, unique, and never reused.** Identifiers are
      server-generated with stated entropy; a caller cannot supply or influence one; and no
      identifier is ever issued twice, including after `API-34` reaps the tenant that held it.
      Asserted against the generator, not by sampling. The failure it prevents is a new caller
      inheriting a reaped tenant's balance and deposits, which survive by identifier alone.
      (`DOM-1`, `STO-26`, `STO-29`, `API-34`)
- [ ] **CNF-248** — **Every mandated `409` carries a defined reason.** Drive each member of
      `WIR-9a`'s `conflict` union — including `signup_window_closed`, `deposit_already_attributed`
      and `cancellation_committed` — and assert the reason string is present and from the closed set.
      A `409` with no reason, or one outside the union, fails. (`WIR-9a`, `API-34`, `WIR-42`,
      `OPS-42`)
- [ ] **CNF-249** — **`?state=` on the case collection is honoured, and a bad value is refused.**
      `open`, `closed` and `all` each return the right set; the default is `open`; and an
      unrecognised value is `invalid_request` rather than ignored. The last clause is the one that
      matters: `WIR-2` ignores unknown query parameters, so a silently-ignored `state` answers the
      wrong question with a `200`. (`WIR-43`, `DOM-24`, `WIR-2`)
- [ ] **CNF-250** — **`network_restriction.source` and `observed_at` are null exactly when
      `status` is `unknown`**, and `system_reason` parses against a closed enum. A freshly created
      machine, a clear provider reading without an operator record, and an operator-only record
      after withdrawal each render `{"status": "unknown", "source": null, "observed_at": null}`;
      a strict client parsing
      `system_reason` against `WIR-10a`'s set accepts every value the system emits. (`PRV-35`,
      `WIR-10a`, `WIR-47`). *Amended 2026-10-10 (`ADR-0038`, Q15).*
- [ ] **CNF-237** — **A delete is not resolved as failed while the provider is still catching up.**
      With a provider whose resource read lags its write, an ambiguous delete resolves correctly:
      resolution takes no read before the effective visibility window elapses, a pre-mutation reading
      inside the window leaves the operation pending rather than concluding, a post-mutation reading
      is never reverted by a later contrary read, and a pre-mutation reading beyond the window
      resolves *not applied*. Assert with an injected read lag; a sample exceeding the declared
      window widens it and does **not** authorize a replay. (`PRV-36`, `OPS-33`, `OPS-12`)
- [ ] **CNF-238** — **A goal-state rejection is a success.** A delete against an already-deleted
      resource, where the provider answers 4xx meaning "already in the target state", classifies
      `succeeded` and its commitment closes (`LDG-32`) — **once every billable attachment has
      release evidence**, since `LDG-32` says "keep the commitment open while any billable
      attachment's `released_at` is null"; with a billable attachment surviving, `CNF-187`
      governs and the commitment stays open
      (*qualifier added 2026-09-12, `F50`; until then the two items demanded opposite states, both
      BLOCKING*). Asserted against the driver's recorded code
      mapping, not its message text. The failure this catches is a customer's satoshis reserved
      forever against a resource that is gone. (`OPS-11`, `PRV-5`, `LDG-32`)
- [ ] **CNF-239** — **A machine funded a moment before its cancellation is not destroyed, and a
      machine already fenced cannot be funded.** Drive both orderings against one machine: an
      `extend-runway` committing before the worker's fence write leaves the machine alive with the
      worker making no provider call; a fence written first refuses the extension with `conflict`
      and **moves no satoshis**. Neither ordering may both take the payment and destroy the disk.
      **AMENDED 2026-09-02 — drive the third interleaving, which is the one that used to win.**
      Commit the extension **after** the worker's funding read and **before** its fence write: the
      machine must survive, which it does only if `OPS-41`'s read and `OPS-42`'s fence write are one
      serialized transaction. An implementation that reads, then extends, then fences on a still-null
      column passes the two orderings above and destroys a paid-for machine on this one.
      (`OPS-42`, `OPS-41`, `LDG-62`, `LDG-35`, `LDG-69`)
- [ ] **CNF-240** — **Attribution across two tenants deadlocks under no interleaving.** Two concurrent
      `WIR-42` attributions naming each other's tenants both complete, in one transaction each, with
      the primitives acquired in ascending tenant order; and an attribution whose source tenant row
      was already reaped by `API-34` succeeds, proving the primitive does not require a live tenant
      row. (`LDG-35`, `WIR-42`, `STO-26`, `API-34`)
- [ ] **CNF-236** — **The meter's state is checked by range, not by reconstruction, and the checks
      are scoped to one subject.** Assert all four: (a) `0 ≤ r < 1` holds after an arbitrary
      sequence of increments, corrections and clamps; (b) a seeded **out-of-range** `r` is caught
      without consulting any other table; (c) a seeded **in-range but wrong** `r` changes what the
      subject is ever charged by **at most one satoshi** — the bound, asserted, not assumed; (d) the
      high-water mark is checked **one-sidedly** against the greatest increment end in any
      `usage_debit` idempotency key, so a mark *ahead* of every entry passes — an increment can post
      no entry at all, clamped to nothing or rounded to nothing — while a mark *behind* one fails.
      Assert the failure is **quarantine of that subject**: its usage debits, commitment decrements
      and exhaustion decisions stop, cancellation and deletion still work, and no other tenant is
      affected. *WITHDRAWN FORM, and it is the reason this item is worth reading:* it required "an
      audit recomputation of **every** column of `meter_totals` … from `ledger_entries` and
      `operator_deficiencies`", including replaying each increment at the rate on its own entry.
      **No implementation could have passed it.** A `usage_debit` carries no seconds and no
      increment boundary, and its amount is a rounded difference of two cumulative figures, so the
      rational was never recoverable. It read as the most rigorous item in the file for a day.
      (`LDG-72`, `STO-45`, `LDG-38`, `LDG-8`)
      **Execute a quarantined delete:** seed at 0, tick at 7 at 1/5 sat/s (debit 2, mark 7,
      `r = 3/5`), then inject `r = 2` and run the required check to quarantine the subject.
      Delete at 14 with no surviving attachment. Assert deletion and the gone write complete,
      no usage debit or commitment decrement posts, and the exit leaves mark 7 and `r = 2`
      untouched as alert evidence. Commitment release is still permitted; it is not a usage
      decrement. Repeat with a mark behind the existing key instead of an invalid credit.
      No new deficiency cause or later catch-up debit appears. Repeat during a rate outage with
      no existing outage row: quarantine still posts nothing and creates no row. Repeat with an
      existing open subject `rate_outage` row, opened by a posting while the outage is live before
      quarantine: deletion and the gone write complete, and `absorbed_until` receives the stop
      boundary. Mark, `r`, usage entries and usage decrements remain untouched; closing the
      deficiency row does not repair the quarantined meter. Run both quarantine fixtures above.
      (`LDG-72`, `LDG-38`, `LDG-64`, `STO-37`)
- [ ] **CNF-216** — The billing period boundary is `00:00:00Z` on the first of the month for every
      tenant and every machine, and a metered increment straddling it is apportioned across the
      two periods rather than falling wholly into either — **the increment closes at the boundary,
      the old period's `meter_totals` row posts its part with its own credit, and the new period's
      row starts at `r = 0`**, so the two rows never read each other's `r`. *Amended 2026-10-02:
      "never read each other" was too broad; the mark is `LDG-72`'s "the greatest `increment end`
      among that subject's rows".* The same test covers a
      deficiency's `absorbed_from`/`absorbed_until` window straddling the boundary. *The mechanism
      clause was added 2026-09-05; this item asserted apportioning while `LDG-38` split only at a
      rate change, so a straddling increment had two credits and no rule.* (`LDG-68`, `LDG-38`,
      `STO-37`)
- [ ] **CNF-217** — No transaction holding `LDG-35`'s serialization primitive acquires a machine
      (`OPS-8`), waits on a child operation, or makes a provider call — asserted at the storage
      layer over the whole suite's traffic, in the manner of `CNF-157`, not by code review. **The
      converse is NOT asserted, and asserting it would fail a conforming build**: `OPS-41`'s
      funding re-check is a worker that already holds the machine entering the primitive for a
      bounded read and the fence write, which is the one direction `LDG-69` permits and the thing
      `OPS-42`'s fence is built on. *Noted 2026-09-02, when that path became the first genuine
      nesting in the set.* (`LDG-69`, `LDG-35`, `OPS-8`, `OPS-41`, `OPS-42`)
- [ ] **CNF-218** — A machine funded by `extend-runway` **after** its cleanup cancellation was
      enqueued is **not** deleted: the worker re-reads funding while holding the machine
      (`OPS-8`), makes no provider call, settles `succeeded`, and the episode closes (`OPS-48`).
      **Afterwards
      `machines.destroy_committed` is null, the stored `runway_until` is the re-derived future date,
      a second `extend-runway` succeeds** (*amended 2026-10-04, `pv-gip.39`: remove deficiency
      resolution bookkeeping; survival and repeated extension remain covered*) — a build that leaves the fence set passes the first
      sentence and refuses every later extension forever, and one that leaves the stored date in
      the past is re-routed by the next sweep and loops. **Then the same with a `rate_outage_bound`
      cancellation** whose rate returns between enqueue and claim: the worker re-derives at the
      returned rate and aborts. **And the same with restoration committing *after* the
      worker's claim snapshot and before its fence transaction begins**: that transaction reads a
      rate, so the worker re-derives at the rate in force, makes no conditional write on the
      machine's `rate_outage` record, and makes no provider call. **And the same past the deadline,
      with restoration committing after the fence transaction has read no rate and before its
      conditional write**: the write affects no row, the worker re-derives at the rate now in
      force, and it still makes no provider call — a build that
      establishes "no rate" by a read passes the cases before this one and deletes the fleet in
      it. **Then the same with the commitment unchanged and only the price
      cut** between enqueue and claim: the re-derived date is in the future, the worker aborts,
      makes no provider call, and clears the fence — a worker that aborts only on a grown
      commitment passes every other case here and destroys a machine a price cut rescued.
      **With no rate, a funding cancellation waits; it is not cancelled and not settled**
      (rewritten 2026-10-02, `ADR-0029`; `OPS-41`'s order is what each case exercises). *A fresh
      outage*: with a
      live machine outside a restore incident whose stored date has passed, its episode open and
      its cancellation queued — an
      `exhausted` attempt enqueued before the rate was lost, and separately `OPS-36`'s late-attach
      cleanup, enqueued by its attach transaction while a rate existed — lose the rate before the
      claim, and before the meter has
      opened any `rate_outage` record for the machine, and claim: assert the attempt returns to
      `queued` after a short delay, `machines.destroy_committed` stays null, no provider call is
      made, the operation has not settled and the episode is still open — a build that reads the
      absent record as a stopped meter settles it `succeeded` here and the sweep queues it again.
      *The same for an attempt claimed while a rate existed* that loses the rate before its fence
      transaction: it defers, since the decision is the transaction's and not the claim's. *The rate
      returning before the deadline*: at the next claim the worker re-derives, and aborts or cancels
      on the ordinary predicate. *A suspension joining the deferred attempt* (`API-58`): within one
      short delay the next claim proceeds to the provider call with still no rate. *The machine
      recorded gone mid-outage*: the next claim settles `succeeded` with no mutation required,
      makes no provider call and writes no `runway_until`, the episode already closed by the
      gone-write. *The deadline passing with still no
      rate*: the next claim writes the fence and cancels — where the machine has an open
      `rate_outage` record and where it has none alike. *The maximum tolerated outage lowered
      mid-outage below the time already run* (`OVR-19`): the deferred attempt's first claim after
      the restart that loads it proceeds.
      **Restore grace across outages** (`OPS-41`, `STO-56`; amended 2026-10-02, `ADR-0029`).
      Keep the restore record open throughout the following traces, including the refused close
      attempts below; successful closure is exercised in `CNF-295`. Unless a trace specifies
      otherwise, use an active tenant, an unfenced live machine with an open funding episode,
      and a queued cancellation; set a bound
      later than each tested return except in the bound cases below.
      For every extension assertion, first establish a rate, sufficient available balance and
      all other admission conditions (`LDG-40`, `LDG-62`); choose requested runway beyond the
      tested re-claim. Write step (3)'s mark and original end
      once. Before that mark, a null end still defers by a short delay with no fence or provider
      call. Exercise the following histories using `STO-49`'s currency rows:
      *No outage*: at a claim inside the grace `available_at` is the original end; an extension
      is admitted, and re-claim at that end settles `funded`, clears the fence and leaves the
      machine alive (`OPS-48`).
      *An outage covering the entire original grace*, including one caused by restoring away
      rate-observation rows: before the original end claims defer to that end; afterwards, with
      no rate and before the bound, the ordered worker uses step 4's short delay, never an
      unknowable return instant. Admit an observation that leaves the window thin and assert it
      does not start spending grace. At the qualifying return `R`, claim and run the fence
      transaction: with the re-derived date still past, assert the ordinary short delay in
      `available_at`, no fence or provider call, and the attempt queued with its episode open.
      Let `I` be the re-derivation interval. At each eligible claim before `I` rate-present time
      has accumulated, an unfunded attempt short-defers again; it does not park until `R + I`.
      Admit an eligible extension during this remaining grace, with enough runway beyond the
      next claim. At that next eligible claim, still before the interval completes, assert
      the existing `funded` no-mutation outcome: `succeeded`, the re-derived future date written,
      fence cleared and episode closed, with the machine intact. Repeat with commitment unchanged
      and a price cut making the re-derived date future; it settles at that next eligible claim
      too, without waiting for the grace to finish.
      *An outage after part of the grace*: spend `a < I` with a rate after step (3), then lose
      the rate past the original end; on a qualifying return at `R`, claim and run the fence
      transaction: assert a short delay and only `I - a` rate-present time left. With the rate
      continuously present and no new funding, the first eligible claim at or after `R + (I - a)`
      proceeds, without granting another full interval.
      *Flapping*: spend another `b < I - a` with a rate, lose it again, and claim at the next
      qualifying return `S`: assert a short delay and only `I - a - b` rate-present time left.
      Re-claim after later
      outages and returns and check the sum of all rate-present segments, with none discarded
      or counted twice. With no extension and an unfunded re-check, cancellation can proceed
      once the sum reaches `I`. Prune between the returns and restart: the history and its
      left edge needed to reproduce every result survive while the restore record is open
      (`STO-49`). Repeat for a live machine with no `rate_outage` record. Stop another subject
      in the same currency and write its `absorbed_until` before the currency returns: the
      live machine's grace is unchanged by that subject record.
      *Settings changed during the incident* (*amended 2026-10-04, `pv-gip.28`*): use a
      1h staleness bound, 1h re-derivation interval, 24h window and quorum three. Retain accepted
      observations at 08:00, 09:00 and 10:00, each from three independent live sources at the
      same price, with their stamped verdicts/bounds and the left edge needed for replay.
      Step (3) is 11:00, original end 12:00. No observation is accepted before 14:10; the
      10:00 observation expires at 11:00. Load a 6h staleness bound on restart: no return.
      A qualifying pass reads at 14:00 and accepts at 14:10 at the same price
      (*amended 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*). Both relevant windows are
      sufficiently populated, so thinness does not decide the trace. Keep the incident open,
      outage maximum later than the trace, active tenant, live unfenced machine, open funding
      episode and eligible cancellation at 14:15 with no competing operation hold. Leave
      commitment insufficient and admit no extension. At the fence transaction only
      [14:10,14:15) contributes: 300 of 3600 seconds spent, 3300 remaining. Assert ordinary
      short deferral, no fence/provider call and episode still open. No part of [11:00,14:10)
      was usable grace, including the read-to-acceptance interval. With continuous rate presence,
      eligible claims short-defer until 15:10; the first at or after 15:10 may cancel. A further outage pauses the remaining measure.
      Prune and restart before re-claim: retain the stamped left-edge state and each intervening
      return/outage while the restore stays open, even when a later yielding pass moves the
      ordinary retention floor. This tests history replay; the effective-span model does not
      prove replay or retention.
      *Return between claim and fence transaction* (`pv-gip.35`): with no rate at the claim,
      the original end passed, and an unfunded re-derivation, commit a qualifying return before
      the fence transaction. Assert the transaction reads that return and its currency history,
      finds unspent rate-time grace, short-defers the attempt with its episode open, writes no
      fence and makes no provider call; the live machine remains intact. Repeat with a subject
      outage record at the bound and the return committing after the transaction read no rate
      but before its conditional write: zero affected rows reaches the same step-3 deferral.
      *A new outage bound after paused deferral* (`pv-gip.36`): let `d` be the ordinary short
      delay and choose remaining grace greater than `3d`. At `R`, with a rate, an unfunded
      attempt short-defers in step 3. Inspect `available_at = R + d`. Lose the rate before that
      instant and choose the new outage's bound `B` after `R + d` but before the former computed
      paused end. Run the actual queue through eligible claims only; while no rate exists and
      before `B`, assert each short deferral's availability. At the first eligible claim at or
      after `B`, no later than `B + d` with the worker otherwise available, assert step 5 fences
      and calls the provider to cancel, without waiting for that former end. Run this with and
      without a subject `rate_outage` record. The original wall-clock end is already past.
      *A suspension after paused deferral* (`pv-gip.36`): repeat the rate-present deferral at
      `R`, inspect `available_at = R + d`, then suspend the tenant before that instant. Assert
      the fan-out joins the existing episode and creates no replacement attempt. No claim is
      manufactured before availability; at the next eligible claim at `R + d`, step 2 proceeds
      to the fence and cancellation, within one short delay of suspension. Exercise with and
      without a rate at that claim.
      *Close refused between the bound and the next eligible claim* (`pv-gip.37`; added
      2026-10-03): let `d` be the ordinary short delay. After the original wall-clock end,
      Alice's live unfenced machine has a queued funding cancellation, an active tenant and
      unspent rate-time grace. With no rate, claim at `Q` before the outage bound `B`; step 4
      short-defers with `available_at = Q + d`. Choose `Q < B < Q + d`, complete all other
      incident obligations, and attempt close after `B` but before `Q + d`: assert refusal
      under `STO-56` and leave the record open. Return the rate before `Q + d`, leaving
      accumulated grace unspent at the next eligible claim and the re-derived date still past.
      With the worker available and no competing hold, claim at `Q + d`: assert step 3
      re-derives first, short-defers, writes no new fence, makes no provider call, and keeps
      the attempt queued and episode open. Do not manufacture a claim before `available_at`
      or close the record to reproduce the defect. Retain the direct-return and conditional-write
      interleavings above, and their funded re-derivation-first outcomes.
      *New routing after the bound*: begin instead with a live unfenced machine in the outage
      currency and no open episode or queued cancellation. Let the bound pass before its
      cancellation is routed, with all other incident obligations complete and grace unspent;
      assert close is refused even though nothing is queued. Return the rate, keep the stored
      and re-derived dates past, and run the exhaustion sweep before the bound canceller routes
      an attempt. At the new funding attempt's first eligible claim, with the tenant active and
      accumulated grace still unspent, assert the same step-3 short deferral, no fence or
      provider call, and an open episode.
      *No return through disposition*: after the wall-clock end, leave the rate absent and
      grace unspent, with all other incident obligations complete. Include a funded live
      unfenced machine with no queued attempt and a machine with no `rate_outage` record.
      Past the bound, before disposition, assert close is refused. Run the bound canceller
      and actual queue through eligible claims; step 5 processes every machine in the currency
      to recorded gone or fenced. Assert the currency still blocks while any live unfenced
      machine remains. For a bound cancellation whose provider call is refused, assert the
      failed attempt leaves its live machine fenced (`machines.destroy_committed` non-null).
      A failure alone is not the discharge condition. Once every machine qualifies, assert
      this currency ceases to block despite unspent rate time; keep the record open here and
      exercise successful closure and ordinary restart in `CNF-295`.
      *The bound while paused grace is unfinished*: with no rate and the wall-clock end passed,
      a funding-enqueued attempt reaches step 5 and cancels, both with and without an outage
      record. If the deadline falls before the original end, a claim past the deadline still
      returns to `queued` with `available_at = grace_ends_at`, with no fence or provider call;
      at that end, still without a rate, it reaches step 5. *Current suspension*: after the
      wall-clock end a suspended tenant's claim proceeds without waiting for unspent paused
      grace, with and without a rate, even if enqueued for exhaustion. Conversely, historical
      suspension reasons do not bypass paused grace for a resumed tenant. The episode stays
      open on each deferral, and every later eligible claim re-decides from step 1; no deferral settles
      the attempt,
      writes a new fence, clears an inherited fence, or calls the provider. Repeat the rate-return
      cases for an inherited fence: extension remains refused `cancellation_committed`, and
      retry claims observe the applicable grace. `CNF-295` exercises incident closure.
      *The fence and date assertions and the outage case were added 2026-09-05; the outage kind was
      outside `OPS-41` entirely, so a bound reached one second before the rate returned destroyed
      the fleet. `OPS-41`'s note of 2026-10-02 holds the reasoning this item's last case was
      withdrawn with.*
      (`OPS-41`, `OPS-36`, `OPS-8`, `OPS-48`, `STO-49`, `STO-54`, `STO-56`,
      `LDG-62`, `LDG-40`, `LDG-64`, `LDG-65`, `OVR-19`)
- [ ] **CNF-219** — `GET /v1/balance` is answered from the latest entry's `balance_after` and takes
      no write transaction; an audit recomputation of `Σ(ledger entries)` equals it; and a seeded
      mismatch **fails closed** rather than answering from either number. (`LDG-70`, `LDG-9`,
      `CNF-157`)
- [ ] **CNF-220** — The deployment states its worst-case operation hold (`OVR-19`), and
      `wind_down_cost` includes it. Asserted by enqueuing an exposure-reducing cancellation against
      a machine held by a long-running operation and confirming the reserve covered the full wait.
      (`PRV-13b`, `OPS-8`, `OVR-19`)
### The abuse surface (grill session, 2026-08-16)

- [ ] **CNF-222** — **Address resolution answers from history, not from current state.** Machine A
      holds `203.0.113.7` and is deleted; the address is later observed on machine B, owned by a
      different tenant. Resolving `203.0.113.7` at an instant inside A's window returns **A**, and
      at an instant inside B's returns **B**. Asserting only the live case passes against the
      defect. **Run it on a machine created and never refreshed** — that is the ordinary machine,
      and binding the history write to the refresh alone leaves it with none. The operations that
      touched the machine in that window are recoverable alongside it (`SEC-45`), which
      `GET /v1/operations` under `WIR-33`'s override already answers. (`SEC-54`, `STO-41`, `DOM-8`)
- [ ] **CNF-223** — Resolution returns a **candidate set**, and an address never observed at that
      instant returns an empty one rather than a nearest match. An operator acting on a confident
      wrong answer opens a case against an innocent tenant. (`SEC-54`)
- [ ] **CNF-224** — **No part of the notice reaches the customer surface.** With a case open, neither
      the machine view, nor the case collection, nor the case detail, nor any error `details` on
      those paths contains the provider's case reference, its statement link, its own wording, or a
      third party the notice named. Run against **all three** read paths — one projection, three
      renderers, and a rule enforced on some of them is the failure mode. **It does not assert the
      absence of the provider's name**: `provider_account` is already in the machine view
      (`WIR-11`) and `WIR-29` returns the account kind, so a test written that way fails every
      conforming implementation. (`WIR-45`, `API-59`)
- [ ] **CNF-225** — **The deadline has no hands.** A case whose `respond_by` has passed with no
      statement leaves the tenant unsuspended, the machine uncancelled, the balance untouched, and
      the case still accepting statements. (`DOM-25`, `DOM-24`)
- [ ] **CNF-226** — Statements are append-only and unbounded in count while the case is `open`: a
      second and third submission both succeed and both appear in order; submission after `closed`
      is `409` `case_closed`; no endpoint edits or deletes one. (`STO-40`, `WIR-43`)
- [ ] **CNF-227** — **Closing purges raw statement bodies and keeps what was sent.** After close, the
      statement rows survive with their timing, their `body` renders as `null`, and
      `sent_statement` — plus `sent_verbatim` and the statement ids it covered — is still readable
      by the operator. The purge commits in the close transaction, not after it. **And a case left
      open past the configured age purges anyway**, which is the only clock that fires without an
      operator. (`STO-42`, `STO-43`, `WIR-44`)
- [ ] **CNF-231** — A retried statement submission carrying the same `Idempotency-Key` appends **one**
      statement, not two, and returns the same body. Under `STO-40` a duplicate can never be
      deleted, and the caller is an agent with a retry loop. (`WIR-43`, `WIR-24`, `API-8`)
- [ ] **CNF-232** — `GET /v1/address-resolution` returns candidates ordered by `first_seen` with the
      matched window on each, an empty array where nothing matches, and `out_of_horizon: true` for
      an instant older than the deployment can answer for — distinguishable from "it was nobody's".
      (`WIR-46`, `STO-43`)
- [ ] **CNF-228** — **REWRITTEN 2026-08-16 — it tested English.** A restricted machine keeps billing
      and says so *structurally*: positive evidence from either source makes
      `network_restriction.status` read `restricted` on the machine view and in every case rendering,
      including two open cases for the same machine; `usage_debit` postings continue, the commitment decays,
      `runway_until` keeps moving, and `delete` on that machine is accepted. For a whole-server
      lock with no provider signal or operator record, assert unknown/null/null on those views
      while billing, runway and delete retain the same behavior. **No assertion about
      prose.** *Withdrawn clause:* "the case's `consequence` states the drain" — no conformance run
      can execute a judgement about whether a sentence says a thing. (`LDG-71`, `DOM-27`, `DOM-26`,
      `WIR-47`) *Amended 2026-10-10 (`ADR-0038`).*
- [ ] **CNF-233** — `unknown` is never rendered as `none`. Exercise the following traces with
      machine and case reads after every step: operator record → provider flag set → flag clear
      preserves the operator warning and its original time; provider flag set → operator records
      successfully → flag clear → operator withdraws renders provider provenance, then operator
      provenance, then unknown/null/null. Operator record → flag set → operator withdraws leaves
      provider provenance immediately, without a refresh. A whole-machine lock with no provider
      signal and no operator record remains unknown/null/null after a clear read; with an operator
      record it continues to warn. A provider-positive observation wins provenance regardless of
      which observation is newer, and clearing either half preserves the other. Assert the
      provider and operator columns after each write, including after case closure and a gone-write;
      neither implicitly withdraws the record. On Cloud, read `public_net.ipv4.blocked: true`
      with `public_net.ipv6: null`: assert stored `provider_restricted: true` at the read time and
      rendered `restricted/provider_api` at that time, preserving an existing operator record. Then read
      `public_net.ipv4.blocked: false` with `public_net.ipv6: null`: assert stored `false` at the
      new read time, unchanged operator columns, and `restricted/operator_notice` at the operator's original
      recording time; without an operator record, assert unknown/null/null. On Robot, read several
      mapped addresses with one `locked: true`: assert stored `true` at the read time and rendered
      `restricted/provider_api` at that time, preserving an existing operator record. On
      DigitalOcean, read `locked: true` as an action lock: assert it produces no mapped provider
      restriction observation, leaving both provider columns null before any mapped reading;
      render `restricted/operator_notice` with an existing operator record and unknown/null/null
      without one. Submit a withdrawal with `operator_ref` and assert `invalid_request` names it as the first unknown body field, with no column change; the recording body still requires that field. (`PRV-35`, `WIR-47`, `WIR-2`, `STO-39`)
      *Amended 2026-10-10 (`ADR-0038`, Q15).*
- [ ] **CNF-234** — `warned_consequence` has no write path after open, and a deadline revision
      appends: after two extensions the case carries both prior dates with their revision times,
      and `respond_by` reads the latest. (`STO-44`, `WIR-47`)
- [ ] **CNF-229** — An open case blocks nothing else — create, install, extend-runway and delete all
      behave exactly as they do with no case open. (`DOM-26`)
- [ ] **CNF-230** — A case is creatable **only** by an operator, and the statement write mints no
      operation: it returns `200` synchronously and `GET /v1/operations` gains no row. (`API-60`,
      `API-48`, `DOM-23`)

## Surface completeness

- [ ] **CNF-149** — Every endpoint the requirements mandate appears in the surface table, and every
      row in the surface table has a requirement behind it. Run as a diff, both directions —
      enrolment and funding were each mandated and unlisted for a day, and `API-33`'s admission
      token was mandated and unlisted for two reviews, which made **every enrolment**
      unsatisfiable. **AMENDED 2026-09-02 — run the same diff over the closed sets, not only over
      the routes**: `DOM-13`'s strategy/source pairings against `WIR-20`'s union, `WIR-10a`'s enums
      against the values the requirements emit, and `WIR-35`'s two resolution sets against the
      operation kinds that can reach `needs_reconciliation`. **Not `DOM-17` against `WIR-9a`**,
      which is a *minimum*-keys table by its own words — a kind whose `details` are genuinely empty
      conforms, so that diff fails by construction and would be deleted by whoever ran it first. The catalogue-install variant was missing from `WIR-20` while `DOM-13`
      carried the pairing, and three items tested a path no caller could request — the same
      failure as the missing route, one document over. (`API-48`, `DOM-13`, `WIR-20`, `F19`)
- [ ] **CNF-150** — A caller can read its balance, its available figure and its committed satoshis
      without attempting a purchase. **A create rejected with `insufficient_balance` is not an
      acceptable way to answer "can I afford this"**, because an autonomous caller responds to it
      by retrying. (`API-47`, `DOM-20`)
- [ ] **CNF-151** — Exactly the endpoints in `API-48`'s list are synchronous; every other write
      returns `202` with an operation. Asserted against the routing table, so that adding an
      endpoint later cannot quietly extend the exemption. The list's newest member is the one a
      reader will misfile: `POST /v1/episodes/{id}/actions/retry` answers `200` with the episode
      view, and the attempt it enqueues is asynchronous and visible only through
      `current_operation_id` (`API-64`). (`API-48`, `API-1`, `API-64`)

## Completion and pacing

Added 2026-08-12 with `API-49`–`API-54`.

- [ ] **CNF-152** — A simulated caller that obeys every `Retry-After` it receives — across a
      non-terminal list poll, a balance poll and a machines poll at the finest advertised
      cadence — receives no `429` from caller-throughput pacing over a sustained run.
      A separate first-create case closes a provider-shared ordering channel through
      another tenant and asserts a well-paced caller can receive its `rate_limited`
      refusal. **The pacing invariant is the test**, because a fixed rate-limit number
      stops being tested the day the fleet grows. (`API-50`, `PRV-40`)
      *Amended 2026-10-09 (`ADR-0036`): the shared channel is a first-create exception.*
- [ ] **CNF-153** — Every non-terminal operation response carries `Retry-After` and a matching
      `poll_after_ms`, values differ by operation kind and state, and the enrolment poll carries
      no delay-derived value — the one endpoint where the pacing hint is a forbidden oracle.
      (`API-49`, `API-33`)
- [ ] **CNF-154** — An operation in `needs_reconciliation` is delivered with `retryable: false`,
      and the client documentation states that re-issuing under a fresh idempotency key is a
      second purchase. The test is the field; the sentence is checked by reading. (`API-51`)
- [ ] **CNF-155** — A pending tenant that has paid can observe `active` on its enrolment handle
      without attempting a create. A pending tenant that has not paid can reach only `API-43`'s
      allowlist — funding, its own deposit, that handle, and revocation. *The "at or after
      `issuable_at`" qualifier went with `issuable_at` on 2026-09-02 (`API-33`).*
      (`API-52`, `API-43`)
- [ ] **CNF-156** — Two interleaved polls delivered out of order leave the caller holding the
      higher `revision`; the operation's revision strictly increases across every client-visible
      change, verified by killing and restarting the process mid-operation. (`API-53`)
- [ ] **CNF-157** — No `GET` takes a write transaction, asserted at the storage layer over the
      whole test suite's traffic, not by code review. A polling customer must be unable to
      trigger what `DEF-11`'s internal loop triggered. (`API-54`)
- [ ] **CNF-158** — Reading an operation past the retention horizon answers `gone`, not
      `not_found`, and the published observability horizon equals the idempotency horizon.
      (`DOM-21`, `STO-33`)
- [ ] **CNF-159** — Driving a tenant's balance to exhaustion produces a tenant-visible operation
      with `requested_by: system` and reason `exhausted`, holding the machine (`OPS-8`), and capable
      of ending in `needs_reconciliation` like any cancel. The test is that the customer-facing
      history contains the event **before** the machine record shows it gone. (`OPS-39`,
      `LDG-14`)

## The meter and serialization

Added 2026-08-12 closing `F30`'s list of untested requirements from the commitment rewrite.

- [ ] **CNF-160** — Posting the same `(subject, billing period, kind, increment end)` usage debit twice moves the
      balance once, and the debit and its commitment decrement land in one transaction — killing
      the process between them leaves neither. **And a replay that writes no entry moves nothing
      either** (2026-10-02): post an increment that rounds to nothing, replay it, and assert the
      subject's `r`, its high-water mark and its deficiency records are where the first posting
      left them, with no entry added; then the same for an increment that posted an entry and whose
      replay would round to nothing. A build that relies on the idempotency key alone fails both:
      neither replay meets a conflict, and each moves `r`.
      (`LDG-38`, `LDG-31`, `STO-28`, `STO-45`, `LDG-8`)
- [ ] **CNF-304** — **An increment starts at the subject's high-water mark, whatever the meter
      re-observed.** With a subject's mark at 10:00, drive a re-meter that observes 09:00–10:30 —
      a restart that lost its place — and assert the subject is charged for 10:00–10:30 and for
      nothing else, under the key of the increment ending at 10:30, and that the mark is then
      10:30. The wrong builds: one that admits the increment whole because its end is past
      the mark charges 09:00–10:00 a second time, and one that discards it whole because it
      overlaps the mark never charges 10:00–10:30. (`LDG-38`, `LDG-72`, `LDG-8`)
- [ ] **CNF-305** — **The mark is seeded when a subject becomes billable, and the first increment
      starts there.** *Run on an offer whose `billing_unit.seconds` is zero, or on a seed that is
      not the machine's first; the first seed under a non-zero unit is `CNF-318`'s (2026-10-08,
      `ADR-0033`).* A machine recorded billable at Jan 31 23:59:30Z whose first tick is Feb 1
      00:00:30Z is charged thirty seconds under January's `meter_totals` row and key and thirty
      under February's. The wrong builds: one that starts a never-marked subject's first
      increment at the period's start never charges January's thirty seconds, and one that files
      the whole minute under either month charges it against one row's credit. **And a mark more
      than one period back is still the start**: the same machine, billable throughout, whose
      first tick is instead Mar 1 00:00:30Z is charged from Jan 31 23:59:30Z, split at both
      boundaries — thirty seconds under January's row and key, all of February under February's,
      thirty seconds under March's. The wrong build reads the mark from the current period's row
      and, failing that, the period before's: it finds none in either, and does not charge from
      January's mark. Assert the seed itself after the first write that records the machine
      billable, under the deployment's own billable states (`LDG-37`): where it bills from
      creation, that write is the row insert; where it bills from a later state, a nonbillable
      row insert seeds nothing and the first write into a billable state seeds the mark. Test a
      later re-entry into a billable state too. Before any tick, the mark
      is the transition's recorded instant, no ledger entry was written for the seed, and an
      existing row's `r` is unchanged. Use transitions after the latest mark for these cases;
      separately assert that a seed at or before the latest mark changes nothing. A build that
      seeds only at create leaves the old mark on re-entry. For a billable attachment, assert the
      seed in `PRV-45`'s write and its first increment in both cases: an ordinary gone delete
      seeds at the gone observation's instant; a scheduled machine with effective cancellation
      at 10:00 and gone observation and attachment write at 10:05 seeds at 10:00, so the
      attachment's first increment starts at 10:00. Neither seed posts an entry; a new period
      row starts at `r = 0`. A build that uses the attachment write's time in the scheduled case
      leaves 10:00–10:05 uncharged. (`LDG-38`, `STO-45`, `LDG-72`, `LDG-68`, `PRV-45`, `LDG-74`,
      `LDG-37`)
      **Close before re-entry:** configure a deployment-defined nonbillable state, such as
      `unknown`, without changing the billability of `stopped` or treating `failed` as gone.
      Within one period at 1/5 sat/s, seed at 0, tick at 7, record that nonbillable state at 9,
      re-enter billable at 20 and exit at 24. Keep the commitment open across the temporary
      exit. Expect intervals [0,7), [7,9), [20,24), debits 2 then 1 in total (the first exit
      writes no entry), mark 9 and `r = 1/5` at the first exit, seed 20 with that credit
      unchanged, and final mark 24 with `r = 2/5`. No [9,20) seconds are charged; re-entry
      cannot erase the earlier tail. (`LDG-38`, `LDG-37`)
      **Exit and re-entry inside one outage:** outage 12:20–13:00, with the subject already
      billable at 12:20. Post at 12:25 while no rate exists, exit to nonbillable at 12:30,
      re-enter at 12:40, post at 12:45 and exit at 12:50. Keep the commitment open. Assert
      separate native-only rows with absorbed windows [12:20,12:30) and [12:40,12:50), each
      closed with `absorbed_seconds = 600`, and no absorption or billing for [12:30,12:40).
      Competing no-rate postings in either span create
      no duplicate open row. The currency outage start remains 12:20 and the computed deadline
      is unchanged across re-entry with the same stamped history and maximum (amended 2026-10-04,
      `pv-gip.28`). Rate return at
      13:00 does not extend either closed row. (`STO-37`, `LDG-64`, `LDG-38`)
- [ ] **CNF-161** — A machine powered off for a full billing period is billed for it, and a machine
      in `cancellation_scheduled` is billed through its effective date. The meter stopping at
      cancellation *acceptance* is the defect. With seed at 10:00, effective date 10:04,
      gone observation at 10:05, `r = 0`, rate 1/5 sat/s and sufficient authority, expect 48
      sats and mark 10:04. First run with no intervening tick: the gone write posts the 48
      before commitment release. Repeat with a tick that already closed at 10:04: the gone
      write discards its attempt and changes neither meter state nor entries. Neither case
      charges 10:04–10:05, and cancellation acceptance posts no future consumption.
      (`LDG-37`, `DOM-19`, `LDG-38`, `LDG-74`)
- [ ] **CNF-162** — **REWRITTEN.** The setup fee and the prepaid first unit each follow `LDG-39`'s
      table (the unit since 2026-10-08, `ADR-0033`): each debited **at successful settlement after acceptance** (`ADR-0035`, 2026-10-08) as
      its own kind and the commitment decremented in the **same transaction** (kill the process
      between them and neither survives); **released in full** on deterministic rejection and on
      resolved-absent — **except a fee the provider's transaction shows was charged for a matched
      order whose machine is gone, which becomes an `unrecoverable_setup_fee` deficiency — and the
      unit, on its own evidence, an `unrecoverable_first_unit` one — in the
      resolution's own transaction** (2026-09-05; kill the process between them and neither
      survives); **held** through `needs_reconciliation`. Assert `available` never goes
      negative across the whole sequence — that is the bug this item missed by testing only the
      debit. (`LDG-39`, `LDG-31`, `LDG-10`)
- [ ] **CNF-163** — Two concurrent creates against a balance that can fund exactly one result in
      one commitment and one `insufficient_balance` — under load, not by code review. This is
      the per-tenant serialization primitive `STO-27` exists for. (`LDG-35`, `STO-27`)
- [ ] **CNF-164** — A machine whose correlator arrives after `OPS-33` released the commitment is
      attached to its tenant and then routed through the ordinary exhaustion path — not silently
      adopted free, not destroyed without a record. (`OPS-36`)
- [ ] **CNF-165** — When correlator search returns **many**, no automatic attach occurs, the
      operator is shown all candidates, and the recorded choice names which duplicate was kept
      and why the others are believed spurious. (`OPS-38`, `OPS-31`)

- [ ] **CNF-166** — Withhold from the customer offer listing an offer with no cancellation
      bound, a descriptor-declared bound later than provider-local today, and an offer-reported
      bound later than provider-local today. For each, create with a remembered offer id and
      assert the purchase-tail `400 invalid_request` with `details.reason: offer_not_sellable`,
      its `WIR-9a` refusal and skipped-check entries, no commitment or other purchase write,
      and no provider order. A bound learned only after an order is not a pre-order refusal.
      An otherwise sellable offer with a bound no later than provider-local today and a
      sellable traffic bound is admitted and opens a commitment sized to that bound. Show that
      the earliest-date contribution to `protected_sats` is zero before and after a shorter actual
      date is read, while the commitment remains unchanged (`PRV-13`, `PRV-31`, `LDG-33`).
      Preserve cap and balance suppression for an unsellable offer under `API-7`.
      Separately create with an offer id the provider has never listed, absent from every source
      admission could read. Assert the purchase-tail `400 invalid_request` with
      `details.reason: "offer_not_sellable"`, its `WIR-9a` refusal entry, and `not_checked` entries
      for balance and, when supplied, the commitment cap, each with `because: "offer_not_sellable"`.
      Cap and balance do not run; there is no commitment, purchase write or provider order.
      (`PRV-31`, `PRV-13c`, `LDG-12`, `API-7`, `WIR-9a`, `DOM-9`, `WIR-30`, `CNF-307`)
      *Amended 2026-10-09 (`ADR-0039`): the no-bound sale refusal uses the
      create-tail offer reason.*
      *Amended 2026-10-12 (`ADR-0037`, Q25): future-bound listing and create cases.*
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added a never-listed offer id and its purchase-tail refusal and
      skipped-check entries.*

- [ ] **CNF-167** — A rate halving increases **no** commitment anywhere in the fleet, except
      machines on the scheduled-cancellation branch. What moves is every affected machine's
      `runway_until`. Fault-inject the rate; diff the commitments table. (`LDG-33`, `ADR-0011`)
- [ ] **CNF-168** — `runway_until` moves at re-derivation in **both** directions and the machine
      view reflects it on the next read. (`LDG-33`, `LDG-15`)
- [ ] **CNF-169** — `runway_until` is derived with `protected_sats` subtracted (`LDG-33`), and a
      machine is routed into the exhaustion path while its remaining commitment still covers
      wind-down at the current rate — at cancellation time the operator is not out
      of pocket. Drive a machine to exhaustion under a falling rate and assert the invariant at
      the moment of cancellation, not at the end of the test. (`LDG-16`)
- [ ] **CNF-170** — Two concurrent runway extensions against a balance that can fund one result in
      one extension and one `insufficient_balance`, and replaying an extension with its
      idempotency key does not reserve twice. (`LDG-62`, `LDG-35`, `API-8`)
- [ ] **CNF-171** — On the scheduled-cancellation branch, a shortfall that available cannot top is
      surfaced to the operator as a named deficiency — not silently absorbed, not billed to the
      customer twice. (`LDG-63`)
- [ ] **CNF-172** — A create/install carrying a signed URL whose expiry is inside the stated
      admission-to-start bound is rejected at accept; at claim, a URL that cannot outlive the
      install fails the operation with no provider mutation and no rescue entry. (`OPS-40`,
      `SEC-21`)
- [ ] **CNF-174** — A customer request authenticates by `Authorization: Bearer <token>` compared
      to a stored **hash** in constant time; the raw token appears in no log line, URL, or
      operation record; and an unknown or malformed token fails `authentication` before any body
      parsing (`API-7`). *Withdrawn signing-vector test: the Ed25519 scheme this checked
      was withdrawn 2026-08-13; a bearer token has no signing string to interoperate on.* (`WIR-5`, `API-39`, `API-3`)
- [ ] **CNF-175** — A request with an unknown body field is rejected naming the field, and a
      response with an extra field is accepted by the reference client. Both directions of
      `WIR-2`, tested separately. (`WIR-2`)
- [ ] **CNF-176** — Every example body in `13-wire-contract.md` validates against the
      implementation's actual parser — the examples are test fixtures, not illustrations, and
      contain no `...` placeholder inside an object (`WIR-37`). (`F19`)
- [ ] **CNF-177** — A browser-origin preflight (`OPTIONS` with the `Authorization` and
      `Idempotency-Key` request headers) succeeds **unauthenticated** and returns the allow-lists
      of `WIR-4a`; a customer request from a wasm client then completes end to end. Run from an
      actual cross-origin fetch, because this is the failure that is invisible in server-only
      tests. (`WIR-4a`, `API-49`)
- [ ] **CNF-178** — A body reusing an idempotency key against a **different** machine or endpoint is
      `409`, not a replay of the first result; and a body with a duplicate JSON member, or an
      integer above 2^53, is rejected. (`WIR-3`, `WIR-1a`)
- [ ] **CNF-179** — An operator resolves a `needs_reconciliation` operation through
      `POST /.../actions/resolve` in each of its **five** forms — `observed`, `absent` and
      `abandoned` on a create, `applied`, `not_applied` and `abandoned` on a kind that acts
      on a machine that already exists (`OPS-31`, `WIR-35`, added 2026-09-02) — with each form
      refused **on a kind whose set does not admit it**, and `abandoned` accepted on both, since it
      is the member common to the two sets; the
      `absent` form releases the
      commitment, and a customer-authenticated request to that route — and to `retry` —
      returns `404`, not `authentication`. (`WIR-35`, `WIR-34`, `OPS-31`, `OPS-45`, `API-64`)
- [ ] **CNF-173** — After startup, enumerating the process environment from inside the
      customer-facing module yields no provider credential — asserted by actually reading the
      environment at runtime, not by reviewing the scrub call, because a runtime that caches the
      environment makes the scrub a no-op. (`OVR-10c`, `F13`)

## Ownership, deletion and duplication

- [ ] **CNF-107** — Two tenants cannot both hold the same `(provider_account, external_id)`, and
      neither can two records for one external machine exist by any other route. The
      constraint is enforced by the store, not by application code. *Absorbed `CNF-6` on 2026-09-02,
      which tested the same control in the words `SEC-10` uses; this item survives because it names
      the constraint that enforces it, and it takes that citation with it.* (`STO-17`, `SEC-10`)
- [ ] **CNF-108** — A machine with an unreleased billable attachment cannot be tombstoned.
      (`STO-18`)
- [ ] **CNF-109** — An idempotency key reused after its operation was retained-out either returns
      the original or is refused — it never performs the mutation a second time. (`STO-25`)
- [ ] **CNF-110** — A `retry` leaves the failed attempt's row — its error included — byte-identical,
      and the fresh attempt is a separate operation carrying the retry's stated reason. (`API-64`,
      `WIR-51`, `DOM-31`)

## Blast radius

- [ ] **CNF-111** — Tenants are distributed across more than one provider account. An assignment
      policy that places every tenant in one account fails this item even though it satisfies
      `API-17b`. (`SEC-43`)
- [ ] **CNF-112** — The provider's account-linkage practice has been verified in writing. Until it
      is, `CNF-111` proves nothing. (`SEC-44`)
- [ ] **CNF-113** — **REWRITTEN 2026-08-15** — it tested a deadline `SEC-45` no longer asserts.
      Two halves, both required. (a) One operator action suspends a tenant and enqueues a
      cancellation for every machine it owns, without the operator enumerating them by hand.
      (b) Given a provider resource, an address and an instant, the system names the owning
      tenant, the machine, and the operations that touched it in that window — the fact an abuse
      answer depends on, previously supported by the schema and required by nothing.
      **Half (b) was untestable as written and is superseded by `CNF-222`/`CNF-223`**: it said
      "an instant" while the only data was current state, so any implementation passed it by
      ignoring the instant — which is precisely the defect. Assert it against `STO-41`'s history
      with a reissued address, or not at all. (`SEC-45`, `SEC-54`, `API-58`)
- **CNF-114** — **MERGED INTO `CNF-188` 2026-09-02.** Both tested `SEC-46`'s three-state table and
      both were counted, the duplicate a launch tier below its survivor, double-counting one
      control — the same defect `CNF-195` was
      already the marker for, on the same requirement, which is a hint about where this document's
      duplicates come from. `CNF-188` is the survivor and carries this item's operator-deficiency
      clause. Identifier retained rather than reused, and not a checkbox.
- [ ] **CNF-115** — Balances and commitments are answerable with every provider unreachable.
      (`SEC-47`)

## Added 2026-10-08 (`ADR-0035`)

- [ ] **CNF-322** — **Acceptance belongs to the operation's mutation.** Exercise each driver
      error with acceptance known true, known false, and unknown. Assert `details.accepted`
      is always present and never defaulted: before any mutating-request byte is sent it is
      false; after a request was sent but no reply arrives, inject both a connection failure
      and a timeout and assert `network` or `timeout` respectively with explicit null. Return
      a 5xx to the mutating request with acceptance unknown: assert `provider`, retained
      `details.status`, and null. Return an unreadable reply whose failure has no mapping:
      assert `internal` and null. After a known successful 2xx mutation response, fail to parse
      its body: assert `internal` but accepted true. For each unknown case assert the driver
      reports the mutating request's own failure, even if a later request also fails, never
      substituting the later kind or status, omitting the field, or reporting false. Accept a
      create's key upload, refuse the order, and assert false. Accept the order, then fail a
      read, and assert true on that and every later error. Repeat for the mutations
      in `OPS-11`'s last row without requiring a correlator. Inject Robot's
      `403 RATE_LIMIT_EXCEEDED`: assert `rate_limited`, `details.status: 403`, and retained
      acceptance. Check upstream status retention and redaction on these errors. (`PRV-5`,
      `PRV-7`, `PRV-26`, `DOM-18`)
      *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): updated the reference to the remaining last row.*
- [ ] **CNF-323** — **A refused read does not erase an accepted mutation.** For create and every kind in
      `OPS-11`'s last row, accept the mutation, then inject each of `rate_limited`, `not_found`,
      `authentication`, and a provider 4xx on a read other than the accepted dated cancellation
      read-back and post-order read (`PRV-13`, `PRV-13c`; `OPS-11`'s exception paragraph);
      for create, fail `OPS-27`'s "direct read" or
      "search the correlator across every ordering channel". Assert `needs_reconciliation`, no automatic repeat,
      and `retryable: false`. Separately supply the goal-state answer on a goal-state mutation and assert `succeeded`.
      Contrast rejection before acceptance, including the ancillary-key case in `CNF-322`,
      with transport failure and unknown acceptance under `PRV-5`'s mapped-cause rule:
      deterministic rejection is `failed`, while a pre-send `network` failure (for create, from a step-9 call) remains ambiguous
      despite accepted false, and an unknown-acceptance `network`, `timeout`, `provider` 5xx or
      unmapped `internal` failure remains ambiguous (for create, recorded after step 9 begins). Run the other classifier
      rows through `CNF-31a`/`CNF-31b` and retain the install-marker demonstrations.
      Timeout polling an accepted order: assert kind `timeout`, acceptance true, the transaction
      identifier retained and the message warning that the order may remain pending and must
      not be repeated. (`OPS-11`, `OPS-12`, `API-51`, `PRV-5`, `PRV-11`)
      *Amended 2026-10-14 (`ADR-0037`, Q31): scope the injected read to the classifier.*
      *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): retained create acceptance coverage and scoped its transport cases to step 9 onward.*
- [ ] **CNF-324** — **Accepted creates settle only on one verified resource.** After acceptance,
      exercise settle-time searches across every ordering channel with zero, one and many exact
      matches, a failed search, and a non-authoritative search. Only one resource confirmed by a
      direct read settles `succeeded`; every other case stays `needs_reconciliation`, with no
      automatic attachment of duplicates. Fail the confirming read inside the visibility window
      and retain the later direct-read and resolution demonstrations in `CNF-286`.
      Return a matched order still in progress; advance beyond the configured negative window
      and assert no release or absent resolution from that window. Contrast a genuinely negative
      search that releases under its window, continuing to search afterwards. (`OPS-27`,
      `OPS-29`, `OPS-33`, `OPS-38`, `PRV-36`, `PRV-38`)
- [ ] **CNF-325** — **Accepted but unresolved creates keep their obligations pending.** With a
      setup fee and a nonzero prepaid unit, accept the order then fail `OPS-27`'s confirming
      "direct read" or settle-time "search the correlator across every ordering channel",
      outside the accepted dated cancellation read-back and post-order read
      (`PRV-13`, `PRV-13c`; `OPS-11`'s exception paragraph). Assert no debit yet,
      both amounts still reserved and both obligations parked.
      Resolve observed with the create's commitment open: assert both debits and paired
      decrements, the machine/terminal writes and clearing both parked obligations commit
      atomically. Repeat after negative-window release: assert the separate operator deficiencies
      and no charge to available balance or a wind-down commitment. Exercise absent with and
      without provider evidence of each charge, and abandoned; retain the zero-unit exceptions
      in `CNF-315`/`CNF-316`. (`LDG-39`, `LDG-67`, `LDG-31`, `LDG-32`, `LDG-66`, `OPS-27`, `OPS-33`)
      *Amended 2026-10-14 (`ADR-0037`, Q31): fail confirmation or search before settlement.*
- [ ] **CNF-326** — **Applied completed-release resolution ends that attachment's meter.** Accept a
      release, fail its follow-up read, and resolve it `applied` on evidence of completed release
      with no effective date. Assert the attachment's `released_at`
      and the applicable `LDG-38` exit write commit with the resolution; inject a transaction
      failure to demonstrate no partial effects. Preserve meter exit exceptions, machine state,
      other attachments and the episode/fence outcomes of `OPS-48`. Contrast unresolved,
      `not_applied`, and `abandoned`: none records an applied release. (`PRV-45`, `OPS-31`,
      `OPS-48`, `LDG-38`) *Completed-release premise qualified 2026-10-08 (`ADR-0037`).*
- [ ] **CNF-327** — **Retry-after can accompany a non-retryable operation.** Read a
      `needs_reconciliation` create whose error is `rate_limited`: assert `details.retry_after_ms`
      and `retryable: false` together, with the per-kind keys retained and no mutation repeated
      when the interval expires. Separately throttle a GET of its operation view: the read error
      does not change or stand in for the operation outcome. (`API-51`, `API-50`, `WIR-9a`,
      `WIR-9b`, `OPS-12`)

- [ ] **CNF-328** — **A dated attachment release stops customer metering at its date; the sweep
      records later absence.** On both ordinary success and `applied` resolution, return an
      effective date for a billable attachment. For customer-debit assertions, inject a priced
      attachment only as an isolated accounting fixture: v1 has no attachment customer-rate
      source and this is not a v1 sale. Exercise a future date and one already passed at
      acceptance. Assert the terminal or resolution transaction stores the date atomically,
      leaves `released_at` null, changes neither machine state nor other attachments, and keeps
      the commitment and `STO-18` tombstone gate. Inject a transaction failure and assert no
      partial date or meter write. Advance the clock past the future date before a meter tick and
      sweep as in `CNF-277`: the attachment's customer meter closes exactly at the date, with no
      future debit or mark at acceptance and no debit after the date, while `released_at` remains
      null until evidence. With the mark preceding a date already passed at acceptance, the next
      tick clips at that date. Separately, post usage through t=20 on each of a machine and an
      isolated priced attachment subject, then learn a stop at t=10. Assert both marks and all
      posted entries unchanged, no corrective entry, and no later posting past either stop.
      This late-learned trace does not arise from a v1 sale. Enabling an attachment customer rate
      or a future-scheduled offer requires the automatic, idempotent corrective credit owned by
      `LDG-38`; the attachment rate also requires `PRV-13b`'s kind bound and per-offer created-kind
      declaration. Distinguish an ordinary exit inside a prepaid first unit: its first-unit debit
      remains and its closing increment is discarded. Exercise a
      provider gone before the date: direct absence writes `released_at` at observation and the
      meter clips to that earlier instant; a later dated release result preserves that
      observation. Exercise presence after the date: the meter stays
      stopped but `released_at` stays null and the gate remains closed. With the machine already
      recorded gone, omit that attachment from a complete listing and confirm direct absence:
      an automatic sweep writes `released_at` at
      observation, closes the exit and commitment through their owners, and permits tombstoning.
      An interrupted account pass or per-machine attachment listing writes no absence; a
      complete listing omission contradicted by a
      direct read finding the attachment also writes nothing. Request a Robot `now` release at
      `2026-10-31T12:00:00Z` and have the provider return day-only
      `cancellation_date=2026-10-31`; assert the stored effective boundary is
      `2026-10-31T22:59:59Z` in this isolated fixture, which assumes provider zone
      `Europe/Berlin` (also verified for Robot by `docs/research/panels-2026-10/r40/zone-check.txt`), with
      `released_at` still null until release evidence when there was no earlier gone
      observation, rather than noon or the start of that day. Separately return an explicit
      provider timestamp and keep its stated instant. Resolve a scheduled release `applied`
      with its required wire date;
      assert that the resolution stores the date without deriving `released_at`. `WIR-35` says
      "Without the date, `applied` asserts a completed release"; submit that assertion and
      exercise the completed-release effects using `CNF-326` and `CNF-293`. For a separate
      hypothetical surviving billable Robot attachment, assert the commitment remains held
      until `cleanup: api` release evidence and its provider cost belongs to `LDG-75`; this
      is an accounting fixture, not the observed auction outcome. Current Robot offers that
      order `primary_ipv4` remain sellable on all Robot ordering channels without a separate
      attachment customer charge or attachment bound. The tested auction order's recorded
      absence creates no survivor row; catalogue survival remains unverified.
      (`PRV-45`, `OPS-32`, `WIR-35`, `WIR-52`, `LDG-38`, `LDG-32`, `STO-18`, `PRV-13b`, `LDG-75`)
- [ ] **CNF-329** — **A provider call that never replies has a deadline.** Configure a finite,
      positive deadline and dispatch a provider call whose reply never arrives; assert the wait
      ends at the configured bound. Repeat with a mutation whose outcome remains unknown:
      expiry alone proves neither success nor non-application nor billing stop, and no
      automatic replay occurs; classification and evidence-based resolution retain their existing
      rules without assuming acceptance from elapsed time. Show wind-down sizing covers the
      full sequential allowance: metering detection cadence, mutating-call deadline, effective
      visibility window starting at the reply or deadline expiry, resolution-read cadence,
      that read's own deadline, worst-case machine-operation hold and margin. Exercise a reply
      at the deadline followed by visibility lag and a lost reply followed by a delayed
      resolution read whose own call lasts to its deadline. Assert neither max(deadline, window)
      nor their sum without the read wait funds the trace. Refuse startup with a missing, zero,
      negative, non-finite or malformed deadline or resolution-read cadence; enforce the stated
      cadence. (`OVR-19`, `PRV-13b`,
      `PRV-36`, `PRV-5`, `OPS-11`, `OPS-12`)

## Before production

Beyond the checklist, a deployment must state every parameter on `OVR-19`'s register — the human
items (the `needs_reconciliation` rota, the recovery-key inventory) included — and startup must
refuse to run on a missing or out-of-range startup-validated row. *This section carried its own list
of thirteen until 2026-09-08; it was a second copy of the register, and it had drifted.*

- [ ] **CNF-330** — **A seed's month owns its row, even with a later mark** (added 2026-10-08,
      `ADR-0033`). With a first unit actually debited and copied duration 3600, seed at
      2026-01-31 23:30Z: only the `2026-01` row is written, its mark 2026-02-01 00:30Z.
      January is created with `r = 0`. No February row is created by the seed or by midnight.
      Retention keeps January while it supplies the latest mark. Tick at 23:50 and 00:10, exit at 00:20,
      and re-enter at 00:25: each is discarded, all rows and credit unchanged; also test an
      exit/re-entry exactly at 00:30. The global latest-mark read still returns January's 00:30,
      and the mark never moves backwards. A tick at 01:00 prices only 00:30–01:00 in February,
      initializing February's `r = 0` if absent, without importing January's credit. At 1/5
      sat/s this posts 360 sats and leaves February credit zero, January unchanged. Separately,
      exercise an ordinary later re-entry into a month whose row already has credit 1/3 from
      earlier increments: the seed preserves that credit and a later integer-charge increment
      uses and preserves it, never importing another month's credit. The seed writes no entry,
      no deficiency and no seconds; the prepaid debit's attribution is unchanged, its covered time and the metered seconds neither overlap nor
      leave a billable second uncovered. For the exit/re-entry variant, nonbillable time is
      excluded from metering without refunding the unit, and the paid interval still ends at
      00:30. A seed at Feb 1 00:00 instead writes February with mark 01:00. A Jan 31 23:00 seed whose paid mark lands exactly
      at Feb 1 00:00 still writes January; a tick at 00:05 uses February credit for only
      00:00–00:05. Delay the first real tick beyond another month boundary and assert the
      existing split and per-piece credit allocation. Do not reject a mark merely because
      it lies outside its row's month; the one-sided high-water check still passes. Neither
      the one-row Funding model nor the mark-free Period model proves this storage placement;
      these are running-implementation obligations. (`LDG-72`, `LDG-38`, `LDG-68`, `STO-45`)


## Provider traffic (`ADR-0034`, added 2026-10-08)

- [ ] **CNF-331** — **Refresh cache settlement preserves observation age.** Configure a positive
      freshness window. Enqueue a refresh of a machine observed within it: assert `202`, then
      `succeeded`, result `{}`, zero provider calls and unchanged `state_observed_at`. Repeat
      at the stale boundary, with a null observation, and with an observation timestamp later than claim time: each can read the provider. A future timestamp does not make the cache fresh. Queue several
      refreshes while stale, then claim them serially within the window after a responding read;
      assert one provider read in total. Change the stored observation between enqueue and claim
      to prove the check reads it at claim. (`DOM-8`, `OPS-8`, `OPS-11`, `API-7`, `WIR-10`)
- [ ] **CNF-332** — **Failed refreshes do not create freshness.** On a stale machine fail a provider
      read, assert `failed` and unchanged `state_observed_at`, then enqueue and claim a new refresh
      before a window elapses. It reads again; another failure remains
      `failed`. Repeat from a null observation. No attempted-read timestamp or cooldown substitutes
      for a successful observation. (`DOM-8`, `OPS-11`)
- [ ] **CNF-333** — **The machine view exposes observation age.** Assert GET and list views include
      `state_observed_at` as the exact stored timestamp in wire format, and as explicit null for an
      unobserved machine. Change `updated_at` independently and show it does not change the
      observation field. Validate the machine fixture and both timestamp/null responses.
      (`WIR-11`, `WIR-1`, `STO-48`)
- [ ] **CNF-334** — **Reverse-DNS is ceilinged before local settlement.** Drive the authenticated
      request pipeline at and below the per-principal reverse-DNS ceiling. Assert `ceiling_exceeded`
      at the limit, including an identical recorded value; a replay spends no second slot. Below
      the limit assert `202` followed by `succeeded` and `{}` with zero provider calls for an
      identical established PTR. Reject a foreign machine, an address outside its recorded list,
      an empty/overlong hostname and CR/LF even when its text matches a stored entry. Retain the
      capability check. (`SEC-39`, `API-7`, `API-16`, `API-17`, `PRV-2`, `PRV-25`, `WIR-10`)
- [ ] **CNF-335** — **A requested PTR is not provider evidence.** Begin with no recorded value and
      send a write. Observe invalidation before dispatch of a differing write and verify enqueue
      and mere acceptance establish nothing. Lose the reply; the former value must not qualify
      for a no-op. Confirm a value by completed write, authoritative read and authoritative
      resolution in separate cases; each stores the provider-established entry and permits an
      identical subsequent no-op. Remove the address and assert its entry disappears. Exercise
      deterministic and ambiguous provider failures with the existing classifications.
      (`PRV-25`, `PRV-12`, `PRV-36`, `OPS-11`, `OPS-31`)
- [ ] **CNF-339** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Refresh freshness is validated at startup.** Missing, malformed,
      non-finite, zero or negative freshness durations refuse startup. A positive window
      shorter than twice the account-sweep interval also refuses startup. Exercise a
      window equal to one interval, just below two intervals, exactly two intervals
      and above two intervals: reject the first two and accept the latter two. At
      the next sweep boundary, claim refresh before the sweep writes: the old
      one-interval window is stale at equality while the two-interval window
      reuses the prior observation. (`DOM-8`, `OVR-19`, `OPS-32`)

## Traffic sale scope (`ADR-0039`, added 2026-10-09)

- [ ] **CNF-340** — **Only traffic-safe offers are advertised and sold.** For the
      currently documented provider products, assert a Robot default unlimited-traffic
      offer is listed with `traffic_bound: "unlimited"` and can reach purchase admission.
      Assert Cloud, DigitalOcean and Robot 10 Gbit allowance offers are omitted, including
      from a direct account offers route. A numeric allowance or missing traffic bound is
      insufficient. For each withheld offer, create using a remembered ID and assert the
      `offer_not_sellable` tail response from `CNF-307`, before any provider call or write.
      An offer lacking a declared cancellation bound follows the same refusal (`CNF-166`).
      An unassigned or unhealthy account still takes its existing listing response.
      Check the listed offer's customer price and install strategies remain governed by
      their existing contracts. Vary the provider feed's allowance; the returned offer's
      `traffic_bound` follows current terms rather than a compiled constant or
      `08-provider-notes.md` value. Describe capabilities remains pure and synchronous.
      For a future allowance-offer re-admission, read current overage price with the offer
      terms; no overage-price descriptor field is required. (`DOM-9`, `WIR-30`, `PRV-13b`, `PRV-31`, `PRV-44`,
      `PRV-13c`, `API-7`)
- [ ] **CNF-341** — **Conditional allowance re-admission needs measured evidence.** A
      driver declaring an allowance and headroom without a live counter-freshness bound
      does not list or sell that offer. Evidence for a future re-admission must bound
      traffic after the last reading through deletion under `ADR-0033`'s "priced, not
      amplified" criterion, and the bound and its cancellation/destruction consequence
      must appear before purchase. For an offer re-admitted after that live evidence,
      assert both disclosures in its listing before admitting a create. Until an offer
      passes that condition, no `traffic_allowance` cancellation reason is active.
      A provider invoice may carry residual traffic cost without a customer byte debit
      or new deficiency cause. (`PRV-13b`, `PRV-44`, `DOM-9`, `WIR-30`, `LDG-75`)

## Robot ordering (`ADR-0036`, added 2026-10-09)

- [ ] **CNF-342** — **Bad forwarded values and absent offers cause no provider mutation.**
      Run on `CNF-241`'s `correlator: per_order_key` ordering channel. Use stored creates
      carrying provider-forwarded values that pass API boundary validation but the driver
      rejects, including a provider-options object containing a value the provider does not
      accept. For each, assert the driver rejects it at `OPS-43`'s step 7, "Run `PRV-47`'s
      driver validation", with no provider mutation: no per-order key upload and no order
      request. The List offers read is permitted. For a stored create carrying a
      provider-forwarded value that API boundary validation rejects, assert it fails at
      `OPS-43`'s step 3 instead, with no provider request at all.
      Separately omit the caller-supplied purchase acknowledgement. Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` naming
      the field, `retryable: false` on the error and operation view, `failed`, commitment
      released in full and no provider request at all, including no List offers read.
      For a valid request, remove the named auction offer after admission and before claim
      (`OPS-5`), while the create is `queued` and unclaimed. Repeat for an ordinary catalogue
      offer removed in that same window. Detect absence at `OPS-43`'s step 5, "Check for the
      named offer's absence from that result", using the step-4 List offers result. In each
      case assert `invalid_request`, `details.reason: "offer_not_sellable"`, `retryable: false`
      on both the error and operation view, `failed`, commitment released in full with no
      setup-fee or first-unit debit, and the resource-offer exclusion freed where the create holds
      one. A catalogue create takes no resource-offer exclusion. Assert no per-order key upload
      and no order request; the List offers read is permitted. The inner error has no
      `details.refusals` or `details.not_checked` and no cap or balance result or amount derived
      from the offer's price. Neither check adds a provider lookup to `API-7`'s rich-tail collection.
      (`PRV-47`, `PRV-10`, `PRV-42`, `API-7`, `OPS-43`, `OPS-23`, `OPS-5`, `STO-58`, `LDG-39`,
      `WIR-9`, `WIR-9a`, `WIR-9b`, `WIR-10b`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      separated acknowledgement, forwarded-value and queued offer-removal
      cases; split forwarded-value fixtures into boundary-valid values the driver rejects at
      step 7 and boundary-invalid values rejected at step 3; asserted absence outcomes and no key upload on a per-order-key channel.*

- [ ] **CNF-343** — **One resource offer has one create in flight.** Race two different
      tenants and two replicas on one `offer_is_resource` account/channel/offer.
      Both read an open snapshot; at the admitting conditional-write barrier exactly
      one wins, and the loser receives an ordinary HTTP `409 conflict`/`state`
      error with `retryable: false`, no `details.refusals`, no synthesized pacing
      or `Retry-After`, and no commitment, balance change, operation or receipt.
      Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further
      creates lose on every replica; settle it and assert the exclusion releases.
      A catalogue product admits independent creates. Race account termination
      separately to retain `API-63`'s guard, and race extension with cancellation
      to retain `LDG-62`'s.
      (`PRV-42`, `STO-27`, `STO-58`, `API-63`, `LDG-62`, `API-7`)
      *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): pinned the restart after step 8; `ADR-0042`.*
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
- [ ] **CNF-345** — **Activation minimum is registered and validated.** Omit, zero,
      set negative or make the satoshi minimum noninteger: startup refuses each.
      With a valid positive integer, startup and restart succeed during a rate
      outage, without fetching an offer or rate to validate the minimum. Two
      credited payments below the valid minimum that
      cumulatively meet it activate once; neither is required to meet a per-payment
      floor. `API-35`'s "The minimum MUST be large enough to purchase something"
      remains the operator's obligation; startup does not value it.
      (`OVR-19`, `API-35`, `LDG-44`, `LDG-52`)

- [ ] **CNF-346** — **DigitalOcean correlator tags never drive bulk deletion** (`docs/research/provider-verify-2026-10.md`, V16, 2026-10-06). Exercise create, ambiguous resolution and cleanup with a lowercase correlator tag satisfying the DO-spec charset and length, using `:` or `_` as a separator; assert no call to `DELETE /v2/droplets?tag_name=` occurs and any delete names a verified individual Droplet id. (`PRV-48`, `OPS-27`)
- [ ] **CNF-347** — **Survivor kinds and individual evidence stay distinct** (`docs/research/provider-verify-2026-10.md`, V17 and §3, updated 2026-10-11 under `ADR-0037`, Q21). For each applicable provider, inspect the immutable descriptor and assert the `PRV-13a` table's kinds and `api`/`manual` classifications: Cloud Primary IP is `api` regardless of any instance's `auto_delete`, Robot Additional IP and subnet are `api` possible survivors, and DigitalOcean backup is `manual`. Separately, exercise attachment listing after deletion: a Cloud Primary IP read back with `auto_delete: true` and then absent after deletion is not reported as surviving; one that remains with `auto_delete: false` is reported with its identity and `cleanup: api`. Exercise a Robot case with a separately ordered Additional IP or subnet that survives and one with none as isolated fixtures; do not infer survival for every instance from the descriptor. Assert release follows each listed billable `api` attachment. For the observed auction `primary_ipv4` add-on and included /64, return a complete empty post-cancellation listing and assert no survivor row or release is invented. Inspect DigitalOcean create requests and assert `backups: true` is never sent; leave backup billing `[verify]` and separately ordered Robot attachments unverified. (`PRV-13a`, `PRV-44`, `PRV-45`)
- [ ] **CNF-348** — **Existing rescue activation is disabled before re-enabling** (`docs/research/provider-verify-2026-10.md`, V4/V10, 2026-10-06). On Cloud read `rescue_enabled`, disable when true, then enable and reset inside its 60-minute interval. On Robot read `active`, use `DELETE /boot/{n}/rescue` when true, then re-enable and reset. Robot accepted a second activation for the next boot in the 2026-10-12 live session; Cloud remains unverified. (`PRV-15`)
- [ ] **CNF-349** — **Cherry correlator lookup scans the project list** (`docs/research/provider-verify-2026-10.md`, V21, 2026-10-06). Exercise more than one page with the matching tag on a later page; assert the driver filters client-side and returns the exact operation match, without assuming a server-side tag query. (`PRV-26`, `OPS-27`)
- [ ] **CNF-350** — **Operator recording and withdrawal keep the server's time and replay receipt.**
      With the provider never read, record at t1 using `{"status":"restricted","operator_ref":"ref-1"}`;
      assert the machine and every case view show `operator_notice` at t1, with no caller-supplied
      instant. Record again at t3 under a fresh key with
      `{"status":"restricted","operator_ref":"ref-2"}` and assert the
      stored operator pair becomes `(t3, ref-2)`. Fresh reads of the machine and every case view
      render `restricted/operator_notice` at t3. Replay the t1 key:
      assert the exact original status and response body, including t1, are returned while the
      stored pair remains `(t3, ref-2)`; fresh reads of the machine and every case view still
      render `restricted/operator_notice` at t3. Withdraw under a fresh key and assert unknown/null/null with
      both operator columns cleared; replay the withdrawal and assert its exact original response
      with no additional write. Reuse either key with a changed fingerprint and assert `409 conflict`
      (`details.reason: "idempotency_mismatch"`). Check the state change and receipt are committed
      atomically. An account-wide lock requires a separate record on each affected machine.
      (`WIR-47`, `WIR-24`,
      `SEC-41`, `API-61`) *Added 2026-10-10 (`ADR-0038`, Q15 and Q15b).*

## Provider traffic follow-through (`ADR-0034`, Q20 and Q20b)

- [ ] **CNF-351** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **The complete sweep supplies refresh observations.** With N managed Robot
      machines observed present by a successful complete pass, exercise refresh loops across
      the covered sweep interval, after the pass has written its observations: assert one
      `GET /server`, N present-writes of state and `state_observed_at`, and zero
      `GET /server/{server-number}` caused by those refreshes. Keep claim times within each
      observation's freshness window and provider listing successful. Do not count an initially
      stale machine before its sweep observation. Stop the sweep and show successful reads
      fall back to one per machine per window. Run a refresh claim at the next
      sweep boundary before that sweep writes: the previous observation remains
      fresh under the validated two-interval minimum. (`OPS-32`, `DOM-8`, `STO-48`)
- [ ] **CNF-352** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Failed sweep reads establish no absence or freshness.** Interrupt an
      account enumeration and assert no absence is recorded. Complete an enumeration that
      omits a managed machine, then return `403 RATE_LIMIT_EXCEEDED` on its direct confirming
      read: assert no gone write, no absence-dependent ledger or episode effects, and no
      advance of `state_observed_at`; assert the account-and-path alarm on that
      Robot throttle. (`OPS-32`, `STO-48`, `LDG-74`, `PRV-5`)
- [ ] **CNF-353** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **A throttled Robot rescue exit alarms without settling.** Return a Robot
      throttle from end rescue. Assert a monitorable alarm naming the provider account and
      request path under `PRV-5`, and the existing ambiguous error and reconciliation
      outcome; assert no silent retry or successful settlement. (`PRV-22`, `PRV-5`, `OPS-11`)
- [ ] **CNF-354** — **Attachment cleanup is an enabling precondition.** Inspect each proposed sold
      create path able to leave a billable attachment after its machine is gone, including separately
      ordered Robot IPs or subnets and Cloud or DigitalOcean re-admission. Before enabling that path,
      demonstrate complete automatic discovery and cleanup: capture identities while present, enqueue
      `release_attachment` at every gone-write for billable survivors, distinguish never-completed
      listings from completed-empty listings, cover disappearance before identity capture, and require
      no manual operator recovery. Trace each duty to `PRV-49`; inspect the sale configuration and
      conformance evidence rather than asserting an unspecified runtime refusal API. Assert current
      Robot `primary_ipv4` offers remain sold in both ordering channels under `PRV-49`'s accepted
      exception. Exercise the tested auction empty listing without inventing a survivor; catalogue
      survival and provider termination remain unverified, with an accepted accident-only, uncapped EUR
      1.90/month per-stray-address residual until noticed. Do not treat `LDG-31`'s
      "The decrement clamps at zero and the excess is the
      operator's" as an operator cap on that residual. (`PRV-49`, `PRV-13b`, `PRV-45`, `LDG-31`, `LDG-32`)

- [ ] **CNF-355** — **Added 2026-10-12 (`ADR-0041`, Q27).** **Robot rescue pins follow a changed last-rescue record.**
      Return `host_key: []` from activation and ordinary `GET /boot/{n}/rescue`; the
      session awaits provider pins. Before activation, read `/rescue/last` and keep
      its `boot_time` string only as in-memory driver refresh state, not pin material or
      durable state. Return the same baseline record after reset and assert the session
      keeps waiting. Return a record with at least one ECDSA, ED25519 or RSA SHA256
      fingerprint and a non-null `boot_time` string different verbatim from the baseline:
      accept its pins, including when the string looks earlier than reset, without
      interpreting time. Independently set up two new sessions before any pins are accepted
      for either session. In each, the pre-activation baseline record has a non-null
      `boot_time` string B and a nonempty fingerprint set K; K supplies test inputs, not
      accepted session pins. In the first session, return after reset a non-null string C
      different verbatim from B with exactly the same fingerprint set K, and assert K is
      accepted as the session's pins. In the second, return after reset the same string B
      with a different nonempty fingerprint set J, and assert the session keeps awaiting
      pins. With no baseline record, accept the first qualifying record.
      A record with fingerprints but null or missing `boot_time`, and a changed string
      without fingerprints, leave the session awaiting pins. Fail the baseline lookup
      with an error other than no record and assert begin rescue fails before activation,
      with nothing to clean up. Assert the existing active-read and disable-before-enable
      procedure still runs when needed. Connect with a presented full key matching an
      accepted provider pin's algorithm and SHA256 digest; pin that presented full key
      for the connection without synthesizing a key from a fingerprint. Supply caller
      full keys in separate overlapping and nonoverlapping cases: compare their algorithm
      and SHA256 digest to provider pins, refuse nonoverlap, and require the actual Robot
      connection to match a provider pin. Refuse a mismatched presented key before
      authentication. Keep waiting through `RSC-9`'s boot-derived deadline when eligible
      pins never arrive; fail `integrity` even with explicit first-use opt-in. Later
      empty, unchanged or differing records after acceptance, retry and timeout never
      replace or clear the accepted pins or enable first-use trust.
      **Amended 2026-10-14 (`ADR-0041`, Q33): only overlapping caller keys are pinned.**
      Supply one ed25519 caller full key and an eligible provider record with SHA256
      host-key fingerprints for that key and an ecdsa key. Assert the client offers only
      the ed25519 host-key algorithm, and the pinned set is exactly the overlapping caller
      key. Separately assert that a rescue host presenting the provider-pinned ecdsa key
      is refused before authentication: no credential is sent and that key is not pinned.
      Repeat with the caller's ed25519 key and a second, different ed25519 host-key
      fingerprint in the provider record; presenting that second key is refused before
      authentication, with no credential sent and that key not pinned. Separately, supply
      an RSA caller key overlapping an RSA host-key fingerprint and assert the client
      offers `rsa-sha2-512,rsa-sha2-256`.
      (`PRV-15`, `DOM-11`, `PRV-16`, `PRV-19`, `PRV-20`, `RSC-3`,
      `RSC-5`, `RSC-6`, `RSC-9`, `WIR-20`, `WIR-40`)
- [ ] **CNF-356** — **Added 2026-10-12 (`ADR-0037`, Q28).** **Robot cancellation needs no `/server` pre-read.** Block the shared
      `/server` read family and issue a Robot delete. Assert no
      `GET /server/{n}/cancellation` pre-read occurs in the deletion dispatch path,
      and the request sends
      `cancellation_date=now&reserve_location=false`. Accept a dated response, then
      fail its one required direct machine read with `403 RATE_LIMIT_EXCEEDED`:
      the attempt remains `succeeded`/`cancellation_scheduled` with the converted
      effective date and `PRV-5`'s alarm names account and path. Neither uncertainty
      nor a stalled episode follows the absorbed read failure. Contrast mapped
      absence, which records gone at that read, and presence, which remains scheduled.
      Separately refuse an ordinary `GET /server/{n}` and assert the same alarm.
      Retain the post-order future-earliest-date and deviation cases of `CNF-147`.
      **Amended 2026-10-14 (`ADR-0037`, Q31): failed post-order constraint read.**
      In separate cases, accept a Robot auction-channel order with a v1 bound of
      provider-local today, complete the authoritative settle-time search and successful
      confirming `GET /server/{n}`, then inject `403 RATE_LIMIT_EXCEEDED` and a network
      error respectively on the post-order `GET /server/{n}/cancellation` response only.
      Keep the shared `/server` read family available for these cases.
      Compare each with an otherwise identical create whose post-order read succeeds
      with today's date: assert the same `succeeded` status, ledger entries, commitment
      and attached machine row, with only `earliest_cancellation_date` null in the failed
      case. Assert no `needs_reconciliation` and no entry into the failure classifier.
      Price the earliest-date term from `machines.declared_cancellation_bound`: its contribution is zero
      for this v1 offer, as in `CNF-166`; the commitment remains unchanged.
      On the `403` case, assert the alarm names the provider account and request path.
      Then accept a cancellation whose response supplies the per-machine date and assert
      `earliest_cancellation_date` now holds it.
      Repeat the successful read and the network-error case at `OPS-27`'s other two entry
      points: automatic `OPS-27` resolving-observed after a lost order reply, and `OPS-36`'s late attach of a
      machine whose commitment `OPS-33` released. At each, assert the date, or null on
      failure, is written with the machine row in the landed-order transaction, and that a
      failed read changes nothing else.
      **Amended 2026-10-15 (`ADR-0037`, Q34): the committing settlement's read.**
      This replaces Q31's per-create read count.
      Assert each settlement pass that reaches the post-order read makes at most one
      `GET /server/{n}/cancellation`, after its confirming read. Assert the committing
      pass's own result — its date, or null on its own failure — is written with the
      machine row in the landed-order transaction. Once the store holds the machine
      row, assert no constraint read follows by resolution, refresh or the sweep.
      In separate crash cases, kill the engine after a successful post-order read and
      after a failed post-order read, each before the landed-order commit. After restart
      (`OPS-15`), assert the committing automatic resolution pass makes one constraint
      read after its confirming read. Exercise success and failure of that pass's read;
      assert its date, or null on its own failure, is written with the machine row in
      the landed-order transaction. Including the interrupted read, assert two constraint
      reads for each create in these cases and no constraint read after settlement.
      Separately force whole-transaction repeats under `OPS-49` and assert they retain
      the post-order read's result without repeating that read. Also lose the reply to
      a committed landed-order transaction, exhaust the store-error bound and restart;
      assert the stored machine row prevents a later constraint read.
      On a create in `needs_reconciliation`, use the operator's synchronous `observed`
      resolution (`WIR-35`). Assert no `GET /server/{n}/cancellation` and that
      `earliest_cancellation_date` is written null. Assert the earliest-date term is
      priced from `machines.declared_cancellation_bound` under `LDG-33`, contributing zero for the v1 offer.
      **Amended 2026-10-16 (`ADR-0037`, `pv-tsb`): the stored declared bound.**
      At settle-time success (`OPS-27`), withdraw the offer after the order is placed
      and before the landed-order transaction; repeat with the offer re-listed with a
      reported bound later than the snapshot's value in that interval.
      At automatic `OPS-27` resolving-observed after a lost order reply, withdraw the
      offer after the order is placed and before attach; repeat with the offer re-listed
      with a reported bound later than the snapshot's value in that interval.
      At `OPS-36`'s late attach of a machine whose commitment `OPS-33` released, withdraw
      the offer after the order is placed and before attach; repeat with the offer
      re-listed with a reported bound later than the snapshot's value in that interval.
      At each of these paths, exercise both success and failure of the post-order read
      and assert `declared_cancellation_bound` equals the create's `request_summary` offer
      snapshot value, copied in the same transaction as `offer_id` and the machine row.
      On a create in `needs_reconciliation`, withdraw the offer after the order is placed
      and before the operator's synchronous `observed` attach (`WIR-35`); repeat with the
      offer re-listed with a reported bound later than the snapshot's value in that interval.
      Assert `declared_cancellation_bound` is copied from that operation's `request_summary`
      offer snapshot in the same transaction as `offer_id` and the machine row, while
      `earliest_cancellation_date` is written null.
      Separately on automatic `OPS-27` resolving-observed, `OPS-36` late attach and the
      operator's synchronous `observed` attach (`WIR-35`), re-declare the descriptor's
      `cancellation_bound` to a date later than the snapshot's value across a restart
      after the order is placed and before attach. At each, assert
      `declared_cancellation_bound` still equals the create's `request_summary` offer snapshot value.
      In separate cases, sell from a v1 offer and fail the committing pass's post-order
      read, leaving `earliest_cancellation_date` null and the accepted bound copied to
      `declared_cancellation_bound`. Withdraw the offer from the driver's offer listing in
      one case; in another, re-list it with a later reported bound. On the next re-derivation,
      assert the earliest-date term and `runway_until` are derived from the stored copy
      and re-derivation succeeds. Record the driver's offer calls during re-derivation
      and assert none occur; repeat with those calls configured to fail.
      For the later-bound comparison, keep the clock, current rate, remaining commitment,
      mark and other protected terms fixed, with no effective cancellation date and enough
      remaining commitment for positive usable runway even through the later bound.
      Assert a live-offer read would protect cost through that later date's provider-local
      day end and derive an earlier `runway_until` than the stored-copy result.
      Separately re-declare the descriptor's `cancellation_bound` to a later date across a
      restart. With the same fixed inputs, assert the term and `runway_until` are unchanged.
      Instrument descriptor-bound access during re-derivation and assert no access supplies
      the term; repeat with that access configured to fail. Startup may load the descriptor;
      the observation covers re-derivation's bound access.
      Separately inject a machine with null `earliest_cancellation_date` and a future
      provider-local date in `declared_cancellation_bound`, stored in `PRV-13`'s representation:
      "a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone".
      This fixture is injected, not sold under the v1 sale rule. With no effective cancellation
      date, assert `protected_sats` includes cost through that future date's provider-local
      day end at the current rate, and the commitment is unchanged. Keep enough commitment
      for positive usable runway so ignoring the copy also gives a different `runway_until`.
      Null the copy in the injected fixture, giving the live offer, descriptor and retained
      create snapshot future bounds: assert no earliest-date term and no offer or descriptor bound
      access, using the same instrumentation and failing-access cases.
      Repeat the non-null and null-copy derivations after removing the settled create
      under `STO-14`; assert their respective results are unchanged. While the create is
      still retained, also instrument reads of its `request_summary` and assert none occur
      during either re-derivation; repeat with those reads configured to fail.
      Finally accept creates with both a descriptor bound and an offer-reported bound,
      different but both sellable: once with the descriptor's bound later, once with the
      offer's, with the earlier bound before provider-local today in each run.
      In each run, assert the admitting transaction's `request_summary`
      offer snapshot carries the later bound, resolved to a provider-local date at API
      acceptance in the representation quoted above; exercise the attach cases above
      with this snapshot and assert the machine takes the snapshot's value.
      The wrong builds: one that reads the live offer fails on withdrawal or changes the
      term after re-listing; one that reads the descriptor changes the term after restart;
      one that ignores the column misses the injected future term; one that falls back
      on null invents a term from sources the machine did not copy; one that reads the
      create snapshot fails after retention or the instrumented read failure; one that
      omits a writer leaves the copy absent on that attach path; one that snapshots the
      earlier bound, always takes the descriptor or always takes the offer fails the
      acceptance cases with each source later; one that
      re-resolves the offer or the descriptor at attach takes a value the sale never
      admitted, or finds no offer to read.
      (`PRV-5`, `PRV-12`, `PRV-13`, `PRV-13c`, `PRV-31`, `OPS-11`, `OPS-27`, `OPS-33`,
      `OPS-36`, `OPS-48`, `OPS-15`, `OPS-49`, `WIR-35`, `LDG-33`, `STO-50`, `STO-14`)
- [ ] **CNF-357** — **Added 2026-10-12 (`ADR-0037`, Q28).** **Robot optional reads and attachments use their own evidence.**
      With fresh post-action `state_observed_at`, assert no opportunistic
      `GET /server/{n}`; with a stale observation, exercise the existing read and
      mapped failure behavior, without using cached presence as mutation or absence
      proof. Visit attachments for every retained machine, including one already
      recorded gone. Assert Robot listing and direct attachment reads use `GET /ip`
      and `GET /subnet`, never `GET /server/{n}`. During a failed account pass, let
      `/ip` work but assert it cannot record all attachments absent; require a
      complete pass, complete machine attachment listing and direct confirmation
      before each `released_at`. Retain `STO-18`'s tombstone and `LDG-32`'s
      commitment rules. (`PRV-12`, `DOM-8`, `OPS-32`, `PRV-45`, `STO-18`, `LDG-32`)
