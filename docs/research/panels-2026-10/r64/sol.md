Reviewed `b90783d`; no gates or Lean builds run.

**Q1 — AMEND A; behaviour changed. Owner:** this chooses immediate exit over preserving an outcome in hand.

A distinct, delivered failover stop meets `OPS-21`’s “one arriving after the stop being recorded”. However, `STO-54` requires processes to have stopped; it does not require another signal. PR #23 therefore does not eliminate every failover instance of the gap.

I found no independent, in-scope property protected by lock-loss exit. Neither the boot check nor `STO-56`’s “once per process” supplies a counterexample under the settled supervisor and promotion obligations.

Q1b: intend immediate process exit, without first cancelling and recording `execute`. Draft A alone does not state that timing globally.

Use `Event.lockLost`, a `lock_lost_exits` theorem, and extend `finished_unrecorded_exit` with that exit.

Touches: `OPS-47`, `OPS-21`, `CNF-366`, `ADR-0019`, `ADR-0044`, `StopRecord.lean`.

Draft:

> Replace `OPS-47`’s loss clause with: “where the connection carrying it is lost it MUST exit at once, without initiating a stop record or waiting for one; this applies whether or not a stop has arrived.”
>
> Add to `OPS-21`: “Loss of the connection carrying `OPS-47`’s startup lock ends a pending record at any point. After the loss is seen the worker MUST NOT begin or repeat a record transaction. A transaction already sent remains the server’s to decide; a row still `running` goes to restart recovery.”
>
> Retain A’s after-return list addition.
>
> `CNF-366`: repeat `CNF-362`’s later-stop cases with detected startup-lock connection loss, retaining its assertion “Accept either outcome”. Also lose that connection during `execute` without a stop; assert immediate exit without a cut-off record and restart recovery for any row still `running`.

`STO-7`’s “short of its process exiting” permits this exit despite a sent COMMIT.

**Q2 — AMEND A, plus D; behaviour changed. Owner:** resolves competing classification outcomes in favour of the null-marker evidence.

Keep A’s formal branches, including `!f.accepted`, and preserve `accepted_never_failed` unchanged. I favour stating the acceptance exception explicitly. `PRV-5` says “A failure before any byte of the mutating request was sent MUST report `details.accepted: false`”, but the theorem also covers arbitrary marker combinations.

Keep `CNF-31b`’s pre-send network expectation with its marker set; add A’s unset-marker cases. `CNF-31a` stays unchanged. `Rescue.Install.governs` stays unchanged.

No blanket `retryable: true` amendment is needed: retain `DOM-17`’s “safe and sensible” guidance and `WIR-9b`’s precedence.

Touches: `OPS-11`, `OPS-21`, `CNF-31b`, `CNF-362`, persistence-column prose, `Tables.lean`, new `ADR-0046`.

Draft replacement classification rule:

> After the goal-state success rule, a failure the worker records MUST settle `failed`, whatever its kind, when the write-started marker is unset, either no rescue session was opened or it was closed without error (`OPS-45`), and the mutation is not known accepted (`details.accepted` is not `true`). Otherwise, `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one.

Add that marker clause to `OPS-21`’s pointers. Delete `CNF-362`’s existing pre-dispatch no-assertion sentence. Apply D’s specified deletion from `05-persistence.md`.

**Q3:** Separate Runs: record abandonment and failure classification have independent acceptance evidence.

**Against Q1, written on request:** A discards a successful provider outcome after an unrelated connection failure, despite no demonstrated safety benefit. B could preserve it within the existing record bound, while `STO-54` still prevents reaching the promoted store before shutdown completes.

**Against Q2, written on request:** B preserves the classifier’s existing conservative behaviour and avoids expanding its dependence on marker timing. A changes automatic settlement and relies on implementers preserving the distinction between an unset marker and a request that merely never reached the provider.

**Brief errors**

- **The proposed Q1 drill is too strong if “writes no worker classification” excludes an already-sent transaction landing.** `rg -n -A8 'The sent transaction.s fate' 10-conformance-checklist.md` shows `CNF-362`: “Accept either outcome: the transaction committed”.
- **A alone does not specify Q1b’s immediate exit.** `rg -n -A15 '^\*\*OPS-47' 03-operation-lifecycle.md` shows only “where the connection carrying it is lost it MUST exit”; A’s added rule addresses a pending record.
- **Pre-dispatch does not itself imply `failed`.** `rg -n -A4 'An operation settles|before that phase runs' 03-operation-lifecycle.md` shows the condition “when the write-started marker is unset” and that it is written “before that phase runs”. A stop between marker acknowledgement and dispatch remains outside that exception.
- **Q2’s additions must remove the existing exclusion.** `rg -n -A1 'Make no assertions about power' 10-conformance-checklist.md` shows `CNF-362` explicitly excluding these pre-dispatch cases.