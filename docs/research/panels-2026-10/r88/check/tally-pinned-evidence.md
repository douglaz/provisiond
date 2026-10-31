# r88 tally — pinned source evidence

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Extracted from the isolated check clone; no main-worktree specification reads. Line numbers below are at this pin.

## 05-persistence.md:179–209

```text
179: **A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, a deadline or a cancellation of the request or worker that sent it MUST NOT release its connection before the reply arrives or the transport is found dead. Cancellation alone does not release that write checkout. Dead database transports and process exits can leave waiting backends outside the pool's accounting. A request that finds the write checkouts taken is refused at checkout (`STO-55`).
180: 
181: **Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is `local`
182: on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every connection and
183: `synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so PostgreSQL acknowledges a commit
184: only once one of them has flushed it to durable storage. The deployment MUST NOT let the primary commit without one
185: of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names`
186: empty. `OVR-18` alarms either standby being unavailable, and while both are, every write waits.
187: 
188: The operator MUST keep this synchronous replication configuration in force while the primary serves component work. Provisiond relies on that duty; no additional runtime replication-configuration drift check is required. If `synchronous_standby_names` is emptied after a connection has passed its new-connection check, a later commit on that connection can be acknowledged locally without either named standby having flushed it. That is a deployment misconfiguration, and the earlier connection check does not detect the change.
189: 
190: **A component checks each new connection before using it** (*added 2026-10-23, `ADR-0045`*): it MUST NOT use a
191:   new store connection until one of the standbys `OVR-19` names has flushed the primary's WAL up to the flush
192:   position the primary reports on that connection, which it learns by reading the standbys' reported positions,
193:   never by committing a write. A check that errors, cannot see a standby's position, or has not passed is a failed
194:   connection attempt: the connection is closed unused, and nothing falls back to an unchecked one. Every
195:   connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is
196:   checked: a commit that was waiting for a standby when the primary stopped is "marked fully committed once the
197:   primary database recovers", whether or not a standby has it.
198: Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a
199:   target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the
200:   result and repeat the whole read.
201: 
202: No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side deadline
203: expires closes its connection, except a sent COMMIT, which no deadline releases, and the transaction's fate is the server's (`OPS-49`).
204: 
205: The deployment MUST NOT cancel or terminate a primary backend while it waits for a standby (wait event `SyncRep`),
206: other than by shutting the primary down.
207: 
208: A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not have been
209: replicated to the standby." is not acknowledged: the component treats it as a lost reply (`OPS-49`).
```

## 05-persistence.md:232–243

```text
232: For acknowledged commits, `SynchronousCommit` separately relates acknowledgement to an actual
233: record and an endpoint reached by a named standby; durable-prefix semantics then establish
234: membership. `Provisiond.WalHistory.local_ack_admitted_without_sync` retains the documented
235: configuration-drift case above, even with maximal equal reports. No runtime configuration check
236: is added.
237: 
238: The module documents its premises and limits. It proves neither PostgreSQL implementation or
239: SQL behavior, observer/report correctness, actual topology/configuration, process stopping or
240: fencing in a deployment, nor every externally visible action's safety; the broader action/history
241: audit remains `pv-v4gp`. It supplies no implementation conformance or new fixture obligation.
242: No rendered region is added; see `ADR-0025` for authority. For promotion properties and witnesses,
243: see `STO-54`.
```

## 05-persistence.md:298–307

```text
298:   and budget the separate background/server resources. A declared allowance alone does not ensure
299:   a fresh observer can connect when that allowance or resources are consumed; PostgreSQL reserve
300:   roles alone are no proof of observer access. The enforcement construction is the deployment's.
301: 
302:   Release requires fencing every delayed arrival/retry and fresh privileged direct-primary
303:   evidence, read in a fresh transaction, that the bound backend ended. Leaving `SyncRep` is
304:   insufficient. Unidentified attempts remain charged until fenced server-incarnation termination
305:   proves absence. Observer failure denies growth and retains charges.
306: 
307:   Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or
```

## 05-persistence.md:1652–1689

```text
1652: - **Promoting the standby that holds every acknowledged commit is a restart** (*added 2026-10-23, `ADR-0045`*).
1653:   After every engine and `api` process connected to the old primary has stopped, both standbys `OVR-19` names
1654:   report the end of the WAL each has flushed on the old primary's timeline, and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal): every acknowledged commit was
1655:   flushed by one of them, and both hold a prefix of one WAL sequence, so every standby at the maximal reported end holds them all and its promotion
1656:   loses none. The
1657:   engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
1658:   continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
1659:   every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
1660:   component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
1661:   standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
1662:   store. `OVR-19` then names the other standby and the rejoining old
1663:   primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
1664:   without both standbys' report, with a report on another timeline, or of a standby whose reported end is behind the other's, of a standby `STO-7` does not name, or after the primary committed without one of them, served a component before it had caught
1665:   up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
1666:   `STO-56`'s record is committed into the promoted store before either component is started.
1667:   Only an operator starts a
1668:   promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
1669:   without a primary until both standbys report or an operator decides.
1670: 
1671:   **Formal checking interpretation (2026-10-29, `pv-26ju`).**
1672:   `Provisiond.WalHistory.maximal_preserves_acknowledged` proves preservation for an arbitrary
1673:   acknowledged commit under `SynchronousCommit`, truthful durable-prefix reports on one actual
1674:   history, and `MaximalReport`. Report snapshots assume the old component processes have stopped
1675:   and the reported WAL remains durable. The hypothesis is actual common history, not equality
1676:   of labels or positions. `Provisiond.WalHistory.equal_reports_allow_either` admits either named
1677:   standby when reports tie, and `Provisiond.WalHistory.equal_maximal_protected` supplies a
1678:   successful tied promotion witness. `Provisiond.WalHistory.divergent_equal_reports_admitted`
1679:   retains equal truthful reports on different histories with an absent acknowledged commit;
1680:   the refusal under common-prefix semantics is `Provisiond.WalHistory.divergent_promotion_refused`.
1681:   `Provisiond.WalHistory.he_admitted_without_maximal` retains
1682:   H-e: s1 durably holds an acknowledged commit, s2 holds only an earlier prefix of that same
1683:   history, and promoting s2 leaves the commit absent. The failed premise is maximal selection,
1684:   separately from H-d's history mismatch. `Provisiond.WalHistory.he_refused_with_maximal` and
1685:   `Provisiond.WalHistory.he_maximal_protected` retain the refusal and protected choice. This
1686:   witness is possible loss on an operator-authorized restore, not a ban on that restore or a
1687:   reclassification as a restart. The model does not establish the deployment duties or the
1688:   restore procedure, and does not connect WAL membership to the existing engine-step restore
1689:   model. For the module's limits and transitional Markdown authority, see `STO-7`.
```

## 05-persistence.md:1691–1734

```text
1691: - **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every
1692: engine and `api` process, and MUST start neither component until the transaction that commits
1693: `STO-56`'s record (below) has been acknowledged (*added 2026-10-24, `ADR-0047`*).
1694: 
1695:   For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of
1696:   the newly begun transaction inserting this incident. This is the event time of incident
1697:   creation, not the time of the recovered history. The transaction begins after the existing
1698:   stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it
1699:   is not claimed as a fact already proved by the formal model.
1700: 
1701:   The report separates that event from the history that survived. Persist a nullable
1702:   conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence
1703:   references when the incident is inserted. A non-null b MUST certify that every source-history
1704:   component commit acknowledged before b belongs to recovered committed history. A non-null f
1705:   MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST
1706:   be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery
1707:   time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather
1708:   than an apparent finite interval.
1709: 
1710:   The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence
1711:   that e bounds the source clock's error, the timestamp was generated before insertion, and the
1712:   recovered continuous prefix on matching ancestry contains that complete record. Capture the
1713:   observation before restart can erase it, or identify the complete record in retained WAL. The
1714:   earlier-acknowledgement implication is the certificate: this timestamp is neither an exact
1715:   snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN,
1716:   filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound
1717:   needs the same inclusion proof.
1718: 
1719:   A verified upper error bound on the incident transaction's event clock, with retained
1720:   stopping/fencing evidence that no old-history acknowledgement follows that transaction's
1721:   start, can supply f=restore_instant+e_event. Source and event clocks may have different error
1722:   bounds; record their provenance. If either endpoint cannot be certified, persist null for it
1723:   and say that endpoint is unknown. The event timestamp alone never substitutes for a missing
1724:   history bound. Retain evidence outside the lost failure domain or with the incident so that
1725:   continuation does not depend on the failed primary.
1726: 
1727:   Publish possible loss within [b,f] and its bounding duration only when both endpoints are
1728:   known. Include b because the lower certificate guarantees commits acknowledged strictly before
1729:   b. Otherwise publish each known bound, identify every unknown endpoint and state that no
1730:   finite duration is established; identify clock/provenance assumptions for known bounds.
1731:   Missing reporting evidence does not hold incident creation, the existing restore procedure or
1732:   component startup once its existing prerequisites are satisfied. Continuations reuse the
1733:   persisted endpoints and evidence unchanged. Backup restores use the same contract.
1734: 
```

## 05-persistence.md:1735–1744

```text
1735:   (1) *Before the startup lock:* the public listener is down;
1736:   the possible-loss report defined above is published to the operator; exactly five
1737:   things are frozen, because starting either component to reconcile starts everything it hosts —
1738:   the exhaustion sweep, `LDG-64`'s canceller, `API-34`'s time-to-live sweep, `STO-14`'s and
1739:   `STO-43`'s retention, and `OPS-15`'s `suspend_tenant` exception — and the freeze lifts at
1740:   `grace_ends_at` (`STO-56`; *amended 2026-09-25, `ADR-0028`: until then "the freeze lifts when
1741:   step (3) completes"*), except the exception, whose own later condition stands on top: it stays off
1742:   until the operator has confirmed or cancelled every waiting parent; `OPS-27`'s and `OPS-32`'s
1743:   sweeps, the meter, re-derivation, the solvency check and the settlement watcher are not frozen,
1744:   and the account sweep's two passes are a step below; `provider_account_status` is re-established,
```

## 05-persistence.md:1757–1768

```text
1757:   **any `rate_confirmation_ref` already present is preserved**, because a restore is not an
1758:   observation and discharges nothing".* (2) *Before the first claim:* every `queued` create, install
1759:   and rescue inventory is moved to `needs_reconciliation` — a repeat is a second order, a second
1760:   disk write, a second boot into rescue — and `OPS-27` establishes what happened rather than doing
1761:   it again; the goal-state kinds (delete, power, end-rescue, release attachment, reverse DNS)
1762:   re-run, since `OPS-11` classifies "already in the target state" as `succeeded`; a `suspend_tenant`
1763:   parent found `running`, or `queued` and unsettled (`OPS-49`'s waiting parent is `queued`), waits
1764:   for operator confirmation instead of resuming. Its mark keeps this step from running again; it never suppresses `OPS-15`'s pass over `running` rows, which runs at every startup. (3) *Before the first `api` request:* the watch set
1765:   is re-derived (`STO-32`), both rails are replayed (`STO-31`), `SEC-39`'s counters are re-seeded,
1766:   every tenant's credential generation is bumped — the restored store cannot know which tenants
1767:   revoked inside Δ, so every spending token dies and each customer re-issues through the recovery
1768:   credential (`API-56`) — and `deposits.derivation_index` is skipped forward by the stated gap
```

## 05-persistence.md:1799–1810

```text
1799:   have completed — before either component is started, and **a process that starts while a restore
1800:   record is open is continuing that incident, not restarting**, whatever ended its predecessor. It
1801:   resumes at the first step the record does not mark, and every restriction above stands where its
1802:   step's mark is missing: the quarantine and the closed listener follow the record's marks exactly
1803:   as they follow the steps in a run nothing interrupts, and the freeze follows the marks and the
1804:   record's `grace_ends_at` (`STO-56`), so a process that starts after step (3)'s mark and before
1805:   that instant keeps the five actors frozen (*amended 2026-09-25, `ADR-0028`*). Without the record,
1806:   a process that died between the restore landing and step (2)'s pass is succeeded by one that comes
1807:   up under `STO-5`'s restart rule on a restored store — the boot this requirement exists to prevent,
1808:   on which every destructive case `ADR-0023` lists fires. **A marked step does not run again**: the
1809:   grace is written once per incident — `STO-56`'s `grace_ends_at`, in step (3)'s mark transaction —
1810:   the credential generation is bumped once, the derivation index is skipped once, and a customer
```

## 00-overview.md:338–350

```text
338: **OVR-18** The engine's liveness MUST be alarmed. While the engine is down no exposure-reducing
339: mechanism runs (`LDG-14`, `OPS-32`, `SEC-45`'s fan-out), and the restart window is the accepted
340: outage (`ADR-0016`); the supervisor's restart guarantee and the alarm threshold are deployment
341: parameters (`OVR-19`). **Two more conditions are alarmed on the same model** (added 2026-09-12,
342: `ADR-0023`): the recovery point exceeding its threshold, and either named standby being
343: unavailable (`STO-7`). **Two exits are alarmed on the same model** (added 2026-10-24,
344: `ADR-0047`): an engine's superseded exit (`OPS-50`), and its startup exit on the generation
345: advance's timeout (`OPS-15`). `OPS-50` says "the engine MUST log loudly that it was superseded and exit non-zero at once"; `OPS-15` says "On that timeout or any store error, including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing". *Amended 2026-10-23 (`pv-s4m`; panel r63,
346: `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose
347: synchronous replication”; S1 “Three servers (Recommended)”; `ADR-0045`): alarmed either named
348: standby being unavailable.*
349: 
350: Admission exhaustion and accounting loss MUST be alarmed (`STO-55`).
```

## 00-overview.md:363–367

```text
363: **OVR-19** **A parameter is on this register or it is not a parameter.** Every value the set
364: says a deployment MUST state is listed here, with the requirement that mandates it. Startup MUST
365: validate every startup-validated row and refuse to run on a missing or out-of-range value; the rows
366: marked human are procedures the deployment records rather than values the process reads.
367: 
```

## 00-overview.md:421–436

```text
421: | Restore source/event clock-error evidence | `STO-54` | human — certificates and provenance for any asserted clock-error bounds; no unvalidated finite error assumed | no |
422: | Restore endpoint capture, validation and retention procedure | `STO-54` | human — possible-loss reporting procedure | no |
423: | Synchronous standby names | `STO-7`, `STO-54` | two identifiers | yes |
424: | Pooled-connection keepalives | `STO-7` | durations | yes |
425: | Derivation-index gap on restore | `STO-54` | integer | yes |
426: | Migration `lock_timeout` and retry count | `STO-13` | duration, integer | no — the migrator's, read at `migrate` |
427: | Store timeouts: `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout` | `STO-7`, `STO-55` | durations | yes |
428: | Engine worker count | `STO-55` | integer | yes |
429: | `api` request concurrency per replica, read and write | `STO-55` | integers | yes |
430: | Pool checkout bound | `STO-55` | duration | yes |
431: | Connection budget against `max_connections` | `STO-55` | human — the sum across every process at maximum rollout overlap | no; the engine checks its own share |
432: | Component admission capacity C | `STO-55` | integer; capacity contract at `STO-55` | no — deployment authority |
433: | Observer/operator/other-client allowances A | `STO-55` | bounded occupancy allowances; deployment obligations at `STO-55` | no — deployment |
434: | Admission resource ceilings | `STO-55` | human — server reservations and separate background/server resource budgets; `STO-55` | no — deployment |
435: | Admission authority and reconstruction procedures | `STO-55` | human; `STO-55` | no — deployment |
436: | Metering cadence | `LDG-37` | duration | yes |
```

## 10-conformance-checklist.md:1184–1220

```text
1184: - [ ] **CNF-365** — **Promotion after the primary is lost** (`ADR-0045`). With both components
1185:   running, let one create
1186:   commit step 8 and order, and claim a second. Kill the primary and promote a named standby whose reported end is at least as far ahead as the other's, with no open restore record and every other restart-promotion condition satisfied, by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine and `api` process connected
1187:   to the old primary has stopped before any component connects to the promoted store, and that the old primary
1188:   serves no component; that both rows are on the promoted store; that no restore record is written; and that the
1189:   successor's startup pass takes `OPS-15`'s restart branch. Then, with both standbys stalled while a write waits,
1190:   crash the primary, restart it in place, then separately crash one backend while a write
1191:   waits, and each time assert no component uses a connection before a standby has flushed at or past the flush
1192:   position it reported. For both components: With healthy replication, withhold position-query results through the connection-attempt
1193:   deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend.
1194:   Inspect the deployed topology for transaction-mode pooling.
1195:   With one standby unreachable, assert the
1196:   procedure promotes neither as a restart
1197:   and none until an operator decides, while that standby's report stays unavailable.
1198:   With one standby on another timeline, assert the
1199:   procedure promotes neither as a restart and automatic failover promotes neither standby at all,
1200:   including as a restore, before an operator decides, regardless of whether the numerical reports
1201:   are equal (`STO-54`: “Only an operator starts a promotion that is a restore”). Stop one standby, make an acknowledged write, stop the other, lose the
1202:   primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped.
1203:   Promote a lagging standby as an operator restore with verified prefix/clock evidence and
1204:   assert the incident stores certified bounds. Repeat with an idle restarted standby that has
1205:   replayed no transaction record and no retained fallback proof: assert unknown history bound
1206:   and an explicit nonnumeric report, followed by the existing restore procedure. Repeat with no
1207:   verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a
1208:   backup name to fill an unknown history bound.
1209:   For these operator-restore arms, supply certified evidence for each asserted known
1210:   `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
1211:   non-null incident-keyed `history_evidence_ref`
1212:   identifying evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).
1213: 
1214:   Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.
1215: 
1216:   Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.
1217: 
1218:   Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.
1219:   (`STO-5`, `STO-7`,
1220:   `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*
```

## docs/adr/0045-every-commit-waits-for-a-standby-and-promotion-follows-wal-history.md:9–20

```text
9: 
10: The owner's decision was “I think we should just suppose synchronous replication”. The answers
11: were S1 “Three servers (Recommended)”, S2′ “A: stop on time (Recommended)”, S3 “B: check each new
12: connection (Recommended)”, P “Wait (Recommended)”, and owner question F (a quick shutdown while both standbys are down) “Check again (Recommended)”.
13: 
14: `STO-7` owns the commit rule: “`synchronous_commit` is `on` on every connection and
15: `synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names”. It owns the connection
16: check: “A component checks each new connection before using it”. `STO-54` owns classification:
17: “Promoting the standby that holds every acknowledged commit is a restart”. Its automatic-failover
18: choice is “Only an operator starts a promotion that is a restore: an automatic failover promotes
19: only as a restart, and otherwise leaves the store without a primary until both standbys report
20: or an operator decides.”
```

## docs/adr/0045-every-commit-waits-for-a-standby-and-promotion-follows-wal-history.md:66–66

```text
66: Runtime replication-configuration and routing duties, including their misconfiguration limits, are owned by `STO-7` and `STO-55`. For `pv-c7vg`, on 2026-10-28 the owner answered “Don't add the check”, selecting “Trust the deployment to keep replication on.” The fuller option was “No new control — Rely on the deployment never disabling synchronous replication; document it as an operator requirement. Cheapest, and it puts safety on infrastructure configuration.” No runtime controller was adopted. The separate action/history audit stays with `pv-v4gp`.
```

## docs/research/promotion-action-history-audit-2026-10.md:330–380

```text
330: ### T-WAIT — wait termination, historical classification and knowability
331: 
332: **Disposition:** source-supported ingredient and a deployment-misconfiguration trace; the full
333: fast-shutdown reader schedule remains an unmeasured hypothesis. No compliant restart loss of an
334: acknowledged commit is established.
335: 
336: **Initial state:** primary P and named standbys S1/S2 share durable prefix H. Existing component
337: sessions passed their connection checks; the engine's startup generation is g. Both standbys
338: then disconnect. P locally flushes new commit X and waits in SyncRep; neither standby nor the
339: recoverable archive has X. No successful synchronous acknowledgement of X exists.
340: 
341: **Minimal ingredient order:** terminate the waiting backend individually, let its commit cleanup
342: complete, then use a different previously checked session to read X. The archived H-b measurement
343: supports this visibility ingredient; pinned `syncrep.c`'s pending-termination branch and `xact.c`'s
344: post-wait `ProcArrayEndTransaction`/lock release explain it. An individual termination is a
345: violation of [STO-7](../../05-persistence.md#engine-choice): “The deployment MUST NOT cancel or
346: terminate a primary backend while it waits for a standby” except “by shutting the primary down”.
347: A component-issued cancel also violates its “No component sends PostgreSQL a cancel request”.
348: A replication warning is not a successful acknowledgement: the same owner says “is not
349: acknowledged”. Application-request cancellation alone is not this database event.
350: 
351: **Hypothetical fast-shutdown variant:** instead of the forbidden individual termination, P starts
352: fast shutdown. A waiting writer handles its termination and finishes commit cleanup; another
353: already checked backend takes a fresh snapshot, reads X and completes its response before acting
354: on its own termination. The pinned sources show sequential child signalling, pending signals
355: and cleanup ordering, but do not guarantee this reader schedule. PostgreSQL's
356: [synchronous-replication documentation](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION)
357: says “Users will stop waiting if a fast shutdown is requested.” Connected standbys and available
358: archived WAL can defeat the loss premise; the trace needs neither to recover X before promotion.
359: An immediate shutdown is not this wait-release/reader schedule. There is no measured duration,
360: probability or complete reproduction here.
361: 
362: **Promotion order and survivors:** after the response or read-licensed external action, all old
363: component processes stop, P never serves component work again, and S1/S2 report H on the old
364: history. Either can be maximal and equal while lacking unacknowledged X. If a promoter calls this
365: a restart, X disappears and no restore procedure runs. This violates the historical arm of
366: [STO-54](../../05-persistence.md#backup-and-restore): “or had a waiting backend cancelled or
367: terminated” “is a restore”. The shutdown exception to STO-7's prohibition is not an exception
368: written into this classification arm. Proper classification is already a restore, with the
369: existing operator decision and procedure, not a new rule proposed here.
370: 
371: **Historical scope:** those current words have no stated expiry or catch-up reset. A prior
372: terminated waiter does not become an eligible restart merely because the current reports tie,
373: or even because a later standby obtained the record. The archive raised this breadth; this
374: audit does not narrow it. The clean-H execution with no such termination and the execution above
375: can present the same surviving standby reports. Equal reports do not reveal which occurred.
376: The warning and primary log might be gone; an alarm says a standby was unavailable, not which
377: backend was waiting at shutdown. The fixture's [CNF-365](../../10-conformance-checklist.md#key-custody)
378: qualification “each made known to the deployment's procedure” does not establish how that
379: knowledge survives P's loss. C-WITNESS and C-UNKNOWN evaluate that missing evidence without
380: changing policy.
```

## docs/research/promotion-action-history-audit-2026-10.md:673–747

```text
673: 
674: ### C-WITNESS — candidate durable off-primary shutdown/cancellation evidence
675: 
676: **Candidate only; not adopted.** Stable motivating traces: T-WAIT, T-REVOKE, T-CONFLICT and T-REVISION;
677: T-RUNWAY remains disputed. T-IMAGE/T-KEY retain their conditional barrier analysis; the cited
678: owners have not established its read-side COMMIT/acknowledgement premise here. A shutdown-history
679: witness would not itself establish that transaction termination and dispatch order.
680: 
681: The fact to establish is whether the affected source-primary incarnation/history ever had the
682: waiting-backend cancellation/termination condition relevant to the contemplated promotion,
683: including shutdown-induced termination. This is distinct from whether an observer now sees a
684: backend absent, a standby unavailable, equal ends, or a bounded possible-loss interval. A record
685: of “shutdown requested” without whether a waiter was affected is only conservative evidence;
686: a missing record cannot mean the condition did not occur.
687: 
688: A possible construction would durably record shutdown intent/possible wait termination outside
689: P's failure domain before signalling, bound to database identity, primary incarnation and
690: actual WAL ancestry; individual cancellation/termination paths and abrupt host shutdowns would
691: need coverage too. A later completion/catch-up observation would need trustworthy provenance and
692: ordering. A reported end-of-WAL would need a continuous actual-history certificate and relation
693: to the affected commit, rather than a larger number. Even catching up does not, by itself,
694: remove the current historical classification condition; allowing such an expiry would be a
695: separate policy decision. There is no adopted storage protocol, trusted issuer or proof that
696: these records cannot be lost, bypassed or forged.
697: 
698: The existing artifacts do not automatically fill that role:
699: 
700: - [SEC-32](../../07-security-requirements.md#audit) specifies request audit fields including
701:   “correlation id, tenant, authenticated identity” and “outcome”; [SEC-33](../../07-security-requirements.md#audit)
702:   says “a destination separate from the operation store”. Those words supply neither a
703:   before-shutdown durable write nor complete coverage of primary-incarnation backend history.
704: - [STO-55](../../05-persistence.md#engine-choice) requires “fresh privileged direct-primary evidence”
705:   for reservation release and says “Leaving `SyncRep` is insufficient”. That is evidence of
706:   backend ending for capacity accounting, not why its commit became visible or the full
707:   historical condition for promotion. A grant retained forever remains conservative capacity
708:   accounting; it does not automatically identify a cancelled waiter.
709: - [STO-54](../../05-persistence.md#backup-and-restore) certifies that “every source-history component
710:   commit acknowledged before b belongs to recovered committed history” for a known lower bound.
711:   That certificate concerns inclusion of acknowledged records, not wait-termination history.
712:   Unknown endpoints do not supply the missing fact either.
713: 
714: Costs would include an independent durable service/storage path, incarnation/ancestry binding,
715: coverage of crash and power-loss paths, evidence validation and indefinite ambiguity if that
716: path failed. Failure/bypass could silently recreate T-WAIT's indistinguishable reports; observing
717: absence is not a negative certificate. This candidate also cannot repair the independent
718: configuration/routing violations in T-DRIFT or reconstruct an already deleted provider resource.
719: No monitoring, storage, reporting, admission or conformance duty is added here.
720: 
721: <a id="c-unknown"></a>
722: 
723: ### C-UNKNOWN — candidate conservative restore classification for unknown history
724: 
725: **Candidate only; not adopted.** Stable motivating trace: T-WAIT, with C-WITNESS's evidence gap.
726: “Unknown” here means the promoter cannot establish the relevant historical restart-eligibility
727: facts for the affected primary incarnation/history, particularly whether a waiting backend was
728: cancelled/terminated. It does not mean merely equal valid reports, and it does not mean an
729: unknown possible-loss endpoint after an operator already authorized a restore.
730: 
731: A possible policy would refuse automatic promotion when that eligibility remains unknown and
732: let an operator authorize a restore under the existing procedure. Costs would include longer
733: outages and more restore incidents, credential invalidation, quarantine, grace and operator
734: work even when no acknowledged history was lost. It would need a definition of trustworthy
735: negative evidence and how uncertainty is propagated across incarnations; treating missing logs
736: as clean history would defeat the candidate. Known configuration violations would still be
737: violations, and a dishonest/misconfigured evidence source could falsely say “known clean”.
738: 
739: The adopted positive case remains [STO-54](../../05-persistence.md#backup-and-restore): “either may
740: be chosen when they are equal”, under its other conditions; [CNF-365](../../10-conformance-checklist.md#key-custody)
741: adds “no open restore record and every other restart-promotion condition satisfied”. A known
742: violation remains its existing restore case, not this proposed uncertainty policy. The existing
743: operator boundary remains “Only an operator starts a promotion that is a restore” in STO-54.
744: For an already authorized restore, [STO-54](../../05-persistence.md#backup-and-restore) says “Missing reporting evidence
745: does not hold incident creation”; C-UNKNOWN does not reverse it. Neither candidate replaces the
746: valid-equality path or the owner's accepted replication/routing trust posture.
747: Neither candidate supplies T-CLEANUP-BARRIER's additional read-side COMMIT/acknowledgement premise.
```

## docs/research/panels-2026-10/r74/decisions/pv-1i3n.md:12–26

```text
12: **Owner answer, verbatim (2026-10-28):**
13: 
14: > Yes, T-known (Recommended)
15: 
16: **Option shown to the owner, verbatim:**
17: 
18: > Panel pick, 4–0 as written. Promote either as a restart, so tokens stay valid; all existing guards and known-violation handling stay. Becomes ready-for-agent.
19: 
20: **Problem and desired behavior:** Make equal valid maximal reports eligible for the restart path
21: without introducing a tenant credential-generation bump, while keeping the open-incident and
22: prior-violation cases distinct.
23: 
24: **Landing sites:** `STO-54` and the `STO-5` pointer in `05-persistence.md`; `CNF-365` in
25: `10-conformance-checklist.md`; the module classification comment in
26: `tools/formal/Provisiond/Restore.lean`. After the rule edits, record the equality decision and
```

## docs/research/panels-2026-10/r74/decisions/pv-1i3n.md:53–68

```text
53: ## T2: STO-54 reasoning — behaviour unchanged relative to T1
54: 
55: Replace exactly:
56: 
57: > so that one holds them all
58: 
59: with:
60: 
61: > so every standby at the maximal reported end holds them all
62: 
63: This changes no evidence requirement. Its premise remains the paragraph's existing sentence:
64: 
65: > every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence
66: 
67: ## T3: STO-5 pointer — behaviour unchanged relative to T1
68: 
```

## docs/research/panels-2026-10/r74/decisions/pv-1i3n.md:153–163

```text
153: Decision source: `/var/tmp/provisiond-manager/owner-decisions-1028-panelA.md`. Review base: `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`.
154: `r76/tally.md` Q4 counts fable/opus/astra/sol ACCEPT on T-known, including the already-reviewed
155: known-violation fixture restriction. T1–T6 are copied byte-for-byte; historical candidate preamble
156: and the final review solicitation are not application instructions and are omitted. No repair.
157: Original candidate SHA-256: `6dbae0d502b7f7f1b3211227b007f1646df6d7be9cc11300becc8feb3300fbf4`. T1–T6 package SHA-256: `f984a4bbb019c1c50883fafe7a283f052b4a2edb0a948ddd8369ddcaf5806cf2`.
158: 
159: This turn authorizes drafts only. No Run, tracker mutation, source application, branch operation
160: or PR follows from this file. Live pv-6350 must leave the checkout before any later drain starts.
```

## docs/research/panels-2026-10/r63/r63d/fable.md:1–6

```text
1: **Votes**
2: 
3: - **CORE: ACCEPT.** One missed consequence is under Ripple.
4: - **E1: KEEP.** Load-bearing. FA2 shows a close never reaches the cancel branch; a driver's cancel request does (libpq's cancel path, which pgx sends by default on a context deadline, from memory, not verified here).
5: - **E2: KEEP.** Load-bearing. After FA1, `pg_cancel_backend`/`pg_terminate_backend` are the only remaining routes to a visible, unreplicated commit short of postmaster death.
6: - **E3: DELETE.** It changes no behaviour. `OPS-49` repeats the transaction and the write-once guard "has seen its earlier attempt land, and moves on" (`03:1834-1835`), which is what an ack does. Replacement: delete, or alarm it under `OVR-18` if a tripwire is wanted.
```

## docs/research/panels-2026-10/r63/r63d/fable.md:20–25

```text
20: - **FC1: yes, by LSN.** `ANY 1` lets "each commit proceed as soon as at least any" one replies, so neither standby holds every ack by construction; WAL is linear, so the standby with the greatest flushed LSN does. CORE-2 would need "the standby with the greatest flushed LSN is promoted", and `OVR-19`'s single identifier would become a set. Patroni: "will not promote a standby unless it is certain that the standby contains all transactions".
21: - **FC2: confirmed.** "the primary is not be available for writes … blocking all client write requests until at least one synchronous replica comes up." CORE-1's non-empty `synchronous_standby_names` has the same effect: "If no synchronous standby names are specified here, then synchronous replication is not enabled."
22: 
23: **Brief errors:** none found.
```

## docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:153–166

```text
153: ## Why not synchronous commit on every write
154: 
155: Both readers agreed the destructive cases are real; they split on the remedy. One recommended
156: `synchronous_commit = on` with a named standby and no positive recovery point. The other found the
157: reason that fails here, and it is `ADR-0022`'s.
158: 
159: `ADR-0022` rests on "the client never gives up first": the client-side deadline "MUST NOT be
160: shorter than `STO-7`'s server-side timeouts, so the server decides every statement's fate before
161: the client does, and the only lost reply is a dead transport." PostgreSQL has no server-side
162: timeout for the synchronous-replication wait. Its documentation says such commits "may never be
163: completed if any one of the synchronous standbys should crash", offers only a fast shutdown or a
164: configuration reload as the way out, and confirms the commit record is already durable locally:
165: waiting transactions "will be marked fully committed once the primary database recovers". So under a
166: stalled standby the client's deadline fires first on every write, the rare lost acknowledgement
```

## 07-security-requirements.md:291–298

```text
291: **SEC-32** Every mutating request MUST produce an audit record containing: correlation
292: id, tenant, authenticated identity, whether an admin override was used and to which
293: tenant, operation id, operation kind, target machine, and outcome.
294: 
295: **SEC-33** Audit records MUST be written to a destination separate from the operation
296: store, so that a compromise of the service's own database does not erase the trail.
297: 
298: **SEC-34** The operation log is not an audit log. It records what the system did, not who
```

## tools/formal/Provisiond/WalHistory.lean:19–45

```text
19:   argument. An endpoint counts abstract records, not WAL bytes.
20: * `SameHistory`: the histories agree record for record through the earlier commit, independently
21:   of positions and labels. The uninterrupted-session clause above and `STO-54`'s duties —
22:   "Before any component connects to the promoted store, the deployment MUST stop every engine
23:   and `api` process that was connected to the old primary" and "the old primary MUST NOT serve a
24:   component again" — are its deployment basis, not facts established here. Histories may extend differently
25:   after this prefix; equality of complete histories is unnecessary.
26: * `DurablePrefix`: a report is in bounds and the actual durable records equal that history's
27:   prefix at the reported endpoint. It assumes observer/report correctness and continuous durable
28:   WAL prefixes. `STO-7`: "has flushed the primary's WAL up to the flush position the primary reports
29:   on that connection". `STO-54`: "both hold a prefix of one WAL sequence". For promotion the
30:   snapshots are after old component processes stop; reports describe retained, not discarded, WAL.
31: * `SynchronousCommit`: a received acknowledgement has an actual commit record and at least one
32:   named standby's report is beyond it. `STO-7`: "PostgreSQL acknowledges a commit only once one of
33:   them has flushed it to durable storage". It is the trusted deployment/platform duty, supplied
34:   separately from the durable-prefix facts, never a field assuming replicated membership.
35: * `MaximalReport`: selection compares every eligible standby, including equality. `STO-54`:
36:   "a standby whose reported end is at least as far ahead as the other's is promoted (either may
37:   be chosen when they are equal)". The eligible names here stand for the deployment's named pair.
38: 
39: The model proves list membership from these premises. It does not prove PostgreSQL implementation
40: or SQL behavior, observer/report correctness, actual topology/configuration, process stopping or
41: fencing in a deployment, or every externally visible action's safety. It models neither incident
42: procedures nor permission to promote: H-e can be an operator-authorized restore, never evidence
43: for calling it a restart. It does not compose with `Restore.History`, which is live engine steps.
44: No new runtime mechanism, trusted assumption, or implementation conformance follows from a green
45: gate. No rendered region is added; see `ADR-0025` for authority.
```

## tools/formal/Provisiond/WalHistory.lean:150–177

```text
150: @[req "STO-54"]
151: abbrev MaximalReport (replicas : Standbys) (chosen : Standby) : Prop :=
152:   ∀ s, (replicas s).reportedEnd ≤ (replicas chosen).reportedEnd
153: 
154: /-- Every acknowledged commit survives a maximal-prefix promotion. The history is shared in
155: `hPrefixes`, and actual commit identity enters through `hSync`, not through report comparison.
156: H-e (`he_admitted_without_maximal`) refutes this without `hMaximal`. -/
157: @[req "STO-54"]
158: theorem maximal_preserves_acknowledged {history : History} {replicas : Standbys}
159:     {chosen : Standby} {ack : Ack}
160:     (hAck : Acknowledged ack)
161:     (hSync : Acknowledged ack → SynchronousCommit history replicas ack)
162:     (hPrefixes : ∀ s, DurablePrefix history (replicas s))
163:     (hMaximal : MaximalReport replicas chosen) : Replicated ack.commit (replicas chosen) := by
164:   obtain ⟨hRecord, s, hEnd⟩ := hSync hAck
165:   exact commit_in_durable_prefix hRecord (Nat.lt_of_lt_of_le hEnd (hMaximal s))
166:     (hPrefixes chosen)
167: 
168: /-- With the named pair tied, each is eligible; there is no strict-greater condition. -/
169: @[req "STO-54"]
170: theorem equal_reports_allow_either {replicas : Standbys}
171:     (hEqual : (replicas .s1).reportedEnd = (replicas .s2).reportedEnd) :
172:     MaximalReport replicas .s1 ∧ MaximalReport replicas .s2 := by
173:   constructor <;> intro s <;> cases s <;> simp [hEqual]
174: 
175: -- Concrete event snapshots. Tokens name commits independently of their list indices.
176: private def root : CommitId := ⟨10⟩
177: private def deposit : CommitId := ⟨20⟩
```

## tools/formal/Provisiond/WalHistory.lean:296–312

```text
296: /-- Idle-system equality after both standbys have flushed deposit: either promotion preserves it. -/
297: private def tiedReplicas : Standbys := fun _ => ⟨heHistory, 2⟩
298: 
299: @[req "STO-54"]
300: theorem equal_maximal_protected :
301:     MaximalReport tiedReplicas .s1 ∧ MaximalReport tiedReplicas .s2 ∧
302:     Replicated depositAck.commit (tiedReplicas .s1) ∧
303:     Replicated depositAck.commit (tiedReplicas .s2) := by
304:   have hEqual := equal_reports_allow_either (replicas := tiedReplicas) rfl
305:   have hPrefixes : ∀ s, DurablePrefix heHistory (tiedReplicas s) := by
306:     intro s
307:     exact ⟨Nat.le_refl 2, rfl⟩
308:   have hSync : Acknowledged depositAck → SynchronousCommit heHistory tiedReplicas depositAck :=
309:     fun _ => ⟨by decide, .s1, by decide⟩
310:   exact ⟨hEqual.1, hEqual.2,
311:     maximal_preserves_acknowledged rfl hSync hPrefixes hEqual.1,
312:     maximal_preserves_acknowledged rfl hSync hPrefixes hEqual.2⟩
```

## tools/formal/Provisiond/Restore.lean:29–38

```text
29: 
30: The create restart arm is the 2026-10-17 amendment to `OPS-15`: "A create found `running` at
31: startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."
32: 
33: What the model omits: the money release. For promotion classification, see `STO-54`. This module takes the classification as input;
34: it does not compare WAL reports. A restore-class promotion is a `RestoreTrace`. The safety of the
35: restart arm is **not proved**, and the model admits its failure: `Live` has no step 8, so a create
36: claimed, applied and then interrupted reaches the restart arm with the column null and settles
37: `failed`. Only `OPS-43`'s "Step 9 MUST begin only after step 8's transaction is acknowledged."
38: excludes that trace.
```
