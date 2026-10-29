# Settled r82 Q1 — D2

Pinned landing: `10-conformance-checklist.md`, CNF-302, at c824e4fa4d612b231110bc5deb3e88b3b3e90f92.

Insert as one new paragraph immediately after the paragraph whose final sentence is:

> A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks.

That sentence ends at pinned line 3087. Use the item's six-space indent, with one blank line before and after the new paragraph, before the install-case table whose header at pinned line 3089 is:

> | Install case after successor pass | `disk_effect` / `rescue_exit` |

The complete paragraph below is D2 verbatim apart from the landing's six-space indent. No repair or amendment marker is added. Exact-form acceptance: fable, astra, sol; refusal: opus. Explicit final pick: fable. Rule 2 settles this sole qualifying exact form; see [tally](../tally.md).

```markdown
      For one actual restore, lose the establishment transaction's connection before it commits,
      so that no record with the retained id exists, and repeat establishment with that id in a
      later transaction whose start time differs: assert exactly one record with that id, its
      `restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
      provenance initialized in the repeating transaction, and neither component started before
      that transaction is acknowledged. Separately let establishment commit, drop its reply and
      repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
      stored instant, predecessor and step marks, that it is not refused merely because the
      repeating transaction starts later, and that the components then start and continue that
      incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
      algorithm.
```
