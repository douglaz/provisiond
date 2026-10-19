**Yes, both engines conform today.** `OPS-21` leans Y. It requires recording "subject to the bounded abandonment and later-stop exits below", and its later-stop exit covers only "that loop", which is the record's own loop. `OPS-49`'s gloss excludes "the cancellation being recorded", and that is this stop. But pv-tst kept three texts that allow X:
- `CNF-361`: "at step 8 outside `OPS-49`'s retry loop … and classifies nothing". This is pv-qga's text (`c8b7cbc`), from before decision A.
- pv-qga's note on `OPS-21`: "the retry-loop exits remain exits without worker classification".
- `OPS-49` itself: "A worker cancelled during the retry loop stops retrying and exits". Its gloss narrows only the record's loop.

`CNF-362` runs "with a working store", so no conformance item separates X from Y.

**Pick Y. Decision A settles it:** "Any stop the engine survives MUST record the outcome before the engine exits." Decision 2's "stay as settled" follows "On expiry the engine exits" in the Stop-record bound's bullet, so it governs the record's loop.

**The first attempt may finish.** Nothing forbids it, and its time counts against the bound, which is "measured from the stop". No text today forbids starting step 9 after the stop; my edit below forbids it.

**The install differs.** The create row is positional: "MUST NOT read `about_to_order_at`". The install row reads the markers. After a lost reply or an abort mid-commit, the worker can't know what the markers hold. `OPS-45` requires only "acknowledged by the store before the provider call it precedes is made". An abort needs no store error, so X has this gap too.

**Edit:**
- `OPS-21`, after the shielding sentence, add:
  - "A stop arriving while a write inside `execute` (`OPS-43`'s step 8, an `OPS-45` marker write) is in flight or repeating under `OPS-49` is the cancellation being recorded."
  - "The worker MUST NOT repeat that write or start anything it precedes, and makes the record; an attempt already sent MAY finish."
  - "Where the kind's row reads `OPS-45`'s markers, the record classifies against the markers its own transaction reads."
- `OPS-49`: append to the "This means…" sentence: "; a stop arriving while a write inside `execute` repeats is that cancellation (`OPS-21`)". The quoted bullet stays unchanged.
- `CNF-361`: the carve-out becomes "at step 8 on its first attempt and during its `OPS-49` repeat after a lost reply".
- `CNF-362`: stop a `provider_native` install while its marker write repeats. If the attempt committed, assert `needs_reconciliation`; if it was refused, assert `failed`. Rescue-based installs park either way, because a rescue session is open.

**A wrong edit passes every gate.** I planted an unscoped edit in `OPS-49`, "a stop arriving during any `OPS-49` loop is recorded under `OPS-21`", and left `CNF-361` untouched. `check-all.sh` exited 0 with all seven gates passing; the log is `r58c-plant-gates.log`. That edit also rules on pv-zbp's settle loop. Lean misses it because `StopRecord.schedule` starts at the record.

**The case for X.** A failing store will probably fail the record too. Y can stretch shutdown by up to the bound and needs a new rule for reading the markers. X keeps the settled exit and `CNF-361` as they are, and the restart is safe either way.

**What would change my mind:** the owner saying "stay as settled" covers the loops inside `execute`.

---
The plant is reverted and the tracked files are clean. This answer is saved as `r58c-opus-answer.md` in the clone.
