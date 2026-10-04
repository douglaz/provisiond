# 00 — Overview

## Problem

Server hosting providers expose wildly different provisioning surfaces. A cloud VPS
API gives you create/rebuild/delete against a catalog of images. A dedicated-server
API gives you an ordering system, a rescue environment, and an out-of-band reset — and
expects you to bring your own operating system. Any control plane that tries to unify
these by reducing them to a common subset ends up unable to do the one thing bare metal
is for: putting an arbitrary, operator-controlled image on a machine.

The system specified here unifies the *lifecycle* — create, refresh, power,
rescue inventory, install, reverse-DNS, delete — while treating provider-specific capability as
first-class rather than as an exception. Rescue mode in particular is a workflow the
control plane orchestrates, not an opaque flag it forwards.

## Design goals

**OVR-1** The system MUST expose a uniform machine lifecycle across providers without
reducing provider capability to a lowest common denominator.

**OVR-2** Capability MUST be discoverable at runtime (`GET /v1/providers`). Clients
MUST NOT be required to infer support from a provider's name, and the server MUST NOT
accept an operation a provider has not declared support for. See `DOM-10`.

**OVR-3** Rescue-mode image installation MUST be a first-class orchestrated workflow:
the control plane activates rescue, pins the SSH host key, waits for the environment,
verifies the image, writes it, exits rescue, and cleans up credentials.

**OVR-4** Every write that reaches a provider MUST be asynchronous and durable. Provisioning and
reimaging take minutes and involve billable or destructive provider mutations; they
MUST NOT be tied to the lifetime of an HTTP connection. The closed set of synchronous writes is
`API-48`'s.

**OVR-5** **AMENDED.** *Uncertainty is a first-class state, not an error.* When the system
cannot determine whether a provider mutation took effect, the operation MUST enter a distinct
**resolution-pending** state (`OPS-3`) that requires evidence or human inspection to leave. **The mutation MUST NOT be retried automatically, and no timer may clear the state**; automatic
*resolution* by correlator search (`OPS-27`) is expressly permitted and required — it establishes
what happened rather than doing it again, and forbidding it would strand every automatically
resolvable operation on an operator's desk. *"Terminal" was withdrawn 2026-08-13: the state settles to
`succeeded` or `failed` on resolution, and calling it terminal forbade the very transitions
`OPS-27` and `OPS-31` mandate. What was load-bearing about the word survives intact — nothing
automatic and nothing caller-driven moves it.*
This is the single most important requirement in this document. See `03-operation-lifecycle.md`.

**OVR-6** Destructive and billable actions MUST require an explicit per-request
acknowledgement in the request body, independent of authentication and idempotency.

**OVR-7** Provider credentials MUST NOT appear in configuration files. Configuration
names the environment variable; the process reads the secret from the environment.

## System context

```
                    +---------------------------+       +--------------------+
   API client ----->|  HTTP API                 |------>|  Ledger            |
                    |  authn / tenancy /        |       |  entries +         |
                    |  idempotency / validation |       |  commitments +     |
                    +-------------+-------------+       |  the meter + rate  |
                                  |                     +----------+---------+
                                  v                                ^
                    +---------------------------+                  |
                    |  Durable operation log    |                  |
                    |  queue, one engine,       |                  |
                    |  supervised (OPS-47)      |                  |
                    +-------------+-------------+                  |
                                  |                                |
                        restart-safe workers ---------------------->
                                  |     OPS-27's terminal write
                                  |     goes through the ledger
                                  |
             +--------------------+--------------------+
             |                    |                    |
             v                    v                    v
      Provider driver A    Provider driver B    Provider driver C
       (cloud VPS)          (dedicated)          (cloud VPS)
             |                    |                    |
             +--------------------+--------------------+
                                  |
                                  v
                    +---------------------------+
                    |  Generic rescue engine    |
                    |  SSH + host-key pinning   |
                    |  rootfs / raw-disk writer |
                    +---------------------------+
```

### What happens when an agent buys a machine

```mermaid
sequenceDiagram
    autonumber
    participant C as Caller (an agent)
    participant A as api
    participant DB as Store
    participant E as engine
    participant P as Provider

    C->>A: POST /v1/machines
    A->>A: authenticate, then validate<br/>API-7 — in that order, DEF-4
    A->>A: reject a pending tenant, API-35<br/>reject a suspended one at 5b
    A->>DB: fingerprint + idempotency, WIR-3
    Note over A,DB: Same key, same body -> the stored result.<br/>Same key, different body -> 409.
    A->>DB: available >= required_commitment?<br/>LDG-9, the ONLY authorization a create gets
    Note over A,DB: Serialized per tenant, LDG-35.<br/>Without it two creates spend one balance<br/>and neither errors.
    A->>DB: open the commitment AND enqueue<br/>in ONE transaction, LDG-11
    A-->>C: 202 + operation view + poll_after_ms
    Note over C: Every write is 202. The record IS the<br/>completion guarantee, so no webhook<br/>and nothing to miss.

    E->>DB: claim atomically, OPS-5
    E->>E: re-validate, OPS-23
    E->>DB: write provider_account and the<br/>correlator BEFORE the call, OPS-35, PRV-26
    E->>DB: re-check the provider's price, OPS-43
    E->>P: create
    alt reply arrives
        P-->>E: machine
        E->>DB: machine row + setup-fee debit +<br/>terminal write, one transaction, OPS-27
        Note over E,DB: The debit is engine's write through ledger.<br/>Both api and engine depend on that module;<br/>neither depends on the other for money, OVR-9.
    else reply is lost
        Note over E,P: This is the case the whole design exists for.
        E->>DB: needs_reconciliation.<br/>No retry, no timer, no caller action.
    end
```

**Step 9 is the one that decides the architecture.** Authorizing the purchase and opening the
commitment must be a single transaction, and `ADR-0001` chose one deployable because two stores
cannot give you one.

The four layers map to the modules below, with strictly one-way dependencies:

| Module | Responsibility | Depends on |
|---|---|---|
| `core` | Domain model, capability declarations, error taxonomy, provider interface | nothing |
| `providers` | Per-provider HTTP adapters implementing the provider interface | `core` |
| `rescue` | SSH orchestration and image installers, generic across providers | `core` |
| `store` | Migrations — applied through the deployable's `migrate` entry point, run before a release's components start (`STO-13`) — the schema, the connection pool, the transaction handle, and every primitive `05-persistence.md` says the store MUST provide (`STO-1`, `STO-51`, `LDG-35`'s advisory-lock helper). Holds no credential | `core` |
| `ledger` | **The money**: ledger entries, commitments, the meter, rate derivation, solvency, and `LDG-35`'s per-tenant serialization primitive. Holds no provider credential and no payment-rail credential | `core`, `store` |
| `engine` | **The credential-holding lifecycle side**: workers, driver invocation, the durable queue's execution, the exhaustion and account sweeps, and the only code that may reach a provider credential | `core`, `store`, `providers`, `rescue`, `ledger` |
| `api` | **The customer-facing side**: HTTP surface, authentication, tenancy, enrolment, the funding rails and their settlement watcher, abuse | `core`, `store`, `ledger`, `engine` — and `engine` **only through a narrow trait that does not expose a credential** |

**AMENDED 2026-08-31 — `server` is split, because the boundary that matters had no home.**
`ADR-0001` accepted one deployable on the promise that code structure keeps the public surface away
from provider credentials, and calls `OVR-10a` "the only structural defence left". `CNF-71`–`CNF-73`
then test a "customer-facing layer" and a "lifecycle layer" — **neither of which was a module.** Both
lived inside `server`, so `CNF-71`'s compile-fail test had no edge to fail across and `CNF-72`'s
tripwire had no visibility change to watch. A boundary absent from the dependency graph is a comment.

**AMENDED 2026-09-02 — `ledger` is separated out, because that split left the money with no legal
home.** Putting billing in `api` while `OVR-9` forbids `engine → api` made `OPS-27`'s terminal
transaction unbuildable: it requires a **worker** — which lives in `engine` — to commit the machine
row, the setup-fee debit and the commitment decrement together, and no edge existed for it. The
diagram above draws exactly that write, eighteen lines before a table that forbade it. Three readings
were available and all three were wrong: give `engine` an edge to `api` (forbidden, and it inverts
the credential boundary), split the transaction (forbidden by `OPS-27`, and a partial commit is
unrepairable), or move the workers into `api` (which deletes the boundary `ADR-0001` was decided on).

**The fix is a module both sides may depend on.** The money is not the customer-facing *surface* and
it is not the credential-holding *lifecycle*; it is the thing they share, and `ADR-0001` chose one
deployable precisely so that one transaction could span them. `engine → ledger` and `api → ledger`
are both legal, `engine → api` stays forbidden, and `ledger` depends on `core` alone — so the money
code cannot reach a provider credential, a driver, or an HTTP handler. *The credential boundary is
unchanged: it was never between the surface and the ledger, it was between everything and
`providers`/`rescue`.*

**OVR-8** The rescue engine MUST be generic. It receives a provider driver through the
provider interface and MUST NOT contain provider-specific branches. Provider-specific
rescue activation belongs in the driver (`PRV-8`).

**OVR-9** The dependency direction above MUST hold. In particular `core` MUST NOT
depend on an HTTP client, a database, or a web framework.

**`api` MUST NOT depend on `providers` or `rescue` at all, and MUST reach `engine` only through a
trait whose signatures mention no credential type.** `engine` MUST NOT depend on `api`. That single
edge, and its narrowness, is what `OVR-10a` requires and what `CNF-71`–`CNF-74` prove; the
credential-owning type is private to `engine` and reachable through nothing else.

**`store` is the only module that opens a transaction** (2026-09-08); `ledger` and `engine`
write-side functions take one as a parameter. The narrow trait between `api` and `engine` may
mention the transaction type and still no credential type.

**The partition of responsibilities across modules is the current assignment and may change as the
implementation discovers better seams. Two things are not tentative: the credential edge
(`OVR-10a`), and that exactly one module hands out the transaction.**

**`ledger` MUST NOT depend on `providers`, `rescue`, `engine` or `api`** (2026-09-02). Both `api`
and `engine` depend on it, which is what gives `OPS-27`'s money-bearing terminal transaction a legal
home and `LDG-11`'s commit-and-enqueue another. The direction buys one real property: **a module
that cannot name a driver cannot make a provider call from inside `LDG-35`'s serialization** — which
is one clause of `LDG-69` obtained structurally rather than by discipline. *The rest of `LDG-69` is
not obtained this way and MUST NOT be claimed to be: it binds a **worker**, which lives in `engine`,
and `OPS-41`'s funding re-check now genuinely nests the primitive inside a running operation's hold
on its machine (`OPS-8`) from there.
`CNF-217` asserts the whole boundary at runtime because only part of it is a compile-time fact.*

**`ledger` MUST NOT enqueue
an operation** — the queue's record and its enqueue primitive belong to `engine` and are reached
through the same narrow trait `api` uses — so a component that must both read a balance and enqueue
work belongs in **`api` or `engine`**, both of which can do each, and `OVR-17` says which for each
component. *`api` doing exactly that is the ordinary create path: `LDG-11` opens the commitment and
enqueues the operation in one transaction, which is step 9 of the diagram above and the reason
`ADR-0001` chose one deployable.*

## Deployment assumptions

**OVR-10** **SETTLED by `ADR-0001`: one deployable, with a module boundary inside it.**
Customer-facing concerns — enrolment, billing, abuse — are separated from the credential-holding
lifecycle engine by code structure, not by a network hop.

*The separate-service alternative and its comparison table are withdrawn. `ADR-0001` chose against
it and records why; keeping both forms live meant every later requirement had to be written twice
and a family of requirements accumulated around a deployment shape this product does not have
(swept 2026-08-31; see the README's withdrawn-identifier index).* **`OVR-10a` is therefore the only structural credential defence**, which is what
makes it load-bearing rather than belt-and-braces.

**OVR-10a** A deployment choosing the single-component form MUST NOT leave provider credentials
ambient in the process. They MUST be reachable only through `engine`'s narrow trait (`OVR-9`), so
a defect in the public surface cannot read them by accident. The boundary MUST be enforced by
the code's structure — module privacy, a narrow trait, a dedicated type owning the secret — and
not merely documented. This is the compensating control for the blast radius named above;
without it the single-component form has no defence at all.

**OVR-10b** **AMENDED 2026-09-02 — "a payment" meant two things and one of them is the ledger.**
The customer-facing side MUST NOT see a provider credential, and the lifecycle side MUST NOT see a
customer credential or **payment-rail material**: the Lightning and on-chain credentials, the
destinations derived from them, and the settlement stream they produce (`STO-30`–`STO-32`,
`SEC-48`). Shared storage is permitted; shared secrets are not.

*The withdrawn word was "a payment", unqualified, and read literally it forbade `OPS-27` — which
requires a **worker** to commit a setup-fee debit and a commitment decrement in the transaction that
records the machine. A ledger entry is not payment material: it identifies no counterparty
(`LDG-21`), carries no bearer secret, and is the authorization record `ADR-0002` makes the whole
system out of. What must stay away from the credential-holding side is the material that can
**receive or move money** — which is precisely `SEC-48`'s boundary, stated here in dependency terms:
`engine` reaches the money through `ledger`, and `ledger` holds no rail credential either.*

**OVR-10c** **Provider credentials MUST be read from the environment exactly once, at startup, by
the credential-owning module — and then removed from the process environment.** `OVR-7` puts
secrets in the environment to keep them out of configuration files, but an environment variable
is ambient: any code in the process can read it forever, which reduces `OVR-10a`'s carefully
typed boundary to decoration (`F13`). Scrubbing after the single read makes the boundary
structural — after initialization, the only copy lives inside the owning type, and a defect in
the public surface that dumps the environment discloses nothing. The scrub MUST be verified, not
assumed (`CNF-173`), because some runtimes cache the environment at startup and "removed" can
mean "removed from a copy".

**OVR-14** **v1 ships three drivers: Hetzner Cloud, Hetzner Robot and DigitalOcean** (`ADR-0010`)
— both machine shapes across two unrelated companies. **This is a scope statement, not a licence
to specialise.** Nothing in `01`–`07` may make a provider's behaviour *normative* — a requirement
MAY cite a verified provider fact as evidence for a general rule (`PRV-30`, `PRV-32`), which is
what keeps a rule falsifiable rather than asserted — and `PRV-13c` continues to forbid
encoding any provider's commercial terms as constants; the launch set exists so that the
provider-neutral contract is *tested* against difference, not so that it can quietly acquire a
default.

**OVR-15** The three drivers MUST NOT share provider-specific behaviour through `core`. Two of
them face one company's API house style, and the risk this requirement addresses is specific: an
assumption true of both Hetzner products migrating into shared code where it reads as a general
rule. **DigitalOcean's role in the launch set is to make that migration fail visibly** — a
capability, an error shape or a cancellation semantic that only makes sense at Hetzner MUST break
against it rather than being absorbed.

**OVR-16** The **capability matrix MUST be exercised, not asserted.** Three drivers with different
capability sets is the first configuration in which `OVR-2`'s runtime discovery does real work, so
a deployment MUST verify that a caller reading `GET /v1/providers` can distinguish what each
provider can actually do. *(`F10`'s capabilities-without-operations were withdrawn by `DOM-22`,
not merely tested — there are none left to verify.)*

**OVR-17** **Every component that runs without a caller MUST be assigned to a module, and here is
the assignment.** The table above allocates the request path; the periodic and background work was
allocated nowhere, and none of it had a stated home. **Most of the components below write money,
touch a provider, or both** — and the rest still need an assignment, because a component with no
module has no dependency rule, which means it has no credential boundary either. That is the reason
the requirement exists, and it does not depend on what any particular component does. Store access
is assigned like any component: through `store`, which is the only module that opens a transaction
(`OVR-9`).

*This said "every one of the components below writes money, touches a provider, or both" until
2026-09-03, and it was already false when written: `API-34`'s time-to-live sweep is "tenancy records,
no provider and no rail", `STO-14`'s retention job deletes request records, and the solvency check
"Reads balances and held satoshis". The retention row added the same day was one more. **A universal claim used as a
rationale is worth less than the argument underneath it**, which was in the next sentence all along.
The first correction of this note counted the counterexamples and undercounted them — the third time
in one day that a number written into prose in this set turned out wrong, which is why there is no
count in it now.*

| Component | Module | Why there |
|---|---|---|
| The meter (`LDG-37`, `LDG-38`, `LDG-72`) | `ledger` | Posts debits and decrements commitments, and enqueues nothing. **Where `LDG-37`'s stated source of truth is a provider usage API rather than the machine record, the driver call belongs to `engine`** and hands the meter the figures — the same shape as the sweep below |
| Rate derivation and re-derivation (`LDG-58`–`LDG-61`, `PRV-13e`, `LDG-33`) | `ledger` | A pure balance event mints no operation (`OPS-39`), and the source set is fixed at deployment (`LDG-61`) |
| Provider billing recording and derivation (*added 2026-10-04, `pv-gip.39`*) (`API-66`, `API-67`, `LDG-75`) | `ledger`, reached through `api` | Local accounting rows and a read; no provider call or payment execution |
| The solvency check (`LDG-17`, `LDG-20`) | `ledger` | Reads balances and held satoshis. **The two rail balances it needs are pushed in by `api`'s funding side** (`SEC-48`'s scoped read); `ledger` MUST NOT call `api` to fetch them, which `OVR-9` forbids and which would make the money module depend on the surface |
| The exhaustion sweep (`LDG-13`, `LDG-14`) | `engine` | It reads the machine's `runway_until` (`05-persistence.md`), and through `ledger` its commitment and whether its currency has a rate (`LDG-16`), then **enqueues** a cancellation, which is `engine`'s primitive (`OVR-9`) |
| `LDG-64`'s outage-bound canceller | `engine` | Same shape: a balance-adjacent condition — `LDG-64`'s computed deadline, read through `ledger` — whose effect is an enqueued provider mutation with `system_reason: rate_outage_bound` (`OPS-39`) |
| `OPS-27`'s resolution sweep | `engine` | It searches providers by correlator, so it needs a provider credential, and its terminal transaction writes money through `ledger` (`OPS-27`) |
| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |
| `OPS-15`'s startup pass and the worker pool | `engine` | Already implied by the table; stated so the list is complete |
| The settlement watcher (`STO-30`–`STO-32`, `LDG-47`, `LDG-57`) | `api` | It holds the payment-rail material `OVR-10b` keeps away from the lifecycle side, and posts its credits through `ledger` |
| `API-34`'s time-to-live sweep | `api` | Tenancy records, no provider and no rail |
| `STO-14`'s retention job | `api` | It deletes settled operations, which is a **request** record, and never an episode (`STO-52`): an attempt's row aging out leaves the episode it belonged to open, which is the point of the episode being a row of its own (`ADR-0017`) |
| `STO-42`/`STO-43`'s abuse and address retention | `api` | Tenancy-adjacent records, no provider and no rail. **It is not the row above**: `STO-43` says `STO-14` "reaches **settled operations** and nothing else", so closed cases, statement bodies and `machine_addresses` run on ages of their own. Added 2026-09-03 |

**Three of these placements are the ones a builder gets wrong**, so the reasoning is recorded rather
than left to be re-derived. The exhaustion sweep looks like money and is not: it is a machine
mutation triggered by a balance, and `LDG-13` calls cancellation "the only effective remedy", so it
belongs where mutations are enqueued and executed. The settlement watcher looks like the ledger and
is not: it terminates a Lightning subscription and a chain scan, which is rail material, and putting
it in `ledger` would drag a spending-adjacent credential into the module `engine` depends on. And
the retention job looks like a store-maintenance chore that could live anywhere: it deletes rows the
queue depends on, and the one table it must **not** reach is on the machine.

*The list is closed as of 2026-09-03 and MUST be extended when a component is added, which is the
obligation this requirement really carries — an unassigned background job is an unassigned
credential boundary.*

**A module is not a process, and the three `ledger` rows run in the engine process** (added
2026-09-12, decided at `F51`'s landing and recorded there). The table assigns a module, which fixes the dependency rule and the credential
boundary; it did not say which process hosts a periodic component, and `STO-55` sizes the engine's
pool by counting them. The meter, re-derivation and the solvency check run in the one engine
process: each writes on a schedule, and `api` replicas each running them would contend on
`LDG-35`'s primitive for the same subject. The engine calls them through `ledger`'s interface,
which is the dependency direction `OVR-9` already allows.

*It was extended once already, the day after it was closed, and by exactly the omission it warns
about: `STO-42` and `STO-43` require a purge of closed cases, statement bodies and address history on
stated ages of their own, and the table carried only `STO-14`'s operation retention. `STO-43` had
even written down why the two are not one job — a citation to `STO-14` "is not a clock" — and this
list still read as though it were. **The obligation is not merely to add a row when a component is
invented; it is to add one when a requirement elsewhere mandates periodic work**, which is the form
this miss actually took. The `machine_addresses` half is the one with a customer-visible
consequence: purging it shortens the horizon `SEC-54` can answer an abuse notice over, so an
unassigned job here silently narrows a control two conformance items depend on.*

**OVR-18** The engine's liveness MUST be alarmed. While the engine is down no exposure-reducing
mechanism runs (`LDG-14`, `OPS-32`, `SEC-45`'s fan-out), and the restart window is the accepted
outage (`ADR-0016`); the supervisor's restart guarantee and the alarm threshold are deployment
parameters (`OVR-19`). **Two more conditions are alarmed on the same model** (added 2026-09-12,
`ADR-0023`): the recovery point exceeding its threshold, and a stalled synchronous standby, which
hangs the two money-in transactions `STO-7` commits synchronously and nothing else.

**OVR-11** The host running the service MUST have an SSH client, an SSH key generator,
and — if any configured provider uses password-based rescue — a non-interactive
password helper for SSH.

**OVR-12** The operation store and the rescue recovery directory MUST be on encrypted
storage. Both contain material that grants access to customer machines: signed image
URLs in the former, recovery private keys in the latter.

## Deployment parameters

**OVR-19** **A parameter is on this register or it is not a parameter.** Every value the set
says a deployment MUST state is listed here, with the requirement that mandates it. Startup MUST
validate every startup-validated row and refuse to run on a missing or out-of-range value; the rows
marked human are procedures the deployment records rather than values the process reads.

| Parameter | Mandated by | Type | Startup-validated |
|---|---|---|---|
| Rate source set | `LDG-61` | list of sources | yes |
| Rate quorum | `LDG-59` | integer | yes |
| Rate window, per billing currency | `LDG-58`, `LDG-59` | duration | yes |
| Rate pass cadence | `LDG-59` | duration | yes |
| Source staleness bound | `LDG-59` | duration | yes |
| Outlier band | `LDG-60` | basis points | yes |
| Maximum tolerated rate outage | `LDG-64` | duration | yes |
| On-chain confirmation depth | `LDG-48` | integer | yes |
| Per-rail floors | `LDG-52` | satoshis, per rail | yes |
| Deposit expiry | `LDG-54` | duration | yes |
| Channel-balance treatment in solvency | `LDG-53` | rule | yes |
| Billing period | `LDG-68` | calendar month, UTC | yes |
| Re-derivation interval | `PRV-13e` | duration | yes |
| Account-sweep interval | `OPS-32`, `LDG-74` | duration | yes |
| Worst-case operation hold, per product | `PRV-13b` | duration | yes |
| Margin | `LDG-24` | basis points | yes |
| Runway floor | `PRV-13d` | duration | yes |
| Image host allowlist | `SEC-19` | list of host patterns (`SEC-20`) | yes |
| Raw-disk single- or two-pass mode | `RSC-30` | enum | yes |
| First-use-trust policy, per provider account | `SEC-22`, `SEC-24` | enum | yes |
| Autonomous per-principal ceilings and their interval | `SEC-39` | integers, duration | yes |
| Operator-principal ceilings | `SEC-39` | integers | yes |
| Lightning ceiling | `SEC-49` | satoshis | yes |
| Order budget, per ordering account | `PRV-40` | `{limit, per}` — declared by the driver (`PRV-44`); the deployment may lower it | yes |
| Enrolment per-source concurrency | `API-36` | integer | yes |
| Pending-tenant ceiling | `API-41` | integer | yes |
| Rescue timeouts | `RSC-35` | durations | yes |
| Address canonical form | `STO-41` | normalisation rule | yes |
| Retention windows | `STO-14`, `STO-43` | durations | yes |
| `allow_orders`, per ordering account | `DOM-16` | boolean | yes |
| Negative-resolution window, per provider | `OPS-33` | duration | yes |
| Tenant-to-account assignment policy | `API-57`, `SEC-43` | policy over assignable accounts | yes |
| Startup-lock wait bound | `OPS-47` | duration | yes |
| Startup-lock connection keepalives | `OPS-47` | durations | yes |
| Store-retry bound | `OPS-49` | duration | yes |
| Recovery point | `STO-54` | greatest age of a committed write not yet in a separate failure domain | no — outside the process |
| Recovery-point alarm threshold | `STO-54` | duration | yes |
| Synchronous standby name | `STO-7`, `STO-54` | identifier | yes |
| Derivation-index gap on restore | `STO-54` | integer | yes |
| Migration `lock_timeout` and retry count | `STO-13` | duration, integer | no — the migrator's, read at `migrate` |
| Store timeouts: `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout` | `STO-7`, `STO-55` | durations | yes |
| Engine worker count | `STO-55` | integer | yes |
| `api` request concurrency per replica, read and write | `STO-55` | integers | yes |
| Pool checkout bound | `STO-55` | duration | yes |
| Synchronous-commit concurrency cap per replica | `STO-55` | integer | yes |
| Connection budget against `max_connections` | `STO-55` | human — the sum across every process at maximum rollout overlap | no; the engine checks its own share |
| Metering cadence | `LDG-37` | duration | yes |
| Engine liveness alarm threshold | `OVR-18` | duration | no — outside the process |
| Supervisor restart guarantee | `OVR-18` | statement | no — outside the process |
| Reconciliation rota | `OPS-26` | human | no |
| Recovery directory | `RSC-20` | absolute path | yes |
| Recovery-key inventory procedure | `RSC-21` | human | no |

**The maximum tolerated rate outage is read at the value in force when `LDG-64`'s deadline is
computed, for an outage already open too.** Lowering it below the elapsed outage makes that
outage's cancellations eligible at the restart loading it, with no further notice. `LDG-58`,
`LDG-59` and `STO-37` own rate verdicts and historical replay. *Amended 2026-10-04
(`pv-gip.28`, `ADR-0029`): the 2026-10-02 rule now applies to the maximum only; the
2026-10-03 current-setting extension to paused grace is withdrawn. `ADR-0029` holds the
rationale and `WIR-30` the offer disclosure.*

## Non-goals

The following are explicitly out of scope. A deployment that needs them MUST obtain
them elsewhere, and the specification does not pretend to provide them:

- end-user identity verification or KYC — deliberately unnecessary, because a prepaid
  balance is the entire spending authority (`ADR-0002`) and an unpaid stranger can do
  nothing;
- automatic reconciliation of duplicated provider resources;
- image signature verification beyond a caller-supplied content digest;
- console proxying or KVM-over-IP;
- network, firewall, or DNS-zone orchestration beyond reverse DNS;
- automatic filesystem expansion after a raw-image write beyond a single optional
  partition-grow step.

**Three entries were withdrawn from this list on 2026-08-10** and are recorded here rather
than deleted, because a reader who remembers them needs to know they were reversed
deliberately.

- **"Customer billing, invoicing, or quota enforcement."** Withdrawn. Self-serve enrolment
  plus prepaid balance (`ADR-0002`) makes a ledger, commitments, and balance enforcement part of
  this system's core. Nothing else can hold the reserve at the instant a create is
  authorized (`API-17b`).
- **"Abuse handling."** Withdrawn. It was defensible when tenants were operator-configured;
  once a stranger's agent can enrol itself it is this system's problem (`SEC-41`, `SEC-42`).
- **"Cancellation of dedicated-server contracts… a business process, not an API call."**
  Withdrawn as both wrong and dangerous. Wrong: Hetzner Robot cancels immediately over its
  API with no minimum term (`PRV-13c`). Dangerous: under prepaid authority, **automated
  cancellation is the enforcement mechanism.** A balance that reaches zero with no way to
  stop the meter converts a customer's exhausted credit into the operator's ongoing loss.

**OVR-13** The list above MUST be kept current. A capability that is modelled but not
implemented MUST return an explicit "unsupported" error rather than failing obscurely
or silently succeeding.
