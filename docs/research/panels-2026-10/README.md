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

r23's fable seat failed on quota; r19's fable and opus seats were relaunched after a session limit.
