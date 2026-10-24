Reviewed r64b’s forms against `b90783d`; static review only, no gates or `lake`.

**Q1 — R: CANNOT ACCEPT as written. E: ACCEPT. Pick: R, with the repair below.**

R’s added `OPS-21` sentence, “For a worker in `execute` it is the cancellation being recorded”, loses an existing exception. Trace: a create’s confirming read succeeds; during its post-order read, the lock loss is detected. R directs cancellation and a cut-off record. But `03-operation-lifecycle.md`, `OPS-21`, says that stop “MUST NOT cancel `execute`”. `CNF-362`’s absorbed-read case requires `succeeded`, “no `needs_reconciliation` and no `cut_off`”. The parent also needs its defer, not an error.

Replace R’s sentence beginning “For a worker in `execute`” with:

> For a worker in `execute`, the loss follows this requirement’s stop rules, including the case that “MUST NOT cancel `execute`” and the parent’s defer, which “records no error”. For one whose `execute` has returned, its settle write records it; the loss ends no record already pending.

Replace R’s `CNF-366` execute-case assertion with:

> Outside `CNF-362`’s absorbed-read and parent cases, assert the cut-off classification against the kind’s row. Repeat those absorbed-read and parent cases with lock loss as the stop, asserting their respective outcomes.

My strongest reason for R is preserving verified outcomes and known execution position when recording remains possible. The no-correlator argument in the brief does **not** support that preference; see below.

**Against my pick:** R prolongs overlap with a mistakenly started successor. Row guards protect particular transactions, but they do not establish exclusive engine execution. Already-running periodic work and outstanding provider calls remain concerns, and the successor’s startup pass can still defeat the old worker’s record.

**The owner’s question:** A separate “do I still hold the lock?” read is insufficient: ownership can change between checking and writing. An application-level database fence could serialize takeover against every claim and engine-write transaction using a globally authoritative generation checked while holding a transaction lock. It must compare against shared authority, unlike the deleted self-stamped epoch.

That amends `OPS-47`’s “no write is guarded on it”, `STO-51`’s “guards no write”, and the claim/write contracts. It costs coordination, contention, and discarded outcomes after takeover. It still cannot retract an outstanding provider request; complete exclusion needs provider-side enforcement or assured termination. This explicitly reopens `ADR-0019`’s scope decision, rather than presenting a lock check as equivalent protection.

**Q2 — M: ACCEPT with [P], without [Q].**

- **[P]: YES.** It aligns the prose with `!f.accepted` and `accepted_never_failed`; `OPS-11` says later errors “MUST NOT classify that accepted mutation `failed`”.
- **[Q]: NO.** Its unset-marker universal omits acceptance and rescue cleanliness. For example, accepted=true, goalStateHeld=false and marker unset still produces `needsReconciliation` in M.
- **Read whole:** With those selections, no new contradiction found. The proposed theorem fixes goal-state evidence false, and the cut-off witness does not depend on the goal-state switch. These are source-level conclusions, not build results.

**Brief errors**

- **The no-correlator success story is unreachable as stated.** `OPS-27` says: “A create MUST NOT settle `succeeded` on the strength of the reply in hand alone.” Its non-authoritative-search row explicitly includes “no verified correlator exists” and requires “Unresolved. Escalate to an operator”. Such a create already requires an operator under R; E does not newly impose that burden.
- **R’s Q1b universal is false.** `OPS-21`’s absorbed-read exception says “MUST NOT cancel `execute`”; its parent provision says “It records no error.” Neither records the asserted cut-off conflict.
- **Correction 6 overgeneralizes request-building failures.** A set marker does not itself make every failure ambiguous. `OPS-11`’s last row says “otherwise `failed`”; an unaccepted `invalid_request`, without goal-state success, remains `failed` even with the marker set.
- **The overlap explanation needs the defer exception.** Its zero-row exit describes settlement writes. `STO-3` says a zero-row defer means “already deferred or already claimed again; the worker moves on and does not exit”. The row-protection argument survives, but its claimed exit is not universal.