# 10 — Conformance checklist

What an implementation must demonstrate before it touches a real provider account. Each
item names the requirement it proves and is written so it can become a test.

The reference implementation shipped with a CI job that ran a test suite containing zero
tests, and a green check next to it. Treat any unchecked box below as that same green
check.

## Build and gate

- [ ] **CNF-1** CI builds the project from a clean checkout, with no network-dependent
      manual steps. (`DEF-14`)
- [ ] **CNF-2** The declared lint gate passes on the declared source at the declared
      strictness. If the gate is warnings-as-errors, there are no warnings. (`DEF-15`)
- [ ] **CNF-3** The test suite fails when a test is deliberately broken — verified once,
      by hand, so that "tests passed" means something. (`DEF-16`)

## Tiering — which of these gate what

An untiered checklist is an unbounded commitment. These tiers gate *launch*; they do not forbid
doing a cheap item early. Several PRE-SCALE items are hour-sized — do them when convenient, just
don't let them block.

### The rule

For each item, name the concrete production event where its test would fail. Then ask:

1. **Can the operator undo it** with money, a redeploy, or an apology?
2. **Would the operator even know it happened** without this control?
3. **Can an autonomous retrying caller trigger it** with no human in the loop?

**BLOCKING** — "no" to (1); or "no" to (2) where the hidden harm is irreversible; or "yes" to
(3) for any provider mutation. The irreversible families are **destroyed data** (wrong disk
written, wrong machine deleted), **escaped secret** (provider credential, rescue key, machine
root password — a leak outlives the incident), **money out** (duplicate order, unbounded
ordering, unstoppable billing), and **boundary crossed** (tenant→tenant, public
surface→credentials).

Question 3 is why ambiguity handling is a *destruction* safeguard here rather than an
ergonomics feature: the caller is an AI that retries on its own initiative, so "misclassified
ambiguous create" and "double purchase" are the same item.

**PRE-SCALE** — failures the operator personally absorbs at concierge scale, by watching every
operation, reading every provider invoice line, and using `psql`. They stop being absorbable
when attention stops scaling. **The trigger is whichever comes first:** five external tenants;
the first customer the operator does not personally know; concurrent installs becoming routine;
or the operator no longer reading every operation and every invoice line.

**DEFERRED** — recoverable annoyance, or a guard for a deployment shape that does not currently
exist.

The rule *generates* items as well as sorting them. Applied honestly it demanded a conformance
item for `OVR-10a`, which had none — that is `CNF-71`–`CNF-75` below.

### Assignments

**BLOCKING** — `CNF-1`, `CNF-3` (the epistemic pair: every other checkmark is testimony from
this witness); `CNF-4`–`CNF-9` (tenancy — three internal tenants exist from day one, so
cross-tenant control is takeover plus destruction before any external customer arrives);
`CNF-10`–`CNF-13` (injection — path injection reaches the wrong machine in the operator's whole
account, shell metacharacters reach root on the rescue system); `CNF-14`–`CNF-17` (redaction —
create responses carry machine root passwords, rescue passwords are root on customer machines);
`CNF-19`, `CNF-20` (capability gating, the enforcement direction); `CNF-21`–`CNF-23`, `CNF-25`,
`CNF-26`, `CNF-27`, `CNF-28`, `CNF-29`, `CNF-31` (create and ambiguity rows), `CNF-32`
(idempotency and double-mutation — the money-out core; `CNF-32` is `OVR-5`, the spec's
self-declared most important property); `CNF-36`–`CNF-38`, `CNF-40`, `CNF-41`, `CNF-43`,
`CNF-44`, `CNF-46` (rescue safety); `CNF-49`–`CNF-51`, `CNF-53` (image supply chain — each ends
in an attacker-supplied image written to a customer's disk); `CNF-54`, `CNF-55`, `CNF-63`,
`CNF-64`, `CNF-69` (money-out gates, including the term-billing honesty pair — "deleted but
still billing" is unbounded operator money-out); `CNF-71`–`CNF-75` (the `OVR-10a` boundary,
which in the single-component form is the only structural defence there is).

**PRE-SCALE** — `CNF-2` (lint: hygiene, not harm — free, so do it early, but it gates nothing),
`CNF-18`, `CNF-24`, `CNF-30`, `CNF-31` (the remaining rows), `CNF-33`, `CNF-34` (becomes
blocking the moment anything but the API writes the store), `CNF-35`, `CNF-39`, `CNF-42`,
`CNF-45`, `CNF-47`, `CNF-48`, `CNF-52`, `CNF-56`–`CNF-60` (`CNF-58` must land before any
rolling deploy or version skew exists), `CNF-61`, `CNF-65`, `CNF-70`.

**DEFERRED** — `CNF-62` (separate audit destination: tamper-resistance maturity; no adversary
model requires it below the PRE-SCALE trigger).

**N/A UNTIL SPLIT** — `CNF-66`–`CNF-68`. These are conditional on the admin-plus-override front
service, which the single-component form of `OVR-10` deletes. Marked this way rather than
deferred so they resurrect automatically if the architecture ever splits.

### Tiering the other 234 requirements — first pass

The same three questions apply. This pass is at *area* level with named exceptions, because an
honest per-item verdict on 234 requirements needs a target deployment in front of you. Treat it
as a starting sort, not a ruling.

**Blocking as a whole area** — the safety spine, where a first pass is safe because almost
everything in them is irreversible:

- **`SEC-*` (42 items).** The entire namespace. Every one guards a family in the irreversible
  list. Exceptions that are genuinely PRE-SCALE: `SEC-30`/`SEC-31` (rate limiting and
  starvation — a queue with one tenant cannot starve anyone), `SEC-33` (separate audit sink),
  `SEC-38` (rotation procedures, needed before the first credential ages out rather than before
  the first customer).
- **`RSC-*` (37 items).** Rescue writes to disks and holds root credentials. `RSC-31` (partition
  growth), `RSC-33`/`RSC-34` (preflight capture) are the plausible PRE-SCALE exceptions.
- **`PRV-6`, `PRV-9`–`PRV-13c`, `PRV-17`, `PRV-22`.** Injection, key-material timing, deletion
  semantics, rescue credential handling, ambiguity honesty.
- **`OPS-1`–`OPS-23`.** The uncertainty model is the product's most valuable property and it
  is a money-out control, not an ergonomics one.
- **`OVR-5`, `OVR-9`, `OVR-10`, `OVR-10a`, `OVR-10b`, `OVR-12`.**
- **`DOM-6`, `DOM-10`, `DOM-13`, `DOM-14`, `DOM-17`–`DOM-19`.** Redaction, capability gating,
  strategy/image pairing, digest requirement, error taxonomy, cancellation honesty.
- **`API-7`–`API-19`, `API-24`, `API-25`, `API-30`, `API-31`.** Auth ordering, idempotency,
  validation, acknowledgements, authorization, error mapping, message hygiene.
- **`STO-1`–`STO-5`, `STO-8`, `STO-8a`, `STO-9`, `STO-15`.** The transactional primitives the
  queue depends on, plus tombstone honesty and credential-grade storage.
- **Every `DEF-*`.** They are prohibitions derived from defects that actually shipped.

**PRE-SCALE** — real requirements the operator absorbs by paying attention: `API-23`, `API-26`,
`API-28`, `API-29` (listing, pagination, correlation ids, unauthenticated rate limits);
`OPS-24`–`OPS-26` (fairness, retention, operator listing); `STO-12`–`STO-14`, `STO-16`
(migration tooling, retention, backup handling); `SEC-32` (audit records, once more than one
person acts); `OVR-13`; `DOM-9`, `DOM-11`, `DOM-12`, `DOM-15`, `DOM-16`.

**DEFERRED** — guards a shape that does not exist yet, or is recoverable: `PRV-24`, `PRV-25`
(iPXE and reverse DNS, if those capabilities are not in v1); `RSC-30`'s two-pass *default* if
`D5` chooses single-pass deliberately; `API-21`, `API-22` presentation details; anything
governing providers not shipping in v1.

**The honest caveat.** Blocking still dominates, and that is the shape of a
destructive-operations product rather than a failure of the sort. If the blocking set is
uncomfortably large, the lever is **narrowing v1's capability surface** — fewer providers, no
rescue, no self-serve — not lowering the bar on the capabilities you keep. Cutting a capability
removes its requirements honestly; deferring a safety requirement for a capability you ship
does not.

### The honest finding about this exercise

Tiering buys less relief than expected: roughly 44 of 75 land blocking. That is not tier
inflation. This checklist was distilled from the defect list of a discarded implementation of a
destructive-operations product, so it was already the sharp end. **The real relief lives in
tiering the full requirement set**, where the deferrable long tail actually is — pagination,
notification surfaces, operational polish. Apply the same three questions there and expect the
blocking fraction to be far lower.

## Architecture boundary

Applies to the single-component form of `OVR-10`. In that form these replace the network
isolation the separate-service form provides, so they are not optional hardening — they are the
only structural defence there is.

- [ ] **CNF-71** A provider credential cannot be read from the customer-facing layer, and the
      guarantee is enforced by the code rather than by convention. Prove it the way the
      language allows: in Rust, the credential-owning type is private to the internal module and
      reachable only through a trait that does not expose it, demonstrated by a **compile-fail
      test** asserting that external-layer code referencing it does not build. A comment saying
      "do not use this here" is not a proof. (`OVR-10a`)
- [ ] **CNF-72** A static tripwire fails CI when a new import, re-export, or `pub` visibility
      change makes the credential type reachable from the customer-facing layer. The boundary
      must fail closed as the code grows; the compile-fail test of `CNF-71` proves today's
      state, this proves tomorrow's. (`OVR-10a`)
- [ ] **CNF-73** The customer-facing layer holds no provider credential and the lifecycle layer
      holds no customer credential or payment material. Assert on the types each layer's
      constructors accept, not on runtime values. (`OVR-10b`)
- [ ] **CNF-74** Operator-only routes — requeue above all, since it can re-issue a purchase
      (`API-19`, `OPS-20`) — are not served on the customer-facing listener. (`API-27`)
- [ ] **CNF-75** The deployment recorded which `OVR-10` form it chose. An unrecorded choice
      means later reviewers cannot tell which requirements apply.

## Tenancy and authorization

- [ ] **CNF-4** Tenant A cannot read, refresh, power, install on, or delete tenant B's
      machine; every attempt returns `404`, never `403`. (`API-17`, `SEC-8`)
- [ ] **CNF-5** Adoption without entitlement proof is rejected. Specifically: a tenant
      naming a valid provider account and a valid external identifier it is not entitled
      to gets an error, not a machine. (`API-18`, `SEC-7`, `DEF-1`)
- [ ] **CNF-6** Two tenants cannot both hold a record for the same external machine.
      (`SEC-10`)
- [ ] **CNF-7** A non-admin token's tenant-override header is ignored, not honoured.
      (`API-5`, `SEC-9`)
- [ ] **CNF-8** An unauthenticated request to every write endpoint is rejected before any
      body validation error can be observed. (`API-7`, `DEF-4`)
- [ ] **CNF-9** Requeue is refused for a tenant token. (`API-19`)

## Injection

- [ ] **CNF-10** An `external_id` of `1/../../other/endpoint` produces a request to the
      intended endpoint path, or is rejected outright. Assert on the constructed URL, not
      on the response. (`PRV-6`, `DEF-2`)
- [ ] **CNF-11** An `external_id` containing `?` or `#` does not inject a query string or
      truncate the path. (`PRV-6`)
- [ ] **CNF-12** Hostname, device path, digest, image URL, key material, and post-install
      script each containing shell metacharacters produce a remote script in which those
      values appear only base64-encoded. Assert on the generated script text. (`RSC-15`,
      `SEC-12`)
- [ ] **CNF-13** Installer-config fields containing CR, LF, NUL, or whitespace are
      rejected. (`RSC-23`, `SEC-13`)

## Redaction

- [ ] **CNF-14** A provider payload containing keys named `password`, `secret`,
      `private_key`, `token`, `api_key`, `authorization`, and `credential` — nested inside
      objects and arrays — is redacted before storage. (`DOM-6`)
- [ ] **CNF-15** A **successful** provider response that the driver cannot interpret is
      redacted before it reaches the operation error. (`DOM-18`, `SEC-4`, `DEF-3`)
- [ ] **CNF-16** No log line, operation result, or operation error in the whole test suite
      contains a rescue password or a private key. Assert by scanning captured output.
      (`SEC-3`)
- [ ] **CNF-17** Debug formatting of the rescue session type does not reveal the
      credential. (`DOM-11`)

## Capability model

- [ ] **CNF-18** For every driver, every declared capability has a working code path, and
      every implemented operation has its capability declared. Table-driven, one case per
      (driver, capability) pair. (`DOM-15`, `PRV-4`)
- [ ] **CNF-19** Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
- [ ] **CNF-20** Every operation on a driver that declares nothing returns `unsupported`,
      not a panic and not a wrong default. (`PRV-2`)

## Idempotency

- [ ] **CNF-21** Same key, byte-equivalent body, twice: one operation, both responses
      identical. (`API-11`)
- [ ] **CNF-22** Same key, different body: `409`, and no second operation exists.
      (`API-11`)
- [ ] **CNF-23** Same key, different tenants: two independent operations, neither
      observable by the other, and no internal error. (`API-10`)
- [ ] **CNF-24** Semantically identical bodies differing only in JSON key order do not
      produce a spurious conflict. (`API-12`)
- [ ] **CNF-25** Requeue with the same key twice enqueues the work once. (`OPS-18`)

## Operation lifecycle

- [ ] **CNF-26** Two workers racing to claim one queued operation: exactly one wins.
      (`OPS-5`)
- [ ] **CNF-27** Two operations on one machine: the second is deferred back to `queued`,
      not failed, and runs after the first releases. (`OPS-8`, `OPS-9`)
- [ ] **CNF-28** A worker whose lease is stolen mid-flight abandons its work and does not
      write a terminal state. (`OPS-3`, `OPS-7`)
- [ ] **CNF-29** A `running` operation whose lease expires is swept to
      `needs_reconciliation` — never back to `queued`. (`OPS-14`)
- [ ] **CNF-30** The sweeper does not overwrite an error already recorded. (`OPS-16`)
- [ ] **CNF-31** The full classification table in `OPS-11` is covered, one case per row.
      In particular: a create failing with a provider 4xx is `failed`; a create failing
      with a provider 5xx, a network error, or a timeout is `needs_reconciliation`.
- [ ] **CNF-32** Nothing in the system retries an ambiguous mutation. Assert by counting
      driver invocations across a failure scenario. (`OPS-12`, `SEC-27`)
- [ ] **CNF-33** An operation is executed correctly after a full process restart between
      enqueue and claim. (`OPS-2`, `STO-5`)
- [ ] **CNF-34** Validation is enforced in the worker even when the stored request bypasses
      the API layer. (`OPS-23`)
- [ ] **CNF-35** `GET /v1/operations?status=needs_reconciliation` returns them, paginated.
      (`API-23`, `DEF-8`)

## Rescue and installation

- [ ] **CNF-36** Every row of the host-key decision table in `RSC-3` is covered, including
      the two abort cases: no keys and no opt-in; and caller keys that do not overlap
      driver keys.
- [ ] **CNF-37** A pinned connection is never downgraded to first-use trust, including
      when the driver returns an empty key set on a later refresh. (`RSC-5`, `PRV-20`)
- [ ] **CNF-38** Host-key comparison is canonical: the same key with a different comment,
      a leading host pattern, or extra whitespace compares equal; a different key does
      not. (`RSC-6`)
- [ ] **CNF-39** The host-key wait deadline scales with the configured boot timeout.
      (`RSC-9`, `DEF-5`)
- [ ] **CNF-40** A rescue password never appears in a command line. Assert on the spawned
      process's argument vector. (`RSC-11`)
- [ ] **CNF-41** The generated installer config disables copying rescue authorized keys
      into the installed system. (`RSC-12`)
- [ ] **CNF-42** A rootfs install with no authorized keys is rejected; a raw-disk install
      *with* authorized keys is rejected. (`RSC-13`, `RSC-14`)
- [ ] **CNF-43** A digest mismatch on the rootfs path aborts before the installer runs.
      (`RSC-25`)
- [ ] **CNF-44** A digest mismatch on the raw-disk path produces an `integrity` error and
      routes to `needs_reconciliation`. (`RSC-29`, `OPS-11`)
- [ ] **CNF-45** On uncertain rescue exit, the recovery key is persisted and its path,
      with the rescue address and port, appears in the operation error. (`RSC-19`)
- [ ] **CNF-46** The recovery directory is created owner-only. (`RSC-20`)
- [ ] **CNF-47** The preflight report is attached to the operation result, and an
      unparseable report is captured raw rather than dropped. (`RSC-33`, `RSC-34`)
- [ ] **CNF-48** A 90-minute install does not lose its lease. Simulated with compressed
      timers. (`RSC-37`)

## Image policy

- [ ] **CNF-49** A non-HTTPS URL is rejected unless insecure HTTP is explicitly enabled.
      (`API-13`, `SEC-18`)
- [ ] **CNF-50** URLs with embedded credentials or a fragment are rejected. (`SEC-18`)
- [ ] **CNF-51** `*.example.com` matches `a.example.com` but not `example.com`, and
      matching is case-insensitive. (`SEC-20`)
- [ ] **CNF-52** An empty allowlist logs a loud startup warning. (`SEC-19`)
- [ ] **CNF-53** A redirect from `https` to `http` is refused by the remote fetch itself.
      (`RSC-17`)

## Acknowledgements

- [ ] **CNF-54** Install without the destructive acknowledgement is rejected; delete
      without it is rejected. (`API-14`)
- [ ] **CNF-55** Create against an order-billed provider is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. (`API-15`,
      `PRV-10`)

## Persistence

- [ ] **CNF-56** Connection-scoped settings are asserted on a freshly checked-out pooled
      connection, not on the one that ran migrations. (`STO-7`, `DEF-12`)
- [ ] **CNF-57** Migrations are version-tracked and re-running them is a no-op. (`STO-12`)
- [ ] **CNF-58** An unrecognized status read from the store is a hard error. (`STO-10`)
- [ ] **CNF-59** A deleted machine is tombstoned, and operations referencing it still
      resolve. (`STO-8`)
- [ ] **CNF-60** The operation view never contains the stored request payload. (`API-21`)

## Deletion semantics

- [ ] **CNF-63** For a driver in `PRV-13`'s scheduled-cancellation shape, the action result
      carries the effective cancellation date, and it is not assumed to be "now." (`PRV-13`)
- [ ] **CNF-64** A machine with a future cancellation date is recorded
      `cancellation_scheduled`, not `deleted`, and is **not** tombstoned until that date
      passes. Assert it still appears in inventory queries that exclude deleted rows.
      (`DOM-19`, `STO-8a`)
- [ ] **CNF-65** Every billable attachment the provider API can delete has an exposed cleanup
      path, and the driver's notes name the ones it cannot reach. (`PRV-13a`)

## Ceilings for autonomous callers

- [ ] **CNF-69** A principal that sets every acknowledgement flag on every request still cannot
      exceed its destruction, creation, imaging or spend ceiling. Drive it with a loop that
      acknowledges everything and assert the ceiling stops it. (`SEC-39`)
- [ ] **CNF-70** The deployment has recorded *where* ceilings are enforced, and if that is the
      front service rather than the control plane, the record says so explicitly. (`SEC-40`)

## Front-service tenancy boundary

Applies only to deployments using the admin-plus-override proxy pattern.

- [ ] **CNF-66** The deployment has chosen one of `API-30`'s three options and recorded which.
      If "accept and document," the record explicitly states that `CNF-4`–`CNF-7` prove nothing
      about the front service.
- [ ] **CNF-67** If per-tenant signing was chosen: a forwarded request whose override does not
      match its signature is rejected. If an allowlist was chosen: an override outside the
      allowlist is rejected, and `DOM-1` has been amended. (`API-30`)
- [ ] **CNF-68** The front service's own audit log attributes each action to a customer and
      joins to the control plane's records by correlation id. (`API-31`, `API-28`)

## Audit

- [ ] **CNF-61** Every mutating request produces an audit record with correlation id,
      identity, admin-override target if any, operation id and kind, machine, and outcome.
      (`SEC-32`)
- [ ] **CNF-62** Audit records go to a destination separate from the operation store.
      (`SEC-33`)

## Before production

Beyond the checklist, the following are judgement calls a deployment must make
explicitly and record:

1. Which adoption entitlement mechanism is in force (`API-18`).
2. Whether first-use trust is permitted at all, and for which providers (`SEC-24`).
3. Whether the raw-disk path runs in single-pass or two-pass mode (`RSC-30`).
4. What the image host allowlist is (`SEC-19`).
5. Which provider accounts may order, and what the spend ceiling is (`DOM-16`).
6. Who is on the rota for `needs_reconciliation`, and what the response procedure is
   (`OPS-26`).
7. Where persisted recovery keys are inventoried and how they get destroyed (`RSC-21`).
