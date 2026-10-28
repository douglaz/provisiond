Reviewed the printed r77 packages against `1fc54e8f361e4a9342359388314d32c398595f62`. Saved [astra.draft.md](/var/tmp/provisiond-panel-r77/astra.draft.md). No tracked source changed.

1. **Q1: Y-WIDE — CANNOT ACCEPT; Y-PROV — CANNOT ACCEPT. Final preference: NONE.**

My objection concerns the common package’s promised nested-restore scope, not its Boolean or wire tables.

The proposed STO-54 paragraph requires initialization in “the acknowledged transaction that establishes the restore record” and says: “Another actual restore applies the initialization again, including when an earlier incident was still open.” However, [STO-56](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/05-persistence.md#L1374) specifies “One row per restore”, “at most one row may have `closed_at` null”, and “The operator MUST NOT close the record until” its listed conditions hold, including “`grace_ends_at` has passed”.

Concrete trace: incident A completes step (3); a fresh install is admitted; a backup contains that row and A’s open record; before A’s grace ends, another actual restore lands that backup. Establishing a new open record B conflicts with the partial unique index. Closing A to make room violates the quoted restriction. Reusing A silently abandons “One row per restore” and retains procedure marks; STO-54 says “A marked step does not run again”. Deleting or superseding A requires a policy absent from both packages. I found no such procedure in the owning requirements or relevant ADRs.

This is an inherited lifecycle gap exposed by the explicitly promised scope, not a newly refuted baseline theorem. The Boolean update works **conditional on successfully establishing the appropriate restore record**; that condition remains unresolved here. I cannot supply an unstated supersession mechanism as package acceptance. No exact Q1 repair is offered: supersession policy or an explicit scope restriction needs its own complete form and owner decision.

The remaining provenance mechanics are coherent:

- Initialization precedes either component’s startup and shares the record transaction. It covers the proposed surviving-status set, including existing reconciliation rows.
- Repeating `true` during another actual restore is idempotent. Successors do not repeat initialization; closure and purge do not revive trust.
- Y-PROV’s “Whether the incident is still open does not itself invalidate markers of newly admitted work” distinguishes process death from rollback. Y-WIDE deliberately chooses incident scope instead; its concealment of fresh facts is disclosed.
- WIR-9a says `destructive_boundary_crossed` “does not assert that the install completed”. Neither package turns surviving facts into automatic settlement.
- “Unknown rescue exit retains the address-and-port requirements above” preserves companion fields. Rescue inventory receives no `disk_effect`; provenance survives outside `request_summary`.

**Separate costs:** both require a pre-start bulk update over surviving unsettled install/inventory rows, with transaction, WAL and recovery-delay costs. Conservative legacy initialization can conceal additional retained facts; that is expressly new policy. Y-WIDE additionally conceals valid fresh facts and writes provenance during transitions. Y-PROV requires preserving the distinction correctly. I found no additional hidden baseline wire loss. No migration, latency measurement or runtime conformance test was run.

2. **Q2: M-S — AMEND; M-I — ACCEPT. Final preference: M-I.**

Both transition designs preserve conforming behavior. The old `passDone` gate protected completion of the running-row sweep before claims. M-S changes its mutant meaning to completion of handling without that sweep; changed metadata and later progress are intentional. Its CI integration nevertheless needs the amendment below.

The existing [harness](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/.github/workflows/ci.yml#L917) rejects other than one error, reporting “more than one red”. M-S preserves `successor_sweeps_power` and adds another positive witness using `startupPassGuards/current`. Flipping the current pass guard therefore refutes both. My targeted probe produced both `decide`-false errors. Updating only the comment/trace token does not fix the harness’s acceptance criterion.

M-I preserves the original model, negative witness and control. Its separate global guard contains no selected-row predicate or desired outcome. False/false is honestly a two-guard countermodel. All-state equality with `requirePass=true` holds even with the pass guard false, preserving the original blocked-claim case.

**Checks actually run:** the printed scratch file compiled unchanged, exit 0. Additional proofs extended both step equalities to arbitrary event lists and transported `successor_sweeps_running` to `runS` with its original hypothesis and conclusion. These proofs report only `propext` and `Quot.sound`. I also checked the amended old S witness and the power/mark cells omitted from the shorter printed I examples.

| Model / guards | Old create 4; power 3 | Fresh create 5 | `passDone` |
|---|---|---|---|
| Original, pass=false | running; running | queued, unapplied | false |
| S, pass=false | running; running | running, applied | true |
| S, pass=true | needs_reconciliation; needs_reconciliation | running, applied | true |
| I, pass=false, require=true | running; running | queued, unapplied | false |
| I, pass=false, require=false | running; running | running, applied | false |
| I, pass=true, require=false | needs_reconciliation; needs_reconciliation | running, applied | true |
| I, pass=true, require=true | needs_reconciliation; needs_reconciliation | running, applied | true |

Targeted assertions failed with `decide` proving them false: S’s good sweep assertions under the mutant; I’s later-work assertion after restoring `requirePass`; I’s stranded-row assertion after restoring the sweep; and retaining the old blocked-claim result under S. The original blocked cell has not been relabelled as later work.

My first extended probe failed because I incorrectly qualified `OperationId` as `Provisiond.Claim.OperationId`. Correcting it to `Provisiond.OperationId` produced exit 0. That was my probe error, not a candidate defect.

Both required unpiped repository gates passed. Full integrated-package builds, the complete CI mutation job and runtime conformance were **not run**. Evidence includes the [extended probe](/var/tmp/provisiond-panel-r77/astra/.panel/probe.lean), [two-refutation log](/var/tmp/provisiond-panel-r77/astra/.panel/S_two_reds.log) and [final gate log](/var/tmp/provisiond-panel-r77/astra/.panel/final-gate.log).

3. **Brief defects.**

I found no verified factual error changing either question’s premise. The record-lifecycle omission affects both Q1 votes; the omitted CI error-cardinality adjustment affects M-S. Neither changes fresh-work reachability or the original model’s blocked-claim premise. The printed probe receipt is corroborated by my compile.

Neither question is void on my findings: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

4. **Internal consistency.**

The marker tables and candidate transitions produce their stated cells. Alternative policies are not simultaneous obligations.

The unresolved conflicts are the nested-restore promise against STO-56’s quoted record constraints, and M-S’s additional current-dependent positive witness against the existing one-error CI check. I found no evidence that the original theorem becomes unreachable or vacuous: the S counterexample still strands power, and conforming all-state equivalence transports its guarded theorem.

5. **Requested counterarguments, separate from votes, and repair.**

Against my **Q1 nonacceptance**: the lifecycle gap predates these packages, and the provenance update remains conservative. Isolating a separate lifecycle repair could let the wire decision proceed. Nevertheless, I cannot treat the explicitly promised nested case as complete.

Against preferred **M-I**: it duplicates claim logic and needs two disabled guards for the composite harm. Repaired M-S is smaller and represents a plausible single decision to skip the sweep while continuing startup.

**Exact M-S repair — behaviour changed for CI acceptance; conforming model behaviour unchanged.** Location: M-S’s CI sentence.

Before:

> The existing negative control still flips only passEveryStartup and must reject the positive sweep assertions; extend its owned CI comment/trace evidence to mention the new progress pair without removing the old control.

Replacement:

> Name the new positive progress witness `successor_sweeps_and_progresses`. Keep the existing control’s single mutation of `Restore.current.passEveryStartup`. For that control, replace the harness’s exactly-one-error rule with a check that the complete set of refuted witness declarations is exactly `successor_sweeps_power` and `successor_sweeps_and_progresses`. Require each error to be a `decide` refutation, verify the respective `postStepTwoPower` and `progressTrace` evidence, and reject missing, additional or non-refutation errors. Keep the exactly-one-error rule for every other existing guard control. Extend the owned CI comment accordingly; retain the old witness and control.

This repaired form is not accepted by this vote and needs a complete-form reading.

I have not tallied other seats. Apply the exact settling rule: “a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”, together with the unchanged no-verified-blocking-loss condition. Policy/cost decisions and ties remain the owner’s; no implementation or follow-on round is approved.