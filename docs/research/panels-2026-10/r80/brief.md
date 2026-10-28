# r80 — one wording question for PR #35 / pv-8mt4

Review pin: `f25c9a2f03106353e26cb9feeed89dc647d4767d`. This is an independent reading of one documentation sentence. The two proposed dispositions are below; neither is preselected. The owner adopted M-I verbatim and has now directed a panel to try to settle this wording question. Decide from the quoted evidence whether A, B, or an exact alternative sentence is acceptable, and whether A changes anything beyond wording. Do not assume that the finding or either disposition is correct.

This turn prepares and launches this read only. Do not edit a source file, apply a patch, use br, commit, push, contact a remote service, reply to the PR, resolve a thread, merge, launch another round, or delegate. Work from your own detached clean clone at the pin. Other clones, the main checkout, other panel folders, the manager files and production are off limits. You may read the evidence reproduced here and source files in your own clone. No credential, session or configuration reads, including `~/.grok`, `~/.claude`, `~/.codex` and credential stores. No web search. The external paths below are provenance, not permission to browse them.

Do not read other readers' answers. Return a complete answer within the launcher's 60-minute bound; if needed, write a draft answer to `../<your-seat>.draft.md` before minute 45. Do not create background tasks or subagents. The manager has run the repository gate independently; this is a text question and you need not rerun it. No behavior, requirement, declaration, theorem, guard hypothesis, witness, negative control or check-strength amendment is authorized by this read.

## Exact question and dispositions

Pick **A or B**, or give **one exact alternative replacement sentence**. Also give your acceptance of each printed option (ACCEPT / CANNOT ACCEPT), separately from your final preference. Do not silently combine or enlarge the options.

**A** = `/var/tmp/provisiond-manager/pv-8mt4-pr/proposed-quote-only.patch`: replace only the first docstring sentence with `Global guard for OPS-15: "at startup, before any claim".`, then push, one bot round, merge.

**B** = keep the M-I wording verbatim, reply with evidence and resolve the thread, merge.

These are prospective dispositions for a later manager step, not actions for a reader to perform. The complete exact patch for A is:

```diff
--- a/tools/formal/Provisiond/RestoreIndependent.lean
+++ b/tools/formal/Provisiond/RestoreIndependent.lean
@@ -10,7 +10,7 @@
 
 open Provisiond.Restore Provisiond.Witnesses
 
-/-- Global guard for OPS-15's before-any-claim requirement. True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result. -/
+/-- Global guard for OPS-15: "at startup, before any claim". True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result. -/
 @[req "OPS-15"]
 def permitsI (requirePass : Bool) (p : Params) (w : World) : Permissions :=
   { Restore.permits p w with
```

Explain whether A changes anything beyond wording: **behavior**, **a requirement**, or **a check's strength**. State each separately as unchanged or changed, with a source-based reason; name any concrete changed checked verdict or normative obligation. If you find a substantive change, give the exact source/trace rather than treating an editorial label as evidence. If you propose an alternative sentence, say which objection it resolves and whether it changes any of those three categories. An alternative remains a distinct exact option for tallying.

## Evidence, pinned where repository-owned

### The finding, verbatim

Source: PR #35 comment 4405117474, thread `PRRT_kwDOT30eC86xSSqD`, path `tools/formal/Provisiond/RestoreIndependent.lean:13`, at `f25c9a2f03106353e26cb9feeed89dc647d4767d`. Retained API source: `/var/tmp/provisiond-manager/pv-8mt4-pr/drain-threads.json`; direct finding: https://github.com/douglaz/provisiond/pull/35#discussion_r4405117474

```text
**<sub><sub>![P1 Badge](https://img.shields.io/badge/P1-orange?style=flat)</sub></sub>  Quote OPS-15 in the guard's requirement attribution**

The docstring attributes a “before-any-claim requirement” to OPS-15 without quoting its wording. This violates the repository's explicit requirement that claims about another requirement carry that requirement's own words. Quote the relevant OPS-15 clause (“at startup, before any claim”) alongside the attribution, keeping the explanation of the model's disabled guard separate.

AGENTS.md reference: [AGENTS.md:L29-L32](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/AGENTS.md#L29-L32)

Useful? React with 👍 / 👎.

<!-- codex-code-review-finding:v1 -->
```

### Repository instruction, verbatim

Source: `AGENTS.md:29–32` at `f25c9a2f03106353e26cb9feeed89dc647d4767d`.

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
```

### OPS-15, complete block including its opening paragraph and exceptions

Source: `03-operation-lifecycle.md:371–483` at `f25c9a2f03106353e26cb9feeed89dc647d4767d`; the following requirement starts at line 484. The quotation proposed in A occurs in the opening paragraph.

```text
**OPS-15** **AMENDED 2026-09-08 (`ADR-0016`) — the startup pass is the sweep.** Subject to the
exceptions below, at startup, before any claim, the engine MUST move every `running` operation
to `needs_reconciliation` — after the generation advance below no earlier engine's write commits
(`OPS-50`), so any `running` row at startup is interrupted — guarded on `(id, status = running)`
(`STO-3`), and MUST log the count it found. `OPS-50` says "MUST read `STO-59`'s row `FOR SHARE`
as its first statement, compare it for equality with the value the engine's own startup pass
wrote" and "Where the values differ, the transaction MUST roll back". It MUST NOT move them back to `queued`: a crashed
worker is exactly the case where the provider may have acted and nobody recorded it. No periodic
pass is needed; nothing but a restart can leave a `running` row with no worker behind it.

The engine's first write transaction after taking `STO-51`'s lock MUST contain only the
replacement of `STO-59`'s startup generation (`OPS-50`'s exception). `OPS-50` says "Except for `OPS-15`'s generation-advance transaction". Its commit MUST be
acknowledged before the engine begins any other write transaction, the remainder of the pass, or
any worker or periodic component. The engine makes no write before that transaction. Its
replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s
Startup-lock wait bound. That statement waits on every open `FOR SHARE` of the row (`OPS-50`),
so every earlier engine's write either committed before it, and is swept here, or is refused
after it. On that timeout or any store error, including a lost reply on its commit, the engine
MUST log loudly and exit non-zero having claimed nothing; this exit is not `OPS-49`'s retry,
which covers workers and periodic components. **Liveness:** a `SyncRep` holder (`STO-7`: "A
standby wait has no server-side timeout"), or share holders that keep turning over, can hold the
advance until that exit, which `OVR-18` alarms; the supervisor's restart is the retry.
`OPS-49` says "Where a store call by a worker, or by a periodic component running in the engine
process (`OVR-17`), errors or times out". `OPS-50` says "hold that lock until it commits" and
"Where the values differ, the transaction MUST roll back". `OVR-18` says "its startup exit on
the generation advance's timeout (`OPS-15`)".

**After a restore the premise fails, and `queued` rows are the danger** (added 2026-09-12,
`ADR-0023`). "Any `running` row at startup is interrupted" is true after a crash and false after a
restore, where the row may have settled at the provider inside the lost interval — and a `queued`
row, which this pass never inspects, may already have run. So on a restore (`STO-54`) the pass
additionally moves every `queued` create, install and rescue inventory to `needs_reconciliation`
while `STO-54`'s step (2) is unmarked, guarded on `(id, status = queued)`, with an `internal`
error naming the restore: a repeat is a second order, a second disk write or a second boot into
rescue, and `OPS-27` establishes what
happened rather than doing it again. The goal-state kinds — delete, power, end-rescue, release
attachment, reverse DNS — stay `queued` and re-run, because `OPS-11` classifies "already in the
target state" as `succeeded`. And the `suspend_tenant` exception below does not fire on a restore while `STO-54`'s freeze holds it off:
a parent found `running`, or found `queued` and unsettled — which is where `OPS-49`'s deferred
parent sits, and the likelier state at any backup instant — waits for operator confirmation and is
not claimed, since the fan-out it would resume may have been reversed inside the interval. Once that freeze has lifted for the exception, a parent found `running` is returned to `queued` with no second confirmation.

**What puts the pass on that branch is a record, not an operator's knowledge** (added 2026-09-20,
`ADR-0023`). `STO-54` says "a process that starts while a restore record is open is continuing that
incident, not restarting", so the successor of a process that died inside the procedure takes the
restore branch, with the rest of the procedure it inherits. *Until then the branch had no
predicate: a crash between the restore landing and this pass left the successor reading the
paragraph above, which is the naive boot `ADR-0023` is written against.*
**The pass over `running` rows runs at every startup, the record open
or not.** `OPS-5` says a `running` operation "stays claimed until it settles, defers under `OPS-8`, or the
startup pass finds it (`OPS-15`)", and a dead worker does neither of the first two. A marked step (2) keeps only
its own work from running again (`STO-54`). While the record is open the create exception stays off, so a
create found `running` goes to `needs_reconciliation`, and a `suspend_tenant` parent follows the restore rule
above.

`Provisiond.RestoreIndependent.original_skipped_pass_blocks`,
`Provisiond.RestoreIndependent.both_guards_sweep_and_progress`,
`Provisiond.RestoreIndependent.skipped_pass_required_claim_blocks`,
`Provisiond.RestoreIndependent.pass_only_sweeps_and_progresses`,
`Provisiond.RestoreIndependent.neither_guard_strands_and_progresses`.

**A `refresh` found `running` at startup MUST be settled `failed`** — the same guarded write as
above (`STO-3`), with an `internal` error naming the restart, the nearest of `DOM-17`'s kinds —
and not moved to `needs_reconciliation`: it is read-only (`OPS-11`), so there is
nothing the provider may have done that nobody recorded, and `WIR-35`'s resolve verbs refuse it
by kind. *Added 2026-09-08 (`ADR-0020`): until then this pass sent an interrupted refresh to a
state whose only exits refused it.*

**A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a
restart only.** Where no error is recorded, it MUST carry an `internal` error naming the restart,
with `retryable: true` on both the error and the operation view. An error already recorded stays:
`OPS-16` says the sweeper "fills in an error only where none exists". The operation view's
`retryable` MUST then equal that error's. This is not an `OPS-11` classification: `OPS-45` says
"an operation interrupted rather than classified is `OPS-15`'s". Such a create made no provider mutation and is not ambiguous; it never enters
`needs_reconciliation` and runs no resolution or correlator matching.

For each such row the pass MUST take the tenant's `LDG-35` primitive, then perform the conditional
status write guarded on `(id, status = running, kind = create, about_to_order_at IS NULL)`, then the
money writes, all in one transaction per row. The null test MUST be inside that write, never a
preceding read. Only if the status write affects a row MUST the same transaction close and release
the commitment in full — `LDG-32`'s "the create fails deterministically" — under `LDG-39`'s
"Deterministic rejection before acceptance" row, never debited, and free the resource-offer
exclusion (`STO-58`). If the conditional status write affects no row, the ordinary `(id, status =
running)` write still moves a still-running create to `needs_reconciliation`; a set column takes
that ordinary path. The pass writes neither `about_to_order_at` nor the markers.

Whichever of this null-guarded status write and the live step-8 write commits first, the other's
guard affects no row. This describes their predicates; an earlier engine's step-8 write cannot
commit once the pass has advanced the generation (`OPS-50`). `OPS-47` says "The lock is not a
fence". `OPS-50` says "Where the values differ, the transaction MUST roll back". The exception MUST NOT run periodically. **It does not fire while a restore record is
open** (`STO-54`, `STO-56`). A restore can lose the column's committed write while the provider
holds the order. This restriction lasts for the whole open incident, independently of the
freeze's end.

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and
`docs/research/panels-2026-10/r56/r56b/`): added the null-only create restart exception; `ADR-0042`
amends `ADR-0016`. The interrupted-worker introduction allows for each exception's startup path.
PR #7's review scoped the restart error to a create with none recorded.*

**`suspend_tenant` is another exception, and on a restart it MUST NOT require an operator.** A
`suspend_tenant` parent (`API-58`) found `running` at startup MUST be returned to `queued` and
re-claimed like any other queued work, resuming its fan-out from wherever it stopped — *on a restart, and on a restore once `STO-54`'s freeze has lifted for the exception; until then it waits, above (`STO-54`)*. It mutates no
provider itself — its per-machine children do, and each child is an ordinary operation the rules
above already govern — so a crashed parent leaves nothing ambiguous to establish, and the re-sweep
is idempotent by `OPS-39`'s dedup: an open episode per machine and key (`STO-52`) makes a repeated
pass enqueue nothing twice. Routing the parent to `needs_reconciliation` instead would contradict
`OPS-11`'s `suspend_tenant` row and would leave a suspended tenant's fleet running, and billing,
until a human noticed — which is exactly what `SEC-45`'s one-action termination MUST NOT depend on.
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; `ADR-0045`): removed the promoted-asynchronous-standby exclusion from the create restart exception.*
*Amended 2026-10-23 (`pv-n98`; panel r63, r63c’s Form F′, `docs/research/panels-2026-10/r63/`; owner decision Q2 “Clean up every startup (Recommended)”): separated the per-startup running-row pass from step (2)’s mark and bounded the parent wait by the exception’s freeze.*

*Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): added the startup advance and amended the sweep’s ordering.*
```

### Adopted M-I passage, verbatim

Source: archived `docs/research/panels-2026-10/r77/brief.md:506–510` at `f25c9a2f03106353e26cb9feeed89dc647d4767d`. These lines are also byte-identical to `/var/tmp/provisiond-panel-r77/brief.md:506–510`.

```text
### Complete package M-I: retain the existing model and add an independent countermodel

Leave Restore.Params/current, permits, step, run, successor_sweeps_running and every existing witness unchanged. Add the printed permitsI, stepI, runI as a second formal test model alongside new named witnesses; give requirePass the explicit documentation:

> Global guard for OPS-15's before-any-claim requirement. True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result.
```

Source for the adoption: `/var/tmp/provisiond-manager/owner-decisions-1028-panelB.md:9–11`.

```text
Owner answer (verbatim): "Add M-I (Recommended)"

Meaning: adopt exactly the printed M-I package in /var/tmp/provisiond-panel-r77/brief.md, as tallied in /var/tmp/provisiond-panel-r77/tally.md. No unread repair or union is approved. pv-8mt4 goes to ready-for-agent with that package as its brief, landing in a drain branch's preparation commit together with the r77 records under docs/research/panels-2026-10/.
```

### Current docstring and declaration context, verbatim

Source: `tools/formal/Provisiond/RestoreIndependent.lean:13–18` at `f25c9a2f03106353e26cb9feeed89dc647d4767d`. Compare the first line with the adopted documentation above; the later explanatory sentences survive A unchanged.

```lean
/-- Global guard for OPS-15's before-any-claim requirement. True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result. -/
@[req "OPS-15"]
def permitsI (requirePass : Bool) (p : Params) (w : World) : Permissions :=
  { Restore.permits p w with
    claim := w.locked && (!requirePass || w.passDone) &&
      (!w.fault.isRestore || w.stepTwoMarked) }
```

### Owner's subsequent answer, verbatim

Source: owner's answer relayed in the current launch instruction, and `/var/tmp/provisiond-manager/manager-brief.md`, PR handling, 2026-10-28 wording exception:

> For such wording questions, try to solve by getting a consensus of the panel

## Answer format

1. `Final: A` / `Final: B` / `Final: ALTERNATIVE: <exact sentence>`.
2. A: ACCEPT / CANNOT ACCEPT; B: ACCEPT / CANNOT ACCEPT. Explain the controlling evidence, quoting the source words you rely on. If offering an alternative, give its exact replacement sentence and acceptability separately.
3. A beyond wording: behavior unchanged/changed; requirement unchanged/changed; check strength unchanged/changed. Name exact evidence for each; identify any uncertainty.
4. State the strongest reason against your final preference, clearly labelled **requested counterargument, not my vote**. State whether you can accept the other printed option and what, if anything, would be needed for consensus.

Keep the answer focused on this question, normally no more than 700 words. Do not review unrelated system design or reopen M-I's adopted mechanics.
