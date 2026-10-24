Reviewed r65b’s forms against `b90783d`. No gates or `lake` run; no tracked edits.

**Q1. R: ACCEPT. E: ACCEPT. Pick without G: R.** S3 is decisive: preserving an accepted cancellation’s date avoids operator resolution. `OPS-3` lists resolution through “`OPS-27`’s sweep or `OPS-31`/`WIR-35`’s operator verb”; the sweep is create-shaped. S4 independently favors R without misconfiguration.

**Fixes 1–9: all right.** This confirms their textual and structural coverage, not Lean compilation. E explicitly acknowledges the weakening of `finished_unrecorded_exit`.

**E’s placement: wrong editorially, nonblocking.** Move its insertion after the paragraph ending “`OPS-15` classifies the row as interrupted”, as R does.

**S5, worker reading:** E leaves unrecorded post-pass rows `running`. R records them if no bound, later stop, or other process-exit condition intervenes; a different worker’s zero-row settlement does not terminate them.

**S5, engine reading:** E again strands unrecorded post-pass rows. R can record some before its first zero-row settlement exits the engine; remaining rows strand. A sent transaction may still commit.

**Against my pick:** R permits additional activity after detecting lost exclusivity, including already-running periodic passes. E offers a simpler, immediate process boundary. R’s advantage requires a store that accepts records before either bound expires, and its S5 advantage can disappear under the engine reading.

**Q2. ADOPT G. Sound: YES as a database-write fence.** Require the generation comparison and protected writes in one transaction, retaining the share lock through transaction completion. PostgreSQL says: “A shared lock blocks other transactions from performing `UPDATE`”. [PostgreSQL locking](https://www.postgresql.org/docs/18/explicit-locking.html)

- **(a)** A preceding guarded write exists, but can precede the advance. Trace: E1 acknowledges step 8; E2 advances and sweeps; E1 dispatches step 9 before detecting loss. `OPS-43` requires only “Step 9 MUST begin only after step 8’s transaction is acknowledged.” G does not retract that authorization. The same gap exists after markers.
- **(b)** No universal finite takeover duration. Statement/lock timeouts bound attempts; an idle partitioned transaction is addressed by the idle timeout. PostgreSQL describes it as “waiting for a client query”. [Timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html) But synchronous commit retains locks: “transaction locks continue to be held until the transfer is confirmed”. [Replication](https://www.postgresql.org/docs/18/warm-standby.html) `STO-7` says “A standby wait has no server-side timeout”. Define startup retry/exhaustion explicitly.
- **(c)** Safety rests on one authoritative shared database and complete transactional coverage. Timeout configuration affects availability, not permission to bypass G. Across promotion, infrastructure obligations remain: `STO-54` says “the old primary MUST NOT serve a component again”.
- **(d)** Yes: G reinstates the substance of the rejected **corrected** predicate, then extends it to other writes. It is not the defective self-stamped operation epoch. `ADR-0019` explicitly calls its rejected claim guard “Correct, and cheap.”
- **(e)** No. Keep R; its ordinary single-engine benefits remain.
- **(f)** The list is incomplete. `OPS-15` and `OPS-5` definitely belong. Also address `STO-1`’s claim contract, `OPS-6`’s second-engine disclaimer, `OPS-49`’s mismatch/retry handling, schema/migration ownership, and `CNF-290`’s scope disclaimer. Specify lock ordering consistently with `STO-3`’s “that lock is the transaction’s entry”. G guards on generation; it need not falsely rename the advisory lock itself a fence.

**Q3.** Strongest case for A: it permits recording only after a fresh exclusivity check, reducing overlap while preserving some R outcomes. My answer: that check can reject useful work because E1’s own session remains, and can become obsolete before recording. G supplies the transactional property A lacks.

**DON’T ADOPT A. Sound: YES as a reacquisition checkpoint; under G: moot.** Judge soundness against its stated admission contract; judge usefulness against R. Its deliberate fallback to E is an availability/outcome cost, not independently an incorrect admission. It can prevent writes the existing guards admit: E1’s untouched post-pass rows. Those are precisely useful records it should preserve under R’s policy. This explains the apparent baseline disagreement.

**Brief errors:**

- **Missing A definition:** Q3 begins “exits at once.” I assumed a fresh-session reacquisition attempt before recording, refusal causing immediate exit.
- **`correlator: none` equivalence is false.** After acknowledged step 8, before step 9, R records `failed`; E restarts into reconciliation. `CNF-361` exercises “both an auction channel and a standard channel”.
- **Provider-call cut-off generalization remains false.** Refresh’s `OPS-11` row says “Always `failed`”; absorbed reads also contradict the universal.
- **S1/S2’s E outcomes omit disappearance.** `OPS-27`: “the operation resolves *absent*” when the confirming read finds absence past the visibility window.
- **S1/S5 overpromise R completion.** `OPS-21`: “whichever ends first ends the record”. A working store inside the Stop-record bound alone is insufficient; the same qualification applies to the worker-reading trace.
- **S5 still overstates machine blocking.** `05-persistence.md` defines `operations.machine_id` as “nullable; set on completion for create”. Non-yielded creates need not block any machine.
- **G step 5 omits startup exceptions.** `OPS-15`: refresh “MUST be settled `failed`”; null-column creates likewise; parents “MUST be returned to `queued`”.
- **G’s dispatch discussion omits the committed-write/late-dispatch trace in (a).**
- **A’s quoted “succeeds only after an in-place restart” is false.** Terminating only the lock backend releases its session; E1 can reacquire without restarting PostgreSQL.
- **“PRV-29 … names no writer but the operator” misattributes the conclusion.** That requirement names evidence, not an operator writer. `OPS-3` and `OPS-31` establish the resolution path.

The r64/r65 vote histories are absent from this clone, so I have not independently verified those tallies.