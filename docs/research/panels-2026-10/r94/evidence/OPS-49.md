**OPS-49** **ADDED 2026-09-12 (`ADR-0022`) — a store error is a bounded whole-transaction retry,
then the engine exits.** Where a store call by a worker, or by a periodic component running in
the engine process (`OVR-17`), errors or times out, the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`) — with
the provider's outcome retained in memory, for a stated bound (`OVR-19`), and on exhausting the
bound MUST log loudly and the engine MUST exit non-zero into its supervisor, where `OVR-18`'s
alarm is watching. A refused generation check (`OPS-50`) is not a store error and is never
repeated. `OPS-50` says "A mismatch is not a store error (`OPS-49`) and is never repeated."
The bound covers connection, execution, commit, read-back and backoff together, but
not a commit's wait for the standby (`STO-7`), and it is a money parameter: on exhaustion the
outcome in hand is thrown away and `OPS-15` classifies the row as interrupted — unless the
bound's last repeat committed and its reply was lost, in which case the row is already written,
the money already posted once, and the startup pass finds nothing `running` to classify (*the
formal layer's claim model exhibits this trace, 2026-09-14*). A periodic component whose
repeated write affects no row under a write-once guard — `STO-3`'s resolution write, `STO-52`'s
episode index — has seen its earlier attempt land, and moves on. **`api`'s components do not run
this loop**: a failed request transaction is the caller's `internal` error, and a failed credit
is `STO-31`'s next replay.

An attempt denied by `STO-55` admission is a store error for this loop and sends no SQL
(`STO-55`: "worker/periodic acquisition refusal is an `OPS-49` store error").

- **"Too slow" is `statement_timeout`.** The client-side deadline on a store call MUST NOT be
  shorter than `STO-7`'s server-side timeouts, so the server decides every statement's fate before
  the client does and the only lost reply is a dead transport, or a commit returned with
  PostgreSQL's replication warning (`STO-7`). A server-side timeout is a refused
  write, and the repeat finds the row unchanged; a lost reply after a durable commit is the case
  `STO-3`'s repeat-admitting guards exist for.
- **Constraint violations and serialization failures are not store errors** and do not consume
  the bound. A unique violation on a repeat is the repeat landing on its own earlier commit, and
  the guarded status write preceding the money writes short-circuits the rest (`STO-3`). A
  serialization failure is repeated at once. **A `lock_timeout` is a store error for this
  purpose**: on `LDG-35`'s primitive or on `STO-52`'s index it rolls back, releases the connection
  before any backoff, and repeats the whole transaction with the provider outcome retained,
  against this same bound — the symptom of a genuinely stuck store is indistinguishable at the
  client, and a lock timeout outside any bound is an unalarmed loop on a held primitive. *`ADR-0022`
  first said a lock timeout "do[es] not consume the bound" and said nothing about what the worker
  then does; `F51` decided this and the ADR carries the amendment.*
- **A lost reply on the claim itself is fatal, not retried blind.** The claim's returned row is the
  only way the engine learns what it claimed; a claim repeated after a lost reply strands a
  `running` row with no worker, which `OPS-15` says "nothing but a restart can" do. The engine
  exits and the startup pass classifies it.
- **A worker cancelled during the retry loop stops retrying and exits.** `OPS-21` says "A later stop, one arriving after the stop being recorded and before that record lands, ends the record as an exit without worker classification at any point: before the record's first transaction, during it, or while `OPS-49` repeats it; the worker MUST NOT repeat a record transaction already sent when that later stop arrives."
  `OPS-21` says "The record write MUST NOT be cancelled by the cancellation that stopped `execute`."
  A stop during a loop inside `execute` is that cancellation, not this exit: `OPS-21` says "A stop that arrives while a store transaction inside `execute` is in flight or repeating under `OPS-49`, such as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation being recorded."
  A first stop during an ordinary settle write's loop after `execute` returns is not this exit either: `OPS-21` says "A stop the engine survives that arrives after `execute` returns and before the worker's settle write lands MUST be recorded by that settle write, under the shielding below, and the Stop-record bound and exits that apply to a recorded cancellation."
  A later stop and exhaustion both leave restart recovery to `OPS-15`, whose
  ordinary rule is "the engine MUST move every `running` operation to `needs_reconciliation`",
  subject to its exceptions and the lost-reply case above. `OPS-47` says of a lost lock connection
“The loss is not a later stop”: a worker repeating a record when the loss is seen keeps
repeating it.
- **A suspension parent waiting on its children is deferred, not held** (*this bullet is `F51`'s,
  not `ADR-0022`'s*). A `suspend_tenant` parent (`API-58`) whose children are still queued MUST be
  returned to `queued` with `available_at` advanced — the same write as `OPS-8`'s defer, though
  nothing refused it — rather than occupy a worker while it waits; N parents waiting in N workers
  would leave no worker for the children they wait on. Its state while waiting is `queued`, which
  is why `STO-54`'s restore rule holds a `queued` parent for confirmation as well as a `running`
  one.

*Amended 2026-10-18 (`pv-tst`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): distinguished a later stop during the loop from the stop being recorded.*

*Amended 2026-10-18 (`pv-tst`; panel r58c, `docs/research/panels-2026-10/r58/r58c/`; `ADR-0044`): pointed a stop during a loop inside `execute` at `OPS-21`'s record.*

*Amended 2026-10-19 (`pv-zbp`; `ADR-0044`): pointed the first stop during an ordinary settle write's loop at `OPS-21`.*

*Amended 2026-10-20 (`pv-gq8`): replaced the loop-only later-stop definition with a quotation of the record owner's any-point exit.*
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S2′ “A: stop on time (Recommended)”; the lost-reply sentences of `STO-7` and `OPS-49` “Amend both (Recommended)”; `ADR-0045`): excluded a commit’s standby wait from the Store-retry bound, and made a commit returned with `STO-7`’s replication warning the second lost reply.*

*Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): distinguished generation refusal from store errors and retained recording on lock loss.*
*Amended 2026-10-28 (`pv-oehp`; `ADR-0045`; `STO-55`).*
