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

*Worse on 2026-08-12.* Funding added a request that carries an amount and a response that must
name a rail, a destination and an expiry (`API-44`) — with no body for either. This is the one
endpoint where an implementer's invention is not merely incompatible but dangerous: a caller that
reads the requested amount back out of the response and treats it as credited has re-created the
`LDG-47` defect on the client side, and nothing in a checklist the *server* passes will catch it.

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

**F26. `PRV-13b` needs the earliest-cancellation date before the create that reveals it** —
*narrowed 2026-08-12, and the narrowing came from a document already in this set.* `PRV-13c` says
the per-machine constraint is learned after ordering; `LDG-12` forbids the provider call before
the commitment exists. But `08-provider-notes.md` records that current Robot dedicated servers
carry **no minimum term** and that a newly ordered machine's `earliest_cancellation_date` is
normally *today*, so a create rarely lands on the exception branch at all; and `PRV-13c` names
**adoption** as that branch's main road, where the machine already exists and `PRV-28` makes
adopt a get-machine plus a local write — so the constraint is read *before* the commitment is
opened. What remains is a create at a provider whose offer does not disclose its term. That wants
a driver-declared pre-create bound per offer, with *no declared bound MUST NOT be sold on prepaid
terms*; it is a bounded edit, not a structural one. **Recorded so the next reader does not
re-derive the alarm from the finding's original wording.**

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

*Re-scoped by `ADR-0010`, and in the direction that matters.* Robot is now the flagship product
rather than one of several, which raises the stakes — but the launch set also contains two
providers this does not touch. **So `F29` blocks the Robot driver, not the launch**, and the
verification belongs before that driver is written rather than before anything ships. Had v1 been
Robot-only, this unverified claim would have been a single point of failure for the entire
product.

**F30. The rewrite landed in two files and stopped** — *wider than first recorded.* The
commitment replaced the hold in `12-billing-and-ledger.md` and `CONTEXT.md`; **everywhere else
still says hold**, including `PRV-13b`'s reserve formula (`hold = to_ledger_unit(...)`),
`operations.hold_id`, `SEC-46`, and thirteen uses in the checklist. One is wrong in substance
rather than wording: `PRV-13e` says a re-derivation that comes out higher means "an additional
hold is placed", but there is **one** commitment per machine and it is *re-sized* — stacking a
second reservation reintroduces exactly the double-count `LDG-9` was withdrawn for.

The conformance half stands as written: `CNF-76`–`CNF-115` still need re-pointing at commitments,
plus items for the meter, the rate source, `OPS-36`'s late arrival, cardinality in correlator
matching, and per-tenant serialization. Several tiers are wrong: `CNF-99` is PRE-SCALE while
testing a path that destroys a disk, and `CNF-77`, `CNF-24`, `CNF-113` and `CNF-115` are each a
tier below the item that depends on them. *The funding path is no longer on this list — see
below.*

## The funding decision — 2026-08-12

**`ADR-0008` chose two rails: Lightning primary, on-chain fallback.** `LDG-42` had required a
funding path and then named three candidate rails without picking one, so the endpoint, the
finality rule, the fee-bearer and the tenant binding were all unwritten while `ADR-0002` made the
money path v1-blocking.

The mechanism worth recording is that **attribution comes from the destination, not the payer**
(`LDG-49`). A funding request mints a destination bound to one tenant, and the credit is posted
against that binding — which satisfies `ADR-0005`'s collect-nothing posture and `LDG-42`'s
attribution requirement with the *same* mechanism instead of trading one against the other.
Authentication is structural on both rails: settlement is read from the operator's own node, so
there is no inbound notification to forge and `LDG-42`'s minting risk is designed out rather than
defended against.

**The first draft of that decision was withdrawn within the hour, and the correction is the
interesting part.** It had the operator select the rail at mint — Lightning unless the amount
exceeded inbound capacity, then on-chain. That forced a liquidity guess that can be stale by the
time the customer pays, and it made the operator's guess load-bearing in precisely the case where
being wrong costs most.

**A deposit is now one object — an amount and an expiry — with two destinations, and the payer
chooses** (`LDG-46`). The consequence that matters is not the ergonomics: it is that **expiry now
applies on-chain too**, which is the only available bound on an obligation that is otherwise
permanent. Minting a deposit is free, so anything attached to one forever is something an attacker
mints without limit; with an expiry, the active watch set is bounded by *mint rate × expiry
window* regardless of anyone's patience (`LDG-57`). A whole line of defensive design — restricting
addresses to already-funded tenants, which would have put friction on the largest customer's first
payment — became unnecessary and was recorded in `ADR-0008` as rejected rather than dropped.

`LDG-46`–`LDG-57`, `API-43`–`API-46`, `STO-29`–`STO-32` and `CNF-116`–`CNF-131` are the result.
**The blocking set moves from 73 to 86**, and thirteen of the sixteen new items are BLOCKING for
one structural reason: money-in is the only path in this specification where a bug *creates*
satoshis rather than moving them, after which `LDG-17` reports solvency against a float that is
partly fictional.

Three consequences are open rather than settled.

**The deployment parameters are unset.** The confirmation depth, the per-rail floors, the deposit
expiry and the channel-balance treatment are all things `LDG-42` now requires be stated, and this
set does not state them. The expiry is the one to think hardest about: it is simultaneously the
customer's deadline, the operator's disclosure and the bound on the watch set, so short-to-save-
work and long-to-be-generous are both wrong in ways that hit different people.

**One hazard has no mechanism behind it, only words.** An expired address still accepts payments
nobody is looking for. `LDG-54` requires the disclosure and `CNF-131` tests it, but a disclosure
is not a control, and this is the single place in the funding design where a customer can lose
money by doing something that looks correct.

**The on-chain rail hands the operator a payer's address whether it wants one or not.**
`ADR-0005` still forbids retaining it, and that discipline is harder here than on Lightning
because the information arrives unbidden rather than being asked for.

## The launch set — 2026-08-12

**`ADR-0010` settles `D3`**, open since the first session and never asked: v1 ships **Hetzner
Cloud, Hetzner Robot and DigitalOcean** — both machine shapes across two unrelated companies
(`OVR-14`–`OVR-16`).

The reason this was worth deciding rather than deferring is that **almost every difficult
requirement in this set exists for the dedicated shape**, and a cloud-only launch runs none of
them. The setup fee debited before the order, the reserve covering a cancellation date,
`cancellation_scheduled`, `PRV-13c`'s exception branch, `ADR-0006`'s pass-through — all written,
all unexercised. Specifications turn out to be wrong precisely in the parts that never ran.

Each driver earns its place differently: **Robot is the product**, **Cloud is the cheap machine**
that keeps the conformance checklist affordable to run and is the fallback if `F29` is true, and
**DigitalOcean is the proof the driver contract abstracts anything at all** — two drivers against
one company's API house style can share assumptions neither author notices.

**The cost is stated rather than minimised: three drivers before the first customer**, which is
more work than any alternative considered and is undertaken with nothing yet validated against a
real transaction. That trade — breadth of proof over speed to a first sale — is the opposite of
the one the *fourth question* at the top of this file argues for, and a reader should notice the
tension rather than have it smoothed over.

Two open findings are re-scoped by it. `F29` now blocks the Robot driver rather than the launch.
And `F10`'s dead capability branches stop being theoretical: three genuinely different capability
sets is the first configuration where `OVR-2`'s runtime discovery does real work (`OVR-16`).

## The rate — 2026-08-12

`LDG-40` had required that a rate source "MUST be named" and none was, leaving the last
load-bearing external dependency in the money path unspecified. It is now a **median of at least
three independent sources** with per-source staleness, outlier exclusion, and a quorum below which
there is no rate at all (`LDG-58`–`LDG-61`).

**Two consequences are worth separating from the choice itself**, because they are the parts that
are not cheap to change later:

- **There is no fallback to the last known rate** (`LDG-59`). A stale rate is not a degraded rate;
  it is a number that was true once being used to price a purchase, which is the exact condition
  `LDG-40` already made create halt for. `CNF-141` is the item that catches an implementation
  degrading quietly to a single surviving source.
- **A wrong rate reaches the customer's disk.** Every other external dependency here can at worst
  cost the operator money or stop the service; this one understates the satoshi, makes solvent
  customers look exhausted, and `LDG-14` then cancels the machine and destroys it (`LDG-41`).

**No ADR was written, deliberately.** The trade-off was real and the alternatives — one named
exchange, a published index, or abandoning the rate by pricing in satoshis — were considered. But
the *choice* is cheap to reverse behind `LDG-40`'s interface, and an ADR for a reversible decision
trains a reader to skim the ones that matter. What is expensive to reverse is the halt matrix and
the no-fallback rule, and those are requirements.

**`LDG-58`'s independence rule cannot be enforced by code.** Two front-ends onto one order book
are one source, and nothing at runtime can tell. `CNF-143` is a configuration review, stated as
such rather than dressed as a test.

## Key custody — 2026-08-12

**`ADR-0009` makes the process unable to spend the float**, which is the first requirement in this
set that makes half of `F13` untrue. Deriving addresses (`ADR-0008`) meant holding key material,
which turned that finding from an abstraction into a specific key on a specific disk — and the
answer available here is not available to most businesses that hold customer money: **this one may
never need to spend on-chain at all**, because `ADR-0004` forbids paying anyone out and provider
invoices are settled with the operator's ordinary money.

Lightning cannot go cold, so it is bounded instead (`SEC-49`) and the ceiling *is* the blast
radius, stated as a number. `SEC-48`–`SEC-53` and `CNF-132`–`CNF-137` follow. The blocking set
moves to **92**.

**The luckiest interaction in the set is worth naming**, because it is the reason a manual refill
is affordable: `ADR-0008` gives every deposit both destinations, so exhausted inbound capacity
degrades funding from *fast* to *slow* rather than from *working* to *down*. Without the second
rail, `SEC-51` would make an operator's sleep into a sales outage — and an operator who cannot
sell while asleep will quietly re-introduce the hot key this decision removed. `CNF-136` exists to
catch that pressure before it becomes a change.

**Two things got worse, not better.** The risk moved from compromise to **custody**, and custody
is not smaller by default — losing the cold key destroys the float with no attacker involved, no
insurance and nobody to appeal to, which is why `SEC-53` requires the recovery procedure to have
been *executed* rather than written. And the watch-only material is now a privacy secret of
unusual concentration: an extended public key discloses every deposit address ever derived, so
leaking it publishes the operator's whole payment history with customers linked to each other —
`ADR-0005`'s prohibited outcome reached with nothing stolen (`SEC-52`).

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
defence, and it does not yet hold.

**Half of it closed 2026-08-12.** The "and the float" clause is no longer true by design:
`ADR-0009` makes the process watch-only, so a full compromise costs the machines and whatever sits
under `SEC-49`'s channel ceiling rather than every satoshi ever deposited. The blast radius is now
a number the operator chooses. `CNF-132` deliberately tests *reachability* rather than type
visibility, because repeating `CNF-71`'s mistake here would prove nothing about the money.

**The credential half is also closed:** `API-39` settled on caller-supplied public keys, so the
mitigation this finding called cheapest and untaken has been taken.

**What remains open is the original finding**, unchanged and now isolated: nothing proves
customer-facing code cannot read provider credentials out of the process environment. That is a
provider-credential problem, not a money problem, and it is the last thing `ADR-0001` left
undefended.

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
