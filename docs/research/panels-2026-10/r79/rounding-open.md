# pv-3jw6 — open timestamp-rounding question

Status (2026-10-28 ~15:00 UTC): SETTLED E-KEEP by Panel D0 r79 (/var/tmp/provisiond-panel-r79/tally.md; ACCEPT opus/astra/sol, AMEND fable/grok). UO stays as adopted; pv-3jw6 released to the drain.
Earlier status: OPEN; no substantive decision made by PR #31's manager. Main is routing this question to a five-reader panel before pv-3jw6's implementation Run. No bead, specification, or archived panel record was changed for it.

Finding: https://github.com/douglaz/provisiond/pull/31#discussion_r4401037001

Archive: `docs/research/panels-2026-10/r74/r76/q2-UO.md:19`, adopted as reviewed for pv-3jw6 under the owner answer "Report unknown (UO) (Recommended)". The original panel record stays verbatim under the "record stays" precedent from PR #23 and PR #25. PR #31's thread resolution dispositions the archive-edit request only.

Open question: Must pv-3jw6's application text explicitly require e to bound the source timestamp's total error, including source-clock error, precision, quantization and rounding, rather than only "the source clock's error"? Review the existing certified-prefix and unknown-endpoint obligations as part of that question. The resolution here does not select either interpretation or authorize a wording change.

CodeRabbit's suggested replacement, quoted verbatim:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Original suggested diff, quoted verbatim:

```diff
-The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.
+The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.
```

Carry this to pv-3jw6's application review before any specification text changes. Do not silently amend its adopted package or change its bead based on this handoff.
