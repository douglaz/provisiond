**Y-PROV-R: ACCEPT. Y-WIDE-R: ACCEPT. Final preference: Y-PROV-R.**

I reviewed both complete C1–C7 packages against detached HEAD `1fc54e8f361e4a9342359388314d32c398595f62`. These are complete-package acceptance votes for this reading. They authorize no adoption or implementation. Q2 is outside this vote.

Saved [sol.draft.md](/var/tmp/provisiond-panel-r77/r77b/sol.draft.md).

P preserves a distinction supported by the source. WIR-9a’s heading is “Neither key is rendered from markers a restore may have rolled back”; STO-54 describes the affected install “with its `OPS-45` markers as the backup holds them”. A process crash after admission does not roll back those new commits. P therefore retains ordinary rendering on fresh work. W expressly chooses permanent incident-scope concealment instead. That is a disclosed policy amendment, not an undisclosed baseline loss merely because I prefer P.

I found no verified blocking loss in either printed package and require no AMEND. Their costs and supersession policy remain owner choices.

**Provenance, rendering and prior objections**

C2 puts initialization in the acknowledged restore-record transaction, before either component starts. It reaches queued, running and already-`needs_reconciliation` install/inventory rows while preserving their marker columns.

The already-reconciling case is now disclosed and separately exercised. CNF-300’s initial fixture expects `disk_effect: "none"` and `rescue_exit: "unknown"`. C6 preserves that initial verdict, then deliberately changes the later restored rendering to unknown/unknown. Baseline CNF-300 does not assert that later outcome. Removing `needs_reconciliation` from initialization would change the proposed policy; I do not request it.

C1 is deterministic about legacy rows, including settled rows. STO-13 says a column an old writer does not populate “is nullable in the release that adds it and tightened after a backfill in a later one”. Null renders conservatively during that interval; backfill changes only still-null values. Old writers can produce additional nulls during overlap, so retirement and the remaining backfill precede tightening. Fresh false and established true values survive backfill.

A settled legacy error can lose its former facts, whereas an established settled false row is outside actual-restore invalidation. Those are different, expressly disclosed cases.

C4 limits the override to `disk_effect` on install and `rescue_exit` on both kinds. Address and port remain actual companion fields. The replacement preserves “so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous”; I verified those words against [STO-54](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/05-persistence.md#L1657).

STO-50’s “anything not on the list MUST NOT be written to it” remains compatible because the bit stays outside `request_summary`. API-53’s counter “strictly increases on each client-visible modification” still applies when a provenance write changes rendered details; C6 adds no revision assertion.

The C6 table agrees with both packages:

| Install case | Y-PROV-R: disk / rescue | Y-WIDE-R: disk / rescue |
|---|---|---|
| Old restored unsettled row | unknown / unknown | unknown / unknown |
| Fresh (a), null/null | none / none | unknown / unknown |
| Fresh (b), write/false | destructive_boundary_crossed / unknown | unknown / unknown |
| Fresh (c), write/true | destructive_boundary_crossed / clean | unknown / unknown |
| Formerly fresh unsettled row, actually restored | unknown / unknown | unknown / unknown |
| Existing unresolved CNF-300-derived row, actually restored | unknown / unknown | unknown / unknown |

Fresh rescue inventory’s null/false/true cells are none/unknown/clean under P and unknown/unknown/unknown under W. Neither adds `disk_effect` or an install write-started marker to inventory.

Unknown rescue exit retains address/port and promises no key file: RSC-19 says “An engine crash persists nothing”. Neither package changes interrupted rows’ reconciliation status or authorizes replay. OPS-45 says the destructive marker establishes “preservation is no longer proven, not that a byte landed”; P’s crossed-boundary cell retains that meaning.

**Startup and repeated-restore traces**

1. **Restore-classified promotion.** STO-54 calls a nonqualifying promotion “a restore: the procedure below runs on it”. C2’s initialization therefore accompanies establishment in the promoted store. A qualifying promotion holding all acknowledged commits is a restart; an inherited open incident is continued without fresh initialization or supersession.

2. **Process successor.** The incident and marks survive. OPS-15’s running-row pass “runs at every startup, the record open or not”. P preserves fresh false provenance. W atomically sets true with the specified open-incident transition. Lost transition replies and subsequent startups cannot reverse either result or replay the interrupted operation.

3. **Actual restore over open A.** C5 closes A and inserts distinct B atomically, retaining A and naming it from B. B starts unmarked with null grace. This satisfies STO-56’s “at most one row may have `closed_at` null” without reusing A’s completed marks. C2 initialization shares that transaction; acknowledgment precedes startup.

4. **Second supersession.** A restored store containing open B gets distinct C. B and its predecessor link remain where those records survive in the backup. The package does not reconstruct records lost outside that backup. Ordinary successors create no incident.

5. **Lost establishment reply.** An aborted transaction can be established once by retrying the retained id/instant. A committed transaction receives the matching-id guarded no-op, preserving its instant and step marks. The retry cannot supersede its own newly established record. Mismatched instant or predecessor is refused with both components stopped. Another actual restore requires a distinct id. This answers the previous lifecycle objection with explicit policy; Boolean idempotence alone would not.

6. **Closure, purge and upgrade.** Ordinary closure retains its conditions and live disposition check. Closure and purge clear no provenance. W’s affected fresh facts remain hidden permanently for that retained operation. P preserves ordinary rendering unless a later actual restore invalidates the unsettled row. A restart without an open record preserves the bit, including transitional null. C1 separately governs legacy backfill.

**Supersession’s consequences**

[STO-56](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/05-persistence.md#L1374)’s ordinary guard protects more than the index: it requires “`grace_ends_at` has passed”, “the account sweep’s second pass is done”, and “every waiting parent is confirmed or cancelled”. It also says “Closing at the original end alone MUST NOT disable unspent paused grace for a currency with a live unfenced machine.”

C5 expressly creates an exception and substitutes a full new procedure. I evaluated that exception rather than silently applying the unchanged ordinary close rule.

For unexpired wall-clock grace, B’s null end continues to defer cancellation claims. OPS-41 requires deferral while the end “is null or in the future”. For unfinished paused grace, B computes from B’s step (3), discarding A’s accumulated measure. An outage-bound or suspended-tenant cancellation that could proceed under A can consequently wait for B’s new wall-clock grace. Its existing precedence returns afterward; funding alone receives the paused measure.

Concrete adverse cost trace, reasoned rather than executed: A has step (3) at 0, interval 60, an outage from 10, bound 90 and a live unfenced machine. Restore a backup taken at 80 at time 100; B completes step (3) at 110, ending grace at 170. At 120 A’s no-rate step 5 could cancel; B’s claim must defer until 170. C5 deliberately replaces A’s deadline verdict.

An unconfirmed inherited parent still meets the new step-(2) waiting-parent rule. Closing A does not confirm or cancel its operation. An unfinished account-sweep second pass is replaced by the new two-pass obligation; predecessor progress cannot satisfy it. STO-54 says the first pass “may record nothing about absence”. These obligations remain protected through B.

STO-49’s additional retention applies “While a restore record is open”. Supersession replaces the grace anchor and predecessor-specific retention obligation; other retention floors remain. The new procedure freezes retention before its new grace end, and B’s replay requires its own stamped left-edge state. I found no promise requiring A’s discarded grace verdict to survive the expressly declared replacement.

Existing CNF-218/295 ordinary-close fixtures remain applicable. CNF-308’s “close first, then attach” case expects “the cleanup receives no restore deferral” in that ordinary-close run. Supersession leaves a different incident open: an attach can receive B’s grace without reopening A. That is the declared new-incident policy, not a change to that fixture’s ordinary-close result.

I found no necessary collateral normative or checked-verdict amendment beyond the printed exception and added cases. The combined new traces remain unexecuted.

Both packages add admission metadata, retained fields, staged migration/backfill and a bulk pre-start write. Transaction, WAL and recovery-latency costs are unmeasured; I assume no small backlog. W adds transition writes and permanent concealment of trustworthy fresh facts.

**Formal boundary and checks**

[Rescue.Session.rescueExit](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/tools/formal/Provisiond/Rescue.lean#L972), tagged WIR-9a, matches only `rescue_exited_cleanly`; its World has no provenance input. The candidate retains that ordinary mapping and replaces the previously unmodelled restore override.

[Restore.lean](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/tools/formal/Provisiond/Restore.lean#L39) explicitly omits closure and per-currency closure checks; its Op has no install markers. I found no existing formalized clause requiring a changed definition and no refuted theorem. This is missing coverage. `fresh_work_swept_after_restore` supports create/power timing, not the install table. ADR-0025 says “Authority is per clause” and “A theorem is never conformance”.

Checks actually run:

- Clean detached pin and final unchanged source status verified.
- Required readings and relevant source/formal declarations inspected; targeted source-word comparisons passed.
- Both required unpiped `nix develop --command bash tools/check-all.sh` runs passed, exit 0. [Final receipt](/var/tmp/provisiond-panel-r77/r77b/sol/tools/formal/.lake/sol-final-gates.log).
- `rg` was unavailable, exit 127; grep/sed supplied the reads. No gate failed.

Not run: candidate migrations, runtime conformance, latency measurement, a new provenance theorem, an integrated candidate build or the CI negative-control job. No source or tracker edit was made.

I verified no factual claim in this brief false, found no premise-changing error, and have no vote resting on one. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

This seat establishes no panel tally. Apply “a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”, with no verified blocker. Ties and policy/cost decisions return to the owner.

**Requested counterargument against preferred Y-PROV-R — not a vote**

P’s reassuring fresh values depend on every actual-restore path performing pre-start invalidation correctly. W’s transition write supplies another conservative check on transitioned rows during the incident and gives callers a uniform unknown policy there. P also pays the shared metadata, upgrade, bulk-write and supersession costs to preserve this distinction; the owner may judge that value insufficient. Both forms still depend on correct establishment, and W never recovers its hidden facts at closure.

My preference remains Y-PROV-R. No implementation approval follows.