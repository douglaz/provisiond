# r77 — Panel B: successor recovery

Read this brief and `/var/tmp/provisiond-panel-r77/notes.md` whole before deciding. Your working directory is your private detached clone at pinned origin/master `1fc54e8f361e4a9342359388314d32c398595f62` (reconfirmed during this launch check; see check/claim-verification.json); the approved triage was based on `4662d85`, but this round deliberately reads that pinned master. The two exact triage rows are copied in `check/triage-questions.md`. Another manager may be working on pv-6350 PR preparation in the main checkout; do not access that checkout or Panel A. Do not run br, change branches, commit, push, contact production, or mutate anything outside your own reader clone. You may build/prototype inside that clone and write your own `../<reader>.draft.md`; these are the only permitted writes. Panel-artifact paths (`check/`, notes.md and STATE.md) are relative to `/var/tmp/provisiond-panel-r77/`; repository source paths refer to your own clone. Raw evidence and output stay under this panel directory. No implementation, approval, or automatic follow-on round is authorized.

Five independent seats read identical forms: fable claude-fable-5-1 xhigh; opus claude-opus-5-5 xhigh; astra gpt-6-astra high; sol gpt-6.1-sol xhigh; grok grok-4.7 xhigh. Read AGENTS.md. Do not deliberately read credential/session/config stores, including `~/.grok`, `~/.claude` or `~/.codex`. Do not delegate/background any work. Finish within the wrapper's 3600s timeout. Write a substantive draft to `../<your-reader-label>.draft.md` by minute 45 if still working; return your final answer in this turn. Limit the answer to about 1600 words plus exact repairs or concise proof evidence.

The numbered outcome rules 1–7 in notes.md retain r76 except for rule 2's settling count, replaced verbatim by the owner's 2026-10-28 rule. The current Model and Quota rules govern this five-seat round. Treat Q1 and Q2 separately. For each exact package give ACCEPT / AMEND / CANNOT ACCEPT and one explicit final preference among acceptable packages or NONE. An AMEND must quote location, before and replacement, and label behaviour changed/unchanged. A direction vote is not package acceptance. Any new combined form needs its own complete-form reading. Apply notes.md rule 2's exact settling sentence and its unchanged no-verified-blocker condition; the owner still decides any tie or policy/cost choice. No majority is permission to implement.

Every tally prompt must say: apply notes.md rule 6 exactly as written; this prompt adds no void rule.

## Q1 — pv-ymjo: may a fresh operation keep trustworthy markers?

Plain terms: recovery gets far enough to accept a new install. That install records what it did, and then the engine crashes while the recovery incident remains open. The successor must reconcile the interrupted install. Should its error hide those surviving facts as unknown because recovery is still open, or render the facts because no restore rolled them back? This is a wire-output decision, not a proposal to rerun or auto-fail the install.

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

### Complete alternative packages Y-WIDE and Y-PROV

These are alternative proposed amendments, not an interpretation already accepted by the owner. Each package includes all common text below, its own STO-54 paragraph, and its exact expected cells in the shared conformance addition. The durable Boolean is proposed openly, not asserted to exist today. Read the whole package rather than voting only on the direction. A smaller mechanism is welcome only as an exact AMEND, not as acceptance of an unstated form.

**Common storage and ownership text, included in both packages.** Add this operation-table row in `05-persistence.md` next to the OPS-45 markers:

| Field | Type | Constraint / meaning |
|---|---|---|
| `restore_markers_untrusted` | boolean | non-null; retained with the operation after payload purge; provenance and changes are owned by `STO-54`; wire rendering is owned by `WIR-9a` |

Add to STO-54 before the procedure-survives-interruption bullet:

> **Marker provenance.** An operation of any kind other than install or rescue inventory MUST be inserted with `restore_markers_untrusted = false`; this column has no marker-rendering effect for those kinds. A new install or rescue-inventory operation MUST be inserted with `restore_markers_untrusted = false` in its admission transaction. On each actual store restore, before either component starts, the acknowledged transaction that establishes the restore record MUST set this column true on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`. A successor continuing an existing incident after a process crash MUST NOT repeat that initialization. The column is durable across successor startups, incident closure and payload purge, and MUST NOT be cleared on that operation. Another actual restore applies the initialization again, including when an earlier incident was still open. Rows predating the column for which provenance cannot be established MUST initialize true; this conservative upgrade treatment is an explicit new obligation. The marker columns themselves are preserved. This column is operation metadata and is not added to `request_summary`'s closed enumeration.

For **Y-WIDE only**, immediately following that common STO-54 paragraph add:

> While a restore record is open, each restore-quarantine or startup-pass transition of an install or rescue-inventory row to `needs_reconciliation` MUST set `restore_markers_untrusted = true` in the same guarded transaction as the transition, including a row admitted after step (3). This records incident scope, even where no restore rolled back that row's markers. On an ordinary restart with no open restore record, the startup pass preserves the column.

For **Y-PROV only**, instead add:

> The restore quarantine and each startup pass preserve `restore_markers_untrusted`. In particular a row newly admitted after step (3), interrupted by a process crash, and moved by its successor retains false unless a later actual store restore invalidated it. Whether the incident is still open does not itself invalidate markers of newly admitted work.

For **each package**, replace WIR-9a's entire restore-marker paragraph (source lines 218–222) with this exact text:

> **Restore marker provenance is durable (`STO-54`).** On an install or rescue-inventory operation's error, every key required above is rendered `unknown` where `restore_markers_untrusted` is true, whatever the marker columns hold. Where it is false, the ordinary marker rendering above applies. `unknown` rescue exit retains the address-and-port requirements above. Neither incident closure nor an ordinary restart with no open restore record changes the provenance used for rendering.

For **each package**, replace STO-54's running-install passage (source lines 1657–1662, from “a `running` install” through “(*2026-09-16*)”) with:

> a `running` install found after a restore goes to `needs_reconciliation` with its `OPS-45` marker columns as the backup holds them. See the marker-provenance rule above and `WIR-9a` for rendering;

For **each package**, add a bare pointer after OPS-15's every-startup paragraph:

> For marker provenance and its wire rendering, see `STO-54` and `WIR-9a`.

For **each package**, append to CNF-302:

> Keep a restore incident open through the following paired cases. Restore a backup with an unsettled install whose markers are null although its destructive phase and rescue dispatch occurred in the lost interval. Complete step (3), then assert the old row renders both keys `unknown`. Admit separate fresh raw-disk installs after step (3), and crash the engine while each remains `running`: (a) before either marker write, (b) after the write-started marker and the pre-rescue false marker have committed, (c) after the write-started marker and clean rescue exit true marker have committed but before settlement. Run the successor's startup pass and assert each row is `needs_reconciliation`, with no replay or automatic deterministic settlement. Assert the exact fresh-row wire values in the selected form's table. Repeat successor startup and then close the incident using its existing close conditions; poll the retained operation and assert its wire values do not change merely because of closure or payload purge. In another actual restore from a backup containing a still-unsettled formerly fresh row, assert it now renders both keys `unknown`. For rescue inventory, repeat the old-row and later-restore cases with `rescue_exit: "unknown"` under both packages. For separate fresh rescue-inventory rows with the rescue marker null, false and true, assert respectively `unknown`, `unknown`, `unknown` under Y-WIDE and `none`, `unknown`, `clean` under Y-PROV. Do not write an install write-started marker or introduce `disk_effect` on that kind. Check the untrusted column and rendering across a lost transition reply and a repeat. A pre-column row with unestablished provenance follows the conservative true case.

| Install case after successor pass | Y-WIDE disk_effect / rescue_exit | Y-PROV disk_effect / rescue_exit |
|---|---|---|
| Old unsettled row exposed to actual rollback, restored null/null | unknown / unknown | unknown / unknown |
| Fresh (a): null/null, no later actual restore | unknown / unknown | none / none |
| Fresh (b): write marker set, rescue false | unknown / unknown | destructive_boundary_crossed / unknown |
| Fresh (c): write marker set, rescue true | unknown / unknown | destructive_boundary_crossed / clean |
| Formerly fresh unsettled row exposed to another actual restore | unknown / unknown | unknown / unknown |

The common initialization assigns false on other kinds solely to satisfy the non-null storage column; it adds no wire key on those kinds. It marks surviving unsettled install/rescue-inventory rows before quarantine, not just rows that happen to transition on a later pass. It does not invalidate already-settled rows merely because they survive in a backup. The declared conservative pre-column initialization can conceal additional legacy facts; report that separately as a disclosed upgrade-policy cost. Both packages add a bulk provenance write before startup; report its scope/latency cost rather than assuming it free. Y-WIDE also hides valid fresh facts while the incident is open; Y-PROV requires preserving the provenance distinction. No existing schema migration or runtime test of either package is claimed here.

**Q1 question:** Which exact package can you accept: Y-WIDE, Y-PROV, both, or neither? Identify your preference and strongest reason. Does the common provenance initialization occur early enough, survive a second actual restore and every successor, and avoid treating process crash as rollback? Are the rules, table, conformance addition and scope internally consistent? Do rescue companion fields and retained-error rendering still agree? If you reject the Boolean or its initialization cost, provide a complete smaller durable mechanism, initialization, successor rule and matching old/fresh assertions as an AMEND. Do not simply recommend “trust fresh markers” without its mechanism.

## Q2 — pv-8mt4: a skipped pass must not also freeze every new claim

Plain terms: the current bad-model test can leave an old operation marked running after a crash. But its skipped pass also stops every later claim. It therefore cannot demonstrate the bug where an engine abandons old work while accepting and executing new work. We want that additional counterexample, while preserving the current good model and the existing theorem.

### Source and verified motivation

**OPS-15 / STO-54 model state — `tools/formal/Provisiond/Restore.lean:299–315` at the pin:**

> structure World where
>   fault            : Fault
>   store            : Store
>   /-- The restore instant. Time does not advance. -/
>   now              : Nat
>   /-- The deployment's re-derivation interval (`PRV-13e`). -/
>   interval         : Nat
>   /-- `STO-51`'s startup lock taken. Session-scoped, so a crash clears it. -/
>   locked           : Bool
>   /-- `OPS-15`'s running-row pass done by this process; a crash clears it. -/
>   passDone         : Bool
>   /-- Step (2) done: on a restore, a durable mark of the restore record; the first startup pass also
>   sets it on a restart. A crash keeps it. -/
>   stepTwoMarked    : Bool
>   /-- Step (3) done, a mark of the record, and `grace_ends_at` written in the same transaction
>   (`STO-56`). -/
>   procedureComplete : Bool

**STO-54 permits — `tools/formal/Provisiond/Restore.lean:347–358` at the pin:**

> def permits (p : Params) (w : World) : Permissions :=
>   match w.fault with
>   | .restart =>
>     { claim := w.locked && w.passDone && (!w.fault.isRestore || w.stepTwoMarked), serve := true, recordAbsence := true, run := fun _ => true }
>   | .restore =>
>     { claim := w.locked && w.passDone && (!w.fault.isRestore || w.stepTwoMarked),
>       serve := w.procedureComplete,
>       recordAbsence := !p.twoPassAbsence || (decide (1 ≤ w.completePasses) && w.windowElapsed),
>       run := fun c => match c with
>         | .suspendTenantException =>
>           !p.exceptionFrozen || (w.procedureComplete && w.parentsConfirmed)
>         | c => !frozenOnRestore c || w.procedureComplete }

**STO-54 / OPS-15 transitions — `tools/formal/Provisiond/Restore.lean:426–448` at the pin:**

> /-- The successor. The crash clears `STO-51`'s session-scoped lock and this process's `passDone`.
> The procedure marks, including `stepTwoMarked`, are the record's and stand, which is how
> "a marked step does not run again" survives the process
> that made the mark. The mode is the record's, and the instant is "read from the record and never
> re-computed" — this model has no second clock to contradict it, so the parameter below decides the
> mode and not the instant. Everything else here is the store's or the trace's: the operator's
> confirmation is the rows it moved, and `secondOrder`, `servedGens` and `parentResumedUnconfirmed`
> record what has already happened. -/
> @[req "STO-54"]
> def afterCrash (p : Params) (w : World) : World :=
>   { w with fault := faultAfterCrash p w.store,
>            now := (w.store.record.map (·.restoreInstant)).getD w.now,
>            locked := false, passDone := false }
> 
> def step (p : Params) (w : World) : Event → World
>   | .lock => { w with locked := true }
>   | .startupPass =>
>     if w.locked && !w.passDone && (p.passEveryStartup || !w.stepTwoMarked) then
>       { w with passDone := true, stepTwoMarked := true,
>                store := { w.store with ops := fun j =>
>                  let o := w.store.ops j
>                  if o.status = .running || !w.stepTwoMarked then passOp p w o else o } }
>     else w

**STO-54 claim/admit/apply transitions — `tools/formal/Provisiond/Restore.lean:458–477` at the pin:**

>   | .claim i =>
>     let o := w.store.ops i
>     let perm := permits p w
>     if perm.claim && o.status = .queued
>         && (o.kind ≠ .suspendTenant || perm.run .suspendTenantException) then
>       { w with store := w.store.modify i fun o => { o with status := .running },
>                secondOrder := w.secondOrder || (irreversible o.kind && o.applied),
>                parentResumedUnconfirmed := w.parentResumedUnconfirmed
>                  || (o.kind = .suspendTenant && w.fault.isRestore && !w.parentsConfirmed) }
>     else w
>   | .admit i =>
>     let o := w.store.ops i
>     if w.procedureComplete && w.store.unused i && !o.applied then
>       { w with store := { w.store.modify i fun o => { o with status := .queued } with
>                  unused := fun j => if j = i then false else w.store.unused j } }
>     else w
>   | .apply i =>
>     if (w.store.ops i).status = .running then
>       { w with store := w.store.modify i fun o => { o with applied := true } }
>     else w

**OPS-15 theorem (statement must stand) — `tools/formal/Provisiond/Restore.lean:503–526` at the pin:**

> /-- `OPS-15`: "The pass over `running` rows runs at every startup, the record open or not."
> With `hp : p.passEveryStartup = true`, a successor sweeps every running row except a parent
> whose exception is still frozen. `Provisiond.Witnesses.successor_strands_power_without_pass`
> refutes the statement without `hp`, using a power operation claimed after step (2). -/
> @[req "OPS-15"]
> theorem successor_sweeps_running (p : Params) (hp : p.passEveryStartup = true)
>     (w : World) (j : OperationId) :
>     let v := run p w [.crash, .lock, .startupPass]
>     (v.store.ops j).status = .running →
>     (v.store.ops j).kind = .suspendTenant ∧
>       (permits p v).run .suspendTenantException = false := by
>   let v := { afterCrash p w with locked := true }
>   change ((step p v .startupPass).store.ops j).status = .running →
>     ((step p v .startupPass).store.ops j).kind = .suspendTenant ∧
>       (permits p (step p v .startupPass)).run .suspendTenantException = false
>   have hl : v.locked = true := rfl
>   have hd : v.passDone = false := rfl
>   simp only [step, hp, hl, hd, Bool.not_false, Bool.true_and, Bool.true_or, if_true]
>   cases hs : (v.store.ops j).status <;> cases hk : (v.store.ops j).kind <;>
>     simp_all [passOp, permits, irreversible] <;>
>     (try (split <;> simp_all)) <;> (try (split <;> simp_all))
>   all_goals
>     cases hm : v.stepTwoMarked <;> cases hq : p.quarantineOnRestore <;>
>       cases hf : v.fault <;> simp_all [Fault.isRestore]

**OPS-15 existing positive and negative witnesses — `tools/formal/Provisiond/Witnesses.lean:1390–1444` at the pin:**

> /-- Pin the independent restore guards for fresh-work witnesses. -/
> def restoredWorkParams : Restore.Params :=
>   { quarantineOnRestore := true, exceptionFrozen := true, bumpOnRestore := true,
>     twoPassAbsence := true, recordDecidesBoot := true, createExceptionOnRestart := true,
>     passEveryStartup := true }
> 
> /-- Keep the startup-pass control isolated from the other `current` fields. -/
> def startupPassGuards (p : Restore.Params) : Restore.Params :=
>   { restoredWorkParams with passEveryStartup := p.passEveryStartup }
> 
> /-- A queued power row and two unused create ids beside the original restore rows. -/
> def freshWorkTrace : RestoreTrace :=
>   { restoreTrace with
>     history := { initial := { liveStore with
>       ops := fun j =>
>         if j = ⟨3⟩ then { kind := .power, status := .queued, applied := false }
>         else if j = ⟨4⟩ ∨ j = ⟨5⟩ then
>           { kind := .createMachine, status := .succeeded, applied := false }
>         else liveStore.ops j,
>       unused := fun j => decide (j = ⟨4⟩ ∨ j = ⟨5⟩) }, steps := [] }, delta := 0 }
> 
> /-- Claim the power operation after step (2), then let the successor run its pass. -/
> def postStepTwoPower : List Restore.Event :=
>   [.lock, .startupPass, .claim ⟨3⟩, .crash, .lock, .startupPass]
> 
> /-- `OPS-15`, 2026-10-23: the successor sweeps the power claimed after step (2), while
> preserving the procedure's mark. The other guards are pinned to isolate `passEveryStartup`. -/
> @[req "OPS-15"]
> theorem successor_sweeps_power :
>     let w := Restore.run (startupPassGuards Restore.current) (bootRestore freshWorkTrace)
>       postStepTwoPower
>     (w.store.ops ⟨3⟩).status = .needsReconciliation ∧ w.stepTwoMarked = true ∧
>       w.passDone = true := by decide
> 
> /-- Refutes `Provisiond.Restore.successor_sweeps_running` without `hp`: the power claimed after
> step (2) stays running after the crash, lock and attempted startup pass. -/
> @[req "OPS-15"]
> theorem successor_strands_power_without_pass :
>     let p := { restoredWorkParams with passEveryStartup := false }
>     let w := Restore.run p (bootRestore freshWorkTrace) postStepTwoPower
>     (w.store.ops ⟨3⟩).kind = .power ∧ (w.store.ops ⟨3⟩).status = .running ∧
>       w.stepTwoMarked = true ∧ w.passDone = false := by decide
> 
> /-- Fresh creates admitted after step (3) are expressible. One is claimed and applied; one
> stays queued. After a crash the pass reconciles the claimed create and power, preserves the
> fresh queued create, and permits the queued delete. Step (2)'s mark survives. -/
> @[req "OPS-15"]
> theorem fresh_work_swept_after_restore :
>     let w := Restore.run restoredWorkParams (bootRestore freshWorkTrace)
>       (procedure ++ [.admit ⟨4⟩, .claim ⟨4⟩, .apply ⟨4⟩, .admit ⟨5⟩,
>         .claim ⟨3⟩, .crash, .lock, .startupPass, .claim ⟨2⟩])
>     (w.store.ops ⟨4⟩).status = .needsReconciliation ∧ (w.store.ops ⟨4⟩).applied = true ∧
>     (w.store.ops ⟨3⟩).status = .needsReconciliation ∧ (w.store.ops ⟨5⟩).status = .queued ∧
>     (w.store.ops ⟨2⟩).status = .running ∧ w.stepTwoMarked = true ∧ w.passDone = true ∧
>     w.secondOrder = false := by decide

The motivation follows those clauses directly: a crash clears `passDone`; with `passEveryStartup = false` and step (2) already marked, startupPass is a no-op; both claim branches require `passDone`. Therefore this particular negative trace cannot make later claims. This is a model-coverage limitation, not proof that today's theorem is false or that an implementation has this bug. The original negative witness already refutes the theorem without its guard; we must preserve that fact. `.github/workflows/ci.yml:550–551,785` owns the existing single-field negative control. Read ADR-0025's authority/trust policy; do not put any CNF identifier into tools/formal, weaken successor_sweeps_running's statement, or add the desired conclusion as a theorem/claim precondition. A proof remains about the model.

### Exact code and trace shared by the alternatives

`check/probe-models.lean`, printed completely below, supplies separate candidate transition functions and concrete pairs. It is scratch evidence, not a change to master. The final scratch compile must exit 0 before launch; its receipt is check/probe-models.{log,exit}. The all-event equality proof was repaired by simplifying after the Fault case split; its statement and both candidate transition functions are unchanged. It uses the existing fixtures and one trace: complete the procedure, admit/claim/apply create 4, claim power 3, crash, lock, attempt startup handling, admit/claim/apply fresh create 5. The bad outcome requires BOTH create 4 and power 3 still running while create 5 is running with applied true. This shows actual later model work, not merely a true permission bit. Good-model rows 4 and 3 must instead reconcile while row 5 still runs/applies. The baseline blocked-claim cell must remain reported, not relabelled as the harm we seek.

```lean
import Provisiond.Witnesses

namespace Provisiond.Explore
open Provisiond.Restore Provisiond.Witnesses

-- S: startup handling completes even when the mutant skips the sweep.
def stepS (p : Params) (w : World) : Event → World
  | .startupPass =>
    if w.locked && !w.passDone then
      if p.passEveryStartup || !w.stepTwoMarked then
        { w with passDone := true, stepTwoMarked := true,
                 store := { w.store with ops := fun j =>
                   let o := w.store.ops j
                   if o.status = .running || !w.stepTwoMarked then passOp p w o else o } }
      else { w with passDone := true }
    else w
  | e => Restore.step p w e

def runS (p : Params) (w : World) (es : List Event) : World := es.foldl (stepS p) w

-- I: independent claim-before-pass guard, tested in all four combinations.
def permitsI (requirePass : Bool) (p : Params) (w : World) : Permissions :=
  { Restore.permits p w with
    claim := w.locked && (!requirePass || w.passDone) &&
      (!w.fault.isRestore || w.stepTwoMarked) }

def stepI (requirePass : Bool) (p : Params) (w : World) : Event → World
  | .claim i =>
    let o := w.store.ops i
    let perm := permitsI requirePass p w
    if perm.claim && o.status = .queued
        && (o.kind ≠ .suspendTenant || perm.run .suspendTenantException) then
      { w with store := w.store.modify i fun o => { o with status := .running },
               secondOrder := w.secondOrder || (irreversible o.kind && o.applied),
               parentResumedUnconfirmed := w.parentResumedUnconfirmed
                 || (o.kind = .suspendTenant && w.fault.isRestore && !w.parentsConfirmed) }
    else w
  | e => Restore.step p w e

def runI (requirePass : Bool) (p : Params) (w : World) (es : List Event) : World :=
  es.foldl (stepI requirePass p) w

def progressTrace : List Event :=
  procedure ++ [.admit ⟨4⟩, .claim ⟨4⟩, .apply ⟨4⟩, .claim ⟨3⟩,
    .crash, .lock, .startupPass, .admit ⟨5⟩, .claim ⟨5⟩, .apply ⟨5⟩]

def initial : World := bootRestore freshWorkTrace
def skipped : Params := { restoredWorkParams with passEveryStartup := false }

example :
    let w := Restore.run skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .queued ∧
    (w.store.ops ⟨5⟩).applied = false ∧ w.passDone = false := by decide

example :
    let w := runS skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true ∧
    w.passDone = true := by decide

example :
    let w := runS restoredWorkParams initial progressTrace
    (w.store.ops ⟨4⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨3⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true := by decide

example :
    let w := runI false skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true ∧
    w.passDone = false := by decide

example :
    let w := runI true skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .queued ∧ (w.store.ops ⟨5⟩).applied = false := by decide

example :
    let w := runI false restoredWorkParams initial progressTrace
    (w.store.ops ⟨4⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true := by decide

example :
    let w := runI true restoredWorkParams initial progressTrace
    (w.store.ops ⟨4⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true := by decide

-- This is all-state equality for the valid guard, not just a single trace.
theorem S_current_step_eq (p : Params) (hp : p.passEveryStartup = true)
    (w : World) (e : Event) : stepS p w e = Restore.step p w e := by
  cases e <;> simp [stepS, Restore.step, hp]

theorem I_required_step_eq (p : Params) (w : World) (e : Event) :
    stepI true p w e = Restore.step p w e := by
  cases e <;> simp [stepI, permitsI, Restore.step, Restore.permits]
  all_goals cases w.fault <;> simp

end Provisiond.Explore
```

### Complete package M-S: one skip decision completes startup handling

Integrate `stepS` as Restore.step's `.startupPass` branch exactly as printed above; every other branch and the permits/claim guard remains unchanged. Keep World.passDone as a process-local flag cleared by crash, and replace its docstring with:

> This process completed startup handling. With passEveryStartup true that includes the running-row sweep; the false mutant may complete handling while skipping the sweep. A crash clears it.

Update the Event.startupPass docstring to disclose the mutant's skipped sweep and completed handling. Keep Params/current and all conforming behavior unchanged. `S_current_step_eq` establishes all-state, all-event equality under passEveryStartup=true. Preserve successor_sweeps_running's name, hypotheses and conclusion exactly; adapt only its proof if required by the factored branch. Preserve successor_sweeps_power and fresh_work_swept_after_restore. Preserve the original negative witness's stranded-row/mark assertions, but replace its `w.passDone = false` conjunct with `w.passDone = true`: that is a declared change to bad-model metadata, not a weakened current-model guarantee. Add named positive and negative witnesses for progressTrace using startupPassGuards/current and the single passEveryStartup=false mutant, asserting all cells printed above. The existing negative control still flips only passEveryStartup and must reject the positive sweep assertions; extend its owned CI comment/trace evidence to mention the new progress pair without removing the old control. Add a bare model/witness pointer beside OPS-15's every-startup paragraph; do not amend its normative requirement.

This form changes what the false mutant does, so its returned world changes. It must not change any conforming trace, the parent freeze, step (2)'s queued-row quarantine, or the before-any-claim rule in the good model. Ask what the old passDone gate protected before accepting the new meaning.

### Complete package M-I: retain the existing model and add an independent countermodel

Leave Restore.Params/current, permits, step, run, successor_sweeps_running and every existing witness unchanged. Add the printed permitsI, stepI, runI as a second formal test model alongside new named witnesses; give requirePass the explicit documentation:

> Global guard for OPS-15's before-any-claim requirement. True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result.

Use `I_required_step_eq` to establish equality with the original step for every state/event when requirePass=true. Keep its claim branch otherwise identical to Restore.step, including the lock, queued status, step-(2) and parent-exception checks. Add named witnesses for all four combinations of passEveryStartup and requirePass using the exact progressTrace printed above: true/true sweeps and progresses; false/true strands and blocks fresh claim; true/false sweeps and progresses on this trace; false/false strands old rows while a fresh claim applies. The false/false case is openly a two-guard negative engine, not evidence that the original one-field mutant already permits progress. Add an independent CI negative-control step that proves flipping requirePass back to true rejects the bad-model later-work assertion, and flipping passEveryStartup back to true rejects its stranded-row assertion. Keep the existing passEveryStartup control intact. Add a bare pointer beside OPS-15 to the independent witnesses, without changing normative prose. Expose the distinction in comments; no extra target-row predicate may gate claims or become a theorem premise.

This form adds a second model and a second global control. It offers independence at the cost of duplicated claim logic and only reaches the composite harm with both guards off. Decide whether that is an honest independent countermodel or unnecessary apparatus, rather than calling it a one-guard refutation.

**Q2 question:** Which exact package can you accept: M-S, M-I, both, or neither? Give your preference, an exact counterexample if either loses a checked verdict, and the strongest reason against your preferred form (label that requested counterargument separately from your vote). Check the proof statements, all-event equivalence and positive/negative cells; do not accept the scratch code just because its chosen trace computes. Can the proposed negative control refute a skipped running-row pass alongside real later work without weakening the current model, requiring the conclusion as an input, making a prior witness unreachable/vacuous, or dropping the existing control? If there is a smaller third shape, return a complete AMEND with its state, event, claim rule, witness trace, assertions and CI detection rule. It needs a later full reading before approval.

## Required final format

1. Q1: Y-WIDE mark; Y-PROV mark; explicit Final preference. Each reason cites the owner and exact source words or the proposed text. Report durable-provenance/cost concerns separately from hidden baseline losses.
2. Q2: M-S mark; M-I mark; explicit Final preference. Report the model/trace/proof checks you actually ran, including failures and not-run cells.
3. Brief defects: identify each factual error, whether it changes Q1 or Q2's premise, and any vote whose reason rests on it. apply notes.md rule 6 exactly as written; this prompt adds no void rule.
4. Internal consistency: do this document's rules, candidate forms, examples, expected cells and scope contradict each other? Quote any conflict; do not treat a declared alternative as a simultaneous obligation.
5. For each question give the strongest requested counterargument separately from your vote, and any exact repair. No manager synthesis is pre-approved.
