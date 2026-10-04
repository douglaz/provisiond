# 04 — HTTP API contract

## Surface

| Method | Path | Sync | Purpose |
|---|---|:--:|---|
| GET | `/healthz` | ✓ | Liveness. Unauthenticated. |
| GET | `/v1/providers` | ✓ | Configured accounts and their capabilities |
| GET | `/v1/providers/{account}/offers` | ✓ | Purchasable offers for one account |
| GET | `/v1/machines` | ✓ | List the caller's machines |
| POST | `/v1/machines` | | Create a machine |
| GET | `/v1/machines/{id}` | ✓ | Read one machine |
| POST | `/v1/machines/{id}/actions/refresh` | | Re-read from the provider |
| POST | `/v1/machines/{id}/actions/power` | | Power on/off, reboot, hard reset |
| POST | `/v1/machines/{id}/actions/rescue-inventory` | | Boot rescue and report the disks, before a destructive write (`RSC-38`, `WIR-40`) |
| POST | `/v1/machines/{id}/actions/install` | | Install an image (`WIR-20`, `DOM-13`) |
| POST | `/v1/machines/{id}/actions/reverse-dns` | | Set a PTR record |
| POST | `/v1/machines/{id}/actions/delete` | | Delete the machine |
| GET | `/v1/operations` | ✓ | List operations, filterable by status |
| GET | `/v1/operations/{id}` | ✓ | Poll one operation |
| GET | `/v1/episodes` | ✓ | Operator: list episodes, filterable by state (`API-64`, `WIR-51`) |
| GET | `/v1/episodes/{id}` | ✓ | Operator: read one episode (`WIR-51`) |
| POST | `/v1/episodes/{id}/actions/retry` | ✓ | Operator: enqueue a fresh attempt under a `stalled` episode (`API-64`, `WIR-51`) |
| POST | `/v1/enrol/token` | ✓ | Unauthenticated: obtain the enrolment admission token, answering only after a stated delay (`API-33`, `WIR-49`) |
| POST | `/v1/enrol` | ✓ | Create a pending tenant, return a handle; requires an admission token (`API-32`, `API-33`) |
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
| GET | `/v1/abuse-cases` | ✓ | List the caller's abuse cases (`API-59`, `WIR-43`) |
| GET | `/v1/abuse-cases/{id}` | ✓ | Read one abuse case, with its statements (`WIR-43`) |
| POST | `/v1/abuse-cases/{id}/statements` | ✓ | Submit a statement; append-only (`WIR-43`) |
| POST | `/v1/abuse-cases` | ✓ | Operator: open a case from a notice (`API-60`, `WIR-44`) |
| POST | `/v1/abuse-cases/{id}/actions/close` | ✓ | Operator: close with an outcome (`DOM-24`, `WIR-44`) |
| POST | `/v1/abuse-cases/{id}/actions/record-transmission` | ✓ | Operator: record what was sent to the provider (`WIR-44`) |
| GET | `/v1/address-resolution` | ✓ | Operator: which machines held an address at an instant (`SEC-54`, `WIR-46`) |
| POST | `/v1/machines/{id}/actions/record-network-restriction` | ✓ | Operator: record a restriction no driver can read (`DOM-27`, `WIR-47`) |
| POST | `/v1/abuse-cases/{id}/actions/revise-deadline` | ✓ | Operator: extend `respond_by`, keeping the old value (`STO-44`, `WIR-47`) |
| POST | `/v1/tenants/{tenant_id}/actions/assign-provider-account` | ✓ | Operator: add or replace a tenant's provider-account assignment (`API-62`, `WIR-48`) |
| POST | `/v1/provider-accounts/{account}/actions/record-status` | ✓ | Operator: record an account unreachable, its credentials rejected, or its termination confirmed (`API-63`, `WIR-50`) |
| POST | `/v1/provider-accounts/{account}/actions/record-billing` | ✓ | Operator: record an invoice, payment or void (`API-66`, `WIR-53`) |
| GET | `/v1/provider-accounts/{account}/billing` | ✓ | Operator: billing rows, accrual and deployment headroom (`API-67`, `WIR-54`) |

**The enrolment, funding and balance rows were absent until 2026-08-12** — enrolment shipped on
2026-08-11 and funding earlier the same day as that note, and the recovery, resolve, suspend,
resume, attribute and rescue-inventory rows were added later still, each with requirements and no place on the surface. A table
that omits an endpoint the requirements mandate is `F19` in miniature, and it is the reason
`API-48` now states the synchronous exemptions in one place instead of leaving each new endpoint
to contradict `API-1` on its own.

**API-1** Every non-`GET` endpoint that *accepts* a valid, authorized request MUST return
`202 Accepted` with an operation view; none returns the completed result inline. Requests
rejected before enqueue return their mapped error status (`API-24`) — `400`, `401`, `402`, `403`,
`404`, `409`, `410`, `429`, `501` and `503` are all reachable on write endpoints, which is
`DOM-17`'s mapping and not a shorter list. *The five that were missing here arrived with the kinds
that produce them — `insufficient_balance`, `not_activated`, `suspended`, `gone`, `halted` and
`ceiling_exceeded` — and an enumeration that lags the taxonomy teaches a client to treat a
conforming status as a protocol error.*

**API-2** **AMENDED.** `{id}` in a machine, operation or deposit path is always an internal UUID; a
`{tenant_id}` component follows `DOM-1`'s grammar instead, which is wider than a UUID (`agent-7`
is valid). The original said "always", which a strict router applies to `/v1/tenants/{tenant_id}`
and rejects every valid tenant. A provider-side identifier MUST
NOT appear in a client-constructed path (`DOM-5`).

**In a path, `DOM-1`'s grammar is necessary and not sufficient.** A `{tenant_id}` component MUST
be matched as exactly **one** path segment, never as a greedy remainder, and MUST be validated
**after** percent-decoding and **rejected rather than normalised**. The decoded segment MUST NOT
be `.` or `..` and MUST NOT contain `/` or `\` in any encoding. `DOM-1` admits `.`, so `.` and
`..` are well-formed tenant identifiers, and a router or proxy that resolves them re-points the
request at a route the caller did not name; `/` is outside the grammar but arrives through `%2F`
unless the check runs after decoding. This is `PRV-6` pointed the other way — that one guards the
path this system *writes* to a provider, this one guards the path a caller writes to it.

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
non-extractable asset, and did not justify the cost. *A note here read "`API-33`'s delayed issuance
therefore un-collapses — a generated token *is* transmitted at issuance, so the throttle protecting
that moment matters again", and it is withdrawn 2026-09-02 with the delayed issuance it described.
The reasoning did not survive contact with the mechanism: a delay after the token is in the caller's
hands protects that moment not at all, which is `API-33`'s own conclusion. The throttle that
survived is the admission gate, and it protects a different thing — the pending-tenant slot, not the
secret.*

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
environment-supplied, and outside the tenant model entirely.

**API-5** **AMENDED 2026-09-02.** Each token maps to exactly one **principal** and an admin flag. A
customer token's principal is exactly one tenant (`STO-21`); **the operator token's principal is the
operator, which is no tenant at all** (`API-4`) — it is environment-supplied, outside the tenant
model, and names its subject per request through the override header instead. An admin token MAY act
for another tenant by sending that header (`WIR-33`); a non-admin token MUST NOT, and
the header MUST be ignored rather than honoured for it.

*"Each token maps to exactly one tenant" was false of the only token that reaches the operator
routes, and a builder implementing it literally either invented a synthetic operator tenant — which
`STO-21` would then have to hold, and `LDG-6` would attribute entries to — or made every
operator-only endpoint unreachable. Deleted rather than annotated; the correction is one word,
`principal`, and `WIR-5` already used it.*

**API-6** An overridden tenant identifier MUST be validated against `DOM-1` before use.

**API-7** **Authentication MUST happen before request-body validation.** An
unauthenticated caller MUST NOT be able to learn anything from validation error text, and
MUST NOT be able to make the server do parsing or policy work. See `DEF-4`.

**AMENDED 2026-09-04 — steps 2 and 5b test a TENANT, and an operator principal has none of its
own.** Every step still runs for every authenticated write, operator writes included: they carry
`Idempotency-Key` (`WIR-24`) so step 3 and 5a are load-bearing for them, and `SEC-39`'s ceilings at
5c are the operator's whole budget. What changes is **whose** tenant steps 2 and 5b read, and what
step 4 authorizes against:

- **Every operator verb skips 2 and 5b**, whether or not it names a tenant. *Until 2026-09-08 one
  verb was excepted — `adopt`, the one that bought against the named tenant — and `ADR-0020`
  withdrew it; the exception returns with the verb. The list was stated as a one-verb list and not
  as "wherever a tenant is named", because the second reading — a repair of
  2026-09-04 — refused the operator surface on its ordinary inputs: `WIR-42`'s attribution target
  "MAY be `pending`, the ordinary case since a returning customer enrols afresh", so the only route
  back for an orphaned balance failed `not_activated`; and opening, closing, transmitting, revising a
  deadline and recording a restriction all name a tenant the operator may have just suspended for
  silence, so `SEC-45`'s escalation refused the case it escalates.* The principal is authorized by
  being on the operator listener (`WIR-34`) and bounded at 5c.
- **Step 4** authorizes the target resource by **existence** rather than by ownership for an
  operator, since cross-tenant reach is the point of the surface.

*Step 2's own amendment already had this idea — revoke, resolve and resume are "authorized by
principal rather than by tenant state" — and then expressed it as an allowlist while the
operator surface grew to suspend, attribute, assign-provider-account, record-status,
record-network-restriction, revise-deadline, address-resolution and `WIR-44`'s three abuse verbs.
Read literally, every one of those was rejected at step 2 for a tenant the principal does not have.
A first repair on 2026-09-04 over-corrected, exempting operators from 5b outright — which deleted
the ordering refusal above, since it lives on an operator-only verb and no other step performs
it. The carve-out is about the principal having no tenant **of its own**, and nothing more.*

**The tail is per endpoint class, because one universal pipeline was wrong for four of
the five classes.** Steps 1–5 are common to every authenticated write:

1. authenticate, resolve principal;
2. **reject a tenant that has never been activated** — a `pending` tenant fails `not_activated`
   (`API-35`), **except** the `API-43` allowlist and the **maintenance actions**: revoke
   (`API-56`), resolve and resume are authorized by principal rather than by tenant state,
   and gating them on an activated tenant would leave a suspended or pending tenant unable to
   replace a stolen credential —
   locking the owner out at exactly the moment the mechanism exists for. **This step is the
   issuance check and nothing else: it MUST NOT look at suspension.** A `suspended` tenant passes
   it and is rejected at 5b instead. *The withdrawn wording — "reject unless the tenant is active"
   — rejected a suspended tenant here, which made 5b unreachable and defeated its stated reason
   for existing: every write retried after its tenant was suspended lost the stored idempotent
   result `API-11` promises it, including a suspend whose own `202` was lost;*
3. validate the idempotency key;
4. authorize the target resource against the tenant;
5. deserialize and validate the body;
5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`. This step
    needs the parsed body, which is why it cannot live at step 3;
5b. **reject with `suspended`** if the tenant is suspended and this is not a maintenance action
    (`API-58`, `DOM-20`). **This is the only step that rejects for suspension** — step 2 passes a
    suspended tenant through on purpose. It sits *after* 5a deliberately: a write replayed from
    before the suspension must return its stored result rather than a spurious rejection, and only
    the fingerprint check can tell a replay from a new write.
    **The abuse-statement write (`WIR-43`) is a maintenance action and MUST remain reachable while
    suspended**, and `API-58`'s retained reads extend to the case reads. Added 2026-08-16: `SEC-45`
    names an unanswered notice as a reason to suspend, so without this the operator's escalation for
    silence is what guarantees the silence — and the sentence `STO-40` exists to capture, the late
    one naming the actual cause, is refused at the moment it is most wanted. The write touches no
    provider and moves no money, which is the same ground `WIR-41`'s resume stands on.
5c. **enforce `SEC-39`'s per-principal ceilings** and reject `ceiling_exceeded` (`DOM-17`) with
    `details.ceiling`, `details.limit`, `details.interval_seconds` and `details.retry_after_ms`
    (`WIR-9a`). **Added 2026-09-02**: `SEC-39` is the control that replaces a per-request
    acknowledgement when the caller is a program, `CNF-69` tests it, and **no step of this
    pipeline checked it** — so a builder following these steps literally shipped no ceilings at all
    while the requirement and its test both existed. It sits **after** 5a and 5b for the same
    reasons those sit where they do: a replay must return its stored result rather than spend a slot
    it already spent, and a suspended tenant is refused before its budget is consulted. It sits
    **before** the tail, so a ceiling refusal happens before any commitment opens and before
    anything is enqueued.
    **The exemptions are these, and no others.** `OPS-39` exempts exposure-reducing **system**
    cancellations, because a tenant that hit its destruction limit would otherwise keep machines it
    cannot pay for at the operator's expense — though that sweep enqueues directly and never
    traverses this pipeline, so the exemption bites here only on the other one: `SEC-39`'s stated
    override path for a genuine incident is the operator's, recorded as the uncapped thing.
    **`API-64`'s retry is not exempt**: it counts against `SEC-39`'s operator retry ceiling, and
    the operator is a program (`SEC-39`), so a loop retrying a deterministic rejection is exactly
    what the ceiling is for (`ADR-0017`).

The tail then depends on what the endpoint does:

| Class | Tail |
|---|---|
| **create** | evaluate the rich purchase tail below; on admission, commitment + operation in one transaction (`LDG-11`, `LDG-35`), then `202` |
| **power, install, reverse-DNS, refresh, rescue inventory** | enqueue an operation, then `202`. **No commitment**: they are not purchases, and they pass no spending gate |
| **retry** | operator-only (`API-64`, `WIR-51`); synchronous, `200` with the episode view; the episode's state change, the enqueue of a fresh `delete_machine` attempt and the idempotency record commit in one transaction (`WIR-24`); **no commitment and no spending gate** — the attempt reduces exposure, on the delete row's reasoning |
| **suspend** | operator-only; enqueue one cancellation per machine, then `202` (`API-58`) |
| **release attachment** | operator-only (`API-65`, `WIR-52`); on an `api` row enqueue one `release_attachment`, then `202`; on a `manual` row synchronous `200`, writing `released_at` (`API-48`); **no commitment and no spending gate** — it reduces exposure, on the delete row's reasoning |
| **revoke** | operator or recovery-credential principal (`API-56`, `WIR-38`); synchronous, `200`, no provider mutation (`API-48`) |
| **resume, resolve** | **operator-only** (`WIR-41`, `WIR-35`, `WIR-34`); synchronous, `200`, no provider mutation (`API-48`). The recovery credential reaches **neither** — `API-55` confines it to `API-56`, and a recovered-after-theft credential that could resume its own tenant or resolve an uncertain provider mutation would undo the suspension that answered the theft |
| **delete, cancel** | enqueue an operation, then `202`, and **bypass the rate and solvency gates entirely** — these reduce exposure, and refusing them because exposure is too high is the failure `LDG-20` already forbids |
| **deposit** | synchronous; allowed while pending; **refused `halted` while `LDG-20`'s solvency halt is in force** — that halt stops top-ups *first*, and minting a destination invites exactly the payment it forbids; otherwise **mints a destination and writes NO ledger entry** — a deposit is not money until it settles (`LDG-47`) — plus an idempotency record, in one transaction; `200` |
| **extend-runway** | evaluate the rich purchase tail below; on admission, the guarded extension (`LDG-62`) and idempotency record commit together (`WIR-24`); synchronous `200` |
| **abuse-case writes** | the tenant's statement (`WIR-43`) and the operator's five verbs (`API-60`, `API-61`) — synchronous, **no commitment, no spending gate, no provider mutation**; `201` on create and on a statement, `200` on the rest; each carries `Idempotency-Key` under `WIR-24`'s one-transaction rule. The statement write is a maintenance action and stays reachable while suspended (step 5b) |
| **attribute** | operator-only (`WIR-42`); synchronous, `200`; posts ledger entries, so it **takes `LDG-35`'s serialization for both tenants, in ascending tenant-identifier order**, and the primitive must not require a live `tenants` row — the source tenant is normally already reaped |
| **record billing** (*added 2026-10-04, `pv-gip.39`*) | operator-only (`API-66`, `WIR-53`); synchronous `200`; local row and receipt commit together; no provider mutation, commitment or spending gate |

**Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5c, the tail MUST
collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
transaction, without an extra lock, ceiling slot, write or provider call. `details.refusals`
(`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create
against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension);
`halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`);
`insufficient_balance`. See `ADR-0030` for the order's rationale and `LDG-40` for halt retention.
Both halted entries may appear; no duplicate
means no repeated refusal/check, not unique kind strings. The cap and balance checks MUST NOT
run without a rate, nor for create against an unhealthy account: `WIR-30` says "an account whose
`STO-47` status is not `healthy` `404`s on this route too". `WIR-9a` owns `not_checked`,
including cap presence, reasons and ordering. Each refusal is exactly
`WIR-9`'s inner error object, with no nested refusal list. Entry 0 is the headline: HTTP status,
`kind`, `message` and per-kind details MUST match it; top-level details additionally carry the
aggregate keys. Only top-level `retryable` may differ, under `WIR-9b`. Pacing belongs to the
headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and
`WIR-4`; each entry keeps its own required pacing. No maximum is taken and a subordinate halted
entry MUST NOT supply pacing to a headline kind that does not require it. A refused tail MUST
commit nothing and write no `STO-35` receipt (`WIR-3`), so clearing faults and resending the same
request/key evaluates afresh. Admission retains the conditional-write guards in `API-63` and
`LDG-62`; collection does not replace them with read-only guards. These are admission refusals
(`OPS-11`), never lists in operation views. Steps 1–5c still stop at their first refusal; see
those steps for their rationale. Deposit behavior and other tails are unchanged.

*The withdrawn list applied the commitment and the spending gates to "every write endpoint", so a
literal builder opened a purchase commitment on a reboot and could be blocked from deleting a
machine during a rate outage — the one action that would have stopped the bleeding.*

**The attribute and abuse-case rows were added 2026-08-31.** Those endpoints had joined `API-48`'s closed list and `WIR-34`'s operator-route list and been
missed here, so a builder reached step 5b and the instructions stopped. `attribute` is the one that
mattered: it appends ledger entries to two tenants and nothing said it serialized.

The activation check, the spending-authority check and the commit-and-enqueue transaction were
all absent until 2026-08-12. The list was described as normative "for every
write endpoint", so **a builder following it literally shipped a create with no authorization at
all** — the money check existed in `12-billing-and-ledger.md` and in no sequence any handler
author would read.

## Enrolment

Self-serve enrolment (`ADR-0002`) with no identity collected (`ADR-0005`) means the only thing
standing between a script and an unbounded table of tenant rows is this section.

**API-32** **AMENDED 2026-09-02.** An enrolment endpoint MUST exist that requires **no principal**.
It creates a tenant in a **pending** state and returns an enrolment handle together with both
secrets (`API-33`, `WIR-12`), and the tenant can do nothing but fund itself until `API-35` activates
it (`API-43`).

*"Unauthenticated" is retained as the description of the principal, not of the door.* The request
carries an admission token (`API-33`, `WIR-49`) — which authenticates nothing and identifies nobody;
it proves only that the caller held a connection open for the stated delay, which is the whole
economic point of it.

*The withdrawn sentence was "It MUST NOT return a usable credential immediately", and `API-33` made
it false on the same day it withdrew `issuable_at`.* That clause was the pre-2026-08-31 model, where
the token was minted at enrolment and unusable until an instant — an arrangement `API-33` withdrew
because the delay ran *after* the caller had consumed a pending-tenant slot and therefore defended
nothing. What replaced it is a delay paid **before** the signup exists. Keeping the clause would
mean re-introducing the unusable window under a different name, and a reader reconciling it with
`WIR-12`'s fixture would have found a response carrying a working token beside a requirement
forbidding one.

**API-33** **AMENDED — the token is minted and returned at enrolment.** The enrolment response
carries the spending token and the recovery credential (`API-55`); the server stores only their
hashes. The caller polls its handle for **status only** — never for the credential. *An
`issuable_at` instant before which the token did nothing was part of this amendment and is
withdrawn below.*

*The withdrawn model delivered the token once, later, from `GET /v1/enrol/{handle}`, and that
cannot survive a lost HTTP response: the server has marked it delivered and kept only a hash, so
it can neither re-send nor re-derive it, and a customer who has already funded is permanently
locked out of a tenant nobody else can reach either.* Concurrent polls had the same race. Minting
at enrolment removes the single-delivery trap entirely, and the throttle that defeats a naive
script is the admission delay below, paid *before* the signup exists.

The status poll MUST NOT reveal the remaining time to the nearest instant (it is a free oracle for
tuning an attack).

**AMENDED 2026-08-31 — the delay moves in front of the slot, and becomes the admission gate.**
The withdrawn arrangement minted the token at enrolment and made it unusable until `issuable_at`,
so the delay ran *after* the caller had already consumed a pending-tenant slot. It defended nothing:
`API-41` requires a global ceiling on pending tenants, `API-34` holds each for days, and this
document already concedes the limiter is "trivially defeated by distributed sources" — so an
attacker fills every slot, refills as they expire, and closes the only path from stranger to
customer, for free, for as long as it likes. **`API-41`'s ceiling was itself the denial of service.**

Enrolment therefore requires a **token** the caller obtains from an unauthenticated request that
answers only after a stated delay (30 seconds is a reasonable default). `POST /v1/enrol` without a
valid, unexpired, unused token is refused. The token MUST be a keyed authenticator over its issue
instant and a server-chosen nonce, so **issuing one requires no stored state**; single use is
enforced by an in-memory nonce set bounded by the validity window, which keeps `API-36`'s rule that
rate-limiting state is never persisted.

**What this buys is a change of resource, not a proof.** It converts the attack from requests per
second — unbounded and free — into *concurrently held connections*, which is bounded, visible, and
the thing a proxy can limit per source address. Those per-source limits are in-memory and
unpersisted like every other limiter here (`API-36`), so defending the door does not cost
`ADR-0005`. A sufficiently distributed attacker still gets tokens; it now pays for each one in held
connections rather than in nothing at all.

*This also closes `F33`, which the 2026-08-14 audit held open because `API-33`'s delay had lost its
original justification — it existed to protect the single moment a token crossed the wire, and
`API-33` now returns both secrets in the enrolment response. The delay is not deleted; it is moved
to the one place it does work.*

The status poll MUST still not reveal remaining time to the nearest instant, for the reason below.
`API-34` remains the storage bound.

**AMENDED 2026-09-02 — the token now has a route, a field, and one delay instead of two.** The
amendment above mandated a token that nothing issued and nothing accepted: no endpoint minted one,
the surface table had no row for one, and `WIR-12`'s enrolment body was `{}` under a `WIR-2` that
rejects unknown fields — so `13-wire-contract.md` won and **a conforming server refused every
enrolment**, which is the whole product. Three edits close it.

- **The route is `POST /v1/enrol/token`** (`WIR-49`): unauthenticated, synchronous, on the surface
  table and in `API-48`'s closed list. It holds the connection for the stated delay, answers with
  the token and its expiry, and writes nothing — which is what keeps `API-36`'s no-persisted-limiter
  rule true of the door as well as of the room.
- **`POST /v1/enrol` carries the token as a body field**, `admission_token` (`WIR-12`). A field
  rather than a header, because `WIR-2` validates bodies against a closed schema and would otherwise
  reject it, while an unauthenticated route has no header allow-list of its own to extend. Absent,
  expired, unknown or already spent is `invalid_request`, and the message MUST NOT say which — the
  distinction is a free oracle for exactly the script this gate exists to slow.
- **`issuable_at` is withdrawn entirely**, along with the `enrolments` column (`STO-34`), the
  response field and the `not_yet` status (`WIR-12`, `WIR-13`), and the two gates that read it
  (`API-43` item 4, `API-56`'s pending-window refusal).

*The withdrawal follows this requirement's own argument to its end.* The delay was moved in front of
the slot because, run afterwards, "it defended nothing". Leaving the instant behind left **two**
delays in a set whose every sentence described one — and the surviving one defends nothing under
either model: both secrets are already in the caller's hands when it starts, so an attacker who has
enrolled simply waits thirty seconds. What survives is the delay that is paid *before* a
pending-tenant slot is consumed, which is the only one that was ever doing work. A consequence worth
stating rather than discovering: the spending token is live from the moment enrolment returns it, so
`API-56`'s revocation is reachable from that moment too — which is the right answer to a credential
stolen in transit, and the withdrawn gate refused it for the first thirty seconds of every tenant's
life.

**This is a judgement call, and it is cheap to reverse:** restoring a post-issuance usability delay
is one column and one field. It is recorded here rather than in a commit message so that a reader
who wants the old behaviour can see exactly what went and why.

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

**Where that cap has already passed, the request MUST be refused rather than satisfied with an
already-expired deposit.** A signup with less than one finality window left to run has no room to
mint one: a deposit whose lifetime is zero or negative cannot be paid, and returning it as though
it could invites exactly the stranded payment (`LDG-43`) the cap exists to prevent. The refusal is
`conflict` (`DOM-17`) — what is wrong is the signup's remaining time, not the request — and the
caller's remedy is a fresh enrolment, which costs nothing.

**Re-attribution of a retained credit is an operator action, and the honest reason is
`ADR-0005`.** Collecting nothing means the system holds no proof of who paid, so no self-serve
flow can bind a retained deposit to a new tenant — a caller claiming a deposit id it merely
guessed or observed would be claiming someone else's money. An attribution that brings the receiving tenant's cumulative balance to the activation minimum
**activates it atomically**, exactly as an ordinary settlement would (`API-35`, `LDG-52`) —
otherwise a customer who recovered enough credit would sit pending holding a sufficient balance.
The customer presents its deposit identifier to the operator, who credits it to a *named* tenant — **which may be `pending`**, the ordinary case since a
returning customer enrols afresh, and the credit counts toward `API-35`'s activation minimum like
any other — through
`POST /v1/deposits/{id}/actions/attribute` (operator-only, `WIR-42`) — a real endpoint, because
"the operator surface" with no route is the gap this loop has now found four times.

**The limitation MUST be disclosed at mint** — `WIR-14`'s `orphan_recovery_is_operator_only`
entry is that disclosure, and it says in those terms: recovery requires
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

**AMENDED 2026-09-02 — on `POST /v1/enrol/token` the limit is per-source *concurrency*, and that is
a MUST rather than a preference.** The delay already paces one caller to one token per interval
(`API-33`), so a request-rate limit tight enough to matter would refuse the second honest signup
from a shared address while costing a distributed attacker nothing; what is scarce there is held
connections, and bounding those is the control (`WIR-49`). It is in memory and unpersisted like
every other limiter here, so `ADR-0005` is untouched, and **the per-source concurrency limit is a
deployment parameter on the register (`OVR-19`)** — `API-41`'s global ceiling is defensible only
because this one exists.

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

**"Used for nothing except `API-56`" is a restriction the server MUST enforce, not an expectation
of the caller: the recovery credential authenticates the revocation route and nothing else.** A
request presenting it anywhere else — a create, an install, a delete, a read — MUST be rejected as
unauthenticated, exactly as an unknown secret would be, and it MUST NOT be accepted as a spending
token by any path. `API-56` states the prohibition in one direction only, that the spending token
cannot revoke; left unstated in the other, the stronger secret silently authorizes everything the
weaker one does, and the separation this requirement exists to create is gone the first moment the
everyday agent has a reason to hold it.

**API-56** **The recovery credential MAY revoke the spending token and obtain a fresh one; the
spending token MUST NOT be able to do either.** A revocation invalidates the current token
immediately, issues a replacement in the same response, and leaves the tenant, its machines, its
balance and its commitments untouched. **Rotation authorized by the token itself is not
sufficient and MUST NOT be offered**: a thief holding the token would rotate first and lock the
owner out permanently, converting credential theft into total loss of the tenant.

Revocation MUST be **serialized per tenant** (`LDG-35`'s primitive), so two concurrent revocations
under different keys cannot interleave into a state where neither replacement is the live one.
**Serialization alone does not hand both callers a working token, and MUST NOT be described as if
it did**: ordering two revocations means the second invalidates the token the first had just
minted, so a delayed first response delivers a token that is already dead.

**The generation number is what makes that detectable.** Each replacement MUST carry one — the
tenant's `credential_generation`, incremented by every revocation (`05-persistence.md`) — and it
MUST be returned to the caller in the revocation response (`WIR-38`). **A caller whose replacement
token carries a generation lower than one it has since seen for that tenant MUST treat its token as
dead and re-revoke with the recovery credential**, rather than assume the token works — a token
that came from enrolment (`WIR-12`) is at the tenant's initial generation, so any revocation
supersedes it. The generation also stops a token minted by an earlier revocation from being
resurrected by a replay of that earlier call.

Revocation MUST carry an idempotency key and MUST replace the token **at most once per key**
(`STO-35`) — a replay returns `409` with `details.reason: "credential_already_replaced"` rather
than re-returning the new token, because storing a replayable body would mean persisting a live
bearer secret. This is a deliberate narrowing of `API-8`'s replay contract, and it is safe
precisely because the recovery credential can always mint another replacement. **AMENDED
2026-09-02: revocation is reachable while a tenant is `pending`, without qualification.** *The
withdrawn sentence made it unreachable "before `issuable_at` — that window has no credential worth
replacing", and `API-33` has since withdrawn `issuable_at`: there is no such window, and the token
is worth replacing from the instant it is transmitted.*

**API-57** **A tenant MUST be assigned at least one provider account, automatically, in the same
transaction that activates it — where at least one assignable account is `healthy` (`STO-36`,
`STO-47`). Where none is, activation MUST proceed with no assignment, MUST emit a monitorable
event naming the tenant (`SEC-32`), and the deployment MUST assign it by this same policy,
automatically, once an assignable account is `healthy` — **by a durable pass over active tenants
lacking a healthy assignment, run on every `OPS-32` sweep pass and woken early by `API-63`
recording `healthy` or by configuration adding an account** — so the tenant is neither `API-34`'s
to reap nor left for an operator to remember (`API-62` remains the override).** *State-driven
rather than event-driven (2026-09-05): an event with no durable work behind it is lost to a crash
between the recording and the assignment, and the tenant it was for stays active and unusable
forever.* *The automatic retry was added
2026-09-05: an audit event is not a placement queue, and a paid tenant that stays active and
unusable until a human notices is the stranding this clause exists to prevent, by another route.* *The conditional was added 2026-09-05. Read unconditionally against `STO-36`'s refusal of an
unhealthy account, activation was unsatisfiable whenever every assignable account was down, the
tenant stayed `pending` holding money above the minimum, and `API-34` reaped it into `LDG-43` — a
paying customer lost to the interaction of two rules each correct alone.* `API-17b` requires an
explicit assignment and the provider views
return only assigned accounts (`WIR-29`, `WIR-30`) — but **nothing produced one**, so a literal
build gave every enrolled customer an empty provider list forever, on the product's only revenue
path. Both reviewers found it independently.

Assignment MUST follow a stated configured policy over the accounts flagged assignable, MUST
distribute tenants across accounts rather than filling one (`SEC-43`), and MUST be recorded
durably (`STO-34`). **It cannot be an operator step**: `ADR-0002` chose self-serve enrolment, and
an agent enrolling at 3am has no human to wait for.

**API-58** **A funded tenant MUST be suspended, never deleted.** Suspension is an operator action
that (1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**,
so no further **tenant-authorized** write succeeds —
the maintenance actions of `API-7` step 2 remain reachable, because a suspended owner must still be
able to revoke a stolen credential (`API-56`, `CNF-209`), and an operator may retry a stalled
episode (`API-64`), which skips step 5b like every operator verb (`API-7`) — then (2)
**fences work already in flight** — a create claimed before the suspension landed MUST be allowed
to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep,
because abandoning an in-flight order is how a machine ends up bought, unrecorded and unbilled —
then (3) enqueues a system cancellation per machine (`OPS-39`) — then (4) **transitions the tenant's own work — `requested_by: caller`, never a system
cancellation — that is already
`queued` but never claimed straight to `failed`, carrying the reason in the operation's `error`:
`conflict`, with `details.reason: "tenant_suspended"`** (`WIR-9a`, `WIR-10b`) — it
has touched no provider, so cancelling it needs no operation, and it does **not** carry the error
kind `suspended`, which `OPS-11` classifies as admission-only and forbids a worker to emit: that
kind stays an admission-time rejection of a *caller's* write (`DOM-20`).
**Its `requested_by` stays `caller` and its `system_reason` stays null**, because `WIR-10` permits
a non-null `system_reason` only on `requested_by: system`, and re-labelling the request `system`
to make room for one would attribute the caller's own create to the system and destroy the record
of who asked for it. The reason belongs in the error, which is where a caller reads why its work
did not run. *`system_reason: tenant_suspended` was the withdrawn form and it produced an
operation view no strict parser should accept.* The value stays legal on the step-(3)
cancellations, which the system really did request (`OPS-39`). This transition is also **not** a
worker classification: nothing was claimed and no driver was called, so `OPS-11`'s install row —
which sends `conflict` to `needs_reconciliation` — does not reach it, and the operation goes
straight to `failed` as stated. **Not being a classification does not exempt the database write**:
it is `STO-3`'s fifth named case (fourth until the defer was listed on 2026-09-12), guarded on its full predicate — `(id, status = queued,
requested_by = caller, tenant suspended, this suspension's parent still unsettled)`, quoted rather
than paraphrased since 2026-09-05, when a paraphrase here dropped the `requested_by` term and let
step (4) fail the system delete step (3) had just named — and reporting whether it affected a row, so a child claimed
by a real worker in the meantime loses this race and settles through that worker instead. The fan-out then lets anything
already `running` settle, **then re-sweeps: a create that
settled after the fan-out has produced a machine the first pass never saw, and it MUST be
cancelled by a second pass rather than left running against a suspended tenant** — the fan-out
repeats until a pass finds no un-cancelled machine; then (5) aggregates the outcomes,
including any that end `needs_reconciliation`. **The parent then settles `succeeded`, with those
children named in its result** (`WIR-39`'s `cancellations`) — its own job was to fan out and
account for every machine, and it has done it. `OPS-11`'s `suspend_tenant` row already counts a
`needs_reconciliation` child as complete for the parent, and step (5) did not say what that makes
the parent's own outcome; it is `succeeded`, never `failed` and never `needs_reconciliation`. The
unresolved children are their own records, resolved by their own evidence or their own operator
verb (`OPS-27`, `OPS-31`), and read through `GET /v1/operations` like any other operation. Holding
the parent open until they resolve would fence `WIR-41`'s resume off indefinitely and leave every
suspended tenant with a record that never closes.
**A create that has produced no machine yet passes the re-sweep's test**, so settlement here is not
the last guard: where such a create later attaches a machine to a still-suspended tenant, `OPS-27`'s
one-transaction rule enqueues the cancellation in the attach transaction itself, under the same
`OPS-39` trigger step (3) uses. **A process that dies mid-fan-out MUST NOT strand
the suspension**: the engine's startup pass (`OPS-15`) returns an interrupted `suspend_tenant`
parent to `queued`, and it is re-claimed and resumed like any other queued work, because the sweep
is idempotent by the open episode (`STO-52`'s index) and mutates no provider itself. It MUST NOT go
to `needs_reconciliation` and, on a restart, MUST NOT need an operator — *after a restore it waits
for one (`STO-54`, `OPS-15`), because the fan-out it would resume may have been reversed inside the
lost interval*. Reads of the ledger, the machine list **and the tenant's abuse
cases** (`API-59`) MUST continue
to work while suspended — the customer's history is their evidence, and `LDG-22` forbids purging
it anyway. *The case reads joined this list on 2026-08-16 for the same reason and one more: the
collection exists because a notice commonly arrives after the machine is gone, and a suspended
tenant is the likeliest holder of exactly that case.* `SEC-45`'s one-action termination is this verb; `API-34`'s deletion applies only to
**pending** tenants, which have no machines. They MAY hold a below-minimum credit, whose ledger
entries survive them (`STO-26`, `LDG-22`) and remain re-attributable through `WIR-42` — so
"no ledger" was wrong, and it is the case `API-34` exists to handle.

**AMENDED 2026-09-02 — "un-cancelled" is defined, and a deterministically-failed child no longer
hangs the fan-out.** The re-sweep's terminating condition was never defined, and the two readings a
builder could reach were both wrong. **A machine is *cancelled* for the purpose of step (4) when this suspension has already accounted
for it** — the fan-out enqueued a cancellation for it, whatever that cancellation then did —
**and *un-cancelled* otherwise.** The parent records the machines it has enqueued for, in
`WIR-39`'s `cancellations` result; the pass enqueues for every non-tombstoned machine of the tenant
that is not already named there, and terminates when a pass finds none. **Where `OPS-39`'s episode
is already open on a machine under the `delete` key** — an exhaustion episode that predates the
suspension, or the machine `OPS-27`'s suspended-attach clause enqueued for — the pass MUST NOT
enqueue, and MUST instead **append `tenant_suspended` to that episode's `reasons` set (`DOM-31`)
and name its `current_operation_id` in `cancellations`**, which is what "accounted for" means for
it. *Added
2026-09-05. Without this the pass could neither enqueue for such a machine — `OPS-39` forbids the
duplicate — nor name it, so every pass found it un-cancelled, the parent never settled, `WIR-41`'s
resume was refused forever and a worker slot was pinned for the life of the tenant.* **An operation
that `OPS-41`'s no-mutation abort settled does NOT account for its machine**, whatever list names
it: the abort closed the episode (`OPS-48`), so the next pass opens a fresh one and enqueues afresh
— **and replaces the aborted operation's id in `cancellations` with the fresh one's**, so the
per-machine result always names the child currently accounting for the machine rather than one
that settled without acting — which `STO-52`'s index permits precisely because the episode is
closed. *Added 2026-09-05 against the interleaving where the worker's re-check reads the episode
before the join appends `tenant_suspended`, finds the machine funded after a price cut, and aborts
— after which a pass that trusted the name would settle the parent over a funded fleet on a
suspended tenant.*

*The test is the parent's own record, not the episode row.* An earlier draft of this
amendment keyed it on an episode existing "open or already resolved", which fails in both
directions: `OPS-48` **closes** the episode on `abandoned` and clears the fence, so an operator's
`abandoned` made a machine read un-cancelled again and the fan-out re-enqueued against it; and an
episode opened by an *exhaustion* sweep before the suspension would have made a machine read
cancelled that this suspension never touched. The parent's list is the thing that actually answers
"has this fan-out dealt with that machine", and it is already returned to the operator.

*Why the entry and not the outcome.* Keyed on the outcome, a child that fails deterministically —
`authentication` after a credential rotation, `unsupported` on an account that never declared
`delete_machine` — leaves its machine un-cancelled forever, while `OPS-39` forbids the next pass
enqueuing a second delete under the same open episode. The fan-out then cannot terminate and cannot
progress: the parent never settles, `WIR-41`'s resume is fenced indefinitely, and a worker slot is
pinned. Keyed on the entry, the pass terminates because the machine has been **accounted for**,
which is what the parent's job actually is.

**What that costs, stated rather than hidden: the parent settles `succeeded` while a machine of a
suspended tenant may still be running.** Three things bound it and all three are required. The
child's failure is a record of its own, named in the parent's result (`WIR-39`'s `cancellations`)
and readable through `GET /v1/operations`. A `failed` attempt moves its episode to `stalled`
(`OPS-48`), which `OPS-26`'s listing **surfaces to the operator** beside `uncertain`, and the
recovery is `API-64`'s retry on the same episode — which `API-7` skips step 5b for, so a suspended
tenant's stalled episode stays retryable. *Until 2026-09-05 this sentence continued "and the
machine keeps consuming its commitment, so `LDG-13`'s exhaustion path reaches it on the ordinary
schedule whether or not anyone looks" — which `OPS-48` forbids: the episode stays open, the sweep
enqueues nothing against an open episode, and the operator listing and retry are the only
recovery. `CNF-272` carried the same false clause and was corrected the day before; this copy was
not.* **A
suspension is not a promise that the fleet is gone; it is a promise that every machine has been
accounted for and that nothing further can be bought.** The terms and the operator documentation
MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.

**AMENDED 2026-08-31 — the flag lands at admission, not in the worker.** The withdrawn wording
said "the suspension flag and the full fan-out MUST commit together", which on a `202`-returning
endpoint (`WIR-39`) puts the flag in a *worker's* transaction. `API-7` step 5b reads
`tenants.status`, so until a worker claimed the parent the tenant was not suspended and its writes
were admitted — and `OPS-6` claims oldest-first, so its own queued work runs ahead of the suspension
that was meant to stop it. `SEC-45` calls this "one operator action" and sells it as immediate; on a
busy queue it was not effective on return.

The crash-safety the withdrawn clause was protecting is supplied elsewhere and better: the startup
pass (`OPS-15`) returns an interrupted `suspend_tenant` parent to `queued` rather than to
`needs_reconciliation`, and the open episode (`STO-52`) makes the re-sweep idempotent, so a crash
mid-fan-out strands nothing. **The flag and the enqueue of the parent commit together at admission;
the fan-out is the worker's.**

**Because the fan-out re-sweeps, resume MUST NOT be accepted while this parent is unsettled**
(`WIR-41`): a machine created after an early resume is exactly what the re-sweep is built to find,
and it would be cancelled by a suspension the operator already lifted. The parent's state is the
fence, and the refusal is a `conflict` naming the running suspension.

**API-40** Enrolment and every other write MUST be reachable under the general rules, and three
of those rules do not fit an unauthenticated, pre-tenant request. They are resolved here rather
than left as exceptions a builder must invent.

**AMENDED 2026-09-02 — `POST /v1/enrol/token` is governed by this requirement too.** It is the
second pre-tenant route and it was added without being brought here, while `API-48` and `API-49`
were both amended for it the same day — so its exemptions existed only inside `WIR-49`, in the
document that describes bodies rather than the one that reconciles the rules. Every bullet below
applies to it, with one addition: **it creates nothing**, so `API-1` exempts it as it exempts
enrolment, and there is not even a handle to return.

- **`API-7` (authenticate before validating)** — enrolment is unauthenticated by definition
  (`API-32`); there is no tenant yet. `API-7`'s ordering applies to authenticated endpoints, and
  enrolment's own defences are `API-33`'s admission token, `API-36`'s rate limit and `API-41`'s
  global ceiling. **The admission token MUST be checked before any other validation of the body**,
  which is `API-7`'s ordering argument reaching the one route that has no principal to authenticate:
  an unadmitted caller MUST NOT be able to make the server do policy work either.

  **The order resolves a conflict between two MUSTs, so it is stated as a precedence.** `WIR-2`
  requires an unknown body field to be rejected **naming the first one**; `WIR-12` requires a bad
  admission token to be refused **without saying which of absent, expired, unknown or spent it was**.
  A body carrying both a bad token and an unknown field satisfies one and violates the other
  whichever way a handler goes. **The token check wins**: the response is `invalid_request` naming no
  field and giving no token detail. Enrolment is the one route where naming a field is a free
  oracle handed to an unadmitted stranger, and `WIR-2`'s naming rule exists for interoperability with
  callers that got in — which this one has not.
- **`API-1` (every accepted write returns `202` and an operation)** — enrolment is exempt and
  returns its handle directly. It creates no provider mutation, so it needs no durable operation,
  and `operations.tenant_id` could not name a tenant that does not exist yet.
- **`API-8`/`API-10` (idempotency scoped to `(principal, key)`)** — **AMENDED: enrolment carries no
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
4. **`POST /v1/recovery/revoke`** (`API-56`). **AMENDED 2026-09-02 — unconditionally, with the
   `issuable_at` qualifier withdrawn.** The withdrawn wording allowed it "only at or after
   `issuable_at`", on the reasoning that before that instant there was no usable credential to
   replace; `API-33` has since withdrawn the instant itself, and the token is live from the moment
   enrolment returns it. A pending tenant's token can be stolen exactly like an active one's, and
   refusing revocation would leave the owner watching a thief spend a balance they funded.

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

**API-48** **AMENDED 2026-09-08 — one list, no amendment trail.** **The synchronous endpoints are
exactly these**, and they are the closed set of exemptions from `API-1`'s "every accepted write
returns `202` and an operation" — the set `OVR-4` names as the closed set of synchronous writes:

1. every `GET`;
2. `POST /v1/enrol/token` (`WIR-49`) — writes nothing; the only member that is deliberately *slow*;
3. `POST /v1/enrol` (`WIR-12`) — `operations.tenant_id` cannot name a tenant that does not exist yet;
4. `POST /v1/deposits` (`WIR-14`);
5. `POST /v1/deposits/{id}/actions/attribute` (`WIR-42`);
6. `POST /v1/abuse-cases` (`WIR-44`);
7. `POST /v1/abuse-cases/{id}/actions/close` (`WIR-44`);
8. `POST /v1/abuse-cases/{id}/actions/record-transmission` (`WIR-44`);
9. `POST /v1/abuse-cases/{id}/actions/revise-deadline` (`WIR-47`);
10. `POST /v1/abuse-cases/{id}/statements` (`WIR-43`);
11. `POST /v1/machines/{id}/actions/record-network-restriction` (`WIR-47`);
12. `POST /v1/machines/{id}/actions/extend-runway` (`WIR-24`);
13. `POST /v1/provider-accounts/{account}/actions/record-status` (`WIR-50`) — it moves customer
    money on a confirmed termination (`SEC-46`) and still mints no operation: the machines are
    already gone, the commitments table is itself a durable record, `WIR-50` returns the count and
    the affected tenants, and `SEC-39` requires a monitorable event;
14. `POST /v1/tenants/{tenant_id}/actions/assign-provider-account` (`WIR-48`);
15. `POST /v1/tenants/{tenant_id}/actions/resume` (`WIR-41`);
16. `POST /v1/recovery/revoke` (`WIR-38`);
17. `POST /v1/operations/{id}/actions/resolve` (`WIR-35`) — minting an operation *about* an
    operation is a recursion `API-1` never intended;
18. `POST /v1/episodes/{id}/actions/retry` (`API-64`, `WIR-51`) — it answers `200` with the episode
    view; the attempt it enqueues is the asynchronous part, visible through `current_operation_id`;
19. `POST /v1/machines/{id}/attachments/{attachment_id}/actions/release` on a row whose `cleanup`
    is `manual` (`API-65`, `WIR-52`) — it records that an operator did by hand what no driver can
    do, and there is no provider write to be asynchronous about; on an `api` row the same route
    is an ordinary `202`.
20. `POST /v1/provider-accounts/{account}/actions/record-billing` (`API-66`, `WIR-53`; added
    2026-10-04, `pv-gip.39`).

Every member has the same justification: **none of them is itself a provider mutation**, so none
needs a durable operation of its own. Any endpoint added later that *does* touch a provider MUST
obey `API-1`; this list is closed, not a pattern, and an endpoint joins it by being written here.
**Suspension (`WIR-39`) is not on it**: it cancels a fleet, so it returns `202` with a
`suspend_tenant` operation whose children are the per-machine cancellations.

**API-46** Funding MUST be rate-limited per tenant. Each request creates an address the operator
must watch until expiry (`LDG-57`) and a binding it retains afterwards (`STO-29`), so an unlimited
funding endpoint lets an unauthenticated-adjacent caller mint monitoring work at no cost. **The
expiry bounds the damage and the rate limit bounds the rate**; neither alone is sufficient,
because `API-34`'s time-to-live deletes a pending tenant while its deposits outlive it.

**API-41** Enrolment MUST be sheddable under load ahead of every other endpoint, and a deployment
MUST set a **global** ceiling on pending tenants, not only a per-caller rate limit. `API-36`'s
limiter holds its state in memory per `api` replica, so it resets on every restart, counts each
replica separately, and is trivially defeated by distributed sources. The damage is not row count: the
time-to-live sweep of `API-34` is a large periodic delete against the same single-writer store
that serves the operation queue's atomic claim (`STO-1`, `STO-6`), and `DEF-11` records that this
store has already been starved once by a needless periodic write loop. **Enrolment at line rate
becomes a write-lock generator that stalls machine creation and commitment re-derivation.**

**AMENDED 2026-09-02 — the ceiling stands, and it stands only because `API-33`'s admission gate now
stands in front of it.** `API-33` calls this ceiling "itself the denial of service", and against a
free `POST /v1/enrol` it was: an attacker filled every slot, refilled as they expired, and shut the
only door from stranger to customer at no cost. That reading is now historical rather than current.
A slot costs a held connection (`API-33`, `WIR-49`), which is bounded and per-source limitable, so
the ceiling bounds the store's write amplification without handing anyone a free lockout.

Two things follow, and both are requirements rather than commentary. **The ceiling MUST be a
shedding threshold, not a permanent refusal**: at the ceiling, `POST /v1/enrol` is refused
`rate_limited` with a `retry_after_ms` (`WIR-9a`) — never a bare failure — so a legitimate caller is
told to come back rather than told, indistinguishably, that the product is closed. And **the
deployment MUST choose the ceiling against `API-34`'s time-to-live**, since the pair is what caps
the table at *enrolment rate × TTL*; a ceiling below the number of signups a normal day produces
inside one TTL is a self-inflicted outage, and that arithmetic MUST be stated with the figure on
the register (`OVR-19`).

## Idempotency

**API-8** Every write request MUST carry a caller-generated idempotency key header.

**API-9** The key MUST be 8–200 characters of ASCII letters, digits, `.`, `_`, `:`, or
`-`.

**API-10** Idempotency MUST be scoped to `(principal, key)` — the tenant for a tenant credential,
the operator identity for an operator credential — which is what `STO-35`'s `(scope_kind, scope_id,
key)` already stores. A key collision across principals MUST NOT be observable by either — not as a
conflict, not as a shared operation, and not as an internal error. *"Scoped to `(tenant, key)`"
until 2026-09-05, while every operator write carries the key and an operator is no tenant at all —
so a builder had to invent a synthetic tenant, pick an arbitrary affected one, or make operator keys
global, and for `record-status`, which touches many tenants, there was no defensible choice. The
store had the right shape and the prose did not.*

**API-11** Re-sending the same key with a byte-equivalent request MUST return the
existing operation. Re-sending it with a different request MUST fail `409 Conflict` and
MUST NOT create a second operation.

**API-12** Equivalence MUST be computed over a canonical serialization of the stored and
incoming requests, not over raw request bytes, so that key ordering and whitespace do not
produce spurious conflicts.

**API-38** **Equivalence after the payload is purged.** `ADR-0005` purges the stored request once the
operation stops being live, so for a completed operation there is nothing left to compare against and
`API-11`/`API-12` become unexecutable — `CNF-21` tests a comparison that cannot
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
| SSH public keys | at most 64, each ≤16 KiB, each recognizably an OpenSSH public key |
| expected rescue host keys | at most 16, each a complete OpenSSH public host key |
| catalog image | 1–256 characters |
| user data / post-install script | ≤1 MiB |
| provider options | MUST be a JSON object |
| image URL | ≤8192 bytes, no fragment, no embedded credentials, scheme `https` (or `http` only where explicitly enabled), host in the allowlist. **For a `provider_catalogue` install the allowlist is mandatory and an empty one refuses the request** (`SEC-19`, `RSC-39`), since provisiond itself is the client there; on the rescue strategies an empty list still means any host and is a startup warning. *"When one is configured" applied the fail-open reading to both paths and was withdrawn 2026-09-02* |
| digest | exactly 64 hex characters (`DOM-14`) |
| strategy/image pairing | per `DOM-13` |
| host-key policy | pinned keys and "accept unpinned" MUST be mutually exclusive |
| request body size | globally capped (2 MiB is a reasonable default) |

**API-14** An install request MUST carry an explicit destructive acknowledgement, and a
delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
is not satisfied by authentication, by idempotency, or by having sent one previously.

**API-15** A create request against an order-billed provider MUST carry an explicit
purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*

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
  configured ones" (`API-57` writes it, `API-62` changes it, `SEC-43` is why it is also the
  blast-radius control); and
- **that tenant's spending authority, which is its prepaid balance and nothing else** — the
  `available ≥ required_commitment` check of `LDG-9`, serialized per tenant by `LDG-35`, in the same
  transaction that opens the commitment (`LDG-11`).

Absent both, any tenant can order unbounded billable hardware in any configured account, and no
other requirement in this document stops it.

*The second bullet offered a choice of three — "a ceiling per interval, a prepaid balance, or an
operator approval step" — until 2026-09-02. `ADR-0002` made that choice and rejected the other two
by name, so the paragraph was reading as open while the whole of `12-billing-and-ledger.md` was
written on the answer. Deleted rather than annotated, per the README's retention rule: no trap sits
behind a settled option list. `SEC-39`'s per-principal ceilings still exist and are still required —
they bound what a looping agent can **destroy**, which is a different question from what it may
**buy**, and conflating the two is what let this sentence survive.*

*`API-18` — adoption as an operator-only verb with entitlement by an operator-maintained assignment
— is withdrawn with adopt (`ADR-0020`). Its history is kept because the trap is real: the first
form let any tenant adopt any machine it could name (`DEF-1`), the 2026-08-12 amendment made the
verb operator-only after `F28` found two of three entitlement mechanisms required an operator step
the self-serve product had deleted, and on 2026-09-08 the verb went because no launch driver can
price a machine it did not buy. When adopt returns it returns operator-only, with entitlement by
assignment, and synchronous.*

**API-64** **ADDED 2026-09-08 (`ADR-0017`) — a stalled episode is retried by an operator, and by
nothing else.** `POST /v1/episodes/{id}/actions/retry` (`WIR-51`) is **operator-only** (`WIR-34`)
and is admissible only on an episode in `stalled` (`DOM-31`): it moves the episode to `attempting`
**by a conditional write guarded on `(id, state = stalled)`** and enqueues a fresh `delete_machine`
attempt under it, both in one transaction, and answers `200`
with the episode view. In any other state — including where that write affects no row because a
gone-write closed the episode after the operator read it (`OPS-48`, `ADR-0021`) — it is refused
`409` `conflict` with `details.reason: "state"`. It is idempotent under `WIR-24`'s one-transaction rule — the state change, the enqueue and
the idempotency record commit together — and it counts against `SEC-39`'s operator retry ceiling
(`API-7` step 5c). **A `stalled` episode is never retried by a timer** (`OPS-48`): the attempt
settled `failed` because the provider rejected it and did not act, and repeating a deterministic
rejection automatically is the loop `OPS-39` exists to prevent. A throttled attempt reaches
`stalled` too, for a different reason: `rate_limited` is on neither of `OPS-11`'s ambiguity lists,
so a throttled delete is `failed`, and nothing in this set returns it to `queued` (`F48`). The
episode, not the `failed` attempt row, is what
outlives `STO-14`'s retention, which is why the verb is on the episode (`ADR-0017`).

**API-65** **ADDED 2026-09-08 — the operator's half of `PRV-45`, which had no route.**
`GET /v1/machines/{id}/attachments` (`WIR-52`) is **operator-only** (`WIR-34`) and lists the
machine's `machine_attachments` rows. `POST /v1/machines/{id}/attachments/{attachment_id}/actions/release`
(`WIR-52`) is **operator-only** and admissible only on a row whose `released_at` is null; otherwise
it is refused `409` `conflict` with `details.reason: "state"`. On a row whose `cleanup` is `api` it
enqueues one `release_attachment` operation with `requested_by: operator` and answers `202` with
the operation view — the same kind, and the same driver call, the delete's terminal transaction
enqueues on its own. On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation, and is in `API-48`'s
list for that reason. A release the delete's terminal transaction enqueues carries the delete's own
`requested_by` and `system_reason`, so `WIR-10a`'s set gains no member for it. The `202` form is
idempotent as any operation is (`API-11`); the `200` form, returning no operation, commits the
`released_at` write and its idempotency record together under `WIR-24`'s one-transaction rule.
For the release's exit write, see `LDG-38`.
Either is what opens `STO-18`'s tombstone gate, and `LDG-74` is where the tombstone then happens.

## Operation views

**API-20** **AMENDED 2026-09-08 (`ADR-0017`) — the view names its episode.** The operation view
returned to clients MUST include: id, tenant, idempotency key, kind, status, machine id, provider
account, result, error, timestamps, `revision` (`API-53`), `retryable` (`API-51`),
`requested_by` with its `system_reason` when system-initiated (`OPS-39`), and `episode_id` — the
episode this operation is an attempt under (`DOM-31`), null otherwise. For a non-terminal
operation the view carries `poll_after_ms` (`API-49`). *An "attempt count" left the list on
2026-09-12 (`ADR-0022`): the column counted claims, not attempts, and a deferral count is nothing
a caller can act on — `revision` arbitrates polls and `retryable` says what to do.*

**API-21** The operation view MUST NOT include the stored request payload. It can contain
signed image URLs and other caller secrets that need not be echoed back.

**API-22** Result and error payloads MUST be redacted (`DOM-6`, `DOM-18`) before they are
stored, not merely before they are rendered.

**API-23** `GET /v1/operations` MUST support filtering by status and MUST support
pagination. Listing everything in `needs_reconciliation` is an operational necessity
(`OPS-26`). **AMENDED 2026-09-02: it MUST also filter on `requested_by` and `system_reason`**
(`WIR-10a`, `WIR-26`), so an episode's attempt history is findable without reading every caller
typo alongside it. The open episodes `OPS-26` requires listed are `WIR-51`'s `GET /v1/episodes`,
not a filter here (`ADR-0017`).

## Errors

A single envelope for every failure:

```json
{
  "error": {
    "kind": "invalid_request",
    "message": "human readable, safe to show an operator",
    "retryable": false,
    "details": {}
  },
  "correlation_id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11"
}
```

`correlation_id` is part of the envelope, not an optional extra: `WIR-4` requires it be readable
from the **body**, because an intermediary can strip the header. `WIR-9` is the authoritative
shape (`13-wire-contract.md`); it sits beside `error`, not inside it, because the inner object is
what `WIR-10b` embeds in an operation view, which carries its own.

**API-24** `kind` MUST come from the closed set in `DOM-17`, and the HTTP status MUST be
derived from it by the mapping in that table. Handlers MUST NOT choose statuses
independently.

**API-25** `message` MUST NOT contain a credential, a private key, a signed URL, or an
unredacted provider response.

## Listing and pagination

**API-26** `GET /v1/machines` MUST be tenant-scoped, MUST clamp any caller-supplied limit
to a sane range, and SHOULD offer a cursor rather than an offset.

## Transport

**API-27** **AMENDED — collapsed to the single-component form settled by `ADR-0001`.** The
public surface is reachable by customers by definition, so the deployment MUST:

- terminate TLS such that no credential traverses an untrusted hop in clear text;
- expose *only* the customer-facing routes publicly, keeping operator and reconciliation routes
  on a separate listener or network (`WIR-34` lists them);
- treat `OVR-10a`'s in-code credential boundary as the compensating control, since network
  isolation is no longer providing one.

*The withdrawn branch said the lifecycle API MUST be reachable only over a private network in
the separate-service form. "Private network" is not a property this specification can assume
once the customer is the caller, and `ADR-0001` means it never can.*

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

**Exception (`API-33`):** neither enrolment route may carry a delay-derived `Retry-After` — on
those the pacing hint is the timing oracle `API-33` forbids. Absent, or a constant unrelated to any
remaining delay. This covers the handle poll, whose remaining time is `API-34`'s time-to-live, and
`POST /v1/enrol/token`, which answers *after* its delay rather than advertising it.

**API-50** **A caller that obeys every `Retry-After` it receives MUST never receive `429` for
*throughput*.** This
is the rate-limit contract stated as a relationship rather than a number, because any number is
wrong after the fleet grows.

**AMENDED 2026-09-02 — the promise is about pacing, and two `429`s are not about pacing at all.**
Read unconditionally it is now false three ways, and each of the three is a control the set
deliberately added: `ceiling_exceeded` (`SEC-39`, `DOM-17`) refuses a principal that has spent its
allowance for the interval, and no amount of obedient pacing earns it back; `API-41` sheds enrolment
at the global pending-tenant ceiling; and `WIR-49`'s per-source concurrency limit refuses a caller
holding too many token requests open. **The last two arrive on a caller's very first request, where
no `Retry-After` has ever been issued and the promise cannot even be evaluated.**

The contract therefore splits, and both halves are testable. **A caller obeying every `Retry-After`
MUST never be throttled for rate** — that is `CNF-152`, unchanged. **A `429` that is not about rate
MUST say so in its `kind`**: `ceiling_exceeded` for an exhausted allowance, `rate_limited` for
everything else, and the agent's recovery differs (`DOM-20`'s argument). A replica that cannot
obtain a store connection is not a `429` at all: it refuses `overloaded`, 503, before any
transaction (`STO-55`, added 2026-09-12), because a full pool is the replica's capacity and not the
caller's rate. *An unconditional promise
that three shipped controls break is worse than a narrower one that holds: a caller written against
it treats any `429` as a bug in the server, and the natural response to a bug in the server is to
retry harder.* Read limits MUST be budgeted separately from write limits and MUST
admit, at minimum, one non-terminal list poll plus one balance poll plus one machines poll at the
finest advertised cadence. Every `429` anywhere MUST itself carry `Retry-After`, and a `429` on a
read carries **no information about any operation's outcome** — an autonomous caller MUST NOT
treat a throttled poll as a failed operation, and **a read being rate-limited MUST never become
the reason a caller re-issues a write** (the `CNF-150` pathology: when the read path is closed,
an agent discovers state by mutating).

**API-51** **`retryable` is normative for callers, not advisory to operators.** An operation in
`needs_reconciliation` MUST be delivered with `retryable: false`, and the contract MUST state in
words that re-issuing the request under a fresh idempotency key **is a fresh operation**, not a
retry — on a create, **a second purchase**; on an install, a second destructive write while the
first's outcome is unresolved (*scoped 2026-09-15, `pv-x8r`; it read as if every kind bought
something*). `OPS-12` forbids the *system* from retrying an ambiguous mutation, but nothing else stops
the *customer's* agent from buying the duplicate server `OPS-27` exists to prevent — `SEC-39`'s
per-principal ceiling is the backstop, and this
field is the signal. This is the single most expensive way for "finding out" to go wrong.

**API-52** **A pending tenant MUST be able to observe its own activation without attempting a
purchase.** `API-43` owns the reachable-while-pending set and this requirement does not restate
it. Whatever else that set contains, `GET /v1/balance` is not in it and answers `not_activated` —
so a freshly enrolled agent that has already paid
could learn it was active only by issuing a create and reading the rejection, which is the exact
pathology `API-47` was written out of the post-activation path. `GET /v1/enrol/{handle}` MUST
answer with the tenant's current status (`pending` | `active` | `suspended`, `WIR-13`), and
`API-43` lists it for exactly this reason.

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

## Abuse cases

`DOM-23`'s entity on the wire. `ADR-0012` is why every field here is the operator's own writing
rather than the provider's.

**API-59** **A tenant's abuse cases MUST be readable from both the machine view and a tenant-wide
collection**, and every path MUST render one case projection defined once. `LDG-15`'s reasoning
applies unchanged — *"a caller that is software will act on a number long before it would act on an
email, and there is no email"* — and the collection exists because the common case is a notice
arriving after the machine was deleted, where a tenant that no longer polls that machine would
never find it. Three renderings and one projection: a wire rule enforced on one path and forgotten
on another is how `WIR-45`'s ban would fail in practice, and the detail read — the one that adds
statements — is the path most likely to be forgotten.

**API-60** **Creating, closing, and recording transmission of a case are operator-only writes**,
and none of them mints an operation (`API-48`). A case is not created from a caller request and
not from a driver (`DOM-23`); the operator supplies the machine — or an address and an instant for
`SEC-54` to resolve — the summary, the `warned_consequence` and the tenant-facing deadline.

**API-61** **Recording a network restriction and revising a deadline are operator-only writes**
(`WIR-47`), synchronous, minting no operation (`API-48`). Neither is a caller action: a customer
cannot tell the system its machine was blocked, and cannot grant itself more time.

**API-62** **A tenant's provider-account assignment MUST be changeable by an operator.** `API-57`
writes it automatically — in the activation transaction where a healthy account exists, and by its
reconciling pass afterwards where none did — and nothing could change it
afterwards — while `SEC-46` models the provider confirming an account is terminated and closes the
tenant's commitments. The tenant is then assigned to a dead account, `WIR-29` returns it nothing it
can buy from, and it holds a balance `ADR-0004` forbids refunding. **On a non-refundable product,
"cannot buy anything" and "lost their money" are the same outcome**, and account termination is the
one modelled catastrophe with no route back.

The verb is **operator-only** and synchronous, mints no operation (`API-48`), writes
`tenant_provider_accounts` and bumps its `policy_version` (`STO-36`). It MUST NOT be a customer
action: a tenant choosing its own account would contradict `DOM-3`, and the assignment is
simultaneously `SEC-43`'s blast-radius control, so it stays where that control does.

**`SEC-46`'s confirmed-termination path MUST surface the affected tenants** rather than leaving the
operator to find them, and **every use of this verb MUST emit a monitorable event** naming the
principal, the tenant, the accounts before and after, and the reason — because this surface is
expected to be driven semi-automatically by an internal agent (`SEC-39` as amended for operator
principals), and an automated re-assignment nobody can observe is one nobody can stop.

*Where that surfacing happens was unstated until 2026-09-02, and "MUST surface" with no surface is
not a requirement.* `API-63`'s `record-status` is the call that confirms a termination, and it
returns both tenant lists in its own response (`WIR-50`'s `affected_tenants` and `assigned_tenants`)
— the operator learns who is stranded from the act that strands them, rather than by remembering to
look.

*Automatic re-assignment on account loss was rejected: it moves every affected tenant at once,
precisely when the surviving accounts are least able to absorb them, and `SEC-43` exists to prevent
concentration. It also removes the operator's ability to hold back the tenant that caused the
termination.*

*A case id is a resource id and is principal-scoped like any other: another tenant's case is `404`,
identical to one that does not exist. That is `WIR-36`, cited rather than restated — a draft of
this section carried its own copy of the rule, which is the second-normative-copy failure
`SEC-46` is the standing example of.*

**API-63** **A provider account's status MUST be recordable, and recording `terminated` MUST do
what `SEC-46` says it does.** `POST /v1/provider-accounts/{account}/actions/record-status` is
**operator-only** (`WIR-34`, `WIR-50`), synchronous, mints no operation (`API-48`), and writes
`STO-47`. Without it `SEC-46`'s three states were unreachable: nothing could observe an account
unreachable, nothing could record credentials rejected, and nothing could confirm a termination —
while `LDG-32` cited that confirmation as a commitment-closing event and `API-62` promised to
surface the tenants it affects.

**Recording `terminated` MUST, in one transaction, and in this order:** write the status; **record
every machine in that account gone** — `machines.state` and `machines.state_observed_at` (`STO-48`)
set to the recording instant, which is the write `LDG-74` stops a meter by, and `released_at` set on
every unreleased billable attachment, which is how an attachment's meter stops (`LDG-32`, `STO-18`);
**apply `LDG-38`'s exit rule to every subject**, including scheduled machines and quarantined
subjects; **close and release in full
every open commitment on machines in that account** (`SEC-46`, `LDG-32`); **transition every `queued`, never-claimed create naming that
account straight to `failed`** — `conflict`, `details.reason: "account_terminated"` — **and close
and release its commitment**, exactly as `API-58` step 4 does for a suspension and for the same
reason, that it has touched no provider (*added 2026-09-05: a create's commitment has a null
`machine_id`, so "every open commitment on machines in that account" left it standing; a worker then
dispatched against revoked credentials, the reply was ambiguous, and the customer's money sat frozen
for `OPS-33`'s window — days on Robot*); **close every open episode on those machines
`resource_gone` and clear their fences** (`OPS-48`'s gone-write row, `ADR-0021`), **and transition
every `queued`, never-claimed system cancellation naming those machines straight to `failed`** —
`conflict`, `details.reason: "account_terminated"` — on the create's reasoning, that it has touched
no provider, by a conditional write guarded on `(id, status = queued, requested_by = system, the
machine in that account)` in the manner of `STO-3`; a claimed one loses that race and settles as
its own worker's write under an episode that is already closed (*added 2026-09-09: without the close, every episode open at the recording sat `stalled` in
`OPS-26`'s listing forever — the outcome the paragraph below calls a failure, reached for the
pre-existing episodes rather than the new ones*); tombstone what `STO-18`
now permits; and **return two tenant lists** (`WIR-50`) — `affected_tenants`, "the distinct owners of any metered subject or open commitment in
that account at the recording instant", and `assigned_tenants`, the account's `STO-36` assignment
set (*quoted rather than paraphrased since 2026-09-05: a paraphrase here read "the tenants whose
commitments it just released", which drops a tenant whose late-attached machine is metered and has
no commitment — a tenant that then appeared in neither list*). Together those are `API-62`'s "MUST surface the affected tenants", now
answered by the call that creates the situation rather than left for the operator to discover.
**They are different sets and both are needed**: the first is who lost money, the second is who
`API-62` must move. *Until 2026-09-04 only the assignment list was returned, and a deployment that
had already re-assigned its tenants off a failing account — the responsible thing to have done —
named none of the tenants it was in the act of stranding.*

**It MUST also contend with admission on the account row itself, and that ordering comes first.**
The create's admitting path MUST **conditional-write** `STO-47`'s row, guarded on
`status = healthy`, **in the transaction that opens the commitment**, and fail `conflict` with
`details.reason: "state"` where that write affects no row — so a create admitted after a
termination is impossible rather than merely unlikely, because the two contend on one row and one
provably loses, which is `OPS-42`'s shape. *A draft of 2026-09-04 had the create **read** the row
in that transaction and called it the same shape; it was not. Under the snapshot isolation a server
engine (`STO-6`) ordinarily gives, a read contends with nothing, and the create committed against an
account terminated behind it. The row now exists from configuration so there is always one to
write (`STO-47`), and `STO-27` lists this among the primitives a replacement engine must
reproduce.* *Added 2026-09-04: per-tenant
primitives cannot supply this. They do not cover a tenant with no machines in the account yet, and
the check and the commitment sat in different transactions, so a create could pass the health check,
have the termination commit behind it, and open a commitment against a dead account.* **A create claimed but not yet dispatched narrows the unreachable case to a dispatched order**:
in the transaction that records the attempt's correlator entry (`OPS-35`, `PRV-26`) — the last
write before the ordering call — the worker MUST repeat the admission check as a conditional write
on `STO-47`'s row guarded on `healthy`, and where it affects no row MUST fail the operation
deterministically — `conflict`, with `details.reason: "account_terminated"` where the status is
`terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable
account as a permanent termination is false — releasing its commitment,
with no provider mutation. `LDG-69` keeps the provider call outside that transaction, so a
termination can still commit between the write and the call; that residue is the dispatched case
below, **and the correlator entry is what tells the termination which case it is**: a claimed
attempt with no entry has not passed the check and will fail at it, and one with an entry MUST be
treated as potentially dispatched (*added 2026-09-05; a `running` operation sat between "queued, never claimed" and "already
dispatched" and matched neither, so it ordered with credentials already known to be dead; the
transaction is named so a crash between the check and the correlator entry cannot leave an attempt
recorded with no admission behind it*). **A create
already dispatched to the provider when the termination commits is not reachable by any lock**, and
is `OPS-36`'s late attach: the machine appears under a terminated account, `OPS-36` attaches it and
enqueues the cleanup cancellation, that cancellation fails against the revoked credential, and
its episode goes `stalled` (`OPS-48`) into `OPS-26`'s listing. That is the honest end for it, and it is stated so the
machine is *somewhere* rather than orphaned in silence.

**The transaction MUST hold the `LDG-35` primitive of every tenant in `WIR-50`'s
`affected_tenants`, acquired in ascending tenant-identifier order** — the ordering `LDG-35` already
states for the two-tenant attribution case, applied here to n tenants, and that set rather than "the
tenants whose commitments were released" because a metered machine need not have one (`OPS-36`) and
its meter is exactly what this serializes against. For the posting's serialized re-read and
clipping, see `LDG-38`.
It holds **no machine** (`OPS-8`) — `LDG-69` forbids that under the serialization — and these are
the same columns `OPS-32`'s sweep writes without holding one (`STO-48`); both exit writes take
the tenant primitive per `LDG-38`.

**The order is the requirement, and each step exists because the one after it destroys the evidence
it needs.** For closing increments see `LDG-38`, and for the decision see `ADR-0011` (2026-10-03).
The tombstones cannot come before the attachment writes, because `STO-18` forbids
tombstoning while a billable attachment has a null `released_at`. And **leaving the machine rows
without a gone state is not a smaller version of this rule but a different failure**: the rows stay
in inventory at zero usable satoshis, `LDG-13`'s exhaustion sweep reads them off `runway_until`,
mints an `exhausted` delete against each one, every delete fails deterministically against a
credential the provider has revoked, and each episode sits `stalled` (`OPS-48`) in `OPS-26`'s listing
forever. *Confirming one termination would flood that listing with one permanently-open episode
per machine — the `CNF-272` scenario, at the scale of a whole account.*

**The meter stop MUST come first, and it MUST cover the attachments as well as the machines.**
*Added 2026-09-04. The release was specified without it, and the two are not the same act:
`LDG-32`'s first terminal outcome reads "the machine stops billing **and every billable attachment
it left behind has stopped billing**", which is the shape the other rows share — while the
account-termination row added on 2026-09-02 released the money
and left every meter running. For exit ordering and its rationale, see `LDG-38` and
`ADR-0011` (2026-10-03).*
**This is the one case where a machine's meter and its attachments' meters stop together**, against
`LDG-74`'s general rule that they must not be collapsed: that rule protects volumes which outlive
their machine, and nothing in a terminated account outlives it.
Re-assignment stays a separate, deliberate act (`API-62`), because doing it automatically moves
every affected tenant at once, precisely when the surviving accounts can least absorb them.

**Recording a status the driver itself reports MUST be refused** `conflict` with
`details.reason: "state"`, exactly as `WIR-47` refuses an operator network-restriction where the
driver is authoritative. **`terminated` MUST NOT be reversible** through this verb or any other: it
has already released customer money, and a state that can be left silently would re-reserve balances
against machines the provider says are gone. The remedy for a mistaken termination is a fresh
account and `API-62`, which is a decision with a record.

**Every use MUST emit a monitorable event** naming the principal, the account, the status before and
after, and the reason (`SEC-39`, `SEC-32`) — this is an operator verb that moves customer money, and
`SEC-39` as amended assumes the operator principal is a program.

**API-66** **The operator MUST be able to record a provider invoice, payment or void**
(*added 2026-10-04, `pv-gip.39`, `ADR-0031`*).
`WIR-53` owns the request and result; `STO-57` owns the append-only rows and import uniqueness.
The verb follows the common `API-7` pipeline, skips tenant-state steps as an operator verb, and
commits its row and exact synchronous result receipt together (`STO-35`, `WIR-3`). It MUST be
admitted during a solvency halt and without a currency rate: it is not bill-increasing. It never
executes a payment, calls a provider, creates an operation or moves tenant balances. The `api`
handler records through `ledger` (`OVR-9`); no importer is required. A duplicate provider reference
under a fresh key MUST fail `409` `conflict`, `details.reason: "state"`, without another row or
accounting effect. Invoice amounts MAY be zero, including where no provider document exists,
or negative for credit notes. `STO-57` owns void validation and permanent reference reservation.
Concurrent recording for one account/currency MUST serialize the invoice's reported true-up
calculation and row/receipt commit, so concurrent invoices newly cover one month only once in
those results. This serialization protects the reported number, not an order-dependent B.
No particular lock primitive is prescribed.

**API-67** **The operator MUST be able to read each provider account's billing** (*added
2026-10-04, `pv-gip.39`, `ADR-0031`*). `WIR-54` owns the rows, months still accrued,
derived balances and deployment headroom. The read
uses one consistent read-only snapshot, makes no provider call, and is operator-only under
`WIR-34`. No read writes accrual or repairs bookkeeping.
