1. **Q1 — A.** Return ASCII-edge-trimmed, as-read values for `identifier`, `wwn` and `serial`; normalized-empty values become `null`. Select WWN first, otherwise serial. Normalized output breaks echo: `N("0x0xAB") = "0xab"`, but `N("0xab") = "ab"`.

2. **Q2 — Accept.** Trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`. Thus `0X5000` normalizes to `5000`. I made the whitespace characters explicit.

3. **Q3 — (a).** Add required `name`, such as `"nvme0n1"`, alongside `path`. The proposed minimum now points to the wire field list.

4. **Q4 — Clarify the ambiguity.** `RSC-23` prohibits whitespace “in any config field.” For drives, define that field as the **resolved device path** emitted into installer configuration. The caller’s identifier is resolved beforehand, allowing normalization to trim padding while preserving configuration validation.

5. **Q5 — Amend:** add non-string refusals, repeated-prefix/mixed-case/padded round trips through both strategies, and unchanged fingerprints when devices are reordered or only names/paths change.

6. **Q6 — Applied and checked.** The proposed edits include the settled citation and qualification changes; Lean changes are docstrings only. Full gates exited **0** for [baseline](/var/tmp/provisiond-panel-r61c/sol/.r61c-baseline-gates.log), [amended specs](/var/tmp/provisiond-panel-r61c/sol/.r61c-amended-gates.log), and [restored final specs](/var/tmp/provisiond-panel-r61c/sol/.r61c-final-gates.log).

   **Bad edit:** changed the serial-only example’s `identifier` to `null`, leaving its serial present. **No gate went red:** the [bad-edit run](/var/tmp/provisiond-panel-r61c/sol/.r61c-negative-gates.log) also exited **0**. The gates missed that semantic contradiction. I restored the correct example before the final run.

7. **Q7 — Strongest argument against A (requested):** normalized output hides changes in case or prefix spelling and exposes the values used in hashing. A exposes multiple spellings of one identity and makes callers distinguish presentation from comparison. B would be simpler if normalization were idempotent.