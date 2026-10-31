# Panel D r83b — consensus on Q4 mechanics only

Read this packet and `/var/tmp/provisiond-panel-r83/r83b/notes.md` whole. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.
Read-only source at `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Do not build or run gates/Lean, change source/Git/tracker/panel records, contact a PR, start a subagent/background task, or inspect other panel folders, units or the main checkout. Only temporary files under `/var/tmp/provisiond-panel-r83/r83b/tmp/<your-seat>/` are allowed. Do not read credentials, sessions or configuration (~/.claude, ~/.codex, ~/.grok, kubeconfig, browser profiles). Return a substantive final answer inside 3600 seconds, <=2500 words plus any complete alternative. This packet includes every r83 answer verbatim. Read them all; Q1–Q3 are background and are NOT re-asked.

The only question is Q4/pv-kv2: reach consensus on a complete exact mechanics bundle under the owner's fixed policy. Owner: "Stop before buying (Recommended)". Exact option: "At pickup the worker sees the customer is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles the exact error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a policy choice." Decision homes API-58 and OPS-43; retain OPS-27 for orders already dispatched. No form reversing that decision is in scope.

r83 preferences were fable A, opus A, sol A, astra D. A was accepted by fable/opus/sol, rejected by astra. B accepted by opus/sol, rejected by fable/astra. C accepted by fable/opus/sol, rejected by astra. D is Astra's complete alternative; no other r83 reader saw it. A has not settled: notes rule 3 requires checking the mandatory disclosure and concrete trace below. This is a candidate defect, not a voided premise; no r83 question was voided under rule 6.

Exact disagreement: does API-58's detailed dispatch exception sufficiently qualify its mandatory public promise, or must the promise itself change? At 10:00 step 8 commits and is acknowledged while active; at 10:01 suspension commits; at 10:02 step 9 reaches the provider and is accepted; attach enqueues cancellation. This concerns authorization while active, not first pickup under suspension. Trace the entire case against both API-58's step (2) and the following full pinned public-disclosure requirement. All printed original forms leave this requirement unchanged. Sol says the detailed exception qualifies it; Astra says its MUST-prescribed words remain false. Decide that specific disagreement, not a stricter impossible provider-call boundary. D is printed in full and corrects the public statement alongside the mechanics.

Additional differences, not new questions: A/C false vs B true retry advice; A/B check after account read in step 1 vs C after channel closure in step 3; D makes the API-58 bold-span anchor explicit, uses about_to_order_at terminology, supplies otherwise-passing fixture prerequisites, and tests first-failure precedence. All retain the tenant same-row guard, lost-ack repeat, original worker claim guard, and suspended-attach cancellation. Do not invent an early lock as a replacement for the same-row conditional write. Do not extend the refusal to installs/power/system cancellation.

Full pinned API-58:04-api-contract.md:731–734, extracted with git show:
```text
not.* **A
suspension is not a promise that the fleet is gone; it is a promise that every machine has been
accounted for and that nothing further can be bought.** The terms and the operator documentation
MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.
```

Read the Q4 source excerpts and alternatives below, plus pinned source as needed. Formal scope is the original packet's scope; no existing Lean coverage is claimed for the new dispatch protocol. Source omissions must not be turned into demands for new formalism. The public wording is a substantive disclosure change; it must be reviewed as such, not hidden as editorial cleanup.

Return: preferred exact form, separate ACCEPT / CANNOT ACCEPT for A/B/C/D, strongest reason and condition for each, whether the disclosed trace is a verified block under rule 3, any premise error under rule 6, and one concrete breaking trace or none found. Aim to find a form you can accept. Reject any form requiring substantive repair and supply a COMPLETE distinct alternative if necessary. End `Final Q4: <exact form>; acceptability A ..., B ..., C ..., D ...`. Do not re-vote Q1–Q3 or the owner policy.

## Original Q4 question and pinned source excerpts

## Q4 — pv-kv2: execute the fixed stop-before-buying policy

**Plain-terms failure story.** The customer queues a server at 10:00, is suspended at 10:01, and a worker first picks up that order at 10:02. The fixed answer is to fail it without buying or charging. A plain read at pickup handles that story. A second story needs a guard: the worker reads active, suspension commits, then the worker reaches purchase. The guard must order those events. Provider calls stay outside a database money lock; there is still a boundary after the last transaction and before the request reaches the provider. An order already past that boundary belongs to the existing attach-and-cancel path rather than being erased as never sent.

**Question.** Which complete mechanics bundle implements the owner answer: where is the claim-time tenant-status read in OPS-43's ordered steps; what kind/reason/retryable does the worker record; what same-row conditional-write orders suspension versus dispatch; how do lost acknowledgements work; and what remains with OPS-27 for dispatched orders? The triage's lead is a tenant read in step 1 beside the account read. The forms below keep account status first and differ in retry advice or in the narrower placement of the early check. If another ordering is needed, give its full exact form and first-failure precedence. The policy itself is not a ballot option.

**Pinned evidence — OPS-43, complete ordered steps and first-failure rule, `03-operation-lifecycle.md:757–837`. Verbatim:**

```text
**OPS-43** **The provider's price MUST be re-checked at claim, and the order refused where the
commitment no longer covers it.** A create is priced and its commitment sized when the API accepts
it; the purchase happens later, in a worker. `WIR-30` says an offer price is "an indicative quote
… `binding` is `false`", and the auction channel is a live market with other bidders in it, so the
provider's own price can move in that window — which on the dedicated product can be long, since
`OPS-33` records that robot-style orders poll through an `in process` state with no documented
bound.

**Sale re-test at claim.** At claim (`OPS-5`), before any provider mutation, the worker MUST
re-test the create's named offer for sale under `PRV-13b` and `PRV-31`, applying `API-7`'s
create-tail verdict: "`invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads".
The inputs are the descriptor the worker runs with
(`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers
result taken at claim. Date bounds MUST resolve against provider-local today at the time of
the check.

The worker MUST order the following steps as listed:

1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
   conditional-write guard; the guard remains the conditional write at step 8. If the status
   is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
   where the status is `terminated` and `"state"` for the two recoverable statuses, since
   presenting an unreachable account as a permanent termination is false, and with
   `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
   error and the operation view”. Make no
   provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
   before acceptance" case.
2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
   account and ordering channel when it claims the operation (`OPS-5`), before any provider
   request, including a per-order key upload").
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate.
4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
   above; if present, re-test the named offer for sale on that result and the running descriptor.
6. Compare its price using that same List offers result, as below. An unsellable offer gets no
   price comparison.
7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
   provider, including provider options". For the rejection's error, see `PRV-47`.
8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
   "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
   on `healthy`". It remains "the last write before the ordering call" (`API-63`).
   In this same transaction, on every ordering channel, including `correlator: none`, the worker
   MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
   guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
   "every write that worker makes to the operation MUST carry `claim_number = mine`").
   The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
   lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
   something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
   from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
   fail the operation deterministically". A first attempt that fails that check commits no
   `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
   account-status write makes the account non-`healthy` before the whole-transaction repeat,
   the repeat can fail that check with the column already set. The create still settles `failed`
   under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
   Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
   MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
   temporary key registration required for this create (`PRV-9`: "the driver MUST register and
   attach them as temporary provider-side resources").

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*

*Amended 2026-10-21 (`pv-p1y`): pointed step 7's rejection at `PRV-47`.*

*Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): extended step 1's quote of `API-63`
to its `retryable` values.*

The first failing check stops subsequent checks; its owning classification governs disposition.
Claim-time refusals are not collected: the error carries neither `details.refusals` nor
`details.not_checked`. The order differs from admission: a create both closed and unsellable
fails `rate_limited` at claim (`PRV-40`: "If the channel is closed at that read, the worker MUST
make no provider request and settle the existing operation `failed` with `rate_limited`") but
`offer_not_sellable` at admission, where `API-7` orders "`invalid_request`/`offer_not_sellable`"
before "`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`".
```

**Pinned evidence — OPS-11, classification and prohibited worker kind, `03-operation-lifecycle.md:240–267`. Verbatim:**

```text
**OPS-11** On failure, the system MUST classify the error into `failed` or
`needs_reconciliation` using the operation kind and the error kind:

| Operation | Classification rule |
|---|---|
| refresh | Always `failed`. It is read-only; a failure changed nothing. *The row read "adopt, refresh" until `ADR-0020` withdrew adopt from v1.* |
| suspend_tenant | Never `needs_reconciliation`, and never `failed` as a whole. It is a parent whose per-machine children carry their own outcomes (`WIR-39`), and it settles `succeeded` once every child has either settled or **reached `needs_reconciliation`** — a child that reached that state counts as complete for the parent. `needs_reconciliation` is not itself settled (`OPS-3`); it is a state only evidence or an operator moves, so an unresolved child is a child-level fact, and blocking the parent on it would leave every suspended tenant's record permanently open. |
| rescue inventory | Same rows as `install`. It is **not** read-only in the relevant sense: it boots the machine into rescue, so an ambiguous failure can strand it there, and `PRV-22` makes an end-rescue failure always ambiguous. Classifying it with `refresh` would mark it `failed` while the machine sits in rescue. |
| install | `needs_reconciliation` for `network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity` **once the write-started marker is set** (`OPS-45`). `failed` for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` **where no rescue session was left open** (the paragraph below), **and for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue session was left open** — including `integrity` before the connection, which is `RSC-3`'s host-key abort. An install that got further than that may have begun overwriting a disk, or may have left the machine in rescue; one that did neither, provably did neither. **`failed` past the write-started marker, where rescue exited cleanly, asserts that the install did not complete and nothing about the disk** (*2026-09-15, `pv-x8r`*): the deterministic caller kinds stay `failed` there because the engine knows what it did — an installer that rejected the layout it had begun partitioning for is a known outcome — and `needs_reconciliation` is the state for an outcome nobody knows (`CONTEXT.md`), whose only truthful verb here would be `abandoned`, which settles `failed` after a human looked. It does not mean `not_applied`, which `OPS-31` refuses there. What the disk holds is `OPS-45`'s marker's fact, rendered to the caller as `WIR-9a`'s `disk_effect`; the state does not carry it. |
| create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
| power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): the restart settlement is outside this classification; see `OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."*

*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): the restart exception reads the null column on a restart; the create row instead classifies a failure recorded by the worker, by position. After step 8 is acknowledged and before step 9 begins, a recorded failure settles `failed` with the column set. A restart in that same window takes the ordinary path (`OPS-15`: "the engine MUST move every `running` operation to `needs_reconciliation`"), since the column is set.*

*Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): made the last row read the write-started marker for recorded failures below goal-state success and except known-accepted mutations, with ambiguity in the fallback branch.*

**The table MUST be total, and seven kinds added later were missing.** `insufficient_balance`,
`not_activated`, `halted`, `gone`, `suspended`, — added 2026-09-02 — `ceiling_exceeded`
(`DOM-20`, `DOM-21`, `SEC-39`) and — added 2026-09-12 — `overloaded` (`STO-55`) are
**admission-only**: they are decided
before any driver call, they MUST NOT be emitted by a worker or a driver, and any pre-provider
occurrence classifies deterministically as `failed` for every operation kind. Nothing was
destroyed and nothing was ordered, so ambiguity cannot arise. Every kind in `DOM-17` MUST have a
defined classification for every operation kind. There is no implicit default, because the two possible defaults are both wrong:
defaulting to `failed` invites a caller to retry a mutation that may have happened, and
defaulting to `needs_reconciliation` pages a human for a typo. `CNF-31b` tests totality.
```

**Pinned evidence — API-58, admission flag, claimed work and administrative guard, `04-api-contract.md:617–650`. Verbatim:**

```text
**API-58** **A funded tenant MUST be suspended, never deleted.** Suspension is an operator action
that (1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**,
so no further **tenant-authorized** write succeeds —
the maintenance actions of `API-7` step 2 remain reachable, because a suspended owner must still be
able to revoke a stolen credential (`API-56`, `CNF-209`), and an operator may retry a stalled
episode (`API-64`), which skips step 5b like every operator verb (`API-7`) — then (2)
**fences work already in flight** — a create claimed before the suspension landed MUST be allowed
to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep,
because abandoning an in-flight order is how a machine ends up bought, unrecorded and unbilled —
then (3) enqueues a system cancellation per machine (`OPS-39`) — then (4) **transitions the tenant's own work — `requested_by: caller`, never a system
cancellation — that is already
`queued` but never claimed straight to `failed`, carrying the reason in the operation's `error`:
`conflict`, with `details.reason: "tenant_suspended"`** (`WIR-9a`, `WIR-10b`) — it
has touched no provider, so cancelling it needs no operation, and it does **not** carry the error
kind `suspended`, which `OPS-11` classifies as admission-only and forbids a worker to emit: that
kind stays an admission-time rejection of a *caller's* write (`DOM-20`).
**Its `requested_by` stays `caller` and its `system_reason` stays null**, because `WIR-10` permits
a non-null `system_reason` only on `requested_by: system`, and re-labelling the request `system`
to make room for one would attribute the caller's own create to the system and destroy the record
of who asked for it. The reason belongs in the error, which is where a caller reads why its work
did not run. *`system_reason: tenant_suspended` was the withdrawn form and it produced an
operation view no strict parser should accept.* The value stays legal on the step-(3)
cancellations, which the system really did request (`OPS-39`). This transition is also **not** a
worker classification: nothing was claimed and no driver was called, so `OPS-11`'s install row —
which sends `conflict` to `needs_reconciliation` "once the write-started marker is set" — does not reach it, and the operation goes
straight to `failed` as stated. **Not being a classification does not exempt the database write**:
it is `STO-3`'s fifth named case (fourth until the defer was listed on 2026-09-12), guarded on its full predicate — `(id, status = queued,
requested_by = caller, tenant suspended, this suspension's parent still unsettled)`, quoted rather
than paraphrased since 2026-09-05, when a paraphrase here dropped the `requested_by` term and let
step (4) fail the system delete step (3) had just named — and reporting whether it affected a row, so a child claimed
by a real worker in the meantime loses this race and settles through that worker instead. The fan-out then lets anything
already `running` settle, **then re-sweeps: a create that
settled after the fan-out has produced a machine the first pass never saw, and it MUST be
cancelled by a second pass rather than left running against a suspended tenant** — the fan-out
```

**Pinned evidence — API-58, suspension promise, `04-api-contract.md:728–733`. Verbatim:**

```text
schedule whether or not anyone looks" — which `OPS-48` forbids: the episode stays open, the sweep
enqueues nothing against an open episode, and the operator listing and retry are the only
recovery. `CNF-272` carried the same false clause and was corrected the day before; this copy was
not.* **A
suspension is not a promise that the fleet is gone; it is a promise that every machine has been
accounted for and that nothing further can be bought.** The terms and the operator documentation
```

**Pinned evidence — API-58, admission atomicity and resume fence, `04-api-contract.md:744–753`. Verbatim:**

```text
The crash-safety the withdrawn clause was protecting is supplied elsewhere and better: the startup
pass (`OPS-15`) returns an interrupted `suspend_tenant` parent to `queued` rather than to
`needs_reconciliation`, and the open episode (`STO-52`) makes the re-sweep idempotent, so a crash
mid-fan-out strands nothing. **The flag and the enqueue of the parent commit together at admission;
the fan-out is the worker's.**

**Because the fan-out re-sweeps, resume MUST NOT be accepted while this parent is unsettled**
(`WIR-41`): a machine created after an early resume is exactly what the re-sweep is built to find,
and it would be cancelled by a suspension the operator already lifted. The parent's state is the
fence, and the refusal is a `conflict` naming the running suspension.
```

**Pinned evidence — OPS-27, suspended attach, `03-operation-lifecycle.md:640–654`. Verbatim:**

```text
no-rate branch, "open no commitment, regardless of available balance". Verification: `CNF-308`.*

**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.
```

**Pinned evidence — LDG-69, transaction hold excludes provider call, `12-billing-and-ledger.md:463–473`. Verbatim:**

```text
**LDG-69** **AMENDED 2026-09-08 (`ADR-0016`) — the machine lock is deleted; the rule binds the hold
`OPS-8` defines instead.** A deployment MUST hold `LDG-35`'s primitive for the duration of one
database transaction and no longer. While it is held, an implementation MUST NOT wait on a running
operation's hold on its machine (`OPS-8`), the completion of a child operation (`API-58`,
`WIR-39`), or any provider call.

**The permitted order is one-way: a running operation's hold on its machine (`OPS-8`) → a short
tenant-serialized transaction.** A worker whose operation holds the machine MAY enter the
serialization for a bounded read or write; **a transaction under the serialization MUST NOT acquire
or wait on a machine.** One direction cannot form a cycle, and `OPS-8` makes taking a machine
try-and-defer rather than wait, so nothing blocks on it either.
```

**Pinned evidence — STO-8, persisted dispatch marker, `05-persistence.md:519–521`. Verbatim:**

```text
| `provider_account` | text | nullable |
| `correlator_kind`, `correlator_value` | text, text | nullable; what the create wrote into the provider (`PRV-26`) — `operation_uuid` where a free field exists, `ssh_key_fingerprint` on Robot (`PRV-32`). **A single value, not a list** (`ADR-0014`): a create has one attempt and one correlator. Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8, after its step-4 List offers read and before the order (`PRV-26`: "before the order is sent"; `API-63`: "the last write before the ordering call"), and null for every operation kind other than create. The `provider_account` write retains `OPS-35`'s "before any driver call". *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): aligned correlator timing with the correlator transaction, after List offers and before the order.* *`F36` and `ADR-0014` record what the withdrawn per-attempt list cost* |
| `about_to_order_at` | timestamp | nullable; create only, null on every other kind. Written once in `OPS-43`'s step 8, `API-63`'s correlator transaction, on every ordering channel including `correlator: none`; the only other writer is `STO-13`'s one-time migration backfill. **Never cleared; survives the request-data purge** on entry to a settled state or `needs_reconciliation`. It is a column outside `request`, not a correlator or one of `OPS-45`'s markers; nothing copies it to a machine or renders it on the wire. `OPS-43`: "MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`". *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the all-channel column; `ADR-0042`.* |
```

**Pinned evidence — tenant status enum, `05-persistence.md:663–673`. Verbatim:**

```text
an environment variable (`API-4` as amended).

| Column | Type | Notes |
|---|---|---|
| `id` | text | primary key; opaque, no personal data (`ADR-0005`) |
| `credential_digest` | text | not null; the **spending token** hash, never the credential itself (`API-3`). Replaced in place by `WIR-38` |
| `recovery_digest` | text | not null; the **recovery credential** hash (`API-55`). Minted with the row and never replaced by a spending-token revocation |
| `credential_generation` | integer | increments on every revocation (`API-56`); a token from an earlier generation never authenticates, so a replayed revocation cannot resurrect one |
| `status` | enum | `pending` \| `active` \| `suspended` (`API-58`; a suspended tenant authorizes no *tenant* write, retains ledger, machine and abuse-case reads, and retains the maintenance actions of `API-7` step 2 as narrowed by step 5b — including the abuse-statement write) |
| `pending_expires_at` | timestamp | nullable; unfunded enrolments are deleted at this time (`API-34`) |
| `created_at`, `activated_at` | timestamp | `activated_at` null until first funding (`API-35`) |
```

**Pinned evidence — WIR-9a, existing tenant_suspended conflict reason, `13-wire-contract.md:126–142`. Verbatim:**

```text
**WIR-9a** **`details` is machine-readable and its keys are defined per kind, not left to prose.**
The caller is software; routing a value through `message` (which `API-25` constrains) forces an
agent to parse English. Minimum keys:

| kind | `details` |
|---|---|
| `insufficient_balance` | `available_sats`, `required_sats` |
| `invalid_request` / `offer_not_sellable` on create | `reason: "offer_not_sellable"`; no cap or balance result or amount derived from the withheld offer's price |
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |
| `not_activated` | `activation_minimum_sats` |
| `rate_limited` | `retry_after_ms` |
| `ceiling_exceeded` | `ceiling` (which one, from `SEC-39`'s stated set), `limit`, `interval_seconds`, `retry_after_ms` (to the end of the current interval) |
| `halted` | `retry_after_ms`, `gate` (`"solvency"` \| `"rate_unavailable"`) |
| `overloaded` | `retry_after_ms` (`STO-55`; added 2026-09-12) |
| `gone` | `retained_until` — and the safe reaction is to read machines and balance, never re-issue (`DOM-21`) |
| `conflict` | `reason` (`"idempotency_mismatch"` \| `"state"` \| `"credential_already_replaced"` (`API-56`) \| `"suspension_in_flight"` (`WIR-41`) \| `"tenant_suspended"` (`API-58`) \| `"case_closed"` (`WIR-43`) \| `"signup_window_closed"` (`API-34`) \| `"deposit_already_attributed"` (`WIR-42`) \| `"cancellation_committed"` (`OPS-42`) \| `"price_moved"` (`OPS-43`; with `shortfall_native` and `currency`) \| `"account_terminated"` (`API-63`) \| `"incomplete_record"` (`OPS-23`) \| `"cut_off"` (`OPS-21`)) |
| `unsupported` | `provider_account`, `capability` (`DOM-10`) |
```

**Pinned evidence — API-51, retry guidance, `04-api-contract.md:1259–1273`. Verbatim:**

```text
**API-51** **`retryable` is normative for callers, not advisory to operators.** An operation in
`needs_reconciliation` MUST be delivered with `retryable: false`, and the contract MUST state in
words that re-issuing the request under a fresh idempotency key **is a fresh operation**, not a
retry — on a create, **a second purchase**; on an install, a second destructive write while the
first's outcome is unresolved (*scoped 2026-09-15, `pv-x8r`; it read as if every kind bought
something*). `OPS-12` forbids the *system* from retrying an ambiguous mutation, but nothing else stops
the *customer's* agent from buying the duplicate server `OPS-27` exists to prevent — `SEC-39`'s
per-principal ceiling is the backstop, and this
field is the signal. This is the single most expensive way for "finding out" to go wrong.

*Amended 2026-10-08 (`ADR-0035`):* a `needs_reconciliation` create with error kind
`rate_limited` MUST retain `details.retry_after_ms` alongside `retryable: false`. Retry-after
reports the throttle interval; it does not authorize reissuing the mutation. `WIR-9a` owns the
per-kind keys and `WIR-9b` their retryability precedence. A failure to poll the operation view
is a read failure, distinct from the underlying operation's outcome (`API-50`).
```


## Formal scope


This panel changes no files. Any later amendment to a formalized property must update its owning Lean declaration and Markdown together, after reading the statement and its omissions, without weakening a theorem to silence it; see AGENTS.md and ADR-0025. No CNF identifier belongs in tools/formal. Relevant declarations are indexed under API-58 (Funding.lean and Fence.lean), STO-3 (Claim.lean and Rescue.lean), LDG-32 (Ledger.lean and Funding.lean), PRV-36 (Reconcile.lean), and OVR-19 (Fence.lean and Witnesses.lean). The index alone is not a claim that each declaration models the proposed guard. For example Claim.lean's opening scope explicitly omits API-58's fan-out transition, and Reconcile.lean models one create's knowledge, not a non-create dispatcher. Read those omissions before proposing a formal coverage claim. Identify an actual affected declaration, or state that the mechanics sit outside the current model; do not demand a new formalism merely to accept an option.


## Exact alternative A

### Q4-A — step-1 read plus dispatch guard; retryable false

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In OPS-43 step 1, after the existing account-status refusal paragraph and before step 2, append:

Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.

In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed marker/correlator unchanged and settle the worker's recorded
failure under the same pre-step-9 rule; do not add a null-marker term to the settlement guard.
A serialization failure is retried as a whole transaction under OPS-49 and is not a tenant-status
refusal. The operation-row claim guard and acknowledgement-before-step-9 rules remain required.

In API-58 step (2), replace the text from "fences work already in flight" through "unrecorded and unbilled" with:

fences work already in flight — a create that passed OPS-43's tenant dispatch guard before the
suspension landed is potentially dispatched and MUST be allowed to settle rather than abandoned
mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by itself does
not authorize purchase: a create that first reads the tenant suspended fails under OPS-43, and
suspension winning the step-8 tenant guard also prevents purchase. A create past the guard can
still be between the acknowledged transaction and its provider call, because LDG-69 keeps the
call outside the transaction; treat that residue as the potentially dispatched case. Never fail
or release such an uncertain order through the never-claimed administrative write. This does
not override a deterministic failure the worker actually records before step 9: OPS-11 says
"Any create failure the worker records before any step-9 request (before any per-order key upload
or order request) MUST settle `failed`, whatever its kind."

In API-58, immediately before its paragraph beginning "A create that has produced no machine yet", insert:

For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.

In CNF-202, after the additional Q1 store cases if adopted (otherwise before its amendment note), append:

Independently admit a create while the tenant is active, keep it unclaimed, commit suspension,
then let a worker claim the create before the suspension fan-out can fail it. Assert failed,
conflict with details.reason: "tenant_suspended", retryable: false on both error and operation
view, no provider request, no purchase or fee/first-unit debit, full release, original origin
stamp, and no admission-only suspended error. Separately let the worker's early tenant read
see active, then commit suspension before the step-8 tenant guard: assert the same refusal,
allowing only preceding non-mutating reads, no step-9 request and no first-transaction marker
or correlator commit. Race the tenant dispatch guard against suspension in both orders. Where
the guard wins and its transaction commits, suspend before the provider call and assert the
attempt is treated as potentially dispatched and allowed to settle, with a system cancellation
in the machine's attach transaction if the tenant remains suspended. Exercise the late evidence
attach after the suspension parent has settled as well. Lose step 8's acknowledgement, suspend
before the whole-transaction repeat, and assert deterministic pre-step-9 failure, unchanged
previously committed marker/correlator, full release and no speculative dispatch. Retain the
worker claim guard in every settlement. Run these barriers on auction and standard-channel
(correlator: none) descriptors and on a provider using per-order temporary keys.
```

## Exact alternative B

### Q4-B — same step-1 read and guard; retryable true after safe pre-purchase refusal

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In OPS-43 step 1, after the existing account-status refusal paragraph and before step 2, append:

Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: true on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.

In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: true
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed marker/correlator unchanged and settle the worker's recorded
failure under the same pre-step-9 rule; do not add a null-marker term to the settlement guard.
A serialization failure is retried as a whole transaction under OPS-49 and is not a tenant-status
refusal. The operation-row claim guard and acknowledgement-before-step-9 rules remain required.

In API-58 step (2), replace the text from "fences work already in flight" through "unrecorded and unbilled" with:

fences work already in flight — a create that passed OPS-43's tenant dispatch guard before the
suspension landed is potentially dispatched and MUST be allowed to settle rather than abandoned
mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by itself does
not authorize purchase: a create that first reads the tenant suspended fails under OPS-43, and
suspension winning the step-8 tenant guard also prevents purchase. A create past the guard can
still be between the acknowledged transaction and its provider call, because LDG-69 keeps the
call outside the transaction; treat that residue as the potentially dispatched case. Never fail
or release such an uncertain order through the never-claimed administrative write. This does
not override a deterministic failure the worker actually records before step 9: OPS-11 says
"Any create failure the worker records before any step-9 request (before any per-order key upload
or order request) MUST settle `failed`, whatever its kind."

In API-58, immediately before its paragraph beginning "A create that has produced no machine yet", insert:

For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.

In CNF-202, after the additional Q1 store cases if adopted (otherwise before its amendment note), append:

Independently admit a create while the tenant is active, keep it unclaimed, commit suspension,
then let a worker claim the create before the suspension fan-out can fail it. Assert failed,
conflict with details.reason: "tenant_suspended", retryable: true on both error and operation
view, no provider request, no purchase or fee/first-unit debit, full release, original origin
stamp, and no admission-only suspended error. Separately let the worker's early tenant read
see active, then commit suspension before the step-8 tenant guard: assert the same refusal,
allowing only preceding non-mutating reads, no step-9 request and no first-transaction marker
or correlator commit. Race the tenant dispatch guard against suspension in both orders. Where
the guard wins and its transaction commits, suspend before the provider call and assert the
attempt is treated as potentially dispatched and allowed to settle, with a system cancellation
in the machine's attach transaction if the tenant remains suspended. Exercise the late evidence
attach after the suspension parent has settled as well. Lose step 8's acknowledgement, suspend
before the whole-transaction repeat, and assert deterministic pre-step-9 failure, unchanged
previously committed marker/correlator, full release and no speculative dispatch. Retain the
worker claim guard in every settlement. Run these barriers on auction and standard-channel
(correlator: none) descriptors and on a provider using per-order temporary keys.
```

## Exact alternative C

### Q4-C — narrower step-3 read; same dispatch guard and retryable false

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In OPS-43 step 3, before repeating boundary validation, insert:

Read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read follows the account-status and stored-channel-closure checks and precedes boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.

In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed marker/correlator unchanged and settle the worker's recorded
failure under the same pre-step-9 rule; do not add a null-marker term to the settlement guard.
A serialization failure is retried as a whole transaction under OPS-49 and is not a tenant-status
refusal. The operation-row claim guard and acknowledgement-before-step-9 rules remain required.

In API-58 step (2), replace the text from "fences work already in flight" through "unrecorded and unbilled" with:

fences work already in flight — a create that passed OPS-43's tenant dispatch guard before the
suspension landed is potentially dispatched and MUST be allowed to settle rather than abandoned
mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by itself does
not authorize purchase: a create that first reads the tenant suspended fails under OPS-43, and
suspension winning the step-8 tenant guard also prevents purchase. A create past the guard can
still be between the acknowledged transaction and its provider call, because LDG-69 keeps the
call outside the transaction; treat that residue as the potentially dispatched case. Never fail
or release such an uncertain order through the never-claimed administrative write. This does
not override a deterministic failure the worker actually records before step 9: OPS-11 says
"Any create failure the worker records before any step-9 request (before any per-order key upload
or order request) MUST settle `failed`, whatever its kind."

In API-58, immediately before its paragraph beginning "A create that has produced no machine yet", insert:

For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.

In CNF-202, after the additional Q1 store cases if adopted (otherwise before its amendment note), append:

Independently admit a create while the tenant is active, keep it unclaimed, commit suspension,
then let a worker claim the create before the suspension fan-out can fail it. Assert failed,
conflict with details.reason: "tenant_suspended", retryable: false on both error and operation
view, no provider request, no purchase or fee/first-unit debit, full release, original origin
stamp, and no admission-only suspended error. Separately let the worker's early tenant read
see active, then commit suspension before the step-8 tenant guard: assert the same refusal,
allowing only preceding non-mutating reads, no step-9 request and no first-transaction marker
or correlator commit. Race the tenant dispatch guard against suspension in both orders. Where
the guard wins and its transaction commits, suspend before the provider call and assert the
attempt is treated as potentially dispatched and allowed to settle, with a system cancellation
in the machine's attach transaction if the tenant remains suspended. Exercise the late evidence
attach after the suspension parent has settled as well. Lose step 8's acknowledgement, suspend
before the whole-transaction repeat, and assert deterministic pre-step-9 failure, unchanged
previously committed marker/correlator, full release and no speculative dispatch. Retain the
worker claim guard in every settlement. Run these barriers on auction and standard-channel
(correlator: none) descriptors and on a provider using per-order temporary keys.
```

## Exact alternative D

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
and is not a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any
per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```


## Verbatim r83 answer — fable (Q1–Q3 context only)

**Verification result.** Every pinned quotation in the brief matches the clone at 3109b5b line for line. The bead rows and triage rows in `check/` match the questions. I found no brief error that changes any question's premise, so no tally is void under rule 6. Non-void brief defects are listed under each question. One applies to every printed form: the forms omit the backticks the citation gate reads around identifiers and quotes; that is a landing convention, not a substantive change, and I do not count it against acceptability.

**Formal scope, checked.** No printed form touches a modelled property. The two API-58 declarations are `reap_refuses_active` (`tools/formal/Provisiond/Funding.lean:1011`, the reap refusal) and `suspend` (`Fence.lean:1083`, sets a flag and enqueues one cancellation). `Claim.lean:14-16` lists among its omissions "`API-58`'s fan-out transition (`pv-vwe.6`)" and `OPS-27`'s resolution writes. `AccountStatus.lean:13-15` says "Not modelled: `API-63`'s recording transaction — ... its contention with admission on the account row". `Admission.lean:40-41` says the tail "does not read provider-account or machine rows". `Reconcile.lean` models one create's knowledge, as the brief says. The LDG-32 declarations model release amounts, not which transaction triggers them. So all four questions sit outside the current model, and no theorem needs weakening or extension to accept any form.

---

**Q1 — pv-gvc.** Preferred form: **Q1-B**.

Acceptability: Q1-A ACCEPT, Q1-B ACCEPT, Q1-C ACCEPT, each with one condition stated below.

Release ownership. LDG-32 owns the rule, and its outcome list reaches the administrative transition: `12-billing-and-ledger.md:310-312` says release is due on "**every** terminal outcome: ... the create fails deterministically". A step-(4) create has "touched no provider" (`04-api-contract.md:630-631`), so it is a deterministic failure in that sense. What no text supplies is the writer's own money order, and every other writer in this set states it: the worker (`05-persistence.md:34`: "take the `LDG-35` primitive, make this guarded status write, then release"), the startup pass (`OPS-15`: "Only if the status write affects a row MUST the same transaction close and release the commitment in full"), and the termination (`04-api-contract.md:1375-1377`: "transition every `queued`, never-claimed create ... **and close and release its commitment**"). API-58 step (4) says nothing about money, while API-63 asserts "exactly as `API-58` step 4 does for a suspension". At the pin that assertion has no sentence behind it, which is the AGENTS.md failure shape. Q1-B's insert gives API-58 the duty, places it in the same transaction, after the generation check and the tenant primitive, with the status write short-circuiting the release on zero rows. That matches STO-3's stated order and makes API-63's existing sentence true. So the test alone (A, C) is acceptable because LDG-32 already owns the outcome, but the duty's placement needs the rule, which is why B is the complete form.

Coverage of the five bad builds:

- Deleted origin term: all three vary `requested_by` system and operator on fresh fixtures. Caught.
- Deleted parent-unsettled term: all three run the settled-parent and stale-old-parent cases. Caught.
- Lost claim race: all three race both orders and assert the claim number survives. Caught.
- Kind filter handling only power: A and C both catch it. A build with a {create, install, power} allowlist passes C and fails A.
- Missing create release: all three assert full release and no fee or first-unit debit. Under A and C the only normative basis is LDG-32's outcome row. Under B the writer's transaction is named.

Conditions and non-void defects:

- Every Q1 form's CNF text says a claimed create "follows OPS-43's tenant-status refusal". No such refusal exists at the pin (`03-operation-lifecycle.md:776-784` reads only "the provider account's stored status"). Each Q1 form is acceptable only landed together with, or after, a Q4 form. If Q4 does not settle, that sentence must be removed before landing.
- Q1-A says "WIR-10's operation-kind set". The closed kind enum is WIR-10a's (`13-wire-contract.md:271-273`). Editorial owner correction.
- The "tenant active" fixture with an unsettled parent is unreachable through the API, since WIR-41 refuses resume while the parent is unsettled. As a store fixture it is valid, and the text says so.

Break fixture: none found for any form. The three writers are distinguishable in each form: the store write is guarded on `status = queued`, the worker's settlement on `(running, claim_number = mine)`, and a dispatched order is `running` with the column set and is unreachable by the administrative write.

Don't-build, on request: adding a money sentence to API-58 gives release mechanics a second home beside STO-3 and LDG-32, and a future amendment to one can drift from the other. Counter: OPS-15 and API-63 already carry their own copies for the same reason, and the guard protects nothing that B removes.

Follow-ups: STO-58 frees an `offer_is_resource` exclusion on "the winning create's outcome settlement" and CNF-202 should assert it for a step-(4) failure (overlap with #47). API-58 step (4) states no `retryable` for its failure; see Q4.

---

**Q2 — pv-bxh.** Preferred form: **Q2-A**.

Acceptability: Q2-A ACCEPT, Q2-B CANNOT ACCEPT, Q2-N CANNOT ACCEPT.

Q2-N fails its own acceptance test. No existing clause yields a value: WIR-9a's two account rows key on the "collection-snapshot `STO-47` status" (`13-wire-contract.md:171-172`), which was `healthy` in the race; API-7's constant false is "specific to the resource-offer guard" (`04-api-contract.md:302`); API-63's values at 1423-1427 are the worker's step-8 mapping. DOM-17 gives the meaning of the field, not a value.

Q2-B borrows the resource-offer guard's false without a ruling and contradicts DOM-17 on a concrete refusal. `01-domain-model.md:656-657`: "`retryable` describes whether repeating the *same request* is safe and sensible." Interleaving: a healthy snapshot, then `account_unreachable` commits before the conditional write. Q2-B answers false. The account recovers an hour later and the same request would succeed. One step later on the same condition, API-63 gives true and says why: "presenting an unreachable account as a permanent termination is false" (`04-api-contract.md:1423-1424`). The offer guard's false has a permanent reason (the offer is gone); this refusal does not.

Q2-A names the mechanism the brief asked for. A zero-row UPDATE returns no status; `SELECT ... FOR UPDATE` first does, and under READ COMMITTED it returns the latest committed version after any in-flight recording commits, so the status it returns is the one the guarded write then tests. The recording transaction's own write of STO-47 blocks on that lock, so recovery cannot change the status under a decision already taken. Lock order: the admission already holds the tenant's LDG-35 primitive and already locks the account row at its UPDATE, so Q2-A moves the row lock a few statements earlier and introduces no new ordering. The pre-existing hazard is API-63's recording transaction, which does not say whether its tenant primitives are acquired before its status write; if after, the two deadlock and PostgreSQL aborts one. That is not Q2-A's defect and is a follow-up. Q2-A's "A serialization failure is not a non-healthy status" is right and is the branch the test under snapshot isolation would otherwise misread.

Non-void defects in Q2-A, none blocking:

- The replaced API-63 sentence carried the rationale "so a create admitted after a termination is impossible rather than merely unlikely ... which is `OPS-42`'s shape". Q2-A drops it. Rationale, not a MUST.
- The landing instruction names "the Second barrier sentence and its following explanatory sentence", but `10-conformance-checklist.md:2939-2942` is one sentence ending "snapshot isolation." Locatable.
- Neither Q2-A nor Q2-B states the response shape of this refusal: an ordinary WIR-9 error, as the offer guard's is, or a one-entry refusals list. Either way WIR-9b makes the value determinate. Follow-up.

Break fixture: the deadlock interleaving above, pre-existing, not specific to Q2-A.

Don't-build, on request: the explicit `FOR UPDATE` on a hot per-account row lengthens every create's admission lock footprint, and the constant-false mapping needs no lock. Counter: the lock is already taken at the UPDATE; the only new cost is ordering it before the write, and the constant value is the DOM-17 contradiction above.

---

**Q3 — pv-y0to.** Preferred form: **Q3-A**.

Acceptability: Q3-N ACCEPT, Q3-A ACCEPT, Q3-B ACCEPT.

The automatic path exists at the pin, so I name it before judging the forms. Discovery and owner: `03-operation-lifecycle.md:95-96` says resolution transitions are made "by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb", and lines 76-77 say "`OPS-27`'s evidence sweep is itself automatic and does move the state"; OVR-17's row assigns "`OPS-27`'s resolution sweep" to `engine`. Per-kind dispatch: `02-provider-contract.md:1114-1115` says "Per mutation kind it can be asked to resolve, a driver MUST declare its evidence sources", in PRV-44's descriptor. Window origin: `02:1141-1143` says "`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from the end of the mutating call's wait", which binds OPS-27's resolution to non-create reads. Cadence: `00-overview.md:445-447` says "its resolution read MUST be issued within that cadence". Guarded settlement: `05-persistence.md:59-60` guards it on "(id, status = needs_reconciliation, resolution IS NULL)", STO-19 makes it write-once, OPS-3 lists the exact `applied`/`not_applied` transitions. Operator fallback: `03:1522-1524` says resolution "proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it, falling back to `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot". CNF-237 already requires an ambiguous delete to resolve this way, and CNF-329 requires the cadence enforced.

Two kinds of mutation, separately. Provider-managed kinds (delete, power, reverse DNS, release attachment, `provider_native` and `provider_catalogue` installs) have a provider-side action to read: the write path's own report, the action history, or the resource read after the window. Rescue-based disk writes and rescue inventory have no provider mutation to read; their ambiguity is the engine's own disk write and the rescue exit, and PRV-29's path yields nothing truthful about a disk's contents, so the chain delivers them to OPS-31, where `not_applied` is refused with a set marker. Ordinary machine presence proves nothing about either; no form claims otherwise.

Why Q3-A anyway. OPS-27's own body is create-shaped from its second sentence on, and OVR-17's rationale reads "It searches providers by correlator". A builder reading OPS-27 as the definition of automatic resolution reaches pv-y0to's conclusion. Q3-A adds no behaviour; it tells OPS-27 that its sweep covers non-create operations and points at the owners. Q3-N is acceptable on the chain above, but leaves the misreading in place.

Q3-B is internally consistent and I found no contradiction, so I accept it. It is not preferred because it writes second copies of MUSTs owned elsewhere: OVR-19's cadence ("Reads MUST be issued within OVR-19's stated resolution-read cadence"), OPS-28's no-mutation rule, and STO-19's write-once rule, which AGENTS.md warns is how copies drift. It also adds one new obligation nothing else carries: "Record ... the resolving engine identity with the resolution", a content rule for `resolved_by` with no STO-8 edit. Its CNF-237 append is good coverage, including the operator-wins-the-guard race.

Break fixture: none found. Q3-A's "the correlator search and outcome table below apply to create only" is true; the table's four rows all act on a resource to attach and a commitment.

Don't-build, on request: the chain exists and every added sentence in OPS-27 is a second home. Counter: Q3-A's one paragraph names owners and quotes OPS-28; it restates nothing, and the OVR-17 rationale it replaces is the one sentence in the set that actively says "correlator" where the component also reads evidence.

---

**Q4 — pv-kv2.** Preferred form: **Q4-A**.

Acceptability: Q4-A ACCEPT, Q4-B CANNOT ACCEPT, Q4-C ACCEPT.

Policy test. A create first claimed while the tenant is suspended cannot enter the residue under A or C: the step-1 read (A) or step-3 read (C) sees the committed flag, since API-58 "(1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**" (`04:618`). A create that reads active while a suspend transaction is uncommitted was not yet suspended at pickup; its step-8 tenant write blocks on that row's lock and re-evaluates to zero rows when the suspend commits, which is "one provably loses". The only create that reaches the residue passed the guard while active, which is the "claimed before the suspension landed" case the owner kept. A stricter boundary is impossible: `12:465-467` forbids waiting on "any provider call" under the primitive, and a last plain read is not race-free. The step-8 boundary is the existing account-termination shape (`04:1437`: "A claimed create with `about_to_order_at` set MUST be treated as potentially dispatched"). I therefore do not reject on boundary grounds.

Mechanics checked against the pin:

- Kind and reason: `conflict`/`tenant_suspended` is already in WIR-9a's union (`13:141`) and is what API-58 step (4) uses for the same situation; the admission-only kind `suspended` is forbidden to a worker (`03:264`).
- Settlement: OPS-11's create row (`03:250`) settles any pre-step-9 recorded failure `failed`, and "a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`", so the forms must state the value, and they do.
- Lost acknowledgement: the forms mirror the existing account-status sentence (`03:793-797`); the repeat can fail with the column set and still settles under the create row.
- Lock order: the step-8 transaction takes STO-47's row then the tenants row; the suspend admission takes the tenants row only; API-63's recording takes STO-47's row and tenant primitives, never the tenants row. No cycle.
- Step (2) replacement: "its machine follows OPS-27's suspended-attach cancellation" is right, since OPS-27's clause "applies at **all three** entry points" (`03:646`), including settle-time verification; the re-sweep text later in API-58 is untouched and finds that episode already open. The quoted "claimed before" sentence does need replacing: with a guard, a claim no longer licenses purchase, and the sentence as pinned says it does.

Retryability. Q4-B's true fails DOM-17 on the concrete case: while the tenant is suspended, the same request is refused at API-7 step 5b with the 403 kind `suspended`, and the condition clears only by an operator's resume, after which the fleet is gone and a create is a fresh decision. `halted` and `account_unreachable` are true because a system gate "can clear" on its own; suspension is a judgment about the caller, and API-51 makes the field "normative for callers", so true instructs an agent into repeated 403s. A is the DOM-17 reading. C's only difference from A is precedence: a suspended tenant whose channel is closed is told `rate_limited` with `retry_after_ms`, inviting a retry that admission will refuse `suspended`. Acceptable, less honest, not preferred.

Non-void defects:

- API-58 step (4)'s own `tenant_suspended` failure carries no stated `retryable` at the pin, and CNF-202 does not assert one. Q4 lands a value for the worker's path only. Coordinated follow-up: give step (4) the same value and assert it in CNF-202, or the same reason carries two values by path.
- WIR-9a's union cites `API-58` alone for `tenant_suspended`; OPS-43 becomes a second emitter. Editorial.
- The forms do not extend the rule to a claimed power or install after suspension, and I do not propose that here.

Break fixture: none found for A. Both orders of the step-8 guard against the suspend, the lost-ack repeat, and a crash between step-8 commit and step 9 (restart sends the set-column create to `needs_reconciliation`; resolution finds nothing ordered and releases) all land on the owner's outcome.

Don't-build, on request: a tenants-row write in every create's step 8 adds contention on a row the admission pipeline also reads, and the step-1 read alone satisfies the owner's story in the brief. Counter: the owner's option text says Panel D "settles the exact error and race guard", and without the guard the second story (read active, suspension commits, purchase) buys a machine the fence must then cancel at the customer's fee and first unit.

---

**Other-bead overlap.** pv-ip7 (CNF-360 recoverable statuses) is adjacent to Q2 but distinct. Q1 and Q4 share CNF-202 and API-58 and should land in Q4-then-Q1 order. The API-63 recording-transaction lock order noted under Q2 is a separate pre-existing finding.

Final Q1: Q1-B; acceptability A ACCEPT, B ACCEPT, C ACCEPT, each conditional on landing with or after a Q4 form.
Final Q2: Q2-A; acceptability A ACCEPT, B CANNOT ACCEPT, N CANNOT ACCEPT.
Final Q3: Q3-A; acceptability N ACCEPT, A ACCEPT, B ACCEPT.
Final Q4: Q4-A; acceptability A ACCEPT, B CANNOT ACCEPT, C ACCEPT.

## Verbatim r83 answer — opus (Q1–Q3 context only)

# r83 Panel D: opus reading

Pin: `git rev-parse HEAD` returns `3109b5b44eae17e288cf52aaa976993bd8c5626c`. I read the brief and notes.md in full. A script I wrote under `tmp/opus/` compared all 35 pinned quotations with the pin: 34 matched exactly. The OPS-3 block contains a nested fence that the script couldn't parse, so I checked it by eye; it matches too. I ran no Lean, Nix or gate. I listed the panel directory once but didn't open any other reader's files.

**Rule 6.** I found no brief error that changes a question's premise, so nothing is voided. There are three minor label errors:
- The brief's "STO-8" label for the `operations` table. STO-8 is the tombstone rule at `05-persistence.md:498`; the table follows STO-8a. Q3-B repeats this as "STO-8's resolution row".
- Q1-A says "WIR-10's operation-kind set". The kind enum is WIR-10a's (`13-wire-contract.md:271`).
- "Its paragraph beginning 'A create that has produced no machine yet'" is a line inside a paragraph (`04-api-contract.md:661`). It's still easy to find.

No vote below depends on any of these.

---

## Q1: pv-gvc

**Who owns the release.** LDG-32 already owns the duty. It requires release "on **every** terminal outcome: … the create fails deterministically" (`12-billing-and-ledger.md:310–313`). The administrative transition is a deterministic, terminal `failed` with no provider contact. API-63 reads it the same way: "close and release its commitment, exactly as `API-58` step 4 does for a suspension" (`04-api-contract.md:1376–1377`). So asserting the release tests an existing duty; it isn't a new requirement.

What no text covers is the **transaction shape** of the administrative write. STO-3's rule, "The guarded status write precedes every money write in the transaction and short-circuits the rest", sits only in the worker branch. The fifth bullet (`05-persistence.md:64–72`) has no money clause. That leaves "release, then the guarded write" or a two-transaction build permitted. Q1-B is the only form that makes the shape normative. Its generation-check → LDG-35 → status → release order matches STO-3's worker entry order. That is the difference between test and requirement here.

**Which bad writes each form catches:**

| Bad write | Q1-A | Q1-B | Q1-C |
|---|---|---|---|
| Origin term deleted (system cancellation; operator API-64 retry) | caught | caught | caught |
| Parent-unsettled term deleted (settled parent; stale old parent after resume and re-suspend) | caught | caught | caught |
| Lost claim race (both orders) | caught | caught | caught |
| Kind filter that handles only power | caught | caught | caught, through its create and install cases |
| Create release missing | caught | caught | caught |

Q1-C misses a filter that drops `refresh`, `rescue_inventory`, `reverse_dns` or a caller `delete_machine`. STO-3's predicate has no kind term, so A/B's every-kind loop is the complete form.

None of the three forms forces a **create** into the "status running under a real claim" fixture. With a power operation there, a release-before-guard bug still passes. That's a coverage weakness, not a blocker.

**Separate problem: the prose and the printed guard disagree for a deferred operation.**
- API-58 says "`queued` but never claimed" (`04-api-contract.md:628`), and STO-3's bullet says "was never claimed".
- But the guard has no claim term: `(id, status = queued, requested_by = caller, …)` (`05-persistence.md:64–67`).
- The sibling guard in API-63 carries `claim_number = 0`, and its note says "Queued eligibility still requires never claimed, including after a defer" (`04-api-contract.md:1386, 1400`).

A fixture that breaks it:
1. A caller `provider_catalogue` install is claimed (claim number 1).
2. It yields, because RSC-41 says the operation "MUST import and poll the provider … while **yielded**" (`06-rescue-install.md:504`).
3. The suspension's system delete holds the machine, so clearing `yielded_at` is refused and the install defers to `queued` (`03-operation-lifecycle.md:213`).
4. Step 4's printed guard then fails it as `tenant_suspended`, and the record says "it has touched no provider" although the import did.

None of A/B/C changes or tests this. That's right: a test-only form shouldn't silently change the guard. It needs its own bead.

**How the three paths differ.**
- The store administrative write affects only `queued` rows.
- In the worker race, the pass reads C as queued, a worker claims it, and the administrative write affects zero rows. The worker then settles C (under Q4, by the tenant refusal).
- A dispatched order is never `queued`, so the administrative write can't reach it.

**Coordination with Q4.** All three Q1 forms say "follows OPS-43's tenant-status refusal". That's true only after a Q4 form lands, so Q1 must land with Q4 or after it.

**Formal scope.** `Claim.lean:17` omits "`API-58`'s fan-out transition (`pv-vwe.6`)". The LDG-32 declarations model release arithmetic, not which outcomes trigger it. No Lean change is needed.

**Strongest don't-build argument (requested; not my vote).** CNF-202 already exercises the path that's actually reachable. A fixture like "tenant active, parent unsettled" can't be reached through the API, because WIR-41 fences resume. Store-level cases pin SQL rather than observable behaviour. My answer: STO-3's predicate is itself normative. API-58 records that on 2026-09-05 a paraphrase dropped the `requested_by` term and let step (4) fail a system delete. Only a test of each term separately catches that.

**Follow-ups.**
- The deferred-operation guard bead above.
- The administrative `tenant_suspended` failure states no `retryable`; align it with Q4's value.
- An install failed this way must carry `disk_effect`/`rescue_exit` "whatever the kind" (WIR-9a); assert `none`.
- Assert that STO-58's exclusion is freed for an administratively failed resource-offer create, as #47 does elsewhere.
- Use a create in the claimed-running negative fixture.
- Add STO-3, LDG-32, LDG-39 and OPS-43 to CNF-202's citation list, plus the dated amendment note.
- Overlaps with other beads: pv-kv2 (Q4), pv-shub (exclusion fixture).

**Votes.** Q1-A ACCEPT · Q1-B ACCEPT · Q1-C ACCEPT (weaker). **Preference: Q1-B.**

---

## Q2: pv-bxh

**The premise holds; Q2-N cannot stand.**
- API-63's admission clause states no `retryable` (`04-api-contract.md:1407–1409`).
- WIR-9a's rows depend on the "collection-snapshot `STO-47` status" (`13-wire-contract.md:172–173`). In this race that status is `healthy`, so neither row applies.
- API-7's false is "specific to the resource-offer guard" (`:302`).
- WIR-9b only combines collected tail entries.

No existing clause yields a value, so two engines can disagree, as the bead's example shows.

**How Q2-A works.** A zero-row UPDATE returns nothing. Q2-A names how to keep the status: `SELECT … FOR UPDATE` returns the account row's current committed status and locks it. The guarded write then misses that same locked version, and the response keeps the locked status. A concurrent recovery waits on the row lock until the admitting transaction rolls back.

**Lock order.** The collection is taken "from one read-only snapshot inside the existing `LDG-35` transaction, without an extra lock" (`:263–264`), so the account lock must come after collection. The order is LDG-35 → collection → account row → commitment. Those are the same lock objects in the same order as the base's conditional UPDATE, which already holds that row lock until commit. Q2-A adds no new lock order.

**Transaction errors.** Q2-A rightly refuses to turn a serialization failure into this refusal. One caveat: under an isolation level that raises a serialization failure on the concurrent update, the zero-row path is never reached. The api doesn't repeat transactions ("a failed request transaction is the caller's `internal` error", `03-operation-lifecycle.md:1941`), so the fixture couldn't get a 409. The base API-63 ("where that write affects no row") and CNF-278 already make the same assumption. A fixture precondition note fixes it; I don't count it against the form.

**Editorial issues in Q2-A.**
- The replacement deletes "so a create admitted after a termination is impossible … which is `OPS-42`'s shape". The next italic note, "called it the same shape", then has nothing to refer to. Restore it as rationale; no rule or test is lost.
- Putting the row in WIR-9a's "Purchase-tail entries" table could suggest the refusal carries `details.refusals`. The base is already ambiguous here; clarify it.

**Q2-B is blocked by DOM-17**, which says "`retryable` describes whether repeating the *same request* is safe and sensible" (`01-domain-model.md:656–658`). A concrete case:
1. The collection reads `healthy`.
2. An operator records `account_unreachable`.
3. The guarded write misses, and Q2-B answers `false`.
4. The identical request 1 ms later is refused by the tail with WIR-9a's `true`, "The named account can recover" (`13-wire-contract.md:172`).

Same status, same request, opposite advice, decided purely by timing. After recovery, repeating the request succeeds, so `false` is a wrong description. It also contradicts the worker's step-8 mapping for the same status (`state` → `true`).

**Snapshot versus locked status.** The healthy collection snapshot is what T1 read. The locked refusing status is what T1's FOR UPDATE sees after T2 commits. I found no breaking interleaving for Q2-A under read-committed semantics.

**Formal scope.** `Admission.lean`'s `account_retryability` covers only the collection snapshot ("does not model status persistence or the transaction collecting the snapshot"). `AccountStatus.lean` omits "its contention with admission on the account row". Q2-A sits outside the model; no Lean change.

**Strongest don't-build argument (requested; not my vote).** Nothing commits on this path, the window is milliseconds, and a constant `false` is conservative. My answer: DOM-17 requires a determinate, truthful value, and two engines disagree today.

**Follow-ups.**
- The fixture note on isolation level.
- The restored rationale.
- Whether this refusal carries `details.refusals`.
- A possible pre-existing lock inversion: admission takes LDG-35, then the account row. Termination writes the status first (`04-api-contract.md:1367`), then holds the affected tenants' LDG-35 locks (`:1457`). This needs checking; it doesn't affect the vote.
- pv-ip7 is a separate bead.

**Votes.** Q2-A ACCEPT · Q2-B CANNOT ACCEPT · Q2-N CANNOT ACCEPT. **Preference: Q2-A.**

---

## Q3: pv-y0to

**The automatic path already exists.**
- **Owner and trigger.** OPS-27: "The system MUST attempt automatic resolution before asking a human" (`03-operation-lifecycle.md:555–556`), in the section whose flowchart opens with the non-create branch (`:505–513`). OPS-3 says resolution transitions "are made by no worker — by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb" (`:95–96`), including "resolved applied (non-create)" (`:107`). And "`OPS-27`'s evidence sweep is itself automatic and does move the state" (`:76`).
- **Module.** OVR-17 assigns OPS-27's resolution sweep to `engine` (`00-overview.md:295`).
- **The read, per kind.** PRV-29: "resolution MUST proceed by reading authoritative, non-mutating provider evidence" (`02-provider-contract.md:422–424`). The descriptor declares `evidence_sources` "per mutation kind" (`:82`), ranked by PRV-36.
- **When the window starts.** PRV-36: "`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from the end of the mutating call's wait" (`:1143–1144`). This names OPS-27 as the reader of non-create evidence.
- **Cadence.** OVR-19: "for a resolution-pending mutation, once its effective visibility window ends, its resolution read MUST be issued within that cadence" (`00-overview.md:445–447`). Its conformance item says "enforce the stated cadence" (`10-conformance-checklist.md:4178–4179`).
- **Settlement guard.** STO-3's `(id, status = needs_reconciliation, resolution IS NULL)`, plus STO-19's write-once columns.
- **Operator fallback.** OPS-45: "falling back to `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot" (`03-operation-lifecycle.md:1522–1523`), with OPS-26's listing.
- **No mutation.** OPS-28 (`:914`). CNF-237 tests a delayed delete.
- **Provider-managed kinds** (power, reverse DNS, delete, release attachment, provider-native and catalogue installs) take the evidence path.
- **Rescue-based disk writes** can't be settled by provider evidence. Once the write marker is set, it rules out `not_applied` (`:1419`) and OPS-45 routes the operation to an operator. Seeing the machine still present proves nothing about the install.

The bead's sentence is true of PRV-29 alone, but the specification names the resolver elsewhere, so Q3-N's chain is complete. The real risk is how a builder reads it: OPS-27's body, and OVR-17's "It searches providers by correlator", both describe create only.
- **Q3-A** removes that risk with pointers and adds no behaviour.
- **Q3-B** adds duties: discovery on entry to the state, the resolving engine's identity, keeping a failed read eligible for a later pass, and applying OPS-31's refusal to automatic resolution. These are consistent today. But Q3-B copies OVR-19's MUST, PRV-36's window start and OPS-31's refusal into OPS-27, against AGENTS.md: "One rule, one home; everywhere else points at it."
  - It also cites "STO-8's resolution row", which is the wrong owner.
  - "Only on authoritative evidence for that attempt" can be read as narrowing PRV-36's resource read beyond the window, which resolves "not applied" without any anchor to the attempt.
  - The repair is to drop the copies, which leaves Q3-A.

**Pre-existing tension no form fixes (separate bead).** PRV-36's source 1, "The mutation endpoint's own report that the goal state already holds" (`02-provider-contract.md:1117`), and the flowchart's matching branch (`03-operation-lifecycle.md:509`) can only be obtained during resolution by sending the mutation again. OPS-28 and OVR-5 forbid that.

**Worked example.** A lost-reply delete on a driver that has only a resource read: the window opens at the deadline expiry, and the read is issued within the cadence once the window ends. A pre-mutation reading resolves *not applied*; a post-mutation reading resolves *applied*. I found nothing that breaks the chain. A build that implements only creates would fail CNF-237 and the cadence item.

**Formal scope.** `Reconcile.lean` models "what the system knows about the resource one create ordered". Non-create dispatch is outside the model; no Lean change.

**Strongest don't-build argument (requested; not my vote).** That argument is Q3-N: every piece exists, and Q3-A adds one more sentence that must track six owners.

**Follow-ups.** The source-1 bead. `tools/citation-baseline.json` has an unquoted-attribution entry for OVR-17; the manager's gate run should confirm Q3-A's row replacement doesn't alter that finding.

**Votes.** Q3-A ACCEPT · Q3-B CANNOT ACCEPT · Q3-N ACCEPT. **Preference: Q3-A.**

---

## Q4: pv-kv2 (mechanics only; the policy is fixed)

**Policy test.** Take a create first picked up while the tenant is suspended, so the suspension committed before the claim. The tenant read comes after the claim (step 1 in A/B, step 3 in C), sees `suspended`, and fails the create before any provider request.

An implementation could read inside a claim-transaction snapshot that predates the suspension. Even then, step 8's conditional write on the tenants row competes with API-58's flag write on that same row, affects zero rows, and fails the create.

So the leftover window, where a create is past the guard but hasn't reached the provider, holds only creates whose step-8 transaction committed before the suspension. All of those were claimed earlier. LDG-69 forbids holding a lock across the provider call, so the step-8 commit is the strictest race-free boundary available. It matches API-63's `about_to_order_at` approach. All three forms satisfy the owner's policy.

**Other mechanics I checked.**
- **Flag write.** API-58 step (1) writes `tenants.status` in its admission transaction, so the two writes really are on the same row.
- **Lost acknowledgement.** This mirrors OPS-43's existing account case: the earlier marker stays, OPS-11 classifies by the worker's position, and the worker's claim guard is kept.
- **Serialization failure.** It is repeated whole under OPS-49, then the guard is checked again.
- **Lock order.** Step 8 takes the account row, then the tenants row; the suspension takes only the tenants row. I found no new deadlock cycle.

**Does the existing "claimed before" sentence need replacing?** It isn't strictly contradicted, because a failure before purchase is still a settlement. But "its machine is then cancelled by the same sweep" assumes the claimed create buys, so the replacement is needed to keep API-58 coherent. Its "OPS-27's suspended-attach cancellation" is accurate: OPS-27 says it "applies at **all three** entry points" (`03-operation-lifecycle.md:646`), which includes the worker's own settlement.

One editorial fix: the replaced span starts inside `**fences work already in flight**`, so the closing `**` has to be moved.

**Retryable: `false` (Q4-A).**
- DOM-10's operator-controlled capability refusal carries `retryable: false` (`01-domain-model.md:519`).
- WIR-9a gives `insufficient_balance` `false` because "The caller must supply balance before purchasing" (`13-wire-contract.md:178`).
- A suspension is an operator sanction on the customer itself. Step 5b refuses the same request until resume, and WIR-41 doesn't allow resume while the suspension is still running.
- API-58 promises "nothing further can be bought" (`04-api-contract.md:733`).

Q4-B is defensible by analogy with recoverable account statuses, which get `true` even though an operator clears them. So it's acceptable, but not preferred.

**Placement: step 1 (A) over step 3 (C).** Under C, a suspended tenant's create on a closed ordering channel fails `rate_limited` with `retryable: true` and a retry interval (`13-wire-contract.md:175`). That invites a resend that step 5b will refuse. It also doesn't match the owner's "the worker sees the customer is suspended and fails the order". Both placements stop before spending anything, so C is acceptable.

**Coordinated edits the forms omit** (follow-ups, not blocking):
1. List the step-8 tenants-row conditional write in STO-6's store-primitive list and STO-27's (`05-persistence.md:137–142`). STO-27 explains why: an unlisted primitive is one a deployment could "silently lose" (`:957`).
2. API-58 step 4's administrative `tenant_suspended` failure states no `retryable`; align it with this value.
3. WIR-9a's `conflict` reason list credits `tenant_suspended` to API-58 alone (`13-wire-contract.md:141`); add OPS-43.
4. In Q4's CNF cases, assert STO-58's exclusion is freed for resource-offer creates.
5. Optionally clarify "nothing further can be bought" to cover the leftover window. The API-58 replacement already describes it.

**Formal scope.** Tables.lean keeps `suspended` admission-only, and these forms emit `conflict`, so they agree. Step 8 is outside the live model (`Restore.lean:35`: "`Live` has no step 8"). No Lean change.

**Timelines.**
- **Store administrative write:** an unclaimed create is still queued when the suspension's pass runs, so it fails through the Q1 path.
- **Worker settlement:**
  - Claimed at 10:02 after a 10:01 suspension: refused at step 1.
  - Claimed at 10:00:30, reads `active`, suspension at 10:01: the step-8 guard affects zero rows, so no marker commits and the create is refused.
- **Dispatched:**
  - Step 8 commits at 10:00:59, suspension at 10:01, provider call at 10:01:01: the order is potentially dispatched, and OPS-27 enqueues its cancellation at attach.
  - Lost acknowledgement, then suspension, then the repeat: the guard fails, the earlier marker stays set, and the create fails with no step 9.

I found no break.

**Strongest don't-build argument (requested; not my vote).** The plain read alone covers the owner's literal story. The tenants-row write adds contention on a busy row and a new primitive, and the remaining race costs at most one order that OPS-27 cancels. My answer: OPS-43 calls its own plain read "not a conditional-write guard", and API-63 records that under snapshot isolation "a read contends with nothing". The claim-snapshot case above lets a create claimed after the suspension buy.

**Votes.** Q4-A ACCEPT · Q4-B ACCEPT · Q4-C ACCEPT. **Preference: Q4-A.**

---

Final Q1: Q1-B; acceptability Q1-A ACCEPT, Q1-B ACCEPT, Q1-C ACCEPT; land with or after Q4, because all Q1 forms cite OPS-43's tenant refusal.
Final Q2: Q2-A; acceptability Q2-A ACCEPT, Q2-B CANNOT ACCEPT (DOM-17), Q2-N CANNOT ACCEPT (no existing value).
Final Q3: Q3-A; acceptability Q3-A ACCEPT, Q3-B CANNOT ACCEPT (copies rules owned elsewhere; the repair is Q3-A), Q3-N ACCEPT.
Final Q4: Q4-A; acceptability Q4-A ACCEPT, Q4-B ACCEPT, Q4-C ACCEPT; the owner's stop-before-buying policy is not re-voted.

## Verbatim r83 answer — astra (Q1–Q3 context only)

Verified HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c` and read notes.md whole. No files, Git state or tracker records changed; no builds, gates or subagents ran.

I found no verified brief error that changes a question’s premise. Under notes.md rule 6, I would not void any tally. The Q4 disclosure conflict below is a defect in the proposed bundles, not grounds for an additional void rule.

| Question | Exact printed form | Acceptability |
|---|---|---|
| Q1 | A | **ACCEPT** |
| Q1 | B | **ACCEPT — preferred** |
| Q1 | C | **ACCEPT** |
| Q2 | A | **ACCEPT — preferred** |
| Q2 | B | **CANNOT ACCEPT** |
| Q2 | N | **CANNOT ACCEPT** |
| Q3 | A | **ACCEPT — preferred** |
| Q3 | B | **ACCEPT** |
| Q3 | N | **ACCEPT** |
| Q4 | A | **CANNOT ACCEPT** |
| Q4 | B | **CANNOT ACCEPT** |
| Q4 | C | **CANNOT ACCEPT** |

**Q1.** All three coverage forms catch each specified defect:

| Defect injected | A | B | C |
|---|---|---|---|
| Delete the caller-origin predicate | System/operator negative fixtures fail | Same | Same |
| Delete parent-unsettled predicate | Settled/stale-parent fixture fails | Same | Same |
| Overwrite a successful claim | Claim-first fixture fails | Same | Same |
| Handle only power operations | Other positive kinds fail | Same | Create/install fail |
| Omit create commitment release | Nonzero commitment assertion fails | Same | Same |

C has narrower protection: a filter permitting exactly create, install and power could pass C while incorrectly excluding another caller-requestable kind. A/B derive coverage from the operation-kind owner instead.

Release is already an obligation. **LDG-32** says “A commitment MUST be closed, and its remaining amount released in full” and includes “the create fails deterministically” ([12-billing-and-ledger.md:310](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L310)). An administrative refusal of a never-claimed create satisfies that description. **LDG-39** supplies “Deterministic rejection before acceptance” → “Never debited” ([12-billing-and-ledger.md:1268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L1268)). Its later worker-specific inclusion does not exclude administrative failures.

Consequently, A/C can add release assertions without inventing a new release policy. I prefer B because it additionally specifies administrative atomicity and ordering: generation check, tenant money primitive, guarded status write, release only if that write wins. Those mechanics are stronger than merely asserting the eventual release. They leave LDG-32 as the owner of what is released.

The Q1 worker sentence must be coordinated with Q4: the pin does **not** already contain the tenant-status refusal it references. My acceptance is of these unchanged coverage bundles in this explicitly coordinated round; none independently implements the pickup policy.

There is an additional, genuine source problem. **STO-3** says “still `queued` and was never claimed,” but prints a predicate without a never-claimed term ([05-persistence.md:64](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L64)). Concrete fixture: a caller catalogue install was claimed, yielded, then deferred when reacquisition failed; it is now queued with a nonzero claim number. **OPS-8** expressly permits “`running` back to `queued`” ([03-operation-lifecycle.md:218](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L218)). With a suspended tenant and unsettled parent, the printed administrative predicate matches that row despite the prose exclusion. None of A/B/C fixes or independently tests this discrepancy. It requires a separate coordinated API-58/STO-3 amendment, not a silently enlarged test-only bundle.

For the intended never-claimed fixtures, I found no further breaking interleaving. Administrative failure, worker settlement under its claim, and dispatched-order resolution remain distinct. Preserve CNF-202’s existing held-power case and origin assertions.

**Q2.** A supplies the missing decision input and advice. Its locking read obtains the account status before the conditional write; retaining that value avoids pretending that a zero-row UPDATE returns the refusing row.

The ordering agrees with **API-63**: “It MUST also contend with admission on the account row itself, and that ordering comes first” ([04-api-contract.md:1406](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1406)). Acquire that account-row lock before commitment-opening work and its LDG-35 primitive. This does not substitute the account lock for tenant money serialization.

A also correctly distinguishes transaction failure from status refusal. It does not authorize an API implementation to adopt the engine’s retry loop: **OPS-49** says “`api`’s components do not run this loop” and “a failed request transaction is the caller’s `internal` error” ([03-operation-lifecycle.md:1940](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1940)).

The decisive interleaving is:

1. Collection snapshot is healthy.
2. `credentials_rejected` commits.
3. Admission locks that status and refuses.
4. Recovery attempts to update the same row.
5. After admission releases its lock, recovery commits.

The response still describes step 3. It does not reclassify from the healthy collection snapshot or a later recovery.

B’s concrete failure is the recoverable refusal above. After credential repair, the unchanged purchase can succeed without any earlier purchase effect. Giving it permanent-stop advice merely because the change occurred between collection and admission has no corresponding safety distinction. **DOM-17** defines retryability as whether repeating “the same request is safe and sensible” ([01-domain-model.md:655](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655)); WIR-9a’s recoverable-status rationale is “The named account can recover.” I reject B rather than importing the resource-offer exclusion’s unrelated false value.

N fails its own acceptance condition. WIR-9a’s existing rows explicitly use “collection-snapshot” status, while API-63’s admission guard gives no retryability value or retained refusing status. The worker mapping concerns an existing operation and cannot silently fill this HTTP-admission gap.

A is the complete acceptable alternative to B/N; I propose no repairs to A. Its API-63, WIR-9a and CNF-278 edits are the required owner locations. Keep `pv-ip7`’s worker step-8 cases separate.

**Q3.** The existing chain is executable, although unnecessarily difficult to follow:

- **Discovery:** OPS-25 requires pending records to be “retained until they are resolved” (`03-operation-lifecycle.md:2076`). OVR-19 requires that, for a resolution-pending mutation, its read “MUST be issued within that cadence” (`00-overview.md:443`). Together these require discovery of retained eligible work, including after startup; they do not require a particular notification mechanism.
- **Component:** OVR-17 assigns “`OPS-27`’s resolution sweep” to “`engine`” (`00-overview.md:295`). OPS-3 identifies resolution transitions as made by that sweep or an operator, “by no worker” (`03-operation-lifecycle.md:95`).
- **Dispatch:** PRV-29 requires “authoritative, non-mutating provider evidence anchored to the machine’s known `external_id`” and, where available, the attempt (`02-provider-contract.md:422`). OPS-45 explicitly routes resolution through that evidence path and then operator fallback (`03-operation-lifecycle.md:1521`). The diagram corroborates this routing; it is not the sole assignment.
- **Timing:** PRV-36 starts the window at “the end of the mutating call’s wait,” including deadline expiry, and says resolution “MUST NOT take its first read before the window has elapsed” (`02-provider-contract.md:1142`). OVR-19 bounds the subsequent dispatch delay.
- **Settlement:** STO-3 supplies `(id, status = needs_reconciliation, resolution IS NULL)` (`05-persistence.md:59`); OPS-3 supplies the applied/not-applied transitions; STO-19 requires write-once evidence.
- **Fallback:** OPS-45 says “falling back to `OPS-31`’s `applied`/`not_applied`/`abandoned` where it cannot” produce evidence (`03-operation-lifecycle.md:1522`).

For provider-managed mutations, use the declared per-kind history/resource evidence and PRV-36’s ranking. For rescue disk writes, ordinary machine presence establishes neither installation completion nor non-application. **OPS-31** says “`not_applied` MUST be refused” for the named rescue install strategies with a set write-started marker (`03-operation-lifecycle.md:1417`). A read-only resolution pass cannot boot rescue, finish installation, or end rescue to manufacture evidence.

Adversarial fixture: an ambiguous delete’s resource read still shows presence inside the window; later an operator resolves it before the sweep’s settlement transaction. The existing window and write-once guard reject both premature non-application and overwriting the operator. A/B preserve those protections; I found no breaking trace for either.

N is therefore acceptable. I prefer A because it makes the existing component/path connection explicit and scopes the correlator table to create. It adds no new outcome or permission to mutate. B additionally mandates particular discovery occasions, later-pass eligibility and broader conformance coverage; those are acceptable strengthening, but not evidence that the pin lacked an automatic path.

**Q4.** The proposed transaction boundary satisfies the fixed pickup policy. On otherwise passing inputs, a create first picked up while suspended fails before List offers, key upload, order or debit. If the earlier read sees active but suspension wins the same-row dispatch guard, it also fails before purchase. A claim alone grants no dispatch permission.

A/B precedence is account → tenant → channel → existing validation sequence. C instead gives channel closure precedence over tenant suspension. Both placements prevent buying; I prefer A’s earlier tenant check and false advice while the deliberate suspension remains in force. B’s true advice does not itself authorize an automatic service retry, so I do not treat that choice as a policy reversal.

Lost acknowledgement is handled correctly: repeat the whole transaction, recheck suspension, retain any earlier committed about-to-order column/correlator, and classify the live worker’s recorded pre-step-9 failure without a null-column condition. **OPS-11** says such a failure “MUST settle `failed`, whatever its kind” (`03-operation-lifecycle.md:249`). A crash in that interval remains a different recovery case.

The blocking defect shared by all printed forms is another sentence in API-58. Following “nothing further can be bought,” the pin requires:

> “The terms and the operator documentation MUST say so in those words”

— **API-58**, [04-api-contract.md:732–734](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L732).

Concrete trace: step 8 commits and is acknowledged while active; suspension commits; step 9 orders; the provider accepts; settlement attaches and cancels. Every Q4 form expressly permits this trace while retaining that mandatory unqualified public promise. The promise must be amended together with step (2). This is a substantive disclosure correction, not editorial cleanup or a stricter last-millisecond guard.

Replacing the “claimed before” sentence is also warranted: **API-58** currently says a create “claimed before the suspension landed MUST be allowed to settle” (`04-api-contract.md:623`). The new text must identify dispatch authorization, while preserving deterministic worker failure and OPS-27’s “that same transaction also enqueues a system cancellation” at suspended attachment (`03-operation-lifecycle.md:642`). It must not extend the create refusal to installs, power or system cancellations.

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
and is not a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any
per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```

**Formal scope and follow-up.** No existing declaration I read needs its statement weakened or changed for these mechanics. `Claim.lean:15–18` explicitly omits the administrative transition and resolution writes. `Funding.reap_refuses_active` concerns deletion of funded tenants; `Fence.suspend` enqueues cancellation on an existing machine. `Ledger.close_releases_exact_remainder` establishes release arithmetic, not the administrative trigger. `AccountStatus.lean:13–20` omits admission contention. `Reconcile.lean` models one create’s knowledge, not this dispatcher. The indexed OVR-19 declarations concern the outage setting, not resolution-read scheduling. `Tables.create_before_step9_failed` remains applicable and unchanged.

Required landing owners are those named in the selected bundles. Preserve CNF-197’s distinct resolution guard, CNF-237/CNF-329’s evidence timing, CNF-278’s separate admission/worker barriers, and existing resource-offer exclusion release coverage. Q1/Q4 overlap at API-58 and CNF-202; `pv-ip7` concerns worker account failures, not Q2 admission advice. The deferred-operation predicate discrepancy needs its own precise owner amendment. I inspected no other panel outputs.

**Requested strongest don’t-build arguments — separate from my votes:**

- **Q1:** LDG-32 already requires release, so test-only A suffices unless atomic administrative ordering is itself being specified.
- **Q2:** Constant advice avoids another status-bearing decision, but loses useful recoverable/permanent guidance on the concrete refusal above.
- **Q3:** The existing cadence, sweep ownership, evidence path and guards already impose the behavior; N is defensible.
- **Q4:** Attach-and-cancel already accounts for dispatched orders. It cannot replace the fixed refusal for first pickup while suspended. Removing the tenant dispatch guard admits the active-read → suspension → purchase race.

Final Q1: Q1-B; acceptability A ACCEPT, B ACCEPT, C ACCEPT.  
Final Q2: Q2-A; acceptability A ACCEPT, B CANNOT ACCEPT, N CANNOT ACCEPT.  
Final Q3: Q3-A; acceptability A ACCEPT, B ACCEPT, N ACCEPT.  
Final Q4: Q4-D as printed above; acceptability A CANNOT ACCEPT, B CANNOT ACCEPT, C CANNOT ACCEPT, D ACCEPT.
## Verbatim r83 answer — sol (Q1–Q3 context only)

I reviewed the printed r83 Panel D bundles against **3109b5b44eae17e288cf52aaa976993bd8c5626c** and read `notes.md` whole. My preferences are **Q1-A, Q2-A, Q3-A and Q4-A**.

| Question | Exact-form acceptability |
|---|---|
| Q1 | A **ACCEPT**; B **ACCEPT**; C **ACCEPT** |
| Q2 | A **ACCEPT**; B **CANNOT ACCEPT**; N **CANNOT ACCEPT** |
| Q3 | A **ACCEPT**; B **ACCEPT**; N **ACCEPT** |
| Q4 | A **ACCEPT**; B **ACCEPT**; C **ACCEPT** |

These are individual reader votes, not a settlement or authorization to implement.

**Q1 — prefer Q1-A.**

All printed forms catch the requested defects:

| Defect | A | B | C |
|---|---|---|---|
| Deleted origin term | System cancellation and operator retry fixtures | Same | Same |
| Deleted parent-unsettled term | Settled-parent and old-parent fixtures | Same | Same |
| Lost claim race | Both claim/write orderings | Same | Same |
| Filter handling only power | Other caller kinds | Same | Create and install |
| Missing create release | Nonzero commitment and fee/unit assertions | Same | Same |

C catches the specifically named **power-only** implementation. It would not catch every omitted kind: an implementation handling precisely create, install and power could pass C. A’s coverage tied to the existing kind set is stronger without maintaining another representative list. The enum’s precise home is **WIR-10a**, “The closed enums,” at [13-wire-contract.md:271](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L271).

The existing release duty suffices to justify the release assertion. **LDG-32** already requires release on “the create fails deterministically” at [12-billing-and-ledger.md:310](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L310). **LDG-39** supplies the money verdict: “Deterministic rejection before acceptance” is “Never debited; released with the commitment” at [12-billing-and-ledger.md:1268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L1268). Administrative refusal before provider contact satisfies that description; it need not become a worker classification to qualify.

B remains acceptable. Its useful addition is **explicit atomic composition and ordering** of the administrative status write and release. That is stronger local machinery than merely adding coverage for the existing release outcome. I do not require that additional obligation to accept A’s tests.

The concrete fixture is a queued system cancellation beside caller work, under a suspended tenant and unsettled parent. Removing only `requested_by = caller` must change its administrative-write result from zero to one. For the worker race, claim first must leave the administrative write at zero; the worker may subsequently fail its own create under the separately settled Q4 mechanics. That worker failure must not be mistaken for administrative race loss.

There is an additional, pre-existing predicate problem. **API-58** says “queued but never claimed,” while its quoted “full predicate” omits a never-claimed term at [04-api-contract.md:628](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L628) and [04-api-contract.md:643](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L643). **STO-3** repeats the mismatch at [05-persistence.md:64](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L64). A caller catalogue install can be claimed, yield during import, defer, and return to `queued` with a positive claim number. The printed predicate admits it despite the prose. None of these fresh, never-claimed fixtures repairs or detects that problem. It needs a separate coordinated owner amendment; I have not silently added `claim_number = 0` here.

Q1’s worker-race expectation must land alongside an accepted Q4 mechanics form. It is not evidence that pinned **OPS-43** already contains a tenant-status refusal. Preserve CNF-202’s held-power scheduling case and its existing origin assertions.

*Strongest don’t-build argument, requested; not my vote:* the generic store predicate makes exhaustive kind fixtures look repetitive. C is a defensible smaller regression bundle. It still leaves selective omissions that A catches; existing CNF-202 does not independently reject the named negative guard writes.

**Q2 — prefer Q2-A.**

A identifies the refusing status without inventing information in an UPDATE result: it first locks the account row, retains that locked status, and classifies before releasing it. A zero-row guarded UPDATE alone returns no refusing row.

The healthy collection snapshot and refusing status have different jobs. The snapshot permits the earlier tail to pass; the locked non-healthy status determines this later refusal. **WIR-9a**’s existing rows expressly say “collection-snapshot” at [13-wire-contract.md:171](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L171), so they cannot supply the later input by themselves.

A preserves the existing ordering requirement, **API-63**’s “contend with admission on the account row itself, and that ordering comes first,” at [04-api-contract.md:1406](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1406). Its row lock supplements rather than replaces the conditional write. It also preserves the money primitive: **LDG-35** requires “The authorization read and the commitment write MUST be serialized per tenant” at [12-billing-and-ledger.md:431](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L431). No provider call belongs under that money hold.

Serialization failure must remain a transaction failure, not fabricated evidence of an unhealthy status. In particular, **OPS-49** says “api’s components do not run this loop” and calls a failed request transaction the caller’s `internal` error at [03-operation-lifecycle.md:1940](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1940). A does not import the engine’s retry loop into admission.

**Q2-B blocker:** consider a healthy snapshot, then `account_unreachable` winning before admission’s final guard. Admission commits nothing; the same named account subsequently recovers. Repeating the unchanged purchase is safe and can succeed. B nevertheless requires false solely because the failure occurred at the later barrier. **DOM-17** defines `retryable` as whether repeating “the same request is safe and sensible” at [01-domain-model.md:655](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655). The concrete recovery supplies both properties. Merely naming this a “distinct refusal” supplies no changed request or side effect explaining opposite advice. This is my technical ruling on the proposed mapping, not a claim that the pinned snapshot rows already govern it.

**Q2-N blocker:** no cited pinned clause supplies both a determinate value and its race-free input for the healthy-snapshot case. **API-63** requires `conflict/state` when the admission write affects no row at [04-api-contract.md:1407](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1407), without specifying retryability there. **API-7** explicitly says its constant-false response “is specific to the resource-offer guard” at [04-api-contract.md:298](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L298).

The concrete adversarial trace is: healthy snapshot → recoverable status → locked refusal → concurrent attempted recovery → rollback/unlock → recovery succeeds → response retains the captured decision’s value. A handles it; no breaking interleaving found.

The complete alternative to B and N is **the printed Q2-A bundle unchanged**, at its stated API-63, WIR-9a and CNF-278 locations. I propose no repaired hybrid. This remains an HTTP admission response with no existing operation view.

*Strongest don’t-build argument, requested; not my vote:* constant false avoids retaining status and adding an explicit locking read. That simplicity costs accurate guidance for the concrete recoverable refusal above.

**Q3 — prefer Q3-A; Q3-N is sufficient.**

The existing automatic path is real:

- **Discovery/trigger:** **OPS-27** says “The system MUST attempt automatic resolution before asking a human” at [03-operation-lifecycle.md:555](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L555). **OVR-19** quantifies the achieved read duty over a “resolution-pending mutation,” rather than only creates.
- **Component:** **OVR-17** assigns “OPS-27’s resolution sweep” to `engine` at [00-overview.md:295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L295). The row’s correlator explanation is incomplete for non-creates; it does not exclude them.
- **Identity and dispatch:** **PRV-29** requires authoritative non-mutating evidence anchored to the known `external_id` and, where available, the attempt at [02-provider-contract.md:421](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L421). **PRV-36** requires evidence sources “Per mutation kind” at [02-provider-contract.md:1114](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L1114).
- **Timing:** **PRV-36** starts the window at “the end of the mutating call’s wait,” including deadline expiry, at [02-provider-contract.md:1142](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L1142). **OVR-19** requires the read “MUST be issued within that cadence” at [00-overview.md:443](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L443).
- **Settlement:** **STO-3** supplies `(id, status = needs_reconciliation, resolution IS NULL)` at [05-persistence.md:59](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L59); **STO-19** requires write-once evidence.
- **Fallback:** **OPS-45** explicitly directs resolution through provider evidence “where the driver can produce it,” falling back to the operator verbs “where it cannot,” at [03-operation-lifecycle.md:1521](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1521).

A periodic scan of retained unresolved rows is an executable way to satisfy that universal cadence duty, including rows surviving restart. The specification need not prescribe a helper name or require one particular discovery implementation.

For provider-managed mutations, dispatch the declared action/history or resource evidence for that mutation’s goal. Preserve source ranking and the distinction between mutation completion, disappearance and billing stop.

For rescue disk writes, ordinary machine presence establishes neither installation completion nor non-application. **OPS-45** says a set destructive marker means preservation “is no longer proven, not that a byte landed” at [03-operation-lifecycle.md:1525](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1525). Without truthful evidence for that attempt, use operator fallback; do not boot or end rescue during the evidence pass. The diagram’s “still present” label cannot be generalized into an install-completion test.

A clarifies the existing linkage and scopes the correlator table, making it my preferred documentation repair. B is acceptable but adds explicit discovery obligations and broader running-engine conformance assertions. Those are more than a missing pointer. N remains acceptable because the combined existing obligations already require the path.

Adversarial trace: an ambiguous delete’s resource read still shows the pre-delete state inside the visibility window. It remains pending; after the window, authoritative evidence can resolve it. A pending power mutation cannot instead be resolved merely because the machine remains present. No breaking interleaving found for A, B or the properly interpreted existing chain.

*Strongest don’t-build argument, requested; not my vote:* choose N. The achieved cadence, automatic sweep, evidence contract and fallback already impose the behavior. A improves discoverability without requiring another resolver.

**Q4 — prefer Q4-A.**

All printed forms implement the fixed pickup story: the early tenant check refuses before List offers, key upload or ordering; a create that observes suspension there never reaches step 8’s residue case.

A/B establish precedence **account → tenant → channel → boundary validation**. C establishes **account → channel → tenant → boundary validation**. C still stops purchase when an earlier channel refusal wins. At step 8, all forms retain account guard before tenant guard and operation-row guard, with the generation check first under **OPS-50**, “MUST read STO-59’s row FOR SHARE as its first statement” at [03-operation-lifecycle.md:1996](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1996).

The critical interleavings are correctly separated:

1. Administrative failure wins against an unclaimed operation: no worker dispatch.
2. Claim wins: the administrative write affects zero rows; that worker still performs its own refusal checks.
3. Early tenant read sees active, suspension wins before the tenant dispatch guard: rollback and deterministic worker failure.
4. Dispatch transaction wins before suspension: potentially dispatched; preserve settlement and suspended-attach cancellation.
5. Step-8 commit loses its acknowledgement, suspension defeats the repeat: no speculative step 9; record the known pre-step-9 failure while retaining committed correlation data.

The fourth case respects the fixed owner policy: it concerns a create already authorized for dispatch while active, not one first observing suspension at pickup. A stricter zero-gap provider guarantee is neither supplied by these forms nor required by the owner’s quoted pickup decision. **LDG-69** prohibits waiting on “any provider call” while holding the money primitive at [12-billing-and-ledger.md:463](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L463).

The lost-acknowledgement exception is essential. **OPS-11** says a worker-recorded failure before any step-9 request “MUST settle failed, whatever its kind,” and forbids using `about_to_order_at` to decide that classification at [03-operation-lifecycle.md:249](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249). A set timestamp therefore does not justify retaining the commitment after this known refusal.

I prefer false for the suspension refusal because it communicates the operator’s stop-serving decision. B is nevertheless acceptable: true can describe safe caller reissuance after authorized resume; it grants no automatic service retry. No pinned clause assigns a contradictory fixed value to `tenant_suspended`. This differs from an unresolved dispatched order, whose retryability remains false.

The API-58 replacement is appropriate: the old phrase “a create claimed before the suspension landed” at [04-api-contract.md:623](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L623) does not identify the dispatch authorization boundary. The detailed exception also qualifies API-58’s “nothing further can be bought” promise; that promise cannot truthfully mean that already authorized in-flight purchases vanish at suspension. I require no additional owner edit beyond the printed coordinated replacements.

Keep **OPS-27** unchanged: “Where the machine’s tenant is suspended at the moment of the attach, that same transaction also enqueues a system cancellation” at [03-operation-lifecycle.md:642](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L642). None of this creates tenant-status refusal rules for power, install or system cancellation.

*Strongest don’t-build argument, requested; not my vote:* existing attach-and-cancel handles resource accounting. It cannot satisfy the fixed policy for a create picked up under suspension, so it cannot replace the early refusal and dispatch guard.

**Follow-up scope and formal limits.**

The landing owners/assertions are those in the accepted bundles: CNF-202 for Q1/Q4; API-63, WIR-9a and CNF-278 for Q2; OPS-27/OVR-17 for Q3-A, with CNF-237 additions only if B is selected. Preserve existing exclusion-release coverage. The supplied `pv-ip7` overlap concerns worker recoverable-status coverage, not Q2’s admission response.

No current declaration models the new administrative predicate or tenant dispatch protocol. **Claim.lean** explicitly omits “API-58’s fan-out transition” at [Claim.lean:15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Claim.lean#L15). **Admission.lean** carries snapshot collection and says it “does not … execute a write” at [Admission.lean:42](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L42); its `account_retryability` theorem remains snapshot-specific. **Reconcile.lean** describes knowledge about “one create” at [Reconcile.lean:2](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Reconcile.lean#L2), not a non-create scheduler. Existing exact-remainder release declarations are unchanged. No new formalism is a condition of these votes.

Applying **notes.md rule 6 exactly as written**, I found no verified brief error changing a question’s premise. The never-claimed predicate mismatch is an additional source defect the brief explicitly asks readers to identify. The corrected brief does not rely on the raw bead’s obsolete implication that CNF-202 lacks origin assertions or that the specification lacks every automatic non-create path.

The clone remains clean. No files, tracker records or panel records changed; no gates, builds, subagents or background work ran.

Final Q1: Q1-A; acceptability A ACCEPT, B ACCEPT, C ACCEPT.  
Final Q2: Q2-A; acceptability A ACCEPT, B CANNOT ACCEPT, N CANNOT ACCEPT.  
Final Q3: Q3-A; acceptability A ACCEPT, B ACCEPT, N ACCEPT.  
Final Q4: Q4-A; acceptability A ACCEPT, B ACCEPT, C ACCEPT.