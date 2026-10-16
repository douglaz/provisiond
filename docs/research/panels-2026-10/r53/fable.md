**Pick: (A) `wontfix`.** Both halves are specified, and the framing describes a rollout that cannot occur: no release has shipped, so the first deployment carries the column and no `api` ever wrote a snapshot without the bound. The text answers both halves regardless.

**1. Settled, with one soft spot before dispatch.**
- Pre-column rows: 05:261 says "a null value MUST contribute no earliest-date term; re-derivation MUST NOT fall back to the live offer, the descriptor or the create's `request_summary`". STO-13 at 05:1376-1377 makes a new column "nullable in the release that adds it and tightened after a backfill in a later one". That is the rollout shape of 05:259-260; nothing requires a backfill.
- Attach: OPS-27 at 03:470 says "Attach it and complete the operation as though it had succeeded", and 05:261 copies the snapshot's value, so an absent field copies null. OPS-23 at 03:1623-1624 is scoped to validation "before the driver is called" and cannot fail an attach.
- Before dispatch the brief overstates. OPS-23's first sentence makes the worker repeat every API-boundary validation, and API-7 runs the `PRV-31` sale check at 04:266-267. So the worker repeats `PRV-31`, and no sentence names its input. Against the live offer, as OPS-43 re-reads the live price at 03:671, the create proceeds. Against the snapshot's bound, the missing field is "a deterministic failure in the worker" at 03:1625-1627. An implementer's choice, but both outcomes are safe: nothing has been ordered, and a failed create is re-submitted under an `api` that snapshots.

**2. Null is exact wherever the true bound is no later than provider-local today at every re-derivation.** Every v1 create's bound is at most its acceptance day, 02:547-549, and LDG-33 prices "only if later than provider-local today", 12:354.
- Lifting the v1 rule: later rows have the column; rows already null were sold under it, so their bound stays past forever.
- PRV-13c deviation: the read date fills `earliest_cancellation_date`, and 12:353 then never consults the bound.
- STO-13 stop-everything stops processes, not queued rows; a queued N−1 create is claimed by N with the same arithmetic.
- Late or operator attach: bound ≤ acceptance day < attach day. 10:3673 already asserts zero for the `WIR-35` attach.
- Re-declared bound: 05:261, "never re-resolved afterwards".
- Inexact only for a snapshot written by an `api` predating Q25, when `PRV-31` admitted future bounds. No such release exists.

**3. Close with:** half 1 at 05:261 and 05:1376-1377; half 2 at 03:470 and 03:1623-1624; exactness at 02:547-549 and 12:354. The release that lifts the v1 rule owns the line that pre-existing null rows were sold under it. (C) parks a bead on an unscheduled change the arithmetic already covers.

**Strongest case for the other side (written on request).** The OPS-23 gap is live text, not history: the worker MUST repeat `PRV-31` and no sentence says what it reads. AGENTS.md's bar is a quoted sentence that fails, and that one does. The exactness proof leans on a fact the repo never records, that nothing shipped before Q25, so a reader lifting the v1 rule next year cannot check it from the text. `SEC-46` and `ddd3df0` record "already specified" asserted and wrong. One sentence under OPS-23 closes both: "A field no check before dispatch reads, `declared_cancellation_bound` among them, is copied at attach as the snapshot holds it, null included, and is not this failure." That is (B), on OPS-23, for one line.
