## STO-56: 05-persistence.md:1454–1522 at d65dc63e059bdefc8bab2e2e64416acf52f5b904

```text
1454: **STO-56** **`restore_incidents`** — `id`, `restore_instant`, `steps_completed` (0 to 3),
1455: `grace_ends_at`, nullable (*added 2026-09-25, `ADR-0028`*), `lost_window_starts_at`, nullable,
1456: `loss_end_at`, nullable, `history_evidence_ref`, non-null, and `closed_at`, nullable, and
1457: `supersedes_incident_id`, nullable, a foreign key to the retained predecessor record. One row per
1458: restore (`STO-54`), written into the restored or promoted store before either component is started and closed
1459: by the operator under the rules below; at most one row may have `closed_at` null, a partial unique index over
1460: the table.
1461: Both components read the open row before anything else they do: it is what says a starting process
1462: is continuing an incident rather than restarting, and `steps_completed` is what says where to
1463: resume, so neither fact depends on an operator being at the console when a process dies. *Added
1464: 2026-09-20 (`ADR-0023`).*
1465: 
1466: **Actual-restore supersession.** On an actual store restore whose restored store contains an open
1467: incident R, the transaction establishing the new record MUST close R by supersession and insert a
1468: distinct record naming R in `supersedes_incident_id`, with the new restore instant,
1469: `steps_completed` = 0, `grace_ends_at` = `null` and `closed_at` = `null`. R is retained. For
1470: provenance initialization and the start boundary, see `STO-54`. Supersession is the sole exception
1471: to the ordinary close conditions below: it replaces the predecessor's outstanding recovery
1472: obligations with the new incident's full procedure and close conditions, and no predecessor step
1473: mark satisfies a new step. No component starts between closing R and establishing the new record.
1474: Where the restored store has no open incident, the new record has `supersedes_incident_id` `null`. A
1475: process crash without an actual store restore creates and supersedes no incident.
1476: 
1477: The operator MUST select and retain one new incident id per actual restore before attempting
1478: establishment, and reuse that id on a lost-reply retry. If establishment with that id finds no
1479: committed record with that id, it MUST insert the incident with restore_instant defined by STO-54
1480: for the newly begun transaction inserting it; an instant selected for an earlier attempt that
1481: did not commit is not reused. Repeating establishment with that id when a committed matching
1482: record exists MUST affect that record as a guarded no-op, not create or supersede another
1483: record, preserving its step marks and original restore instant. A mismatch in the committed
1484: id's restore instant or predecessor MUST be refused with both components stopped. The initial
1485: establishment or its matching no-op repeat MUST be acknowledged before either component starts.
1486: A new actual store restore uses a distinct id even when the predecessor incident is still open.
1487: 
1488: `restore_instant` is non-null; its event-time definition and the meanings of
1489: `lost_window_starts_at`=b and `loss_end_at`=f belong to `STO-54`. The incident-keyed
1490: `history_evidence_ref` identifies retained evidence or the unknown-endpoint reason, and is non-null
1491: even when both bounds are unknown. The endpoints and reference MUST be written with the row;
1492: continuations MUST NOT recompute them. `STO-54`: "Continuations reuse the persisted endpoints and
1493: evidence unchanged."
1494: 
1495: **`grace_ends_at` is the unpaused end of the restore grace, one stored instant for the whole
1496: incident** (*added 2026-09-25, `ADR-0028`; amended 2026-10-02, `ADR-0029`*). It is null until
1497: step (3) of `STO-54`'s procedure is marked, and it MUST be written in the same transaction as that
1498: mark, as step (3)'s instant plus one re-derivation interval — `STO-54` says "A marked step does
1499: not run again", so it is written once per incident. `OPS-41` owns its per-claim read and the
1500: funding-only paused check in the fence transaction; `STO-49` owns the history retained for that
1501: computation.
1502: The startup read above is taken once per process, so it cannot see an instant written or passed
1503: later in the incident. `STO-54` says "the freeze lifts at `grace_ends_at`"; keeping this record
1504: open does not prolong that freeze.
1505: 
1506: **Except for the atomic supersession above, the operator MUST NOT close the record until** step (3)
1507: is marked, `grace_ends_at` has passed,
1508: the account sweep's second pass is done, every waiting parent is confirmed or cancelled, and,
1509: for **each currency**, either its accumulated rate-present time since step (3) has reached one
1510: re-derivation interval (`OPS-41`) or every machine priced in that currency is recorded gone or
1511: fenced (`machines.destroy_committed` is non-null; `OPS-42`, `LDG-62`). A finished currency does
1512: not discharge another's obligation. Closing at the original end alone MUST NOT disable unspent
1513: paused grace for a currency with a live unfenced machine. The gone-or-fenced alternative requires
1514: no outage-bound crossing and discharges only that currency's grace obligation, not the wall-clock
1515: or other incident obligations.
1516: 
1517: *Amended 2026-10-04 (`pv-gip.27`).* The machine-disposition condition MUST be evaluated at the
1518: close, not latched from an earlier read: a late attach ordered before close can make it false
1519: again. An attach ordered after close MUST NOT reopen the incident and receives no restore grace;
1520: `OPS-41` owns the worker's no-open-record case. No general post-return survival interval is added.
1521: 
1522: *Amended 2026-10-03 (`ADR-0029`): withdrawn — "or its outage has reached `LDG-64`'s bound. The
```

## STO-54: 05-persistence.md:1638–1823 at d65dc63e059bdefc8bab2e2e64416acf52f5b904

```text
1638: **STO-54** **ADDED 2026-09-12 (`ADR-0023`) — a restore is a recovery incident with a stated
1639: procedure, never a restart.** A store restored from backup lands at some instant `T − Δ` before
1640: the failure, and an engine brought up on it as if nothing happened *performs* destructive actions
1641: on state the restore rewrote: an extension lost in Δ routes a paid machine into `LDG-14`, a token
1642: revoked in Δ is live again (`API-56`), a `queued` create that already ordered in Δ orders again
1643: (on a restart `OPS-15` inspects `running` rows only), and a `suspend_tenant` parent restored
1644: unsettled re-runs a fan-out the operator may have reversed. So:
1645: 
1646: - **Durability posture.** The deployment runs synchronous streaming replication to two standbys (`STO-7`) and continuous
1647:   WAL archiving, and states a **recovery point** — the greatest age of a committed write not yet in
1648:   a separate failure domain — as a human row on `OVR-19`, with its alarm threshold a
1649:   startup-validated value alarmed on `OVR-18`'s model. The number is not the safety argument: a
1650:   create dispatches in one second, a deposit mints in one, an extension lands in one. The
1651:   procedure's order below is.
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
1690: 
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
1745:   since `STO-36` routes on it. *Withdrawn 2026-09-25 (`ADR-0028`): "every machine whose stored
1746:   `runway_until` has passed has `destroy_not_before` set to **the restore instant plus one
1747:   re-derivation interval** — `LDG-16`'s own grace for a date moved backward by something other than
1748:   consumption, written as the deadline itself rather than as a start, so that a second run of an
1749:   unmarked step cannot re-apply it from a fresh clock (`LDG-64` persists its deadline for the same
1750:   reason) (amended 2026-09-21, `ADR-0026`: the withdrawn form set `exhausted_since` to the restore
1751:   instant, one slot serving both this grace and the confirmation wait, which is why re-running this
1752:   step could "backdate an `exhausted_since` a later re-derivation had set" — `ADR-0023`'s own reason
1753:   for the step marks. Two facts cannot collide in one slot, and re-keying that slot to an
1754:   observation instead was refused because a rate arriving seconds after a restore would then end
1755:   the grace)" — the stored unpaused end is `STO-56`'s `grace_ends_at`, and no machine
1756:   carries a deadline.* *Withdrawn 2026-09-23 (`ADR-0027`), with the reference: "and
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
1769:   (`OVR-19`) before any deposit is minted.
1770: - **Marker provenance.** An operation of any kind other than install or rescue inventory MUST be
1771:   inserted with `restore_markers_untrusted` = `false`; this column has no marker-rendering effect
1772:   for those kinds. A new install or rescue-inventory operation MUST be inserted with
1773:   `restore_markers_untrusted` = `false` in its admission transaction. On each actual store restore,
1774:   before either component starts, the acknowledged transaction that establishes the restore record
1775:   MUST set this column `true` on every surviving install or rescue-inventory row whose status is
1776:   `queued`, `running` or `needs_reconciliation`. The marker columns themselves are preserved. A
1777:   successor continuing an existing incident after a process crash MUST NOT repeat this
1778:   initialization. Once `true` the column MUST NOT be cleared on that operation, including at
1779:   incident closure or payload purge. Another actual restore applies the initialization again. An
1780:   open incident inherited from the restored store is superseded under `STO-56`; an ordinary process
1781:   successor never supersedes it. The column is operation metadata and is not added to
1782:   `request_summary`'s closed enumeration.
1783: 
1784:   The restore quarantine and each startup pass preserve `restore_markers_untrusted`. In particular a
1785:   row newly admitted after step (3), interrupted by a process crash, and moved by its successor
1786:   retains `false` unless a later actual store restore invalidated it. Whether the incident is still
1787:   open does not itself invalidate markers of newly admitted work.
1788: 
1789:   **Provenance upgrade.** The release that adds the column leaves it nullable; see `STO-13`. For an
1790:   install or rescue-inventory row, a `null` column MUST be treated as untrusted for rendering. The
1791:   backfill MUST set a still-null column `true` on every existing install or rescue-inventory row,
1792:   including a settled row, and `false` on other kinds; it MUST NOT overwrite a non-null value. After
1793:   previous-release writers are retired and the remaining nulls are backfilled, a later release
1794:   tightens the column to non-null. No pre-column marker history is treated as sufficient to
1795:   initialize `false`. This deliberately conceals legacy facts, including settled retained errors; it
1796:   does not claim those facts were rolled back.
1797: - **The procedure survives its own interruption, because the incident outlives the process.** The
1798:   restore commits `STO-56`'s **restore record** — the restore instant, and which of the three steps
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
1811:   that re-issued after step (3) keeps the token it re-issued. A step interrupted before its mark
1812:   commits does run again, and that repeat is safe on each of its writes: the instant is read from
1813:   the record and never re-computed, step (2)'s quarantine is guarded on `(id, status = queued)`, and
1814:   step (3)'s two forward writes only rise — a second bump can invalidate and never resurrect, and a
1815:   second skip of `deposits.derivation_index` allocates forward, the only direction that column moves
1816:   — while `grace_ends_at` is written in the mark's own transaction (`STO-56`), so an interruption
1817:   before the mark leaves it null and the repeat writes it once (*added 2026-09-25, `ADR-0028`*). The
1818:   operator closes the record only under `STO-56`'s close rule (*amended 2026-10-03, `ADR-0029`*).
1819:   When no restore record remains open, a process that starts is an ordinary restart; for
1820:   supersession and the new open record, see `STO-56`. *Added 2026-09-20 (`ADR-0023`): the
1821:   procedure ordered its steps and said nothing
1822:   about a crash inside them, so `OPS-15`'s restore branch rested on knowledge no engine held.*
1823: - **`OPS-32`'s complete pass is a step, not a gate, and runs twice.** The first pass may record
```

## CNF-365: 10-conformance-checklist.md:1184–1228 at d65dc63e059bdefc8bab2e2e64416acf52f5b904

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
1205:   replayed no transaction record and no retained fallback proof, leaving the lower history endpoint
1206:   unknown, but supply valid retained event-clock and stopping/fencing evidence certifying an
1207:   upper endpoint under `STO-54`. Assert that the incident persists `lost_window_starts_at` as
1208:   null and `loss_end_at` as that certified upper endpoint, with a non-null incident-keyed
1209:   `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint
1210:   reason (`STO-54`, `STO-56`). For this fixture, assert that the operator report publishes
1211:   the certified upper endpoint and its clock/provenance assumptions, identifies the lower
1212:   endpoint as unknown and states that no finite duration is established (`STO-54`).
1213:   A report omitting the certified upper endpoint or inventing a finite loss duration fails
1214:   this case. Follow with the existing restore procedure. Repeat with no
1215:   verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a
1216:   backup name to fill an unknown history bound.
1217:   For these operator-restore arms, supply certified evidence for each asserted known
1218:   `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
1219:   non-null incident-keyed `history_evidence_ref`
1220:   identifying evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).
1221: 
1222:   Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.
1223: 
1224:   Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.
1225: 
1226:   Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.
1227:   (`STO-5`, `STO-7`,
1228:   `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*
```

