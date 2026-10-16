Your reading is mostly right, but one part of the in-flight half isn't specified. I'd still close the bead, as unreachable rather than as "already specified", so I pick (D).

## 1. Does the text settle both halves?

**Pre-column rows: settled.** 05:261 says "a null value MUST contribute no earliest-date term", with no fallback.

**Attach: settled.** Every writer that 05:261 lists runs after the order has landed. 03:470 says "Attach it and complete the operation as though it had succeeded". Copying a field isn't a check, and `OPS-23` repeats validation only "before the driver is called" (03:1623-1624). The bead's "whether attaching it fails (per `OPS-23`)" isn't a real case.

**Dispatch: not settled.** This is the sentence that leaves the choice to an implementer. `OPS-23` says "Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called." `PRV-31`'s refusal runs at the boundary (04:266-267), and no text says what the repeated check reads:
- **If it reads the snapshot**, the missing bound is "a deterministic failure in the worker" (03:1625-1627).
- **If it reads the live offer**, the create goes ahead and gets a null copy.

`invalid_request` isn't on `OPS-11`'s admission-only list (03:234-238), so a worker may emit `offer_not_sellable`. Neither 04:950-952 nor `CONTEXT.md` limits what "validation" covers. Your "no worker re-check of `PRV-31` reads the snapshot" holds only because nothing says what that re-check reads.

**One of your precedents fails.** `billing_unit_seconds` is in `OPS-43`'s must-hold list (03:673-675). So a create from an older `api` that lacks it fails before dispatch, and the bound isn't on that list. `install_strategies` (05:259) has the same shape as the bound and still works as a precedent.

## 2. Is null ever not exact?

**Null is exact whenever the true bound is at most provider-local today:**
- **v1:** the bound is at most the acceptance day (02:547-549), and `LDG-33` counts it "only if later than provider-local today" (12:354).
- **Late or operator attach:** the bound is still at most today.
- **Deviation:** a successful read fills `earliest_cancellation_date`, so the fallback is never read. After a failed read, either value leaves the deviation unpriced (ADR-0037:294).
- **`STO-13`:** the release stops every component first (05:1396-1401), but that doesn't empty the queue. The null-read rule covers the creates still queued.
- **Lifting the v1 rule later:** rows already sold keep bounds that are already past.

**Null is not exact in two cases:**
- a row admitted by an `api` that predates the Q25 rule;
- a rollback to a pre-column binary (05:1394) from a release that both adds the column and lifts the v1 rule.

Both need a deployment that ran without the column. `impl-report-01.md` says "no implementation was produced", and a build from `02ed28a` already has the column.

## 3. Pick: (D)

Close it as `wontfix` because it's unreachable, not because it's "already specified". The dispatch fork costs no money, and only an upgrade that no deployment has made can reach it. The closing comment should cite 05:261 and 03:1623-1624 and drop the `billing_unit_seconds` precedent. Whether `OPS-23` covers sale refusals at all also affects `PRV-13b`, so it belongs in a separate bead.

## Strongest case for the other side (written on request)

The case is for (B). The set already says what happens when an older `api` leaves out a copied field, for the seconds (03:673-675). For the bound it leaves the choice to the implementer, so two conformant engines can give the customer different outcomes. `OPS-23` owns what the worker fails, so the sentence goes there, after 03:1627:

> A create whose snapshot lacks the declared cancellation bound MUST NOT be failed for its absence; the `machines.declared_cancellation_bound` row prices the null.

---

The review above is 492 words and is saved as `scratch-pv-d21-review.md` in the clone. I edited no tracked files. Running `br show` left an untracked `.beads/beads.db.fsqlite-migration-state` in the clone.
