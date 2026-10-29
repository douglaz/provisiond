# A lost startup-lock connection records the stop, and a startup generation fences every engine write

**Status:** accepted (2026-10-24, the owner's decisions “Yes, R (Recommended)” and
“Adopt; one combined Run”; `pv-buc`; panel r66e and its parent rounds,
`docs/research/panels-2026-10/r65/`, `docs/research/panels-2026-10/r65/r65b/` and
`docs/research/panels-2026-10/r66/`). Amends `ADR-0019`, `ADR-0022` and the stop-record
model recorded in `ADR-0044`.

## Context

A lock connection can be lost while the worker still has a working store connection and an
outcome to record. Form R preserves that outcome within the existing recording bounds.
`OPS-47` now says “treat the loss as a stop of every worker not already recording one”.
For its application to the worker and the store-error loop, see `OPS-21` and `OPS-49`.

The startup lock cannot prevent a stale engine from writing through its other connections.
`ADR-0019` rejected “guard the claim itself on `engine_epoch = mine`” on scope and cost:
“Rejected because it buys a defence for the case this ADR puts out of scope, and keeps a
column, a counter and a guard term alive to do it.” This decision reverses that rejection.

## Decision

Adopt Form R and Fence G together. The owner chose “Yes, R (Recommended)” for R and
“Adopt; one combined Run” for G on 2026-10-24
(`docs/research/panels-2026-10/r66/r66b/notes.md` and the panel index in
`docs/research/panels-2026-10/README.md`).

**R: record the stop before exit.** `OPS-47` owns the detection point: “from the moment it detects the loss”.
Its no-new-work clause is “claim nothing more and begin no periodic pass”. Its distinction is “The loss is not a later
stop: a record already pending when the loss is seen continues under its own Stop-record
bound and exits.” For the cancellation, absorbed-read and parent cases, see `OPS-21`;
for repetition of a pending record, see `OPS-49`. `OPS-47` keeps “hold it for its lifetime”.

**G: check one shared row before every engine write.** `STO-59` owns the startup generation:
“Every startup advance MUST choose a random UUID distinct from the values chosen by earlier
startup advances, including choices whose effects a restore removed.” `STO-59` also says
“It is not a counter and is never compared for order: every check is equality”.
`STO-59` places the advance “in a transaction of its own”. `OPS-15` owns its ordering:
“Its commit MUST be acknowledged before the engine begins any other write transaction”. `OPS-50` owns the other engine transactions:
“MUST read `STO-59`'s row `FOR SHARE` as its first statement”, compare equality with their own
startup value, and “hold that lock until it commits”. `OPS-50` owns the refusal:
“Where the values differ, the transaction MUST roll back, and the engine MUST log loudly
that it was superseded and exit non-zero at once, beginning no other transaction.”
It also says “A mismatch is not a store error (`OPS-49`) and is never repeated.”
The rule widens the option rejected by
`ADR-0019` from the claim to every engine write; the read transaction licensing a provider
dispatch also carries the check. The cost paid in place of the deleted counter is the shared
UUID row, the advance transaction, and the share-lock read and comparison on the engine's
transactions. No lease, expiry or renewal is introduced.

The share lock closes the read-to-write race. PostgreSQL 18, section 13.3.2, says “A shared
lock blocks other transactions from performing `UPDATE`” and “Row-level locks are released at
transaction end” ([row locks](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS)).
The generation read precedes `LDG-35`'s primitive. The advance holds only the generation row,
so it waits on share holders while holding nothing they wait for: there is no cycle. Because
it commits before the sweep transaction begins, the sweep's snapshot follows every share
holder the advance waited on. This is the lock-order argument; the requirements point to
the mechanism rather than keeping another copy of the argument.

**Startup order and timeout typing.** `OPS-15` owns the anchor: “The engine's first write
transaction after taking `STO-51`'s lock MUST contain only the replacement of `STO-59`'s
startup generation”. This is anchored to the first write after the lock rather than the
pass's first transaction: `STO-54` labels step (2) “*Before the first claim:*”. That write
cannot precede the advance: a write before it would have no own value to compare against.
`OPS-15` also says “The engine makes no write before that transaction.”

`OPS-15` owns the advance statement's timeouts: “Its replacing statement MUST run with
`statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait bound.”
PostgreSQL 18 says `lock_timeout` “applies separately to each lock acquisition attempt”
([timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html)), and of
`statement_timeout`, “Abort any statement that takes more than the specified amount of
time”; setting both bounds the whole wait. The same page
says of both settings, “A value of zero (the default) disables the timeout”. For the bound's current type, see
`OVR-19`'s Startup-lock wait bound row. `OVR-19` requires startup to “refuse to run on a missing or
out-of-range value”. A zero therefore stops startup rather than disabling the timeout;
this also types the existing startup-lock retry's bound. `OPS-15` owns the fatal advance
error: “On that timeout or any store error, including a lost reply on its commit, the engine
MUST log loudly and exit non-zero having claimed nothing”. Its retry is “the supervisor's
restart is the retry”. For the alarms, see `OVR-18`.

**Restore begins with the system stopped.** On 2026-10-24 the owner said, “I don't think we
should tolerate a gross operator mistake like restoring some backup with the system
running” (`docs/research/panels-2026-10/r66/r66e/notes.md`, input from r66d).
`STO-54` records the step: “*Before the restore begins,* the deployment MUST stop every
engine and `api` process, and MUST start neither component until the transaction that
commits `STO-56`'s record (below) has been acknowledged”. The lead-in is unnumbered;
`STO-56` retains “`steps_completed` (0 to 3)”. For a promotion that is a restore, this is before
the procedure runs on it. No application-side restore check is added.

**What G does not cover:**

- A provider call licensed by a check that committed **before** the takeover goes out
  (the list in `OPS-50`).
- Two writable copies of the database (`STO-54`). G fences one database history only.
- A restore performed while any engine or `api` process runs. It is unsupported:
  `STO-54`'s procedure stops every one before the restore begins (`STO-54`). `STO-54` says "the
  deployment MUST stop every engine and `api` process".
- Liveness: a `SyncRep` holder, or share holders that keep turning over, delay the takeover
  until `OPS-15`'s exit.

## Considered and rejected

- **Form E, exit at once on lock loss.** It was not adopted. The r65 tally records “Pick:
  R 4-0”; r65b's outcome is “**(a) consensus: R**”
  (`docs/research/panels-2026-10/r65/tally.md` and `r65/r65b/tally.md`).
- **Fence A beside G.** The r65b tally records “**Moot** (moot rule: Q2 consensus ADOPT,
  and 4 of 4 call A moot under G)”.
- **A fresh generation write in the restore-record transaction.** Dropped on the owner's
  2026-10-24 answer “Drop it (Recommended)” (`docs/research/panels-2026-10/README.md`,
  r66 outcome). The dependent restore-record wording and assertions are dropped with it.
  `STO-59` retains “Reinstating a backed-up value is not a new generation choice.”
- **A transition clause in `STO-13` for an engine without the check.** No transition from an
  engine without the check is specified, because on the owner's answer (2026-10-24,
  “The project isn't built yet”) no build predates `OPS-50`. The full answer is
  “Us this scenario real? The project isn't built yet”
  (`docs/research/panels-2026-10/README.md`, r66 outcome).
- **An application-side restore check.** Not added
  (`docs/research/panels-2026-10/r66/r66e/notes.md`). The owner's 2026-10-24 words are
  quoted under the restore decision above.

## Consequences

The requirement homes carry the rules. The pointers in `STO-1`, `STO-6`, `OVR-17`,
`ADR-0016` and `CONTEXT.md` lead to those homes. `CNF-366` exercises R; the generation-fence
conformance items are `CNF-367`–`CNF-370`. They include a restarted engine after the backup,
so a restored history has removed a generation choice. `CNF-370` says "Start an engine; back up; restart the engine".

`Provisiond.Claim.engineStep` checks equality before a claim. Its Bool is separate from
`Guards`, preserving the worker guard controls. `superseded_never_commits` proves refusal;
`superseded_commits_without_check` admits the same stale claim with the check off. The
shipped check has a concrete refusal witness. Tokens stand for UUIDs; the model assumes the
row value read under the share lock and does not prove PostgreSQL locking or generation
freshness. The existing lost-claim-reply theorem supplies matching tokens for its
single-engine case; the exited-engine theorem holds for arbitrary tokens.

The stop-record schedule gains the generation-refusal event, preserving a prefix's lost-reply
commit in `superseded_exits`. `finished_unrecorded_exit` is weakened by one disjunct,
`events[plan.elapsed]? = some .superseded`, against `ADR-0044`'s “No existing theorem is
weakened”. No other existing theorem is weakened. The event is a generation refusal, not a
constructor for lock loss: R's original stop or pending record already models that loss.
