# A cancellation episode is an entity, `failed` is a fact about an attempt, and requeue is deleted

**Status:** accepted (2026-09-07). Completes what `ADR-0014` began: that ADR deleted requeue for
creates and left it one kind; this one gives that kind a home of its own and deletes the verb.

## The problem as found

A system-triggered cancellation — "this machine's exhaustion", "this account's loss" — is an
*episode*: minted once, reused by every sweep until the exposure ends. The word appears some forty
times in `03-operation-lifecycle.md`. **It had no row.** It lived as an entry in a JSON column on
the machine (`machines.system_trigger_ids`), a fence on the same row (`machines.destroy_committed`)
holding the *current attempt's operation id*, and a convenience copy on the operation. Its lifecycle
was `OPS-44`'s six-row table of side effects keyed on how the *operation* settled. Its recovery was
"requeue that same operation", which existed only because the dedup entry blocked a fresh enqueue —
and which in turn required the `failed` operation row to outlive `STO-14`'s retention. It did not:
past the retention age the fence pointed at a deleted row, nothing could ever present that id
again, and the machine billed forever behind a permanent `conflict` on extend-runway. `CNF-212` and
`CNF-271` each tested one half of that and both passed inside the window.

The 2026-09-07 review's first remedy was a retention exemption for referenced rows. It would have
worked. **The actual defect was that `failed` was being asked to mean two things**: a terminal fact
about one attempt — the provider rejected it and did not act — and an unsettled state of the
episode, which is still open, still billing, and waiting on a decision. The attempt row was standing
in for an entity the model lacked.

## The decision

- **Episode is a first-class record** (`DOM-31`, `STO-52`): the machine, the key (`delete` for an
  exposure-reducing cancellation, the `system_reason` for every other trigger — `OPS-39`'s
  2026-08-14 key rule, unchanged), the **set** of reasons that contributed, when it opened, the
  current attempt's operation id, and a state. **At most one open episode per machine and key** is a
  partial unique index — `OPS-39`'s dedup, enforced by the store instead of by an atomic claim on a
  JSON column.
- **Five states**: `attempting` (an operation is queued or running under it), `uncertain` (the
  attempt is `needs_reconciliation`, and `OPS-31`'s verbs on that operation resolve it), `stalled`
  (the attempt settled `failed` — the provider did not act, and a decision is owed), `scheduled`
  (the provider accepted a future date; ends when the machine is tombstoned, `DOM-19`), and
  `closed`, carrying why. `OPS-48` is the lifecycle; `OPS-44`'s table becomes its transitions.
- **The fence holds the episode.** `machines.destroy_committed` keeps its name, its conditional
  write and its contention with `LDG-62`'s extend-runway, and now holds the **open episode's id**.
  It points at nothing retention deletes.
- **Recovery is an operator verb on the episode** — `retry` (`API-64`, `WIR-51`) — which enqueues a
  fresh `delete_machine` under the same episode. **A `stalled` episode is never retried by a
  timer.** A deterministic rejection repeated automatically is the loop `OPS-39` exists to prevent;
  the transient cases are already deferred rather than failed (`OPS-11`).
- **Operation states are untouched.** `failed` stays terminal *for the attempt*; `needs_reconciliation`
  keeps meaning "unknown". What the episode carries is the third thing the operation could not:
  *known, and not done*.
- **Requeue is deleted.** `OPS-46` had reduced it to one kind; that kind's recovery is now an episode
  verb, so it has none. `OPS-4`'s requeue branch, `OPS-18`, `OPS-20`, `OPS-34`, `OPS-46`, `API-19`,
  `WIR-28` and the glossary entry go, with `README.md`'s withdrawn-identifier index carrying the
  numbers. Every requirement the 2026-09-07 review found still describing an ordering, adopt,
  install, power or reverse-DNS requeue — `API-7`'s two steps, `PRV-13`'s third growth path,
  `LDG-62`, `LDG-39`'s parked-fee clause, `OPS-45`'s marker reset, `PRV-40`'s budget line,
  `OPS-27`'s "one per attempt" — is deleted rather than patched, under `README.md`'s rule that
  withdrawn wording recording a fact that changed is deleted outright. `ADR-0014`'s consequence
  bullet listing five admissible kinds is annotated, not rewritten.
- **`STO-14` is unchanged.** Settled operations age out; the episode is what outlives them, and it
  is the only thing that needed to.

## Considered options

**A retention exemption for referenced operations.** One predicate in one job, and the smaller diff.
Rejected because it keeps an attempt row alive to impersonate the episode, which is the confusion
that produced the defect, and because it leaves requeue — a verb with one kind and a fixture that
contradicted its own prose — in the set.

**A new operation state** (`failed_pending`, `needs_operator`). Rejected because it would put the
episode's unsettledness on the attempt again, from the other side: an operation that "failed but is
not settled" is the sentence this ADR exists to stop anyone writing.

**Requeue minting a successor operation and repointing the fence.** Rejected because it changes
what the glossary said requeue was, and because once the successor is an ordinary enqueue under an
open episode there is nothing left of requeue but the name.

## Consequences

- `OPS-39`'s "the id MUST outlive the operations that carry it" is now trivially true — the id is a
  row, not an entry in a list — and its atomic-claim language is replaced by the index.
- `OPS-26`'s operator listing shows open episodes in `stalled` and `uncertain`, not "failed
  cancellations": the episode is the unit of attention, and an attempt is its history.
- `API-58`'s suspension fan-out joins an open `delete` episode by naming it, as it already did by
  naming its queued delete; the join is a row reference instead of a JSON match.
- `CNF-212` and `CNF-271` are rewritten against the episode: retention deletes the first attempt's
  row, the episode stays `stalled`, `LDG-62` is still refused, and `retry` enqueues a second attempt
  under the same episode id. `CNF-291` asserts the partial unique index refuses a second open
  episode per machine and key.
- The 2026-09-07 review's blockers 6.1 (requeue contradictions) and 6.4 (failed-cancellation
  retention) are both closed by this ADR: the first by deletion, the second by not arising.
