# Panel M r92 — preserve both owner decisions in CNF-365

Read this brief and `/var/tmp/provisiond-panel-r92/notes.md` whole. Your own clean independent reader clone is detached at **d65dc63e059bdefc8bab2e2e64416acf52f5b904**, the origin/master pin fetched for this round (PR #52, pv-zuu5). The other seven PR #53 beads are outside this question. No source, tracker or PR change is authorized in this round.

All `sources/` and `candidates/` paths in this brief are relative to `/var/tmp/provisiond-panel-r92/`, not your clone.

Read-only: do not change source, Git state, tracker or packet records; do not commit, push, fetch, checkout, reset, stash, clean, contact any PR, start subagents or background work. Do not run `lake build`, the full gate or any command that can start Lean: other sessions share the host's two-build ceiling. The manager runs required before/final full unpiped Nix gates in check/spec. Temporary verification files belong only in `/var/tmp/provisiond-panel-r92/tmp/<your-seat>/`. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' answers/clones, the main checkout, any other worktree, or unrelated panel folders. All needed historical evidence is copied below sources/ in this packet. Read pinned specification only in your own clone or with `git show d65dc63e059bdefc8bab2e2e64416acf52f5b904:<path>`. Return a substantive answer within 3600 seconds; aim for <=2200 words plus any exact alternative. Do not wait for another reader.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Plain-terms failure story

A recovery has no proven starting time for the history that may be missing, but retained evidence proves an ending time. A report can give that proven ending time, identify the unknown starting time and say it cannot establish a finite duration. The landed check explicitly tests all of those facts. A second approved change adds checks for recovery when the operator cannot establish whether automatic restart is safe. That second change was printed as a replacement of the entire older item. Applying it literally now would remove the newer report checks. The panel must determine whether this is a stale replacement boundary or a conflict in what the owner decided the report must contain.

This story is tied to the landed CNF-365 reporting arm and STO-54's words quoted below. It asserts neither a running implementation failure nor loss of an acknowledged commit. Reporting evidence and restart-eligibility evidence are different inputs; test that distinction rather than assuming it.

## Scope and fixed decisions

The only unsettled issue is how pv-by1w's adopted C-UNKNOWN applies to CNF-365 after pv-zuu5 landed. Owner item 9 and item 18 are both in force. This round does not reopen choosing C-UNKNOWN versus WITNESS/NEITHER or approve extra infrastructure, costs, alarms, expiry, classification changes, owner changes, theorem changes or other beads. C-UNKNOWN's STO-54 replacement is supplied whole for context and remains the owner-adopted text, not a new alternative to vote on. The question here is its CNF-365 landing, including its meaning for reports with unknown duration.

PR #53's remote fetched head is `26743d89663e996aceeb9aed245d185310dc3463`. Its unpushed clean rebase `29dcceebdea761e6ad71feb018d95b0f176f0bf2` in wt-prep-dghi is a read-only evidence source and has no new approval. The tracker at the pin closes pv-zuu5 and still contains pv-by1w's original needs-triage record; the open PR's committed Agent Brief carries item 18. Do not treat either tracker status as panel settlement.

## Required complete historical reads

Read each of these whole; none is a new vote. The copies preserve their original text, including historical status wording such as “Candidate only; not adopted” in the form or tally. Item 18 below supplies the subsequent adoption.

- `sources/mgr-dr-dghi-merge-stop.md`: the entire required 2026-10-30 23:29:20 UTC UPDATE.
- `sources/landing-site-stop.json`, `sources/cnf365-exact-form-difference.diff`, `sources/rebase-verification.json`, `sources/pr-at-stop.json` and `sources/rebased-check-all.exit`: stop evidence. The recorded gates concern that previous rebase, not this candidate.
- `sources/pin-pv-zuu5.json` and `sources/pin-pv-zuu5.md`: complete committed pv-zuu5 row and Agent Brief from `git show <pin>:.beads/issues.jsonl`.
- `sources/pin-pv-by1w.json` and `sources/pr53-pv-by1w.json` / `.md`: pinned bead and the complete committed PR #53 Agent Brief, including its overlapping-change stop instruction. Reading other PR beads is not requested.
- `sources/landed-pv-zuu5.diff`: whole unmodified `git diff 832a219 d65dc63`. Its tracker context is historical context, not an invitation to review unrelated beads. Only pv-zuu5 closure fields and the CNF-365 arm change.
- `sources/triage-1030-rows.md`: the source triage rows for these beads (the lean was the exact pv-zuu5 repair and a separate promotion-evidence panel).
- `sources/r88-form-C-UNKNOWN.md`: entire exact adopted package, SHA-256 `84b5e77d55ed3d3fcf1d4f0d2ffd8020d5abff978c3d949c991a7c449067902b`, written at pin `3109b5b44eae17e288cf52aaa976993bd8c5626c` before pv-zuu5.
- `sources/r88-tally.md` whole and `sources/r88-owner-questions.md` whole: prior rationale, checks, dissent and approval scope. The tally's table is its source for counts, not the vote in r92.

## Owner items 9 and 18, verbatim

Source: `/var/tmp/provisiond-manager/owner-decisions-1030.md`, items 9 and 18 (copied in sources/owner-items-9-18.md).

```text
9. **Triage-1030 batch** — Q: "Approve the triage of the five new beads as listed in triage-1030/table.md (3 ready for
   implementation, 2 to their own panels H and I)?" A: **"Approve (Recommended)"**. Option text: "pv-zuu5, pv-avok,
   pv-shub go to ready-for-agent with the exact briefs in the table and the drain lane implements them. Panels H
   (pv-3zzo) and I (pv-by1w) launch." Rejected: "Revise". Table: /var/tmp/provisiond-manager/triage-1030/table.md.

18. **pv-by1w (Panel I r88 Q1; C-UNKNOWN preferred 3–1, opus + astra + sol; fable prefers NEITHER; both accepted 4–0;
    grok missing, 402; owner approval of a behaviour/check change)** — Q: "pv-by1w: if the database is lost and the
    backups can't prove what happened, should automatic restart wait for evidence?" A: **"Require evidence
    (Recommended)"**. Option text: "Adopt C-UNKNOWN: pause automatic recovery until trustworthy evidence arrives or a
    person approves a restore. No specific evidence service is required. Preferred 3–1, all 4 accept." Rejected: "Keep
    current rules" (NEITHER). Meaning: adopt exactly /var/tmp/provisiond-panel-r88/form-C-UNKNOWN.md (SHA-256
    84b5e77d55ed3d3fcf1d4f0d2ffd8020d5abff978c3d949c991a7c449067902b, pin 3109b5b): amend STO-54 and CNF-365 as printed,
    per r88/owner-questions.md; nothing beyond its stated approval scope (no expiry, scope repair, extra alarm, register
    parameter, infrastructure or cost). pv-by1w → ready-for-agent with that package as its brief.
```

## Owner wording authority, verbatim

Source: manager-brief.md, PR handling; copied in sources/owner-wording-rule.md.

```text
- A finding that touches an owner ruling is a question for the owner, not a fix. EXCEPTION (owner, 2026-10-28:
  "For such wording questions, try to solve by getting a consensus of the panel"): when the finding touches only
  the WORDING of owner-adopted text (no behaviour, requirement or check-strength change), run the five-reader panel
  on the exact options and act on a settled result without asking. Settle: at least 3 agree and more agree than
  disagree. A tie gets ONE consensus round, then it goes to the owner.
```

## Current pin: owning rule and complete landed check

The source locations below are at the round pin, not r88's older line numbers. STO-54's publication sentence is “Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds.” STO-54 also says “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.” Check the full context, including its certification conditions and the formal model's limits. Do not infer a theorem about report formatting from a model that does not model that report.

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

## Owner-adopted STO-54 replacement, whole, for fixed context

Source: exact C-UNKNOWN owner block. Its named original 05-persistence.md:1652–1669 boundary remains byte-identical at this pin. The following formal-interpretation paragraph and restore procedure are retained. No change to this adopted block is proposed by r92.

```markdown
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

  **Unknown restart eligibility.** For a contemplated promotion, evaluate the restart-promotion
  conditions above for the affected source-primary incarnation/history through the old
  primary's fencing boundary. A condition is established only by evidence valid for that
  database, incarnation and actual WAL ancestry, or by a trusted deployment invariant whose
  uninterrupted coverage establishes the fact. Equal numerical ends alone establish neither
  actual common history nor the absence of a waiting-backend cancellation or termination.
  Classify a known disqualifying condition under the existing restore rule even if another
  fact is unknown. Otherwise restart eligibility is unknown if at least one applicable
  restart condition cannot be established. It is established only when every applicable
  condition is established and none is disqualifying. Continuing an already open restore
  incident remains continuation, not a new restart decision.

  In particular, evidence that no waiting backend was cancelled or terminated MUST cover the
  affected incarnation/history, including shutdown-induced termination and inherited conditions
  and uncertainty on which the contemplated restart depends, through fencing. A trustworthy
  negative assertion requires an authenticated source and complete event coverage, or an
  independently enforced no-event invariant with established coverage and non-bypass. Its
  database/incarnation/ancestry binding and its coverage MUST be verifiable without the lost
  primary or its logs. A missing record, sampled absence, an alarm, unverified operator belief,
  or successful later catch-up is not negative evidence. Conflicting, incomplete, lost or
  invalid evidence leaves that condition unknown unless a disqualifying fact is already known.
  This paragraph specifies no new evidence service or runtime replication-configuration or
  topology-drift controller; existing trusted deployment duties remain in force. A deployment
  unable to supply the negative evidence may use the operator boundary below.

  Automatic failover MUST NOT promote while restart eligibility is unknown and MUST report the
  unresolved condition to the operator. It MUST leave the store without a primary and MUST NOT
  perform a restore. The operator may wait for sufficient valid evidence to establish a restart,
  or authorize a restore under the procedure below; operator belief alone cannot reclassify
  unknown as established. A promotion with unknown restart eligibility MUST be treated as a
  restore when authorized, with the existing incident and startup prerequisites. A known
  violation remains a violation; this rule neither permits it nor turns it into uncertainty.
  A known historical waiting-backend cancellation or termination remains a restore condition,
  including a shutdown-induced termination permitted by the shutdown exception. Time, new
  incarnation identifiers, equal reports or later catch-up do not expire that condition or
  resolve an uncovered historical interval. A later decision MUST retain unresolved inherited
  facts on which it depends rather than treating a new incarnation as clean by default.

  Established eligibility preserves the equal-report restart path above when its other
  conditions hold. Unknown possible-loss reporting endpoints on an operator-authorized restore
  are separate: they use the reporting rules below and do not delay that restore's incident
  creation, procedure or startup once its existing prerequisites are satisfied.
```
## Exact candidate forms against the round pin

Every block below is a complete replacement for CNF-365, starting at `10-conformance-checklist.md:1184` and ending with its added-date paragraph at line 1228, before `## The rate`. All other CNF text stays unchanged. For R-BOTH, the separate owner-adopted STO-54 block immediately above is the fixed accompanying pv-by1w change. HOLD postpones that package entirely. No claim that either candidate has already been reviewed is made.

### R-BOTH — retain the landed arm and add the adopted eligibility cases

This is the minimal insertion onto the landed item: preserve every landed byte and insert exactly C-UNKNOWN's new “Unknown restart eligibility” conformance paragraphs before the trailing owner/provenance paragraph. Its certificate/report paragraph is the landed pv-zuu5 paragraph, not the old “explicit nonnumeric report” sentence. Whether that preserves the meaning of item 18 is Q1/Q2's central question. The manager found a reader-checkable text-application conflict, but has not established a substantive owner-policy conflict. This candidate does not assume that “nonnumeric report” forbids publishing a known numeric endpoint; nor does it assume that phrase can be silently discarded. Decide from the exact words and owner context.

```markdown
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
  procedure promotes neither as a restart and automatic failover promotes neither standby at all,
  including as a restore, before an operator decides, regardless of whether the numerical reports
  are equal (`STO-54`: “Only an operator starts a promotion that is a restore”). Stop one standby, make an acknowledged write, stop the other, lose the
  primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped.
  Promote a lagging standby as an operator restore with verified prefix/clock evidence and
  assert the incident stores certified bounds. Repeat with an idle restarted standby that has
  replayed no transaction record and no retained fallback proof, leaving the lower history endpoint
  unknown, but supply valid retained event-clock and stopping/fencing evidence certifying an
  upper endpoint under `STO-54`. Assert that the incident persists `lost_window_starts_at` as
  null and `loss_end_at` as that certified upper endpoint, with a non-null incident-keyed
  `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint
  reason (`STO-54`, `STO-56`). For this fixture, assert that the operator report publishes
  the certified upper endpoint and its clock/provenance assumptions, identifies the lower
  endpoint as unknown and states that no finite duration is established (`STO-54`).
  A report omitting the certified upper endpoint or inventing a finite loss duration fails
  this case. Follow with the existing restore procedure. Repeat with no
  verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a
  backup name to fill an unknown history bound.
  For these operator-restore arms, supply certified evidence for each asserted known
  `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
  non-null incident-keyed `history_evidence_ref`
  identifying evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).

  Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.

  Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.

  Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.

  **Unknown restart eligibility.** Construct two fixtures with identical surviving standby
  reports on the same actual old-primary history and no open incident. In the first, establish
  complete trustworthy negative evidence of no waiting-backend cancellation or termination;
  satisfy every other restart condition. Promote each equal standby in a separate run and
  assert restart classification, no restore record and no restore credential-generation bump,
  preserving the ordinary startup-generation advance. In the second, arrange a waiting-backend
  termination independently observed by the test, then lose the primary and its logs and hide
  the event evidence from the promotion procedure; the surviving reports are the same as in
  the first fixture. Assert unknown eligibility, operator notice and no automatic promotion.
  Do not give the procedure the test's hidden oracle or label its unknown state as a known
  violation. In a separate known-event case supply valid event evidence and assert the existing
  restore classification, including when the termination was caused by primary shutdown.

  Repeat unknown eligibility with no event in fact but lost or incomplete coverage, mismatched
  database/incarnation/ancestry evidence, an unauthenticated clean assertion and conflicting
  records. Missing logs or an assertion without continuous coverage cannot pass. Retain a known
  termination and separately an unknown interval across later catch-up, equal reports and an
  incarnation change on which the next restart depends; neither is silently reset. In each
  unknown fixture assert no restore begins automatically; let an operator explicitly authorize
  one and assert the stopped-components procedure and an acknowledged incident record before
  startup. This is not a fast-shutdown read/action reproduction. Finally authorize a restore
  with no certified loss-report endpoints and assert null endpoints and an explicit unknown
  report, followed by the existing procedure without a wait for reporting evidence. (`STO-54`)

  (`STO-5`, `STO-7`,
  `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*
```
### HOLD — exact no-change reference while the interaction remains unresolved

This complete no-change form preserves the pin. It is defensible only as a hold if no exact reconciliation is safe. It does **not** implement item 18, and must not be counted as a final combined implementation. A pick of HOLD must name the reader-checkable conflict and what would go to the owner. This is not a substantive policy alternative already adopted or a proposal to retire pv-by1w.

```markdown
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
  procedure promotes neither as a restart and automatic failover promotes neither standby at all,
  including as a restore, before an operator decides, regardless of whether the numerical reports
  are equal (`STO-54`: “Only an operator starts a promotion that is a restore”). Stop one standby, make an acknowledged write, stop the other, lose the
  primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped.
  Promote a lagging standby as an operator restore with verified prefix/clock evidence and
  assert the incident stores certified bounds. Repeat with an idle restarted standby that has
  replayed no transaction record and no retained fallback proof, leaving the lower history endpoint
  unknown, but supply valid retained event-clock and stopping/fencing evidence certifying an
  upper endpoint under `STO-54`. Assert that the incident persists `lost_window_starts_at` as
  null and `loss_end_at` as that certified upper endpoint, with a non-null incident-keyed
  `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint
  reason (`STO-54`, `STO-56`). For this fixture, assert that the operator report publishes
  the certified upper endpoint and its clock/provenance assumptions, identifies the lower
  endpoint as unknown and states that no finite duration is established (`STO-54`).
  A report omitting the certified upper endpoint or inventing a finite loss duration fails
  this case. Follow with the existing restore procedure. Repeat with no
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
```
## Historical whole-item replacement and conditional conflict alternatives

Read the complete exact historical CNF-365 replacement in `sources/r88-form-C-UNKNOWN.md` (also extracted as `sources/adopted-C-UNKNOWN-CNF-365.md`); it is evidence, not an additional approved r92 reconciliation candidate. The full difference against the landed item is in `sources/cnf365-exact-form-difference.diff`. It both adds the eligibility paragraphs and restores the old report paragraph. A literal application loses the explicit landed certificate/report checks. That loss alone establishes the stop, not that items 9 and 18 demand incompatible reports.

No direction-specific owner-policy resolution is preprinted because a substantive conflict has not yet been demonstrated from the words. If you establish one, quote both incompatible demands, give a concrete same-fixture report that cannot pass both, and supply **each way** as a full exact CNF-365 replacement against the pin, with all collateral flips named. Do not resolve it by silently deleting an assertion, changing STO-54 or weakening a theorem. Distinct exact alternatives remain distinct forms; a manager will not synthesize them into votes. If R-BOTH merely needs a narrower wording clarification, give its complete replacement and state precisely what changes from printed R-BOTH. No partial sketch can settle Q2.

## Preservation checklist to audit, with the source holding each assertion

Audit all the following source-derived obligations, naming each and locating its exact surviving sentence in your pick. These are review prompts, not a second normative home. An asserted loss needs a changed check verdict or quoted normative duty and a concrete trace.

- pv-zuu5: the entire acceptance criteria in sources/pin-pv-zuu5.md, especially the fixture “leaving the lower history endpoint unknown” and “supply valid retained event-clock and stopping/fencing evidence”; persist null lower, certified upper, and incident-keyed non-null evidence reference with retained evidence/unknown-lower reason; publish upper and clock/provenance assumptions, identify unknown lower, state no finite duration; “A report omitting the certified upper endpoint or inventing a finite loss duration fails this case”; follow existing restore procedure; retain separate no-event-clock/unknown-upper arm, no restart-time/backup-name filling, other promotion arms and continuation.
- C-UNKNOWN: the old operator-restore reporting checks in its exact check form, including the meaning of “an explicit nonnumeric report” when a certified upper exists; retain certified evidence for each known endpoint/null for each unknown/evidence reference. Then audit every sentence of its added “Unknown restart eligibility” paragraphs: substantiated clean/equal positive control once promoting each; no restore record/restore generation bump but ordinary startup advance; hidden-event paired fixture with identical survivor inputs and no oracle leakage/false known-violation label; known-event restore including shutdown; no-event incomplete/lost coverage and mismatched/unauthenticated/conflicting evidence; no clean pass for missing logs/noncontinuous assertion; known termination and unknown interval retained across catch-up/equality/incarnation; operator notice/no automatic promotion or automatic restore; explicit operator authorization/stopped components/acknowledged incident before startup; last no-certified-endpoints restore/null endpoints/explicit unknown report/no wait for reporting evidence. The exact form, not this list, owns the details.
- Both decisions: unchanged older CNF-365 assertions before/after the reporting arm, and fixed C-UNKNOWN STO-54 meaning. Report whether any guard, obligation, fixture, negative-control strength, theorem or positive control changes. No `lake build` is needed or allowed for this reading.

## Questions and answer format

**Q1 — substance or landing?** Do owner items 9 and 18 conflict in substance for CNF-365's required report when loss duration is unknown, or only in how a pre-repair whole-item replacement applies? Answer **LANDING ONLY**, **SUBSTANTIVE CONFLICT**, or **UNRESOLVED**. Quote both decisions' operative words and the exact STO-54/CNF-365 passages. Distinguish unknown restart eligibility, unknown lower endpoint, unknown upper endpoint and unknown duration. For a substantive conflict, exhibit the same-fixture incompatible verdict; a removed assertion caused by stale copying is not automatically proof that the owner intended its removal.

**Q2 — exact text and authority?** Pick exactly **R-BOTH**, **HOLD**, or **EXACT ALTERNATIVE <name>**. Separately ACCEPT / CANNOT ACCEPT R-BOTH as a final combined implementation, and ACCEPT / CANNOT ACCEPT HOLD as a temporary hold. If picking an alternative, print it whole as above, including its landing boundary. For your pick, classify its relation to **each** owner decision as **MEANING PRESERVED / WORDING REBASED** or **MEANING CHANGED** and explain whether the owner's 2026-10-28 wording rule settles it or a substantive decision must go to the owner. Item 18 already authorizes its new obligations: adding them relative to master is not by itself a new deviation from that owner decision. Conversely, don't call deletion of a tested report assertion mere wording. Give the assertion-by-assertion preservation audit above with exact surviving quotations and line/paragraph locations; name any loss without claiming no weakening if one exists.

Then give (a) the strongest objection to your own pick, explicitly labelled as a requested counterargument rather than your vote; (b) any verified error in this brief, with its effect under notes.md rule 6. Do not recast the originally adopted C-UNKNOWN behavior change as editorial: the narrower question is whether rebasing its CNF-365 wording on top of another adopted repair alters either already-authorized meaning.

End with two machine-readable-style lines:
`Q1 FINAL: LANDING ONLY | SUBSTANTIVE CONFLICT | UNRESOLVED` (choose one)
`Q2 FINAL: <one exact candidate>; ITEM9: <classification>; ITEM18: <classification>; AUTHORITY: WORDING RULE | OWNER REQUIRED` (choose one per field).

This turn only launches r92. A split or unsettled result gets ONE consensus round r92b in a later turn; no tally, owner question, application, tracker write, PR action or follow-on round occurs here.
