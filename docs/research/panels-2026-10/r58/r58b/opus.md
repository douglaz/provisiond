I'd go with the smaller shape: one attempt at the settle write, no Lean, no `ci.yml`. The tie-break needs a sentence, and the reason value should be `cut_off`. The gates exited 0 before the plant and 0 with it; the plant is reverted.

**1. Picks**
- **(a) One attempt, within `OPS-49`'s "Store-retry bound" (00:401), and the stop's cancellation must not cancel it.**
  - Reason: a worker already in the loop when the stop lands exits at once (03:1764, settled). Giving one cancelled a moment earlier the full bound treats one stop two ways and means narrowing a settled bullet.
  - Also edit the comment at 03:1683: "every store write below is retried as a whole transaction under `OPS-49`".
  - **03:1764 ruling:** no, not "whatever A says". A cancellation still in force covers the first attempt too, so even zero attempts conform. Once A keeps the cancellation off the first attempt, it is in force again from the first error, so 03:1764 applies: one attempt, then exit. A must state the count.
- **(b) Nothing.** `posts_at_most_once` (Claim.lean:372) holds for every outcome list, and the list's "length is the bound" (:325). So one attempt is already proved.
- **(c) None.** A adds no gate and no declaration.

**2. Claims I break**
- **S1, settle-write half:** the client deadline has only a floor ("MUST NOT be shorter than the server-side timeouts", 05:140-141) and no register row. Only `OPS-49`'s bound caps it ("covers connection, execution, commit, read-back and backoff together"), so A must say "within" that bound.
- **S2's premise:** Claim.lean:407 models exit: "or exited for the supervisor". Its conclusion stands.
- **L1:** the number is already registered (00:401). A supervisor kill is a crash, which parks (settled).
- **L2:** not broken, absorbed. 05:143-144 already pictures "a connection abandoned mid-transaction — by a timeout, a cancelled worker or a lost reply".
- **L3:** "one negative-control step per gate that has one". The controls prove gates, not rules, and `ci.yml` has no coverage-gate control (0 matches).

**3. What would change each pick**
- **(a):** evidence that the store usually blips during the stop (one deploy restarts the engine and the store). That would argue for the full bound, with 03:1764 amended.
- **(b):** A changing what `Tables` computes, such as a new `Failure` field. That would need a model and witnesses.
- **(c):** follows (b). A new guarded declaration gets its mutation.

**4. Tie-break: yes (T2).** The trigger is "whose children are still queued". The sentence:
> A cancelled `suspend_tenant` parent records no `OPS-11` outcome; it is returned to `queued` under its claim number with `available_at` unchanged, and its next claim resumes the fan-out, as `OPS-15` re-queues a parent found running, "resuming its fan-out from wherever it stopped".

"Unchanged", not 03:1767's "advanced": `OVR-18` names `SEC-45`'s fan-out among what stops while the engine is down.

**5. Reason value: `cut_off`**
- It is `OPS-11`'s own wording, "the worker being cut off mid-flight" (03:270), and the formal layer's `cutOff`.
- Against `execution_cancelled`:
  - `CONTEXT.md`: "Use **cancel** whenever an end date is involved".
  - Beside `cancellation_committed` (`retryable: false`, 13:170), a caller would read a machine cancellation.
- `cut_off` says only that the worker stopped. That is true whether the row settles `failed` or, like an install past its marker, parks.
- Edits:
  - add the value to 13:137's list;
  - `CNF-361` asserts `details.reason: "cut_off"` instead of "Make no assertion";
  - `CNF-248` covers only 409s and stays as it is.

**6. The plant**
- After 03:1708: "A cancellation the engine survives MUST be recorded and classified under `OPS-11` in one attempt at the settle transaction before the engine exits; if that attempt errors, the worker exits, since `OPS-49` says "A worker cancelled during the retry loop stops retrying and exits"."
- It neither keeps the cancellation off the write nor caps the attempt.
- **Gates exit 0, all seven PASS.** No gate checks what a MUST means.
- What should catch it is `CNF` cases:
  - cancel after step 8 is acknowledged, and assert the guarded settle write reaches the store;
  - blackhole the store after the cancellation, and assert exit within the Store-retry bound, then `needs_reconciliation` on restart.
- Reverted with `git checkout`. The only untracked file is `.beads/beads.db.fsqlite-migration-state`, which `br show` created.
