# r77b — Panel B Q1: complete provenance and repeated-restore repairs

Read this brief and notes.md whole. This is a **new complete-form reading**, authorized by the owner's r77 tally task. Neither candidate has been reviewed as a whole. No recommendation, adoption, source commit, tracker write or implementation is authorized. Q2 pv-8mt4 is outside this round: r77 accepted its printed M-I package and the manager is returning that choice to the owner. Do not re-vote Q2.

Work only inside your own detached clone at `1fc54e8f361e4a9342359388314d32c398595f62`, and your own `../<reader>.draft.md`. This folder is `/var/tmp/provisiond-panel-r77/r77b/`; check/ and notes.md refer to this folder. Read AGENTS.md. Do not access the main checkout, its branches/shared tracker, Panel A, production services, or credential/session/config stores including ~/.grok, ~/.claude and ~/.codex. Do not use br, change branches, commit, push or delegate/background work. You may prototype/build only in your own clone. Five seats: fable claude-fable-5-1 xhigh; opus claude-opus-5-5 xhigh; astra gpt-6-astra high; sol gpt-6.1-sol xhigh; grok grok-4.7 xhigh. Finish within 3600s; save a substantive draft by minute 45 and return a final answer in this turn. About 1600 words plus exact repairs/evidence.

Prior final answers are available read-only at /var/tmp/provisiond-panel-r77/fable.md, /var/tmp/provisiond-panel-r77/opus.md, /var/tmp/provisiond-panel-r77/astra.md, /var/tmp/provisiond-panel-r77/sol.md, /var/tmp/provisiond-panel-r77/grok.md. Consult them for the objections this form must answer; do not read another r77b seat's answer. The manager has checked the source premises below. Judge the full amended forms independently rather than accepting their repairs because a reader proposed them.

## The question, in plain terms

Recovery finishes enough to admit a new install. It records what it did and then the process dies while the recovery incident remains open. No database restore rolled back this new work. Should its later error preserve those facts or permanently replace them with unknown? Both candidates now also specify what to do if a later actual restore loads a backup that itself contains an unfinished recovery incident. This proposed supersession rule is a new owner policy choice, not an interpretation of the existing close rule.

**Vote on each complete package:** Y-PROV-R and Y-WIDE-R. For each give ACCEPT / AMEND / CANNOT ACCEPT, then one explicit final preference among acceptable packages or NONE. Exact location, before/replacement and behaviour changed/unchanged are required for an AMEND. A new runtime obligation, fixture restriction, payload change, lifecycle exception or supersession mechanism is behavioural. Strict wording/quotation repairs count only after verification. Use notes.md's settling rule, including no verified blocker; policy/cost choices still return to the owner. No unread repair is accepted by this read.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## What r77 established and what it did not

- All five answers were substantive. No Q1 package reached the owner's settling threshold. Direction preferences are not complete-package acceptance.
- The inherited-open-record trace is real: STO-56's unique open row and close prohibition obstruct establishing a new record before the old grace ends. A pointer to the unique rule alone does not solve it. The proposal below adds an explicit exception; test what it costs and what it discharges.
- WIR-9a's proposed “every key required above” was overbroad, and the replacement dropped the existing operator ambiguity instruction. Both are repaired explicitly below.
- Marking a row already needs_reconciliation can conceal previously retained facts, even though no new quarantine/pass transition moves it. That is now an explicit conservative scope change with its own case, not an assertion that baseline CNF-300 already tests the post-restore outcome.
- The old gloss that W hides facts “while the incident is open” was misleading. Its monotone bit makes that concealment persist for the affected operation after closure and purge. The repaired forms say this directly.
- No migration latency measurement, runtime conformance result or formal install-provenance theorem exists here. The existing create/power witness establishes timing only. Costs and new policy are open to rejection.

## Pinned sources for the fresh-work question

### Source and verified motivation

**WIR-9a — `13-wire-contract.md:196–222` at the pin:**

> **On an `install` operation's error, `details.disk_effect` is required whatever the kind** (*added
> 2026-09-15, `pv-x8r`*): `none` where this operation is established to have written nothing to the
> target disk — `OPS-45`'s write-started marker unset on `rootfs_via_rescue` or `raw_disk`, or a
> `provider_native`/`provider_catalogue` rejection the provider did not act on;
> `destructive_boundary_crossed` on `rootfs_via_rescue` or `raw_disk` once that marker is set, which
> tells the caller not to assume its prior contents survived and does not assert that the install
> completed; `unknown` after a `provider_native`/`provider_catalogue` dispatch whose effect nothing
> established. It is rendered from the operation's marker columns and outlives the payload purge with
> them (`OPS-45`). `status` alone never says which: `RSC-3`'s abort with the disk untouched and an
> installer's rejection of a layout it had begun partitioning for both settle `failed`, and without
> this key they are identical on the wire. `retryable` is `DOM-17`'s question about the same request,
> not this one — a rejected layout re-sent unchanged is refused again, and `disk_effect` does not make
> it sensible.
> 
> **On an `install` or `rescue_inventory` operation's error, `details.rescue_exit` is required whatever
> the kind** (*added 2026-09-15*): `none` only where no rescue session was opened, `clean` where the
> driver's end-rescue call returned success, `unknown` where it failed or the operation died before
> reaching it — `OPS-45`'s second marker, rendered as `disk_effect` renders the first. With `unknown`
> the error also carries `rescue_address` and `rescue_port` (`RSC-19`): the machine is the tenant's own
> and its address is already on `WIR-11`. It never carries a recovery-key path; the file is named by
> the operation id and the directory is the operator's (`RSC-20`).
> 
> **Neither key is rendered from markers a restore may have rolled back** (*added 2026-09-16*). On an
> operation the restore quarantine or the post-restore startup pass moved (`STO-54`, `OPS-15`),
> `disk_effect` and `rescue_exit` are both `unknown` whatever the columns hold: `STO-54` says of
> exactly those rows that "a null marker there does not mean the disk is untouched", and `none` on
> either key would tell the caller the opposite of what the operator is told about the same row.

**OPS-15 — `03-operation-lifecycle.md:369–377` at the pin:**

> **OPS-15** **AMENDED 2026-09-08 (`ADR-0016`) — the startup pass is the sweep.** Subject to the
> exceptions below, at startup, before any claim, the engine MUST move every `running` operation
> to `needs_reconciliation` — after the generation advance below no earlier engine's write commits
> (`OPS-50`), so any `running` row at startup is interrupted — guarded on `(id, status = running)`
> (`STO-3`), and MUST log the count it found. `OPS-50` says "MUST read `STO-59`'s row `FOR SHARE`
> as its first statement, compare it for equality with the value the engine's own startup pass
> wrote" and "Where the values differ, the transaction MUST roll back". It MUST NOT move them back to `queued`: a crashed
> worker is exactly the case where the provider may have acted and nobody recorded it. No periodic
> pass is needed; nothing but a restart can leave a `running` row with no worker behind it.

**OPS-15 — `03-operation-lifecycle.md:411–422` at the pin:**

> **What puts the pass on that branch is a record, not an operator's knowledge** (added 2026-09-20,
> `ADR-0023`). `STO-54` says "a process that starts while a restore record is open is continuing that
> incident, not restarting", so the successor of a process that died inside the procedure takes the
> restore branch, with the rest of the procedure it inherits. *Until then the branch had no
> predicate: a crash between the restore landing and this pass left the successor reading the
> paragraph above, which is the naive boot `ADR-0023` is written against.*
> **The pass over `running` rows runs at every startup, the record open
> or not.** `OPS-5` says a `running` operation "stays claimed until it settles, defers under `OPS-8`, or the
> startup pass finds it (`OPS-15`)", and a dead worker does neither of the first two. A marked step (2) keeps only
> its own work from running again (`STO-54`). While the record is open the create exception stays off, so a
> create found `running` goes to `needs_reconciliation`, and a `suspend_tenant` parent follows the restore rule
> above.

**STO-54 — `05-persistence.md:1582–1611` at the pin:**

>   **any `rate_confirmation_ref` already present is preserved**, because a restore is not an
>   observation and discharges nothing".* (2) *Before the first claim:* every `queued` create, install
>   and rescue inventory is moved to `needs_reconciliation` — a repeat is a second order, a second
>   disk write, a second boot into rescue — and `OPS-27` establishes what happened rather than doing
>   it again; the goal-state kinds (delete, power, end-rescue, release attachment, reverse DNS)
>   re-run, since `OPS-11` classifies "already in the target state" as `succeeded`; a `suspend_tenant`
>   parent found `running`, or `queued` and unsettled (`OPS-49`'s waiting parent is `queued`), waits
>   for operator confirmation instead of resuming. Its mark keeps this step from running again; it never suppresses `OPS-15`'s pass over `running` rows, which runs at every startup. (3) *Before the first `api` request:* the watch set
>   is re-derived (`STO-32`), both rails are replayed (`STO-31`), `SEC-39`'s counters are re-seeded,
>   every tenant's credential generation is bumped — the restored store cannot know which tenants
>   revoked inside Δ, so every spending token dies and each customer re-issues through the recovery
>   credential (`API-56`) — and `deposits.derivation_index` is skipped forward by the stated gap
>   (`OVR-19`) before any deposit is minted.
> - **The procedure survives its own interruption, because the incident outlives the process.** The
>   restore commits `STO-56`'s **restore record** — the restore instant, and which of the three steps
>   have completed — before either component is started, and **a process that starts while a restore
>   record is open is continuing that incident, not restarting**, whatever ended its predecessor. It
>   resumes at the first step the record does not mark, and every restriction above stands where its
>   step's mark is missing: the quarantine and the closed listener follow the record's marks exactly
>   as they follow the steps in a run nothing interrupts, and the freeze follows the marks and the
>   record's `grace_ends_at` (`STO-56`), so a process that starts after step (3)'s mark and before
>   that instant keeps the five actors frozen (*amended 2026-09-25, `ADR-0028`*). Without the record,
>   a process that died between the restore landing and step (2)'s pass is succeeded by one that comes
>   up under `STO-5`'s restart rule on a restored store — the boot this requirement exists to prevent,
>   on which every destructive case `ADR-0023` lists fires. **A marked step does not run again**: the
>   grace is written once per incident — `STO-56`'s `grace_ends_at`, in step (3)'s mark transaction —
>   the credential generation is bumped once, the derivation index is skipped once, and a customer
>   that re-issued after step (3) keeps the token it re-issued. A step interrupted before its mark
>   commits does run again, and that repeat is safe on each of its writes: the instant is read from
>   the record and never re-computed, step (2)'s quarantine is guarded on `(id, status = queued)`, and

**STO-54 — `05-persistence.md:1656–1662` at the pin:**

> start and its computed deadline move with what the backup holds, and the report naming `T − Δ` is
> what tells the operator the clock moved (*amended 2026-10-02, `ADR-0029`*); a `running` install
> found after a
> restore goes to `needs_reconciliation` with its `OPS-45` markers as the backup holds them, so a
> null marker there does not mean the disk is untouched and the operator resolves such a row as
> ambiguous — and `WIR-9a` renders both wire keys `unknown` on such a row for the same reason
> (*2026-09-16*); `LDG-72`'s checks pass on a consistent restore and prove nothing about it.*

**OPS-45 — `03-operation-lifecycle.md:1482–1498` at the pin:**

> `PRV-22` makes *failure* of the exit always ambiguous — so "nothing was written" is not on its own
> "nothing happened". The engine MUST therefore also record **whether the rescue session it opened
> was closed without error** — `rescue_exited_cleanly` (`05-persistence.md`), three-valued: **null**,
> the column before its first write, which says no session was opened (*reworded 2026-09-19; it read
> "where begin rescue was never dispatched"*); **false, written before begin rescue (`PRV-15`) is
> dispatched**, as the write-started marker is written before its phase, and standing while the
> session is open, where the exit fails and where the operation dies before reaching it; **true**
> when the driver's end-rescue call returns success. A dead process writes nothing, which is why
> `false` precedes the session and not the exit: it is what lets `OPS-15`'s pass render `rescue_exit:
> "unknown"` (`RSC-19`, `WIR-9a`). `false` is the conservative value as much as the open-session one:
> a process that dies between that write and the dispatch leaves `false` over a machine that was
> never rebooted into rescue, and the column does not separate that row from one whose session is
> still open. Null is the only value that means no session was opened, and `false` moves to `true`
> and never back. **A driver's report that it cleaned up after a partial activation (`PRV-18`) does
> not move this marker**: the engine did not open the session and did not close it. On failed
> deactivation `PRV-18` reports "the identifier of the rescue environment left behind"; on failed
> eligible-key deletion it reports "the identifier of the key left behind". `PRV-18` also says "A key

**CNF-302 — `10-conformance-checklist.md:2917–2935` at the pin:**

> - [ ] **CNF-302** — **`rescue_exit: "none"` is a fact, and the column is written before the session,
>       not after the exit** (added 2026-09-16). Drive an install refused before begin rescue —
>       `OPS-40`'s claim-time URL gate, or a `rescue_ssh` capability refusal (`DOM-10`) — and assert
>       `failed`, `rescue_exit: "none"`, no `rescue_address`, and `rescue_exited_cleanly` **null** in
>       the row and in `request_summary`. Then kill the engine after the pre-dispatch write commits
>       and before the begin-rescue dispatch (*step added 2026-09-20, `pv-v1f`*): no begin-rescue call
>       reaches the provider, `OPS-15` moves the operation to `needs_reconciliation`, the column is
>       **false** over a machine that was never rebooted into rescue, the error carries
>       `rescue_exit: "unknown"` with the `rescue_address` and `rescue_port` that `OPS-15`'s pass
>       renders from the machine row (`RSC-19`), and no key file exists. Then kill the engine between
>       the begin-rescue dispatch and the end-rescue call: `OPS-15` moves the operation to
>       `needs_reconciliation`, the error carries `rescue_exit: "unknown"` with `rescue_address` and
>       `rescue_port`, the column is **false**, and no key file exists (`RSC-19`: a crash persists
>       nothing, and `unknown` never implies a file). Then `CNF-301`'s clean exit: **true**. Then
>       repeat the pre-dispatch write after a simulated lost reply and assert it affects one row and
>       changes nothing (`ADR-0022`, `STO-3`). Then restore from a backup taken before the dispatch
>       and assert the quarantined row renders both keys `unknown` whatever the restored columns hold
>       (`WIR-9a`). Three distinct column values, or the item passes an implementation that writes the
>       marker only at the exit — which renders a crashed session as `none`, the one lie the column

The motivation is limited to what those lines establish. WIR-9a's heading refers to markers a restore may have rolled back; its body names the post-restore startup pass. OPS-15's pass applies at every startup, and STO-54 keeps the incident open beyond step (3). An ordinary process crash after fresh admission does not itself restore an earlier database. The fresh-work reachability is also explicit in `fresh_work_swept_after_restore` (Witnesses.lean:1433–1444): a fresh admitted create is claimed and applied after the procedure, then swept by its successor while the durable mark survives. That witness models create/power, not install marker values: it supports the timing only. The discrepancy is which wire facts to render; neither candidate changes `needs_reconciliation` into `failed`, retries the interrupted operation, proves that bytes landed, or infers a rescue session from the row's status. Do not import an install marker model that does not exist here.

## Additional pinned sources the repair must respect

**`05-persistence.md:1374–1408` at the pin:**

> **STO-56** **`restore_incidents`** — `id`, `restore_instant`, `steps_completed` (0 to 3),
> `grace_ends_at`, nullable (*added 2026-09-25, `ADR-0028`*), and `closed_at`, nullable. One row per
> restore (`STO-54`), written into the restored or promoted store before either component is started and closed
> by the operator; at most one row may have `closed_at` null, a partial unique index over the table.
> Both components read the open row before anything else they do: it is what says a starting process
> is continuing an incident rather than restarting, and `steps_completed` is what says where to
> resume, so neither fact depends on an operator being at the console when a process dies. *Added
> 2026-09-20 (`ADR-0023`).*
> 
> **`grace_ends_at` is the unpaused end of the restore grace, one stored instant for the whole
> incident** (*added 2026-09-25, `ADR-0028`; amended 2026-10-02, `ADR-0029`*). It is null until
> step (3) of `STO-54`'s procedure is marked, and it MUST be written in the same transaction as that
> mark, as step (3)'s instant plus one re-derivation interval — `STO-54` says "A marked step does
> not run again", so it is written once per incident. `OPS-41` owns its per-claim read and the
> funding-only paused check in the fence transaction; `STO-49` owns the history retained for that
> computation.
> The startup read above is taken once per process, so it cannot see an instant written or passed
> later in the incident. `STO-54` says "the freeze lifts at `grace_ends_at`"; keeping this record
> open does not prolong that freeze.
> 
> **The operator MUST NOT close the record until** step (3) is marked, `grace_ends_at` has passed,
> the account sweep's second pass is done, every waiting parent is confirmed or cancelled, and,
> for **each currency**, either its accumulated rate-present time since step (3) has reached one
> re-derivation interval (`OPS-41`) or every machine priced in that currency is recorded gone or
> fenced (`machines.destroy_committed` is non-null; `OPS-42`, `LDG-62`). A finished currency does
> not discharge another's obligation. Closing at the original end alone MUST NOT disable unspent
> paused grace for a currency with a live unfenced machine. The gone-or-fenced alternative requires
> no outage-bound crossing and discharges only that currency's grace obligation, not the wall-clock
> or other incident obligations.
> 
> *Amended 2026-10-04 (`pv-gip.27`).* The machine-disposition condition MUST be evaluated at the
> close, not latched from an earlier read: a late attach ordered before close can make it false
> again. An attach ordered after close MUST NOT reopen the incident and receives no restore grace;
> `OPS-41` owns the worker's no-open-record case. No general post-return survival interval is added.
> 

**`05-persistence.md:1442–1457` at the pin:**

> **STO-13** **AMENDED 2026-09-12 (`ADR-0024`) — both halves, each where it is cheap, and the class
> neither half makes safe.** Migrations MUST be forward-only and MUST be applied by the deployable's
> own `migrate` entry point, run by the deployment **before any component of a release starts and
> while the previous release's engine and `api` keep running** — never by `api`, and never by the
> engine at boot, whose restart window `ADR-0016` priced at seconds and `OVR-18` alarms. Every
> migration MUST be safe against a running instance of the previous release of both components:
> 
> - it MUST NOT drop, rename or narrow a column, table or type;
> - it MUST NOT add a `NOT NULL` column a previous-release writer does not populate — such a column
>   is nullable in the release that adds it and tightened after a backfill in a later one;
> - it MUST NOT add a constraint a previous-release write can violate;
> - it MUST NOT write a value of an enumerated column the previous release does not recognize —
>   `STO-10` makes that "a hard error, not a silent default" on every old reader — so **the release
>   that adds a value does not write it, and the release after may**;
> - DDL that takes `ACCESS EXCLUSIVE` MUST run under a stated `lock_timeout` and retry count
>   (`OVR-19`), and index builds on `operations`, `ledger_entries` and `machines` MUST be

**`10-conformance-checklist.md:2894–2908` at the pin:**

> - [ ] **CNF-300** — **A `failed` install says what it did to the disk, and the state never carries
>       it** (added 2026-09-15, `pv-x8r`). Drive a `rootfs_via_rescue` install whose installer starts
>       and then rejects the layout, with the rescue exit succeeding and the engine reporting
>       `invalid_request`: assert the operation settles `failed`, `terminal: true`, `retryable` is
>       what `DOM-17` gives that kind, and the error carries `details.disk_effect:
>       "destructive_boundary_crossed"`. Then `CNF-279`'s pinned-key abort: `failed` with
>       `disk_effect: "none"`. Then a `provider_native` rebuild the provider rejects `not_found`
>       before acting: `failed` with `disk_effect: "none"`. Then `CNF-279`'s failed rescue exit: `needs_reconciliation`,
>       `retryable: false`, `disk_effect: "none"` (it aborted before writing) and `rescue_exit:
>       "unknown"`; and an ambiguous `provider_native` dispatch: `disk_effect: "unknown"`,
>       `rescue_exit: "none"` (*corrected 2026-09-16; the first draft paired the abort with
>       `destructive_boundary_crossed`*). Assert every install error carries
>       the key, and that the two `failed` rescue installs differ on nothing but it — or the item
>       passes an implementation whose callers cannot tell an untouched disk from a partitioned one.
>       (`OPS-3`, `OPS-11`, `OPS-45`, `API-51`, `WIR-9a`)

**`03-operation-lifecycle.md:1085–1106` at the pin:**

>    including the re-derived date write, fence clearing and episode closure where applicable.
>    **Only if the predicate would cancel**, and a restore record is open, its original
>    `grace_ends_at` has passed, and the currency has accumulated less than one re-derivation
>    interval of rate-present time since step (3), the worker MUST return the attempt to `queued`
>    by `OPS-8`'s ordinary short delay. The paused check reads the restore record and currency
>    history on this transaction's reads, including the returned rate it sees, never the claim's
>    rate snapshot. It writes no new fence, makes no provider call, and neither settles the attempt
>    nor closes its episode. Otherwise it proceeds to the existing fence and cancellation path.
>    *Amended 2026-10-03 (`ADR-0029`): the paused check moved here from the claim. Withdrawn:
>    "After that wall-clock end, while a rate exists and a funding cancellation has unspent grace,
>    the claim MUST return the attempt to `queued` with `available_at` equal to
>    `now + (one re-derivation interval − accumulated rate-present time)`, the paused end computed
>    at this claim." The ordinary short delay replaces that availability.*
> 4. **There is no rate, and the outage's deadline has not passed** (`LDG-64` holds how the deadline
>    is computed). The claim defers: the operation is returned to `queued` by `OPS-8`'s ordinary
>    short delay, and no fence is written.
> 5. **There is no rate, and the deadline has passed.** This is `LDG-64`'s bound. The worker MUST, in
>    the same fence transaction, conditional-write **this machine's** open `rate_outage` deficiency
>    record (`STO-37`, guarded on `absorbed_until IS NULL`; a no-op write on the row, whose only
>    purpose is to contend). Where that write affects a row, the outage is still open for this
>    machine and the cancellation proceeds. Where it affects no row and a rate is now in force —
>    restoration (`LDG-64`) closed the record first — the worker takes step 3 at that returned rate,

## Complete alternative packages

Each package consists of **all common amendments C1–C7**, its own P or W paragraph in C3, and its own column in the expected-value table. They are alternatives, not simultaneous obligations. The scoped column, upgrade policy and supersession exception are declared changes, not baseline facts. No clause below authorizes replay or deterministic settlement of an interrupted install/inventory operation.

### C1 — target storage and staged upgrade (both packages)

Add next to the OPS-45 marker columns in the operations table in 05-persistence.md:

| Field | Type | Constraint / meaning |
|---|---|---|
| restore_markers_untrusted | boolean | target non-null after STO-13's staged migration; retained with the operation after payload purge; provenance owned by STO-54; wire rendering owned by WIR-9a |

Add this upgrade paragraph to STO-54's new marker-provenance block:

> **Provenance upgrade.** The release that adds the column leaves it nullable; see STO-13. For an install or rescue-inventory row, a null column MUST be treated as untrusted for rendering. The backfill MUST set a still-null column true on every existing install or rescue-inventory row, including a settled row, and false on other kinds; it MUST NOT overwrite a non-null value. After previous-release writers are retired and the remaining nulls are backfilled, a later release tightens the column to non-null. No pre-column marker history is treated as sufficient to initialize false. This deliberately conceals legacy facts, including settled retained errors; it does not claim those facts were rolled back.

This is a conservative deterministic upgrade policy, rather than r77's undefined “provenance cannot be established” predicate. It differs from fable's proposed settled=false migration. Null is a transitional storage value, not a fourth value of either OPS-45 marker.

### C2 — marker provenance (both packages)

Add to STO-54 before its procedure-survives-interruption bullet:

> **Marker provenance.** An operation of any kind other than install or rescue inventory MUST be inserted with restore_markers_untrusted = false; this column has no marker-rendering effect for those kinds. A new install or rescue-inventory operation MUST be inserted with restore_markers_untrusted = false in its admission transaction. On each actual store restore, before either component starts, the acknowledged transaction that establishes the restore record MUST set this column true on every surviving install or rescue-inventory row whose status is queued, running or needs_reconciliation. The marker columns themselves are preserved. A successor continuing an existing incident after a process crash MUST NOT repeat this initialization. Once true the column MUST NOT be cleared on that operation, including at incident closure or payload purge. Another actual restore applies the initialization again. An open incident inherited from the restored store is superseded under STO-56; an ordinary process successor never supersedes it. The column is operation metadata and is not added to request_summary's closed enumeration.

The status set deliberately includes rows already needs_reconciliation. This can change an ordinary none/unknown error to unknown/unknown on a later restore without another status transition. Already-settled rows with established non-null provenance are not invalidated merely by surviving an actual restore; the separate legacy-upgrade rule above can conceal settled legacy facts.

### C3 — the only wire-policy difference

**Y-PROV-R only**, after C2 add:

> The restore quarantine and each startup pass preserve restore_markers_untrusted. In particular a row newly admitted after step (3), interrupted by a process crash, and moved by its successor retains false unless a later actual store restore invalidated it. Whether the incident is still open does not itself invalidate markers of newly admitted work.

**Y-WIDE-R only**, instead add:

> While a restore record is open, each restore-quarantine or startup-pass transition of an install or rescue-inventory row to needs_reconciliation MUST set restore_markers_untrusted = true in the same guarded transaction as the transition, including a row admitted after step (3). This records incident scope, even where no restore rolled back that row's markers. On an ordinary restart with no open restore record, the startup pass preserves the column. Once the transition has set true, the affected operation's marker facts remain hidden after closure and purge; closure does not restore trust.

### C4 — exact wire/owner edits (both packages)

Replace WIR-9a's whole restore-marker paragraph (source 218–222) with:

> **Restore marker provenance is durable (STO-54).** On an install or rescue-inventory operation's error, disk_effect (install) and rescue_exit (both kinds) are rendered unknown where restore_markers_untrusted is true or transitionally null, whatever the marker columns hold. Where it is false, the ordinary marker rendering above applies. An unknown rescue_exit retains the address-and-port requirements above; those fields are not replaced with unknown. Neither incident closure nor an ordinary restart with no open restore record changes the provenance used for rendering.

Replace STO-54's running-install passage (source 1657–1662, from “a running install” through its 2026-09-16 note) with:

> a running install found after a restore goes to needs_reconciliation with its OPS-45 marker columns as the backup holds them, so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous. See the marker-provenance rule above and WIR-9a for rendering;

Preserve the source's inline-code formatting on identifiers when applying these candidate words. The ambiguity instruction is preserved verbatim in words; it is not replaced by a model proof or an automatic settle rule. Add a bare pointer after OPS-15's every-startup paragraph:

> For marker provenance and its wire rendering, see STO-54 and WIR-9a.

### C5 — inherited-open-record supersession (both packages; NEW POLICY)

In STO-56's opening field list, replace “and closed_at, nullable.” with:

> closed_at, nullable, and supersedes_incident_id, nullable, a foreign key to the retained predecessor record.

In the same opening paragraph, replace “and closed by the operator” with “and closed by the operator under the rules below”. Keep “One row per restore” and the partial unique open-row index. After its opening paragraph add:

> **Actual-restore supersession.** On an actual store restore whose restored store contains an open incident R, the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R in supersedes_incident_id, with the new restore instant, steps_completed = 0, grace_ends_at = null and closed_at = null. R is retained. For provenance initialization and the start boundary, see STO-54. Supersession is the sole exception to the ordinary close conditions below: it replaces the predecessor's outstanding recovery obligations with the new incident's full procedure and close conditions, and no predecessor step mark satisfies a new step. No component starts between closing R and establishing the new record. Where the restored store has no open incident, the new record has supersedes_incident_id null. A process crash without an actual store restore creates and supersedes no incident.

Add immediately after that paragraph:

> The operator MUST select and retain one new incident id and restore instant per actual restore before attempting establishment, and reuse both on a lost-reply retry. Repeating establishment with that id MUST affect the matching record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant. A mismatch in the id's restore instant or predecessor MUST be refused with both components stopped. The initial establishment or its matching no-op repeat MUST be acknowledged before either component starts. A new actual store restore uses a distinct id even when the predecessor incident is still open.

This retry rule is a manager-proposed addition to sol's supersession repair and is unreviewed along with the complete package. It supplies no permission to reuse an inherited predecessor's id for a new actual restore.

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

| Install case after successor pass | Y-WIDE-R disk_effect / rescue_exit | Y-PROV-R disk_effect / rescue_exit |
|---|---|---|
| Old unsettled row exposed to rollback, restored null/null | unknown / unknown | unknown / unknown |
| Fresh (a), null/null, no later actual restore | unknown / unknown | none / none |
| Fresh (b), write marker set, rescue false | unknown / unknown | destructive_boundary_crossed / unknown |
| Fresh (c), write marker set, rescue true | unknown / unknown | destructive_boundary_crossed / clean |
| Formerly fresh unsettled row exposed to another actual restore | unknown / unknown | unknown / unknown |
| Existing unresolved CNF-300-derived row, after actual restore | unknown / unknown | unknown / unknown |

### C7 — scope and separate costs

Both packages add admission metadata, a retained column, staged migration/backfill, a bulk provenance write before startup, and supersession policy/metadata. Recovery latency and WAL cost are unmeasured; unsettled backlog is not assumed small. Conservative upgrade deliberately conceals legacy facts, including settled error facts. The already-reconciling-row change is deliberate. W additionally conceals trustworthy fresh facts permanently for each affected operation and writes the bit during each specified transition; P preserves that provenance distinction. The proposed supersession grants a new full recovery procedure/grace and replaces predecessor obligations, with any further necessary collateral edits still a reason to reject this printed form. None of these costs is called negligible or approved by the owner.

Neither package changes OPS-15's interrupted-operation settlement, authorizes replay, proves bytes landed, or infers an actual rescue session from status. The formal Rescue helper still lacks a restore-provenance input; inspect whether the candidate changes a formalized clause that needs a paired Lean edit under AGENTS.md/ADR-0025. Report coverage separately from a contradiction; no new formal/runtime coverage is claimed by these candidates.

## Adversarial checks and final answer format

1. Give marks on both **whole packages** and one final preference among acceptable packages or NONE. Does the source justify retaining the changed status scope, or does it conceal a verdict the form failed to disclose?
2. Trace initialization before all startup paths, including restore-classified promotion; a process successor; actual restore over an open incident; a second supersession; a lost establishment reply; incident closure; purge; and staged upgrade. Does a deleted close guard protect something the new full procedure fails to preserve? Quote the relevant MUST/SHOULD or checked verdict and give the full adverse trace. Do not accept supersession just because setting a Boolean is idempotent.
3. Check the new field, null-upgrade semantics, ordinary/supersession close rules, companion fields, all table cells and exact conformance assertions together. Declared alternatives and disclosed changed obligations are not hidden baseline losses; undisclosed collateral changes still matter. An absent new runtime test is not a baseline contradiction.
4. Identify every factual claim of this brief you broke, whether it changes this question's premise, and any vote resting on it. apply notes.md rule 6 exactly as written; this prompt adds no void rule.
5. Label the strongest argument against your preferred package as a **requested counterargument, not a vote**. Any exact behavioural repair or alternative lifecycle is unreviewed until its own complete-form read. State checks actually run, failures and not-run checks. Return no implementation approval.
