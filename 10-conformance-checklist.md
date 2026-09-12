# 10 — Conformance checklist

What an implementation must demonstrate before it touches a real provider account. Each
item names the requirement it proves and is written so it can become a test.

The reference implementation shipped with a CI job that ran a test suite containing zero
tests, and a green check next to it. Treat any unchecked box below as that same green
check.

## Build and gate

- [ ] **CNF-1** **BLOCKING** — CI builds the project from a clean checkout, with no network-dependent
      manual steps. (`DEF-14`)
- [ ] **CNF-2** **PRE-SCALE** — The declared lint gate passes on the declared source at the declared
      strictness. If the gate is warnings-as-errors, there are no warnings. (`DEF-15`)
- [ ] **CNF-3** **BLOCKING** — The test suite fails when a test is deliberately broken — verified once,
      by hand, so that "tests passed" means something. (`DEF-16`)

## Tiering — which of these gate what

An untiered checklist is an unbounded commitment. These tiers gate *launch*; they do not forbid
doing a cheap item early. Several PRE-SCALE items are hour-sized — do them when convenient, just
don't let them block.

**The tier of record is the tag on the item line** — `- [ ] **CNF-n** **BLOCKING** — …` — which
`tools/check_ids.py` requires on every item and counts; the assignment paragraphs below are the
reasons and the graduation triggers, not where a tier is read from.

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
this witness); `CNF-4`, `CNF-7`–`CNF-9` (tenancy — three internal tenants exist from day
one, so cross-tenant control is takeover plus destruction before any external customer arrives;
*written out rather than as `CNF-4`–`CNF-9`, because that range swallowed `CNF-6` and kept assigning
a tier to a merge marker after it stopped being an item*);
`CNF-10`–`CNF-13` (injection — path injection reaches the wrong machine in the operator's whole
account, shell metacharacters reach root on the rescue system); `CNF-14`–`CNF-17` (redaction —
create responses carry machine root passwords, rescue passwords are root on customer machines);
`CNF-19`, `CNF-20` (capability gating, the enforcement direction); `CNF-21`–`CNF-25`,
`CNF-26`, `CNF-27`, `CNF-29`, `CNF-31a` (the create and ambiguity rows only — see the split below), `CNF-32`
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
`CNF-45`, `CNF-47`, `CNF-52`, `CNF-56`, `CNF-57`, `CNF-59`, `CNF-60`, `CNF-61`,
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
queue's safety machinery: an exhaustion cancel outside the queue has no per-machine
serialization (`OPS-8`), no atomic claim (`OPS-5`) and no `needs_reconciliation` path, which is a
blind mutation against a customer machine — the thing
`OVR-5` calls the single most important thing this system refuses to do.

See **The blocking count** below.

That added a further block of BLOCKING items; the total lives in **The blocking count** and
nowhere else, this passage included. **This is the honest cost
of the 2026-08-11 decisions** and it should be read as such: choosing self-serve enrolment and a
prepaid balance did not merely add features, it added a money system whose correctness gates
launch. A reader deciding whether that trade was worth it will find the number there.

### Tiering the rest of the requirement set — first pass

The same three questions apply. This pass is at *area* level with named exceptions, because an
honest per-item verdict on every requirement in the set needs a target deployment in front of you.
Treat it as a starting sort, not a ruling.

*The heading and this paragraph both said "234 requirements" until 2026-09-03; `tools/check_coverage.py`
counted 490 on that date. The figure is deleted rather than updated, on **The blocking count**'s own
finding: a number written into prose in two places disagrees with itself the first time either moves,
and this one was in two places in three lines.*

**Blocking as a whole area** — the safety spine, where a first pass is safe because almost
everything in them is irreversible:

- **`SEC-*` — the entire namespace, whatever its extent.** All of it. Every one guards a family in the irreversible
  list. Exceptions that are genuinely PRE-SCALE: `SEC-30`/`SEC-31` (rate limiting and
  starvation — a queue with one tenant cannot starve anyone), `SEC-33` (separate audit sink),
  `SEC-38` (rotation procedures, needed before the first credential ages out rather than before
  the first customer).
- **`RSC-*` — the entire namespace, whatever its extent.** Rescue writes to disks and holds root credentials. `RSC-31` (partition
  growth), `RSC-33`/`RSC-34` (inventory capture) are the plausible PRE-SCALE exceptions.
  **`RSC-39`–`RSC-44` are in scope although they enter no rescue at all**, and the reason above does
  not reach them: catalogue install has the *control plane* fetch an anonymous stranger's URL, so
  `RSC-44` is an SSRF control inside the credential-holding process (escaped-secret and
  boundary-crossed, `CNF-276`), `RSC-39`/`RSC-40` are the only integrity check that path has and the
  refusal to run a parser over hostile binary (`CNF-265`), and `RSC-42` is a copy of a customer's
  operating system left in the operator's account (`CNF-267`). `RSC-41` and `RSC-43` are the
  PRE-SCALE pair — a hold bound and a disclosure.

*Both bullets named a closing identifier — `SEC-1`–`SEC-53` and `RSC-1`–`RSC-38` — until 2026-09-03,
by which point `SEC-55` and `RSC-44` existed. **The ranges are deleted rather than corrected**: a
namespace's extent moves every time a requirement is added, and a sort that says "all of it" has no
use for a number that will be wrong again next week. `CNF-233`/`CNF-234` fell off the end of a range
block written the same way, which this document already records as a defect — the fix is the same
one, applied to the requirement sort instead of to the item sort.*
- **`PRV-6`, `PRV-9`–`PRV-13c`, `PRV-17`, `PRV-22`.** Injection, key-material timing, deletion
  semantics, rescue credential handling, ambiguity honesty.
- **`OPS-1`–`OPS-23`.** The uncertainty model is the product's most valuable property and it
  is a money-out control, not an ergonomics one.
- **`OVR-5`, `OVR-9`, `OVR-10`, `OVR-10a`, `OVR-10b`, `OVR-12`.**
- **`DOM-6`, `DOM-10`, `DOM-13`, `DOM-14`, `DOM-17`–`DOM-19`.** Redaction, capability gating,
  strategy/image pairing, digest requirement, error taxonomy, cancellation honesty.
- **`API-7`–`API-17b`, `API-22`, `API-24`, `API-25`.** Auth ordering, idempotency,
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

- [ ] **CNF-71** **BLOCKING** — A provider credential cannot be read from `api` or from `ledger`, and the
      guarantee is enforced by the code rather than by convention. Prove it the way the
      language allows: in Rust, the credential-owning type is private to `engine` and
      reachable only through a trait that does not expose it, demonstrated by a **compile-fail
      test** asserting that code in either other module referencing it does not build. A comment
      saying "do not use this here" is not a proof. *`ledger` joined this item on 2026-09-02: it is
      a module `engine` depends on, so a credential reachable from it is a credential reachable from
      the money code.* (`OVR-10a`, `OVR-9`)
- [ ] **CNF-72** **BLOCKING** — A static tripwire fails CI when a new import, re-export, or `pub` visibility
      change makes the credential type reachable from `api` or `ledger`. The boundary
      must fail closed as the code grows; the compile-fail test of `CNF-71` proves today's
      state, this proves tomorrow's. (`OVR-10a`)
- [ ] **CNF-73** **BLOCKING** — **REWRITTEN 2026-09-02 — it asserted the thing `OPS-27` requires.** `api` holds no
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
- [ ] **CNF-74** **BLOCKING** — Operator-only routes — `WIR-34`'s list; `retry` above all, since it re-dispatches
      a delete (`API-64`) — are not served on the customer-facing listener. (`API-27`)
## Tenancy and authorization

- [ ] **CNF-4** **BLOCKING** — Tenant A cannot read, refresh, power, install on, or delete tenant B's
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
- [ ] **CNF-7** **BLOCKING** — A non-admin token's tenant-override header is ignored, not honoured.
      (`API-5`, `SEC-9`)
- [ ] **CNF-8** **BLOCKING** — An unauthenticated request to every write endpoint is rejected before any
      body validation error can be observed. (`API-7`, `DEF-4`)
- [ ] **CNF-9** **BLOCKING** — `POST /v1/episodes/{id}/actions/retry` and both episode reads are refused for a
      tenant token — `404`, never `authentication`. (`API-64`, `WIR-51`, `WIR-34`)

## Injection

- [ ] **CNF-10** **BLOCKING** — An `external_id` of `1/../../other/endpoint` produces a request to the
      intended endpoint path, or is rejected outright. Assert on the constructed URL, not
      on the response. (`PRV-6`, `DEF-2`)
- [ ] **CNF-11** **BLOCKING** — An `external_id` containing `?` or `#` does not inject a query string or
      truncate the path. (`PRV-6`)
- [ ] **CNF-12** **BLOCKING** — Hostname, device path, digest, image URL, key material, and post-install
      script each containing shell metacharacters produce a remote script in which those
      values appear only base64-encoded. Assert on the generated script text. (`RSC-15`,
      `SEC-12`)
- [ ] **CNF-13** **BLOCKING** — Installer-config fields containing CR, LF, NUL, or whitespace are
      rejected. (`RSC-23`, `SEC-13`)

## Redaction

- [ ] **CNF-14** **BLOCKING** — A provider payload containing keys named `password`, `secret`,
      `private_key`, `token`, `api_key`, `authorization`, and `credential` — nested inside
      objects and arrays — is redacted before storage. (`DOM-6`)
- [ ] **CNF-15** **BLOCKING** — A **successful** provider response that the driver cannot interpret is
      redacted before it reaches the operation error. (`DOM-18`, `SEC-4`, `DEF-3`)
- [ ] **CNF-16** **BLOCKING** — No log line, operation result, or operation error in the whole test suite
      contains a rescue password or a private key. Assert by scanning captured output.
      (`SEC-3`)
- [ ] **CNF-17** **BLOCKING** — Debug formatting of the rescue session type does not reveal the
      credential. (`DOM-11`)

## Capability model

- [ ] **CNF-18** **PRE-SCALE** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed — and a field with nothing to declare says so
      explicitly rather than being absent. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
- [ ] **CNF-19** **BLOCKING** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
- [ ] **CNF-20** **BLOCKING** — Every operation on a driver that declares nothing returns `unsupported`,
      not a panic and not a wrong default — except `PRV-2`'s three named exceptions, each
      asserted for its own stated behaviour instead: describe capabilities and get machine are
      implemented (`PRV-3`), and refresh rescue session returns the session unchanged (`PRV-19`).
      (`PRV-2`)

## Idempotency

- [ ] **CNF-21** **BLOCKING** — Same key, byte-equivalent body, twice: one operation, both responses
      identical. (`API-11`)
- [ ] **CNF-22** **BLOCKING** — Same key, different body: `409`, and no second operation exists.
      (`API-11`)
- [ ] **CNF-23** **BLOCKING** — Same key, different tenants: two independent operations, neither
      observable by the other, and no internal error. **Same key, a tenant and an operator; and
      same key, two operator identities: the same three assertions** (2026-09-05 — operator
      writes carry the key and had no scope). (`API-10`, `STO-4`, `STO-35`)
- [ ] **CNF-24** **BLOCKING** — Semantically identical bodies differing only in JSON key order do not
      produce a spurious conflict. (`API-12`)
- [ ] **CNF-25** **BLOCKING** — `retry` with the same key twice enqueues one attempt and returns the same
      episode view. (`API-64`, `WIR-24`)

## Operation lifecycle

- [ ] **CNF-26** **BLOCKING** — Two workers racing to claim one queued operation: exactly one wins.
      (`OPS-5`)
- [ ] **CNF-27** **BLOCKING** — Two operations on one machine: the second is deferred back to `queued`,
      not failed, and runs after the first releases — and the deferral is the store's refusal
      (`STO-51`'s index), not an application-level check. **Then the claim-number case** (added
      2026-09-12, `ADR-0022`): with an operation deferred by its first execution, let a second
      execution claim it, then replay the first execution's defer write carrying its old
      `claim_number`, and assert it affects **no row** and the second execution's operation is
      still `running`; assert that the same write with only the claim term removed *does* affect
      the row, which is the evidence the term is doing work. (`OPS-8`, `OPS-6`, `STO-51`, `STO-3`)
- [ ] **CNF-29** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0016`) — the sweep has no deadline; the startup pass
      is the sweep.** Every operation found `running` when the engine starts is moved to
      `needs_reconciliation` — never back to `queued` — and the count is logged. Kill the engine
      with an operation of each dispatching kind `running`, restart, and assert each one — **except
      a `refresh`, which settles `failed`** (`ADR-0020`): assert its row is `failed` with an
      `internal` error and that `WIR-35`'s resolve refuses it by kind. (`OPS-15`)
- [ ] **CNF-30** **PRE-SCALE** — The startup pass does not overwrite an error already recorded. (`OPS-16`)
- **CNF-31** — **SPLIT 2026-08-09** into `CNF-31a` and `CNF-31b`. The original conflated two
      different stakes: rows where a misclassification causes a repeated provider mutation, and
      rows that only need covering for exhaustiveness. They belong in different tiers, and the
      undivided item was consequently listed in two of them. Identifier retained rather than
      reused, per the append-only convention in the README.
- [ ] **CNF-31a** **BLOCKING** — The rows of `OPS-11` where a misclassification causes a repeated provider
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
- [ ] **CNF-31b** **PRE-SCALE** — The remaining rows of `OPS-11`, for exhaustiveness — including that the table
      is *total*: every error kind in `DOM-17` has a defined classification for every operation
      kind, with no implicit default.
- [ ] **CNF-32** **BLOCKING** — Nothing in the system retries an ambiguous mutation. Assert by counting
      driver invocations across a failure scenario. (`OPS-12`, `SEC-27`)
- [ ] **CNF-33** **PRE-SCALE** — An operation is executed correctly after a full process restart between
      enqueue and claim. (`OPS-2`, `STO-5`)
- [ ] **CNF-34** **PRE-SCALE** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. (`OPS-23`)
- [ ] **CNF-35** **PRE-SCALE** — `GET /v1/operations?status=needs_reconciliation` returns them, paginated.
      (`API-23`, `DEF-8`)

## Rescue and installation

- [ ] **CNF-36** **BLOCKING** — Every row of the host-key decision table in `RSC-3` is covered, including
      the two abort cases: no keys and no opt-in; and caller keys that do not overlap
      driver keys.
- [ ] **CNF-37** **BLOCKING** — A pinned connection is never downgraded to first-use trust, including
      when the driver returns an empty key set on a later refresh. (`RSC-5`, `PRV-20`)
- [ ] **CNF-38** **BLOCKING** — Host-key comparison is canonical: the same key with a different comment,
      a leading host pattern, or extra whitespace compares equal; a different key does
      not. (`RSC-6`)
- [ ] **CNF-39** **PRE-SCALE** — The host-key wait deadline scales with the configured boot timeout.
      (`RSC-9`, `DEF-5`)
- [ ] **CNF-40** **BLOCKING** — A rescue password never appears in a command line. Assert on the spawned
      process's argument vector. (`RSC-11`)
- [ ] **CNF-41** **BLOCKING** — The generated installer config disables copying rescue authorized keys
      into the installed system. (`RSC-12`)
- [ ] **CNF-42** **PRE-SCALE** — A rootfs install with no authorized keys is rejected; a raw-disk install
      *with* authorized keys is rejected. (`RSC-13`, `RSC-14`)
- [ ] **CNF-43** **BLOCKING** — A digest mismatch on the rootfs path aborts before the installer runs.
      (`RSC-25`)
- [ ] **CNF-44** **BLOCKING** — A digest mismatch on the raw-disk path produces an `integrity` error and
      routes to `needs_reconciliation` **in single-pass mode, where verification completes only
      after the overwrite has begun** (`RSC-29`) — which is what sets `OPS-45`'s write marker. **In
      `RSC-30`'s two-pass mode the same mismatch is caught in scratch with nothing written, so the
      marker is unset and the operation settles `failed`.** Both, and the difference is the point:
      the two modes make different claims about the disk and must not report the same outcome.
      *Amended 2026-09-02; stated unconditionally it failed the mode `RSC-30` says SHOULD be the
      default.* (`RSC-29`, `RSC-30`, `OPS-11`, `OPS-45`)
- [ ] **CNF-45** **PRE-SCALE** — On uncertain rescue exit, the recovery key is persisted and its path,
      with the rescue address and port, appears in the operation error. (`RSC-19`)
- [ ] **CNF-46** **BLOCKING** — The recovery directory is created owner-only. (`RSC-20`)
- [ ] **CNF-47** **PRE-SCALE** — The inventory report is attached to the operation result **for every operation that
      enters rescue, and only for those** — the two rescue-entering install strategies and
      `RSC-38`'s inventory pass; a `provider_native` or `provider_catalogue` install returns `{}`,
      since neither boots anything and neither can read a disk (`RSC-33`, `WIR-10b`). An
      unparseable report is captured raw rather than dropped. (`RSC-33`, `RSC-34`, `WIR-10b`)
## Image policy

- [ ] **CNF-49** **BLOCKING** — A non-HTTPS URL is rejected unless insecure HTTP is explicitly enabled.
      (`API-13`, `SEC-18`)
- [ ] **CNF-50** **BLOCKING** — URLs with embedded credentials or a fragment are rejected. (`SEC-18`)
- [ ] **CNF-51** **BLOCKING** — `*.example.com` matches `a.example.com` but not `example.com`, and
      matching is case-insensitive. (`SEC-20`)
- [ ] **CNF-52** **PRE-SCALE** — An empty allowlist logs a loud startup warning. (`SEC-19`)
- [ ] **CNF-53** **BLOCKING** — A redirect from `https` to `http` is refused by the remote fetch itself.
      (`RSC-17`)

## Acknowledgements

- [ ] **CNF-54** **BLOCKING** — Install without the destructive acknowledgement is rejected; delete
      without it is rejected. (`API-14`)
- [ ] **CNF-55** **BLOCKING** — Create against an order-billed provider is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. (`API-15`,
      `PRV-10`)

## Persistence

- [ ] **CNF-56** **PRE-SCALE** — Connection-scoped settings are asserted on a freshly checked-out pooled
      connection, not on the one that ran migrations. (`STO-7`, `DEF-12`)
- [ ] **CNF-57** **PRE-SCALE** — Migrations are version-tracked and re-running them is a no-op. **Then the
      release drill** (added 2026-09-12, `ADR-0024`): with release N−1's engine and `api` running,
      apply release N's migrations through the `migrate` entry point and assert no `api` write is
      refused and no engine write exits; start two runners at once and assert one waits on
      `STO-12`'s key while the engine's startup lock is untouched; start N−1 binaries against the N
      schema and assert they serve, then start an N binary against the N−1 schema and assert it
      exits non-zero; run an N−1 `api` extension against an N engine cancellation and a settlement
      replay across the pair; and put a contract step in the same release as its expansion and
      assert the migration is refused. (`STO-12`, `STO-13`)
- [ ] **CNF-58** **BLOCKING** — An unrecognized status read from the store is a hard error. (`STO-10`)
- [ ] **CNF-59** **PRE-SCALE** — A deleted machine is tombstoned, and operations referencing it still
      resolve. (`STO-8`)
- [ ] **CNF-60** **PRE-SCALE** — The operation view never contains the stored request payload. (`API-21`)

## Deletion semantics

- [ ] **CNF-63** **BLOCKING** — For a driver in `PRV-13`'s scheduled-cancellation shape, the action result
      carries the effective cancellation date, and it is not assumed to be "now." (`PRV-13`)
- [ ] **CNF-64** **BLOCKING** — A machine with a future cancellation date is recorded
      `cancellation_scheduled`, not `deleted`, and is **not** tombstoned until that date
      passes. Assert it still appears in inventory queries that exclude deleted rows. Then record
      it gone before the date by `OPS-32`'s complete pass, and assert the earlier end is taken: the
      meter stops, and its `scheduled` episode closes `resource_gone` (`OPS-48`, `ADR-0021`).
      (`DOM-19`, `STO-8a`)
- [ ] **CNF-65** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0018`) — the cleanup path now has a method.** After
      every delete that succeeds with the resource gone, the engine calls *list attachments*
      (`PRV-45`) and writes `machine_attachments`; a release is enqueued for every row whose kind
      the descriptor declares `cleanup: api` and which is billable, and the kinds declared
      `cleanup: manual` in `surviving_attachments` (`PRV-44`) are the only ones left for the
      operator. Assert against a delete that leaves one of each. (`PRV-13a`, `PRV-44`, `PRV-45`)

## Ceilings for autonomous callers

- [ ] **CNF-69** **BLOCKING** — A principal that sets every acknowledgement flag on every request still cannot
      exceed its destruction, creation, imaging or spend ceiling. Drive it with a loop that
      acknowledges everything and assert the ceiling stops it. **AMENDED 2026-09-02 — assert the
      refusal, not only the stop.** The rejection is kind `ceiling_exceeded` (`DOM-17`), never
      `rate_limited` and never `halted`, and carries `details.ceiling`, `details.limit`,
      `details.interval_seconds` and `details.retry_after_ms` (`WIR-9a`). It happens at `API-7`
      step 5c: **after** the idempotency fingerprint, so a replay returns its stored result rather
      than spending a slot twice, and **before** any commitment opens or anything is enqueued.
      Assert the exemption. An exposure-reducing system cancellation is not refused by a
      principal's destruction ceiling (`OPS-39`), or a tenant that hit its limit keeps machines the
      operator pays for. *Until today this item was BLOCKING against a taxonomy that could not express its
      rejection and a pipeline that never performed its check.* (`SEC-39`, `DOM-17`, `API-7`,
      `WIR-9a`, `OPS-39`)
- [ ] **CNF-70** **PRE-SCALE** — The deployment has recorded *where* ceilings are enforced and what each integer
      is. Under `ADR-0001` that is this control plane — there is no front service to defer to,
      which is why the front-service variant of this rule was swept. (`SEC-39`)

## Audit

- [ ] **CNF-61** **PRE-SCALE** — Every mutating request produces an audit record with correlation id,
      identity, admin-override target if any, operation id and kind, machine, and outcome.
      (`SEC-32`)
- [ ] **CNF-62** **PRE-SCALE** — Audit records go to a destination separate from the operation store.
      (`SEC-33`)

## Enrolment and credentials

- [ ] **CNF-76** **PRE-SCALE** — **REWRITTEN 2026-09-02** — it tested `issuable_at`, which `API-33` withdrew: the
      delay no longer sits after issuance, so "no usable credential before the delay elapses" is
      false of a conforming build. It now tests the gate that replaced it: `POST /v1/enrol` is
      refused `invalid_request` with no admission token, with an expired one, with an unknown one,
      and with one already spent — and the four refusals are **indistinguishable** to the caller, so
      the endpoint is not a free oracle for tuning the attack it exists to slow. The credential
      returned by a successful enrolment works immediately. *Withdrawn text:* Enrolment returns no
      usable credential before the configured delay elapses, and the not-yet response does not
      disclose the remaining time precisely. (`API-33`, `WIR-49`, `WIR-12`)
- [ ] **CNF-77** **BLOCKING** — An unfunded pending tenant is deleted at its TTL together with its credential.
      Verified by clock advance, not by reading the code. (`API-34`)
- [ ] **CNF-78** **BLOCKING** — **REWRITTEN 2026-08-14** — the old item tested a rule two amendments had
      replaced, and no implementation could satisfy it and `CNF-125` at once: it predates
      `API-43`'s allowlist, and "until a payment has been credited" is the per-payment trigger
      `API-35` withdrew on 2026-08-13. It now tests: a pending tenant performs **no action outside
      `API-43`'s allowlist** — every other authenticated endpoint answers `not_activated` — and it
      **remains pending until its cumulative credited balance reaches the configured minimum**,
      so two credited payments that each fall short but together clear the minimum activate it.
      *Withdrawn text:* A pending tenant can perform no authorized action of any kind until a
      payment has been credited. (`API-35`, `API-43`, `DOM-20`)
- [ ] **CNF-79** **PRE-SCALE** — Enrolment rate-limiting state is never persisted — no caller address reaches
      the store or the logs. (`API-36`, `ADR-0005`)
- [ ] **CNF-80** **PRE-SCALE** — **REWRITTEN 2026-08-13** — testing "no column beyond those specified" now fails
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
- [ ] **CNF-81** **BLOCKING** — Operator credentials still come only from the environment, and no runtime-issued
      customer credential can become one. (`API-4`)

## Reconciliation and correlators

- [ ] **CNF-82** **BLOCKING** — A create writes its correlator into the provider — the operation id where a free field exists, otherwise the per-operation artifact `PRV-32` defines — and records it against the operation before the order is sent
      **in the same request that performs the mutation** — verified against a recorded provider
      request, not against a follow-up call. (`PRV-26`)
- [ ] **CNF-83** **BLOCKING** — The correlator carries no tenant identifier, customer-chosen hostname, or other
      linkable value. Anyone reading the operator's provider console learns nothing. (`PRV-26`,
      `ADR-0005`)
- [ ] **CNF-84** **BLOCKING** — Resolution attaches a resource only on an **exact** correlator match. A machine
      matching on hostname, offer and creation window but carrying no correlator is left
      unresolved, not attached. (`OPS-29`)
- [ ] **CNF-85** **BLOCKING** — Resolution performs no mutation. A driver whose search path mutates fails this
      item. (`OPS-28`)
- [ ] **CNF-86** **BLOCKING** — A sweep does not attach a resource whose operation is still `running` and not
      yielded (`OPS-8`). (`OPS-30`)
- [ ] **CNF-87** **BLOCKING** — A commitment is closed and its reserved satoshis returned once the negative
      window elapses, even though the operation remains open, and the sweep keeps searching
      afterwards. (`OPS-33`)
- [ ] **CNF-88** **PRE-SCALE** — The account-wide sweep reports an unrecorded machine to the operator and attaches
      it to no tenant. (`OPS-32`)
- [ ] **CNF-89** **PRE-SCALE** — Resolution columns are write-once; a second resolution of the same record is
      refused. (`STO-19`)
- [ ] **CNF-90** **PRE-SCALE** — **REWRITTEN 2026-08-13** — the old item tested the case `PRV-27` calls
      impossible (recording a transaction identifier the provider never returned because the reply
      was lost). It now tests: the identifier is recorded **when the provider returned one**, and
      resolution succeeds **without** it via the durable correlator (`PRV-32`, `OPS-27`).
      *Withdrawn text follows.* An order-shaped driver records the provider's transaction identifier **before**
      the outcome can be classified ambiguous. (`PRV-27`)

## Ledger and money

- [ ] **CNF-91** **BLOCKING** — No floating-point type appears anywhere in a money path. Asserted at the type
      level, not by inspection. (`LDG-1`)
- [ ] **CNF-92** **BLOCKING** — Adding two amounts with different currency codes is refused — never silently
      converted. (`LDG-3`)
- [ ] **CNF-93** **BLOCKING** — The ledger has no update or delete path at the storage layer. Attempting one
      fails; convention is not the control. (`LDG-5`, `STO-22`)
- [ ] **CNF-94** **BLOCKING** — A replayed top-up notification carrying the same idempotency key credits exactly
      once. (`LDG-8`)
- [ ] **CNF-95** **BLOCKING** — A create whose available balance is one satoshi short is rejected and **no
      provider call is made**. (`LDG-9`, `LDG-12`)
- [ ] **CNF-96** **BLOCKING** — A commitment and its operation are written in one transaction: killing the
      process between them leaves neither. (`LDG-11`, `STO-23`)
- [ ] **CNF-97** **BLOCKING** — No sequence of concurrent operations can drive a balance negative. (`LDG-10`)
- [ ] **CNF-98** **PRE-SCALE** — Remaining runway is readable from the machine view before exhaustion.
      (`LDG-15`)
- [ ] **CNF-99** **BLOCKING** — A single adverse rate read cannot cancel a machine: the deficiency must persist
      across derivations. **Asserted through the mechanism, not the outcome** (2026-09-05): feed one
      poisoned rate reading, assert re-derivation writes a past `runway_until` **and** sets
      `machines.exhausted_since`, assert the sweep does **not** route the machine while that column
      is younger than one re-derivation interval, feed a sane reading, and assert the column clears.
      **Then the two edges of the set rule**: a poisoned reading that moves a date from thirty
      minutes out to one minute past sets the column and the sweep waits, and an honest reading
      that moves a date from forty-five to forty minutes out leaves it null and the machine routes at
      forty. **Then let a runway expire with no rate movement at all and assert the machine is
      routed on the very next pass, the column still null** — a build that gates every past date on the
      interval runs each ordinary exhaustion one interval into the wind-down reserve.
      Then hold the bad rate across two intervals and assert the machine **is** routed. **Then the
      restore edge** (added 2026-09-12, `ADR-0023`): restore a store in which a machine's stored
      `runway_until` is past and `exhausted_since` null, run `STO-54`'s procedure, and assert the
      column is set to the restore instant and the sweep waits one interval; extend the machine
      inside that interval and assert the column clears and it is never routed. *The per-tick cap clause is withdrawn with the construct it tested
      (`ADR-0011`). Until 2026-09-05 this item tested a behaviour with no column, no predicate and
      no reader behind it, and a build that routed on the date alone passed it by never being fed a
      poisoned reading.* (`PRV-13e`, `LDG-16`, `LDG-58`)
- [ ] **CNF-100** **BLOCKING** — At end of runway the machine is cancelled and its disk destroyed — and the
      caller-facing documentation says so in words. (`LDG-13`, `LDG-14`)
- [ ] **CNF-101** **BLOCKING** — Under a failing solvency check, every bill-increasing operation is refused
      while cancel and delete continue to work. **The operations that reduce exposure are never
      gated by the check that fires because exposure is too high.** (`LDG-20`)
- [ ] **CNF-102** **PRE-SCALE** — The ledger contains no caller address, payment counterparty, preimage or ecash
      token. (`LDG-21`)
- [ ] **CNF-103** **PRE-SCALE** — Retention never deletes a ledger entry. (`LDG-22`, `STO-24`)
- [ ] **CNF-104** **PRE-SCALE** — Customer price is produced by exactly one function; no call site reads a
      provider price string directly. (`LDG-23`)
- [ ] **CNF-105** **PRE-SCALE** — Privileged operations are metered although they are free. (`LDG-25`)
- [ ] **CNF-106** **BLOCKING** — The reserve commits **customer** price for machine time and the setup fee **at
      cost** — a reserve computed from provider cost under-commits by exactly the margin.
      (`PRV-13b`)

## Funding

Added 2026-08-12 with `ADR-0008`. Every item here is a way to mint satoshis that do not exist or
to strand satoshis that do.

- [ ] **CNF-116** **BLOCKING** — A payment settling for less than the requested amount credits the **settled**
      value. A credit derived from `deposits.requested_sats` is the defect — assert it
      at the call site, not by reading the number back. (`LDG-47`, `STO-29`)
- [ ] **CNF-117** **BLOCKING** — An overpayment is credited in full and is never refused or truncated. (`LDG-47`)
- [ ] **CNF-118** **BLOCKING** — No credit is posted for an unconfirmed on-chain transaction at any amount, and
      an RBF replacement that lowers the value before the stated depth results in the lower credit
      or none — never the original. (`LDG-48`)
- [ ] **CNF-119** **BLOCKING** — An accepted-but-unsettled Lightning HTLC posts no credit. A held invoice that is
      later cancelled leaves the balance untouched. (`LDG-48`)
- [ ] **CNF-120** **BLOCKING** — Two funding requests never produce the same destination on either rail, and two
      tenants never share one. (`LDG-49`)
- [ ] **CNF-121** **BLOCKING** — Two funding requests from one tenant produce two distinct on-chain addresses;
      the same request retried with the same idempotency key produces **one deposit** — same
      invoice, same address. Both halves must hold — the first is the privacy rule, the second is
      the double-payment rule. (`LDG-50`, `API-45`)
- [ ] **CNF-122** **PRE-SCALE** — A payment observed at an expired deposit's address, for a live tenant, is
      credited rather than refused. Expiry ends watching, not resolution. (`LDG-51`, `LDG-54`)
- [ ] **CNF-123** **BLOCKING** — Deleting a pending tenant at its time-to-live leaves its deposits intact, and a
      later payment to one of them is recorded as unattributed rather than lost or dropped.
      (`STO-29`, `LDG-43`, `API-42`)
- [ ] **CNF-124** **BLOCKING** — Killing the process between crediting the ledger and marking the destination
      settled leaves the payment credited exactly once after recovery — not twice, not zero times.
      Replaying the rail's settlement stream produces no second entry. (`STO-30`, `STO-31`)
- [ ] **CNF-125** **BLOCKING** — A pending tenant can reach exactly `POST /v1/deposits`, `GET /v1/deposits/{id}`
      for its own deposit, the unauthenticated enrolment handle, and `POST /v1/recovery/revoke`
      — **unconditionally**, since `API-33` withdrew `issuable_at` and the token is live from the
      enrolment response (`API-43`) — and **nothing else**; every
      other authenticated endpoint answers `not_activated`. The deposit-read half is what lets a
      tenant that paid below the activation minimum see what happened to unrefundable money.
      (`API-43`, `API-52`, `DOM-20`)
- [ ] **CNF-126** **PRE-SCALE** — The solvency check counts channel balances and confirmed on-chain outputs, and
      the deployment's stated treatment of an encumbered channel balance is the one implemented.
      (`LDG-53`, `LDG-17`)
- [ ] **CNF-127** **PRE-SCALE** — An on-chain payment below the floor that covers spending its own output is
      **credited at its received value, not refused** — and the floor was disclosed with the
      destination. A deposit is payable over either rail, so the floor cannot gate the mint.
      (`LDG-52`, `LDG-47`)
- [ ] **CNF-128** **BLOCKING** — One deposit paid on **both** rails credits **both** payments. Settling the
      invoice does not stop the address being watched before expiry. This is the test that catches
      an implementation which closes a deposit on first settlement. (`LDG-55`, `LDG-56`)
- [ ] **CNF-129** **BLOCKING** — The watch set survives a restart: deposits minted before the process died are
      still being watched after it comes back, and a payment to one of them is credited. Asserted
      by killing the process, not by reading the start-up code. (`STO-32`)
- [ ] **CNF-130** **PRE-SCALE** — The watch set contains no expired deposit. Minting deposits at the rate limit
      for longer than the expiry window leaves the set bounded rather than growing. (`LDG-57`)
- [ ] **CNF-131** **BLOCKING** — The funding response states, in words a customer would understand, that an
      expired address still accepts payments the operator will not see, and that paying twice
      credits twice with no refund. **The disclosure is the control** — there is no mechanism
      behind it. (`LDG-54`, `LDG-56`, `API-44`)

## Key custody

Added 2026-08-12 with `ADR-0009`. These are the first items that make `F13`'s "one compromise
takes the machines *and* the float" partly false.

- [ ] **CNF-132** **BLOCKING** — **AMENDED 2026-09-02 — it asserted the clause `SEC-48` withdrew.** No spending key
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
- [ ] **CNF-133** **BLOCKING** — Address derivation and payment observation both work with watch-only material
      only. Removing everything but the extended public key breaks nothing in the funding path.
      (`SEC-48`, `LDG-50`, `LDG-57`)
- [ ] **CNF-134** **BLOCKING** — The solvency check completes with no spending key present. (`LDG-53`, `LDG-17`)
- [ ] **CNF-135** **BLOCKING** — **AMENDED 2026-09-02 — it tested an automatic, channel-only sweep, and `SEC-49`
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
- [ ] **CNF-136** **BLOCKING** — With inbound capacity fully exhausted, a funding request still succeeds and the
      resulting deposit is payable on-chain. **This is the test that makes `SEC-51`'s manual
      refill survivable** — without it, an operator asleep is an operator not selling. (`SEC-51`,
      `LDG-46`)
- [ ] **CNF-137** **BLOCKING** — The cold key's recovery procedure has been executed end to end, from backup to a
      signed spend, by someone other than whoever wrote it. Before the first customer payment.
      (`SEC-53`)
- [ ] **CNF-295** **BLOCKING** — **The restore rehearsal** (added 2026-09-12, `ADR-0023`). Before the
      first customer payment, by someone other than whoever wrote the procedure: take a backup,
      then in the lost interval extend a machine's runway from balance, revoke a spending token,
      let a `queued` create order and a `queued` raw-disk install write, and suspend then resume
      a tenant; restore, and run `STO-54`'s procedure in its stated order. Assert: no provider
      mutation and no disk write occurs before the first claim; the extended machine is not routed
      into exhaustion during `LDG-16`'s interval and its re-extension clears `exhausted_since`; the
      old token authenticates nothing and the recovery credential issues a new one (`API-56`); the
      create and the install are `needs_reconciliation`, never claimed, and `OPS-27` resolves the
      create `observed` against the machine the lost interval bought; the `suspend_tenant` parent
      does not resume without operator confirmation; the sweep's first pass records no absence and
      its second may; and the operator report names `T − Δ` and every unrecorded machine per
      account. (`STO-54`, `OPS-15`, `LDG-16`, `API-56`, `OPS-27`, `OPS-32`)
- [ ] **CNF-296** **BLOCKING** — **The two synchronous writes hang alone** (added 2026-09-12,
      `ADR-0023`). Stall the named standby. Assert a deposit mint and a payment credit block, every
      engine write and every other `api` write proceeds, and `OVR-18`'s alarm fires. Release the
      standby and assert the caller's re-sent funding request returns the same deposit (`API-45`)
      and the rail's replayed settlement credits once (`STO-31`). Then assert `synchronous_commit`
      reads `local` on a freshly checked-out connection (`CNF-56`'s method) and `on` only inside
      those two transactions. (`STO-7`, `STO-54`, `OVR-18`)
- [ ] **CNF-297** **BLOCKING** — **The derivation index never goes backwards** (added 2026-09-12,
      `ADR-0023`). Mint deposits, take a backup, mint more, restore, run `STO-54`'s skip-forward,
      and assert the next index allocated exceeds every index a rolled-back row held, and that no
      address is ever handed to two deposits (`LDG-49`). (`STO-54`, `LDG-49`)
- [ ] **CNF-298** **BLOCKING** — **One transaction at a time, and never across the network** (added
      2026-09-12, `F51`). With the engine's pool sized exactly to `STO-55`'s count, run every
      periodic component and a full worker set against a fleet larger than one sweep batch and
      assert no component ever waits for a second connection; instrument every provider, rail and
      rescue-host call and assert none is made while that component holds an open transaction;
      set `idle_in_transaction_session_timeout` to `STO-55`'s bound and assert a transaction
      deliberately held across a provider call is killed by the server, not by the client. Then,
      with the three `ledger` components running in the engine process (`OVR-17`), assert an `api`
      replica runs none of them. (`STO-55`, `STO-7`, `OVR-17`)
- [ ] **CNF-299** **BLOCKING** — **`overloaded` is refused before any transaction, and the pool
      keeps serving under a stalled standby** (added 2026-09-12, `F51`). Saturate one replica's
      write checkouts and assert the next write is refused `overloaded`, 503, with
      `retry_after_ms`, that `STO-35` holds no receipt for its key, that the same key re-sent after
      capacity returns succeeds as a first send, and that a read still succeeds under the separate
      read budget. Then stall the standby (`CNF-296`'s method) with more funding requests than the
      synchronous-commit cap and assert no more than the cap's connections are occupied and a
      suspension request (`API-58`) is admitted. Then let the meter fall behind its cadence by more
      than one interval and assert the alarm fires. (`STO-55`, `DOM-17`, `API-50`, `LDG-37`)

## The rate

Added 2026-08-12. Past the persistence rule (`LDG-16`), a wrong rate is the only
external input in this specification that reaches a customer's disk (`LDG-41`, `LDG-14`).

- [ ] **CNF-138** **BLOCKING** — With every rate source unavailable, a create is refused, re-derivation halts
      **without** cancelling anything, the exhaustion sweep still runs, and the solvency check
      fails closed. All four, from one fault injection. (`LDG-40`, `LDG-59`)
- [ ] **CNF-139** **BLOCKING** — No code path uses a rate older than the stated bound, and there is no
      last-known-good fallback anywhere. Asserted by removing every source and confirming the
      system reports *no rate* rather than a number. (`LDG-59`)
- [ ] **CNF-140** **PRE-SCALE** — One source returning an extreme price does not move the rate, and that source is
      excluded rather than averaged in. (`LDG-60`)
- [ ] **CNF-141** **BLOCKING** — Exclusions count against the quorum: with three sources, one stale and one
      outlying, the result is *no rate* — not a rate derived from the single survivor. **This is
      the item that catches an implementation which degrades quietly to one source.** (`LDG-59`,
      `LDG-60`)
- [ ] **CNF-142** **BLOCKING** — The source set cannot be changed by any API call, tenant input, or database
      write. Attempting each fails. (`LDG-61`, and `CNF-135` for the same property applied to the
      sweep destination)
- [ ] **CNF-143** **PRE-SCALE** — Two sources that are front-ends onto the same venue are configured, and the
      deployment's quorum treats them as one. **Independence is a claim about the world that no
      code can check**, so this is a review item against the configured list, not a runtime test.
      (`LDG-58`)

## The launch set

Added 2026-08-12 with `ADR-0010`. These test that three drivers made the contract *more* general
rather than acquiring a default.

- [ ] **CNF-144** **PRE-SCALE** — No module under `core` names a provider, branches on one, or contains a constant
      that is any provider's commercial term. Asserted against the source, not by inspection of
      behaviour. (`OVR-14`, `OVR-15`, `PRV-13c`)
- [ ] **CNF-145** **PRE-SCALE** — Removing the DigitalOcean driver from the build leaves the other two compiling
      and passing, and removing **both** Hetzner drivers leaves DigitalOcean compiling and
      passing. The second half is the real test — it is where an assumption shared by two drivers
      of one house style shows up as a dependency. (`OVR-15`)
- [ ] **CNF-146** **PRE-SCALE** — `GET /v1/providers` reports three distinguishable capability sets, and a caller
      that acts only on what it reports never invokes an operation a provider does not have.
      (`OVR-16`, `OVR-2`)
- [ ] **CNF-147** **BLOCKING** — **AMENDED 2026-09-02 — it required a scheduled cancellation on a product that
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
- [ ] **CNF-148** **BLOCKING** — **The Robot order `comment` field is never populated, by any code path** —
      Hetzner routes commented orders to manual processing (`PRV-30`, confirmed). Asserted against
      the outbound request, not by reading the driver.
- [ ] **CNF-180** **BLOCKING** — **AMENDED 2026-09-04 — the `test=true` route does not reach this, and the
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
- [ ] **CNF-289** **BLOCKING** — **`request_summary` carries nothing outside its enumeration.**
      Submit a create and an install whose bodies carry a caller-chosen hostname, SSH keys, user
      data, a post-install script, a signed image URL and a disk layout; drive each to a state that
      purges the payload; then assert `request_summary` contains **none** of them. Asserted by
      reading the stored record, not the API response — `API-21` already hides `request`, so a
      summary that quietly retained the payload would pass every surface test. This is `ADR-0005`
      enforced where it is actually enforceable: the purge is only as good as the list of what
      survives it. (`STO-50`, `STO-9`, `ADR-0005`, `OPS-13`)
- [ ] **CNF-290** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0019`) — the restart drill, and the
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
- [ ] **CNF-294** **BLOCKING** — **The lost-reply drill** (added 2026-09-12, `ADR-0022`). For a
      settled-state write, an `OPS-45` marker write and an `OPS-8` defer: let the transaction
      commit and drop the reply before the client sees it, let the worker repeat the whole
      transaction under `OPS-49`, and assert the repeat affects one row, changes no column,
      advances `revision` no further, and the worker continues — never exits. Then make the store
      refuse the write with a server-side `statement_timeout` and assert the repeat finds the row
      still `running` and lands normally. Then hold the store unavailable past the stated
      store-retry bound (`OVR-19`) and assert the engine exits non-zero with the provider outcome
      logged, never re-issuing the provider call (`OPS-12`); on restart `OPS-15` classifies the
      row. Then hold `LDG-35`'s primitive on a tenant past `lock_timeout` and assert the meter's
      write repeats as a whole transaction against the same bound rather than looping outside it.
      Then drop the reply to a *claim* and assert the engine exits rather than claiming again.
      Asserted with `STO-7`'s client deadline set no shorter than the server timeouts, and with an
      abandoned connection reset before reuse. (`OPS-49`, `OPS-22`, `STO-3`, `STO-7`, `OPS-6`)
- [ ] **CNF-291** **BLOCKING** — **The episode outlives its attempts, and there is one of it.**
      Open a `delete` episode on a machine and attempt to insert a second open `(machine_id,
      delete)` episode directly at the store: `STO-52`'s index refuses it. Then let the first
      attempt settle `failed`, run retention past `STO-14`'s horizon so the attempt row is gone,
      and assert the episode is still `stalled`, `destroy_committed` still holds its id, `LDG-62`'s
      extend-runway is still refused `conflict`, and `retry` (`API-64`) enqueues a second attempt
      whose `episode_id` is the same id. **The failure this catches is the one `ADR-0017` was
      written for**: a fence pointing at a deleted row, a machine that bills forever behind a
      permanent `conflict`, and a test that passed inside the retention window. (`STO-52`,
      `DOM-31`, `OPS-48`, `API-64`, `LDG-62`, `STO-14`)
- [ ] **CNF-292** **BLOCKING** — **An observed sample widens the window without a redeploy.** With a
      driver whose descriptor declares a visibility window of *n* seconds, dispatch a create whose
      resource first appears in the listing at *n + k* seconds and assert a `provider_observations`
      row is written with that `dispatched_at` and `observed_at` (`STO-53`); then dispatch another
      create, lose its reply, and assert resolution takes no read before *n + k* has elapsed — the
      effective window is `max(declared, max(observed))` and the process was not restarted between
      the two. Assert the descriptor value itself is unchanged, and that the same holds for
      `billing_stop_window` (`PRV-13b`). A build that reads the window from driver source
      resolves the second create `absent`, releases the commitment, and the machine arrives with
      nobody paying. (`PRV-36`, `PRV-44`, `STO-53`, `ADR-0018`)
- [ ] **CNF-293** **BLOCKING** — **An attachment is released by an operator through a route, and
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
- [ ] **CNF-288** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0017`) — the verb it tested is deleted,
      so the item asserts its absence.** **No settled operation of any kind re-enters `queued`.**
      For every operation kind, drive an operation to `failed` and to `needs_reconciliation` and
      assert there is no route — no endpoint on either listener, no operator verb, no sweep — that
      moves it back to `queued` (`OPS-4`). **A restore is the route this item did not enumerate**
      (added 2026-09-12, `ADR-0023`): it returns a settled row to `queued` by rewriting the store,
      and `STO-54` is what stands in its way — `CNF-295` asserts it. **Then assert the recovery that replaced it is scoped to the episode**: `retry` (`API-64`) on a
      `stalled` episode enqueues a **fresh** `delete_machine` attempt under the same episode id and
      leaves the failed attempt's row untouched; `retry` on an episode in any other state is `409`
      `state`; and no episode ever carries a `create_machine`, `install`, `power`
      or `reverse_dns` attempt, so none of those kinds has a second attempt by any path. A build
      that re-runs a settled create buys a machine the customer holds no credential on with the
      customer's satoshis (`ADR-0014`); one that re-runs an install lets an operator choose the
      bytes written to a customer's disk and the host-key decision `SEC-22` reserves for the caller.
      (`OPS-4`,
      `OPS-48`, `API-64`, `ADR-0014`, `ADR-0017`)
- [ ] **CNF-281** **BLOCKING** — **Resolution searches every ordering channel.** Order on one channel, resolve with
      a driver configured to query only the other, and assert the outcome is **not** resolved-absent.
      A driver that declares more than one channel and searches one fails. Without it a customer's
      balance is released in full while a physical server bought on the unsearched channel runs
      unrecorded — money out, and the operator learns of it from an invoice. (`PRV-38`, `OPS-27`,
      `OPS-32`)
- [ ] **CNF-282** **PRE-SCALE** — **An authoritative-empty search is an empty result, not an error.** Present the
      driver with the provider's empty-listing response — for Robot a `404` carrying
      `no transactions found` — and assert it reaches `OPS-27`'s resolved-absent and releases the
      commitment, and is never surfaced as `DOM-17`'s `not_found`. Both failures end with a
      customer's satoshis committed behind an order that never landed — which `OPS-31`'s `absent`
      verb undoes, so the operator can recover it and would see it in the listing. (`PRV-39`,
      `OPS-27`, `LDG-32`)
- [ ] **CNF-283** **BLOCKING** — **The ordering budget is enforced at admission.** Exhaust the driver's declared
      daily order limit and assert the next create is refused before any provider call, classified
      `failed` per `OPS-11`'s admission-only rule, with nothing ambiguous created. The budget is
      the only bound on ordering an autonomous caller cannot acknowledge past — unbounded ordering
      is the money-out family. (`PRV-40`, `OPS-11`)
- [ ] **CNF-284** **PRE-SCALE** — **An authentication failure is attempted once.** Give a driver a bad credential
      and assert it makes exactly one attempt and escalates, with no scheduled re-attempt. Asserted
      by counting requests, not by reading the code. On a provider that locks out on repeated
      failures the retry loop takes every tenant's operations offline with it — an outage the
      operator sees and the provider's support desk undoes. (`PRV-41`, `OPS-26`)
- [ ] **CNF-285** **PRE-SCALE** — **Where the offer identifier is the resource identifier, resolution reads the
      resource.** For a channel whose descriptor entry carries `offer_is_resource: true` (`PRV-44`),
      assert an ambiguous create resolves by reading the named resource rather than by searching a
      listing, and that absence is interpreted through `PRV-36`'s window. A driver that declares
      the identity and still searches is carrying `OPS-33`'s listing horizon for no reason — slower
      resolution, not a wrong one. (`PRV-42`, `PRV-44`, `PRV-36`, `OPS-27`)
- [ ] **CNF-286** **BLOCKING** — **A landed order is not attached without confirming the resource
      exists.** Resolve a create whose order record reports success and whose resource has since been
      destroyed, and assert the outcome is **not** resolved-observed: no `machines` row, no
      commitment, no meter. Without it the system bills a customer for a machine that is gone, which
      is the defect `OPS-32` was amended to close reached through the resolution path instead of
      through drift. (`PRV-43`, `OPS-27`, `PRV-36`)
- [ ] **CNF-287** **BLOCKING** — **The rescue path can reach a machine as ordered.** Assert the
      driver either orders an address the deployment can route to, with its cost carried into the
      offer price, or declares `rescue_address_family` IPv6-capable in its descriptor (`PRV-44`) —
      and that a create is refused rather than placed where neither holds. A machine bought and
      unreachable bills and drains runway with delete as the only remedy: an autonomous caller
      reaches a provider mutation whose product it cannot use, which is question (3). (`RSC-45`,
      `PRV-44`, `PRV-13b`)
- [ ] **CNF-184** **BLOCKING** — A rate outage bills the customer **nothing** for the window: no deferred
      satoshi debit is posted when the rate returns, the native accrual appears as an operator
      deficiency, and machines are cancelled at the stated maximum outage if no rate comes back.
      (`LDG-64`, `LDG-65`)
- [ ] **CNF-185** **BLOCKING** — **AMENDED 2026-09-02 (twice in one day; read the note).** Metering the same period
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
- [ ] **CNF-186** **BLOCKING** — Two credited payments each below the activation minimum, summing above it,
      activate the tenant atomically. (`LDG-52`, `API-35`)
- [ ] **CNF-187** **BLOCKING** — A machine deleted while a billable attachment survives keeps its commitment
      open and keeps metering that attachment; the commitment closes only when the last billable
      resource stops. (`LDG-32`, `PRV-13a`, `STO-18`)
- [ ] **CNF-188** **BLOCKING** — An unreachable provider account or rejected credentials leave commitments
      **open**, with the carried exposure recorded as an **operator deficiency** (`LDG-66`); only
      confirmed termination closes them and returns their reserved satoshis to available. Run it
      against `07-security-requirements.md` itself, because that amendment was written on
      2026-08-13, failed to apply, and shipped as prose claiming it had. *Absorbed `CNF-114` and
      `CNF-195`, which each tested the same table.* (`SEC-46`, `LDG-66`, `LDG-32`)
- [ ] **CNF-189** **PRE-SCALE** — The enrolment response carries both secrets **once**, they are stored hashed
      only, both work from that moment, and neither is ever returned by the handle poll. Losing the
      response loses the credentials — and the tenant is unfunded, so nothing of value is stranded.
      *"Both work from that moment" replaced an `issuable_at` window on 2026-09-02 (`API-33`).*
      (`API-33`, `API-55`, `STO-34`, `WIR-12`)
- [ ] **CNF-190** **BLOCKING** — The recovery credential revokes the spending token and issues a fresh one; the
      **spending token cannot revoke or rotate itself**. Both halves — the second is what stops a
      thief locking the owner out. (`API-56`, `WIR-38`)
- [ ] **CNF-191** **BLOCKING** — A freshly activated tenant has at least one assigned provider account,
      recorded durably — **where a healthy account exists; where none does, it activates
      unassigned, and kill the process after an account is recorded `healthy` and before the
      assignment lands: on restart the reconciling pass assigns it with no event to prompt it**
      (2026-09-05) — and successive tenants are spread across accounts rather than filling one.
      (`API-57`, `STO-36`, `SEC-43`, `STO-47`)
- [ ] **CNF-192** **BLOCKING** — An install naming a device identifier absent from a freshly re-read inventory,
      or carrying a stale `inventory_fingerprint`, aborts `integrity` **with no bytes written**.
      Verified by mutating the inventory between the rescue-inventory pass and the install.
      (`RSC-26`, `RSC-38`)
- [ ] **CNF-193** **PRE-SCALE** — A pending tenant's signup time-to-live exceeds the deposit expiry plus the
      finality window; a deposit minted at the last moment expires early enough that its own
      finality window still closes before the signup is reaped; and no tenant is deleted while a
      deposit of its own is inside that window.
      (`API-34`, `API-42`, `LDG-54`)
- [ ] **CNF-194** **BLOCKING** — Suspending a tenant blocks every **tenant-authorized** write while leaving the
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
- [ ] **CNF-196** **BLOCKING** — Enrolment ignores an `Idempotency-Key`: two signups presenting the same key
      receive **different** handles and different credentials. The withdrawn rule returned the
      same handle, and the handle's response carries both secrets. (`API-40`, `WIR-12`)
- [ ] **CNF-197** **PRE-SCALE** — A resolution transition out of `needs_reconciliation` succeeds with **no worker**
      — by sweep and by operator verb, guarded on `(id, status = needs_reconciliation)` alone —
      while a *worker* write against an operation moved by something else affects no row, **and a
      worker's repeat of its own settled-state write affects one row and changes nothing**
      (corrected 2026-09-12, `ADR-0022`: the item read "against an operation no longer `running`",
      which the repeat-admitting branch makes false for the worker's own outcome). Three halves:
      the guards are different predicates (`STO-3`), a build that applies the worker's to
      resolution can never resolve anything, and a build without the repeat branch exits on every
      lost reply. (`OPS-3`, `STO-19`, `STO-3`, `OPS-22`)
- [ ] **CNF-198** **BLOCKING** — Metering a period at a cadence that subdivides it posts every increment: no
      posting is deduplicated away by the idempotency key, and two billable attachments on one
      machine do not collide. (`LDG-8`, `LDG-38`)
- [ ] **CNF-199** **BLOCKING** — A late-attach cleanup on a tenant whose balance is **below** the wind-down floor
      opens **no commitment at all**, carries the **whole** wind-down as an operator deficiency
      rather than a shortfall against a partial one, still executes the cancel, and never drives
      available negative. (`OPS-36`, `LDG-10`, `LDG-66`)
- [ ] **CNF-200** **BLOCKING** — A rootfs install naming a drive by unstable device path is rejected; the layout
      carries stable identifiers checked against the inventory fingerprint, exactly as raw-disk
      does. (`RSC-26`, `RSC-22`, `WIR-20`)
- [ ] **CNF-201** **PRE-SCALE** — A rescue-inventory run carries a trust policy and is capability-gated on
      `rescue_ssh`; a failure whose rescue exit **also** failed classifies like an install, not like
      a refresh — the machine can be left in rescue — while one whose exit succeeded is `failed`,
      since the pass writes nothing to a disk and `OPS-45`'s first marker is never set for it. Both
      halves; classifying every inventory failure as ambiguous fills an operator's queue with runs
      that ended cleanly. (`WIR-40`, `DOM-10`, `OPS-11`, `OPS-45`)
- [ ] **CNF-202** **PRE-SCALE** — Suspending a tenant returns a `suspend_tenant` operation whose children are
      readable through `GET /v1/operations`; resume is synchronous and restores no machines.
      (`WIR-39`, `WIR-41`, `API-58`)
- [ ] **CNF-203** **BLOCKING** — A replayed revocation returns `409` and no stored bearer token appears anywhere
      in `idempotency_records`. Grep the table for the token value. (`STO-35`, `WIR-38`, `API-3`)
- [ ] **CNF-206** **BLOCKING** — A disk identifier matching **two** devices aborts `integrity` with no write, and
      an offer whose devices expose no unique identifier is unsellable for rescue installs.
      (`RSC-26`)
- [ ] **CNF-207** **BLOCKING** — A rootfs install body round-trips `partitions`, `raid.level` and per-drive
      identifiers through the parser. This fixture was silently broken by a fix in the previous
      pass, which is what a fixture is for. (`WIR-20`, `RSC-22`)
- [ ] **CNF-208** **PRE-SCALE** — **AMENDED 2026-09-02 — one instant, because the other no longer exists.** The
      enrolment status poll never returns `expires_at`; only the enrolment response does, and the
      poll's status enum is exactly `pending` | `active` | `suspended` — the third added 2026-09-02,
      since `tenants.status` admits it and a suspended tenant's handle had no legal answer without it.
      Publishing the signup's deadline on an
      unauthenticated, handle-addressable endpoint yields its creation instant by subtraction from
      `API-34`'s stated time-to-live. *`issuable_at` was the other half of this item and was
      withdrawn with the field (`API-33`).* (`WIR-13`, `API-33`, `API-34`)
- [ ] **CNF-209** **BLOCKING** — A suspended tenant can still revoke its spending token. Gating maintenance on an
      active tenant locks the owner out exactly when revocation matters. (`API-7`, `API-56`)
- [ ] **CNF-210** **PRE-SCALE** — An orphaned deposit is credited to a named tenant exactly once through the
      operator attribution endpoint; a second call naming a different tenant is `409`. (`WIR-42`,
      `API-34`)
- [ ] **CNF-211** **BLOCKING** — **REWRITTEN 2026-09-02 — it tested the seizure `LDG-31` forbids.** An ambiguous
      create that resolves *observed* **while its commitment is still open** debits the setup fee
      against that commitment and decrements it in the same transaction. Resolving *after* `OPS-33`
      released it debits the customer **nothing**: the fee becomes an operator deficiency
      (`LDG-66`, cause `unrecoverable_setup_fee`), `LDG-67`'s parked obligation is cleared in the
      same resolution transaction, available balance does not move, and a wind-down commitment
      `OPS-36` opened on the same machine is **not** decremented. Both halves, and the second is the
      one three requirements disagreed about. (`LDG-39`, `LDG-67`, `LDG-31`, `LDG-66`, `OPS-33`)
- [ ] **CNF-212** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0017`) — the dedup is a row, not a JSON entry.** Two
      consecutive exhaustion sweeps over the same machine open **one** episode and enqueue **one**
      cancellation: the second finds the open `(machine_id, delete)` episode and enqueues nothing.
      Opening a second episode per sweep is the failure, and `STO-52`'s index is what refuses it —
      assert the refusal is the store's, by attempting the second insert directly. `CNF-291` carries
      the retention half. (`OPS-39`, `OPS-48`, `STO-52`)
- [ ] **CNF-213** **BLOCKING** — Attributing an orphaned deposit posts **one `correction` pair per settled
      payment** — never a second `topup`, which would mint satoshis the original settlement already
      credited — and `operator_ref` holds no name, address or contact string. A deposit paid on
      both rails produces two pairs. (`WIR-42`, `LDG-5`, `LDG-55`, `ADR-0005`)
- [ ] **CNF-183** **BLOCKING** — No customer-facing surface — terms, API documentation, error text, marketing —
      states or implies that satoshis are held, backed, reserved or segregated against a balance,
      **and** the terms do state that a balance is an unsecured claim. Both halves: silence about
      the ratio, disclaimer about the arrangement. (`LDG-19`, `LDG-19a`, `ADR-0004` §4)
- [ ] **CNF-182** **BLOCKING** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
- [ ] **CNF-181** **BLOCKING** — On a channel with no verified correlator — Robot's **standard** channel — an
      ambiguous create ends in `needs_reconciliation` awaiting an operator, the recent-order
      listing is surfaced as evidence, and **no automatic attach occurs on any hostname or timing
      similarity**. The negative window still releases the commitment in full. **And the same
      create on the auction channel of the same account resolves automatically through
      `CNF-180`'s path** — correlation is per channel, and a build that switches it on or off
      provider-wide fails one half (2026-09-05). (`PRV-33`, `OPS-29`, `OPS-33`, `PRV-32`)
- [ ] **CNF-214** **BLOCKING** — A machine and one of its billable attachments, both metered in the same period,
      carry **separate** `meter_totals` rows: charging the attachment does not move the machine's
      rounding credit or high-water mark, and neither does the reverse. Asserted against the stored
      subject, not against `machine_id`. *Said "separate `already_charged` sums" until 2026-09-02;
      the quantity is renamed but the failure is the same one — a shared row bills two subjects as
      one.* (`STO-38`, `LDG-8`, `LDG-38`, `LDG-32`)
- [ ] **CNF-215** **BLOCKING** — **A correction is never clawed back, and the meter is not involved.** Post a
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
- [ ] **CNF-235** **PRE-SCALE** — The meter's cost per tick does not grow within a period. Meter one subject for a
      full period at a cadence that subdivides it, and assert the storage reads per posting are
      constant rather than proportional to the number of prior postings — asserted at the storage
      layer over the suite's traffic in the manner of `CNF-157`, not by reading the code. The
      running total and the entry commit together: kill the process between them and neither
      survives. **Then two zero-debit increments** (2026-09-05): one that **rounds** to nothing
      commits the meter row alone, with no ledger entry; one that **clamps** to nothing commits the
      meter row and its `STO-37` deficiency together — kill the process between those two and
      neither survives. A build that cannot write meter state without an entry, or writes it
      without the deficiency, fails one of the two. (`LDG-72`, `STO-45`, `LDG-35`, `LDG-31`)
- [ ] **CNF-257** **BLOCKING** — **The install gate reads the create's retained copy, and nothing tested it before
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
- [ ] **CNF-259** **BLOCKING** — **Idempotency still works after the payload is purged.** Re-send a key whose
      operation has settled and whose `request` is gone: a byte-equivalent body returns the stored
      result, a different one is `409`. Asserted against the canonical digest, since the payload it
      would otherwise compare against no longer exists — which is the case `API-38` was written for
      and `CNF-21` cannot reach. Both failures end in a duplicate purchase. (`API-38`, `API-11`,
      `ADR-0005`)
- [ ] **CNF-260** **BLOCKING** — **A machine never has two open commitments.** Attempt every path that opens one
      against a machine that already has one — create, `LDG-62`'s extend on a machine with none,
      `OPS-36`'s wind-down — and assert the store refuses. `LDG-31`'s "that machine's commitment"
      rests on this and it was stated only as a storage constraint. (`LDG-30`, `STO-23`)
- [ ] **CNF-262** **PRE-SCALE** — **Two re-derivations of one machine do not both apply.** Concurrent commitment
      adjustments against the same row: one succeeds, the other's conditional write on `version`
      affects no row and is retried or refused. This is the primitive `LDG-34` exists for and it had
      no test. (`LDG-34`, `STO-28`)
- [ ] **CNF-263** **BLOCKING** — **The write target is verified to be a block device at run time.** A resolved
      identifier pointing at a regular file, a partition, or anything that is not a whole block
      device aborts before any write. `CNF-192` covers identity; this covers what the identity
      resolves to. (`RSC-27`, `RSC-26`)
- [ ] **CNF-264** **BLOCKING** — **A PTR may only be set on an address the machine actually holds.** A
      reverse-DNS request naming an address absent from the machine's recorded list is refused
      before the driver is called, including an address belonging to another machine in the same
      provider account. (`API-16`, `PRV-25`)
- [ ] **CNF-265** **BLOCKING** — **Catalogue install verifies in transit and never interprets.** The caller's image
      is fetched by provisiond, its digest verified as it streams, and a mismatch aborts before
      anything reaches the provider; the caller's own URL is never sent to the provider; an image
      exceeding the offer's `max_image_bytes` aborts the transfer rather than completing it; and the
      declared `compression` is taken on trust — asserted by supplying a
      deliberately mislabelled image and confirming provisiond does not inspect it. *`format` was
      named here until 2026-09-02 and this path's body cannot carry one: its source is `raw_disk`,
      which has `url`, `sha256` and `compression` (`WIR-20`).* (`RSC-39`,
      `RSC-40`, `SEC-21`, `WIR-20`)
- [ ] **CNF-266** **PRE-SCALE** — **The import runs with the machine yielded, and is bounded.** During the import
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
- [ ] **CNF-267** **BLOCKING** — **Both image copies are purged, and an orphan is swept.** On settle and on entry
      to `needs_reconciliation`, the operator's re-hosted copy and the provider's imported one are
      both gone. Then the case that matters: lose the provider-side delete's reply and assert the
      account sweep deletes the image on its next pass, treating an "already deleted" rejection as
      success. A copy of a customer's operating system left in the operator's account is the
      failure, not the storage charge. (`RSC-42`, `OPS-32`, `OPS-11`, `ADR-0005`)
- [ ] **CNF-268** **PRE-SCALE** — **A catalogue install settles on the provider's word and says so.** With an image
      that boots unreachable, the operation still settles `succeeded`, provisiond makes no
      reachability probe, the machine's `last_install` reports
      `bytes_verified_by_provisiond: false`, and the offer carried non-null `guest_requirements`.
      **The absence of the probe is the assertion** — a caller's image may legitimately ship no SSH
      daemon. (`RSC-43`, `DOM-29`, `WIR-30`, `OVR-1`)
- [ ] **CNF-269** **PRE-SCALE** — **`last_install` outlives the operation that wrote it.** Install a machine, let
      retention delete the settled operation (`STO-14`), and assert the machine still reports the
      strategy, the verification flag and the instant. A machine that outlives the record of how it
      came to be is the defect `STO-43`'s ages were moved onto this row to avoid, and the one
      `ADR-0017` gave the episode a row of its own to avoid. (`DOM-29`, `STO-14`)
- [ ] **CNF-270** **PRE-SCALE** — **An imported image is not reachable by another tenant, and does not outlive its
      install.** No caller-supplied input reaches the provider's image identifier — a caller can
      name a URL and nothing else — so no tenant can build from another's image through this system.
      The image is gone once the operation settles, and the deployment has stated how many tenants
      share one provider account (`SEC-43`). Assert the first clause against the request surface,
      not by reading the driver. (`SEC-55`, `RSC-42`, `API-17`, `SEC-43`)

### Added 2026-09-02 (the two-reviewer pass that returned NOT BUILDABLE)

- [ ] **CNF-271** **BLOCKING** — **AMENDED 2026-09-08 (`ADR-0017`) — the episode is the unit, and `failed` is a
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
- [ ] **CNF-272** **BLOCKING** — **A suspension terminates even when a child cannot delete.** Suspend a tenant
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
- [ ] **CNF-273** **BLOCKING** — **A settled payment is findable afterwards, by the only handle anyone kept.**
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
- [ ] **CNF-274** **BLOCKING** — **A rate move never re-prices time already billed — within an increment or
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
- [ ] **CNF-275** **PRE-SCALE** — **Re-derivation runs on its own clock, not the billing period's.** The deployment
      states a re-derivation interval separately from `LDG-68`'s period; `runway_until` on a live
      machine is never staler than that interval; `LDG-16`'s "more than one derivation" is measured
      in intervals and a machine at the edge is routed into exhaustion within two of them, not two
      months; and `PRV-13c`'s "materially in the future" test — *now + one interval + wind-down* —
      still puts a cancellation date a week out on the **exception** branch. Assert the last one
      against a machine whose `earliest_cancellation_date` is days away, since a monthly interval
      swallows it into the ordinary path and silently deletes the `DOM-19`/`LDG-63` branch.
      (`PRV-13e`, `LDG-68`, `LDG-16`, `PRV-13c`, `OVR-19`)
- [ ] **CNF-276** **BLOCKING** — **The catalogue fetch cannot be pointed at the inside.** Drive `RSC-39` with a URL
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
- [ ] **CNF-277** **BLOCKING** — **A machine the provider destroyed stops being billed without anyone asking.**
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
- [ ] **CNF-278** **BLOCKING** — **An account can actually be recorded lost, and the right thing happens.** Drive
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
      unreleased billable attachment carries a `released_at`, and the **last** debit for each subject
      ends exactly at that instant — neither dropped nor clamped away, which is what posting it after
      the release would do. Then advance past at least one metered increment and assert **nothing
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
- [ ] **CNF-279** **BLOCKING** — **An install that wrote nothing and left nothing in rescue is not a mystery.**
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
      is set, and that both are refused on a create. **Then the same verb on a `delete_machine`
      whose provider call was dispatched and whose response was lost — and table-drive the same
      assertion across **every** dispatch-marked row of `OPS-45`'s table**: `provider_native` install,
      `provider_catalogue` install, power, reverse DNS and delete. The marker is set on all five and
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
- [ ] **CNF-251** **BLOCKING** — **The credential boundary is a module edge, not a comment.** `api` does not depend
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
- [ ] **CNF-252** **PRE-SCALE** — **Rescue entries and power cycles are capped.** A principal that sets every
      acknowledgement flag on every request still cannot exceed its rescue-entry or power-cycle
      ceiling; the rescue-entry ceiling counts the inventory pass and rescue-entering installs
      together. Drive it with a loop that acknowledges everything. (`SEC-39`, `RSC-38`)
- [ ] **CNF-253** **BLOCKING** — **The operator principal is capped and observed.** An operator principal exceeding
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
- [ ] **CNF-254** **BLOCKING** — **The credential-holding process cannot move the float.** Its Lightning credential
      permits exactly `SEC-48`'s six operations — create, look up, list, subscribe, **cancel an
      unsettled invoice**, and **read the channel and on-chain wallet balances** — and nothing else:
      attempting a payment, a keysend, an on-chain send, a channel open or close, an arbitrary
      message or PSBT signature, a peer addition or a configuration change each fail. Both halves
      are required: **a build where the cancel or the balance reads fail cannot execute `LDG-20`'s
      halt or `LDG-53`'s solvency check**, which is the failure the withdrawn four-verb scope
      guaranteed. Asserted by attempting them, not by reading the
      credential's configuration — `CNF-132`'s rule that reachability is the test, not visibility.
      (`SEC-48`, `LDG-20`, `LDG-53`, `ADR-0001`)
- [ ] **CNF-255** **BLOCKING** — **The stated ceiling covers both pots and the sweep destination is pinned.**
      Channel balance plus the node's on-chain wallet is what the ceiling measures; a sweep whose
      outputs are not the pinned cold destination is rejected by the signer; and the destination
      cannot be changed by any runtime input. `CNF-135` tests the last clause for the sweep
      destination — this adds the wallet to the arithmetic `ADR-0009` is sold on. (`SEC-49`,
      `SEC-50`, `ADR-0009`)
- [ ] **CNF-256** **PRE-SCALE** — **A signup slot costs a held connection.** `POST /v1/enrol` without a valid,
      unexpired, unused token is refused; a token is obtained only from `POST /v1/enrol/token`,
      which answers after the stated delay; a token is single-use; and issuing one writes nothing to
      the store. **A token request abandoned before the delay elapses leaves nothing collectable
      afterwards** — that is what keeps the cost a held connection rather than a free request. Then
      the test that matters: a caller cannot hold more concurrent token requests than the proxy's
      stated per-source limit, and no caller address is persisted anywhere while enforcing it. **At
      the global ceiling, enrolment sheds with `rate_limited` and a `retry_after_ms` rather than
      failing bare** (`API-41`). (`API-33`, `WIR-49`, `WIR-12`,
      `API-36`, `API-41`, `ADR-0005`)
- [ ] **CNF-241** **BLOCKING** — **A create is refused rather than bought at a price nobody authorized.** With the
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
- [ ] **CNF-242** **BLOCKING** — **A solvency halt stops what it can and says so about what it cannot.** Under a
      failing check: minting is refused `halted`; unsettled Lightning invoices on unexpired deposits
      are cancelled and a payment attempted against one fails back with the payer's funds intact; an
      on-chain payment arriving at an already-issued address is still **credited**, not held; and the
      deposit read reports the halt with `gate: "solvency"` before a caller pays. (`LDG-20`,
      `LDG-55`, `LDG-47`, `LDG-51`, `WIR-15`)
- [ ] **CNF-243** **BLOCKING** — **A tenant is not stranded on a dead provider account.** After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and a create
      against it succeeds. Every use of the verb emits a monitorable event naming principal, tenant,
      before and after, and reason. A customer token calling the route gets `404`. (`API-62`,
      `WIR-48`, `SEC-46`, `STO-36`)
- [ ] **CNF-244** **BLOCKING** — **Suspension is effective when the call returns.** A write issued by the tenant
      immediately after `POST .../suspend` returns `202` — and before any worker has claimed the
      parent — is rejected `suspended`. Asserted with the worker pool stopped, which is the state the
      withdrawn wording left permissive. (`API-58`, `API-7`, `WIR-39`)
- [ ] **CNF-245** **PRE-SCALE** — **The account sweep has a budget.** It paginates the provider listing rather than
      assuming one response, yields on `rate_limited` instead of retrying into it, does not delay
      caller-initiated work, and reads by `(provider_account, external_id)` against the index
      `STO-17`'s constraint supplies. An imported image whose operation has settled is **deleted** by
      the same sweep, while an unclaimed machine is only reported. (`OPS-32`, `STO-17`, `ADR-0013`)
- [ ] **CNF-246** **PRE-SCALE** — **The balance poll does not grow with the fleet.** `GET /v1/balance` returns the
      totals and `earliest_runway_until` with no per-commitment array; `?commitments=true` returns it
      cursor-paginated, and on the full listing `committed_sats` equals the sum of `reserved_sats`.
      Asserted against a tenant with more machines than one page holds. (`WIR-16`, `WIR-32`,
      `API-49`, `LDG-9`)
- [ ] **CNF-247** **BLOCKING** — **A tenant identifier is minted, unique, and never reused.** Identifiers are
      server-generated with stated entropy; a caller cannot supply or influence one; and no
      identifier is ever issued twice, including after `API-34` reaps the tenant that held it.
      Asserted against the generator, not by sampling. The failure it prevents is a new caller
      inheriting a reaped tenant's balance and deposits, which survive by identifier alone.
      (`DOM-1`, `STO-26`, `STO-29`, `API-34`)
- [ ] **CNF-248** **PRE-SCALE** — **Every mandated `409` carries a defined reason.** Drive each member of
      `WIR-9a`'s `conflict` union — including `signup_window_closed`, `deposit_already_attributed`
      and `cancellation_committed` — and assert the reason string is present and from the closed set.
      A `409` with no reason, or one outside the union, fails. (`WIR-9a`, `API-34`, `WIR-42`,
      `OPS-42`)
- [ ] **CNF-249** **PRE-SCALE** — **`?state=` on the case collection is honoured, and a bad value is refused.**
      `open`, `closed` and `all` each return the right set; the default is `open`; and an
      unrecognised value is `invalid_request` rather than ignored. The last clause is the one that
      matters: `WIR-2` ignores unknown query parameters, so a silently-ignored `state` answers the
      wrong question with a `200`. (`WIR-43`, `DOM-24`, `WIR-2`)
- [ ] **CNF-250** **PRE-SCALE** — **`network_restriction.source` is null exactly when nobody has looked**, and
      `system_reason` parses against a closed enum. A freshly created machine renders
      `{"status": "unknown", "source": null, "observed_at": null}`; a strict client parsing
      `system_reason` against `WIR-10a`'s set accepts every value the system emits. (`PRV-35`,
      `WIR-10a`, `WIR-47`)
- [ ] **CNF-237** **BLOCKING** — **A delete is not resolved as failed while the provider is still catching up.**
      With a provider whose resource read lags its write, an ambiguous delete resolves correctly:
      resolution takes no read before the effective visibility window elapses, a pre-mutation reading
      inside the window leaves the operation pending rather than concluding, a post-mutation reading
      is never reverted by a later contrary read, and a pre-mutation reading beyond the window
      resolves *not applied*. Assert with an injected read lag; a sample exceeding the declared
      window widens it and does **not** authorize a replay. (`PRV-36`, `OPS-33`, `OPS-12`)
- [ ] **CNF-238** **BLOCKING** — **A goal-state rejection is a success.** A delete against an already-deleted
      resource, where the provider answers 4xx meaning "already in the target state", classifies
      `succeeded` and its commitment closes (`LDG-32`). Asserted against the driver's recorded code
      mapping, not its message text. The failure this catches is a customer's satoshis reserved
      forever against a resource that is gone. (`OPS-11`, `PRV-5`, `LDG-32`)
- [ ] **CNF-239** **BLOCKING** — **A machine funded a moment before its cancellation is not destroyed, and a
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
- [ ] **CNF-240** **BLOCKING** — **Attribution across two tenants deadlocks under no interleaving.** Two concurrent
      `WIR-42` attributions naming each other's tenants both complete, in one transaction each, with
      the primitives acquired in ascending tenant order; and an attribution whose source tenant row
      was already reaped by `API-34` succeeds, proving the primitive does not require a live tenant
      row. (`LDG-35`, `WIR-42`, `STO-26`, `API-34`)
- [ ] **CNF-236** **BLOCKING** — **The meter's state is checked by range, not by reconstruction, and the checks
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
- [ ] **CNF-216** **PRE-SCALE** — The billing period boundary is `00:00:00Z` on the first of the month for every
      tenant and every machine, and a metered increment straddling it is apportioned across the
      two periods rather than falling wholly into either — **the increment closes at the boundary,
      the old period's `meter_totals` row posts its part with its own credit, and the new period's
      row starts at `r = 0`**, so the two rows never read each other. The same test covers a
      deficiency's `absorbed_from`/`absorbed_until` window straddling the boundary. *The mechanism
      clause was added 2026-09-05; this item asserted apportioning while `LDG-38` split only at a
      rate change, so a straddling increment had two credits and no rule.* (`LDG-68`, `LDG-38`,
      `STO-37`)
- [ ] **CNF-217** **PRE-SCALE** — No transaction holding `LDG-35`'s serialization primitive acquires a machine
      (`OPS-8`), waits on a child operation, or makes a provider call — asserted at the storage
      layer over the whole suite's traffic, in the manner of `CNF-157`, not by code review. **The
      converse is NOT asserted, and asserting it would fail a conforming build**: `OPS-41`'s
      funding re-check is a worker that already holds the machine entering the primitive for a
      bounded read and the fence write, which is the one direction `LDG-69` permits and the thing
      `OPS-42`'s fence is built on. *Noted 2026-09-02, when that path became the first genuine
      nesting in the set.* (`LDG-69`, `LDG-35`, `OPS-8`, `OPS-41`, `OPS-42`)
- [ ] **CNF-218** **BLOCKING** — A machine funded by `extend-runway` **after** its cleanup cancellation was
      enqueued is **not** deleted: the worker re-reads funding while holding the machine
      (`OPS-8`), makes no provider call, settles `succeeded`, and the episode closes (`OPS-48`).
      **Afterwards
      `machines.destroy_committed` is null, the stored `runway_until` is the re-derived future date,
      a second `extend-runway` succeeds, and — where the episode was `OPS-36`'s late-attach cleanup —
      the wind-down deficiency it booked carries `resolved_at` and no longer feeds the solvency
      check** — a build that leaves the fence set passes the first
      sentence and refuses every later extension forever, and one that leaves the stored date in
      the past is re-routed by the next sweep and loops. **Then the same with a `rate_outage_bound`
      cancellation** whose rate returns between enqueue and claim: the worker re-derives at the
      returned rate and aborts. **And the same with restoration committing *after* the worker's
      snapshot and before its fence transaction**: the worker's conditional write on the machine's
      `rate_outage` record affects no row, and it still makes no provider call — a build that
      establishes "no rate" by a read passes the first case and deletes the fleet in this one. **Then the same with the commitment unchanged and only the price
      cut** between enqueue and claim: the re-derived date is in the future, the worker aborts,
      makes no provider call, and clears the fence — a worker that aborts only on a grown
      commitment passes every other case here and destroys a machine a price cut rescued. The same
      test with **no rate available** cancels the machine,
      because a funding check that cannot be computed is not a funded machine. *The fence and date
      assertions and the outage case were added 2026-09-05; the outage kind was outside `OPS-41`
      entirely, so a bound reached one second before the rate returned destroyed the fleet.*
      (`OPS-41`, `OPS-36`, `LDG-62`, `LDG-40`, `LDG-64`)
- [ ] **CNF-219** **BLOCKING** — `GET /v1/balance` is answered from the latest entry's `balance_after` and takes
      no write transaction; an audit recomputation of `Σ(ledger entries)` equals it; and a seeded
      mismatch **fails closed** rather than answering from either number. (`LDG-70`, `LDG-9`,
      `CNF-157`)
- [ ] **CNF-220** **PRE-SCALE** — The deployment states its worst-case operation hold (`OVR-19`), and
      `wind_down_cost` includes it. Asserted by enqueuing an exposure-reducing cancellation against
      a machine held by a long-running operation and confirming the reserve covered the full wait.
      (`PRV-13b`, `OPS-8`, `OVR-19`)
### The abuse surface (grill session, 2026-08-16)

- [ ] **CNF-222** **BLOCKING** — **Address resolution answers from history, not from current state.** Machine A
      holds `203.0.113.7` and is deleted; the address is later observed on machine B, owned by a
      different tenant. Resolving `203.0.113.7` at an instant inside A's window returns **A**, and
      at an instant inside B's returns **B**. Asserting only the live case passes against the
      defect. **Run it on a machine created and never refreshed** — that is the ordinary machine,
      and binding the history write to the refresh alone leaves it with none. The operations that
      touched the machine in that window are recoverable alongside it (`SEC-45`), which
      `GET /v1/operations` under `WIR-33`'s override already answers. (`SEC-54`, `STO-41`, `DOM-8`)
- [ ] **CNF-223** **BLOCKING** — Resolution returns a **candidate set**, and an address never observed at that
      instant returns an empty one rather than a nearest match. An operator acting on a confident
      wrong answer opens a case against an innocent tenant. (`SEC-54`)
- [ ] **CNF-224** **BLOCKING** — **No part of the notice reaches the customer surface.** With a case open, neither
      the machine view, nor the case collection, nor the case detail, nor any error `details` on
      those paths contains the provider's case reference, its statement link, its own wording, or a
      third party the notice named. Run against **all three** read paths — one projection, three
      renderers, and a rule enforced on some of them is the failure mode. **It does not assert the
      absence of the provider's name**: `provider_account` is already in the machine view
      (`WIR-11`) and `WIR-29` returns the account kind, so a test written that way fails every
      conforming implementation. (`WIR-45`, `API-59`)
- [ ] **CNF-225** **BLOCKING** — **The deadline has no hands.** A case whose `respond_by` has passed with no
      statement leaves the tenant unsuspended, the machine uncancelled, the balance untouched, and
      the case still accepting statements. (`DOM-25`, `DOM-24`)
- [ ] **CNF-226** **PRE-SCALE** — Statements are append-only and unbounded in count while the case is `open`: a
      second and third submission both succeed and both appear in order; submission after `closed`
      is `409` `case_closed`; no endpoint edits or deletes one. (`STO-40`, `WIR-43`)
- [ ] **CNF-227** **PRE-SCALE** — **Closing purges raw statement bodies and keeps what was sent.** After close, the
      statement rows survive with their timing, their `body` renders as `null`, and
      `sent_statement` — plus `sent_verbatim` and the statement ids it covered — is still readable
      by the operator. The purge commits in the close transaction, not after it. **And a case left
      open past the configured age purges anyway**, which is the only clock that fires without an
      operator. (`STO-42`, `STO-43`, `WIR-44`)
- [ ] **CNF-231** **PRE-SCALE** — A retried statement submission carrying the same `Idempotency-Key` appends **one**
      statement, not two, and returns the same body. Under `STO-40` a duplicate can never be
      deleted, and the caller is an agent with a retry loop. (`WIR-43`, `WIR-24`, `API-8`)
- [ ] **CNF-232** **PRE-SCALE** — `GET /v1/address-resolution` returns candidates ordered by `first_seen` with the
      matched window on each, an empty array where nothing matches, and `out_of_horizon: true` for
      an instant older than the deployment can answer for — distinguishable from "it was nobody's".
      (`WIR-46`, `STO-43`)
- [ ] **CNF-228** **PRE-SCALE** — **REWRITTEN 2026-08-16 — it tested English.** A restricted machine keeps billing
      and says so *structurally*: `network_restriction.status` reads `disabled` on the machine view
      and in every case rendering, `usage_debit` postings continue, the commitment decays,
      `runway_until` keeps moving, and `delete` on that machine is accepted. **No assertion about
      prose.** *Withdrawn clause:* "the case's `consequence` states the drain" — no conformance run
      can execute a judgement about whether a sentence says a thing. (`LDG-71`, `DOM-27`, `DOM-26`)
- [ ] **CNF-233** **PRE-SCALE** — `unknown` is never rendered as `none`. A machine whose driver reports no
      restriction signal reads `"status": "unknown"` with a null `observed_at`, and an operator
      recording is refused where the driver *does* report (`409` `state`). A field that is silently
      `none` when nobody looked is worse than no field. (`PRV-35`, `WIR-47`)
- [ ] **CNF-234** **PRE-SCALE** — `warned_consequence` has no write path after open, and a deadline revision
      appends: after two extensions the case carries both prior dates with their revision times,
      and `respond_by` reads the latest. (`STO-44`, `WIR-47`)
- [ ] **CNF-229** **PRE-SCALE** — An open case blocks nothing else — create, install, extend-runway and delete all
      behave exactly as they do with no case open. (`DOM-26`)
- [ ] **CNF-230** **PRE-SCALE** — A case is creatable **only** by an operator, and the statement write mints no
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

- [ ] **CNF-149** **PRE-SCALE** — Every endpoint the requirements mandate appears in the surface table, and every
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
- [ ] **CNF-150** **BLOCKING** — A caller can read its balance, its available figure and its committed satoshis
      without attempting a purchase. **A create rejected with `insufficient_balance` is not an
      acceptable way to answer "can I afford this"**, because an autonomous caller responds to it
      by retrying. (`API-47`, `DOM-20`)
- [ ] **CNF-151** **PRE-SCALE** — Exactly the endpoints in `API-48`'s list are synchronous; every other write
      returns `202` with an operation. Asserted against the routing table, so that adding an
      endpoint later cannot quietly extend the exemption. The list's newest member is the one a
      reader will misfile: `POST /v1/episodes/{id}/actions/retry` answers `200` with the episode
      view, and the attempt it enqueues is asynchronous and visible only through
      `current_operation_id` (`API-64`). (`API-48`, `API-1`, `API-64`)

## Completion and pacing

Added 2026-08-12 with `API-49`–`API-54`.

- [ ] **CNF-152** **PRE-SCALE** — A simulated caller that obeys every `Retry-After` it receives — across a
      non-terminal list poll, a balance poll and a machines poll at the finest advertised
      cadence — receives zero `429`s over a sustained run. **The invariant is the test**, because
      any fixed rate-limit number stops being tested the day the fleet grows. (`API-50`)
- [ ] **CNF-153** **PRE-SCALE** — Every non-terminal operation response carries `Retry-After` and a matching
      `poll_after_ms`, values differ by operation kind and state, and the enrolment poll carries
      no delay-derived value — the one endpoint where the pacing hint is a forbidden oracle.
      (`API-49`, `API-33`)
- [ ] **CNF-154** **BLOCKING** — An operation in `needs_reconciliation` is delivered with `retryable: false`,
      and the client documentation states that re-issuing under a fresh idempotency key is a
      second purchase. The test is the field; the sentence is checked by reading. (`API-51`)
- [ ] **CNF-155** **BLOCKING** — A pending tenant that has paid can observe `active` on its enrolment handle
      without attempting a create. A pending tenant that has not paid can reach only `API-43`'s
      allowlist — funding, its own deposit, that handle, and revocation. *The "at or after
      `issuable_at`" qualifier went with `issuable_at` on 2026-09-02 (`API-33`).*
      (`API-52`, `API-43`)
- [ ] **CNF-156** **PRE-SCALE** — Two interleaved polls delivered out of order leave the caller holding the
      higher `revision`; the operation's revision strictly increases across every client-visible
      change, verified by killing and restarting the process mid-operation. (`API-53`)
- [ ] **CNF-157** **BLOCKING** — No `GET` takes a write transaction, asserted at the storage layer over the
      whole test suite's traffic, not by code review. A polling customer must be unable to
      trigger what `DEF-11`'s internal loop triggered. (`API-54`)
- [ ] **CNF-158** **PRE-SCALE** — Reading an operation past the retention horizon answers `gone`, not
      `not_found`, and the published observability horizon equals the idempotency horizon.
      (`DOM-21`, `STO-33`)
- [ ] **CNF-159** **BLOCKING** — Driving a tenant's balance to exhaustion produces a tenant-visible operation
      with `requested_by: system` and reason `exhausted`, holding the machine (`OPS-8`), and capable
      of ending in `needs_reconciliation` like any cancel. The test is that the customer-facing
      history contains the event **before** the machine record shows it gone. (`OPS-39`,
      `LDG-14`)

## The meter and serialization

Added 2026-08-12 closing `F30`'s list of untested requirements from the commitment rewrite.

- [ ] **CNF-160** **BLOCKING** — Posting the same `(subject, billing period, kind, increment end)` usage debit twice moves the
      balance once, and the debit and its commitment decrement land in one transaction — killing
      the process between them leaves neither. (`LDG-38`, `LDG-31`, `STO-28`)
- [ ] **CNF-161** **BLOCKING** — A machine powered off for a full billing period is billed for it, and a machine
      in `cancellation_scheduled` is billed through its effective date. The meter stopping at
      cancellation *acceptance* is the defect. (`LDG-37`, `DOM-19`)
- [ ] **CNF-162** **BLOCKING** — **REWRITTEN.** The setup fee follows `LDG-39`'s table: debited **on confirmed
      acceptance** and the commitment decremented in the **same transaction** (kill the process
      between them and neither survives); **released in full** on deterministic rejection and on
      resolved-absent — **except a fee the provider's transaction shows was charged for a matched
      order whose machine is gone, which becomes an `unrecoverable_setup_fee` deficiency in the
      resolution's own transaction** (2026-09-05; kill the process between them and neither
      survives); **held** through `needs_reconciliation`. Assert `available` never goes
      negative across the whole sequence — that is the bug this item missed by testing only the
      debit. (`LDG-39`, `LDG-31`, `LDG-10`)
- [ ] **CNF-163** **BLOCKING** — Two concurrent creates against a balance that can fund exactly one result in
      one commitment and one `insufficient_balance` — under load, not by code review. This is
      the per-tenant serialization primitive `STO-27` exists for. (`LDG-35`, `STO-27`)
- [ ] **CNF-164** **BLOCKING** — A machine whose correlator arrives after `OPS-33` released the commitment is
      attached to its tenant and then routed through the ordinary exhaustion path — not silently
      adopted free, not destroyed without a record. (`OPS-36`)
- [ ] **CNF-165** **PRE-SCALE** — When correlator search returns **many**, no automatic attach occurs, the
      operator is shown all candidates, and the recorded choice names which duplicate was kept
      and why the others are believed spurious. (`OPS-38`, `OPS-31`)

### Assignments for `CNF-160`–`CNF-165`

**BLOCKING** — `CNF-160` (double-billing or an unmetered machine, and the crash window mints the
difference); `CNF-161` (under-billing exactly the machines the operator is still paying for);
`CNF-162` (the €39-per-iteration pump the setup-fee rewrite closed — this is its test);
`CNF-163` (two creates spending one balance is authorization failure, the write-skew case);
`CNF-164` (a machine running free or destroyed with no record — both irreversible).

- [ ] **CNF-166** **BLOCKING** — A create against an offer with no declared cancellation bound is refused
      before any provider call, and a create against one with a bound opens a commitment sized to
      that bound, which the machine's actual date then **lowers `protected_sats` against rather
      than resizing** (`PRV-31`, `LDG-33`). (`PRV-31`,
      `PRV-13c`, `LDG-12`)

- [ ] **CNF-167** **BLOCKING** — A rate halving increases **no** commitment anywhere in the fleet, except
      machines on the scheduled-cancellation branch. What moves is every affected machine's
      `runway_until`. Fault-inject the rate; diff the commitments table. (`LDG-33`, `ADR-0011`)
- [ ] **CNF-168** **PRE-SCALE** — `runway_until` moves at re-derivation in **both** directions and the machine
      view reflects it on the next read. (`LDG-33`, `LDG-15`)
- [ ] **CNF-169** **BLOCKING** — `runway_until` is derived with `protected_sats` subtracted (`LDG-33`), and a
      machine is routed into the exhaustion path while its remaining commitment still covers
      wind-down at the current rate — at cancellation time the operator is not out
      of pocket. Drive a machine to exhaustion under a falling rate and assert the invariant at
      the moment of cancellation, not at the end of the test. (`LDG-16`)
- [ ] **CNF-170** **BLOCKING** — Two concurrent runway extensions against a balance that can fund one result in
      one extension and one `insufficient_balance`, and replaying an extension with its
      idempotency key does not reserve twice. (`LDG-62`, `LDG-35`, `API-8`)
- [ ] **CNF-171** **PRE-SCALE** — On the scheduled-cancellation branch, a shortfall that available cannot top is
      surfaced to the operator as a named deficiency — not silently absorbed, not billed to the
      customer twice. (`LDG-63`)
- [ ] **CNF-172** **BLOCKING** — A create/install carrying a signed URL whose expiry is inside the stated
      admission-to-start bound is rejected at accept; at claim, a URL that cannot outlive the
      install fails the operation with no provider mutation and no rescue entry. (`OPS-40`,
      `SEC-21`)
- [ ] **CNF-174** **PRE-SCALE** — A customer request authenticates by `Authorization: Bearer <token>` compared
      to a stored **hash** in constant time; the raw token appears in no log line, URL, or
      operation record; and an unknown or malformed token fails `authentication` before any body
      parsing (`API-7`). *Withdrawn signing-vector test: the Ed25519 scheme this checked
      was withdrawn 2026-08-13; a bearer token has no signing string to interoperate on.* (`WIR-5`, `API-39`, `API-3`)
- [ ] **CNF-175** **PRE-SCALE** — A request with an unknown body field is rejected naming the field, and a
      response with an extra field is accepted by the reference client. Both directions of
      `WIR-2`, tested separately. (`WIR-2`)
- [ ] **CNF-176** **PRE-SCALE** — Every example body in `13-wire-contract.md` validates against the
      implementation's actual parser — the examples are test fixtures, not illustrations, and
      contain no `...` placeholder inside an object (`WIR-37`). (`F19`)
- [ ] **CNF-177** **BLOCKING** — A browser-origin preflight (`OPTIONS` with the `Authorization` and
      `Idempotency-Key` request headers) succeeds **unauthenticated** and returns the allow-lists
      of `WIR-4a`; a customer request from a wasm client then completes end to end. Run from an
      actual cross-origin fetch, because this is the failure that is invisible in server-only
      tests. (`WIR-4a`, `API-49`)
- [ ] **CNF-178** **BLOCKING** — A body reusing an idempotency key against a **different** machine or endpoint is
      `409`, not a replay of the first result; and a body with a duplicate JSON member, or an
      integer above 2^53, is rejected. (`WIR-3`, `WIR-1a`)
- [ ] **CNF-179** **BLOCKING** — An operator resolves a `needs_reconciliation` operation through
      `POST /.../actions/resolve` in each of its **five** forms — `observed`, `absent` and
      `abandoned` on a create, `applied`, `not_applied` and `abandoned` on a kind that acts
      on a machine that already exists (`OPS-31`, `WIR-35`, added 2026-09-02) — with each form
      refused **on a kind whose set does not admit it**, and `abandoned` accepted on both, since it
      is the member common to the two sets; the
      `absent` form releases the
      commitment, and a customer-authenticated request to that route — and to `retry` —
      returns `404`, not `authentication`. (`WIR-35`, `WIR-34`, `OPS-31`, `OPS-45`, `API-64`)
- [ ] **CNF-173** **BLOCKING** — After startup, enumerating the process environment from inside the
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

- [ ] **CNF-107** **BLOCKING** — Two tenants cannot both hold the same `(provider_account, external_id)`, and
      neither can two records for one external machine exist by any other route. The
      constraint is enforced by the store, not by application code. *Absorbed `CNF-6` on 2026-09-02,
      which tested the same control in the words `SEC-10` uses; this item survives because it names
      the constraint that enforces it, and it takes that citation with it.* (`STO-17`, `SEC-10`)
- [ ] **CNF-108** **BLOCKING** — A machine with an unreleased billable attachment cannot be tombstoned.
      (`STO-18`)
- [ ] **CNF-109** **BLOCKING** — An idempotency key reused after its operation was retained-out either returns
      the original or is refused — it never performs the mutation a second time. (`STO-25`)
- [ ] **CNF-110** **PRE-SCALE** — A `retry` leaves the failed attempt's row — its error included — byte-identical,
      and the fresh attempt is a separate operation carrying the retry's stated reason. (`API-64`,
      `WIR-51`, `DOM-31`)

## Blast radius

- [ ] **CNF-111** **BLOCKING** — Tenants are distributed across more than one provider account. An assignment
      policy that places every tenant in one account fails this item even though it satisfies
      `API-17b`. (`SEC-43`)
- [ ] **CNF-112** **BLOCKING** — The provider's account-linkage practice has been verified in writing. Until it
      is, `CNF-111` proves nothing. (`SEC-44`)
- [ ] **CNF-113** **BLOCKING** — **REWRITTEN 2026-08-15** — it tested a deadline `SEC-45` no longer asserts.
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
- [ ] **CNF-115** **BLOCKING** — Balances and commitments are answerable with every provider unreachable.
      (`SEC-47`)

## Before production

Beyond the checklist, a deployment must state every parameter on `OVR-19`'s register — the human
items (the `needs_reconciliation` rota, the recovery-key inventory) included — and startup must
refuse to run on a missing or out-of-range startup-validated row. *This section carried its own list
of thirteen until 2026-09-08; it was a second copy of the register, and it had drifted.*


### Assignments for `CNF-214`–`CNF-220` (engineering review, 2026-08-15)

**BLOCKING** — `CNF-214` (two metered subjects sharing one column under-bill silently and
permanently); `CNF-215` (a correction either re-charges the customer or refunds them twice, on
the next tick, in both directions); `CNF-218` (a paid-for machine destroyed anyway — accepted
payment, lost disk, and the branch `OPS-33`'s early release depends on); `CNF-219` (the number
that authorizes every purchase, read from an unstated source).

**PRE-SCALE** — `CNF-216`, `CNF-217`, `CNF-220`. Each bounds cost or contention rather than losing
money or data on the first occurrence: a straddling increment mis-apportions a partial period, a
nesting violation is unreachable while `LDG-25` prices privileged operations at zero, and an
unpriced wait for a held machine costs one machine's burn for one install.

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
destroyed data); ~~`CNF-258`~~ (withdrawn with adopt, `ADR-0020`);
`CNF-259` (both failure modes end in a duplicate purchase, which is what `API-38` was written to
stop); `CNF-260` (two open commitments double-reserve a balance silently); `CNF-263` (destroyed data — writing a raw image to the wrong kind of device);
`CNF-264` (a PTR set on an address the tenant does not hold crosses a boundary in the operator's own
account); `CNF-265` (the only integrity check catalogue install has, plus the credential disclosure
`SEC-21` forbids); `CNF-267` (a customer's operating system left in the operator's account after the
deployment undertook to destroy it).

**PRE-SCALE** — `CNF-262`, `CNF-266`, `CNF-268`, `CNF-269`. A concurrency primitive whose
failure is contention rather than loss at concierge scale, a hold bound that costs one machine's
burn, and two disclosure items. **`CNF-262` graduates the day concurrent installs become
routine**, which the tiering rule already names as a PRE-SCALE trigger.

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

- `CNF-237` — a delete resolved as failed is a delete an operator retries, which is a **repeated
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
`CNF-272` (a suspension that never completes, or one whose deterministically failed child is left
**unlisted or unretryable** — `SEC-45`'s one action is the operator's whole remedy and it must
land, and where a credential is rejected the listing is the only remedy there is, so losing it is
unbounded billing. *Corrected 2026-09-04: this read "completes with a billing machine on a suspended
tenant", which the amended item now deliberately permits — that machine is the expected settled
state, and the failure is nobody being told about it*);
`CNF-273` (money-in, the family this checklist already calls the only one where a bug **mints**
satoshis: a payment credited twice, or a real customer's balance made unreachable forever);
`CNF-274` (retroactive re-pricing of hours the customer already paid for, or a positive
`usage_debit` growing a commitment nobody authorized — the operator would learn of either from a
customer, if at all);
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

**The count is the line `bash tools/check-all.sh` prints** — `conformance items: N | BLOCKING a |
PRE-SCALE b | DEFERRED c | markers m`, from `tools/check_ids.py` — **and no figure is written here,
because a figure written here was wrong twice** (`F16`, then again on 2026-08-12 when three separate
running totals disagreed by one) and stale twice more after that in this section alone. Every other
passage that used to carry a number points here, and this section points at the gate.

**The tag on the item is the tier of record.** Since 2026-09-09 every checkbox item carries its tier
inline — `- [ ] **CNF-1** **BLOCKING** — …` — and `tools/check_ids.py` refuses an untiered item and a
checkbox on a withdrawn, merged or split id. The assignment paragraphs above are the *reasons* — the
arguments and the graduation triggers — and are no longer where a tier is read from. The tags are a
faithful copy of those paragraphs as they stood on 2026-09-09; `F50` in `11-open-findings.md` holds
what the copy preserved, including the places two readers found the prose wrong.

**How it was counted before that, and why each count went stale.** Counted mechanically on
2026-08-31, after a review that added twenty-nine items, most of them in the destroyed-data and
money-out families, and again on 2026-09-02; each figure was superseded within days, and the earlier
"approximately 135" of 2026-08-13 had lasted two reviews past the point it was true.

**Three things those counts established, which are worth more than any number.**

*The tiers are consistent.* `F16`'s defect — one item in two tiers — has not recurred. Seven items
appeared to be double-assigned and every one was a parser artifact: they are *mentioned* in
explanatory prose inside a tier block rather than assigned there. `CNF-99` is discussed in a
PRE-SCALE paragraph about re-tiering; it is BLOCKING and has been since `F30`.

*Two items had no tier at all.* `CNF-233` and `CNF-234` were defined on 2026-08-16 under an
assignment block headed `CNF-222`–`CNF-232`, and fell off the end of it. Now assigned. `CNF-31`,
`CNF-6`, `CNF-114` and `CNF-195` are correctly absent — they are split and merge markers, not items.

**Re-counted 2026-09-02.** The
two-reviewer pass of that date added nine items, `CNF-271`–`CNF-279`, eight of them BLOCKING and
every one in the destroyed-data, money-out or boundary-crossed families. It removed two by merging
duplicate pairs that had each been counted twice: `CNF-6` into `CNF-107` — **both BLOCKING**, so the
BLOCKING total falls by one there — and `CNF-114`, which was PRE-SCALE, into `CNF-188`, which is
BLOCKING. `CNF-195`'s checkbox went at the same time; this passage had called it
"correctly absent" while it was still tickable, which is exactly the folklore this section exists to
stop, appearing inside the section itself.

**The durable fix is still the durable fix, and this pass is more evidence for it.** Carrying the
tier on the item would have caught three of the bookkeeping errors above mechanically: a range
`CNF-4`–`CNF-9` silently re-tiering a merge marker, a survivor and its duplicate sitting in
different tiers, and a block of new items whose tier paragraph closed before the last of them. It
landed on 2026-09-09 as one mechanical edit across every checkbox item; the gate prints how many
that was.

*The number was approximate because the assignments were prose, and that was the durable problem.*
Tiers lived in paragraphs scattered across the document, in item order nowhere: `CNF-183`, `CNF-182`
and `CNF-181` sit after `CNF-213`, `CNF-173` after `CNF-179`. One block read "BLOCKING — all six"
with no identifiers, which no count can resolve; it was expanded. **Finding an item's tier meant
scanning thirteen hundred lines, and counting them meant writing a parser for English** — the
2026-09-09 copy was made with exactly such a parser, once, so that nobody writes another. The tier
is now on the item, the count is a `grep`, and `tools/check_ids.py` refuses an untiered item
outright. *The figure written here was 265, then 271, and each was stale within a week, which is
itself the point: a count written into prose disagrees with the document the first time either
moves.*

A checklist whose own arithmetic is folklore is the failure `CNF-1`/`CNF-3` exist to prevent,
applied to itself. It is now arithmetic a gate performs on every run, with the method in
`tools/check_ids.py` and no figure in this document left to go stale.
