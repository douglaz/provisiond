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
out to depend on a fact nobody had checked: that every provider offers a caller-controlled field a
create can write an operation id into. **That premise was partly false, and it took until
2026-08-13 to find out.** Hetzner Cloud, Cherry and DigitalOcean do (`08-provider-notes.md`);
**Hetzner Robot does not** — its only candidate field, the order `comment`, routes the order to
manual processing (`PRV-30`, `F29` confirmed), so it is unusable. Where a correlator exists,
resolution is an exact lookup rather than a heuristic match on hostname and timing (`OPS-29`
forbids the latter); where it does not, resolution is an **operator** action (`PRV-33`) and
`OPS-29` still forbids guessing. `OPS-33` bounds how long a customer's balance stays frozen by an
unresolved record either way — a cost that did not exist when this finding was written, and the
reason the no-correlator branch is survivable at all.

*Both auditors had named this the highest-value remaining edit, and advised writing it from the
transcript of a real ambiguous outcome rather than from imagination. That advice was not followed,
on the reasoning that the correlator design made the mechanism verifiable from provider APIs rather
than from experience — **and the Robot case is what that shortcut cost**: the field was verifiable
in principle and nobody verified it, so a mechanism the design leaned on for its most expensive
product survived three audits before failing. **The negative window in `OPS-33` is still a guess**,
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

**F23. CLOSED 2026-08-12 with `F19` — `13-wire-contract.md` exists.** Thirty-two `WIR`
requirements: conventions (I-JSON, JCS for idempotency, reject-unknown-on-write), the error
envelope with a machine-readable `details` table, the operation and machine views, and a body for
every endpoint — including `extend-runway`, which `LDG-62` created and no surface row carried
until this document forced the enumeration.

**Panel-reviewed and revised 2026-08-13.** A three-model panel (Fable, Opus, Codex) returned ~30
findings, six critical; the reconciled fix pass produced `WIR-1a`, `WIR-4a`, `WIR-5a`, `WIR-9a`,
`WIR-9b`, `WIR-10a`, `WIR-10b`, `WIR-33`–`WIR-37` and amended most of the rest. **The largest
consequence was not a wire fix but an auth reversal:** the panel's six P0s were concentrated in
the Ed25519 signing scheme (`WIR-6`), and re-examining why it existed showed it guarded a
non-extractable asset at the cost of the most interop-fragile construct in the set — so `API-39`
was reversed to a hashed bearer token and `WIR-6`–`WIR-8` withdrawn. The surviving panel fixes:
CORS preflight (`WIR-4a` — without it the browser client could not make one request), the
method+target idempotency fingerprint (`WIR-3`), the complete install body (`WIR-20`), the
operator resolution endpoint `OPS-31` had always mandated with no route (`WIR-35`), principal-
scoped ids (`WIR-36`), and the operator-listener separation (`WIR-34`). *Original:* Enrolment added
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

**Settled, then re-settled:** customer authentication was a caller-supplied public key
(`API-39`, both audits) — reversed 2026-08-13 to a hashed bearer token after the wire-contract
panel showed the signing scheme guarded a non-extractable asset at outsized interop cost. See the
`F23` closure below.

## Open after the second audit

**F25. `LDG-19` versus `ADR-0004` §4 — put this to a lawyer first.** `LDG-17` requires holding
satoshis equal to the float and `LDG-19` required *publishing* that invariant, while `ADR-0004`
§4 forbids describing balances as "held", "backed", "reserved" or "segregated". A published
one-to-one asset-to-claim ratio is what safekeeping on behalf of clients looks like from outside,
whatever the contract says — so the publication requirement was demanding exactly the substance
`ADR-0003`'s defence exists to deny. Publication is now withheld pending advice. **This precedes
the refund question `ADR-0003` nominates as first.**

**F26. CLOSED 2026-08-12** by `PRV-31`: a driver declares a per-offer worst-case cancellation
bound before any order, the commitment is sized to it at create, and the machine's actual date —
read after ordering — re-sizes it downward at the first re-derivation. An offer with no declared
bound is not sellable on prepaid terms. `CNF-166` tests it. *The narrowing that made this a
bounded edit rather than a structural one came from a document already in this set:* `PRV-13c` says
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

**F27. CLOSED 2026-08-12 — and the interviewee's question dissolved it rather than any of the
interviewer's three proposed fixes.** The finding said `PRV-13e`'s throttle contradicts
`ADR-0003`'s "matched at all times"; three design rounds went into how fast commitments should
widen (symmetric cap, asymmetric grow-fast-shrink-slow, a repricing-race scenario). The user's
objection — *every authorization prices at the current rate, so nothing can be overcommitted at
stale prices* — unravelled the premise: usage debits at spot, so a fixed satoshi commitment
simply drains faster after a crash, and **the price move belongs to the customer's runway date,
not to the operator's coverage**. `ADR-0011` records the resulting model: fixed commitment,
floating `runway_until`, no automatic widening ever (`LDG-33`, `LDG-16`, `PRV-13e` all AMENDED;
`LDG-62` runway extension as an authorized caller write; `LDG-63` the scheduled-cancellation
exception). The freeze-attack surface three questions were spent on does not exist in the final
design, because nothing automatic remains to trigger. `ADR-0003`'s claim now carries a footnote
naming its two bounded exceptions instead of an absolute it never delivered.

**F28. CLOSED 2026-08-12, both halves, by decisions rather than mechanisms.** The B2B half: the
operator decided **not to chase jurisdictional consumer-law compliance** — the regimes differ
everywhere and cannot all be satisfied by a seller who deliberately knows nothing about the
buyer. The control is terms clarity: **no refunds, ever, stated unmistakably** (`ADR-0004` §5
AMENDED, with the declined checkbox alternatives recorded). The residual withdrawal exposure is
knowingly operator-borne and joins `F25`'s lawyer list as context. The adoption half dissolved on
inspection: under self-serve, machines exist only in the operator's accounts, so a customer has
nothing to adopt — **adoption is operator-only** (`API-18` AMENDED), the entitlement problem
disappears with the customer-facing feature that carried it, and the challenge token leaves v1
scope.

**F29. CLOSED 2026-08-13 — CONFIRMED TRUE, and the design loses the field.** Hetzner does state
that supplying the order `comment` sends standard and auction orders to **manual processing**. The
claim survived three audits as `[verify]`; the operator confirmed it. `comment` is now prohibited
outright (`PRV-30`) — not merely as a correlator — because a caller-controlled field that changes
how the provider handles the request is not a free field.

**What it costs.** Robot loses its exact recovery stamp, and Robot is the product where a lost
reply is most expensive: a duplicate order means a second physical server and a second
non-refundable setup fee. `PRV-32` nominates a substitute — a **per-order throwaway SSH key**,
whose fingerprint is a caller-chosen stamp and which `PRV-9` already requires the driver to
create, so uniqueness is free — and **both of its falsification conditions were checked the same
day and held**:

- *the transaction listing returns the key* — **verified in two independent client libraries.**
  `hrobot-rs` deserializes `#[serde(rename = "authorized_key")] authorized_keys:
  Vec<InitialProductSshKey>` with a `fingerprint` field; `appscode/go-hetzner` independently
  declares `Transaction.AuthorizedKey` → `AuthorizedKey.Fingerprint`. Standard and auction-market
  transactions both carry it;
- *a distinct key per order changes no handling* — `authorized_key[]` is structured data and one
  arm of the order's mandatory authorization choice (the other is `password`), not free text. Only
  `comment` carries a processing caveat, and a differing value in a structured field has no
  mechanism by which to summon a human.

**The Robot correlator therefore survives, by a different field than the design assumed.**

**If it fails, `PRV-33` governs and the guarantee holds anyway:** an ambiguous Robot create
resolves to an **operator**, never to a timing-based guess. `OPS-29`'s prohibition on heuristic
matching is not relaxed by the correlator being unavailable — the temptation runs precisely the
other way, and a wrong match hands one customer another customer's physical server. The visible
consequence, stated rather than hidden: for such a provider the `OPS-33` negative window is
bounded by operator response time, and the commitment is still released on it (`OPS-33`), so a
customer's satoshis are never held hostage to how fast a human looks.

**Two further facts came out of actually reading the clients**, and one of them is worth more
than the finding that prompted it:

- **Robot orders have a `test` mode** (`PRV-34`). `test=true` simulates the purchase and returns a
  `Cancelled` transaction. The entire dedicated ordering path — the most expensive thing to get
  wrong in this specification, and the one `CNF-147` could previously only test by buying a
  server — is exercisable against the live API for free. It also creates a new blocking item
  (`CNF-182`): the flag must **default to test**, or an accidental conformance run buys a machine.
- **This document had misattributed `API-15`'s design.** A note claimed Hetzner's own order
  request carries a field named `i_want_to_spend_money_to_purchase_a_server`, offered as evidence
  that the provider independently arrived at explicit purchase acknowledgement. That identifier is
  `hrobot-rs`'s *Rust field name*; the wire parameter is plain `test`. The claim is corrected in
  place in `08-provider-notes.md`.

*The methodological lesson is the one worth keeping, and it now has three instances rather than
one: the whole correlator design rested on a provider fact nobody had checked (`F1`); the
disqualifying detail was documented in a client library the whole time; and a flattering claim
about the provider turned out to be about a library author. **A caller-controlled field is only a
correlator if writing to it is free**, absence of a documented side effect is not evidence
(`PRV-30`), and reading the client source is cheaper than every audit that missed this.*

*Re-scoped by `ADR-0010`, and in the direction that matters.* Robot is now the flagship product
rather than one of several, which raises the stakes — but the launch set also contains two
providers this does not touch. **So `F29` blocks the Robot driver, not the launch**, and the
verification belongs before that driver is written rather than before anything ships. Had v1 been
Robot-only, this unverified claim would have been a single point of failure for the entire
product.

**F30. CLOSED 2026-08-12.** The rewrite had landed in two files and stopped; the sweep is now
done. The rename reached `PRV-13b`'s formula (`commitment_sats = …`), `operations.commitment_id`,
`SEC-46`, `00`'s withdrawn-non-goal note and the checklist's four remaining money uses. The one
substantive defect is fixed in place: **`PRV-13e` is AMENDED** — a higher re-derivation re-sizes
the machine's single commitment via `LDG-34`'s conditional write; the withdrawn "an additional
hold is placed" would have reintroduced the double-count `LDG-9` was amended to remove. The
missing tests exist (`CNF-160`–`CNF-165`: the meter's idempotent debit-plus-decrement, billable
`stopped` and `cancellation_scheduled`, the setup-fee debit, per-tenant serialization under load,
`OPS-36`'s late arrival, `OPS-38`'s many-case), and the five mis-tiered items are promoted with
the reasoning recorded in the checklist's tier-corrections note (`CNF-99`, `CNF-77`, `CNF-24`,
`CNF-113`, `CNF-115`). Blocking set 113.

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

## Two holes found while checking the surface — 2026-08-12

Looking at `04-api-contract.md`'s surface table to answer a different question turned up two
things neither audit caught, because both audits read the requirements and the table is not one.

**There was no way to read a balance.** Under `ADR-0002` a prepaid balance is the entire spending
authority, and no endpoint returned it. A caller — software, with no human — could learn its own
solvency only by attempting a create and being rejected with `insufficient_balance`. That turns an
ordinary question into a failed write and pushes an autonomous agent toward **retrying purchases
to discover whether it can afford one**, which is the tiering rule's question (3) answered yes for
a provider mutation. `API-47` fixes it; `CNF-150` is BLOCKING.

**The surface table was a day behind the requirements, twice.** Enrolment shipped 2026-08-11 and
funding on 2026-08-12, each with mandated endpoints that appeared nowhere in the table — and each
exempted itself from `API-1`'s `202`-and-an-operation rule in its own paragraph. `API-48` now
states the synchronous set once and closes it. `CNF-149` runs the diff in both directions.

*This is `F19` in miniature and the same root cause: the wire surface is maintained by hand in
prose, so it drifts silently every time a decision adds an endpoint.*

## Completion — 2026-08-12

**How the caller learns an operation finished was never specified**, and the question was put to
a three-model panel (Fable, Opus, Codex) after the interviewer's own recommendation — a cursored
change feed — was challenged. **All three independently rejected it for v1** and converged on the
same answer: polling with server-chosen pacing, written as `API-49`–`API-54`, `STO-33`, `DOM-21`,
`CNF-152`–`CNF-158`. No ADR, by the rate-source precedent: the transport is cheap to reverse
behind the endpoint; what is expensive — the pacing contract, the rate-limit invariant, the
retention horizon — landed as requirements.

The shared reasoning is worth one paragraph because it corrects a framing error. The durable
operation record already *is* the completion guarantee — `OVR-4` made every outcome a persistent
row, so a missed event is impossible by construction, and every push mechanism would re-deliver
what the store already promises. And the list endpoint already gives one request per interval
regardless of fleet size, so the feed's headline benefit existed before the feed. What was
actually missing was the half nobody had written: who sets the polling cadence (`API-49`), what
the rate limit promises a compliant poller (`API-50`), and what an autonomous caller may do with
`needs_reconciliation` (`API-51` — re-issuing under a fresh key is a second purchase, and the
panel unanimously called this the most expensive way for "finding out" to go wrong).

**Rejected, with the reasons recorded:** SSE (browser `EventSource` could not carry the signed
headers `API-39` then required — now moot since auth is a bearer token, but `EventSource` still
cannot set `Authorization`; a held stream caches an authorization decision, so a suspended tenant keeps
streaming past `SEC-45`'s deadline); long-poll (its naive implementation — parked handlers
polling the store on a timer — rebuilds `DEF-11` with customers as the trigger); webhooks (the
process holding every provider credential initiating outbound connections to caller-chosen hosts
is an SSRF primitive and an egress path out of `OVR-10a`'s boundary — this holds even if
server-side integrators appear, so their appearance does not reopen the question); the change
feed (deferred, not refused — `STO-6` now carries the note on what its cursor requires, because
that primitive silently breaks on a server engine).

**The panel also found two defects the question wasn't about.** A pending tenant could not
observe its own activation — the funnel's happy path ended in probe-by-purchase (`API-52`,
`CNF-155` BLOCKING). And a poll past the retention horizon answered "never existed," inviting a
re-send (`DOM-21`'s `gone`, `STO-33` aligning the two horizons `STO-14` and `STO-25` had left
free to cross).

**F31 — opened and closed the same day.** Whether system-initiated mutations mint tenant-visible
operation records. → `OPS-39`: **yes, for provider mutations** — exhaustion cancels and late-
attach cleanup go through the queue (lock, lease, `needs_reconciliation` and all, because an
ambiguous cancel is ambiguous regardless of who asked) and appear in the tenant's list as
`requested_by: system` with a reason. Pure balance events mint nothing; the ledger is already
that record. The deciding observation: these mutations need the queue's safety machinery
*anyway* — an exhaustion cancel outside it is a blind mutation against a customer machine — so
tenant visibility was the only genuinely open part, and hiding a machine's destruction from its
owner's history had nothing arguing for it. `CNF-159` is BLOCKING.

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

**F6. Re-scoped 2026-08-12: gates the Cherry driver, which `ADR-0010` left out of v1.** The only
password-only rescue in the notes is Cherry's; Robot rescue is key-based and Hetzner Cloud
accepts keys, so no launch-set driver hits this. The interface gap is real and stands for
whenever Cherry ships: begin-rescue always
receives an ephemeral public key, and `PRV-17` forbids accepting-then-ignoring it. No
alternative access-request variant exists, so a password-rescue provider cannot conform.

**F10. CLOSED 2026-08-12** (`DOM-22`): `remote_console` withdrawn (non-goal with no operation
behind it), `attach_iso` and the `iso` image source withdrawn from v1 (no driver operation ever
specified, no launch provider exposes it), `list_offers` added so `OVR-2`'s discovery rule holds
for the offers endpoint. The `adopt_existing` half had already closed via `PRV-28`. *Original
text:* `adopt_existing` is
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

**The credential half is also closed** — though the mechanism changed: `API-39` first chose
caller-supplied keys, then reversed (2026-08-13) to a **hashed** bearer token. Either way the
store holds no usable customer secret, which is the mitigation this finding called cheapest and
untaken; hashing gets it without a signing protocol.

**The last piece closed 2026-08-12: `OVR-10c`.** Credentials are read once at startup by the
owning module and scrubbed from the process environment, so after initialization the only copy
lives inside the owning type and an environment dump from the public surface discloses nothing.
`CNF-173` (BLOCKING) tests it by reading the environment at runtime rather than reviewing the
scrub call — the type-visibility mistake `CNF-71` made, not repeated. What survives of `F13` is
implementation proof, which is where a specification finding is supposed to end.

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

**F12. CLOSED 2026-08-12.** The conflict resolved on a capability fact: for iPXE (and the now-
withdrawn ISO mode) this system never touches the bytes, so `SEC-16`'s "every custom image" was
demanding an attestation nothing could check. `SEC-16` AMENDED to `DOM-14`'s scope — digests for
what the system writes — with the out-of-reach cases stated as out of reach rather than implied
covered.

**F18. CLOSED 2026-08-12.** Each vague MUST now carries units and a procedure in place:
"measured" = worst observed over ≥20 real deletions, recorded with sample size and date, with a
declared conservative bound until then (`PRV-13b`); "materially in the future" = beyond one
re-derivation period plus wind-down (`PRV-13c`); `SEC-39`'s interval defaults to one hour with
stated integer ceilings; `SEC-42`'s "enforce what it can" = checkable at request time from held
data, everything else explicitly a terms obligation; `RSC-30`'s storage = content-addressed or
version-pinned; `API-26`'s range = 1–200 default 50 (`WIR-32`). `PRV-13b`'s haircut ambiguity
had already been fixed with `F18`'s earlier half. *Original:* "measured worst-case delay," "materially in
the future" (`PRV-13c`), ceilings "per interval" (`SEC-39`), "enforce what it can" (`SEC-42`),
"a sane range" (`API-26`), "controlled, immutable storage" (`RSC-30`). No units, thresholds,
measurement procedure or pass/fail boundary. `PRV-13b`'s formula also leaves ambiguous whether
the FX haircut multiplies the whole reserve or only part of it.

**F19. CLOSED 2026-08-12 — see `F23`.** *Original:* In ~2,600 lines there is exactly one JSON example —
the error envelope. No request or response body for any endpoint. The idempotency header is
required by `API-8` and never named; likewise the tenant-override header and the destructive
and purchase acknowledgement fields. `CNF-21` tests "byte-equivalent body" against a contract
nobody wrote, so every implementer invents one and the checklist blesses it. `API-13` also
omits `PRV-8`'s minimum-one-key create rule. **Two competent implementations will not
interoperate.**

**F20. CLOSED 2026-08-12** by `OPS-40`: minimum URL validity checked at accept against the
stated admission-to-start bound, a deterministic pre-destructive gate at claim, mid-stream expiry
classified as an ordinary install failure, and requeue's fresh payload (`OPS-34`) as the refresh
path. *Original:* `OPS-2` persists the
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
