04-api-contract.md
**API-64** **ADDED 2026-09-08 (`ADR-0017`) — a stalled episode is retried by an operator, and by
nothing else.** `POST /v1/episodes/{id}/actions/retry` (`WIR-51`) is **operator-only** (`WIR-34`)
and is admissible only on an episode in `stalled` (`DOM-31`): it moves the episode to `attempting`
**by a conditional write guarded on `(id, state = stalled)`** and enqueues a fresh `delete_machine`
attempt under it, both in one transaction, and answers `200`
with the episode view. In any other state — including where that write affects no row because a
gone-write closed the episode after the operator read it (`OPS-48`, `ADR-0021`) — it is refused
`409` `conflict` with `details.reason: "state"`. It is idempotent under `WIR-24`'s one-transaction rule — the state change, the enqueue and
the idempotency record commit together — and it counts against `SEC-39`'s operator retry ceiling
(`API-7` step 5c). **A `stalled` episode is never retried by a timer** (`OPS-48`): the attempt
settled `failed` because the provider rejected it and did not act, and repeating a deterministic
rejection automatically is the loop `OPS-39` exists to prevent. *Amended 2026-10-08 (`ADR-0035`):* throttle classification follows `OPS-11`'s
"the operation's mutating request was accepted by the provider" condition, and episode effects
follow `OPS-48`: a pre-acceptance refusal can stall; post-acceptance ambiguity is `uncertain`,
where this retry verb is inadmissible. `F48` retains the rejected automatic-deferral history. The
episode, not the `failed` attempt row, is what
outlives `STO-14`'s retention, which is why the verb is on the episode (`ADR-0017`).

*Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`): The new attempt is stamped
`requested_by: operator`, with its non-null `episode_id`, in the enqueue transaction;
these fields identify its origin across claims and restarts.
Keeping the machine is the distinct `API-68` verb.*

*Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`): `OPS-41` step 2 owns the retry
guard.*

