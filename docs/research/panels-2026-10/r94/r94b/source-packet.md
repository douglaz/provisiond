# Historical owner authority and pinned sources


Source: /var/tmp/provisiond-manager/owner-decisions-1030.md, items 3 and 19 (historical owner record, not new requirements at the pin).

### owner-item3.md

3. **pv-kv2** — Q: "When a suspended customer's queued order is first picked up after the suspension, what should
   happen?" A: **"Stop before buying (Recommended)"**. Option text shown: "At pickup the worker sees the customer
   is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles
   the exact error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a
   policy choice."
   - Story shown first: a customer queues a server order at 10:00, you suspend them at 10:01, a worker first
     picks the order up at 10:02; today's text lets it buy, charge the setup fee and first billing unit, then
     enqueue a cancellation that can itself fail.
   - Rejected: "Buy, charge, then cancel".
   - Decision homes (triage-1027 row): `API-58`, `OPS-43`; keep `OPS-27` for orders already dispatched. The
     refusal kind and race guard go to Panel D (r83).


### owner-item19.md

19. **pv-kv2 (Panel D r83b Q4, unsettled after its one consensus round: D preferred and accepted 3–1 by fable +
    astra + sol, opus rejects; A preferred by opus, acceptance 2–2; D's 3–1 blocked by a verified rule-3 loss (the
    positive duty to publish the existing-fleet warning); no panel recommendation; grok missing, 402)** — Q: "pv-kv2
    public terms (panel unsettled): explain the 'approved before suspension' exception, or keep today's exact words and
    warning?" A: **"D: explain exception"**. Option text: "3–1 pick (fable, astra, sol). Terms say an order approved
    before suspension may still complete. Drops the required public warning that existing servers may keep running if
    cancellation fails (opus's objection)." Rejected: "A: keep current words". Meaning: adopt exactly
    /var/tmp/provisiond-panel-r83/r83b/Q4-D.md, unchanged, under item 3 "Stop before buying (Recommended)"; the owner
    knowingly accepts the loss of API-58's positive publication duty for the existing-fleet warning (opus's dissent on
    record). No A/D combination, repaired D or partial D. pv-kv2 → ready-for-agent with item 3's Q1 package plus
    Q4-D.md; items 13 (pv-gvc) and 14 (pv-bxh) stand and land with or after it.


### owner-questions.md

# Q4 after its sole consensus round — main asks this one question

**TL;DR: Which exact reviewed wording should accompany the already-fixed stop-before-buying rule? There is no settled panel recommendation.**

A server order gets its final permission at 10:00, you suspend the customer at 10:01, and the provider accepts the order at 10:02. Both choices below keep that order recorded and send its server for cancellation. Both stop an order first picked up after suspension before buying or charging.

The remaining dispute is what the public terms must say. A keeps the current exact promise that nothing further can be bought. D explicitly explains the earlier-permission exception, but removes the duty to publish the warning that existing servers may still be running when cancellation fails. Keeping the warning only inside the spec does not require it in customer terms.

- **D: publish the earlier-permission exception.** Exact reviewed [Q4-D.md](Q4-D.md), unchanged. Preferred and accepted by fable, astra and sol; opus rejects. Preferences 3–1; acceptance 3–1. Fable values clearer disclosure and explicit error-order tests; astra and sol require truthful wording for the 10:00/10:01/10:02 case. Opus's verified objection: customer terms can omit the warning about pre-existing machines still running. This changes the strength of the public-disclosure obligation; it is beyond the already-delegated error and race guard. The tally has not settled or recommended D despite its numerical majority.
- **A: retain the current required public words.** Exact reviewed [Q4-A.md](Q4-A.md), unchanged. Opus's pick; fable accepts but prefers D; astra and sol reject. Preferences 1–3; acceptance 2–2. Opus argues that the detailed exception already qualifies the public promise, while keeping the existing positive fleet warning compulsory. Astra and sol argue that a permitted purchase completing after suspension still conflicts with the mandatory "nothing further can be bought" statement. Fable treats this disclosure tension as pre-existing and nonblocking. A's column-name/bold-anchor observations remain ordinary landing observations, not authorization for an added disclosure clause.

Every exact form has been read by every present seat. B/C have no current first preference and offer different retry advice or error order, not another resolution of the public-disclosure dispute; their full ballots remain in [tally.md](tally.md). No A/D combination, repaired D, partial D, or new promise is a reviewed option. No further consensus round is authorized. This is an unresolved choice under the owner's "a tie comes to you" instruction, not a claim that the preference tally itself is 2–2.

The complete dissent trace, verified quotes and source pin are in [check/tally-evidence.md](check/tally-evidence.md). The positive publication duty's loss is why notes rules 2/3 prevent treating D's 3–1 as settlement. Rule 6 voids nothing.

**IDs and prior decisions, last:** pv-kv2, API-58, OPS-43, CNF-202; retain OPS-27's dispatched-order attachment path. Owner-decisions-1030.md item 3 remains **"Stop before buying (Recommended)"**, with "Nothing is bought or charged" for first pickup under suspension. Items 13 pv-gvc **"B: say it explicitly (Recommended)"** and 14 pv-bxh **"A: tell them apart (Recommended)"** already stand; they are not re-asked. Approved pv-gvc lands with or after pv-kv2's resolved exact mechanics. No tracker or specification change has been made by this tally.

The owner's 2026-10-28 wording instruction, verbatim, is: "For such wording questions, try to solve by getting a consensus of the panel". The manager brief limits that exception to no behaviour, requirement or check-strength change, with settled exact forms. Each pick must separately classify those three dimensions; if substantive, it goes to the owner. No A/D combination, no new publication duty, no restoration of anything item 19 knowingly relinquished is authorized. r83b exhausted its consensus round on the substantive package; this distinct retained-rule wording question is in its first round r94. A split/unsettled r94 gets ONE r94b in a later turn.

## AGENTS rule and complete owning requirements

Every quoted source block below preserves the source bytes, including line breaks. Verify from your own clone. All four source files AGENTS.md, 03-operation-lifecycle.md, 04-api-contract.md and 12-billing-and-ledger.md are byte-identical at M and H; check/source-verification.json records this. Do not use the reply's reflowed display as the byte authority.

Source at M: AGENTS.md:29–32.

````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
````

Source at M: 12-billing-and-ledger.md:463–494, complete LDG-69.

````text
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

*The clause withdrawn on 2026-08-31 forbade a worker holding the machine from entering the primitive
at all, and then ordered the case it had just forbidden. Two independent reviewers found the
contradiction. It was written when nothing needed the nesting; `OPS-41` was added a week later and
is exactly a machine-holding worker that must read commitment state another transaction writes
under this primitive.*

**And the order alone does not make `OPS-41` correct** — which is the sharper half, and both
reviewers reached it independently. The window that matters is **between the read and the provider
call**, not inside the transaction: this requirement rightly forbids a provider call under the
serialization, so the worker must release it before mutating, and `LDG-62` can commit in the gap.
Entering the serialization changes nothing about that. `OPS-41`'s correctness rests on the fence
`OPS-42` specifies, not on this ordering.

**AMENDED 2026-09-02 — but the fence needs the nesting this requirement permits, so the permission
is now load-bearing rather than theoretical.** `OPS-42` requires `OPS-41`'s funding read and the
fence write to be **one** transaction under this primitive, taken by a worker whose operation already
holds the machine: without that, the extension commits between the read and the write, the fence
column is still null when the worker writes it, and the machine is destroyed anyway. So the
permitted direction above is exactly what the fence is built on, and the prohibition that matters is
the other clause: **the provider call happens after that transaction commits**, never inside it.
````

Source at M: 03-operation-lifecycle.md:1925–1994, complete OPS-49.

````text
**OPS-49** **ADDED 2026-09-12 (`ADR-0022`) — a store error is a bounded whole-transaction retry,
then the engine exits.** Where a store call by a worker, or by a periodic component running in
the engine process (`OVR-17`), errors or times out, the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`) — with
the provider's outcome retained in memory, for a stated bound (`OVR-19`), and on exhausting the
bound MUST log loudly and the engine MUST exit non-zero into its supervisor, where `OVR-18`'s
alarm is watching. A refused generation check (`OPS-50`) is not a store error and is never
repeated. `OPS-50` says "A mismatch is not a store error (`OPS-49`) and is never repeated."
The bound covers connection, execution, commit, read-back and backoff together, but
not a commit's wait for the standby (`STO-7`), and it is a money parameter: on exhaustion the
outcome in hand is thrown away and `OPS-15` classifies the row as interrupted — unless the
bound's last repeat committed and its reply was lost, in which case the row is already written,
the money already posted once, and the startup pass finds nothing `running` to classify (*the
formal layer's claim model exhibits this trace, 2026-09-14*). A periodic component whose
repeated write affects no row under a write-once guard — `STO-3`'s resolution write, `STO-52`'s
episode index — has seen its earlier attempt land, and moves on. **`api`'s components do not run
this loop**: a failed request transaction is the caller's `internal` error, and a failed credit
is `STO-31`'s next replay.

An attempt denied by `STO-55` admission is a store error for this loop and sends no SQL
(`STO-55`: "worker/periodic acquisition refusal is an `OPS-49` store error").

- **"Too slow" is `statement_timeout`.** The client-side deadline on a store call MUST NOT be
  shorter than `STO-7`'s server-side timeouts, so the server decides every statement's fate before
  the client does and the only lost reply is a dead transport, or a commit returned with
  PostgreSQL's replication warning (`STO-7`). A server-side timeout is a refused
  write, and the repeat finds the row unchanged; a lost reply after a durable commit is the case
  `STO-3`'s repeat-admitting guards exist for.
- **Constraint violations and serialization failures are not store errors** and do not consume
  the bound. A unique violation on a repeat is the repeat landing on its own earlier commit, and
  the guarded status write preceding the money writes short-circuits the rest (`STO-3`). A
  serialization failure is repeated at once. **A `lock_timeout` is a store error for this
  purpose**: on `LDG-35`'s primitive or on `STO-52`'s index it rolls back, releases the connection
  before any backoff, and repeats the whole transaction with the provider outcome retained,
  against this same bound — the symptom of a genuinely stuck store is indistinguishable at the
  client, and a lock timeout outside any bound is an unalarmed loop on a held primitive. *`ADR-0022`
  first said a lock timeout "do[es] not consume the bound" and said nothing about what the worker
  then does; `F51` decided this and the ADR carries the amendment.*
- **A lost reply on the claim itself is fatal, not retried blind.** The claim's returned row is the
  only way the engine learns what it claimed; a claim repeated after a lost reply strands a
  `running` row with no worker, which `OPS-15` says "nothing but a restart can" do. The engine
  exits and the startup pass classifies it.
- **A worker cancelled during the retry loop stops retrying and exits.** `OPS-21` says "A later stop, one arriving after the stop being recorded and before that record lands, ends the record as an exit without worker classification at any point: before the record's first transaction, during it, or while `OPS-49` repeats it; the worker MUST NOT repeat a record transaction already sent when that later stop arrives."
  `OPS-21` says "The record write MUST NOT be cancelled by the cancellation that stopped `execute`."
  A stop during a loop inside `execute` is that cancellation, not this exit: `OPS-21` says "A stop that arrives while a store transaction inside `execute` is in flight or repeating under `OPS-49`, such as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation being recorded."
  A first stop during an ordinary settle write's loop after `execute` returns is not this exit either: `OPS-21` says "A stop the engine survives that arrives after `execute` returns and before the worker's settle write lands MUST be recorded by that settle write, under the shielding below, and the Stop-record bound and exits that apply to a recorded cancellation."
  A later stop and exhaustion both leave restart recovery to `OPS-15`, whose
  ordinary rule is "the engine MUST move every `running` operation to `needs_reconciliation`",
  subject to its exceptions and the lost-reply case above. `OPS-47` says of a lost lock connection
“The loss is not a later stop”: a worker repeating a record when the loss is seen keeps
repeating it.
- **A suspension parent waiting on its children is deferred, not held** (*this bullet is `F51`'s,
  not `ADR-0022`'s*). A `suspend_tenant` parent (`API-58`) whose children are still queued MUST be
  returned to `queued` with `available_at` advanced — the same write as `OPS-8`'s defer, though
  nothing refused it — rather than occupy a worker while it waits; N parents waiting in N workers
  would leave no worker for the children they wait on. Its state while waiting is `queued`, which
  is why `STO-54`'s restore rule holds a `queued` parent for confirmation as well as a `running`
  one.

*Amended 2026-10-18 (`pv-tst`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): distinguished a later stop during the loop from the stop being recorded.*

*Amended 2026-10-18 (`pv-tst`; panel r58c, `docs/research/panels-2026-10/r58/r58c/`; `ADR-0044`): pointed a stop during a loop inside `execute` at `OPS-21`'s record.*

*Amended 2026-10-19 (`pv-zbp`; `ADR-0044`): pointed the first stop during an ordinary settle write's loop at `OPS-21`.*

*Amended 2026-10-20 (`pv-gq8`): replaced the loop-only later-stop definition with a quotation of the record owner's any-point exit.*
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S2′ “A: stop on time (Recommended)”; the lost-reply sentences of `STO-7` and `OPS-49` “Amend both (Recommended)”; `ADR-0045`): excluded a commit’s standby wait from the Store-retry bound, and made a commit returned with `STO-7`’s replication warning the second lost reply.*

*Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): distinguished generation refusal from store errors and retained recording on lock loss.*
*Amended 2026-10-28 (`pv-oehp`; `ADR-0045`; `STO-55`).*
````

Source at M: 03-operation-lifecycle.md:757–835, ordered create context.

````text
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
````

Source at M: 04-api-contract.md:623–738, suspension context.

````text
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
repeats until a pass finds no un-cancelled machine; then (5) aggregates the outcomes,
including any that end `needs_reconciliation`. **The parent then settles `succeeded`, with those
children named in its result** (`WIR-39`'s `cancellations`) — its own job was to fan out and
account for every machine, and it has done it. `OPS-11`'s `suspend_tenant` row already counts a
`needs_reconciliation` child as complete for the parent, and step (5) did not say what that makes
the parent's own outcome; it is `succeeded`, never `failed` and never `needs_reconciliation`. The
unresolved children are their own records, resolved by their own evidence or their own operator
verb (`OPS-27`, `OPS-31`), and read through `GET /v1/operations` like any other operation. Holding
the parent open until they resolve would fence `WIR-41`'s resume off indefinitely and leave every
suspended tenant with a record that never closes.
**A create that has produced no machine yet passes the re-sweep's test**, so settlement here is not
the last guard: where such a create later attaches a machine to a still-suspended tenant, `OPS-27`'s
one-transaction rule enqueues the cancellation in the attach transaction itself, under the same
`OPS-39` trigger step (3) uses. **A process that dies mid-fan-out MUST NOT strand
the suspension**: the engine's startup pass (`OPS-15`) returns an interrupted `suspend_tenant`
parent to `queued`, and it is re-claimed and resumed like any other queued work, because the sweep
is idempotent by the open episode (`STO-52`'s index) and mutates no provider itself. It MUST NOT go
to `needs_reconciliation` and, on a restart, MUST NOT need an operator — *after a restore it waits for one while `STO-54`'s freeze holds the exception off (`STO-54`, `OPS-15`), because the fan-out it would resume may have been reversed inside the
lost interval*. Reads of the ledger, the machine list **and the tenant's abuse
cases** (`API-59`) MUST continue
to work while suspended — the customer's history is their evidence, and `LDG-22` forbids purging
it anyway. *The case reads joined this list on 2026-08-16 for the same reason and one more: the
collection exists because a notice commonly arrives after the machine is gone, and a suspended
tenant is the likeliest holder of exactly that case.* `SEC-45`'s one-action termination is this verb; `API-34`'s deletion applies only to
**pending** tenants, which have no machines. They MAY hold a below-minimum credit, whose ledger
entries survive them (`STO-26`, `LDG-22`) and remain re-attributable through `WIR-42` — so
"no ledger" was wrong, and it is the case `API-34` exists to handle.

**AMENDED 2026-09-02 — "un-cancelled" is defined, and a deterministically-failed child no longer
hangs the fan-out.** The re-sweep's terminating condition was never defined, and the two readings a
builder could reach were both wrong. **A machine is *cancelled* for the purpose of step (4) when this suspension has already accounted
for it** — the fan-out enqueued a cancellation for it, whatever that cancellation then did —
**and *un-cancelled* otherwise.** The parent records the machines it has enqueued for, in
`WIR-39`'s `cancellations` result; the pass enqueues for every non-tombstoned machine of the tenant
that is not already named there, and terminates when a pass finds none. **Where `OPS-39`'s episode
is already open on a machine under the `delete` key** — an exhaustion episode that predates the
suspension, or the machine `OPS-27`'s suspended-attach clause enqueued for — the pass MUST NOT
enqueue, and MUST instead **append `tenant_suspended` to that episode's `reasons` set (`DOM-31`)
and name its `current_operation_id` in `cancellations`**, which is what "accounted for" means for
it. *Added
2026-09-05. Without this the pass could neither enqueue for such a machine — `OPS-39` forbids the
duplicate — nor name it, so every pass found it un-cancelled, the parent never settled, `WIR-41`'s
resume was refused forever and a worker slot was pinned for the life of the tenant.* **An operation
that `OPS-41`'s no-mutation abort settled does NOT account for its machine**, whatever list names
it: the abort closed the episode (`OPS-48`), so the next pass opens a fresh one and enqueues afresh
— **and replaces the aborted operation's id in `cancellations` with the fresh one's**, so the
per-machine result always names the child currently accounting for the machine rather than one
that settled without acting — which `STO-52`'s index permits precisely because the episode is
closed. *Added 2026-09-05 against the interleaving where the worker's re-check reads the episode
before the join appends `tenant_suspended`, finds the machine funded after a price cut, and aborts
— after which a pass that trusted the name would settle the parent over a funded fleet on a
suspended tenant.*

*The test is the parent's own record, not the episode row.* An earlier draft of this
amendment keyed it on an episode existing "open or already resolved", which fails in both
directions: `OPS-48` **closes** the episode on `abandoned` and clears the fence, so an operator's
`abandoned` made a machine read un-cancelled again and the fan-out re-enqueued against it; and an
episode opened by an *exhaustion* sweep before the suspension would have made a machine read
cancelled that this suspension never touched. The parent's list is the thing that actually answers
"has this fan-out dealt with that machine", and it is already returned to the operator.

*Why the entry and not the outcome.* Keyed on the outcome, a child that fails deterministically —
`authentication` after a credential rotation, `unsupported` on an account that never declared
`delete_machine` — leaves its machine un-cancelled forever, while `OPS-39` forbids the next pass
enqueuing a second delete under the same open episode. The fan-out then cannot terminate and cannot
progress: the parent never settles, `WIR-41`'s resume is fenced indefinitely, and a worker slot is
pinned. Keyed on the entry, the pass terminates because the machine has been **accounted for**,
which is what the parent's job actually is.

**What that costs, stated rather than hidden: the parent settles `succeeded` while a machine of a
suspended tenant may still be running.** Three things bound it and all three are required. The
child's failure is a record of its own, named in the parent's result (`WIR-39`'s `cancellations`)
and readable through `GET /v1/operations`. A `failed` attempt moves its episode to `stalled`
(`OPS-48`), which `OPS-26`'s listing **surfaces to the operator** beside `uncertain`, and the
recovery is `API-64`'s retry on the same episode — which `API-7` skips step 5b for, so a suspended
tenant's stalled episode stays retryable. *Until 2026-09-05 this sentence continued "and the
machine keeps consuming its commitment, so `LDG-13`'s exhaustion path reaches it on the ordinary
schedule whether or not anyone looks" — which `OPS-48` forbids: the episode stays open, the sweep
enqueues nothing against an open episode, and the operator listing and retry are the only
recovery. `CNF-272` carried the same false clause and was corrected the day before; this copy was
not.* **A
suspension is not a promise that the fleet is gone; it is a promise that every machine has been
accounted for and that nothing further can be bought.** The terms and the operator documentation
MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.

**AMENDED 2026-08-31 — the flag lands at admission, not in the worker.** The withdrawn wording
said "the suspension flag and the full fan-out MUST commit together", which on a `202`-returning
endpoint (`WIR-39`) puts the flag in a *worker's* transaction. `API-7` step 5b reads
````

Source at M: 03-operation-lifecycle.md:240–250, classifier/create row.

````text
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
````

