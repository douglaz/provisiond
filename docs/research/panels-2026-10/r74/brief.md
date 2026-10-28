# r74 — Panel A: replication drift, recovery instant, residual backends, tied promotion

You are an independent technical reader. Work only in your assigned throwaway clone under /var/tmp/provisiond-panel-r74/, pinned to master 4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239. Read its AGENTS.md. Do not touch /home/user/projects/provisiond-spec, its tracker/branches, the manager brief, other readers, or any remote. Do not run br: read your clone's committed .beads/issues.jsonl if needed. No commits or spec edits are requested. You may read files and write draft notes inside your own clone; keep final answer under 3000 words, with a usable draft by minute 45. No agents/background tasks; the launcher has a one-hour bound.

Read notes.md's **R74 live scope** and **R74 tally procedure**. Earlier Panel E material there is an explicitly preserved launch-template copy, not the subject of this read. Later tally prompts will say: "apply notes.md rule 6 exactly as written; this prompt adds no void rule". Apply that rule to brief errors: report whether an error changes one question's premise, rather than inventing an additional void rule.

These are independent decisions. This round asks for technically viable directions and candidate wording, not permission to implement or an already accepted complete amendment. Candidate forms below are coordinator sketches, unreviewed; no preferred direction has been selected. Q1 is P1 and comes first. Q2 and Q4 share recovery context, but one vote cannot settle the other. The case is a not-yet-implemented specification; do not invent existing provisiond runtime behavior.

Settled inputs: ADR-0045 records the owner's “I think we should just suppose synchronous replication” and S2′ “A: stop on time (Recommended)”, S3 “B: check each new connection (Recommended)”. See its Decision and owners section in your clone. The source excerpts S1/S2/S8 are the current requirements, not permission to cancel a standby-waiting backend. ADR-0047's restore-with-components-stopped decision remains settled; read it if your direction changes startup/restore ordering. Added resource cost, restart delay or operating constraints must be stated for the owner after this technical read, not silently approved here. Do not reopen those choices as routine fixes.

Source excerpts S1–S15 below are copied from this exact master. They own the factual premises; historical ADR/panel observations are labelled as historical, not a new database experiment. Independently inspect the surrounding clauses and challenge any premise. If a PostgreSQL mechanism determines feasibility, give primary-source evidence or an explicit unverified dependency. You are not asked to perform a costly full prototype for this first direction read.

## Q1 — pv-c7vg, P1: notice replication protection being disabled after startup

**Plain terms.** A connection can pass its initial checks and remain open while the deployment changes the database or inserts a pooler. We need to decide how provisiond notices unsafe drift, what it refuses once noticed, and exactly what is protected before it notices.

**Verified premise and why it matters.** S1/STO-7 says “A component checks each new connection before using it” and “the primary never serves with `synchronous_standby_names`” followed by “empty.” S2/STO-55 says “No pooler in transaction mode fronts the pools”. S3/CNF-296 checks `synchronous_commit` “on a freshly checked-out connection”. These cited paragraphs prescribe the posture and checks but do not specify a runtime drift-monitor cadence/refusal latch for an already-used session. Historical S12/ADR-0045 explicitly records “Correct replication configuration is a trusted deployment assumption” and the emptied-list case; S15/F3 records the follow-up. The inference is a missing runtime detection/refusal contract, not that today's deployment is allowed to empty the list, nor a claim that every unchecked drift necessarily produces a lost write. Detection after a local-only commit must not be described as prevention of that commit.

**Candidate forms (unreviewed sketches).**

- **D — bounded detector and refusal.** A deployment-owned runtime monitor observes the effective primary replication configuration, every component connection's applicable settings and the forbidden pooler topology on a declared bound. Unsafe or unobservable evidence trips a latch: alarm, refuse new unsafe store use/work and stop components under the existing stop/sent-COMMIT rules; no cancellation/termination of SyncRep backends. Re-enable only after verified safe posture. D explicitly admits an interval between drift and detection and offers no retrospective prevention claim. The reader must define what the monitor can actually observe, when the bound starts/ends, how every component learns the latch, the refusal/exit behavior for api and engine, and safe resumption. Do not assume a monitor sharing the same stale session can prove the physical topology.
- **P — prevention at the configuration boundary plus runtime detection.** D's observation and response, plus an enforceable restriction on who/how replication configuration and topology can change: the deployment quiesces/fences component use before an unsafe change can take effect and keeps it fenced until the new posture is verified. Per-use read checks may supplement this, but are not by themselves an atomic guard against a later reload or backend switch. State the trusted actor/control, any residual race and what “prevents” is actually proved. If that stronger prevention cannot be achieved within the accepted deployment assumptions, say so rather than inventing an atomic PostgreSQL primitive.
- **Z — retain the present trusted-deployment assumption.** No runtime closure; document the remaining failure mode. Argue this case as requested, but choose it only if you actually recommend accepting that residual safety risk. This is not automatically an approved closure of the P1 bead.
- **OTHER.** Give a complete distinct direction if D/P/Z frame the problem wrongly.

**Question.** Which technical contract is viable for the emptied standby list and for a transaction-mode pooler introduced after checks? Supply observation point, detection bound, refusal/exit/resumption, trust boundary, and the strongest concrete race for each offered guarantee. Give negative controls: drift after a check on a retained connection, unsafe-before-first-use, healthy unchanged settings, a legitimately unavailable standby, observer/query failure, pooler backend reassignment, and an already-sent COMMIT. State what a conformance test can prove and what only the deployment controls can establish. Identify new OVR-19 parameters/costs and their requirement homes without duplicating their normative rules.

## Q2 — pv-3jw6, P2: define the recovery instant when promotion is a restore

**Plain terms.** If a replica is promoted after losing some acknowledged history, the recovery record needs a defensible account of how far back the surviving state goes. The old primary may be gone; the clock time a replacement component happens to start is not evidence of the surviving history.

**Verified premise and why it matters.** S4/STO-54 says a backup “lands at some instant `T − Δ`” and certain other promotions “is a restore”; step (1) says “the lost window `T − Δ` is stated as a number and published to the operator”. S6/STO-56 lists “`id`, `restore_instant`, `steps_completed` (0 to 3)” and puts the row before component startup. S5/STO-54 says “the instant is read from” / “the record and never re-computed” across an interruption. These cited clauses give a field, classification and persisted reuse; they do not give an evidence-to-time derivation for an arbitrary promoted store. This is a scoped source observation, not proof that a WAL byte position is an exact wall-clock snapshot or that no evidence mechanism could exist elsewhere. S14/CNF-295 says “the operator report names `T − Δ`”; the promotion case needs equally truthful reporting.

**Candidate forms (unreviewed sketches).**

- **E — evidence-based conservative instant within the existing field.** STO-54 defines a recoverable-history boundary using retained, timeline-bound evidence (reader must name it, explain how it reaches wall-clock time, and handle clocks/holes). Record its conservative lower bound once as restore_instant and publish the resulting possible-loss interval. If no defensible finite boundary is known, do not substitute restart/promotion time: hold startup/incident-record creation until the operator supplies verifiable evidence or chooses a known recovery point. Keep one definition in STO-54; STO-56 points to it. State the availability cost and how backup-based restores use the same definition.
- **U — represent uncertainty explicitly.** Distinguish the recovery event's wall-clock time from the surviving-history boundary/possible-loss interval. Permit an unknown or bounded history result with evidence/provenance in the incident record and report; never assert an exact lost instant from an LSN alone. Define the conservative recovery actions for absent old-primary evidence, whether startup may proceed, and all consequences for the current non-null restore_instant field and its consumers. Keep one semantic owner in STO-54 with schema pointers from STO-56. This is a schema/behavior proposal, not a wording-only repair.
- **Z — preserve current schema/procedure and require operator-supplied timestamp.** State what makes that number defensible and how an unavailable old primary is handled; if the value is merely guessed, call out the remaining gap. Do not label a guess as verified history.
- **OTHER.** Propose a different complete definition, including the no-evidence case.

**Question.** What exactly should restore_instant mean for a restore-class promotion, what evidence fixes it and the published loss interval, and what happens when the old primary/evidence is unavailable? Trace one known boundary, one missing boundary, one interrupted procedure and one ordinary backup restore. Identify current consumers/checks before changing semantics; keep step-(3) grace anchoring distinct from the history boundary. Coordinate with Q4: a safe equal-position restart should not be forced through an invented restore timestamp, while missing/incomparable evidence remains its own case.

## Q3 — pv-oehp, P3: keep abandoned database backends within a deployment budget

**Plain terms.** During a long replication stall, a process can exit or lose its network connection while its database backend remains. A replacement process can open another pool. Repeating this can use capacity that the live processes' pool sizes do not describe.

**Verified premise and why it matters.** S1/STO-7 says “Dead database transports and process exits can leave waiting backends outside the pool's accounting.” S2/STO-55 calls its sum “The sum fits outside a stall” and says stalled backends “hold slots outside this `max_connections` account”. S13/ADR-0045 and historical S15/F2 record this availability follow-up. The effect is an unaccounted capacity class during a stall, not a newly discovered contradiction in the ordinary outside-stall pool sum, nor a claim that safety requires cancelling those backends. S1/STO-7 says “The deployment MUST NOT cancel or terminate a primary backend while it waits for a standby (wait event `SyncRep`),” / “other than by shutting the primary down.” S8/OPS-21 says “On expiry the worker” / “MUST abandon the record” and “exit”, and preserves the supervisor wait. The accepted stop-on-time choice stays intact.

**Candidate forms (unreviewed sketches).**

- **B — deployment-wide conservative slot budget with admission/backoff.** Before admitting a new component incarnation or database checkout, reserve bounded capacity for its possible residual backends across engines, api replicas and rollout overlap, plus the existing operator/migrator/lock allowances. Hold residual reservations across exit/dead-transport/restart until evidence confirms those backends gone; exhaustion alarms and delays/refuses additional use instead of cancelling SyncRep. The reader must define a real accounting authority, incarnation/backend identity, conservative unknown case, race-free reservation, lost accounting state, monitoring access and release. Merely summing currently live pools does not implement B.
- **S — supervisor quiescence gate across the whole deployment.** After a stall-related exit/dead transport, suppress replacement/rollout/connection growth until a read-only observer proves sufficient backend capacity has cleared. Reserve monitoring/operator access and permit existing safe reads within explicit bounds. The reader must make the gate cover reconnects of surviving processes and api replicas as well as engine restarts; blind exponential delay with unlimited retries is not a finite slot bound. State how multiple supervisors coordinate and whether a global no-growth latch is sufficient.
- **Z — retain the accepted availability limit.** Keep the outside-stall budget, rely on operator recovery without backend cancellation, and explicitly state no continued-service guarantee through arbitrarily repeated exits during a stall. Choose only if you recommend accepting the remaining availability gap/cost; do not call an unchanged assumption a solved budget.
- **OTHER.** A different mechanism is welcome if it states a finite, deployment-wide invariant and its exhaustion behavior.

**Question.** What accounting/backoff rule actually bounds residual slots across exits, transport losses, restarts and overlapping rollouts, while keeping stop-on-time and the SyncRep prohibition? Distinguish a capacity-safety invariant (no budget overrun) from the availability guarantee (which reads/writes/recovery access remain possible, under what assumptions). Give a repeated-stall test with multiple api replicas, engine exits, dead transports and rollout overlap; prove it reaches rather than bypasses the residual case. Include exhaustion, observer failure, cleared-backend recovery and accounting-state loss. Present resource and restart-delay costs for the owner after the technical review.

## Q4 — pv-1i3n, P3: promote either equally current replica without unnecessary token invalidation

**Plain terms.** After an idle period, both replicas may hold exactly the same end of the same history. We need an explicit choice between treating either promotion as an ordinary restart or deliberately requiring recovery, and a test that distinguishes a true tie from missing evidence.

**Verified premise and why it matters.** S4/STO-54 says “the one further ahead is promoted” and makes a promotion “of the one not further ahead” a restore. Equality is not explicitly named in that distinction. S7/CNF-365 covers further-ahead, unavailable-report and other-timeline cases, but has no equal-position fixture in that item. If equality is interpreted as a restore, the consequence is S5/STO-54: “every tenant's credential generation is bumped” and “every spending token dies”. That is a conditional consequence, not a claim that the existing text uniquely requires that tie interpretation. The bead's committed description records the owner's 2026-10-23 “Follow-up ticket (Recommended)” and a reading round for the fix, not approval of a tie policy. Read it directly if needed.

**Candidate forms (unreviewed).**

- **T — explicit maximal-position tie allowed.** Proposed exact changes in STO-54, leaving every other safety condition intact: replace “and the one further ahead is promoted:” with “and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal):”; replace “or of the one not further ahead,” with “or of a standby whose reported end is behind the other's,”. Inspect the surrounding reasoning (“so that one holds them all”) and propose any necessary wording-only clarification, naming it. Proposed CNF-365 addition: “Repeat with both named standbys reporting the same flushed end on the old primary's timeline, with every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no credential-generation bump from the restore procedure. Repeat with an unavailable report and with reports on different timelines; neither case may use the equal-position path.” This fixture addition is behaviour changed for tally purposes; it is not a citation repair. Do not confuse tenant credential generation with the engine startup generation, which remains governed by its existing owners.
- **R — explicitly retain conservative restore treatment on equality.** State equal positions as a restore-class case, with an explicit tied fixture exercising the recovery procedure; automation leaves the store without a primary until an operator starts that restore. Explain the safety benefit that justifies the credential/availability cost when all the other restart conditions hold. No such benefit is assumed in this brief.
- **OTHER.** Give exact alternative wording and a matching fixture if the comparison/report semantics need a different formulation.

**Question.** When both named standbys report equal flushed ends on the same old-primary history and every other safety condition holds, may either be promoted as a restart? Review the exact T wording and fixture together; distinguish equality, unequal same-history positions, unavailable reports, incomparable timelines, open restore records and a previously violated replication posture. Check the source paragraph's reasoning for consistency with the edit. Preserve the other preconditions, including old-process stopping/fencing and a standby streaming from the promoted store. Identify whether anything beyond the declared equal-position classification/test changes.

## Required answer shape

For Q1, Q2, Q3, Q4 separately: (a) Final pick: candidate letter, OTHER or NONE, with any condition explicit; (b) one plain-terms example and strongest reason; (c) mechanics, authoritative observation/evidence, refusal and recovery; (d) exact proposed owner clauses and conformance cases, marking every proposed AMEND behaviour unchanged or behaviour changed; (e) any collateral checked-verdict loss, with owner quote/file/trace or named CNF/Lean theorem and the changed result; (f) cost/priority/scope choice the owner must make, if any. A sketch needing mechanics or an added exception is not accepted as complete wording merely because its direction is preferred.

Then explicitly ask **does this document contradict itself?** Check its problems, candidate forms, invariants, examples, exception cases and requested fixtures against each other; identify any conflict between your own Q1–Q4 proposals as well. For every brief error give the exact source counterexample and whether it changes that question's premise. Finish with the strongest “don't add this mechanism” case for each question, clearly labelled **requested counterargument, not my vote**. A reader's recommendation and a requested adversarial argument must remain distinguishable.

## Pinned source excerpts (quotes; line ranges refer to master 4662d85)

### S1 — STO-7, `05-persistence.md:170–208`

> **Rules about the connection follow** (added 2026-09-12, `ADR-0022`). The client-side deadline
> on any store call MUST NOT be shorter than the server-side timeouts above, so that the server
> decides a statement's fate before the client gives up and a lost reply is only ever a dead
> transport (`OPS-49`), or a commit returned with PostgreSQL's replication warning. A standby wait has no server-side timeout and is excluded from that call's
> store-call and Store-retry deadlines. A dead transport during it is found by the connection's TCP
> keepalives (`OVR-19`). `OPS-21`'s stop bounds still apply. And a connection abandoned mid-transaction before it sends COMMIT — by a timeout, a cancelled
> worker or a lost reply — MUST be reset before it returns to the pool, or the next checkout inherits
> an aborted transaction.
> 
> **A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, a deadline or a cancellation of the request or worker that sent it MUST NOT release its connection before the reply arrives or the transport is found dead. Cancellation alone does not release that write checkout. Dead database transports and process exits can leave waiting backends outside the pool's accounting. A request that finds the write checkouts taken is refused at checkout (`STO-55`).
> 
> **Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is `local`
> on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every connection and
> `synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so PostgreSQL acknowledges a commit
> only once one of them has flushed it to durable storage. The deployment MUST NOT let the primary commit without one
> of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names`
> empty. `OVR-18` alarms either standby being unavailable, and while both are, every write waits.
> **A component checks each new connection before using it** (*added 2026-10-23, `ADR-0045`*): it MUST NOT use a
>   new store connection until one of the standbys `OVR-19` names has flushed the primary's WAL up to the flush
>   position the primary reports on that connection, which it learns by reading the standbys' reported positions,
>   never by committing a write. A check that errors, cannot see a standby's position, or has not passed is a failed
>   connection attempt: the connection is closed unused, and nothing falls back to an unchecked one. Every
>   connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is
>   checked: a commit that was waiting for a standby when the primary stopped is "marked fully committed once the
>   primary database recovers", whether or not a standby has it.
> Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a
>   target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the
>   result and repeat the whole read.
> 
> No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side deadline
> expires closes its connection, except a sent COMMIT, which no deadline releases, and the transaction's fate is the server's (`OPS-49`).
> 
> The deployment MUST NOT cancel or terminate a primary backend while it waits for a standby (wait event `SyncRep`),
> other than by shutting the primary down.
> 
> A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not have been
> replicated to the standby." is not acknowledged: the component treats it as a lost reply (`OPS-49`).
> *Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S2′ “A: stop on time (Recommended)”; S3 “B: check each new connection (Recommended)”; owner question F (a quick shutdown while both standbys are down) “Check again (Recommended)”; the lost-reply sentences of `STO-7` and `OPS-49` “Amend both (Recommended)”; `ADR-0045`): adopted synchronous commits, retained sent COMMIT connections, excluded standby waits from deadlines, added connection and deposit-read checks, and made a commit returned with the replication warning the second lost reply.*

### S2 — STO-55, `05-persistence.md:232–248`

>   connection within a stated checkout bound (`OVR-19`) is refused `overloaded` (`DOM-17`, HTTP 503,
>   `retryable: true`, `retry_after_ms`) before any transaction begins, so the refusal writes no
>   `STO-35` receipt of its own, and `API-11` judges the key's re-send against whatever receipt an
>   earlier send left — none, for a key never sent before. It is not `rate_limited`: `API-50` says an
>   obedient caller "MUST never be throttled by the deployment's caller-throughput pacing", and a full pool is the replica's condition,
>   not the caller's rate, so the decision is `503` rather than a non-rate `429`. Read and write
>   checkouts are budgeted separately, on the same reasoning `API-50` applies to rate limits, so a
>   poller cannot crowd out an extension.
> - **The sum fits outside a stall, and the engine checks its share.** The deployment states that the engine pool,
>   every replica's pool at the rollout's maximum overlap, the lock connection, the migrator and its
>   waiting runners, and an operator reserve together fit inside `max_connections` less the server's
>   reserved slots — a human row on `OVR-19`, since only the deployment sees the whole — and the
>   engine reads `max_connections` at startup and refuses to run where its own pool plus the lock
>   connection does not fit. During a stall, backends left waiting by an exited process or a dead
>   transport hold slots outside this `max_connections` account (`pv-oehp`).
> - **No pooler in transaction mode fronts the pools** (*amended 2026-10-23, `ADR-0045`; until then one "MAY front the pools only on two conditions"*): behind one, a crash of the primary ends its backends but not the component's connection to the pooler, so `STO-7`'s new-connection check would never run.

### S3 — CNF-296, `10-conformance-checklist.md:1070–1080`

> - [ ] **CNF-296** — **Every write waits for the standby** (*amended 2026-10-23, `ADR-0045`; was "The two synchronous writes hang
>   alone"*). Stall both named standbys. Assert an engine write and an `api` write each wait in `SyncRep`, a read still
>   succeeds, and `OVR-18`'s alarm fires. Exercise a contending engine write and assert `OPS-49`'s bounded retry and
>   exit. First fill one `api` replica's write-checkout budget with waiting commits. Cancel every `api` request whose write
>   waits, its client disconnecting, and assert that, throughout this step, the primary holds no more of that replica's backends than its
>   pool, a further write request is refused `overloaded`, and a read still succeeds.
>   While each sent COMMIT remains unresolved and its transport remains live, assert its original connection and write checkout remain retained. Release both and
>   assert the caller's re-sent funding request returns the same deposit (`API-45`) and the rail's replayed settlement
>   credits once (`STO-31`). Then stall one only and assert an engine write and an `api` write each
>   succeed. Then assert `synchronous_commit` reads `on` on a freshly checked-out connection
>   (`CNF-56`'s method). (`STO-7`, `STO-54`, `OVR-18`) *Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S2′ “A: stop on time (Recommended)”; S3 “B: check each new connection (Recommended)”; `ADR-0045`): replaced the two-write stall drill with the synchronous-write, checkout-retention and connection-setting drill.*

### S4 — STO-54, `05-persistence.md:1525–1567`

> **STO-54** **ADDED 2026-09-12 (`ADR-0023`) — a restore is a recovery incident with a stated
> procedure, never a restart.** A store restored from backup lands at some instant `T − Δ` before
> the failure, and an engine brought up on it as if nothing happened *performs* destructive actions
> on state the restore rewrote: an extension lost in Δ routes a paid machine into `LDG-14`, a token
> revoked in Δ is live again (`API-56`), a `queued` create that already ordered in Δ orders again
> (on a restart `OPS-15` inspects `running` rows only), and a `suspend_tenant` parent restored
> unsettled re-runs a fan-out the operator may have reversed. So:
> 
> - **Durability posture.** The deployment runs synchronous streaming replication to two standbys (`STO-7`) and continuous
>   WAL archiving, and states a **recovery point** — the greatest age of a committed write not yet in
>   a separate failure domain — as a human row on `OVR-19`, with its alarm threshold a
>   startup-validated value alarmed on `OVR-18`'s model. The number is not the safety argument: a
>   create dispatches in one second, a deposit mints in one, an extension lands in one. The
>   procedure's order below is.
> - **Promoting the standby that holds every acknowledged commit is a restart** (*added 2026-10-23, `ADR-0045`*).
>   After every engine and `api` process connected to the old primary has stopped, both standbys `OVR-19` names
>   report the end of the WAL each has flushed on the old primary's timeline, and the one further ahead is promoted: every acknowledged commit was
>   flushed by one of them, and both hold a prefix of one WAL sequence, so that one holds them all and its promotion
>   loses none. The
>   engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
>   continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
>   every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
>   component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
>   standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
>   store. `OVR-19` then names the other standby and the rejoining old
>   primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
>   without both standbys' report, with a report on another timeline, or of the one not further ahead, of a standby `STO-7` does not name, or after the primary committed without one of them, served a component before it had caught
>   up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
>   `STO-56`'s record is committed into the promoted store before either component is started.
>   Only an operator starts a
>   promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
>   without a primary until both standbys report or an operator decides.
> - **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every
> engine and `api` process, and MUST start neither component until the transaction that commits
> `STO-56`'s record (below) has been acknowledged (*added 2026-10-24, `ADR-0047`*). (1) *Before
> the startup lock:* the public listener is down;
>   the lost window `T − Δ` is stated as a number and published to the operator; exactly five
>   things are frozen, because starting either component to reconcile starts everything it hosts —
>   the exhaustion sweep, `LDG-64`'s canceller, `API-34`'s time-to-live sweep, `STO-14`'s and
>   `STO-43`'s retention, and `OPS-15`'s `suspend_tenant` exception — and the freeze lifts at
>   `grace_ends_at` (`STO-56`; *amended 2026-09-25, `ADR-0028`: until then "the freeze lifts when
>   step (3) completes"*), except the exception, whose own later condition stands on top: it stays off
>   until the operator has confirmed or cancelled every waiting parent; `OPS-27`'s and `OPS-32`'s

### S5 — STO-54, `05-persistence.md:1586–1611`

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

### S6 — STO-56, `05-persistence.md:1374–1389`

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

### S7 — CNF-365, `10-conformance-checklist.md:1106–1123`

> - [ ] **CNF-365** — **Promoting the standby `STO-54`'s report puts further ahead is a restart** (`ADR-0045`). With both components
>   running, let one create
>   commit step 8 and order, and claim a second. Kill the primary and promote the standby `STO-54`'s report puts further ahead by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine and `api` process connected
>   to the old primary has stopped before any component connects to the promoted store, and that the old primary
>   serves no component; that both rows are on the promoted store; that no restore record is written; and that the
>   successor's startup pass takes `OPS-15`'s restart branch. Then, with both standbys stalled while a write waits,
>   crash the primary, restart it in place, then separately crash one backend while a write
>   waits, and each time assert no component uses a connection before a standby has flushed at or past the flush
>   position it reported. For both components: With healthy replication, withhold position-query results through the connection-attempt
>   deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend.
>   Inspect the deployed topology for transaction-mode pooling.
>   With one standby unreachable, assert the
>   procedure promotes neither as a restart
>   and none until an operator decides, while that standby's report stays unavailable.
>   With one standby on another timeline, assert the
>   procedure promotes neither as a restart. Stop one standby, make an acknowledged write, stop the other, lose the
>   primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped. (`STO-5`, `STO-7`,
>   `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*

### S8 — OPS-21, `03-operation-lifecycle.md:1829–1839`

> The Stop-record bound is measured from the stop, counts every repeat including serialization failures, and never resets.
> This includes the repeats of which `OPS-49` says "do not consume the bound"; that bound is the
> Store-retry bound, independent of this one. The Stop-record bound runs until the record lands
> and covers connection, execution, commit, read-back and backoff together. On expiry the worker
> MUST abandon the record, and the engine MUST log loudly, naming every operation whose record
> it did not see land, and exit. For the lost-reply case see `OPS-49`: "unless the bound's last
> repeat committed and its reply was lost"; a row still `running` goes to restart recovery as
> after a crash. There is no ordering constraint between the Stop-record bound and the
> Store-retry bound: whichever ends first ends the record, with the latter's exhaustion exit
> unchanged. The deployment's supervisor MUST wait at least the Stop-record bound after a stop
> before it kills the engine. A kill before the record lands is a crash.

### S9 — OVR-18, `00-overview.md:338–348`

> **OVR-18** The engine's liveness MUST be alarmed. While the engine is down no exposure-reducing
> mechanism runs (`LDG-14`, `OPS-32`, `SEC-45`'s fan-out), and the restart window is the accepted
> outage (`ADR-0016`); the supervisor's restart guarantee and the alarm threshold are deployment
> parameters (`OVR-19`). **Two more conditions are alarmed on the same model** (added 2026-09-12,
> `ADR-0023`): the recovery point exceeding its threshold, and either named standby being
> unavailable (`STO-7`). **Two exits are alarmed on the same model** (added 2026-10-24,
> `ADR-0047`): an engine's superseded exit (`OPS-50`), and its startup exit on the generation
> advance's timeout (`OPS-15`). `OPS-50` says "the engine MUST log loudly that it was superseded and exit non-zero at once"; `OPS-15` says "On that timeout or any store error, including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing". *Amended 2026-10-23 (`pv-s4m`; panel r63,
> `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose
> synchronous replication”; S1 “Three servers (Recommended)”; `ADR-0045`): alarmed either named
> standby being unavailable.*

### S10 — OVR-19, `00-overview.md:360–363`

> **OVR-19** **A parameter is on this register or it is not a parameter.** Every value the set
> says a deployment MUST state is listed here, with the requirement that mandates it. Startup MUST
> validate every startup-validated row and refuse to run on a missing or out-of-range value; the rows
> marked human are procedures the deployment records rather than values the process reads.

### S11 — OVR-19, `00-overview.md:413–425`

> | Stop-record bound | `OPS-21` | finite, positive duration; `OPS-21` says "The Stop-record bound is measured from the stop, counts every repeat including serialization failures, and never resets." and "The deployment's supervisor MUST wait at least the Stop-record bound after a stop before it kills the engine." | yes |
> | Recovery point | `STO-54` | greatest age of a committed write not yet in a separate failure domain | no — outside the process |
> | Recovery-point alarm threshold | `STO-54` | duration | yes |
> | Synchronous standby names | `STO-7`, `STO-54` | two identifiers | yes |
> | Pooled-connection keepalives | `STO-7` | durations | yes |
> | Derivation-index gap on restore | `STO-54` | integer | yes |
> | Migration `lock_timeout` and retry count | `STO-13` | duration, integer | no — the migrator's, read at `migrate` |
> | Store timeouts: `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout` | `STO-7`, `STO-55` | durations | yes |
> | Engine worker count | `STO-55` | integer | yes |
> | `api` request concurrency per replica, read and write | `STO-55` | integers | yes |
> | Pool checkout bound | `STO-55` | duration | yes |
> | Connection budget against `max_connections` | `STO-55` | human — the sum across every process at maximum rollout overlap | no; the engine checks its own share |
> | Metering cadence | `LDG-37` | duration | yes |

### S12 — ADR-0045, `docs/adr/0045-every-commit-waits-for-a-standby-and-promotion-follows-wal-history.md:65–70`

> 
> Correct replication configuration is a trusted deployment assumption. An emptied
> `synchronous_standby_names` makes every commit local, and nothing in provisiond sees it (H-d2;
> follow-up `pv-c7vg`). The same follow-up covers a transaction-mode pooler added later.
> 
> ## Why the connection check is a read

### S13 — ADR-0045, `docs/adr/0045-every-commit-waits-for-a-standby-and-promotion-follows-wal-history.md:94–97`

> Option A's known limit: every exit during a stall leaves backends waiting outside the pools. In a
> long stall, `STO-55`'s “fit inside `max_connections`” stops holding (`05-persistence.md:191` at
> `dc5d40d`). Follow-up `pv-oehp` covers those backends, including dead transports. Follow-up
> `pv-26ju` carries the WAL-history proof and counterexamples.

### S14 — CNF-295, `10-conformance-checklist.md:1010–1045`

> - [ ] **CNF-295** — **The restore rehearsal** (added 2026-09-12, `ADR-0023`). Before the
>       first customer payment, by someone other than whoever wrote the procedure: keep a rate in
>       force for the no-outage run below, with separate active tenants for the re-extension machines,
>       sufficient available balance, requested runway beyond the tested re-claim and otherwise
>       satisfied admission conditions; with a `suspend_tenant` parent for another tenant unsettled — once `running`, once `queued` under `OPS-49`'s defer —
>       take a backup, then in the lost interval extend a machine's runway from balance, revoke a
>       spending token, let a `queued` create order and a `queued` raw-disk install write, and let
>       the parent settle and the tenant resume; restore, and run `STO-54`'s procedure in its stated
>       order, killing the engine once after the record is committed and before step (2)'s mark
>       commits, and once after step (3)'s (added 2026-09-20, `ADR-0023`). Before it, claim a create and a power operation. Assert the
>       successor, before any claim, moves both to `needs_reconciliation` and leaves a create queued after step (3)
>       `queued`, and that a delete queued on the power operation's machine is then claimed. Again after
>       `grace_ends_at`, with every waiting parent confirmed, kill the engine with a confirmed parent claimed: the
>       successor returns it to `queued` and it resumes with no second confirmation. Assert of the first
>       successor that it continues the incident — it takes the restore branch of the pass and
>       quarantines the executed create, and `api` serves nothing until step (3) is marked; of the
>       second, that it repeats no marked step — the listener is not taken down again, the token a
>       tenant re-issued after step (3) still authenticates, and the record's `grace_ends_at` is not
>       rewritten (*amended 2026-09-25, `ADR-0028`*);
>       and that once the operator closes the record a restart is an ordinary one, leaving `queued`
>       rows alone. Assert: no worker makes a
>       provider mutation and nothing writes a disk before the first
>       claim (`OPS-32`'s deletion of an orphaned imported image is the one provider call the freeze
>       does not stop); the extended machine is not routed into exhaustion before the record's
>       `grace_ends_at` passes, and its re-extension is admitted and leaves `grace_ends_at` as written
>       (`OPS-41`; *amended 2026-09-25, `ADR-0028`*) — and a second machine extended in the lost
>       interval and **not** re-extended is routed once the interval ends, with the extension's
>       satoshis back in its tenant's balance and its `runway_until` reading the restored date
>       throughout (added 2026-09-12: the grace is one interval, not a repair); the old token authenticates nothing and the
>       recovery credential issues a new one (`API-56`); the create and the install are
>       `needs_reconciliation`, never claimed, and `OPS-27` resolves the create `observed` where its
>       correlator was written before the backup and otherwise leaves it to the operator; the
>       `suspend_tenant` parent, in either state, does not resume without operator confirmation; the
>       sweep's first pass records no absence and
>       its second may; and the operator report names `T − Δ` and every unrecorded machine per
>       account. Repeat across an outage starting inside grace and a restore-caused outage:

### S15 — r63h F2/F3 (historical), `docs/research/panels-2026-10/r63/r63h/forms-chosen.md:328–338`

> - **F2:** residual backends during a stall, from:
>   - exiting processes, and repeated stops under STOP-A;
>   - dead database transports, including COMMITs still in flight under S3-B′. Their number has no pool-derived bound
>     (r63h trace 1, from source).
> 
>   Remedies: a supervisor backoff, or a budget across restarts and rollouts (`05:189-192`). Availability only.
> - **F3:** replication-configuration drift at run time.
>   - An emptied `synchronous_standby_names` plus a reload makes every commit local, and nothing in provisiond sees it
>     (H-d2). `CNF-296` checks only a fresh connection.
>   - It also covers a transaction-mode pooler added later.
>   - Safety-relevant (4-0 in r63g); file it with priority.
