Recommend C1–C7 with these amendments:

- **C1 — Amend:** Return the original preferred WWN/serial string; normalization decides absence. This preserves identifier round trips without broadening matching equivalence.
- **C2 — Amend:** Normalize original strings once: trim, lowercase, strip one prefix. Hash normalized values; empty values become `null`.
- **C3 — Accept:** Canonical UTF-8 byte ordering is deterministic; retain identical elements.
- **C4 — Accept:** Reject malformed identifiers before enqueue; valid nonmatches still abort `integrity` in the worker.
- **C5 — (ii), amend:** Expose nullable `wwn`/`serial` and add `name`. `RSC-33` includes “name, path, size, type, model, serial”.
- **C6 — CNF-363, amend:** Cover both install forms, identifier round trips, normalization, sorting, and duplicate retention; leave `CNF-47` focused.
- **C7 — Amend:** No new theorem; update quoted docstrings and remove the overstrong fingerprint comment.

The substantive clash is C1’s “normalized WWN, else the normalized serial” versus original `RSC-46`’s “stripped of a leading `0x`”: serial `0x0xAB` advertises `0xab`, which normalizes again to `ab` when echoed. Returning original strings repairs this. C2’s “matches nothing” and C4’s “before enqueue” concern different phases and do not conflict.

Also corrected `Rescue.lean`’s “two device sets do not share one”: original `RSC-46` specifies “each device exactly `{wwn, serial, size_bytes}`”, leaving same-sized anonymous replacements indistinguishable.

Applied the [selected amendments](/var/tmp/provisiond-panel-r61b/sol/review-amendments.patch). Gate exits: baseline **0**; selected amendments **0**; path-fallback plant **0—nothing red**; unnamed-device wildcard plant **1** (`resolves_only_the_named_disk` fails); restored final form **0**. Both plants are restored. [Gate evidence](/var/tmp/provisiond-panel-r61b/sol/review-gates.txt). `CNF-363` remains an implementation-test obligation.

The owner question bundles unsettled choices and reopens settled alternatives. Rewrite:

> Given the settled choice to retain every disk, approve original WWN-or-serial identifiers, `null` when neither survives normalization; nullable `wwn`/`serial` plus `name`; normalized whole-set hashing with canonical-byte sorting and duplicate retention; early `invalid_request` for malformed install identifiers; and `CNF-363` covering both install forms? Valid nonmatches still abort `integrity`. The fingerprint recipe changes. Inventory still reboots the machine; anonymous disks remain unselectable, and same-sized anonymous replacements remain undetectable.

**Written on request — strongest counterargument (C5(ii), least confidence):** Nullability needs no additional response fields. `WIR-2`’s “clients MUST ignore unknown response fields” permits adding them later; including that expansion now increases scope and review surface.