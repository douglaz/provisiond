# r83 — triage-1027 Panel D: lifecycle and evidence

Read this brief and `/var/tmp/provisiond-panel-r83/notes.md` whole. Each reader has its own clean clone pinned to **3109b5b44eae17e288cf52aaa976993bd8c5626c**, fetched origin/master on 2026-10-30. No proposed amendment below is applied to the source. The pin, rather than the stale 10-27 table line numbers, controls every source quotation.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR or start subagents/background work. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r83/tmp/` in a reader-specific subdirectory. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' outputs/clones, or the main working tree. **Run no `lake build`, Nix gate or other Lean build**: this is a source-reading panel and the host has a shared build limit. The manager runs the gates separately. Return a substantive final answer within the 3600-second launcher limit, aiming for <=3000 words plus any exact replacement forms needed. Do not wait for other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

This turn authorizes verification, drafting and launch only. No implementation Run, source/tracker write, adoption, PR, follow-on panel or merge. Read the questions as technical calls within the fixed policy. Each form is a separately reviewable amendment bundle, with precise edit locations and complete inserted/replacement text. ACCEPT means you can accept that exact bundle unchanged; if you need any substantive repair, mark CANNOT ACCEPT and give the complete corrected bundle as a distinct alternative. Keep final preference separate from acceptability.

## Fixed owner policy and provenance

Owner-decision record `/var/tmp/provisiond-manager/owner-decisions-1030.md`, item 3 (postdates the pin; it is not claimed to be in Git):

Owner answer, verbatim: **"Stop before buying (Recommended)"**.

Option text, verbatim: **"At pickup the worker sees the customer is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles the exact error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a policy choice."**

Decision homes: API-58 and OPS-43. Keep OPS-27 for orders already dispatched. Q4 asks only how to carry that policy out. Buying, charging, then cancelling an order first picked up while suspended is outside every acceptable form. Q1's create fixture must respect the same choice. The panel may flag that a proposed mechanics form fails the policy; it may not vote to reverse the policy.

## Verification at the pin

The raw committed rows for pv-gvc, pv-bxh, pv-y0to and pv-kv2 are open; they are copied without using the tracker CLI in `check/beads.json`. The triage rows and grouping are copied in `check/triage-rows.txt`. No question was dropped. Relevant merged amendments since 10-27 include account-status tests (#29, #43) and exclusion-release coverage (#47), but the quoted second admission barrier below still lacks retryability, and the worker still reads only account status in step 1. For Q3, the cadence, diagram and OPS-45's evidence path are positive existing support, so this brief does **not** assert that the whole specification has no automatic path. Readers must decide whether their combined wording already supplies an executable path before adding one.

Owner settling rule, verbatim: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four".

The question order follows the triage grouping: Q1 pv-gvc; Q2 pv-bxh; Q3 pv-y0to; Q4 pv-kv2. Coordinate Q1 and Q4 explicitly, but tally them separately. The minimal variants deliberately differ from the more explicit variants; none is pre-adopted.

## Q1 — pv-gvc: test the suspension write and its release ownership

**Plain-terms failure story.** A customer has queued work when suspension starts. A faulty store update could fail the cleanup job instead of the customer's work, overwrite work that a worker already took, or act on an old suspension after its parent settled. A create refused before purchase could also leave its reserve tied up. The existing held-power test is a real scheduler setup and already checks caller origin; it does not independently vary those negative guards. A normally eligible create can be claimed ahead of the suspension worker, so it cannot stand in for a store-only never-claimed fixture.

**Question.** Which exact coverage bundle should land, and does the existing deterministic-create-failure release duty suffice for the administrative failure or must API-58 explicitly name it? The triage leans to independent store-level guards and kind coverage, resolving release ownership first. Preserve CNF-202's reachable held-power case in every form. Do not turn its existing origin assertions into a claim that no origin checks exist. If the never-claimed prose and printed guard disagree for a previously deferred operation, identify that as an additional precise problem rather than silently changing the guard in a test-only form.

**Pinned evidence — API-58, transition and race, `04-api-contract.md:617–669`. Verbatim:**

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
```

**Pinned evidence — STO-3, worker and administrative writes, `05-persistence.md:19–81`. Verbatim:**

```text
**STO-3** **AMENDED 2026-09-12 (`ADR-0022`) — the worker's guard carries the claim number and
admits its own repeat; the defer is the fifth guarded write and the restore quarantine the
sixth.** Six conditional writes move an operation, and each MUST report whether it affected a row
(`OPS-22`):

- **A worker's write** — every settled-state write, and a worker moving its own operation into
  `needs_reconciliation` — is guarded on
  `(id, status = running, claim_number = mine) OR (id, status = target, claim_number = mine, the
  written columns are not distinct from what is being written)`, where `mine` is the number
  `STO-1`'s claim returned (`OPS-6`). The second branch admits the row this same execution's write
  already produced — the claim term is on both branches, since matching columns do not establish
  matching execution — so a repeat after a lost reply (`OPS-49`) affects one row and changes
  nothing; `revision` and `updated_at` advance only on the first branch, which keeps `API-53`'s
  "strictly increases on each client-visible modification" true. **The guarded status write
  precedes every money write in the transaction and short-circuits the rest** — after `OPS-50`'s generation read and then `LDG-35`'s primitive where the settlement needs it,
  since those locks, in that order, are the transaction's entry —
  so `OPS-27`'s multi-row settlement repeats as a unit or not at all. `OPS-50` says "MUST read
  `STO-59`'s row `FOR SHARE` as its first statement".
  This includes the create row's worker settlement (`OPS-11`: "MUST settle `failed`, whatever its kind"): take the `LDG-35` primitive, make this guarded status write, then release under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full"). It adds no `about_to_order_at IS NULL` term.
  A write that affects no row means something other than this execution moved the operation —
  the startup pass after a restart, or a later claim after a defer — and the worker exits
  (`OPS-22`). *Until 2026-09-12 the guard was `(id, status = running)` alone; the `epoch = mine`
  term that once sat beside it held by construction, because the claiming process stamped the
  value itself (`ADR-0019`). The claim number does not: a later claim rewrites it.*
  *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): included the create settle write within this worker branch and its money order.*
- **The defer** (`OPS-8`) — `running` back to `queued` with `available_at` advanced — is guarded
  on `(id, status = running, claim_number = mine)`. A write that affects no row means the operation
  was already deferred or already claimed again; the worker moves on and does not exit. *Added
  2026-09-12: this write was not in the list, and unguarded by the claim number a retried defer
  landing after a re-claim pulled the second execution's operation back to `queued`.*
- **The startup pass** (`OPS-15`) moves every `running` operation to its startup state —
  `needs_reconciliation`, or `failed` for a `refresh` (`ADR-0020`) and, on a restart,
  for the create exception (`OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only.") — guarded on
  `(id, status = running)`, with `(kind = create, about_to_order_at IS NULL)` additionally inside
  the create settlement's conditional write, and carrying **no claim term**: it is made by no execution. It runs after `OPS-15`'s generation advance and before the process makes any claim, so no
  earlier engine's write commits beside it (`OPS-50`). `OPS-50` says "MUST read `STO-59`'s row
  `FOR SHARE` as its first statement, compare it for equality with the value the engine's own
  startup pass wrote" and "Where the values differ, the transaction MUST roll back". `OPS-15`
  says "every earlier engine's write either committed before it, and is swept here, or is refused
  after it".
- **Resolution out of `needs_reconciliation`** is not a worker write (`OPS-3`): it is guarded on
  `(id, status = needs_reconciliation, resolution IS NULL)`, which is `STO-19`'s write-once rule
  expressed as the same kind of conditional write. *Unscoped, this requirement forbade every
  transition `OPS-3` enumerates — a `status = running` guard can never hold for an operation
  sitting in `needs_reconciliation`.*
- **The suspension fan-out's administrative transition.** `API-58` step (4) moves an operation
  that is still `queued` and was never claimed straight to `failed`, guarded on
  `(id, status = queued, requested_by = caller, the operation's tenant is suspended, and that
  suspension's fan-out parent is still unsettled)`. A child claimed by a real worker between the
  pass and the write must lose this race and settle as its own worker's write instead.
  *`requested_by = caller` was added 2026-09-05: the fan-out joins a pre-existing exhaustion
  episode by naming its queued delete rather than enqueuing a second one, and without this term
  step (4) failed the very delete step (3) had just named — an episode `OPS-48` then holds
  `stalled` for an operator, on a machine the suspension had reported as accounted for.*
- **The restore quarantine** (`STO-54`, `OPS-15`) moves a `queued` create, install or rescue
  inventory to `needs_reconciliation`, guarded on `(id, status = queued)`, and carries no claim
  term: it runs before any claim. *Added 2026-09-12.*

**Step 8's `operations`-row write** (`OPS-43`) is also a worker write, though it moves no status.
It is guarded on the first branch alone (`OPS-43`: "guarded on `(id, status = running,
claim_number = mine)`"), and its `COALESCE` preserves a set value. A whole-transaction repeat after
a lost reply changes no column and advances neither `revision` nor `updated_at` (`OPS-43`: "a
whole-transaction repeat after a lost reply affects one row and changes nothing").
```

**Pinned evidence — LDG-32, release owner, `12-billing-and-ledger.md:310–328`. Verbatim:**

```text
**LDG-32** **AMENDED.** A commitment MUST be closed, and its remaining amount released in full,
on **every** terminal outcome: the machine's meter stops **and every billable attachment it left
behind has release evidence (`released_at`)** (`PRV-13a`, `STO-18`); the create fails deterministically; the create
is resolved absent (`OPS-27`); the create is abandoned (`OPS-31`); **or the machine's
provider account is recorded `terminated`** (`SEC-46`, `API-63`), which stops every meter in that
account (`LDG-74`) and closes every open commitment on its machines in the transaction that records
it — *the stop is named here because the first row above makes stopped billing the precondition for
every other outcome on this list, and the termination row arrived without it.*

*The account-termination row was missing until 2026-09-02 while `SEC-46` and `API-63` both cited
this requirement as the closing rule and the commitment state machine above drew the edge — the
"every terminal outcome" list named four and the set had five.* And the abandonment row is scoped to
the kinds that opened a commitment: an install or a delete opens none, and the only one within reach
is the machine's **running** commitment, which abandonment MUST NOT release (`OPS-31`).

The outcome "the create fails deterministically" includes the create row's case. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."

*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): included the worker-recorded failure case regardless of error kind.*
```

**Pinned evidence — API-63, assertion about suspension release, `04-api-contract.md:1370–1383`. Verbatim:**

```text
instant"), subject to its earlier scheduled-date case, and
`released_at` set on every unreleased billable attachment as its release evidence (`LDG-32`,
`STO-18`);
**apply `LDG-38`'s exit rule to every subject**, including scheduled machines and quarantined
subjects; **close and release in full
every open commitment on machines in that account** (`SEC-46`, `LDG-32`); **transition every `queued`, never-claimed create naming that
account straight to `failed`** — `conflict`, `details.reason: "account_terminated"` — **and close
and release its commitment**, exactly as `API-58` step 4 does for a suspension and for the same
reason, that it has touched no provider (*added 2026-09-05: a create's commitment has a null
`machine_id`, so "every open commitment on machines in that account" left it standing; a worker then
dispatched against revoked credentials, the reply was ambiguous, and the customer's money sat frozen
for `OPS-33`'s window — days on Robot*); **close every open episode on those machines
`resource_gone` and clear their fences** (`OPS-48`'s gone-write row, `ADR-0021`), **and transition
every `queued`, never-claimed system cancellation or `API-64` retry attempt naming those
```

**Pinned evidence — CNF-202, existing test kept in full, `10-conformance-checklist.md:2252–2275`. Verbatim:**

```text
- [ ] **CNF-202** — Suspending a tenant returns a `suspend_tenant` operation whose children are
      readable through `GET /v1/operations`; resume is synchronous and restores no machines.
      Separately, hold a power operation the caller requested `running` at its driver call on one
      of a tenant's machines, and keep a second worker free. Enqueue a second power operation the
      caller requests on that machine, and hold the engine's clock from then until a worker has
      claimed the `suspend_tenant` operation. `OPS-8` says “A claim (`OPS-5`) that the index refuses
      because another running operation holds the machine MUST return the operation to `queued`
      with a short delay”. Before suspending, read the second at the store and check it is
      `queued` with `claim_number` 0. `OPS-6` says “A claim the per-machine index refuses
      (`OPS-8`) never left `queued` and does not advance the number”. Suspend the tenant. Keep the
      first held until the second has left `queued`. If the first settles before that, the setup
      failed and the case has not run. If the second is still `queued` when a stated bound
      passes, the case fails there, before any release. Otherwise release the first, and wait
      until the `suspend_tenant` operation has settled. Then assert the second is `failed` with `conflict` and
      `details.reason: "tenant_suspended"`: `API-58` says “`queued` but never claimed straight to
      `failed`, carrying the reason in the operation's `error`: `conflict`, with
      `details.reason: "tenant_suspended"`”. Assert its `requested_by` is `caller` and its
      `system_reason` is null: `API-58` says “Its `requested_by` stays `caller` and its
      `system_reason` stays null”. Assert no provider request was made for it: `API-58` says “it
      has touched no provider”.
      (`WIR-39`, `WIR-41`, `API-58`, `WIR-9a`, `WIR-10b`, `OPS-6`, `OPS-8`, `ADR-0022`)
      *Amended 2026-10-21 (`pv-1wn`, panel r60): added the queued, never-claimed caller power
      operation that suspension fails with `tenant_suspended`, held `queued` behind a running
      power operation on its machine, quoting `API-58` for each assertion.*
```

### Q1-A — store cases; release remains with the existing owner

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
```

### Q1-B — explicit API-58 release duty plus store cases

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In API-58, immediately after the sentence ending "that kind stays an admission-time rejection of a *caller's* write (`DOM-20`).", insert:

Where step (4) fails a create deterministically, the same guarded transaction MUST close its
commitment and release the remaining amount in full; see LDG-32, "the create fails deterministically".
It MUST make no setup-fee or first-unit debit. The administrative status write MUST precede the
release and short-circuit it when it affects no row, after the transaction's generation check
and the tenant's LDG-35 primitive.

At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
```

### Q1-C — narrower representative kind coverage; existing release owner

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. Independently for create, install and power, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
```

For each Q1 form, decide whether it would catch a deleted origin term, a deleted parent-unsettled term, a lost claim race, a kind filter that handles only power, and missing create release. State any difference between accepting an added test and needing a new requirement. No no-change form is presumed adequate for the independent guard cases; an exact no-edit alternative is welcome only with a pinned existing assertion that already rejects each named bad write.

## Q2 — pv-bxh: retry advice for an account changing during admission

**Plain-terms failure story.** The API collects a healthy account snapshot. Before it opens the order's reserve, the account becomes unreachable, its credentials are rejected, or it is permanently terminated. The final write correctly refuses the order. The caller still needs to know whether sending the same order later makes sense. Reading the account after releasing its row could report a recovery that happened after the refusal, rather than the status that refused it.

**Question.** Which exact retryability rule belongs to API-63's admission conditional-write refusal, how does it identify a status without a race, which wire clause owns the mapping, and what must the second-barrier test assert? This is separate from the already explicit worker step-8 mapping. The triage asks whether permanent and recoverable statuses must differ; it supplies no permission to copy the resource-offer guard's false value or the worker's values without a ruling.

**Pinned evidence — API-63, admission guard versus worker guard, `04-api-contract.md:1405–1433`. Verbatim:**

```text

**It MUST also contend with admission on the account row itself, and that ordering comes first.**
The create's admitting path MUST **conditional-write** `STO-47`'s row, guarded on
`status = healthy`, **in the transaction that opens the commitment**, and fail `conflict` with
`details.reason: "state"` where that write affects no row — so a create admitted after a
termination is impossible rather than merely unlikely, because the two contend on one row and one
provably loses, which is `OPS-42`'s shape. *A draft of 2026-09-04 had the create **read** the row
in that transaction and called it the same shape; it was not. Under the snapshot isolation a server
engine (`STO-6`) ordinarily gives, a read contends with nothing, and the create committed against an
account terminated behind it. The row now exists from configuration so there is always one to
write (`STO-47`), and `STO-27` lists this among the primitives a replacement engine must
reproduce.* *Added 2026-09-04: per-tenant
primitives cannot supply this. They do not cover a tenant with no machines in the account yet, and
the check and the commitment sat in different transactions, so a create could pass the health check,
have the termination commit behind it, and open a commitment against a dead account.* **A create claimed but not yet dispatched narrows the unreachable case to a dispatched order**:
in `OPS-43`'s step 8, the correlator transaction (`PRV-26`: "before the order is
sent"), where "on every ordering channel, including `correlator: none`, the worker MUST set
`operations.about_to_order_at`" (`OPS-43`) — the last write before the ordering call — the worker MUST repeat the admission check as a
conditional write on `STO-47`'s row guarded on `healthy`, and where it affects no row MUST fail the
operation deterministically — `conflict`, with `details.reason: "account_terminated"` where the status is
`terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable
account as a permanent termination is false, and with `retryable: false` for `"account_terminated"`
and `retryable: true` for `"state"` on both the error and the operation view (`WIR-9b`) — releasing its commitment,
with no provider mutation. `LDG-69` keeps the provider call outside that transaction, so a
termination can still commit between the write and the call; that residue is the dispatched case
below, **and `about_to_order_at` is what tells the termination which case it is**: a claimed
create still `running` with the column null has not passed the conditional-write check and does not dispatch. Under
`OPS-43`'s claim order it may fail at step 1, "Read the provider account's stored status", at
another preceding check, or at this conditional write. Interruption can instead leave the create
```

**Pinned evidence — API-7, resource-offer-specific refusal, `04-api-contract.md:296–302`. Verbatim:**

```text
an added lookup.*

**Amended 2026-10-10 (`ADR-0036`).** After an otherwise successful tail collection,
a create whose resource-offer conditional write affects no row (`PRV-42`) MUST receive an
ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no
`details.refusals`, no synthesized pacing or `Retry-After`, and no commitment,
operation or receipt. This response is specific to the resource-offer guard.
```

**Pinned evidence — WIR-9a, snapshot-based retry mapping, `13-wire-contract.md:165–188`. Verbatim:**

```text
`offer_not_sellable`, `rate_unavailable`.
Purchase-tail entries MUST use these `retryable` values, applying `DOM-17`'s "whether repeating
the same request is safe and sensible":

| Refusal | `retryable` | Reason |
|---|---|---|
| `halted` / `solvency` or `rate_unavailable` | `true` | The same purchase can succeed when the gate clears |
| `conflict` / `state` on a create account whose collection-snapshot `STO-47` status is `account_unreachable` or `credentials_rejected` | `true` | The named account can recover |
| `conflict` / `state` on a create account whose collection-snapshot `STO-47` status is `terminated` | `false` | The named account cannot recover |
| `invalid_request` / `offer_not_sellable` on create | `false` | The offer cannot be bought on the same request |
| `rate_limited` / closed ordering channel on create | `true` | The same create can be evaluated after the reported interval clears |
| `conflict` / `cancellation_committed` | `false` | Repeating does not revoke a committed cancellation (`API-68` is a separate decision) |
| `invalid_request` for `max_commitment_sats` | `false` | The caller must revise its spend bound |
| `insufficient_balance` | `false` | The caller must supply balance before purchasing |

*Amended 2026-10-04 (`pv-gip.11`): fence retryability retains false; keep is a separate operator decision.*

*Amended 2026-10-04 (`pv-gip.26`, S2): account retryability distinguishes permanent termination
from recoverable status; kind and reason remain unchanged.*
*Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): the offer refusal and
unchecked reason join create tails; cap and balance amounts are withheld for that offer.*
*Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment): a local closed-channel
entry carries `retry_after_ms` and is retryable when its interval can clear. Its
headline uses HTTP 429 and `WIR-4`'s `Retry-After`; `WIR-9b` still aggregates every
```

**Pinned evidence — CNF-278, second barrier and separate worker cases, `10-conformance-checklist.md:2936–2970`. Verbatim:**

```text
      **Barrier case, and it is the one a lock alone fails**: hold a meter tick
      that has already read the machine as billable, commit the termination, then release the tick —
      it must post nothing, because `LDG-38` re-reads billability inside the serialization rather
      than trusting what it read before. **Second barrier**: admit a create that passes the health
      check, commit the termination before its commitment opens, and assert the create is refused —
      the create **conditional-writes** `STO-47`'s row guarded on `healthy` in the transaction that opens
      the commitment, and a mere read there is not enough under snapshot isolation. **Third**: leave
      a create `queued` and unclaimed naming the account, commit the termination, and assert it is
      `failed` with `details.reason: "account_terminated"` and its commitment released — a worker
      that claims it afterwards dispatches against revoked credentials and freezes the customer's
      money for `OPS-33`'s window. **Fourth**: claim a create, commit the termination before its
      step-8 transaction commits (`about_to_order_at` still null), and assert it fails `account_terminated`
      with `retryable: false` on both the error and the operation view (`API-63`: “with
      `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
      error and the operation view”) and with no provider mutation;
      the List offers read is permitted;
      then commit the termination *after* step 8 commits (`about_to_order_at` set) and before the call, and assert the
      termination treats that attempt as potentially dispatched — neither failed nor released, and
      resolved through `OPS-36`'s late attach.
      **Account-read cases:** admit a create and leave it `queued` and unclaimed, record
      `credentials_rejected` before claim, then claim it; repeat with `account_unreachable` on
      another account. Assert `OPS-43`'s step 1, "Read the
      provider account's stored status", fails it `conflict` with `details.reason: "state"` and
      `retryable: true` on both the error and the operation view, `failed`, no provider request
      and full commitment release. On a fresh account, claim a
      create, let the List offers read complete, then commit termination before step 8 commits (`about_to_order_at` null). Assert `conflict`, `details.reason: "account_terminated"`,
      `retryable: false` on both the error and the operation view, `failed`, full commitment
      release, and no provider mutation: no per-order key upload and no order request.
      Repeat the step-8 barriers and account-read cases with an auction-channel descriptor and
      a standard-channel (`correlator: none`) descriptor; assert the column's null/set test on
      both, and each failing case's `retryable` value above, asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not.
      **Fifth**: reload configuration over the `terminated` row and assert it stays `terminated`.
      **Then activate a
      fresh tenant while that account is terminated and assert it is never assigned to it**
      (`STO-36`, `API-57`); with **every** assignable account unhealthy, assert activation still
```

**Pinned evidence — DOM-17, meaning of retryable, `01-domain-model.md:655–662`. Verbatim:**

```text
**DOM-17** Every error MUST carry a kind, a human-readable message, a boolean
`retryable`, and a structured `details` object. `retryable` describes whether repeating
the *same request* is safe and sensible. **It is normative guidance to callers** (`API-51`) —
never authorization for an automatic service retry, and no substitute for an operator's `API-64`
retry of a stalled episode. It MUST NOT be
used by the system to retry automatically (`OPS-12`).

**DOM-18** `details` MUST be redacted with the same rules as `DOM-6` before it is stored
```

### Q2-A — status-sensitive admission refusal with a locked decision

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In API-63, replace the first sentence after "It MUST also contend with admission on the account row itself, and that ordering comes first." with:

The create's admitting path MUST lock STO-47's account row for update, then conditional-write
that row guarded on status = healthy, in the transaction that opens the commitment. This
account-row ordering precedes the commitment-opening work. Where the guarded write affects no
row because the locked status is non-healthy, the admission MUST fail conflict with
details.reason: "state" and the retryable value in WIR-9a's admission-guard row. The refusal
MUST retain the locked status used for that decision before releasing the lock; it MUST NOT
classify using a later unlocked status read or the earlier collection snapshot. A serialization
failure is not a non-healthy status and MUST NOT be converted into this refusal. No operation,
commitment, receipt or purchase effect commits on the refused admission.

In WIR-9a, immediately after the collection-snapshot terminated row in the purchase-tail table, insert:

| conflict / state from API-63's admission conditional write, after a healthy collection snapshot | false for a locked refusing status of terminated; true for account_unreachable or credentials_rejected | Use the status retained by the guarded admission decision in API-63, not the collection snapshot or a later read |

In CNF-278, replace the Second barrier sentence and its following explanatory sentence, ending "snapshot isolation.", with:

**Second barrier:** on fresh independent fixtures collect a healthy account snapshot, then
commit each non-healthy STO-47 status before the admitting transaction opens the commitment.
Assert HTTP 409 conflict, details.reason: "state", retryable false for terminated and true for
account_unreachable and credentials_rejected, with no operation, commitment, receipt or provider
request. The admission locks and conditional-writes the account row in its commitment-opening
transaction. Hold a recoverable refusal at its locked decision and attempt recovery concurrently;
recovery cannot alter the status used for that refusal. Recover after lock release and assert
the already decided response retains true; an independent later request can use the new status.
A mere snapshot read in the admitting transaction is not a replacement for the conditional write.
```

### Q2-B — narrower constant false advice for the admission guard

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In API-63, in the admission conditional-write sentence, replace "and fail `conflict` with `details.reason: "state"` where that write affects no row" with:

and fail conflict with details.reason: "state" and retryable: false where that write affects no
row because the account is no longer healthy. This admission-guard refusal has one retryable
value regardless of which non-healthy status defeated the write; it needs no later status read.
A serialization failure is not this refusal. No operation, commitment, receipt or purchase effect
commits on the refused admission.

In WIR-9a, immediately after the collection-snapshot terminated row in the purchase-tail table, insert:

| conflict / state from API-63's admission conditional write, after a healthy collection snapshot | false | The admission race is a distinct refusal; this value does not depend on a later status read |

In CNF-278, replace the Second barrier sentence and its following explanatory sentence, ending "snapshot isolation.", with:

**Second barrier:** on fresh independent fixtures collect a healthy account snapshot, then
commit each non-healthy STO-47 status before the admitting transaction opens the commitment.
Assert HTTP 409 conflict, details.reason: "state", retryable: false in each response, and no
operation, commitment, receipt or provider request. The create conditional-writes STO-47's row
guarded on healthy in the transaction that would open the commitment; a mere read there is not
enough under snapshot isolation. Let a recoverable account become healthy after the refusal
and assert that change does not rewrite the response. This admission mapping is separate from
the initial collection-snapshot and worker step-8 mappings.
```

### Q2-N — no amendment, only if an existing chain already decides the value

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
No repository text changes. Retain API-63, WIR-9a and CNF-278 exactly as pinned. Acceptance requires citing the existing exact clause that yields one determinate retryable value for a healthy-snapshot admission guard refusal and identifying the existing race-free input it uses.
```

Assess Q2-A's lock order against the current account-row-first rule, money primitive and transaction-error handling. A zero-row UPDATE alone returns no refusing row; do not claim it captures the status unless you name how. If Q2-B conflicts with DOM-17's "safe and sensible", identify the concrete refusal, not an assumed value borrowed from another guard. Keep HTTP admission response distinct from a worker refusal on an existing operation view.

## Q3 — pv-y0to: who dispatches non-create evidence reads?

**Plain-terms failure story.** A provider may have applied a delete or power change but its reply was lost. The operation waits for evidence. The driver contract explains which reads can tell the truth, and the deployment register requires a read within a stated delay. A builder still needs to connect those reads to a background component and resolve the attempt without issuing the original change again. Conversely, adding a second resolver would be needless if the existing diagram, cadence and sweep already mandate that dispatch.

**Question.** Is the existing combination executable for each applicable non-create kind? If yes, choose no change or a minimal pointer. If not, select a complete engine scheduling/dispatch form: trigger, component owner, read identity, cadence, authoritative-window test, guarded settlement and operator fallback. The one-line bead is not evidence that every automatic path is missing. Explain the path separately for provider-managed mutation kinds and rescue-based disk writes; do not mistake ordinary resource presence for proof of a completed install. Never reissue a mutation as an evidence read.

**Pinned evidence — PRV-29, non-create evidence, `02-provider-contract.md:421–457`. Verbatim:**

```text
**PRV-29** **AMENDED 2026-08-31 — the test is bounded freshness of evidence, not richness of
state.** For any ambiguous mutation **other than create**, resolution MUST proceed by reading
authoritative, non-mutating provider evidence anchored to the machine's known `external_id` and,
where available, to the mutation attempt itself — the identifier is known, which is precisely what a
lost create reply lacks. `PRV-36` ranks the sources and bounds their freshness.

**A driver can resolve a non-create mutation if and only if it can bound the time after which its
evidence is truthful** — by a source that is truthful immediately (the write path's own report, the
provider's mutation history) or by `PRV-36`'s measured visibility window on a resource read. A
driver that can do neither declares so in the descriptor's `evidence_sources` (`PRV-44`), and its
machines MUST carry the unreduced `wind_down_cost`.

Where a provider genuinely has long-lived *scheduled* and *accepted-pending* states — the
robot-style cancellation with an effective date (`PRV-13c`, `DOM-19`) — the driver MUST additionally
separate *rejected*, *accepted-pending*, *scheduled with an effective date* and *complete*, because
there all four persist and look identical from outside.

*The withdrawn text demanded that richness from every driver and said a driver that can only answer
"the machine still exists" cannot resolve a cancellation. That was wrong in two directions at once.
**Too narrow on evidence:** it mandated a `PRV-12` machine read and thereby excluded the stronger
action-log and write-path sources `PRV-36` now ranks above it. **Too weak on freshness:** a naive
driver satisfies its letter — it reads state for a known id — and still concludes "the delete
failed" eight seconds after a successful delete, which is a confident wrong answer that an operator
verb can act on, and worse than "I do not know". And it was perverse in the reserve: on a cloud
provider that deletes immediately, the four states collapse to applied/not-applied plus an interval
the window bounds, so the old wording put the provider with the **fastest** deletes into the
**worst** `wind_down_cost` bucket — inflating, through `PRV-13b`, the commitment every customer must
post before buying anything.*

**Mutation complete, resource absent, and billing stopped are three different facts** and MUST be
evidenced separately. For the customer's meter, the billing-stop evidence is the gone-write for
a machine or `released_at` for a completed attachment release; a stored effective date stops
the corresponding scheduled machine or attachment meter while the resource may remain present.
Meter boundaries remain with `LDG-38` and `LDG-74` ("Billing stops at the observation instant").
An action reporting `completed` does not establish that billing stopped.
*Amended 2026-10-08 (`ADR-0037`): wind-down sizing above uses the effective visibility window;
billing-stop evidence is named here. Amended 2026-10-09 (`ADR-0037`, Q14): the attachment date
```

**Pinned evidence — PRV-36, source ranking and window, `02-provider-contract.md:1100–1152`. Verbatim:**

```text
**PRV-36** **Read-after-write. A read of provider state is not authoritative about a mutation the
driver issued until that provider's effective visibility window has elapsed.**

`OPS-33` already states half of this and states it for creates: absence within the negative window
is **not evidence** that nothing was created. This is the mirror, and it is the half that was
missing — presence within the visibility window is **not evidence** that a mutation did not happen.
One principle, two directions.

**It was measured, not theorised.** Against the live DigitalOcean API on 2026-08-31,
`DELETE /v2/droplets/{id}` returned `204`; a `GET` on the same id eight seconds later returned `200`
with `"status":"active"` and a live public address; it returned `404` only on the next poll. A
driver that reads "the machine still exists" as "the delete failed" therefore reports a successful
deletion as a failure, and the remedy for a failed delete is to perform it again.

**Per mutation kind it can be asked to resolve, a driver MUST declare its evidence sources in
descending strength** — the descriptor's `evidence_sources` (`PRV-44`):

1. **The mutation endpoint's own report that the goal state already holds.** Truthful immediately;
   it comes from the write path. *(The same measurement found `DELETE /v2/images/{id}` answers `422`
   `"Can not delete an already deleted image."` on a second call, while `GET` answers `404` at the
   same instant — the write path and the read path disagreeing about one resource.)*
2. **The provider's mutation history for the known `external_id`** — an action or transaction
   object. This is not a correlator and MUST NOT be described as one: `PRV-26` scopes correlators to
   create, where the identifier is *unknown*. Here it is known, and what is needed is a stronger
   place to read it from.
3. **A read of the resource**, interpreted only through the effective window below.

A stronger source, when consulted, overrides a weaker one. A weaker source never overrides a
stronger one.

**For the resource read the driver MUST declare a measured visibility window** in seconds, with
sample size and date: the worst observed request-to-observation latency over at least twenty real
mutations, re-declared when the provider changes the API — carrying a declared conservative bound
marked **unmeasured** until twenty samples exist. *Procedure owned here from 2026-10-08
(`ADR-0037`).*
**AMENDED 2026-09-08 (`ADR-0018`) — the effective
window is a max, not the declaration.** The declared value lives in the descriptor's
`visibility_window` (`PRV-44`), immutable. The engine writes every ordinary mutation and every
resolution as an observed sample to `provider_observations` (`STO-53`), and the effective window
is `max(declared, max(observed))`. Widening by an observed sample that exceeds the declaration is
thereby automatic; narrowing is a human re-declaring and archiving the samples.

**Within the window, a read showing the pre-mutation state is no evidence and resolution stays
pending.** `OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from
the end of the mutating call's wait: its reply, or the provider-call deadline's expiry when no
reply arrives. **A read showing the post-mutation state is evidence at any time, and MUST NOT be
reverted by a later
contrary read** — reads flap in both directions, and a resolution already reached on absence is not
undone by a stale read. Beyond the window, a read still showing the pre-mutation state resolves
the mutation as *not applied*.

*Amended 2026-10-09 (`ADR-0037`, Q13): the visibility clock starts when the mutation call's
wait ends, including the lost-reply deadline, while `STO-53` retains its dispatch-to-observation
```

**Pinned evidence — OPS-3, transitions and non-worker resolution, `03-operation-lifecycle.md:79–120`. Verbatim:**

```text
**OPS-3** **AMENDED 2026-09-12 (`ADR-0022`) — the worker's guard is the operation's status and
its claim number, and a repeat of the worker's own write is admitted.** `needs_reconciliation` is
*resolution-pending*, not terminal; `succeeded` and `failed` are the terminal states. **`failed`
asserts that the operation did not complete, and nothing about its side effects** (*added
2026-09-15, `pv-x8r`*): a `failed` install may have partitioned its disk, a `failed` delete may have
been dispatched. The one positive record that nothing took effect is `OPS-31`'s `not_applied`, in
the resolution column, and `abandoned` reaches `failed` having established nothing — so the state
alone never carries either claim. What an install did to its disk is `OPS-45`'s marker's fact, and
`WIR-9a`'s `disk_effect` renders it to the caller, who sees neither the marker nor a verb. **A
transition made *by a worker* MUST be guarded on that operation still being `running` under the
claim number the worker holds** (`STO-3`, `OPS-6`), and the guard MUST admit the row the same
write already produced, so that a write repeated under `OPS-49` after a lost reply affects one row
and changes nothing; a worker whose guarded write affects no row has been overtaken — by
`OPS-15`'s startup pass after a restart, or by a later claim of the same operation after an
`OPS-8` defer — and MUST NOT overwrite the record. *Until 2026-09-12 the guard was the status
alone; the epoch that briefly replaced the lease is deleted (`ADR-0019`).*
**Resolution transitions out of `needs_reconciliation` are made by no worker** — by `OPS-27`'s
sweep or `OPS-31`/`WIR-35`'s operator verb — and are guarded instead by `STO-19`'s write-once
resolution columns. Scoping the worker clause is required, not stylistic: read unscoped it forbids
the operator verb, which no status guard fits.

*Calling it terminal contradicted every requirement that resolves it.* `OPS-27` transitions it
automatically on a correlator match, `OPS-31`/`WIR-35` transition it by operator verb, and `OPS-4`
forbade both by forbidding transitions out of terminal states. The permitted transitions are
exactly:

```
needs_reconciliation --resolved observed (create)--> succeeded
needs_reconciliation --resolved applied (non-create)--> succeeded
needs_reconciliation --resolved absent (create)--> failed
needs_reconciliation --resolved not_applied (non-create)--> failed
needs_reconciliation --resolved abandoned (any kind)--> failed
```

*The two non-create rows were added 2026-09-02 with `OPS-45`. They are not new transitions — the
states either side are unchanged — but the list says "exactly", so a verb missing from it is a verb
`OPS-4` forbids.*

**What was actually load-bearing about "terminal" survives unchanged**, and it is `OVR-5`: the
system MUST NOT retry the mutation automatically, MUST NOT clear the state on its own timer, and
MUST NOT let a caller drive it. Only evidence (`OPS-27`) or an operator (`OPS-31`) moves it. The
caller-facing `terminal` flag (`WIR-10`) is `false` in this state, and `retryable` is `false`
```

**Pinned evidence — existing non-create diagram branch, `03-operation-lifecycle.md:505–519`. Verbatim:**

```text
    A["Operation reached<br/>needs_reconciliation"] --> B{"Is it a create?"}

    B -- "no" --> C["external_id is known.<br/>Read provider evidence, PRV-29"]
    C --> C1{"Strongest source available?"}
    C1 -- "write path says<br/>goal state holds" --> DONE1["succeeded<br/>OPS-11 goal-state row"]
    C1 -- "mutation history<br/>for this id" --> DONE2["settle on the action record"]
    C1 -- "resource read only" --> C2{"Has PRV-36's visibility<br/>window elapsed?"}
    C2 -- "no" --> WAIT["Not evidence.<br/>Stay pending, do not read again yet"]
    C2 -- "yes, still present" --> NOTAPPLIED["not applied"]
    C2 -- "post-mutation state seen" --> DONE3["applied.<br/>Never reverted by a later read"]

    B -- "yes" --> D["Search the correlator on<br/>EVERY ordering channel, PRV-38.<br/>Union over channels"]
    D --> E{"How many resources?"}

    E -- "exactly one" --> V{"Direct read, OPS-27 / PRV-36"}
```

**Pinned evidence — OPS-27, existing create-shaped entry, `03-operation-lifecycle.md:555–566`. Verbatim:**

```text
**OPS-27** **AMENDED 2026-09-08 (`ADR-0017`) — one correlator, searched on every channel.** The
system MUST attempt automatic resolution before asking a human. Resolution searches the provider
for the operation's correlator (`PRV-26`, `PRV-27`) on **every ordering channel the driver
reaches** (`PRV-38`), takes the union of what those searches return, and reaches one of the four
outcomes below:

| Finding | Resolution | Effect on the commitment |
|---|---|---|
| Exactly one resource across every channel | **Resolved-observed.** Attach it and complete the operation as though it had succeeded. | Becomes the machine's running commitment (`OPS-36` where it was already released) |
| The provider's search is authoritative and returns nothing on any channel, and the negative window has elapsed — or a matched resource is read directly and is gone, past `PRV-36`'s window | **Resolved-absent.** No resource exists to attach — *"the mutation did not happen" until 2026-09-05, which the matched-and-gone case falsifies: the order landed and left nothing* | Closed and released in full (`LDG-32`); a charged fee per `LDG-39`'s absent row |
| More than one resource across every channel | **Unresolved — duplicate.** MUST NOT auto-attach either. Surface both for operator remediation (`OPS-38`). | Released per `OPS-33`; the duplicate is operator cost |
| Any one of the searches cannot be made authoritative — the provider cannot filter, the listing window has expired, or no verified correlator exists for the operation's ordering channel (`PRV-33`) | **Unresolved.** Escalate to an operator (`OPS-31`, `WIR-35`). | Released per `OPS-33`, which applies here too |
```

**Pinned evidence — OPS-28, no mutating resolution, `03-operation-lifecycle.md:914–916`. Verbatim:**

```text
**OPS-28** Automatic resolution MUST be restricted to searching and MUST NOT mutate. Discovering
that nothing exists does not authorize creating it; that is a new decision by the caller, and a
new purchase.
```

**Pinned evidence — OPS-30/31, races and operator fallback, `03-operation-lifecycle.md:1386–1438`. Verbatim:**

```text
**OPS-30** Resolution MUST be idempotent and MUST NOT race a healthy in-flight operation. A
resource bearing operation X's correlator belongs to operation X and to nothing else; a sweep
MUST NOT attach a resource whose operation is still `running` and not yielded (`OPS-8`). *"Claim"
here read "attach" until 2026-09-12; the word now names the queue take (`OPS-5`, `CONTEXT.md`).*

**OPS-31** Operator verbs MUST exist for the unresolved case, and they resolve the attempt — an
episode's `retry` (`API-64`) is a different verb on a different record (`OPS-48`): record an
observed resource by its external identifier, record that nothing was created, or
abandon the operation and accept the loss. Each MUST record who resolved it and on what
evidence, and abandonment MUST close the commitment and release it in full (`LDG-32`) **where the
operation opened one** — a create (`LDG-11`). An install, a rescue inventory,
a power action, a
reverse-DNS change and a delete open none (`API-7`'s tail), and the only commitment within reach of one is the
machine's **running** commitment, which abandonment MUST NOT touch: the machine is still there and
still consuming it. *Scoped 2026-09-02; unscoped, abandoning a failed install released the funding
of a machine that is still running, which is `LDG-13`'s unfunded machine created by an operator
verb.*

**AMENDED 2026-09-02 — those three verbs are create-shaped, and the kinds `OPS-45` governs cannot
use them** (*"five" until 2026-09-16; `PRV-45`'s release attachment made six*). `observed` names an
`external_id` that a create produced; `absent` says nothing was created.
An install, a **rescue inventory**, a power action, a reverse-DNS change, a **delete** and a release
attachment all act on
a machine that
**already exists**, so
neither verb has a meaning there and the only reachable one is `abandoned` — which is why every
install that failed after entering rescue could be resolved exactly one way, as a loss, with
`retryable: false` returned to the caller. **On a delete the create-shaped verbs are worse than
useless: `absent` reads as "the resource is gone", which for a cancellation is *success* and for a
create is *failure*** — the same word, opposite meanings, on the operation an exposure-reducing
episode hangs on (`OPS-44`). **Two further verbs therefore exist, `applied` and
`not_applied`** (`WIR-35`), which are the non-create shapes of `observed` and `absent`: the mutation
took effect, so the operation settles `succeeded`; or it did not, so it settles `failed`. `abandoned`
remains for the case nobody can establish. **`not_applied` MUST be refused, on a `rootfs_via_rescue`
or `raw_disk` install only, where `OPS-45`'s write-started marker is set** — a partially written disk
is not "nothing happened", and the verb would record on `STO-19`'s evidence trail that the mutation
did not take effect, which is false. *It read "tells a caller its data survived" until 2026-09-15;
the caller sees no resolution verb (`API-20`) and reads the disk from `WIR-9a`'s `disk_effect`
instead.* There the
honest verbs are `applied` or `abandoned`. *The scope was absent until 2026-09-04, and it is the
difference between a rule and its opposite: on every other kind `OPS-45` sets that marker when the
provider call is **dispatched**, so the refusal covered every operation an operator could ever be
asked to resolve. `WIR-35` carries the same rule for the wire; this sentence is the engine's copy of
it, and the first correction reached only the wire.*

*Amended 2026-10-08 (`ADR-0035`) and 2026-10-09 (`ADR-0037`, Q14): for a release resolved
`applied`, `PRV-45` owns the attachment effect: "A successful completed release with no
effective date MUST write the row's `released_at`"; a result with an effective date stores that
date instead. `LDG-38` owns the exit write. `OPS-48` owns episode and fence transitions.*

**And an operator MUST NOT be the first resort here.** `OPS-45` requires the engine's own record of
whether a write began to be consulted before any of this: most install failures never reached a
disk, and those are deterministic outcomes, not questions for a human.
```

**Pinned evidence — OPS-45, explicit evidence/fallback path, `03-operation-lifecycle.md:1515–1541`. Verbatim:**

```text
**An operation settles `failed` — deterministically, with no operator and no reconciliation — when
the write-started marker is unset *and* either no rescue session was opened or the one that was
opened was closed without error.** In that state the engine has positive evidence from its own
execution that the disk is untouched and the machine is back where it started. This rule classifies a failure a
worker recorded; an operation interrupted rather than classified is `OPS-15`'s, whatever the markers
hold, and after a restore `STO-54` quarantines it on the same footing (*scoped 2026-09-16*). Everything else
follows `OPS-11`'s classification, and resolution then
proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it, falling back to
`OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot.

**The marker means two different things across the table above, and only one of them can foreclose
anything.** On `rootfs_via_rescue` and `raw_disk` it means **the destructive phase was allowed to begin** — the
installer invoked, or the first write issued — and from then on the machine's old contents MUST NOT
be represented as preserved, whatever the outcome. The marker is written before the phase runs, so
it establishes that preservation is no longer proven, not that a byte landed: a process that dies
between the write and the phase leaves a set marker over an untouched disk, and nothing later can
tell the two apart (*reworded 2026-09-15; it read "bytes have reached the disk"*). On `provider_native`, `provider_catalogue`, power, reverse DNS, delete and release
attachment it means only
that **a request was dispatched**, which is a fact about this process and not about the machine: a
rebuild the provider never began, a power call it dropped, a delete whose response was lost, all set
the marker and all may have changed nothing. *Recorded 2026-09-04 because a single column carrying
two meanings was read as carrying the first one everywhere — see `WIR-35`, where it made
`not_applied` unreachable on every kind whose marker is set at dispatch, which is every kind that
accepts the verb except the two rescue-based install variants.* Where the marker means
dispatch, whether the mutation landed is exactly the question `OPS-31`'s resolution exists to
answer, and it is answered from the provider (`PRV-36`'s evidence sources), never from this column.
```

**Pinned evidence — OVR-17, component assignments, `00-overview.md:288–311`. Verbatim:**

```text
|---|---|---|
| The meter (`LDG-37`, `LDG-38`, `LDG-72`) | `ledger` | Posts debits and decrements commitments, and enqueues nothing. **Where `LDG-37`'s stated source of truth is a provider usage API rather than the machine record, the driver call belongs to `engine`** and hands the meter the figures — the same shape as the sweep below |
| Rate derivation and re-derivation (`LDG-58`–`LDG-61`, `PRV-13e`, `LDG-33`) | `ledger` | A pure balance event mints no operation (`OPS-39`), and the source set is fixed at deployment (`LDG-61`) |
| Provider billing recording and derivation (*added 2026-10-04, `pv-gip.39`*) (`API-66`, `API-67`, `LDG-75`) | `ledger`, reached through `api` | Local accounting rows and a read; no provider call or payment execution |
| The solvency check (`LDG-17`, `LDG-20`) | `ledger` | Reads balances and held satoshis. **The two rail balances it needs are pushed in by `api`'s funding side** (`SEC-48`'s scoped read); `ledger` MUST NOT call `api` to fetch them, which `OVR-9` forbids and which would make the money module depend on the surface |
| The exhaustion sweep (`LDG-13`, `LDG-14`) | `engine` | It reads the machine's `runway_until` (`05-persistence.md`), and through `ledger` its commitment and whether its currency has a rate (`LDG-16`), then **enqueues** a cancellation, which is `engine`'s primitive (`OVR-9`) |
| `LDG-64`'s outage-bound canceller | `engine` | Same shape: a balance-adjacent condition — `LDG-64`'s computed deadline, read through `ledger` — whose effect is an enqueued provider mutation with `system_reason: rate_outage_bound` (`OPS-39`) |
| `OPS-27`'s resolution sweep | `engine` | It searches providers by correlator, so it needs a provider credential, and its terminal transaction writes money through `ledger` (`OPS-27`) |
| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |
| Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
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
```

**Pinned evidence — OVR-19, registered cadence, `00-overview.md:389–397`. Verbatim:**

```text
| Re-derivation interval | `PRV-13e` | duration | yes |
| Account-sweep interval | `OPS-32`, `LDG-74` | duration | yes |
| Worst-case operation hold, per product | `PRV-13b` | duration | yes |
| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |
| Offer-listing age | `API-7` | finite, positive duration | yes |
| Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |
| Provider-call deadline | `OVR-19` | finite, positive duration | yes |
| Resolution-read cadence, per provider account | `OVR-19` | finite, positive duration; maximum wait from a mutation's visibility-window end until its resolution read is issued | yes |
| Margin | `LDG-24` | basis points | yes |
```

**Pinned evidence — OVR-19, achieved resolution-read duty, `00-overview.md:443–451`. Verbatim:**

```text
**The deployment MUST state and enforce a finite, positive provider-call deadline**, measured
from dispatch for each provider call, including a call that never replies. The deployment MUST
state and achieve a finite, positive resolution-read cadence per provider account: for a
resolution-pending mutation, once its effective visibility window ends, its resolution read
MUST be issued within that cadence. A missing, zero, negative, non-finite or malformed cadence
MUST refuse startup as the deadline does. `PRV-13b` owns the sequential wind-down composition.
Deadline expiry
bounds the wait for a reply; it establishes neither the mutation's outcome nor that billing
stopped. Classification and resolution remain with `OPS-11`, `PRV-5` and `PRV-36`; `OPS-12`'s
```

**Pinned evidence — STO-19, write-once resolution, `05-persistence.md:586–589`. Verbatim:**

```text
**STO-19** `resolution` and its evidence columns MUST be write-once. A `needs_reconciliation`
record that can be silently re-resolved is an audit trail that can be edited, and these records
exist precisely for the cases where money moved and nobody is sure.
```

**Pinned evidence — CNF-237, existing delayed delete evidence case, `10-conformance-checklist.md:3402–3408`. Verbatim:**

```text
- [ ] **CNF-237** — **A delete is not resolved as failed while the provider is still catching up.**
      With a provider whose resource read lags its write, an ambiguous delete resolves correctly:
      resolution takes no read before the effective visibility window elapses, a pre-mutation reading
      inside the window leaves the operation pending rather than concluding, a post-mutation reading
      is never reverted by a later contrary read, and a pre-mutation reading beyond the window
      resolves *not applied*. Assert with an injected read lag; a sample exceeding the declared
      window widens it and does **not** authorize a replay. (`PRV-36`, `OPS-33`, `OPS-12`)
```

**Pinned evidence — existing cadence/deadline conformance assertions, `10-conformance-checklist.md:4168–4180`. Verbatim:**

```text
      ends at the configured bound. Repeat with a mutation whose outcome remains unknown:
      expiry alone proves neither success nor non-application nor billing stop, and no
      automatic replay occurs; classification and evidence-based resolution retain their existing
      rules without assuming acceptance from elapsed time. Show wind-down sizing covers the
      full sequential allowance: metering detection cadence, mutating-call deadline, effective
      visibility window starting at the reply or deadline expiry, resolution-read cadence,
      that read's own deadline, worst-case machine-operation hold and margin. Exercise a reply
      at the deadline followed by visibility lag and a lost reply followed by a delayed
      resolution read whose own call lasts to its deadline. Assert neither max(deadline, window)
      nor their sum without the read wait funds the trace. Refuse startup with a missing, zero,
      negative, non-finite or malformed deadline or resolution-read cadence; enforce the stated
      cadence. (`OVR-19`, `PRV-13b`,
      `PRV-36`, `PRV-5`, `OPS-11`, `OPS-12`)
```

### Q3-A — minimal explicit dispatch link using the existing sweep and cadence

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In OPS-27, immediately after its first sentence, "The system MUST attempt automatic resolution before asking a human.", insert:

The engine's resolution sweep covers both create and non-create resolution-pending operations.
For a non-create, dispatch the evidence path in PRV-29 and PRV-36, with OPS-45's marker limits,
OPS-3's resolution transitions, STO-3's resolution guard and OPS-31's operator fallback; the
correlator search and outcome table below apply to create only. Use OVR-19's resolution-read
cadence. OPS-28 says "Automatic resolution MUST be restricted to searching and MUST NOT mutate."

In OVR-17's component table replace the OPS-27 resolution-sweep row with:

| OPS-27's resolution sweep, including PRV-29's non-create evidence dispatch | engine | Provider evidence reads need the provider credential; resolution writes go through store and money effects through ledger |
```

### Q3-B — explicit discovery, dispatch and settlement duties

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
In OPS-27, immediately after its first sentence, "The system MUST attempt automatic resolution before asking a human.", insert:

The engine's resolution sweep MUST discover retained operations in needs_reconciliation with
resolution null on entry to that state, on engine startup and on subsequent passes. It MUST
dispatch non-create operations to PRV-29's authoritative non-mutating evidence path, anchored
to the operation's provider account and known external_id and, where available, the recorded
mutation attempt. The correlator search and outcome table below apply to create only. Reads
MUST be issued within OVR-19's stated resolution-read cadence after the effective visibility
window ends; a pending or failed evidence read leaves the operation pending and eligible for a
later pass, subject to the credential authentication stop and provider rate limits. A read
failure, an elapsed timer or the lack of an action identifier MUST NOT manufacture a resolution.

For every applicable non-create kind in STO-8's resolution row, select only evidence the driver
declares for that mutation kind, ranked and interpreted under PRV-36. Read the provider's action
or transaction history when available; a resource read is interpreted only after the effective
window from the mutating call's reply or deadline expiry. Positive post-mutation evidence and
negative pre-mutation evidence follow PRV-36. Resource presence alone MUST NOT establish that
an install or rescue inventory did or did not finish. Where the driver cannot provide truthful
evidence for that kind, surface the unresolved attempt to OPS-26 and use OPS-31's operator
fallback; do not hold off the operator on a timer that cannot produce evidence.

The sweep MUST commit applied as succeeded or not_applied as failed only on authoritative
evidence for that attempt, using STO-3's resolution guard (id, status = needs_reconciliation,
resolution IS NULL) and STO-19's write-once evidence columns, through store under OPS-50's
generation check. Record the evidence and the resolving engine identity with the resolution.
On a lost-reply repeat use OPS-49; a zero-row guard MUST NOT overwrite the winner. Preserve
OPS-31's refusal of not_applied for a rootfs_via_rescue or raw_disk install with a set write-started
marker. Apply the existing PRV-45/LDG-38 attachment effects and OPS-48 episode/fence effects
where applicable; applying a mutation, disappearance and billing stop remain separate facts.
No evidence pass may reissue the mutation, run install or rescue phases, start a new attempt,
or clear needs_reconciliation solely because time passed.

In OVR-17's component table replace the OPS-27 resolution-sweep row with:

| OPS-27's resolution sweep, including PRV-29's non-create evidence dispatch | engine | Provider evidence reads need the provider credential; resolution writes go through store and money effects through ledger |

At the end of CNF-237 append:

Run the real engine with a pending delete and, independently, power, reverse DNS, release
attachment and each applicable install/rescue-inventory strategy for which the driver declares
authoritative evidence. With no new caller request, assert the resolution sweep issues the
per-kind evidence read within OVR-19's cadence after the effective window. Inject failed and
pending reads, authoritative applied and not_applied results, stronger and weaker contradictory
evidence, an operator winning the resolution guard, and a lost settlement reply. Assert no
mutating request is repeated, the winning resolution/evidence is not overwritten, and effects
on meters, attachments, episodes and fences occur only under their owning rules. On a driver
with no truthful source for that kind, assert the operation remains pending and is surfaced for
operator resolution. For rescue disk installs with a set write-started marker, assert no
automatic not_applied; an ordinary machine-presence read is not install-completion evidence.
```

### Q3-N — existing chain is sufficient; no repository change

This is the complete amendment bundle for this form; all other pinned text stays unchanged.

```text
No repository text changes. Retain the pinned PRV-29, PRV-36, OPS-3, OPS-27, OPS-28, OPS-45, OVR-17, OVR-19 and CNF-237. Acceptance requires giving the executable chain for discovery, module ownership, per-kind dispatch, window origin, cadence, guarded settlement and operator fallback from the quoted sources, without inventing an automatic mutation retry.
```

Q3-B deliberately makes scheduling explicit; Q3-A is the narrower reference repair. Determine whether either actually adds behavior and whether the current cadence already makes Q3-N sufficient. A diagram is evidence to interpret, not proof by itself that a named component performs the reads. A missing helper name in the pseudocode is not proof by itself of a missing normative duty. Do not resolve a rescue session by booting or ending rescue in an allegedly read-only pass.

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

All Q4 forms retain the existing OPS-27 suspended-attach rule; none removes it. These forms propose the step-8 transaction as the potentially dispatched boundary, matching the existing account-termination shape. **Test that interpretation against the fixed owner policy explicitly**: if a stricter boundary is needed, reject the exact form and provide a complete alternative that respects LDG-69 rather than claiming a last-millisecond plain read is race-free. In particular, a create first picked up while suspended must never enter that residue case. Explain whether the quoted existing "claimed before" sentence requires the precise replacement above, and whether any other owner clause needs a coordinated edit. Do not silently extend the create rule to power/install or to a system cancellation.

## Formal scope and adversarial checks

This panel changes no files. Any later amendment to a formalized property must update its owning Lean declaration and Markdown together, after reading the statement and its omissions, without weakening a theorem to silence it; see AGENTS.md and ADR-0025. No CNF identifier belongs in tools/formal. Relevant declarations are indexed under API-58 (Funding.lean and Fence.lean), STO-3 (Claim.lean and Rescue.lean), LDG-32 (Ledger.lean and Funding.lean), PRV-36 (Reconcile.lean), and OVR-19 (Fence.lean and Witnesses.lean). The index alone is not a claim that each declaration models the proposed guard. For example Claim.lean's opening scope explicitly omits API-58's fan-out transition, and Reconcile.lean models one create's knowledge, not a non-create dispatcher. Read those omissions before proposing a formal coverage claim. Identify an actual affected declaration, or state that the mechanics sit outside the current model; do not demand a new formalism merely to accept an option.

For each Q1–Q4:

1. Give your preferred exact form and ACCEPT / CANNOT ACCEPT for every printed form, separately. Quote any blocking source with owner and path:line at the pin. An alternative needs complete exact inserted/replacement text and landing locations, not "add a guard" or a combination the other readers did not read.
2. Ask where the brief is actively wrong, whether it contradicts itself, and whether a narrower form carries the obligation. If a motivating claim is false, distinguish that premise error from a valid objection to a candidate.
3. Give one concrete interleaving or store fixture that would break the candidate, or say none found. For Q1/Q4, distinguish the store administrative write, the worker's own claim settlement, and an order already dispatched. For Q2, distinguish a healthy collection snapshot from the locked refusing status. For Q3, name the automatic path before declaring it absent.
4. Give the strongest don't-build argument **on request**, labelled as such and separate from your actual vote. If removing a guard or widening a read, state what the guard protected and a checked/normative verdict that changes.
5. List required follow-up owner locations and conformance assertions, and any other-bead overlap. Another panel's questions stay outside this round. Do not inspect or write other panel folders or units.

End with four lines in this shape: `Final Q1: <exact form>; acceptability ...`, through Q4. No policy re-vote. No manager synthesis counts as read. This is the first round for these exact forms, not the authorized consensus round after a tie.

