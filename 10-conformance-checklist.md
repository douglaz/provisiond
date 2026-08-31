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
item for `OVR-10a`, which had none — that is `CNF-71`–`CNF-74` below.

### Assignments

**BLOCKING** (count superseded — see **The blocking count**) — `CNF-1`, `CNF-3` (the epistemic pair: every other checkmark is testimony from
this witness); `CNF-4`–`CNF-9` (tenancy — three internal tenants exist from day one, so
cross-tenant control is takeover plus destruction before any external customer arrives);
`CNF-10`–`CNF-13` (injection — path injection reaches the wrong machine in the operator's whole
account, shell metacharacters reach root on the rescue system); `CNF-14`–`CNF-17` (redaction —
create responses carry machine root passwords, rescue passwords are root on customer machines);
`CNF-19`, `CNF-20` (capability gating, the enforcement direction); `CNF-21`–`CNF-25`,
`CNF-26`, `CNF-27`, `CNF-28`, `CNF-29`, `CNF-31a` (the create and ambiguity rows only — see the split below), `CNF-32`
(idempotency and double-mutation — the money-out core; `CNF-32` is `OVR-5`, the spec's
self-declared most important property); `CNF-36`–`CNF-38`, `CNF-40`, `CNF-41`, `CNF-43`,
`CNF-44`, `CNF-46` (rescue safety); `CNF-49`–`CNF-51`, `CNF-53` (image supply chain — each ends
in an attacker-supplied image written to a customer's disk); `CNF-54`, `CNF-55`, `CNF-63`,
`CNF-64`, `CNF-69` (money-out gates, including the term-billing honesty pair — "deleted but
still billing" is unbounded operator money-out); `CNF-71`–`CNF-74` (the `OVR-10a` boundary,
which in the single-component form is the only structural defence there is).

**PRE-SCALE** — `CNF-2` (lint: hygiene, not harm — free, so do it early, but it gates nothing),
`CNF-18`, `CNF-30`, `CNF-31b` (the remaining rows), `CNF-33`, `CNF-34` (becomes
blocking the moment anything but the API writes the store), `CNF-35`, `CNF-39`, `CNF-42`,
`CNF-45`, `CNF-47`, `CNF-48`, `CNF-52`, `CNF-56`, `CNF-57`, `CNF-59`, `CNF-60`, `CNF-61`,
`CNF-70`.

**PROMOTED TO BLOCKING 2026-08-13**, under this checklist's own rule rather than by opinion:
`CNF-58` (an unknown stored status that can become `queued` repeats a provider mutation — question
3 answered yes) and `CNF-65` (autonomous deletion leaving unbounded billable attachments is
unstoppable billing — the money-out family, and `LDG-32` now depends on it).

**DEFERRED** — nothing, after audit. `CNF-62` (separate audit destination) was listed here
while the area sort below calls its parent `SEC-33` PRE-SCALE; the area sort is right, so
`CNF-62` is **PRE-SCALE**. Likewise `CNF-60` is PRE-SCALE while `API-21`, which it tests, was
sorted DEFERRED — `API-21` is corrected to PRE-SCALE.

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
`CNF-106` (under-committing every machine by exactly the margin); `CNF-107` (tenant→tenant
destruction — this was `F15`); `CNF-108`, `CNF-109` (unbounded billing and duplicate purchase);
`CNF-111`, `CNF-112` (an account termination cannot be undone with money or an apology, and
`CNF-112` is what makes `CNF-111` real rather than believed); `CNF-77`, `CNF-99`, `CNF-113`,
`CNF-115` (promoted 2026-08-12 — see the tier corrections below).

### Tier corrections — 2026-08-12 (`F30`)

Five items sat a tier below either their own harm or the BLOCKING item that depends on them.
Applying the three questions again, honestly:

- **`CNF-99`** tests that one adverse rate read cannot cancel a machine. Cancellation destroys
  the disk (`LDG-14`) — that is the *destroyed data* family, not a degraded service. It was
  PRE-SCALE because the trigger felt operational; the harm is not.
- **`CNF-77`** (time-to-live deletion) is what `CNF-123` — BLOCKING — exercises the second half
  of, and it is the storage bound that makes unauthenticated enrolment safe at all (`API-34`).
- **`CNF-24`** (key-order canonicalization): a spurious idempotency conflict tells an autonomous
  caller its request was wrong, and its documented recovery is to mutate the request and retry —
  a duplicate purchase reached through a JSON serializer. `CNF-21`–`CNF-23` were already
  BLOCKING; this is the same family.
- **`CNF-113`** (one-action tenant termination) is the mechanism `CNF-111`/`CNF-112` — both
  BLOCKING — assume exists; a control's test cannot gate less than the tests that rely on it.
- **`CNF-115`** (balances answerable with every provider unreachable): the insolvency gate
  (`CNF-101`, BLOCKING) and `SEC-46`'s release both read balances at exactly the moment a
  provider has vanished.

**PRE-SCALE** — `CNF-76`, `CNF-79`, `CNF-80`, `CNF-88`, `CNF-89`, `CNF-90`, `CNF-98`,
`CNF-102`–`CNF-105`, `CNF-110`, `CNF-114`.

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

### Assignments for `CNF-184`–`CNF-194` (added 2026-08-13)

**BLOCKING** — `CNF-184` (retroactive billing at a rate the customer never saw, or an unbounded
operator loss); `CNF-185` (metering cadence changing the price is a silent, systematic
overcharge); `CNF-186` (a customer stranded pending while holding non-refundable satoshis above
the minimum); `CNF-187`, `CNF-188` (both are unstoppable provider billing against a closed
commitment); `CNF-190` (without it a stolen credential is permanent, and it authorizes disk
destruction); `CNF-191` (without it no tenant can buy anything, ever); `CNF-192` (destroyed data,
and the only test that catches the device-identity binding); `CNF-194` (stopping service to a
tenant is the operator's remedy under `ADR-0005`, and `SEC-45` as amended does not depend on a
provider deadline to justify it).

**PRE-SCALE** — `CNF-189`, `CNF-193`. Both bound storage and recoverability rather than money in
flight; `CNF-193` graduates the moment on-chain funding is enabled in production, because that is
when the finality window becomes real.

### Assignments for `CNF-144`–`CNF-148` (added 2026-08-12)

**BLOCKING** — `CNF-147` (it is the only item that runs the dedicated money path against a real
machine, and every requirement it touches was written without ever having been executed);
`CNF-148` (populating `comment` turns every dedicated order into a human-latency order —
confirmed, not suspected); `CNF-181` (a timing-based attach hands one customer another's physical
server, and it is exactly what a builder reaches for when the correlator is missing).

`CNF-180` is **before production** rather than blocking: it gates the *Robot driver*, not the
launch — `ADR-0010`'s other two drivers are unaffected, which is the payoff for having chosen a
launch set spanning two companies. **`CNF-183` is BLOCKING** — describing a balance in custody words is the misstep `ADR-0004`'s
whole perimeter is built to avoid, it cannot be un-said once published, and the operator would not
learn it was wrong from anything but an enforcement letter. **`CNF-182` is BLOCKING** too, and it
is new: `PRV-34`'s test mode
is only a safety net if the default points at it, and a flag that defaults the wrong way converts
every accidental conformance run into a purchased dedicated server — money out, unrecoverable,
exactly the family the tiering rule puts in the top tier.

**PRE-SCALE** — `CNF-144`, `CNF-145`, `CNF-146`. These protect the contract's generality, which
degrades slowly and visibly rather than losing money; `CNF-145` is the one to run first, because
the leak it catches gets harder to reverse the longer it sits.

See **The blocking count** below.

### Assignments for `CNF-149`–`CNF-151` (added 2026-08-12)

**BLOCKING** — `CNF-150`. It looks like an ergonomics item and is not: without it the only way an
autonomous caller can discover whether it can afford a machine is to try to buy one, which is
question (3) of the tiering rule answered *yes* for a provider mutation.

**PRE-SCALE** — `CNF-149`, `CNF-151`. Both are consistency checks the operator can run by reading,
and both catch drift rather than harm.

See **The blocking count** below.

### Assignments for `CNF-152`–`CNF-158` (added 2026-08-12)

**BLOCKING** — `CNF-154` (the duplicate-purchase path an autonomous caller reaches through the
completion mechanism itself — the panel's unanimous "most expensive way for finding out to go
wrong"); `CNF-155` (without it enrolment's happy path ends in a probe-by-purchase, and the funnel
teaches every new customer the exact behaviour `CNF-150` bans); `CNF-157` (a customer-triggered
`DEF-11` is a denial of service on the store that also runs the money).

**PRE-SCALE** — `CNF-152`, `CNF-153`, `CNF-156`, `CNF-158`. Pacing and staleness degrade service
and burn rate-limit budget; they do not move money. `CNF-152` graduates to BLOCKING the day a
second independent client implementation exists, because at that point the invariant is the only
shared contract.

**BLOCKING** (added with `OPS-39`) — `CNF-159`. It is the destroyed-data event routed through the
queue's safety machinery: an exhaustion cancel outside the queue has no lock, no lease and no
`needs_reconciliation` path, which is a blind mutation against a customer machine — the thing
`OVR-5` calls the single most important thing this system refuses to do.

See **The blocking count** below.

That added a further block of BLOCKING items; the total lives in **The blocking count** and
nowhere else, this passage included. **This is the honest cost
of the 2026-08-11 decisions** and it should be read as such: choosing self-serve enrolment and a
prepaid balance did not merely add features, it added a money system whose correctness gates
launch. A reader deciding whether that trade was worth it will find the number there.

### Tiering the other 234 requirements — first pass

The same three questions apply. This pass is at *area* level with named exceptions, because an
honest per-item verdict on 234 requirements needs a target deployment in front of you. Treat it
as a starting sort, not a ruling.

**Blocking as a whole area** — the safety spine, where a first pass is safe because almost
everything in them is irreversible:

- **`SEC-*` (the entire namespace, now `SEC-1`–`SEC-53`).** All of it. Every one guards a family in the irreversible
  list. Exceptions that are genuinely PRE-SCALE: `SEC-30`/`SEC-31` (rate limiting and
  starvation — a queue with one tenant cannot starve anyone), `SEC-33` (separate audit sink),
  `SEC-38` (rotation procedures, needed before the first credential ages out rather than before
  the first customer).
- **`RSC-*` (now `RSC-1`–`RSC-38`).** Rescue writes to disks and holds root credentials. `RSC-31` (partition
  growth), `RSC-33`/`RSC-34` (inventory capture) are the plausible PRE-SCALE exceptions.
- **`PRV-6`, `PRV-9`–`PRV-13c`, `PRV-17`, `PRV-22`.** Injection, key-material timing, deletion
  semantics, rescue credential handling, ambiguity honesty.
- **`OPS-1`–`OPS-23`.** The uncertainty model is the product's most valuable property and it
  is a money-out control, not an ergonomics one.
- **`OVR-5`, `OVR-9`, `OVR-10`, `OVR-10a`, `OVR-10b`, `OVR-12`.**
- **`DOM-6`, `DOM-10`, `DOM-13`, `DOM-14`, `DOM-17`–`DOM-19`.** Redaction, capability gating,
  strategy/image pairing, digest requirement, error taxonomy, cancellation honesty.
- **`API-7`–`API-19`, `API-22`, `API-24`, `API-25`.** Auth ordering, idempotency,
  validation, acknowledgements, authorization, redaction before storage, error mapping, message
  hygiene.
- **`STO-1`–`STO-5`, `STO-8`, `STO-8a`, `STO-9`, `STO-15`.** The transactional primitives the
  queue depends on, plus tombstone honesty and credential-grade storage.
- **Every `DEF-*`.** They are prohibitions derived from defects that actually shipped.

**PRE-SCALE** — real requirements the operator absorbs by paying attention: `API-23`, `API-26`,
`API-28`, `API-29` (listing, pagination, correlation ids, unauthenticated rate limits);
`OPS-24`–`OPS-26` (fairness, retention, operator listing); `STO-12`–`STO-14`, `STO-16`
(migration tooling, retention, backup handling); `SEC-32` (audit records, once more than one
person acts); `OVR-13`; `DOM-9`, `DOM-11`, `DOM-15`, `DOM-16`.

**DEFERRED** — guards a shape that does not exist yet, or is recoverable: `PRV-25`
(reverse DNS, if that capability is not in v1); `RSC-30`'s two-pass *default* if
`RSC-30` permits single-pass deliberately; anything
governing providers not shipping in v1. *`API-22` was listed here as "presentation details" and is
corrected to BLOCKING above: it restates `DOM-6` and `DOM-18`, both BLOCKING, and what it requires
is redaction **before storage** — an unredacted credential written to the store is not a
presentation choice and cannot be un-written. `API-21` was corrected to PRE-SCALE above.*

**The honest caveat.** Blocking still dominates, and that is the shape of a
destructive-operations product rather than a failure of the sort. If the blocking set is
uncomfortably large, the lever is **narrowing v1's capability surface** — fewer providers, no
rescue, no self-serve — not lowering the bar on the capabilities you keep. Cutting a capability
removes its requirements honestly; deferring a safety requirement for a capability you ship
does not.

### The honest finding about this exercise

Tiering buys less relief than expected: a large majority of items land BLOCKING (see **The
blocking count**). That is not tier
inflation. This checklist was distilled from the defect list of a discarded implementation of a
destructive-operations product, so it was already the sharp end. **The real relief lives in
tiering the full requirement set**, where the deferrable long tail actually is — pagination,
notification surfaces, operational polish. Apply the same three questions there and expect the
blocking fraction to be far lower.

## Architecture boundary

`ADR-0001` chose the single-component form of `OVR-10`, so these always apply. They replace the
network isolation the withdrawn separate-service form would have provided, which is why they are
not optional hardening — they are the only structural defence there is.

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
      not a panic and not a wrong default — except `PRV-2`'s three named exceptions, each
      asserted for its own stated behaviour instead: describe capabilities and get machine are
      implemented (`PRV-3`), and refresh rescue session returns the session unchanged (`PRV-19`).
      (`PRV-2`)

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
- [ ] **CNF-47** The inventory report is attached to the operation result, and an
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
- [ ] **CNF-70** The deployment has recorded *where* ceilings are enforced and what each integer
      is. Under `ADR-0001` that is this control plane — there is no front service to defer to,
      which is why the front-service variant of this rule was swept. (`SEC-39`)

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
- [ ] **CNF-78** **REWRITTEN 2026-08-14** — the old item tested a rule two amendments had
      replaced, and no implementation could satisfy it and `CNF-125` at once: it predates
      `API-43`'s allowlist, and "until a payment has been credited" is the per-payment trigger
      `API-35` withdrew on 2026-08-13. It now tests: a pending tenant performs **no action outside
      `API-43`'s allowlist** — every other authenticated endpoint answers `not_activated` — and it
      **remains pending until its cumulative credited balance reaches the configured minimum**,
      so two credited payments that each fall short but together clear the minimum activate it.
      *Withdrawn text:* A pending tenant can perform no authorized action of any kind until a
      payment has been credited. (`API-35`, `API-43`, `DOM-20`)
- [ ] **CNF-79** Enrolment rate-limiting state is never persisted — no caller address reaches
      the store or the logs. (`API-36`, `ADR-0005`)
- [ ] **CNF-80** **REWRITTEN 2026-08-13** — testing "no column beyond those specified" now fails
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
- [ ] **CNF-81** Operator credentials still come only from the environment, and no runtime-issued
      customer credential can become one. (`API-4`)

## Reconciliation and correlators

- [ ] **CNF-82** A create writes its correlator into the provider — the operation id where a free field exists, otherwise the per-operation artifact `PRV-32` defines — and records it against the operation before the order is sent
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
- [ ] **CNF-87** A commitment is closed and its reserved satoshis returned once the negative
      window elapses, even though the operation remains open, and the sweep keeps searching
      afterwards. (`OPS-33`)
- [ ] **CNF-88** The account-wide sweep reports an unclaimed machine to the operator and attaches
      it to no tenant. (`OPS-32`)
- [ ] **CNF-89** Resolution columns are write-once; a second resolution of the same record is
      refused. (`STO-19`)
- [ ] **CNF-90** **REWRITTEN 2026-08-13** — the old item tested the case `PRV-27` calls
      impossible (recording a transaction identifier the provider never returned because the reply
      was lost). It now tests: the identifier is recorded **when the provider returned one**, and
      resolution succeeds **without** it via the durable correlator (`PRV-32`, `OPS-27`).
      *Withdrawn text follows.* An order-shaped driver records the provider's transaction identifier **before**
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
- [ ] **CNF-96** A commitment and its operation are written in one transaction: killing the
      process between them leaves neither. (`LDG-11`, `STO-23`)
- [ ] **CNF-97** No sequence of concurrent operations can drive a balance negative. (`LDG-10`)
- [ ] **CNF-98** Remaining runway is readable from the machine view before exhaustion.
      (`LDG-15`)
- [ ] **CNF-99** A single adverse rate read cannot cancel a machine: the deficiency must persist
      across derivations. *The per-tick cap clause is withdrawn with the construct it tested
      (`ADR-0011`).* (`PRV-13e`, `LDG-16`)
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
- [ ] **CNF-125** A pending tenant can reach exactly `POST /v1/deposits`, `GET /v1/deposits/{id}`
      for its own deposit, the unauthenticated enrolment handle, and `POST /v1/recovery/revoke`
      **at or after `issuable_at`** (`API-43`) — and **nothing else**; every
      other authenticated endpoint answers `not_activated`. The deposit-read half is what lets a
      tenant that paid below the activation minimum see what happened to unrefundable money.
      (`API-43`, `API-52`, `DOM-20`)
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

Added 2026-08-12. Past the persistence rule (`LDG-16`), a wrong rate is the only
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
      a setup fee committed before the order and debited on confirmed acceptance (`LDG-39`), a commitment sized to include cost through the
      earliest cancellation date, a cancellation that schedules rather than deletes, and billing
      that continues until the effective date. **The requirements this tests were all written
      before any of them had run.** (`LDG-39`, `PRV-13b`, `PRV-13c`, `DOM-19`)
- [ ] **CNF-148** **The Robot order `comment` field is never populated, by any code path** —
      Hetzner routes commented orders to manual processing (`PRV-30`, confirmed). Asserted against
      the outbound request, not by reading the driver.
- [ ] **CNF-180** `PRV-32`'s correlator round-trip is confirmed against the live Robot API before
      the driver ships — **using `test=true`, so it costs nothing** (`PRV-34`): an order carrying a
      unique SSH key is placed, the transaction is fetched, and the returned
      `authorized_key[].fingerprint` matches the key sent. If simulated transactions do not appear
      in the listing, one real order closes the remaining half. Failing that, the driver declares
      no correlator (`PRV-33`). (`PRV-32`, `PRV-34`)
- [ ] **CNF-184** A rate outage bills the customer **nothing** for the window: no deferred
      satoshi debit is posted when the rate returns, the native accrual appears as an operator
      deficiency, and machines are cancelled at the stated maximum outage if no rate comes back.
      (`LDG-64`, `LDG-65`)
- [ ] **CNF-185** Metering the same period at one-minute and one-hour cadence produces the
      **identical** total charge. Rounding is cumulative, not per tick — a property test over
      arbitrary subdivision. (`LDG-38`, `LDG-28`)
- [ ] **CNF-186** Two credited payments each below the activation minimum, summing above it,
      activate the tenant atomically. (`LDG-52`, `API-35`)
- [ ] **CNF-187** A machine deleted while a billable attachment survives keeps its commitment
      open and keeps metering that attachment; the commitment closes only when the last billable
      resource stops. (`LDG-32`, `PRV-13a`, `STO-18`)
- [ ] **CNF-188** An unreachable provider account or rejected credentials leave commitments
      **open**; only confirmed termination releases them. (`SEC-46`)
- [ ] **CNF-189** The enrolment response carries both secrets **once**, they are stored hashed
      only, and neither is ever returned by the handle poll. Losing the response loses the
      credentials — and the tenant is unfunded, so nothing of value is stranded. (`API-33`,
      `API-55`, `STO-34`, `WIR-12`)
- [ ] **CNF-190** The recovery credential revokes the spending token and issues a fresh one; the
      **spending token cannot revoke or rotate itself**. Both halves — the second is what stops a
      thief locking the owner out. (`API-56`, `WIR-38`)
- [ ] **CNF-191** A freshly activated tenant has at least one assigned provider account,
      recorded durably, and successive tenants are spread across accounts rather than filling one.
      (`API-57`, `STO-36`, `SEC-43`)
- [ ] **CNF-192** An install naming a device identifier absent from a freshly re-read inventory,
      or carrying a stale `inventory_fingerprint`, aborts `integrity` **with no bytes written**.
      Verified by mutating the inventory between the rescue-inventory pass and the install.
      (`RSC-26`, `RSC-38`)
- [ ] **CNF-193** A pending tenant's signup time-to-live exceeds the deposit expiry plus the
      finality window; a deposit minted at the last moment expires early enough that its own
      finality window still closes before the signup is reaped; and no tenant is deleted while a
      deposit of its own is inside that window.
      (`API-34`, `API-42`, `LDG-54`)
- [ ] **CNF-194** Suspending a tenant blocks every **tenant-authorized** write while leaving the
      maintenance actions reachable (`CNF-209`), enqueues one deduplicated cancellation
      per machine, leaves ledger and machine reads working, and reports per-machine outcomes
      including any `needs_reconciliation`. (`API-58`, `OPS-39`, `SEC-45`)
- [ ] **CNF-195** **MERGED INTO `CNF-188`** — both tested `SEC-46`'s retained-commitments table
      and both were counted BLOCKING, double-counting one control. `CNF-188` is the survivor and
      gains this item's second half: the carried exposure MUST appear as an operator deficiency
      (`LDG-66`), and the test MUST be run against `07-security-requirements.md` itself, because
      that amendment was written on 2026-08-13, failed to apply, and shipped as prose claiming it
      had.
- [ ] **CNF-196** Enrolment ignores an `Idempotency-Key`: two signups presenting the same key
      receive **different** handles and different credentials. The withdrawn rule returned the
      same handle, and the handle's response carries both secrets. (`API-40`, `WIR-12`)
- [ ] **CNF-197** A resolution transition out of `needs_reconciliation` succeeds with **no worker
      and no lease** — by sweep and by operator verb — while a lease-less *worker* write is still
      refused. Both halves. (`OPS-3`, `STO-19`, `STO-3`)
- [ ] **CNF-198** Metering a period at a cadence that subdivides it posts every increment: no
      posting is deduplicated away by the idempotency key, and two billable attachments on one
      machine do not collide. (`LDG-8`, `LDG-38`)
- [ ] **CNF-199** A late-attach cleanup on a tenant whose balance is **below** the wind-down floor
      opens **no commitment at all**, carries the **whole** wind-down as an operator deficiency
      rather than a shortfall against a partial one, still executes the cancel, and never drives
      available negative. (`OPS-36`, `LDG-10`, `LDG-66`)
- [ ] **CNF-200** A rootfs install naming a drive by unstable device path is rejected; the layout
      carries stable identifiers checked against the inventory fingerprint, exactly as raw-disk
      does. (`RSC-26`, `RSC-22`, `WIR-20`)
- [ ] **CNF-201** A rescue-inventory run carries a trust policy and is capability-gated on
      `rescue_ssh`; an ambiguous failure classifies like an install, not like a refresh — the machine can
      be left in rescue. (`WIR-40`, `DOM-10`, `OPS-11`)
- [ ] **CNF-202** Suspending a tenant returns a `suspend_tenant` operation whose children are
      readable through `GET /v1/operations`; resume is synchronous and restores no machines.
      (`WIR-39`, `WIR-41`, `API-58`)
- [ ] **CNF-203** A replayed revocation returns `409` and no stored bearer token appears anywhere
      in `idempotency_records`. Grep the table for the token value. (`STO-35`, `WIR-38`, `API-3`)
- [ ] **CNF-206** A disk identifier matching **two** devices aborts `integrity` with no write, and
      an offer whose devices expose no unique identifier is unsellable for rescue installs.
      (`RSC-26`)
- [ ] **CNF-207** A rootfs install body round-trips `partitions`, `raid.level` and per-drive
      identifiers through the parser. This fixture was silently broken by a fix in the previous
      pass, which is what a fixture is for. (`WIR-20`, `RSC-22`)
- [ ] **CNF-208** The enrolment status poll never returns `issuable_at` **or `expires_at`**; only
      the enrolment response does. Either instant yields the other by subtraction, so publishing
      one on the unauthenticated handle defeats the redaction of the other. (`WIR-13`, `API-33`,
      `API-34`)
- [ ] **CNF-209** A suspended tenant can still revoke its spending token. Gating maintenance on an
      active tenant locks the owner out exactly when revocation matters. (`API-7`, `API-56`)
- [ ] **CNF-210** An orphaned deposit is credited to a named tenant exactly once through the
      operator attribution endpoint; a second call naming a different tenant is `409`. (`WIR-42`,
      `API-34`)
- [ ] **CNF-211** An ambiguous create that resolves *observed* debits the setup fee from
      available balance after `OPS-33` has already closed the commitment, and records an operator
      deficiency when available cannot cover it — the fee is neither dropped nor clamped away.
      (`LDG-39`, `LDG-67`, `LDG-31`)
- [ ] **CNF-212** Two consecutive exhaustion sweeps over the same machine enqueue **one**
      cancellation: the second reuses the episode's trigger id and conflicts. Minting a fresh id
      per sweep is the failure. Run the second sweep again **after retention has deleted the first
      sweep's operation row** (`STO-14`) and assert it still enqueues nothing — the machine's
      retained `system_trigger_ids` entry, not the operation, is what holds. (`OPS-39`, `STO-14`)
- [ ] **CNF-213** Attributing an orphaned deposit posts **one `correction` pair per settled
      payment** — never a second `topup`, which would mint satoshis the original settlement already
      credited — and `operator_ref` holds no name, address or contact string. A deposit paid on
      both rails produces two pairs. (`WIR-42`, `LDG-5`, `LDG-55`, `ADR-0005`)
- [ ] **CNF-183** No customer-facing surface — terms, API documentation, error text, marketing —
      states or implies that satoshis are held, backed, reserved or segregated against a balance,
      **and** the terms do state that a balance is an unsecured claim. Both halves: silence about
      the ratio, disclaimer about the arrangement. (`LDG-19`, `LDG-19a`, `ADR-0004` §4)
- [ ] **CNF-182** The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
- [ ] **CNF-181** With no verified correlator, an ambiguous Robot create ends in
      `needs_reconciliation` awaiting an operator, the recent-order listing is surfaced as
      evidence, and **no automatic attach occurs on any hostname or timing similarity**. The
      negative window still releases the commitment in full. (`PRV-33`, `OPS-29`, `OPS-33`)
- [ ] **CNF-214** A machine and one of its billable attachments, both metered in the same period,
      produce **separate** `already_charged` sums: charging the attachment does not reduce what
      the machine is billed, and neither does the reverse. Asserted against the stored subject,
      not against `machine_id`. (`STO-38`, `LDG-8`, `LDG-38`, `LDG-32`)
- [ ] **CNF-215** **REWRITTEN 2026-08-31 — it tested the claw-back as correct behaviour.** A
      `correction` naming a `usage_debit` carries `corrected_seconds` (`LDG-73`), and after it the
      period's total is **stable**: the next tick posts neither the corrected amount back nor a
      compensating credit, because both `already_charged` and `billable_seconds` moved. Assert
      across a full metering interval, not just the posting. A correction posted in a later period
      still nets against the period of the entry it **names**, not the period it was posted in; and
      a correction naming an entry of another kind is excluded from the sum and carries no seconds.
      *Withdrawn clauses:* "A `correction` that **reduces** a charge makes the next tick post
      **more**; one that **increases** it makes the next tick post **less**" — true of the
      arithmetic as it stood, and it described a credit being reclaimed within one tick.
      (`LDG-73`, `LDG-38`, `LDG-5`, `LDG-7`, `STO-38`)
- [ ] **CNF-235** The meter's cost per tick does not grow within a period. Meter one subject for a
      full period at a cadence that subdivides it, and assert the storage reads per posting are
      constant rather than proportional to the number of prior postings — asserted at the storage
      layer over the suite's traffic in the manner of `CNF-157`, not by reading the code. The
      running total and the entry commit together: kill the process between them and neither
      survives. (`LDG-72`, `STO-45`, `LDG-35`)
- [ ] **CNF-251** **The credential boundary is a module edge, not a comment.** `api` does not depend
      on `providers` or `rescue`, depends on `engine` only through a trait whose signatures mention
      no credential type, and `engine` does not depend on `api`. `CNF-71`'s compile-fail test asserts
      across that edge and `CNF-72`'s tripwire watches it. A build where the credential-owning type
      becomes reachable from `api` fails to compile. (`OVR-9`, `OVR-10a`, `ADR-0001`)
- [ ] **CNF-252** **Rescue entries and power cycles are capped.** A principal that sets every
      acknowledgement flag on every request still cannot exceed its rescue-entry or power-cycle
      ceiling; the rescue-entry ceiling counts the inventory pass and rescue-entering installs
      together. Drive it with a loop that acknowledges everything. (`SEC-39`, `RSC-38`)
- [ ] **CNF-253** **The operator principal is capped and observed.** An operator principal exceeding
      its stated requeue, resolution, suspension or re-assignment ceiling is refused; the override
      path works and is itself recorded; and every operator verb emits a monitorable event naming
      principal, target and reason. The failure this catches is a looping operator agent buying
      duplicate servers or attaching a machine to the wrong tenant — strictly more power than any
      customer holds, previously uncapped. (`SEC-39`, `SEC-32`, `API-62`)
- [ ] **CNF-254** **The credential-holding process cannot move the float.** Its Lightning credential
      permits creating and observing invoices and nothing else: attempting a payment, a channel
      close or an on-chain send with it fails. Asserted by attempting them, not by reading the
      credential's configuration — `CNF-132`'s rule that reachability is the test, not visibility.
      (`SEC-48`, `ADR-0001`)
- [ ] **CNF-255** **The stated ceiling covers both pots and the sweep destination is pinned.**
      Channel balance plus the node's on-chain wallet is what the ceiling measures; a sweep whose
      outputs are not the pinned cold destination is rejected by the signer; and the destination
      cannot be changed by any runtime input. `CNF-135` tests the last clause for the sweep
      destination — this adds the wallet to the arithmetic `ADR-0009` is sold on. (`SEC-49`,
      `SEC-50`, `ADR-0009`)
- [ ] **CNF-256** **A signup slot costs a held connection.** `POST /v1/enrol` without a valid,
      unexpired, unused token is refused; a token is obtained only from a request that answers after
      the stated delay; a token is single-use; and issuing one writes nothing to the store. Then the
      test that matters: a caller cannot hold more concurrent token requests than the proxy's stated
      per-source limit, and no caller address is persisted anywhere while enforcing it. (`API-33`,
      `API-36`, `API-41`, `ADR-0005`)
- [ ] **CNF-241** **A create is refused rather than bought at a price nobody authorized.** With the
      offer's provider price raised between accept and claim so the open commitment no longer covers
      `PRV-13b`'s reserve, the worker fails the operation deterministically **with no provider call
      and no ordering request**, and the error names the shortfall. With the price unchanged or
      lower, it proceeds. No commitment grows in either case. (`OPS-43`, `PRV-13b`, `ADR-0011`)
- [ ] **CNF-242** **A solvency halt stops what it can and says so about what it cannot.** Under a
      failing check: minting is refused `halted`; unsettled Lightning invoices on unexpired deposits
      are cancelled and a payment attempted against one fails back with the payer's funds intact; an
      on-chain payment arriving at an already-issued address is still **credited**, not held; and the
      deposit read reports the halt with `gate: "solvency"` before a caller pays. (`LDG-20`,
      `LDG-55`, `LDG-47`, `LDG-51`, `WIR-15`)
- [ ] **CNF-243** **A tenant is not stranded on a dead provider account.** After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and a create
      against it succeeds. Every use of the verb emits a monitorable event naming principal, tenant,
      before and after, and reason. A customer token calling the route gets `404`. (`API-62`,
      `WIR-48`, `SEC-46`, `STO-36`)
- [ ] **CNF-244** **Suspension is effective when the call returns.** A write issued by the tenant
      immediately after `POST .../suspend` returns `202` — and before any worker has claimed the
      parent — is rejected `suspended`. Asserted with the worker pool stopped, which is the state the
      withdrawn wording left permissive. (`API-58`, `API-7`, `WIR-39`)
- [ ] **CNF-245** **The account sweep has a budget.** It paginates the provider listing rather than
      assuming one response, yields on `rate_limited` instead of retrying into it, does not delay
      caller-initiated work, and reads by `(provider_account, external_id)` against the index
      `STO-17`'s constraint supplies. An imported image whose operation has settled is **deleted** by
      the same sweep, while an unclaimed machine is only reported. (`OPS-32`, `STO-17`, `ADR-0013`)
- [ ] **CNF-246** **The balance poll does not grow with the fleet.** `GET /v1/balance` returns the
      totals and `earliest_runway_until` with no per-commitment array; `?commitments=true` returns it
      cursor-paginated, and on the full listing `committed_sats` equals the sum of `reserved_sats`.
      Asserted against a tenant with more machines than one page holds. (`WIR-16`, `WIR-32`,
      `API-49`, `LDG-9`)
- [ ] **CNF-247** **A tenant identifier is minted, unique, and never reused.** Identifiers are
      server-generated with stated entropy; a caller cannot supply or influence one; and no
      identifier is ever issued twice, including after `API-34` reaps the tenant that held it.
      Asserted against the generator, not by sampling. The failure it prevents is a new caller
      inheriting a reaped tenant's balance and deposits, which survive by identifier alone.
      (`DOM-1`, `STO-26`, `STO-29`, `API-34`)
- [ ] **CNF-248** **Every mandated `409` carries a defined reason.** Drive each member of
      `WIR-9a`'s `conflict` union — including `signup_window_closed`, `deposit_already_attributed`
      and `cancellation_committed` — and assert the reason string is present and from the closed set.
      A `409` with no reason, or one outside the union, fails. (`WIR-9a`, `API-34`, `WIR-42`,
      `OPS-42`)
- [ ] **CNF-249** **`?state=` on the case collection is honoured, and a bad value is refused.**
      `open`, `closed` and `all` each return the right set; the default is `open`; and an
      unrecognised value is `invalid_request` rather than ignored. The last clause is the one that
      matters: `WIR-2` ignores unknown query parameters, so a silently-ignored `state` answers the
      wrong question with a `200`. (`WIR-43`, `DOM-24`, `WIR-2`)
- [ ] **CNF-250** **`network_restriction.source` is null exactly when nobody has looked**, and
      `system_reason` parses against a closed enum. A freshly created machine renders
      `{"status": "unknown", "source": null, "observed_at": null}`; a strict client parsing
      `system_reason` against `WIR-10a`'s set accepts every value the system emits. (`PRV-35`,
      `WIR-10a`, `WIR-47`)
- [ ] **CNF-237** **A delete is not resolved as failed while the provider is still catching up.**
      With a provider whose resource read lags its write, an ambiguous delete resolves correctly:
      resolution takes no read before the declared visibility window elapses, a pre-mutation reading
      inside the window leaves the operation pending rather than concluding, a post-mutation reading
      is never reverted by a later contrary read, and a pre-mutation reading beyond the window
      resolves *not applied*. Assert with an injected read lag; a sample exceeding the declared
      window widens it and does **not** authorize a replay. (`PRV-36`, `OPS-33`, `OPS-12`)
- [ ] **CNF-238** **A goal-state rejection is a success.** A delete against an already-deleted
      resource, where the provider answers 4xx meaning "already in the target state", classifies
      `succeeded` and its commitment closes (`LDG-32`). Asserted against the driver's recorded code
      mapping, not its message text. The failure this catches is a customer's satoshis reserved
      forever against a resource that is gone. (`OPS-11`, `PRV-5`, `LDG-32`)
- [ ] **CNF-239** **A machine funded a moment before its cancellation is not destroyed, and a
      machine already fenced cannot be funded.** Drive both orderings against one machine: an
      `extend-runway` committing before the worker's fence write leaves the machine alive with the
      worker making no provider call; a fence written first refuses the extension with `conflict`
      and **moves no satoshis**. Neither ordering may both take the payment and destroy the disk.
      (`OPS-42`, `OPS-41`, `LDG-62`)
- [ ] **CNF-240** **Attribution across two tenants deadlocks under no interleaving.** Two concurrent
      `WIR-42` attributions naming each other's tenants both complete, in one transaction each, with
      the primitives acquired in ascending tenant order; and an attribution whose source tenant row
      was already reaped by `API-34` succeeds, proving the primitive does not require a live tenant
      row. (`LDG-35`, `WIR-42`, `STO-26`, `API-34`)
- [ ] **CNF-236** The running total is provably derived. An audit recomputation of
      `charged_magnitude` and `high_water_increment_end` from `ledger_entries` equals the stored
      row; a seeded mismatch **fails closed** rather than answering from either figure. This is
      `CNF-219` applied to the second denormalised money number. (`LDG-72`, `STO-45`)
- [ ] **CNF-216** The billing period boundary is `00:00:00Z` on the first of the month for every
      tenant and every machine, and a metered increment straddling it is apportioned across the
      two periods rather than falling wholly into either. The same test covers a deficiency's
      `absorbed_from`/`absorbed_until` window straddling the boundary. (`LDG-68`, `LDG-38`,
      `STO-37`)
- [ ] **CNF-217** No transaction holding `LDG-35`'s serialization primitive acquires a
      `machine_locks` row, waits on an operation lease, waits on a child operation, or makes a
      provider call — asserted at the storage layer over the whole suite's traffic, in the manner
      of `CNF-157`, not by code review. (`LDG-69`, `LDG-35`, `OPS-8`)
- [ ] **CNF-218** A machine funded by `extend-runway` **after** its cleanup cancellation was
      enqueued is **not** deleted: the worker re-reads funding under the machine lock, makes no
      provider call, settles `succeeded`, and resolves the trigger episode. The same test with
      **no rate available** cancels the machine, because a funding check that cannot be computed
      is not a funded machine. (`OPS-41`, `OPS-36`, `LDG-62`, `LDG-40`)
- [ ] **CNF-219** `GET /v1/balance` is answered from the latest entry's `balance_after` and takes
      no write transaction; an audit recomputation of `Σ(ledger entries)` equals it; and a seeded
      mismatch **fails closed** rather than answering from either number. (`LDG-70`, `LDG-9`,
      `CNF-157`)
- [ ] **CNF-220** The deployment states its worst-case machine-lock hold, and `wind_down_cost`
      includes it. Asserted by enqueuing an exposure-reducing cancellation against a machine whose
      lock is held by a long-running operation and confirming the reserve covered the full wait.
      (`PRV-13b`, `OPS-9`, `LDG-42`)
- [ ] **CNF-221** A requeue supplying a payload that differs from the retained `request_summary`
      in kind, machine, provider account or target is **refused**; one that matches proceeds; and
      one whose summary cannot establish equivalence is refused with `OPS-31`'s verbs named as the
      alternative. `OPS-34` had no conformance item at all, on the requirement that made requeue
      implementable after `ADR-0005`. (`OPS-34`, `OPS-20`, `API-19`)

### The abuse surface (grill session, 2026-08-16)

- [ ] **CNF-222** **Address resolution answers from history, not from current state.** Machine A
      holds `203.0.113.7` and is deleted; the address is later observed on machine B, owned by a
      different tenant. Resolving `203.0.113.7` at an instant inside A's window returns **A**, and
      at an instant inside B's returns **B**. Asserting only the live case passes against the
      defect. **Run it on a machine created and never refreshed** — that is the ordinary machine,
      and binding the history write to the refresh alone leaves it with none. The operations that
      touched the machine in that window are recoverable alongside it (`SEC-45`), which
      `GET /v1/operations` under `WIR-33`'s override already answers. (`SEC-54`, `STO-41`, `DOM-8`)
- [ ] **CNF-223** Resolution returns a **candidate set**, and an address never observed at that
      instant returns an empty one rather than a nearest match. An operator acting on a confident
      wrong answer opens a case against an innocent tenant. (`SEC-54`)
- [ ] **CNF-224** **No part of the notice reaches the customer surface.** With a case open, neither
      the machine view, nor the case collection, nor the case detail, nor any error `details` on
      those paths contains the provider's case reference, its statement link, its own wording, or a
      third party the notice named. Run against **all three** read paths — one projection, three
      renderers, and a rule enforced on some of them is the failure mode. **It does not assert the
      absence of the provider's name**: `provider_account` is already in the machine view
      (`WIR-11`) and `WIR-29` returns the account kind, so a test written that way fails every
      conforming implementation. (`WIR-45`, `API-59`)
- [ ] **CNF-225** **The deadline has no hands.** A case whose `respond_by` has passed with no
      statement leaves the tenant unsuspended, the machine uncancelled, the balance untouched, and
      the case still accepting statements. (`DOM-25`, `DOM-24`)
- [ ] **CNF-226** Statements are append-only and unbounded in count while the case is `open`: a
      second and third submission both succeed and both appear in order; submission after `closed`
      is `409` `case_closed`; no endpoint edits or deletes one. (`STO-40`, `WIR-43`)
- [ ] **CNF-227** **Closing purges raw statement bodies and keeps what was sent.** After close, the
      statement rows survive with their timing, their `body` renders as `null`, and
      `sent_statement` — plus `sent_verbatim` and the statement ids it covered — is still readable
      by the operator. The purge commits in the close transaction, not after it. **And a case left
      open past the configured age purges anyway**, which is the only clock that fires without an
      operator. (`STO-42`, `STO-43`, `WIR-44`)
- [ ] **CNF-231** A retried statement submission carrying the same `Idempotency-Key` appends **one**
      statement, not two, and returns the same body. Under `STO-40` a duplicate can never be
      deleted, and the caller is an agent with a retry loop. (`WIR-43`, `WIR-24`, `API-8`)
- [ ] **CNF-232** `GET /v1/address-resolution` returns candidates ordered by `first_seen` with the
      matched window on each, an empty array where nothing matches, and `out_of_horizon: true` for
      an instant older than the deployment can answer for — distinguishable from "it was nobody's".
      (`WIR-46`, `STO-43`)
- [ ] **CNF-228** **REWRITTEN 2026-08-16 — it tested English.** A restricted machine keeps billing
      and says so *structurally*: `network_restriction.status` reads `disabled` on the machine view
      and in every case rendering, `usage_debit` postings continue, the commitment decays,
      `runway_until` keeps moving, and `delete` on that machine is accepted. **No assertion about
      prose.** *Withdrawn clause:* "the case's `consequence` states the drain" — no conformance run
      can execute a judgement about whether a sentence says a thing. (`LDG-71`, `DOM-27`, `DOM-26`)
- [ ] **CNF-233** `unknown` is never rendered as `none`. A machine whose driver reports no
      restriction signal reads `"status": "unknown"` with a null `observed_at`, and an operator
      recording is refused where the driver *does* report (`409` `state`). A field that is silently
      `none` when nobody looked is worse than no field. (`PRV-35`, `WIR-47`)
- [ ] **CNF-234** `warned_consequence` has no write path after open, and a deadline revision
      appends: after two extensions the case carries both prior dates with their revision times,
      and `respond_by` reads the latest. (`STO-44`, `WIR-47`)
- [ ] **CNF-229** An open case blocks nothing else — create, install, extend-runway and delete all
      behave exactly as they do with no case open. (`DOM-26`)
- [ ] **CNF-230** A case is creatable **only** by an operator, and the statement write mints no
      operation: it returns `200` synchronously and `GET /v1/operations` gains no row. (`API-60`,
      `API-48`, `DOM-23`)

### Assignments for `CNF-222`–`CNF-232` (grill session, 2026-08-16)

**BLOCKING** — `CNF-222` and `CNF-223` (the wrong tenant is accused, and then invited to explain a
machine that was never theirs — a cross-tenant disclosure the operator performs itself);
`CNF-224` (a bearer credential whose use ends the operator's deadline, handed to a poll loop);
`CNF-225` (a paying customer's whole fleet cancelled by a timer because a program stopped polling).

**PRE-SCALE** — `CNF-226`, `CNF-227`, `CNF-228`, `CNF-229`, `CNF-230`, `CNF-231`, `CNF-232`. Each
degrades the channel or retains text too long rather than destroying money, data or a tenancy
boundary. `CNF-228` is the closest call: it is a customer paying for compute it cannot reach, which
is a disclosure problem before it is a money one, and `LDG-71` makes the disclosure the requirement.

*These four BLOCKING items are not yet folded into the count below; do that in the mechanical
recount that section requires rather than by adding four to a number nobody re-derived.*

## Surface completeness

- [ ] **CNF-149** Every endpoint the requirements mandate appears in the surface table, and every
      row in the surface table has a requirement behind it. Run as a diff, both directions —
      enrolment and funding were each mandated and unlisted for a day. (`API-48`, `F19`)
- [ ] **CNF-150** A caller can read its balance, its available figure and its committed satoshis
      without attempting a purchase. **A create rejected with `insufficient_balance` is not an
      acceptable way to answer "can I afford this"**, because an autonomous caller responds to it
      by retrying. (`API-47`, `DOM-20`)
- [ ] **CNF-151** Exactly the endpoints named in `API-48` are synchronous; every other write
      returns `202` with an operation. Asserted against the routing table, so that adding an
      endpoint later cannot quietly extend the exemption. (`API-48`, `API-1`)

## Completion and pacing

Added 2026-08-12 with `API-49`–`API-54`.

- [ ] **CNF-152** A simulated caller that obeys every `Retry-After` it receives — across a
      non-terminal list poll, a balance poll and a machines poll at the finest advertised
      cadence — receives zero `429`s over a sustained run. **The invariant is the test**, because
      any fixed rate-limit number stops being tested the day the fleet grows. (`API-50`)
- [ ] **CNF-153** Every non-terminal operation response carries `Retry-After` and a matching
      `poll_after_ms`, values differ by operation kind and state, and the enrolment poll carries
      no delay-derived value — the one endpoint where the pacing hint is a forbidden oracle.
      (`API-49`, `API-33`)
- [ ] **CNF-154** An operation in `needs_reconciliation` is delivered with `retryable: false`,
      and the client documentation states that re-issuing under a fresh idempotency key is a
      second purchase. The test is the field; the sentence is checked by reading. (`API-51`)
- [ ] **CNF-155** A pending tenant that has paid can observe `active` on its enrolment handle
      without attempting a create. A pending tenant that has not paid can reach only `API-43`'s
      allowlist — funding, its own deposit, that handle, and revocation at or after
      `issuable_at`. (`API-52`, `API-43`)
- [ ] **CNF-156** Two interleaved polls delivered out of order leave the caller holding the
      higher `revision`; the operation's revision strictly increases across every client-visible
      change, verified by killing and restarting the process mid-operation. (`API-53`)
- [ ] **CNF-157** No `GET` takes a write transaction, asserted at the storage layer over the
      whole test suite's traffic, not by code review. A polling customer must be unable to
      trigger what `DEF-11`'s internal loop triggered. (`API-54`)
- [ ] **CNF-158** Reading an operation past the retention horizon answers `gone`, not
      `not_found`, and the published observability horizon equals the idempotency horizon.
      (`DOM-21`, `STO-33`)
- [ ] **CNF-159** Driving a tenant's balance to exhaustion produces a tenant-visible operation
      with `requested_by: system` and reason `exhausted`, holding the machine lock, and capable
      of ending in `needs_reconciliation` like any cancel. The test is that the customer-facing
      history contains the event **before** the machine record shows it gone. (`OPS-39`,
      `LDG-14`)

## The meter and serialization

Added 2026-08-12 closing `F30`'s list of untested requirements from the commitment rewrite.

- [ ] **CNF-160** Posting the same `(subject, billing period, kind, increment end)` usage debit twice moves the
      balance once, and the debit and its commitment decrement land in one transaction — killing
      the process between them leaves neither. (`LDG-38`, `LDG-31`, `STO-28`)
- [ ] **CNF-161** A machine powered off for a full billing period is billed for it, and a machine
      in `cancellation_scheduled` is billed through its effective date. The meter stopping at
      cancellation *acceptance* is the defect. (`LDG-37`, `DOM-19`)
- [ ] **CNF-162** **REWRITTEN.** The setup fee follows `LDG-39`'s table: debited **on confirmed
      acceptance** and the commitment decremented in the **same transaction** (kill the process
      between them and neither survives); **released in full** on deterministic rejection and on
      resolved-absent; **held** through `needs_reconciliation`. Assert `available` never goes
      negative across the whole sequence — that is the bug this item missed by testing only the
      debit. (`LDG-39`, `LDG-31`, `LDG-10`)
- [ ] **CNF-163** Two concurrent creates against a balance that can fund exactly one result in
      one commitment and one `insufficient_balance` — under load, not by code review. This is
      the per-tenant serialization primitive `STO-27` exists for. (`LDG-35`, `STO-27`)
- [ ] **CNF-164** A machine whose correlator arrives after `OPS-33` released the commitment is
      attached to its tenant and then routed through the ordinary exhaustion path — not silently
      adopted free, not destroyed without a record. (`OPS-36`)
- [ ] **CNF-165** When correlator search returns **many**, no automatic attach occurs, the
      operator is shown all candidates, and the recorded choice names which duplicate was kept
      and why the others are believed spurious. (`OPS-38`, `OPS-31`)

### Assignments for `CNF-160`–`CNF-165`

**BLOCKING** — `CNF-160` (double-billing or an unmetered machine, and the crash window mints the
difference); `CNF-161` (under-billing exactly the machines the operator is still paying for);
`CNF-162` (the €39-per-iteration pump the setup-fee rewrite closed — this is its test);
`CNF-163` (two creates spending one balance is authorization failure, the write-skew case);
`CNF-164` (a machine running free or destroyed with no record — both irreversible).

- [ ] **CNF-166** A create against an offer with no declared cancellation bound is refused
      before any provider call, and a create against one with a bound opens a commitment sized to
      that bound, which the machine's actual date then **lowers `protected_sats` against rather
      than resizing** (`PRV-31`, `LDG-33`). (`PRV-31`,
      `PRV-13c`, `LDG-12`)

- [ ] **CNF-167** A rate halving increases **no** commitment anywhere in the fleet, except
      machines on the scheduled-cancellation branch. What moves is every affected machine's
      `runway_until`. Fault-inject the rate; diff the commitments table. (`LDG-33`, `ADR-0011`)
- [ ] **CNF-168** `runway_until` moves at re-derivation in **both** directions and the machine
      view reflects it on the next read. (`LDG-33`, `LDG-15`)
- [ ] **CNF-169** `runway_until` is derived with `protected_sats` subtracted (`LDG-33`), and a
      machine is routed into the exhaustion path while its remaining commitment still covers
      wind-down at the current rate — at cancellation time the operator is not out
      of pocket. Drive a machine to exhaustion under a falling rate and assert the invariant at
      the moment of cancellation, not at the end of the test. (`LDG-16`)
- [ ] **CNF-170** Two concurrent runway extensions against a balance that can fund one result in
      one extension and one `insufficient_balance`, and replaying an extension with its
      idempotency key does not reserve twice. (`LDG-62`, `LDG-35`, `API-8`)
- [ ] **CNF-171** On the scheduled-cancellation branch, a shortfall that available cannot top is
      surfaced to the operator as a named deficiency — not silently absorbed, not billed to the
      customer twice. (`LDG-63`)
- [ ] **CNF-172** A create/install carrying a signed URL whose expiry is inside the stated
      admission-to-start bound is rejected at accept; at claim, a URL that cannot outlive the
      install fails the operation with no provider mutation and no rescue entry. (`OPS-40`,
      `SEC-21`)
- [ ] **CNF-174** A customer request authenticates by `Authorization: Bearer <token>` compared
      to a stored **hash** in constant time; the raw token appears in no log line, URL, or
      operation record; and an unknown or malformed token fails `authentication` before any body
      parsing (`API-7`). *Withdrawn signing-vector test: the Ed25519 scheme this checked
      was withdrawn 2026-08-13; a bearer token has no signing string to interoperate on.* (`WIR-5`, `API-39`, `API-3`)
- [ ] **CNF-175** A request with an unknown body field is rejected naming the field, and a
      response with an extra field is accepted by the reference client. Both directions of
      `WIR-2`, tested separately. (`WIR-2`)
- [ ] **CNF-176** Every example body in `13-wire-contract.md` validates against the
      implementation's actual parser — the examples are test fixtures, not illustrations, and
      contain no `...` placeholder inside an object (`WIR-37`). (`F19`)
- [ ] **CNF-177** A browser-origin preflight (`OPTIONS` with the `Authorization` and
      `Idempotency-Key` request headers) succeeds **unauthenticated** and returns the allow-lists
      of `WIR-4a`; a customer request from a wasm client then completes end to end. Run from an
      actual cross-origin fetch, because this is the failure that is invisible in server-only
      tests. (`WIR-4a`, `API-49`)
- [ ] **CNF-178** A body reusing an idempotency key against a **different** machine or endpoint is
      `409`, not a replay of the first result; and a body with a duplicate JSON member, or an
      integer above 2^53, is rejected. (`WIR-3`, `WIR-1a`)
- [ ] **CNF-179** An operator resolves a `needs_reconciliation` operation through
      `POST /.../actions/resolve` in each of its three forms, the `absent` form releases the
      commitment, and a customer-authenticated request to that route — and to adopt and requeue —
      returns `404`, not `authentication`. (`WIR-35`, `WIR-34`, `OPS-31`)
- [ ] **CNF-173** After startup, enumerating the process environment from inside the
      customer-facing module yields no provider credential — asserted by actually reading the
      environment at runtime, not by reviewing the scrub call, because a runtime that caches the
      environment makes the scrub a no-op. (`OVR-10c`, `F13`)

**PRE-SCALE** — `CNF-165` (an operator procedure with a human already in the loop).

**BLOCKING** — `CNF-166` (an order whose exposure could not be bounded before purchase is
unauthorized spending of the operator's money, which is the exact thing `PRV-13b` exists to
prevent); `CNF-167` (an automatic commitment increase is the freeze surface `ADR-0011` removed —
its reappearance is a security regression, not a tuning choice); `CNF-169` (the single invariant
that keeps the operator whole under repricing; its failure is silent money-out discovered on a
provider invoice); `CNF-170` (write-skew on the money path, the `LDG-35` case in a new costume).

**PRE-SCALE** — `CNF-168`, `CNF-171` (visibility items; the harm they catch is bounded and
operator-absorbable at concierge scale).

**BLOCKING** — `CNF-177` (as written the browser-wasm caller cannot complete one request
until the preflight passes — the product is unreachable from its own client); `CNF-178` (an
idempotency fingerprint missing method+target replays a destructive action against the wrong
target); `CNF-179` (without the resolve verbs a frozen ambiguous operation strands a customer's
commitment with no operator road out); `CNF-172` (the gate stands between a doomed input and a
destructive write that has already wiped a disk by the time the doom arrives); `CNF-173` (escaped-secret family — the
only structural credential defence `ADR-0001` left standing, finally given a test that measures
reachability instead of type visibility).

**PRE-SCALE** — `CNF-174`, `CNF-175`, `CNF-176` (contract-drift and auth-hygiene catchers;
they harden the wire, they do not move money — `CNF-174` dropped from blocking when the fragile
signing scheme it guarded was withdrawn).

See **The blocking count** at the end of this document; it is stated in one place only.

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
- [ ] **CNF-113** **REWRITTEN 2026-08-15** — it tested a deadline `SEC-45` no longer asserts.
      Two halves, both required. (a) One operator action suspends a tenant and enqueues a
      cancellation for every machine it owns, without the operator enumerating them by hand.
      (b) Given a provider resource, an address and an instant, the system names the owning
      tenant, the machine, and the operations that touched it in that window — the fact an abuse
      answer depends on, previously supported by the schema and required by nothing.
      **Half (b) was untestable as written and is superseded by `CNF-222`/`CNF-223`**: it said
      "an instant" while the only data was current state, so any implementation passed it by
      ignoring the instant — which is precisely the defect. Assert it against `STO-41`'s history
      with a reissued address, or not at all. (`SEC-45`, `SEC-54`, `API-58`)
- [ ] **CNF-114** **Only confirmed termination** closes the affected commitments and returns
      their reserved satoshis to available; an unreachable account or rejected credentials leave
      them open, with the exposure recorded as an operator deficiency. (`SEC-46`, `LDG-66`)
- [ ] **CNF-115** Balances and commitments are answerable with every provider unreachable.
      (`SEC-47`)

## Before production

Beyond the checklist, the following are judgement calls a deployment must make
explicitly and record:

1. ~~Which adoption entitlement mechanism is in force~~ — **settled 2026-08-12: adoption is
   operator-only, and entitlement is the operator-maintained assignment of external machine
   identifiers to tenants** (`API-18`).
2. Whether first-use trust is permitted at all, and for which providers (`SEC-24`).
3. Whether the raw-disk path runs in single-pass or two-pass mode (`RSC-30`).
4. What the image host allowlist is (`SEC-19`).
5. Which provider accounts may order, and what the spend ceiling is (`DOM-16`).
6. Who is on the rota for `needs_reconciliation`, and what the response procedure is
   (`OPS-26`).
7. Where persisted recovery keys are inventoried and how they get destroyed (`RSC-21`).
8. ~~Whether enrolment issues a server-generated token or registers a caller-supplied public
   key~~ — **settled 2026-08-13: a server-issued bearer token, stored hashed** (`API-39`).
9. The negative window per provider, and the measurement it was derived from (`OPS-33`).
10. The margin, per provider account or product class (`LDG-24`).
11. The tenant-to-provider-account assignment policy, which is simultaneously the authorization
    rule (`API-17b`) and the blast-radius control (`SEC-43`).
12. The configured runway floor, and the `wind_down_cost` measurement behind it (`PRV-13d`).


### Assignments for `CNF-214`–`CNF-221` (engineering review, 2026-08-15)

**BLOCKING** — `CNF-214` (two metered subjects sharing one column under-bill silently and
permanently); `CNF-215` (a correction either re-charges the customer or refunds them twice, on
the next tick, in both directions); `CNF-218` (a paid-for machine destroyed anyway — accepted
payment, lost disk, and the branch `OPS-33`'s early release depends on); `CNF-219` (the number
that authorizes every purchase, read from an unstated source); `CNF-221` (a requeue that cannot
establish equivalence is a second physical order under terms nobody checked).

**PRE-SCALE** — `CNF-216`, `CNF-217`, `CNF-220`. Each bounds cost or contention rather than losing
money or data on the first occurrence: a straddling increment mis-apportions a partial period, a
nesting violation is unreachable while `LDG-25` prices privileged operations at zero, and an
unpriced lock wait costs one machine's burn for one install.

### Assignments for `CNF-235`–`CNF-236` (the meter, 2026-08-31)

**BLOCKING** — `CNF-236`. It is `CNF-219`'s argument applied to a second denormalised money figure:
a running total that has silently drifted from the entries is a wrong charge on every subsequent
tick, the operator would not learn it from anything but a customer complaint, and the tiering rule's
question (1) is answered no.

**PRE-SCALE** — `CNF-235`. A quadratic meter degrades the store rather than mis-charging anyone —
`DEF-11` is the precedent and it was a starvation, not a loss. It graduates the moment metering
cadence is set finer than hourly, because that is when the arithmetic stops being survivable.

### Assignments for `CNF-251`–`CNF-256` (structure, ceilings and custody, 2026-08-31)

**BLOCKING** — `CNF-251` (the escaped-secret family: `ADR-0001` calls this the only structural
defence and it had no module edge to enforce); `CNF-253` (an uncapped operator principal that is a
program can buy duplicate servers and attach a machine to the wrong tenant, and `OPS-29` says a wrong
attach hands one customer another's physical server); `CNF-254` (money out, and it is the one
boundary in the key-custody design that is actually achievable — untested it is a belief);
`CNF-255` (the blast-radius number `ADR-0009` is sold on, wrong until this passes).

**PRE-SCALE** — `CNF-252`, `CNF-256`. A looping agent rebooting its own machine is a customer
harming itself, recoverable and visible; and the enrolment ceiling is a denial of service rather
than a loss. **`CNF-256` graduates the day enrolment is publicly reachable**, which is also the day
the attack costs nothing to mount.

### Assignments for `CNF-241`–`CNF-250` (the review's mechanical and money set, 2026-08-31)

**BLOCKING** — `CNF-241` (buying at a price the customer's balance was never checked against is
unauthorized spending of the operator's money, silent until an invoice); `CNF-242` (taking money for
a claim you have computed you cannot honour is the misrepresentation `LDG-19` names, and the
crediting half prevents `LDG-43`'s forbidden stranding); `CNF-243` (a non-refundable balance that
can buy nothing is a lost balance, and it is the only modelled catastrophe with no route back);
`CNF-244` (a safety control whose latency is the queue's latency is one the operator cannot reason
about); `CNF-247` (a reused identifier hands a stranger someone else's money, and nothing else in
the set prevents it).

**PRE-SCALE** — `CNF-245`, `CNF-246`, `CNF-248`, `CNF-249`, `CNF-250`. Each degrades service,
throughput or interoperability rather than losing money or data on the first occurrence. `CNF-245`
graduates when a second provider account exists, because that is when the sweep's cost becomes real;
`CNF-248` and `CNF-250` graduate the day a second independent client implementation exists, on
`CNF-152`'s reasoning — at that point the closed enums are the only shared contract.

### Assignments for `CNF-237`–`CNF-240` (locks, fences and freshness, 2026-08-31)

**BLOCKING** — all four, and each lands in a named irreversible family.

- `CNF-237` — a delete resolved as failed is a delete an operator requeues, which is a **repeated
  destructive provider mutation**; question (3) of the tiering rule answered yes.
- `CNF-238` — **money out**: the commitment never closes, so a customer's satoshis stay reserved
  against a resource that no longer exists, and nothing raises an error.
- `CNF-239` — **destroyed data**, and the one where the customer has already paid to prevent it.
  `OPS-36` calls `OPS-41` "what makes `OPS-33`'s early release safe", so this is the test that makes
  that release honest rather than believed.
- `CNF-240` — a hung operator endpoint on the money path, and a primitive that cannot be acquired at
  all on this endpoint's ordinary input.

### Assignments for `CNF-211`–`CNF-213` (multi-reviewer loop, pass 3)

**BLOCKING** — `CNF-211` (a setup fee dropped or double-counted, depending on which branch the
implementation guessed), `CNF-212` (duplicate provider cancellations by timer), `CNF-213` (a
minted `topup` would inflate the float, and the personal-data half is `ADR-0005`).

**PRE-SCALE** — none.

### Assignments for `CNF-206`–`CNF-210` (multi-reviewer loop, pass 2)

**BLOCKING** — `CNF-206` (destroyed
data on an ambiguous identifier), `CNF-207` (an invalid install body on the primary path),
`CNF-209` (a locked-out owner cannot stop a thief).

**PRE-SCALE** — `CNF-208`, `CNF-210`.

### Assignments for `CNF-195`–`CNF-203` (added 2026-08-13, from the multi-reviewer loop)

**BLOCKING** — `CNF-196` (credential disclosure by guessing a low-entropy string);
`CNF-198` (deduplicated postings stop the commitment decaying — unbilled machine time);
`CNF-199` (either a negative balance or an unfunded cancel, on the branch's own common input);
`CNF-200` (destroyed data on the launch product's primary install path); `CNF-203` (a live bearer
token persisted in a replay table).

**PRE-SCALE** — `CNF-197`, `CNF-201`, `CNF-202`. Each blocks a workflow or leaves a
machine in rescue rather than losing money or data.

## The blocking count

**Stated here and nowhere else, because it was wrong twice** (`F16`, then again on 2026-08-12 when
three separate running totals disagreed by one). Every other passage that used to carry a number
now points here.

**Recount from the enumerated assignments above, not from memory.** As of 2026-08-13 the blocking
set is **approximately 135 items**, and the approximation is deliberate: an exact figure that
nobody re-derives is how the last three wrong numbers happened. **Before launch, count the
BLOCKING labels mechanically and record the result with its date.** A checklist whose own
arithmetic is folklore is the failure `CNF-1`/`CNF-3` exist to prevent, applied to itself.
