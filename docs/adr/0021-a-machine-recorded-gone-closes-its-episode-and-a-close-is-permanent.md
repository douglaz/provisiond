# A machine recorded gone closes its open episode, and a close is permanent

**Status:** accepted (2026-09-09). Completes `ADR-0017`: that ADR gave the episode its states and
keyed every transition on how an attempt settled; this one adds the transition that is keyed on the
machine, and deletes an exit the diagram drew that nothing provided.

## The problem as found

`DOM-31`'s diagram drew `stalled --> closed : abandoned`. The only `abandoned` in the set is
`OPS-31`'s operator verb on an attempt in `needs_reconciliation` — the exit from `uncertain`. A
`stalled` episode's attempt is `failed`, a settled state the resolution verbs cannot reach, and the
episode's one verb, `retry` (`API-64`), opens a fresh attempt. So the edge had no provider.

Two independent reviews of one brief — Codex and a fresh Claude reader — agreed the edge should go,
and both found the same thing behind it: when a provider account is recorded `terminated`
(`API-63`), every machine is recorded gone and tombstoned, but an episode already open on one stayed
open, its fence set, in `OPS-26`'s listing forever. `OPS-39` said so in as many words — "A
tombstoned machine keeps any episode that is still open" — while `API-63` called exactly that
outcome, for episodes minted *after* the termination, "a different failure". The same hole sat
behind `LDG-74`'s evidence write: a machine the provider deleted behind the system's back had its
meter stopped and its episode left open, until an operator retried a delete for the bookkeeping.

## The decision

- **A machine's gone-write closes its open episode `resource_gone` and clears the fence, in that
  transaction.** The gone-write is the write of `machines.state` to gone with `state_observed_at`
  (`STO-48`), by any of `LDG-74`'s triggers — a refresh, a driver read during any operation,
  `OPS-32`'s complete pass — or by `API-63`'s termination. It applies in every open state,
  `scheduled` included: a resource independently established gone before its effective date is the
  earlier end `DOM-19` and `STO-8a` now admit. The two writes that could race it are guarded
  against it: `retry` is a conditional write on `state = stalled`, and `OPS-42`'s fence write is
  guarded on the episode being open.
- **The trigger is the machine's gone-write, never the account's status.** A machine `OPS-36`
  attaches under a terminated account has been observed present, carries no gone-write, and its
  cleanup episode stalls as `API-63` already says. Termination establishes that the resources it
  covered are gone (`SEC-46`), not that a resource observed later is.
- **A close is permanent.** `OPS-48`'s attempt-keyed rows apply to an open episode only. An attempt
  under a closed episode that later settles, or is resolved under `OPS-31`, changes the attempt and
  not the episode; `OPS-25` still retains the unresolved attempt, and `STO-52`'s `closed_at` and
  `close_reason` are write-once.
- **`API-63` fails queued, never-claimed system cancellations as it fails creates**, on the same
  reasoning: they have touched no provider. The write is guarded on `status = queued` and
  `requested_by = system`; a claimed one loses that race and settles as its own worker's write
  under an episode that is already closed.
- **Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`).** The stalled `abandoned` edge remains
  withdrawn; the later operator decision has its own home in `API-68`. The retry-as-withdrawal
  argument and the sweep-close suspension exemption are superseded. `OPS-41` and `OPS-48`
  hold the current scope and transitions.

## Considered options

**An operator `abandon` on a `stalled` episode.** Originally rejected because retry was treated
as a withdrawal path. *Superseded 2026-10-04 by `ADR-0032`: that premise is withdrawn; the
explicit operator decision is `API-68` keep. The remaining unfunded-machine sweep consequence
belongs there, rather than being an accepted no-exit residual here.*

**Closing episodes only at `API-63`.** Rejected because the gap is the gone-write's, not the
termination's: `LDG-74` had the same hole for a machine the provider removed on its own.

**Leaving the episode open and having `retry` find the goal state.** The path exists — `OPS-11`'s
goal-state rule classifies "already deleted" `succeeded` — but it re-issues a provider mutation for
bookkeeping, counts against `SEC-39`'s retry ceiling, is pinned to no provider's code for a machine
delete in `08-provider-notes.md`, and never returns that answer on a dead account.

## Original consequences (2026-09-09; operator paths superseded by `ADR-0032`)

- `DOM-31`'s diagram loses the `abandoned` exit from `stalled` and gains a `machine recorded gone`
  exit from every open state. `CONTEXT.md`'s Episode entry says what closes one and what does not.
- `OPS-48` gains the gone-write row, the permanence rule and the two guards; `OPS-39`'s "keeps any
  episode" sentence is replaced; `OPS-41`'s scope and its abort's close are amended; `OPS-42`
  stated the stalled residual and retry route (superseded 2026-10-04), and its fence write is guarded on the episode
  being open; `OPS-26` names the gone-write exit. `STO-52`'s close columns are write-once;
  `machines.destroy_committed` lists the gone-write among what clears it.
- `API-63` closes the episodes and fails the queued system cancellations under a stated guard;
  `API-64`'s state change is a stated conditional write; `LDG-74`'s recording bullet closes the
  episode. `DOM-19` and `STO-8a` admit the earlier end.
- `CNF-64`, `CNF-278`'s termination case, `CNF-271` and `CNF-272` are extended; `CNF-272`'s "fund
  the machine" step, which the fence refused, is corrected.
- `11-open-findings.md`: `F49`.
