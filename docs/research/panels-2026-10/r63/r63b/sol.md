**S: ACCEPT.**

**D: OMIT.** The timeline observation and reconnect protocol remain unspecified; S supplies the explicit deployment barrier.

**F: CANNOT ACCEPT.** F6’s instruction to re-key `step_quarantined_restore` to `stepTwoMarked` retains an invariant contradicted by its new admission events. [Restore.lean:703](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/tools/formal/Provisiond/Restore.lean#L703) defines `World.quarantined` as every queued row having `irreversible = false`; the helper preserves that predicate.

Trace: run `.lock, .startupPass, .completeProcedure t`, then admit F6’s fresh queued create. `stepTwoMarked = true`, but that create is irreversible, so `World.quarantined` is false. Merely changing the mark’s name leaves the helper false on the newly required workload.

Replace only F6’s “`step_quarantined_restore` is re-keyed to `stepTwoMarked`” bullet with:

> `step_quarantined_restore` is re-keyed to `stepTwoMarked` and replaces its `World.quarantined` invariant with `World.safe`: every queued irreversible operation has `applied = false` (`Restore.lean:505–508`). Prove this invariant over the extended event set, including fresh admission and provider application, while retaining `quarantine_before_first_claim`’s existing `secondOrder = false` conclusion.

This preserves the settled Q2 behavior while allowing fresh queued creates.

**Brief errors**

None identified in the brief’s factual claims.