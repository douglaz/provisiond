# Owner questions after the external review (pv-s4m)

Four questions. S2′ and S3 were asked before; only what changed is new. Tallies: r63g/tally.md and r63h/tally.md.

What the review changed, in one line each:
- **Verified and measured.** We ran three real PostgreSQL 18 servers on this machine and broke them on purpose. The
  crash, cancellation, abandoned-request and promotion failures all happened as described, and so did the ones the
  reviewer added. One further gap, in a quick shutdown, comes from reading PostgreSQL's code and wasn't reproduced
  (question F).
- **Settled by the panel, not asked:**
  - A switch to a copy compares positions only within the same history (4-0).
  - A web request that gives up mid-save keeps its database connection until the save finishes. So the service
    refuses new saves instead of exhausting the database (2 picked, 2 accepted). A process that exits, or a broken
    database connection, can still leave waiting saves behind (follow-up F2).
  - The design records its aim: nothing irreversible may depend on a write that isn't on a copy yet, because even
    a no-loss switch can drop it. A restore can still lose confirmed writes (4-0).
  - The reviewer's rule as a requirement ("nothing irreversible rests on an unconfirmed write") is dropped, 0-4. It
    added no protection beyond option B below. A read-only commit proves nothing about copies, and its other branch
    was B's check.
  - The test list gains new and sharper checks. Some apply only under S3's B, and one applies only under Wait in
    P. One proposed test is dropped, because it would fail a correct build.

## S2′. During a freeze, does a deploy's stop still finish on time? (asked before)

**TL;DR:** It's the same choice as before. **The panel picks A, 3-1, and the reviewer also picks A. All four
accept either.** What changed: the reviewer found a bigger pile-up than the deploy's: web requests that give up
while their save is frozen. That one is now handled (see above). A stop, a crash or a broken connection can still
leave waiting saves behind.

- **A, stop on time** (panel 3-1, reviewer).
  - B would make the deploy tool wait without limit, which puts the duty on the infrastructure. A needs no
    deployment setting.
  - Cost: a stop during a freeze leaves its waiting saves behind until a copy catches up or the main server shuts
    down. Repeated stops in one freeze pile them up (follow-up F2).
  - Lands on `STO-7` `05:141-143`, `OPS-49` `03:1830`, `CNF-296` and `ADR-0045`.
- **B, wait for a copy** (1 of 4).
  - Cost: a stop during a freeze can last as long as the freeze.
  - If misconfigured: a deploy tool that kills the service before its wait ends turns B into A, with no warning.
  - Lands on the same, plus `OPS-21` and every quote of it.

## S3. How do we close the "crash makes an unconfirmed deposit visible" hole? (asked before)

**TL;DR:** You asked whether we're using PostgreSQL wrongly. It promises only that a write it confirmed is on a
copy; we had assumed anything we can read is on one. **The panel picks B, 4-0, and so does the reviewer. All four
accept A or both.** Under B our code checks each new connection until a copy has caught up. It needs one read
permission and no special server setting.

Story: both copies are down at 10:00, and a deposit is saved but not yet copied. At 10:01 one database process
crashes, and PostgreSQL restarts itself in seconds. The deposit is now visible. The customer asks again and is shown
its address. At 11:00 the copies return, but the main server dies before either catches up. The copy we switch to
never had the deposit, and its address can later be handed to another customer.

- **B, check each new connection** (panel 4-0, reviewer).
  - It also drops the optional connection pooler in "transaction mode", because the check can't see through it.
  - Cost: while both copies are down, no new database connection can be used, even to read. A restarting service
    process can't connect, and a running one can't replace a connection it loses.
  - A broken connection can still leave a save waiting, but only if the save was still being written when the
    freeze began (follow-up F2).
  - If misconfigured:
    - A missing read permission is loud: the service can't open new database connections.
    - A connection pooler in transaction mode silently reopens the hole, and no check reliably catches one added
      later.
  - Lands on `STO-7`, `STO-55` `05:195`, `CNF-365` and `ADR-0045`.
- **A, turn PostgreSQL's self-restart off** (r63f's pick, 4-0; now accepted by all four, picked by none).
  - It's one server setting, plus a "wait for a copy" rule the deployment applies at every start.
  - A also takes a second rule: all four readers say A needs it, or must state its cost. When a database
    connection breaks mid-save,
    the service keeps counting that save against its limit until it learns the save finished, or the process
    restarts. Without that rule, broken connections during a freeze pile up waiting saves until the database
    refuses every new connection, even to read (measured).
  - Cost: a crash of one database process stops the whole database until it's restarted. After broken
    connections, fewer saves are admitted.
  - If misconfigured: leaving `restart_after_crash` at PostgreSQL's default, or skipping the start gate, silently
    reopens the hole.
  - Lands on `STO-7`, `CNF-296`, `CNF-365` and `ADR-0045`.
- **Both:** B's check plus A's setting and start gate.
- **Under every option:** if the copy list is emptied, the database confirms saves without waiting for a copy,
  and nothing in the service notices (follow-up F3).

## P (new). If the copy with the latest writes is unreachable, may we switch automatically?

**TL;DR:** With two copies, a confirmed write may be on only one of them. If that copy is unreachable when the main
server dies, switching to the other loses that write. We measured it. **The panel picks Wait, 4-0, and the reviewer
also picks Wait. All four accept Switch.**

Story: at 10:00 copy 2 is lagging, and a deposit is confirmed by copy 1 alone. At 10:01 the main server dies, and copy
1 is unreachable.

- **Wait** (panel 4-0, reviewer).
  - No automatic switch. The service stays down, reads included, until copy 1 is back, or until a person decides
    to switch and accept the loss.
  - Cost: it waits whenever either copy can't report, even if the reachable one holds everything.
  - If misconfigured: a failover tool left free to switch on one copy's report silently loses confirmed writes and
    treats the switch as a no-loss one, so addresses can be re-issued.
  - Lands on `STO-54` and `CNF-365`.
- **Switch, as a restore** (today's draft).
  - A controller may switch to copy 2 without waiting for a person. The restore procedure then runs: the lost window
    is stated, every customer's token is revoked as after any restore, and deposit addresses skip ahead so none is
    reused. Skipping prevents reuse, but it doesn't bring back a lost deposit.
  - The service stays closed through those steps, and writes resume only once another copy streams from copy 2. So
    it saves less time than it seems.
  - Switching automatically is safe only if the switching tool also runs our restore steps.
  - If misconfigured: whatever runs the switch must class it as a restore and write the restore record before the
    service starts. If it doesn't, the service restarts on a restored database and re-issues addresses.
  - Lands on nothing new.

## F (new). A quick shutdown while both copies are down

**TL;DR:** A gap found by reading PostgreSQL's code. It isn't reproduced, and how long it stays open is
unmeasured. A quick shutdown of the main server while both copies are down can show a customer a deposit address no
copy holds. Lose the main server then, and the address can go to another customer. **The panel picks "Check
again", 3-1. All four accept either.** The reviewer didn't cover this.

Story: at 10:00 both copies are down, and a deposit's save is waiting for one. At 10:01 the main database is stopped
with a fast shutdown. That ends the wait, and the deposit becomes visible for a moment to requests already connected,
before each connection closes. The customer's repeated request, on one of them, is shown the address. At 11:00 the
main server's disk is lost before either copy has the deposit; it is enough that the main server simply stays down
while we switch. The copy we switch to never had the deposit. Our rules already call this switch a restore, which
would skip addresses ahead. But nothing tells whoever switches: both copies report the same position. Treated as a
no-loss switch, the address can later be handed to another customer.

- **Check again before showing a deposit address** (panel 3-1).
  - After reading a deposit, the service waits on the same connection until a copy holds what it read. If the
    connection drops, it reads again.
  - Cost: while both copies are down, showing any deposit address waits and then fails. Each showing costs one
    extra check (about 10 ms in our test, not a bound).
  - Reach: deposit addresses only. A replayed token revocation answered in that moment, and the engine's clean-up
    deletions, stay with follow-up F4.
  - If misconfigured: it needs the same read permission as S3's B. Without it no address is shown, which is loud.
    Under S3's A, it brings in B's check and that permission.
  - Lands on `STO-7` and `ADR-0045`.
- **Accept it for v1** (1 of 4).
  - The design record states the gap, and follow-up F4 owns it. Nothing in the service guards it. A deposit shown
    in that moment can be lost even if the switch is correctly treated as a restore.
  - Only a fast shutdown opens the gap; an immediate stop doesn't (from PostgreSQL's code). But nothing in the
    service controls which kind of stop the deployment uses.
  - Lands on `ADR-0045` and follow-up F4.
- *Not an option yet:* readers suggested keeping a record, off the main server, of how it shut down, so that such a
  switch is known to be a restore. It would be a new duty on the deployment. No reader has reviewed it as written,
  so it needs one more round if you want it.
