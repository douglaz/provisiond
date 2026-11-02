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


## Wording correction — 2026-10-31 (Panel O r94)

The text above is retained as the historical form approved in owner item 19.
The executable pv-kv2 Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q4-D text is retained.

Replacement for the serialization-retry sentence:

```text
OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.
```

Replacement for the provider-call passage:

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case.
```

Source pin: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.
Review head: `b85af778fda2a96fb0024a07c69092665303bfbe`.
Panel record: `../../r94/notes.md`.
