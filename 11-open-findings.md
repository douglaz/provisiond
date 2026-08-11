# 11 — Open findings

An independent structural audit read all twelve documents end to end on 2026-08-09 and
returned **21 findings, 5 of them critical**, with the verdict:

> **NO.** A competent engineer could not build this without asking the author questions.

A separate usability audit reached the same conclusion by a different route: the `core`,
`providers` and `rescue` documents are buildable on day one; every stall is in the API and
persistence surface.

This file tracks all of it. Items marked **FIXED** were resolved on 2026-08-09; **CLOSED
2026-08-11** marks those resolved by the design session that produced `docs/adr/`. The rest are
open and inherited by whoever picks this up.

## The three questions a builder must ask first — all three now answered

They are kept here rather than deleted, because a reader who was told these were blocking
deserves to see where each landed.

1. **Which deployment form and tenant model is authoritative?** → `ADR-0001` (single deployable)
   and `ADR-0002` (self-serve enrolment, registry required). Customer credentials are runtime-
   issued (`API-32`–`API-37`, `STO`'s `tenants` table); there are no per-tenant ceilings because
   `ADR-0002` replaced the whole idea with a prepaid balance.
2. **How is `needs_reconciliation` resolved without replaying the mutation?** → `OPS-27`–`OPS-33`.
   Resolution searches for a correlator the create wrote into the provider (`PRV-26`, `PRV-27`);
   attaching a discovered resource is `PRV-28`'s adopt path; `OPS-31` gives operator verbs for
   what cannot be resolved automatically.
3. **What is the complete deletion and billing contract?** → `PRV-13b`–`PRV-13e` for the reserve,
   `machine_attachments` and `STO-18` for the cleanup surface, `STO-17` for cross-tenant
   ownership, and `12-billing-and-ledger.md` for everything downstream of the money.

**A fourth question replaces them, and it is not a specification question.** Nothing in this set
has been validated against a running system, a real provider response, or a paying customer. The
design is now internally consistent and considerably more opinionated than it was — which raises,
rather than lowers, the value of the first real transaction.

## Critical — closed 2026-08-11

**F1. `needs_reconciliation` had no resolution path.** → `OPS-27`–`OPS-33`. The mechanism turned
out to depend on a fact nobody had checked: **every provider in the set offers a caller-controlled
field** that a create can write an operation id into, and three of four can filter on it
server-side (`08-provider-notes.md`). That converts resolution from a heuristic match on hostname
and timing — which `OPS-29` now forbids — into an exact lookup. `OPS-33` additionally bounds how
long a customer's balance may stay frozen by an unresolved record, which is a cost that did not
exist when this finding was written.

*Both auditors had named this the highest-value remaining edit, and advised writing it from the
transcript of a real ambiguous outcome rather than from imagination. That advice was not followed
and the reason should be recorded: the correlator design makes the mechanism verifiable from
provider APIs rather than from experience. **The negative window in `OPS-33` is still a guess**,
and it is the part a real transaction would calibrate.*

**F2. The registry branch of `DOM-1a` was not buildable.** → `API-4` split. Operator credentials
stay environment-supplied and static; customer credentials are runtime-issued (`API-32`–`API-37`)
against a `tenants` table (`STO-21`). The self-serve product this set was extracted for is now
specifiable.

**F5. Deletion semantics were incomplete.** → `machines` gains effective and earliest
cancellation dates plus the full reserve tuple; `machine_attachments` models what keeps billing
after deletion; `STO-18` forbids tombstoning while a billable attachment survives, which is where
`STO-8` and `PRV-13a` are finally reconciled.

## Critical — open

**F23. The wire contract is now further behind than when `F19` was written.** Enrolment added
endpoints, the create request gained a runway field (`PRV-13d`), and machines gained
caller-readable runway (`LDG-15`) — none with a request or response body. See `F19`. **This is
now the largest single gap in the set.**

**F24. CLOSED by being right.** It warned that nothing decided on 2026-08-11 had been reviewed by
anyone but its author, and that confidence should be no higher than it was before the previous
audit. Two independent audits on 2026-08-12 returned **NO** with roughly forty distinct findings
between them, six confirmed by both models separately. The warning was correct and the money
model was, as predicted, the worst part.

## The second audit — 2026-08-12

**The root defect: the hold was the wrong primitive.** A hold is a card-payments idea — authorize
once, capture once, against a discrete purchase of known size. Machine time is continuous
consumption. Twelve requirements placed, gated, subtracted, raised and released a hold; **none
made it shrink as the machine was used**, so the ordinary happy path drove the available balance
negative one hour into the first machine's life. Six further findings were downstream of the same
mistake, and the tell was that `PRV-13b` consumed an `accrued_unbilled_usage` term that no
requirement produced — the author knew a meter must exist, wrote it into the formula, and never
specified it.

`12-billing-and-ledger.md` was rewritten around a **commitment that decays as it is consumed**
(`LDG-30`–`LDG-36`), and the consumption half — the meter (`LDG-37`–`LDG-39`), the rate source
(`LDG-40`–`LDG-41`), and the funding path (`LDG-42`–`LDG-44`) — now exists.

**Fixed 2026-08-12.** Available going negative in normal operation; nothing releasing a
reservation on `failed`, `succeeded` or delete (the only statement of it lived in `CONTEXT.md`,
which declares itself non-normative); the setup fee reserved rather than debited, making a
create-delete loop cost the operator a setup fee per iteration and the tenant almost nothing;
the double-count between `LDG-9` and `LDG-5`–`LDG-7`; no serialization on the authorization read,
so two concurrent creates spend one balance; **no money-in path at all** — sixteen endpoints and
none took money, while `CNF-94` was BLOCKING and tested a payment notification with no endpoint;
one satoshi defeating the enrolment time-to-live; `DOM-17` having no way to say *insufficient
balance*, so four BLOCKING items asserted a rejection the taxonomy could not express; `OPS-32`
reporting 100% of Robot and adopted machines as unclaimed forever; `OPS-27` and `OPS-33` giving
opposite MUSTs for the same trigger; `OPS-36`'s missing late-arrival branch; requeue and
idempotency comparison both broken by the payload purge; `API-7`'s normative step list containing
no authorization check at all; `STO-21` forbidding what enrolment requires; the `commitments`
table not existing while `CNF-96` tested writes to it.

**The correlator claim was overstated and is corrected.** `PRV-26` writes the *create* operation's
id; a cancellation is a different operation with nothing written provider-side. That premise had
been used to shrink `wind_down_cost`, so a reconciliation error was propagating into systematic
under-reserving across the fleet. `PRV-29` now states the real rule — non-create mutations resolve
by reading provider state for a known `external_id` — and `wind_down_cost` is reduced only where a
driver can distinguish *rejected*, *accepted-pending*, *scheduled* and *complete*.

**Settled:** customer authentication is a caller-supplied public key (`API-39`). Both audits
reached it independently.

## Open after the second audit

**F25. `LDG-19` versus `ADR-0004` §4 — put this to a lawyer first.** `LDG-17` requires holding
satoshis equal to the float and `LDG-19` required *publishing* that invariant, while `ADR-0004`
§4 forbids describing balances as "held", "backed", "reserved" or "segregated". A published
one-to-one asset-to-claim ratio is what safekeeping on behalf of clients looks like from outside,
whatever the contract says — so the publication requirement was demanding exactly the substance
`ADR-0003`'s defence exists to deny. Publication is now withheld pending advice. **This precedes
the refund question `ADR-0003` nominates as first.**

**F26. `PRV-13b` needs the earliest-cancellation date before the create that reveals it.**
`PRV-13c` says that per-machine constraint is learned after ordering; `LDG-12` forbids the
provider call before the commitment exists. For an offer that does not expose contract terms up
front, the commitment can only be sized after making the purchase it is meant to authorize.

**F27. `ADR-0003`'s "matched at all times" is not what `PRV-13e` delivers.** The matching argument
needs unthrottled re-pricing; `PRV-13e` deliberately caps per-tick increases and requires a
deficiency to persist — with no cap value stated. On the −49% move the ADR itself cites, every
running machine is under-reserved by the uncapped remainder for at least two derivation periods.
The dissent recorded in that ADR is about MiCA; **this objection is arithmetic, and it is the one
that costs satoshis.**

**F28. `ADR-0004` §5 (B2B only) is unenforceable under `ADR-0005`.** Nothing may be recorded, so
nothing distinguishes a business from a consumer, and the consumer withdrawal right §5 exists to
avoid is still reachable. Relatedly `API-18`'s adoption entitlement has no workable option under
self-serve enrolment: two of its three require an operator step the product deleted, and the
third requires access to a machine the tenant does not yet have.

**F29. `PRV-30` — the Hetzner Robot `comment` field may force manual order processing.** Claimed
by one audit, citing the Robot documentation; **not verified** — the docs page truncates before
the ordering section and the client libraries carry no note. If true, the Robot correlator turns
every order into a human-latency order and invalidates the measured negative window for that
provider. Check before shipping the Robot driver.

**F30. Conformance items still lag the rewrite.** `CNF-76`–`CNF-115` were written against the
hold model. They need re-pointing at commitments, plus new items for the meter, the rate source,
the funding path, `OPS-36`'s late arrival, cardinality in correlator matching, and per-tenant
serialization. Several existing tiers are wrong: `CNF-99` is PRE-SCALE while testing a path that
destroys a disk, and `CNF-77`, `CNF-24`, `CNF-113` and `CNF-115` are each a tier below the item
that depends on them.

## Critical — closed 2026-08-11 (second pass)

**F22. The conformance checklist covered nothing decided on 2026-08-11.** → `CNF-76`–`CNF-115`,
covering enrolment and credentials, correlators and reconciliation, the ledger, ownership and
deletion, and blast radius. **23 of the 40 are BLOCKING**, taking the blocking set from 50 to 73.

That number is the finding's real content and it is left visible rather than buried: choosing
self-serve enrolment and a prepaid balance did not add features, it added a money system whose
correctness gates launch. A reader deciding whether that trade was worth making now has the
price in front of them.

## Critical — fixed 2026-08-09

**F3. Operations had no tenancy rule.** `API-17` covered only machine-scoped endpoints, so
`/v1/operations` and `/v1/operations/{id}` could expose another tenant's operation, provider
account, result and error. Pagination was specified; isolation was not. → **`API-17a`.**

**F4. Any tenant could create against any provider account.** Create is the only verb with no
target to authorize against, and neither account assignment nor spending authority existed.
`allow_orders` plus an acknowledgement prevents accidents, not unauthorized spending — which
directly contradicted `DOM-3`. → **`API-17b`.**

## High — open

**F6. Password-only rescue is impossible under the declared interface.** Begin-rescue always
receives an ephemeral public key, and `PRV-17` forbids accepting-then-ignoring it. No
alternative access-request variant exists, so a password-rescue provider cannot conform.

**F10. The capability model has dead branches** — *partially closed.* `adopt_existing` is
resolved: `PRV-28` states that adoption is get-machine plus a local write, so the missing driver
operation was never needed and a reader looking for it should not add one. **Still open:**
`remote_console` has no operation while console proxying is a non-goal; `attach_iso` gates an
install pairing with no provider operation behind it; list-offers has no capability at all,
contradicting `OVR-2`.

**F13. The single-process credential boundary is not proven by its own tests** — *and `ADR-0001`
raised the stakes rather than lowering them.* Provider secrets originate in the process
environment, which customer-facing code can read without ever referencing the private credential
type; `CNF-71`/`CNF-72` prove *type visibility*, not inability to read the environment or inspect
shared process state. The single-deployable decision is now final, so this is the only structural
defence, and it does not yet hold. **It got worse:** the same process is now specified to hold
the ledger and payment rails, so one compromise takes the machines *and* the float. The
sub-decision recorded after `API-37` — caller-supplied public keys instead of server-held tokens
— is the cheapest available mitigation and is not yet taken.

**F17. Tier assignments change under honest application of the rule** — *partially closed.*
`ADR-0001` chose the single-component form, so `CNF-71`–`CNF-74` apply and `CNF-66`–`CNF-68` do
not; that blocker is resolved. **Still open:** `CNF-65` is BLOCKING because autonomous deletion
can leave unbounded billable attachments, and `CNF-58` is BLOCKING if an unknown stored state can
become `queued` and repeat a mutation. Neither has been re-tiered, and `F22` means the new
requirements have no tier at all.

## High — fixed 2026-08-09

**F7. Install failure classification was neither total nor consistent.** `authentication` and
`rate_limited` were absent from both install outcomes, and `PRV-22` appeared to contradict the
install row. → `OPS-11` table made total, the `PRV-22` interaction stated explicitly, `CNF-31`
split into `CNF-31a` (misclassification causes a repeated mutation) and `CNF-31b` (totality).

**F11. "Every non-`GET` endpoint MUST return `202`"** contradicted mandatory `400`, `401`,
`409`. → `API-1` now says every *accepted, valid* write.

**F14. `API-30` contradicted itself** — registry deployments "MAY treat the options as
advisory," then an unconditional "MUST do one." → rewritten, and it now states what a registry
does *not* buy: it proves an override names an existing tenant, never that it names the
*right* one.

**F16. Tier arithmetic was wrong.** `CNF-31` appeared in two tiers; the blocking list held 50
items while the prose said "roughly 44"; `CNF-62` was DEFERRED while the area sort called its
parent PRE-SCALE; `CNF-60` was PRE-SCALE while `API-21` was DEFERRED. → all corrected.

**F21. Stale citations after the day's edits.** `OPS-13` cited `RSC-17` instead of `RSC-19`;
`API-30`, `CNF-67` and `SEC-40` still said "amend `DOM-1`" after `DOM-1a` superseded it; the
README claimed no provider fact was web-verified while `08` carries a dated verified claim.
→ all corrected.

## High — closed 2026-08-11

**F8. Idempotency had no retention boundary.** → `STO-25`. Either retention preserves the
`(tenant, key)` pair beyond the operation it guarded, or `API-11`'s promise gets an explicit
expiry stated to callers. The unstated third option — silently performing the mutation a second
time — is now named as the duplicate purchase it is.

**F9. Mandatory data was absent from the normative schema.** → `operations` gains
`correlation_id` (`API-28`) and the resolution columns; `operation_requeues` gains `reason` and
`previous_error` (`STO-20`), without which `OPS-19`'s audit trail is overwritten by the next
attempt.

**F15. Global uniqueness of an external machine was required but not enforceable.** → `STO-17`.
The stated constraint included `tenant_id` and so permitted exactly the duplicate it was meant to
prevent; two tenants adopting one machine would each have been authorized to destroy the other's
server.

**Part of F18** — `PRV-13b`'s FX haircut. The formula now applies one haircut to the conversion
rather than trailing an ambiguous multiplier after the sum, and states that no volatile-asset
haircut applies at all, because `ADR-0003` matched the ledger's denomination to the asset.

## Medium — open

**F12. Digest policy conflicts.** `DOM-14` requires digests for rootfs and raw disk only; ISO's
is explicitly optional and iPXE has none. `SEC-16` requires one for "every custom image."

**F18. Several MUSTs are untestable as written:** "measured worst-case delay," "materially in
the future" (`PRV-13c`), ceilings "per interval" (`SEC-39`), "enforce what it can" (`SEC-42`),
"a sane range" (`API-26`), "controlled, immutable storage" (`RSC-30`). No units, thresholds,
measurement procedure or pass/fail boundary. `PRV-13b`'s formula also leaves ambiguous whether
the FX haircut multiplies the whole reserve or only part of it.

**F19. The wire contract does not exist.** In ~2,600 lines there is exactly one JSON example —
the error envelope. No request or response body for any endpoint. The idempotency header is
required by `API-8` and never named; likewise the tenant-override header and the destructive
and purchase acknowledgement fields. `CNF-21` tests "byte-equivalent body" against a contract
nobody wrote, so every implementer invents one and the checklist blesses it. `API-13` also
omits `PRV-8`'s minimum-one-key create rule. **Two competent implementations will not
interoperate.**

**F20. Durable queueing conflicts with short-lived signed image URLs.** `OPS-2` persists the
request; `SEC-21` wants short URL lifetimes. A URL can expire between enqueue, restart,
deferral and execution, and there is no refresh or caller-replacement mechanism.

## How to read the fixed/open split

The 2026-08-09 batch were the *cheap* items — self-contradictions and stale references from a day
of heavy editing, plus two security holes clear enough to close without a product decision.

**The 2026-08-11 batch is different, and carries its own warning.** Those items were closed by
making product decisions (`docs/adr/`), and a decision resolves a *specification* gap without
producing any evidence that the decision is right. `F1` is the clearest case: it is closed
because a mechanism now exists and is verifiable against real provider APIs — but `OPS-33`'s
negative window, the number that decides how long a customer's money stays frozen, is still a
guess, and no amount of internal consistency will calibrate it.

Note also the direction of travel in `F22` and `F23`: **this session created open findings faster
than a careless reader would notice**, because a hundred new requirements arrived with no
conformance items and no wire format. A specification that grows faster than its checklist is
getting less testable, not more finished.

What has genuinely changed is the *kind* of uncertainty. Before, the set could not describe its
own product. Now it can, and the open questions are about whether the described product is
correct — which is the question a first real transaction answers and no further editing will.
