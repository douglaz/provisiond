# A store error is a bounded retry, every worker write is idempotent under repeat, and it carries its claim number

**Status:** proposed (2026-09-10); accepted when the amendments under *Consequences* land, under
`AGENTS.md`'s rule that the rule lands before the record. Answers the first of `impl-report-01.md`
§6.15's four production-operability gaps — "the response to a database that is reachable but too
slow" — which `ADR-0015` recorded as "New operational surface the set does not yet specify" and
nothing since had taken up. Does not amend `ADR-0016` or `ADR-0019`: the engine is still one
supervised process, and the term this ADR adds is not a fence against a second one.

## The problem as found

`STO-7` puts `statement_timeout`, `lock_timeout` and `idle_in_transaction_session_timeout` on every
pooled connection, and nothing in the set said what a worker does when one of them fires, or when
the connection drops, with a provider outcome in hand. The worker algorithm showed every settle as
one attempt followed by `if not ok: exit()`, and `OPS-22` gave the only rule for a write that did
not land: "Where the guarded write affects no row, the worker MUST log it loudly, leave the record
alone, and exit; the startup pass has already classified it (`OPS-15`)."

Two independent reviews of one brief — Codex at xhigh and a fresh Claude reader — were run before
anything was decided, and a second pair on the naming below. Both pairs converged.

**The lost acknowledgement is real, and it has one shape.** A server-side timeout is a refused
write: PostgreSQL "Abort[s] any statement that takes more than the specified amount of time", the
implicit or explicit transaction rolls back, and a retry finds the row still `running`. What is not
refused is the transport: the commit record is durable and the reply never arrives. PostgreSQL
documents this case by name — `pg_xact_status` exists so "applications ... determine whether their
transaction committed or aborted after the application and database server become disconnected
while a `COMMIT` is in progress" — and both readers added that the statement timeout is disabled
before commit processing and interrupts are held across the commit record, so a client deadline
expiring proves nothing about rollback. A retried settle write after a lost reply affects zero
rows, and `OPS-22` reads zero rows as "the startup pass has already classified it", which is false:
the process never restarted.

**The owning worker is not a stable identity inside one process.** `OPS-8` has the worker itself
return an operation to `queued` — "in which case the operation MUST defer with a short delay, as
above" — after which the same row is claimed again and run by a different execution. Under a
retry: execution A's defer write commits, its reply is lost, execution B claims the row, A repeats
its defer. The row is `running`, so `STO-3`'s guard `(id, status = running)` passes, and B's
operation is pulled back to `queued` mid-provider-call. B's settle then affects zero rows and the
engine exits under `OPS-22`; the row is claimed a third time and the mutation re-runs — `OVR-5`'s
"MUST NOT be retried automatically" reached through the retry, inside one process, with every
guard passing. Both readers found this; neither of the two resolutions on the brief's table caught
it, because both trigger only on zero rows.

**The column that could distinguish the executions was misnamed.** `OPS-6` said "Attempt count
MUST be incremented on claim" into `operations.attempts`, while the glossary defines an
**attempt** as one operation under an episode, `OPS-2` says "the operation is one attempt, and a
later attempt is a fresh operation", and `CNF-288`, BLOCKING, says a create has "no second attempt
by any path". A create deferred once read `2`.

## The decision

- **A store error is retried, bounded, and then the engine exits.** A worker whose store
  transaction errors or times out repeats the *whole transaction* — never the last failed
  statement, and never the provider call (`OPS-12`) — for a stated bound, then logs loudly and the
  engine exits non-zero into its supervisor, where `OVR-18`'s alarm is already watching. The bound
  is a startup-validated duration on `OVR-19`'s register and covers connection, execution, commit,
  read-back and backoff together. It is a money parameter: on exhaustion the provider's answer is
  thrown away and `OPS-15` classifies the row as interrupted.
- **"Too slow" is `statement_timeout`, and the client never gives up first.** The client-side
  deadline on a store call MUST NOT be shorter than `STO-7`'s server-side timeouts, so the server
  decides every statement's fate before the client does, and the only lost reply is a dead
  transport. A connection abandoned mid-transaction MUST be reset before it returns to the pool.
- **Constraint violations, serialization failures and lock timeouts are not store errors** in this
  sense. They do not consume the bound. A unique violation on a repeat is the repeat landing on its
  own earlier commit and is handled by the next bullet; a serialization failure is retried at once
  under PostgreSQL's own guidance; a lock timeout is a held `LDG-35` primitive, not an unavailable
  store.
- **Every worker write is idempotent under repeat.** The settle guard admits the row it already
  produced: `status = running OR (status = target AND the written columns are not distinct from
  what is being written)`; `revision` and `updated_at` advance only on the `running` branch, so
  `API-53`'s "strictly increases on each client-visible modification" holds. Write-once markers
  (`OPS-45`) are written `COALESCE(marker, now)` guarded on `status = running`, never guarded on
  the marker being null. The guarded status write is the transaction's first statement and
  short-circuits the rest, so `OPS-27`'s multi-row create settlement and the meter's
  debit-plus-decrement-plus-total (`STO-28`, `STO-45`) repeat as a unit or not at all. `OPS-22`'s
  zero-row clause keeps its single meaning: someone else moved it.
- **Every worker write carries the claim number.** `operations.attempts` becomes
  `operations.claim_number` — added and backfilled in one release, dropped in the next, under
  `ADR-0024`'s rule that a rename is a contract step; the atomic claim (`OPS-5`) increments it and returns it, and every
  write by that execution carries `claim_number = mine`. An index-refused claim never left `queued`
  — `OPS-5` says select-and-mark is "one indivisible step" — and does not advance it. The number
  identifies a claim; it bounds nothing, routes nothing, is not an attempt count, and is not a fence
  against a second engine: `OPS-47`'s "where two engines run, nothing here refuses the second"
  stays true. The startup pass and the resolution writes do not carry it, on `OPS-3`'s scoping
  argument — they are made by no execution.
- **The defer write is `STO-3`'s fifth guarded write**, on `(id, status = running, claim_number =
  mine)`, and its zero-row meaning is "already deferred or already re-claimed; move on" — not
  `OPS-22`'s exit.
- **A lost reply on the claim itself is fatal, not retried blind.** The claim's returned row is
  the only way the engine learns what it claimed; a repeated claim after a lost reply strands a
  `running` row with no worker, which `OPS-15` says "nothing but a restart can" do. The engine
  exits and the startup pass classifies it.
- **A worker cancelled during the retry loop stops retrying and exits.** `OPS-15` gives the same
  answer either way once the process is gone.
- **The number leaves the wire.** `API-20`'s "attempt count" and `WIR-10`'s `"attempts"` are
  dropped rather than renamed: no caller behaviour in the set depends on it — `revision` arbitrates
  polls, `retryable` tells the caller what to do — and a deferral count is nothing a caller can act
  on.

## Why the claim number is not the epoch

`ADR-0019` deleted a term because "the claiming process stamped that value itself, so it held by
construction", and `CONTEXT.md` bans "a guard whose compared value has a single writer that is also
the thing being guarded". The claim number has a second writer that is not the write being guarded:
a later claim of the same row, by another worker of the same engine. Status cannot separate the two
executions — both are `running` — so this is a term that fires where the status term cannot, the
test `ADR-0019` applied to the epoch and the epoch failed. The firing case is written into `OPS-6`
so a reader can check it, the way `OPS-42` states its race; a guard whose firing case is not
written is how the epoch survived two reviews.

`ADR-0016` rejected "`attempt` reused as a generation" because it arrived with "a heartbeat
cadence, a lease duration, a sweep interval" to defend a second *process*. This term carries no
expiry, no renewal and no deadline, defends nothing about a second engine, and its sentence in
`ADR-0016` — "A token per operation means a heartbeat cadence" — has this as its counterexample.

## Considered options

**Exit immediately on any store error, no retry.** The laziest rule and the one first proposed: a
slow store is a down store, the restart window is the accepted outage, the existing classification
does all the work. Rejected by the record in favour of the bounded retry; the objection raised
against the retry — a period of two-writer ambiguity — was wrong, since nothing else writes while a
worker retries under one engine. What the retry actually costs is the idempotence work above.

**Narrow `OPS-22` to the first attempt** ("under one engine, a zero-row settle write on a retry is
always our own earlier attempt"). The writer inventory is true today — cancellation under `OPS-21`
is an outcome the owning worker records; `API-58`'s fan-out and `API-63` touch only `queued` rows;
the operator verbs are guarded on `needs_reconciliation`; retention "reaches settled operations and
nothing else". Rejected because it holds by inventory, which is "in prose and absent from the
predicate" (`ADR-0016`), because the same premise is repeated in `OPS-3` and `STO-3`, and because
the inventory of *executions* is already false under `OPS-8`.

**Read the row back on zero rows.** Works, and must compare the written columns and not `status`
alone — a worker's `needs_reconciliation` and the startup pass's differ only in `error`. Rejected
as a guard bolted after a result the retry made ambiguous; folding the comparison into the guard
removes the ambiguity instead of handling it, and the set already has that shape in `OPS-42`'s
fence, "guarded on `destroy_committed IS NULL` *or* `destroy_committed` already holding this
operation's episode id" — which is why the fence was the one worker write the lost reply never
broke.

**An idempotent settle command backed by a receipt row** (`applied` / `already_recorded` /
`conflict`), surviving later resolution. Codex's preference. Rejected as a schema addition to cover
one case the conservative response already handles correctly: a worker's `needs_reconciliation`
resolved by an operator inside the retry bound leaves the retry with zero rows and a row that is
right, and "leave the record alone" is the correct outcome.

**`pg_xact_status`.** The general tool for a client that already holds an xid. Rejected here: the
xid is only held if a prior round trip returned it, so it costs a round trip on every settle to
answer a narrower question than the row answers, and the one shape it fits is answered equally by
the guard.

**A minted token instead of a counter.** A UUID has no second reading and cannot be bounded or
displayed as a count. Rejected: the counter is an existing column, has a natural zero for "never
claimed" — which makes `API-58`'s and `API-63`'s "queued, never claimed" checkable — and does the
one job, distinguishing execution N's late write from execution N+1's row, exactly as well. The
misuse a counter invites is prohibited in words instead.

**Keep `attempts` and flag it.** Rejected: a flagged ambiguity is what the set uses when a word
cannot be changed, and this one can. Leaving it would keep a BLOCKING item asserting "no second
attempt by any path" beside a column that counts to two on that path.

## Consequences

- `OPS-22`, `OPS-3`, `STO-3` and the worker algorithm: the worker predicate becomes
  `(id, status = running, claim_number = mine)` with the repeat-admitting branch, spelled out once
  in `STO-3` and cited elsewhere; the diagnosis "a restart swept it" is replaced, since a claim
  mismatch does not prove a restart. `STO-3` gains the defer as its fifth guarded write with its
  own zero-row meaning.
- `OPS-6` renames the counter, states its return to the claiming worker, states the firing case,
  and states what the number is not. `OPS-5` names the defer as a way a claim ends. `OPS-8`'s
  re-acquire after a defer is stated to be a new claim carrying a new number. `STO-1`'s "the claim
  stamps nothing" is qualified.
- `OPS-45`'s markers are `COALESCE`d; its "a record is no longer re-run" is narrowed to the
  prohibited recovery of settled or unresolved operations, since re-claims are documented.
- A new requirement in `03-operation-lifecycle.md` states the retry, its unit, its bound, the
  client-deadline rule, the error classes that do not consume the bound, the fatal claim case and
  the cancelled-loop rule. `OVR-19` gains the store-retry bound. `STO-7` gains the reset-before-
  reuse rule and the client-deadline rule's store half.
- `05-persistence.md`'s `operations` table renames the column. `API-20` and `WIR-10` drop the
  field.
- `OPS-30`, `OPS-32`, `CNF-86`, `CNF-88` and `CNF-281` are reworded off the adopt sense of "claim".
  `OPS-13`, `LDG-67` and `CNF-241`'s "attempt" readings on a create are checked against `OPS-2`.
- `CNF-197`'s "a worker write against an operation no longer `running` affects no row" is corrected
  for accepted repetition. `CNF-27` or `CNF-266` gains the firing case: defer, re-claim, replay the
  first execution's defer write, assert zero rows and that the second execution is still `running`,
  and assert that removing only the claim term admits the stale write. A same-claim repetition is
  asserted to succeed unchanged. `CNF-290` asserts the refused claim did not advance the number.
- `CONTEXT.md` gains **Claim** and the flagged ambiguity on the word; **Adopt**'s avoid list is
  qualified.
- `11-open-findings.md`: a finding number for §6.15, with this as its first closure; backup and
  restore is `ADR-0023`; pool sizing and migrations against a live database remain open under it
  until decided.
