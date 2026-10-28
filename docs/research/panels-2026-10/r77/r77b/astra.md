**Y-PROV-R: AMEND. Y-WIDE-R: AMEND. Final preference: Y-PROV-R.**

Both amendments are the same **verified wording-only repair A1**, below, and count as ACCEPT under notes.md rule 1 on that basis. A1 introduces no runtime obligation or lifecycle exception beyond printed C5. I found no necessary behavioural repair and no verified blocking loss beyond the explicitly declared policy changes.

I prefer P because a process crash that loses no acknowledged marker write should preserve those wire facts. W’s permanent concealment is coherent conservative policy, but gives callers less information. Costs and adoption remain the owner’s decisions.

Read against detached pin `1fc54e8f361e4a9342359388314d32c398595f62`. The [substantive draft is saved](/var/tmp/provisiond-panel-r77/r77b/astra.draft.md). Q2 was not re-voted.

**Provenance, scope and wire results**

The motivation survives inspection. WIR-9a says “Neither key is rendered from markers a restore may have rolled back”; OPS-15 says its pass “runs at every startup, the record open or not”. Fresh work can therefore be swept without a later rollback. `fresh_work_swept_after_restore` establishes the timing for create/power; its operation type has no install-marker fields.

C1–C4 address the earlier objections explicitly. C4 preserves “and the operator resolves such a row as ambiguous”. Only the named marker keys become unknown; address and port remain companion fields. Legacy upgrade and marking an already-reconciling row are disclosed conservative changes, not claims that those facts necessarily suffered rollback.

The baseline does not establish that the broader status scope is necessary. It nevertheless permits that proposed policy to be judged on its merits. CNF-300’s `disk_effect: "none"` / `rescue_exit: "unknown"` describes its immediate failed-exit fixture, not the result after another restore. C6 supplies that distinct later-restore case honestly.

The marker columns themselves remain preserved. The selected package produces these wire values:

| Install case | Y-PROV-R | Y-WIDE-R |
|---|---|---|
| Old unsettled row, restored null/null | unknown / unknown | unknown / unknown |
| Fresh (a), null/null | none / none | unknown / unknown |
| Fresh (b), write marker set, rescue false | destructive_boundary_crossed / unknown | unknown / unknown |
| Fresh (c), write marker set, rescue true | destructive_boundary_crossed / clean | unknown / unknown |
| Formerly fresh unsettled row after another restore | unknown / unknown | unknown / unknown |
| Already-unresolved failed-exit row after restore | unknown / unknown | unknown / unknown |

Fresh inventory’s null/false/true cases give none/unknown/clean under P and unknown/unknown/unknown under W. Its old-row and later-restore cases give unknown under both. It gains neither `disk_effect` nor a write-started marker.

WIR-9a says “With `unknown` the error also carries `rescue_address` and `rescue_port`”; C4 preserves that requirement. Unknown does not promise a recovery-key file: RSC-19 says “An engine crash persists nothing”. Nor does the destructive-boundary value prove completion: WIR-9a says it “does not assert that the install completed”. Neither package authorizes replay or automatic settlement.

**Establishment and repeated recovery**

STO-54 requires the deployment to “stop every engine and `api` process” and “start neither component until the transaction that commits `STO-56`’s record … has been acknowledged”. C2 places initialization in that transaction.

This reaches restore-classified promotions: STO-54 explicitly says such a promotion “is a restore: the procedure below runs on it”. A promotion preserving every acknowledged commit does not repeat initialization; an inherited open incident continues under its existing record.

A process successor preserves the incident’s completed marks and does not initialize again. P preserves fresh false provenance. W sets true during its specified guarded transition. Repeating the transition cannot reverse true. Closure and payload purge cannot reverse it either. Another actual restore initializes every surviving row in C2’s status set, including rows already awaiting reconciliation.

The metadata stays outside `request_summary`: STO-50 says “anything not on the list MUST NOT be written to it”.

C5 solves the previous unique-open-row obstruction through record replacement, not Boolean idempotence. Within one transaction, close inherited R and insert distinct B naming R. Retain R; start B unmarked with a null grace end; acknowledge before component startup. Closing R before inserting B inside that transaction satisfies the partial unique index without exposing a component-start gap.

A subsequent actual restore containing open B establishes distinct C naming B and repeats the full procedure. No predecessor step mark satisfies the successor’s step.

For a lost establishment reply, retry uses the retained new id and restore instant. If the first transaction did not land, establishment occurs. If it landed, the matching retry is a guarded no-op preserving that record’s instant and marks. It cannot manufacture a new predecessor from whichever row is now open. C5 requires a mismatch to be refused with both components stopped. An ordinary crash establishes or supersedes nothing.

C1’s staging matches STO-13’s “nullable in the release that adds it and tightened after a backfill in a later one”. Null renders conservatively. Backfill changes only still-null values; fresh false and existing true survive. Previous-release writers retire before the remaining nulls are backfilled and the later constraint is tightened. This is deterministic upgrade policy, not evidence of historical rollback.

**What supersession replaces—and what that costs**

STO-56’s ordinary restriction, “The operator MUST NOT close the record until”, protects outstanding obligations. C5 deliberately introduces an exception and replaces them with a full new procedure. That is owner policy, not an interpretation of the old restriction.

For unexpired wall-clock grace, B’s null end blocks cancellation claims, and B’s step (3) starts another interval. For partially spent rate-present grace, OPS-41’s “From step (3)’s instant … accumulate only time” now uses B’s left edge. R’s accumulated amount does not transfer.

STO-49 requires retention of history needed “from step (3)’s instant” while the record is open. B’s grace-history floor replaces R’s special floor, subject to all other retention obligations. Retaining R’s incident row does not by itself preserve enough history to reconstruct R’s former grace calculation. The package promises retained predecessor records, not complete historical grace audits.

An already-reached outage bound or a suspended tenant’s cancellation can wait again. OPS-41 requires “any exposure-reducing cancellation” to defer while the open end “is null or in the future”. Repeated actual restores can repeat that delay; the chain’s cost is not bounded to one interval. Inherited fences remain: STO-54 says “a machine already fenced when the grace begins gets no extension from it”.

The new procedure also protects the unfinished account sweep and waiting parents. STO-54 says “The first pass may record nothing about absence”; its second pass must be separated by the effective window. A predecessor’s unfinished pair cannot count as B’s completed pair. An unsettled parent again “waits for operator confirmation instead of resuming”. Process successors preserve B’s work; actual supersession starts the new procedure.

I found no outstanding obligation that inherently demands preserving R’s deadlines instead of the disclosed replacement policy.

**A1: exact collateral wording repair**

Location: [STO-54, 05-persistence.md:1616](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/05-persistence.md#L1616).

Before:

> The operator closes the record only under `STO-56`’s close rule (*amended 2026-10-03, `ADR-0029`*), after which a process that starts is an ordinary restart.

Replacement:

> The operator closes the record only under `STO-56`’s close rule (*amended 2026-10-03, `ADR-0029`*). When no restore record remains open, a process that starts is an ordinary restart; for supersession and the new open record, see `STO-56`.

**Behaviour unchanged relative to printed C5 and the existing open-record rule.** C5 already requires the new open record and its full procedure; STO-56 says “Both components read the open row before anything else they do”. A1 corrects the old after-close gloss without adding a guard, write, exception or fixture restriction.

Verification trace: supersede R with B, acknowledge, then start. B determines startup. A later process crash continues B; another actual restore establishes C. Ordinary closure of the last open incident leaves no open row and permits ordinary restart. The existing `faultAfterCrash` helper agrees with that selection, although it does not model supersession itself.

The ordinary late-attach check requires no additional policy. Supersession does not reopen R or confer R’s grace; B supplies its own grace. With B’s step (3) at 100 and interval 10, a cleanup claim at 101 defers to 110 under OPS-41’s “claim MUST defer” rule. After ordinary closure with no open record, it receives no restore deferral.

No existing fixture is narrowed. CNF-295’s “Only when every prerequisite is satisfied close and verify ordinary restart behavior” still tests ordinary closure. CNF-218 explicitly says “Keep the restore record open throughout the following traces”. Neither is a supersession test.

**Coverage, checks and tally treatment**

The tagged rescue helper has no restore-provenance input; C4 preserves its ordinary mapping. The existing restore override was already outside that helper. `Restore.lean` also omits incident closure and a retained predecessor chain. I found no changed formalized calculation requiring a paired declaration change or weakened theorem. These omissions are coverage limits, not proofs of the proposed mechanism. ADR-0025 says “A theorem is never conformance”.

Both packages add retained metadata, admission writes, backfill and a synchronous pre-start bulk update. Backlog size, WAL volume and migration/recovery latency remain unmeasured. W additionally permanently hides trustworthy fresh facts. None of these costs is negligible by evidence.

Checks actually run:

- Both required unpiped `nix develop --command bash tools/check-all.sh` invocations passed, exit 0. [Final receipt](/var/tmp/provisiond-panel-r77/r77b/astra/review-evidence/final-gate.log).
- The [targeted Lean probe](/var/tmp/provisiond-panel-r77/r77b/astra/review-evidence/existing-semantics.lean) passed, checking existing open-record selection, null/future grace deferral and ordinary rescue-marker rendering.
- Exact-text checks verified A1’s source sentence, staged migration wording, open-row selection and preserved operator ambiguity instruction.
- No applied-candidate build, runtime conformance, migration benchmark or complete CI mutation workflow ran. Exploratory reads encountered a guessed nonexistent filename and no-match searches; corrected reads succeeded. Tracked sources remain unchanged.

I found no verified factual brief error changing Q1’s premise. A1 addresses a stale source gloss exposed by the proposed exception; no vote rests on a false motivating fact.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

No tally is void on this reading. Settling still requires “at least three agree and more agree than disagree”, the owner’s tie handling and three-of-four fallback if Grok is down, plus no verified blocking loss. I have not read or tallied another r77b seat.

**Requested counterargument against preferred Y-PROV-R, not a vote:** missed restore initialization can expose stale nulls as none. W’s transition write catches moved rows again while the incident is open. Both still depend on correct initialization for already-reconciling rows, so W is not a complete substitute. P’s information advantage must be weighed against that implementation risk and the shared costs.

No adoption, implementation, source commit, tracker write or follow-on round is approved.