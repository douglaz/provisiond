# Promotion action/history audit (2026-10)

## Baseline, authority and evidence

Audit for `pv-v4gp`, pinned to current master and Run base
`3fa6e997203900570330bc71036a91aa6e2dc9d7` (PR #40), on 2026-10-29.
This is a descriptive research record. It changes no requirement, decision, conformance
obligation or deployment duty. The source owners linked below remain authoritative.
[ADR-0045](../adr/0045-every-commit-waits-for-a-standby-and-promotion-follows-wal-history.md)
states the objective “irreversible external consequences must not depend on history a promotion
classified as a restart may discard” and immediately qualifies it: “This is rationale, not an
additional requirement.” Every candidate and deployment-misconfiguration trace is collected in
[Candidate follow-ups](#candidate-follow-ups); no follow-up issue is requested.

The inventory is a join of the following source lists, rather than a remembered list of
provider writes. The lists themselves hold their membership; this record groups them by
licensing evidence and external effect, without copying their counts.

| Source at the baseline | Use in this audit |
|---|---|
| [Provider contract, Operations](../../02-provider-contract.md#operations), including descriptor, attachment and catalogue methods | Driver reads, registrations, orders, machine mutations, rescue, image import/build/delete and resource cleanup |
| [Lifecycle](../../03-operation-lifecycle.md), especially claiming, worker algorithm, reconciliation, retention and periodic paths | The ordering between admission, claim, authorizing reads, barriers, dispatch, settlement and cleanup |
| [API Surface](../../04-api-contract.md#surface), [API-48, Funding](../../04-api-contract.md#funding) and [wire Endpoints](../../13-wire-contract.md#endpoints) | Caller/operator requests, synchronous exemptions, responses, secrets and administrative paths |
| [Wire Views](../../13-wire-contract.md#views), including WIR-10a's closed kind enumeration | Cross-check operation kinds against the request and driver inventories |
| [OVR-17, component assignment](../../00-overview.md#deployment-assumptions) | Work without a caller: worker/startup, account/resolution sweeps, exhaustion sweep, LDG-64's outage-bound canceller, offer refresh, meter, rate derivation, solvency, settlement watching, tenancy and retention; I-BACKGROUND maps the cancellation triggers to I-MACHINE and its traces |
| [Rescue/install](../../06-rescue-install.md), [security](../../07-security-requirements.md), [ledger](../../12-billing-and-ledger.md), [persistence](../../05-persistence.md) | Remote disk effects, image copies, credentials, audit records, rail effects, money writes and promotion evidence |
| [Glossary](../../CONTEXT.md), [requirement conventions](../../README.md#requirement-conventions) and [withdrawn index](../../README.md#withdrawn-identifiers) | Restore/restart/runway vocabulary and exclusions |

Historical inputs are [r63h's chosen form, FSW-N and F4](panels-2026-10/r63/r63h/forms-chosen.md),
[forms and errata](panels-2026-10/r63/r63h/forms-r63h.md),
[brief](panels-2026-10/r63/r63h/brief.md), [notes](panels-2026-10/r63/r63h/notes.md),
[owner questions](panels-2026-10/r63/r63h/owner-questions.md), and
[tally, including the opposing runway arguments](panels-2026-10/r63/r63h/tally.md).
The original answers in that archive were read as arguments, not as current authority.
[r63g's verification record](panels-2026-10/r63/r63g/verify.md) is read subject to those errata.
The voided universal claim about provider mutations and the unmeasured latency characterization
are not premises here. [The earlier provider research](provider-verify-2026-10.md) supplies the
layout/evidence convention, not policy. Later decisions are checked against
[r74's owner decisions](panels-2026-10/r74/owner-decisions.md) and the present owners below;
archived proposals do not override landed text.

Evidence kinds used here:

- **Current text:** quotations checked against complete current owning blocks. A quoted rule
  is a premise, not proof that a deployment satisfies it.
- **Source deduction:** PostgreSQL at commit
  `b049b4e7b4a159d373ef394bda67f7cf25758998`, the source pin in ADR-0045:
  [syncrep.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L280),
  [xact.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1506),
  [postmaster.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/postmaster/postmaster.c#L3473)
  [heapam.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/heap/heapam.c#L5377),
  and [postgres.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/tcop/postgres.c#L3023).
  These sources were re-read for local flush, wait interruption, transaction visibility,
  lock release, row-lock WAL generation, per-child signalling and pending-signal handling. They do not establish a
  duration or a provisiond execution.
- **Archived measurement:** r63g's H-b transcript reports termination of a waiting backend
  followed by visibility (`3|T`); H-d/H-e concern histories and promotion; H-f concerns
  the read-only check. These are database ingredients reported by the archive, not newly
  executed experiments. H-b is not the full fast-shutdown schedule.
- **Formal deduction:** [WalHistory.lean](../../tools/formal/Provisiond/WalHistory.lean),
  with the checking interpretations in [STO-7](../../05-persistence.md#engine-choice) and
  [STO-54](../../05-persistence.md#backup-and-restore). Actual record identity, history
  agreement, read/target order, truthful continuous durable prefixes and synchronous
  acknowledgement are independent hypotheses. Equal labels/positions supply none of them.
- **Conditional trace:** an event order with stated premises, not an implementation measurement.
  “Proved” below is limited to an implication under those premises or an existing formal
  theorem; it never means a deployed provisiond was tested. There is no implementation here.

No live deployment or new database campaign was used. Raw source copies and audit scratch stay
under `/var/tmp/rloop-units/provisiond-spec-pv-v4gp-1029T053526/audit/`; no raw logs or secrets
are part of this record.

## What an acknowledgement establishes

| Fact | Current owner and exact words | Audit interpretation |
|---|---|---|
| A local commit can differ from acknowledgement | [STO-7](../../05-persistence.md#engine-choice): “A commit that returns PostgreSQL's warning” “is not acknowledged: the component treats it as a lost reply” | Local visibility, a replication-warning reply, a dead transport and successful acknowledgement are distinct observations. A lost response might follow replication; it does not establish either loss or absence. |
| Successful synchronous commit | [STO-7](../../05-persistence.md#engine-choice): “PostgreSQL acknowledges a commit only once one of them has flushed it to durable storage” | A received acknowledgement protects that actual record under the stated replication/history premises. An ordinary HTTP read response is not that acknowledgement. |
| A new-connection check | [STO-7](../../05-persistence.md#engine-choice): “A component checks each new connection before using it” and “never by committing a write” | Its target precedes later work. It does not by itself certify a later read. |
| A read-only response | [API-54](../../04-api-contract.md#completion-and-pacing): “A read MUST NOT take a write transaction.” | Reading an exposed value is no implicit WAL-writing barrier. A read-only COMMIT does not make an earlier writer's record synchronous. |
| No transaction across an external call | [STO-55](../../05-persistence.md#engine-choice): “MUST NOT hold a transaction open across a provider, rail or rescue-host call” | Check each action's actual earlier transaction and acknowledgement; do not invent a transaction around the call. |
| Same-history barriers | [STO-7, checking interpretation](../../05-persistence.md#engine-choice): “Commit identity is independent of position; prefix agreement is about records, not equal timeline labels.” | A later acknowledged WAL write can protect an earlier observed commit only on the relevant actual history. See T-CREATE and T-MUTATE. |
| Promotion selection | [STO-54](../../05-persistence.md#backup-and-restore): “a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal)” and “both hold a prefix of one WAL sequence” | Maximal truthful reports on one history protect acknowledged records. Numerical equality alone is not restart eligibility. See T-EQUAL. |

## Inventory and evidence mapping

The identifiers I-* are audit rows, not requirement identifiers. Named F4 cases have their own
trace links. Grouping similar wire routes does not generalize an ordering proof to every phase.

| Class and source-list members | Reads, writes, acknowledgements and external evidence | Disposition / trace |
|---|---|---|
| **I-READ:** descriptor, offer and machine/attachment reads; refresh; provider observations; health and ordinary GET views (provider Operations, API Surface, wire Views/Endpoints) | [PRV-12](../../02-provider-contract.md#get-machine): “Get machine MUST be read-only and free of side effects”; [PRV-50](../../02-provider-contract.md#list-offers): “The driver's List offers MUST be read-only”; [PRV-45](../../02-provider-contract.md#list-attachments--release-attachment): “List attachments is read-only”. A provider read has external provider evidence, while a cached view has the stored observation history. Neither is acknowledgement of a pending store writer. | Non-mutating at the provider; observed response history still matters. Revision: [T-REVISION](#t-revision). Runway: [T-RUNWAY](#t-runway). Deposits are separated below. |
| **I-CREATE:** caller create, including key uploads, ordering channels, purchase checks and late attachment | [OPS-43](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “Step 9 MUST begin only after step 8's transaction is acknowledged.” Its step 9 is “Perform the per-order key upload, then the order.” The admission/claim/account/correlator/about-to-order writes precede dispatch; provider acceptance and exact correlator/resource reads are a separate truth about outcome. [OPS-27](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “A create MUST NOT settle `succeeded` on the strength of the reply in hand alone.” | [T-CREATE](#t-create), a non-counterexample for pre-order history. Settlement history is not inferred from the provider having accepted. Key cleanup is I-KEY. |
| **I-MACHINE:** power, reverse DNS, native/catalogue rebuild, caller delete, system cancellation, API-cleanup attachment release | [OPS-45](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “The engine MUST persist a write-started marker on the operation” “before that phase runs”; “each acknowledged by the store before the provider call it precedes is made.” [PRV-25](../../02-provider-contract.md#set-reverse-dns): “An identical established value MUST settle `succeeded` without a provider call.” [PRV-45](../../02-provider-contract.md#list-attachments--release-attachment): “Release attachment is its own operation kind”. | [T-MUTATE](#t-mutate) protects preceding same-history reads when the actual barrier is later and acknowledged. Scheduled cancellation and release keep their own provider outcome/effective-date evidence; a dispatched marker alone is no proof of deletion. Funding cancellation also needs [T-RUNWAY](#t-runway). |
| **I-RESCUE:** begin/refresh/end rescue, inventory, rootfs/raw-disk writes, image downloads and post-install commands (rescue Sequence and driver rescue methods) | [OPS-45](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “false, written before begin rescue” and “true when the driver's end-rescue call returns success”; the destructive-phase marker has its own later position. [RSC-25](../../06-rescue-install.md#rootfs-archive-installation): “The digest MUST be verified after download and before the installer runs.” [RSC-19](../../06-rescue-install.md#failure-handling): “An engine crash persists nothing”. | The rescue-entry acknowledgement protects entry inputs; it does not establish a later disk result or clean exit. Destructive phases use T-MUTATE separately. SSH pins/digests/provider observations remain their own evidence; inventory boots rescue even though it does not write the disk. Recovery private keys and human removal are I-HUMAN. |
| **I-IMAGE:** catalogue re-host/import/poll/build, ordinary purge and orphan image deletion | [RSC-39](../../06-rescue-install.md#catalogue-installation): “store it in operator-controlled immutable storage” and “The caller's own URL MUST NOT be passed to the provider.” [RSC-41](../../06-rescue-install.md#catalogue-installation): “The import touches no machine; only the switch-over does.” [RSC-42](../../06-rescue-install.md#catalogue-installation): “Both copies of the image are purged when the operation stops being live” including “on entry to `needs_reconciliation`”. Admission/claim backs the install; import/re-host consumes network/storage, build has its separate marker, and cleanup has a different license. | Do not infer a pre-import barrier after every revalidation read from the later rebuild marker. No particular import loss is established here. Read-licensed orphan deletion is checked in [T-IMAGE](#t-image): its protection is conditional on a WAL-writing COMMIT acknowledged before dispatch, a premise not established here by the quoted owners. The ordinary purge uses the lifecycle event and may fail or be lost. |
| **I-KEY:** temporary provider registrations for creates/rescue, driver pre-acceptance cleanup, sweep deletion | [PRV-9](../../02-provider-contract.md#create-machine): “when, and only when, its operation has settled or its record has vanished, and no machine that operation produced still reads `provisioning`”; “On failure before acceptance, the driver MUST delete only a temporary key that its own operation successfully registered.” Registration ownership comes from the provider; sweep eligibility comes from store reads. | [T-KEY](#t-key), independently of image deletion, has the same unestablished COMMIT/acknowledgement premise for its conditional protection. [T-KEY-GUARDS](#t-key-guards) rejects the tempting but invalid eligibility/ownership shortcuts. |
| **I-ENROL:** admission-token response, enrolment secrets, status polling and tenancy expiry | [WIR-49](../../13-wire-contract.md#endpoints): “writes nothing”; [WIR-12](../../13-wire-contract.md#endpoints): “this is the only time either secret is ever transmitted”; [WIR-13](../../13-wire-contract.md#endpoints): “status only, no secrets ever”. [API-33](../../04-api-contract.md#enrolment) says “the server stores only their hashes”; the store write's acknowledgement is distinct from delivery of the HTTP response; expiry is a separate local write. | Initial issuance is a write path, not the read-replay shortcut of revocation. Losing its HTTP response can strand an unfunded signup; it does not prove its acknowledged store transaction absent from a compliant restart. Stateless admission pacing is not WAL history. |
| **I-REVOKE:** recovery/operator credential replacement and replay refusal | [API-56](../../04-api-contract.md#enrolment): “Revocation MUST carry an idempotency key and MUST replace the token at most once per key”; “a replay returns `409`” with “credential_already_replaced”. Token hash, generation and receipt are the write; the replay is an observation of it, with no replayable bearer secret. | [T-REVOKE](#t-revoke) checks the old token after promotion, and distinguishes a lost initial response from a seen refusal. |
| **I-DEPOSIT:** initial mint, POST replay and GET, invoice creation and address derivation | [API-45](../../04-api-contract.md#funding): “re-sending one MUST return the same deposit”; [STO-7](../../05-persistence.md#engine-choice): “Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a target sampled after that read, on the same uninterrupted PostgreSQL session.” The row/index/receipt write, external invoice and later response check are distinct. | Existing FSW-N coverage, [T-DEPOSIT](#t-deposit), including WIR-14 POST/API-45 re-send and WIR-15 GET. Do not extend the check to other responses. |
| **I-MONEY:** settlement credits, attribution/corrections, commitments, extend-runway, keep, meter, rate history and invoice/payment/void recording | [STO-30](../../05-persistence.md#payments): “credit its ledger entry and record the payment in one transaction”; [STO-31](../../05-persistence.md#payments): “MUST tolerate replay from the rail”; [WIR-24](../../13-wire-contract.md#endpoints): “the commitment change and an idempotency record (fingerprint, status, the exact response body) MUST commit in one transaction”. These are local writes with acknowledgements; provider invoice records are not payment execution. | Payment identity and the external rail can support replay; they do not reconstruct a lost runway extension. Response/history case: [T-RUNWAY](#t-runway). Provider dispatches triggered by these rows remain I-MACHINE. |
| **I-ADMIN:** suspension/resume, resolve, episode retry/keep, assignment, account status, abuse cases/statements/transmission/deadlines/restrictions and manual-release recording (API Surface/API-48, wire operator routes) | [API-48](../../04-api-contract.md#funding): “none of them is itself a provider mutation”; [API-58](../../04-api-contract.md#enrolment): “marks the tenant `suspended` in the admission transaction, before the `202` is returned”; [STO-35](../../05-persistence.md#enrolments-idempotency_records-tenant_provider_accounts): “The record MUST be written in the same transaction as the write it guards”. Local administrative facts/receipts need their own acknowledgement; suspension children and episode retries separately enter I-MACHINE. | Pure recorded-state effects are not unguarded provider dispatch. Human provider correspondence/manual cleanup is I-HUMAN. Conflict refusals and later reads can observe unacknowledged history: [T-CONFLICT](#t-conflict), [T-REVISION](#t-revision), [T-WAIT](#t-wait). |
| **I-BACKGROUND:** [OVR-17](../../00-overview.md#deployment-assumptions)'s named periodic/startup/worker components, explicitly including “The exhaustion sweep (`LDG-13`, `LDG-14`)” and “`LDG-64`'s outage-bound canceller” | [OPS-50](../../03-operation-lifecycle.md#worker-algorithm): “MUST read `STO-59`'s row `FOR SHARE` as its first statement” and “A component that acts on the provider from reads” checks “in the read transaction that licenses the dispatch.” Account/resolution/offer reads have provider evidence; local meter/rate/tenancy/retention writes have WAL; rail watching has rail evidence. [OPS-28](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “Automatic resolution MUST be restricted to searching and MUST NOT mutate.” For the exhaustion sweep, [OVR-17](../../00-overview.md#deployment-assumptions) says “then **enqueues** a cancellation”; for the outage-bound canceller it says “an enqueued provider mutation with `system_reason: rate_outage_bound`”. | Those cancellation triggers map to I-MACHINE/[T-MUTATE](#t-mutate); the disputed funding case is [T-RUNWAY](#t-runway). Component placement alone supplies no post-read flush barrier; [T-CLEANUP-BARRIER](#t-cleanup-barrier) separates the generation-lock check from the additional COMMIT/acknowledgement premise. Account absence observations write local exits, not deletes of unrecorded machines. Read-licensed cleanup remains I-IMAGE/I-KEY; startup/stop evidence is not a shutdown witness: [T-WAIT](#t-wait). |
| **I-RAIL / I-AUDIT:** invoice mint/cancel, watch/subscription/lookup/balance reads, watch expiry; audit events and alarms | [SEC-48](../../07-security-requirements.md#key-custody) lists “Create an invoice”, “Cancel an unsettled invoice” and “Read the channel balance and the node's on-chain wallet balance”; [LDG-20](../../12-billing-and-ledger.md#solvency): “Cancel unsettled Lightning invoices on unexpired deposits.” [SEC-33](../../07-security-requirements.md#audit): “Audit records MUST be written to a destination separate from the operation store”. Invoice creation/cancellation is an external rail effect, while subscriptions/balances are observations; audit output has its own destination. | No general claim of a later acknowledged barrier for read-triggered invoice cancellation or audit output: an external invoice can remain cancelled if a triggering local halt is lost. This conditional read-licensed effect is [T-RAIL](#t-rail). External audit placement alone is not classification evidence: [C-WITNESS](#c-witness). |
| **I-HUMAN / exclusions:** provider correspondence, manual attachment cleanup, recovery-key removal, Lightning ceiling sweep and cold refill; withdrawn/deferred surfaces | [RSC-21](../../06-rescue-install.md#failure-handling): “removable by an operator once recovery is complete”; [SEC-49](../../07-security-requirements.md#key-custody): “The sweep is a manual operator action”; [SEC-51](../../07-security-requirements.md#key-custody): “Refilling channels from cold MUST be a manual operator action”. [WIR-10a](../../13-wire-contract.md#views): “withdrew adopt from v1”; [Completion and pacing, unnumbered preamble](../../04-api-contract.md#completion-and-pacing): “No webhook, stream, long-poll or change feed ships in v1”. | Human decisions can consume an observed response; this is an observation dependency, not an automated dispatch/barrier proof. The provider has its own truth about a manually removed attachment; its recording is I-ADMIN. No v1 adopt/requeue/feed/iPXE path is invented; use the README withdrawn index and DOM-22's capability exclusions. Outgoing rail spending is excluded by [SEC-48](../../07-security-requirements.md#key-custody): “MUST NOT be able to: pay an invoice or send a keysend”. |

## Existing coverage and non-counterexamples

<a id="t-create"></a>

### T-CREATE

Initial state: a durable admitted create/commitment and a worker holding its claim. Reads:
account status/channel closure, validation, live offers, sale and price checks. Event order:
step 8's account/correlator/about-to-order transaction, acknowledgement, then temporary-key
registration and order. Owner support is [OPS-43](../../03-operation-lifecycle.md#resolving-needs_reconciliation):
“Step 9 MUST begin only after step 8's transaction is acknowledged” and a lost acknowledgement
means “repeat the whole transaction” rather than speculative dispatch.

Deduction: if a named standby flushes that actual step-8 record on the same continuous history,
its prefix also contains the earlier store commits read before it. A compliant maximal-history
promotion retains that record and those earlier commits; the provider may separately have
accepted an order whose settlement reply is lost. With neither standby advancing, an
unacknowledged step 8 licenses no step-9 request. Thus this schedule is no counterexample about
an order dispatched solely on later-discarded pre-order history. It does not prove the
settlement survived or that every provider call is step 9.

<a id="t-mutate"></a>

### T-MUTATE

Initial state: an existing machine, a claimed operation and the relevant guard/revalidation
reads. Event order: the phase's marker write is acknowledged on history H, then the phase runs.
For rescue entry use its pre-entry false marker; for a disk write or provider mutation use the
separate write-started marker. Owner support is [OPS-45](../../03-operation-lifecycle.md#resolving-needs_reconciliation):
“before that phase runs” and “each acknowledged by the store before the provider call it precedes
is made.” For an exposure-reducing cancellation add [OPS-41](../../03-operation-lifecycle.md#resolving-needs_reconciliation):
“in the same serialized transaction that writes `OPS-42`'s fence”; [OPS-42](../../03-operation-lifecycle.md#resolving-needs_reconciliation):
“Before any provider mutation” and “the store totally orders them.”

Deduction: a later actual acknowledged WAL record on H protects an earlier observed commit on H;
`Provisiond.WalHistory.barrier_same_history_replicated` states this with `ReadObserved`,
`ReadBeforeTarget`, `BarrierAck`, `SameHistory` and `DurablePrefix`. A phase whose marker cannot
be acknowledged during a freeze cannot start speculatively. If its marker preceded the newly
observed state, this deduction does not cover that state. A marker is not evidence that the
provider or disk actually changed. Cleanup, import, rescue exit and phases without a later
marker must be inspected separately; I-IMAGE, I-KEY and I-RESCUE do so.

Actual common history is a necessary hypothesis of this deduction; the excluded deployment case
and the formal witness's limits are recorded in [T-CHANGED-HISTORY](#t-changed-history).

<a id="t-cleanup-barrier"></a>

### T-CLEANUP-BARRIER

This is a conditional source-based non-counterexample: the licensing transaction takes the
generation-row lock on an ordinary WAL-logged PostgreSQL table, ends in a WAL-writing **COMMIT**,
and receives its successful synchronous acknowledgement **before dispatch**, on the same history
as the eligibility read. COMMIT, receipt of its acknowledgement and their order are additional
premises of this deduction, not a new cleanup policy or an implementation measurement.

**Quoted duties versus the additional premise.** Current
[OPS-50](../../03-operation-lifecycle.md#worker-algorithm) places “hold that lock until it commits”
in the sentence about “every write transaction made in the engine process”. Its separate
read-side sentence is: “A component that acts on the provider from reads (the key deletion
`PRV-9` gives `OPS-32`'s sweep) MUST make the check in the read transaction that licenses the
dispatch.” This general read-licensed-provider sentence is the basis used here for applying
the check to image deletion too; it does not name image deletion separately.
[STO-55](../../05-persistence.md#engine-choice) says “MUST NOT hold a transaction open across a
provider, rail or rescue-host call” and gives the batching sequence “a sweep selects a bounded
batch by key, commits, and writes per row in its own transaction”. That names a batch commit;
this audit has not established that the licensing read below is that transaction or that a
successful COMMIT acknowledgement must be received before its dispatch. Ending a transaction
before a call does not, by itself, select COMMIT over ROLLBACK. The quoted owners have not
established the read-side COMMIT/acknowledgement premise for this audit; no normative reading
of the permissible termination path is selected here.

The pinned `heapam.c` row-lock path (`heap_lock_tuple`, approximately lines 5377–5461) obtains
`GetCurrentTransactionId()` and emits `XLOG_HEAP_LOCK` for a WAL-logged relation. In `xact.c`,
`RecordTransactionCommit` tests the assigned transaction id and `XactLastRecEnd`, writes the
commit record, flushes locally and reaches `SyncRepWaitForLSN` when the transaction assigned an
id and wrote WAL (approximately lines 1323–1567). Thus, **if that transaction ends in COMMIT**,
this SQL path reaches a real later synchronous-commit wait, even though its business purpose
was a read. Receipt of its successful acknowledgement is a further event. If the row lock was
already held within the same transaction, that fact does not make the whole transaction WAL-free.
This source argument is about ordinary logged
PostgreSQL row locking; a plain snapshot read or advisory lock alone is a different operation.

Initial state: X's newly visible eligibility fact is absent from both standbys. Order: check
and lock generation g, read X, commit licensing transaction Y, receive its successful
acknowledgement, dispatch. Y's commit record follows the read and X on the same history. A
standby durable through Y also contains X; if both standbys remain frozen, Y cannot receive
that successful COMMIT acknowledgement. A shutdown-released COMMIT produces a warning/transport
failure rather than a safe dispatch acknowledgement: [STO-7](../../05-persistence.md#engine-choice) says it “is not
acknowledged” and [OPS-49](../../03-operation-lifecycle.md#worker-algorithm) requires “repeat the
whole transaction” after a store error, “never the provider call”. A lost reply is not permission
to dispatch on that failed COMMIT path.

**Limiting branch: normal ROLLBACK after reading.** Suppose Y takes the row lock, reads X, then
deliberately ends with ROLLBACK and receives that command's normal completion before the proposed
dispatch. In the pinned [xact.c abort path](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1764),
`UserAbortTransactionBlock` selects abort processing; `AbortTransaction` uses
`RecordTransactionAbort`, not `RecordTransactionCommit`, and releases the locks. An abort record
is not a COMMIT record, and this path supplies no `SyncRepWaitForLSN` commit wait. The row-lock
WAL ingredient alone therefore does not establish the barrier above. This is a transaction that
has ended normally by deliberate ROLLBACK, distinct from a still-open transaction, a store error
or a COMMIT returned with a replication warning. No compliance of dispatch after that ROLLBACK
is established here, and no such path is adopted.

The protected COMMIT/acknowledgement order defeats the simple lost-license schedule only under
its stated SQL, termination, receipt, read-before-commit and common-history premises. It does
not universally exclude a read-licensed loss trace. No new database experiment established
the exact SQL or termination choice of a provisiond store adapter; none exists here. Nothing
here turns the generation *value* alone into a replication witness or reopens its adopted fence.

<a id="t-key-guards"></a>

### T-KEY-GUARDS

Initial state and negative controls, independently of any history loss:

- The operation is accepted and still `needs_reconciliation`, the key is tagged and registered,
  and its produced machine is no longer provisioning. No deletion is eligible:
  [PRV-9](../../02-provider-contract.md#create-machine) says “A post-acceptance `needs_reconciliation`
  operation retains its key until resolution settles it.” Unresolved is not settled.
- A settled operation has aged out, but its produced machine is retained and still reads
  provisioning. A tag lookup alone is insufficient: [PRV-9](../../02-provider-contract.md#create-machine)
  says “A vanished operation record satisfies only the settlement condition; the sweep MUST still
  check the provisioning condition against retained `machines` rows.” [STO-14](../../05-persistence.md#retention-and-encryption)
  reaches “settled operations and nothing else”. The lookup has the machine's correlator value:
  [PRV-9](../../02-provider-contract.md#create-machine) specifies “the operation UUID on Hetzner Cloud
  and DigitalOcean, or its per-order correlator-key fingerprint on Robot”; caller keys tagged with
  that operation need the same produced-machine check as the Robot correlator key.
- Pre-acceptance registration succeeded for this operation, then its mutation failed before
  acceptance. The driver has independent ownership evidence and cleans up its own key:
  [PRV-9](../../02-provider-contract.md#create-machine) says “its own operation successfully registered”.
  With duplicate-fingerprint refusal or an indeterminate upload reply it has no such license:
  the same owner says “MUST NOT trigger deletion by fingerprint” and “The refusal precedes acceptance
  and sends no order”. This is not evidence that the old registration belongs to the new operation.
- Post-acceptance end-rescue is not a second deleter: [PRV-21](../../02-provider-contract.md#end-rescue)
  says “leave any temporary credential it registered for `OPS-32`'s sweep to remove when `PRV-9`
  permits deletion”. [PRV-18](../../02-provider-contract.md#begin-rescue) separately requires an attempt
  “to deactivate rescue” on partial failure; deactivation is not deletion of a provider key.

These schedules establish no lost-history counterexample. Neither a tagged public registration
nor its deletion is a persisted recovery private key: [PRV-9](../../02-provider-contract.md#create-machine)
says it “is distinct from the persisted recovery private key”; [RSC-19](../../06-rescue-install.md#failure-handling)
says “The key is the only part of the session that may be written”. Recovery-directory handling
is a separate external filesystem/human path, not an eligibility shortcut.

<a id="t-deposit"></a>

### T-DEPOSIT

Initial state: a deposit row locally visible but not yet present on either standby, and an
already checked reader. Event order: a POST re-send or GET reads the destination, then samples
its flush target on that same uninterrupted PostgreSQL session, then checks the named standby's
flush. The current [STO-7](../../05-persistence.md#engine-choice) wording is:

> Before exposing a deposit destination read from the store, repeat the read-only flush-position
> check with a target sampled after that read, on the same uninterrupted PostgreSQL session.
> On session failure discard the result and repeat the whole read.

During a complete standby freeze this check cannot certify the just-read deposit. If the session
dies the cached result is discarded; a replacement reader cannot use an earlier successful
check as its post-read check. Once a correct same-history check succeeds, the model's
`Provisiond.WalHistory.barrier_same_history_replicated` derives membership under its independent
visibility, target-order and durable-prefix premises. `Provisiond.WalHistory.stale_target_admitted`
shows why the earlier connection check alone is insufficient.

This is existing FSW-N coverage. Exact response homes are [WIR-14](../../13-wire-contract.md#endpoints):
“`POST /v1/deposits`”, [API-45](../../04-api-contract.md#funding): “the same invoice and the same
address”, and [WIR-15](../../13-wire-contract.md#endpoints): “`GET /v1/deposits/{id}`”.
An initial acknowledged mint is already a synchronous write; a lost mint response does not
weaken the subsequent destination-read check. The protection is not transferred to a balance,
operation, revocation or conflict response by analogy.

<a id="t-equal"></a>
<a id="t-restore"></a>

### T-EQUAL and T-RESTORE

Initial state for T-EQUAL: old components stopped, both named standbys truthfully reporting
maximal ends on the actual old-primary history, all other restart conditions satisfied, and no
open restore incident. Either equal maximal prefix retains every acknowledged commit under
`Provisiond.WalHistory.maximal_preserves_acknowledged` and
`Provisiond.WalHistory.equal_reports_allow_either`. This is a non-counterexample, not a demand
for new evidence machinery.

Current [CNF-365](../../10-conformance-checklist.md#key-custody) explicitly exercises
“no open restore record and every other restart-promotion condition satisfied” and, on another
timeline, “automatic failover promotes neither standby at all, including as a restore, before an
operator decides, regardless of whether the numerical reports are equal”. Its known-violation
arm includes “after a waiting backend was cancelled or terminated, each made known to the
deployment's procedure”. There is no missing other-timeline automatic-promotion rule to rediscover.

T-RESTORE starts instead with an operator-authorized promotion of a lagging standby, or an
already open incident. The evidence and path differ: [STO-54](../../05-persistence.md#backup-and-restore)
says “Only an operator starts a promotion that is a restore” and “a process that starts while a
restore record is open is continuing that incident, not restarting”. The current reporting owner
also says “If either endpoint cannot be certified, persist null for it” and “Missing reporting
evidence does not hold incident creation”. An unknown possible-loss endpoint on this already
authorized restore is distinct from unknown eligibility to call a future promotion a restart.
[STO-56](../../05-persistence.md#restore_incidents) says “The initial establishment or its matching
no-op repeat MUST be acknowledged before either component starts.” These are existing paths;
no extra hold is inferred from this audit.

## Landed work reconciled at the baseline

| Landed work | Current owning words and audit consequence |
|---|---|
| PR #29–#30 | Current [OPS-43](../../03-operation-lifecycle.md#resolving-needs_reconciliation): “The worker MUST order the following steps as listed”; current [API-7](../../04-api-contract.md#authentication-and-tenancy) orders “compute the request fingerprint and check it”. The inventory uses the current step-8/step-9 and wire surfaces, not archived line positions or older fixtures. |
| PR #31 / pv-c7vg | [STO-7](../../05-persistence.md#engine-choice): “The operator MUST keep this synchronous replication configuration in force while the primary serves component work” and “no additional runtime replication-configuration drift check is required”; [STO-55](../../05-persistence.md#engine-choice): “The operator MUST maintain this exclusion” of transaction-mode pooling. The accepted trust/misconfiguration boundary remains; see T-DRIFT. |
| PR #32 / pv-oehp | [STO-55](../../05-persistence.md#engine-choice): “Every physical connection attempt” needs a “distinct durable reservation before dialing”; release needs “fresh privileged direct-primary evidence” that “the bound backend ended”. This accounts for capacity and delayed arrivals, not the historical fact of how a SyncRep wait ended. |
| PR #33 / pv-3jw6 | [STO-54](../../05-persistence.md#backup-and-restore): “A bound without valid evidence is unknown, not an invented recovery time” and “Continuations reuse the persisted endpoints and evidence unchanged.” A reporting certificate is not automatically a shutdown-history witness; C-WITNESS distinguishes the facts. |
| PR #34 / pv-1i3n | [STO-54](../../05-persistence.md#backup-and-restore): “either may be chosen when they are equal”; [CNF-365](../../10-conformance-checklist.md#key-custody): “equality permits neither promotion as a restart” for known violations and “Equality neither closes the record nor waives any outstanding incident obligation.” T-EQUAL/T-RESTORE retain each branch. |
| PR #35–#38 | [OPS-15](../../03-operation-lifecycle.md#interrupted-workers): “The pass over `running` rows runs at every startup, the record open or not”; [STO-54](../../05-persistence.md#backup-and-restore): “A successor continuing an existing incident after a process crash MUST NOT repeat this initialization”; [STO-56](../../05-persistence.md#restore_incidents): “reuse that id on a lost-reply retry”; [OPS-15](../../03-operation-lifecycle.md#interrupted-workers): “statement_timeout and lock_timeout both set to `OVR-19`'s Startup-lock wait bound”; [OPS-21](../../03-operation-lifecycle.md#worker-algorithm): “The Stop-record bound is measured from the stop” and “never resets.” These cover successor passes, marker provenance, retry event time, the startup statement and stopped execution, not the new inventory's shutdown-history question. |
| PR #39 / pv-5lip | [CNF-365](../../10-conformance-checklist.md#key-custody): “before an operator decides, regardless of whether the numerical reports are equal”. This is existing coverage in T-EQUAL, not a candidate amendment. |
| PR #40 / pv-26ju | [STO-7](../../05-persistence.md#engine-choice): “None of these premises is established about a deployment by the proof”; [STO-54](../../05-persistence.md#backup-and-restore): “The hypothesis is actual common history, not equality of labels or positions.” WAL membership proofs support the stated deductions; they do not supply actual shutdown, routing or action safety evidence. |

## Candidate follow-ups

This section is the sole home in this record for deployment-misconfiguration traces, conditional
loss findings and proposed rules. None is adopted. A finding may remain unresolved here without
creating a bead. “Loss” distinguishes lost observed history, an irreversible external consequence
and loss of an acknowledged commit; these are not interchangeable.

<a id="t-wait"></a>

### T-WAIT — wait termination, historical classification and knowability

**Disposition:** source-supported ingredient and a deployment-misconfiguration trace; the full
fast-shutdown reader schedule remains an unmeasured hypothesis. No compliant restart loss of an
acknowledged commit is established.

**Initial state:** primary P and named standbys S1/S2 share durable prefix H. Existing component
sessions passed their connection checks; the engine's startup generation is g. Both standbys
then disconnect. P locally flushes new commit X and waits in SyncRep; neither standby nor the
recoverable archive has X. No successful synchronous acknowledgement of X exists.

**Minimal ingredient order:** terminate the waiting backend individually, let its commit cleanup
complete, then use a different previously checked session to read X. The archived H-b measurement
supports this visibility ingredient; pinned `syncrep.c`'s pending-termination branch and `xact.c`'s
post-wait `ProcArrayEndTransaction`/lock release explain it. An individual termination is a
violation of [STO-7](../../05-persistence.md#engine-choice): “The deployment MUST NOT cancel or
terminate a primary backend while it waits for a standby” except “by shutting the primary down”.
A component-issued cancel also violates its “No component sends PostgreSQL a cancel request”.
A replication warning is not a successful acknowledgement: the same owner says “is not
acknowledged”. Application-request cancellation alone is not this database event.

**Hypothetical fast-shutdown variant:** instead of the forbidden individual termination, P starts
fast shutdown. A waiting writer handles its termination and finishes commit cleanup; another
already checked backend takes a fresh snapshot, reads X and completes its response before acting
on its own termination. The pinned sources show sequential child signalling, pending signals
and cleanup ordering, but do not guarantee this reader schedule. PostgreSQL's
[synchronous-replication documentation](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION)
says “Users will stop waiting if a fast shutdown is requested.” Connected standbys and available
archived WAL can defeat the loss premise; the trace needs neither to recover X before promotion.
An immediate shutdown is not this wait-release/reader schedule. There is no measured duration,
probability or complete reproduction here.

**Promotion order and survivors:** after the response or read-licensed external action, all old
component processes stop, P never serves component work again, and S1/S2 report H on the old
history. Either can be maximal and equal while lacking unacknowledged X. If a promoter calls this
a restart, X disappears and no restore procedure runs. This violates the historical arm of
[STO-54](../../05-persistence.md#backup-and-restore): “or had a waiting backend cancelled or
terminated” “is a restore”. The shutdown exception to STO-7's prohibition is not an exception
written into this classification arm. Proper classification is already a restore, with the
existing operator decision and procedure, not a new rule proposed here.

**Historical scope:** those current words have no stated expiry or catch-up reset. A prior
terminated waiter does not become an eligible restart merely because the current reports tie,
or even because a later standby obtained the record. The archive raised this breadth; this
audit does not narrow it. The clean-H execution with no such termination and the execution above
can present the same surviving standby reports. Equal reports do not reveal which occurred.
The warning and primary log might be gone; an alarm says a standby was unavailable, not which
backend was waiting at shutdown. The fixture's [CNF-365](../../10-conformance-checklist.md#key-custody)
qualification “each made known to the deployment's procedure” does not establish how that
knowledge survives P's loss. C-WITNESS and C-UNKNOWN evaluate that missing evidence without
changing policy.

<a id="t-changed-history"></a>

### T-CHANGED-HISTORY — retained read and barrier on another history

**Disposition:** deployment misconfiguration; not a compliant deployment or a new missing rule.
This is the excluded history case for [T-MUTATE](#t-mutate), also relevant to T-IMAGE/T-KEY.

**Initial state/order:** a process reads X on old history H0, retains that read across promotion
to H1 lacking X, then receives acknowledgement of a later barrier B on H1 and dispatches using
its retained X. The standby can durably hold B while lacking X; numerical ordering of the read
and barrier positions does not establish actual common history. The external action is
conditional on that dispatch; an acknowledged barrier alone proves no provider effect.

**Survivors/evidence and violated duty:** H1 retains B, not X. Retaining that process across the
promotion violates [STO-54](../../05-persistence.md#backup-and-restore): “Before any component
connects to the promoted store, the deployment MUST stop every engine and `api` process that was
connected to the old primary” and “the old primary MUST NOT serve a component again”. The
formal witness `Provisiond.WalHistory.hd_admitted_without_history` has `ReadObserved`,
`ReadBeforeTarget`, `BarrierAck` and `DurablePrefix`, and the barrier write is replicated;
`SameHistory` and replication of the earlier read commit fail. Its companion
`Provisiond.WalHistory.hd_refused_with_history` refutes that trace with `SameHistory` restored.
These are abstract WAL-membership witnesses, with a deposit-named read, not a machine-dispatch
model or proof of PostgreSQL behavior, process stopping, actual routing or an external action.

[OPS-50](../../03-operation-lifecycle.md#worker-algorithm) excludes “a provider call licensed by
a check that committed before `OPS-15`'s advance” and states “its guarantee covers one writable
database history”. A fresh startup generation is therefore not an acknowledgement barrier for
a retained, already licensed call. This trace does not reopen the adopted generation fence.

<a id="t-image"></a>

### T-IMAGE — imported-image deletion through OPS-32

**Disposition:** conditional non-counterexample under T-CLEANUP-BARRIER's logged-row path and
WAL-writing COMMIT with successful acknowledgement before dispatch. The quoted owners
have not established that termination/acknowledgement premise here, so this is no universal
exclusion of read-licensed loss. No proved irreversible loss on a compliant restart is claimed.

**Initial state:** H contains catalogue-install O running, tagged imported image I at the
provider, its admission/claim/dispatch history and generation g. The provider build completed,
but image cleanup has not. X locally settles O, waits without acknowledgement, and becomes
readable through T-WAIT. [OPS-32](../../03-operation-lifecycle.md#resolving-needs_reconciliation)
licenses “an image tagged with an operation's correlator whose operation has settled or vanished”
to be “deleted rather than reported”. This is different from deletion of an unrecorded machine.

**Conditional protected order/evidence:** the sweep checks g, reads X's settled O and matches
I's exact tag. Apply [OPS-50](../../03-operation-lifecycle.md#worker-algorithm)'s general
“A component that acts on the provider from reads” sentence as discussed in T-CLEANUP-BARRIER.
Add the premise that its logged `FOR SHARE` licensing transaction Y ends in COMMIT and receives
a successful synchronous acknowledgement before deletion dispatch. Under that premise, a
frozen-standby wait or failed COMMIT supplies no dispatch acknowledgement; if the acknowledgement
arrives, its actual durable prefix contains X. If the provider is then told to delete I and
succeeds, a maximal same-history promotion also retains X. Normal ROLLBACK after the read is
T-CLEANUP-BARRIER's limiting branch, not a failed COMMIT and not evidence of that protection.

**Survivors/result and limits:** an irreversible provider deletion can certainly occur, but no
loss of its licensing X follows in that protected order. Outside it, the quoted rules have not
established the COMMIT/acknowledgement premise for this audit; a loss trace is neither excluded
by the row-lock argument alone nor demonstrated compliant here. The changed-history posture
violation has its own entry in [T-CHANGED-HISTORY](#t-changed-history). If T-WAIT happened, calling
the promotion a restart would additionally violate its quoted historical classification arm.
A correctly authorized restore can lose X and cannot recreate I, but that is a different
classification and no guaranteed recovery copy: [RSC-42](../../06-rescue-install.md#catalogue-installation)
already includes purge “on entry to `needs_reconciliation`”. No evidence here establishes
customer disk loss or deletion of the wrong image. The archived generic image counterexample
must therefore remain qualified by this landed guard and the evidence limits.

<a id="t-key"></a>

### T-KEY — temporary provider-key deletion independently of images

**Disposition:** independently checked eligibility and conditional protection under
T-CLEANUP-BARRIER's logged-row path and WAL-writing COMMIT with successful acknowledgement before
dispatch. Those termination/acknowledgement premises are not established by the quoted owners
here; no universal exclusion of read-licensed loss follows. No lost recovery private key or
customer disk loss is established.

**Initial state:** H has accepted O in `needs_reconciliation`, retained produced-machine row M
already non-provisioning, and public-key registration K tagged with O's id. M retains the
correct production correlator (operation UUID or Robot per-order fingerprint). A caller key
distinct from Robot's correlator fingerprint still has O's tag. No image is involved. X resolves
O to settled but waits without acknowledgement. [PRV-9](../../02-provider-contract.md#create-machine)
supplies the guards: “its operation has settled or its record has vanished, and no machine that
operation produced still reads `provisioning`, whether or not an order was accepted”.

**Attempted order/evidence:** release X as in T-WAIT; the sweep checks g and reads settled O and
all relevant retained M rows. Read-time eligibility holds, unlike the invalid shortcuts in
T-KEY-GUARDS. For the protected order, add Y's WAL-writing COMMIT and receipt of its successful
acknowledgement before external dispatch. Because this is
specifically the read-licensed key deletion named by [OPS-50](../../03-operation-lifecycle.md#worker-algorithm)
(“the key deletion `PRV-9` gives `OPS-32`'s sweep”), its `FOR SHARE` transaction must be included
in the analysis. Under the added COMMIT/acknowledgement premise, Y protects earlier X;
with both standbys still frozen that acknowledgement cannot arrive. A warning/error takes the
transaction-retry path. This says nothing about normal ROLLBACK after reading: that limiting
branch and its unestablished dispatch compliance are distinguished in T-CLEANUP-BARRIER.

**Survivors/result and limits:** if K is deleted after Y's successful COMMIT acknowledgement,
X survives a maximal same-history promotion. Without that termination/acknowledgement premise,
the row-lock deduction alone does not exclude a trace with unresolved O after promotion and K
gone; no compliant dispatch on that branch is established here. The different-history case is
[T-CHANGED-HISTORY](#t-changed-history); an operator-authorized restore is a separate branch.
T-WAIT's restart misclassification is still a violation if that event occurred, not
proof that the cleanup transaction lacks WAL. The provider is independent evidence of successful
registration/deletion, not of O's store settlement. [PRV-9](../../02-provider-contract.md#create-machine)
says after acceptance “the sweep is its only deleter”; the separate pre-acceptance driver
ownership path is T-KEY-GUARDS. No evidence here implies that removing a public registration
removes an already injected authorized key, destroys a recovery private key, or prevents all
future rescue login.

<a id="t-revoke"></a>

### T-REVOKE — observed replay refusal and the old token after promotion

**Disposition:** conditional security-state reversal after misclassification, not an
acknowledged revocation lost on a compliant restart.

**Initial state:** H has live spending token T0's hash, recovery-credential hash and generation g0;
no receipt for recovery request key k. X replaces the token hash, increments generation and
writes k's receipt atomically but waits for a standby. The initial success body is not received.
[API-56](../../04-api-contract.md#enrolment) says “A revocation invalidates the current token
immediately”; its replay rule is “a replay returns `409`” with “credential_already_replaced”.
[STO-35](../../05-persistence.md#enrolments-idempotency_records-tenant_provider_accounts) says
“response_body MUST NOT contain a bearer secret”.

**Order/evidence:** release X via T-WAIT, then an already checked API session processes the
recovery-credential re-send with k and observes the receipt. The caller receives the specified
409 refusal; no stored token body is returned. T0 is dead on P at this point. The replay response
is an observation, not acknowledgement of X. This case concerns API-56, not ordinary spending-token
rotation or enrolment credential delivery.

**Survivors/result:** stop old components and promote H. If wrongly called a restart, the receipt,
replacement hash and generation bump are absent; T0 is live again. The observed refusal survives
only in the caller's history. Correct restore handling is different: [STO-54](../../05-persistence.md#backup-and-restore)
step (3) requires “every tenant's credential generation is bumped” before the first API request,
so “every spending token dies” and the customer re-issues using the recovery credential. A marked
continuation does not repeat that bump. No irreversible provider action is proved here; use of
T0 to mutate a machine would be a later, separately guarded operation on the misclassified store.

<a id="t-conflict"></a>

### T-CONFLICT — API-11's 409 and fingerprint/receipt history

**Disposition:** conditional externally observed conflict followed by loss of its basis;
not a demonstrated duplicate provider order.

**Initial state:** H has no receipt for principal/key (p,k). X atomically inserts an admitted
operation O and the receipt with canonical fingerprint A, then waits without acknowledgement.
[STO-35](../../05-persistence.md#enrolments-idempotency_records-tenant_provider_accounts) says
“The record MUST be written in the same transaction as the write it guards”; [API-12](../../04-api-contract.md#idempotency)
uses “a canonical serialization” rather than raw bytes; [API-38](../../04-api-contract.md#idempotency)
retains a “canonical digest of the request” after payload purge.

**Order/evidence:** X becomes visible through T-WAIT. An already checked session receives a
different request B under (p,k), compares its fingerprint with A and returns 409 without
creating another operation. [API-11](../../04-api-contract.md#idempotency) says “Re-sending it with
a different request MUST fail `409 Conflict` and MUST NOT create a second operation.” Choose
this refusal branch, not a new write that would itself wait for synchronous acknowledgement.

**Survivors/result:** promote H after old processes stop; calling it a restart violates T-WAIT.
Both O and its receipt A are absent. The same B can now be admitted as a first request under k,
with a new acknowledged receipt once replication works. The caller's earlier 409 no longer has
its fingerprint history. This is neither ordinary key expiry nor the receipt-retention policy:
[STO-25](../../05-persistence.md#retention-and-encryption) says “Idempotency records MUST outlive the operations
they guard”. This example supplies no initial acknowledged 202 and no dispatched order for O;
it therefore proves neither duplicate purchase nor provider irreversibility. An original
acknowledged receipt on a correctly selected same-history prefix would survive instead.

<a id="t-revision"></a>

### T-REVISION — exposed API-53 value and subsequent history

**Disposition:** conditional observed-history/revision reversal, separately from irreversible
provider effects.

**Initial state:** H has O running at revision n, with prior dispatch evidence as appropriate.
X is its client-visible settlement at n+1, locally waiting without acknowledgement.
[API-53](../../04-api-contract.md#completion-and-pacing) defines “a per-operation counter that
strictly increases on each client-visible modification”; [STO-33](../../05-persistence.md#enrolments-idempotency_records-tenant_provider_accounts)
says revision is “incremented in the same statement as any client-visible change”.

**Order/evidence:** T-WAIT makes X visible; a GET on an existing checked session returns n+1 and
its settled payload. A response lost before the caller sees it is not enough for this trace:
the caller actually observes n+1. [API-53](../../04-api-contract.md#completion-and-pacing) says a
lower revision “is stale and MUST be discarded by the caller”. The GET is no post-read barrier.

**Survivors/result:** misclassified promotion restores H's running O at n. The caller may next
see n and discard it; the startup settlement to unresolved can increment the retained n to n+1
again with a different payload. An equal number does not distinguish that new payload from the
formerly exposed settlement. This is a possible revision reuse/contract-observation problem;
it is not evidence that an irreversible provider action was replayed. A provider result can
outlive its local settlement, and ordinary reconciliation is still a separate path. The
misclassification violates T-WAIT; a correct operator restore explicitly accepts history loss,
and this audit adopts no new revision allocator or cross-restore promise.

<a id="t-runway"></a>

### T-RUNWAY — LDG-14, disputed

**Disposition: disputed.** The original disagreement in r63h's tally contrasts a later
acknowledged marker with an earlier shown extension. Neither assertion alone settles the event
order. No complete fast-shutdown schedule or compliant-restart paid-machine deletion is proved.

**Initial state:** active tenant, machine with no cancellation fence, old stored runway U0 past,
a queued exhaustion episode, a current rate and sufficient available balance. X admits an
extension, increases the commitment and writes future U1 plus its receipt, but is still waiting
for a standby. [LDG-62](../../12-billing-and-ledger.md#exhaustion) requires “conditional-write the
machine row guarded on `machines.destroy_committed IS NULL`” and “write the re-derived
`runway_until`”; [WIR-24](../../13-wire-contract.md#endpoints) puts the exact response/receipt in
that transaction. No successful extension 200 is assumed. The proposed observation is a later
ordinary machine GET of U1 after wait release: [LDG-15](../../12-billing-and-ledger.md#exhaustion)
says “Remaining runway MUST be readable from the machine view”.

**Order A, same old history:** after observing X, a cancellation worker re-checks the commitment
under the fence transaction, before dispatch, and then reaches the write-started marker. The
current [OPS-41](../../03-operation-lifecycle.md#resolving-needs_reconciliation) words are “never
on its claim snapshot” and, if future-funded, “MUST make no provider call”. [OPS-42](../../03-operation-lifecycle.md#resolving-needs_reconciliation)
orders fence and extension “so that one of them provably loses”. If a later marker/barrier is
acknowledged on that same history, X is in the flushed prefix; if neither standby progresses,
that acknowledgement cannot arrive. If a fence already won, the assumed admitting extension
is refused instead. This is the marker argument's valid scope, and defeats an immediate
same-history destroy justified only by an old claim snapshot.

**Order B, lost observation first:** hypothesize T-WAIT's complete read-response schedule exposes
U1, then stop the components, lose X and falsely classify H's promotion as a restart. On the new
history the worker can later re-check U0 and its smaller commitment, write/acknowledge its fence
and marker, and cancel. Its marker now follows loss, not X on the same history. The old-history
marker argument does not protect X across that change. Conversely, this premise is forbidden
restart classification, so the schedule is a deployment-misconfiguration consequence, not a
compliant restart counterexample. It does not establish a successful acknowledged extension.

**Proper restore branch and limits:** [STO-54](../../05-persistence.md#backup-and-restore) explicitly
says “an extension lost in Δ is not rebuilt”; [OPS-41](../../03-operation-lifecycle.md#resolving-needs_reconciliation)
says a claim during the open grace “defers, and writes no fence”. After the applicable grace
and re-check, failure to re-extend can still lead to cancellation; [LDG-14](../../12-billing-and-ledger.md#exhaustion)
says “At end of runway the machine MUST be cancelled and its disk destroyed with it”, with its
scheduled-cancellation and outage qualifications. That permitted restore residual is not proof
of the original disputed restart claim. Rate changes also move runway, so U1 becoming U0 alone
cannot diagnose loss. Missing evidence remains the full reader schedule, relevant fence/marker
positions and acknowledgements, and actual common-history/promotion eligibility. No majority or
preference resolves those premises here.

<a id="t-rail"></a>

### T-RAIL — read-triggered external invoice cancellation

**Disposition:** conditional external rail effect whose triggering observation can be lost;
not a measured money loss or a new cancellation policy.

**Initial state:** H has an unexpired deposit with an unsettled invoice and covered solvency;
X is a new stored halt/solvency verdict, locally waiting without acknowledgement. Existing
funding-side sessions can observe X after T-WAIT. [LDG-20](../../12-billing-and-ledger.md#solvency)
says “Cancel unsettled Lightning invoices on unexpired deposits”; [STO-55](../../05-persistence.md#engine-choice)
forbids holding the transaction “across a provider, rail or rescue-host call”. No current text
quoted here supplies a post-verdict WAL barrier for this particular cancellation dispatch.

**Order/evidence/survivors:** conditionally let a funding component read the halt, release its
read transaction and successfully cancel that invoice at the rail before stopping. After H's
promotion the triggering stored verdict is absent; the external invoice remains cancelled.
If the halt was only computed in memory, this particular lost-store-commit premise does not
apply; an implementation's actual halt representation and ordering have not been measured.
A claimed restart following T-WAIT would still be misconfiguration. This does not undo a settled
payment or demonstrate a spend: [SEC-48](../../07-security-requirements.md#key-custody) says
“Cancelling an unsettled invoice moves nothing”; [LDG-20](../../12-billing-and-ledger.md#solvency)
says a concurrently settled HTLC “was received and MUST be credited”. Destination-exposure
coverage T-DEPOSIT does not certify the stored history of this separate rail action.

<a id="t-drift"></a>

### T-DRIFT — trusted replication/routing posture, already disclosed

**Disposition:** deployment misconfiguration, already covered; no runtime controller proposed.

**Initial state/order:** a checked connection on P, correct synchronous configuration and prefix
H; later the deployment empties `synchronous_standby_names` and reloads while component work
continues. It can acknowledge X locally without either standby having X. Stop old components
and promote equal H reports while incorrectly taking the restart branch. X, even though
acknowledged to the component, is missing. [STO-7](../../05-persistence.md#engine-choice) describes
this exact limit: “That is a deployment misconfiguration, and the earlier connection check does
not detect the change”; [STO-54](../../05-persistence.md#backup-and-restore) includes “after the
primary committed without one of them” among restore-class promotions. The model witness is
`Provisiond.WalHistory.local_ack_admitted_without_sync`; equal maximal reports do not restore
its absent synchronous-commit premise.

A transaction-mode pooler added after startup similarly breaks the new-connection/session
basis when the primary changes behind a component's surviving client connection.
[STO-55](../../05-persistence.md#engine-choice) says “No pooler in transaction mode fronts the
pools” and “No additional runtime topology-drift check is required.” The owner selected
“Don't add the check” / “Trust the deployment to keep replication on” in the r74 decision
record. This audit retains that accepted trust boundary; a fresh check in the past is not
continuous configuration or topology evidence.

<a id="c-witness"></a>

### C-WITNESS — candidate durable off-primary shutdown/cancellation evidence

**Candidate only; not adopted.** Stable motivating traces: T-WAIT, T-REVOKE, T-CONFLICT and T-REVISION;
T-RUNWAY remains disputed. T-IMAGE/T-KEY retain their conditional barrier analysis; the cited
owners have not established its read-side COMMIT/acknowledgement premise here. A shutdown-history
witness would not itself establish that transaction termination and dispatch order.

The fact to establish is whether the affected source-primary incarnation/history ever had the
waiting-backend cancellation/termination condition relevant to the contemplated promotion,
including shutdown-induced termination. This is distinct from whether an observer now sees a
backend absent, a standby unavailable, equal ends, or a bounded possible-loss interval. A record
of “shutdown requested” without whether a waiter was affected is only conservative evidence;
a missing record cannot mean the condition did not occur.

A possible construction would durably record shutdown intent/possible wait termination outside
P's failure domain before signalling, bound to database identity, primary incarnation and
actual WAL ancestry; individual cancellation/termination paths and abrupt host shutdowns would
need coverage too. A later completion/catch-up observation would need trustworthy provenance and
ordering. A reported end-of-WAL would need a continuous actual-history certificate and relation
to the affected commit, rather than a larger number. Even catching up does not, by itself,
remove the current historical classification condition; allowing such an expiry would be a
separate policy decision. There is no adopted storage protocol, trusted issuer or proof that
these records cannot be lost, bypassed or forged.

The existing artifacts do not automatically fill that role:

- [SEC-32](../../07-security-requirements.md#audit) specifies request audit fields including
  “correlation id, tenant, authenticated identity” and “outcome”; [SEC-33](../../07-security-requirements.md#audit)
  says “a destination separate from the operation store”. Those words supply neither a
  before-shutdown durable write nor complete coverage of primary-incarnation backend history.
- [STO-55](../../05-persistence.md#engine-choice) requires “fresh privileged direct-primary evidence”
  for reservation release and says “Leaving `SyncRep` is insufficient”. That is evidence of
  backend ending for capacity accounting, not why its commit became visible or the full
  historical condition for promotion. A grant retained forever remains conservative capacity
  accounting; it does not automatically identify a cancelled waiter.
- [STO-54](../../05-persistence.md#backup-and-restore) certifies that “every source-history component
  commit acknowledged before b belongs to recovered committed history” for a known lower bound.
  That certificate concerns inclusion of acknowledged records, not wait-termination history.
  Unknown endpoints do not supply the missing fact either.

Costs would include an independent durable service/storage path, incarnation/ancestry binding,
coverage of crash and power-loss paths, evidence validation and indefinite ambiguity if that
path failed. Failure/bypass could silently recreate T-WAIT's indistinguishable reports; observing
absence is not a negative certificate. This candidate also cannot repair the independent
configuration/routing violations in T-DRIFT or reconstruct an already deleted provider resource.
No monitoring, storage, reporting, admission or conformance duty is added here.

<a id="c-unknown"></a>

### C-UNKNOWN — candidate conservative restore classification for unknown history

**Candidate only; not adopted.** Stable motivating trace: T-WAIT, with C-WITNESS's evidence gap.
“Unknown” here means the promoter cannot establish the relevant historical restart-eligibility
facts for the affected primary incarnation/history, particularly whether a waiting backend was
cancelled/terminated. It does not mean merely equal valid reports, and it does not mean an
unknown possible-loss endpoint after an operator already authorized a restore.

A possible policy would refuse automatic promotion when that eligibility remains unknown and
let an operator authorize a restore under the existing procedure. Costs would include longer
outages and more restore incidents, credential invalidation, quarantine, grace and operator
work even when no acknowledged history was lost. It would need a definition of trustworthy
negative evidence and how uncertainty is propagated across incarnations; treating missing logs
as clean history would defeat the candidate. Known configuration violations would still be
violations, and a dishonest/misconfigured evidence source could falsely say “known clean”.

The adopted positive case remains [STO-54](../../05-persistence.md#backup-and-restore): “either may
be chosen when they are equal”, under its other conditions; [CNF-365](../../10-conformance-checklist.md#key-custody)
adds “no open restore record and every other restart-promotion condition satisfied”. A known
violation remains its existing restore case, not this proposed uncertainty policy. The existing
operator boundary remains “Only an operator starts a promotion that is a restore” in STO-54.
For an already authorized restore, [STO-54](../../05-persistence.md#backup-and-restore) says “Missing reporting evidence
does not hold incident creation”; C-UNKNOWN does not reverse it. Neither candidate replaces the
valid-equality path or the owner's accepted replication/routing trust posture.
Neither candidate supplies T-CLEANUP-BARRIER's additional read-side COMMIT/acknowledgement premise.

## Limits and verification

This inventory is traceable to the source lists above, including administrative, background,
rail and human paths. It is not a proof about an implementation, and no exhaustive runtime
interleaving exploration was performed. No compliant restart loss of an acknowledged commit was
established. Conditional observed-history losses and external effects are located only in
Candidate follow-ups; fast-shutdown duration and full schedule are unmeasured, and T-RUNWAY
remains disputed. The cleanup non-counterexamples are conditional on the logged-row path,
WAL-writing COMMIT and receipt of its successful acknowledgement before dispatch on the same
history, as examined in T-CLEANUP-BARRIER. The quoted owners have not established the read-side
termination/acknowledgement premise here; normal ROLLBACK after reading supplies no such commit
barrier. This audit neither declares that dispatch compliant nor universally excludes a
read-licensed loss trace, and adopts no COMMIT/acknowledgement duty.

Verification uses the repository's full gate through the Run's serialized `formal-gate.sh`,
which executes `nix develop --command bash tools/check-all.sh` unpiped. The baseline invocation
exited 0. The revised committed research bytes require the same gate; its actual status and
commits are reported with the Run result rather than embedding a self-changing commit hash
here. The existing tracker closure is retained. The gate checks specification/formal
consistency, not the deployment hypotheses in these traces. The citation gate checks root
Markdown and Lean docstrings, using ADRs as sources; it does not check this research directory.
Changed quotations were manually checked
against their complete current owning blocks, along with changed links and dependent conclusions.
