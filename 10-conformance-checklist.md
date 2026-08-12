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

**BLOCKING** (50 items) — `CNF-1`, `CNF-3` (the epistemic pair: every other checkmark is testimony from
this witness); `CNF-4`–`CNF-9` (tenancy — three internal tenants exist from day one, so
cross-tenant control is takeover plus destruction before any external customer arrives);
`CNF-10`–`CNF-13` (injection — path injection reaches the wrong machine in the operator's whole
account, shell metacharacters reach root on the rescue system); `CNF-14`–`CNF-17` (redaction —
create responses carry machine root passwords, rescue passwords are root on customer machines);
`CNF-19`, `CNF-20` (capability gating, the enforcement direction); `CNF-21`–`CNF-23`, `CNF-25`,
`CNF-26`, `CNF-27`, `CNF-28`, `CNF-29`, `CNF-31a` (the create and ambiguity rows only — see the split below), `CNF-32`
(idempotency and double-mutation — the money-out core; `CNF-32` is `OVR-5`, the spec's
self-declared most important property); `CNF-36`–`CNF-38`, `CNF-40`, `CNF-41`, `CNF-43`,
`CNF-44`, `CNF-46` (rescue safety); `CNF-49`–`CNF-51`, `CNF-53` (image supply chain — each ends
in an attacker-supplied image written to a customer's disk); `CNF-54`, `CNF-55`, `CNF-63`,
`CNF-64`, `CNF-69` (money-out gates, including the term-billing honesty pair — "deleted but
still billing" is unbounded operator money-out); `CNF-71`–`CNF-75` (the `OVR-10a` boundary,
which in the single-component form is the only structural defence there is).

**PRE-SCALE** — `CNF-2` (lint: hygiene, not harm — free, so do it early, but it gates nothing),
`CNF-18`, `CNF-24`, `CNF-30`, `CNF-31b` (the remaining rows), `CNF-33`, `CNF-34` (becomes
blocking the moment anything but the API writes the store), `CNF-35`, `CNF-39`, `CNF-42`,
`CNF-45`, `CNF-47`, `CNF-48`, `CNF-52`, `CNF-56`–`CNF-60` (`CNF-58` must land before any
rolling deploy or version skew exists), `CNF-61`, `CNF-65`, `CNF-70`.

**DEFERRED** — nothing, after audit. `CNF-62` (separate audit destination) was listed here
while the area sort below calls its parent `SEC-33` PRE-SCALE; the area sort is right, so
`CNF-62` is **PRE-SCALE**. Likewise `CNF-60` is PRE-SCALE while `API-21`, which it tests, was
sorted DEFERRED — `API-21` is corrected to PRE-SCALE.

**N/A UNTIL SPLIT** — `CNF-66`–`CNF-68`. These are conditional on the admin-plus-override front
service, which `ADR-0001` deletes by choosing the single component. Marked this way rather than
deferred so they resurrect automatically if the architecture ever splits.

### Assignments for `CNF-76`–`CNF-115` (added 2026-08-11)

These cover enrolment, reconciliation, the ledger and blast radius. **The ledger items are
disproportionately BLOCKING for one reason: under `ADR-0002` a prepaid balance is the only thing
that authorizes spending, so a ledger bug is an authorization bug, not an accounting one.**

**BLOCKING** — `CNF-78`, `CNF-81` (an unfunded or privilege-escalated tenant is money-out and
boundary-crossed); `CNF-82`, `CNF-84`, `CNF-85`, `CNF-86`, `CNF-87` (reconciliation correctness —
a wrong attach hands one customer another's machine, and `CNF-87` is the difference between a
frozen balance and a released one); `CNF-83` (a linkable value written into a provider console
cannot be un-disclosed); `CNF-91`–`CNF-97` (ledger integrity, i.e. authorization integrity);
`CNF-100` (destroyed data, and the documentation half is what makes it survivable); `CNF-101`
(the insolvency gate, including that it must not block the operations that reduce exposure);
`CNF-106` (under-holding every machine by exactly the margin); `CNF-107` (tenant→tenant
destruction — this was `F15`); `CNF-108`, `CNF-109` (unbounded billing and duplicate purchase);
`CNF-111`, `CNF-112` (an account termination cannot be undone with money or an apology, and
`CNF-112` is what makes `CNF-111` real rather than believed).

**PRE-SCALE** — `CNF-76`, `CNF-77`, `CNF-79`, `CNF-80`, `CNF-88`, `CNF-89`, `CNF-90`, `CNF-98`,
`CNF-99`, `CNF-102`–`CNF-105`, `CNF-110`, `CNF-113`–`CNF-115`.

**DEFERRED** — none.

### Assignments for `CNF-116`–`CNF-131` (added 2026-08-12)

The funding items, for `ADR-0008`'s two rails. Applying the three questions honestly puts almost
all of them in the top tier, and the reason is structural rather than pessimistic: **money-in is
the only path where a bug creates satoshis instead of moving them.** Everywhere else in this
specification the worst case is that the operator pays for a machine; here the worst case is that
the ledger records value the operator never received, and `LDG-17` then reports solvency against
a float that is partly fictional. The operator cannot undo it, would not know, and an autonomous
caller that retries reaches it by accident.

**BLOCKING** — `CNF-116`, `CNF-117`, `CNF-118`, `CNF-119` (each one credits satoshis that were
not received, or refuses satoshis that were); `CNF-120` (a shared destination credits one
customer's payment to another); `CNF-121` (both halves: minting a fresh deposit per retry makes a
caller pay twice for one top-up); `CNF-123`, `CNF-124` (the two ways a real payment is
irrecoverably lost or silently doubled); `CNF-125` (without it, enrolment cannot complete and the
product does not exist); `CNF-128` (closing a deposit on first settlement strands the second
payment, and `ADR-0004` forbids returning it); `CNF-129` (a watch set that does not survive
restart loses real customers' money, and **raises no error while doing it** — the operator would
not know); `CNF-131` (the disclosure is the only thing standing between a customer and an
unwatched address, so an implementation that omits it has no control at all, not a weak one).

**PRE-SCALE** — `CNF-122`, `CNF-126`, `CNF-127`, `CNF-130`.

**DEFERRED** — none.

`CNF-130` is PRE-SCALE rather than BLOCKING on the argument that an unbounded watch set degrades
service rather than losing money — **which is the same argument that put `CNF-99` in the wrong
tier** (`F30`). It is recorded here so that whoever re-tiers `CNF-99` re-examines this one in the
same pass.

### Assignments for `CNF-132`–`CNF-137` (added 2026-08-12)

**BLOCKING** — all six. Applying the three questions to key custody gives the same answer every
time, and it is worth saying why rather than asserting it. The operator cannot undo a drained
float: there is no chargeback, no insurance and no counterparty. They would not know until the
solvency check fails, by which point the money is gone. And `CNF-136` is here for the opposite
reason — it is not a money-loss test at all, it is the test that keeps `SEC-51`'s manual refill
from turning every exhausted channel into a sales outage, which is the failure most likely to make
an operator quietly re-introduce the hot key `ADR-0009` removed.

`CNF-137` is additionally a **before production** item: a recovery procedure that has never been
run is a belief about a procedure.

### Assignments for `CNF-138`–`CNF-143` (added 2026-08-12)

**BLOCKING** — `CNF-138`, `CNF-139`, `CNF-141` (each one is a path to a wrong fleet-wide price, and
`LDG-14` turns a sufficiently wrong price into a destroyed disk — the operator cannot undo it and
would not know until a customer complains); `CNF-142` (a settable source list is a second front
door onto every price in the system).

**PRE-SCALE** — `CNF-140`, `CNF-143`. `CNF-140` is the ordinary case `CNF-141` covers the hard
version of; `CNF-143` is a configuration review rather than a test, and **independence cannot be
verified by any code**, which is worth stating plainly rather than pretending the checklist
proves it.

### Assignments for `CNF-144`–`CNF-148` (added 2026-08-12)

**BLOCKING** — `CNF-147` (it is the only item that runs the dedicated money path against a real
machine, and every requirement it touches was written without ever having been executed);
`CNF-148` (an unverified provider fact underneath the reconciliation design — the same class of
belief `F1` was closed on).

**PRE-SCALE** — `CNF-144`, `CNF-145`, `CNF-146`. These protect the contract's generality, which
degrades slowly and visibly rather than losing money; `CNF-145` is the one to run first, because
the leak it catches gets harder to reverse the longer it sits.

The blocking set moves from 73 to **98**.

That is 23 more BLOCKING items, taking the blocking set from 50 to 73. **This is the honest cost
of the 2026-08-11 decisions** and it should be read as such: choosing self-serve enrolment and a
prepaid balance did not merely add features, it added a money system whose correctness gates
launch. A reader deciding whether that trade was worth it now has the number.

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

Tiering buys less relief than expected: 50 of 75 land blocking. That is not tier
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
- **CNF-31** — **SPLIT 2026-08-09** into `CNF-31a` and `CNF-31b`. The original conflated two
      different stakes: rows where a misclassification causes a repeated provider mutation, and
      rows that only need covering for exhaustiveness. They belong in different tiers, and the
      undivided item was consequently listed in two of them. Identifier retained rather than
      reused, per the append-only convention in the README.
- [ ] **CNF-31a** The rows of `OPS-11` where a misclassification causes a repeated provider
      mutation. A create failing with a provider 4xx is `failed`; a create failing with a
      provider 5xx, a network error, or a timeout is `needs_reconciliation`; every install
      failure that is not a deterministic caller error is `needs_reconciliation`. Getting these
      wrong invites the caller to retry a mutation that already happened.
- [ ] **CNF-31b** The remaining rows of `OPS-11`, for exhaustiveness — including that the table
      is *total*: every error kind in `DOM-17` has a defined classification for every operation
      kind, with no implicit default.
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
      allowlist is rejected, and `DOM-1a`'s registry branch was selected. (`API-30`)
- [ ] **CNF-68** The front service's own audit log attributes each action to a customer and
      joins to the control plane's records by correlation id. (`API-31`, `API-28`)

## Audit

- [ ] **CNF-61** Every mutating request produces an audit record with correlation id,
      identity, admin-override target if any, operation id and kind, machine, and outcome.
      (`SEC-32`)
- [ ] **CNF-62** Audit records go to a destination separate from the operation store.
      (`SEC-33`)

## Enrolment and credentials

- [ ] **CNF-76** Enrolment returns no usable credential before the configured delay elapses,
      and the not-yet response does not disclose the remaining time precisely. (`API-33`)
- [ ] **CNF-77** An unfunded pending tenant is deleted at its TTL together with its credential.
      Verified by clock advance, not by reading the code. (`API-34`)
- [ ] **CNF-78** A pending tenant can perform no authorized action of any kind until a payment
      has been credited. (`API-35`)
- [ ] **CNF-79** Enrolment rate-limiting state is never persisted — no caller address reaches
      the store or the logs. (`API-36`, `ADR-0005`)
- [ ] **CNF-80** The `tenants` table holds no column beyond those specified. Asserted by a schema
      test that **fails when a column is added**, because the way a privacy policy dies is one
      harmless-looking column. (`STO-21`)
- [ ] **CNF-81** Operator credentials still come only from the environment, and no runtime-issued
      customer credential can become one. (`API-4`)

## Reconciliation and correlators

- [ ] **CNF-82** A create writes the operation id into the provider's caller-controlled field
      **in the same request that performs the mutation** — verified against a recorded provider
      request, not against a follow-up call. (`PRV-26`)
- [ ] **CNF-83** The correlator carries no tenant identifier, customer-chosen hostname, or other
      linkable value. Anyone reading the operator's provider console learns nothing. (`PRV-26`,
      `ADR-0005`)
- [ ] **CNF-84** Resolution attaches a resource only on an **exact** correlator match. A machine
      matching on hostname, offer and creation window but carrying no correlator is left
      unresolved, not attached. (`OPS-29`)
- [ ] **CNF-85** Resolution performs no mutation. A driver whose search path mutates fails this
      item. (`OPS-28`)
- [ ] **CNF-86** A sweep does not claim a resource whose operation is still `running` under a
      live lease. (`OPS-30`)
- [ ] **CNF-87** A hold is released once the negative window elapses, even though the operation
      remains open, and the sweep keeps searching afterwards. (`OPS-33`)
- [ ] **CNF-88** The account-wide sweep reports an unclaimed machine to the operator and attaches
      it to no tenant. (`OPS-32`)
- [ ] **CNF-89** Resolution columns are write-once; a second resolution of the same record is
      refused. (`STO-19`)
- [ ] **CNF-90** An order-shaped driver records the provider's transaction identifier **before**
      the outcome can be classified ambiguous. (`PRV-27`)

## Ledger and money

- [ ] **CNF-91** No floating-point type appears anywhere in a money path. Asserted at the type
      level, not by inspection. (`LDG-1`)
- [ ] **CNF-92** Adding two amounts with different currency codes is refused — never silently
      converted. (`LDG-3`)
- [ ] **CNF-93** The ledger has no update or delete path at the storage layer. Attempting one
      fails; convention is not the control. (`LDG-5`, `STO-22`)
- [ ] **CNF-94** A replayed top-up notification carrying the same idempotency key credits exactly
      once. (`LDG-8`)
- [ ] **CNF-95** A create whose available balance is one satoshi short is rejected and **no
      provider call is made**. (`LDG-9`, `LDG-12`)
- [ ] **CNF-96** A hold and its operation are written in one transaction: killing the process
      between them leaves neither. (`LDG-11`, `STO-23`)
- [ ] **CNF-97** No sequence of concurrent operations can drive a balance negative. (`LDG-10`)
- [ ] **CNF-98** Remaining runway is readable from the machine view before exhaustion.
      (`LDG-15`)
- [ ] **CNF-99** A single adverse rate read cannot cancel a machine: the deficiency must persist
      across derivations and the per-tick increase is capped. (`PRV-13e`, `LDG-16`)
- [ ] **CNF-100** At end of runway the machine is cancelled and its disk destroyed — and the
      caller-facing documentation says so in words. (`LDG-13`, `LDG-14`)
- [ ] **CNF-101** Under a failing solvency check, every bill-increasing operation is refused
      while cancel and delete continue to work. **The operations that reduce exposure are never
      gated by the check that fires because exposure is too high.** (`LDG-20`)
- [ ] **CNF-102** The ledger contains no caller address, payment counterparty, preimage or ecash
      token. (`LDG-21`)
- [ ] **CNF-103** Retention never deletes a ledger entry. (`LDG-22`, `STO-24`)
- [ ] **CNF-104** Customer price is produced by exactly one function; no call site reads a
      provider price string directly. (`LDG-23`)
- [ ] **CNF-105** Privileged operations are metered although they are free. (`LDG-25`)
- [ ] **CNF-106** The reserve commits **customer** price for machine time and the setup fee **at
      cost** — a reserve computed from provider cost under-commits by exactly the margin.
      (`PRV-13b`)

## Funding

Added 2026-08-12 with `ADR-0008`. Every item here is a way to mint satoshis that do not exist or
to strand satoshis that do.

- [ ] **CNF-116** A payment settling for less than the requested amount credits the **settled**
      value. A credit derived from `deposits.requested_sats` is the defect — assert it
      at the call site, not by reading the number back. (`LDG-47`, `STO-29`)
- [ ] **CNF-117** An overpayment is credited in full and is never refused or truncated. (`LDG-47`)
- [ ] **CNF-118** No credit is posted for an unconfirmed on-chain transaction at any amount, and
      an RBF replacement that lowers the value before the stated depth results in the lower credit
      or none — never the original. (`LDG-48`)
- [ ] **CNF-119** An accepted-but-unsettled Lightning HTLC posts no credit. A held invoice that is
      later cancelled leaves the balance untouched. (`LDG-48`)
- [ ] **CNF-120** Two funding requests never produce the same destination on either rail, and two
      tenants never share one. (`LDG-49`)
- [ ] **CNF-121** Two funding requests from one tenant produce two distinct on-chain addresses;
      the same request retried with the same idempotency key produces **one deposit** — same
      invoice, same address. Both halves must hold — the first is the privacy rule, the second is
      the double-payment rule. (`LDG-50`, `API-45`)
- [ ] **CNF-122** A payment observed at an expired deposit's address, for a live tenant, is
      credited rather than refused. Expiry ends watching, not resolution. (`LDG-51`, `LDG-54`)
- [ ] **CNF-123** Deleting a pending tenant at its time-to-live leaves its deposits intact, and a
      later payment to one of them is recorded as unattributed rather than lost or dropped.
      (`STO-29`, `LDG-43`, `API-42`)
- [ ] **CNF-124** Killing the process between crediting the ledger and marking the destination
      settled leaves the payment credited exactly once after recovery — not twice, not zero times.
      Replaying the rail's settlement stream produces no second entry. (`STO-30`, `STO-31`)
- [ ] **CNF-125** A pending tenant can reach the funding endpoint and **only** the funding
      endpoint; every other authenticated endpoint answers `not_activated`. (`API-43`, `DOM-20`)
- [ ] **CNF-126** The solvency check counts channel balances and confirmed on-chain outputs, and
      the deployment's stated treatment of an encumbered channel balance is the one implemented.
      (`LDG-53`, `LDG-17`)
- [ ] **CNF-127** An on-chain payment below the floor that covers spending its own output is
      **credited at its received value, not refused** — and the floor was disclosed with the
      destination. A deposit is payable over either rail, so the floor cannot gate the mint.
      (`LDG-52`, `LDG-47`)
- [ ] **CNF-128** One deposit paid on **both** rails credits **both** payments. Settling the
      invoice does not stop the address being watched before expiry. This is the test that catches
      an implementation which closes a deposit on first settlement. (`LDG-55`, `LDG-56`)
- [ ] **CNF-129** The watch set survives a restart: deposits minted before the process died are
      still being watched after it comes back, and a payment to one of them is credited. Asserted
      by killing the process, not by reading the start-up code. (`STO-32`)
- [ ] **CNF-130** The watch set contains no expired deposit. Minting deposits at the rate limit
      for longer than the expiry window leaves the set bounded rather than growing. (`LDG-57`)
- [ ] **CNF-131** The funding response states, in words a customer would understand, that an
      expired address still accepts payments the operator will not see, and that paying twice
      credits twice with no refund. **The disclosure is the control** — there is no mechanism
      behind it. (`LDG-54`, `LDG-56`, `API-44`)

## Key custody

Added 2026-08-12 with `ADR-0009`. These are the first items that make `F13`'s "one compromise
takes the machines *and* the float" partly false.

- [ ] **CNF-132** No spending key or seed is reachable from the process — not in its environment,
      its configuration, its filesystem or any service it can call. Asserted by attempting to
      construct a spend from inside it and failing. **Type-level absence is not the test**;
      `CNF-71`'s weakness was proving visibility rather than reachability, and repeating it here
      would prove nothing about the money. (`SEC-48`, `F13`)
- [ ] **CNF-133** Address derivation and payment observation both work with watch-only material
      only. Removing everything but the extended public key breaks nothing in the funding path.
      (`SEC-48`, `LDG-50`, `LDG-57`)
- [ ] **CNF-134** The solvency check completes with no spending key present. (`LDG-53`, `LDG-17`)
- [ ] **CNF-135** Channel balance above the stated ceiling is swept to cold, and the sweep
      destination cannot be changed by any runtime input — configuration, API, environment or
      database write. Attempting to change it fails. (`SEC-49`, `SEC-50`)
- [ ] **CNF-136** With inbound capacity fully exhausted, a funding request still succeeds and the
      resulting deposit is payable on-chain. **This is the test that makes `SEC-51`'s manual
      refill survivable** — without it, an operator asleep is an operator not selling. (`SEC-51`,
      `LDG-46`)
- [ ] **CNF-137** The cold key's recovery procedure has been executed end to end, from backup to a
      signed spend, by someone other than whoever wrote it. Before the first customer payment.
      (`SEC-53`)

## The rate

Added 2026-08-12. Past the per-tick cap and the persistence rule, a wrong rate is the only
external input in this specification that reaches a customer's disk (`LDG-41`, `LDG-14`).

- [ ] **CNF-138** With every rate source unavailable, a create is refused, re-derivation halts
      **without** cancelling anything, the exhaustion sweep still runs, and the solvency check
      fails closed. All four, from one fault injection. (`LDG-40`, `LDG-59`)
- [ ] **CNF-139** No code path uses a rate older than the stated bound, and there is no
      last-known-good fallback anywhere. Asserted by removing every source and confirming the
      system reports *no rate* rather than a number. (`LDG-59`)
- [ ] **CNF-140** One source returning an extreme price does not move the rate, and that source is
      excluded rather than averaged in. (`LDG-60`)
- [ ] **CNF-141** Exclusions count against the quorum: with three sources, one stale and one
      outlying, the result is *no rate* — not a rate derived from the single survivor. **This is
      the item that catches an implementation which degrades quietly to one source.** (`LDG-59`,
      `LDG-60`)
- [ ] **CNF-142** The source set cannot be changed by any API call, tenant input, or database
      write. Attempting each fails. (`LDG-61`, and `CNF-135` for the same property applied to the
      sweep destination)
- [ ] **CNF-143** Two sources that are front-ends onto the same venue are configured, and the
      deployment's quorum treats them as one. **Independence is a claim about the world that no
      code can check**, so this is a review item against the configured list, not a runtime test.
      (`LDG-58`)

## The launch set

Added 2026-08-12 with `ADR-0010`. These test that three drivers made the contract *more* general
rather than acquiring a default.

- [ ] **CNF-144** No module under `core` names a provider, branches on one, or contains a constant
      that is any provider's commercial term. Asserted against the source, not by inspection of
      behaviour. (`OVR-14`, `OVR-15`, `PRV-13c`)
- [ ] **CNF-145** Removing the DigitalOcean driver from the build leaves the other two compiling
      and passing, and removing **both** Hetzner drivers leaves DigitalOcean compiling and
      passing. The second half is the real test — it is where an assumption shared by two drivers
      of one house style shows up as a dependency. (`OVR-15`)
- [ ] **CNF-146** `GET /v1/providers` reports three distinguishable capability sets, and a caller
      that acts only on what it reports never invokes an operation a provider does not have.
      (`OVR-16`, `OVR-2`)
- [ ] **CNF-147** The dedicated path is exercised end to end against a real Hetzner Robot machine:
      a setup fee debited before the order, a commitment sized to include cost through the
      earliest cancellation date, a cancellation that schedules rather than deletes, and billing
      that continues until the effective date. **The requirements this tests were all written
      before any of them had run.** (`LDG-39`, `PRV-13b`, `PRV-13c`, `DOM-19`)
- [ ] **CNF-148** `PRV-30`'s manual-processing claim has been verified against Hetzner Robot in
      writing, before the Robot driver is written. Until it is, the Robot correlator and the
      negative window derived from it are beliefs. (`F29`, `PRV-30`, `OPS-33`)

## Ownership, deletion and duplication

- [ ] **CNF-107** Two tenants cannot both hold the same `(provider_account, external_id)`. The
      constraint is enforced by the store, not by application code. (`STO-17`)
- [ ] **CNF-108** A machine with an unreleased billable attachment cannot be tombstoned.
      (`STO-18`)
- [ ] **CNF-109** An idempotency key reused after its operation was retained-out either returns
      the original or is refused — it never performs the mutation a second time. (`STO-25`)
- [ ] **CNF-110** A requeue preserves the previous error and the stated reason, and the next
      attempt does not overwrite them. (`STO-20`, `OPS-19`)

## Blast radius

- [ ] **CNF-111** Tenants are distributed across more than one provider account. An assignment
      policy that places every tenant in one account fails this item even though it satisfies
      `API-17b`. (`SEC-43`)
- [ ] **CNF-112** The provider's account-linkage practice has been verified in writing. Until it
      is, `CNF-111` proves nothing. (`SEC-44`)
- [ ] **CNF-113** One operator action terminates a tenant and every machine it owns, fast enough
      to meet the provider's abuse-notice deadline. (`SEC-45`)
- [ ] **CNF-114** Loss of a provider account releases the affected holds back to available
      balance. (`SEC-46`)
- [ ] **CNF-115** Balances and holds are answerable with every provider unreachable. (`SEC-47`)

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
8. Whether enrolment issues a server-generated token or registers a caller-supplied public key
   (`API-37`, and the note recorded after it).
9. The negative window per provider, and the measurement it was derived from (`OPS-33`).
10. The margin, per provider account or product class (`LDG-24`).
11. The tenant-to-provider-account assignment policy, which is simultaneously the authorization
    rule (`API-17b`) and the blast-radius control (`SEC-43`).
12. The configured runway floor, and the `wind_down_cost` measurement behind it (`PRV-13d`).
