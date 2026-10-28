# r75 tally — Panel A at 4662d85

Instruction applied: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

All four seats exited 0 with substantive complete answers. `check/tally-reader-receipts.json` records the answer hashes, sizes, pinned clone heads and empty tracked status. Source assertions were checked against independent `git show` snapshots at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`, compared with the reader clone bytes. `check/tally-source/manifest.json` owns that inventory. External primary-source retrieval and comparisons are in `check/tally-primary/manifest.json`; the verification ledger is `check/tally-claim-audit.md`. No database experiment or implementation certificate is claimed. The unpiped pre-tally gate exited 0 (`check/tally-gate-before.exit`). No main checkout, branch, tracker, manager brief or memory was mutated.

The live **r75/notes.md** rules apply. A preferred repair is not an ACCEPT of the printed package. A fixture restriction is behavioural even when it enforces an existing normative exception. No historical H/U rule, automatic tie-break, or additional void rule applies. Original clauses and exact returned repairs, including their authors' behaviour marks, remain intact in [fable.md](fable.md), [opus.md](opus.md), [astra.md](astra.md), [sol.md](sol.md) and `reader-proposals/`; nothing in this tally silently replaces those bytes.

## Q1 — pv-c7vg, P1

| Reader | Pick | Strongest argument | Conditions |
|---|---|---|---|
| fable | **NONE printed; unreviewed P4+** | P4 can bound new-use refusal without treating a healthy waiting COMMIT as unsafe; per-commit packages contradict their fixtures. | Add CNF-362 posture-success restriction and refused-record case; trusted exclusive authority, observer and local expiry; retain sent COMMITs and existing recording bounds. P3's residual-session latch objection needs the registry qualification below. |
| opus | **A2 as amended, unreviewed** | Checking a named standby before acknowledgement protects a particular commit without racing a poll. | Post-COMMIT identity read, corrected healthy fixture, reassignment control; hot-path read/wait cost and unverified quorum-view consistency. P3/P4 need complete fixture/timing text and an explicit in-flight transaction boundary. |
| astra | **P3 printed** | A sole mutation authority prevents managed unsafe changes before live use; monitoring cannot undo an earlier acknowledgement. | Exclusive authenticated routing/configuration/credential control, trusted SQL and inventory, monotonic expiry, bounded local enforcement, declared CNF-362 restriction; no retrospective guarantee for admitted work or privileged bypass. |
| sol | **P3 printed** | Controlled mutation plus session evidence and expiry makes a coherent conditional contract. | Same printed trust/expiry assumptions; observer capacity and maintenance outages remain owner costs; P4 requires CNF-362 collateral. |

| Printed package | fable | opus | astra | sol | Counted ACCEPT |
|---|---|---|---|---|---|
| V1 | CANNOT | CANNOT | CANNOT | CANNOT | 0 |
| A2 | AMEND changed | AMEND changed | CANNOT | CANNOT | 0 |
| P3 | AMEND changed | CANNOT | ACCEPT | ACCEPT | 2 |
| P4 | AMEND changed | CANNOT | AMEND changed | AMEND changed | 0 |

**Verification.** STO-7 says “the primary never serves with `synchronous_standby_names` empty” (05:188–190). The pinned PostgreSQL empty-list path wakes all waiters with WAIT_COMPLETE before the warning branches. This is forbidden drift that the bead asks to handle, not a conforming base execution. A global flush target after a reply may contain later component or background WAL; both a healthy single component writer and concurrent writers can need an extra wait. Thus V1's unconditional warning/no-ack fixture and A2's one-read/no-wait fixture are invalid. A2's durable-monitor bound also omits external-record latency. No supplied source proves finite catch-up time or “milliseconds”.

PgBouncer releases transaction ownership after COMMIT. A transaction-local PID/backend_start observation does not bind the later confirmation or prove pooling absent; repeated assignment to the same backend is possible. A changed identity detects a switch, but the identity pair is not a globally authenticated node identity. Fable's statement that appending the pair alone closes every different-server case is too strong. Same-server positions can be conservative without proving the stipulated uninterrupted-session topology. Existing direct TCP and an already fronted client connection must remain distinct cases.

P3/P4's session guarantees are conditional trust contracts, not another session's SHOW inspecting busy-session settings. Command-line precedence protects against global file/reload changes, not arbitrary session overrides. Their expiry bounds concern **new use**, with functioning local enforcement; they do not bound COMMIT completion or retract already admitted effects. Opus's requested explicit boundary is a useful completeness repair, not proof that the printed new-transaction gate promised to stop every in-flight COMMIT.

**Dissent checked.** P3 says “Missing identities, unaccounted sessions … MUST latch refusal.” Fable traces CNF-296's engine exit to a backend lacking a live registry, then a latched refusal preventing the later one-standby success. This is a real underspecified residual-accounting case. It is **not proved inevitable**: P3 does not require the observer to forget a previously identified session when its component exits. Durable retained identity could account for it. Conversely the package supplies no complete residual-registry/release fixture. Astra/sol's blanket success reading and fable's inevitable-failure reading both need that qualification. The next candidate avoids making a session-count ledger part of the posture latch; capacity accounting remains Q3.

CNF-362 says “with a working store” and “the engine exits only after the record lands” (10:1660,1681). Working PostgreSQL with unavailable posture evidence is a concrete counterexample under P4; its admission refuses every record. Opus's conforming-observer reply proves only the healthy-observer arm, not the fixture's literal scope. P3 declares a posture fixture restriction already; P4 does not. Adding it is behavioural under rule 1. Denied attempts can consume the existing Store-retry/Stop-record bounds: `StopRecord.finished_unrecorded_exit` (StopRecord.lean:432) already includes their exits; no immediate new exit is licensed. CNF-296 says “a read still succeeds”; independent live admitted reads and safe unchanged configuration can preserve it without treating standby loss alone as drift.

**Next:** no reviewed form. r76 reads a complete, explicitly unreviewed P4-based assembly with the returned CNF-362 repair, exact fixtures/register rows and an explicit new-use/in-flight boundary. It is a candidate for review, not a recommendation or owner approval. A2's alternative argument and original text remain available for challenge; no A2 repair is represented as reviewed. Control infrastructure, hot-path alternatives, restricted administration and observer-failure outages remain owner choices.

## Q2 — pv-3jw6, P2

| Reader | Pick | Strongest argument | Conditions |
|---|---|---|---|
| fable | **NONE printed; unreviewed U1+** | Keep event time separate from history evidence and permit an honestly unknown report without stopping recovery. | Replay-order/clock caveat, transaction rather than commit fixture terminology; allocation gate separate. Its CNF-358 exclusion is false, below. |
| opus | **U1 as amended, unreviewed** | Bump/quarantine/skip do not consume the report number; an evidence hold imposes outage for a human report. | Keep event meaning, unknown permitted, clock labels, remove numeric-only report wording; no allocation/grace coupling. One sentence of its replacement remains false, below. |
| astra | **NONE printed; unreviewed finite U2\*** | A finite conservative interval needs a prefix/clock certificate and persisted endpoints. | Keep event field; evidence capture/retention, upper bound and formal clarification, explicit success-fixture restrictions; no record/startup without evidence. |
| sol | **NONE printed; unreviewed finite U2R** | Preserve the execution event clock; store independent history bounds and evidence. | Same finite-only policy, exact event definition proposed as new, schema/continuation and restore/seed fixture scope; no U4 allocation gate. |

| Printed package | fable | opus | astra | sol | Counted ACCEPT |
|---|---|---|---|---|---|
| U1 | AMEND changed | AMEND changed | CANNOT | CANNOT | 0 |
| U2 | AMEND changed | AMEND changed | AMEND | AMEND | 0 |
| E3 | AMEND changed | CANNOT | CANNOT | CANNOT | 0 |
| U4 | AMEND changed | CANNOT | CANNOT | CANNOT | 0 |

Astra/sol's U2 amendments have explicit behavioural complete replacements; they do not accept printed U2. Missing evidence admission remains a policy split, not a common U vote.

**Verification.** Tagged `RestoreTrace.store` writes `restoreInstant := t.now` while delta chooses history (Restore.lean:163–168); `afterCrash` loads that event into now (:435–438); `bootRestore` uses t.now (:541). These establish event versus history, not a particular SQL timestamp. E3/U4 intentionally change semantics and need synchronized formal representation, including the execution clock; compiling arbitrary Nat is no validation. `step_three_writes_grace` (:548) uses the later completion event independently. STO-54 says “the instant is read from the record and never re-computed” (05:1610); STO-56 owns the row and mark/grace transaction (05:1374–1388).

The replay function returns the generated time of a commit **or abort** record; it can be null, and ordinary restart can erase the observation. xact.c:1446 samples the transaction timestamp before inserting the WAL record. WAL order is therefore not timestamp order. Clock labels alone do not prove a common-clock interval. But inversion does **not** demand a bound on the timestamp-to-insertion delay to prove the correct acknowledged-prefix property: if a verified lower clock bound precedes generation of a complete record that the recovered prefix contains, every commit acknowledged before that bound was already inserted before that record. Upper error/fencing evidence is separately required. This distinction is a review target, not a measured certificate.

Opus's U1 repair says “A commit generated after that time is absent”. **False**: the last replayed record can sample its time first, pause, then insert after another transaction with a later timestamp; that other transaction survives earlier in the prefix. Do not copy that sentence into a new form. Fable's “no finer than … commit-record ordering” also does not quantify a clock certificate. E3's ordered trusted-time/insert-position and U4's named-restore-point arguments are conditionally sound with complete record inclusion, source identity/ancestry and external evidence. A standing retained source of evidence is a deployment obligation/cost, not an API fact or something the dead primary can later supply. A bare LSN, filename or backup START TIME is insufficient.

U2's report uses event+allowance, its CNF-295 replacement names event alone, and its row does not persist the upper endpoint/allowance despite “Both … never re-computed”. Opus's fallback fixture also needs every retained-WAL fallback excluded before expecting a hold. These are substantive internal mismatches.

**Collateral and dissent:** fable's claim “CNF-358 is a restart fixture and no hold restricts it” is disproved by its **Restore control**: “restore that backup with an open restore record and start the engine” (10:1540–1543). Its restart arms remain independent; its restore arm is affected. Sol/astra correctly include it along with actual restore arms in CNF-99/295/297/302/370; seeded records need schema/evidence as applicable. This list is a set to audit, not a claim that no other consumer exists. STO-54's “before the restore begins … MUST stop every engine and api process” and acknowledged-record-before-start requirement remain (05:1558–1561).

The allocation dissent is fully checked: with restored maximum m, lost sequential allocations through m+n and skip g, choosing n>g+1 makes a next allocation no greater than an old issued value under either off-by-one convention. 05:924 says “Allocated strictly increasing and never re-issued”; CNF-297 says “exceeds every index a rolled-back row held”. This is pre-existing; knowing a duration alone does not bound the allocation count. Omitting U4's new admission mechanism does not waive the obligation. It is a separate scope decision, not necessary to define the report. No tracker write is authorized here.

**Next:** no reviewed form. r76 compares one complete unknown-permitted U candidate against sol's complete finite-only U2R, both explicitly unreviewed. The unknown candidate is a disclosed coordinator repair, not opus's false timestamp sentence. It reports certified bounds or unknown endpoints without changing the event/grace/allocation mechanisms. Evidence/schema costs and potentially indefinite outage remain for the owner after the exact alternatives are read.

## Q3 — pv-oehp, P3

| Reader | Pick | Strongest argument | Conditions |
|---|---|---|---|
| fable | **B4 printed** | Every backend consumes a charged one-attempt grant; client/process loss never releases capacity. | Controlled single physical attempts, fenced delayed arrivals, charged unknowns, privileged bounded observation; no local fallback. It disputes the need for supervisor wording. |
| opus | **B2 as amended, unreviewed** | The server retains per-role accounting for residual authenticated backends without an external journal. | Accept pre-authentication occupancy and recovery risk, per-class non-superuser roles, consumer narrowing and cleanup-bound repair; reserved-access assumptions unproved. |
| astra | **NONE printed; unreviewed B4\*** | Grant-before-dial plus fenced termination provides a conditional injection bound across incarnations. | Exact consumer/supervisor/restart/read/record fixture collateral; budget all uncertain allowances, lost state fails closed. |
| sol | **NONE printed; unreviewed B3R** | Releasing credit on process death double-spends a slot whose backend still exists. | Exact supervisor/CNF-290/read conditions, one physical attempt per permit, charged unknowns and fresh fenced absence, observer/resource assumptions explicit. |

| Printed package | fable | opus | astra | sol | Counted ACCEPT |
|---|---|---|---|---|---|
| C1 | CANNOT | CANNOT | CANNOT | CANNOT | 0 |
| B2 | AMEND changed | AMEND changed | CANNOT | CANNOT | 0 |
| B3 | AMEND changed | CANNOT | AMEND changed | AMEND changed | 0 |
| B4 | ACCEPT | CANNOT | AMEND changed | CANNOT | 1 |

**C1 dissent traced in full.** Once a commit's local flush outruns both frozen standbys, STO-7 says an unpassed check means “the connection is closed unused” (05:194–196). This forbids the tempting trace of successful reconnects after that freeze. It does not prohibit physical attempts during a failed check. The pin's r63h trace 1 (42–54), and independently fetched xact.c, instead place transport loss after HOLD_INTERRUPTS but before local flush; replacement checks read the earlier target while replication is healthy. Repeat within one incarnation, then freeze and release delayed commits: old attempts become waiters without another startup. Against budget ten and two pools of five, startup count zero plus own five passes twice; reconnect residue pushes actual use over ten while rollout overlap remains two. Nonwaiting live sessions, pre-flush orphans and concurrent count reads are also unreserved. C1's one startup SyncRep query cannot establish its proposed invariant. This is source-grounded reachability, not a measured new drill or a new failed base CNF.

Sol correctly narrows the read objection: “cut the other's transport” need not mean cutting **all** of its independent read sessions. Thus the fixture is ambiguous, not proof there can be no surviving read. Name the retained read session; that does not rescue C1's capacity count.

**New fixture flaw:** opus's deferred pg_sleep trigger is before HOLD_INTERRUPTS (xact.c:2276 versus :2358). The sleep checks interrupts (misc.c, pg_sleep). It is not an established way to hold the nonabortable pre-flush segment. Use a controlled test pause after interrupt hold and before local flush, or honestly reach physical residuals by withholding connection-check replies, preserving server legs and verifying PIDs. Do not publish the trigger as a demonstrated implementation of r63h's trace.

**B2 dissent checked in full.** postinit.c:704 requires a PGPROC before InitPostgres; authentication precedes InitializeSessionUserId (:900–901), and role checking is later (miscinit.c:873–880). Concurrent role counting is documented conservative refusal, not an established over-admission race among accepted sessions. But pre-limit attempts already occupy physical slots, and a soon-refused role-tagged attempt can exceed an all-samples count. Server reserves are enforced after slot allocation; their documented roles do not by themselves bound pre-authentication occupancy or guarantee observer access through a burst. authentication_timeout limits authentication, not every possible initialization/cleanup delay. Opus's repair accepts a weaker time/recovery class rather than proving the originally requested pre-attempt invariant. Server keepalives after replication progress do not prove immediate termination, and an indefinitely blackholed network needs explicit liveness assumptions. Its strongest no-external-state argument remains a real cost alternative, not evidence of that stronger bound.

**External permits:** actual controlled backends ≤ unreleased one-attempt grants ≤ C is sound only with complete ingress control, durable-before-dial issuance, no hidden redial/driver fallback, charged unknowns, fenced delayed capabilities and fresh authoritative absence. A libpq connection operation may try multiple transports/hosts; each physical attempt needs its own grant. PID reuse needs database boot identity and backend_start. Leaving SyncRep is not termination. All observer/operator/migrator/waiting-runner allowances include residuals and unknowns; internal pools and resources need their own ceilings. Lost authority state fails closed. These are conditional contracts, not existing PostgreSQL capabilities or a prototype certificate.

**Availability collateral:** STO-55 says “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” (05:213–214); B4 explicitly narrows it, B2/B3 do not. OPS-47 says “supervisor that restarts it and never runs two” (03:136); CNF-290 says “release the first and assert the second then starts” (10:1517). Fable and opus are right that CNF-290's healthy-capacity arm can still succeed; the source gives no immediate-start deadline. The manager's prior suggestion of an **automatic** CNF-290 flip was too broad. An indefinite exhausted-admission policy nevertheless needs its declared relationship to restart/service promises printed. Astra/sol's exact conditions are behavioural additions for that new arm, not evidence that every old arm was impossible. CNF-296/299 independent reads remain possible on retained admitted sessions; no proposal proves reads after all such sessions disappear. Denied record attempts can use the existing StopRecord exits unchanged.

**Next:** no reviewed form. r76 compares sol's exact complete B3R replacement and astra's exact B4\* independently, without silently merging them; opus's role-limit dissent remains available. It must specifically test fixture sufficiency, acquisition error routing, observer resources and all supervisor/service collateral. New authority, reserve capacity, restart delay and reconstruction shutdown remain owner costs.

## Q4 — pv-1i3n, P3

| Reader | Pick | Strongest argument | Conditions |
|---|---|---|---|
| fable | **T with T5 repair**; called wording-only | Equal valid same-history prefixes contain identical acknowledged work; no safety is gained by invalidating tokens. | Add “to the deployment's knowledge” to both prior-posture controls; all other exceptions/guards retained. **Not counted ACCEPT**, below. |
| opus | **T as amended**, changed fixture | The maximum-prefix argument includes equality, but the procedure cannot observe every hidden unsafe history without evidence. | Make each violation known to the deployment's procedure; no Q1 monitor assumed. |
| astra | **T printed, ACCEPT** | Either equal maximal prefix contains all acknowledged commits under the printed premises. | Trustworthy same-history reports, no override of prior violations/open incident, old processes stopped/fenced, other standby streaming. |
| sol | **T printed, ACCEPT** | max(F,F)=F preserves every acknowledged commit; startup and tenant generations remain distinct. | Same guards, open-record continuation and marked-step behavior; equality proves neither report accuracy nor posture. |

**Count:** T1–T6 printed has **2 ACCEPT / 2 not counted ACCEPT**. All four prefer equality policy with their own conditions, not one accepted repaired form. Fable's original mark is preserved. Under r75 rule 1, a **fixture restriction** is behavioural: a trace with an actual but unknown violation is within printed T5, and outside its repair. The new epistemic condition is not merely quoting an owner's sentence. Opus independently calls the same restriction behaviour changed. Fable's label therefore fails the verification required for unchanged AMEND to count ACCEPT. No silent tie-break or direction-vote threshold applies.

**Verification/dissent:** STO-54's premise is “every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence” (05:1540–1541). Either equal maximum holds them all. Reports missing, another timeline, unnamed standby, prior unsafe writes/cancelled waiters, old-process stopping, fencing and other-standby streaming remain independent. STO-54 says “a process that starts while a restore record is open is continuing that incident” and “A marked step does not run again” (05:1598–1606); equal WAL ends cannot waive a pending bump or repeat a completed one. `marked_step_three_writes_nothing` and `step_three_writes_grace` remain unaltered. OPS-15's startup generation is separate. No formal declaration compares reports; the candidate changes its module comment only.

The exact T5 control says “Repeat equal reports after the primary committed without either named standby … equality permits neither promotion as a restart.” ADR-0045 says “an emptied synchronous_standby_names makes every commit local, and nothing in provisiond sees it” (66–69). The harness knowing it injected a violation is not the deployment knowing. A hidden empty-list interval can leave equal reports indistinguishable from a healthy history; with no evidence mechanism, the procedure cannot distinguish them. The same issue applies to a hidden waiter cancellation. Known injected violations can exercise the existing classification without requiring Q1. Thus the two repairs have a genuine fixture purpose; this is not a new objection to safe equality or proof that equality authenticates history.

All original anchors were independently matched; no candidate source was changed in this tally. Reader gate reports demonstrate syntactic/gate compatibility, not historical-observability coverage. “Follow-up ticket” does not approve equality policy.

**Next:** not owner-ready and not ready-for-agent. r76 reads T1–T6 with **opus's exact single-sentence T5 restriction**, explicitly behaviour changed. The whole revised package needs its own acceptance. No equality owner question until that read qualifies.

## Broken manager claims and rule 6

Rule 6, verbatim: “A verified brief error that changes a question's premise voids that question's tally only; re-ask it corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.”

| Challenged manager claim | Checked disposition / affected reasons | Rule 6 |
|---|---|---|
| r74 tally discussed unhealthy first probes primarily under concurrent writers. | fable/opus show background WAL defeats the single-component-writer fixture too. This strengthens the V1/A2 defects; it does not remove the drift problem. | Q1 not void. |
| r74 tally says P forms try to preserve CNF-296 reads. | P3's unaccounted-session latch lacks a complete residual-registry fixture. Fable identifies a possible loss, not an inevitable one. Astra/sol's success claim needs the retained-accounting condition. | Q1 not void. |
| r74 tally's post-COMMIT session objection. | Fable correctly distinguishes same-server global positions from different-server confirmation, but PID/backend_start alone does not authenticate a server. Objection narrowed, not destroyed. | Q1 not void. |
| r74 tally says P could change CNF-362. | Opus disputes it on the healthy-observer arm. That does not cover working PostgreSQL plus unavailable evidence; the collateral is real. | No verified manager error; Q1 not void. |
| r74 supervisor/CNF-290 wording implies a necessary positive-fixture flip. | fable/opus correctly show success with adequate observed capacity; the base has no immediate-start deadline. Exact exhausted-admission semantics remain necessary to review, not an automatic old-test failure. | Q3 not void. |
| r74 replay discussion omits timestamp-before-insertion ordering. | opus/fable add a real evidence distinction. It defeats exact-history-end language, not the existence of a conservative certified bound or the missing-evidence policy choice. | Q2 not void. |
| r74 finite-hold fixture inventory includes CNF-358. | fable says this was wrong; the source's Restore control disproves that challenge. Sol/astra retain the affected restore arm correctly. | No verified manager error; Q2 not void. |
| B3 was described as supplying matching changes. | astra correctly notes it names some collateral but omits the universal consumer sentence. Affects printed B3 acceptance. | Q3 not void. |
| T5 introduces no historical-evidence mechanism and assumes no Q1 monitor. | fable/opus identify the implicit knowledge condition. Scope the injected known-violation fixture; the equality premise and alternative remain intact. | Q4 not void. |

**No question is void.** No exact package reaches the live threshold. Follow-up is for unreviewed repairs/completions, not a voided direction or owner acceptance inferred from precedent.

## Requested counterarguments — not votes

| Question | fable | opus | astra | sol |
|---|---|---|---|---|
| Q1 | Added controller can stop service while root still bypasses it. | Command-line pin may address the reload case more cheaply than hot-path reads. | Deployment trust already carries the premise; a controller adds outages. | Same trust/cost objection; no added controller prevents root bypass. |
| Q2 | A human unknown report may not merit schema/hold machinery. | Finite hold produces an auditable interval; unknown may become routine. | Evidence holds can indefinitely block useful recovery. | Unknown may be preferable to an indefinite hold for a report. |
| Q3 | Admission authority adds a failure dependency; primary shutdown clears residue. | Only external permits cover the pre-authentication reserve exhaustion that role limits miss. | Infrastructure may cost more than operator recovery. | Same infrastructure/reserve cost versus accepting exhaustion. |
| Q4 | Broken reporters can falsely tie. | Historical false receive reports look like ties. | Bad reports justify caution, not a rejection under valid-report premises. | Historical report/posture assurance may matter more than avoiding restores. |

## Follow-up boundary

The user's current instruction authorizes the next reading despite the historical launch-only/no-auto-round text. r76 is prepared and launched under this panel tree only, pinned to the same commit. Its candidates are explicitly unreviewed. The r75 acceptance matrices and original text stay frozen; r76 must read the entire returned replacements and this dissent ledger, not only summaries. No spec/tracker change, Run, PR, owner policy/cost acceptance or manager-brief amendment is authorized. STATE.md records the confirmed launch or explicit quota hold and exact wait command. Required final unpiped gate receipt: `check/tally-gate-after.exit`.
