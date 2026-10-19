**1. Picks**

- **(a) `OPS-49`'s bound, no new row.** `OPS-49` already binds this write: "Where a store call by a worker ... errors or times out, the component MUST repeat the **whole transaction** ... for a stated bound (`OVR-19`)". One attempt needs a new exception to a settled rule; a row is a second copy of 00:401.
- **03:1764:** No. The stop that ended `execute` is what the write records; "cancelled during the retry loop" is a later stop. Read otherwise, A's MUST voids itself. The sentence must say the record write runs outside the cancellation that stopped `execute`, under `OPS-49`'s loop; a further stop during the loop exits per 03:1764.
- **(b) Nothing.** `Failure` is "One failure as the classification reads it" (Tables.lean:88). Claim.lean models `retryWhole` to exhaustion and `exited` but contains no cancellation (zero hits). A record-before-exit theorem would be its own hypothesis.
- **(c) None.** Controls are per gate: "one negative-control step per gate that has one". No new gate, no control owed.

**2. Broken**

- **L1.** `OVR-19` lists values "the set says a deployment MUST state". Nothing makes a deployment state a stop wait, and the owner's rule binds "any stop the engine survives", not the supervisor. The wait is 00:401 alone: `OPS-21` says the call is "abandoned mid-flight", not awaited.
- **L3.** check_coverage.py: "The conformance checklist IS this project's test suite -- there is no code." The rule's test is a CNF case, not a gate.
- **T1.** The bullet's trigger is a parent "whose children are still queued" (03:1767); mid-fan-out, children do not exist yet.
- L2 holds and dictates one clause. S1-S3 hold; S1's sum overstates, since the deadline never runs.

**3. Changers**

- (a) A sentence requiring a stated stop wait, or `OPS-49` excluding this write from its loop.
- (b) Claim.lean gaining a cancellation event; a cut-off path would then compose and owe witnesses.
- (c) Any new Lean declaration (`ADR-0025` owes it a mutation).

**4. Tie-break: yes.** "A `suspend_tenant` parent cancelled at any point in its fan-out is recorded by `OPS-49`'s parent write, "returned to `queued` with `available_at` advanced — the same write as `OPS-8`'s defer, though nothing refused it", and resumes its fan-out when next claimed."

**5. Reason: `cut_off`.** Not `execution_cancelled`: `CONTEXT.md` says "Use **cancel** whenever an end date is involved", and `cancellation_committed` is such a value ("Repeating does not revoke a committed cancellation", 13:170); a sibling `*_cancelled` reads as an end-date fact. `cut_off` is `OPS-11`'s own term ("cut off mid-flight (`OPS-21`)", "a cut-off `conflict`"), Tables.lean's `cutOff`, and kind-neutral. `CNF-361` becomes "assert `details.reason: "cut_off"` for each cancellation case"; `WIR-9a` gains `"cut_off"` (`OPS-21`). check_fixtures.py has no reason-enum check, so only a CNF run (10:2784) catches an unlisted value.

**6. Plant.** After 03:1708: an unbounded "MUST be recorded and classified under `OPS-11` before the engine exits", write left under the cancellation, plus `OPS-49` says "the record is repeated for the store-retry bound".

| Gate | Result |
|---|---|
| citations | FAIL: "attributes to OPS-49 a phrase OPS-49 does not contain" |
| formal, identifiers, fixtures, obligations, coverage, regions | PASS |

Exit 1. The missing bound and the cancellable write passed every gate. What should catch them: `CNF-361`'s new case, cancel at step 8, hold the first settle statement, assert the row lands within the store-retry bound, and a second stop during the loop parks. Reverted; tree clean.
