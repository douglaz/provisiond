# r82 — adopted B: one exact conformance case and a wording question

Read this brief and `/var/tmp/provisiond-panel-r82/notes.md` whole. Each reader has its own clean clone of the LOCAL repository branch pv-ymjo at **c824e4fa4d612b231110bc5deb3e88b3b3e90f92**. No source has been amended for this round. The owner has adopted B as printed below. This is a reading round on the two questions at the end; do not reopen A versus B or revise any other part of B.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR or start subagents/background work. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r82/tmp/` in a reader-specific subdirectory. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' output/clones, or unrelated main-worktree content. The historical extracts supplied in this packet and the pinned sources in your own clone are the evidence. If testing, capture actual command exits unpiped. Return a substantive final answer within the 3600-second launcher limit; aim for <=1800 words plus exact CNF text. Do not wait on other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

No rloop Run, source/tracker/main-worktree write, PR action or follow-on round is authorized this turn. pv-ymjo is already closed in committed JSONL, while the previous Run exited blocked; that is not acceptance. Any later authorized fix must keep the closure consistent with its outcome. The drain stays held here.

## Owner answers, verbatim

Source: the owner's current instruction to this manager, relaying the two r81 answers verbatim. These answers postdate the pinned repository; they are not claimed to exist in commit c824e4fa4d612b231110bc5deb3e88b3b3e90f92.

- Clock: “B: inserting txn (Recommended)”
- Check: “Add one case (Recommended)”

The exact Check question put to the owner was “should a conformance case test this exact retry (first attempt aborted, retry saves its own time; a retry after a commit keeps the original)?”, with “All 4 readers: yes to one CNF case, no new gate ... the panel settles one exact text before the fix Run.”

The frozen r81 tally is historical: it settled B with three of four final picks and referred it for adoption; the owner's answer above now adopts that exact form. Its timestamp-comparator blocker was not verified. The complete checked discussion is reproduced below, not treated as a new vote. Grok's sole preflight is HTTP 402/balance exhausted; its seat is missing, and notes.md fixes the 3-of-4 fallback before launch.

## Adopted form B, whole

Source: `/var/tmp/provisiond-panel-r81/check/form-B.txt:1–10`, whole frozen settled text. This is the candidate replacement for the pinned `05-persistence.md:1442–1448`; it has not yet been applied there. Line wrapping is preserved.

```text
The operator MUST select and retain one new incident id per actual restore before attempting
establishment, and reuse that id on a lost-reply retry. If establishment with that id finds no
committed matching record, it MUST insert the incident with restore_instant defined by STO-54
for the newly begun transaction inserting it; an instant selected for an earlier attempt that
did not commit is not reused. Repeating establishment with that id when a committed matching
record exists MUST affect that record as a guarded no-op, not create or supersede another
record, preserving its step marks and original restore instant. A mismatch in the committed
id's restore instant or predecessor MUST be refused with both components stopped. The initial
establishment or its matching no-op repeat MUST be acknowledged before either component starts.
A new actual store restore uses a distinct id even when the predecessor incident is still open.
```

## Pinned owning context

Source: `05-persistence.md:1419–1487` at c824e4fa4d612b231110bc5deb3e88b3b3e90f92, STO-56 whole. The old retry paragraph is printed as pinned historical source; adopted B above replaces that paragraph for the forthcoming fix.

```text
**STO-56** **`restore_incidents`** — `id`, `restore_instant`, `steps_completed` (0 to 3),
`grace_ends_at`, nullable (*added 2026-09-25, `ADR-0028`*), `lost_window_starts_at`, nullable,
`loss_end_at`, nullable, `history_evidence_ref`, non-null, and `closed_at`, nullable, and
`supersedes_incident_id`, nullable, a foreign key to the retained predecessor record. One row per
restore (`STO-54`), written into the restored or promoted store before either component is started and closed
by the operator under the rules below; at most one row may have `closed_at` null, a partial unique index over
the table.
Both components read the open row before anything else they do: it is what says a starting process
is continuing an incident rather than restarting, and `steps_completed` is what says where to
resume, so neither fact depends on an operator being at the console when a process dies. *Added
2026-09-20 (`ADR-0023`).*

**Actual-restore supersession.** On an actual store restore whose restored store contains an open
incident R, the transaction establishing the new record MUST close R by supersession and insert a
distinct record naming R in `supersedes_incident_id`, with the new restore instant,
`steps_completed` = 0, `grace_ends_at` = `null` and `closed_at` = `null`. R is retained. For
provenance initialization and the start boundary, see `STO-54`. Supersession is the sole exception
to the ordinary close conditions below: it replaces the predecessor's outstanding recovery
obligations with the new incident's full procedure and close conditions, and no predecessor step
mark satisfies a new step. No component starts between closing R and establishing the new record.
Where the restored store has no open incident, the new record has `supersedes_incident_id` `null`. A
process crash without an actual store restore creates and supersedes no incident.

The operator MUST select and retain one new incident id and restore instant per actual restore
before attempting establishment, and reuse both on a lost-reply retry. Repeating establishment with
that id MUST affect the matching record as a guarded no-op, not create or supersede another record,
preserving its step marks and original restore instant. A mismatch in the id's restore instant or
predecessor MUST be refused with both components stopped. The initial establishment or its matching
no-op repeat MUST be acknowledged before either component starts. A new actual store restore uses a
distinct id even when the predecessor incident is still open.

`restore_instant` is non-null; its event-time definition and the meanings of
`lost_window_starts_at`=b and `loss_end_at`=f belong to `STO-54`. The incident-keyed
`history_evidence_ref` identifies retained evidence or the unknown-endpoint reason, and is non-null
even when both bounds are unknown. The endpoints and reference MUST be written with the row;
continuations MUST NOT recompute them. `STO-54`: "Continuations reuse the persisted endpoints and
evidence unchanged."

**`grace_ends_at` is the unpaused end of the restore grace, one stored instant for the whole
incident** (*added 2026-09-25, `ADR-0028`; amended 2026-10-02, `ADR-0029`*). It is null until
step (3) of `STO-54`'s procedure is marked, and it MUST be written in the same transaction as that
mark, as step (3)'s instant plus one re-derivation interval — `STO-54` says "A marked step does
not run again", so it is written once per incident. `OPS-41` owns its per-claim read and the
funding-only paused check in the fence transaction; `STO-49` owns the history retained for that
computation.
The startup read above is taken once per process, so it cannot see an instant written or passed
later in the incident. `STO-54` says "the freeze lifts at `grace_ends_at`"; keeping this record
open does not prolong that freeze.

**Except for the atomic supersession above, the operator MUST NOT close the record until** step (3)
is marked, `grace_ends_at` has passed,
the account sweep's second pass is done, every waiting parent is confirmed or cancelled, and,
for **each currency**, either its accumulated rate-present time since step (3) has reached one
re-derivation interval (`OPS-41`) or every machine priced in that currency is recorded gone or
fenced (`machines.destroy_committed` is non-null; `OPS-42`, `LDG-62`). A finished currency does
not discharge another's obligation. Closing at the original end alone MUST NOT disable unspent
paused grace for a currency with a live unfenced machine. The gone-or-fenced alternative requires
no outage-bound crossing and discharges only that currency's grace obligation, not the wall-clock
or other incident obligations.

*Amended 2026-10-04 (`pv-gip.27`).* The machine-disposition condition MUST be evaluated at the
close, not latched from an earlier read: a late attach ordered before close can make it false
again. An attach ordered after close MUST NOT reopen the incident and receives no restore grace;
`OPS-41` owns the worker's no-open-record case. No general post-return survival interval is added.

*Amended 2026-10-03 (`ADR-0029`): withdrawn — "or its outage has reached `LDG-64`'s bound. The
bound discharges that currency's grace obligation even if its rate never returns: no funding
cancellation remains to protect past that bound." `ADR-0029` holds the decision and its argument.*
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; `ADR-0045`): included the promoted store as a record destination.*
```

Source: `05-persistence.md:1632–1666` at c824e4fa4d612b231110bc5deb3e88b3b3e90f92, the start boundary, inserting-transaction clock, endpoint duties and event-clock recipe. Read the rest in your own clone if needed.

```text
- **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every
engine and `api` process, and MUST start neither component until the transaction that commits
`STO-56`'s record (below) has been acknowledged (*added 2026-10-24, `ADR-0047`*).

  For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of
  the newly begun transaction inserting this incident. This is the event time of incident
  creation, not the time of the recovered history. The transaction begins after the existing
  stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it
  is not claimed as a fact already proved by the formal model.

  The report separates that event from the history that survived. Persist a nullable
  conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence
  references when the incident is inserted. A non-null b MUST certify that every source-history
  component commit acknowledged before b belongs to recovered committed history. A non-null f
  MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST
  be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery
  time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather
  than an apparent finite interval.

  The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence
  that e bounds the source clock's error, the timestamp was generated before insertion, and the
  recovered continuous prefix on matching ancestry contains that complete record. Capture the
  observation before restart can erase it, or identify the complete record in retained WAL. The
  earlier-acknowledgement implication is the certificate: this timestamp is neither an exact
  snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN,
  filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound
  needs the same inclusion proof.

  A verified upper error bound on the incident transaction's event clock, with retained
  stopping/fencing evidence that no old-history acknowledgement follows that transaction's
  start, can supply f=restore_instant+e_event. Source and event clocks may have different error
  bounds; record their provenance. If either endpoint cannot be certified, persist null for it
  and say that endpoint is unknown. The event timestamp alone never substitutes for a missing
  history bound. Retain evidence outside the lost failure domain or with the incident so that
  continuation does not depend on the failed primary.
```

## Existing landing: CNF-302, whole

Source: `10-conformance-checklist.md:3022–3097` at c824e4fa4d612b231110bc5deb3e88b3b3e90f92. The next item, CNF-303, begins at line 3098.

```markdown
- [ ] **CNF-302** — **`rescue_exit: "none"` is a fact, and the column is written before the session,
      not after the exit** (added 2026-09-16). Drive an install refused before begin rescue —
      `OPS-40`'s claim-time URL gate, or a `rescue_ssh` capability refusal (`DOM-10`) — and assert
      `failed`, `rescue_exit: "none"`, no `rescue_address`, and `rescue_exited_cleanly` **null** in
      the row and in `request_summary`. Then kill the engine after the pre-dispatch write commits
      and before the begin-rescue dispatch (*step added 2026-09-20, `pv-v1f`*): no begin-rescue call
      reaches the provider, `OPS-15` moves the operation to `needs_reconciliation`, the column is
      **false** over a machine that was never rebooted into rescue, the error carries
      `rescue_exit: "unknown"` with the `rescue_address` and `rescue_port` that `OPS-15`'s pass
      renders from the machine row (`RSC-19`), and no key file exists. Then kill the engine between
      the begin-rescue dispatch and the end-rescue call: `OPS-15` moves the operation to
      `needs_reconciliation`, the error carries `rescue_exit: "unknown"` with `rescue_address` and
      `rescue_port`, the column is **false**, and no key file exists (`RSC-19`: a crash persists
      nothing, and `unknown` never implies a file). Then `CNF-301`'s clean exit: **true**. Then
      repeat the pre-dispatch write after a simulated lost reply and assert it affects one row and
      changes nothing (`ADR-0022`, `STO-3`). Then restore from a backup taken before the dispatch,
      inserting an incident with null `lost_window_starts_at` and `loss_end_at` and a non-null
      incident-keyed `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`,
      `STO-56`), and assert the quarantined row renders both keys `unknown` whatever the restored
      columns hold (`WIR-9a`). Three distinct column values, or the item passes an implementation that writes the
      marker only at the exit — which renders a crashed session as `none`, the one lie the column
      exists to prevent. The pre-dispatch kill is the step that separates the required write from
      one made at the dispatch instead: `OPS-45` states "false, written before begin rescue … is
      dispatched", and an implementation that waits for the dispatch renders that row `none`.
      (`OPS-45`, `OPS-15`, `RSC-19`, `WIR-9a`, `STO-50`, `STO-54`)

      Keep a restore incident open through the following paired cases. Restore a backup with an
      unsettled install whose markers are `null` although its destructive phase and rescue dispatch
      occurred in the lost interval. Complete step (3), then assert the old row renders both keys
      `unknown`. Admit separate fresh raw-disk installs after step (3), and crash the engine while
      each remains `running`: (a) before either marker write, (b) after the write-started marker and
      pre-rescue `false` marker have committed, (c) after the write-started marker and clean
      rescue-exit `true` marker have committed but before settlement. Run the successor's startup
      pass and assert each row is `needs_reconciliation`, with no replay or automatic deterministic
      settlement. Assert `none`/`none` for (a), `destructive_boundary_crossed`/`unknown` for (b),
      `destructive_boundary_crossed`/`clean` for (c). Repeat successor startup, close the incident
      under its ordinary close conditions, and purge payloads; assert the retained wire values do
      not change merely because of those events. In another actual restore from a backup containing
      a still-unsettled formerly fresh row, assert both keys now render `unknown`. For rescue
      inventory repeat the old-row and later-restore cases with `rescue_exit` `unknown`; for
      separate fresh rescue-inventory rows with rescue marker `null`, `false` and `true` assert
      `none`, `unknown`, `clean`. Do not write an install write-started marker or introduce
      `disk_effect` on that kind. Check provenance and rendering across a lost transition reply and
      a repeat.

      Separately construct `CNF-300`'s unresolved failed-rescue-exit row with `disk_effect` `none` and
      `rescue_exit` `unknown` without a prior restore, then back it up and actually restore it
      (`CNF-300`: "`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
      "unknown"`"). It
      remains `needs_reconciliation`, acquires `true` provenance before startup, and now renders
      `unknown`/`unknown`. This is a declared conservative change on a row already awaiting
      resolution. For settled rows with established `false` provenance, an actual restore does not
      alone change their flag. During upgrade a `null` flag renders conservatively; backfill changes
      only nulls, never a freshly admitted `false` row or an already-true row. Assert that a settled
      pre-column install can therefore lose its former ordinary wire facts under the declared
      upgrade policy, and that other operation kinds gain no marker wire keys.

      Repeat the actual restore using a backup containing an open predecessor whose ordinary close
      conditions are unmet. Assert the predecessor is retained and closed by supersession, the
      distinct new record names it and starts unmarked with a `null` grace end, provenance is
      `true`, and the complete new procedure and its close conditions apply. Neither component
      starts before that transaction is acknowledged. Include predecessor cases with unexpired
      wall-clock grace, unfinished rate-present grace, an unconfirmed parent and an unfinished
      account-sweep second pass; test the selected supersession rule's stated consequences. A mere
      process crash must create no new incident or supersession. A lost transaction reply must not
      produce two open incidents or silently continue using predecessor step marks.

      | Install case after successor pass | `disk_effect` / `rescue_exit` |
      |---|---|
      | Old unsettled row exposed to rollback, restored null/null | `unknown` / `unknown` |
      | Fresh (a), null/null, no later actual restore | `none` / `none` |
      | Fresh (b), write marker set, rescue false | `destructive_boundary_crossed` / `unknown` |
      | Fresh (c), write marker set, rescue true | `destructive_boundary_crossed` / `clean` |
      | Formerly fresh unsettled row exposed to another actual restore | `unknown` / `unknown` |
      | Existing unresolved CNF-300-derived row, after actual restore | `unknown` / `unknown` |

```

## Existing landing: CNF-295, whole

Source: `10-conformance-checklist.md:1019–1093` at c824e4fa4d612b231110bc5deb3e88b3b3e90f92. The next item, CNF-296, begins at line 1094.

```markdown
- [ ] **CNF-295** — **The restore rehearsal** (added 2026-09-12, `ADR-0023`). Before the
      first customer payment, by someone other than whoever wrote the procedure: keep a rate in
      force for the no-outage run below, with separate active tenants for the re-extension machines,
      sufficient available balance, requested runway beyond the tested re-claim and otherwise
      satisfied admission conditions; with a `suspend_tenant` parent for another tenant unsettled — once `running`, once `queued` under `OPS-49`'s defer —
      take a backup, then in the lost interval extend a machine's runway from balance, revoke a
      spending token, let a `queued` create order and a `queued` raw-disk install write, and let
      the parent settle and the tenant resume; restore, and run `STO-54`'s procedure in its stated
      order, killing the engine once after the record is committed and before step (2)'s mark
      commits, and once after step (3)'s (added 2026-09-20, `ADR-0023`). Before it, claim a create and a power operation. Assert the
      successor, before any claim, moves both to `needs_reconciliation` and leaves a create queued after step (3)
      `queued`, and that a delete queued on the power operation's machine is then claimed. Again after
      `grace_ends_at`, with every waiting parent confirmed, kill the engine with a confirmed parent claimed: the
      successor returns it to `queued` and it resumes with no second confirmation. Assert of the first
      successor that it continues the incident — it takes the restore branch of the pass and
      quarantines the executed create, and `api` serves nothing until step (3) is marked; of the
      second, that it repeats no marked step — the listener is not taken down again, the token a
      tenant re-issued after step (3) still authenticates, and the record's `grace_ends_at` is not
      rewritten (*amended 2026-09-25, `ADR-0028`*);
      and that when no restore record remains open a restart is an ordinary one, leaving `queued`
      rows alone. Assert: no worker makes a
      provider mutation and nothing writes a disk before the first
      claim (`OPS-32`'s deletion of an orphaned imported image is the one provider call the freeze
      does not stop); the extended machine is not routed into exhaustion before the record's
      `grace_ends_at` passes, and its re-extension is admitted and leaves `grace_ends_at` as written
      (`OPS-41`; *amended 2026-09-25, `ADR-0028`*) — and a second machine extended in the lost
      interval and **not** re-extended is routed once the interval ends, with the extension's
      satoshis back in its tenant's balance and its `runway_until` reading the restored date
      throughout (added 2026-09-12: the grace is one interval, not a repair); the old token authenticates nothing and the
      recovery credential issues a new one (`API-56`); the create and the install are
      `needs_reconciliation`, never claimed, and `OPS-27` resolves the create `observed` where its
      correlator was written before the backup and otherwise leaves it to the operator; the
      `suspend_tenant` parent, in either state, does not resume without operator confirmation; the
      sweep's first pass records no absence and
      its second may; and the operator report names the persisted conservative possible-loss bounds
      and bounding duration where both are known, and explicitly identifies unknown endpoints
      otherwise; it also names every unrecorded machine per account. Repeat across an outage
      starting inside grace and a restore-caused outage:
      after the wall-clock end the actors in `STO-54`'s freeze run, but unfinished funding grace
      still short-defers unfunded attempts in `OPS-41`'s fence transaction. Kill and restart after
      multiple qualifying returns;
      assert recomputation from retained `STO-49` history preserves the unspent time and the
      step-(3) mark and original end remain unchanged. Finish currency A's grace while B has
      unspent grace and a live unfenced machine: closing is refused. Leave B without a rate
      through its bound: closing is still refused until every machine priced in B is recorded
      gone or fenced (`machines.destroy_committed` non-null). Drive `CNF-218`'s no-return
      disposition trace, including its funded machine with no queued attempt, absent outage
      record and provider refusal; assert B ceases to block despite its unspent rate time.
      The refused deletion does not block B's discharge merely because the machine is not
      recorded gone: check its fence, not just the failed attempt. In a separate run, make every
      B machine gone or fenced before its outage bound and assert B's grace obligation is discharged then.
      Then resolve one fenced B machine's episode `abandoned` (`OPS-48`; its fence clears and the
      machine stays live) and assert close is refused again until that machine is gone or fenced
      once more: the discharge is read at close, never latched. In each run, refuse close while any other prerequisite in `STO-56` remains unsatisfied;
      exercise the wall-clock end and the other incident obligations independently, including
      a run with all machines already gone or fenced before the wall-clock end. Only when every
      prerequisite is satisfied close and verify ordinary restart behavior. `CNF-218` carries
      the refused-close/returned-rate worker regressions. *Amended 2026-10-03 (`ADR-0029`):
      withdrawn — "Leave B without a rate through its bound: B ceases to block closure".*
      Exercise known evidence with the old primary unavailable; a last-abort record; null replay
      observation; unavailable source/event clock bounds; timestamp/WAL-order inversion; wrong
      ancestry; WAL holes; backup restore; and interruptions before and after step marks.
      Invalid evidence is never labelled a certified bound. For absent or invalid reporting
      evidence, insert a record with unknown endpoint fields and complete the existing
      procedure; assert no extra reporting-evidence hold. Existing consistency,
      stopping/fencing, acknowledged-record-before-start and all other recovery prerequisites
      still apply. Re-enter the incident and assert endpoints/references unchanged. Complete
      step (3) much later and assert its grace uses its own event, not b, f or restore_instant.
      For every actual restore in this item, supply certified evidence for any asserted known
      `lost_window_starts_at` or `loss_end_at`; otherwise use null endpoint fields with the
      non-null incident-keyed
      `history_evidence_ref` retaining evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).
      (`STO-54`, `STO-56`, `STO-49`, `OPS-15`, `OPS-41`, `LDG-16`,
      `LDG-64`, `API-56`, `OPS-27`, `OPS-32`)
      *Amended 2026-10-23 (`pv-n98`; panel r63, r63c’s Form F′, `docs/research/panels-2026-10/r63/`; owner decision Q2 “Clean up every startup (Recommended)”): extended the successor rehearsal to newly claimed work and a confirmed parent.*
```

## Historical CNF proposals, complete separate Q4 result

Source: `/var/tmp/provisiond-panel-r81/tally.md:143–208`, whole “Separate Q4 result” section. For Q1, D1, D2, D3 and D4 mean its four exact fenced drafts in printed order. Their attributed headings, original landings, caveats and wording are retained verbatim; none is already an exact-text settlement. The mention of A is a historical adaptation, not an r82 candidate.

## Separate Q4 result — conformance addition yes; new gate no

| Reader | CNF addition | New gate | Exact proposed landing |
|---|---|---|---|
| fable | YES | NO | Append to CNF-302 after its supersession paragraph |
| opus | YES | NO | Append to CNF-302 after its supersession paragraph |
| astra | YES | No new specification gate proposed | Append to CNF-302 after its supersession/lost-reply paragraph |
| sol | YES | A conformance addition, not a new gate | Add to CNF-295 |

All participating readers agree on conformance coverage and propose no new specification gate. **No exact CNF wording is settled:** the proposals below are distinct and have not been combined. Q4 is not part of B or a condition on any A/B acceptance. [CNF-302](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L3076) says **“A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks”**; it does not explicitly exercise the absent-record aborted-attempt clock and subsequent committed no-op value. The coverage gap is separate from the pin's actual normative conflict.

### fable — exact proposed case text

```text
Separately drive establishment twice for one actual restore with one retained id: once with
the first attempt's connection dropped before its commit reaches the store, and once with it
dropped after the commit is durable but before its reply. In each run assert exactly one
record carries that id, no refusal occurs, and recovery proceeds after the acknowledged
repeat without operator re-selection. In the aborted run assert the persisted
`restore_instant` equals the inserting retry transaction's own `transaction_timestamp()`,
read in that transaction, and not an instant captured before the first attempt; in the
committed run assert it is the first transaction's and the repeat changes nothing. `STO-56`:
"Repeating establishment with that id when a committed matching record exists MUST affect
that record as a guarded no-op".
```

Fable additionally says: Under A the aborted-run assertion would instead read **“equals the instant selected and retained before the first attempt”**, and the quote would cite A’s unchanged STO-56 sentence. This is a separate adaptation, not text included in B.

### opus — exact proposed case text

```text
For one actual restore, lose the establishment transaction's connection before it commits,
so that no record with the retained id exists, and repeat establishment with that id in a
later transaction whose start time differs: assert exactly one record with that id, its
`restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
provenance initialized in the repeating transaction, and neither component started before
that transaction is acknowledged. Separately let establishment commit, drop its reply and
repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
stored instant, predecessor and step marks, that it is not refused merely because the
repeating transaction starts later, and that the components then start and continue that
incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
algorithm.
```

### astra — exact proposed case text

```text
**Establishment retry clock.** Exercise the following cases for one actual restore per run, retaining the same new incident id N throughout its establishment retries. Run each case with no inherited open incident and with an inherited open predecessor R whose ordinary close conditions are unmet. Use establishment transactions whose observed `transaction_timestamp()` values differ.

In the first case, let the first establishment transaction have timestamp t1, force it to abort, and lose its reply. Verify that N is absent and none of its establishment effects committed. Retry in a newly begun transaction with timestamp t2. Assert that the committed N carries restore_instant=t2, not t1. Lose this transaction’s commit reply too. Keep both components stopped, repeat establishment in a transaction with timestamp t3, and assert a matching guarded no-op preserving t2, the predecessor, step marks, endpoint fields and history_evidence_ref. Acknowledge that repeat before either component starts.

In a separate case, let the first establishment transaction commit N at t1 and lose its reply. Repeat in a transaction with timestamp t2 and assert the same preservation and acknowledgement behavior, with restore_instant still t1.

Use null endpoint fields with retained unknown-endpoint reasons for the unknown-evidence runs. Repeat with certified upper-bound evidence using STO-54’s event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats. Assert no duplicate incident or additional supersession.
```

### sol — exact proposed case text

```text
Exercise establishment for one actual restore with incident id N, for backup restore and separately for restore-class promotion. Begin the first establishment transaction at t1, lose its connection/reply, and establish that it did not commit; assert N is absent. Retry the same actual restore with the same id in a newly begun transaction at t2 distinct from t1. Assert N is inserted once with restore_instant equal to t2. Repeat with an open predecessor and assert atomic supersession.

Separately let the first establishment transaction commit at t1 but lose its reply. Retry at distinct t2 and assert a guarded no-op preserving N’s original restore instant, predecessor, step marks, grace end, endpoints and evidence reference, without creating another incident. Neither component starts before establishment or its matching no-op is acknowledged.

Use null endpoint fields with a non-null incident-keyed evidence reference retaining the unknown-endpoint reasons. Also exercise the event-clock upper-bound recipe with certified evidence for the transaction that inserted N; assert it uses the persisted incident instant rather than an uncommitted attempt’s instant or the no-op transaction’s timestamp.
```


## Historical insert/refuse-overlap text and checked verdict

Source: `/var/tmp/provisiond-panel-r81/opus.md:48`, exact original objection:

```text
2. **Two MUSTs overlap.** "finds no committed matching record … MUST insert" also covers a committed N whose predecessor differs. There one MUST says insert and the next says "MUST be refused". The intended condition is "no committed record with that id".
```

Source: `/var/tmp/provisiond-panel-r81/tally.md:65–74`, whole insert/refuse-overlap subsection including its verdict:

### Insert/refuse overlap: conditional ambiguity, not a verified unavoidable conflict

Opus writes:

> “finds no committed matching record … MUST insert” also covers a committed N whose predecessor differs. There one MUST says insert and the next says “MUST be refused”.

This identifies a real concern about **matching**. It is not established that this word must mean “matches every asserted field” rather than “matches that id”. B introduces the condition as **“establishment with that id”**, then separately requires refusal for **“A mismatch in the committed id's restore instant or predecessor”**. On an identity match with an actually incompatible predecessor assertion, refusal need not treat the committed id as absent. No pinned definition specifies a full-payload predicate or mandates entering both branches.

With opus's full-payload interpretation the obligations overlap on its mismatch trace. With identity lookup followed by validation they do not. These are rival readings of an unspecified comparison boundary. No unavoidable contradictory MUST or changed conformance/theorem verdict is verified. The manager does **not** replace the condition with opus's clearer “no committed record with that id”, delete the instant arm, select R2, or count a repair as acceptance of B. The ambiguity and dissent stay on record for the owner.


Source: `/var/tmp/provisiond-panel-r81/tally.md:41–64`, the separate timestamp-comparator objection and checked verdict, complete subsection:

## Opus's blocking claim, checked against the exact words

### Reading 1 — mandatory comparison with the repeat's new timestamp: not verified

Opus writes:

> *Reading 1:* the natural upsert compares the repeat's own `transaction_timestamp()`.

and concludes:

> Then every repeat in case (ii) mismatches (t2 ≠ t1) and is refused, every time.

> **This is a verified blocking loss (rule 3).**

The comparator is an added premise. [Exact B](/var/tmp/provisiond-panel-r82/check/form-B.txt) instead requires:

> Repeating establishment with that id when a committed matching record exists MUST affect that record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant.

The retained [STO-54 definition](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636) says **“restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident.”** A no-op transaction does not insert that incident. The definition does not turn a repeating transaction's timestamp into an expected value for an already committed record.

Concrete trace: T1 inserts N at t1, closes R if present and commits; its reply is lost. T2 at distinct t2 finds committed N. B requires preserving N's original t1 and marks on the matching no-op, then acknowledgement. [STO-54's boundary](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1632) says **“MUST start neither component until the transaction that commits `STO-56`'s record (below) has been acknowledged”**; B explicitly permits the matching repeat's acknowledgement. No clause orders a comparison of t2 with t1. An implementation that refuses this otherwise matching repeat because t2 differs would violate the explicit no-op duty; it is not a failure forced by B. This is a satisfiable trace through the printed obligations, not adoption of a comparison algorithm.

The pinned [r77b tally](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/tally.md#L41) likewise distinguishes an unstated current-open-row comparator from P's required matching no-op. That history corroborates the distinction; the current verdict follows from B's own words.


## Questions — answer independently

### Q1 — exact CNF case text and landing

Pick one of D1–D4 in the complete Q4 extract above, or give one complete exact merged text, and choose its landing: CNF-302 or CNF-295. Print the complete final text even if choosing an existing draft, and the exact insertion point in that item. It must test B as adopted: an aborted first attempt leaves no committed record; a retry inserts with its own transaction's restore_instant; a retry finding the committed matching record is a guarded no-op that keeps the original instant and step marks. Use distinct transaction timestamps so the clock assertion distinguishes the two paths. Add no new gate, and assert nothing B does not require. Existing pinned duties may remain fixture prerequisites, with their owner and exact source words identified; do not silently turn a preferred algorithm, stronger check or guarantee into B's rule.

For each D1–D4, return ACCEPT / CANNOT ACCEPT as printed with its proposed landing, and identify any exact repair needed. For a merged text, print it whole, name its landing, and distinguish any new assertion from what the adopted words require. Do not combine different texts or landings into one vote. Explain the concrete wrong result your chosen case catches and any assertion the existing drafts overreach. A requested criticism is separate from your final pick.

### Q2 — B's wording, exact alternatives

KEEP: keep “finds no committed matching record” verbatim.

REPLACE: replace only “finds no committed matching record” with “finds no committed record with that id”. In B's preserved line wrap this is the span `finds no` followed by `committed matching record`; change only those words. All other B words remain as printed, including its committed-instant/predecessor refusal and matching no-op clauses. No fuller alternative paragraph is in this question.

Give your final preference KEEP / REPLACE, and separately ACCEPT / CANNOT ACCEPT for each. Say separately whether the replacement changes (a) behaviour, (b) a requirement, or (c) a check's strength. Support a claimed change with the exact owner words and a concrete trace or checked verdict, and say what the original phrase protects. If any answer says the replacement changes one of these, that answer will be reported, not enacted: the owner adopted B as printed. This wording question does not authorize a substantive departure or removal of another clause.

End with `Final Q1: <D1/D2/D3/D4 or exact merged form; CNF-302/CNF-295; insertion point>` and `Final Q2: <KEEP/REPLACE; behaviour change YES/NO; requirement change YES/NO; check-strength change YES/NO>`. Preserve exact-text acceptability separately from preference.
