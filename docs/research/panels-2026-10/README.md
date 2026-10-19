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

r23's fable seat failed on quota; r19's fable and opus seats were relaunched after a session limit.
