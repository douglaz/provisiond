# pin pv-by1w

The T-WAIT trace leaves the promoter unable to tell whether the old primary had a waiting backend cancelled or terminated once that primary and its logs are lost. The surviving standbys can report the same WAL ends both when this happened and when it did not. Equal standby reports therefore do not supply the missing history. The audit establishes no compliant loss of an acknowledged commit.

STO-54's historical classification arm on master says:

> Any other promotion —
>   without both standbys' report, with a report on another timeline, or of a standby whose reported end is behind the other's, of a standby `STO-7` does not name, or after the primary committed without one of them, served a component before it had caught
>   up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
>   `STO-56`'s record is committed into the promoted store before either component is started.

Audit sections:

- [T-WAIT](https://github.com/douglaz/provisiond/blob/c7be186d50b09f5e84ea4aeeffa0c3a4b4230b35/docs/research/promotion-action-history-audit-2026-10.md#t-wait): the trace and knowability gap.
- [C-WITNESS](https://github.com/douglaz/provisiond/blob/c7be186d50b09f5e84ea4aeeffa0c3a4b4230b35/docs/research/promotion-action-history-audit-2026-10.md#c-witness): candidate durable evidence outside the primary's failure domain.
- [C-UNKNOWN](https://github.com/douglaz/provisiond/blob/c7be186d50b09f5e84ea4aeeffa0c3a4b4230b35/docs/research/promotion-action-history-audit-2026-10.md#c-unknown): candidate handling when the relevant history cannot be established.

Triage chooses among C-WITNESS, C-UNKNOWN, and neither. No outcome is recommended here. Both proposals remain candidates; nothing is adopted and this bead authorizes no specification, ADR or conformance change.

