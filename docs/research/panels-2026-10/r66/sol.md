Reviewed r66’s G and R against `d78085a`. No gates or `lake` run; tracked files unchanged.

**Q1. CANNOT ACCEPT G’s text.**

1. **Blocker: startup must refuse itself.** `OPS-50` requires every engine write transaction to read the generation “as its first statement”; `OPS-15` requires its first transaction to “begin by replacing” it. Before that replacement, the startup pass has written no value it can compare against. Reading first violates `OPS-15`; replacing first violates `OPS-50`. This wrongly refuses startup without a takeover and makes `CNF-368` unreachable.

   Replace `OPS-50`’s opening phrase with:

   > Except for `OPS-15`’s generation-advance transaction, every write transaction made in the engine process

   Replace `OPS-15`’s new first sentence with:

   > The pass’s first transaction MUST contain only the replacement of `STO-59`’s startup generation. Its commit MUST be acknowledged before the remainder of the pass runs or any worker or periodic component begins. This transaction alone is exempt from `OPS-50`’s generation read.

2. **Blocker: refusal does not establish “unlanded”.** Quote: “A record pending under `OPS-21` ends there, unlanded”. Trace: the record commits, its reply is lost, the successor advances, and the predecessor’s retry is refused. The record already landed. `OPS-49` expressly allows “the row is already written, the money already posted once”. The proposed `superseded_exits`, following `later_stop_exits`, must preserve that committed prefix.

   Replace that sentence with:

   > A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost.

   The residual’s “and its row reaches `needs_reconciliation` or one of `OPS-15`’s exceptions” is also false for cleanup. `CNF-303` explicitly requires deletion “with the row still absent”. Delete that trailing recovery assertion; retain the dispatch-window statement.

3. **Blocker: zero disables the intended timeout.** The assignment “`lock_timeout` set to `OPS-47`’s startup-lock retry bound” imports an `OVR-19` row typed merely “duration”. PostgreSQL says: “A value of zero (the default) disables the timeout.” With bound zero, hold the share lock briefly, then release it before `statement_timeout`: the successor advances and claims, contrary to `CNF-369`. [PostgreSQL documentation](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-LOCK-TIMEOUT)

   Replace that register row’s type with:

   > finite, positive duration

4. **Blocker: previous-release engines escape the fence.** Missing owner: `STO-13`, which permits “Rollback is the previous binary against the current schema”. An older engine loses its lock session but has not detected it; a new engine advances; the older binary claims fresh work without a generation check. That is a stale write after the advance.

   Add to `STO-13`:

   > Activating `OPS-50` is a contract step. Before the first startup-generation advance, the deployment MUST stop every engine binary lacking that check and prevent it from reconnecting. Rollback to such a binary is inadmissible.

**Id list.** The proposed numbers are free. Besides `STO-13`, these spans need attention:

- **`OPS-15`**, beyond amendment 6: it still quotes `STO-3` saying “nothing contends with it”, which amendment 11 removes. Its “the other’s guard affects no row” also overlooks refusal before that guard executes. Replace the paragraph’s first three sentences with:

  > `OPS-50` applies to the startup settlement and the live step-8 transaction.

- **`CNF-290`**, beyond amendment 12: its final note still quotes “nothing here refuses the second, and both will work the queue”. Replace the sentence containing that attribution with:

  > The generation fence is covered by `OPS-50`’s conformance items.

- **`ADR-0022`**: appending a pointer leaves “The guarded status write is the transaction’s first statement” unqualified. Add:

  > *2026-10-24: `ADR-0047` changes this order; `OPS-50`’s generation read precedes the guarded status write.*

The restore rewrite, timeout assignment, and promised superseded-exit alarm are behavioral additions. Their owners need substantive clauses; a bare pointer does not establish a new alarm duty.

**The four conformance items:**

- **`CNF-367`:** use independent trials; otherwise the first required engine exit makes subsequent paths unreachable. Replace its setup with:

  > In a separate run for each engine write path, advance the generation out of band after that engine’s startup advance, then drive the selected path.

- **`CNF-368`:** a conforming predecessor still holding the startup advisory lock prevents the successor from reaching its advance. Replace its setup with:

  > After the predecessor’s startup-lock session ends, keep an already-sent engine transaction holding the generation row `FOR SHARE`; start the successor and verify it acquires the startup lock.

- **`CNF-369`:** inherits that fixture correction and needs the positive-bound amendment above.
- **`CNF-370`:** no conforming-failure found. Specify that the survivor holds the backed-up generation; repeat with PITR. Those are the useful restore controls.

**Lean names.** `schedule`, `schedule_bounded`, `later_stop_exits`, the three `selection` splits, `money_posts_at_most_once`, and `finished_unrecorded_exit` exist. `superseded_exits` is new. `Claim.lean:23` is the single-engine omission comment, not a guard declaration; update it. Name the new claim theorem and include the refused/admitted witness pair required by `ADR-0025`: “the bad trace is refused with the guard and admitted without it”. The additional `finished_unrecorded_exit` disjunct is a real weakening; recording it is correct.

**Q2. CANNOT ACCEPT R as amended.**

The `CNF-366` detection qualifier is right. Its “loud log timestamps the detection” assumes a logging duty absent from R’s proposed `OPS-47`: successful records can land without any loud log, failing the test.

**Open point: yes.** “where the connection carrying it is lost, the engine MUST claim nothing more” has the same detection-window defect. Without a generation advance, G admits that intervening claim and does not change the answer.

Replace that opening span with:

> when the engine detects loss of the connection carrying it, the engine MUST log that detection loudly with its timestamp, begin no further claim transaction or periodic pass

Also replace R’s “A stop that arrives after the loss” and `CNF-366(iv)`’s “Deliver a stop after the loss” with “after the engine detects the loss”.

Replace R’s “ends there, unlanded” sentence with:

> `OPS-50` says “A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost.”

Otherwise the added generation-refusal exception reconciles R’s “it ends no record already pending” with G’s “exit non-zero at once”: loss alone preserves recording; supersession ends further attempts.

**Brief errors:**

- All quoted **before** spans match, allowing line wrapping. The next-free ids and PR #24’s use of `ADR-0046` are correct.
- “The advance holds nothing but the generation row” does not follow from “first statement”. The draft permits further statements in that transaction. The dedicated transaction replacement above establishes the claimed property.
- “fresh random UUID … so no value is ever written twice” overstates the generator. PostgreSQL promises a “version 4 (random) UUID”, not historical non-reuse. [PostgreSQL documentation](https://www.postgresql.org/docs/18/functions-uuid.html) Non-reuse remains a required invariant. A rolled-back advance preserves the preceding generation; PITR requires the fresh write **after replay and before component access**. Under those requirements, neither authorizes reuse.