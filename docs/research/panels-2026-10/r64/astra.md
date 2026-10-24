Reviewed `b90783d`. No gates or Lean commands run; no tracked files changed.

**Q1 — AMEND A; behaviour changed. Owner:** immediate exit sacrifices a record that could still land; no independent in-scope safety property requires that sacrifice.

For (b), a distinct promotion stop arriving before the first record lands satisfies `OPS-21`’s “one arriving after the stop being recorded and before that record lands”. But `STO-54` requires processes to have stopped; it does not necessarily require another signal.

What does lock-loss exit protect? Beyond the literal lifetime-lock policy, I found no independent requirement that fails without it. `STO-56`’s “once per process” is not a justification: promotion already requires stopping the old processes. The boot check cannot become a continuous guarantee.

Use a distinct `Event.lockLost`, an exit theorem, and amend `finished_unrecorded_exit`’s exit disjunction.

Touches: `OPS-47`, `OPS-21`, `CNF-366`, `ADR-0019`, new `ADR-0046`, `StopRecord.lean`. **Q1b:** immediate process exit, including without a prior stop; the replacement explicitly says so.

Draft replacements/additions:

> `OPS-47`, replacing its lost-connection clause: “where loss of the connection carrying it is detected, the engine MUST exit immediately, whether or not a stop or its record is pending.”
>
> `OPS-21`, replace “subject to the bounded abandonment and later-stop exits below” with “subject to the exits below”. Add:
>
> “Loss of the connection carrying `OPS-47`’s startup lock is another exit from a pending record. The worker MUST NOT begin or repeat a record transaction after detecting that loss. A transaction already sent retains its server-decided outcome; a row still `running` follows `OPS-15`, including its exceptions.”
>
> Add “the lock-loss exit” to the after-return exit list.
>
> `CNF-366`: “Drop the lock connection before the first record transaction, during it, and between repeats, for both cancellation and after-return records. Assert immediate engine exit and no new or repeated record transaction. Permit an already-sent transaction to commit with its effects once; otherwise assert restart classification under `OPS-15`, including its exceptions. Separately drop the connection without a preceding stop during `execute`; assert immediate exit and restart recovery.”

**Q2 — AMEND A plus D; behaviour changed. Owner:** choose marker-based determinism over the existing last-row classifier.

Keep A’s guarded Lean branches and goal-state precedence. Add a last-row marker theorem and a negative witness. Do not narrow `Rescue.governs`: its “scope and the table agree” theorem covers marker ownership, not merely settlement.

Use an explicit acceptance exception in prose. `PRV-5` requires a pre-send failure to report “`details.accepted: false`”, but `accepted_never_failed` also covers inconsistent marker/acceptance inputs.

No blanket `retryable: true` rule is needed: `DOM-17` requires “safe and sensible”; `WIR-9b` makes the operation view “authoritative”. Keep existing precedence.

`CNF-31a` needs no change: its assertions concern create and install. Add the requested unset-marker cases to `CNF-31b`/`CNF-362`, preserving their dispatched cases.

Touches: `OPS-11`, `OPS-21`, `CNF-31b`, `CNF-362`, `Tables.lean`, witnesses/negative controls, and `05-persistence.md`.

Draft last-row replacement:

> “Subject to the goal-state success rule, a failure the worker records MUST settle `failed`, whatever its kind, where `OPS-45`’s write-started marker is unset and no rescue session was opened or the session was closed without error, unless the mutation is known to have been accepted. Otherwise it settles `needs_reconciliation` if ambiguous, and `failed` otherwise. A release classifies exactly as a delete.”

Add that marker clause to `OPS-21`’s pointers. Apply D’s exact deletion. In `CNF-31b`, explicitly distinguish a failure before the marker write from a pre-send failure inside an already-dispatched call.

**Q3 — Separate Runs; mechanics:** the exit-policy and classifier counterexamples are independent.

**Against my picks — written on request.**

- **Q1:** A destroys useful in-memory outcomes after a harmless connection failure. B could preserve them within the existing bound; C removes an exit with no demonstrated independent safety benefit.
- **Q2:** B preserves the classifier’s simpler acceptance/ambiguity policy and avoids extra precedence rules. A also needs disciplined testing of the marker-write/dispatch gap.
- **Q3:** Both changes touch `OPS-21` and conformance prose; one Run could reduce integration drift.

**Brief errors.**

- **Keepalives do not exist only to detect lock loss.** `rg -n -A8 'Why a bounded wait' docs/adr/0019*` finds “reap a half-open session” and “the keepalive requirement is the actual cure”: successor-start availability is another stated purpose.
- **Pre-dispatch does not imply marker unset.** `rg -n -A3 'before that phase runs' 03-operation-lifecycle.md` finds `OPS-45`’s “before that phase runs”. A marker can commit before dispatch. The explicit null-marker example is sound; the brief’s broader statement needs qualification.
- **Draft A’s unconditional “writes no worker classification” assertion is too strong.** `rg -n -A9 'let the store decide' 10-conformance-checklist.md` finds `CNF-362`’s “Accept either outcome: the transaction committed”. Exit cannot undo a sent transaction.
- **Unamended A does not establish immediate exit without a stop.** `rg -n -A4 'Where the lock is refused' 03-operation-lifecycle.md` finds only “it MUST exit”, with no timing. A’s added pending-record clause does not resolve Q1b; my `OPS-47` amendment does.