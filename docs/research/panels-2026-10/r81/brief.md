# r81 — restore-record establishment retry clock

Read this brief and `/var/tmp/provisiond-panel-r81/notes.md` whole. Review the local branch's pinned commit **c824e4fa4d612b231110bc5deb3e88b3b3e90f92**; each reader has its own clean clone of the LOCAL repository, not origin. The branch is local and unpushed. This is a reading round only; no adoption, implementation, tracker write, PR action or follow-on round is authorized in this turn.

One actual restore attempts to establish incident N. The first attempt loses its connection/reply without committing. A later transaction finds N absent and inserts it. Which event time must the persisted record carry? A preserves the selected instant across attempts; B preserves the inserting-transaction definition and qualifies the absent-record retry. Both are exact complete candidate amendments below. Neither is a recommendation. The judge's recommendation is printed only as part of its historical section. The proposed texts have not been independently reviewed as whole forms.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR or start subagents/background work. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r81/tmp/` in a reader-specific subdirectory. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' output/clones, or unrelated main-worktree content. This supplied packet and the pinned sources in your own clone are the evidence. If testing, capture the command's actual exit unpiped. Do not wait on other readers. Return a substantive final answer before the 3600-second launcher limit; aim for <=1800 words plus exact alternative text if needed.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

The main worktree and committed closure stay untouched: pv-ymjo is already closed in the committed JSONL, but the Run exited 1/blocked and acceptance was withheld. A later authorized fix round must keep that closure consistent with its actual outcome. The drain holds here; pv-kwuf must not start while pv-ymjo holds the worktree.

## Preliminary checks and checked external fact

Check 2a compared both landed restore-instant paragraphs, including every new sentence mentioning that instant, with P/C5: they agree in words after line wrapping and identifier backticks. P itself prints the disputed retention rule; this is not an Implementer departure. The existing STO-54 event-clock definition is unchanged from base 7974839. Exact passages follow.

Check 2b searched ADRs, docs (including archived r77/r77b/r80), and `.beads/issues.jsonl` for `restore_instant`, `transaction_timestamp`, `lost-reply` and `restore instant`. No recorded owner answer found addresses which clock wins when P's first establishment attempt did not commit. UO defines the transaction clock; P later adopts its retained retry instant. The printed r77b lost-reply tally examines a committed-first-attempt trace and says an uncommitted attempt establishes N once, without resolving this clock pair. Review that conclusion yourself; the source passages follow.

The owner chose pv-kwuf's "Whole milliseconds (Recommended)" for K-EXACT's **Startup-lock wait bound**. Its exact type-cell candidate is printed below; it concerns startup timeout inputs, not `restore_instant`. Neither candidate here changes that setting, SQL timeout serialization, or timestamp precision. The r79 E-KEEP disposition for the existing reporting certificate is retained: the source recipe's clock-error wording is not broadened into a new precision policy here.

Preparation independently checked PostgreSQL 18's [Current Date/Time documentation](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT): `transaction_timestamp()` is the current transaction's start time. This is a documented semantic check, not a local SQL experiment. Check the PostgreSQL claim yourself as part of answer 1. A later transaction can begin at a different instant after the first one aborts; the conflict trace assumes those instants differ.

## Run evidence

### Judge: whole “Blocking passages and trace” section

Source: `/home/user/projects/provisiond-spec/.rloop/runs/20261028T202329.236758584Z-557505/finished.md:7–27`; retained Run artifact.

```text
## Blocking passages and trace

Both passages are in `05-persistence.md`:

- `STO-56`, lines 1442–1449, adds: “The operator MUST select and retain one new incident id and restore instant per actual restore before attempting establishment, and reuse both on a lost-reply retry.” It also requires: “Repeating establishment with that id MUST affect the matching record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant.”
- `STO-54`, lines 1636–1641, already said before this Run: “For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident.” It continues: “This is the event time of incident creation, not the time of the recovered history.”

PostgreSQL defines `transaction_timestamp()` by the current transaction's start time. This was independently checked against [PostgreSQL 18, Current Date/Time](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT).

Consider one actual restore with establishment id N and chosen instant t1. The first establishment transaction does not commit, its connection/reply is lost, and no record N exists. A subsequent transaction at t2, with t2 distinct from t1, must insert N if recovery is to proceed. The readings lead to different persisted values:

1. Preserve the selected per-restore instant t1 on the retry. This follows the new retention rule, but t1 is not the timestamp of the transaction that inserts N.
2. Insert N with t2, the inserting transaction's timestamp. This follows the existing event-time definition, but changes the instant retained for this actual restore.

The committed-first-attempt case has no such timestamp conflict: a matching repeat can preserve the existing row's instant. The missing case is an uncommitted first attempt. Declaring the second attempt a different actual restore, excluding aborted attempts from the fixture, or silently changing either clock rule would add policy that the brief forbids. No gate currently checks this interaction.

This is separate from the archived R2 predecessor-comparison dissent. No predecessor-comparison algorithm was selected, and R2 remains excluded.

**Clarification requested:** For the same actual restore, after an establishment attempt did not commit, must a later successful insertion use the retained first-attempt instant or its own transaction start? Which owning definition should change?

**Recommendation, not an adopted amendment:** preserve the selected package's same-id/same-instant behavior and explicitly revise the event-time definition to identify the retained first establishment-attempt instant. The owner must approve that change and its consequences for reporting evidence, the decision record and quoted formal documentation. Alternatively, retain the existing insertion-transaction definition and expressly qualify the retry-time rule for an absent incident. Neither alternative is authorized by the current package, and neither was applied.
```

### Round-one finding (complete feedback artifact)

Source: `/home/user/projects/provisiond-spec/.rloop/runs/20261028T202329.236758584Z-557505/feedback-1-astra.md:1–26`; retained Run artifact.

```text
## 0. What I could not do

I ran everything I needed. Both required unpiped runs of `nix develop --command bash tools/check-all.sh` exited **0**.

Reviewed `12c3da0` and `82f5241` against the specified baseline, including working-tree/untracked checks and excluding the requested paths. Verdict: **FAIL**.

## 1. Findings

**Blocker — retained retry instant conflicts with the existing transaction-time definition.**

At [05-persistence.md:1442](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1442), new `STO-56` requires selecting and retaining an incident id and restore instant before establishment, then “reuse both on a lost-reply retry.”

However, [05-persistence.md:1636](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636) defines `restore_instant` as “transaction_timestamp() of the newly begun transaction inserting this incident.” I verified this definition already existed at the review baseline. PostgreSQL defines that function using the current transaction’s start time. [PostgreSQL documentation](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT)

Consider an establishment attempt at `t1` whose connection fails and whose transaction does **not** commit. A retry at `t2` finds no incident and must insert it:

- Retaining `t1` satisfies the new retry requirement but violates the insertion-transaction timestamp definition.
- Using `t2` satisfies that definition but violates the requirement to reuse the retained instant.

This leaves the uncommitted-first-attempt retry without a compliant outcome. Verified by reading both clauses and tracing that case; the passing gates do not check this interaction.

The brief requires conflicting passages to be escalated for an owner decision. Resolve this conflict before acceptance; it is separate from the excluded R2 predecessor-comparison repair.

## 2. Suggestions

None.
```

## Landed owning passages, whole

### STO-56, whole

Source: `05-persistence.md:1419–1487` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

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

### STO-54, whole

Source: `05-persistence.md:1600–1809` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
**STO-54** **ADDED 2026-09-12 (`ADR-0023`) — a restore is a recovery incident with a stated
procedure, never a restart.** A store restored from backup lands at some instant `T − Δ` before
the failure, and an engine brought up on it as if nothing happened *performs* destructive actions
on state the restore rewrote: an extension lost in Δ routes a paid machine into `LDG-14`, a token
revoked in Δ is live again (`API-56`), a `queued` create that already ordered in Δ orders again
(on a restart `OPS-15` inspects `running` rows only), and a `suspend_tenant` parent restored
unsettled re-runs a fan-out the operator may have reversed. So:

- **Durability posture.** The deployment runs synchronous streaming replication to two standbys (`STO-7`) and continuous
  WAL archiving, and states a **recovery point** — the greatest age of a committed write not yet in
  a separate failure domain — as a human row on `OVR-19`, with its alarm threshold a
  startup-validated value alarmed on `OVR-18`'s model. The number is not the safety argument: a
  create dispatches in one second, a deposit mints in one, an extension lands in one. The
  procedure's order below is.
- **Promoting the standby that holds every acknowledged commit is a restart** (*added 2026-10-23, `ADR-0045`*).
  After every engine and `api` process connected to the old primary has stopped, both standbys `OVR-19` names
  report the end of the WAL each has flushed on the old primary's timeline, and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal): every acknowledged commit was
  flushed by one of them, and both hold a prefix of one WAL sequence, so every standby at the maximal reported end holds them all and its promotion
  loses none. The
  engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
  continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
  every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
  component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
  standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
  store. `OVR-19` then names the other standby and the rejoining old
  primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
  without both standbys' report, with a report on another timeline, or of a standby whose reported end is behind the other's, of a standby `STO-7` does not name, or after the primary committed without one of them, served a component before it had caught
  up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
  `STO-56`'s record is committed into the promoted store before either component is started.
  Only an operator starts a
  promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
  without a primary until both standbys report or an operator decides.
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

  Publish possible loss within [b,f] and its bounding duration only when both endpoints are
  known. Include b because the lower certificate guarantees commits acknowledged strictly before
  b. Otherwise publish each known bound, identify every unknown endpoint and state that no
  finite duration is established; identify clock/provenance assumptions for known bounds.
  Missing reporting evidence does not hold incident creation, the existing restore procedure or
  component startup once its existing prerequisites are satisfied. Continuations reuse the
  persisted endpoints and evidence unchanged. Backup restores use the same contract.

  (1) *Before the startup lock:* the public listener is down;
  the possible-loss report defined above is published to the operator; exactly five
  things are frozen, because starting either component to reconcile starts everything it hosts —
  the exhaustion sweep, `LDG-64`'s canceller, `API-34`'s time-to-live sweep, `STO-14`'s and
  `STO-43`'s retention, and `OPS-15`'s `suspend_tenant` exception — and the freeze lifts at
  `grace_ends_at` (`STO-56`; *amended 2026-09-25, `ADR-0028`: until then "the freeze lifts when
  step (3) completes"*), except the exception, whose own later condition stands on top: it stays off
  until the operator has confirmed or cancelled every waiting parent; `OPS-27`'s and `OPS-32`'s
  sweeps, the meter, re-derivation, the solvency check and the settlement watcher are not frozen,
  and the account sweep's two passes are a step below; `provider_account_status` is re-established,
  since `STO-36` routes on it. *Withdrawn 2026-09-25 (`ADR-0028`): "every machine whose stored
  `runway_until` has passed has `destroy_not_before` set to **the restore instant plus one
  re-derivation interval** — `LDG-16`'s own grace for a date moved backward by something other than
  consumption, written as the deadline itself rather than as a start, so that a second run of an
  unmarked step cannot re-apply it from a fresh clock (`LDG-64` persists its deadline for the same
  reason) (amended 2026-09-21, `ADR-0026`: the withdrawn form set `exhausted_since` to the restore
  instant, one slot serving both this grace and the confirmation wait, which is why re-running this
  step could "backdate an `exhausted_since` a later re-derivation had set" — `ADR-0023`'s own reason
  for the step marks. Two facts cannot collide in one slot, and re-keying that slot to an
  observation instead was refused because a rate arriving seconds after a restore would then end
  the grace)" — the stored unpaused end is `STO-56`'s `grace_ends_at`, and no machine
  carries a deadline.* *Withdrawn 2026-09-23 (`ADR-0027`), with the reference: "and
  **any `rate_confirmation_ref` already present is preserved**, because a restore is not an
  observation and discharges nothing".* (2) *Before the first claim:* every `queued` create, install
  and rescue inventory is moved to `needs_reconciliation` — a repeat is a second order, a second
  disk write, a second boot into rescue — and `OPS-27` establishes what happened rather than doing
  it again; the goal-state kinds (delete, power, end-rescue, release attachment, reverse DNS)
  re-run, since `OPS-11` classifies "already in the target state" as `succeeded`; a `suspend_tenant`
  parent found `running`, or `queued` and unsettled (`OPS-49`'s waiting parent is `queued`), waits
  for operator confirmation instead of resuming. Its mark keeps this step from running again; it never suppresses `OPS-15`'s pass over `running` rows, which runs at every startup. (3) *Before the first `api` request:* the watch set
  is re-derived (`STO-32`), both rails are replayed (`STO-31`), `SEC-39`'s counters are re-seeded,
  every tenant's credential generation is bumped — the restored store cannot know which tenants
  revoked inside Δ, so every spending token dies and each customer re-issues through the recovery
  credential (`API-56`) — and `deposits.derivation_index` is skipped forward by the stated gap
  (`OVR-19`) before any deposit is minted.
- **Marker provenance.** An operation of any kind other than install or rescue inventory MUST be
  inserted with `restore_markers_untrusted` = `false`; this column has no marker-rendering effect
  for those kinds. A new install or rescue-inventory operation MUST be inserted with
  `restore_markers_untrusted` = `false` in its admission transaction. On each actual store restore,
  before either component starts, the acknowledged transaction that establishes the restore record
  MUST set this column `true` on every surviving install or rescue-inventory row whose status is
  `queued`, `running` or `needs_reconciliation`. The marker columns themselves are preserved. A
  successor continuing an existing incident after a process crash MUST NOT repeat this
  initialization. Once `true` the column MUST NOT be cleared on that operation, including at
  incident closure or payload purge. Another actual restore applies the initialization again. An
  open incident inherited from the restored store is superseded under `STO-56`; an ordinary process
  successor never supersedes it. The column is operation metadata and is not added to
  `request_summary`'s closed enumeration.

  The restore quarantine and each startup pass preserve `restore_markers_untrusted`. In particular a
  row newly admitted after step (3), interrupted by a process crash, and moved by its successor
  retains `false` unless a later actual store restore invalidated it. Whether the incident is still
  open does not itself invalidate markers of newly admitted work.

  **Provenance upgrade.** The release that adds the column leaves it nullable; see `STO-13`. For an
  install or rescue-inventory row, a `null` column MUST be treated as untrusted for rendering. The
  backfill MUST set a still-null column `true` on every existing install or rescue-inventory row,
  including a settled row, and `false` on other kinds; it MUST NOT overwrite a non-null value. After
  previous-release writers are retired and the remaining nulls are backfilled, a later release
  tightens the column to non-null. No pre-column marker history is treated as sufficient to
  initialize `false`. This deliberately conceals legacy facts, including settled retained errors; it
  does not claim those facts were rolled back.
- **The procedure survives its own interruption, because the incident outlives the process.** The
  restore commits `STO-56`'s **restore record** — the restore instant, and which of the three steps
  have completed — before either component is started, and **a process that starts while a restore
  record is open is continuing that incident, not restarting**, whatever ended its predecessor. It
  resumes at the first step the record does not mark, and every restriction above stands where its
  step's mark is missing: the quarantine and the closed listener follow the record's marks exactly
  as they follow the steps in a run nothing interrupts, and the freeze follows the marks and the
  record's `grace_ends_at` (`STO-56`), so a process that starts after step (3)'s mark and before
  that instant keeps the five actors frozen (*amended 2026-09-25, `ADR-0028`*). Without the record,
  a process that died between the restore landing and step (2)'s pass is succeeded by one that comes
  up under `STO-5`'s restart rule on a restored store — the boot this requirement exists to prevent,
  on which every destructive case `ADR-0023` lists fires. **A marked step does not run again**: the
  grace is written once per incident — `STO-56`'s `grace_ends_at`, in step (3)'s mark transaction —
  the credential generation is bumped once, the derivation index is skipped once, and a customer
  that re-issued after step (3) keeps the token it re-issued. A step interrupted before its mark
  commits does run again, and that repeat is safe on each of its writes: the instant is read from
  the record and never re-computed, step (2)'s quarantine is guarded on `(id, status = queued)`, and
  step (3)'s two forward writes only rise — a second bump can invalidate and never resurrect, and a
  second skip of `deposits.derivation_index` allocates forward, the only direction that column moves
  — while `grace_ends_at` is written in the mark's own transaction (`STO-56`), so an interruption
  before the mark leaves it null and the repeat writes it once (*added 2026-09-25, `ADR-0028`*). The
  operator closes the record only under `STO-56`'s close rule (*amended 2026-10-03, `ADR-0029`*).
  When no restore record remains open, a process that starts is an ordinary restart; for
  supersession and the new open record, see `STO-56`. *Added 2026-09-20 (`ADR-0023`): the
  procedure ordered its steps and said nothing
  about a crash inside them, so `OPS-15`'s restore branch rested on knowledge no engine held.*
- **`OPS-32`'s complete pass is a step, not a gate, and runs twice.** The first pass may record
  nothing about absence: `provider_observations` written in Δ are gone, so `PRV-36`'s effective
  window has been narrowed by the restore, a narrowing `STO-53` says is "never an engine write". A
  second pass separated by the effective window is what may record absence. A machine the sweep
  finds unrecorded is reported and never attached (`OPS-32`); the restored engine cannot tell a
  machine created in Δ from one created by hand, and the report says so per account.
- **Rehearsed.** The procedure MUST have been executed end to end before the first customer
  payment, by someone other than whoever wrote it, on `CNF-137`'s model, and the rehearsal drives
  the four destructive witnesses above through it (`CNF-295`).

*What the restore does not repair, stated so it is not assumed: **an extension lost in Δ is not
rebuilt** — `OPS-41` owns the opportunity to extend again and its funding-only paused measure;
extension admission remains subject to `LDG-40` and `LDG-62`. Routing follows `LDG-16`, and
cancellation follows `OPS-41`, including when the rate is absent (*amended 2026-10-02,
`ADR-0029`; amended 2026-09-25, `ADR-0028`: the interval runs from step (3),
when the tenant can first act, not from the restore instant, and **a machine already fenced when the
grace begins gets no extension from it** — its fence stayed set because the provider refused
(`stalled`), because nobody yet knows what the provider did (`uncertain`) or because the provider
accepted a dated cancellation (`scheduled`); its route back is `OPS-42`'s, and a retry's
claim follows `OPS-41`'s grace rule like every claim — in `ADR-0028`'s words, “"outside the grace"
means no extension, not exemption from the wait”; see that ADR for the rejected fence-clearing
alternative and its reasoning*); the extension's satoshis are back in the tenant's balance, because
the debit that paid for it rolled back with it, and the backward move of `runway_until` is visible to the caller on
every machine read — the possible-loss report is published to the operator, and **no notice reaches a tenant,
by decision** (*2026-09-13: the caller is a program that already polls `runway_until`, the satoshis
are back in its balance, and the harm is bounded to one interval, so a per-tenant channel this set
has not built under `ADR-0005` is not built for this. Added 2026-09-12; until then this requirement
and `ADR-0023` described the grace as what "stands between
the restore and the destroyed disk", which is true only of a tenant that re-extends in time*); a
debit lost in Δ is re-metered
by `LDG-38`'s start rule, from the mark the backup holds, and the rate boundaries `LDG-38` would
have split the span at are gone with the `rate_observations` written in Δ; a gone-write lost in Δ
extends the customer's charge to the next complete pass (`LDG-74`), and the correction is an
operator `LDG-5` entry; a commitment is "not a ledger entry" (`LDG-30`) and is not rebuilt from
payments;
`STO-49` rows written in Δ are lost, and where `LDG-64`'s outage start is replayed from them its
start and its computed deadline move with what the backup holds, and the possible-loss report
identifies uncertainty in that history clock (*amended 2026-10-02, `ADR-0029`*); a `running` install
found after a restore goes to `needs_reconciliation` with its `OPS-45` marker columns as the backup
holds them, so a `null` marker there does not mean the disk is untouched and the operator resolves
such a row as ambiguous. See the marker-provenance rule above and `WIR-9a` for rendering; `LDG-72`'s
checks pass on a consistent restore and prove nothing about it.*
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): adopted the synchronous posture and classified promotions by WAL history with operator choice for a restore.*
*Amended 2026-10-23 (`pv-n98`; panel r63, r63c’s Form F′, `docs/research/panels-2026-10/r63/`; owner decision Q2 “Clean up every startup (Recommended)”): distinguished step (2)’s durable mark from the per-startup running-row pass.*

*Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decision “I don't think we should tolerate a gross operator mistake like restoring some backup with the system running”; `ADR-0047`): added the stopped-system restore lead-in.*
```

## P’s printed form and owner answer

The following are P’s common owner amendments and selected preservation paragraph. The event-clock definition was not replaced by P. C5 is common to both printed packages. R2 remains outside this question.

### P/C1: STO-54 provenance upgrade

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:288–290` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
Add this upgrade paragraph to STO-54's new marker-provenance block:

> **Provenance upgrade.** The release that adds the column leaves it nullable; see STO-13. For an install or rescue-inventory row, a null column MUST be treated as untrusted for rendering. The backfill MUST set a still-null column true on every existing install or rescue-inventory row, including a settled row, and false on other kinds; it MUST NOT overwrite a non-null value. After previous-release writers are retired and the remaining nulls are backfilled, a later release tightens the column to non-null. No pre-column marker history is treated as sufficient to initialize false. This deliberately conceals legacy facts, including settled retained errors; it does not claim those facts were rolled back.
```

### P/C2: STO-54 marker provenance

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:294–298` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
### C2 — marker provenance (both packages)

Add to STO-54 before its procedure-survives-interruption bullet:

> **Marker provenance.** An operation of any kind other than install or rescue inventory MUST be inserted with restore_markers_untrusted = false; this column has no marker-rendering effect for those kinds. A new install or rescue-inventory operation MUST be inserted with restore_markers_untrusted = false in its admission transaction. On each actual store restore, before either component starts, the acknowledged transaction that establishes the restore record MUST set this column true on every surviving install or rescue-inventory row whose status is queued, running or needs_reconciliation. The marker columns themselves are preserved. A successor continuing an existing incident after a process crash MUST NOT repeat this initialization. Once true the column MUST NOT be cleared on that operation, including at incident closure or payload purge. Another actual restore applies the initialization again. An open incident inherited from the restored store is superseded under STO-56; an ordinary process successor never supersedes it. The column is operation metadata and is not added to request_summary's closed enumeration.
```

### P/C3: selected preservation paragraph

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:302–306` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
### C3 — the only wire-policy difference

**Y-PROV-R only**, after C2 add:

> The restore quarantine and each startup pass preserve restore_markers_untrusted. In particular a row newly admitted after step (3), interrupted by a process crash, and moved by its successor retains false unless a later actual store restore invalidated it. Whether the incident is still open does not itself invalidate markers of newly admitted work.
```

### P/C4: STO-54 running-install replacement

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:318–320` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
Replace STO-54's running-install passage (source 1657–1662, from “a running install” through its 2026-09-16 note) with:

> a running install found after a restore goes to needs_reconciliation with its OPS-45 marker columns as the backup holds them, so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous. See the marker-provenance rule above and WIR-9a for rendering;
```

### P/C5: complete field/supersession/retry words

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:326–338` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
### C5 — inherited-open-record supersession (both packages; NEW POLICY)

In STO-56's opening field list, replace “and closed_at, nullable.” with:

> closed_at, nullable, and supersedes_incident_id, nullable, a foreign key to the retained predecessor record.

In the same opening paragraph, replace “and closed by the operator” with “and closed by the operator under the rules below”. Keep “One row per restore” and the partial unique open-row index. After its opening paragraph add:

> **Actual-restore supersession.** On an actual store restore whose restored store contains an open incident R, the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R in supersedes_incident_id, with the new restore instant, steps_completed = 0, grace_ends_at = null and closed_at = null. R is retained. For provenance initialization and the start boundary, see STO-54. Supersession is the sole exception to the ordinary close conditions below: it replaces the predecessor's outstanding recovery obligations with the new incident's full procedure and close conditions, and no predecessor step mark satisfies a new step. No component starts between closing R and establishing the new record. Where the restored store has no open incident, the new record has supersedes_incident_id null. A process crash without an actual store restore creates and supersedes no incident.

Add immediately after that paragraph:

> The operator MUST select and retain one new incident id and restore instant per actual restore before attempting establishment, and reuse both on a lost-reply retry. Repeating establishment with that id MUST affect the matching record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant. A mismatch in the id's restore instant or predecessor MUST be refused with both components stopped. The initial establishment or its matching no-op repeat MUST be acknowledged before either component starts. A new actual store restore uses a distinct id even when the predecessor incident is still open.
```

### P/C5 ordinary close and C6 supersession assertion

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:342–356` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
Replace STO-56's “The operator MUST NOT close the record until” lead with:

> Except for the atomic supersession above, the operator MUST NOT close the record until

Keep every existing ordinary close condition and its late-attach check. The exception intentionally replaces outstanding obligations with a full fresh procedure and fresh grace. It is **not asserted to preserve every predecessor-specific deadline or paused-grace verdict**. Trace those consequences against OPS-41, STO-49, STO-54 and STO-56 and name any necessary collateral amendment. If the new exception is unsafe or underspecified, vote AMEND/CANNOT ACCEPT; do not silently invent a lifecycle or presume the owner approved it. No claim that a nested restore is currently implementable is being made.

### C6 — exact conformance additions (both packages)

Append to CNF-302:

> Keep a restore incident open through the following paired cases. Restore a backup with an unsettled install whose markers are null although its destructive phase and rescue dispatch occurred in the lost interval. Complete step (3), then assert the old row renders both keys unknown. Admit separate fresh raw-disk installs after step (3), and crash the engine while each remains running: (a) before either marker write, (b) after the write-started marker and pre-rescue false marker have committed, (c) after the write-started marker and clean rescue-exit true marker have committed but before settlement. Run the successor's startup pass and assert each row is needs_reconciliation, with no replay or automatic deterministic settlement. Assert the selected package's fresh-row table values. Repeat successor startup, close the incident under its ordinary close conditions, and purge payloads; assert the retained wire values do not change merely because of those events. In another actual restore from a backup containing a still-unsettled formerly fresh row, assert both keys now render unknown. For rescue inventory repeat the old-row and later-restore cases with rescue_exit unknown under both packages; for separate fresh rescue-inventory rows with rescue marker null, false and true assert unknown, unknown, unknown under Y-WIDE-R and none, unknown, clean under Y-PROV-R. Do not write an install write-started marker or introduce disk_effect on that kind. Check provenance and rendering across a lost transition reply and a repeat.
>
> Separately construct CNF-300's unresolved failed-rescue-exit row with disk_effect none and rescue_exit unknown without a prior restore, then back it up and actually restore it. It remains needs_reconciliation, acquires true provenance before startup, and now renders unknown/unknown. This is a declared conservative change on a row already awaiting resolution. For settled rows with established false provenance, an actual restore does not alone change their flag. During upgrade a null flag renders conservatively; backfill changes only nulls, never a freshly admitted false row or an already-true row. Assert that a settled pre-column install can therefore lose its former ordinary wire facts under the declared upgrade policy, and that other operation kinds gain no marker wire keys.
>
> Repeat the actual restore using a backup containing an open predecessor whose ordinary close conditions are unmet. Assert the predecessor is retained and closed by supersession, the distinct new record names it and starts unmarked with a null grace end, provenance is true, and the complete new procedure and its close conditions apply. Neither component starts before that transaction is acknowledged. Include predecessor cases with unexpired wall-clock grace, unfinished rate-present grace, an unconfirmed parent and an unfinished account-sweep second pass; test the selected supersession rule's stated consequences and report collateral normative/checked-verdict changes. A mere process crash must create no new incident or supersession. A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks.
```

### P/C7 formal boundary

Source: `docs/research/panels-2026-10/r77/r77b/brief.md:368–371` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text

Both packages add admission metadata, a retained column, staged migration/backfill, a bulk provenance write before startup, and supersession policy/metadata. Recovery latency and WAL cost are unmeasured; unsettled backlog is not assumed small. Conservative upgrade deliberately conceals legacy facts, including settled error facts. The already-reconciling-row change is deliberate. W additionally conceals trustworthy fresh facts permanently for each affected operation and writes the bit during each specified transition; P preserves that provenance distinction. The proposed supersession grants a new full recovery procedure/grace and replaces predecessor obligations, with any further necessary collateral edits still a reason to reject this printed form. None of these costs is called negligible or approved by the owner.

Neither package changes OPS-15's interrupted-operation settlement, authorizes replay, proves bytes landed, or infers an actual rescue session from status. The formal Rescue helper still lacks a restore-provenance input; inspect whether the candidate changes a formalized clause that needs a paired Lean edit under AGENTS.md/ADR-0025. Report coverage separately from a contradiction; no new formal/runtime coverage is claimed by these candidates.
```

### Owner answer, verbatim

Source: `docs/research/panels-2026-10/r77/owner-decisions.md:24–24` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
Owner answer (verbatim): "Adopt P (Recommended)"
```

Source: `docs/research/panels-2026-10/r77/owner-decisions.md:26` (first sentence), at the pin:

> Meaning: adopt package P as tallied in /var/tmp/provisiond-panel-r77/r77b/tally.md, with only the wording-only repairs that tally verified and counted toward P (it lists them); nothing else.

### Archived committed-first-attempt trace

Source: `docs/research/panels-2026-10/r77/r77b/tally.md:39–40` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
1. Initially the restored store holds open R. Ordinary closure is forbidden by `STO-56:1394–1402`: “The operator MUST NOT close the record until”, including “grace_ends_at has passed”. Its index permits “at most one row” with null closed_at (`:1377`). Printed C5 expressly excepts atomic supersession from that prohibition; it closes R and opens distinct N naming R, unmarked with null grace. C2 writes provenance in that same acknowledged transaction.
2. The transaction commits but its reply is lost. Stored N has predecessor R; R is retained and closed. The operator retains N's chosen id and restore instant. This is a real lost-reply case: `STO-54:1557–1559` says deployment “MUST start neither component until the transaction that commits STO-56's record … has been acknowledged”. Components therefore remain stopped pending a matching repeat.
```

### Archived matching-repeat and uncommitted-attempt scope

Source: `docs/research/panels-2026-10/r77/r77b/tally.md:42–42` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
4. The stronger claim that the printed package necessarily refuses every retry is not verified. C5 also says **“Repeating establishment with that id MUST affect the matching record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant.”** No clause says to recompute a committed request's predecessor from today's open row. Choosing N as a fresh predecessor for the same request cannot be imposed over that explicit matching-id obligation. The successful trace the four other readers give is: match N, preserve N's predecessor R/instant/marks, acknowledge the no-op, then start and resume N. An uncommitted first attempt instead establishes N once. A distinct actual restore uses a distinct id.
```

### Counted STO-54 after-close wording repair

Source: `docs/research/panels-2026-10/r77/r77b/tally.md:67–67` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
  > The operator closes the record only under `STO-56`'s close rule (*amended 2026-10-03, `ADR-0029`*). When no restore record remains open, a process that starts is an ordinary restart; for supersession and the new open record, see `STO-56`.
```

## Existing event-clock consumers and reporting evidence

This is the source inventory for clock meaning and its consumers, including generic evidence consumers whose words are proposed unchanged. Frozen research records and committed historical comments remain evidence, not amendment targets. Current owning clauses are printed above.

### Formal module clock paragraph

Source: `tools/formal/Provisiond/Restore.lean:21–28` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text

`Params` lists the guards dated amendments added, each a field so that removing it is a one-token
change a witness theorem exercises (`ADR-0025`). Every model here is one tenant, one machine, one
engine (`OPS-47`), and time does not advance: `now` abstracts the incident-creation event
clock. `STO-54` defines that event: "restore_instant is transaction_timestamp() of the newly begun
transaction inserting this incident." The SQL definition is new; this model does not establish
it or model recovered-history bounds. Interval/certificate publication and its evidence protocol
remain outside the model's scope.
```

### Formal step-(3) clock distinction

Source: `tools/formal/Provisiond/Restore.lean:58–61` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
the freeze at step (3)'s mark instead, one interval early, and `frozen_until_step_three` is the
half it keeps. Step (3)'s instant is the event's own (`Event.completeProcedure`), not `now`: the
restore instant is what the record holds, and the two differ by however long steps (1) and (2)
took.
```

### Formal Record documentation

Source: `tools/formal/Provisiond/Restore.lean:95–99` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
/-- `STO-56`'s restore record: `restore_instant`, and `grace_ends_at`, which "is null until step
(3) of `STO-54`'s procedure is marked". The `Provisiond.Claim.RestoreRecord` it extends is the
view a claim reads. `restoreInstant` abstracts the newly defined incident transaction event
time, not a recovered-history endpoint; the reporting endpoints and certificates are omitted. -/
structure Record extends RestoreRecord where
```

### Formal RestoreTrace and store documentation

Source: `tools/formal/Provisiond/Restore.lean:156–167` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
/-- `STO-54`'s trace: the backup holds the store `delta` steps before the crash, the provider's
facts are the crash's, and `now` abstracts the incident transaction event time defined by
`STO-54`, independently of the recovered history. -/
structure RestoreTrace where
  history  : History
  delta    : Nat
  now      : Nat
  interval : Nat

/-- The restored store: every row as the backup held it, with `applied` as the provider holds it,
and the record open at its incident-creation event time — committed before the engine is started,
so no run of the model has a window in which it is absent. -/
```

### Formal afterCrash documentation

Source: `tools/formal/Provisiond/Restore.lean:431–439` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
/-- The successor. The crash clears `STO-51`'s session-scoped lock and this process's `passDone`.
The procedure marks, including `stepTwoMarked`, are the record's and stand, which is how
"a marked step does not run again" survives the process
that made the mark. The mode is the record's, and the instant is "read from the record and never
re-computed" — this model has no second clock to contradict it, so the parameter below decides the
mode and not the instant. That instant remains the incident transaction event time, not a
history bound. Everything else here is the store's or the trace's: the operator's
confirmation is the rows it moved, and `secondOrder`, `servedGens` and `parentResumedUnconfirmed`
record what has already happened. -/
```

### Formal bootRestore documentation

Source: `tools/formal/Provisiond/Restore.lean:545–546` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
/-- `STO-54`: the engine comes up on the restored store; `t.now` is the incident transaction
event time retained by the record, not the time of the recovered history. -/
```

### ADR-0023: event-clock decision and reporting scope

Source: `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:243–270` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
## Incident event time and possible-loss reporting — 2026-10-28

Adopt UO for `pv-3jw6`, under the owner's answer **“Report unknown (UO) (Recommended)”**.
The decision source is `docs/research/panels-2026-10/r74/owner-decisions.md`; the approved
application package is `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md`, with its
previously approved “defined below” → “defined above” repair. The release disposition is
`docs/research/panels-2026-10/r79/tally.md` (E-KEEP). No replacement clock-error wording from
that round is adopted.

This supersedes the numeric-report clause under *The decision* above. The reporting contract
and its arguments belong to `STO-54`: “A bound without valid evidence is unknown, not an invented
recovery time.” Its event definition is “restore_instant is transaction_timestamp() of the newly
begun transaction inserting this incident.” For the endpoint fields and incident-keyed retained
evidence/unknown-reason reference, see `STO-56`; for the human deployment procedures, see
`OVR-19`. The scenario and fixture inventory is `10-conformance-checklist.md`, with the reporting
rehearsal in `CNF-295` and operator-promotion cases in `CNF-365`.

The accepted uncertainty does not impose finite-only admission: `STO-54` says “Missing reporting
evidence does not hold incident creation, the existing restore procedure or component startup
once its existing prerequisites are satisfied.” The stopped-system ordering remains the decision
in `ADR-0047`. The derivation-index obligation is separate: `05-persistence.md`'s
`deposits.derivation_index` row says “Allocated strictly increasing and never re-issued”. This
amendment adds neither an allocation-evidence admission gate nor a proof of the configured gap.

The synchronization in `tools/formal/Provisiond/Restore.lean` changes documentation only.
The incident transaction event time is the abstraction used by `restoreInstant`/`now`;
`Event.completeProcedure` retains step (3)'s separate instant. SQL timestamp semantics and the
reporting-certificate protocol remain outside that model's scope; compilation proves neither.
```

### ADR-0023: subsequent P decision record

Source: `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:273–300` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
## Marker provenance and actual-restore supersession — 2026-10-28

The owner's answer, verbatim: **“Adopt P (Recommended)”**
([owner decision](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/owner-decisions.md#pv-ymjo--decided-r77b);
`pv-ymjo`, committed comment 839). Adopt P (Y-PROV-R): C1–C7, its selected P paragraph and
column, and only the wording repairs counted toward P by the
[frozen tally](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/tally.md#brief-defects-and-wording-normalization).
The complete alternatives are in the
[frozen brief](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/brief.md#complete-alternative-packages).
R2 and the optional narrowing of already-unresolved rows are excluded; the
[dissent and lost-reply trace](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/tally.md#lone-dissent-checked-in-full)
remain on record. The requirement/conformance edits landed first, in `12c3da0`.

For the rules, see the `operations` table, `STO-54` and `STO-56` in
[05-persistence.md](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md), and `WIR-9a` in
[13-wire-contract.md](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/13-wire-contract.md). For the startup pointer, see `OPS-15` in
[03-operation-lifecycle.md](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/03-operation-lifecycle.md). For conformance and the counted
after-close wording correction, see `CNF-302` and `CNF-295` in
[10-conformance-checklist.md](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md).
The landing, consistency and compatibility lists are in comment 839 and the frozen tally's
*Factual audit at the pin*; this record adds no list of obligations.

The adopted P costs and scope limits belong to
[C7 in the frozen brief](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/brief.md#c7--scope-and-separate-costs)
and the tally's *Factual audit at the pin*, read with the owner's adoption above. Recovery
latency and WAL cost remain unmeasured. No runtime conformance or new formal coverage is claimed.
The inspected declarations are unchanged; provenance and retained supersession remain outside
those models. `ADR-0025` states “Authority is per clause” and “A theorem is never conformance”.
```

### OVR-19: reporting-evidence and restore parameter rows

Source: `00-overview.md:419–425` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
| Recovery point | `STO-54` | greatest age of a committed write not yet in a separate failure domain | no — outside the process |
| Recovery-point alarm threshold | `STO-54` | duration | yes |
| Restore source/event clock-error evidence | `STO-54` | human — certificates and provenance for any asserted clock-error bounds; no unvalidated finite error assumed | no |
| Restore endpoint capture, validation and retention procedure | `STO-54` | human — possible-loss reporting procedure | no |
| Synchronous standby names | `STO-7`, `STO-54` | two identifiers | yes |
| Pooled-connection keepalives | `STO-7` | durations | yes |
| Derivation-index gap on restore | `STO-54` | integer | yes |
```

### Domain restore-record meaning and owning pointer

Source: `CONTEXT.md:187–197` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
**Restore**:
Bringing the store back from a backup, landing at some instant before the failure, or a promotion
`STO-54` classes as one. A recovery
incident with a stated procedure (`ADR-0023`), never a **restart**: a restart loses no acknowledged commit and the startup pass settles what was in flight at startup; a restore may lose an interval, and the
engine brought up on it naïvely performs destructive actions on state the restore rewrote.
The **restore record** is the row that makes the incident recognizable to a process rather than to
an operator: open from before either component starts until the operator closes it, carrying the
restore instant and which of the procedure's steps have completed (`STO-56`, `STO-54` owns what it
means). *Added 2026-09-20.*
_Avoid_: restart, recovery (bare — the rescue recovery directory and the recovery credential
already own that word), rollback (that is a transaction)
```

### CNF-29 — complete existing evidence consumer

Source: `10-conformance-checklist.md:186–201` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-29** — **AMENDED 2026-09-08 (`ADR-0016`) — the sweep has no deadline; the startup pass
      is the sweep.** Every operation found `running` when the engine starts is, subject to the
      exceptions below, moved to `needs_reconciliation` — never back to `queued`, except a
      `suspend_tenant` parent, which `OPS-15` says "MUST be returned to `queued`" on a restart —
      and the count is logged. Kill the engine
      with an operation of each dispatching kind `running`, restart, and assert each one — **except
      a `refresh`, which settles `failed`** (`ADR-0020`): assert its row is `failed` with an
      `internal` error and that `WIR-35`'s resolve refuses it by kind — **and a create whose
      `about_to_order_at` is null**, which settles `failed` on a restart with full commitment
      release and resource-offer exclusion freed; for its error, `OPS-15` says "Where no error is
      recorded, it MUST carry an `internal` error naming the restart, with `retryable: true` on
      both the error and the operation view". A set column stays `needs_reconciliation`; the null
      exception stays off while a restore record is open. For that open-record control, seed
      `lost_window_starts_at` and `loss_end_at` null, with a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`, `STO-56`).
      (`OPS-15`) *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the create exception and qualified the startup outcome, naming the `suspend_tenant` return to `queued` the summary had missed; the exclusion control uses an open restore record; `ADR-0042`.*
```

### CNF-99 — complete existing evidence consumer

Source: `10-conformance-checklist.md:558–777` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-99** — One adverse rate observation keeps to `LDG-16`'s bound — `LDG-16` says "no single
      rate observation moves the rate outside the range the window's other observations carry" — and
      a window that cannot produce a rate halts instead of pricing.
      For this item's actual restores and seeded open incidents, use null
      `lost_window_starts_at` and `loss_end_at`, with a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`, `STO-56`).
      **Asserted through the
      mechanism, not the outcome** (2026-09-05; rewritten 2026-09-21 for `ADR-0026` and 2026-09-23
      for `ADR-0027`, with the sub-quorum and ageing-out cases added the same day for its two
      amendments, the steady-state and silent-feed cases for `LDG-59`'s two clocks, and the
      two-subjects, thin-start and preserved-row cases 2026-09-25 for `STO-37`'s opening rule, and
      the crossing and concurrent-guard cases the same day for `ADR-0027`'s replayed start, and
      the deadline assertions restated 2026-10-02 on `LDG-64`'s computed deadline, with the
      no-record, restart and changed-parameter cases, for `ADR-0029`):
      assert the rate itself, not only whether a disk survived. **One poisoned pass among honest ones**, in
      three shapes, each asserting that the rate lies inside the range the remaining honest
      observations carry: fill a window with five honest observations at distinct prices and replace
      any one with a print far below them all; fill it again and replace any one with a print far
      above them all; and fill a window with honest observations at 100, 103 and 104, replace the
      103 with 101.5, and assert the rate reads 101.5 — a price no honest pass accepted, inside the
      honest range. **A print carried by half the window**: fill a window with four observations,
      two of them at one print below every honest price, and assert the rate is that print. **A
      window with no fresh observation**: let every observation inside the window age past the
      staleness bound and assert there is no rate, observed as `CNF-138` observes it from dead
      sources. **A thin window**: leave two fresh observations inside it and assert there is no
      rate, the same way. **Steady state at a window of exactly three passes never drops the rate
      between passes** (added 2026-09-23, `ADR-0027`, with the next case, for `LDG-59`'s two
      clocks): configure the window to hold exactly three passes — cadence × 3 = window length —
      with a staleness bound longer than the cadence plus the read-to-acceptance lag — the
      interval from `observed_at` to `accepted_at` — and negligible publication delay in this
      fixture (*amended 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*) — and run in steady state, so the oldest
      observation ages out just before each new one arrives, each accepting pass running strictly
      after the oldest has aged out, so that a continuous count would read two in between; assert
      that at every instant between passes there is a rate and it is the one the last accepting pass
      computed, and that the count of observations inside the window is not re-tested between
      passes. **A feed silent for longer than the staleness bound is no rate before any pass accepts
      an observation**: with a window that produces a rate, stop every source, or otherwise ensure
      no pass accepts an observation, and let the wall clock advance past the staleness bound
      measured from the newest observation's `observed_at` with no pass having accepted anything
      since; assert that at that instant there is **no rate** — a create is refused and
      re-derivation halts without cancelling (`LDG-40`) — before any pass accepts an observation,
      and that the opening of the `LDG-64` outage does not wait for a pass to notice (`STO-37`).
      **Two subjects' meters posting after one outage began** (added 2026-09-25, `ADR-0027`, for
      `STO-37`'s opening rule): with the feed silent past the staleness bound as above, let two
      machines in one currency each post through the meter after the outage began, each finding no
      open row for itself, and assert two `STO-37` `rate_outage` rows, one per machine, each
      `absorbed_from` equal to the newest observation's `observed_at` plus the staleness bound — the
      two equal to each other and to neither posting's wall clock — and each machine's view
      (`WIR-11`) showing `rate_outage_deadline` equal to that instant plus `LDG-64`'s bound. **A
      machine with no record shows the same deadline**: assert that a third machine priced in that
      currency, under `LDG-72`'s quarantine so that its meter posts nothing and it has no
      `STO-37` row, shows that same `rate_outage_deadline`, that a machine priced in a currency with a rate
      shows null, and that no `STO-37` row stores a deadline. Then, past that deadline, let the
      worker's `OPS-41` contend run on the third machine, which has no record, and assert the
      third machine still has no `STO-37` row — `STO-37`: "Nor does the worker's `OPS-41` contend
      open one"; a build whose worker inserts where it finds no row, or upserts, fails here and
      passes on a machine that already has one. **A thin window's outage
      starts at the pass that found it thin** (added 2026-09-25, `ADR-0027`): with a window that
      produces a rate, and a staleness bound longer than the gap between its last accepted
      observation and the pass that finds it thin, so that observation is still fresh when the
      window is found thin, let the window come to hold fewer than three observations as of an
      accepting pass — passes below `LDG-59`'s quorum accept nothing while older observations leave
      the window — so that pass finds it thin; post the meter for one machine metered in that
      currency and assert that the `STO-37` row it opens carries `absorbed_from` equal to that
      ~~pass's `observed_at`~~, not the newest observation's `observed_at` plus the staleness bound,
      which lies in the future. *Amended 2026-10-04 (`pv-gip.28`, Q13): the struck-through
      2026-09-25 boundary is withdrawn; assert the pass's `accepted_at` under `LDG-58`
      instead, including when observation precedes acceptance.* **An open row is preserved**: then let the newest observation age
      past the bound — a staleness computation would now yield a later start — post the meter again
      for the same machine, and assert that the row's `absorbed_from` did not move and no second row
      opened. **The clocks cross inside one outage** (added 2026-09-25, `ADR-0027`, for the replayed
      start): with a staleness bound `b` shorter than the pass cadence `c`, a window of length `3c`
      and `LDG-64`'s bound `M` longer than `3c`, let passes at `t0−2c`, `t0−c` and `t0` each accept
      an observation, so that at `t0` the window holds three, the newest (`observed_at = t0`) is
      fresh, and there is a rate; the case starts from the pass at `t0` and asserts nothing before
      it — any rows an earlier flap opened were closed at or before `t0` by `LDG-64`'s closer, the
      "observation with which `LDG-58`'s window produces a rate again".
      *Amended 2026-10-04 (`pv-gip.28`, Q13): that 2026-09-25 quotation is historical,
      superseded wording. Use `accepted_at = observed_at` for these passes and close earlier
      flap rows under current `LDG-64`; the quotation supplies no observation-time instruction.*
      Keep machines A and B in that currency continuously billable from `t0` through the last
      tested posting, within one billing period. Each has an open increment starting at its seed
      or prior high-water mark at `t0`, with no intervening posting before its specified posting
      below. Let the feed go silent, so
      that at `t0+b` the newest observation is stale and there is no rate, with no pass running
      (`LDG-59`). Post machine A's meter at some `tA` in `(t0+b, t0+c)`; it finds no open row for A
      and opens A's row: assert `absorbed_from = t0+b` and, on A's view, `rate_outage_deadline =
      t0+b+M`. Let the
      passes at `t0+c` and `t0+2c` fall below `LDG-59`'s quorum, accepting nothing and writing no
      `STO-49` row, and after each assert that A still has its one open outage row, no duplicate
      has appeared, and `absorbed_from` remains `t0+b`. At `t0+3c` let a pass accept one observation
      (`accepted_at = observed_at = t0+3c`): as of that pass the window holds at most two observations — `t0−2c`
      and `t0−c` are outside it and `t0` is at its edge — so on either side of that edge the window
      is thin, and there is still no rate although the new observation is fresh. Accept no further
      observation before the tested postings finish. Post machine B's meter at some `tB` with
      `t0+3c < tB < t0+b+M`; it finds no open row for B and opens B's row: assert
      `absorbed_from = t0+b`, equal to A's and not `t0+3c` (what the per-writer thin formula would
      give), `rate_outage_deadline = t0+b+M` on B's view, one deadline for both machines, and that
      `[t0+b, t0+3c)` lies inside both B's posting span and its absorbed window, so B's `LDG-38`
      apportioning charges nothing for it. Assert also that B's write read no sibling row. For
      that independence check, rerun with A's posting delayed until after B's but before `t0+b+M`,
      or omitted, keeping B's billable span and starting mark unchanged: B's result is identical.
      **A restart does not move the deadline, and a changed parameter does**
      (added 2026-10-02, `ADR-0029`): mid-outage, restart the engine with every `OVR-19` value
      unchanged and assert each machine's `rate_outage_deadline` is the instant it was; restart it
      with the maximum tolerated outage changed to `M′` and assert each reads the outage's start
      plus `M′`, without changing the absorbed window. (*Amended 2026-10-04, `pv-gip.28`.*)
      **Stamped rows preserve the outage across settings changes.** Use a populated window,
      newest observation at 12:00 stamped with a 20-minute bound, and a silent feed. A was
      billable before 12:20 and posts at 12:25: its row starts at 12:20, with null end and zero
      stored absorbed seconds. At 12:30 load a 60-minute bound and post A again and first-post B,
      also billable before 12:20, later: both starts stay 12:20 and neither closes. No duplicate
      row or already-granted relief is lost; both deadlines remain 12:20 plus the maximum.
      A third subject seeded at 12:35 clips its start to 12:35. At 12:50 an accepting pass with
      sufficient retained observations actually yields a rate: closures are at 12:50 with
      1800/1800/900 seconds respectively. Each subject subtracts its own row's overlap.
      Reverse A/B posting order and omit A entirely: B's outcome is identical.
      **Loading a larger window cannot end a thin verdict.** Retain observations at 11:40,
      11:50 and 12:00 with a 30-minute window and 20-minute stamped bound; the 12:00 pass
      produces a rate. Accept nothing until 12:50, whose pass is thin under that window and
      stores null. The outage starts at 12:20. With seed/mark 12:00 and enough authority, post
      at 12:25: row [12:20, null), stored seconds zero. Load a two-hour window at 12:55 and
      accept nothing before posting at 13:00. The row remains open from 12:20; loading the
      window supplies no return. With customer rate 1/5 sat/s before the outage, no price or
      margin changes and initial `r = 0`, the two postings charge 1200 × 1/5 = 240 sats total,
      none for [12:20,13:00), final `r = 0`, mark 13:00. Repeating the posting adds nothing.
      A subject first posted at 13:00 gets the same outage start, clipped to its own seed.
      At 13:05 accept a pass with enough retained observations to yield customer rate 2/5:
      close at 13:05 with 2700 absorbed seconds. Posting through 13:10 then adds 300 × 2/5 =
      120 sats (360 total), never charging the absorbed interval. In a separate run, make the
      subsequent accepting pass thin too: no closure until a later pass actually yields a rate.
      **Setting changes alone leave the verdict and stamped staleness unchanged.** Raise and
      lower window length while a rate is held and while its latest verdict is null: neither
      action changes the verdict or historical spans. A newest 12:00 observation stamped with
      a 60-minute bound still supplies freshness at 12:30 after loading a 20-minute bound at
      12:10 without a pass; it expires at 13:00. New observations use the new bound. Conversely
      raising a bound never revives a stale observation. After shrinking a window, let the next
      accepting pass find it thin while the newest observation is fresh: the outage starts at
      that pass, not at configuration load. Prune everything now eligible under `STO-49`, then
      first-post a subject seeded before that outage and assert the same start and relief.
      Enlarge again: only retained observations enter future computations; no invented rows or
      changed historical verdicts. Exercise an accepting row observed earlier than a prior row:
      its acceptance order selects the verdict, but freshness uses the newest observation's
      own stamp, not the latest accepted row's bound. Restart over unchanged stamped rows and
      verify the held verdict, start and all historical spans survive.
      **Acceptance-time replay** (*added 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*).
      Previous newest observation 10:50, stamped bound one hour; a non-thin pass reads at
      11:45 and is accepted at 11:55. Post one subject at 11:52 and another only after
      acceptance, both seeded before 11:50. Each row starts at 11:50 and closes at 11:55;
      reverse posting order and omit the early posting: starts and charges are unchanged.
      Acceptance cannot erase [11:50,11:55). For a delayed thin verdict, keep old evidence
      fresh through acceptance, read at 11:45 and accept null at 11:55: the outage starts
      at 11:55, not 11:45. Before 11:55 the earlier accepted non-null verdict still holds.
      Repeat with a latest-accepted observation older than a previously accepted one:
      acceptance order selects the verdict and observation order selects freshness, using
      only rows accepted by the queried instant. With the previous `accepted_at = 11:55`,
      roll the transaction clock back to 11:50: the next row is stamped 11:55 and a larger
      acceptance order. At that tied timestamp use the later verdict; at 11:54 it has no
      effect. Prune all eligible rows and restart, retaining the prior accepted row for
      the clamp and the predecessor/freshness inputs for an open increment and an open
      restore across repeated returns. Replay all tested boundaries unchanged, including
      a delayed row whose `observed_at` is before an increment's left edge but whose
      `accepted_at` is inside it. `CNF-277` owns the delayed-return billing/deadline cases;
      `CNF-218` owns the usable-grace case.
      **Quorum changes acceptance, not replay.** With the needed history retained, raise
      the quorum from three to five while holding staleness and window fixed. Assert that
      recorded observations accepted from three sources remain replay inputs, and replayed
      outage boundaries and existing rows are unchanged. A new pass with three live,
      non-excluded sources accepts nothing and writes no observation; a later pass with
      five accepts one, whose effect on the window is then replayed normally.
      **Two concurrent postings
      of one subject open one row** (added 2026-09-25,
      `ADR-0027`): let two concurrent postings of one subject both compute no rate and both find no
      open row for it, and assert exactly one `rate_outage` row for that subject, both postings
      continuing against it, and its `absorbed_from` the replayed instant. **A sub-quorum pass with
      a fresh window**: with a window that produces a rate, run one pass below `LDG-59`'s quorum and
      assert that creates and re-derivations proceed at the rate in force, that no `LDG-40` halt
      fires and no `LDG-64` outage opens, and that the next accepting pass recomputes the rate. **An
      observation ageing out mid-increment**: fill a window with observations at 104, 100, 102, 106
      and 108, oldest first, so the rate is 104; let the oldest age out between two passes inside an
      open increment — recomputed then, the four left would give 102 — and assert that the rate does
      not move and the increment is not split before the next accepting pass recomputes; let that
      pass observe 110 inside the same increment and assert that the rate becomes 106 — with the
      oldest still inside the window it would have stayed 104 — that the change splits the increment
      at that pass's `STO-49` row, and that the age-out changed nothing charged: the increment the
      split closes is debited at 104 for all of its time, the stretch after the oldest aged out
      included, and only the one it opens is priced at 106 (`LDG-38`). **Then, with a rate in
      force, let a runway expire
      with no rate movement at all and assert the machine is routed on the very next sweep** — a
      build that holds every past date for a second look runs each ordinary exhaustion one interval
      into the wind-down reserve. **A gone machine is not routed again:** retain a past
      stored date after recording a machine gone and closing its episode `resource_gone`.
      With a rate present, the next exhaustion sweep opens no episode and enqueues no attempt.
      With no rate, at and after the outage deadline, the bound canceller likewise opens no
      episode and enqueues no attempt. Contrast a live machine without an outage record,
      including a quarantined one: at the bound it is enqueued. A live scheduled cancellation
      is not a gone record. **Then the restore edge** (added 2026-09-12, `ADR-0023`; rewritten
      2026-09-25, `ADR-0028`, to measure from step (3)): with a rate continuously in force,
      an active tenant, sufficient available balance and otherwise satisfied extension admission
      conditions, with the requested runway extending beyond the tested re-claim, restore a store
      in which a machine's stored
      `runway_until` is past, run `STO-54`'s procedure, and assert that the record's `grace_ends_at`
      (`STO-56`) is step (3)'s instant plus one re-derivation interval and that the exhaustion sweep
      does not route the machine before it — the freeze holds; take a queued delete re-run by step
      (2) and claimed before step (3), and assert it defers by a short delay, writes no fence
      (`machines.destroy_committed` stays null) and makes no provider call; take one claimed after
      step (3), and assert it is returned to `queued` with `available_at = grace_ends_at`, writes no
      fence and makes no provider call (`OPS-41`); extend the machine inside the grace, and assert
      the extension is admitted — no fence refuses it — and that at the re-claim after
      `grace_ends_at` the worker aborts and closes the episode `funded` (`OPS-48`'s no-mutation
      row), the machine never routed again for that lapse; and take a machine already fenced when
      the grace begins, and assert an extension is refused `cancellation_committed` throughout the
      grace and that its retry's claim waits for `grace_ends_at` like every claim. Repeat with
      a restore-caused loss of `STO-49` rows leaving no rate: exercise `CNF-218`'s paused
      cases and assert the single original end is never rewritten (`STO-56`). *The per-tick cap
      clause is withdrawn with the construct it tested (`ADR-0011`). Until 2026-09-05 this item
      tested a behaviour with no column, no predicate and no reader behind it, and a build that
      routed on the date alone passed it by never being fed a poisoned reading.* (`PRV-13e`,
      `LDG-16`, `LDG-38`, `LDG-58`, `LDG-59`, `LDG-64`, `STO-37`, `STO-49`, `STO-54`, `STO-56`, `OPS-41`,
      `OVR-19`, `WIR-11`)
```

### CNF-295 — complete existing evidence consumer

Source: `10-conformance-checklist.md:1019–1093` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
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

### CNF-297 — complete existing evidence consumer

Source: `10-conformance-checklist.md:1107–1113` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-297** — **The derivation index never goes backwards** (added 2026-09-12,
      `ADR-0023`). Mint deposits, take a backup, mint more, restore with null
      `lost_window_starts_at` and `loss_end_at` and a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`, `STO-56`),
      run `STO-54`'s skip-forward,
      and assert the next index allocated exceeds every index a rolled-back row held, and that no
      address is ever handed to two deposits (`LDG-49`). (`STO-54`, `LDG-49`)
```

### CNF-365 — complete existing evidence consumer

Source: `10-conformance-checklist.md:1177–1217` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-365** — **Promotion after the primary is lost** (`ADR-0045`). With both components
  running, let one create
  commit step 8 and order, and claim a second. Kill the primary and promote a named standby whose reported end is at least as far ahead as the other's, with no open restore record and every other restart-promotion condition satisfied, by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine and `api` process connected
  to the old primary has stopped before any component connects to the promoted store, and that the old primary
  serves no component; that both rows are on the promoted store; that no restore record is written; and that the
  successor's startup pass takes `OPS-15`'s restart branch. Then, with both standbys stalled while a write waits,
  crash the primary, restart it in place, then separately crash one backend while a write
  waits, and each time assert no component uses a connection before a standby has flushed at or past the flush
  position it reported. For both components: With healthy replication, withhold position-query results through the connection-attempt
  deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend.
  Inspect the deployed topology for transaction-mode pooling.
  With one standby unreachable, assert the
  procedure promotes neither as a restart
  and none until an operator decides, while that standby's report stays unavailable.
  With one standby on another timeline, assert the
  procedure promotes neither as a restart. Stop one standby, make an acknowledged write, stop the other, lose the
  primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped.
  Promote a lagging standby as an operator restore with verified prefix/clock evidence and
  assert the incident stores certified bounds. Repeat with an idle restarted standby that has
  replayed no transaction record and no retained fallback proof: assert unknown history bound
  and an explicit nonnumeric report, followed by the existing restore procedure. Repeat with no
  verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a
  backup name to fill an unknown history bound.
  For these operator-restore arms, supply certified evidence for each asserted known
  `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
  non-null incident-keyed `history_evidence_ref`
  identifying evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).

  Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.

  Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.

  Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.
  (`STO-5`, `STO-7`,
  `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*

## The rate

Added 2026-08-12. Past the window median (`LDG-58`), a wrong rate is the only
external input in this specification that reaches a customer's disk (`LDG-41`, `LDG-14`).
```

### CNF-358 — complete existing evidence consumer

Source: `10-conformance-checklist.md:1616–1640` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-358** — **A create interrupted around step 8 has a distinct restart outcome.**
      With an auction-channel descriptor and again with a standard-channel (`correlator: none`)
      descriptor, kill during step 4's List offers read, after step 7, and while step 8's
      transaction is in flight before commit. Read the stored record and assert
      `about_to_order_at` is null at each kill. Restart: assert `failed`, a restart-naming
      `internal` error, `retryable: true` on both error and operation view, commitment closed and
      released in full, no setup-fee or first-unit debit, and the resource-offer exclusion freed
      where the create holds one. Assert no step-9 request reached the provider: no per-order key upload and no order;
      the List offers read is permitted. Repeat with an injected recorded error carrying
      `retryable: false`, written to the stored row before the restart, since `CNF-30` says "The
      startup pass does not overwrite an error already recorded": assert the error survives
      unchanged and the operation view carries `retryable: false`.
      Kill after step 8 commits but before step 9, and again after the order: assert the stored
      column is set and unchanged after restart, and the operation `needs_reconciliation`,
      with its commitment still open. No resolution or correlator matching runs for the failed cases.
      **Restore control:** take a backup after claim and before step 8, let the provider receive
      the order, restore that backup with an open restore record carrying null
      `lost_window_starts_at` and `loss_end_at` and a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`, `STO-56`),
      and start the engine. The stored column
      is null, but the operation stays `needs_reconciliation`; repeat after a crash before the
      startup pass, and after the freeze lifts while the record remains open. These cases reject
      a missing step-8 write, a write delayed into step 9, and an exception applied on a restore.
      (`OPS-15`, `OPS-16`, `OPS-43`, `LDG-32`, `LDG-39`, `STO-58`)
      *Added 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the kill-timing and restore controls; `ADR-0042`.*
```

### CNF-370 — complete existing evidence consumer

Source: `10-conformance-checklist.md:1759–1764` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-370** — Start an engine; back up; restart the engine; stop every engine and `api`
      process; restore from that backup with null `lost_window_starts_at` and `loss_end_at`
      and a non-null incident-keyed `history_evidence_ref` retaining the unknown-endpoint reasons
      (`STO-54`, `STO-56`). Then start an engine on the restored store, and assert
      that every value written by an advance is distinct.
```

### CNF-308 — complete existing evidence consumer

Source: `10-conformance-checklist.md:2179–2220` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-308** — **Late attach with no rate** (*added 2026-10-04, `pv-gip.27`*).
      Release the create's commitment, then produce a correlator match during a currency outage,
      with available balance above any plausible wind-down floor. Assert attachment, no commitment,
      unchanged available balance, a native `late_attach_cleanup` deficiency with null rate and
      zero absorbed seconds, and the applicable `unrecoverable_setup_fee` and
      `unrecoverable_first_unit` records (`ADR-0033`, 2026-10-08) with the same
      null-rate/zero-seconds shape. Attach, deficiency records, fee settlement/parked-fee clearing
      and cleanup enqueue are atomic: inject failure between effects and observe all or none.
      Before the bound the cleanup short-defers with no fence or provider call; extension is
      refused by the rate gate. With declared duration 60, attach at 30 without any customer
      first-unit debit: assert `first_unit_debit_id` null and mark 30. The meter charges nothing;
      a no-rate tick at 60 opens an outage row from 30, absorbing eligible post-attach time and
      no pre-attach time. `STO-37` owns the start: "The subject row starts at
      `max(currency outage start, the subject's latest mark)`".

      Return the rate at 60. In one ordering, extend before the cleanup fence: a commitment
      opens, `runway_until` is re-derived (*amended 2026-10-04, `pv-gip.39`: no deficiency-resolution
      bookkeeping*) and the cleanup aborts without provider mutation; the machine survives.
      In the other ordering, make no extension: with zero usable sats and a valid rate,
      `max(60, 30) + 0 = 60`, which is not strictly in the future. Cleanup proceeds through
      the existing fence, absent an existing independent deferral; there is no automatic survival
      to 90. Repeat with a rate present at attach and re-check at 60: the same mark and result.
      Pair this with a machine whose first-unit customer debit actually landed before its seed
      at 30: mark 90, and at 60 the re-derived date 90 permits the funding abort. This paid
      fixture is a separate settlement path, not a debit manufactured after release. Keep
      `CNF-318`'s duration/null cases. The opening rates on the native-only wind-down, setup-fee
      and first-unit records remain null after the outage case's return. *Amended 2026-10-08,
      `ADR-0033`: the unpaid inside-unit abort expectation is withdrawn.*
      Separately keep the outage through its bound and
      exercise cancellation, including an attach after the bound. Repeat under current suspension
      and under an open restore to check the existing worker precedence. For the open-restore
      arms, seed null `lost_window_starts_at` and `loss_end_at` with a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`, `STO-56`).

      With an open restore, satisfy its other close conditions and leave this currency's
      rate-present grace unspent. First establish that all its machines are gone or fenced, then
      attach before the close: close is refused while the new machine is live and unfenced.
      Fence it, record it gone, or spend the remaining rate-present grace; each independently
      permits that currency's close condition. Reverse the ordering: close first, then attach;
      the incident stays closed and the cleanup receives no restore deferral. Check both
      orderings at the close transaction, not just against a previously read inventory.
      (`OPS-36`, `OPS-41`, `OPS-42`, `LDG-40`, `LDG-62`, `LDG-64`, `LDG-66`, `STO-37`, `STO-56`)
```

### CNF-271 — complete existing evidence consumer

Source: `10-conformance-checklist.md:2485–2539` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-271** — **AMENDED 2026-09-08 (`ADR-0017`) — the episode is the unit, and `failed` is a
      fact about an attempt.** Walk `OPS-48`'s transitions against a real row. Drive an
      exposure-reducing cancellation whose provider call fails after the fence is written — once
      with a 5xx, once with `authentication`, and once with `rate_limited` — both before
      and after acceptance. Assert: 5xx is `needs_reconciliation`/`uncertain` in either case;
      the other kinds are `failed`/`stalled` before acceptance and
      `needs_reconciliation`/`uncertain` after acceptance (amended 2026-10-08, `ADR-0035`); in both, the episode stays open, `destroy_committed` still holds its id,
      `LDG-62` is still refused `conflict`, and the `stalled` episode appears in the operator
      listing `OPS-26` requires. `retry` on the `stalled` one enqueues a fresh attempt that **runs
      the provider call again** rather than aborting into a false `succeeded`, and the episode is
      `attempting` with `current_operation_id` naming the new attempt. Then the closing rows: an
      attempt that succeeded **with the resource gone** closes the episode `resource_gone` and clears
      the fence in the same transaction; an operator `abandoned` on an **`uncertain`** episode's
      attempt (`OPS-31`) closes it `abandoned` and clears the fence so a later sweep may open a
      fresh one — there is no such verb on a `stalled` one; a machine **recorded gone** (`API-63`,
      `LDG-74`) closes an episode in any open state `resource_gone` and clears the fence in that
      write, and a later `OPS-31` resolution of its retained attempt leaves the closed episode
      closed; and **no timer ever moves a `stalled` episode** — run the clock out and assert it is still `stalled` with one
      attempt, including a `rate_limited` refusal before acceptance (`ADR-0035`; `F48` retains the deferral history). **Then the row a reader
      will get wrong**: a cancellation the provider merely *scheduled* (`DOM-19`) settles
      `succeeded`, the episode is `scheduled`, and it and the fence both **stay** while the
      machine is present, even after the effective date. Only an evidenced gone-write closes
      the episode and clears its fence; tombstoning waits for the retention gate. Closing at
      the date lets the next exhaustion sweep open
      a fresh episode and place a second cancellation against a machine already scheduled, which
      `OPS-39` warns can alter or repeat the first's mutation. **The failure this catches is a
      sweep loop that settles `succeeded` forever while the machine bills forever.** (`OPS-48`,
      `DOM-31`, `OPS-42`, `OPS-39`, `OPS-26`, `API-64`, `LDG-62`)
      **Added 2026-10-04 (`pv-gip.11`, `ADR-0032`): rate-funded stalls and explicit keep.**
      After a deterministic failed delete, accept a favorable rate and re-derive future runway.
      Sweep repeatedly: same stalled episode and attempt, same fence, extension refused. Let
      that date lapse and sweep again: no new attempt. Retry the price-funded episode with a
      fresh key and observe the provider call, not a funding abort; also try no rate before the
      outage bound. The retry still defers under an open restore record with null/future original
      grace end; seed that incident with null `lost_window_starts_at` and `loss_end_at` and a
      non-null incident-keyed `history_evidence_ref` retaining the unknown-endpoint reasons
      (`STO-54`, `STO-56`). Once claimable, it uses the retry branch. A gone-write or permanent
      close before its fence transaction still prevents the call. An ordinary funded attempt still aborts.
      On a separate stalled fixture, keep: in one transaction observe `closed`/`kept`, cleared
      fence, re-derived date, authenticated `kept_by` and the submitted `operator_ref` in
      `keep_evidence`, and the durable receipt; no new operation, provider call or money movement.
      An extension now succeeds with other admission conditions satisfied. Kill/restart at the
      transaction boundary and after response loss: either no effects or all effects, and exact
      receipt replay repeats none. Retire the old attempt under `STO-14`: episode evidence remains.
      Use a new key on that closed episode, and exercise attempting, uncertain and scheduled
      states: `409` state, unchanged. Race keep against retry and against a gone-write in both
      orders; the losing conditional write cannot overwrite a close or clear the retry's fence,
      and a gone-write after keep does not re-close the old episode. Replay keep after a new
      episode opens: the original view returns and the new fence remains. Keep an unfunded
      machine: no funds are added and the next sweep opens a fresh episode under the existing
      predicate. With no rate keep retains the stored date; the sweep waits for rate under
      `LDG-16`. Keep remains operator-only (customer/recovery cannot reach it), is synchronous,
      and is not a spending or retry-ceiling verb. (`API-68`, `WIR-55`, `STO-52`, `WIR-24`)
      **Added 2026-10-05 (Q14):** `CNF-312` covers the interrupted, never-fenced prefix and
      its extension/fence orderings; retain this item's fenced, timer and keep controls.
```

### CNF-302 — complete existing evidence consumer

Source: `10-conformance-checklist.md:3022–3097` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
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

### CNF-218 — complete existing evidence consumer

Source: `10-conformance-checklist.md:3416–3601` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
- [ ] **CNF-218** — A machine funded by `extend-runway` **after** its cleanup cancellation was
      enqueued is **not** deleted: the worker re-reads funding while holding the machine
      (`OPS-8`), makes no provider call, settles `succeeded`, and the episode closes (`OPS-48`).
      **Afterwards
      `machines.destroy_committed` is null, the stored `runway_until` is the re-derived future date,
      a second `extend-runway` succeeds** (*amended 2026-10-04, `pv-gip.39`: remove deficiency
      resolution bookkeeping; survival and repeated extension remain covered*) — a build that leaves the fence set passes the first
      sentence and refuses every later extension forever, and one that leaves the stored date in
      the past is re-routed by the next sweep and loops. **Then the same with a `rate_outage_bound`
      cancellation** whose rate returns between enqueue and claim: the worker re-derives at the
      returned rate and aborts. **And the same with restoration committing *after* the
      worker's claim snapshot and before its fence transaction begins**: that transaction reads a
      rate, so the worker re-derives at the rate in force, makes no conditional write on the
      machine's `rate_outage` record, and makes no provider call. **And the same past the deadline,
      with restoration committing after the fence transaction has read no rate and before its
      conditional write**: the write affects no row, the worker re-derives at the rate now in
      force, and it still makes no provider call — a build that
      establishes "no rate" by a read passes the cases before this one and deletes the fleet in
      it. **Then the same with the commitment unchanged and only the price
      cut** between enqueue and claim: the re-derived date is in the future, the worker aborts,
      makes no provider call, and clears the fence — a worker that aborts only on a grown
      commitment passes every other case here and destroys a machine a price cut rescued.
      **With no rate, a funding cancellation waits; it is not cancelled and not settled**
      (rewritten 2026-10-02, `ADR-0029`; `OPS-41`'s order is what each case exercises). *A fresh
      outage*: with a
      live machine outside a restore incident whose stored date has passed, its episode open and
      its cancellation queued — an
      `exhausted` attempt enqueued before the rate was lost, and separately `OPS-36`'s late-attach
      cleanup, enqueued by its attach transaction while a rate existed — lose the rate before the
      claim, and before the meter has
      opened any `rate_outage` record for the machine, and claim: assert the attempt returns to
      `queued` after a short delay, `machines.destroy_committed` stays null, no provider call is
      made, the operation has not settled and the episode is still open — a build that reads the
      absent record as a stopped meter settles it `succeeded` here and the sweep queues it again.
      *The same for an attempt claimed while a rate existed* that loses the rate before its fence
      transaction: it defers, since the decision is the transaction's and not the claim's. *The rate
      returning before the deadline*: at the next claim the worker re-derives, and aborts or cancels
      on the ordinary predicate. *A suspension joining the deferred attempt* (`API-58`): within one
      short delay the next claim proceeds to the provider call with still no rate. *The machine
      recorded gone mid-outage*: the next claim settles `succeeded` with no mutation required,
      makes no provider call and writes no `runway_until`, the episode already closed by the
      gone-write. *The deadline passing with still no
      rate*: the next claim writes the fence and cancels — where the machine has an open
      `rate_outage` record and where it has none alike. *The maximum tolerated outage lowered
      mid-outage below the time already run* (`OVR-19`): the deferred attempt's first claim after
      the restart that loads it proceeds.
      **Restore grace across outages** (`OPS-41`, `STO-56`; amended 2026-10-02, `ADR-0029`).
      Seed the incidents in the following restore-grace traces with null `lost_window_starts_at`
      and `loss_end_at` and a non-null incident-keyed `history_evidence_ref` retaining the
      unknown-endpoint reasons (`STO-54`, `STO-56`).
      Keep the restore record open throughout the following traces, including the refused close
      attempts below; successful closure is exercised in `CNF-295`. Unless a trace specifies
      otherwise, use an active tenant, an unfenced live machine with an open funding episode,
      and a queued cancellation; set a bound
      later than each tested return except in the bound cases below.
      For every extension assertion, first establish a rate, sufficient available balance and
      all other admission conditions (`LDG-40`, `LDG-62`); choose requested runway beyond the
      tested re-claim. Write step (3)'s mark and original end
      once. Before that mark, a null end still defers by a short delay with no fence or provider
      call. Exercise the following histories using `STO-49`'s currency rows:
      *No outage*: at a claim inside the grace `available_at` is the original end; an extension
      is admitted, and re-claim at that end settles `funded`, clears the fence and leaves the
      machine alive (`OPS-48`).
      *An outage covering the entire original grace*, including one caused by restoring away
      rate-observation rows: before the original end claims defer to that end; afterwards, with
      no rate and before the bound, the ordered worker uses step 4's short delay, never an
      unknowable return instant. Admit an observation that leaves the window thin and assert it
      does not start spending grace. At the qualifying return `R`, claim and run the fence
      transaction: with the re-derived date still past, assert the ordinary short delay in
      `available_at`, no fence or provider call, and the attempt queued with its episode open.
      Let `I` be the re-derivation interval. At each eligible claim before `I` rate-present time
      has accumulated, an unfunded attempt short-defers again; it does not park until `R + I`.
      Admit an eligible extension during this remaining grace, with enough runway beyond the
      next claim. At that next eligible claim, still before the interval completes, assert
      the existing `funded` no-mutation outcome: `succeeded`, the re-derived future date written,
      fence cleared and episode closed, with the machine intact. Repeat with commitment unchanged
      and a price cut making the re-derived date future; it settles at that next eligible claim
      too, without waiting for the grace to finish.
      *An outage after part of the grace*: spend `a < I` with a rate after step (3), then lose
      the rate past the original end; on a qualifying return at `R`, claim and run the fence
      transaction: assert a short delay and only `I - a` rate-present time left. With the rate
      continuously present and no new funding, the first eligible claim at or after `R + (I - a)`
      proceeds, without granting another full interval.
      *Flapping*: spend another `b < I - a` with a rate, lose it again, and claim at the next
      qualifying return `S`: assert a short delay and only `I - a - b` rate-present time left.
      Re-claim after later
      outages and returns and check the sum of all rate-present segments, with none discarded
      or counted twice. With no extension and an unfunded re-check, cancellation can proceed
      once the sum reaches `I`. Prune between the returns and restart: the history and its
      left edge needed to reproduce every result survive while the restore record is open
      (`STO-49`). Repeat for a live machine with no `rate_outage` record. Stop another subject
      in the same currency and write its `absorbed_until` before the currency returns: the
      live machine's grace is unchanged by that subject record.
      *Settings changed during the incident* (*amended 2026-10-04, `pv-gip.28`*): use a
      1h staleness bound, 1h re-derivation interval, 24h window and quorum three. Retain accepted
      observations at 08:00, 09:00 and 10:00, each from three independent live sources at the
      same price, with their stamped verdicts/bounds and the left edge needed for replay.
      Step (3) is 11:00, original end 12:00. No observation is accepted before 14:10; the
      10:00 observation expires at 11:00. Load a 6h staleness bound on restart: no return.
      A qualifying pass reads at 14:00 and accepts at 14:10 at the same price
      (*amended 2026-10-04, `pv-gip.28`, `pv-gip.6`, Q13*). Both relevant windows are
      sufficiently populated, so thinness does not decide the trace. Keep the incident open,
      outage maximum later than the trace, active tenant, live unfenced machine, open funding
      episode and eligible cancellation at 14:15 with no competing operation hold. Leave
      commitment insufficient and admit no extension. At the fence transaction only
      [14:10,14:15) contributes: 300 of 3600 seconds spent, 3300 remaining. Assert ordinary
      short deferral, no fence/provider call and episode still open. No part of [11:00,14:10)
      was usable grace, including the read-to-acceptance interval. With continuous rate presence,
      eligible claims short-defer until 15:10; the first at or after 15:10 may cancel. A further outage pauses the remaining measure.
      Prune and restart before re-claim: retain the stamped left-edge state and each intervening
      return/outage while the restore stays open, even when a later yielding pass moves the
      ordinary retention floor. This tests history replay; the effective-span model does not
      prove replay or retention.
      *Return between claim and fence transaction* (`pv-gip.35`): with no rate at the claim,
      the original end passed, and an unfunded re-derivation, commit a qualifying return before
      the fence transaction. Assert the transaction reads that return and its currency history,
      finds unspent rate-time grace, short-defers the attempt with its episode open, writes no
      fence and makes no provider call; the live machine remains intact. Repeat with a subject
      outage record at the bound and the return committing after the transaction read no rate
      but before its conditional write: zero affected rows reaches the same step-3 deferral.
      *A new outage bound after paused deferral* (`pv-gip.36`): let `d` be the ordinary short
      delay and choose remaining grace greater than `3d`. At `R`, with a rate, an unfunded
      attempt short-defers in step 3. Inspect `available_at = R + d`. Lose the rate before that
      instant and choose the new outage's bound `B` after `R + d` but before the former computed
      paused end. Run the actual queue through eligible claims only; while no rate exists and
      before `B`, assert each short deferral's availability. At the first eligible claim at or
      after `B`, no later than `B + d` with the worker otherwise available, assert step 5 fences
      and calls the provider to cancel, without waiting for that former end. Run this with and
      without a subject `rate_outage` record. The original wall-clock end is already past.
      *A suspension after paused deferral* (`pv-gip.36`): repeat the rate-present deferral at
      `R`, inspect `available_at = R + d`, then suspend the tenant before that instant. Assert
      the fan-out joins the existing episode and creates no replacement attempt. No claim is
      manufactured before availability; at the next eligible claim at `R + d`, step 2 proceeds
      to the fence and cancellation, within one short delay of suspension. Exercise with and
      without a rate at that claim.
      *Close refused between the bound and the next eligible claim* (`pv-gip.37`; added
      2026-10-03): let `d` be the ordinary short delay. After the original wall-clock end,
      Alice's live unfenced machine has a queued funding cancellation, an active tenant and
      unspent rate-time grace. With no rate, claim at `Q` before the outage bound `B`; step 4
      short-defers with `available_at = Q + d`. Choose `Q < B < Q + d`, complete all other
      incident obligations, and attempt close after `B` but before `Q + d`: assert refusal
      under `STO-56` and leave the record open. Return the rate before `Q + d`, leaving
      accumulated grace unspent at the next eligible claim and the re-derived date still past.
      With the worker available and no competing hold, claim at `Q + d`: assert step 3
      re-derives first, short-defers, writes no new fence, makes no provider call, and keeps
      the attempt queued and episode open. Do not manufacture a claim before `available_at`
      or close the record to reproduce the defect. Retain the direct-return and conditional-write
      interleavings above, and their funded re-derivation-first outcomes.
      *New routing after the bound*: begin instead with a live unfenced machine in the outage
      currency and no open episode or queued cancellation. Let the bound pass before its
      cancellation is routed, with all other incident obligations complete and grace unspent;
      assert close is refused even though nothing is queued. Return the rate, keep the stored
      and re-derived dates past, and run the exhaustion sweep before the bound canceller routes
      an attempt. At the new funding attempt's first eligible claim, with the tenant active and
      accumulated grace still unspent, assert the same step-3 short deferral, no fence or
      provider call, and an open episode.
      *No return through disposition*: after the wall-clock end, leave the rate absent and
      grace unspent, with all other incident obligations complete. Include a funded live
      unfenced machine with no queued attempt and a machine with no `rate_outage` record.
      Past the bound, before disposition, assert close is refused. Run the bound canceller
      and actual queue through eligible claims; step 5 processes every machine in the currency
      to recorded gone or fenced. Assert the currency still blocks while any live unfenced
      machine remains. For a bound cancellation whose provider call is refused, assert the
      failed attempt leaves its live machine fenced (`machines.destroy_committed` non-null).
      A failure alone is not the discharge condition. Once every machine qualifies, assert
      this currency ceases to block despite unspent rate time; keep the record open here and
      exercise successful closure and ordinary restart in `CNF-295`.
      *The bound while paused grace is unfinished*: with no rate and the wall-clock end passed,
      a funding-enqueued attempt reaches step 5 and cancels, both with and without an outage
      record. If the deadline falls before the original end, a claim past the deadline still
      returns to `queued` with `available_at = grace_ends_at`, with no fence or provider call;
      at that end, still without a rate, it reaches step 5. *Current suspension*: after the
      wall-clock end a suspended tenant's claim proceeds without waiting for unspent paused
      grace, with and without a rate, even if enqueued for exhaustion. Conversely, historical
      suspension reasons do not bypass paused grace for a resumed tenant. The episode stays
      open on each deferral, and every later eligible claim re-decides from step 1; no deferral settles
      the attempt,
      writes a new fence, clears an inherited fence, or calls the provider. Repeat the rate-return
      cases for an inherited fence: extension remains refused `cancellation_committed`, and
      retry claims observe the applicable grace. `CNF-295` exercises incident closure.
      *The fence and date assertions and the outage case were added 2026-09-05; the outage kind was
      outside `OPS-41` entirely, so a bound reached one second before the rate returned destroyed
      the fleet. `OPS-41`'s note of 2026-10-02 holds the reasoning this item's last case was
      withdrawn with.*
      (`OPS-41`, `OPS-36`, `OPS-8`, `OPS-48`, `STO-49`, `STO-54`, `STO-56`,
      `LDG-62`, `LDG-40`, `LDG-64`, `LDG-65`, `OVR-19`)
```

### WIR-9a: P wire consumer (no direct event-clock definition)

Source: `13-wire-contract.md:218–224` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
**Restore marker provenance is durable (`STO-54`).** On an install or rescue-inventory operation's
error, `disk_effect` (install) and `rescue_exit` (both kinds) are rendered `unknown` where
`restore_markers_untrusted` is `true` or transitionally `null`, whatever the marker columns hold.
Where it is `false`, the ordinary marker rendering above applies. An `unknown` `rescue_exit` retains
the address-and-port requirements above; those fields are not replaced with `unknown`. Neither
incident closure nor an ordinary restart with no open restore record changes the provenance used for
rendering.
```

### WIR-1: wire timestamp precision context

Source: `13-wire-contract.md:10–20` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
**WIR-1** **AMENDED.** Request and response bodies are JSON, `application/json; charset=utf-8`.
Money is an integer number of satoshis in a field suffixed `_sats` (`LDG-1`). Timestamps are
RFC 3339 UTC emitted with a `Z` suffix (never `+00:00`) at second precision; clients MUST accept
both forms. Durations chosen by callers are integer **seconds**.

Identifier types are **not** uniform, and the earlier "identifiers are UUID strings" was wrong
against `DOM-1`/`DOM-9`: machine, operation and deposit ids are UUID strings; a **tenant id**
follows `DOM-1` (1–128 chars of a wider set); a **provider account**, an **offer id** and an
**external id** are opaque provider-scoped strings; an **idempotency key** is an opaque
caller-chosen string. A field's type is whatever its defining requirement says, not UUID by
default.
```

Source inventory: the CNF item identifiers are generated from each complete item containing `restore_instant`, `history_evidence_ref`, `event-clock` or `source/event clock`; see `check/source-inventory.json`. WIR-9a is P’s marker-provenance consumer; its words above contain no `restore_instant` clock. The wire timestamp convention does not redefine the stored incident event. Neither option replaces a CNF or WIR passage. If that leaves a forced amendment unprinted, answer AMEND and supply the complete missing replacement; do not count an unread repair as acceptance.

### Earlier UO owner answer and limited wording repair

Source: `docs/research/panels-2026-10/r74/owner-decisions.md:6–9` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
1. **pv-3jw6** — Q: "pv-3jw6: when a promoted restore can't prove how much history survived, what should the
   restore report do?" A: **"Report unknown (UO) (Recommended)"**. Option text shown: "Panel pick, 4–0 accepted as
   written. Record the window when it's proven; otherwise record "unknown" with the reason and let recovery
   proceed. Becomes ready-for-agent and the drain lane lands it."
```

### Frozen UO application: time, evidence and formal-documentation instructions

Source: `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:43–73` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
> the possible-loss report defined above is published to the operator

Insert immediately after the acknowledged-record-before-start procedure introduction, before step (1):

> For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident. This is the event time of incident creation, not the time of the recovered history. The transaction begins after the existing stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it is not claimed as a fact already proved by the formal model.
>
> The report separates that event from the history that survived. Persist a nullable conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence references when the incident is inserted. A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history. A non-null f MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather than an apparent finite interval.
>
> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record. Capture the observation before restart can erase it, or identify the complete record in retained WAL. The earlier-acknowledgement implication is the certificate: this timestamp is neither an exact snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN, filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound needs the same inclusion proof.
>
> A verified upper error bound on the incident transaction's event clock, with retained stopping/fencing evidence that no old-history acknowledgement follows that transaction's start, can supply f=restore_instant+e_event. Source and event clocks may have different error bounds; record their provenance. If either endpoint cannot be certified, persist null for it and say that endpoint is unknown. The event timestamp alone never substitutes for a missing history bound. Retain evidence outside the lost failure domain or with the incident so that continuation does not depend on the failed primary.
>
> Publish possible loss within [b,f] and its bounding duration only when both endpoints are known. Include b because the lower certificate guarantees commits acknowledged strictly before b. Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds. Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied. Continuations reuse the persisted endpoints and evidence unchanged. Backup restores use the same contract.

At 05:1656 replace “the report naming `T − Δ` is what tells the operator the clock moved” with:

> the possible-loss report identifies uncertainty in that history clock

No change to the stopped-components ordering, acknowledged incident record, quarantine, credential bump, derivation skip, grace anchor, continuation or close rules is proposed.

## STO-56

Add nullable `lost_window_starts_at`=b and `loss_end_at`=f, with their meanings owned by STO-54. Add an incident-keyed `history_evidence_ref` identifying the retained evidence/unknown-endpoint reason; the reference is non-null even when both bounds are unknown. Existing non-null `restore_instant` remains the event timestamp defined by STO-54. Endpoints/references are written with the row and continuations do not recompute them. No allocation-evidence admission gate is added.

## OVR-19

Add human STO-54-owned rows for source/event clock-error evidence and the endpoint capture, validation and retention procedure. A missing clock certificate produces an unknown endpoint under STO-54, not an automatic startup hold. No unvalidated finite error value may be silently assumed.

## Formal synchronization

Clarify the record/module documentation that restoreInstant/t.now abstracts the newly defined incident transaction event time. Retain the event assignments in RestoreTrace.store, afterCrash and bootRestore and the existing independent completeProcedure instant used by step_three_writes_grace. Interval/certificate publication remains outside this model's scope. Do not change a declaration to assign b or f to now, and do not claim compilation proves the certificate protocol.
```

## pv-kwuf check

### Owner’s precision answer

Source: `docs/research/panels-2026-10/r78/owner-decisions.md:9–9` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
Owner answer (verbatim): "Whole milliseconds (Recommended)"
```

### K-EXACT input-domain candidate and unchanged startup protocol

Source: `docs/research/panels-2026-10/r78/brief.md:78–90` at `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`.

```text
### Whole candidate K-EXACT

1. In OVR-19's **Startup-lock wait bound** type cell replace:
   > finite, positive duration; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)
   with:
   > finite duration expressible exactly as a positive whole number of milliseconds accepted by both `OPS-15` timeout settings, minimum 1 ms; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)
   This register cell owns the admissible range/precision. OVR-19 already orders startup validation; do not duplicate the numeric rule in OPS-15. Equivalent unit spellings are allowed when their duration is an exact whole millisecond.
2. Keep OPS-15's existing timeout-setting and loud/nonzero/no-claim exit sentences unchanged. No new retry or read-back protocol is added.
3. Append to CNF-369:
   > On independent startup attempts, supply a missing bound, zero, a negative duration, a non-finite duration, 400 microseconds, 600 microseconds, 1500 microseconds, and a whole-millisecond duration outside either store setting's accepted range. Assert startup refuses each with a non-zero exit before the generation advance, with no generation change, claim or provider call. With a bound of exactly 1 millisecond, assert validation accepts it and both effective timeout settings on the advance's connection are 1 millisecond; validation acceptance does not require the contested generation advance to succeed. Preserve this item's held-share timeout case and its existing exit/generation/session-commit assertions.

This changes accepted deployment inputs: all fractional milliseconds are refused, including ones PostgreSQL would round to a positive value. It adds runtime conformance checks, not a promise about an implementation's representation type.
```

## Exact option A — retain the per-restore instant on every retry

A keeps the two STO-56 supersession/retry paragraphs printed above verbatim. It replaces only the passages listed A1–A9 below. Its proposed selected event time precedes the first establishment attempt and follows existing stopping/fencing requirements; it is reused even if the first transaction aborts. The changes in the reporting upper-bound recipe are part of A, not a new test or precision rule. The lower-bound recipe, endpoint certificate obligations, unknown path, step-(3) grace anchor and continuation reuse are the printed STO-54 text. Check every collateral consequence rather than presuming these replacements are enough.

### A1 — exact replacement for `05-persistence.md:1636–1640`

```text
  For backup restore and restore-class promotion, restore_instant is the event time selected
  and retained under STO-56 before the first establishment attempt for this actual restore.
  This is the event time of that selection, not the time of the recovered history or of a
  later inserting transaction. The selection occurs after the existing stopping/fencing
  requirements are satisfied. Its clock definition is new; it is not claimed as a fact
  already proved by the formal model.
```

### A2 — exact replacement for `05-persistence.md:1660–1666`

```text
  A verified upper error bound on the selected event time's clock, with retained
  stopping/fencing evidence that no old-history acknowledgement follows that selection,
  can supply f=restore_instant+e_event. Source and event clocks may have different error
  bounds; record their provenance. If either endpoint cannot be certified, persist null for it
  and say that endpoint is unknown. The event timestamp alone never substitutes for a missing
  history bound. Retain evidence outside the lost failure domain or with the incident so that
  continuation does not depend on the failed primary.
```

### A3 — exact replacement for `tools/formal/Provisiond/Restore.lean:21–28`

```text
`Params` lists the guards dated amendments added, each a field so that removing it is a one-token
change a witness theorem exercises (`ADR-0025`). Every model here is one tenant, one machine, one
engine (`OPS-47`), and time does not advance: `now` abstracts the selected event time.
`STO-54` defines that event: "restore_instant is the event time selected and retained under
STO-56 before the first establishment attempt for this actual restore." This model does not
establish the clock selection or model recovered-history bounds. Interval/certificate
publication and its evidence protocol remain outside the model's scope.
```

### A4 — exact replacement for `tools/formal/Provisiond/Restore.lean:95–98`

```text
/-- `STO-56`'s restore record: `restore_instant`, and `grace_ends_at`, which "is null until step
(3) of `STO-54`'s procedure is marked". The `Provisiond.Claim.RestoreRecord` it extends is the
view a claim reads. `restoreInstant` abstracts the selected event time defined by `STO-54`,
not a recovered-history endpoint; the reporting endpoints and certificates are omitted. -/
```

### A5 — exact replacement for `tools/formal/Provisiond/Restore.lean:156–158`

```text
/-- `STO-54`'s trace: the backup holds the store `delta` steps before the crash, the provider's
facts are the crash's, and `now` abstracts the selected event time defined by `STO-54`,
independently of the recovered history. -/
```

### A6 — exact replacement for `tools/formal/Provisiond/Restore.lean:165–167`

```text
/-- The restored store: every row as the backup held it, with `applied` as the provider holds it,
and the record open, carrying its retained selected event time — committed before the engine starts,
so no run of the model has a window in which it is absent. -/
```

### A7 — exact replacement for `tools/formal/Provisiond/Restore.lean:431–439`

```text
/-- The successor. The crash clears `STO-51`'s session-scoped lock and this process's `passDone`.
The procedure marks, including `stepTwoMarked`, are the record's and stand, which is how
"a marked step does not run again" survives the process
that made the mark. The mode is the record's, and the instant is "read from the record and never
re-computed" — this model has no second clock to contradict it, so the parameter below decides the
mode and not the instant. That instant remains the selected event time defined by `STO-54`, not a
history bound. Everything else here is the store's or the trace's: the operator's
confirmation is the rows it moved, and `secondOrder`, `servedGens` and `parentResumedUnconfirmed`
record what has already happened. -/
```

### A8 — exact replacement for `tools/formal/Provisiond/Restore.lean:545–546`

```text
/-- `STO-54`: the engine comes up on the restored store; `t.now` is the selected event time
retained by the record, not the time of the recovered history. -/
```

### A9 — exact replacement for `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:252–270`

```text
This supersedes the numeric-report clause under *The decision* above. The reporting contract
and its arguments belong to `STO-54`: “A bound without valid evidence is unknown, not an invented
recovery time.” The retry-clock amendment replaces UO's original inserting-transaction definition. `STO-54`
now defines the event: “restore_instant is the event time selected and retained under STO-56
before the first establishment attempt for this actual restore.” For the endpoint fields and incident-keyed retained
evidence/unknown-reason reference, see `STO-56`; for the human deployment procedures, see
`OVR-19`. The scenario and fixture inventory is `10-conformance-checklist.md`, with the reporting
rehearsal in `CNF-295` and operator-promotion cases in `CNF-365`.

The accepted uncertainty does not impose finite-only admission: `STO-54` says “Missing reporting
evidence does not hold incident creation, the existing restore procedure or component startup
once its existing prerequisites are satisfied.” The stopped-system ordering remains the decision
in `ADR-0047`. The derivation-index obligation is separate: `05-persistence.md`'s
`deposits.derivation_index` row says “Allocated strictly increasing and never re-issued”. This
amendment adds neither an allocation-evidence admission gate nor a proof of the configured gap.

The synchronization in `tools/formal/Provisiond/Restore.lean` changes documentation only.
The selected event time is the abstraction used by `restoreInstant`/`now`;
`Event.completeProcedure` retains step (3)'s separate instant. Clock selection and the
reporting-certificate protocol remain outside that model's scope; compilation proves neither.
```

No Lean declaration, assignment, theorem or guard hypothesis is replaced by A’s printed form; the proposed formal edits are the exact documentation replacements above. Review whether this claim holds for the model’s arbitrary `Nat` event time and whether the meaning change needs any further paired declaration amendment. A new theorem or runtime test is a separate answer under question 4, not an implicit part of A.

## Exact option B — keep the inserting-transaction clock

B keeps STO-54’s full text and the existing formal/ADR clock descriptions printed above. It replaces only STO-56’s complete retry paragraph at `05-persistence.md:1442–1448` with the following exact text. The absent-record branch permits a later insertion for the same actual restore and id with that later transaction’s timestamp. A matching committed-record repeat preserves the committed instant. This does not choose the excluded predecessor-comparison repair; assess whether its surviving mismatch obligation is still coherent without that repair.

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

B adds no separate replacement for a generic evidence consumer: the persisted insertion event and the retained STO-54 certificate/continuation rules remain their owners. If B requires another live passage to change, provide its whole exact replacement before counting B acceptable. The historical P adoption remains on record; B would be a qualification of that adopted retry policy, not a verbatim re-application of P.

## Required answers — keep the fourth answer separate

1. **Conflict at the pin:** is the conflict real at c824e4f? Check PostgreSQL’s `transaction_timestamp()` semantics yourself against the official source. Trace (i) the first establishment transaction aborting/no committed N, and (ii) the first establishment transaction committing but its reply being lost. Separate an unsupported premise from an actual contradictory obligation. Do not reinterpret a failed attempt as a different actual restore or remove aborted attempts from a fixture to make the question disappear.
2. **Exact form:** final pick A, B, or an exact alternative complete form, with separate ACCEPT / CANNOT ACCEPT for each printed option. Check every proposed replacement and every dependency printed here. If neither is complete, give file/owner/before/replacement and the complete alternative, without silently combining repairs. A direction vote is not acceptance of unread words. State the strongest counterargument to your own pick, explicitly labelled “requested counterargument”.
3. **Substance and collateral effects:** separately assess behavior, requirement and check-strength change, especially any change beyond the passages printed. Quote the owning clause and give a trace for any loss. State what each replaced guard/definition protected. Check stopping/fencing, certificate truth, null/unknown path, endpoint reuse, record/start boundary, marker provenance, supersession, step marks, grace and ordinary continuation. Distinguish the substantive choice between A and B from a merely editorial synchronization. Flag any forced replacement missing from this packet. E-KEEP and pv-kwuf’s adopted input precision must remain consistent with the pick.
4. **SEPARATE CNF/GATE QUESTION:** does this clock decision need a new CNF case or a gate? Answer YES / NO / AMEND independently of your A/B vote; explain the concrete failure it would catch, and give exact proposed words if YES. Do not bundle a new test, new gate, stronger fixture, new formal mechanism or excluded predecessor algorithm into A or B. The current gate’s passing status does not establish this retry interaction, and absence of a new runtime test alone is not a contradiction in the unchanged base.

A reader may propose an exact alternative involving a different actual-restore policy or fixture scope, but it must be labelled new policy with its consequences and exact words. Those policies are not printed options A or B. This launch-only round does not authorize applying any answer.
