**Q1 — A.** Return the WWN as read, otherwise the serial, trimmed of ASCII whitespace; return `null` when neither survives normalization. Use the same representation for `wwn` and `serial`. The counterexample holds: `N("0x0xAB") = "0xab"`, but `N("0xab") = "ab"`. Preserve original request values through admission so validation cannot introduce the same double-normalization bug.

**Q2 — Accept.** Trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`. Specify whitespace as U+0009–U+000D and U+0020. Normalize original inputs once.

**Q3 — (a).** Add `name`, illustrated as `"nvme0n1"` alongside `path: "/dev/nvme0n1"`. Assuming the owner’s yes, add nullable `wwn` and `serial`; include WWN in the inventory minimum.

**Q4 — Clarify now.** Make the whitespace restriction explicitly govern generated installer configuration fields. Identifiers are lookup inputs; only validated resolved paths enter installer drive fields. This accepts padded identifiers without relaxing configuration safety.

**Q5 — Amend:** require otherwise-admissible fixtures with unique chosen identifiers; add name/path presence, `0X5000`/`0x0xAB` and padded echo cases for both strategies, non-string and bare-`0X` refusals, and fingerprint invariance under device reordering.

**Q6 — Applied and checked.** The clone contains these edits and the settled citation/docstring qualifications. Lean declarations and `CNF-47`, `CNF-192`, and `CNF-206` remain unchanged. Baseline, edited, and restored-final full suites each exited **0**. Planting the stale quote “the device list sorted by identifier” made citations exit **1**, reporting a Lean quotation found nowhere. The mutation was restored. [Final gate log](/var/tmp/provisiond-panel-r61c/astra/panel-final.log); [negative-control log](/var/tmp/provisiond-panel-r61c/astra/panel-negative.log).

**Q7 — Strongest argument against A:** normalized wire values provide one canonical representation, avoid casing/prefix churn, and simplify fingerprint reconstruction. That is attractive, but requires an explicitly idempotent normalization rule to make echoed identifiers reliable; stripping one prefix does not provide one.