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
`CNF-102`–`CNF-105`, `CNF-110`. *`CNF-114` was listed here and was merged into `CNF-188`, which is
BLOCKING, on 2026-09-02 — the duplicate had also been sitting a tier below its survivor.*

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

**BLOCKING** — `CNF-132`, `CNF-133`, `CNF-134`, `CNF-135`, `CNF-136`, `CNF-137`. Applying the three questions to key custody gives the same answer every
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

- [ ] **CNF-71** A provider credential cannot be read from `api` or from `ledger`, and the
      guarantee is enforced by the code rather than by convention. Prove it the way the
      language allows: in Rust, the credential-owning type is private to `engine` and
      reachable only through a trait that does not expose it, demonstrated by a **compile-fail
      test** asserting that code in either other module referencing it does not build. A comment
      saying "do not use this here" is not a proof. *`ledger` joined this item on 2026-09-02: it is
      a module `engine` depends on, so a credential reachable from it is a credential reachable from
      the money code.* (`OVR-10a`, `OVR-9`)
- [ ] **CNF-72** A static tripwire fails CI when a new import, re-export, or `pub` visibility
      change makes the credential type reachable from `api` or `ledger`. The boundary
      must fail closed as the code grows; the compile-fail test of `CNF-71` proves today's
      state, this proves tomorrow's. (`OVR-10a`)
- [ ] **CNF-73** **REWRITTEN 2026-09-02 — it asserted the thing `OPS-27` requires.** `api` holds no
      provider credential, and `engine` holds no customer credential and no **payment-rail**
      material — no Lightning or on-chain credential, no destination derivation, no settlement
      subscription (`STO-30`–`STO-32`, `SEC-48`). It **does** write ledger entries and commitments,
      through `ledger`, because `OPS-27` requires a worker to commit the setup-fee debit and the
      commitment decrement in the same transaction as the machine row. Assert on the types each
      module's constructors accept, and on the dependency edges (`CNF-251`), not on runtime values.
      *Withdrawn text:* the lifecycle layer holds no customer credential **or payment material** —
      which, read against the module table, made the product's terminal money write illegal in every
      module that could perform it. (`OVR-10b`, `OVR-9`, `OPS-27`)
- [ ] **CNF-74** Operator-only routes — requeue above all, since it can re-issue a purchase
      (`API-19`, `OPS-20`) — are not served on the customer-facing listener. (`API-27`)
## Tenancy and authorization

- [ ] **CNF-4** Tenant A cannot read, refresh, power, install on, or delete tenant B's
      machine; every attempt returns `404`, never `403`. (`API-17`, `SEC-8`)
- [ ] **CNF-5** **REWRITTEN 2026-09-02 — it tested a tenant-facing adopt that `API-18` abolished.**
      Adoption is operator-only, so the entitlement question is no longer "may this tenant claim
      this machine" but "does the operator's own assignment name it": (a) a **customer**-authenticated
      request to `POST /v1/machines/adopt` returns `404`, never `authentication` — the route's
      existence is not customer-observable (`WIR-34`); and (b) an **operator** adopt naming an
      external identifier absent from the operator-maintained assignment of external machine
      identifiers to tenants is refused, and that assignment is unique per external machine
      (`SEC-10`, `STO-17`). *Withdrawn text:* a tenant naming a valid provider account and a valid
      external identifier it is not entitled to gets an error, not a machine — which no conforming
      build can reach, since the tenant gets `404` at the door. (`API-18`, `SEC-7`, `WIR-34`,
      `DEF-1`)
- **CNF-6** — **MERGED INTO `CNF-107` 2026-09-02.** It read "two tenants cannot both hold a record
      for the same external machine"; `CNF-107` reads "two tenants cannot both hold the same
      `(provider_account, external_id)`, enforced by the store, not by application code" — the same
      control, tested twice and counted twice in the BLOCKING total. `CNF-107` is the survivor
      because it names the constraint that enforces it. Identifier retained rather than reused, and
      not a checkbox: like `CNF-31`, it is a marker rather than an item.
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
      `needs_reconciliation` — never back to `queued`. **AMENDED 2026-09-02 — with `OPS-14`'s one
      exception, which this item contradicted.** A `suspend_tenant` **parent** whose lease expires
      goes back to `queued` and resumes its fan-out; both halves must hold, and an implementation
      that passes the first clause universally fails `OPS-14` and strands every suspension whose
      worker crashed. The parent mutates no provider itself and `OPS-39`'s trigger ids make the
      re-sweep enqueue nothing twice, which is why it is the exception. (`OPS-14`, `API-58`,
      `OPS-39`)
- [ ] **CNF-30** The sweeper does not overwrite an error already recorded. (`OPS-16`)
- **CNF-31** — **SPLIT 2026-08-09** into `CNF-31a` and `CNF-31b`. The original conflated two
      different stakes: rows where a misclassification causes a repeated provider mutation, and
      rows that only need covering for exhaustiveness. They belong in different tiers, and the
      undivided item was consequently listed in two of them. Identifier retained rather than
      reused, per the append-only convention in the README.
- [ ] **CNF-31a** The rows of `OPS-11` where a misclassification causes a repeated provider
      mutation. A create failing with a provider 4xx is `failed`; a create failing with a
      provider 5xx, a network error, or a timeout is `needs_reconciliation`; every install
      failure that is not a deterministic caller error **and that `OPS-45`'s markers do not clear**
      is `needs_reconciliation`. Getting these
      wrong invites the caller to retry a mutation that already happened. **AMENDED 2026-09-02 —
      the install clause was unconditional and `OPS-45` narrowed it**: a failure with the disk
      untouched and the rescue session closed cleanly is deterministic, and classifying it ambiguous
      is the defect that made `RSC-3`'s host-key abort an operator-resolved loss. The clause matters
      in both directions, so assert both: an install past the write marker is never `failed`, and
      one short of it with a clean exit is never `needs_reconciliation`.
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
      routes to `needs_reconciliation` **in single-pass mode, where verification completes only
      after the overwrite has begun** (`RSC-29`) — which is what sets `OPS-45`'s write marker. **In
      `RSC-30`'s two-pass mode the same mismatch is caught in scratch with nothing written, so the
      marker is unset and the operation settles `failed`.** Both, and the difference is the point:
      the two modes make different claims about the disk and must not report the same outcome.
      *Amended 2026-09-02; stated unconditionally it failed the mode `RSC-30` says SHOULD be the
      default.* (`RSC-29`, `RSC-30`, `OPS-11`, `OPS-45`)
- [ ] **CNF-45** On uncertain rescue exit, the recovery key is persisted and its path,
      with the rescue address and port, appears in the operation error. (`RSC-19`)
- [ ] **CNF-46** The recovery directory is created owner-only. (`RSC-20`)
- [ ] **CNF-47** The inventory report is attached to the operation result **for every operation that
      enters rescue, and only for those** — the two rescue-entering install strategies and
      `RSC-38`'s inventory pass; a `provider_native` or `provider_catalogue` install returns `{}`,
      since neither boots anything and neither can read a disk (`RSC-33`, `WIR-10b`). An
      unparseable report is captured raw rather than dropped. (`RSC-33`, `RSC-34`, `WIR-10b`)
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
      acknowledges everything and assert the ceiling stops it. **AMENDED 2026-09-02 — assert the
      refusal, not only the stop.** The rejection is kind `ceiling_exceeded` (`DOM-17`), never
      `rate_limited` and never `halted`, and carries `details.ceiling`, `details.limit`,
      `details.interval_seconds` and `details.retry_after_ms` (`WIR-9a`). It happens at `API-7`
      step 5c: **after** the idempotency fingerprint, so a replay returns its stored result rather
      than spending a slot twice, and **before** any commitment opens or anything is enqueued.
      Assert both exemptions. An exposure-reducing system cancellation is not refused by a
      principal's destruction ceiling (`OPS-39`), or a tenant that hit its limit keeps machines the
      operator pays for. **And a requeue of an exposure-reducing operation is admitted at 5c even
      when the operator principal's requeue ceiling is exhausted** — it is the only recovery
      `OPS-44` leaves for a cancellation that failed deterministically, and refusing it one step
      after 5b admitted it is a machine that bills forever, produced by a safety control. *Until today this item was BLOCKING against a taxonomy that could not express its
      rejection and a pipeline that never performed its check.* (`SEC-39`, `DOM-17`, `API-7`,
      `WIR-9a`, `OPS-39`)
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

- [ ] **CNF-76** **REWRITTEN 2026-09-02** — it tested `issuable_at`, which `API-33` withdrew: the
      delay no longer sits after issuance, so "no usable credential before the delay elapses" is
      false of a conforming build. It now tests the gate that replaced it: `POST /v1/enrol` is
      refused `invalid_request` with no admission token, with an expired one, with an unknown one,
      and with one already spent — and the four refusals are **indistinguishable** to the caller, so
      the endpoint is not a free oracle for tuning the attack it exists to slow. The credential
      returned by a successful enrolment works immediately. *Withdrawn text:* Enrolment returns no
      usable credential before the configured delay elapses, and the not-yet response does not
      disclose the remaining time precisely. (`API-33`, `WIR-49`, `WIR-12`)
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
      — **unconditionally**, since `API-33` withdrew `issuable_at` and the token is live from the
      enrolment response (`API-43`) — and **nothing else**; every
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

- [ ] **CNF-132** **AMENDED 2026-09-02 — it asserted the clause `SEC-48` withdrew.** No spending key
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
- [ ] **CNF-133** Address derivation and payment observation both work with watch-only material
      only. Removing everything but the extended public key breaks nothing in the funding path.
      (`SEC-48`, `LDG-50`, `LDG-57`)
- [ ] **CNF-134** The solvency check completes with no spending key present. (`LDG-53`, `LDG-17`)
- [ ] **CNF-135** **AMENDED 2026-09-02 — it tested an automatic, channel-only sweep, and `SEC-49`
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
- [ ] **CNF-147** **AMENDED 2026-09-02 — it required a scheduled cancellation on a product that
      cancels immediately.** The dedicated path is exercised end to end against a real Hetzner Robot
      machine: a setup fee committed before the order and debited on confirmed acceptance
      (`LDG-39`), and a commitment sized to include cost through the machine's **read**
      `earliest_cancellation_date`. The cancellation is then asserted **against what the machine
      actually says**, which is `PRV-13c`'s read-and-branch: where that date is today — the normal
      case for a newly ordered current-generation server, per `08-provider-notes.md` — cancellation
      is immediate and billing stops; where it is materially in the future, the machine goes to
      `cancellation_scheduled` with its effective date and billing continues until it arrives
      (`DOM-19`, `STO-8a`). **Both branches must be covered, and adoption is the road to the second
      one** — an adopted machine carries whatever contract it came with, which is why `PRV-13c`
      calls it the main road onto the exception branch. *Withdrawn clause:* "a cancellation that
      schedules rather than deletes, and billing that continues until the effective date", asserted
      unconditionally — which `08-provider-notes.md` records as not existing on current Robot
      servers, so the item was unpassable on the product it was written for and would have been
      "fixed" by encoding a commercial term `PRV-13c` forbids as a constant. **The requirements this
      tests were all written before any of them had run.** (`LDG-39`, `PRV-13b`, `PRV-13c`,
      `DOM-19`, `PRV-31`)
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
- [ ] **CNF-185** **AMENDED 2026-09-02 — the invariant needs a fixed rate to be stated against, and
      the withdrawn wording was satisfiable only by the defect.** **At a constant rate**, metering
      the same period at one-minute and one-hour cadence produces the **identical** total charge:
      rounding is cumulative, not per tick — a property test over arbitrary subdivision. **Under a
      moving rate the totals may differ, and the item asserts the bound rather than equality**: each
      cadence prices each increment at the rate in force when that increment closed (`LDG-38`), so
      the two totals differ by at most the rate movement across one increment of the coarser
      cadence, and **neither cadence ever re-prices an increment already posted**. The bound is
      stated as an inequality over the whole period — the sum over increments of
      `net_seconds_i × |rate movement across increment i|` — rather than as a single increment's
      worth, because under a trending rate the per-increment errors share a sign and accumulate.
      *Withdrawn
      wording:* an unconditional "identical total charge", which under a moving rate is satisfiable
      **only** by re-pricing the whole period at the latest rate — the defect this item sat next to
      and appeared to endorse. (`LDG-38`, `LDG-28`, `LDG-4`)
- [ ] **CNF-186** Two credited payments each below the activation minimum, summing above it,
      activate the tenant atomically. (`LDG-52`, `API-35`)
- [ ] **CNF-187** A machine deleted while a billable attachment survives keeps its commitment
      open and keeps metering that attachment; the commitment closes only when the last billable
      resource stops. (`LDG-32`, `PRV-13a`, `STO-18`)
- [ ] **CNF-188** An unreachable provider account or rejected credentials leave commitments
      **open**, with the carried exposure recorded as an **operator deficiency** (`LDG-66`); only
      confirmed termination closes them and returns their reserved satoshis to available. Run it
      against `07-security-requirements.md` itself, because that amendment was written on
      2026-08-13, failed to apply, and shipped as prose claiming it had. *Absorbed `CNF-114` and
      `CNF-195`, which each tested the same table.* (`SEC-46`, `LDG-66`, `LDG-32`)
- [ ] **CNF-189** The enrolment response carries both secrets **once**, they are stored hashed
      only, both work from that moment, and neither is ever returned by the handle poll. Losing the
      response loses the credentials — and the tenant is unfunded, so nothing of value is stranded.
      *"Both work from that moment" replaced an `issuable_at` window on 2026-09-02 (`API-33`).*
      (`API-33`, `API-55`, `STO-34`, `WIR-12`)
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
- **CNF-195** — **MERGED INTO `CNF-188`.** Both tested `SEC-46`'s retained-commitments table
      and both were counted BLOCKING, double-counting one control. `CNF-188` is the survivor and
      gains this item's second half: the carried exposure MUST appear as an operator deficiency
      (`LDG-66`), and the test MUST be run against `07-security-requirements.md` itself, because
      that amendment was written on 2026-08-13, failed to apply, and shipped as prose claiming it
      had. *The checkbox was removed 2026-09-02: the blocking count already described this item as
      "correctly absent — a split and merge marker, not an item", while it was still a live
      checkbox anyone could tick.*
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
      `rescue_ssh`; a failure whose rescue exit **also** failed classifies like an install, not like
      a refresh — the machine can be left in rescue — while one whose exit succeeded is `failed`,
      since the pass writes nothing to a disk and `OPS-45`'s first marker is never set for it. Both
      halves; classifying every inventory failure as ambiguous fills an operator's queue with runs
      that ended cleanly. (`WIR-40`, `DOM-10`, `OPS-11`, `OPS-45`)
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
- [ ] **CNF-208** **AMENDED 2026-09-02 — one instant, because the other no longer exists.** The
      enrolment status poll never returns `expires_at`; only the enrolment response does, and the
      poll's status enum is exactly `pending` | `active` | `suspended` — the third added 2026-09-02,
      since `tenants.status` admits it and a suspended tenant's handle had no legal answer without it.
      Publishing the signup's deadline on an
      unauthenticated, handle-addressable endpoint yields its creation instant by subtraction from
      `API-34`'s stated time-to-live. *`issuable_at` was the other half of this item and was
      withdrawn with the field (`API-33`).* (`WIR-13`, `API-33`, `API-34`)
- [ ] **CNF-209** A suspended tenant can still revoke its spending token. Gating maintenance on an
      active tenant locks the owner out exactly when revocation matters. (`API-7`, `API-56`)
- [ ] **CNF-210** An orphaned deposit is credited to a named tenant exactly once through the
      operator attribution endpoint; a second call naming a different tenant is `409`. (`WIR-42`,
      `API-34`)
- [ ] **CNF-211** **REWRITTEN 2026-09-02 — it tested the seizure `LDG-31` forbids.** An ambiguous
      create that resolves *observed* **while its commitment is still open** debits the setup fee
      against that commitment and decrements it in the same transaction. Resolving *after* `OPS-33`
      released it debits the customer **nothing**: the fee becomes an operator deficiency
      (`LDG-66`, cause `unrecoverable_setup_fee`), `LDG-67`'s parked obligation is cleared in the
      same resolution transaction, available balance does not move, and a wind-down commitment
      `OPS-36` opened on the same machine is **not** decremented. Both halves, and the second is the
      one three requirements disagreed about. (`LDG-39`, `LDG-67`, `LDG-31`, `LDG-66`, `OPS-33`)
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
      compensating credit, because `already_charged` and `exact_total` both moved by the
      correction's own magnitude (**amended 2026-09-02** — it said `billable_seconds`, which under
      per-increment pricing is no longer a term in the charge; the seconds channel still moves, and
      what it keeps honest is `meter_totals` and `LDG-72`'s audit). Assert
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
- [ ] **CNF-257** **The install gate reads the matched attempt's copy, and nothing tests it today.**
      Resolve an ambiguous create whose *earlier* attempt landed, and assert the attached machine's
      `install_strategies` is the snapshot from that attempt's `request_summary` entry — not the
      latest attempt's, and not the offer as it stands now. Then assert an install naming a strategy
      absent from that copy is refused before enqueue. **No conformance item anywhere mentioned
      `install_strategies` before this one**, and `05-persistence.md` calls it a safety gate: get it
      wrong and a disk-wiping install is authorized on a machine that cannot take one. (`OPS-13`,
      `WIR-30`, `DOM-13`)
- [ ] **CNF-258** **Adopt places a commitment and gets a runway.** An adopt with insufficient
      available balance is refused with no provider call; a successful one opens a commitment, sets
      `runway_until`, and the machine enters the exhaustion sweep. Without it an adopted machine
      consumes unstoppable billable compute against a balance nobody checked, and `PRV-13c` names
      adoption as the main road onto the branch where cost cannot be stopped quickly. (`LDG-36`,
      `LDG-12`, `PRV-13c`)
- [ ] **CNF-259** **Idempotency still works after the payload is purged.** Re-send a key whose
      operation has settled and whose `request` is gone: a byte-equivalent body returns the stored
      result, a different one is `409`. Asserted against the canonical digest, since the payload it
      would otherwise compare against no longer exists — which is the case `API-38` was written for
      and `CNF-21` cannot reach. Both failures end in a duplicate purchase. (`API-38`, `API-11`,
      `ADR-0005`)
- [ ] **CNF-260** **A machine never has two open commitments.** Attempt every path that opens one
      against a machine that already has one — create, requeue reuse, `LDG-62`'s extend on a machine
      with none, `OPS-36`'s wind-down — and assert the store refuses. `OPS-20`'s reuse rule and
      `LDG-31`'s "that machine's commitment" both rest on this and it was stated only as a storage
      constraint. (`LDG-30`, `STO-23`)
- [ ] **CNF-261** **Two workers race the machine lock and one loses.** Concurrent claims against one
      machine: exactly one holds it, the other defers to `queued`; a lock whose lease expired is
      taken over; a lock held live is not. Asserted under load against the storage primitive, not
      the API. `CNF-26` races the operation claim; nothing raced this. (`STO-2`, `OPS-9`,
      `machine_locks`)
- [ ] **CNF-262** **Two re-derivations of one machine do not both apply.** Concurrent commitment
      adjustments against the same row: one succeeds, the other's conditional write on `version`
      affects no row and is retried or refused. This is the primitive `LDG-34` exists for and it had
      no test. (`LDG-34`, `STO-28`)
- [ ] **CNF-263** **The write target is verified to be a block device at run time.** A resolved
      identifier pointing at a regular file, a partition, or anything that is not a whole block
      device aborts before any write. `CNF-192` covers identity; this covers what the identity
      resolves to. (`RSC-27`, `RSC-26`)
- [ ] **CNF-264** **A PTR may only be set on an address the machine actually holds.** A
      reverse-DNS request naming an address absent from the machine's recorded list is refused
      before the driver is called, including an address belonging to another machine in the same
      provider account. (`API-16`, `PRV-25`)
- [ ] **CNF-265** **Catalogue install verifies in transit and never interprets.** The caller's image
      is fetched by provisiond, its digest verified as it streams, and a mismatch aborts before
      anything reaches the provider; the caller's own URL is never sent to the provider; an image
      exceeding the offer's `max_image_bytes` aborts the transfer rather than completing it; and the
      declared `format` and `compression` are taken on trust — asserted by supplying a
      deliberately mislabelled image and confirming provisiond does not inspect it. (`RSC-39`,
      `RSC-40`, `SEC-21`)
- [ ] **CNF-266** **The import runs outside the machine lock and is bounded.** During the import the
      machine's lock is free — a concurrent exposure-reducing cancellation acquires it and runs —
      and the lock is taken only for the switch-over. An import exceeding the stated maximum wait
      aborts the operation and deletes the imported image. (`RSC-41`, `OPS-8`, `PRV-13b`)
- [ ] **CNF-267** **Both image copies are purged, and an orphan is swept.** On settle and on entry
      to `needs_reconciliation`, the operator's re-hosted copy and the provider's imported one are
      both gone. Then the case that matters: lose the provider-side delete's reply and assert the
      account sweep deletes the image on its next pass, treating an "already deleted" rejection as
      success. A copy of a customer's operating system left in the operator's account is the
      failure, not the storage charge. (`RSC-42`, `OPS-32`, `OPS-11`, `ADR-0005`)
- [ ] **CNF-268** **A catalogue install settles on the provider's word and says so.** With an image
      that boots unreachable, the operation still settles `succeeded`, provisiond makes no
      reachability probe, the machine's `last_install` reports
      `bytes_verified_by_provisiond: false`, and the offer carried non-null `guest_requirements`.
      **The absence of the probe is the assertion** — a caller's image may legitimately ship no SSH
      daemon. (`RSC-43`, `DOM-29`, `WIR-30`, `OVR-1`)
- [ ] **CNF-269** **`last_install` outlives the operation that wrote it.** Install a machine, let
      retention delete the settled operation (`STO-14`), and assert the machine still reports the
      strategy, the verification flag and the instant. A machine that outlives the record of how it
      came to be is the defect `OPS-39`'s trigger id and `STO-43`'s ages were both moved onto this
      row to avoid. (`DOM-29`, `STO-14`)
- [ ] **CNF-270** **An imported image is not reachable by another tenant, and does not outlive its
      install.** No caller-supplied input reaches the provider's image identifier — a caller can
      name a URL and nothing else — so no tenant can build from another's image through this system.
      The image is gone once the operation settles, and the deployment has stated how many tenants
      share one provider account (`SEC-43`). Assert the first clause against the request surface,
      not by reading the driver. (`SEC-55`, `RSC-42`, `API-17`, `SEC-43`)

### Added 2026-09-02 (the two-reviewer pass that returned NOT BUILDABLE)

- [ ] **CNF-271** **A failed cancellation is retryable, and the fence does not eat its own retry.**
      Drive an exposure-reducing cancellation whose provider call fails after the fence is written —
      once with a 5xx (`needs_reconciliation`) and once with a deterministic `authentication`
      (`failed`) — and assert for each: the episode entry stays open, `destroy_committed` stays set,
      `LDG-62` is still refused `conflict`, and an operator requeue of that same operation **runs
      the provider call again** rather than aborting into a false `succeeded`. Then the other half
      of `OPS-44`'s table: a cancellation that succeeded **with the resource gone** removes the
      entry and clears the fence in the
      terminal transaction, an operator `abandoned` clears it so a later sweep can fence afresh, and
      a `failed` one appears in the operator listing `OPS-26` requires. **Then the row a reader will
      get wrong**: a cancellation the provider merely *scheduled* (`DOM-19`) settles `succeeded` and
      the entry and fence both **stay** until the effective date passes and the machine is
      tombstoned — resolving there lets the next exhaustion sweep mint a fresh episode and place a
      second cancellation against a machine already scheduled, which `OPS-39` warns can alter or
      repeat the first's mutation. **The failure this catches
      is a sweep loop that settles `succeeded` forever while the machine bills forever.**
      (`OPS-44`, `OPS-42`, `OPS-39`, `OPS-41`, `LDG-62`)
- [ ] **CNF-272** **A suspension terminates even when a child cannot delete.** Suspend a tenant
      while the provider account's credential is rejected, so every child cancellation fails
      `authentication` — deterministic, and `OPS-11` sends it to `failed` rather than to
      `needs_reconciliation`. Assert the fan-out **terminates** — a later pass enqueues nothing for
      those machines, because an episode entry exists for each — the parent settles `succeeded` with
      that child named in `WIR-39`'s `cancellations`, `WIR-41`'s resume becomes available, the
      failed child is listed for the operator, an operator requeue of it is admitted although the
      tenant is suspended (`API-7` step 5b), and the machine keeps draining runway so `LDG-13`
      reaches it unaided. Both wrong answers fail this item: a fan-out that never settles, and one
      that settles while nothing at all accounts for the machine. (`API-58`, `OPS-44`, `OPS-39`,
      `API-7`, `LDG-13`)
- [ ] **CNF-273** **A settled payment is findable afterwards, by the only handle anyone kept.**
      Settle a deposit on both rails, reap its tenant at `API-34`'s time-to-live, and then attribute
      the deposit to a fresh tenant: the two payments are enumerated from `payments` by
      `deposit_id`, each `correction` pair names that payment's own credit entry, and every entry
      carries the `deposit_id`. Assert the storage shape too, because it is what makes the rest
      possible: a payment row and its `topup` commit in one transaction (kill the process between
      them and neither survives), `payment_ref` is unique so a replayed settlement credits once, and
      a credit whose tenant identifier matches no live row is reported unattributed **by the join**
      rather than by a stored flag. **The failure this catches is a stranger's money the operator
      has made itself unable to return** — `LDG-43` calls it the one outcome the specification must
      not permit by accident, and until today the deposit binding, the payment record and the
      enumeration it needs were three MUSTs pointing at each other with no column underneath.
      (`STO-46`, `STO-30`, `STO-31`, `LDG-43`, `WIR-42`)
- [ ] **CNF-274** **A rate move never re-prices an hour already billed.** Meter one subject across a
      period, move the rate **up** between two increments, and assert the second posting charges
      only the second increment's seconds at the new rate — not the whole elapsed period. Then move
      it **down** and assert the posting is a smaller positive figure and **never negative**: a
      positive `usage_debit` is undefined (`LDG-7`) and `LDG-31` would take it as a debit to pair
      with and **grow** the commitment, which is the automatic widening `ADR-0011` abolished. Assert
      the storage shape that makes it possible: the running total carries the cumulative charge as
      an **unrounded rational**, the elapsed, absorbed and corrected seconds are maintained rather
      than summed per tick, and a seeded mismatch against a recomputation from `ledger_entries` and
      `operator_deficiencies` **fails closed** rather than posting from either figure. **Then the
      clamp**: drive a posting that exceeds the remaining commitment and assert `already_charged`
      advances by the **full** computed debit while the ledger entry carries only what the tenant's
      authority covered and the rest becomes a deficiency (`LDG-31`). Advancing it by the entry
      instead re-charges the written-off remainder on every later tick, and the error is *positive*,
      so the fail-closed guard never fires. **The failure
      this catches is a customer billed twice for hour one because the price moved in hour two** —
      silent, systematic, and invisible until someone reconciles a month by hand. (`LDG-38`,
      `LDG-72`, `STO-45`, `LDG-31`, `ADR-0011`)
- [ ] **CNF-275** **Re-derivation runs on its own clock, not the billing period's.** The deployment
      states a re-derivation interval separately from `LDG-68`'s period; `runway_until` on a live
      machine is never staler than that interval; `LDG-16`'s "more than one derivation" is measured
      in intervals and a machine at the edge is routed into exhaustion within two of them, not two
      months; and `PRV-13c`'s "materially in the future" test — *now + one interval + wind-down* —
      still puts a cancellation date a week out on the **exception** branch. Assert the last one
      against a machine whose `earliest_cancellation_date` is days away, since a monthly interval
      swallows it into the ordinary path and silently deletes the `DOM-19`/`LDG-63` branch.
      (`PRV-13e`, `LDG-68`, `LDG-16`, `PRV-13c`, `LDG-42`)
- [ ] **CNF-276** **The catalogue fetch cannot be pointed at the inside.** Drive `RSC-39` with a URL
      resolving to loopback, to `169.254.169.254`, to an RFC 1918 address, and to an IPv4-mapped
      IPv6 wrapper around each: every one is refused before a byte is sent. Then the three that a
      naive implementation passes — a name whose **second** resolution answers with a private
      address (rebinding: the connection must go to the address that was validated, or revalidate at
      connect), a public host that redirects to a private one (revalidated per hop, with the hop
      count capped), and a public host that redirects to a **scheme** change (`RSC-17`). Assert the
      refusal carries no resolved address, status or body size, so a refused fetch is not a port
      scanner with an oracle. And assert `SEC-19`'s half: with an empty allowlist, a catalogue
      install is **refused** rather than admitted to any host. **This is an SSRF primitive inside
      the process holding every provider credential and root on every customer machine** — `RSC-40`
      put the hostile input there on purpose and bounded only what is done with the bytes.
      (`RSC-44`, `RSC-39`, `SEC-19`, `RSC-17`, `OVR-10a`)
- [ ] **CNF-277** **A machine the provider destroyed stops being billed without anyone asking.**
      Delete a machine at the provider behind the system's back and then run **only** `OPS-32`'s
      sweep — no refresh, no caller request, no operator action. Assert the sweep **writes** the
      observation to the machine row, the meter posts nothing for time after that instant, and the
      commitment closes once the last billable attachment has stopped (`LDG-32`, `STO-18`). Then the
      halves that are easy to get wrong. Nothing is credited for the window **before** the
      observation, since provisiond polls rather than watches and the earlier instant is not
      knowable. Under `SEC-46`'s `account_unreachable` or `credentials_rejected` the meter
      **keeps running**, because the machines are still there and still billing the operator. A
      machine in `DOM-7`'s **`failed`** keeps being metered — it is broken, not gone, and a failed
      dedicated machine is still allocated and still invoiced. A machine with an unreleased billable
      attachment stops its **own** meter and is **not** tombstoned (`STO-18`), while the attachment
      keeps being metered on its own subject. And a sweep pass that **yields to `rate_limited` part
      way records no absence at all** — the half-listing must not close a whole account's
      commitments. Run the first half on a machine created and never refreshed — that is the
      ordinary machine, and binding the stop to a caller's refresh leaves it draining forever.
      (`LDG-74`, `OPS-32`, `STO-48`, `LDG-37`, `DOM-7`, `DOM-8`, `STO-18`, `SEC-46`)
- [ ] **CNF-278** **An account can actually be recorded lost, and the right thing happens.** Drive
      `POST /v1/provider-accounts/{account}/actions/record-status` through all four statuses:
      `account_unreachable` and `credentials_rejected` **retain** every commitment on that account's
      machines, `terminated` closes and releases them all in **one** transaction and returns the
      assigned tenants in `affected_tenants`, and `healthy` restores nothing that was released.
      Then the three refusals: recording a status the driver itself reports is `409` `state` —
      asserted against a **stubbed** driver observation, since no launch driver reports one and
      `driver_observation` is reserved (`STO-47`), and the test MUST say which it used — moving
      an account **out of** `terminated` is `409` `state`, and a customer-authenticated request is
      `404`. Assert the event is emitted with principal, account, before, after and reason. **Until
      today `SEC-46`'s three states had no verb and no column at all**, so `CNF-114`, `CNF-188` and
      `CNF-243` each fault-injected a transition nothing could perform. (`API-63`, `WIR-50`,
      `STO-47`, `SEC-46`, `LDG-32`, `API-62`)
- [ ] **CNF-279** **An install that wrote nothing and left nothing in rescue is not a mystery.**
      Drive an install against a
      machine whose pinned host key does not match: `RSC-3` aborts **before connecting**, the
      write-started marker is unset, `on_failure: exit_rescue` closes the session cleanly, and the
      operation settles **`failed`** — not
      `needs_reconciliation`, and not an operator's problem. **Then the same abort with the rescue
      exit failing: `needs_reconciliation`**, because the machine may be sitting in rescue with a
      temporary credential registered (`PRV-22`), and an untouched disk is not the same fact. Both
      halves, or the item passes an implementation that reads only one marker. `OPS-40`'s claim-time
      URL gate, which fires before rescue is entered at all, is `failed`.
      Then set the write marker — mismatch the digest mid-stream on the raw-disk path (`RSC-29`) — and
      assert `needs_reconciliation`, that `applied` and `not_applied` are both offered where
      `observed`/`absent` are not, that `not_applied` is **refused** `409` `state` while the marker
      is set, and that both are refused on a create. Assert the marker survives the payload purge.
      **The failure this catches is the differentiator's own safety abort resolving only as
      `abandoned`**, which is what happened when three create-shaped verbs were the only ones there
      were. (`OPS-45`, `OPS-11`, `OPS-31`, `WIR-35`, `RSC-3`)
- [ ] **CNF-251** **The credential boundary is a module edge, not a comment.** `api` does not depend
      on `providers` or `rescue`, depends on `engine` only through a trait whose signatures mention
      no credential type, and `engine` does not depend on `api`. **AMENDED 2026-09-02 — the money
      edge is asserted too**: `ledger` depends on `core` and nothing else, both `api` and `engine`
      depend on it, and `OPS-27`'s terminal write executes **in a worker** — one transaction
      carrying the machine row, the setup-fee debit and the commitment decrement, proved by killing
      the process between them and finding neither. A build where `ledger` can name a driver, or
      where the credential-owning type becomes reachable from `api` or `ledger`, fails to compile.
      **And every component in `OVR-17`'s table lives in the module named there** — asserted against
      the dependency graph, since a sweep in the wrong module is a credential or a rail secret in
      the wrong module. (`OVR-9`, `OVR-10a`, `OVR-17`, `OPS-27`, `ADR-0001`)
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
      permits exactly `SEC-48`'s six operations — create, look up, list, subscribe, **cancel an
      unsettled invoice**, and **read the channel and on-chain wallet balances** — and nothing else:
      attempting a payment, a keysend, an on-chain send, a channel open or close, an arbitrary
      message or PSBT signature, a peer addition or a configuration change each fail. Both halves
      are required: **a build where the cancel or the balance reads fail cannot execute `LDG-20`'s
      halt or `LDG-53`'s solvency check**, which is the failure the withdrawn four-verb scope
      guaranteed. Asserted by attempting them, not by reading the
      credential's configuration — `CNF-132`'s rule that reachability is the test, not visibility.
      (`SEC-48`, `LDG-20`, `LDG-53`, `ADR-0001`)
- [ ] **CNF-255** **The stated ceiling covers both pots and the sweep destination is pinned.**
      Channel balance plus the node's on-chain wallet is what the ceiling measures; a sweep whose
      outputs are not the pinned cold destination is rejected by the signer; and the destination
      cannot be changed by any runtime input. `CNF-135` tests the last clause for the sweep
      destination — this adds the wallet to the arithmetic `ADR-0009` is sold on. (`SEC-49`,
      `SEC-50`, `ADR-0009`)
- [ ] **CNF-256** **A signup slot costs a held connection.** `POST /v1/enrol` without a valid,
      unexpired, unused token is refused; a token is obtained only from `POST /v1/enrol/token`,
      which answers after the stated delay; a token is single-use; and issuing one writes nothing to
      the store. **A token request abandoned before the delay elapses leaves nothing collectable
      afterwards** — that is what keeps the cost a held connection rather than a free request. Then
      the test that matters: a caller cannot hold more concurrent token requests than the proxy's
      stated per-source limit, and no caller address is persisted anywhere while enforcing it. **At
      the global ceiling, enrolment sheds with `rate_limited` and a `retry_after_ms` rather than
      failing bare** (`API-41`). (`API-33`, `WIR-49`, `WIR-12`,
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
      **AMENDED 2026-09-02 — drive the third interleaving, which is the one that used to win.**
      Commit the extension **after** the worker's funding read and **before** its fence write: the
      machine must survive, which it does only if `OPS-41`'s read and `OPS-42`'s fence write are one
      serialized transaction. An implementation that reads, then extends, then fences on a still-null
      column passes the two orderings above and destroys a paid-for machine on this one.
      (`OPS-42`, `OPS-41`, `LDG-62`, `LDG-35`, `LDG-69`)
- [ ] **CNF-240** **Attribution across two tenants deadlocks under no interleaving.** Two concurrent
      `WIR-42` attributions naming each other's tenants both complete, in one transaction each, with
      the primitives acquired in ascending tenant order; and an attribution whose source tenant row
      was already reaped by `API-34` succeeds, proving the primitive does not require a live tenant
      row. (`LDG-35`, `WIR-42`, `STO-26`, `API-34`)
- [ ] **CNF-236** The running total is provably derived. An audit recomputation of **every** column
      of `meter_totals` — `charged_magnitude`, the exact-charge rational, the elapsed, absorbed and
      corrected seconds, and `high_water_increment_end` — from `ledger_entries` and
      `operator_deficiencies` equals the stored
      row; a seeded mismatch **fails closed** rather than answering from either figure. This is
      `CNF-219` applied to the second denormalised money number. **The rational is the one that
      would otherwise be believed rather than checked**: recomputing it means replaying each
      increment at the rate denormalised onto its own entry (`LDG-4`), which is the only way to
      prove no increment was re-priced. (`LDG-72`, `STO-45`, `LDG-38`, `LDG-4`)
- [ ] **CNF-216** The billing period boundary is `00:00:00Z` on the first of the month for every
      tenant and every machine, and a metered increment straddling it is apportioned across the
      two periods rather than falling wholly into either. The same test covers a deficiency's
      `absorbed_from`/`absorbed_until` window straddling the boundary. (`LDG-68`, `LDG-38`,
      `STO-37`)
- [ ] **CNF-217** No transaction holding `LDG-35`'s serialization primitive acquires a
      `machine_locks` row, waits on an operation lease, waits on a child operation, or makes a
      provider call — asserted at the storage layer over the whole suite's traffic, in the manner
      of `CNF-157`, not by code review. **The converse is NOT asserted, and asserting it would fail
      a conforming build**: `OPS-41`'s funding re-check is a worker that already holds the machine
      lock entering the primitive for a bounded read and the fence write, which is the one direction
      `LDG-69` permits and the thing `OPS-42`'s fence is built on. *Noted 2026-09-02, when that path
      became the first genuine nesting in the set; `LDG-69` had described the lock-free property as
      an accident the set happened to satisfy.* (`LDG-69`, `LDG-35`, `OPS-8`, `OPS-41`, `OPS-42`)
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

**Assignments for `CNF-233`–`CNF-234`**, which were defined without one until 2026-08-31:
**PRE-SCALE** — both. `CNF-233` catches a field silently reading `none` when nobody looked, and
`CNF-234` catches a warning being edited after a tenant may have acted on it; each is a disclosure
or record-integrity failure rather than money, data or a tenancy boundary. *An untiered item is an
unbounded commitment, by this document's own opening rule, and these two sat that way because the
assignment block was headed `CNF-222`–`CNF-232` and stopped there.*

## Surface completeness

- [ ] **CNF-149** Every endpoint the requirements mandate appears in the surface table, and every
      row in the surface table has a requirement behind it. Run as a diff, both directions —
      enrolment and funding were each mandated and unlisted for a day, and `API-33`'s admission
      token was mandated and unlisted for two reviews, which made **every enrolment**
      unsatisfiable. **AMENDED 2026-09-02 — run the same diff over the closed sets, not only over
      the routes**: `DOM-13`'s strategy/source pairings against `WIR-20`'s union, `WIR-10a`'s enums
      against the values the requirements emit, and `WIR-35`'s two resolution sets against the
      operation kinds that can reach `needs_reconciliation`. **Not `DOM-17` against `WIR-9a`**,
      which is a *minimum*-keys table by its own words — a kind whose `details` are genuinely empty
      conforms, so that diff fails by construction and would be deleted by whoever ran it first. The catalogue-install variant was missing from `WIR-20` while `DOM-13`
      carried the pairing, and three BLOCKING items tested a path no caller could request — the same
      failure as the missing route, one document over. (`API-48`, `DOM-13`, `WIR-20`, `F19`)
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
      allowlist — funding, its own deposit, that handle, and revocation. *The "at or after
      `issuable_at`" qualifier went with `issuable_at` on 2026-09-02 (`API-33`).*
      (`API-52`, `API-43`)
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
      `POST /.../actions/resolve` in each of its **five** forms — `observed`, `absent` and
      `abandoned` on a create or adopt, `applied`, `not_applied` and `abandoned` on a kind that acts
      on a machine that already exists (`OPS-31`, `WIR-35`, added 2026-09-02) — with each form
      refused **on a kind whose set does not admit it**, and `abandoned` accepted on both, since it
      is the member common to the two sets; the
      `absent` form releases the
      commitment, and a customer-authenticated request to that route — and to adopt and requeue —
      returns `404`, not `authentication`. (`WIR-35`, `WIR-34`, `OPS-31`, `OPS-45`)
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
- **CNF-114** — **MERGED INTO `CNF-188` 2026-09-02.** Both tested `SEC-46`'s three-state table and
      both were counted BLOCKING, double-counting one control — the same defect `CNF-195` was
      already the marker for, on the same requirement, which is a hint about where this document's
      duplicates come from. `CNF-188` is the survivor and carries this item's operator-deficiency
      clause. Identifier retained rather than reused, and not a checkbox.
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
4. What the image host allowlist is (`SEC-19`) — and note it is a **MUST** for the one URL
   provisiond fetches itself (`RSC-39`), where an empty list means no catalogue install rather than
   any host.
4a. **The per-source concurrency limit on `POST /v1/enrol/token`** (`API-36`, `WIR-49`). `API-41`'s
   global pending-tenant ceiling is defensible only because this one exists, so shipping the ceiling
   without stating this figure re-creates the denial of service `API-33` named. Added 2026-09-02.
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
13. **The re-derivation interval** — separate from `LDG-68`'s billing period, and the bound on how
    stale `runway_until` may be (`PRV-13e`, `LDG-42`). Added 2026-09-02; it had been read off the
    billing period, which made it a month.


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

### Assignments for `CNF-257`–`CNF-269` (coverage gaps and catalogue install, 2026-08-31)

**BLOCKING** — `CNF-257` (the install safety gate, which had no conformance item naming it at all —
destroyed data); `CNF-258` (money out: an adopted machine billing against a balance nobody checked);
`CNF-259` (both failure modes end in a duplicate purchase, which is what `API-38` was written to
stop); `CNF-260` (two open commitments double-reserve a balance and break `OPS-20`'s reuse rule
silently); `CNF-263` (destroyed data — writing a raw image to the wrong kind of device);
`CNF-264` (a PTR set on an address the tenant does not hold crosses a boundary in the operator's own
account); `CNF-265` (the only integrity check catalogue install has, plus the credential disclosure
`SEC-21` forbids); `CNF-267` (a customer's operating system left in the operator's account after the
deployment undertook to destroy it).

**PRE-SCALE** — `CNF-261`, `CNF-262`, `CNF-266`, `CNF-268`, `CNF-269`. Concurrency primitives whose
failures are contention rather than loss at concierge scale, a lock-hold bound that costs one
machine's burn, and two disclosure items. **`CNF-261` and `CNF-262` graduate the day concurrent
installs become routine**, which the tiering rule already names as a PRE-SCALE trigger.

**`CNF-270`** (added 2026-08-31 with `SEC-55`) is **PRE-SCALE**: the exposure is operator-side and
bounded by `RSC-42`'s purge to the length of one install, and no caller can reach it. It graduates
if a deployment ever retains imported images past their operation.

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

### Assignments for the 2026-09-02 two-reviewer pass

**BLOCKING** — `CNF-271` (unstoppable billing: a cancellation that can never run again while the
record claims it succeeded, which the operator would not learn from anything but an invoice);
`CNF-272` (a suspension that either never completes or completes with a billing machine on a
suspended tenant — `SEC-45`'s one action is the operator's whole remedy and it must land);
`CNF-273` (money-in, the family this checklist already calls the only one where a bug **mints**
satoshis: a payment credited twice, or a real customer's balance made unreachable forever);
`CNF-274` (retroactive re-pricing of hours the customer already paid for, or a positive
`usage_debit` growing a commitment nobody authorized — the operator would learn of either from a
customer, if at all).

`CNF-276` (the boundary-crossed family, and the escaped-secret one behind it: an anonymous stranger
aiming the credential-holding process at the operator's own metadata service or management network);
`CNF-277` (unstoppable billing for a machine that does not exist, which the customer discovers and
the operator does not); `CNF-278` (the release of every affected customer's commitments hangs on
this verb, and a wrong or reversible `terminated` re-reserves or double-releases balances across a
whole account); `CNF-279` (destroyed data on the wrong side of it: an operator told a partly written
disk was "nothing happened", and the pinned-host-key abort — this set's most security-critical
success case — reachable only as an abandoned loss).

**PRE-SCALE** — `CNF-275`. A stale `runway_until` and an over-long persistence window degrade a
disclosure and delay an exhaustion rather than losing money on the first occurrence — but it
**graduates the day a machine's runway can drain inside one interval**, because past that point
`LDG-16`'s control stops standing between a bad rate read and a destroyed disk.

## The blocking count

**Stated here and nowhere else, because it was wrong twice** (`F16`, then again on 2026-08-12 when
three separate running totals disagreed by one). Every other passage that used to carry a number
now points here.

**Counted mechanically 2026-08-31: 265 conformance items, of which approximately 175 are
BLOCKING.** The previous figure was "approximately 135" as of 2026-08-13, and the growth is real —
this review added twenty-nine items, most of them in the destroyed-data and money-out families.

**Three things the count itself established, which are worth more than the number.**

*The tiers are consistent.* `F16`'s defect — one item in two tiers — has not recurred. Seven items
appeared to be double-assigned and every one was a parser artifact: they are *mentioned* in
explanatory prose inside a tier block rather than assigned there. `CNF-99` is discussed in a
PRE-SCALE paragraph about re-tiering; it is BLOCKING and has been since `F30`.

*Two items had no tier at all.* `CNF-233` and `CNF-234` were defined on 2026-08-16 under an
assignment block headed `CNF-222`–`CNF-232`, and fell off the end of it. Now assigned. `CNF-31`,
`CNF-6`, `CNF-114` and `CNF-195` are correctly absent — they are split and merge markers, not items.

**Re-counted 2026-09-02: 271 conformance items — 275 identifiers less the four markers — of which
approximately 182 are BLOCKING.** The
two-reviewer pass of that date added nine items, `CNF-271`–`CNF-279`, eight of them BLOCKING and
every one in the destroyed-data, money-out or boundary-crossed families. It removed two by merging
duplicate pairs that had each been counted twice: `CNF-6` into `CNF-107` (one of them BLOCKING) and
`CNF-114` into `CNF-188`. `CNF-195`'s checkbox went at the same time; this passage had called it
"correctly absent" while it was still tickable, which is exactly the folklore this section exists to
stop, appearing inside the section itself.

*The number is approximate because the assignments are prose, and that is the durable problem.*
Tiers live in paragraphs scattered across the document, in item order nowhere: `CNF-183`, `CNF-182`
and `CNF-181` sit after `CNF-213`, `CNF-173` after `CNF-179`. One block read "BLOCKING — all six"
with no identifiers, which no count can resolve; it has been expanded. **Finding an item's tier
means scanning thirteen hundred lines, and counting them means writing a parser for English.** The
durable fix is to carry the tier on the item — `- [ ] **CNF-1** [BLOCKING] …` — after which the
count is a `grep` and `tools/check_ids.py` could refuse an untiered item outright. That is a
mechanical edit across 265 items and is recorded as the next obvious one rather than done here.

A checklist whose own arithmetic is folklore is the failure `CNF-1`/`CNF-3` exist to prevent,
applied to itself. It is now arithmetic with a stated method and a date, and a stated reason why it
is still approximate.
