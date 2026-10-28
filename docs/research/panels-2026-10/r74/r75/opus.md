# r75 Panel A, Reader 2 (opus): verdicts on Q1–Q4

**Disclosure:** I wrote A2 (Q1) and B2 (Q3) in r74, so I attacked those two hardest. The pin is 4662d85, and my clone is clean and back at the pin.

**Q4 gate run:** I applied `check/q4-proposed.diff` in my clone and ran `nix develop --command bash tools/check-all.sh` unpiped. It exited 0 ("All gates passed"). I then ran `git checkout --` on the three files.

**Sources:** primary sources come from `../check/tally-primary/`. I ran no database experiment.

Per the instruction, I applied notes.md rule 6 exactly as written; this prompt adds no void rule.

---

## Q1 — pv-c7vg

**Trace 1 (empty-list reload).** Verified at syncrep.c:974–983: when `synchronous_standby_names` becomes empty, `SyncRepWakeQueue(true, i)` releases every waiter with no warning.
- **V1 and A2** protect acknowledgements at every moment, idle or busy. They protect nothing a component does on a read alone (the `pv-v4gp` class).
- **A2's M** gives bounded detection of persistent drift deployment-wide, within the period plus the query timeout.
- **V1** gives no detection while the system is idle.
- **P3 and P4** prevent drift made through the change authority. They detect persistent bypass within H+J (P3) or C+Q+V (P4), then gate later dispatches and exposures too. Bypass acknowledgements made before detection stay exposed.
- **P3's command-line pin** is real: command-line settings outrank reloads. It defeats the reload failure outright, short of a restart.

**Trace 2 (target after the reply).** A flush target sampled after the reply can include later writers' WAL. It can also include background WAL: autovacuum, checkpoint records, other in-process periodic components.
- So a first probe can fail on a healthy system even with a single component writer.
- This breaks V1's "healthy replication never produces one". It also breaks A2's fixture "with a single writer, one confirmation read and no added wait".

**Trace 3 (pooler).** For a direct TCP connection, "same session" holds by construction: a failover kills the transport.
- For a connection already fronted by a pooler, a post-COMMIT read can land on another backend. After a reroute, that backend can be on another primary, and the read can then falsely confirm.
- A2's in-transaction PID + `backend_start` check binds one transaction. Its confirmation read is outside that binding, so it needs repair A2-1 below.
- V1's PID-only check misses PID reuse after an in-place restart, and the same backend being handed back by the pooler.

**Trace 4 (P session evidence and expiry).** P3 and P4 both rely on a session-local check plus trusted component SQL and exclusive change control. Neither relies on another session's SHOW.
- Expiry is measured from the challenge, so delayed replies cannot extend it, and disconnected components expire.
- A healthy busy COMMIT keeps its evidence (P3 by carry-forward, P4 by "enforced unchanged settings").
- Gap: permission is checked "before new transactions", not before COMMIT. Neither states that a transaction admitted before expiry can still commit after it (bounded by statement and idle timeouts).

**Trace 5 (retained COMMITs and stop records).**
- All four keep sent-COMMIT retention.
- `CNF-296`'s "a read still succeeds" holds under all four: confirmation runs only on writes, and P's latch ignores mere standby loss.
- `CNF-362`: a conforming P deployment runs its observer, so the working-store fixture still reaches its record. It flips only if the fixture removes the observer. P3 declares a fixture amendment; P4 needs none.
- `StopRecord.finished_unrecorded_exit` (StopRecord.lean:432) does not change: P4 routes refusals through `OPS-49`'s existing store-error bound.
- A1's exit on an identity mismatch is a new unrecorded exit cause. No theorem flips, because `OPS-21` counts "A kill before the record lands" as a crash and the theorem covers finished plans. It must still be disclosed as owner-visible.

| Package | Verdict |
|---|---|
| V1 | **CANNOT ACCEPT** as printed |
| A2 | **AMEND** (behaviour changed) |
| P3 | **CANNOT ACCEPT** as printed (form incomplete) |
| P4 | **CANNOT ACCEPT** as printed (form incomplete) |

**V1's blocking defects:**
1. **The rule contradicts its fixture.** The rule says "repeating it until it passes". The fixture expects "With both standbys streaming … assert neither is acknowledged, each is handled as the warning case". Standbys streaming asynchronously will pass the repeat, so the correct outcome is an acknowledgement.
2. **False alarms.** "A check that does not pass on a warning-free reply is logged loudly" fires under healthy concurrent load (trace 2).
3. **Closed lists contradicted.** V1 makes a PID change on a live transport "a session failure" and so "the warning case". But STO-7 says a lost reply "is only ever a dead transport (`OPS-49`), or a commit returned with PostgreSQL's replication warning", and OPS-49:1937 says "the only lost reply is a dead transport, or a commit returned with…". V1 amends neither list.

**A2 repairs (exact text):**
- **A2-1** (behaviour changed). In clause 1's second paragraph, replace "after COMMIT returns, the component reads on the same session the flush position the primary reports and the named standbys' reported flush positions; the commit is acknowledged only when one of them is at or past it." with:
  > after COMMIT returns, the component reads, in each read on that connection, the backend identity recorded above, the flush position the primary reports and the named standbys' reported flush positions; the commit is acknowledged only when that identity is unchanged and one of them is at or past that flush position. A different identity is a lost reply, as below.
- **A2-2** (behaviour changed). In clause 6, replace "**Healthy, unchanged settings:** with a single writer, one confirmation read and no added wait. With concurrent writers, every commit is acknowledged and none becomes a lost reply." with:
  > **Healthy, unchanged settings:** with a single writer and with concurrent writers, every commit is acknowledged, none becomes a lost reply, and no posture alarm fires.
- **A2-3** (behaviour changed). Append to the pooler fixture:
  > Then route a confirmation read after COMMIT to another backend; assert a lost reply, never an acknowledgement.
- **Wording note:** the "bounded" in A2's mechanics prose is unsupported when standbys stop. It is not in the clauses.
- **Kept, with costs:** clause 4 ("an interval that record does not show verified counts as one") has no discharge. That is owner cost, not a contradiction, because it only supplies evidence for STO-54's existing "after the primary committed without one of them". The fallback (A1 + D, detection only) stays a separate package and is not voted on.

**What P3 and P4 are missing.** Their normative STO-7/STO-55 text is coherent under the trust conditions they declare. But the CNF-296/365 additions, the `CNF-362` change (P3), the OVR-18/19 rows and the timing ownership are described, not printed, so there is no exact fixture to accept. To accept either one I need:
- exact CNF text;
- a statement that a transaction admitted before expiry can still commit after it;
- for P3, a stated H+J bound that includes the longest transaction.

**Preference: A2 as amended (unreviewed).**
- **Strongest argument:** "acknowledged ⇒ on a named standby" survives any drift, including root bypass, without racing a poll. M adds bounded detection.
- **Conditions:**
  - owner accepts one round trip per commit, the interim-WAL wait, the per-transaction A1 read, the monitor's connection and period, and exit-on-mismatch;
  - read-only external effects stay with `pv-v4gp`;
  - **unverified:** whether `pg_stat_replication`/SHOW can lag the checkpointer's `sync_standbys_status` flag.
- **No checked verdict flips.**

---

## Q2 — pv-3jw6

**Formal home.**
- `RestoreTrace.store` (Restore.lean:163–168) writes `restoreInstant := t.now` and selects history separately by `delta`.
- `afterCrash` (:435–438) sets the execution `now` from `restoreInstant`.
- `bootRestore` (:541) is "at the restore instant".
- `step_three_writes_grace` (:548) uses step (3)'s own instant.

Redefining `restore_instant` as a history bound (E3, U4) would make a continuing process run at a historical boundary. That needs `Record`, `afterCrash`, `bootRestore` and the module doc changed. Neither E3 nor U4 prints that change.

**New fact (xact.c:1446).** `XactLogCommitRecord(GetCurrentTransactionStopTimestamp(), …)` reads the clock before the commit's WAL record is inserted. So commit timestamps are not in WAL order, and a lost commit can carry a timestamp before the last replayed one.
- U1's "the lost window starts at" that timestamp is therefore not a strict bound.
- U2's allowance absorbs this only if the allowance is stated to cover it.

**Evidence comparison:**
- **Replay timestamp (U1, U2):** it marks what the store actually replayed. WAL holes and backup recovery are self-limiting, because recovery stops at the hole. It needs same-history ancestry (U2's "the history it continues"), clock offset, inversion slack, and capture before restart, since it is NULL after a normal start. The old primary can be gone.
- **Insert-position certificate (E3):** commits acknowledged before the trusted lower clock bound were reserved before P, so it soundly covers acknowledged commits if the recovered prefix includes every record ending at or before P. It needs a periodic producer retained outside the failure domain, which is new infrastructure.
- **Named restore point (U4):** the same ordering inference with the same infrastructure dependency.

**Allocation (U4's gate).** The counterexample is valid: restored maximum m, then n > g+1 lost allocations, means the skip-forward reissues an index.
- It is pre-existing. 05:924 says "Allocated strictly increasing and never re-issued" with the gap "a deployment parameter on the register", and nothing proves the gap is big enough. CNF-297 tests one fixture.
- Whether the gap is big enough depends on how many allocations were lost, not on the timestamp. So it is outside pv-3jw6's necessary scope. It deserves its own bead; the existing obligation is neither waived nor newly gated here.

| Package | Verdict |
|---|---|
| U1 | **AMEND** (behaviour changed) |
| U2 | **AMEND** (behaviour changed) |
| E3 | **CANNOT ACCEPT** as printed |
| U4 | **CANNOT ACCEPT** as printed |

**U1, complete exact replacement (unreviewed).** Replace U1's `STO-54` insertion with:

> For a restore, from backup or by promotion, `restore_instant` is the instant that record is committed. The lost window starts at about the restored or promoted store's history end: `pg_last_xact_replay_timestamp()` read on it before promotion or any restart, where it is not null — the time, on the old primary's clock, at which the last commit or abort it replayed was generated. A commit generated after that time is absent, and so may be one generated shortly before it, because PostgreSQL takes a commit's timestamp before inserting its WAL record. For a promotion the window ends at the instant the last component connected to the old primary stopped, on the deployment's clock. Where the read is null the start is unknown, the record says so, and step (1) publishes the end alone; an operator MAY supply an earlier instant the store is shown to hold, never a later one. A backup restore uses the same read after its recovery completes.

Also:
- In step (1), replace "the lost window `T − Δ` is stated as a number and published to the operator" with "the lost window this requirement defines is published to the operator, each end's clock named". The printed U1 leaves "stated as a number", which contradicts its own null case.
- At 05:1656, replace "the report naming `T − Δ`" with "the report naming the lost window" (pointer only).
- In U1's CNF-365 fixture, replace "last replayed commit time" with "last replayed commit or abort time".
- U1's `STO-56` and `CNF-295` edits are kept verbatim.
- The phrase "as for a backup" is removed: it asserted an unquoted meaning the prose never defines.

**U2 repairs:**
- Its CNF-365 fixture ("switch segment removed before capture: no record") contradicts its own fallback "that record read from the retained WAL". Add "and no retained or archived WAL holding that record" (behaviour changed).
- The `OVR-19` allowance row must say it covers clock offset plus commit-timestamp/WAL-order inversion, as a declared trust assumption (behaviour changed).
- "Nothing flips" is too strong. The hold makes CNF-295, 297, 358 and 370 depend on replay evidence existing. Engine commits are replayed during recovery, so they are probably reachable, but the precondition must be declared.

**E3 is blocked by:**
- the redefinition without matching Lean changes;
- new certificate infrastructure;
- an indefinite hold on startup.

Its proof is sound if those certificates exist.

**U4 is blocked by:**
- the same unprinted Lean representation change;
- `history_evidence` not given exact form;
- an allocation gate outside the bead's scope that holds step (3) without owner authorization.

**Preference: U1 as amended (unreviewed).**
- **Strongest argument:** nothing automated consumes Δ. Bump, quarantine and skip are window-independent, so holding the restore buys only a report number while customers stay out. Unknown, honestly labelled, is cheaper.
- **Conditions:**
  - the read is taken before promotion or restart;
  - the two clocks stay named;
  - no grace or allocation coupling;
  - `step_three_writes_grace` and the `ADR-0047` ordering are untouched.
- **Changed checked verdict (declared):** CNF-295 "the operator report names `T − Δ`".

---

## Q3 — pv-oehp

**C1 traced in full.**
- Fable is right that once a waiting commit's local flush passes both frozen standbys, every new check fails (05:194–196, "the connection is closed unused").
- The tally's counterexample holds. While replication is healthy, a live incarnation's pool keeps redialing after transport loss during COMMITs held before local flush. The checks pass on the earlier target. A later freeze strands all those orphans. C counts only at startup, so the redials are never admitted against the count, and rollout overlap stays two throughout.
- C counts only `SyncRep` backends. It misses held pre-flush orphans and attempts still authenticating.
- C's fixture asserts reads "on the surviving replica" after cutting that replica's transport. Its new connection fails the check during the freeze, so the assertion is false.
- C's count query is never reached when the first check fails.

**B2 source ordering.**
- postinit.c:704 shows `InitProcess` runs first. Then `PerformAuthentication` (:900), then `InitializeSessionUserId` (:901). The role limit is checked at miscinit.c:873–876.
- `roleId` is set (:614) before `CountUserBackends`, so the race only errs toward refusal. No over-admission.
- But a PGPROC is held through authentication, up to `authentication_timeout`, outside every role count. A burst can occupy slots the reserve depends on, so the reserve is protected only against authenticated normal-role backends.
- Superusers are exempt, so component roles must not be superusers (B2 says so).

**B3 and B4.** Their invariant (live + residual ≤ unreleased one-attempt permits ≤ C) is sound if:
- every attempt is granted before it is dialed;
- unknown attempts stay charged;
- release waits for fenced, fresh absence;
- authority loss fails closed.

Leaving `SyncRep` is correctly not treated as proof the backend ended.

| Package | Verdict |
|---|---|
| C1 | **CANNOT ACCEPT** |
| B2 | **AMEND** (behaviour changed) |
| B3 | **CANNOT ACCEPT** as printed |
| B4 | **CANNOT ACCEPT** as printed |

**B2 repairs (exact text):**
- **B2-1.** After "…fit inside `max_connections`." add:
  > Connection attempts not yet authenticated hold server slots outside every role's count until `authentication_timeout` (`OVR-19`); the stated sum also holds each live component's concurrent attempts, at most its pool, and a burst of abandoned attempts can still occupy the reserve until that timeout.
- **B2-2.** In `STO-55`, replace "Every consumer then has a connection when it needs one" with:
  > Every consumer then has a connection when it needs one while its role is under its connection limit
- **B2-3.** In the fixture, replace "releasing one standby clears the orphans, and new connections succeed" with:
  > releasing one standby clears the orphans within the server keepalive bound, and new connections then succeed

**B2 unverified dependencies:** `reserved_connections` and `pg_use_reserved_connections` (PG16+) were not re-fetched; protection against pre-authentication occupancy is not shown.

**B3 and B4 as printed:**
- **B3** describes but does not print its OPS-47, CNF-290 and conformance changes, and omits the STO-55 consumer sentence.
- **B4** describes but does not print its OPS-47/CNF-290 alignment and conformance text.
- Both add a durable external authority whose outage halts every dial.

**Residual-reaching fixture (common to all packages, unreviewed):**
1. With the engine and two `api` replicas checked while healthy, hold COMMITs before local flush with a deferred `pg_sleep` trigger.
2. Cut those transports. Let the pools redial (checks pass), and repeat.
3. Overlap a rollout, then freeze both standbys and release the holds. Confirm the exact PIDs are in `SyncRep` and outside the live pools.
4. Kill the engine through the Stop-record bound. Blackhole replacement handshakes. Exercise PID reuse and observer loss. Reach exhaustion.
5. Assert the bound, refusal, alarm and operator access. Assert no read on a session that was cut.
6. Release a standby, wait out the keepalive bound, and assert recovery.

**Preference: B2 as amended (unreviewed).**
- **Strongest argument:** the server counts every authenticated backend of a role, residuals included, with no external state to lose.
- **Conditions:**
  - non-superuser per-class roles;
  - pre-authentication occupancy accepted as a time-bounded, operator-recoverable class;
  - the lock connection's role choice (engine orphans can block the successor's lock).
- **Costs, separate:**
  - allowance slots;
  - no new connections at exhaustion;
  - restart delay.
- **CNF flips:** none. CNF-290 has no residuals, so it is unaffected. The narrowing of STO-55 and OPS-47 is disclosed.

---

## Q4 — pv-1i3n (T1–T6 as one form)

**Checked:**
- Every anchor is unique.
- Every live "further ahead" occurrence is covered (05:96, 1541, 1551; 10:1106, 1108; Restore.lean:30).
- The gate passes.

**Traces:**
- On a valid tie, either promoted standby holds every acknowledged commit, because "every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence".
- Unequal reports on the same history: greater → restart; behind → restore.
- Unavailable report or a different timeline → restore. T5 controls both.
- Stopping and fencing the old process and other-standby streaming are unchanged text.
- An open record → continuation (05:1544–1545, 1598–1599).
- Tenant credential-generation bump and engine startup generation stay distinct.

**One defect.** T5 asserts "Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated: equality permits neither promotion as a restart."
- ADR-0045 says "nothing in provisiond sees it".
- Automatic failover "promotes only as a restart", so without posture evidence it fails this control. The assertion silently requires a Q1 detection mechanism, which contradicts the assembly's "do not assume a Q1 monitor exists".

**Verdict: AMEND** (behaviour changed: a fixture restriction). Replace that sentence with:

> Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart.

T1–T4 and T6 I accept as printed. "Preserve the engine's ordinary startup-generation advance" would read better as "assert …", but it is not required.

**Readiness:** with this amendment the form is ready for the owner to choose an equality policy. "Follow-up ticket" is not that approval. Nothing else is introduced beyond equality, controls and pointers. The dated amendment records come after, as AGENTS.md says ("Land the rule; write the record after").

---

## Summary

| Question | Verdicts | Preferred (all unreviewed) |
|---|---|---|
| Q1 | V1 CANNOT; A2 AMEND; P3 CANNOT; P4 CANNOT | A2 as amended |
| Q2 | U1 AMEND; U2 AMEND; E3 CANNOT; U4 CANNOT | U1 as amended |
| Q3 | C1 CANNOT; B2 AMEND; B3 CANNOT; B4 CANNOT | B2 as amended |
| Q4 | T AMEND (one fixture) | T as amended |

As printed, no package qualifies for any question.

**Does this brief or my proposed combination contradict itself?**
- **Brief:** no premise contradiction.
- **Q4 assembly:** its "do not assume a Q1 monitor" conflicts with T5's posture control (repaired above).
- **My combination:**
  - Under A2, drift never yields an acknowledged commit that is missing from a standby. That makes T's tie safe even through undetected drift.
  - A2 clause 4 then adds restore classification for unverified intervals. That reduces T's benefit, but it is consistent with it.
  - U1 and B2 are independent of the rest.

I am not adopting the union.

**Manager claims tested (none changes a premise under rule 6; every tally stands):**
- The tally's lists of what each mechanism protects omit transient pre-authentication backends held through authentication (postinit.c:704/900–901).
- The tally's and U1's replay-timestamp discussions omit that commit timestamps can be out of WAL order (xact.c:1446).
- The tally's suggestion that `CNF-362` could flip under P holds only when the fixture removes the observer.
- The coordinator's "no new historical-evidence mechanism" claim does not hold for T5's posture control (Q4 above).
- All other tally claims I checked held.

## Requested counterarguments — not my vote

- **Q1:** P3's command-line pin stops the actual reload failure for free. A per-commit round trip forever is a big price for drift a deployment can simply forbid.
- **Q2:** U2's hold yields an auditable finite window, and the archive usually supplies the evidence. "Unknown" may become routine.
- **Q3:** only B3 and B4 count pre-authentication attempts. B2's time-bounded leak is exactly the reserve exhaustion the bead fears.
- **Q4:** equal reports from a broken reporter (H-e) look identical to a valid tie. Restore is the conservative default at only credential cost.
