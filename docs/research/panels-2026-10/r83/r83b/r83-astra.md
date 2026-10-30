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