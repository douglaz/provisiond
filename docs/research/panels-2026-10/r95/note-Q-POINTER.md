
## Wording correction — 2026-11-02 (Panel P r95)

The text above, including Panel O’s 2026-10-31 appendix, is retained as the historical record.
The pv-kv2 specification and executable Agent Brief use the following additional replacements
under the owner’s 2026-10-28 wording rule; all other text is retained.

Replacement 1, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11.
```

Replacement 2, for the matching executable passage (including Panel O’s substitution where applicable):

```text
on both error and operation view, then settle failed with full
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11.
```

Replacement 3, for the matching executable passage (including Panel O’s substitution where applicable):

```text
worker's recorded failure as a pre-step-9 failure; do not add a null-column term to
the settlement guard. For classification and settlement, see OPS-11.
```

Replacement 4, for the matching executable passage (including Panel O’s substitution where applicable):

```text
abandoned mid-order; for its machine, see OPS-27.
```

Replacement 5, for the matching executable passage (including Panel O’s substitution where applicable):

```text
For orders already potentially dispatched, including later evidence-based attachment after
the suspension parent has settled, see OPS-27.
```

Replacement 6, for the matching executable passage (including Panel O’s substitution where applicable):

```text
This write and the suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. For the admission-time suspension flag, see API-58.
```

Replacement 7, for the matching executable passage (including Panel O’s substitution where applicable):

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

Source pin: `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`.
Review head: `96a72898c7ace67790aec0bab3727eee858e2245`.
Panel record: `../../r95/notes.md`.
