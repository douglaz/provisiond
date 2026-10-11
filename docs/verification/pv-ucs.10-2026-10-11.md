# pv-ucs.10 verification — 2026-10-11

The starting HEAD was `918af0e` on `pv-ucs-impl`; the comparison baseline for
never-master text was `903053d`. The ticket remains `in_progress` for review. This Run
changed specifications, conformance descriptions and checking interpretations only.
No provider API or live account action was performed, and no implementation
conformance box was checked.

## Work-list disposition

| Item | Edit and evidence location |
|---|---|
| 1–2 | Removed never-master amendment markers and tombstones from the named overview, domain, provider, API, wire and conformance passages; retained amendments to master text. `CNF-328` now has its direct dated-release headline. |
| 3–7 | Repaired the ADR-0034 quotation, PRV-13a's research step pointer, the Robot V7 source, Admission's declaration-scoped heartbeats, and README's never-master reservation source. |
| 8–10 | Aligned OPS-32 and PRV-43 with DOM-8's sweep writes; defined future timestamps as stale in DOM-8 and ProviderTraffic, with `CNF-331` coverage; corrected WIR-35's Berlin end-of-day fixture. |
| 11 | Routed current allowance terms through List offers in PRV-13c and `CNF-340`; limited overage-price reading to future allowance-offer re-admission. |
| 12 / Q24 | Assigned settled temporary-key deletion to the OPS-32 sweep in PRV-9 and callers, with pre-acceptance driver cleanup limited to keys its operation successfully registered; expanded `CNF-303`, provider notes and formal scope comments. |
| 13–15 | Made withdrawal's `operator_ref` an unknown-body-field refusal in WIR-47 and `CNF-233`; changed `CNF-354` to inspect PRV-49's enabling precondition; tied the PRV-40/CNF-344/OVR-19 alarm to Robot's reported 403. |
| 16 | Recorded the supplied read-only Robot product-list observation, with its source and unverified-in-this-Run status, in provider notes. |
| 17 / Q23a | Added PRV-13's failed/present read-back tail, LDG-31's clamp reachability and `CNF-64`'s exhausted-commitment trace; qualified LDG-74 and its live references for throttling, incomplete passes and failed confirmation. |
| 18 / Q23b | Made LDG-32 point to PRV-49 for the sale decision; stated the accident-only, uncapped EUR 1.90/month residual in PRV-49; carried its exception into PRV-13b and `CNF-354`. |
| 19 / Q23c | Separated the stored provider-local permitted-from start from the priced-through local-day end in PRV-13, PRV-13c, persistence and LDG-33; added both Berlin cases to `CNF-63`; kept `CNF-147`'s commitment fixed under PRV-31. |

## Formal scope

`ProviderTraffic.fresh` now has an explicit theorem rejecting a future observation;
the DOM-8 Markdown and `CNF-331` use the same claim-time interpretation.
`Rescue.keyEligible` and `step` continue to model one operation's eligibility and an
explicit sweep-removal event. Their theorems do not prove scheduler liveness, provider
fingerprint namespace behavior, duplicate refusal, or cross-operation ownership races.
`Runway.usableSats` takes protected cost as an input: it does not derive the
provider-local date conversion or its priced-through cost. No theorem statement
was weakened. No `CNF` identifier was added to the formal tree.

## Gates and negative controls

The unpiped `nix develop --command bash tools/check-all.sh` exited 0 before edits.
After the semantic and formal edits it exited 0, with all seven gates passing and
799 tagged Lean declarations. A separate targeted Admission build also exited 0.
The final unpiped gate after the verification record and tracker sync is recorded
below. `git diff --check` passed during review and was rerun before commit.

The control inventory was read from the then-current `.github/workflows/ci.yml`:
33 `Prove` steps, of which one is the source-guard matrix. All 32 standalone steps
passed in one repository-local copy. The accepted-failure step exercised its two
distinct mutations and checked their named witnesses. The 96 source rows were
partitioned by source index modulo four, 24 rows per shard; each index 0–95 ran
once. Every mutation produced a nonzero Lean build, exactly one
`Provisiond/Witnesses.lean` error, a refuted `decide` proposition and its expected
named token. Source bytes and timestamps and the copied `.lake` state were restored
after each row. The copied repository built clean before controls and after both
the standalone and source-row suites (exit 0 each time). The one copy and its
rehearsal files were removed after the review. The final prose-only edits after
this rehearsal changed no formal source, gate script, workflow or control inventory;
the final full gate checks the complete resulting documents.

### Standalone control outcomes

All listed controls passed. The numbers below are the workflow's `Prove` step
indices; index 17 is the 96-row matrix reported separately.

| Indices | Outcome |
|---|---|
| 0–16 | PASS each; index 15 passed both accepted-failure and in-progress-order mutations. |
| 18–32 | PASS each. |

### Source-guard outcomes

Each entry gives `source index: expected token`; **PASS** means the named
diagnostic and single-witness checks above passed. Shard = index modulo four.

<!-- The compact source-row inventory below is generated from the current workflow. -->

| Source row and expected diagnostic | Source row and expected diagnostic | Source row and expected diagnostic | Source row and expected diagnostic |
|---|---|---|---|
| **PASS** 0: `Fence.recheckInsideFence` → `fenceWorld paidMachineTrace` | **PASS** 1: `Fence.fenceHolds` → `fenceWorld retryTrace` | **PASS** 2: `Fence.fenceOnOpenEpisode` → `goneRaceTrace` | **PASS** 3: `Fence.abortPredicate` → `AbortPredicate.sats` |
| **PASS** 4: `Fence.abortWritesDate` → `staleDateWorld abortTrace` | **PASS** 5: `Fence.extendWritesDate` → `Event.extend 100` | **PASS** 6: `Fence.suspensionKey` → `resumedTenantTrace` | **PASS** 7: `Fence.outageWrite` → `restoredRateTrace` |
| **PASS** 8: `Fence.ownIdClause` → `fenceWorld retryTrace` | **PASS** 9: `Fence.rateIsWindowMedian` → `poisonedPassTrace` | **PASS** 10: `Rate.acceptanceBoundary` → `delayedAcceptanceTrace` | **PASS** 11: `Fence.graceAtClaim` → `graceTrace` |
| **PASS** 12: `Fence.pauseFundingGrace` → `pausedGraceReturn` | **PASS** 13: `Fence.pausedGraceInFence` → `pausedGraceRace` | **PASS** 14: `Fence.rederiveFirst` → `fundingOrderGuards Fence.current` | **PASS** 15: `Fence.retryDeletes` → `priceFundedStall ++ tail` |
| **PASS** 16: `Fence.retryNeedsFence` → `fenceWorld interruptedRetry;` | **PASS** 17: `Fence.keepWritesDate` → `operatorGuards Fence.current` | **PASS** 18: `Fence.keepGuard` → `keepEligibilityGuards Fence.current` | **PASS** 19: `Fence.retryGuard` → `goneAfterStallTrace ++` |
| **PASS** 20: `Fence.goneOrClosedFirst` → `goneMidOutageTrace` | **PASS** 21: `Fence.noRateWaits` → `freshOutageTrace` | **PASS** 22: `Fence.absentRecordProceeds` → `unrecordedBoundTrace` | **PASS** 23: `Fence.boundReachesAll` → `boundCancellerTrace` |
| **PASS** 24: `Fence.sweepNeedsRate` → `pastDateNoRateWorld` | **PASS** 25: `Fence.extendNeedsRate` → `haltedExtensionTrace` | **PASS** 26: `Restore.quarantineOnRestore` → `Event.startupPass, Event.claim { n := 0 }` | **PASS** 27: `Restore.exceptionFrozen` → `Event.confirmParents, Event.claim { n := 1 }` |
| **PASS** 28: `Restore.bumpOnRestore` → `Event.request 0, Event.completeProcedure` | **PASS** 29: `Restore.twoPassAbsence` → `Event.sweep true false, Event.windowElapses` | **PASS** 30: `Restore.recordDecidesBoot` → `Event.crash, Event.lock` | **PASS** 31: `Reconcile.completePassOnly` → `w.retriedIntoThrottle = false` |
| **PASS** 32: `Reconcile.pastWindowOnly` → `Event.advance 7, Event.sweep true false Answer.notFound` | **PASS** 33: `Reconcile.rereadBeforeAbsence` → `Event.advance 2000, Event.sweep true false Answer.found` | **PASS** 34: `Reconcile.absenceWindow` → `Event.advance 20, Event.sweep true false Answer.notFound` | **PASS** 35: `Reconcile.visibilityFromWaitEnd` → `lateAcceptedWorld` |
| **PASS** 36: `Reconcile.readConfirmsMatch` → `w.orderLanded = some mach` | **PASS** 37: `Ledger.clampAtAuthority` → `seizureBalances` | **PASS** 38: `Ledger.serializedAuthorization` → `skewTrace` | **PASS** 39: `Ledger.appendReadsLatest` → `staleDebitTrace` |
| **PASS** 40: `Funding.keyFrom` → `replayTrace` | **PASS** 41: `Funding.keyFrom` → `bothRailsTrace` | **PASS** 42: `Funding.paymentRecordUnique` → `KeySource.observation` | **PASS** 43: `Funding.correctionPrefix` → `attributionTrace` |
| **PASS** 44: `Funding.reapWaitsForWindow` → `reapTrace` | **PASS** 45: `Funding.usageKeyFrom` → `incrementReplayTrace` | **PASS** 46: `Funding.markDiscards` → `remeterTrace` | **PASS** 47: `Funding.startsAtMark` → `overlapTrace` |
| **PASS** 48: `Funding.seedOnBillable` → `seedTrace` | **PASS** 49: `Funding.exitPosts` → `exitCases Funding.current` | **PASS** 50: `Funding.closeBeforeRelease` → `releaseOrderTail Funding.current` | **PASS** 51: `Funding.prepaidFirstUnit` → `unitTrace` |
| **PASS** 52: `Funding.offsetRequiresDebit` → `unpaidLateSeed Funding.current` | **PASS** 53: `Runway.startAtMark` → `insideTheUnitDate` | **PASS** 54: `Wire.endpointInPreimage` → `deleteOnA` | **PASS** 55: `Wire.closedSummary` → `secretRow` |
| **PASS** 56: `Rescue.coalesceWrite` → `rawInstall lostReplyThenRepeat` | **PASS** 57: `Rescue.markerBeforePhase` → `rawInstall phaseWithoutMarker` | **PASS** 58: `Rescue.secondMarkerBeforeSession` → `Rescue.current rescueSession crashedSession` | **PASS** 59: `Rescue.partialCleanupMovesNothing` → `Rescue.current rescueInstall partialActivation` |
| **PASS** 60: `Rescue.persistAtActivation` → `Rescue.current rescueSession cleanSession` | **PASS** 61: `Rescue.temporaryKeyEligibility` → `Rescue.current rescueSession crashedSession` | **PASS** 62: `Rehost.allowlistRequired` → `emptyAllowlist` | **PASS** 63: `Rehost.allowlistPerHop` → `attackerRedirect` |
| **PASS** 64: `Rehost.schemePerHop` → `schemeDowngrade` | **PASS** 65: `Admission.listenerSplit` → `customerHitsAnOperatorRoute` | **PASS** 66: `Admission.operatorSkipsTenantSteps` → `pendingAttribution` | **PASS** 67: `Admission.stepTwoReadsSuspension` → `suspendedInstall` |
| **PASS** 68: `Admission.maintenanceCarveOut` → `suspendedRevoke` | **PASS** 69: `Admission.statementWhileSuspended` → `suspendedStatement` | **PASS** 70: `Admission.ceilingStep` → `createAtCeiling` | **PASS** 71: `Admission.replayBeforePolicy` → `replayUnderBudget` |
| **PASS** 72: `Admission.haltMintsOnly` → `haltedMint` | **PASS** 73: `Admission.cancelUnsettledInvoices` → `unsettledUnexpiredInvoice` | **PASS** 74: `Admission.exposureExemptUnderHalt` → `exposureReducingUnderHalt` | **PASS** 75: `Admission.sweepRoutesNothingWithoutRate` → `exposureReducingWithoutRate` |
| **PASS** 76: `Admission.solvencyUsesValuedTerms` → `Action.solvencyCheck` | **PASS** 77: `Admission.completeCheckToLift` → `incompletePassingTrace` | **PASS** 78: `Admission.richTailCollection` → `fencedHaltedNoRate` | **PASS** 79: `Admission.offerSaleGuard` → `offerNotSellable` |
| **PASS** 80: `Admission.channelClosureGuard` → `channelClosed` | **PASS** 81: `Admission.reverseDnsCeiling` → `reverseDnsAdmission` | **PASS** 82: `ProviderTraffic.reuseFresh` → `freshClaim` | **PASS** 83: `ProviderTraffic.checkAtClaim` → `queuedRefreshes` |
| **PASS** 84: `ProviderTraffic.preserveAge` → `ageClaim` | **PASS** 85: `ProviderTraffic.successfulOnly` → `failedRefreshes` | **PASS** 86: `ProviderTraffic.reverseDnsNoop` → `establishedPtrNoop` | **PASS** 87: `ProviderTraffic.establishedOnly` → `uncertainPtrNoop` |
| **PASS** 88: `ProviderTraffic.sweepWritesPresent` → `sweepRefresh` | **PASS** 89: `ProviderTraffic.windowAtLeastSweep` → `shortWindowValidation` | **PASS** 90: `Ledger.nativeCostSplit` → `nativeClampTrace` | **PASS** 91: `Period.resetAtBoundary` → `twoPeriodTrace` |
| **PASS** 92: `Period.splitAtBoundary` → `straddleTrace` | **PASS** 93: `Period.deploymentWide` → `lateSubjectTrace` | **PASS** 94: `AccountStatus.retainUnlessTerminated` → `credentialsRejected` | **PASS** 95: `ProviderTraffic.invalidatePtr` → `ptrAfterDifferingDispatch` |

## Handoff limits

The Robot zone and date conversion remain `[verify]`; no live midnight exercise
was authorized. The supplied product-list and Cloud/Robot duplicate-refusal facts
were documented, not reproduced live here. Allowance-offer re-admission and the
PRV-49 future-path discovery/cleanup precondition remain future implementation
and conformance work. These are recorded on `pv-ucs.10` without creating new beads.

After the verification record and tracker sync, the unpiped full gate exited 0:
all seven gates passed, with 799 tagged Lean declarations, 336 conformance items,
no new coverage or citation findings, and four rendered regions matching Lean.
