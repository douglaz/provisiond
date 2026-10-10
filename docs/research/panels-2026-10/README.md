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
| r34 | An overcharge behind the mark; an attachment kind without a bound | pending (Q18) |

r23's fable seat failed on quota; r19's fable and opus seats were relaunched after a session limit.
