# Panel records, 2026-10-06/07

The four-reader panels behind `ADR-0033`..`ADR-0039`, copied from the machine-local directories they
ran in (`/var/tmp/provisiond-panel-rNN/`). Each directory holds the brief, every reader's answer
(fable and opus: Claude; astra and sol: Codex) and the orchestrator's synthesis, whose citations
were checked against the files. The answers are evidence, not requirements; their file links point
into the throwaway clones each reader worked in.

| Round | Question | Decision |
|---|---|---|
| r18 | Who pays the rest of a provider's started billing unit | superseded by r19 |
| r19 | Threat model for provider rounding and shared provider budgets | `ADR-0033`, `ADR-0034` |
| r20 | A failed read after an accepted create | `ADR-0035` |
| r21 | The Robot order budget | `ADR-0036` |
| r22 | Whether `billing_stop_window` should exist | `ADR-0037` |
| r23, r24 | What a network-restriction flag can establish | `ADR-0038` |
| r25 | Provider traffic overage | `ADR-0039` |

r23's fable seat failed on quota; r19's fable and opus seats were relaunched after a session limit.
