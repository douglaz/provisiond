# Forms r63g (pv-s4m, panel C): taking in the external review. 2026-10-23

Base: /var/tmp/provisiond-panel-r63e/forms-final.md ("forms-final"), which holds the voted text with two slots still
PENDING (S2-STOP and S3). The items below add to it or fill it. Facts are in verify.md and in
/var/tmp/provisiond-pgharness/results.md (repository copy: docs/research/panels-2026-10/r63/pgharness/results.md) (H-a … H-f). Line numbers are at `dc5d40d`.

## NA: a sent COMMIT is never abandoned (new; Finding 1)

- **`05:141-144`**, `STO-7`'s "Two rules about the connection", after "…or the next checkout inherits an aborted
  transaction.", gains:

  "**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, neither a
  deadline nor the cancellation of the request or worker that sent it releases its connection before the reply arrives or the transport is found
  dead, so a live process never has more backends waiting for a standby than its pool holds (`STO-55`), and a
  request that finds the write checkouts taken is refused at checkout."

- **C9** (`CNF-296`) gains, before "Release the standby and", while both are still stalled: "Cancel every `api` request whose write waits, its client
  disconnecting, and assert the primary never holds more of that replica's backends than its pool, a further write
  request is refused `overloaded`, and a read still succeeds."
- **Why** (H-c):
  - The draft licenses the abandonment: `05:143` reads "a connection abandoned mid-transaction — by a timeout, a
    cancelled worker or a lost reply — MUST be reset".
  - In the harness, 17 abandoned waits used every non-reserved slot, with no restart.
  - C7 deletes the one existing bound, "Synchronous-commit transactions are capped per replica".
  - NA puts `STO-55`'s existing checkout refusal in that bound's place.
- **What NA does not bound:** backends left by a process that exits. That is the r63f Run point at `05:189-192`;
  it becomes follow-up F2.

## STOP (S2'): the engine's stop during a stall. Owner question

Both texts are unchanged from forms-final, "S2 texts", Option A and Option B. NA applies under either.
- The reviewer picks **A**: "B complicates shutdown semantics without addressing the larger API-side failure mode".
- With NA, the pile-up the A/B split was about is bounded per live process. An exit still leaves waiters, under A
  on a stop and under LOCK-A on contention.

## S3: what closes the recovered-commit hole. Owner question

### S3-B' (the reviewer's pick: S3-B, fail-closed, no transaction-mode pooler, `restart_after_crash` left on)

- **`STO-7`**: the PENDING S3 slot gets no text, and **RS's sentence** ("After any start of the primary, the
  deployment MUST NOT let a component connect to it until one of them has flushed the primary's WAL up to the end
  of the WAL the primary started with: a commit that was waiting … whether or not the standby has it.") is
  replaced by:

  "**A component checks each new connection before using it** (*added 2026-10-23, `ADR-0045`*): it MUST NOT use a
  new store connection until one of the standbys `OVR-19` names has flushed the primary's WAL up to the flush
  position the primary reports on that connection, which it learns by reading the standbys' reported positions,
  never by committing a write. A check that errors, cannot see a standby's position, or has not passed is a failed
  connection attempt: the connection is closed unused, and nothing falls back to an unchecked one. Every
  connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is
  checked: a commit that was waiting for a standby when the primary stopped is "marked fully committed once the
  primary database recovers", whether or not a standby has it."

- **`05:195-201`**, the bullet "**A pooler in transaction mode MAY front the pools only on two conditions.** …
  where a pooler is present." is replaced by (C8 is superseded):

  "- **No pooler in transaction mode fronts the pools** (*amended 2026-10-23, `ADR-0045`; until then one "MAY front
  the pools only on two conditions"*): behind one, a crash of the primary ends its backends but not the component's
  connection to the pooler, so `STO-7`'s new-connection check would never run."

- **C12** (`CNF-365`): "crash the primary, restart it in place, and assert no component connects to it until the
  standby has caught up" becomes "crash the primary, restart it in place, then separately crash one backend while
  a write waits, and each time assert no component uses a connection before a standby has flushed past the flush
  position it reported". It also gains: "Withhold the read of the standbys' positions and assert both components
  refuse every new connection."
- **The privilege** (H-f) goes in C13's ADR text, not in a MUST.
  - Without `pg_read_all_stats`, a role sees only pid, usesysid, usename and application_name in
    `pg_stat_replication`.
  - So the deployment grants it, or a SECURITY DEFINER function owned by a role that holds it. A missing grant
    fails closed: no connection is ever used.
- **Why the flush position and not the insert position** (H-f, xlog.c:9488): the insert position can sit past a
  page header that no standby's flush reaches on an idle primary. A flush target is safe because no connection is
  below `local`.
- **Why read and not write:** a write check leaves one `SyncRep` waiter per attempt during a stall (H-f: 3 of 3),
  which breaks NA's bound.
- **Deleted by S3-B':**
  - RS's deployment gate;
  - the transaction-mode pooler allowance, with `CNF-56`'s "MUST force a backend reassignment where a pooler is
    present";
  - r63f's `restart_after_crash = off`.

### S3-A (r63f's pick, 4-0): forms-final's PENDING S3 text, with RS kept. Unchanged

### S3-AB: both. Unchanged from r63f

## PT: promotion compares positions on one timeline (new; review §7)

- **Draft `STO-54`.** "both standbys `OVR-19` names report the end of the WAL each has flushed, and the one further
  ahead is promoted" becomes "both standbys `OVR-19` names report the end of the WAL each has flushed on the old
  primary's timeline, and the one further ahead is promoted". The list "Any other promotion — without both
  standbys' report," gains "with a report on another timeline,".
- **C12** gains: "With one standby on another timeline, assert the procedure promotes neither as a restart."
- **Why:**
  - H-e2: an old primary started as a standby without `pg_rewind` reported replay `0/47B2898` on TL1, against s2's
    `0/4004658` on TL2. It lacks every TL2 commit.
  - H-e: after a restart with the primary dead, both standbys reported `pg_last_wal_receive_lsn() = 0/4000000`
    whatever they held.
  - That is ADR material: the report is what each standby holds, not `receive_lsn`.

## PA: may a promotion that is a restore happen automatically? Owner question (new; review §7)

- **PA-1 (the draft):** no new text. A promotion without both reports, or of the one not further ahead, "is a
  restore: the procedure below runs on it". The text doesn't say who starts it.
- **PA-2 (the reviewer: "it MUST refuse automatic promotion, even at the cost of write availability").** Draft
  `STO-54` gains, after the "Any other promotion … is a restore" sentence:

  "Only an operator starts a promotion that is a restore: an automatic failover promotes only as a restart, and
  otherwise leaves the store without a primary until both standbys report or an operator decides."

- **The trade:** when the standby holding the latest acknowledged writes is unreachable, writes stay down until it
  returns or a human chooses to lose them (PA-2). Under PA-1, a controller may promote the other at once under the
  restore procedure, and acknowledged writes can be lost (H-e).

## INV: the invariant "No irreversible external consequence may depend on database history that an allowed failover could discard"

- **INV-ADR:** it goes in C13's `ADR-0045` as the rationale, with no normative text. Follow-up
  F4 audits every externally visible action against it.
- **INV-STO:** `STO-7` gains, after the lost-reply warning sentence:

  "**Nothing irreversible rests on an unacknowledged commit** (*added 2026-10-23, `ADR-0045`*): a component shows
  a deposit destination, makes a credit spendable, or requests a provider mutation only on state it read in a
  transaction whose commit is acknowledged, or on a connection `STO-7` checked."

- **The case for INV-ADR** (verify.md §6):
  - Every engine provider mutation already follows an acknowledged commit made after its authorizing reads:
    `OPS-43` `03:760` "Step 9 MUST begin only after step 8's transaction is acknowledged"; `OPS-45` `03:1422`; the
    claim.
  - The mint and the credit are writes.
  - The deposit re-send is covered by the S3 fix.
  - Draft `STO-54`'s stop rule keeps a process from spanning two histories.
- **The one residual found:** E2's "other than by shutting the primary down" (a fast shutdown) leaves a
  sub-millisecond read window on an already-checked connection (analysis only). It goes to F4.

## Scope split

- **pv-s4m carries:** forms-final, plus NA, STOP (owner), S3 (owner), PT, PA (owner), and INV-ADR or INV-STO.
- **Follow-up beads,** filed `needs-triage` after the Run:
  - **F1: a WAL-history model** in `tools/formal/`. Prove `BarrierAck ∧ SameHistory ⇒ Replicated`. Exhibit
    counterexamples without `SameHistory` (H-d) and with a lagging promotion (H-e).
  - **F2: residual backends from exiting processes during a stall.** A supervisor backoff, or a budget across
    restarts and rollouts (`05:189-192`). Availability only.
  - **F3: replication-configuration drift at run time.** H-d: an empty `synchronous_standby_names` plus a reload
    makes every commit local, and nothing in provisiond sees it. `CNF-296` checks only a fresh connection.
  - **F4: an audit of every externally visible action against the invariant.** It covers the fast-shutdown window,
    and whether deposit-returning reads (`API-45`'s re-send, `GET /v1/deposits/{id}`) need a same-transaction
    barrier in addition to the S3 fix.
- **Not filed:** re-admitting a transaction-mode pooler with a per-transaction check. Nothing needs it. The ADR
  records it as rejected for v1.

## Run review points added by r63g

- `11-open-findings.md:438` (F51's record: "A transaction-mode pooler may front the pools only with …"): leave it as
  a record. If S3-B' carries, its resolution line gains "amended by `ADR-0045`".
- If S3-B': the r63f point "If S3-B: `05:195`'s … gains S3-B's pooler condition" is superseded by S3-B''s
  replacement bullet.
