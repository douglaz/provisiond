# Panel records, 2026-10-06/07

The panels behind `ADR-0033`..`ADR-0039`, copied from the machine-local directories they
ran in (`/var/tmp/provisiond-panel-rNN/`). Each directory holds the brief, every reader's answer
(fable and opus: Claude; astra and sol: Codex) and the orchestrator's synthesis, whose citations
were checked against the files.

**The readers' answers are kept verbatim, including claims a later round or the synthesis
corrected.** They are evidence of what was argued, not requirements: the synthesis records what
was verified, and the ADR records what was decided. Their file links pointed into throwaway clones;
they now point at the same files at the commit each clone was taken from, so line numbers stay exact.
Two of Sol's r18 links named ADR files that never existed and now point at the real ones.

| Round | Question | Decision |
|---|---|---|
| r18 | Who pays the rest of a provider's started billing unit | superseded by r19 |
| r19 | Threat model for provider rounding and shared provider budgets | `ADR-0033`, `ADR-0034`; background to `ADR-0036` |
| r20 | A failed read after an accepted create | `ADR-0035` |
| r21 | The Robot order budget | `ADR-0036` |
| r22 | Whether `billing_stop_window` should exist | `ADR-0037` |
| r23, r24 | What a network-restriction flag can establish | `ADR-0038` |
| r25 | Provider traffic overage | `ADR-0039` |
| r26 | Whether a failed refresh counts toward the per-machine bound | `ADR-0034` amendment of 2026-10-08 |
| r27 | What a driver reports when it cannot tell acceptance | `ADR-0035` amendment of 2026-10-08 |
| r28 | Placing two new create refusals in the purchase tail | `ADR-0030` amendment and `ADR-0036` correction of 2026-10-09 |
| r29 | Wind-down's latency composition; a scheduled attachment release | `ADR-0037` amendments of 2026-10-09 (Q13, Q14) |
| r30 | A network restriction's provenance after an operator-only withdrawal | `ADR-0038` clarification of 2026-10-09 (Q15) |
| r31 | Auction identity resolution; temporary-key lifetime | `ADR-0040` (Q16) |
| r32 | Startup validation; a create queued behind a closure; a lost offer claim | `ADR-0036` amendment of 2026-10-10 (Q17) |
| r33 | Which instant an operator's restriction record shows | `ADR-0038` clarification of 2026-10-10 (Q15b) |
| r34 | An overcharge behind the mark; an attachment kind without a bound | `ADR-0037` amendment of 2026-10-10 (Q18a) |
| r35 | Review of the proposed attachment-bound fix (`q18a.txt` is the accepted Q18a text it was briefed with) | `ADR-0037` amendment of 2026-10-10 (Q18b) |
| r36 | pv-ucs.2: continuations versus the reserve; operator traffic; the refusal surface (`manager-blocker.md` is the Run report it answers; fable.md was recovered from its session log) | `ADR-0034` amendment of 2026-10-10 (Q19) |
| r37 | Robot's per-endpoint request limits in v1 (`q19.txt` is the accepted Q19 text it was briefed with) | `ADR-0034` amendments of 2026-10-10 (Q20) and 2026-10-11 (Q20b) |
| r38 | pv-ucs.4: an attachment left unrecorded when the listing never runs | test first (Q21) |
| r39 | pv-ucs.4 after the live Robot test (`live-result.txt`, the runner's summary lines; one pre-existing server's number redacted) | `ADR-0037` amendment of 2026-10-11 (Q21) |
| r40 | What a Robot `now` delete settles as; the zone of a day-only date (`zone-check.txt` is the 2026-10-11 Berlin-midnight verification; `q21.txt` is the accepted Q21 text it was briefed with) | `ADR-0037` amendment of 2026-10-11 (Q22) |
| r41 | Branch-review questions: a failed read-back's tail; `LDG-32`'s cap versus `PRV-49`; the instant of an earliest cancellation date (`fable.md` is the usage-limit failure; three readers answered) | `ADR-0037` amendment of 2026-10-11 (Q23a–c) |
| r42 | Who deletes a successful create's temporary key, and when (`manager-blocker.md` is the pv-ucs.10 Run report it answers; three readers, fable not run) | `ADR-0040` amendment of 2026-10-11 (Q24) |
| r43 | A still-future earliest cancellation day near midnight (`manager-blocker.md` is the pv-ucs.10 Run report it answers; opus.md recovered from its session log) | `ADR-0037` amendment of 2026-10-11 (Q25) |
| r44 | Operation retention versus the provisioning guard on a temporary key (`manager-blocker.md` is the pv-ucs.10 Run report it answers) | `ADR-0040` amendment of 2026-10-12 (Q26) |
| r45 | Q23a after Robot's server-read counter proved account-wide; with the 2026-10-12 live sessions 2–4 (read limit, rescue V10/V11, rescue host keys, IP scope; one pre-existing server's number and IP and the rescue passwords redacted) | `ADR-0037` amendment of 2026-10-12 (Q28); `ADR-0041` (Q27) |
| r46 | Telling a fresh Robot last-rescue record from a stale one (`manager-blocker.md` is the pv-wd0 Run report it answers) | `ADR-0041` (Q29) |
| r47 | What remains of the formal layer (`pv-vwe`'s seven unwritten candidates) and `pv-erp` (`evaluation.md` is the sub-agent read under review) | owner decision Q30: five formal follow-ups, `pv-vwe` closed |
| r48 | Q31: keep or drop Robot's post-order cancellation read (`PRV-13c`), raised by the branch review before the robot-live PR | owner decision Q31: keep it as one attempt at settlement with an absorbed failure (`ADR-0037`, 2026-10-14) |
| r49 | Q32: when may a theorem assume a guard is on (`ADR-0025`), raised by the branch review | owner decision Q32: a hypothesis `current` satisfies is not a weakening; one added to an existing theorem must be needed and cite its refuting witness (`ADR-0025`, 2026-10-14) |
| r50 | Q33: which presented host key a Robot session may accept when the caller also supplied keys (`RSC-3`, `WIR-20`, `PRV-20`), raised by `pv-f6g` | owner decision Q33: only a key in both sets (`ADR-0041`, 2026-10-14); refusing caller keys for Robot deferred to the double-rescue test |
| r51 | Q31's alarm: should a non-rate-limit failure of Robot's post-order read raise an alarm, raised by the second branch review | owner decision: no new alarm; `ADR-0037` Q31's wording corrected to "where its trigger applies" (2026-10-15) |
| r52 | Q34: the PR #3 codex finding that Robot's one-shot post-order read is not crash-recoverable | owner decision Q34: the pass whose landed-order transaction commits makes the one read; operator attach writes null; `LDG-33` prices the declared bound where the date is null (`ADR-0037`, 2026-10-15) |
| r53 | `pv-d21` triage: what `machines.declared_cancellation_bound` holds on rows from before the column, and whether a create queued by an older `api` fails under `OPS-23` | owner decision: `pv-d21` closed `wontfix` as unreachable (no deployment can hold such a row or snapshot); what `OPS-23`'s repeated sale check reads filed as `pv-hsm` (2026-10-16) |
| r54 | `pv-hsm` triage: what the worker's repeated sale check reads before dispatch, the create's offer snapshot or the provider's current offer (`PRV-31`, `PRV-13b`) | owner decision: re-test sellability against the current offer and descriptor at claim, homed in `OPS-43` (order: channel closure, List offers, sellability, price, key upload), `CNF-241` extended, a pointer in `OPS-23`; `pv-hsm` `ready-for-agent`; the offer-reported cancellation-bound field gap filed separately (2026-10-16) |
| r55 | `pv-14b` triage: where `OPS-43`'s claim order places the account check, `OPS-23`'s re-validation and `PRV-47`, and what an offer absent from the claim-time List offers result fails with; round r55b (`r55/r55b/`) settled `OPS-23`'s missing-field kind | owner decisions: a plain `STO-47` read first in the claim order; `conflict`/`incomplete_record` for an `api`-written field and `invalid_request` for a caller-supplied one; the absent offer homed in `API-7`'s create-tail verdict, which `OPS-43` refers to; `pv-14b` `ready-for-agent`; `pv-tcs`, `pv-xer` and `pv-p3k` filed (2026-10-17) |
| r56 | `pv-k4l` triage: whether a create interrupted before `OPS-43`'s step 8 may settle `failed` at startup, and what records that step 8 committed; round r56b (`r56/r56b/`) took the 2-2 splits on the record's shape, the ADR and pv-qga's dependency; round r56c (`r56/r56c/`) took the view's `retryable` when `OPS-16` keeps a recorded error (PR #7 review) | owner decisions: a new column `operations.about_to_order_at` written in `OPS-43`'s step 8 and read only when null by a new `OPS-15` restart exception (`failed`, `internal`, `retryable: true`, released under `LDG-39`); a new `ADR-0042` amending `ADR-0016`; `pv-qga` related, not blocking; `pv-k4l` `bug` + `ready-for-agent`; the standby-promotion gap filed separately (2026-10-17) |
| r57 | `pv-qga` triage: whether a create failure recorded before any provider mutation must park under `OPS-11`'s ambiguity list | owner decision (option 1): a create failure the worker records before any step-9 request settles `failed` by worker position, keeping its kind with `retryable: true`; a cancellation stays a cut-off `conflict`; `ADR-0043`; `pv-qga` `bug` + `ready-for-agent`; `pv-9j6` and `pv-f7a` filed (2026-10-18) |
| r58 | `pv-tst` triage: whether a cancelled `execute` must record its outcome or may exit and leave the row to `OPS-15` | owner decision: recording (A, 4-0), for every operation kind, with pv-f7a folded in and `OPS-21`'s exception widened to install before the disk and refresh; round r58b (`r58/r58b/`) took A's size (2-2 on a new bound, Lean and `ci.yml`), the cancelled parent's sentence (4-0 yes) and pv-f7a's reason value (2-2); owner decision 2: the larger shape, a new `OVR-19` stop-record limit with a Lean model and `ci.yml` controls; owner decision 3: reason value `cut_off`; `pv-tst` `bug` + `ready-for-agent`, `pv-f7a` closes with it; round r58c (`r58/r58c/`), from the pv-tst review, took a stop during `OPS-49`'s retry loop inside `execute`: 2-2, record (Y) against exit (X); owner decision 4: Y (2026-10-18) |
| r59 | `pv-zbp` review: whether a stop the engine survives during `PRV-13c`'s post-order read is a cut-off `conflict` (the branch's `OPS-21`, `CNF-362`) or a failed read that leaves the settlement `succeeded` with a null date (`PRV-13c`, `CNF-356`); whether that also decides `pv-ilb` | 4-0 for (a), absorbed as a failed read; pv-ilb 3-1 (opus: its own text); owner decision (option 1): (a) for both reads, `OPS-21` and `CNF-362` amended, `pv-ilb` closed with `pv-zbp`; no r59b (2026-10-19) |
| r60 | `pv-1wn` review: whether `CNF-202`'s case, a caller's create still `queued` and never claimed when `API-58` step (4) runs, can be set up on a conforming engine under `OPS-6`'s oldest-first claim; which fixture the case uses; whether create reachability is a spec gap | 4-0 for (a), a power operation held `queued` behind a running operation by `OPS-8`; create reachability 4-0 a real gap; owner decision: (a), the case holds a power operation behind a running power operation, and create reachability is `pv-kv2` (needs-triage) (2026-10-21) |
| r61 | `pv-6p8` triage: what `rescue_inventory` returns for a disk with no serial and no WWN; rounds r61b–r61f (`r61/r61b/` … `r61/r61f/`) took the fingerprint order, admission, the qualifiers, the Lean scope and the test (r61b), the wire form and normalization (r61c), `RSC-23`'s scope and `name` (r61d, 2-2 on `name`), and `name` again (r61e, r61f) | r61 4-0 for option 1, `identifier: null`, the disk kept in `devices` and the fingerprint; owner decision: "Yes, in this bead": each device also shows `wwn` and `serial` and `RSC-33` names both; owner on `name`: "Try to get a consensus", reached 4-0 in r61f: no `name` field; the reviewed form is `r61/r61d/final-form.md` (2026-10-22) |
| r62 | Panel B triage of `pv-p3k` (`allow_orders` has no error kind), `pv-009` (the claim-time `list_offers` gate), `pv-gpw` (a present value that fails claim-time validation), `pv-ss4` (the wire form of naming a field) and `pv-7j3` (`WIR-48`'s refusal reason); rounds r62b–r62f (`r62/r62b/` … `r62/r62f/`) took the drafted text (r62b), the remaining checklist and stale-wording items (r62c), the reader-worded folds and the tie-break's scope (r62d, 2-2 on scope), `API-40`'s conflict rationale (r62e, both rewordings 0-4) and its deletion (r62f) | r62: Q1 (`pv-p3k`), Q4 (`pv-ss4`) and Q5 (`pv-7j3`) 4-0, Q2 (`pv-009`) 3-1 for a gate at step 4, Q3 (`pv-gpw`) settled in r62b 4-0; owner decisions (2026-10-22): `pv-p3k` "MUST, not retryable", B6 "Yes, any unhealthy", the tie-break's scope "Wide: all four ops"; r62f 4-0 to delete `API-40`'s rationale; the reviewed form is `r62/final-form.md`, its exact text `r62/final-form.patch` (2026-10-22) |
| r63 | Panel C triage of `pv-s4m` (a promoted asynchronous standby can lose committed writes, and no text says whether bringing the engine up on it is a restart or a restore, `STO-5`, `STO-54`) and `pv-n98` (whether a successor runs `OPS-15`'s pass over `running` rows while a restore record is open); rounds r63b–r63h (`r63/r63b/` … `r63/r63h/`) took the confirmation read of both forms (r63b), their last read (r63c), Q1 re-formed under synchronous replication (r63d, r63e), the stop and the new-connection check (r63f), an external review (r63g) and what r63g left open (r63h) | owner decisions (2026-10-23): Q2 "Clean up every startup", form F′ (`r63/r63c/forms-final.md`); Q3 "One Run, one PR"; Q1 "I think we should just suppose synchronous replication", which superseded r63c's form S′; then S2′ "A: stop on time (Recommended)", S3 "B: check each new connection (Recommended)", P "Wait (Recommended)", F "Check again (Recommended)"; the chosen form is `r63/r63h/forms-chosen.md`, with r63c's F′ (2026-10-23) |
| r64 | Panel D triage of `pv-buc` (losing the startup-lock connection during a stop's record has no stated exit, `OPS-47`, `OPS-21`) and `pv-9j6` (`OPS-45` settles a pre-dispatch power, reverse-DNS, delete or release failure `failed` while `OPS-11`'s last row ignores the marker); round r64b (`r64/r64b/`) took `pv-buc`'s two exact forms, R (record first) and E (exit at once), and a confirmation read of `pv-9j6`'s merged form M with the optional clauses [P] and [Q] | r64: `pv-buc` split 2-2 on behaviour, labelled owner; `pv-9j6` 4-0 for the guarded behaviour; separate Runs 4-0; r64b: `pv-9j6` 4-0 for M, [P] 4-0 in, [Q] 0-4 out; owner decision (2026-10-23): "Yes, settle failed (Recommended)" (`ADR-0046`); `pv-buc` continues in round r65, not recorded here (2026-10-23) |
| r65 | Panel D, `pv-buc` only: R (record first, merged with r64b's fixes) against E (exit at once, completed), and two fences, G and A; round r65b (`r65/r65b/`) read R and E with the fixes, and both fences | r65: E 4 ACCEPT, R 3 ACCEPT and 1 verified blocking CANNOT ACCEPT confined to R's new test item, R picked 4-0, owner question; r65b: R picked 4-0, Fence G 4-0 adopt in principle (its sketch not sound, so its text needs its own round), Fence A 4-0 don't adopt and moot under G; owner decisions (2026-10-24): R "Yes, R (Recommended)", Fence G "Adopt; one combined Run", Fence A dropped (2026-10-24) |
| r66 | Panel D, `pv-buc`: Fence G's text, and R read with G; rounds r66b–r66e (`r66/r66b/` … `r66/r66e/`) read G and R merged with a `STO-13` rollback question (r66b), drafts of an app-side restore check, the F1-F9 fixes and the D1-D4 drop (r66c), four restore guards (r66d) and R + G combined, a final confirmation read (r66e) | r66: G 0-4, R with G 0-4 clean, another round; r66b: merged G 1-3 (the restore window precedes the fence), R with G 4-0, rollback 3-1; owner: "Draft 2) using the panel and assess complexity", and on the rollback "Us this scenario real? The project isn't built yet" (dropped); r66c: three drafts, owner question, F1-F9 4-0, the drop 4-0; owner: "try to reach a consensus"; r66d: a 2-1-1 split; owner: "I don't think we should tolerate a gross operator mistake like restoring some backup with the system running"; r66e: 4-0 ACCEPT; owner on span 19: "Drop it (Recommended)" (`ADR-0047`) (2026-10-24) |
| r67; follow-up rounds [r68](r67/r68/), [r69](r67/r69/), [r70](r67/r70/), [r71](r67/r71/), [r72](r67/r72/) and [r73](r67/r73/) | Panel E: `pv-tcs` admission offer source and listing age; `pv-ytv` fingerprint evidence on a `correlator: none` Robot channel | [Owner and main decisions](r67/owner-decisions.md); reviewed Form H in [r73/tally.md](r67/r73/tally.md); exact H, K1–K6 and original K-d in [r73/run-input.md](r67/r73/run-input.md) |

r23's fable seat failed on quota; r19's fable and opus seats were relaunched after a session limit. r63h's astra seat ran twice; the first run failed. r66e's readers were labelled a–d; its notes.md maps each label to a reader, and each answer is filed under its reader's name.

Panel E records retain the reader labels and answer text, including arguments superseded by later rounds. Clone-file links name the frozen base on GitHub. Machine-local verification receipts, raw logs, clones and scratch trees remain under `/var/tmp`; they are not part of this archive. r73 retains the replacement fable/opus answers; its tally records the failed session-limit attempts.

## Panel A and B records, 2026-10-28

| Rounds | Questions | Archived decision records |
|---|---|---|
| [r74–r76](r74/STATE.md) | pv-c7vg, pv-3jw6, pv-oehp, pv-1i3n | [Owner decisions](r74/owner-decisions.md); [application briefs and drain plan](r74/decisions/plan.md) |
| [r77](r77/STATE.md), [r77b](r77/r77b/STATE.md) | pv-8mt4, pv-ymjo | [Owner decision for pv-8mt4](r77/owner-decisions.md), adopting the printed M-I package in [the reviewed brief](r77/brief.md); [pv-ymjo tally](r77/r77b/tally.md) and [recorded owner question](r77/r77b/owner-question.md) |

The [r77b state](r77/r77b/STATE.md) and recorded owner question retain the decision status at
that snapshot. The linked owner records supersede historical owner-pending wording for the decided beads. Panel records
preserve their original STATE, notes, briefs, reader answers and tallies, including claims corrected
in later rounds. These records document deliberation; the requirement owners hold the rules.
Specification links in these answers name the frozen review base. Scratch and verification
references retain their original machine-local paths; those artifacts stay outside the archive.

## Panel B decision and Panel C records, 2026-10-28

| Rounds | Questions | Decision/status sources |
|---|---|---|
| [r77b](r77/r77b/STATE.md) | pv-ymjo | [Owner decision](r77/owner-decisions.md), adopting P with the verified wording repairs in [the tally](r77/r77b/tally.md); the bead carries the application brief |
| [r78](r78/STATE.md) | pv-kwuf | [Owner decision](r78/owner-decisions.md), adopting K-EXACT in [the brief](r78/brief.md) with only R1 in [the tally](r78/tally.md); the bead carries the application brief |
| [r78b](r78/r78b/STATE.md) | pv-75w3 | [Tally](r78/r78b/tally.md) and [next-step record](r78/r78b/STATE.md#next-step); awaiting the owner and not ready-for-agent at the recorded snapshot |

The owner records above supersede historical owner-pending wording for pv-ymjo and pv-kwuf.
The records preserve STATE, notes, briefs, reader answers and tallies at this snapshot; the
r78b tally and its conditional dissent remain on record. Clone specification links name the
frozen review base; scratch and verification paths retain their original machine-local paths.
Raw logs and clones remain outside the archive. The requirement owners hold the rules.

## Panel C decision and Panel D0 settlement, 2026-10-28

| Round | Question | Decision/status sources |
|---|---|---|
| [r78b](r78/r78b/STATE.md) | pv-75w3 | [Owner decision](r78/owner-decisions.md#pv-75w3), adopting only S-STOP-R S1–S4 in [the reviewed brief](r78/r78b/brief.md), with S3's actual-landing-date substitution; [tally](r78/r78b/tally.md) |
| [r79](r79/STATE.md) | pv-3jw6 source timestamp allowance | [Tally and E-KEEP settlement](r79/tally.md); [rounding-question record](r79/rounding-open.md); [existing owner decision](r74/owner-decisions.md) and [unchanged application brief](r74/decisions/pv-3jw6.md) |

The linked pv-75w3 owner decision supersedes the earlier snapshot's owner-pending status.
The r79 records preserve the STATE, notes, brief, reader answers and tally, including proposed
repairs that were not adopted. Specification links name the frozen review base; scratch,
draft and verification references retain their machine-local destinations. Raw logs and clones
remain outside this archive. The requirement owners hold the rules.

## PR #35 wording review, 2026-10-28

| Round | Question | Settlement source |
|---|---|---|
| [r80](r80/brief.md) | permitsI documentation wording | [Tally](r80/tally.md); fixed [reading rules](r80/notes.md) and reader answers are retained with the reviewed brief |

The records preserve the review at its frozen base. Specification links name that base;
raw logs, clones and verification receipts remain under `/var/tmp`. The requirement owners hold the rules.

## Restore retry clock and conformance reviews, 2026-10-28

| Round | Question | Settlement source |
|---|---|---|
| [r81](r81/brief.md) | Restore-establishment retry clock | [Tally](r81/tally.md); fixed [reading rules](r81/notes.md), reader answers and exact option files are retained |
| [r82](r82/brief.md) | Retry conformance paragraph and insertion-condition wording | [Tally](r82/tally.md); [exact paragraph and landing](r82/check/cnf-case.md), fixed [reading rules](r82/notes.md) and reader answers are retained |

The records preserve the review at its frozen base, including dissent and unadopted proposals.
Specification links name that base; links to omitted scratch, raw logs and launch receipts retain
their machine-local destinations under `/var/tmp`. The check files retain the exact reviewed
forms and source comparisons. The requirement owners hold the rules.

## Supplementary historical records

The following machine-local panel files are retained verbatim as historical supporting material.
The amendment excerpts and proposed bead are archived drafts; requirement owners and decision
records remain at their existing homes.

| Round | Supporting record |
|---|---|
| r48 | [Q31 amendment excerpt](r48/adr-0037-q31.md) |
| r49 | [Q32 amendment excerpt](r49/adr-0025-q32.md) |
| r50 | [Q33 amendment excerpt](r50/adr-0041-q33.md) |
| r62 | [Manager's source-check notes](r62/notes.md) |
| r63 | [Proposed WIR-48 coverage bead](r63/bead-wir48.md) |

## Supplementary reading and handoff records

These historical supporting records complete the archived material listed below. They retain
superseded launch instructions and proposals; the requirement owners and decision records
hold the current rules. The reader-specific r66d briefs carry their original seat preambles
and the same common packet as the archived r66d brief. Raw logs and clones remain outside
this archive.

| Round | Supporting records |
|---|---|
| r62c–r62f | [r62c notes](r62/r62c/notes.md), [r62d notes](r62/r62d/notes.md), [r62e notes](r62/r62e/notes.md), [r62f notes](r62/r62f/notes.md) |
| r66d | Reader-specific briefs: [fable](r66/r66d/brief-fable.md), [opus](r66/r66d/brief-opus.md), [astra](r66/r66d/brief-astra.md), [sol](r66/r66d/brief-sol.md) |
| r66e | [Run handoff](r66/r66e/run-inputs.md) |
