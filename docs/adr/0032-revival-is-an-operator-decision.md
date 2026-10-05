# Revival is an operator decision

**Status:** accepted (2026-10-04, `pv-gip.11`, owner decisions Q11/Q12); amended
2026-10-05 (`pv-gip.43`, Q14).

A decision to delete deserves care before it is made. A provider hiccup followed by a favorable
rate is no new decision to keep a machine. Automatic revival made that accident choose for the
operator, while overloading retry with revival made the operator's intent ambiguous.

The rule homes are `OPS-41`, `OPS-48`, `API-64` and `API-68`; the wire home for keep is
`WIR-55`. This decision supersedes `ADR-0021`'s retry-as-withdrawal argument and its accepted
no-exit residual, preserving its gone-write and permanent-close reasoning.

Rejected alternatives from the Q11 panel: closing in re-derivation (Opus/Sol) would let price
maintenance reverse the deletion decision; a second sweep population (Astra) would add a second
lifecycle scanner for the same automatic reversal. The original Q12 decision (narrowed by Q14 below) rejects retry that revives: an
operator asking to retry deletion should not unknowingly keep the machine. An explicit keep
records that choice without pretending it pays for the machine.


## Q14: the decision is recorded by the fence — 2026-10-05

Owner decision on `pv-gip.43`, comment 194, narrows Q12. The owner's Q12 reason on `pv-gip.11`,
comment 178, was "the decision to delete was made when the fence was written". A never-fenced
episode has no recorded deletion decision to reverse: its retry decides from funding and can close
`funded`. `OPS-41` step 2 is the sole normative home; this addendum owns the reason. Q11's
operator decision remains necessary to leave a stalled episode, apart from the gone-write;
price maintenance alone does not close it. No state, verb, close reason, column or row is added.

The established null-fence stalled routes are crash and restore through `OPS-15`: "move every
`running` operation to `needs_reconciliation`". For restore its warning is "the row may have
settled at the provider inside the lost interval". `OPS-31`'s `not_applied` outcome is "it did
not, so it settles `failed`"; `OPS-48` renders "Resolved `not_applied` — the machine is still there" as `stalled`
with the fence "**Unchanged**". Neither route manufactures the missing fence.
After a restore, a rolled-back fence counts as never written: a decision made in the lost
interval is not honored. The retry decides as a re-run delete does under `STO-54`, which directs
goal-state kinds to "re-run, since `OPS-11` classifies ‘already in the target state’ as
`succeeded`". The original restore claim gate remains ahead of that decision: `OPS-41` says
"A claim made while a restore record is open and its `grace_ends_at` is null or in the future
defers, and writes no fence". That gate is distinct from step 3's funding-only paused-grace
check, reached "Only if the predicate would cancel".

Owner comment 194 says "Covers all three routes", including worker-recorded pre-fence
failure. The fence-keyed rule covers that condition if such an ordering is ever specified;
no current clause orders a worker-recorded failure before the fence write: `OPS-45` says "This rule classifies a failure a worker recorded";
its interruption rule applies "whatever the markers hold". `OPS-23` requires validation
"before the driver is called", which does not order it before the fence. Store failures instead
follow `OPS-49`'s "repeat the **whole transaction**" and, on exhaustion, "the engine MUST exit
non-zero". Thus this amendment specifies no separate route-3 injection. The model deliberately
admits abstract pre-fence failure as an over-approximation; `CNF-312` drives the established crash
route only. In every case the rule is keyed on the fence, not the route.

Rejected alternatives:

- (2) `not_applied` closes the episode: no existing close reason is true there; the fix would key on one route rather than the fence.
- (3) Fence earlier: a crash would decide deletion without the re-check.
- (4) Startup requeue: the proposed alternative covers the crash route only, using the
  interrupted attempt's markers to choose requeue. Restore can roll those markers back too;
  they cannot establish what happened in the lost interval (`OPS-15`: "the row may have
  settled at the provider inside the lost interval"). The accepted rule uses the restored
  record, with the missing fence treated as above; it does not preserve a lost fence or
  reinstate startup requeue.

The former RetryFenceInv and retry_has_episode_fence are withdrawn: sweep, claim, interrupt,
resolve notApplied, retry leaves an open episode and a null fence. The replacement extension
proof uses that null fence directly, and the interruptedRetry witness compares the guarded and
unguarded policy. These are model results, not running-service conformance; full crash/restore,
queue scheduling, database and provider behavior remain outside those proofs.
