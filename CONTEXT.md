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

**Float**:
The sum of all customer balances — what the operator owes at any instant. The operator's own
margin is not part of it.
_Avoid_: reserves, customer funds, AUM

**Hold**:
The portion of a balance that is committed to a running machine and cannot be spent on anything
else. Placed when a create is authorized, released when the machine stops billing.
_Avoid_: lock, freeze, escrow

**Reserve**:
The *amount* a hold must be sized to: enough that the operator is never left paying a provider
for a machine the customer walked away from. A calculation; a **hold** is the ledger entry that
results from it.
_Avoid_: buffer, deposit, collateral, margin

**Debit**:
Moving satoshis out of a balance permanently, because compute was consumed or a non-refundable
provider fee was incurred. Distinct from a **hold**, which is reversible.
_Avoid_: charge, capture, settle

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

**"Hold" is the ledger entry; "reserve" is the calculation.** They are not synonyms, and the
schema has both.

**"Provision"** is banned as a verb for installing an OS. It means acquiring a machine from a
provider. Use **create** for acquisition and **install** for putting an image on a disk.
