# pv-ucs.2 verification — 2026-10-08

Task: apply [ADR-0034 and Q10](../adr/0034-tenant-traffic-cannot-spend-the-providers-request-budget-the-system-needs.md).
Starting commit: `4830cd02890fa37aea205dd8cd0e2b4e8a1f9876`, branch `pv-ucs-impl`.
The Manager's existing Beads export was preserved. The ticket remains open for independent review.

## Amendment ownership and conformance

| Topic | Normative home | Implementation obligations |
|---|---|---|
| Refresh freshness, claim-time cache check, observation age and failed-read residual | `DOM-8` | `CNF-331`, `CNF-332` |
| Nullable observation timestamp in the machine view | `WIR-11`; stored semantics: `STO-48` and the machines schema | `CNF-333` |
| Reverse-DNS per-principal ceiling | `SEC-39`; pipeline: `API-7` | `CNF-334` |
| Reverse-DNS no-op, established PTR map and invalidation | `PRV-25`; representation: machines schema | `CNF-334`, `CNF-335` |
| Driver request-budget declaration | `PRV-44` | `CNF-336`, `CNF-339` |
| Credential-scope accounting, reserve admission, continuation and exhaustion alarm | `PRV-46` | `CNF-336`, `CNF-337`, `CNF-338` |
| Deployment parameter types and startup checks | `OVR-19` | `CNF-339` |

The asynchronous endpoint and result contracts were reviewed alongside the local settlement
pointers near `OPS-11`. Its failure table and `Provisiond.Tables.refresh_always_failed` were not
changed. `PRV-40` was not changed. The conformance checklist remains unchecked: this work supplies
implementation obligations, not evidence from a running provisiond.

## Formal evidence

- [ProviderTraffic.lean](../../tools/formal/Provisiond/ProviderTraffic.lean): tagged cache,
  PTR and request-budget declarations; general properties for cache reuse, failed observation,
  invalidated PTR, new tenant refusal, system access and admitted continuation.
- [Admission.lean](../../tools/formal/Provisiond/Admission.lean): the reverse-DNS ceiling in the
  total map and its pipeline guard. `only_the_override_is_uncapped` explicitly assumes that new
  guard is enabled; its conclusion for the current policy is retained.
- [Wire.lean](../../tools/formal/Provisiond/Wire.lean): optional observation timestamp in the
  projection and its preservation theorem; the provider-field independence theorem remains.
- [Witnesses.lean](../../tools/formal/Provisiond/Witnesses.lean): guarded and unguarded traces for
  each new guard listed in the control table below. Queue tests compute a successful observation
  from a serialized read. Budget tests begin with empty usage and derive admission from a first
  dispatch, then compare another tenant, a system path and a continuation.

The models do not prove driver behavior, configuration loading, persistence, scheduling or runtime
conformance. The new budget model carries local admission/accounting for a period, not a provider
rate-limit or dispatch-timing guarantee. Its continuations retain accounting without a second local
admission refusal. The axiom gate passed without an exception; no coverage baseline was raised.

## Gate and control procedure

The unpiped `nix develop --command bash tools/check-all.sh` exited **0** before work and **0**
after the semantic amendments and control repairs. Final pre-commit verification is recorded below.

The control source is [ci.yml](../../.github/workflows/ci.yml). Every standalone control and every
source row of its guard matrix was exercised across the workflow's shard assignments. The initial
matrix rehearsal exited **1**: the reverse-DNS ceiling and evidence rows refuted their intended
witnesses but their token checks missed text beyond the diagnostic excerpt; disabling the no-op
also refuted a second witness that had not pinned the unrelated guard. Named expressions and an
independent guard setting repaired these controls. Their diagnostic assertions were not relaxed.
The new invalidation row and all new traffic/ceiling rows were then rechecked on the final model,
with the complete source partition validated before selecting affected rows. Unchanged successful
rows were not repeated.

One repository copy, `.pv-ucs2-rehearsal/repo`, served the entire rehearsal. Sources and the clean
prepared `.lake` tree were restored in place between rows. The workflow's repeated-copy setup was
replaced with that restoration; the mutation and expected-diagnostic assertions were retained.
The publication fixture's temporary-directory location was moved inside the repository, and all
other temporary files used the in-repository temporary directory. No nested repository copy was
made. After restoration, `lake build` in the copy exited **0**.

### Standalone workflow controls

| Shard | Workflow step | Result |
|---|---|---|
| 0 | Prove formal publication survives overlap and failures | PASS (exit 0; workflow assertions retained) |
| 0 | Prove direct formal writes fail the publication interleaving regression | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the identifier gate can fail | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the identifier gate refuses a tiered conformance item | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the obligation gate can fail | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the citation gate can fail | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the Lean build rejects the withdrawn OPS-41 predicate | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the axiom gate rejects a sorry the build accepts | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the axiom gate rejects native_decide outside Provisiond.Explore | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the formal gate rejects a module the build never reads | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the formal gate rejects a conformance identifier in the formal layer | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the Lean build rejects the claim guard without its claim term | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the Lean build rejects an error kind without a classification row | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the Lean build rejects the classification without its goal-state row | PASS (exit 0; workflow assertions retained) |
| 0 | Prove accepted failures and in-progress orders survive only with their guards | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the migration type refuses a CONCURRENTLY build inside a transaction | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the rendering gate rejects a hand edit inside a rendered region | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the rendering gate rejects a flipped outcome in a diffed table | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the citation gate rejects a declaration name the index does not carry | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the citation gate rejects a misquote in a Lean docstring | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the citation gate names unterminated Lean block comments | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the citation gate rejects a Lean docstring quote found nowhere | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the citation gate rejects an attribution only the ADR pool satisfied | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the citation gate rejects a spaced elision after a short quote | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the citation gate rejects bare possessive, apostrophe and nested misquotes | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the citation gate preserves trailing possessives and detects a bypass | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the citation gate preserves equivalent nested delimiters | PASS (exit 0; workflow assertions retained) |
| 0 | Prove the citation gate refuses damaged baselines, stale exemptions and an empty Lean scan | PASS (exit 0; workflow assertions retained) |
| 1 | Prove the citation gate rejects duplicates and altered exempted Markdown wording | PASS (exit 0; workflow assertions retained) |
| 2 | Prove the citation gate rejects unpaired quotation marks at source lines | PASS (exit 0; workflow assertions retained) |
| 3 | Prove the citation gate rejects loss of closing-markup boundaries | PASS (exit 0; workflow assertions retained) |

The accepted-failure step separately passed `Tables.acceptanceRule` →
`accepted_read_failure_witness` and `Reconcile.negativeOnly` → `in_progress_order_witness`.
The diagnostic location and single-refutation checks passed for each.

### Guard matrix source rows

Indices are zero-based positions in the workflow's `ROWS` block; the shard is the source index
modulo the workflow's job total. PASS means the mutation applied, the build failed with exactly
one `Provisiond/Witnesses.lean` refutation, and the workflow's named-token assertion passed.

| Source index | Shard | Module and guard | Removed setting | Witness token | Result |
|---|---|---|---|---|---|
| 0 | 0 | `Fence.recheckInsideFence` | `true` → `false` | `fenceWorld paidMachineTrace` | PASS |
| 1 | 1 | `Fence.fenceHolds` | `.episodeId` → `.attemptId` | `fenceWorld retryTrace` | PASS |
| 2 | 2 | `Fence.fenceOnOpenEpisode` | `true` → `false` | `goneRaceTrace` | PASS |
| 3 | 3 | `Fence.abortPredicate` | `.date` → `.sats` | `AbortPredicate.sats` | PASS |
| 4 | 0 | `Fence.abortWritesDate` | `true` → `false` | `staleDateWorld abortTrace` | PASS |
| 5 | 1 | `Fence.extendWritesDate` | `true` → `false` | `Event.extend 100` | PASS |
| 6 | 2 | `Fence.suspensionKey` | `.currentState` → `.episodeReasons` | `resumedTenantTrace` | PASS |
| 7 | 3 | `Fence.outageWrite` | `true` → `false` | `restoredRateTrace` | PASS |
| 8 | 0 | `Fence.ownIdClause` | `true` → `false` | `fenceWorld retryTrace` | PASS |
| 9 | 1 | `Fence.rateIsWindowMedian` | `true` → `false` | `poisonedPassTrace` | PASS |
| 10 | 2 | `Rate.acceptanceBoundary` | `true` → `false` | `delayedAcceptanceTrace` | PASS |
| 11 | 3 | `Fence.graceAtClaim` | `true` → `false` | `graceTrace` | PASS |
| 12 | 0 | `Fence.pauseFundingGrace` | `true` → `false` | `pausedGraceReturn` | PASS |
| 13 | 1 | `Fence.pausedGraceInFence` | `true` → `false` | `pausedGraceRace` | PASS |
| 14 | 2 | `Fence.rederiveFirst` | `true` → `false` | `fundingOrderGuards Fence.current` | PASS |
| 15 | 3 | `Fence.retryDeletes` | `true` → `false` | `priceFundedStall ++ tail` | PASS |
| 16 | 0 | `Fence.retryNeedsFence` | `true` → `false` | `fenceWorld interruptedRetry;` | PASS |
| 17 | 1 | `Fence.keepWritesDate` | `true` → `false` | `operatorGuards Fence.current` | PASS |
| 18 | 2 | `Fence.keepGuard` | `true` → `false` | `keepEligibilityGuards Fence.current` | PASS |
| 19 | 3 | `Fence.retryGuard` | `true` → `false` | `goneAfterStallTrace ++` | PASS |
| 20 | 0 | `Fence.goneOrClosedFirst` | `true` → `false` | `goneMidOutageTrace` | PASS |
| 21 | 1 | `Fence.noRateWaits` | `true` → `false` | `freshOutageTrace` | PASS |
| 22 | 2 | `Fence.absentRecordProceeds` | `true` → `false` | `unrecordedBoundTrace` | PASS |
| 23 | 3 | `Fence.boundReachesAll` | `true` → `false` | `boundCancellerTrace` | PASS |
| 24 | 0 | `Fence.sweepNeedsRate` | `true` → `false` | `pastDateNoRateWorld` | PASS |
| 25 | 1 | `Fence.extendNeedsRate` | `true` → `false` | `haltedExtensionTrace` | PASS |
| 26 | 2 | `Restore.quarantineOnRestore` | `true` → `false` | `Event.startupPass, Event.claim { n := 0 }` | PASS |
| 27 | 3 | `Restore.exceptionFrozen` | `true` → `false` | `Event.confirmParents, Event.claim { n := 1 }` | PASS |
| 28 | 0 | `Restore.bumpOnRestore` | `true` → `false` | `Event.request 0, Event.completeProcedure` | PASS |
| 29 | 1 | `Restore.twoPassAbsence` | `true` → `false` | `Event.sweep true false, Event.windowElapses` | PASS |
| 30 | 2 | `Restore.recordDecidesBoot` | `true` → `false` | `Event.crash, Event.lock` | PASS |
| 31 | 3 | `Reconcile.completePassOnly` | `true` → `false` | `w.retriedIntoThrottle = false` | PASS |
| 32 | 0 | `Reconcile.pastWindowOnly` | `true` → `false` | `Event.advance 7, Event.sweep true false Answer.notFound` | PASS |
| 33 | 1 | `Reconcile.rereadBeforeAbsence` | `true` → `false` | `Event.advance 2000, Event.sweep true false Answer.found` | PASS |
| 34 | 2 | `Reconcile.absenceWindow` | `.visibility` → `.negative` | `Event.advance 20, Event.sweep true false Answer.notFound` | PASS |
| 35 | 3 | `Reconcile.readConfirmsMatch` | `true` → `false` | `w.orderLanded = some mach` | PASS |
| 36 | 0 | `Ledger.clampAtAuthority` | `true` → `false` | `seizureBalances` | PASS |
| 37 | 1 | `Ledger.serializedAuthorization` | `true` → `false` | `skewTrace` | PASS |
| 38 | 2 | `Ledger.appendReadsLatest` | `true` → `false` | `staleDebitTrace` | PASS |
| 39 | 3 | `Funding.keyFrom` | `.payment` → `.observation` | `replayTrace` | PASS |
| 40 | 0 | `Funding.keyFrom` | `.payment` → `.deposit` | `bothRailsTrace` | PASS |
| 41 | 1 | `Funding.paymentRecordUnique` | `true` → `false` | `KeySource.observation` | PASS |
| 42 | 2 | `Funding.correctionPrefix` | `true` → `false` | `attributionTrace` | PASS |
| 43 | 3 | `Funding.reapWaitsForWindow` | `true` → `false` | `reapTrace` | PASS |
| 44 | 0 | `Funding.usageKeyFrom` | `.incrementEnd` → `.postingIndex` | `incrementReplayTrace` | PASS |
| 45 | 1 | `Funding.markDiscards` | `true` → `false` | `remeterTrace` | PASS |
| 46 | 2 | `Funding.startsAtMark` | `true` → `false` | `overlapTrace` | PASS |
| 47 | 3 | `Funding.seedOnBillable` | `true` → `false` | `seedTrace` | PASS |
| 48 | 0 | `Funding.exitPosts` | `true` → `false` | `exitCases Funding.current` | PASS |
| 49 | 1 | `Funding.closeBeforeRelease` | `true` → `false` | `releaseOrderTail Funding.current` | PASS |
| 50 | 2 | `Funding.prepaidFirstUnit` | `true` → `false` | `unitTrace` | PASS |
| 51 | 3 | `Funding.offsetRequiresDebit` | `true` → `false` | `unpaidLateSeed Funding.current` | PASS |
| 52 | 0 | `Runway.startAtMark` | `true` → `false` | `insideTheUnitDate` | PASS |
| 53 | 1 | `Wire.endpointInPreimage` | `true` → `false` | `deleteOnA` | PASS |
| 54 | 2 | `Wire.closedSummary` | `true` → `false` | `secretRow` | PASS |
| 55 | 3 | `Rescue.coalesceWrite` | `true` → `false` | `rawInstall lostReplyThenRepeat` | PASS |
| 56 | 0 | `Rescue.markerBeforePhase` | `true` → `false` | `rawInstall phaseWithoutMarker` | PASS |
| 57 | 1 | `Rescue.secondMarkerBeforeSession` | `true` → `false` | `Rescue.current rescueSession crashedSession` | PASS |
| 58 | 2 | `Rescue.partialCleanupMovesNothing` | `true` → `false` | `Rescue.current rescueInstall partialActivation` | PASS |
| 59 | 3 | `Rescue.persistAtActivation` | `false` → `true` | `Rescue.current rescueSession cleanSession` | PASS |
| 60 | 0 | `Rehost.allowlistRequired` | `true` → `false` | `emptyAllowlist` | PASS |
| 61 | 1 | `Rehost.allowlistPerHop` | `true` → `false` | `attackerRedirect` | PASS |
| 62 | 2 | `Rehost.schemePerHop` | `true` → `false` | `schemeDowngrade` | PASS |
| 63 | 3 | `Admission.listenerSplit` | `true` → `false` | `customerHitsAnOperatorRoute` | PASS |
| 64 | 0 | `Admission.operatorSkipsTenantSteps` | `true` → `false` | `pendingAttribution` | PASS |
| 65 | 1 | `Admission.stepTwoReadsSuspension` | `false` → `true` | `suspendedInstall` | PASS |
| 66 | 2 | `Admission.maintenanceCarveOut` | `true` → `false` | `suspendedRevoke` | PASS |
| 67 | 3 | `Admission.statementWhileSuspended` | `true` → `false` | `suspendedStatement` | PASS |
| 68 | 0 | `Admission.ceilingStep` | `true` → `false` | `createAtCeiling` | PASS |
| 69 | 1 | `Admission.replayBeforePolicy` | `true` → `false` | `replayUnderBudget` | PASS |
| 70 | 2 | `Admission.haltMintsOnly` | `true` → `false` | `haltedMint` | PASS |
| 71 | 3 | `Admission.cancelUnsettledInvoices` | `true` → `false` | `unsettledUnexpiredInvoice` | PASS |
| 72 | 0 | `Admission.exposureExemptUnderHalt` | `true` → `false` | `exposureReducingUnderHalt` | PASS |
| 73 | 1 | `Admission.sweepRoutesNothingWithoutRate` | `true` → `false` | `exposureReducingWithoutRate` | PASS |
| 74 | 2 | `Admission.solvencyUsesValuedTerms` | `true` → `false` | `Action.solvencyCheck` | PASS |
| 75 | 3 | `Admission.completeCheckToLift` | `true` → `false` | `incompletePassingTrace` | PASS |
| 76 | 0 | `Admission.richTailCollection` | `true` → `false` | `fencedHaltedNoRate` | PASS |
| 77 | 1 | `Admission.reverseDnsCeiling` | `true` → `false` | `reverseDnsAdmission` | PASS (final recheck) |
| 78 | 2 | `ProviderTraffic.reuseFresh` | `true` → `false` | `freshClaim` | PASS (final recheck) |
| 79 | 3 | `ProviderTraffic.checkAtClaim` | `true` → `false` | `queuedRefreshes` | PASS (final recheck) |
| 80 | 0 | `ProviderTraffic.preserveAge` | `true` → `false` | `ageClaim` | PASS (final recheck) |
| 81 | 1 | `ProviderTraffic.successfulOnly` | `true` → `false` | `failedRefreshes` | PASS (final recheck) |
| 82 | 2 | `ProviderTraffic.reverseDnsNoop` | `true` → `false` | `establishedPtrNoop` | PASS (final recheck) |
| 83 | 3 | `ProviderTraffic.establishedOnly` | `true` → `false` | `uncertainPtrNoop` | PASS (final recheck) |
| 84 | 0 | `ProviderTraffic.sharedScope` | `true` → `false` | `scopeGuards` | PASS (final recheck) |
| 85 | 1 | `ProviderTraffic.protectReserve` | `true` → `false` | `reserveGuards` | PASS (final recheck) |
| 86 | 2 | `ProviderTraffic.admitOnce` | `true` → `false` | `continuationGuards` | PASS (final recheck) |
| 87 | 3 | `ProviderTraffic.accountEveryRequest` | `true` → `false` | `accountingGuards` | PASS (final recheck) |
| 88 | 0 | `Ledger.nativeCostSplit` | `true` → `false` | `nativeClampTrace` | PASS |
| 89 | 1 | `Period.resetAtBoundary` | `true` → `false` | `twoPeriodTrace` | PASS |
| 90 | 2 | `Period.splitAtBoundary` | `true` → `false` | `straddleTrace` | PASS |
| 91 | 3 | `Period.deploymentWide` | `true` → `false` | `lateSubjectTrace` | PASS |
| 92 | 0 | `AccountStatus.retainUnlessTerminated` | `true` → `false` | `credentialsRejected` | PASS |
| 93 | 1 | `ProviderTraffic.invalidatePtr` | `true` → `false` | `ptrAfterDifferingDispatch` | PASS (final recheck) |

## Final handoff

Final pre-commit full gate: **exit 0**, unpiped; all specification gates passed.
Scratch cleanup: `.pv-ucs2-rehearsal` (including the sole repository copy, temporary fixtures,
runner and logs) removed; absence verified. This report retains each control result.
Follow-ups: none identified; `pv-ucs.2` stays open for independent review.
No production provider calls were made.
