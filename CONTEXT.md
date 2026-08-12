# provisiond

A compute reseller control plane. The **operator** holds accounts at hardware providers;
**customers** buy machines through provisiond and never hold a provider credential. The
differentiator is that custom OS images, rescue-system access and platform-specific features
are exposed as automated, configurable API operations rather than support tickets.

This file is a glossary. It contains no design decisions — those live in `docs/adr/` — and no
requirements — those live in the numbered specification documents.

## Language

### People and boundaries

**Operator**:
The party running provisiond, who holds the provider accounts and pays the provider bills.
Singular: there is exactly one per deployment.
_Avoid_: admin, us, owner

**Customer**:
A party that buys machines from the operator. Enrols itself; never holds a provider credential.
_Avoid_: user, client, buyer

**Tenant**:
The isolation boundary a customer's machines and operations belong to. One per customer, created
at runtime by self-serve enrolment.
_Avoid_: org, workspace, project

**Caller**:
The software making API requests on a customer's behalf — expected to be an autonomous agent,
not a human at a keyboard. Distinguished from **Customer** because a per-request prompt is not a
control when the caller is a program (`SEC-39`).
_Avoid_: user, operator

**Provider**:
A company that sells machines to the operator — Hetzner, Cherry, DigitalOcean.
_Avoid_: vendor, upstream, backend

**Provider account**:
One set of the operator's credentials at one provider. A global resource: naming it grants
nothing (`DOM-3`).
_Avoid_: account (bare — see flagged ambiguities), project, credential

### Things that are bought and managed

**Machine**:
One VPS or dedicated server under management, addressed by internal UUID.
_Avoid_: server, instance, host, box, node

**Offer**:
A purchasable configuration at a provider — a server type, a standard dedicated product, or a
market listing. An offer is not yet a machine.
_Avoid_: plan, product, SKU, listing

**Adopt**:
Bringing a machine that already exists at a provider under provisiond's management, as opposed
to creating one.
_Avoid_: import, register, claim

### Work

**Operation**:
The durable record of one requested mutation, with an explicit terminal state. The central
entity: every write creates one, and the API returns it rather than a result.
_Avoid_: job, task, request, action

**needs_reconciliation**:
The terminal operation state meaning *the outcome is unknown* — provisiond cannot tell whether
the provider acted. A first-class answer, not an error.
_Avoid_: pending, stuck, errored, retryable

**Rescue**:
A provider-supplied minimal OS booted in place of the installed one, over which provisiond
installs custom images. Provider-specific and the reason this is not a thin API proxy.
_Avoid_: recovery mode, live CD, netboot

**Install**:
Putting a caller-chosen OS image onto a machine's disk. Destructive by definition.
_Avoid_: deploy, provision, image (verb), reimage, rebuild

### Money

**Balance**:
A customer's prepaid, satoshi-denominated claim on the operator for future compute. Not money,
not a deposit, not a crypto-asset — a contractual claim whose price index happens to be the
satoshi (`ADR-0003`, `ADR-0004`).
_Avoid_: wallet, account, deposit, funds, credit line

**Top-up**:
A customer payment that increases a balance. The only way a balance goes up.
_Avoid_: deposit, funding, recharge, payment

**Deposit**:
One request to add funds: an amount, an expiry, and **two** destinations — a Lightning invoice and
an on-chain address — either of which pays it (`ADR-0008`). One object, two ways in. Not a
receivable: it promises nothing and can be paid twice, once, or never.
_Avoid_: top-up (that is the resulting *entry*), invoice, payment request, order

**Destination**:
One of a deposit's two payable things. What makes a payment attributable **without knowing who
paid** — which is how the collect-nothing posture and the need to credit the right balance are
satisfied by the same mechanism.
_Avoid_: address, invoice (each names one rail only)

**Rail**:
Which of the two a payment actually came in over. **Discovered, not assigned** — the payer picks
at payment time and the operator does not choose for them.
_Avoid_: payment method, channel, network, fallback

**Float**:
The sum of all customer balances — what the operator owes at any instant. The operator's own
margin is not part of it.
_Avoid_: reserves, customer funds, AUM

**Commitment**:
Satoshis reserved against one machine and unavailable for anything else. It **decreases** as the
machine is consumed, so ordinary use neither frees nor freezes anything. Not a ledger entry — a
record of its own (`LDG-30`).
_Avoid_: **hold** (banned — see flagged ambiguities), lock, freeze, escrow, authorization

**Reserve**:
The *amount* a commitment must be sized to: enough that the operator is never left paying a
provider for a machine the customer walked away from. A calculation; a **commitment** is the
record that results from it.
_Avoid_: buffer, deposit, collateral, margin

**Debit**:
Moving satoshis out of a balance permanently, because compute was consumed or a non-refundable
provider fee was incurred. Distinct from a **commitment**, which is released if unused.
_Avoid_: charge, capture, settle

**Meter**:
What measures billable machine time and produces the debits that draw a commitment down. Its
absence is what made the first version of the ledger unimplementable.
_Avoid_: usage tracker, billing loop

**Runway**:
How long a machine is guaranteed to keep running before an exhausted balance can cancel it.
Chosen by the caller at create, prepaid, and readable at any time.
_Avoid_: grace period, term, credit, trial

**Correlator**:
The operation identifier written into a provider-side field at create, so that a machine created
by a request whose reply was lost can announce which operation it belongs to.
_Avoid_: tag, label, marker, reference

**Setup fee**:
A provider's one-time charge for a dedicated machine. Non-refundable, passed to the customer at
cost, and the one component entirely lost if a customer vanishes immediately.
_Avoid_: onboarding fee, installation fee, deposit

**Rate**:
What a satoshi is worth in a provider's billing currency. The median of several independent
sources (`LDG-58`), never one venue's price. **The only external input that can reach a customer's
disk**: understate the satoshi and solvent customers look exhausted, after which `LDG-14` cancels
and destroys.
_Avoid_: price (that is what a customer pays), spot, exchange rate, oracle

**Quorum**:
The fewest live, non-excluded rate sources that still produce a rate. Below it there is **no
rate** — not a stale one, not the last known good one — and `LDG-40`'s halt matrix applies.
_Avoid_: threshold, minimum sources

**Channel ceiling**:
The most the operator lets sit in Lightning channels before sweeping the excess beyond the running
system's reach. Lightning cannot be made cold, so this number *is* the blast radius of a full
compromise (`ADR-0009`).
_Avoid_: hot wallet limit, float cap, reserve (taken — see **Reserve**)

**Solvency invariant**:
The rule that satoshis actually held must cover the float. Stated publicly on purpose
(`ADR-0004`).
_Avoid_: reserve ratio, backing, proof of reserves

## Flagged ambiguities

**"Account"** is overloaded and MUST be qualified. **Provider account** is the operator's
credentials at a provider. A customer's relationship with the operator is a **tenant** (for
isolation) — never "account".

**"Delete" is not "cancel."** Deleting a virtual machine stops the billing; cancelling a
dedicated machine schedules an end date and the machine keeps running and keeps billing until
it arrives (`DOM-19`, `cancellation_scheduled`). Use **cancel** whenever an end date is
involved, and reserve **delete** for gone-and-not-billing.

**A balance is not custody, and the wording is load-bearing.** The operator never holds bitcoin
*for* a customer; title passes on receipt and the customer holds a claim to compute. Never write
"held", "backed", "reserved", "segregated" or "your bitcoin" about a balance — those words are
the difference between a merchant and a regulated custodian (`ADR-0004`).

**"Hold" is banned.** It is a card-payments word — authorize once, capture once, against a
discrete purchase — and importing it made the first ledger draft model a reservation that never
shrank, which drives the available balance negative one hour into the first machine's life. Use
**commitment**, which decays. "Reserve" remains the *calculation* that sizes it; the two are not
synonyms and the schema has both.

**This glossary is not normative.** It says so above, and it once contained the only statement in
the entire set of when a reservation is released — a requirement hiding in a file that disclaims
having any. If a rule matters, it belongs in a numbered requirement.

**"Expired" means two different things and the difference can cost a customer money.** An expired
Lightning invoice *cannot be paid* — the network refuses it. An expired on-chain address is
*still perfectly payable*; all that expired is the operator's watching of it. Never write "the
deposit expired" without saying which is meant, and never let a customer-facing string imply the
address stopped working (`LDG-54`).

**"Provision"** is banned as a verb for installing an OS. It means acquiring a machine from a
provider. Use **create** for acquisition and **install** for putting an image on a disk.
