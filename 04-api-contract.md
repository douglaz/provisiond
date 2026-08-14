# 04 — HTTP API contract

## Surface

| Method | Path | Sync | Purpose |
|---|---|:--:|---|
| GET | `/healthz` | ✓ | Liveness. Unauthenticated. |
| GET | `/v1/providers` | ✓ | Configured accounts and their capabilities |
| GET | `/v1/providers/{account}/offers` | ✓ | Purchasable offers for one account |
| GET | `/v1/machines` | ✓ | List the caller's machines |
| POST | `/v1/machines` | | Create a machine |
| POST | `/v1/machines/adopt` | | Import an existing machine |
| GET | `/v1/machines/{id}` | ✓ | Read one machine |
| POST | `/v1/machines/{id}/actions/refresh` | | Re-read from the provider |
| POST | `/v1/machines/{id}/actions/power` | | Power on/off, reboot, hard reset |
| POST | `/v1/machines/{id}/actions/preflight` | | Read-only disk inventory before an install (`RSC-38`, `WIR-40`) |
| POST | `/v1/machines/{id}/actions/install` | | Install an image |
| POST | `/v1/machines/{id}/actions/reverse-dns` | | Set a PTR record |
| POST | `/v1/machines/{id}/actions/delete` | | Delete the machine |
| GET | `/v1/operations` | ✓ | List operations, filterable by status |
| GET | `/v1/operations/{id}` | ✓ | Poll one operation |
| POST | `/v1/operations/{id}/actions/requeue` | | Operator requeue |
| POST | `/v1/enrol` | ✓ | Create a pending tenant, return a handle (`API-32`) |
| GET | `/v1/enrol/{handle}` | ✓ | Enrolment **status only**; never returns a credential (`API-33`, `WIR-13`) |
| POST | `/v1/deposits` | ✓ | Mint a deposit: amount, expiry, both destinations (`API-43`) |
| GET | `/v1/deposits/{id}` | ✓ | Read one deposit |
| GET | `/v1/balance` | ✓ | Balance, available, and open commitments (`API-47`) |
| POST | `/v1/recovery/revoke` | ✓ | Revoke the spending token, get a fresh one (`API-56`, `WIR-38`) |
| POST | `/v1/deposits/{id}/actions/attribute` | ✓ | Operator: credit an orphaned deposit to a tenant (`API-34`, `WIR-42`) |
| POST | `/v1/operations/{id}/actions/resolve` | ✓ | Operator reconciliation verbs (`OPS-31`, `WIR-35`) |
| POST | `/v1/tenants/{tenant_id}/actions/suspend` | | Operator: suspend and cancel the fleet (`API-58`, `WIR-39`) |
| POST | `/v1/tenants/{tenant_id}/actions/resume` | ✓ | Operator: clear the suspension (`API-58`, `WIR-41`) |
| POST | `/v1/machines/{id}/actions/extend-runway` | ✓ | Grow the machine's commitment from available (`LDG-62`, `WIR-24`) |

**The enrolment, funding and balance rows were absent until 2026-08-12** — enrolment shipped on
2026-08-11 and funding earlier the same day as that note, and the recovery, resolve, suspend,
resume, attribute and preflight rows were added later still, each with requirements and no place on the surface. A table
that omits an endpoint the requirements mandate is `F19` in miniature, and it is the reason
`API-48` now states the synchronous exemptions in one place instead of leaving each new endpoint
to contradict `API-1` on its own.

**API-1** Every non-`GET` endpoint that *accepts* a valid, authorized request MUST return
`202 Accepted` with an operation view; none returns the completed result inline. Requests
rejected before enqueue return their mapped error status (`API-24`) — `400`, `401`, `404`,
`409` and `501` are all reachable on write endpoints.

**API-2** **AMENDED.** `{id}` in a machine, operation or deposit path is always an internal UUID; a
`{tenant_id}` component follows `DOM-1`'s grammar instead, which is wider than a UUID (`agent-7`
is valid). The original said "always", which a strict router applies to `/v1/tenants/{tenant_id}`
and rejects every valid tenant. A provider-side identifier MUST
NOT appear in a client-constructed path (`DOM-5`).

## Authentication and tenancy

**API-3** **AMENDED twice; the history matters.** Operator **and** customer requests both
authenticate with a bearer token — `Authorization: Bearer <token>` — held only as a **hash** and
compared in constant time. The operator token is environment-supplied and static (`API-4`); the
customer token is server-issued at enrolment and its hash persists in the `tenants` table
(`STO-21`), so "held in memory" is true only of the operator's. The first amendment (2026-08-12)
switched customer auth to a caller-supplied public key; the second (2026-08-13) reversed it back
to a token — see `API-39` for why.

**API-39** **AMENDED 2026-08-13 — customer authentication is a server-issued bearer token,
stored hashed. The earlier caller-supplied-key decision is reversed, and the reversal is the more
interesting record.** Enrolment mints a high-entropy token, returns it once, and persists only its
hash (`STO-21`), exactly as the operator token is handled (`API-3`). A customer sends it as
`Authorization: Bearer <token>`; the server hashes what arrives and compares in constant time.

The key scheme was adopted (2026-08-12, on both audit models' recommendation) to keep every
secret off the wire and out of the store. Reconsidered against this product it did not earn its
cost:

- **The asset it protected is nearly worthless to a thief.** A stolen customer credential — key or
  token — can only *burn the victim's prepaid balance on compute*; there are no withdrawals
  (`ADR-0004`), so nothing can be extracted. Elaborate authentication was guarding a prepaid
  arcade card.
- **The store-compromise benefit is obtained by hashing.** A leaked table of token *hashes* of
  high-entropy secrets discloses nothing usable — the same answer to `F13` a public key gives,
  without a signing protocol. The process compromise that actually matters takes the provider
  credentials and the float regardless; customer credentials were never the prize.
- **The signing scheme was the most interop-fragile thing in the set.** A three-model panel found
  ~30 issues in it, six critical: signatures that replayed across deployments, a malleable body
  hash, ambiguous path/header canonicalization, unspecified Ed25519 strictness. None of those
  failure modes exists for a bearer token.

The residual advantage keys held — the secret never travels, so a request captured after TLS
yields a one-request signature rather than a reusable credential — is real but modest against a
non-extractable asset, and did not justify the cost. **`API-33`'s delayed issuance therefore
un-collapses** (a generated token *is* transmitted at issuance, so the throttle protecting that
moment matters again).

**AMENDED again 2026-08-13: revocation and replacement are IN scope** (`API-55`, `API-56`,
`WIR-38`). This paragraph previously excluded them, on the reasoning that a stolen token "cannot
extract" value — **which is false.** A customer credential authorizes `install`, which wipes a
disk, and `delete`, which destroys a machine; the asset behind it is the customer's data and
running infrastructure. `API-37`'s rule is narrowed accordingly: losing *both* the spending token
and the recovery credential is a lost balance, because `ADR-0005` leaves no identity to recover
against — losing only the spending token is not.

**API-4** **AMENDED — it now applies to operator credentials only.** Operator tokens MUST be
supplied through the environment, named — not valued — by the configuration. A minimum length
MUST be enforced at startup (24 bytes is a reasonable floor) and duplicate tokens across
identities MUST fail startup.

The original text applied this to every token, which `ADR-0002` made impossible: a self-serve
tenant appears at runtime and cannot have been named in an environment variable at startup.
This was `F2`, recorded as unbuildable, and the split resolves it. **Customer credentials are
issued at runtime and governed by `API-32`–`API-37`.** Operator credentials remain static,
environment-supplied, and outside the tenant model entirely — which is also what keeps `API-19`
(requeue is a purchase) genuinely operator-only.

**API-5** Each token maps to exactly one tenant and an admin flag. An admin token MAY act
for another tenant by sending a tenant override header; a non-admin token MUST NOT, and
the header MUST be ignored rather than honoured for it.

**API-6** An overridden tenant identifier MUST be validated against `DOM-1` before use.

**API-7** **Authentication MUST happen before request-body validation.** An
unauthenticated caller MUST NOT be able to learn anything from validation error text, and
MUST NOT be able to make the server do parsing or policy work. See `DEF-4`.

**AMENDED — the tail is per endpoint class, because one universal pipeline was wrong for four of
the five classes.** Steps 1–5 are common to every authenticated write:

1. authenticate, resolve principal;
2. reject unless the tenant is active — a pending tenant fails `not_activated` (`API-35`),
   **except** the `API-43` allowlist and the **maintenance actions**: revoke (`API-56`), resolve
   resume and requeue are authorized by principal rather than by tenant state — and gating them on an
   active tenant would make a suspended or pending tenant unable to replace a stolen credential —
   locking the owner out at exactly the moment the mechanism exists for;
3. validate the idempotency key;
4. authorize the target resource against the tenant;
5. deserialize and validate the body;
2a. reject with `suspended` if the tenant is suspended and the endpoint is not a maintenance
    action — checked **after** step 2's replay lookup would have matched, so a replayed write
    from before the suspension returns its stored result rather than a spurious rejection;
5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
    same `(tenant, key)` returns the stored result, a different one fails `conflict`. This step
    needs the parsed body, which is why it cannot live at step 3.

The tail then depends on what the endpoint does:

| Class | Tail |
|---|---|
| **create, adopt** | spending gates (`LDG-9`, `LDG-20`, `LDG-40`), then commitment + operation in one transaction (`LDG-11`), serialized per tenant (`LDG-35`), then `202` |
| **power, install, reverse-DNS, refresh, preflight** | enqueue an operation, then `202`. **No commitment**: they are not purchases, and they pass no spending gate |
| **requeue** | operator-only; takes the class of the operation it requeues — a requeued create passes the spending gates and opens a commitment (`OPS-20`) |
| **suspend** | operator-only; enqueue one cancellation per machine, then `202` (`API-58`) |
| **resume, resolve, revoke** | operator or recovery-credential principal; synchronous, `200`, no provider mutation (`API-48`) |
| **delete, cancel** | enqueue an operation, then `202`, and **bypass the rate and solvency gates entirely** — these reduce exposure, and refusing them because exposure is too high is the failure `LDG-20` already forbids |
| **deposit** | synchronous; allowed while pending; **mints a destination and writes NO ledger entry** — a deposit is not money until it settles (`LDG-47`) — plus an idempotency record, in one transaction; `200` |
| **extend-runway** | synchronous; ledger write plus idempotency record in one transaction (`WIR-24`); `200` |

*The withdrawn list applied the commitment and the spending gates to "every write endpoint", so a
literal builder opened a purchase commitment on a reboot and could be blocked from deleting a
machine during a rate outage — the one action that would have stopped the bleeding.*

The activation check, the spending-authority check and the commit-and-enqueue transaction were
all absent until 2026-08-12. The list was described as normative "for every
write endpoint", so **a builder following it literally shipped a create with no authorization at
all** — the money check existed in `12-billing-and-ledger.md` and in no sequence any handler
author would read.

## Enrolment

Self-serve enrolment (`ADR-0002`) with no identity collected (`ADR-0005`) means the only thing
standing between a script and an unbounded table of tenant rows is this section.

**API-32** An unauthenticated enrolment endpoint MUST exist. It creates a tenant in a **pending**
state and returns an enrolment handle. It MUST NOT return a usable credential immediately.

**API-33** **AMENDED — the token is minted and returned at enrolment, and is simply not usable
until the delay elapses.** The enrolment response carries the spending token, the recovery
credential (`API-55`) and an `issuable_at` instant; the server stores only their hashes; and every
authenticated request before `issuable_at` fails `not_activated`. The caller polls its handle for
**status only** — never for the credential.

*The withdrawn model delivered the token once, later, from `GET /v1/enrol/{handle}`, and that
cannot survive a lost HTTP response: the server has marked it delivered and kept only a hash, so
it can neither re-send nor re-derive it, and a customer who has already funded is permanently
locked out of a tenant nobody else can reach either.* Concurrent polls had the same race. Minting
at enrolment keeps `API-33`'s throttle — the credential still does nothing until the delay
passes, which is what defeats a naive script — while removing the single-delivery trap entirely.

The status poll MUST NOT reveal the remaining time to the nearest instant (it is a free oracle for
tuning an attack).

**A delay is a real control against a naive script and a weak one against a parallel attacker**,
because concurrency makes wall-clock free. It is specified here as the operator's chosen friction,
not as the storage bound. `API-34` is the storage bound.

**API-34** **AMENDED — the time-to-live has a floor, and it is not free to choose.** A pending
tenant that has not been funded within a configured time-to-live MUST be deleted along with its
credential hashes. This caps the table at *enrolment rate × TTL* rather than letting it grow
without limit, and it is the requirement to test — an implementation that ships `API-33` without
`API-34` has bought delay and no bound.

**The TTL MUST exceed the deposit expiry (`LDG-54`) plus the maximum on-chain finality window**,
and a tenant MUST NOT be deleted while any deposit of its own remains inside that window
(`API-42`). Choose it shorter and a live, correctly-paid, still-watched deposit outlives the
tenant it belongs to — manufacturing `LDG-43`'s stranded payment out of configuration alone. With
a day-scale deposit expiry the floor lands around two days; a value of several days is the
sensible default, long enough that a slow payment does not cost a real customer their signup.

**A credited balance below the activation minimum does not extend the TTL.** When the signup
expires holding one, the tenant row is reaped as normal and the credit becomes an unattributed
ledger record (`LDG-43`) whose deposit binding is retained forever (`STO-29`) — so the money is
neither extinguished nor silently kept, and a customer returning with their deposit can have it
attributed. Exempting any credited tenant from the TTL would instead let a dust payment mint a
permanent row, reopening the immortal-tenant attack `API-35`'s minimum closed. `WIR-14`'s
disclosures MUST state this.

**A pending tenant's deposit expiry MUST be capped at its remaining signup time-to-live *minus
the finality window*.** Capping at the bare remainder still lets a deposit minted at the last
moment settle after the signup is reaped, which is the stranding this rule exists to prevent.
Otherwise a caller mints a fresh unpaid deposit just before each window closes and the
"do not delete while a deposit is in flight" rule defers reaping forever — one free signup
occupying a slot in `API-41`'s global ceiling indefinitely, at no cost. Capping it means an
unpaid deposit can never outlive the signup that created it, so the two rules stop fighting.

**Re-attribution of a retained credit is an operator action, and the honest reason is
`ADR-0005`.** Collecting nothing means the system holds no proof of who paid, so no self-serve
flow can bind a retained deposit to a new tenant — a caller claiming a deposit id it merely
guessed or observed would be claiming someone else's money. An attribution that brings the receiving tenant's cumulative balance to the activation minimum
**activates it atomically**, exactly as an ordinary settlement would (`API-35`, `LDG-52`) —
otherwise a customer who recovered enough credit would sit pending holding a sufficient balance.
The customer presents its deposit identifier to the operator, who credits it to a *named* tenant
through
`POST /v1/deposits/{id}/actions/attribute` (operator-only, `WIR-42`) — a real endpoint, because
"the operator surface" with no route is the gap this loop has now found four times.

**The limitation MUST be disclosed at mint** (`WIR-14`) in those terms: recovery requires
contacting the operator and is not self-serve, because `ADR-0005` leaves the system no way to tell
a returning customer from someone who observed a deposit identifier. Calling the credit
"re-attributable" without saying that implies a self-serve flow that cannot exist.

**API-35** **AMENDED twice.** A tenant MUST NOT graduate out of pending until its **cumulative
credited balance** reaches a configured minimum (`LDG-44`, `LDG-52`), and activation MUST occur
atomically the moment it does. *The 2026-08-13 amendment replaced "a payment meeting a minimum":
under the per-payment reading two credited payments of 60,000 against a 100,000 minimum left the
tenant pending forever holding 120,000 non-refundable satoshis.* The original said "a payment", so one
satoshi produced a permanently activated row that `API-34`'s time-to-live could never reclaim —
an attacker could mint immortal tenants for a rounding error each. The minimum MUST be large
enough to purchase something, since a balance that cannot buy compute is not a customer.

**API-42** A tenant MUST NOT be deleted while a payment attributable to it is in flight, and a
payment that arrives after its tenant was deleted MUST be recorded as unattributed rather than
dropped (`LDG-43`). The failure this prevents is specific and unrecoverable: the ledger is
append-only and exempt from retention, `ADR-0004` forbids a refund, and `ADR-0005` forbids
retaining anything that could identify the payer — so **money credited to a tenant that no longer
exists is money kept from someone the operator has made itself unable to find.**

**API-36** Enrolment MUST be rate-limited (`API-29`). Rate-limiting state MUST be held in memory
and MUST NOT be persisted — retaining caller addresses to defend the enrolment endpoint would
give up `ADR-0005` to protect a table.

**API-37** **AMENDED — there is no *identity* recovery, but there is a recovery *credential*
(`API-55`).** No identity is collected, so nothing an operator could verify proves ownership; any
mechanism built on that would be account takeover wearing a helpful name. What replaces it is
possession of a second secret issued at enrolment, which proves control without proving identity.

**So the client instruction changes and MUST be stated correctly at issuance:** a lost or
compromised *spending token* is **recoverable** while the recovery credential survives
(`API-56`) — the caller replaces it and keeps the tenant, its machines and its balance. Only
losing **both** is unrecoverable. *The withdrawn wording told a caller to abandon the tenant and
let its machines self-cancel, which on a funded, recoverable tenant destroys running machines for
no reason.* A lost token means a lost
balance, and so does a compromised one — the remedy for either is to stop funding it and let its
machines self-cancel at exhaustion (`LDG-14`) — **but only when both secrets are gone**; while the
recovery credential survives, the remedy is `API-56`, not abandonment. The caller is software and can
store a secret reliably — but it MUST be told at issuance that it has to, and that there is no
second chance.

**API-55** **Enrolment issues two secrets, and only one of them is used day to day.** The
**spending token** authenticates ordinary requests. The **recovery credential** is issued in the
same response, stored by the server as a hash only, never sent again, and used for nothing except
`API-56`. The caller MUST be told to store it somewhere its everyday agent does not reach, and
that losing both is a lost balance.

**This exists because the earlier reasoning about credential theft was wrong.** The reversal to
bearer tokens (`API-39`) argued that a stolen customer credential can only burn the victim's
prepaid balance, since there are no withdrawals. **A customer credential also authorizes `install`
— which wipes a disk — and `delete`, which destroys a machine.** The asset behind it is the
customer's data and running infrastructure, not a prepaid arcade card, and that holds identically
for a key or a token, so it does not disturb `API-39`'s choice — only the conclusion drawn from
it, that revocation earned nothing.

**API-56** **The recovery credential MAY revoke the spending token and obtain a fresh one; the
spending token MUST NOT be able to do either.** A revocation invalidates the current token
immediately, issues a replacement in the same response, and leaves the tenant, its machines, its
balance and its commitments untouched. **Rotation authorized by the token itself is not
sufficient and MUST NOT be offered**: a thief holding the token would rotate first and lock the
owner out permanently, converting credential theft into total loss of the tenant.

Revocation MUST carry an idempotency key and MUST replace the token **at most once per key**
(`STO-35`) — a replay returns `409` with `details.reason: "credential_already_replaced"` rather
than re-returning the new token, because storing a replayable body would mean persisting a live
bearer secret. This is a deliberate narrowing of `API-8`'s replay contract, and it is safe
precisely because the recovery credential can always mint another replacement and MUST NOT be reachable while a tenant is `pending`
before `issuable_at` — that window has no credential worth replacing.

**API-57** **A tenant MUST be assigned at least one provider account, automatically, in the same
transaction that activates it.** `API-17b` requires an explicit assignment and the provider views
return only assigned accounts (`WIR-29`, `WIR-30`) — but **nothing produced one**, so a literal
build gave every enrolled customer an empty provider list forever, on the product's only revenue
path. Both reviewers found it independently.

Assignment MUST follow a stated configured policy over the accounts flagged assignable, MUST
distribute tenants across accounts rather than filling one (`SEC-43`), and MUST be recorded
durably (`STO-34`). **It cannot be an operator step**: `ADR-0002` chose self-serve enrolment, and
an agent enrolling at 3am has no human to wait for.

**API-58** **A funded tenant MUST be suspended, never deleted.** Suspension is an operator action
that (1) marks the tenant `suspended` atomically so no further **tenant-authorized** write succeeds —
the maintenance actions of `API-7` step 2 remain reachable, because a suspended owner must still be
able to revoke a stolen credential (`API-56`, `CNF-209`) — then (2)
**fences work already in flight** — a create claimed before the suspension landed MUST be allowed
to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep,
because abandoning an in-flight order is how a machine ends up bought, unrecorded and unbilled —
then (3) enqueues a system cancellation per machine (`OPS-39`), then (4) aggregates their
outcomes,
including any that end `needs_reconciliation`. Reads of the ledger and machine list MUST continue
to work while suspended — the customer's history is their evidence, and `LDG-22` forbids purging
it anyway. `SEC-45`'s one-action termination is this verb; `API-34`'s deletion applies only to
**pending** tenants, which have no machines. They MAY hold a below-minimum credit, whose ledger
entries survive them (`STO-26`, `LDG-22`) and remain re-attributable through `WIR-42` — so
"no ledger" was wrong, and it is the case `API-34` exists to handle.

**API-40** Enrolment and every other write MUST be reachable under the general rules, and three
of those rules do not fit an unauthenticated, pre-tenant request. They are resolved here rather
than left as exceptions a builder must invent:

- **`API-7` (authenticate before validating)** — enrolment is unauthenticated by definition
  (`API-32`); there is no tenant yet. `API-7`'s ordering applies to authenticated endpoints, and
  enrolment's own defences are `API-33`'s issuance delay, `API-36`'s rate limit and `API-41`'s
  global ceiling.
- **`API-1` (every accepted write returns `202` and an operation)** — enrolment is exempt and
  returns its handle directly. It creates no provider mutation, so it needs no durable operation,
  and `operations.tenant_id` could not name a tenant that does not exist yet.
- **`API-8`/`API-10` (idempotency scoped to `(tenant, key)`)** — **AMENDED: enrolment carries no
  idempotency replay at all** (`WIR-12`). The withdrawn rule scoped it to the `Idempotency-Key`
  header alone, which is a **global unauthenticated key space**: two callers choosing the same
  low-entropy key would receive the same handle, and under `API-33` that handle's response carries
  the spending token *and* the recovery credential. That is credential disclosure reached by
  guessing a string. A duplicate signup is free and `API-34` reclaims it; a leaked capability is
  not. An `Idempotency-Key` presented to enrolment MUST be ignored, never honoured.

## Funding

**API-43** **AMENDED twice — the pending-tenant allowlist, named here so no endpoint has to guess.** `API-35` will not graduate a tenant until a payment is credited, so an
enrolment that cannot pay is a dead end. A **pending** tenant MAY reach:

1. **`POST /v1/deposits`** — mint a funding destination;
2. **`GET /v1/deposits/{id}`** — read *its own* deposit. This was omitted until 2026-08-13, and
   the omission was a money-visibility hole: a pending tenant that pays **below** the activation
   minimum (`LDG-44`) stays pending, its satoshis are non-refundable (`ADR-0004`), and without
   this endpoint it could not see what had been credited — only that it was still, unexplainedly,
   pending;
3. **`GET /v1/enrol/{handle}`** — unauthenticated, so not strictly an exception, but listed
   because it is how a pending tenant learns it has become active (`API-52`);
4. **`POST /v1/recovery/revoke`** — but **only at or after `issuable_at`** (`API-56`). Before that
   instant there is no usable credential to replace, so revocation is meaningless; after it, a
   pending tenant's token is live and can be stolen exactly like an active one's, and refusing
   revocation would leave the owner watching a thief spend a balance they funded.

**Every other authenticated endpoint MUST reject a pending tenant with `not_activated`**
(`DOM-20`).

**API-44** A funding request MUST carry the amount the caller intends to pay. The response MUST
return one **deposit** (`LDG-46`) carrying that amount, an expiry, and **both** destinations — the
Lightning invoice and the on-chain address — because the payer chooses the rail, not the
deployment.

The response MUST also carry two disclosures, and they are requirements rather than courtesies:

- **that the on-chain expiry is when the operator stops watching, not when the address stops
  working** (`LDG-54`). The address will still accept a payment afterwards and that payment may be
  lost;
- **that paying both destinations credits both, and nothing is refundable** (`LDG-56`).

**The amount is an intent, not a commitment.** `LDG-47` credits what arrives. A funding request
MUST NOT reserve, promise or pre-credit anything, and MUST NOT be treated as a receivable — on
either rail or on both.

**API-45** A funding request MUST be idempotent per `(tenant, idempotency key)` like every other
write (`API-8`), and re-sending one MUST return the **same** deposit — the same invoice and the
same address — rather than minting a second one. Minting a fresh deposit per retry is how a
caller that retries on timeout leaves a trail of addresses the operator must watch (`LDG-57`),
and how it eventually pays two of them for one intended top-up and is charged for both
(`LDG-56`).

**API-47** **A caller MUST be able to read its own balance**, and the view MUST distinguish the
ledger sum, the **available** figure that actually authorizes a purchase, and the satoshis held by
open commitments (`LDG-30`). Until 2026-08-12 no endpoint returned any of these: under `ADR-0002`
a prepaid balance is the entire spending authority, and the caller — software, acting without a
human — could learn its own solvency only by having a create rejected with `insufficient_balance`.
**That makes an ordinary check into a failed write**, and pushes an autonomous agent toward
retrying purchases to discover whether it can afford one.

The view MUST also expose what `LDG-15` already requires per machine — remaining runway — in
aggregate, so a caller can see the whole fleet's exhaustion horizon without walking every machine.

**API-48** **The synchronous endpoints are exactly: every `GET`, plus `POST /v1/enrol` and `POST
/v1/deposits`.** These are the exemptions from `API-1`'s "every accepted write returns `202` and
an operation", and they are listed together because each was previously exempted in its own
paragraph — `API-40` for enrolment, `API-43` implicitly for funding — which is how a general rule
acquires undocumented exceptions.

Both exemptions have the same justification: **neither causes a provider mutation**, so neither
needs a durable operation, and `operations.tenant_id` cannot name a tenant that does not exist yet
(enrolment). Any endpoint added later that *does* touch a provider MUST obey `API-1`; this list is
closed, not a pattern.

**AMENDED (2026-08-14): `POST /v1/deposits/{id}/actions/attribute` also joins** (`WIR-42`) — it
posts a ledger entry and touches no provider.

**AMENDED (2026-08-13, second time): `POST /v1/tenants/{tenant_id}/actions/resume` also joins**
(`WIR-41`) — it clears a flag and touches no provider. Suspension does **not**: it cancels a
fleet, so it returns `202` with a `suspend_tenant` operation whose children are the per-machine
cancellations.

**AMENDED (2026-08-13): three more join the list** — `POST /v1/recovery/revoke` (`WIR-38`, a pure
credential action), `POST /v1/operations/{id}/actions/resolve` (`WIR-35`, an operator decision
recorded against an existing operation; minting an operation *about* an operation is exactly the
recursion `API-1` never intended), and `GET`-shaped reads as always. Suspension (`WIR-39`) is
**not** synchronous: it cancels a fleet, so it returns `202` and its child cancellations are
ordinary operations.

**AMENDED (2026-08-12, `WIR-24`): `POST /v1/machines/{id}/actions/extend-runway` joins the list**,
under the same justification — it is a pure ledger action (`LDG-62`), returns the updated machine
view synchronously, and mints no operation per `OPS-39`'s rule that pure balance events are the
ledger's to record. The list being closed is why this amendment is written here rather than the
endpoint quietly exempting itself — which is exactly how the last two exemptions went unlisted
for a day.

**API-46** Funding MUST be rate-limited per tenant. Each request creates an address the operator
must watch until expiry (`LDG-57`) and a binding it retains afterwards (`STO-29`), so an unlimited
funding endpoint lets an unauthenticated-adjacent caller mint monitoring work at no cost. **The
expiry bounds the damage and the rate limit bounds the rate**; neither alone is sufficient,
because `API-34`'s time-to-live deletes a pending tenant while its deposits outlive it.

**API-41** Enrolment MUST be sheddable under load ahead of every other endpoint, and a deployment
MUST set a **global** ceiling on pending tenants, not only a per-caller rate limit. `API-36`'s
limiter holds its state in memory, so it resets on every restart of the single process
(`ADR-0001`) and is trivially defeated by distributed sources. The damage is not row count: the
time-to-live sweep of `API-34` is a large periodic delete against the same single-writer store
that serves the operation queue's atomic claim (`STO-1`, `STO-6`), and `DEF-11` records that this
store has already been starved once by a needless periodic write loop. **Enrolment at line rate
becomes a write-lock generator that stalls machine creation and commitment re-derivation.**

## Idempotency

**API-8** Every write request MUST carry a caller-generated idempotency key header.

**API-9** The key MUST be 8–200 characters of ASCII letters, digits, `.`, `_`, `:`, or
`-`.

**API-10** Idempotency MUST be scoped to `(tenant, key)`. A key collision across tenants
MUST NOT be observable by either tenant — not as a conflict, not as a shared operation,
and not as an internal error.

**API-11** Re-sending the same key with a byte-equivalent request MUST return the
existing operation. Re-sending it with a different request MUST fail `409 Conflict` and
MUST NOT create a second operation.

**API-12** Equivalence MUST be computed over a canonical serialization of the stored and
incoming requests, not over raw request bytes, so that key ordering and whitespace do not
produce spurious conflicts.

**API-38** **Equivalence after the payload is purged.** `ADR-0005` purges the stored request once the
operation stops being live, so for a completed operation there is nothing left to compare against and
`API-11`/`API-12` become unexecutable — `CNF-21` is BLOCKING and tests a comparison that cannot
be performed. The resolution is to persist, alongside the summary, a **canonical digest of the
request** computed at submission time. It survives the purge, carries no caller secret, and makes
equivalence a hash comparison rather than a field-by-field one.

This is not a detail. Without it an implementer picks between two failures, and **both end in a
duplicate purchase**: return `409` for a legitimate retry, after which an autonomous caller
generates a fresh idempotency key and buys a second machine; or return the existing operation
without checking, which breaks `API-11`'s promise that a *different* request under a reused key
is refused.

## Validation

Validation happens at the boundary *and* again in the worker (`OPS-23`).

**API-13** The following MUST be enforced before an operation is enqueued:

| Field | Rule |
|---|---|
| hostname | 1–253 characters, no CR or LF |
| offer identifier | 1–256 characters |
| `external_id` (adopt) | 1–256 characters, and a provider-appropriate character set (`PRV-6`) |
| SSH public keys | at most 64, each ≤16 KiB, each recognizably an OpenSSH public key |
| expected rescue host keys | at most 16, each a complete OpenSSH public host key |
| iPXE script | ≤128 KiB, begins with the iPXE shebang |
| catalog image | 1–256 characters |
| user data / post-install script | ≤1 MiB |
| provider options | MUST be a JSON object |
| image URL | ≤8192 bytes, no fragment, no embedded credentials, scheme `https` (or `http` only where explicitly enabled), host in the allowlist when one is configured |
| digest | exactly 64 hex characters (`DOM-14`) |
| strategy/image pairing | per `DOM-13` |
| host-key policy | pinned keys and "accept unpinned" MUST be mutually exclusive |
| request body size | globally capped (2 MiB is a reasonable default) |

**API-14** An install request MUST carry an explicit destructive acknowledgement, and a
delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
is not satisfied by authentication, by idempotency, or by having sent one previously.

**API-15** A create request against an order-billed provider MUST carry an explicit
purchase acknowledgement in its provider options, in addition to the account being
configured to allow ordering (`PRV-10`).

**API-16** A reverse-DNS request MUST be rejected unless the supplied address is present
in the machine's recorded address list, and the hostname MUST be 1–253 characters with no
CR or LF.

## Authorization

**API-17** Every machine-scoped endpoint MUST resolve the machine *within the caller's
tenant* and MUST return `404` — not `403` — when it does not exist there. Existence of
another tenant's machine MUST NOT be observable.

**API-17a** **The same rule applies to operations, and it is easy to miss because operations
are not machine-scoped.** `GET /v1/operations/{id}` MUST resolve within the caller's tenant and
return `404` otherwise; `GET /v1/operations` MUST be tenant-filtered before pagination. An
operation record carries the tenant, the provider account, the result and the error — enough to
enumerate another customer's estate from a stolen or guessed identifier. Specifying pagination
without specifying isolation is how this gets missed.

**API-17b** **Creation needs an authorization rule, and it is the only operation that has no
target to authorize against.** Every other verb is gated by a machine record the tenant already
owns. Create is gated by nothing: a tenant names a provider account and spends the operator's
money in it. `allow_orders` and a per-request purchase acknowledgement prevent *accidents*, not
*unauthorized* spending, and `DOM-3` says naming an account MUST grant nothing — which create
currently contradicts.

A deployment MUST therefore define, before accepting creates from more than one tenant:

- **which provider accounts a tenant may create in** — an explicit assignment, not "all
  configured ones"; and
- **that tenant's spending authority** — a ceiling per interval (`SEC-39`), a prepaid balance,
  or an operator approval step.

Absent both, any tenant can order unbounded billable hardware in any configured account, and no
other requirement in this document stops it.

**API-18** **AMENDED 2026-08-12 — adoption is an operator-only verb.** Under self-serve
enrolment every machine lives in the operator's provider accounts, so a customer cannot have a
machine there to adopt; adoption's only real use is the operator assigning a pre-existing machine
to a tenant. Entitlement is therefore the first of the original mechanisms — an
operator-maintained assignment of external machine identifiers to tenants, checked before
adoption — and the caller-facing adopt endpoint MUST reject tenant credentials outright, like
requeue (`API-19`). *The withdrawn text offered three mechanisms; `F28` observed two required an
operator step the self-serve product deleted and the third required access to a machine the
tenant does not have. All true, and moot: the feature they were defending was never reachable by
a customer under this product shape. The challenge-token mechanism is deleted from v1 scope and
returns only with a bring-your-own-machine product, which would need its own ADR.* See `DEF-1`.

**API-19** Requeue MUST be restricted to operators. A tenant token MUST NOT be able to
requeue an operation, because requeue can re-issue a purchase (`OPS-20`).

**API-30** Where a front service proxies customer requests using one admin identity plus the
tenant-override header (`API-5`), the override is the *entire* tenancy boundary for the
product, and this system cannot check it. `API-6` validates the identifier's character set
(`DOM-1`); whether it can validate that the tenant *exists* depends entirely on which branch of
`DOM-1a` the deployment chose. **With no registry, it cannot** — a well-formed identifier is
indistinguishable from a correct one, and this requirement applies in full. **With a registry,
this objection largely dissolves**: the override becomes checkable, and the remaining risk is
the ordinary one that the front service resolves the wrong tenant, which the registry cannot
detect but which is no longer unbounded. Deployments choosing a registry MAY treat the options
below as satisfied by the registry itself, and need not additionally implement one.

**A registry is not a complete answer.** It proves an override names an *existing* tenant. It
cannot detect the case that actually happens — a cached header, a reused connection, a wrong
variable — where the front service confidently selects the *wrong existing* tenant. Only
per-tenant proof carried from the client closes that, and `API-30`'s options below are about
the first problem, not the second. Every request legitimately carries admin plus override, so there is no anomalous case to
alarm on. A proxy bug — a cached header, a reused connection, a wrong variable — silently maps
one customer's request onto another customer's machines, and nothing here notices.

A deployment using this pattern MUST therefore do one of:

- **Sign per tenant.** The front service signs each forwarded request with a per-tenant key
  this system holds and verifies. Preferred: it makes the override falsifiable.
- **Keep a synced allowlist.** This system maintains an out-of-band-synchronised set of valid
  tenant identifiers and rejects overrides outside it. This is a tenant registry, so a
  deployment choosing it MUST select `DOM-1a`'s registry branch explicitly.
- **Accept and document.** Record explicitly that the front service's proxy is the single
  point of tenancy enforcement, that this system's tenancy tests (`CNF-4`–`CNF-7`) prove
  nothing about it, and that the front service needs its own equivalents.

**API-31** Where the front service proxies with one admin identity, every audit record here
reads "admin override" (`SEC-32`), which makes the trail useless for attributing an action to
a customer. The front service MUST keep its own request→customer audit log, joinable to these
records by correlation id (`API-28`).

## Operation views

**API-20** **AMENDED 2026-08-12.** The operation view returned to clients MUST include: id,
tenant, idempotency key, kind, status, machine id, provider account, result, error, attempt
count, timestamps, `revision` (`API-53`), `retryable` (`API-51`), and `requested_by` with its
`system_reason` when system-initiated (`OPS-39`). For a non-terminal operation the view carries
`poll_after_ms` (`API-49`).

**API-21** The operation view MUST NOT include the stored request payload. It can contain
signed image URLs and other caller secrets that need not be echoed back.

**API-22** Result and error payloads MUST be redacted (`DOM-6`, `DOM-18`) before they are
stored, not merely before they are rendered.

**API-23** `GET /v1/operations` MUST support filtering by status and MUST support
pagination. Listing everything in `needs_reconciliation` is an operational necessity
(`OPS-26`).

## Errors

A single envelope for every failure:

```json
{
  "error": {
    "kind": "invalid_request",
    "message": "human readable, safe to show an operator",
    "retryable": false,
    "details": {}
  }
}
```

**API-24** `kind` MUST come from the closed set in `DOM-17`, and the HTTP status MUST be
derived from it by the mapping in that table. Handlers MUST NOT choose statuses
independently.

**API-25** `message` MUST NOT contain a credential, a private key, a signed URL, or an
unredacted provider response.

## Listing and pagination

**API-26** `GET /v1/machines` MUST be tenant-scoped, MUST clamp any caller-supplied limit
to a sane range, and SHOULD offer a cursor rather than an offset.

## Transport

**API-27** Reachability follows the separation form chosen under `OVR-10`. In the
separate-service form the lifecycle API MUST be reachable only over a private network. In the
single-component form the public surface is reachable by customers by definition, and the
deployment MUST instead:

- terminate TLS such that no credential traverses an untrusted hop in clear text;
- expose *only* the customer-facing routes publicly, keeping operator and reconciliation routes
  on a separate listener or network (`API-19` requeue in particular is operator-only and is a
  purchase);
- treat `OVR-10a`'s in-code credential boundary as the compensating control, since network
  isolation is no longer providing one.

A deployment MUST record which form it chose. "Private network" is not a property this
specification can assume once the customer is the caller.

**API-28** Every request SHOULD carry a correlation identifier, generated if absent, and
that identifier MUST appear in the operation record and in every log line emitted while
handling the request.

**API-29** The service SHOULD rate-limit per tenant (`OPS-24`). Unauthenticated requests
MUST be rate-limited.

## Completion and pacing

Every write returns `202` and a ticket (`API-1`), which left the other half unstated: how the
caller — software that does not get bored — finds out the work finished, and at what request rate.
Decided 2026-08-12 by a three-model panel that reached the same answer independently; the
alternatives it rejected are recorded in `11-open-findings.md`. **The completion mechanism is
polling with server-chosen pacing.** No webhook, stream, long-poll or change feed ships in v1;
each is additively possible later, and none may be assumed by a client.

**API-49** **The server paces the caller.** Every response describing a non-terminal operation
MUST carry a `Retry-After` header and the same value as a `poll_after_ms` body field (proxies
strip headers; the body survives, and a browser caller cannot read non-safelisted headers without
`Access-Control-Expose-Headers`). The value is server-derived per operation kind, provider and
current state — never a client-side constant (`DEF-5` is on the defect list for exactly that) —
and MAY grow over an operation's life: seconds for a power cycle, minutes for a dedicated order
sitting `in process`. It is a next-check instruction, never a completion estimate.

**The fleet pattern is the list, not the loop.** `GET /v1/operations?terminal=false` is one
request per interval regardless of fleet size (`API-23`'s filtering plus `API-26`'s pagination),
and the documentation MUST steer fleet-scale callers to it. The status filter MUST accept a
`terminal=false` predicate.

**Exception (`API-33`):** the enrolment poll MUST NOT carry a delay-derived `Retry-After` — on
that one endpoint the pacing hint is the timing oracle `API-33` forbids. Absent, or a constant
unrelated to the remaining delay.

**API-50** **A caller that obeys every `Retry-After` it receives MUST never receive `429`.** This
is the rate-limit contract stated as a relationship rather than a number, because any number is
wrong after the fleet grows. Read limits MUST be budgeted separately from write limits and MUST
admit, at minimum, one non-terminal list poll plus one balance poll plus one machines poll at the
finest advertised cadence. Every `429` anywhere MUST itself carry `Retry-After`, and a `429` on a
read carries **no information about any operation's outcome** — an autonomous caller MUST NOT
treat a throttled poll as a failed operation, and **a read being rate-limited MUST never become
the reason a caller re-issues a write** (the `CNF-150` pathology: when the read path is closed,
an agent discovers state by mutating).

**API-51** **`retryable` is normative for callers, not advisory to operators.** An operation in
`needs_reconciliation` MUST be delivered with `retryable: false`, and the contract MUST state in
words that re-issuing the request under a fresh idempotency key **is a second purchase**, not a
retry. `OPS-12` forbids the *system* from retrying an ambiguous mutation and `API-19` makes
requeue operator-only, but nothing else stops the *customer's* agent from buying the duplicate
server `OPS-20` exists to prevent — `SEC-39`'s per-principal ceiling is the backstop, and this
field is the signal. This is the single most expensive way for "finding out" to go wrong.

**API-52** **A pending tenant MUST be able to observe its own activation without attempting a
purchase.** `API-43` grants a pending tenant the funding endpoint and nothing else, and
`GET /v1/balance` answers `not_activated` — so a freshly enrolled agent that has already paid
could learn it was active only by issuing a create and reading the rejection, which is the exact
pathology `API-47` was written out of the post-activation path. `GET /v1/enrol/{handle}` MUST
answer with the tenant's current status (`pending` | `active`) after credential issuance, and is
added to `API-43`'s reachable-while-pending set alongside funding.

**API-53** **Every operation view carries a `revision`**: a per-operation counter that strictly
increases on each client-visible modification. A response bearing a lower revision than one the
caller has already observed is stale and MUST be discarded by the caller; the contract promises
no ordering across *different* operations. This exists because two polls can arrive out of order,
and `updated_at` cannot arbitrate — clock reads tie at millisecond resolution and step backwards
under NTP. A tenant-wide sequence was considered and deferred with the change feed; `STO-6`'s
note records what a future feed must add.

**API-54** **A read MUST NOT take a write transaction.** No `GET` may run a sweep, refresh
provider state, bump a `last_seen`, or otherwise write — `DEF-11` records this store being
starved by one internal periodic writer, and a read path that writes hands that trigger to every
polling customer. Rate-limiter state stays in memory (`API-36` already requires this for
enrolment; it is general).
