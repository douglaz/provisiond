# Settled pv-5pmu wording correction — Panel N r93

Q1: Q-QUOTE. Q2: L-NOTE. Opus, Astra and Sol each prefer and accept these exact forms, and each classifies each pick WORDING-ONLY. Fable (limit line) and Grok (402) are missing seats, not votes. This records a panel settlement only; no tracker or PR change occurred.

Reviewed PR #53 head: `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`. Source pin: `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`. Rebase target checked: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.

The source quotations below, the retained API-tail anchor in the complete form, and AGENTS.md lines 29–32 are byte-identical at the source pin and rebase target. The complete AGENTS.md, API, domain, lifecycle and overview source files also match the reviewed head. Historical approval strings are checked against the historical originals and reviewed head; they are not represented as new master requirements.

## Exact PR #53 locations

- `.beads/issues.jsonl:15`: only pv-5pmu, `comments[0]`, comment id `856`, the Agent Brief. Its decoded line 6 receives the authority-line replacement below. Within Desired behavior, decoded lines 37–38 receive the replay substring replacement and decoded line 39 receives the manual-release substring replacement. Preserve all surrounding bytes, including the API-64 retry clause on lines 38–39 and every historical quotation and acceptance criterion. JSON encoding places this entire comment on the one physical JSONL line; re-resolve the pv-5pmu row after rebase.
- `docs/research/panels-2026-10/r86/r86b/Q1-A.md`: replace no original line. Preserve original lines 1–59, all 3860 bytes, SHA-256 `db7f2b55cf4f49fcc22e6b57d6efc72daaa158817faff1cf2ad67981c19f28e3`. Append exactly `note-Q-QUOTE.md` below, starting at new line 60; its heading is line 61. The original replay at lines 12–13 and manual clause at line 14 remain as historical evidence.
- The apply turn must also archive the settled r93 panel record, including `docs/research/panels-2026-10/r93/notes.md`, so the reviewed note’s `../../r93/notes.md` link resolves. That path is absent at the reviewed head; do not ship a dangling record link. This is the dependency already reviewed by all agreeing readers.

## Replay substring replacement

Old (decoded Agent Brief lines 37–38; archive original lines 12–13):

```text
A replay returned by API-7 step 5a never reaches
this check.
```

New, exactly:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

## Manual-release substring replacement

Old (decoded Agent Brief line 39; archive original line 14):

```text
API-65's manual release has no driver operation and takes no capability check.
```

New, exactly:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

The no-capability-check instruction comes from item 16’s own timing rule, original Q1-A line 14 and retained lines 41–42. It remains explicit after the API-65 quotation and in the unchanged final exclusion. API-65 supplies only the quoted no-driver-call/no-operation facts. No assertion of the adopted form is removed or weakened; the complete independent map is `assertion-map.md`.

## Agent Brief authority-line replacement

Old (decoded line 6):

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`.
```

New, exactly:

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
```

## Exact dated archive appendix

The following outer fence contains the complete 24-line appendix, including its initial blank line and final newline. Its SHA-256 is `5c8d78a058c4e4507fdff0f014ecfa1c5e9855b7eac148d80ec41afe70457bac`.

````text

## Wording correction — 2026-10-31 (Panel N r93)

The text above is retained as the historical form approved in owner item 16.
The executable pv-5pmu Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q1-A text is retained.

Replacement for the replay sentence:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Replacement for the manual-release clause:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

Source pin: `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`.
Review head: `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.
Panel record: `../../r93/notes.md`.
````

## Verification artifacts and next step

`check/tally-verification.json` records exact source and original matches. Reversing only the two substitutions and authority-line change restores every original Agent Brief byte. `Q-QUOTE.md` is the reviewed complete form; `check/prospective-agent-brief.md` is the complete prospective comment, SHA-256 `25455e9ed612d7832b4ddbd97ab3564fa27e0c9330dab8797204321e481f01df`. `check/prospective-archive.md` is the exact append-only archive result, SHA-256 `4cf03ef8c9a04dd8252c3dacfe2efb4d9eb69cc4232380edd4b422837b868881`. These are local review artifacts, not adoption into the tracker.

Next step: an apply turn on PR #53, rebased onto the checked master, using these exact forms and satisfying the r93 archive dependency. No owner question and no r93b are needed. Do not silently add the unreviewed owner-decisions/README edits suggested in a counterargument. Subsequent source drift or a conflicting rebase requires a fresh check before application.
