**Verdict: yes, both X and Y conform today, by contradiction rather than silence. The text should say Y.**

`OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits, for every operation kind, subject to the bounded abandonment and later-stop exits below." Its listed exits are bound expiry, "A later stop during that loop" (the record's own loop) and `OPS-49`'s exhaustion. A first stop inside step 8's repeat matches none, so `OPS-21` demands Y. `OPS-49`'s bullet says "This means a stop arriving during the loop", and `CNF-361` carves the case out: "at step 8 outside `OPS-49`'s retry loop, where … classifies nothing" (that phrase predates pv-tst; it is at `ee81952`). Both say X. An X engine cites the bullet, a Y engine cites the MUST.

**What settles the direction:** owner decision A, "Any stop the engine survives MUST record the outcome before the engine exits … every kind." X here produces exactly the harm A was taken to end: a held commitment and a correlator search for an order nobody placed. Decision 2's "`OPS-49`'s retry loop and its exits stay as settled" answered r58b's question about the record's own loop; nobody put an in-`execute` loop to the owner, so no decision or requirement text settles this case alone. The agent brief's item 2 is wording, not a ruling.

**First attempt in flight:** let it finish. `OPS-49` says "the server decides every statement's fate before the client does"; cancelling a store call mid-flight manufactures the lost reply that sentence exists to exclude. Then record, never continue to step 9. For a create the attempt's fate is irrelevant: the row reads "It is the worker's position", with "no `about_to_order_at IS NULL` term", so it settles `failed` either way.

**Install differs in outcome, not rule.** Its row reads the markers, and "nothing clears them" (`OPS-45`). A marker attempt that committed before the stop parks the install under Y as under X; Y only adds the `cut_off` record and a clean exit. Cancelling the attempt cannot avoid that, since the server may commit anyway.

**Minimal edit (applied in the clone, gate exit 0):**
- `OPS-21`, after "restart recovery remains with `OPS-15`.": "This includes a stop arriving while a store transaction inside `execute` is being repeated under `OPS-49`, such as `OPS-43`'s step 8 or `OPS-45`'s marker write: the worker abandons that repeat and makes the record. A store call already in flight when the stop arrives MUST be allowed to finish, since `OPS-49` says "the server decides every statement's fate before the client does"; the worker then records rather than continuing `execute`."
- `OPS-49`'s bullet: "a stop arriving during the loop of a write made after `execute` returned" (leaves pv-zbp open), plus "A stop arriving during a loop inside `execute` is that cancellation".
- `CNF-361`: "at step 8 both outside and inside `OPS-49`'s whole-transaction repeat of its transaction, the latter after a first attempt that committed with its reply lost."

**Gate blind spot, tested:** the wrong edit "the worker finishes that repeat under the Store-retry bound and then makes the record" passed every gate (exit 0). `StopRecord.schedule` has no event for a pre-record loop, and citations checks only quotes.

**Strongest case for X:** it is the one settled exit for every `OPS-49` loop since `ADR-0022`, `CNF-361` encoded it under review, and Y spends up to the Stop-record bound against a store already known to be failing, usually ending in the same `OPS-15` park.

**Would change my mind:** the owner stating decision 2 meant in-`execute` loops too, or evidence that stores routinely blip during deploy stops, making Y's bounded wait pure deploy delay.
