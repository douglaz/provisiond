# A restore is a recovery incident, not a restart, and durability is bought only where there is no second truth

**Status:** accepted (2026-09-12; proposed 2026-09-10, amendments landed 2026-09-12). The restore
procedure is `STO-54`. Answers
the second of `impl-report-01.md` §6.15's four gaps — "backup/PITR procedures" — which `ADR-0015`
recorded as "New operational surface the set does not yet specify". Builds on `ADR-0022`: the
engine's write path is what that ADR made safe under a lost acknowledgement, and this ADR is shaped
so as not to make that the steady state.

## The problem as found

Backups were in the threat model and nowhere in the requirements: `07-security-requirements.md`
lists "An adversary who obtains the operation store or a backup", `STO-16` says backups "must be
treated as credential material", and nothing stated a recovery point, a restore procedure, or what a
restored engine may do first. `STO-5` promises no loss "across process restart", which is a
different event.

The question put to two independent readers — Codex at xhigh and Opus, on one brief — was whether
a restore may land at `T − Δ` with `Δ > 0`. The brief carried the proposer's inventory of what a
lost interval costs and how the set recovers each class. Both readers found the inventory wrong on
most lines, and both found the same thing under it: **a restore at `T − Δ` makes the engine
perform destructive actions, not merely fail to prevent losses.** Each needs one transaction in Δ.

- **A paid machine destroyed.** A customer extends runway in Δ from an existing balance, so there
  is no rail payment to replay. The restore erases the extension; `LDG-16` routes the machine on
  its stored `runway_until`; `OPS-41` aborts only where the re-derived date is "strictly in the
  future", re-derived from the commitment the restore shrank; `LDG-14`: "the machine MUST be
  cancelled and its disk destroyed with it." Every recovered invariant holds while it happens.
- **A revoked token works again.** `API-56`: "A revocation invalidates the current token
  immediately." The restore reinstates the old digest and generation, and `API-55` names what that
  token can do — an install "which wipes a disk" and a delete "which destroys a machine".
- **An executed operation runs twice.** `OPS-15` inspects `running` rows on the premise that "with
  one writer, any `running` row at startup is interrupted" — true after a crash, false after a
  restore — and says nothing about `queued` rows, which are simply claimed. A create that ordered in
  Δ orders again; a raw-disk install that wrote in Δ wipes a disk the customer has since filled.
  `OVR-5`'s "The mutation MUST NOT be retried automatically" is reached, and `CNF-288`'s "No settled
  operation of any kind re-enters `queued`" is falsified by a route its enumeration does not
  contain.
- **A reversed suspension re-runs.** A `suspend_tenant` parent restored to `running` fires
  `OPS-15`'s exception — "returned to `queued` and re-claimed like any other queued work, resuming
  its fan-out from wherever it stopped", which "MUST NOT require an operator" — and cancels a fleet
  the operator may have resumed inside Δ.

The compensations the inventory claimed were asserted, not provided. `WIR-42` enumerates payments
"by `deposit_id`" and needs the deposit row to exist. `OPS-32`: "An unclaimed machine MUST NOT be
auto-attached to any tenant". `LDG-30`: a commitment "is **not a ledger entry**", so lost
reservations cannot be rebuilt from payment history. `SEC-39`'s ceiling counters are "incremented
by a conditional write in the transaction of the write it gates" and roll back with the
idempotency records they were cited as bounding. `LDG-72`'s post-restore check is one-sided by
design — "only a mark *behind* one is evidence of loss" — and a transactionally consistent restore
never leaves the mark behind, so it passes and proves nothing.

**Two things no recovery point bounds.** A deposit minted in Δ whose payment then lands is money the
restored store cannot name, record (`payments.deposit_id` is not null), credit, or refund
(`ADR-0004`) — `LDG-43`'s "the one outcome this specification must not permit by accident",
produced on purpose. And `deposits.derivation_index` has no allocation rule anywhere in the set; a
`max + 1` implementation re-issues after a rollback an address already handed to another tenant, and
the unique constraint cannot catch it because the conflicting row is the one the restore deleted.

## The decision

- **A restore is a recovery incident with a stated procedure, never an ordinary restart.** A
  restored store is not served at `T − Δ` as if nothing happened. The procedure is a numbered
  requirement, rehearsed end to end before the first customer payment on `CNF-137`'s model, and it
  exercises the destructive witnesses above, not merely a successful start.
- **The order is fixed, and the first boundary is not "before any claim".** `OVR-17` puts the
  exhaustion sweep, `LDG-64`'s outage canceller and `OPS-27`'s resolution sweep on the engine, and
  `API-34`'s TTL sweep, retention and the settlement watcher on `api`. Starting either to reconcile
  starts all of them. So: (1) before the startup lock — the public listener is down, the lost
  window `T − Δ` is stated as a number and published to the operator, the exhaustion sweep, the
  outage canceller, the TTL sweep, retention and `OPS-15`'s `suspend_tenant` exception are frozen,
  and `provider_account_status` and the rate quorum are re-established, since `LDG-16` and `STO-36`
  route on them; (2) before the first claim — the irreversible `queued` kinds are quarantined and
  the reversible ones are not (next bullet); (3) before the first `api` request — the watch set is
  re-derived, both rails are replayed, `SEC-39`'s counters are re-seeded, and every credential
  generation is bumped (below).
- **A restore is a backward move of the fleet's dates, and `LDG-16` already says what a backward
  move gets.** `LDG-16`'s promise is that "a single bad rate reading can move a date but can never
  destroy a disk", and its mechanism is `machines.exhausted_since`: set when a derivation moves a
  date backward into the past, after which the sweep routes only once the column is "older than one
  re-derivation interval", so the deficiency must persist across a second derivation. The null case
  routes at once because "natural expiry of a runway the customer was shown is not a glitch". A
  date the restore moved into the past was not shown to the customer. So the procedure sets
  `exhausted_since` to the restore instant on every machine whose stored `runway_until` has passed,
  and nothing else is needed: the sweep waits one interval, `OPS-41`'s re-derivation at claim "is
  itself the second derivation", and an extension inside the interval clears the column and writes
  a future date, exactly as `LDG-62` already does. This is what stands between the restore and the
  destroyed disk, and it is an existing mechanism applied to a case it was written for. A machine
  that genuinely lapsed inside Δ is cancelled one interval late, the price the set already pays for
  a poisoned reading. *Corrected 2026-09-12: "stands between" overstated it. The grace does not
  rebuild the lost extension; it gives the tenant one interval to extend again, and a tenant that
  does not is cancelled at its end, with the extension's satoshis back in its balance. `STO-54`
  now states that as unrepaired, beside the other losses it lists. Telling tenants — the operator
  is told, tenants are not — would be new machinery and is not decided here.* *A "funding quiet period" — a new pause of stated length during which the
  sweep would list and not route — was on the table and is withdrawn: it was a guard for a
  precondition the column removes, with a parameter of its own.*
- **The irreversible `queued` kinds are escalated to `needs_reconciliation`; the goal-state kinds
  run.** The partition is `OPS-11`'s own: a create, an install and a rescue inventory repeated are a
  second order, a second disk write and a second boot into rescue, so they go to
  `needs_reconciliation` and `OPS-27` "establishes what happened rather than doing it again".
  Delete, power, end-rescue and release-attachment are goal-state mutations whose repeat "MUST
  classify `succeeded`", and reverse-DNS sets a value; they re-run. A `suspend_tenant` parent found
  `running` — or, since `F51` returned a waiting parent to `queued`, found `queued` and unsettled
  — waits for operator confirmation instead of resuming under `OPS-15`'s exception (*the `queued`
  case added 2026-09-12 at the landing's verification*).
- **`OPS-32`'s complete pass is a step, not a gate, and it runs twice.** The first pass may
  record nothing about absence — `provider_observations` written in Δ are gone, so the effective
  visibility window (`PRV-36`) has been narrowed by the restore, a narrowing the set says is "never
  an engine write" — and a second pass separated by the effective window is what may record absence.
  What the sweep finds unrecorded is reported, not attached; the restored engine cannot tell a
  machine created in Δ from one created by hand, and the report says so per account.
- **Durability posture: asynchronous streaming replication plus continuous WAL archiving, with a
  recovery-point alarm.** The recovery point is stated as the maximum age of WAL not yet in a
  separate failure domain, a human row on `OVR-19` with its alarm threshold startup-validated on
  `OVR-18`'s model. The number is not the safety argument — a create dispatches in one second, a
  deposit mints in one, an extension lands in one — and the requirement says so beside it.
- **Synchronous commit is bought for exactly the two transactions with no second truth.**
  `SET LOCAL synchronous_commit = on` inside the deposit mint and `STO-30`'s payment-credit
  transaction, both on `api`, against a named standby; `local` everywhere else. Under a stalled
  standby those two hang, which is a degraded money-in path alarmed under `OVR-18`, and they fail
  safe: `STO-31`'s rail replay is built for a credit that did not land, and `API-45` returns the
  locally committed deposit to a caller that re-sends its key. The engine's write path never waits.
- **Every tenant's credential generation is bumped on restore.** The restored store cannot know
  which tenants revoked inside Δ, so it invalidates every spending token at once; each customer
  re-issues through the recovery credential, the route `API-56` already provides, which leaves "the
  tenant, its machines, its balance and its commitments untouched". One write, nothing outside the
  restored store, and the resurrected token is dead by construction. Replaying revocations from
  `SEC-33`'s audit destination was rejected: it makes the audit log a second store with its own
  lost interval, and a revocation it missed is a stolen token that works again.
- **The derivation index never goes backwards.** A restore skips it forward by a stated gap, a
  startup-validated row on `OVR-19`, before any deposit is minted; the allocation rule itself is
  written into `05-persistence.md`, where the column today carries only a note.

## Why not synchronous commit on every write

Both readers agreed the destructive cases are real; they split on the remedy. One recommended
`synchronous_commit = on` with a named standby and no positive recovery point. The other found the
reason that fails here, and it is `ADR-0022`'s.

`ADR-0022` rests on "the client never gives up first": the client-side deadline "MUST NOT be
shorter than `STO-7`'s server-side timeouts, so the server decides every statement's fate before
the client does, and the only lost reply is a dead transport." PostgreSQL has no server-side
timeout for the synchronous-replication wait. Its documentation says such commits "may never be
completed if any one of the synchronous standbys should crash", offers only a fast shutdown or a
configuration reload as the way out, and confirms the commit record is already durable locally:
waiting transactions "will be marked fully committed once the primary database recovers". So under a
stalled standby the client's deadline fires first on every write, the rare lost acknowledgement
becomes the steady state, the retry re-commits and re-stalls until the bound exhausts, the engine
exits, and the successor's startup pass — which writes — stalls the same way. A crash loop across
the whole safety layer, on the mechanism bought for availability, while every machine keeps
billing. That is the outage `ADR-0015` chose PostgreSQL to avoid.

A quorum of two standbys (`ANY 1 (s1, s2)`) tolerates one standby's loss at the cost of a third
node and returns the stall when the second goes. It is an addition to this ADR for a deployment that
wants it, not an alternative: a synchronous standby replicates a bad migration, an operator
`DELETE` and logical corruption instantly and faithfully, so the restore procedure is owed
regardless, and the classes that make Δ dangerous are answered by the procedure's order, not by the
number.

## Considered options

**Continuous archiving with a stated recovery point and a restore procedure whose gate was "a
complete `OPS-32` pass before any claim".** The proposer's option. Rejected as written: it gated
the wrong boundary (the sweeps start with the engine), made an unbounded pass a precondition while
every exposure-reducing mechanism was held down, cited compensations the set does not provide, and
had no answer for the extension, the credential or the queued create.

**Synchronous replication on every commit, recovery point zero.** Rejected above. Its own reader
conceded a two-node setup stalls on standby loss.

**Reconstructing the money-in path from `SEC-33`'s separate audit destination** by adding the
deposit id to `SEC-32`'s field list. Correct and cheap, and it may still be done; rejected as the
primary answer because it creates an operator reconstruction verb for a case that a per-transaction
platform setting closes at the source.

**A refund for the unreachable deposit.** Forbidden by `ADR-0004`; the term "refund" is what
converts a merchant into a custodian.

## Consequences

- A new requirement in `05-persistence.md` owns the restore procedure and its order, the
  irreversible-kinds partition, the two-pass sweep, the recovery-point statement and the
  derivation-index rule; `OVR-17`'s component table is the list it freezes, cited rather than
  restated. `STO-5`'s "process restart" is qualified so a reader does not take it for this. `STO-7`
  gains the per-transaction `synchronous_commit` rule beside its other connection-scoped settings.
- `OPS-15` gains the restore-time quarantine of create, install and rescue inventory, and the
  operator-confirmation exception for a `suspend_tenant` parent. `CNF-288`'s "no route" assertion
  names the restore as the route it now guards.
- `OVR-19` gains: recovery point (human), its alarm threshold (validated), the derivation-index
  gap (validated), and the synchronous standby name (validated). The grace after a restore is
  `PRV-13e`'s re-derivation interval, already on the register.
- `LDG-16` names the restore as a setter of `exhausted_since` beside re-derivation, and `CNF-99`'s
  mechanism test gains the restore edge: a past date restored from backup sets the column and the
  sweep waits. `OVR-18` names the standby stall as a second alarmed condition.
- `12-billing-and-ledger.md`: `LDG-72`'s trigger keeps "restore" but the requirement states that a
  consistent restore passes it, so it is not the restore gate; `LDG-64`'s outage deadline and
  `LDG-62`'s extension are named as state a restore rewrites. `LDG-74`'s "Billing stops at the
  observation instant" gains the consequence that a restore extends a gone machine's charge to the
  next complete pass, and the correction is an operator `LDG-5` entry.
- `13-wire-contract.md` `WIR-42` and `STO-46`: unchanged; the deposit-minted-in-Δ case is closed
  at the source by the synchronous mint.
- `10-conformance-checklist.md`: a BLOCKING rehearsal item on `CNF-137`'s model that drives the
  four witnesses — lost extension, resurrected token, executed create and install found `queued`,
  reversed suspension — through the procedure and asserts no provider mutation and no disk write
  occurs; an item that a deposit minted with the standby stalled is returned unchanged to a
  re-sent key and its payment credits on replay; an item that the derivation index after a restore
  exceeds every index a rolled-back row could have held.
- `CONTEXT.md`: **Restore** and **Recovery point** as terms, with "restart" listed against the
  first.
- `11-open-findings.md`: the §6.15 finding's second closure; pool sizing and live migration remain.
