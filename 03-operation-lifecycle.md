# 03 — Operation lifecycle

This is the core of the design. Everything else is plumbing around it.

## Why operations exist

A provisioning call can take minutes, can cost money, and can destroy data. The HTTP
request that triggers it can fail at any point — including *after* the provider has
already acted. A control plane that returns the provider's answer synchronously has no
way to tell "the order did not happen" from "the order happened and I lost the reply",
and a control plane that retries on failure will eventually buy two servers.

So every write becomes a durable record with an explicit settled state — plus a third state,
*I do not know*, which is resolution-pending rather than terminal (`OPS-3`): no retry and no
timer leaves it, though evidence does (`OPS-27`).

**OPS-1** Every mutating request MUST create or return a durable operation record before
any provider call is made, and MUST respond `202 Accepted` with that record.

**OPS-2** **AMENDED 2026-08-12.** An operation record MUST persist the full request payload
**while the operation is live**, so a worker can execute it after a process restart without the
original HTTP request. On entry to any settled state — **and to `needs_reconciliation`**
(`OPS-3`) — the payload is purged and replaced by a redacted summary (`ADR-0005`, `STO-9`).

The original text said "MUST persist the full request payload" without qualification, and
`ADR-0005` narrowed it in a different document without editing this sentence — leaving two
normative statements with opposite meanings. Three things depended on the unqualified version and
are corrected by `OPS-34`.

**OPS-34** **Requeue after purge.** `OPS-20` required requeue to "re-execute the original request
verbatim", and the payload is purged on entry to **either** requeue-eligible state — `failed` (terminal) and
`needs_reconciliation` (resolution-pending, `OPS-3`) — so after `ADR-0005` it is always gone and requeue as specified cannot work at all. Since
`API-19`, `OPS-31` and `DEF-17` all rest on it, the resolution is:

- **Requeue MUST carry a fresh payload supplied by the operator**, and the system MUST verify it
  is equivalent to the stored summary in every respect the summary records (kind, machine,
  provider account, target). It is no longer a replay of bytes the system holds; it is a new
  submission checked against what survived.
- Where the summary cannot establish equivalence, requeue MUST be refused and `OPS-31`'s
  resolution verbs are the only road.
- `API-11`'s idempotency comparison has the same problem and the same answer (`API-38`).

**OPS-35** The provider account MUST be resolved and written to the operation record **before**
any driver call. `05` marks it nullable, and a create whose reply is lost is precisely the case
where reconciliation must know which account to search — a search that cannot begin if the
account was only ever determined inside the call that vanished.

## States

| State | Meaning | Terminal |
|---|---|---|
| `queued` | Waiting for a worker | no |
| `running` | Claimed by a worker under a lease | no |
| `succeeded` | Completed; result recorded | yes |
| `failed` | Completed unsuccessfully; provider state is known | yes |
| `needs_reconciliation` | Outcome unknown; resolution pending (`OPS-3`) | **no** — settles to `succeeded` or `failed` |

```
                    +----------+
   enqueue -------->|  queued  |<---------------------+
                    +----+-----+                      |
                         | claim (lease)              | defer (machine locked)
                         v                            | operator requeue
                    +----------+---------------------+
                    | running  |
                    +----+-----+
                         |
        +----------------+----------------+
        |                |                |
   success           failure          ambiguity
        |                |                |
        v                v                v
  +-----------+    +----------+   +----------------------+
  | succeeded |    |  failed  |   | needs_reconciliation |
  +-----------+    +----------+   +----------+-----------+
        ^                ^                   |
        |                |                   | resolved observed -> succeeded
        +----------------+-------------------+ resolved absent/abandoned -> failed
                         |                   |
                         +--- operator requeue ---> queued
```

`needs_reconciliation` is **resolution-pending, not terminal** (`OPS-3`): it settles by evidence
(`OPS-27`) or by an operator verb (`OPS-31`), and nothing automatic or caller-driven moves it.

**OPS-3** **AMENDED — `needs_reconciliation` is *resolution-pending*, not terminal.** `succeeded`
and `failed` are the terminal states. **A transition made *by a worker* MUST be conditional on that
worker still holding the lease** (`STO-3`); a worker that has lost its lease MUST NOT overwrite the
record. **Resolution transitions out of `needs_reconciliation` are made by no worker and under no
lease** — by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb — and are guarded instead by
`STO-19`'s write-once resolution columns. Scoping the lease clause to workers is required, not
stylistic: read unscoped it forbids every transition this amendment enumerates, since an operation
in `needs_reconciliation` has no lease for anyone to hold.

*Calling it terminal contradicted every requirement that resolves it.* `OPS-27` transitions it
automatically on a correlator match, `OPS-31`/`WIR-35` transition it by operator verb, and `OPS-4`
forbade both by forbidding transitions out of terminal states. The permitted transitions are
exactly:

```
needs_reconciliation --resolved observed--> succeeded
needs_reconciliation --resolved absent|abandoned--> failed
needs_reconciliation --operator requeue--> queued
```

**What was actually load-bearing about "terminal" survives unchanged**, and it is `OVR-5`: the
system MUST NOT retry the mutation automatically, MUST NOT clear the state on its own timer, and
MUST NOT let a caller drive it. Only evidence (`OPS-27`) or an operator (`OPS-31`) moves it. The
caller-facing `terminal` flag (`WIR-10`) is `false` in this state, and `retryable` is `false`
(`API-51`) — the operation is not finished, and it is not the caller's to retry.

The payload purge (`ADR-0005`) happens **on entry** to `needs_reconciliation` rather than at a
terminal state, and that is an explicit privacy exception recorded here so a reader does not
find it contradictory.

**OPS-4** Only `failed` and `needs_reconciliation` MAY be requeued, and only by an
explicit operator action (`API-19`). There is no automatic transition out of a terminal
state.

## Claiming and leases

**OPS-5** Claiming MUST be atomic: selecting the next eligible operation and marking it
`running` with a claimant identity and a lease expiry MUST happen in one indivisible
step. Two workers MUST NOT be able to claim the same operation.

**OPS-6** The claim MUST select the oldest `queued` operation whose availability time has
passed. Attempt count MUST be incremented on claim.

**OPS-7** A worker MUST renew its lease on a heartbeat interval strictly shorter than the
lease duration (a third of it is a reasonable default, with a floor). If a heartbeat
finds the lease is no longer held, the worker MUST abandon the in-flight work
immediately and MUST NOT record a result.

## Per-machine locking

**OPS-8** An operation that names a machine MUST hold an exclusive lock on that machine
for its duration. Concurrent install, power, delete, and refresh operations on one
machine are not merely wasteful, they are dangerous.

**OPS-9** Lock acquisition MUST be atomic and MUST succeed only when the lock is free,
its lease has expired, or it is already held by the same operation. An operation that
cannot take the lock MUST be returned to `queued` with a short delay rather than failed —
the conflicting work will finish.

**OPS-10** The machine lock lease MUST be renewed by the same heartbeat that renews the
operation lease, and losing either MUST be treated as losing both.

## Classifying failures — the ambiguity rule

This is `OVR-5` made concrete.

**OPS-11** On failure, the system MUST classify the error into `failed` or
`needs_reconciliation` using the operation kind and the error kind:

| Operation | Classification rule |
|---|---|
| adopt, refresh | Always `failed`. Both are read-only; a failure changed nothing. |
| suspend_tenant | Never `needs_reconciliation`, and never `failed` as a whole. **A child that settles `needs_reconciliation` counts as complete for the parent** — it has reached a state only evidence or an operator moves, and holding the parent open on it would leave every suspended tenant's record permanently unfinished: it is a parent whose per-machine children carry their own outcomes (`WIR-39`). It settles `succeeded` once every child has settled, **including children that settled `needs_reconciliation`** — an unresolved child is a child-level fact, and blocking the parent on it would leave a suspended tenant's record permanently open. |
| preflight | Same rows as `install`. It is **not** read-only in the relevant sense: it boots the machine into rescue, so an ambiguous failure can strand it there, and `PRV-22` makes an end-rescue failure always ambiguous. Classifying it with `refresh` would mark it `failed` while the machine sits in rescue. |
| install | `needs_reconciliation` for `network`, `timeout`, `provider`, `integrity`, `internal`, and `conflict`. `failed` **only** for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` — each of which means the request was rejected before anything was written. An install that got further than that may have begun overwriting a disk. |
| create, power, reverse-DNS, delete | `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |

**The table MUST be total, and five kinds added later were missing.** `insufficient_balance`,
`not_activated`, `halted`, `gone` and `suspended` (`DOM-20`, `DOM-21`) are **admission-only**: they are decided
before any driver call, they MUST NOT be emitted by a worker or a driver, and any pre-provider
occurrence classifies deterministically as `failed` for every operation kind. Nothing was
destroyed and nothing was ordered, so ambiguity cannot arise. Every kind in `DOM-17` MUST have a
defined classification for every operation kind. There is no implicit default, because the two possible defaults are both wrong:
defaulting to `failed` invites a caller to retry a mutation that may have happened, and
defaulting to `needs_reconciliation` pages a human for a typo. `CNF-31b` tests totality.

One case needs stating because two requirements appear to disagree. `PRV-22` says end-rescue
failure is *always* ambiguous. That does not conflict with the install row: an install whose
*rescue exit* fails has already done its work and reached the provider, so it is never a
deterministic caller error, and the install row classifies it `needs_reconciliation` regardless
of which error kind the driver reports.

A failure is **ambiguous** when:

- the error kind is `network`, `timeout`, or `internal` — the request may have been
  received and acted on before the transport died; or
- the error kind is `conflict` *and* it arose from lease or lock loss rather than from a
  provider-reported state conflict — the worker was cut off mid-flight; or
- the error kind is `provider` *and* the upstream status was 5xx, or no upstream status
  was recorded at all. A 4xx means the provider rejected the request and did not act; a
  5xx means it may have acted and then failed to say so.

**OPS-12** The system MUST NOT automatically retry an operation that ended
`needs_reconciliation`, and MUST NOT automatically retry an ambiguous mutation under any
other name (no backoff loop, no "safe" re-poll that re-issues the mutation). The
`retryable` flag on an error is **normative guidance to callers** (`API-51`); what stays
prohibited is the *system* retrying on its own.

**OPS-13** When a mutation's outcome is unknown, the surviving evidence MUST be preserved
and pointed at: the error details MUST record what was attempted, any provider-side
identifiers that were created (transaction ids, key fingerprints, action ids), and the
location of any retained recovery credential (`RSC-19`).

## Interrupted workers

A worker that crashes leaves an operation `running` with a lease that will expire.

**OPS-14** A sweeper MUST periodically move `running` operations whose lease has expired
into `needs_reconciliation`, and MUST release machine locks whose lease has expired. It
MUST NOT move them back to `queued`. A crashed worker is exactly the case where the
provider may have acted and nobody recorded it.

**OPS-15** The sweeper MUST run at startup as well as periodically, and startup MUST log
the count of operations it found interrupted.

**OPS-16** The sweeper MUST NOT overwrite an error already recorded on the operation; it
fills in a marker only where none exists.

**OPS-17** The sweep interval SHOULD be tied to the lease duration (for example, a
fraction of it), not to the worker's idle poll interval. Sweeping on every idle iteration
of a fast poll loop generates continuous write transactions for no benefit. See `DEF-11`.

## Requeue

**OPS-18** Requeue MUST be an explicit operator action on a single operation, MUST be
allowed only from `failed` or `needs_reconciliation`, and MUST itself be idempotent —
repeating a requeue with the same idempotency key MUST NOT enqueue the work twice.

**OPS-19** Requeue MUST preserve an audit trail: the previous error, the stated reason,
and the requeue timestamp MUST survive on the record.

**OPS-20** **AMENDED.** Requeue executes the **fresh operator-supplied payload** `OPS-34`
requires, after verifying every comparison the retained summary supports. *It is not a byte replay
of the original request: `ADR-0005` purges that once the operation stops being live, so the withdrawn wording
("re-executes the original request verbatim") described something that no longer exists while
`API-19`, `OPS-31` and `DEF-17` all rested on it.*

For an ordering operation a requeue means **placing a second order**, so it MUST pass the same
spending gates a fresh create would (`API-7`'s create class). **Where the original operation's
commitment is still open it is reused, not duplicated** (`LDG-30`: one open commitment per
machine); only where it was closed — by `OPS-33`'s window or a terminal outcome — does the requeue
open a new one (`LDG-11`) — a requeued create that skips them buys a machine with no authorized funding, which is
the money-out `ADR-0002` exists to prevent, reached through the operator surface. The API MUST make that
explicit in its response or documentation, and MUST refuse to requeue a provider-non-idempotent
kind unless the request carries a **second, distinct acknowledgement**
(`acknowledge_duplicate_purchase`, `WIR-28`) — the fresh payload's own `acknowledge_purchase` does
not satisfy it, because that one merely says "a purchase is intended", not "a *duplicate* purchase
is intended". Requeueing a create is a purchase decision, not a retry.

## Resolving `needs_reconciliation`

Requeue is not a resolution. It replays the mutation, which is the one thing an ambiguous
outcome forbids. Until this section existed, `needs_reconciliation` was a terminal state with no
exit and `OPS-25` retained its records "until an operator resolves them" through a mechanism
that did not exist.

The cost of leaving one unresolved is no longer merely operational. A create places a commitment on
the customer's balance; while the operation sits unresolved, **those satoshis are frozen** — not
spendable, not returned. Resolution latency is money the customer cannot use.

**OPS-27** The system MUST attempt automatic resolution before asking a human. Resolution
searches the provider for the operation's correlator (`PRV-26`, `PRV-27`) and takes one of three
outcomes:

| Finding | Resolution | Effect on the commitment |
|---|---|---|
| Exactly one resource bears this operation's correlator | **Resolved-observed.** Attach it and complete the operation as though it had succeeded. | Becomes the machine's running commitment (`OPS-36` where it was already released) |
| The provider's search is authoritative and returns nothing, and the negative window has elapsed | **Resolved-absent.** The mutation did not happen. | Closed and released in full (`LDG-32`) |
| More than one resource bears the correlator | **Unresolved — duplicate.** MUST NOT auto-attach either. Surface both for operator remediation (`OPS-38`). | Released per `OPS-33`; the duplicate is operator cost |
| The search cannot be made authoritative — the provider cannot filter, the listing window has expired, or no correlator exists for this operation kind | **Unresolved.** Escalate to an operator (`OPS-31`, `WIR-35`). | Released per `OPS-33`, which applies here too |

**OPS-36** **A correlator match may arrive after `OPS-33` released the commitment and the tenant
spent the balance.** The specification previously had no branch for this and the three available
readings each broke something: attaching unfunded contradicts `ADR-0002`, re-committing
contradicts `LDG-10`, and cancelling contradicts row 1's instruction to attach.

The rule is: **attach the machine, then immediately route it through the exhaustion path**
(`LDG-13`). Attach, because the machine exists and belongs to that tenant and pretending
otherwise creates an orphan the operator pays for. Then cancel, because it has no funding and
`ADR-0002` admits no unfunded machine.

**AMENDED 2026-08-13: the system MUST NOT open a fresh commitment sized to keep the machine
running.** Funding the *cancel* is different in kind and is required — an unfunded cancel is a
machine the operator pays for indefinitely — and it is bounded by the wind-down floor, which is
the smallest amount that ends the exposure rather than any amount that continues it. The
withdrawn sentence said "if the tenant's balance can fund a fresh commitment, the machine
survives" — which is an automatic seizure of available balance the customer may have already
re-planned, sized from a `runway_seconds` the payload purge deleted, ignoring the
`max_commitment_sats` cap the original create may have set. That is precisely the surface
`ADR-0011` abolished, reappearing through reconciliation.

The machine is attached. Where available balance covers the wind-down floor, a commitment of that
size is opened; **where it does not, no commitment is opened at all** and the wind-down is carried
as an operator deficiency (`LDG-66`) — a commitment the balance cannot fund is not a commitment,
and `LDG-10` forbids pretending otherwise — the branch's own
premise is that the tenant spent the balance, so on the common input available is *below* the
floor and `LDG-10` forbids driving it negative. Naming only the commitment left a builder choosing
between two MUSTs with no rule for the remainder. The machine is then routed into exhaustion
immediately (`requested_by: system`,
`system_reason: late_attach_cleanup`). **Survival requires a caller action**: the tenant may `extend-runway` (`LDG-62`) against the attached machine. **Where the branch opened
no commitment**, `LDG-62` **creates** one at the extension's size rather than growing an absent
record — otherwise the survival path this sentence promises is unreachable for exactly the broke
tenant the branch is about. before the exhaustion sweep reaches it,
which is an explicit, capped, idempotent authorization rather than an inference about what it
would have wanted. **This is the branch that makes `OPS-33`'s early release safe**, and without it
that release was a hole rather than a decision.

**OPS-37** **The last row applies to the commitment exactly as `OPS-33` does.** An earlier version
said an unresolved outcome leaves the money "frozen" while `OPS-33` said it MUST be released —
the same trigger with opposite MUSTs, and the unresolved row is the *expected* path for any
provider that cannot filter server-side. `OPS-33` governs: the commitment is released and the
operation stays open. **Nothing about a customer's balance may depend on which provider's search
API is weaker.**

**OPS-38** Correlator matching MUST define cardinality: zero, one, or many. Many is reachable by
a documented procedure — `OPS-20` requeue re-executes an operation that already wrote its
correlator, so a late-succeeding first attempt and a successful second both bear it. A driver
MUST reject a caller-supplied label that collides with the correlator's reserved key, and
`OPS-31`'s operator verbs MUST be able to record which of several duplicates was kept.

**OPS-40** **A signed image URL is validated against the queue's latency, twice** (`F20`).
`OPS-2` persists a request so it can be executed after restarts and deferrals; `SEC-21` wants the
signed URLs inside it short-lived. The two meet as follows: at **accept**, a request carrying a
signed URL MUST be rejected unless the URL's expiry exceeds the deployment's stated worst-case
admission-to-start bound; at **claim**, a worker MUST fail the operation deterministically —
before any provider mutation and before rescue is entered — if the URL cannot outlive the
install's stated worst-case duration, with an error kind and message telling the caller to
re-submit with a fresh URL. An expiry mid-stream after that gate is an ordinary install failure
under `OPS-11`'s classification. **The gate exists because the alternative is entering rescue and
beginning a destructive write fed by a URL that is already doomed.** Operator requeue already
carries a fresh payload (`OPS-34`), so no refresh mechanism inside the record is needed.

**OPS-28** Automatic resolution MUST be restricted to searching and MUST NOT mutate. Discovering
that nothing exists does not authorize creating it; that is a new decision by the caller, and a
new purchase.

**OPS-39** **AMENDED — deduplicated, and never blocked by a caller's ceiling.** Each triggering
episode MUST mint **one** durable `system_trigger_id` (`operations.system_trigger_id`, `STO`) and
**reuse it on every subsequent sweep until that episode is resolved** — the id identifies the
*condition* (this machine's exhaustion, this account's loss), not the sweep that noticed it. With
`(machine_id, system_reason, system_trigger_id)` unique at the storage layer, the second sweep's
insert then conflicts and no duplicate cancellation is enqueued. **The constraint bounds new
enqueues, not recovery**: an operation that failed deterministically may still be requeued under
its existing trigger id (`API-19`, `OPS-20`), because a cancellation that did not happen must
remain retryable or the machine bills forever. **Minting a fresh id per sweep
would make the constraint fire never**, which is the defect this rule exists to prevent — otherwise a sweep that runs every minute enqueues a fresh
cancellation every minute for the same exhausted machine, which is repeated provider mutation by
timer.

**Exposure-reducing system cancellations MUST be exempt from `SEC-39`'s per-principal destruction
ceiling.** That ceiling exists to bound what a runaway *caller* can destroy; applying it to the
system's own exhaustion cancels means a tenant that hit its destruction limit keeps running
machines it cannot pay for, with the operator paying. Pacing MAY delay such a cancellation
briefly; nothing may deny it.

**System-initiated provider mutations MUST be operations, and the tenant MUST see them.** Exhaustion cancelling a machine (`LDG-14`), `OPS-36`'s attach-then-cancel, and any other
mutation the deployment performs on a tenant's machine without a caller request MUST go through
this queue — lock, lease, settled states, `needs_reconciliation` included, because a cancel
whose outcome cannot be established is ambiguous no matter who requested it — and MUST appear in the
tenant's operation list marked `requested_by: system` with a stated reason (`exhausted`,
`late_attach_cleanup`, `account_lost`, `tenant_suspended`, `rate_outage_bound`). Without this,
`GET /v1/operations` is not the history of
a tenant's fleet, and the hole sits exactly where the most alarming event does: the machine that
vanished overnight (`F31`). A pure balance event with no provider mutation — a commitment
release, a re-derivation — mints **no** operation; the ledger is already that record.

**OPS-29** A correlator match MUST be exact. Resolution MUST NOT match on hostname, offer,
creation time or any other heuristic, because two of a tenant's own concurrent creates can look
identical, and attaching the wrong machine gives one customer another's server. Where no
correlator exists, the correct outcome is *unresolved*, not a guess.

**OPS-30** Resolution MUST be idempotent and MUST NOT race a healthy in-flight operation. A
resource bearing operation X's correlator belongs to operation X and to nothing else; a sweep
MUST NOT claim a resource whose operation is still `running` and holding its lease.

**OPS-31** Operator verbs MUST exist for the unresolved case and MUST be distinct from requeue:
record an observed resource by its external identifier, record that nothing was created, or
abandon the operation and accept the loss. Each MUST record who resolved it and on what
evidence, and abandonment MUST close the commitment and release it in full (`LDG-32`).

**OPS-32** **AMENDED 2026-08-12 — it is now a MUST, and it keys on the wrong thing no longer.**
Periodic reconciliation MUST run across each provider account independently of any stuck
operation, comparing what the provider reports against what this system believes exists. It
catches drift no operation record would reveal: machines created by hand, machines deleted behind
the system's back, and orphans from an operation whose correlator search was given up on.

**A machine is unclaimed when it is absent from the `machines` table by
`(provider_account, external_id)`** — *not* when it bears no correlator. The previous wording
would have reported as unclaimed, on every sweep forever, **every Hetzner Robot machine** (whose
correlator lives on the order, never on the server) and **every adopted machine** (`PRV-28`) —
a 100% false-positive rate on the dedicated product line this specification exists for. An
unclaimed machine MUST NOT be auto-attached to any tenant (`OPS-29`); it is reported to the
operator.

It was raised from SHOULD because `OPS-33` releases a customer's commitment on the promise that a
late-appearing machine will be *detected as the operator's own problem*. A MUST that gives money
away, compensated by a SHOULD that recovers it, is not a bounded loss — it is an unbounded one
with an optional remedy.

**OPS-33** A negative search MUST NOT reserve a customer's balance indefinitely. Once a bounded
negative window has elapsed, the commitment MUST be closed and released in full even though the
operation remains open, and `OPS-32`'s account sweep MUST continue searching for the correlator
indefinitely afterwards. `OPS-36` governs what happens if the machine then appears.

**Where a provider has no verified correlator** (`PRV-33` — Hetzner Robot is the live case after
`PRV-30` disqualified its `comment` field), the window MUST still be bounded and the commitment
MUST still be released on it, but the search it bounds is an **operator** search, not an automatic
one. The release rule does not weaken: a customer's satoshis are not held hostage to how quickly a
human looks.

**The window MUST be derived per provider from that provider's own allocation behaviour.** An
earlier version said "on the order of hours", which is wrong for the product that matters:
robot-style dedicated orders poll through an `in process` state with no documented bound, and
`08-provider-notes.md` records a 30-day transaction listing precisely because orders stay
resolvable that long. Cloud VMs allocate in seconds; a dedicated order may not resolve the same
day. **A single figure across providers is guaranteed to be wrong for one of them, and it is
wrong in the direction that costs the operator a setup fee plus a period cap.**

The reasoning is about **who carries the residual risk**, not about confidence in the search.
Releasing early moves the risk from the customer to the operator: a machine that appears late
appears as an *unclaimed machine in the operator's own account*, which the sweep detects and
which immediate cancellation bounds to a setup fee. That is a cost the operator can see, price
and absorb. A frozen balance is a cost the customer can neither see nor escape, and for an agent
buying compute it is indistinguishable from theft. Where the two are in tension, the operator
takes the visible loss.

The window MUST be recorded per provider and MUST be derived from measurement rather than
assumed. For the robot-style ordering shape it interacts with the transaction listing window
(`08-provider-notes.md`): past that horizon automatic resolution is impossible and `OPS-31` is
the only road, but the commitment was released long before.

## Worker algorithm

```
loop:
    if sweeper_due:
        expire_stale_running_operations()
        release_expired_machine_locks()

    op = claim_next_queued_operation(worker_id, lease)
    if op is none:
        idle_sleep(); continue

    if op names a machine:
        if not acquire_machine_lock(machine, op, worker_id, lease):
            defer(op, delay); continue

    start heartbeat(op, machine, lease)          # renews both leases
    outcome = race(
        execute(op),                             # cancelled if lease is lost
        lease_lost_signal()
    )
    stop heartbeat

    if outcome is success:
        finish_success(op, worker_id, result)    # conditional on still holding lease
    else:
        if classify(op, error) is ambiguous:
            finish_needs_reconciliation(op, worker_id, error)
        else:
            finish_failed(op, worker_id, error)

    if op names a machine:
        release_machine_lock(machine, op, worker_id)
```

**OPS-21** `execute` MUST be cancellable, and cancellation MUST be treated as an
ambiguous outcome. A provider call abandoned mid-flight is exactly the uncertainty this
design exists to represent.

**OPS-22** **AMENDED.** A **worker** recording a settled state MUST do so conditional on still
holding the lease (`OPS-3`, `STO-3`); a resolution transition out of `needs_reconciliation` is
made by no worker and is guarded by `STO-19`'s write-once columns instead. Where the conditional write affects no rows, the worker MUST log it loudly and
leave the record alone; the sweeper will classify it.

**OPS-23** Validation that was performed at the API boundary MUST be repeated in the
worker before the driver is called. The record may have been written by an older version
of the service, or edited in the store. Validation is cheap; a wrong install is not.

## Fairness and retention

**OPS-24** Claim ordering by age alone lets one tenant starve every other. The claim
strategy SHOULD provide per-tenant fairness, and the API layer SHOULD rate-limit
enqueues per tenant.

**OPS-25** The operation log grows without bound. A retention policy MUST exist: **settled** operations older than a configured age are archived or deleted, while operations in
`needs_reconciliation` — which is not a settled state (`OPS-3`) — MUST be retained until they are
resolved.

**OPS-26** Operators MUST be able to enumerate operations by status through the API —
specifically every operation in `needs_reconciliation` (`API-23`). A design that tells
operators to monitor a state and provides no way to list it is incomplete. See `DEF-8`.
