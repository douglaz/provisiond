**S: ACCEPT.**

**D: OMIT.** D leaves the promotion-time timeline observation unspecified, so its refusal condition is not established.

**F: CANNOT ACCEPT.** F6’s re-keying alone contradicts its new admission events. [Restore.lean:703](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/tools/formal/Provisiond/Restore.lean#L703) defines `World.quarantined` as:

```lean
∀ j, (w.store.ops j).status = .queued →
  irreversible (w.store.ops j).kind = false
```

Trace: restore → lock → startup pass → complete step (3) → admit a fresh create. Now `stepTwoMarked = true`, but the fresh create is `queued` and irreversible. Thus the re-keyed `step_quarantined_restore` conclusion is false.

Replace only F6’s “`step_quarantined_restore` is re-keyed to `stepTwoMarked`” bullet with:

> Replace `step_quarantined_restore` with preservation of `stepTwoMarked = true → World.safe`, retaining `secondOrder = false`. `World.safe` means every queued irreversible operation has `applied = false`. Retain the stronger quarantine result immediately after the first step-(2) pass. Fresh admission uses an unused operation ID and initializes `applied = false`. Preserve `quarantine_before_first_claim`’s conclusion unchanged.

**Brief errors:** S5 leaves [CONTEXT.md:186](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/CONTEXT.md#L186)’s “a restore loses an interval” unchanged. That universal becomes false under S2’s explicit “whether or not the promotion lost a write.” This is glossary drift, not a normative blocker; change that span to “a restore may lose an interval.”