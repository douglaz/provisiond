# provisiond — Executive Summary

*A single-file orientation to the specification set, for a reader who has never seen it.
Written 2026-08-14 against 660 requirements across 14 numbered documents, 11 ADRs and a glossary;
refreshed 2026-08-16 against 700+ requirements and 12 ADRs; §3 refreshed 2026-09-03 for the two
decisions missing from its survey. Re-derive the count before quoting it —
`10-conformance-checklist.md` records why numbers in this set go stale.*

---

## 1. What this is

`provisiond` is a **specification for a compute-reseller control plane**, and it contains no code
by design. A single **operator** runs the deployment, holds the accounts at hardware providers, and
pays their invoices. **Customers** prepay the operator and receive machines without ever touching a
provider credential. A **tenant** is the isolation boundary owning one customer's machines,
operations and balance. A **machine** is one VPS or dedicated server; an **offer** is a purchasable
configuration that is not yet a machine.

The problem it solves is that providers expose incompatible surfaces. A cloud VPS API offers
create/rebuild/delete against an image catalogue. A dedicated-server API offers an *ordering
system*, a rescue environment and an out-of-band reset, and expects you to bring your own operating
system. Unify those by intersection and you throw away the thing bare metal is for. So the set
unifies the **lifecycle** — create, adopt, refresh, power, rescue inventory, install, reverse-DNS,
delete — while
treating provider capability as first-class and discoverable at runtime.

The differentiator is that **rescue-mode installation is an orchestrated workflow rather than a
forwarded flag**: boot the provider's rescue system, authenticate it safely, inspect the disks,
fetch and verify an image, write it, and return to the installed system. What is normally a support
ticket becomes an API call. `ADR-0010` is blunt about the consequence: nearly every difficult
requirement in the set exists because of the dedicated shape. Cloud-only resale would be a thin
proxy.

v1 ships three drivers — Hetzner Cloud, Hetzner Robot, DigitalOcean — deliberately covering both
machine shapes across two unrelated companies, so that Hetzner-specific assumptions fail visibly
rather than silently.

The set was extracted from a Rust reference implementation that never compiled, had no tests, and
was holed in two of its load-bearing safety claims. What that code got right became a requirement;
what it got wrong became a prohibition in `09-known-defects.md`.

## 2. The caller is a program, and that changes the design

The **caller** — the software making requests for a customer — is expected to be an autonomous AI
agent, not a person at a console. The set takes that literally rather than decoratively, and it is
the most distinctive thing about the design.

**Confirmation flags stop being controls.** `SEC-39` states it directly: *"A per-request
acknowledgement is not a control when the caller is not human… An autonomous caller sets the flag
from a template on every request; it becomes a constant, and the safety property it was carrying
quietly disappears while the field is still present and still `true`."* The replacement is
server-side ceilings per principal — machines destroyed, machines created, images written per
interval — because a ceiling is the one kind of limit the caller cannot set for itself.

**Error taxonomy becomes a safety mechanism.** An agent that cannot distinguish "you are out of
money" from "your request is malformed" recovers the only way it can: mutate the request and retry.
In this system that is how a retry loop becomes a *second physical server*. Hence distinct kinds —
`insufficient_balance`, `not_activated`, `halted`, `gone`, `suspended`, `ceiling_exceeded` —
`retryable` as normative
caller guidance, and a contract that says in words that re-issuing under a fresh idempotency key
"is a second purchase, not a retry."

**Reads must exist, or agents probe by writing.** Until 2026-08-12 no endpoint returned a balance,
so a caller could learn its own solvency only by attempting a purchase and reading the rejection.
Remaining runway is readable per machine for the same reason: *"a caller that is software will act
on a number long before it would act on an email, and there is no email."*

Webhooks were rejected outright — the process holding every provider credential dialling
caller-chosen hosts is an SSRF primitive and an egress path out of the credential boundary. Polling
is server-paced instead, and a rate-limited *read* must never become the reason a caller re-issues a
*write*.

## 3. The decisions everything else follows from

The decisions live in `docs/adr/`, and each one records what was rejected. The rejections are the
informative half. *This paragraph opened "Eleven ADRs" until 2026-09-03, two decisions after the
count moved — and neither of those two was surveyed below, so the number was not merely stale, it was
the marker of a gap: `ADR-0012` appeared nowhere in this file at all, and `ADR-0013` only in a §7
open-items bullet about DigitalOcean's rescue question. The directory is the list; this cites it
rather than counting it, which is the arrangement that cannot drift again. `ADR-0003`'s footnote and
`ADR-0011` each reached the same conclusion about an enumeration of their own.*

**One deployable, not a front service over a credential-holding engine** (`ADR-0001`). The rejected
split isolated credentials better, but it put tenancy on a forwarded header and — decisively —
separated money from machine lifecycle across two stores. Once a prepaid balance became the
spending authority, authorizing a create and opening its commitment had to be one transaction, and
two stores cannot give you one. The accepted cost is stated plainly: the public surface shares an
address space with credentials to every customer's machine, which makes the in-code credential
boundary "the only structural defence left."

**Self-serve enrolment, with a prepaid balance as the entire spending authority** (`ADR-0002`). A
stranger's agent enrols at runtime — no identity, no email, no operator step. The counterweight is
that nothing but a funded balance authorizes spending. Rejected: operator onboarding (cannot reach
a self-serve market), post-pay with a ceiling (extends credit to anonymous strangers, dragging in
KYC and collections), and approval above a threshold (an agent cannot buy a dedicated box at 3am
while a human approves). The cost was accepted explicitly: the money path became v1-blocking, adding
12–16 weeks to a ~20–25 week build, against both reviewers' advice to defer it.

**The float is denominated in satoshis** (`ADR-0003`). Customers pay in bitcoin; providers invoice
in EUR/USD. Rather than hold a fiat liability against a volatile asset, the liability is matched to
the asset: owe sats, hold sats — so the customer bears bitcoin volatility on their prepaid balance.
Rejected with arithmetic: converting on receipt puts a KYB'd exchange and a bank on the critical
path of every pseudonymous payment; hedging means running a margin desk inside the process that
holds provider credentials; borrowing stablecoins is not a hedge but leverage. **A dissent is
recorded** — one analysis preferred EUR on the ground that satoshi denomination is the clearest
MiCA custody trigger. It was overruled because EUR denomination makes the operator structurally
insolvent on a −49% move that has already happened in living memory, whereas satoshi denomination
makes a custody *characterisation* arguable, and an arguable characterisation is answerable with
drafting.

**The regulatory perimeter is held by product design, not licensing** (`ADR-0004`). No withdrawal in
any form, no transfer between customers, no fiat refund, title passing on receipt, B2B terms. Each
prohibition is load-bearing — a fiat refund alone would trip e-money, deposit-taking and MiCA at
once. This is why `CONTEXT.md` bans vocabulary: writing "held", "backed", "reserved" or
"segregated" about a balance is the difference between a merchant and an unlicensed custodian. One
consequence was reversed in place: publishing the solvency invariant was originally a feature, and
is now forbidden, because "we hold satoshis equal to customer balances" *is* the banned
description. What that costs is recorded — the mechanism that would have made a later breach
actionable misrepresentation is gone, and customers are unsecured creditors.

**Collect nothing** (`ADR-0005`). No identity, no analytics, and nothing derived from the caller's
network path; caller payload is purged the moment an operation stops being live. *The deployment
does keep a history of the addresses **its own machines** were observed holding (`STO-41`) — added
2026-08-16, because answering a provider's abuse notice means knowing who held an address at an
instant, and resolving that against current state accuses whichever customer holds it today. That
is machine state, not caller identity, and it ages out on a stated horizon (`STO-43`).* This buys the cheapest GDPR posture, but it also selects
the *sanctions* posture — there is no name to screen — which is recorded as an accepted,
operator-borne risk. It also means there is no account recovery by identity, only a second secret
issued at enrolment. Note the scope honestly: this is privacy from the reseller layer, not from the
infrastructure provider.

**Two funding rails, one credit rule** (`ADR-0008`). A **deposit** is one object — an amount and an
expiry — with two **destinations**: a Lightning invoice and a fresh on-chain address. The *payer*
chooses the rail. Attribution is by destination, never by payer, which satisfies collect-nothing and
correct crediting with a single mechanism. Lightning-only was rejected because inbound liquidity
would cap large top-ups; an operator-chosen rail was rejected because it lets a stale liquidity
estimate decide someone's payment path.

**The process cannot spend the on-chain float** (`ADR-0009`). On-chain key material is watch-only:
the process derives addresses and observes payments but cannot construct a spend. **Lightning cannot
go cold** — receiving is inseparable from spending, and there is no analogue of an extended public
key — so it is bounded instead, by a ceiling covering the channel balance *and* the node's own
on-chain wallet, swept by hand. That ceiling *is* the blast radius of a full compromise, expressed
as a number. The credential the credential-holding process actually holds is narrower still: it
creates and observes invoices, cancels unsettled ones, and reads two balances (`SEC-48`).

**Fixed commitment, floating runway** (`ADR-0011`). Three design rounds went into how fast
reservations should widen after a price crash, until one observation dissolved the problem
entirely: every authorization is priced at the *current* rate, so nothing can be overcommitted at
stale prices. A crash simply drains a fixed satoshi commitment faster, moving the runway date
earlier. The rejected alternative — automatic widening — was the recommended option for two full
rounds, and it would have made a customer's spare balance seizable by one price reading, with the
whole fleet behind it. Also: margin is a percentage of machine time, with installs and rescue free
*but metered from day one*, because a price cannot be introduced later for something that was never
counted (`ADR-0007`); and v1 is pass-through resale, with inventory and VM-slicing deferred
*together*, because a setup fee only amortizes with density (`ADR-0006`).

**The abuse channel is the operator's, in both directions** (`ADR-0012`). A provider's abuse notice
stops at the operator: its case reference, its statement link, its own wording and any third party it
named never reach a tenant. What the tenant sees is a **case the operator wrote** — the machine, the
allegation, what was threatened, one deadline — and provider-neutrality is produced by the act of
rewriting, which is why there is no allegation taxonomy and no parser. Outbound, the tenant's
statement stops at the operator too, though forwarding it verbatim survives as a recorded per-case
decision. The rejected option was the cheap one and was the standing recommendation for part of a
session: relay the notice and let the tenant follow the provider's own link. **A real notice killed
it** — that link is a single-use bearer credential whose *use concludes the deadline*, so handed to
an autonomous caller a poll loop ends the operator's window in the first second, with no human ever
deciding to answer. That is `SEC-39`'s reasoning arriving at a surface nobody had looked at. Owning
the channel also exposed a latent defect: answering a notice means knowing who held an address at an
*instant*, and current state cannot say — every design that relays the notice hides this, because
the provider's own records do the resolving.

**Catalogue install is a second feature, not a second strategy** (`ADR-0013`). DigitalOcean exposes
no way to boot a droplet into recovery through its public API — two documentation passes and a live
probe returning `404 "The specified action type is not available."`, which is positive evidence of
absence rather than an argument from silence. The differentiator survives there by another route:
import the caller's image into the operator's private catalogue and have the provider build from its
own converted copy. **The two make different promises, so they carry different names.** A rescue
install writes bytes provisiond verified onto a disk provisiond laid out, and leaves a way back in; a
catalogue install hands the image over, and the provider exposes no checksum field, imposes its own
guest requirements, and offers no rescue path when the machine comes up unreachable. The rejected
option — one feature with two strategies — was the neatest, and it would let an agent believe its
bytes were checked when nothing checked them. Rejected with it: forwarding the caller's signed URL to
the provider, which discloses a credential and abandons verification entirely; and inspecting the
image before importing it, which is a parser for hostile binary inside the process holding every
provider credential.

## 4. How the system is shaped

Six modules with one-way dependencies: `core` (domain, capabilities, error taxonomy, the driver
interface — forbidden from depending on an HTTP client, a database or a web framework), `providers`
(adapters), `rescue` (generic SSH and installer orchestration, no provider branches), `ledger` (the
money: entries, commitments, the meter, rate derivation, solvency), `engine` (the credential-holding
lifecycle side: workers, driver invocation, the queue's execution and its sweeps) and `api` (the
customer-facing surface, enrolment, funding rails, abuse). `engine` may not depend on `api`; both
depend on `ledger`, which is what gives the worker's money-bearing terminal write a legal home.
*This paragraph said "four modules" and named `server` until 2026-09-02, two revisions after that
module was split — a reminder that an orientation document drifts silently, because nothing cites
it.*

**The provider abstraction** is capability declaration plus a driver contract stated in prose rather
than language signatures. Every operation defaults to `unsupported`, so adding a method to the
interface cannot silently give existing drivers wrong behaviour. Deletion is modelled in three
shapes — immediate destroy, scheduled cancellation, and an out-of-band contract process — and the
third is forbidden from declaring `delete_machine` at all. Commercial terms may never be encoded as
constants; the reason is recorded and is a good warning about this whole class of fact: a
specification, a reviewing model and a researching model each asserted a different set of terms for
the same provider, and two of the three were wrong.

**The operation lifecycle is the heart of the design.** Every provider-touching write becomes a
durable **operation** record *before* any provider call and is answered `202` with that record. The
reasoning is worth quoting because everything follows from it: a control plane that returns the
provider's answer synchronously has no way to tell "the order did not happen" from "the order
happened and I lost the reply" — and one that retries on failure will eventually buy two servers.

So there are five states — `queued`, `running`, `succeeded`, `failed`, and **`needs_reconciliation`**,
meaning *the outcome is unknown*. `OVR-5` calls it "the single most important requirement in this
document" and frames it as *"Uncertainty is a first-class state, not an error."* It is
**resolution-pending, not terminal** — a word withdrawn in place on 2026-08-13, because calling it
terminal forbade the very transitions that resolve it. What survives is what was load-bearing:
nothing automatic, no timer, and no caller action moves it. Only evidence, or an operator.

The evidence mechanism is the **correlator** — whatever a create writes or leaves behind at the
provider that later identifies which operation produced a resource. Where a free caller-controlled
field exists, it is the operation UUID. Where none does, it is an artifact: on Hetzner Robot, a
per-order throwaway SSH key whose fingerprint appears in the transaction listing, because the
obvious field — the order `comment` — turned out to route orders to *manual processing*. That
discovery invalidated an assumption three earlier audits had passed over.

Reconciliation searches every correlator the operation recorded (a requeue **appends**, never
replaces) and takes the union, reaching one of four outcomes: exactly one resource is
resolved-observed and attached; an authoritative zero past a bounded negative window is
resolved-absent and the money is released; **more than one** is a duplicate that only an operator
may remediate; and an unfilterable provider is unresolved. Matching is exact, never heuristic on
hostname or timing — two of a tenant's own concurrent creates can look identical, and attaching the
wrong machine hands one customer another's server.

**Storage** is specified as invariants rather than a product: an atomic queue claim, an atomic
conditional machine-lock upsert, guarded settled-state writes, `(principal, idempotency_key)` (`STO-4`)
uniqueness, per-tenant serialization for money, an append-only ledger with no update or delete path,
and deposits that outlive tenant deletion — because an on-chain address stays payable forever, so
discarding the binding makes a late payment unattributable by construction. An embedded
single-writer engine satisfies all of it for one process; horizontal availability requires a
transactional server database reproducing the same primitives.

## 5. The money model is the security model

This is the part a reader most easily misreads, and `12-billing-and-ledger.md` opens by naming it:
**"The ledger is not an accounting convenience. It is the authorization system."** Under `ADR-0002`
a balance is the only thing that permits spending, so a ledger bug is an authorization bug, and the
transaction that commits funds is the same transaction that authorizes a purchase. There is no
identity, no credit and no collections standing behind it.

The vocabulary is precise because an earlier version was not. A **commitment** is satoshis reserved
against one machine; it is not a ledger entry, and it **decays** as the machine is consumed. A
**reserve** is the calculation that sizes it. The word **"hold" is banned** — importing that
card-payments primitive (authorize once, capture once, against a discrete purchase) made the first
ledger draft model a reservation that never shrank, which drives the available balance negative one
hour into the first machine's life.

The specification's own worked example is the clearest statement of the invariant:

| Event | Σ ledger entries | Reserved | Available |
|---|---:|---:|---:|
| `topup` +72,000 | 72,000 | 0 | 72,000 |
| commitment opened, 72,000 | 72,000 | 72,000 | 0 |
| one hour consumed: `usage_debit` −100 | 71,900 | 71,900 | 0 |
| machine deleted, commitment closed | 71,900 | 0 | 71,900 |

`available = Σ(ledger entries) − Σ(open commitments)`, and `available ≥ required_commitment` is the
**only** authorization a create receives. The check and the write must be serialized per tenant, or
two creates read the same balance and both commit — write skew, which commits without error under
both READ COMMITTED and SNAPSHOT isolation. Opening the commitment and enqueuing the operation are
one transaction, because "a commitment without an operation silently freezes a customer's money; an
operation without a commitment spends the operator's."

Three consequences make this security rather than bookkeeping:

**Enforcement is cancellation, not a bill.** Powering a machine off does not stop provider billing,
so a machine whose funding fails must be cancelled — and at the end of runway it is cancelled *and
its disk destroyed*, disclosed in the terms. Deletion and cancellation therefore **bypass** the
solvency and rate gates entirely: refusing an exposure-reducing action because exposure is too high
is the one failure the halt matrix forbids.

**The exchange rate is an attack surface that reaches customer data.** A rate that understates the
satoshi makes solvent customers look exhausted, after which cancellation destroys their disks.
`LDG-41` draws the line explicitly: every other external dependency can at worst cost the operator
money or stop the service — *"This one reaches the customer's data."* Hence a median of at least
three genuinely independent sources, staleness bounds, outlier exclusion, a source set fixed at
deployment, and a quorum below which there is **no rate** — never a stale one, never last-known-good.
The final guard is that a shortfall must persist across more than one derivation, so a single bad
rate reading can move a date but can never destroy a disk.

**Losses that cannot be billed have a home.** An **operator deficiency** is a durable
*non-ledger* record, in native currency, for costs the customer must not pay — a rate outage, a
commitment overflow, an unfunded late-attach cancellation, an unrecoverable setup fee. Keeping them
out of the ledger is what stops the authorization system from being polluted by the operator's own
accounting.

On money-in, the hazard inverts: this is the one path where a bug *creates* satoshis rather than
moving them. Settlement is read from the operator's own node — there is no webhook to forge —
zero-confirmation credit is forbidden on any rail, and the system credits what arrived, never what
was intended. One honest trap is written down as a requirement: a Lightning invoice enforces its own
expiry, but an address cannot, so on-chain "expiry" means only that *the operator stops watching* —
and that is "the one place in the funding design where a customer can lose money by doing something
that looks correct."

## 6. What is genuinely hard

Most of the set is detailed rather than hard — pagination clamps, header names, redaction lists.
Four areas deserve real thought:

1. **Where uncertainty meets money.** An unresolved create freezes a customer's satoshis, so the
   commitment is released at a bounded negative window even though the operation stays open —
   deliberately moving residual risk to the operator, because "a frozen balance is a cost the
   customer can neither see nor escape, and for an agent buying compute it is indistinguishable from
   theft." Everything downstream is intricate: the late-arriving machine (attach it truthfully, then
   route it straight to cancellation), the setup fee's lifecycle across every resolution outcome,
   and per-attempt records so resolution debits what the matched attempt actually cost. Three
   successive audits each found the *same class* of defect here.
2. **The meter.** Rounding applies to the cumulative charge and never per tick, or a deployment that
   meters every minute charges more than one metering hourly. A correction names the entry it
   corrects and is reported in that entry's period, and leaves the meter's state untouched. Absorbed time is subtracted in *seconds*, because it
   accrued while no rate existed. Every clause exists because a simpler version double-charged or
   double-refunded — including one that charged 400 for 200 sats of consumption.
3. **Disk identity.** The most serious finding of the fourth audit was a path to destroying the
   wrong disk that satisfied every requirement then in force: a caller names `/dev/sdX`, and device
   ordering differs across boots, between the rescue environment and the installed system, and after
   any hardware change. Targets are now bound to serial or WWN plus an inventory fingerprint,
   re-verified immediately before I/O, with *more than one match* treated as the dangerous case.
   A residual hazard is disclosed rather than solved: raw streaming can only verify the digest after
   the overwrite has begun.
4. **Provider facts as load-bearing inputs.** Cancellation terms, billable attachments, rescue
   capability and order fields cannot be inferred from "cloud" or "dedicated". The recorded lesson
   from the `comment` field generalizes: a caller-controlled field is only a correlator if writing to
   it is free, and absence of a documented side effect is not evidence of absence.

## 7. What is established, and what is not

**Nothing here has been validated against a running implementation.** No real provider transaction,
no paying customer. The code it came from never ran.

What it *has* had is sustained adversarial review: four audits and sixteen multi-reviewer rounds,
which found and repaired the non-decaying hold, a missing money-in path, a setup-fee double count,
the unsafe disk naming, absent credential revocation, a meter that double-charged every tick, and a
suspended tenant that could still be handed a funded machine. Reversals are recorded **in place** —
identifiers are append-only, and withdrawn requirements keep their rejected reasoning — which is why
the documents read as arguments rather than statements, and is where much of the value is.

The README's own calibration is the right one, and it cuts against the set: recorded corrections
mark where a review happened to collide with the text, and are not evidence that errors get caught.
The honest inference is a base rate applying to the unmarked text too. A skeptical audit named the
mechanism precisely — duplicated normative text drifting apart is not merely bloat, it is what
generates the defects each pass keeps finding.

Known open items, in the set's own terms:

- The negative-resolution window "is still a guess" that only a real transaction calibrates.
- The DigitalOcean section is almost entirely `[verify]`, **except the rescue question, which was
  settled and settled negatively**: `ADR-0013` records two research passes and a live probe finding
  no way to boot a droplet into a recovery environment through the public API. The differentiator
  survives there by a different mechanism — catalogue install, with different promises — which is
  what that ADR exists to keep separate from rescue install rather than blended with it. *This
  bullet said the question was open until 2026-09-02, three revisions after it closed.*
- A live correlator round-trip against Hetzner Robot is still required before that driver ships,
  which is cheap: Robot orders have a `test` mode that simulates a purchase without buying anything.
- Deployment parameters are required to be stated and are not: confirmation depth, rail floors,
  deposit expiry, rate staleness/quorum/outlier bands, maximum outage bound, the ceiling covering
  the channel balance **and** the Lightning node's own on-chain wallet, margins, runway floor,
  autonomous-caller and operator-principal ceilings, provider negative windows, the re-derivation
  interval, and the account-sweep interval — which is now a money parameter, because it bounds how
  long a customer can be billed for a machine the provider has destroyed (`LDG-74`).
- The launch-gating conformance set stands at approximately 182 BLOCKING items of 271, the
  approximation deliberate because the count was wrong more than once and the tiers still live in
  prose. None has been executed. *This bullet said 135 until 2026-09-02, two reviews after the
  figure moved; the checklist's own blocking-count section is the only place the number is
  maintained.*
- Two questions are explicitly for a lawyer, not an engineer: the satoshi-custody characterisation
  that `ADR-0003`'s dissent raises, and the no-refund posture the whole perimeter rests on.

## 8. How to read the set

Read **`CONTEXT.md` first**. The vocabulary is enforced, and misreading *commitment*, *runway*,
*deposit*, *deficiency* or *correlator* will cost you a document's worth of confusion.

The shortest route to understanding the design is **`00` → `01` → `03` → `12`**: the overview, the
domain model, the operation lifecycle, and the ledger. `03` is the heart — the README calls its
treatment of uncertainty "the part that distinguishes this from a thin API proxy, and the part most
implementations get wrong." Read `ADR-0002` through `ADR-0004` *before* `12`, and `ADR-0011` with
it, or the money model will look like accounting.

The shortest route to deciding whether to *build* it is those four documents, the ADRs, and
**`11-open-findings.md`** — the audit history, what each finding cost, and which reversals were
decisions rather than evidence.

| Document | What it is for |
|---|---|
| `00-overview` | Problem, goals, system context, non-goals (including three withdrawn ones) |
| `01-domain-model` | Entities, machine states, capability model, error taxonomy |
| `02-provider-contract` | What every driver must prove, operation by operation |
| `03-operation-lifecycle` | Queue, leases, locks, ambiguity, reconciliation |
| `04-api-contract` | REST surface, auth, tenancy, enrolment, idempotency |
| `05-persistence` | Required transactional primitives and the schema |
| `06-rescue-install` | Rescue workflow, host-key trust, disk identity, image writing |
| `07-security-requirements` | Threat model and normative controls |
| `08-provider-notes` | Per-provider facts — **read the `[design]`/`[observed]`/`[verify]` marker on the fact you are about to rely on** |
| `09-known-defects` | Prohibitions distilled from the discarded implementation; the least re-reviewed document in the set |
| `10-conformance-checklist` | What an implementation must demonstrate before serving traffic |
| `11-open-findings` | Audit history, reversals, confidence limits. Read before building |
| `12-billing-and-ledger` | The authorization system wearing a ledger's clothes |
| `13-wire-contract` | Bodies, headers, enums, errors. Wins over prose elsewhere; its JSON is test input, not illustration |
| `CONTEXT.md` | Glossary, and the banned vocabulary |
| `docs/adr/` | The decisions, and what was rejected to reach them |

One convention shapes everything: requirement identifiers are **append-only**. Nothing is deleted or
renumbered; things are marked `WITHDRAWN` or `AMENDED` in place, with the reason and often the
superseded text kept inline. The amendment blocks are not clutter — they are frequently the most
informative content on the page, because they record what was tried, why it broke, and what a
rebuilder must not reinvent.
