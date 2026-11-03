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
5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.

The tail then depends on what the endpoint does:

| Class | Tail |
|---|---|
| **create** | evaluate the rich purchase tail below; on admission, commitment + operation in one transaction (`LDG-11`, `LDG-35`), then `202` |
| **power, install, reverse-DNS, refresh, rescue inventory** | enqueue an operation, then `202`. **No commitment**: they are not purchases, and they pass no spending gate |
| **retry** | operator-only (`API-64`, `WIR-51`); synchronous, `200` with the episode view; the episode's state change, the enqueue of a fresh `delete_machine` attempt and the idempotency record commit in one transaction (`WIR-24`); **no commitment and no spending gate** — the attempt reduces exposure, on the delete row's reasoning |
| **suspend** | operator-only; enqueue one cancellation per machine, then `202` (`API-58`) |
| **release attachment** | operator-only (`API-65`, `WIR-52`); on an `api` row enqueue one `release_attachment`, then `202`; on a `manual` row synchronous `200`, writing `released_at` (`API-48`); **no commitment and no spending gate** — it reduces exposure, on the delete row's reasoning |
| **revoke** | operator or recovery-credential principal (`API-56`, `WIR-38`); synchronous, `200`, no provider mutation (`API-48`) |
| **keep** (*added 2026-10-04, `pv-gip.11`*) | operator-only, synchronous `200` (`API-68`, `WIR-55`); **no commitment and no spending gate**; admission follows this pipeline, with no retry-ceiling treatment |
| **resume, resolve** | **operator-only** (`WIR-41`, `WIR-35`, `WIR-34`); synchronous, `200`, no provider mutation (`API-48`). The recovery credential reaches **neither** — `API-55` confines it to `API-56`, and a recovered-after-theft credential that could resume its own tenant or resolve an uncertain provider mutation would undo the suspension that answered the theft |
| **delete, cancel** | enqueue an operation, then `202`, and **bypass the rate and solvency gates entirely** — these reduce exposure, and refusing them because exposure is too high is the failure `LDG-20` already forbids |
| **deposit** | synchronous; allowed while pending; **refused `halted` while `LDG-20`'s solvency halt is in force** — that halt stops top-ups *first*, and minting a destination invites exactly the payment it forbids; otherwise **mints a destination and writes NO ledger entry** — a deposit is not money until it settles (`LDG-47`) — plus an idempotency record, in one transaction; `200` |
| **extend-runway** | evaluate the rich purchase tail below; on admission, the guarded extension (`LDG-62`) and idempotency record commit together (`WIR-24`); synchronous `200` |
| **abuse-case writes** | the tenant's statement (`WIR-43`) and the operator's five verbs (`API-60`, `API-61`) — synchronous, **no commitment, no spending gate, no provider mutation**; `201` on create and on a statement, `200` on the rest; each carries `Idempotency-Key` under `WIR-24`'s one-transaction rule. The statement write is a maintenance action and stays reachable while suspended (step 5b) |
| **attribute** | operator-only (`WIR-42`); synchronous, `200`; posts ledger entries, so it **takes `LDG-35`'s serialization for both tenants, in ascending tenant-identifier order**, and the primitive must not require a live `tenants` row — the source tenant is normally already reaped |
| **record billing** (*added 2026-10-04, `pv-gip.39`*) | operator-only (`API-66`, `WIR-53`); synchronous `200`; local row and receipt commit together; no provider mutation, commitment or spending gate |

**Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
transaction, without an extra lock, ceiling slot, write or provider call. On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`. `details.refusals`
(`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create
against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension);
then, on create only, `invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads;
then, on create only, `rate_limited` when the offer's account and ordering channel
are closed under `PRV-40`;
`halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`);
`insufficient_balance`. See `ADR-0030` for the order's rationale and `LDG-40` for halt retention.
An offer absent from the offers the check reads is an unsellable offer for every rule in this
tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and
`not_checked` entries. No additional lookup is made for this verdict.
Both halted entries may appear; no duplicate
means no repeated refusal/check, not unique kind strings. The cap and balance checks MUST NOT
run without a rate, nor for create against an unhealthy account or unsellable offer:
`WIR-30` says "an account whose
`STO-47` status is not `healthy` `404`s on this route too". `WIR-9a` owns `not_checked`,
including cap presence, reasons and ordering. Each refusal is exactly
`WIR-9`'s inner error object, with no nested refusal list. Entry 0 is the headline: HTTP status,
`kind`, `message` and per-kind details MUST match it; top-level details additionally carry the
aggregate keys. Only top-level `retryable` may differ, under `WIR-9b`. Pacing belongs to the
headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and
`WIR-4`; each entry keeps its own required pacing. No maximum is taken and a subordinate
entry MUST NOT supply pacing to a headline kind that does not require it. A refused tail MUST
commit nothing and write no `STO-35` receipt (`WIR-3`), so clearing faults and resending the same
request/key evaluates afresh. Admission retains the conditional-write guards in `API-63`,
`LDG-62` and `PRV-42`; collection does not replace them with read-only guards. These are admission refusals
(`OPS-11`), never lists in operation views. Steps 1–5d still stop at their first refusal; see
those steps for their rationale. Deposit behavior and other tails are unchanged.

*Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): included an offer
absent from the offers the tail reads in the unsellable verdict throughout the tail, without
an added lookup.*

**Amended 2026-10-10 (`ADR-0036`).** After an otherwise successful tail collection,
a create whose resource-offer conditional write affects no row (`PRV-42`) MUST receive an
ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no
`details.refusals`, no synthesized pacing or `Retry-After`, and no commitment,
operation or receipt. This response is specific to the resource-offer guard.

*Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): an unsellable offer is a
create-only tail refusal after account health. It suppresses cap and balance evaluation,
while independent solvency and rate refusals remain collectible. A refused tail still
commits nothing, including no operation, machine, balance write, receipt or provider call.
The subordinate-entry pacing rule applies to every subordinate refusal.*

*Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment): the stored
account-and-channel closure is a create-only snapshot input, collected after the offer
refusal and before solvency without a provider call or extra collection lock. It does
not suppress pricing checks or add a `not_checked` reason; `WIR-9a` owns that closed
reason set. The same request/key is evaluated again after a transient closure clears.*

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

*Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): added step 5d.*

## Enrolment

Self-serve enrolment (`ADR-0002`) with no identity collected (`ADR-0005`) means the only thing
standing between a script and an unbounded table of tenant rows is this section.

