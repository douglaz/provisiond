Reviewed the merged r66b proposal against `d78085a`.

**Q1. CANNOT ACCEPT G — one blocker: restore exposure precedes the fence.**

Span 19 requires:

> “The transaction that commits that record MUST also write a fresh `STO-59` startup generation”

But [STO-56](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/05-persistence.md#L1338) orders the record only:

> “before either component is started”

That does not order access by an already-running survivor—the case `CNF-370` expressly introduces.

Trace:

1. E holds generation `g`; the backup contains `g`.
2. Restore that backup, making the restored database reachable while E survives. No replacement component starts.
3. Before the restore-record transaction commits, E reconnects and checks the restored `g`. Equality succeeds; its next write commits.
4. The restore procedure subsequently commits the record and fresh generation `h`, still before either replacement component starts.

The engine obeyed `OPS-50`; the restore obeyed the proposed ordering. Nevertheless, `CNF-370`’s assertion that “the survivor’s next write is refused” fails. This meets the brief’s **CNF-verdict gate**. It is a pre-advance exposure window, not a failure of the share-lock protocol after the advance.

**Replace span 19’s added sentence with:**

> The transaction that commits that record MUST also write a fresh `STO-59` startup generation. The restored store MUST remain inaccessible to every engine process, including a surviving process, until that transaction’s commit is acknowledged. Only then may a survivor reach `OPS-50`’s generation check.

**[took] choices.** I contest the restore-record anchor only as a sufficient ordering rule: keep the atomic record/generation transaction, and add the admission boundary above. I also contest span 16’s characterization of `CNF-290`, non-blockingly, below. I found no blocking counterexample to the other choices.

**Identifiers and pointers.** The proposed next identifiers are free: the existing maxima are `OPS-49`, `STO-58`, `CNF-365`, and `ADR-0046`. The restore correction belongs in `STO-54`; `STO-56` can remain a pointer. The listed pointer-only amendments introduce no independent behavior when confined to references to the owning requirements. I found no engine write escaping the universal phrase “every write transaction made in the engine process.”

**Non-reuse.** It is required, but not established by the prescribed generator. PostgreSQL describes `gen_random_uuid()` as “Generates a version 4 (random) UUID”; randomness alone does not prove historical uniqueness, especially across discarded histories. [PostgreSQL UUID functions](https://www.postgresql.org/docs/18/functions-uuid.html). I do not count collision as a second conforming counterexample: `STO-59` explicitly prohibits reuse. Implementation and formal review must distinguish that obligation from an assumption that random generation satisfies it.

**The conformance items:**

- `CNF-367`: the out-of-band advance isolates generation refusal without startup-lock refusal.
- `CNF-368`: the separate, acknowledged advance puts the sweep after the fixture’s commit.
- `CNF-369`: sound with the fixture session kept alive beyond the bound and other startup prerequisites working.
- `CNF-370`: fails under the trace above; enforce the admission boundary before driving the survivor’s write.

**Lean names.** The `StopRecord` changes fit `schedule`, `schedule_bounded`, `later_stop_exits`, the `selection` splits, and the proposed `superseded_exits`. Preserve `exit_store`’s lost-reply alternative; record the extra disjunct in `finished_unrecorded_exit`.

For `Claim.engineStep`, also account explicitly for `lost_claim_reply_exits`: its existing conclusion includes a `running` row. That conclusion describes a submitted claim’s lost reply, not a generation refusal that leaves a queued row unchanged. `superseded_never_commits` needs its refused/admitted witness pair and explicit freshness and transaction-order assumptions. These are source-level observations, not built proofs.

**Q2. ACCEPT R as merged.**

I found no blocking contradiction with G or the surrounding stop rules.

R says:

> “The loss is not a later stop: a record already pending when the loss is seen continues under its own Stop-record bound and exits.”

G supplies the distinct terminating event:

> “A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost.”

Thus lock-loss detection preserves a pending record; an observed generation mismatch ends it. With generation unchanged, `CNF-366` tests the former. Its store-recovery timing, detection-anchored later stop, and explicit store-error case avoid demanding successful recording after a permitted abandonment.

The detection anchor also avoids requiring claims or periodic passes to stop before the engine can observe the loss. I found no remaining MUST that this anchoring necessarily breaks.

**Q3. (A).**

Keep rollback admissible and state the temporary loss of fencing explicitly. The deciding cost is that B turns recovery from a bad first G release into a restore incident. A retains the existing deployment obligation in `OPS-47`:

> “The engine MUST run as exactly one process under an external supervisor that restarts it and never runs two.”

The admitted residual trace is exactly the brief’s: a checked survivor retains `g`; the rollback binary neither advances nor checks it; both can write. That is a disclosed rollback limitation, not a reason to claim G remains effective during rollback.

**Brief errors**

1. **Span 16:** “What this drill does not exercise is the generation fence” is too strong. `CNF-290` says “restart it” and then drives “the old process’s late settled-state write.” Under the amendments, the restart advances the generation and that late write encounters `OPS-50`. The drill does not independently establish the fence’s necessity, but it can exercise it.

   **Replacement:**

   > For the dedicated generation-fence drills, see `CNF-367`–`CNF-370` (`OPS-50`).*

2. **The general claim that `STO-54` excludes two writable copies overstates the quoted provision.** The cited “old primary MUST NOT serve a component again” occurs in the promotion procedure, alongside “Before any component connects to the promoted store.” It does not explicitly impose that exclusion on every backup restore.

   **Replace that part of `OPS-50` with:**

   > Nor does it fence two writable copies of the database; its guarantee covers one writable database history.

The quoted PostgreSQL timeout claim checks out: “A value of zero (the default) disables the timeout.” [PostgreSQL connection defaults](https://www.postgresql.org/docs/18/runtime-config-client.html). The positive-bound amendment addresses zero.

No gates or Lean commands were run. The working tree is clean.