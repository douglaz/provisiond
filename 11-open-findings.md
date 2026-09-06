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
   issued (`API-32`–`API-37`, `STO`'s `tenants` table); per-tenant spending ceilings were replaced as the *authorization* mechanism (`SEC-39`'s
   destruction and creation ceilings remain, as abuse bounds rather than spending authority)
   because
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

## Closed by measurement — 2026-09-04

**F37. `PRV-34`'s free-verification claim was false, and only `CNF-180`'s hedge survived contact.**
`PRV-34` said test mode meant "the entire dedicated ordering path — request shape, authorization,
the transaction listing, and the correlator round-trip of `PRV-32` — can be exercised against the
**live** API without a setup fee or a server."

**A `test=true` transaction is not listed.** Placed against `/order/server/transaction` on
2026-09-04: `201 CREATED`, `status: "cancelled"`, the correlator echoed in the response body — and
then `404 NOT_FOUND "no transactions found"` from both the listing and `/transaction/{id}` for the
transaction just created. Test mode exercises the **order** half and none of the **resolution**
half, which is the only half `PRV-32` exists for, because Robot resolution *is* matching a
fingerprint in that listing.

`CNF-180` already carried the hedge — "If simulated transactions do not appear in the listing, one
real order closes the remaining half" — so the checklist survived intact and the prose did not.
`PRV-34`, `PRV-32` and `08-provider-notes.md` are amended.

**What the real orders then settled.** Two auction orders (about €0.16 in total, both cancelled
immediately) confirmed the correlator round-trip *and* the property `F36` turns on: two distinct
fingerprints each matched **exactly one** transaction. `OPS-13` requires that "Resolution uses the
entry of the attempt **whose correlator matched**", and on Hetzner Robot two attempts genuinely
carry distinguishable correlators — an observation now, not an argument. **`F36`'s surface is
therefore Hetzner Cloud and DigitalOcean alone**, and on those two the setup fee is `0`, so it is
an install-safety problem rather than a money one. `CNF-280` is the new item that keeps a driver
honest about the discrimination, which `CNF-180` alone never tested.

*This is the fourth provider premise in this set to fail on contact — `F1`'s correlator premise,
`PRV-30`'s `comment` field, `PRV-26`'s create-only scope, and now this. Unlike the first three it
was not findable by reading a client library: the documentation says `test` means the order "will
not be processed", which is entirely consistent with the transaction never existing. Three audits
and two cross-model reviews read the claim without doubting it. It took eight cents.*

## Open — found 2026-09-05

**F38. `target` is undefined, and the set spends the word three ways.** `OPS-34`'s requeue
equivalence check runs over "kind, machine, provider account, **target**", `OPS-13` reasons from the
same four, and `CNF-221` tests them by name — but `target` is defined nowhere, is not a column in
`05-persistence.md`, and is not in `CONTEXT.md`. Meanwhile `WIR-20` and `RSC-26`/`RSC-27` use
`target` for **the disk about to be overwritten**, and `API-17b` uses it for the thing a verb
authorizes against, stating that "Creation … is the only operation that has no target to authorize
against." Read through `API-17b`, a create's `target` is null and the check collapses to kind plus
provider account.

**`ADR-0014` removes the create case rather than defining the word, and the word is still
undefined for every kind that remains.** The deeper defect is the relation, not the noun: `OPS-34`
demands equivalence "in every respect the summary records" while `OPS-13` makes the offer snapshot
"evidence, not a comparison field", so which retained facts participate is unstated — and
`request_summary`'s own opening description is "what was attempted", which nothing enumerates. The
remedy is a per-kind table of comparison fields, not a fourth meaning for one word.

**F39. `OPS-46`'s admissible set was hand-enumerated against a test that cannot be applied, and it
admitted two kinds that fail it.** Found 2026-09-06, one day after `OPS-46` was written, by
following its own reasoning to the kinds it granted instead of the one it withheld.

`OPS-46` admits "kinds whose payload the operation record fully determines". **That test is
unanswerable today**: `05-persistence.md` enumerates `request_summary`'s contents for a create and
for no other kind, and everything else is "what was attempted", which nothing defines (`F38`). The
enumeration was therefore a guess dressed as a derivation.

- **`install` fails provably.** `WIR-20`'s body carries the image `source.url` and `sha256`,
  `authorized_keys`, the `layout`/`target` naming the disk to overwrite, `post_install_script`,
  `acknowledge_destruction` and the `trust` object — and `STO-9` purges "signed image URLs, SSH
  keys, and up to 1 MiB of post-install script" by name. It was withheld for the right reason and
  the reason was understated: this is worse than the create case, because the operator would choose
  the bytes written to a customer's disk and the host-key decision `SEC-22` requires the *caller* to
  make.
- **`adopt_machine` fails provably, and was granted.** `WIR-18` carries `runway_seconds`; `LDG-36`
  makes adopt "place a commitment and pass the same authorization check as create". An operator
  requeue therefore chooses how much of the customer's balance to commit — `ADR-0014`'s own
  argument, on a kind that ADR admitted in the act of making it.
- **`power` and `reverse_dns` were granted on presumption.** Nothing says their payloads survive,
  `WIR-19`'s action distinguishes `on` from `hard_reset`, and `WIR-21`'s `ptr` is a customer-chosen
  hostname of the kind `ADR-0005` purges.

**Amended rather than left open**: `OPS-46` now admits only the exposure-reducing cancellation,
which `API-7` had already identified as the load-bearing case — "a suspended tenant's failed
cancellation must stay requeueable or its machine bills forever" — whose payload is one literal, and
which is the only kind **no caller will re-issue**, being system-triggered under `OPS-39`. Every
other kind is the caller's own action on a machine the caller owns, costs nothing to repeat, and is
re-issued by calling the endpoint again.

*The lesson is not that the enumeration was careless. `OPS-46` opens "requeue is admissible only for
kinds whose payload the operation record fully determines, and `create_machine` is not one of them"
— a test, followed by an answer that no available record could have produced. A derivation and a
guess read identically once both are written down, and only the guess needs `F38` discharged before
anyone can check it. `F38` was already open when this one was written.*

## Closed by decision — 2026-09-05

**F36. Resolution cannot identify which attempt landed when the correlator is the operation UUID,
and two requirements assume it can.** → **`ADR-0014`**. A create can no longer be requeued, so a
create has exactly one attempt, one correlator, one offer snapshot and one setup fee, and "the entry
of the attempt whose correlator matched" has nothing left to disambiguate.

*The finding was narrowed twice before it was closed. A live probe on 2026-09-04 (`F37`) established
that Hetzner Robot's per-order key does discriminate attempts, which removed Robot from the surface
and left Hetzner Cloud and DigitalOcean — where the setup fee is zero, so what remained was an
install-safety problem rather than a money one. The remedy considered at that point was a
fail-closed intersection of `install_strategies`. It was overtaken: the mechanism that produced
multiple attempts turned out not to be defensible on its own terms.*

**The original finding, retained because the reasoning is the record:**

`OPS-13` states the mechanism twice: `request_summary` "holds a list aligned one-to-one with
`correlator_value`", and "Resolution uses the entry of the attempt **whose correlator matched**".
`PRV-26` states the opposite case: "Where the correlator is the operation UUID the list simply holds
that one value, however many attempts were made."

**Both are true, and together they leave the selection undefined on two of the three launch
drivers.** Hetzner Cloud and DigitalOcean take a free caller-controlled field, so every attempt of a
requeued create carries the *same* correlator; a search that matches it selects no particular
attempt, and there is nothing for "the entry of the attempt whose correlator matched" to name. Only
Hetzner Robot, where `PRV-32`'s per-order key differs per attempt, has the discriminator the rule
assumes. `WIR-35`'s operator `observed` verb does not close it either: it carries an `external_id`
and no attempt index.

**What rides on it.** `machines.install_strategies` is a safety gate whose absence authorizes a
disk-wiping install (`05-persistence.md`), and `LDG-39` debits the matched attempt's at-cost setup
fee — so the wrong snapshot is both a destroyed disk and a wrong charge. `CNF-257` is BLOCKING and
tests that a create whose *earlier* attempt landed attaches that attempt's snapshot, which is a
behaviour with no mechanism behind it wherever the correlators are identical.

*Found by a cross-model review of `DOM-30`, which had asserted the mechanism as settled while
describing something else. The set has been here before: `F1` closed on a correlator premise nobody
had checked, and `PRV-30` and `PRV-26`'s create-only scope were the two that failed on inspection.
This is the third — and unlike those, it is not a provider fact but an interaction between two of
our own requirements.*

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

**F25. CLOSED 2026-08-13 by operator decision — and not the decision the finding expected.** The
finding framed this as needing counsel: `LDG-17` requires holding satoshis equal to the float,
`LDG-19` required *publishing* that invariant, and `ADR-0004` §4 forbids describing balances as
"held", "backed", "reserved" or "segregated" — a published one-to-one asset-to-claim ratio being
what safekeeping looks like from outside whatever the contract says.

**The operator resolved it without a lawyer, on plainness rather than law: say nothing.** Any
public statement here requires the reader to hold two apparently opposed ideas at once — the
operator is fully reserved, *and* the customer holds only a contractual claim — and every shorter
phrasing collapses toward the banned custody words. A statement a reader will misunderstand is
worse than silence.

**What it costs is recorded rather than glossed:** publishing was the only mechanism converting a
later solvency breach into actionable misrepresentation, and that protection is now gone; a
customer's recourse on operator failure is unsecured creditor status. `ADR-0004`'s consequence
bullet asserting the opposite is reversed in place.

**`LDG-19a` guards the obvious misreading:** silence about the *ratio* is not silence about the
*arrangement*. The terms MUST still state that a balance is an unsecured claim, because saying
nothing at all lets a customer assume safeguarding — the same misrepresentation reached by
omission. Publish no assurance; publish the disclaimer. Nothing internal changes: `LDG-17`,
`LDG-18` and `LDG-20` all stand, so **the operator remains fully reserved and simply declines to
advertise it.**

*This leaves the refund question `ADR-0003` nominates as the first item for counsel — no longer
second to anything.*

**F26. CLOSED 2026-08-12** by `PRV-31`: a driver declares a per-offer worst-case cancellation
bound before any order, the commitment is sized to it at create, and the machine's actual date —
read after ordering — lowers `protected_sats` at the first re-derivation, lengthening runway
rather than resizing the commitment (`PRV-31`, `ADR-0011`). An offer with no declared
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
hold is placed" would have reintroduced the double-count `LDG-9` was amended to remove.
**`ADR-0011` later went further and withdrew the resize itself**, so `PRV-13e` now recomputes
`runway_until` and nothing resizes a commitment automatically — this paragraph records the
intermediate state, not the final one. The
missing tests exist (`CNF-160`–`CNF-165`: the meter's idempotent debit-plus-decrement, billable
`stopped` and `cancellation_scheduled`, the setup-fee debit, per-tenant serialization under load,
`OPS-36`'s late arrival, `OPS-38`'s many-case), and the five mis-tiered items are promoted with
the reasoning recorded in the checklist's tier-corrections note (`CNF-99`, `CNF-77`, `CNF-24`,
`CNF-113`, `CNF-115`). Blocking set 113.

## The funding decision — 2026-08-12

**`ADR-0008` chose two rails, and a deposit is one object payable over either — the payer picks.**
*(An earlier phrasing here, "Lightning primary, on-chain fallback", is the first draft that ADR
withdrew within the hour.)* `LDG-42` had required a
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

## The abuse-surface grill — 2026-08-16

**F34 is CLOSED**, and `F35` with it. The surface deferred on 2026-08-15 was designed by
interview and is now specified: `DOM-23`–`DOM-26`, `STO-39`–`STO-42`, `API-59`–`API-60`,
`WIR-43`–`WIR-45`, `SEC-54`, `LDG-71`, `CNF-222`–`CNF-230`, and `ADR-0012` for the decision the
rest hangs from — **the operator is the only party that speaks to either side, and nothing is
relayed in either direction.**

**Three of the seven answers dissolved machinery rather than sizing it**, which is the pattern this
project keeps producing:

- **No allegation taxonomy.** The case carries the operator's own prose. Once ingestion is a person
  transcribing a notice, provider-neutrality is produced by the rewrite, and a class set invented
  before three real notices would put its own traffic in `other`. The rule that survived is
  narrower and more useful: *structured what the agent must compute, prose what it must
  understand* — the deadline and the machine id are fields, the allegation is text.
- **No second deadline.** F34 had called for two, the tenant's earlier than the provider's. Only
  the tenant's is stored (`STO-39`); the provider's stays in the operator's inbox. "Two deadlines
  and only one is real" is then true by construction, and a date the tenant must never see cannot
  leak from a field that does not exist.
- **No `DOM-7` state for a blocked machine** — the conclusion held, though the reason first given
  for it was wrong twice over. `DOM-27` owns it now: a restricted machine is still `running` or
  `off`, `DOM-7` is single-valued, and collapsing them destroys the state `LDG-37` reads to decide
  billability. See below for what the original reason claimed.

**One new defect was found while checking whether `SEC-45` was satisfiable, and it was the most
serious thing in the session.** `SEC-45` claimed resolution was *"answerable from `machines`
(`public_ips`, …)"*. It was not: `public_ips` is current state overwritten by every refresh
(`DOM-8`), so an address plus an **instant** had nothing to bind to. Providers reissue addresses
within days and the ordinary sequence is that the customer deletes the machine *before* the notice
arrives — so resolving against current state names whichever tenant holds the address today, opens
a case against an innocent customer, and invites them to explain a machine that was never theirs.
**A wrong accusation and a cross-tenant disclosure, performed by the operator, by following the
rule.** `STO-41` adds the observation history and `SEC-54` requires the answer be a candidate set;
`CNF-222`/`CNF-223` test both directions. *Note that every design which relays the provider's
notice hides this defect, because the provider's own records do the resolving — owning the channel
is what exposed it.*

**Two decisions went against the recommendation and both are the record's, not the reviewer's.**
The tenant's statement is **free text**, not a structured cause-and-remediation pair: closed sets
guessed in advance fit nothing, and the operator reads every reply at v1 volume anyway. And
forwarding a statement verbatim is the **operator's per-case call** rather than categorically
forbidden — sometimes the customer's own account is the most credible thing to send. The
half-measure objection was answered by making the decision an artifact: composing is the default,
`sent_verbatim: true` is an explicit recorded act naming the statements it covered, and the tenant
can see that it happened (`WIR-44`).

**Still deliberately absent.** Nothing here handles an account-level notice (one that names no
single machine), repeat-offence policy across cases, or any provider signal that a case has ended —
there is none, so `DOM-24` makes closing an operator act. The first notice handled end to end will
say more about all three than further editing would.

### The two-reviewer pass on the same day

Codex (`gpt-5.6-sol`, xhigh) and Opus reviewed the change against the full set. **Both returned
"not buildable as written"** — 28 findings and 14 — and converged, independently, on the same
defects. Neither disputed any of the seven decisions; every finding was about their specification.

**The worst one was the same defect this change was written to fix, one layer down.** `SEC-45` had
named a capability the schema did not have; `STO-41` replaced it with a capability *the runtime
does not exercise* — the history was bound to "the refresh that already maintains `public_ips`",
and **nothing in this set refreshes a machine on a schedule** (`OPS-14`'s sweeper moves expired
operation leases; refresh is a caller-initiated write). For the ordinary machine — created, then
left alone — the table would hold one row or none, the notice's instant would fall in no window,
and `SEC-54` would return the empty set that `CNF-223` calls correct. Every conformance item in
this change passed, on a fixture that happened to call refresh. `STO-41` now binds the write to
every path that writes `public_ips`, and `CNF-222` runs on a machine that was never refreshed.

Applied from that pass: the append-only rule and the purge were a literal contradiction (`STO-40`);
the retention clock was a citation to `STO-14`, which reaches settled operations and nothing else
(`STO-43` now states it, and `DOM-25`'s headline was narrowed from "nothing fires on a timer",
which forbade the retention timer `ADR-0005` requires); `/v1/address-resolution` was in the surface
table with no wire contract (`WIR-46`); `WIR-34`'s operator-route list was not amended, which is
the closed-list drift the change had carefully avoided in `API-48`; the new writes had no
idempotency rule, so an agent's retry would append a second permanent statement to a list nothing
may delete; `WIR-9a`'s conflict-reason union was closed and lacked `case_closed`; a machine can
have two open cases and the machine view embedded one; `STO-39` carried a `provider_account` both
reviewers asked to delete; `CONTEXT.md` still described an allegation *class* the design had
abolished; the `sent_verbatim: true` fixture was not verbatim; and `ADR-0012`'s own summary —
*"nothing is relayed in either direction"* — was false in one direction by its own decision.

**`CNF-224` was impossible and would have failed every conforming implementation.** It asserted the
provider's *name* was absent from the customer surface, while `WIR-11`'s machine fixture carries
`provider_account: "hetzner-cloud-1"` and `WIR-29` returns the account kind. The ban is on the
notice — reference, link, wording, third parties — never on the fact that Hetzner hosts the
machine. Overreach in a rule of this kind is not harmless: it is the half that gets discovered by
being unbuildable, after the half that matters has already been weakened to make it pass.

**Cleared on inspection:** the `API-48` amendment is correct, `API-54` is not violated (the
`last_seen` write belongs to a refresh operation, not a `GET`), and `LDG-71` does not conflict with
`LDG-13`, `LDG-33`, `LDG-37` or `DOM-19`.

### The adjudication that followed, and the claim it destroyed

One defect from that pass needed a decision rather than a fix: `consequence` was written once at
open, and the provider's block lands *after* the deadline — so at the moment the machine goes dark,
the frozen text still read "the provider **may** block". Three options went to both models: an
amend verb alone, an amend verb plus a `machine_blocked` boolean on the case, or plus a
`billing_continues` boolean.

**Both rejected all three and returned the same fourth answer independently: the structured fact
belongs on the machine, not on the case.** Their reasons differ and both are kept. A machine may
have two cases open at once (`STO-39`), so a case-level flag lets two rows answer one physical
question. An account-level action (`SEC-41`) darkens every machine and opens *no* case, leaving the
disclosure structurally unmeetable. And the signal's real job is not to prompt an agent but to
**stop** one: an agent seeing `running` plus a draining runway plus timeouts concludes the machine
is sick, and reaches for reset, rescue and install — which `CONTEXT.md` defines as destructive by
definition. Without this field the design invites a customer's disk to be wiped in an attempt to
fix a network block no reinstall can lift.

**The claim that did not survive:** `LDG-71` had just been trimmed to say the machine keeps billing
"because nothing knows it is blocked", and the `DOM-7` exclusion rested on the block being an
operator's email rather than provider truth. A web-searching reviewer checked. **Hetzner Cloud
exposes `blocked` per address family on the server object and Robot exposes `locked` per IP**, both
separate from lifecycle status (`PRV-35`, `[verify]`). A driver can read this today. The other
reviewer, without web access, had predicted exactly this — that the rationale was "contingent on a
provider fact and evaporates the day someone reads the hcloud docs" — and it had already been
copied into three documents. **The conclusion survived on a durable argument (orthogonality: a
restricted machine is still `running`, and `DOM-7` is single-valued); the reason was replaced and
the copies collapsed to one.**

Also settled: `warned_consequence` is written once and never edited — it states what the notice
threatened, the machine's field states what is true, and two fields answering different questions
cannot contradict each other. Only `respond_by` moves, appending its prior value (`STO-44`),
because a caller planned against the original date and a record showing only the extension cannot
say whether the tenant got the time it was told it had. A provider that escalates has sent a new
notice, which is a new case — so nothing else needs to move. **Accepted cost:** an operator typo in
`warned_consequence` is permanent.

**Deleted in the same pass**, all three named by both reviewers: the constant sentence "the machine
stays allocated and keeps consuming runway while blocked" from the `warned_consequence` fixture —
true of every case that will ever exist, which is the exact argument that killed
`billing_continues`; `CNF-228`'s "the case's `consequence` states the drain", a conformance item
that tested whether English said a thing; and two of the three copies of the `DOM-7` rationale.

## The engineering review — 2026-08-15

Read `03`, `05` and `12` as **build instructions** rather than for internal consistency, which is
what sixteen prior passes had done. The distinction matters: none of what follows is a
contradiction between two passages, which is why every one of those passes walked past it.

**Seven items were closed in place** — `ledger_entries` had no column list at all (`STO-38`); the
*billing period* was load-bearing in five requirements and defined in none (`LDG-68`); nothing
bounded `LDG-35`'s serialization to its own transaction (`LDG-69`); `OPS-36`'s survival path was
defeated by the cancellation its own transaction enqueues (`OPS-41`); `wind_down_cost` omitted the
time a cancellation waits for the machine lock (`PRV-13b`); `SEC-45` rested on a false premise
about abuse handling; and nothing said which of three stated forms of "the balance" authorizes a
purchase (`LDG-70`). `CNF-214`–`CNF-221` test them, and `CNF-221` closes the gap that `OPS-34` —
the requirement that made requeue implementable after `ADR-0005` — had no conformance item at all.

**One finding was raised and refuted, and the refutation is worth more than the finding.** The
review asserted a live lock-order inversion between the per-machine lock and the per-tenant money
serialization. Two independent reviewers refuted it on the same reading: `OPS-8` binds the lock to
an operation that *names* a machine, and a create's `machine_id` is set only on completion
(`05-persistence.md`), so a create holds no machine lock and `OPS-27`'s money transaction never
nests inside one. What survived was the *absence of a boundary rule*, now `LDG-69` — and the
observation that today's safety is accidental, resting on `LDG-25` pricing privileged operations
at zero so that `operation_fee_debit` is defined, paired, and posted by nothing.

**F34 — there is no way to answer an abuse notice, and the design removed every channel. CLOSED
2026-08-16** — see the grill session above; `ADR-0012` and `DOM-23`.
Correcting `SEC-45` established what the obligation actually is — relay an allegation to a tenant,
take back a statement, and answer the provider as its counterparty — and the specification has no
surface for either direction. `ADR-0005` collects nothing, so there is no email and no contact;
`12-billing-and-ledger.md` states the consequence directly in another context: *"a caller that is
software will act on a number long before it would act on an email, and there is no email."*

The decided shape, not yet specified: a **provider-neutral** abuse case on the tenant's read
surface (machine, allegation class, deadline, consequence), a tenant-submitted statement as an
ordinary API write, and operator review before anything reaches the provider. **The provider's own
case reference and statement link MUST NOT be relayed** — that link is a single-use bearer
credential whose use *concludes the deadline*, confirmed against a real notice, and handing it to
an autonomous caller lets a poll loop end the operator's window in the first second. This is
`SEC-39`'s reasoning arriving somewhere new.

Two obligations fall out that nothing currently carries: the tenant-facing cutoff must sit
**earlier** than the provider's by however long operator analysis takes, so there are two
deadlines and only one is real; and the statement is caller-supplied free text, which is where
`13-wire-contract.md`'s existing rule applies — *"not a name, an email, or a transcript"* — or the
abuse channel becomes the one door identity walks through.

*Deferred deliberately, then taken up the next day.* The reasoning for deferring — a new product
surface in a v1 that `ADR-0006` makes pass-through, no external customer to validate against, and a
shape that changed with every answer — held right up until the design was walked branch by branch,
at which point three of its parts turned out not to need building at all.

**F35 — a provider-locked machine keeps billing and has no state. CLOSED 2026-08-16 by `LDG-71`:
it keeps billing, the case must say so, and delete stays available.** The provider's routine
remedy is to **lock** the offending server, not terminate it. A locked machine is still allocated,
still charged for, and unreachable by its owner — so `LDG-33` keeps draining `runway_until` for
compute the customer cannot use, and `LDG-13` eventually cancels it for exhaustion having billed
the whole way. `DOM-7` has no state for it, `LDG-37` has no rule for whether it is billable, and
the machine view gives its owner no way to tell this apart from a machine that is merely broken.
Note the tension before deciding: the *provider* is still charging the operator, so making it
non-billable moves a real cost onto the operator for a condition the customer caused.

## The skeptical audit — 2026-08-14

Six review passes each *added* text. Nobody had asked what should come out, so a skeptical audit
was run against the opposite question: what here is **not** required for correctness, security or
data safety? It returned **25 candidates**, and its closing observation is the one worth keeping:

> six review passes each added text to fix contradictions that earlier added text created — the
> duplication classes are not just bloat, they are the mechanism generating the defects the
> passes keep finding.

That is correct, and it is visible in this file's own history: `SEC-46` restated `LDG-32`, drifted,
and shipped an amendment claiming to have applied while the requirement said the opposite.

**Accepted and applied.** `OVR-10`'s separate-service form (settled by `ADR-0001`, kept alive as a
live option for weeks, and the reason `API-30`/`SEC-40`/`CNF-66`–`CNF-68` exist); `DOM-1a`'s
no-registry branch (settled by `ADR-0002`); `DOM-12` (folded into `DOM-11`, which forbids the
persistence its round-trip rule described); `custom_ipxe` (deferred by the `DOM-22` precedent — no
launch driver declares it); `LDG-38`'s restatement of the meter key (which had drifted to the
withdrawn form in the same document that withdrew it); and a scope note on `07-security-
requirements.md` making it cite rather than restate rules owned elsewhere.

**Rejected, with reasoning.** `API-53`'s operation `revision` — the audit called it cuttable for a
pre-SDK product, but it is one integer that arbitrates genuinely out-of-order polls, and the
caller is software polling concurrently by design (`API-49`). Removing it would trade a field for
a stale-read class that no other requirement covers. This is the loop's first rejection, and it is
recorded here rather than left as silence, because six passes with zero rejections was itself a
signal worth answering.

**Held for the operator, not applied — CLOSED 2026-09-02.** Cutting `API-33`'s enrolment issuance
delay. The audit is
right that its original justification evaporated — it existed to protect the single moment a
server-generated token crossed the wire, and `API-33` now mints both secrets in the enrolment
response — so what remains is friction against a naive script that `API-36`'s rate limit,
`API-41`'s global ceiling and `API-34`'s time-to-live already bound. But removing it deletes
`issuable_at` and everything keyed to it, which changes the enrolment product rather than tidying
it. **F33.**

*Closed by the 2026-09-02 review, which found the two halves had been half-applied and were
contradicting each other: `API-33`'s 2026-08-31 amendment moved the delay in front of the
pending-tenant slot and said so, but the admission token it introduced had no route, no field and no
place on the surface table — so `WIR-12`'s `{}` body and `WIR-2`'s rejection of unknown fields made
**every enrolment unsatisfiable** — while `issuable_at` survived as a column, a response field and
two gates, leaving two delays in a set that described one. Both halves are now applied: the token
has `POST /v1/enrol/token` (`WIR-49`) and an `admission_token` field, and `issuable_at` is withdrawn
with everything keyed to it. The operator's hesitation was right about the cost and the finding
should not have been left open across two reviews while the requirement asserted it was closed.*

## The fourth audit — 2026-08-13, and the verdict was NO again

Two independent reviewers (Fable; Codex, running three parallel passes) read the full set after
the wire contract, the auth reversal and `ADR-0011` landed. **Both returned "not buildable as-is"
— 42 findings from one, 37 from the other, roughly 35 distinct blocking issues after
deduplication.** The convergence matters more than the count: they agreed, independently, on where
the set was weakest.

**The root defect was the same class as the last two: an entry kind the pairing rule forgot.**
`PRV-13b` put the setup fee inside the commitment; `LDG-39` debited it; nothing decremented the
commitment when it was debited — so on the *ordinary funded dedicated create* the ledger sum fell,
the reservation did not, and `available` went negative by exactly the fee, violating `LDG-10`.
**That is the 2026-08-12 hold double-count, reintroduced through `setup_fee_debit` while the
rewrite that fixed it was still the newest text in the file.** `CNF-162` tested the debit and
never the decrement.

**The most serious finding was one neither I nor two prior audits had seen: a path to destroying
the wrong disk.** A caller names `/dev/sdX` before any inventory exists, device ordering can
differ across boots and between rescue and the installed system, and nothing forced an abort on
mismatch. Every requirement in `06-rescue-install.md` could be satisfied while the customer's data
was destroyed. `RSC-26`/`RSC-38` now bind the target to a serial or WWN plus an inventory
fingerprint, re-verified immediately before disk I/O.

**And one finding corrected my own reasoning, on which a decision had already been made.** The
2026-08-13 auth reversal argued that a stolen customer credential "can only burn the victim's
prepaid balance — nothing extracts". **A customer credential also authorizes `install` and
`delete`.** The asset is the customer's data and running machines, not a prepaid card. That does
not disturb `API-39`'s choice of bearer tokens — a stolen key authorizes exactly the same
destruction — but it demolishes the conclusion drawn from it, that revocation earned nothing.
`API-55`/`API-56` add a recovery credential, and rotation authorized by the spending token is now
explicitly **forbidden**: a thief would rotate first and lock the owner out permanently.

**Fixed 2026-08-13** — in six batches, each committed separately: the setup-fee double-count and
its missing refund path; the absent `runway_until` formula (the obvious reading spent the
wind-down reserve, guaranteeing the operator was short at cancellation on *every* ordinary
exhaustion); per-tick rounding making price depend on metering cadence; rate-outage accounting
(`LDG-64`); debits exceeding the commitment; billable attachments outliving it; commitments
released on mere provider *unreachability*; `API-7`'s universal pipeline opening purchase
commitments on reboots and blocking deletion during a rate outage; the token-delivery model that
could strand a funded tenant on one lost HTTP response; enrolment idempotency as a global
unauthenticated namespace handing out other callers' capabilities; the three tables nobody defined
(`STO-34`–`STO-36`); provider-account assignment, which no requirement produced; tenant
suspension; `needs_reconciliation` being simultaneously terminal and expected to transition;
`OPS-36` seizing balance automatically; system cancels without deduplication and blocked by caller
ceilings; `WIR-20`'s missing provider-published host-key variant, which was silently downgrading
every Robot install to first-use trust.

**F32. CLOSED 2026-08-31 — answered by measurement, and the answer was half of each.** The question
was whether DigitalOcean offers an SSH-reachable rescue. **The reachability was never the blocker;
automated activation is.** The recovery environment exists, runs `sshd` and imports the droplet's
creation-time keys — but booting into it is a control-panel action. Two independent documentation
passes agreed, one grepping the published OpenAPI specification and finding no occurrence of
`recovery`, `rescue` or `iso` in any droplet context, and a live probe returned
`404 "The specified action type is not available."` for both `enable_recovery` and `recovery`
against an unlocked, active droplet. That is positive evidence of absence, which is what `PRV-30`'s
lesson demands of a claim in this direction.

So the driver declares no rescue capability. **But the differentiator survives there by another
route**, established by walking the whole custom-image path against the live API: import from a URL,
poll to available, build or rebuild, delete. `ADR-0013` makes that a second install feature —
`DOM-28`, `RSC-39`–`RSC-43` — because the promises differ: the provider converts the bytes, exposes
no checksum field, imposes its own guest requirements, and offers no way back into a machine that
comes up wrong.

**What was learned on the way is worth more than the finding.** The same test destroyed a documented
constraint the design would otherwise have inherited: DigitalOcean's product pages say a rebuild
must stay within one operating-system family, and **the API does not enforce it** — one droplet went
Ubuntu → Fedora → a custom Alpine image in under two minutes, every action reporting `completed`.
`PRV-13c` forbids encoding a provider's commercial terms as constants, and its first real test
arrived early: the term was not encodable because it was not true.

Two further facts came out of the same run and are recorded in `08-provider-notes.md` as measured:
droplet deletion is **eventually consistent** on the read path (`204`, then `200 "active"` eight
seconds later), which produced `PRV-36`; and image deletion is **not idempotent** and disagrees with
the read path (`422` from `DELETE`, `404` from `GET`, same id, same instant), which corrected
`OPS-11`'s claim that a 4xx means the provider did not act.

*`F29`'s methodological lesson now has a fourth instance, and this time the shortcut was not taken:
the provider fact was checked before the driver was written rather than after three audits.*

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
streaming after `SEC-45`'s suspension); long-poll (its naive implementation — parked handlers
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

**`ADR-0010` settles `D3`**, the launch-set question, open since the first session and never asked: v1 ships **Hetzner
Cloud, Hetzner Robot and DigitalOcean** — both machine shapes across two unrelated companies
(`OVR-14`–`OVR-16`).

The reason this was worth deciding rather than deferring is that **almost every difficult
requirement in this set exists for the dedicated shape**, and a cloud-only launch runs none of
them. The setup fee committed before the order and debited on acceptance, the reserve covering a cancellation date,
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
