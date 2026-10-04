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
      a declared surviving attachment kind is listed — and a field with nothing to declare says so
      explicitly rather than being absent. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
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
      is the sweep.** Every operation found `running` when the engine starts is moved to
      `needs_reconciliation` — never back to `queued` — and the count is logged. Kill the engine
      with an operation of each dispatching kind `running`, restart, and assert each one — **except
      a `refresh`, which settles `failed`** (`ADR-0020`): assert its row is `failed` with an
      `internal` error and that `WIR-35`'s resolve refuses it by kind. (`OPS-15`)
- [ ] **CNF-30** — The startup pass does not overwrite an error already recorded. (`OPS-16`)
- **CNF-31** — **SPLIT 2026-08-09** into `CNF-31a` and `CNF-31b`. The original conflated two
      different stakes: rows where a misclassification causes a repeated provider mutation, and
      rows that only need covering for exhaustiveness. They belonged in different launch tiers
      under the classification then in force (withdrawn 2026-09-12), and the undivided item was
      consequently listed in two of them; the split stands on the two stakes. Identifier retained rather than
      reused, per the append-only convention in the README.
- [ ] **CNF-31a** — The rows of `OPS-11` where a misclassification causes a repeated provider
      mutation. A create failing with a provider 4xx is `failed`; a create failing with a
      provider 5xx, a network error, or a timeout is `needs_reconciliation`; every install
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
- [ ] **CNF-31b** — The remaining rows of `OPS-11`, for exhaustiveness — including that the table
      is *total*: every error kind in `DOM-17` has a defined classification for every operation
      kind, with no implicit default.
- [ ] **CNF-32** — Nothing in the system retries an ambiguous mutation. Assert by counting
      driver invocations across a failure scenario. (`OPS-12`, `SEC-27`)
- [ ] **CNF-33** — An operation is executed correctly after a full process restart between
      enqueue and claim. (`OPS-2`, `STO-5`)
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. (`OPS-23`)
- [ ] **CNF-35** — `GET /v1/operations?status=needs_reconciliation` returns them, paginated.
      (`API-23`, `DEF-8`)

## Rescue and installation

- [ ] **CNF-36** — Every row of the host-key decision table in `RSC-3` is covered, including
      the two abort cases: no keys and no opt-in; and caller keys that do not overlap
      driver keys.
- [ ] **CNF-37** — A pinned connection is never downgraded to first-use trust, including
      when the driver returns an empty key set on a later refresh. (`RSC-5`, `PRV-20`)
- [ ] **CNF-38** — Host-key comparison is canonical: the same key with a different comment,
      a leading host pattern, or extra whitespace compares equal; a different key does
      not. (`RSC-6`)
- [ ] **CNF-39** — The host-key wait deadline scales with the configured boot timeout.
      (`RSC-9`, `DEF-5`)
- [ ] **CNF-40** — A rescue password never appears in a command line. Assert on the spawned
      process's argument vector. (`RSC-11`)
- [ ] **CNF-41** — The generated installer config disables copying rescue authorized keys
      into the installed system. (`RSC-12`)
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
      a transaction with any other. (`STO-12`, `STO-13`)
- [ ] **CNF-58** — An unrecognized status read from the store is a hard error. (`STO-10`)
- [ ] **CNF-59** — A deleted machine is tombstoned, and operations referencing it still
      resolve. (`STO-8`)
- [ ] **CNF-60** — The operation view never contains the stored request payload. (`API-21`)

## Deletion semantics

- [ ] **CNF-63** — For a driver in `PRV-13`'s scheduled-cancellation shape, the action result
      carries the effective cancellation date, and it is not assumed to be "now." (`PRV-13`)
- [ ] **CNF-64** — A machine with a future cancellation date is recorded
      `cancellation_scheduled`, not `deleted`, and is **not** tombstoned until that date
      passes. Assert it still appears in inventory queries that exclude deleted rows. Then record
      it gone before the date by `OPS-32`'s complete pass, and assert the earlier end is taken: the
      meter stops, and its `scheduled` episode closes `resource_gone` (`OPS-48`, `ADR-0021`).
      (`DOM-19`, `STO-8a`)
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
      with a staleness bound longer than the cadence plus the read-to-commit lag — the interval
      between a pass's observation `observed_at` and its row's commit, which `STO-49` allows to be
      non-zero ("a pass that reads early and commits late") — and run in steady state, so the oldest
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
      pass's `observed_at`, not the newest observation's `observed_at` plus the staleness bound,
      which lies in the future. **An open row is preserved**: then let the newest observation age
      past the bound — a staleness computation would now yield a later start — post the meter again
      for the same machine, and assert that the row's `absorbed_from` did not move and no second row
      opened. **The clocks cross inside one outage** (added 2026-09-25, `ADR-0027`, for the replayed
      start): with a staleness bound `b` shorter than the pass cadence `c`, a window of length `3c`
      and `LDG-64`'s bound `M` longer than `3c`, let passes at `t0−2c`, `t0−c` and `t0` each accept
      an observation, so that at `t0` the window holds three, the newest (`observed_at = t0`) is
      fresh, and there is a rate; the case starts from the pass at `t0` and asserts nothing before
      it — any rows an earlier flap opened were closed at or before `t0` by `LDG-64`'s closer, the
      "observation with which `LDG-58`'s window produces a rate again". Let the feed go silent, so
      that at `t0+b` the newest observation is stale and there is no rate, with no pass running
      (`LDG-59`). Post machine A's meter at some `tA` in `(t0+b, t0+3c)`; it finds no open row for A
      and opens A's row: assert `absorbed_from = t0+b` and, on A's view, `rate_outage_deadline =
      t0+b+M`. Let the
      passes at `t0+c` and `t0+2c` fall below `LDG-59`'s quorum, accepting nothing and writing no
      `STO-49` row, and assert that nothing changed. At `t0+3c` let a pass accept one observation
      (`observed_at = t0+3c`): as of that pass the window holds at most two observations — `t0−2c`
      and `t0−c` are outside it and `t0` is at its edge — so on either side of that edge the window
      is thin, and there is still no rate although the new observation is fresh. Post machine B's
      meter at some `tB` after `t0+3c`; it finds no open row for B and opens B's row: assert
      `absorbed_from = t0+b`, equal to A's and not `t0+3c` (what the per-writer thin formula would
      give), `rate_outage_deadline = t0+b+M` on B's view, one deadline for both machines, and that
      `[t0+b, t0+3c)`
      lies inside B's absorbed window, so B's `LDG-38` apportioning charges nothing for it. Assert
      also that B's write read no sibling row: the result is the same when A's row is opened after
      B's, or never. **A restart does not move the deadline, and a changed parameter does**
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
      `LDG-16`, `LDG-58`, `LDG-59`, `LDG-64`, `STO-37`, `STO-49`, `STO-54`, `STO-56`, `OPS-41`,
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
- [ ] **CNF-106** — The reserve commits **customer** price for machine time and the setup fee **at
      cost** — a reserve computed from provider cost under-commits by exactly the margin.
      (`PRV-13b`)

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
      `lightning.cancelled: true`. Restore the rate and cover the full stressed check; only then
      does the halt lift, a fresh deposit mint succeed, and the old read report `gate: null`
      while `lightning.cancelled` remains `true`. Also keep a complete-but-short check halted.
      Repeat independently with no prior halt: first remove the rate, then make the valued terms
      short, starting a halt during the outage. Cover those terms while the rate remains absent;
      assert the same retained halt and deposit results until every leg is valued and a complete
      check passes. This rejects remembering only a short complete check or only the current
      shortfall. `CNF-138` owns no-rate-alone with no prior halt.
      (*Amended 2026-10-04, `pv-gip.42`.*)
      (`LDG-40`, `LDG-20`, `WIR-15`)
- [ ] **CNF-307** — **Rich purchase-tail refusals.** Exercise create and extend-runway after
      the common pipeline, with a fresh key each time. For each fault alone assert a singleton
      `details.refusals` whose singleton is exactly a `WIR-9` inner object, matching
      the headline and its HTTP status: unhealthy create account or fenced extension `409`
      `conflict` (reason `state` or `cancellation_committed`); solvency halt or absent rate `503`
      `halted` (gate `solvency` or `rate_unavailable`); cap exceeded `400` `invalid_request`
      (`max_commitment_sats`, `required_sats`); balance short `402` `insufficient_balance`
      (`available_sats`, `required_sats`). Assert `WIR-9a`'s per-refusal retryability and required pacing, including each
      recoverable account status and a terminated account.
      No entry contains a nested list, no check/refusal repeats, and every refusing tail writes
      no commitment, balance, machine, operation or receipt and makes no provider call.

      Fence + solvency + absent rate: HTTP `409`, entries fence/solvency/rate in that order;
      with a supplied cap, cap and balance each unchecked because `rate_unavailable`; headline has no synthesized
      pacing. Solvency + short balance with a rate: HTTP `503`, envelope `retryable: false`,
      entries solvency (`retryable: true`) then balance (`retryable: false`), with the balance's
      amounts only in the balance entry; solvency's own pacing appears at the top level and in
      the solvency entry. Give the subordinate
      rate entry a longer delay in a solvency+rate case and assert headline pacing is unchanged.
      Cap + short balance: HTTP `400`, cap before balance, envelope false and `not_checked: []`.
      An unhealthy create account + solvency halt with a supplied cap: `409`, state then solvency, cap and balance
      unchecked because `provider_account_not_healthy`; repeat with no rate as well and require
      the rate refusal and both reasons for each skipped check. A skipped check never appears
      as a priced refusal or as passed. A fenced extension with a rate still evaluates cap and
      balance; empty `not_checked` proves they ran even though the resource refused.

      Repeat absent-rate and unhealthy-account cases without `max_commitment_sats`: only balance
      appears in `not_checked`, with every applicable reason and no cap refusal. With a rate and
      healthy account, omitting the cap leaves balance evaluated and `not_checked: []`.
      (*Amended 2026-10-04, `pv-gip.26`, `ADR-0030`.*)

      Clear faults and resend the exact request and key: admission succeeds, proving refusal
      left no replay receipt. Check singleton/no-rate `not_checked` as well as the empty list
      when priced checks ran. Authenticate, authorize, validate body/key, replay, suspend and
      exhaust the ceiling independently before the tail: retain the first early result with no
      rich list or extra ceiling slot. Deposit refusals and operation-view errors retain their
      existing shape. Race admission against the existing account/fence conditional-write guards;
      rich collection must not weaken either guard. (`API-7`, `API-63`, `WIR-9`, `WIR-9a`,
      `WIR-9b`, `WIR-4`, `WIR-17`, `WIR-24`, `WIR-30`, `LDG-35`, `LDG-62`, `STO-35`, `OPS-11`)
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

      Exercise each cause in `LDG-75`'s table: included clamp remainder, closed outage cost and
      unrecoverable setup fee (observed, absent and abandoned-estimate branches); excluded
      exception-branch coverage, account-loss exposure and late-attach floor. Realize excluded
      exposure through subsequent entries/incurred deficiencies and then invoice; it never counts
      both as reserved exposure and actual cost. A computed 100-sat debit with 30 sats remaining
      and 70 native cost produces native entry 21 plus deficiency 49, total 70; a full clamp
      carries all native cost in the deficiency, with no zero ledger row. Fee and attachment
      attribution reach the correct account. Record an invoice replacing outage cost and payment
      covering it: no phantom payable, resolution flag or customer backcharge. Also pay accrued
      outage cost before invoicing, then invoice it: the replacement leaves no phantom payable.

      Demonstrate the accepted gaps in `LDG-75`: invoice authority supplies locally absent free
      operation, quarantine and untracked-resource costs; provider local-month boundaries can
      misplace cost up to the UTC offset; a later-dated deficiency can be missed while an earlier
      invoice is unrecorded behind a later one; and recording only one of a month's two invoices
      already covers that month. These are limitations, not alarms or new cost writers.
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
      headroom is not whole-pool assurance. Repeat `CNF-306` with recorded payment: an incomplete
      pass cannot lift an existing halt, whereas `CNF-138` covers missing-rate-alone and starting
      a halt from short valued terms. An incomplete cost alone likewise starts no halt; short
      valued terms still do. (`LDG-75`, `LDG-17`, `LDG-20`, `LDG-40`, `LDG-53`, `WIR-53`,
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
- [ ] **CNF-147** — **AMENDED 2026-09-02 — it required a scheduled cancellation on a product that
      cancels immediately.** The dedicated path is exercised end to end against a real Hetzner Robot
      machine: a setup fee committed before the order and debited on confirmed acceptance
      (`LDG-39`), and a commitment sized to include cost through the machine's **read**
      `earliest_cancellation_date`. The cancellation is then asserted **against what the machine
      actually says**, which is `PRV-13c`'s read-and-branch: where that date is today — the normal
      case for a newly ordered current-generation server, per `08-provider-notes.md` — cancellation
      is immediate and billing stops; where it is materially in the future, the machine goes to
      `cancellation_scheduled` with its effective date and billing continues until it arrives
      (`DOM-19`, `STO-8a`). **Both branches must be covered**: seed a provider whose per-machine
      date is materially in the future, since no launch product reaches the branch by default and
      adoption, the road that did, is withdrawn (`ADR-0020`). *Withdrawn clause:* "a cancellation that
      schedules rather than deletes, and billing that continues until the effective date", asserted
      unconditionally — which `08-provider-notes.md` records as not existing on current Robot
      servers, so the item was unpassable on the product it was written for and would have been
      "fixed" by encoding a commercial term `PRV-13c` forbids as a constant. **The requirements this
      tests were all written before any of them had run.** (`LDG-39`, `PRV-13b`, `PRV-13c`,
      `DOM-19`, `PRV-31`)
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
      create, lose its reply, and assert resolution takes no read before *n + k* has elapsed — the
      effective window is `max(declared, max(observed))` and the process was not restarted between
      the two. Assert the descriptor value itself is unchanged, and that the same holds for
      `billing_stop_window` (`PRV-13b`). A build that reads the window from driver source
      resolves the second create `absent`, releases the commitment, and the machine arrives with
      nobody paying. (`PRV-36`, `PRV-44`, `STO-53`, `ADR-0018`)
- [ ] **CNF-293** — **An attachment is released by an operator through a route, and
      the route is what opens the tombstone gate.** Delete a machine on a driver whose descriptor
      declares a surviving attachment kind and whose *list attachments* returns one `billable: true`,
      and assert one `machine_attachments` row per returned attachment (`PRV-45`). For an `api` row: assert the delete's terminal transaction
      enqueued a `release_attachment` carrying the delete's own `requested_by` and `system_reason`;
      settle it `failed`, then call `POST .../attachments/{id}/actions/release` as an operator and
      assert a `202` with a fresh `release_attachment` operation, `requested_by: operator`, whose
      success writes `released_at`, after which `STO-18` no longer forbids the tombstone and
      `LDG-74`'s "the row is tombstoned when `STO-18` allows" is what performs it. For a `manual`
      row: assert the same route answers `200` synchronously with `released_at` set and no operation
      minted (`API-48`). Assert a second release of either row is `409` `state`, and that
      `GET .../attachments` shows every row with its `cleanup` and `released_at`. A build without
      the route leaves every machine with a `manual` attachment un-tombstoned forever. (`API-65`,
      `WIR-52`, `PRV-45`, `STO-18`, `LDG-74`)
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
- [ ] **CNF-283** — **The ordering budget is enforced at admission.** Exhaust the driver's declared
      daily order limit and assert the next create is refused before any provider call, classified
      `failed` per `OPS-11`'s admission-only rule, with nothing ambiguous created. The budget is
      the only bound on ordering an autonomous caller cannot acknowledge past — unbounded ordering
      is the money-out family. (`PRV-40`, `OPS-11`)
- [ ] **CNF-284** — **An authentication failure is attempted once.** Give a driver a bad credential
      and assert it makes exactly one attempt and escalates, with no scheduled re-attempt. Asserted
      by counting requests, not by reading the code. On a provider that locks out on repeated
      failures the retry loop takes every tenant's operations offline with it — an outage the
      operator sees and the provider's support desk undoes. (`PRV-41`, `OPS-26`)
- [ ] **CNF-285** — **Where the offer identifier is the resource identifier, resolution reads the
      resource.** For a channel whose descriptor entry carries `offer_is_resource: true` (`PRV-44`),
      assert an ambiguous create resolves by reading the named resource rather than by searching a
      listing, and that absence is interpreted through `PRV-36`'s window. A driver that declares
      the identity and still searches is carrying `OPS-33`'s listing horizon for no reason — slower
      resolution, not a wrong one. (`PRV-42`, `PRV-44`, `PRV-36`, `OPS-27`)
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
      open and keeps metering that attachment; the commitment closes only when the last billable
      resource stops. (`LDG-32`, `PRV-13a`, `STO-18`)
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
      confirmed termination closes them and returns their reserved satoshis to available. Run it
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
      zero absorbed seconds, and the applicable `unrecoverable_setup_fee` record with the same
      null-rate/zero-seconds shape. Attach, deficiency records, fee settlement/parked-fee clearing
      and cleanup enqueue are atomic: inject failure between effects and observe all or none.
      Before the bound the cleanup short-defers with no fence or provider call; extension is
      refused by the rate gate. The meter charges nothing and opens a separate outage row from
      `max(currency outage start, attach seed)`, never absorbing pre-attach time.

      Return the rate. In one ordering, extend before the cleanup fence: a commitment opens,
      `runway_until` is re-derived (*amended 2026-10-04, `pv-gip.39`: no deficiency-resolution
      bookkeeping*) and the
      cleanup aborts without provider mutation; the machine survives. In the other ordering, make
      no extension: the cleanup cancels through the existing fence. The opening rates on the
      native-only wind-down and setup-fee records remain null in both cases. No general interval
      after the return delays cancellation. Separately keep the outage through its bound and
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
      against that commitment and decrements it in the same transaction. Resolving *after* `OPS-33`
      released it debits the customer **nothing**: the fee becomes an operator deficiency
      (`LDG-66`, cause `unrecoverable_setup_fee`), `LDG-67`'s parked obligation is cleared in the
      same resolution transaction, available balance does not move, and a wind-down commitment
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
      ambiguous create ends in `needs_reconciliation` awaiting an operator, the recent-order
      listing is surfaced as evidence, and **no automatic attach occurs on any hostname or timing
      similarity**. The negative window still releases the commitment in full. **And the same
      create on the auction channel of the same account resolves automatically through
      `CNF-180`'s path** — correlation is per channel, and a build that switches it on or off
      provider-wide fails one half (2026-09-05). (`PRV-33`, `OPS-29`, `OPS-33`, `PRV-32`)
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
      with a 5xx, once with a deterministic `authentication`, and once with `rate_limited` — and
      assert: the attempt settles
      `needs_reconciliation` and the episode is `uncertain`, or the attempt settles `failed` and the
      episode is `stalled`; in both, the episode stays open, `destroy_committed` still holds its id,
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
      closed; and **no timer ever moves a `stalled` episode whose
      machine is still unfunded** — run the clock out and assert it is still `stalled` with one
      attempt, including where that attempt failed `rate_limited` (`F48`: a throttle is not deferred). **Then the row a reader
      will get wrong**: a cancellation the provider merely *scheduled* (`DOM-19`) settles
      `succeeded`, the episode is `scheduled`, and it and the fence both **stay** until the effective
      date passes and the machine is tombstoned — closing there lets the next exhaustion sweep open
      a fresh episode and place a second cancellation against a machine already scheduled, which
      `OPS-39` warns can alter or repeat the first's mutation. **The failure this catches is a
      sweep loop that settles `succeeded` forever while the machine bills forever.** (`OPS-48`,
      `DOM-31`, `OPS-42`, `OPS-39`, `OPS-26`, `API-64`, `LDG-62`)
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
      tenant (`WIR-41`), retry the episode, and assert the machine survives** — give the fixture
      months of runway, since a suspension cancels regardless of funding, the fence forbids
      extending it (`LDG-62`), and a `stalled` machine's date keeps moving while it bills (*this
      step said "fund the machine" until 2026-09-09, which the fence refuses*): the
      exemption reads the tenant's *current* state, and a build keyed on the episode's `reasons`
      history destroys a machine its live tenant has paid for. *Added 2026-09-05: with a
      pre-existing episode the pass could neither enqueue nor name the machine, so the parent never
      settled; the resume case is the third rewrite of the exemption in one day.*
      The operator listing is the entire remedy, which is why `OPS-48` never retries a `stalled`
      episode by timer. *Corrected 2026-09-04: this item said "the machine keeps draining runway so
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
      Move it **up mid-increment** and assert the increment **splits** at `rate_observed_at`, so the
      seconds before the move are charged at the old rate (`LDG-38`); an implementation that prices
      the whole increment at the closing rate fails here and is the defect `CNF-185` also catches.
      **Then the same mid-increment move followed by a process kill before the tick**: on restart
      the increment still splits at the recorded `rate_observed_at`, read from `STO-49`'s
      `rate_observations` — a build that keeps the accepted rate in memory prices the whole
      increment at whichever rate restart finds first (2026-09-05).
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
      commitment closes once the last billable attachment has stopped (`LDG-32`, `STO-18`). Then the
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
      keeps being metered on its own subject. And a sweep pass that **yields to `rate_limited` part
      way records no absence at all** — the half-listing must not close a whole account's
      commitments. **A machine created inside `PRV-36`'s effective visibility window and not yet in
      the provider's listing records no absence either**, and its meter keeps running: seed a listing
      that omits a machine created seconds ago, assert the sweep writes nothing, then re-run past
      the window with the machine present and assert it is still metered and still committed.
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
      the returning observation closes it at 12:30. Across that posting and the exit, price
      [12:00,12:20) and [12:30,12:40) at their respective rates, absorb only [12:20,12:30),
      and leave `absorbed_until = 12:30` after exit, with mark 12:40. With `r = 0`, sufficient
      authority, 1/5 sat/s before the outage and 2/5 after it, expect total debit/decrement 480
      and final `r = 0`. The row was opened while the outage was live, so this checks its
      end independently of historical no-row replay; assert `absorbed_seconds = 600`.
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
      operator's later `not_applied` on it leaves the episode closed (`OPS-48`, `ADR-0021`). *Added 2026-09-04: the release was asserted and the
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
      correlator entry is written, and assert it fails `account_terminated` with no provider call;
      then commit the termination *after* the entry is written and before the call, and assert the
      termination treats that attempt as potentially dispatched — neither failed nor released, and
      resolved through `OPS-36`'s late attach.
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
- [ ] **CNF-303** — **A temporary key the engine could not remove is swept, and one in use is not**
      (added 2026-09-16, `pv-lld`). Kill the engine between begin-rescue's key registration and
      `PRV-21`, and again between a create's key registration and `PRV-9`'s cleanup: assert each
      key resource at the provider carries the operation id as its name or tag, that `OPS-32`'s next
      complete pass deletes both, and that a key whose operation is still `running` on the same
      account is untouched by that pass. Then let begin rescue fail partway with cleanup succeeding
      and with it failing: the first leaves no resource, the second attaches the leaked ids to the
      error's details (`PRV-18`) and the sweep removes the resource afterwards. On Robot, assert
      the order transaction still lists the fingerprint after the resource is gone, or the item
      must not delete it. (`PRV-9`, `PRV-18`, `PRV-21`, `OPS-32`, `PRV-32`)
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
      `PRV-13b`'s reserve, the worker fails the operation deterministically **with no provider call
      and no ordering request**, `conflict` with `details.reason: "price_moved"`, and the error
      names the shortfall. With the price unchanged or lower, it proceeds. **With the provider's
      price unchanged and the satoshi rate moved — in either direction — it proceeds**: that is the
      case a build comparing satoshi reserves refuses, and under a falling market it refused every
      resubmission (added 2026-09-05). **Restart the process between acceptance and claim and
      assert the gate still runs**, from the attempt entry's recorded native price — a build that
      keeps it in memory cannot compare anything after a restart. No commitment grows in any case. (`OPS-43`, `PRV-13b`,
      `ADR-0011`, `LDG-2`)
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
- [ ] **CNF-250** — **`network_restriction.source` is null exactly when nobody has looked**, and
      `system_reason` parses against a closed enum. A freshly created machine renders
      `{"status": "unknown", "source": null, "observed_at": null}`; a strict client parsing
      `system_reason` against `WIR-10a`'s set accepts every value the system emits. (`PRV-35`,
      `WIR-10a`, `WIR-47`)
- [ ] **CNF-237** — **A delete is not resolved as failed while the provider is still catching up.**
      With a provider whose resource read lags its write, an ambiguous delete resolves correctly:
      resolution takes no read before the effective visibility window elapses, a pre-mutation reading
      inside the window leaves the operation pending rather than concluding, a post-mutation reading
      is never reverted by a later contrary read, and a pre-mutation reading beyond the window
      resolves *not applied*. Assert with an injected read lag; a sample exceeding the declared
      window widens it and does **not** authorize a replay. (`PRV-36`, `OPS-33`, `OPS-12`)
- [ ] **CNF-238** — **A goal-state rejection is a success.** A delete against an already-deleted
      resource, where the provider answers 4xx meaning "already in the target state", classifies
      `succeeded` and its commitment closes (`LDG-32`) — **once the last billable resource has
      stopped**, since `LDG-32` says "Attachments keep the commitment open, and metering follows
      them"; with a billable attachment surviving, `CNF-187` governs and the commitment stays open
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
      Step (3) is 11:00, original end 12:00. No observation is accepted before 14:00; the
      10:00 observation expires at 11:00. Load a 6h staleness bound on restart: no return.
      A qualifying pass at 14:00 yields a rate at the same price. Both relevant windows are
      sufficiently populated, so thinness does not decide the trace. Keep the incident open,
      outage maximum later than the trace, active tenant, live unfenced machine, open funding
      episode and eligible cancellation at 14:05 with no competing operation hold. Leave
      commitment insufficient and admit no extension. At the fence transaction only
      [14:00,14:05) contributes: 300 of 3600 seconds spent, 3300 remaining. Assert ordinary
      short deferral, no fence/provider call and episode still open. No part of [11:00,14:00)
      was usable grace. With continuous rate presence, eligible claims short-defer until 15:00;
      the first at or after 15:00 may cancel. A further outage pauses the remaining measure.
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
      and says so *structurally*: `network_restriction.status` reads `disabled` on the machine view
      and in every case rendering, `usage_debit` postings continue, the commitment decays,
      `runway_until` keeps moving, and `delete` on that machine is accepted. **No assertion about
      prose.** *Withdrawn clause:* "the case's `consequence` states the drain" — no conformance run
      can execute a judgement about whether a sentence says a thing. (`LDG-71`, `DOM-27`, `DOM-26`)
- [ ] **CNF-233** — `unknown` is never rendered as `none`. A machine whose driver reports no
      restriction signal reads `"status": "unknown"` with a null `observed_at`, and an operator
      recording is refused where the driver *does* report (`409` `state`). A field that is silently
      `none` when nobody looked is worse than no field. (`PRV-35`, `WIR-47`)
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
      cadence — receives zero `429`s over a sustained run. **The invariant is the test**, because
      any fixed rate-limit number stops being tested the day the fleet grows. (`API-50`)
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
      starts there.** A machine recorded billable at Jan 31 23:59:30Z whose first tick is Feb 1
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
- [ ] **CNF-162** — **REWRITTEN.** The setup fee follows `LDG-39`'s table: debited **on confirmed
      acceptance** and the commitment decremented in the **same transaction** (kill the process
      between them and neither survives); **released in full** on deterministic rejection and on
      resolved-absent — **except a fee the provider's transaction shows was charged for a matched
      order whose machine is gone, which becomes an `unrecoverable_setup_fee` deficiency in the
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

- [ ] **CNF-166** — A create against an offer with no declared cancellation bound is refused
      before any provider call, and a create against one with a bound opens a commitment sized to
      that bound, which the machine's actual date then **lowers `protected_sats` against rather
      than resizing** (`PRV-31`, `LDG-33`). (`PRV-31`,
      `PRV-13c`, `LDG-12`)

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

## Before production

Beyond the checklist, a deployment must state every parameter on `OVR-19`'s register — the human
items (the `needs_reconciliation` rota, the recovery-key inventory) included — and startup must
refuse to run on a missing or out-of-range startup-validated row. *This section carried its own list
of thirteen until 2026-09-08; it was a second copy of the register, and it had drifted.*
