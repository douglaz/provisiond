## Exact option A — retain the per-restore instant on every retry

A keeps the two STO-56 supersession/retry paragraphs printed above verbatim. It replaces only the passages listed A1–A9 below. Its proposed selected event time precedes the first establishment attempt and follows existing stopping/fencing requirements; it is reused even if the first transaction aborts. The changes in the reporting upper-bound recipe are part of A, not a new test or precision rule. The lower-bound recipe, endpoint certificate obligations, unknown path, step-(3) grace anchor and continuation reuse are the printed STO-54 text. Check every collateral consequence rather than presuming these replacements are enough.

### A1 — exact replacement for `05-persistence.md:1636–1640`

```text
  For backup restore and restore-class promotion, restore_instant is the event time selected
  and retained under STO-56 before the first establishment attempt for this actual restore.
  This is the event time of that selection, not the time of the recovered history or of a
  later inserting transaction. The selection occurs after the existing stopping/fencing
  requirements are satisfied. Its clock definition is new; it is not claimed as a fact
  already proved by the formal model.
```

### A2 — exact replacement for `05-persistence.md:1660–1666`

```text
  A verified upper error bound on the selected event time's clock, with retained
  stopping/fencing evidence that no old-history acknowledgement follows that selection,
  can supply f=restore_instant+e_event. Source and event clocks may have different error
  bounds; record their provenance. If either endpoint cannot be certified, persist null for it
  and say that endpoint is unknown. The event timestamp alone never substitutes for a missing
  history bound. Retain evidence outside the lost failure domain or with the incident so that
  continuation does not depend on the failed primary.
```

### A3 — exact replacement for `tools/formal/Provisiond/Restore.lean:21–28`

```text
`Params` lists the guards dated amendments added, each a field so that removing it is a one-token
change a witness theorem exercises (`ADR-0025`). Every model here is one tenant, one machine, one
engine (`OPS-47`), and time does not advance: `now` abstracts the selected event time.
`STO-54` defines that event: "restore_instant is the event time selected and retained under
STO-56 before the first establishment attempt for this actual restore." This model does not
establish the clock selection or model recovered-history bounds. Interval/certificate
publication and its evidence protocol remain outside the model's scope.
```

### A4 — exact replacement for `tools/formal/Provisiond/Restore.lean:95–98`

```text
/-- `STO-56`'s restore record: `restore_instant`, and `grace_ends_at`, which "is null until step
(3) of `STO-54`'s procedure is marked". The `Provisiond.Claim.RestoreRecord` it extends is the
view a claim reads. `restoreInstant` abstracts the selected event time defined by `STO-54`,
not a recovered-history endpoint; the reporting endpoints and certificates are omitted. -/
```

### A5 — exact replacement for `tools/formal/Provisiond/Restore.lean:156–158`

```text
/-- `STO-54`'s trace: the backup holds the store `delta` steps before the crash, the provider's
facts are the crash's, and `now` abstracts the selected event time defined by `STO-54`,
independently of the recovered history. -/
```

### A6 — exact replacement for `tools/formal/Provisiond/Restore.lean:165–167`

```text
/-- The restored store: every row as the backup held it, with `applied` as the provider holds it,
and the record open, carrying its retained selected event time — committed before the engine starts,
so no run of the model has a window in which it is absent. -/
```

### A7 — exact replacement for `tools/formal/Provisiond/Restore.lean:431–439`

```text
/-- The successor. The crash clears `STO-51`'s session-scoped lock and this process's `passDone`.
The procedure marks, including `stepTwoMarked`, are the record's and stand, which is how
"a marked step does not run again" survives the process
that made the mark. The mode is the record's, and the instant is "read from the record and never
re-computed" — this model has no second clock to contradict it, so the parameter below decides the
mode and not the instant. That instant remains the selected event time defined by `STO-54`, not a
history bound. Everything else here is the store's or the trace's: the operator's
confirmation is the rows it moved, and `secondOrder`, `servedGens` and `parentResumedUnconfirmed`
record what has already happened. -/
```

### A8 — exact replacement for `tools/formal/Provisiond/Restore.lean:545–546`

```text
/-- `STO-54`: the engine comes up on the restored store; `t.now` is the selected event time
retained by the record, not the time of the recovered history. -/
```

### A9 — exact replacement for `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:252–270`

```text
This supersedes the numeric-report clause under *The decision* above. The reporting contract
and its arguments belong to `STO-54`: “A bound without valid evidence is unknown, not an invented
recovery time.” The retry-clock amendment replaces UO's original inserting-transaction definition. `STO-54`
now defines the event: “restore_instant is the event time selected and retained under STO-56
before the first establishment attempt for this actual restore.” For the endpoint fields and incident-keyed retained
evidence/unknown-reason reference, see `STO-56`; for the human deployment procedures, see
`OVR-19`. The scenario and fixture inventory is `10-conformance-checklist.md`, with the reporting
rehearsal in `CNF-295` and operator-promotion cases in `CNF-365`.

The accepted uncertainty does not impose finite-only admission: `STO-54` says “Missing reporting
evidence does not hold incident creation, the existing restore procedure or component startup
once its existing prerequisites are satisfied.” The stopped-system ordering remains the decision
in `ADR-0047`. The derivation-index obligation is separate: `05-persistence.md`'s
`deposits.derivation_index` row says “Allocated strictly increasing and never re-issued”. This
amendment adds neither an allocation-evidence admission gate nor a proof of the configured gap.

The synchronization in `tools/formal/Provisiond/Restore.lean` changes documentation only.
The selected event time is the abstraction used by `restoreInstant`/`now`;
`Event.completeProcedure` retains step (3)'s separate instant. Clock selection and the
reporting-certificate protocol remain outside that model's scope; compilation proves neither.
```

No Lean declaration, assignment, theorem or guard hypothesis is replaced by A’s printed form; the proposed formal edits are the exact documentation replacements above. Review whether this claim holds for the model’s arbitrary `Nat` event time and whether the meaning change needs any further paired declaration amendment. A new theorem or runtime test is a separate answer under question 4, not an implicit part of A.

