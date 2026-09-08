# provisiond implementation-process report 01

**Date:** 2026-09-06  
**Scope:** implementation analysis only; no implementation was produced  
**Repository reviewed:** the complete specification set: `README.md`, `CONTEXT.md`,
`executive-summary.md`, numbered documents `00` through `13`, the conformance checklist,
the open-findings record, and every ADR in `docs/adr/`

## 1. Executive conclusion

Tau can coordinate an implementation of provisiond, but a responsible full implementation
should not begin from the current documents unchanged.

The architecture and most of the product decisions are unusually well developed. The set has a
clear safety spine:

- a single deployable with structural module boundaries;
- a prepaid balance as the sole spending authority;
- PostgreSQL transactions joining authorization, commitment and durable work;
- first-class uncertainty rather than blind mutation retries;
- provider-neutral lifecycle and rescue orchestration;
- exact correlators and evidence-based reconciliation;
- integer-satoshi accounting with fixed commitments and floating runway;
- strict separation of customer, provider and payment-rail credentials;
- server-side controls designed for autonomous callers.

However, the cross-document review found current normative conflicts and underspecified interfaces
that force an implementer to choose behavior the specification is supposed to choose. Several affect
requeue, lease fencing, cancellation recovery, rescue credentials, provider cleanup, wire schemas and
multi-replica behavior. Those are safety-bearing areas involving purchases, indefinite billing,
customer disks or credentials.

The correct first implementation deliverable is therefore an **executable, repaired contract**:
a pinned requirement registry, resolved contradictions, exact schemas, chosen deployment parameters,
and runnable conformance tests. Production code follows that.

This report does not propose adding implementation code to this repository. The repository boundary
is explicit:

> `README.md`: “Nothing that implements the specified system belongs here, and none should be added.”

An implementation should live in a separate repository and pin the specification revision it claims
to satisfy.

## 2. Review confidence and limits

The specification gates passed before the analysis and again before this report was written. At the
time of review they reported:

- no duplicate, dangling or gapped live identifiers;
- valid JSON fixtures and Mermaid structure;
- no orphaned cross-requirement obligations;
- clean quoted attributions against the citation gate;
- all executable arithmetic claims passing;
- 363 of 501 requirements covered by at least one conformance item;
- 97 ratcheted uncovered requirements plus 41 uncovered `SEC`/`WIR` requirements reported separately.

That green result is evidence of internal hygiene, not release readiness. It does not execute an
implementation, validate provider behavior or establish complete requirement coverage. The
specification itself records the same calibration:

> `README.md`: “Nothing here has been validated against a running implementation.”

The current checklist also contains items added after its maintained blocking-count passage. Some
recent items lack an explicit tier assignment, and one withdrawn item remains formatted as a
checkbox. Release planning should use the actual item list rather than copying a prose count.

At the reviewed revision every checklist box remains unchecked. The checklist's own opening treats
an unchecked item as the same kind of evidence-free green result produced by the discarded
zero-test suite. No implementation may claim conformance by inheriting the specification
repository's green document gates.

## 3. Intended product

Provisiond is a multi-provider compute-reseller control plane. One operator holds provider
accounts and pays provider invoices. Tenants prepay the operator, then create, adopt, inspect,
install, power, reverse-DNS and delete virtual or dedicated machines without receiving provider
credentials.

The expected caller is software, including an autonomous agent. This changes the control model:

- confirmation booleans communicate intent but cannot constrain a caller that always supplies them;
- the server needs independent per-principal ceilings;
- reads for balance, runway, capabilities and operation state prevent callers from probing through
  writes;
- stable error kinds and normative retry guidance prevent mutation loops;
- server-paced polling replaces webhooks and caller-selected callbacks.

The provider abstraction does not flatten providers to their common subset. Capability discovery is
part of the protocol, and a declared capability must correspond to a working implementation.

The v1 launch set is Hetzner Cloud, Hetzner Robot and DigitalOcean. This spans cloud and dedicated
machines across two companies. DigitalOcean deliberately prevents Hetzner-specific behavior from
quietly becoming a general rule.

## 4. Architectural shape

### 4.1 Deployment form

The target is one deployable, not a customer-facing service in front of a separate
credential-holding service. The central reason is transactional: authorizing a purchase, opening its
commitment and creating its durable operation must be one database transaction.

The accepted dependency boundary is:

> `OVR-9`: “`api` MUST NOT depend on `providers` or `rescue` at all, and MUST reach `engine` only
> through a trait whose signatures mention no credential type. `engine` MUST NOT depend on `api`.”

The implementation should contain these modules:

| Module | Responsibility | Allowed direction |
|---|---|---|
| `core` | Domain types, capabilities, errors and provider interface | Depends on no infrastructure |
| `providers` | Isolated provider adapters | Depends on `core` |
| `rescue` | Generic SSH, inventory and image workflows | Depends on `core` |
| `ledger` | Entries, commitments, rates, meter, solvency and tenant serialization | Depends on `core` |
| `engine` | Queue, workers, provider calls, reconciliation and lifecycle sweeps | Depends on `core`, `providers`, `rescue`, `ledger` |
| `api` | HTTP, auth, tenancy, enrolment, funding and abuse | Depends on `core`, `ledger` and a narrow engine interface |

The credential boundary must be structural:

> `OVR-10a`: “The boundary MUST be enforced by the code's structure — module privacy, a narrow trait,
> a dedicated type owning the secret — and not merely documented.”

Provider secrets should be read once during startup by the owning module and then removed from the
real runtime environment:

> `OVR-10c`: “Provider credentials MUST be read from the environment exactly once, at startup, by
> the credential-owning module — and then removed from the process environment.”

Operator-only routes should be mounted on a separate TLS listener. Customer routes must have no
reference to provider adapters or credential-bearing types.

### 4.2 Storage

PostgreSQL is the chosen engine. The implementation needs:

- versioned forward-only migrations;
- connection settings applied on every pool checkout;
- atomic claim with row locking and skip-locked behavior;
- atomic conditional machine-lock upsert;
- transaction-scoped per-tenant advisory locks;
- ascending tenant identifier order when one transaction spans tenants;
- engine-enforced guarded transitions and append-only ledger writes;
- multiple service replicas and database recovery procedures.

The lock order is one-way:

1. operation lease;
2. machine lock;
3. short tenant-serialized transaction.

No provider call, network wait, child-operation wait or machine-lock acquisition may occur while
tenant money serialization is held.

### 4.3 Background ownership

Every component that runs without a caller needs a declared module home:

- meter, rate derivation and solvency checking: `ledger`;
- worker pool, lease sweep, reconciliation, exhaustion, outage cancellation and provider-account
  sweep: `engine`;
- settlement watcher, enrolment TTL, operation retention, abuse retention and address-history
  retention: `api`.

Any new periodic component must extend that closed assignment before it is implemented.

## 5. Correctness spine

### 5.1 Durable operations

The normal provider-touching write path begins with a durable operation:

> `OPS-1`: “Every mutating request MUST create or return a durable operation record before any
> provider call is made, and MUST respond `202 Accepted` with that record.”

Operation states are `queued`, `running`, `succeeded`, `failed` and
`needs_reconciliation`. Only `succeeded` and `failed` are terminal.

Uncertainty is not an ordinary failure:

> `OVR-5`: “The mutation MUST NOT be retried automatically, and no timer may clear the state.”

Evidence gathering may resolve uncertainty; it must not repeat the provider mutation. Exact
correlator matches, direct provider reads, visibility windows and explicit operator verbs are the
resolution mechanisms. Hostname, offer and timing heuristics must never attach a resource.

### 5.2 Money authorization

The ledger is the authorization system, not a reporting subsystem. Customer monetary quantities are
integer satoshis. Provider-native values retain currency and exact conversion evidence.

The operational invariant is:

```text
available = latest balance_after - sum(open commitment reserved amounts)
authorize when available >= required commitment
```

The underlying definition remains the sum of append-only entries; `balance_after` is the indexed
operational read and must be auditable against that sum.

For create and adopt, the following belong in one tenant-serialized transaction:

1. read current balance and open commitments;
2. calculate and verify required commitment;
3. open the commitment;
4. enqueue the operation;
5. write the idempotency record and exact response.

A commitment without an operation freezes customer value. An operation without a commitment spends
operator money. A transaction boundary between them is therefore unacceptable.

### 5.3 Commitments, meter and runway

A commitment is a separate record associated with a machine. It decreases with each machine
attributable debit. Ordinary usage decreases both ledger balance and commitment by the same amount,
leaving available balance unchanged.

The meter should operate cumulatively per subject and UTC billing period. It must:

- split increments at rate and billing-period boundaries;
- subtract only documented rate-outage time;
- round cumulative customer charge rather than each polling tick;
- persist its high-water mark and fractional rounding credit atomically with the debit;
- leave meter state unchanged when a correction entry is posted;
- clamp customer debits to granted commitment and send excess to an operator-deficiency record.

Commitments are fixed after authorization. Exchange-rate changes move `runway_until`; they do not
automatically seize additional available balance. An explicit extend-runway action is the normal
growth path.

### 5.4 Exposure reduction

Powering a machine off does not necessarily stop provider billing. Exhaustion therefore ends in
cancellation/deletion, not merely power-off.

Exposure-reducing actions must remain possible during rate, solvency and tenant-suspension failures.
Cancellation and extend-runway race through a durable machine fence so exactly one decision wins
without holding money serialization across a provider call.

Attachments such as volumes, snapshots, backups and reserved addresses must remain separately
metered until released. Machine tombstoning is blocked while a billable attachment survives.

### 5.5 Rescue and installation

The rescue engine is generic:

> `RSC-2`: “The engine MUST NOT contain provider conditionals. Everything provider-specific lives
> behind the driver interface.”

The rescue flow should be:

1. generate a per-operation keypair;
2. ask the driver to activate rescue and reboot;
3. refresh until provider host keys or the boot-derived deadline;
4. apply the complete host-trust decision table;
5. connect with an isolated strict known-hosts file;
6. collect machine-readable disk inventory;
7. re-read inventory immediately before destructive I/O;
8. resolve stable disk identity to exactly one block device;
9. fetch and install the image;
10. exit rescue and reboot;
11. clean temporary provider credentials;
12. preserve only the permitted recovery key when exit is uncertain.

Rootfs archives are verified before the installer starts. Raw images are streamed and can only
complete digest verification after overwrite begins, so a digest failure may leave a destroyed or
partly written disk.

Catalogue installation is a different feature. Provisiond fetches, size-limits and hashes caller
bytes, rehosts an immutable copy, and gives that copy to the provider. It does not parse the image
and cannot claim that provider-converted bytes were verified on disk.

## 6. Specification blockers found by the review

These should become specification amendments before their affected code is implemented.

### 6.1 Requeue contradictions

The current narrow rule is:

> `OPS-46`: “A requeue is admissible only for an exposure-reducing cancellation — a cancel or a
> delete.”

Active-looking text elsewhere still describes ordering, adopt, install, power and reverse-DNS
requeues. The checklist contains the same conflict: one item requires only cancellation to be
requeueable while other items require install requeues or an ordering requeue to consume the
provider budget.

The stale branches are spread across the implementation surface rather than confined to historical
commentary:

- the API pipeline still describes create/adopt ordering requeues and commitment reuse;
- the operation lifecycle retains second-order repricing and multi-attempt correlator language;
- the provider contract still counts create requeue as a commitment-growth path and charges it
  against an ordering budget;
- the ledger still contains both fresh-attempt settlement language and a later one-attempt rule;
- persistence still describes marker reset for several now-forbidden requeue kinds;
- one BLOCKING checklist item forbids every non-cancellation requeue while another requires second
  attempts for install, power and reverse DNS.

Required resolution:

- state the exact requeueable operation-kind set once;
- remove unreachable ordering and install branches;
- correct the requeue request fixture;
- align failure classification, marker reset, provider budget and conformance items;
- preserve the rule that a fresh caller create is a second purchase.

### 6.2 Asynchronous-write contradiction

The overview states:

> `OVR-4`: “Every write operation MUST be asynchronous and durable.”

The API and wire documents define a growing closed set of synchronous POST operations, including
enrolment, deposits, credential recovery, resolution, runway extension and operator recordkeeping.

Required resolution: amend the owning general rule to distinguish provider mutations from local,
transactional writes and make the final exception list authoritative.

### 6.3 Lease fencing

The documented worker completion guard identifies operation state and claimant, but does not by
itself prove that the claimant still owns an unexpired lease. A stale worker can potentially write
after expiry but before the sweeper, or after the same claimant identifier has reacquired work.

Required resolution:

- add a lease generation/fencing token or database-time lease-validity predicate to every worker
  marker and terminal write;
- specify equality-at-expiry behavior;
- renew operation and machine-lock ownership atomically or under one shared generation;
- test stale worker, sweeper and new claimant at forced barriers.

### 6.4 Failed-cancellation retention

A failed system cancellation can retain the machine trigger and destruction fence, preventing a
replacement enqueue. Recovery may depend on requeueing that exact operation. General settled-operation
retention can delete it.

Required resolution: exempt operations referenced by open trigger/fence state, or atomically replace
the recovery operation and its reference before retention.

### 6.5 Rescue credential interface

One provider requirement forbids a driver from returning a generated rescue password, while the
domain and rescue flow allow an in-process rescue session to carry such authentication material.

Required resolution: define “return” as disclosure through public/result/error surfaces, or expose
credentials through an opaque, in-process secret handle that only the rescue transport can consume.

### 6.6 Capability-less mandatory operations

The provider contract broadly forbids implementing an operation without declaring its capability,
while machine lookup is mandatory and refresh intentionally has no capability. Capability
description itself is also capability-less.

Required resolution: scope the prohibition to methods with corresponding capability entries and
enumerate the mandatory capability-less methods.

### 6.7 Cross-module transaction composition

The architecture prohibits infrastructure dependencies in `core`, prohibits `ledger` from
enqueueing, and prohibits `engine` from depending on `api`. Nevertheless, API and engine workflows
must compose queue, machine and ledger writes in a single PostgreSQL transaction.

Required resolution: define an opaque transaction capability or explicit persistence-adapter module,
including which module owns repository interfaces and which dependency edges are legal.

### 6.8 Multi-replica sweeps

The provider-account sweep lacks a specified per-account lease and monotonic observation guard.
Overlapping replicas can process differently aged provider listings and let an older pass overwrite
newer evidence.

Required resolution:

- one durable sweep lease per provider account;
- observation-time compare-and-set updates;
- rules for partial versus complete listings;
- restart and takeover behavior;
- deterministic pagination semantics.

### 6.9 Provider descriptor and cleanup gaps

Deterministic behavior requires more than a set of capability strings: ordering channels,
correlator modes, evidence sources, visibility windows, order budgets, cancellation behavior and
rescue address families also influence execution.

Billable-attachment cleanup is required but lacks a complete typed driver method/result contract.

Required resolution: define typed immutable provider-account descriptors and an explicit attachment
enumeration/cleanup contract.

### 6.10 Install and inventory details

The exact wire representation and normalization of disk serials/WWNs, inventory fingerprint
canonicalization, and rootfs path handoff are not completely specified. Raw-stream digest scope also
needs an unambiguous definition: compressed source bytes versus decompressed disk bytes.

Required resolution: add exact JSON schemas, canonical byte representation, normalization rules and
golden fixtures, including duplicate stable identifiers and fingerprint drift.

### 6.11 Wire completeness

Issues found include:

- a requeue fixture retaining a now-forbidden duplicate-purchase acknowledgement;
- incomplete exact response schemas for several synchronous operator writes;
- refresh missing from the closed resolution union;
- ambiguous nested operation-error correlation identifiers;
- incomplete cursor placement for commitment pagination;
- missing nullability, ordering and bounds in several projections;
- conflict over the abuse-statement success status;
- insufficiently specified CORS headers on non-preflight responses.

Required resolution: define a single schema for every request, response, error and query parameter,
then make every example validate against the implementation parser and serializer.

### 6.12 Provider evidence and deployment parameters

Some DigitalOcean and Hetzner behaviors remain marked for verification. Provider visibility,
billing-stop and negative-resolution windows require live measurement rather than documentation
inference.

Deployment parameters still need an owned register: rate source set, quorum, staleness and outlier
band; rate-outage bound; confirmation depth; rail floors; deposit expiry; meter and sweep cadence;
margin; runway floor; image policy; autonomous and operator ceilings; Lightning ceiling; trust
policy; and order-account budget.

### 6.13 Adopt ambiguity contradiction

The operation classifier says:

> `OPS-11`: “adopt, refresh | Always `failed`. Both are read-only; a failure changed nothing.”

Other live-looking storage and wire text admits `observed`, `absent` and `abandoned` resolution
outcomes for adopt, while the correlator machinery those outcomes rely on is create-specific.

Required resolution: choose one owner and one model. The low-complexity reading is that the provider
part of adopt is a read and the local attachment/commitment write is transactional, so adopt has no
ambiguous provider mutation to reconcile. Whichever reading is accepted must be reflected in the
failure matrix, resolution union, schema constraints and conformance items.

### 6.14 Checklist selection and status metadata

The conformance checklist's maintained total predates later checklist identifiers and amendments.
Tiers are encoded in English ranges and prose rather than attached mechanically to each live item.
The audit tracker also retains historical “open” headings around findings whose bodies say they were
closed.

Required resolution:

- put a tier and live/withdrawn status on every individual conformance item;
- fail the specification gate for an untiered live item or a withdrawn checkbox;
- regenerate any derived count rather than maintaining it in prose;
- ensure mutually exclusive conformance items cannot both be launch requirements;
- treat the numbered owning requirement as authoritative rather than deriving behavior from a
  historical finding heading.

### 6.15 Further production-operability decisions

The chosen PostgreSQL design does not yet select backup/PITR procedures, pool sizing, live-migration
policy or the response to a database that is reachable but too slow. These need not block local
contract scaffolding, but they block production readiness because the database hosts every mechanism
that stops ongoing provider billing.

The first real abuse case also remains an operational canary: account-level notices, repeat-offence
policy and provider-specific case-closing signals are not generalized into an automatic protocol.
That is an accepted operator-owned boundary, not behavior an implementation agent should invent.

## 7. Proposed Tau implementation process

### Phase 0 — repair and freeze the contract

Create a machine-readable requirement registry with, for every live item:

- identifier and owning document;
- exact normative quotation;
- amendment/withdrawal state;
- dependent requirements;
- conformance item;
- release tier;
- implementation module;
- automated or manual proof;
- irreversible production harm guarded against.

Then:

1. land one specification amendment per blocker above;
2. add exact wire and storage fixtures;
3. tier every current checklist item directly on the item;
4. add conformance coverage for uncovered safety rules;
5. choose and record deployment parameters;
6. complete legal review;
7. verify launch-provider facts;
8. rerun all specification gates.

Exit criterion: no unresolved interpretation affects a BLOCKING item, and two independent reviewers
can derive the same behavior without filling in a product decision.

Before this exit criterion, only low-regret scaffolding should proceed: repository/CI setup,
compile-time dependency checks, strict core value types, the PostgreSQL migration and transaction
test harness, deterministic fakes, and contract/property-test infrastructure. Requeue and attempt
bookkeeping, create/adopt money flow, live adapters and any claim of conformance should wait for the
semantic baseline.

### Phase 1 — establish implementation repository and CI

Create a separate repository that pins the spec commit. Establish:

- the six module/package boundaries;
- dependency and compile-fail tests;
- clean-checkout build;
- strict lint;
- unit, property, integration, wire, chaos and live-certification test suites;
- proof that deliberately breaking a test fails CI;
- requirement-to-test reporting with no vacuous checkmarks.

### Phase 2 — build test infrastructure before business behavior

Provide:

- ephemeral real PostgreSQL;
- deterministic clock and scheduler;
- fake provider supporting success, deterministic rejection, lost reply, timeout, delayed visibility,
  pagination, duplicates, account failure, attachments and scheduled cancellation;
- fake rate sources with stale, outlier, quorum and outage controls;
- fake Lightning and on-chain streams with replay, partial pay, overpay, double-rail pay and
  confirmation changes;
- fake SSH/subprocess boundary recording argv, environment and scripts;
- fake immutable image store;
- explicit crash injection before and after every durable or external boundary.

### Phase 3 — implement the core and store primitives

Build:

- identifier and money types;
- closed enums and errors;
- strict JSON parser and canonical idempotency fingerprint;
- recursive secret redaction;
- provider capability/source-strategy matrices;
- migrations, constraints, indexes and database roles;
- queue claim, lease, fenced transition and machine lock primitives;
- tenant advisory-lock helper;
- idempotency and exact-response storage;
- operation payload purge and redacted closed summary.

Do not add provider HTTP adapters yet.

### Phase 4 — implement and prove the ledger kernel

Implement:

- append-only entries and authoritative `balance_after`;
- commitments and available-balance authorization;
- reserve and runway formulas;
- rate observations and quorum derivation;
- cumulative meter and rounding credit;
- corrections;
- setup-fee lifecycle;
- operator deficiencies;
- solvency and outage behavior;
- extend-runway/cancellation fence.

Use generative tests for arithmetic and forced concurrent transactions for double-spend and
write-skew cases.

### Phase 5 — implement the durable engine against fakes

Build:

- enqueue, claim, heartbeat, defer and sweep;
- total failure-classification matrix;
- pre-dispatch correlator and marker persistence;
- exact reconciliation for create and existing-machine mutations;
- zero/one/many resource handling;
- early commitment release and late attach;
- durable system-trigger deduplication;
- exhaustion and outage cancellations;
- account sweep and provider status handling;
- retention exclusions for live recovery state.

Crash-test before dispatch, after provider acceptance, after reply loss and around every terminal
transaction.

### Phase 6 — implement API, enrolment and funding

Build the common authenticated-write pipeline in this order:

1. authenticate and resolve principal;
2. apply activation rule where applicable;
3. validate idempotency key syntax;
4. authorize the resource;
5. strictly parse and validate the body;
6. check canonical fingerprint and replay;
7. apply suspension rule;
8. enforce principal ceiling;
9. execute the endpoint-class transaction.

Then add:

- customer and recovery credential lifecycle;
- separate operator listener;
- enrolment admission and pending-tenant TTL;
- deposits and both settlement rails;
- balance and runway reads;
- provider/offer discovery;
- server-paced operation polling;
- synchronous operator recordkeeping;
- abuse and address-history surfaces.

### Phase 7 — implement providers and installers

Recommended development order:

1. Hetzner Cloud for low-cost lifecycle iterations;
2. Hetzner Robot for the dedicated ordering, setup-fee, rescue and cancellation path;
3. DigitalOcean to exercise cross-company behavior and catalogue installation.

All three must pass launch certification before the first customer; development order is not a
scope reduction.

Build adapters in layers:

1. capability descriptor and `get_machine`;
2. error normalization and redaction;
3. create and correlator;
4. mutation evidence and visibility windows;
5. delete/cancel and attachments;
6. rescue activation/session cleanup;
7. catalogue import/build/delete.

Build rescue separately over the provider interface: trust, SSH transport, inventory, disk identity,
rootfs install, raw install, recovery-key handling. Build catalogue fetching with per-hop SSRF
validation, size/digest streaming, immutable rehosting and orphan cleanup.

### Phase 8 — destructive and operator workflows

Complete:

- suspension fan-out and resume fencing;
- cancellation episode recovery;
- account termination;
- late-attach cleanup;
- operator resolution;
- abuse mediation;
- network-restriction recording;
- account assignment;
- orphan machine and image reporting;
- retention and audit jobs.

Test all workflows with workers paused at every lock and transaction boundary.

### Phase 9 — certification and launch

Run:

- all launch-BLOCKING conformance items;
- every JSON fixture through real parsers;
- tenancy and cross-principal isolation tests;
- credential reachability and environment-scrub tests;
- mutation idempotency and ambiguity campaigns;
- meter cadence-independence properties;
- rate-quorum and outage drills;
- database restart/failover and backup/restore;
- stale worker and sweep races;
- catalogue SSRF/rebinding/redirect corpus;
- live provider tests with capped spend and teardown evidence;
- measured billing-stop, visibility and negative windows;
- cold-key recovery and Lightning ceiling drills;
- legal/customer-disclosure review.

No unchecked BLOCKING item should be converted into a waiver merely because its test is expensive.

## 8. Harness orchestration

Tau should be used as an engineering coordinator, not as the production control plane.

Recommended agent arrangement:

- one driver agent owns the dependency graph, requirement registry and integration order;
- bounded implementation agents own one module or one conformance family;
- one schema/transaction owner serializes cross-module PostgreSQL changes;
- read-only reviewer agents verify correctness and hunt stale or over-specified behavior;
- a skeptic reviews each phase for invented behavior not required by the contract;
- live-provider and legal gates remain human-owned.

Each implementation task should contain:

1. an exact quotation of the requirement being implemented;
2. the owning requirement identifier;
3. the conformance item and tier;
4. explicit non-goals;
5. expected storage and provider-call effects;
6. crash points and concurrent interleavings;
7. a pass/fail oracle;
8. a statement of what must remain impossible.

Agents should not edit the same module or migration concurrently. Use directory locks, small
commits and one integration owner. Run relevant focused tests after each patch and the entire suite
at every phase boundary.

When requirements conflict, the agent should stop and open a specification issue. It should never
select behavior from dates, intuition or majority wording when money, disks, credentials or
cross-tenant authority are affected.

## 9. Secret and live-system safety

Tau's supervised-extension isolation is defense in depth, not hostile-code containment. Production
provider credentials, Lightning authority and cold spending keys should not be made available to
the harness or model agents.

Use:

- fake credentials for ordinary development;
- isolated sandbox or dedicated certification accounts;
- minimum provider permissions;
- order-disabled defaults;
- hard spend ceilings;
- operator-controlled execution of real-purchase tests;
- separately hosted Lightning node with the narrow enumerated credential;
- watch-only on-chain material in the application;
- cold keys entirely outside the application and harness.

Live certification should record provider account, API version, time, fixture, cost, teardown,
observed behavior and evidence expiry. A documentation check alone is not adequate for load-bearing
provider facts.

## 10. Human decisions that cannot be delegated to implementation agents

Humans must own:

- the legal conclusion on the satoshi-denominated claim and custody characterization;
- enforceability and presentation of the no-refund/B2B terms;
- provider-account and tenant-distribution policy;
- approval and budget for real provider orders;
- rate-source independence assessment;
- provider-account linkage assessment;
- cold-key creation, backup and recovery;
- Lightning reduction procedure and cold destination;
- reconciliation rota and incident procedure;
- final production parameter register;
- acceptance of any PRE-SCALE risk and the date its promotion trigger is reached.

## 11. Release criteria

The service is ready to accept traffic only when:

- the implementation pins a repaired specification revision;
- every live conformance item has a tier and evidence owner;
- every BLOCKING item passes;
- no safety-bearing requirement lacks an executable or explicitly human proof;
- all three launch drivers are certified;
- provider visibility and billing windows are measured;
- deployment parameters are recorded and startup-validated;
- database recovery and multi-replica behavior are demonstrated;
- secret-boundary and custody drills pass;
- legal and customer-facing terms are approved;
- monitoring can identify unresolved operations, failed cancellations, meter/rate failures,
  provider-account problems, unattributed payments and retained recovery keys.

The first external tenant should be treated as a controlled production experiment with lower
ceilings, heightened invoice reconciliation and explicit rollback/termination procedures. It must
not substitute for the launch gate; it follows it.

## 12. Final assessment

Provisiond is implementable in principle and has a coherent high-level architecture. Its hardest
parts are correctly identified: uncertain provider mutations, money authorization, cumulative
metering, stable disk identity, provider facts and automated cancellation.

The current set is not yet an unambiguous construction contract. The remaining problems are
concentrated in exactly the areas where an apparently reasonable guess can buy a second server,
leave one billing forever, destroy the wrong disk, attach the wrong resource or leak a credential.

Tau can implement the system effectively if it follows this order:

1. repair and freeze the contract;
2. construct traceability and test infrastructure;
3. prove architecture and PostgreSQL primitives;
4. prove the ledger;
5. prove the durable engine against fakes;
6. add API and funding;
7. certify providers and install paths;
8. run destructive, concurrency, recovery and human launch gates.

No application code was written as part of this analysis.
