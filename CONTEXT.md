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
A company that sells machines to the operator. The v1 launch set is Hetzner Cloud, Hetzner Robot
and DigitalOcean (`ADR-0010`); Cherry Servers is not in v1 and survives only as a shape the
provider contract must still abstract over.
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
to creating one. Not a v1 verb (withdrawn 2026-09-08, `ADR-0020`): it returns with a driver
whose machine read supplies the machine's cost.
_Avoid_: import, register, claim (as a synonym for adopting — the word belongs to **Claim**)

### Work

**Operation**:
The durable record of one requested mutation, with an explicit settled state — or the
resolution-pending `needs_reconciliation`. The central entity: every write that reaches a provider creates one, and the API returns it
rather than a result. *A small closed set of local-only writes is synchronous instead
(`API-48`).*
_Avoid_: job, task, request, action

**needs_reconciliation**:
The operation state meaning *the outcome is unknown* — provisiond cannot tell whether the provider
acted. A first-class answer, not an error. **Resolution-pending, not terminal** (`OPS-3`): it
settles to `succeeded` or `failed` on evidence or an operator verb — and nothing else moves it: no
automatic retry, no timer, no caller action, and since `ADR-0017` no requeue.
_Avoid_: terminal (withdrawn 2026-08-13), stuck, errored, retryable

**Episode**:
One system-detected condition on one machine that provisiond must act on until it ends — this
machine's exhaustion, its tenant's suspension, its account's loss (`DOM-31`). Opened by a sweep,
closed when the exposure ends — the machine gone or funded — or when nobody can establish what an
attempt did; never closed by declaring the condition over. The unit an operator attends to. An episode has **attempts**,
each an ordinary **operation**; an attempt can settle `failed` while the episode stays open, because
*the provider refused* is a fact about the attempt and *still billing* is a fact about the episode.
At most one open episode per machine and key.
_Avoid_: trigger, incident, case (taken — see **Abuse case**), retry loop

**Attempt**:
One **operation** enqueued under an **episode**. Settles like any operation and is retained or
deleted like any operation; the episode outlives it.
_Avoid_: requeue, run, try

**Claim**:
The engine taking one queued **operation** to run it. Numbered per operation by its **claim
number**, which every write made by that execution carries: a later claim of the same operation
— after an `OPS-8` defer — gets the next number, and that is the only thing that tells the two
executions apart while both rows read `running`. Not an **attempt**: an operation is one attempt
however many times it is claimed. The number identifies a claim and counts nothing.
_Avoid_: attempt, attempt count, generation, epoch (withdrawn), lease (withdrawn), claimant
(withdrawn with the leases), execution (that is what a claim starts, not its name)

**Retry**:
An operator opening a fresh **attempt** under a `stalled` **episode** (`API-64`). Never automatic:
a deterministic refusal repeated by a timer is the loop `OPS-39` exists to prevent.
_Avoid_: requeue (withdrawn 2026-09-07, `ADR-0017`), replay, re-run, resubmit (that is the caller's
word for its own action, and on a create it is a second purchase)

**Rescue**:
A provider-supplied minimal OS booted in place of the installed one, over which provisiond
installs custom images. Provider-specific and the reason this is not a thin API proxy.
_Avoid_: recovery mode, live CD, netboot

**Install**:
Putting a caller-chosen OS image onto a machine's disk. Destructive by definition. **Names two
different promises** — see **Rescue install**, **Catalogue install**, and the flagged ambiguity
below.
_Avoid_: deploy, provision, image (verb), reimage, rebuild

**Rescue install**:
An **install** performed by booting the provider's rescue system and writing the caller's bytes to
the disk from there. provisiond holds the bytes only in flight, verifies the digest before writing,
and controls the disk layout. The differentiator, and the reason this is not a thin API proxy.
_Avoid_: install (bare — say which), native install

**Catalogue install**:
An **install** performed by importing the caller's image into the operator's private catalogue at
the provider, and having the provider build the machine from its own converted copy. provisiond
never verifies what reaches the disk, controls no layout, and the image must satisfy the provider's
own guest requirements. **A different promise from rescue install, not a lesser configuration of
it** — the two are separate capabilities.
_Avoid_: install (bare), rebuild, provider install

**Rescue inventory**:
A read-only pass that boots a machine into rescue and reports its disks with stable identifiers, so
a caller can choose a target before a destructive write. Read-only about the **disk** and nothing
else: it reboots the machine, and an ambiguous exit can leave it in rescue.
_Avoid_: preflight (banned — see flagged ambiguities)

**Marker**:
The engine's record of its own execution on one operation — `OPS-45`'s two columns: whether a
phase began that could have altered the machine, and whether the rescue session it opened was
closed without error. A fact about *this process*, written before the phase runs and read by the
classifier before anyone asks a human. On a **rescue install** the first marker means the
destructive phase was allowed to begin and the old contents can no longer be represented as
preserved; on every other kind it means a request was dispatched and says nothing about the
machine. Never cleared: the first is write-once, the second is armed `false` before the session and
moves to `true` on a clean exit, never back.
_Avoid_: flag, evidence, witness

**Evidence**:
What settles an unknown outcome — a provider observation (`OPS-27`'s correlator match, `PRV-36`'s
sources) or the basis an operator records with a resolution verb (`STO-19`). Not a **marker**,
which the engine wrote about itself, and not a **witness**, which the formal layer checks.
_Avoid_: proof, marker

**Disk effect**:
What one install operation is known to have done to the machine's prior disk contents,
independent of whether the install completed and of the operation's state: `none`, this operation
is established to have written nothing to the target disk; `destructive_boundary_crossed`, a
**rescue install** whose first **marker** is set, so the prior contents may be gone; `unknown`, a
**catalogue install** or native rebuild dispatched with no evidence of whether the provider began
writing. Rendered to the caller on an install's error (`WIR-9a`). A `failed` operation does not
carry this fact in its state.
_Avoid_: rollback, preserved (say `disk_effect: none`), data loss (which is a consequence, not the fact)

**Restore**:
Bringing the store back from a backup, landing at some instant before the failure. A recovery
incident with a stated procedure (`ADR-0023`), never a **restart**: a restart loses no committed
work and the startup pass classifies what was in flight; a restore loses an interval, and the
engine brought up on it naïvely performs destructive actions on state the restore rewrote.
The **restore record** is the row that makes the incident recognizable to a process rather than to
an operator: open from before either component starts until the operator closes it, carrying the
restore instant and which of the procedure's steps have completed (`STO-56`, `STO-54` owns what it
means). *Added 2026-09-20.*
_Avoid_: restart, recovery (bare — the rescue recovery directory and the recovery credential
already own that word), rollback (that is a transaction)

**Recovery point**:
How much committed work a restore may lose, stated as the greatest age of a write not yet in a
separate failure domain. A deployment parameter with an alarm, and explicitly not the safety
argument: the procedure's order is.
_Avoid_: RPO (say it), Δ (the brief's symbol, not a term), data-loss window

### Abuse

**Abuse notice**:
What a provider sends the **operator** alleging that a machine did something its terms forbid.
Addressed to the operator because the operator is the provider's sole counterparty
(`08-provider-notes.md`). Carries the provider's own case reference, a dated deadline and a
single-use statement link — none of which a tenant ever sees (`SEC-45`).
_Avoid_: complaint, report, ticket, abuse case (that is the thing derived from it)

**Abuse case**:
provisiond's provider-neutral record of one notice: a machine, the operator's own summary of the
allegation, a deadline and a consequence. The thing a tenant can read and answer. It is a
*translation* of a notice, not a copy of one — which is what keeps the provider's wording, case
reference and bearer link out of the customer surface, exactly as `WIR-30` and `LDG-26` keep
provider price and raw metadata out. There is deliberately **no allegation class** (`DOM-23`).
_Avoid_: notice (that is the provider's artifact), ticket, incident, violation

**Statement**:
A reply to an allegation, and the word does double duty: the **tenant's** statement is free text
submitted to the operator, and the **operator's** statement is what actually reaches the provider.
`SEC-45` makes the second the operator's own, informed by the first. They are separate records and
neither becomes the other by default — but they are not sealed off from each other, because
`ADR-0012` leaves forwarding a tenant's statement verbatim available as a **recorded per-case
operator decision**. Qualify the word whenever both are in play.
_Avoid_: response, appeal, explanation, defence

### Money

**Balance**:
A customer's prepaid, satoshi-denominated claim on the operator for future compute. Not money,
not a deposit, not a crypto-asset — a contractual claim whose price index happens to be the
satoshi (`ADR-0003`, `ADR-0004`).
_Avoid_: wallet, account, deposit, funds, credit line

**Top-up**:
A customer payment that increases a balance — the ordinary way one goes up. *An operator
attribution of an orphaned deposit (`WIR-42`) also credits, as a `correction` naming the entry it
moves; it re-homes an existing credit rather than creating one.*
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

**Billing period**:
The calendar month in UTC, one boundary for the whole deployment (`LDG-68`). The unit the meter
nets within — corrections belong to the period of the entry they name, not the period they were
posted in. **Not** the provider's invoice month and **not** a per-machine anniversary; both were
readings the set admitted while the term was undefined, and each produced a different bill.
_Avoid_: billing cycle, month, invoice period

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
How long a machine's committed satoshis keep it running at current prices. Chosen by the caller
at create, committed (not prepaid), readable at any time — and **the date floats with the price
of bitcoin** (`ADR-0011`): a price drop shortens it, and the caller extends it with an explicit
action, never by an automatic grab of its balance.
_Avoid_: grace period, term, credit, trial, guarantee (the date moves)

**Correlator**:
Whatever a create writes or leaves behind at the provider that later identifies which **operation**
produced a resource — the operation identifier where a free field exists, a per-order artifact
where none does (`PRV-32`). What announces need not be the machine: on an order-shaped provider it
is the order. One create records one correlator, because a create is placed once (`ADR-0014`).
_Avoid_: tag, label, marker, reference

**Setup fee**:
A provider's one-time charge for a dedicated machine. Non-refundable, passed to the customer at
cost, and the one component entirely lost if a customer vanishes immediately.
_Avoid_: onboarding fee, installation fee, deposit

**Rate**:
What a satoshi is worth in a provider's billing currency: the lower median of the **rate
observations** accepted inside the **window** (`LDG-58`, `ADR-0027`) — a price some pass accepted,
chosen by the window and set by no single pass, never one venue's price. **The only external input
that can reach a customer's disk**: understate the satoshi and solvent customers look exhausted,
after which `LDG-14` cancels and destroys — which is why one observation cannot move it outside what
the others carry.
_Avoid_: price (that is what a customer pays), spot, exchange rate, oracle

**Window**:
The accepted **rate observations** whose `observed_at` lies inside the last window-length before
the **pass** that computed the **rate**; the rate is their median, computed only when a pass
accepts an observation, and it holds until the next pass — an observation ageing out of the window
changes nothing on its own. Its length is stated per deployment and per billing currency, as the
**quorum** is (`LDG-58`, `ADR-0027`). A window with no observation inside the staleness bound, or
with fewer than three observations, is **no rate** (`LDG-59`).
_Avoid_: history, buffer, lookback, average (a median is a selection, not a blend)

**Quorum**:
The fewest live, non-excluded rate sources a **pass** needs to accept a **rate observation**. Below
it the pass accepts none and recomputes nothing, and the **rate** in force holds. **No rate** —
not a stale one, not the last known good one — comes from the **window**, never from one pass:
nothing inside the staleness bound, or fewer than three observations, and then `LDG-40`'s halt
matrix applies.
_Avoid_: threshold, minimum sources

**Rate observation**:
One pass's accepted price: the median `LDG-58` produces from the pass's surviving sources,
recorded by `STO-49` before it is used for anything. One source's number is not an observation; it
is an input to one. One observation is not the **rate**; it is an input to that.
_Avoid_: reading, sample, tick, quote (each is one source's, not the accepted median)

**Pass**:
One run of the rate pipeline for one currency: every source read, the stale and the deviant
excluded (`LDG-59`, `LDG-60`), the **quorum** tested, and — where it holds — one **rate
observation** accepted. Runs on its own cadence, which a deployment states beside the **window**.
A pass is not a **derivation**, which consumes the **rate** and runs on a different interval.
_Avoid_: tick, poll, fetch, sample (one source's), observation (the pass's output, not the pass)

**Derivation**:
One recomputation of a machine's `runway_until` from its commitment and the **rate**
(`PRV-13e`, `LDG-33`). **A derivation is not an observation**: a derivation's instant says when
provisiond computed, an observation's identity says which price a pass accepted, and the rate a
derivation uses is the **window**'s median — so two derivations an interval apart can consume the
same observation, may use the same rate, and one observation cannot move that rate outside what
the window's others carry. Re-derivation runs on an interval and does not imply a
new observation.
_Avoid_: re-pricing, recalculation, refresh (that is `DOM-8`'s read of the provider)

**Channel ceiling**:
The most the operator lets sit in Lightning channels before sweeping the excess beyond the running
system's reach. Lightning cannot be made cold, so this number *is* the blast radius of a full
compromise (`ADR-0009`).
_Avoid_: hot wallet limit, float cap, reserve (taken — see **Reserve**)

**Solvency invariant**:
The rule that satoshis actually held must cover the float. **Internal and unpublished on purpose**
(`LDG-19`): the operator maintains it and never advertises it, because every public phrasing
drifts into the custody words `ADR-0004` §4 bans. The terms still state that a balance is an
unsecured claim (`LDG-19a`) — silence about the ratio, not about the arrangement.
_Avoid_: reserve ratio, backing, proof of reserves, "fully reserved" (all four are the phrasings that cause the problem)

### Checking the set

**Specification gate**:
A command in `tools/` that refuses an inconsistent or invalid specification artifact and is run by
`tools/check-all.sh`. Bare *gate* means this in `README.md`, `AGENTS.md` and `tools/`; in a
requirement it is qualified, because the set also uses *gate* for a runtime refusal — the solvency
gate, the rate gate — and those are requirements, not checks.
_Avoid_: test (that is a conformance item's word), linter

**Marked region**:
The lines between `<!-- formal: Provisiond.Render.… -->` and `<!-- /formal -->` in a requirement:
a table, diagram or worked example that `tools/check_regions.py` holds to what the named
declaration emits (`ADR-0025`). Inside one, the declaration is authoritative and the Markdown is
its rendering; outside one, the transitional rule holds and the Markdown is. A worked example
inside one is computed by the declaration and illustrates it; it is not a **witness**, which is
retained to refuse a trap.
_Avoid_: generated section (a `match` region is diffed, not generated), snippet

**Witness**:
A concrete input or trace, checked by the formal layer, that exhibits a property or its failure —
one usable satoshi at two satoshis per second. A negative witness, or counterexample, is a retained
trap made executable. Not a provider observation, which is **evidence**, and not `OPS-45`'s
**marker**.
_Avoid_: example (a witness is checked; an example is illustrated), sample

**Model**:
The formal layer's explicit state, inputs and transition rules, about which a theorem is proved.
Say *model state* and *model invariant*; a bare *state* is a machine's or an operation's, and a bare
*invariant* is the **solvency invariant**. The model is not the domain model in this glossary and
not a disk's hardware `model` field.
_Avoid_: simulation, spec (the specification is the documents), implementation

**Reference model**:
A **model** of a lifecycle — rows, executions, transactions, the faults dealt to them — whose
definitions compute the outcomes the set permits for a sequence of commands and faults, so that an
implementation can later be compared against it in a test. The comparison is a test and nothing
stronger; the model proves nothing about a running implementation. The claim model
(`ADR-0022`'s guards, under `tools/formal/`) is the first.
_Avoid_: oracle (on **Rate**'s avoid list for the same reason), reference implementation (nothing
here implements), golden model,
executable specification (the specification is the documents)

**Assumption**:
A named hypothesis a theorem takes as a parameter because its truth is not the theorem's to
establish — a provider's visibility window, a platform's transaction semantics, `OPS-47`'s single
engine. A theorem's signature shows what it assumes; a model that omits something says so.
_Avoid_: axiom (the project declares none), precondition (that is a requirement's word for a
caller's obligation), `[verify]` (that marks an unverified provider fact, not a hypothesis)

**Property**:
A proposition about a definition or a trace. A **theorem** is a property with a checked proof under
its stated assumptions; a **decided** property is one closed by finite evaluation within stated
bounds. Neither is evidence about a running implementation.
_Avoid_: claim (taken — see **Claim**), guarantee, requirement (a property is what a requirement's
formalized clause must satisfy)

## Flagged ambiguities

**"Account"** is overloaded and MUST be qualified. **Provider account** is the operator's
credentials at a provider. A customer's relationship with the operator is a **tenant** (for
isolation) — never "account".

**"Delete" is not "cancel."** Deleting a virtual machine stops the billing; cancelling a
dedicated machine schedules an end date and the machine keeps running and keeps billing until
it arrives (`DOM-19`, `cancellation_scheduled`). Use **cancel** whenever an end date is
involved, and reserve **delete** for gone-and-not-billing.

**"Exposure-reducing cancellation" is the set's umbrella for the system's own destruction
paths**, whichever provider verb one ends in. `OPS-41` says "A worker executing **any**
exposure-reducing cancellation". `OPS-39` says "For an exposure-reducing cancellation the key is
the action, `delete`, not the `system_reason`". The rule above governs the provider verbs; this
term names the class. The thing enqueued under an **episode** is an **attempt**, never "a
cancellation".

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

**"Install" names two promises and the difference is the whole product.** Both put a caller-chosen
image on a machine, and that is all they share. **Rescue install** writes bytes provisiond has
verified onto a disk provisiond controls. **Catalogue install** hands the image to the provider,
which converts it and boots its own copy — so nothing verifies what reaches the disk, the layout is
whatever was baked in, and the image must satisfy the provider's guest requirements or the machine
comes up unreachable with no rescue path to fix it. Never write "install" unqualified where a reader
could infer the bytes were checked.

**"Target" means the disk, and nothing else.** In `WIR-20`'s install body and `RSC-26`/`RSC-27` it
is the block device about to be overwritten, and that is the only sense the word keeps here. A
second sense — a requeue comparison field — was carried in three requirements and defined in none,
and is withdrawn (`OPS-34`, amended 2026-09-06; `F38` holds the reasoning). Never introduce
another: an undefined comparison field reads as checkable and is not, which is how that one
survived three reviews and a conformance item that tested it by name.

**"Epoch" is withdrawn** (2026-09-08, `ADR-0019`), and the trap is worth keeping. It named a
counter each engine took at startup and stamped onto the operations it claimed, and it was
described everywhere as a *fence*. It was not one: a worker compared the value against the value
it had written itself, so the term held by construction and the operation's own status was doing
all the work. Never reintroduce a guard whose compared value has a single writer that is also the
thing being guarded — that is not a check, and it reads exactly like one. What replaced it is a
lock taken once at boot, of which `OPS-47` says "**The lock is not a fence**", in its own text and
for this reason.

**"Claim" has one working sense and two it must not take.** Here it is the engine taking a queued
operation (`OPS-5`), and **claim number** is that claim's per-operation number. It is *not* a
synonym for **adopt** — "a sweep claims a resource" and "an unclaimed machine" are the adopt sense
leaking, and they are to be read as *attach* and *unrecorded*. And **Balance** keeps "claim" in its
legal sense, "a contractual claim on the operator", which is a term of art and does not move. The
column this replaced was `attempts`, "incremented on claim", which read as a count of the thing the
glossary calls an **attempt** while `OPS-2` says "the operation is one attempt" — a create deferred
once read `2` on a kind `CNF-288` says has "no second attempt by any path". Never bound, route or
display the claim number as a count; the first draft of `F48` did exactly that one day after
`ADR-0017`.

**"Preflight" is banned**, and it is banned for causing the misreading it names. It was the word for
what is now **rescue inventory**, and it reads as harmless: it is read-only about the *disk* and not
about the *machine*, which it reboots into another operating system and can strand there.
`OPS-11` already has to classify it with `install` rather than `refresh` for exactly that reason —
a name that needs a correction four documents away is the wrong name.
