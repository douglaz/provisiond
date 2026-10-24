Reviewed r66 against `d78085a`. No gates or Lean builds run.

**Q1. CANNOT ACCEPT G’s text.**

1. **Blocker — startup contradicts the universal check.** `OPS-50` requires “Every write transaction made in the engine process” to read first and compare against “the value the engine’s own startup pass wrote”. But `OPS-15` requires that pass’s first transaction to “begin by replacing” the generation. An ordinary startup cannot satisfy both; `CNF-368`’s successful successor is unreachable.

   Replace `OPS-50`’s opening scope:

   > Except for `OPS-15`’s generation-replacement transaction, every write transaction made in the engine process …

   Replace `OPS-15`’s first new sentence:

   > After acquiring `STO-51`’s startup lock, the pass MUST replace `STO-59`’s generation in a separate transaction containing no other application work. This transaction is exempt from `OPS-50`’s read-and-compare check. The engine MUST receive acknowledgement of its commit before beginning the sweep, any claim, or any periodic component. Subsequent startup transactions carry `OPS-50`’s check.

2. **Blocker — replacement needs a commit boundary.** “No write of the first commits once the second’s startup pass has replaced … the generation” includes an UPDATE subsequently rolled back. Trace: successor updates, later errors, rolls back; the original engine legitimately writes using the unchanged generation. No takeover committed, yet the stated prohibition refuses that write.

   Add to `STO-59`:

   > A generation replacement takes effect only when its transaction commits. An aborted replacement does not supersede the current engine. An engine whose replacement has an uncertain outcome exits under `OPS-15` and never uses that candidate value to perform work.

3. **Blocker — “unlanded” excludes a permitted lost-reply outcome.** G says “A record pending under `OPS-21` ends there, unlanded”; R repeats it. Trace: record commits, reply is lost, successor advances, old worker retries and detects mismatch. `OPS-49` says “the row is already written, the money already posted once”; `CNF-362` explicitly checks that outcome. `StopRecord.exit_store` also preserves it.

   Replace both “unlanded” sentences:

   > A refused generation check ends pursuit of the record and exits the engine. The refused transaction commits nothing; an earlier transaction whose acknowledgement was lost may already have committed the record and its effects.

4. **Blocker — missing upgrade boundary, `STO-13`.** It requires migrations “while the previous release’s engine and `api` keep running”. Its mandatory shutdown rule covers predicates “both components evaluate”; G’s check is engine-only. A surviving previous-release engine does not read the new generation and can commit after the new engine advances. That is a stale-write trace outside G’s stated residuals.

   Append to `STO-13`:

   > Before enabling `OPS-50`, the deployment MUST stop every engine version that does not perform its generation check and prevent such a version from restarting against this store. Creating `STO-59`’s row alone does not fence those versions.

**Id list.** The proposed identifiers are free. Besides `STO-13`, these spans need substantive amendments:

- `CNF-290`’s untouched tail still quotes “nothing here refuses the second, and both will work the queue”. Replace that tail with:

  > The startup lock’s admission check and `OPS-50`’s protection against an earlier engine are distinct; the latter’s dispatch residual remains.

- `ADR-0022` says “The guarded status write is the transaction’s first statement”. A bare appended pointer does not correct that ordering. Add a dated correction:

  > `ADR-0047` puts `OPS-50`’s generation check before the tenant primitive and guarded status write.

`OVR-18`’s specific supersession alarm is new behavior, not merely a pointer. Restore placement in `STO-54`/`STO-56` must likewise be explicit. I found no omitted ordinary engine writer: `OPS-50`’s process-wide scope includes the engine-hosted `ledger` components.

**The four conformance items:**

- **`CNF-367`:** exclude the replacement transaction introduced above; “each `OVR-17` engine writer” otherwise includes startup itself. Replace its scope with “In separate runs, drive each protected worker or component transaction of the already-started engine.”
- **`CNF-368`:** a conforming successor can fail it because the first engine still holds the advisory lock, or because release occurs after the advance’s timeout.
- **`CNF-369`:** its exit assertion can pass solely through advisory-lock refusal, never exercising G.
  
  Add to both fixtures:

  > Use an already-pending record transaction holding the generation share lock. Lose the separate startup-lock connection and establish that the successor acquired that advisory lock before testing the generation wait. Keep other deadlines from ending the holder first.

  Add to `CNF-368`:

  > Commit the holder before the advance’s applicable timeouts expire.

- **`CNF-370`:** no additional false-failure case under the stated non-reuse invariant. Pin the survivor to the backup’s generation so the drill actually detects restoration of its old value; collect generation history outside the restored database.

**Lean names.** The named `schedule`, `schedule_bounded`, `later_stop_exits`, three `selection` splits, `money_posts_at_most_once`, and `finished_unrecorded_exit` locations exist. Add `superseded_exits`. Preserve `exit_store`’s lost-reply alternative. `Claim.claim` currently accepts only `admitted` and the row; adding a field to `Guards` alone cannot fence claims. The new theorem must reach the claim transition and distinguish committed advances from aborted ones. `Claim.lean`’s “a second engine” omission statement also needs amendment. No proof result is asserted.

**Q2. CANNOT ACCEPT R as amended.**

**The open point: yes.** “Where the connection … is lost, the engine MUST claim nothing more” starts the prohibition before detection. Trace: backend disappears, engine has not observed it, pool connection claims. Without takeover, G correctly admits that claim; therefore G does not fix the wording.

The `CNF-366` detection cutoff is right, but “as its loud log timestamps the detection” requires a log that R never mandates. A successful bounded recording path can otherwise exit without that particular log.

Replace R’s opening loss clause:

> Where the engine detects loss of the connection carrying the startup lock, it MUST immediately stop beginning claims and periodic passes and log the loss with the detection timestamp. It MUST treat detection as a stop of every worker not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit non-zero.

Keep the remainder, with the lost-reply correction above. Also add to `CNF-366`’s successful-record fixtures:

> Keep the startup generation unchanged throughout these cases; no successor or out-of-band writer advances it.

Otherwise R’s “exit only after … lands” can contradict G’s “exit non-zero at once” after supersession. With that fixture and the explicit supersession exception, I find no further R/G conflict.

**Brief errors:**

- All quoted **before** spans match after normalizing line wrapping. The supplied free-id claims and PR #24 attribution match.
- “First statement” does not establish “holds nothing but the generation row”: the same transaction can subsequently acquire sweep locks. PostgreSQL confirms “A shared lock blocks other transactions from performing `UPDATE`”; the proposed ordering prevents the generation/tenant inversion, but the stated only-lock argument needs the transaction boundary above. [PostgreSQL locking](https://www.postgresql.org/docs/18/explicit-locking.html)
- Random generation does not establish absolute non-reuse. PostgreSQL says “Generates a version 4 (random) UUID”. Backup/PITR refresh avoids deterministic reuse, but historical uniqueness—including failed advances—needs a freshness mechanism surviving rollback. A collision violates G’s explicit MUST NOT, so I do **not** count collision alone as a conforming blocking trace. [UUID functions](https://www.postgresql.org/docs/18/functions-uuid.html)
- The restore timing analogy is misleading: `STO-54` bumps credentials in step (3), “Before the first `api` request”, after engine startup. G’s refresh must precede **either** component; it cannot simply accompany that bump.
- The proposed detection log and “unlanded” assertions are unsupported as detailed above.