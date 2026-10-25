Static review at `b90783d`; no gates or `lake` run.

**R (merged): ACCEPT. E (completed): ACCEPT. Pick: R.** R preserves outcomes already in hand and lets E1 finish rows claimed after E2’s startup pass. E’s shorter lifetime supplies no provider fence.

**The merge: right.** It preserves “MUST NOT cancel `execute`” and “records no error”; case (vi) checks those exceptions under lock loss.

**Against my pick:** R extends the overlap with a misconfigured E2 while existing periodic work continues. E gives a simpler shutdown policy and minimizes activity after detection. Where the worker already knows only uncertainty, recording buys less.

**Fence G: YES**, for database transactions after the generation advances, including claims before E1 detects loss. This adopts `ADR-0019`’s rejected policy, “Fix the predicate”, using a working shared value. Cost: per-transaction locking, takeover contention and discarded stale outcomes; previously authorized provider calls remain possible. PostgreSQL says “A shared lock blocks other transactions from performing `UPDATE`”. [PostgreSQL 18](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS)

**Fence A: YES**, as a recording checkpoint. Cost: another connection/checkpoint, refusal by E1’s unreaped session, and lost recording opportunities; it provides no protection for earlier claims or transactions already sent.

**S3:** Recovery can avoid a person when fresh authoritative evidence recovers the schedule and date. `PRV-29` requires distinguishing “scheduled with an effective date”; `OPS-45` routes resolution through “provider evidence where the driver can produce it”, with operator fallback otherwise. No special parked-cancellation rule is necessary.

**Brief errors:**

- “A cut-off during a provider call ends `needs_reconciliation` under both” is overbroad. Stop a create during step 4’s List offers: `OPS-11` says “MUST settle `failed`, whatever its kind”. At restart, `OPS-15` says a create “with `about_to_order_at` null MUST be settled `failed`, on a restart only”.
- “A kill or a failover records nothing” repeats correction 5’s error. S1’s E row need not remain `running` either: a repeating transaction may already have committed with its reply lost. `CNF-362`: “Accept either outcome”.
- S1’s “A detour, not a person” needs a successful later search assumption. `OPS-27` expressly includes “the listing window has expired” among cases that “Escalate to an operator”. A verified correlator alone does not guarantee automatic resolution after restart.
- S5’s “each holds its machine” is false generally. The operations table says `machine_id` is “nullable; set on completion for create”; `STO-51`’s index additionally requires `yielded_at IS NULL`. The stranding/blocking trace remains valid for non-yielded existing-machine operations.
- Fence A’s “only” better-than-sweep records overstates its selectivity. It also refuses records already overtaken, or with the same classification as restart recovery: `OPS-11` gives refresh “Always `failed`”; `OPS-15` says a running refresh “MUST be settled `failed`”.