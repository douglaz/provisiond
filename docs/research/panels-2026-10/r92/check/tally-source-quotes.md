# Independently read pinned evidence

## 05-persistence.md

```text
1691: - **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every
1692: engine and `api` process, and MUST start neither component until the transaction that commits
1693: `STO-56`'s record (below) has been acknowledged (*added 2026-10-24, `ADR-0047`*).
1694: 
1695:   For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of
1696:   the newly begun transaction inserting this incident. This is the event time of incident
1697:   creation, not the time of the recovered history. The transaction begins after the existing
1698:   stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it
1699:   is not claimed as a fact already proved by the formal model.
1700: 
1701:   The report separates that event from the history that survived. Persist a nullable
1702:   conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence
1703:   references when the incident is inserted. A non-null b MUST certify that every source-history
1704:   component commit acknowledged before b belongs to recovered committed history. A non-null f
1705:   MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST
1706:   be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery
1707:   time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather
1708:   than an apparent finite interval.
1709: 
1710:   The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence
1711:   that e bounds the source clock's error, the timestamp was generated before insertion, and the
1712:   recovered continuous prefix on matching ancestry contains that complete record. Capture the
1713:   observation before restart can erase it, or identify the complete record in retained WAL. The
1714:   earlier-acknowledgement implication is the certificate: this timestamp is neither an exact
1715:   snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN,
1716:   filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound
1717:   needs the same inclusion proof.
1718: 
1719:   A verified upper error bound on the incident transaction's event clock, with retained
1720:   stopping/fencing evidence that no old-history acknowledgement follows that transaction's
1721:   start, can supply f=restore_instant+e_event. Source and event clocks may have different error
1722:   bounds; record their provenance. If either endpoint cannot be certified, persist null for it
1723:   and say that endpoint is unknown. The event timestamp alone never substitutes for a missing
1724:   history bound. Retain evidence outside the lost failure domain or with the incident so that
1725:   continuation does not depend on the failed primary.
1726: 
1727:   Publish possible loss within [b,f] and its bounding duration only when both endpoints are
1728:   known. Include b because the lower certificate guarantees commits acknowledged strictly before
1729:   b. Otherwise publish each known bound, identify every unknown endpoint and state that no
1730:   finite duration is established; identify clock/provenance assumptions for known bounds.
1731:   Missing reporting evidence does not hold incident creation, the existing restore procedure or
1732:   component startup once its existing prerequisites are satisfied. Continuations reuse the
1733:   persisted endpoints and evidence unchanged. Backup restores use the same contract.
```

## tools/formal/Provisiond/Restore.lean

```text
1: import Provisiond.Claim
2: import Provisiond.Tables
3: /-! `STO-54`'s restore beside `STO-5`'s restart: "A restore from backup is not a restart and is
4: not covered by this sentence". A live engine commits a `History` of steps on a `Store` and
5: crashes; what it comes up on is either that store (`RestartTrace`) or a store `Δ` steps behind it
6: with the provider's facts unchanged (`RestoreTrace`). The two are distinct types, so a theorem
7: over restart traces cannot be cited for a restore; `restore_breaks_soundness` (in the witnesses)
8: is the concrete trace on which `OPS-15`'s premise — "any `running` row at startup is interrupted",
9: and a `queued` row never ran — is false.
10: 
11: The four fault events the inventory names: a crash ends a `History` (the store is what it
12: committed); `restart` and `restore` are `Fault`'s constructors, each the boot of its own trace
13: type, and `Δ` is `RestoreTrace.delta`; the complete procedure is `Event.completeProcedure`,
14: `STO-54`'s step (3). A crash *inside* the procedure is `Event.crash`, an event of the run rather
15: than a boot: `STO-51`'s lock dies with the process and the store is what its successor comes up on,
16: `STO-54`'s restore record with it — the record decides the mode the successor comes up in, and its
17: marks say which procedure steps it does not run again; `OPS-15`'s pass over `running` rows runs
18: once per process, independently of step (2)'s durable mark. The procedure's phases are `Permissions`, one field per thing the engine or
19: `api` may do — claim, serve, record absence, run each component — never one Boolean, computed
20: from the fault the engine came up on and the steps done.
21: 
22: `Params` lists the guards dated amendments added, each a field so that removing it is a one-token
23: change a witness theorem exercises (`ADR-0025`). Every model here is one tenant, one machine, one
24: engine (`OPS-47`), and time does not advance: `now` abstracts the incident-creation event
25: clock. `STO-54` defines that event: "restore_instant is transaction_timestamp() of the newly begun
26: transaction inserting this incident." The SQL definition is new; this model does not establish
27: it or model recovered-history bounds. Interval/certificate publication and its evidence protocol
28: remain outside the model's scope.
29: 
30: The create restart arm is the 2026-10-17 amendment to `OPS-15`: "A create found `running` at
31: startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."
32: 
33: What the model omits: the money release. For promotion classification, see `STO-54`. This module takes the classification as input;
34: it does not compare WAL reports. A restore-class promotion is a `RestoreTrace`. The safety of the
35: restart arm is **not proved**, and the model admits its failure: `Live` has no step 8, so a create
36: claimed, applied and then interrupted reaches the restart arm with the column null and settles
37: `failed`. Only `OPS-43`'s "Step 9 MUST begin only after step 8's transaction is acknowledged."
38: excludes that trace.
39: Also omitted: `Provisiond.Reconcile`'s knowledge type — absence here is the machine's
40: `recordedGone` Boolean, and `OPS-32`'s own three conjuncts (a complete pass, `PRV-36`'s window,
41: the direct reread) are that module's, so on a restart the sweep records an absence on a complete
42: pass alone; when the record closes, which `STO-56` gives to the operator once the obligations that
43: outlive step (3) are discharged — so the record is open throughout this module and every successor
44: here is a continuation, and a boot on a closed record is the restart `bootRestart` already is;
45: `STO-54`'s step (1) beyond the freeze (the possible-loss report,
46: the account status and the rate quorum) and step (3) beyond the credential bump and the grace
47: (the watch set, the rails, `SEC-39`'s counters, the derivation index); the operator cancelling a
48: waiting parent, which `Event.confirmParents` stands for beside confirming it; the sweep's
```

## tools/formal/Provisiond/WalHistory.lean

```text
1: import Provisiond.Req
2: import Std
3: 
4: /-! WAL history checking interpretation for `STO-7` and `STO-54` (pv-26ju).
5: 
6: `STO-7`: "Before exposing a deposit destination read from the store, repeat the read-only
7: flush-position check with a target sampled after that read, on the same uninterrupted
8: PostgreSQL session." `BarrierAck` abstracts the successful position observation in this check;
9: it does not issue a write. It can also describe the flush observation behind an acknowledged
10: WAL-writing transaction. H-d uses that historical write-barrier shape only as a counterexample.
11: The new-connection check alone precedes later reads and supplies no `ReadBeforeTarget` for them.
12: 
13: Premises, not PostgreSQL proofs:
14: * `ReadObserved`: the read is attributed to the actual commit at its index in the read history.
15:   This is the platform visibility/commit-identity interpretation of reading a stored destination.
16: * `ReadBeforeTarget`: the sampled flush endpoint follows that commit. The platform's visibility
17:   and local-flush ordering, with the sample after the read, supply this; sampling chronology alone
18:   is not a proof of it. Source: the quoted deposit-read clause and `ADR-0045`'s flush-position
19:   argument. An endpoint counts abstract records, not WAL bytes.
20: * `SameHistory`: the histories agree record for record through the earlier commit, independently
21:   of positions and labels. The uninterrupted-session clause above and `STO-54`'s duties —
22:   "Before any component connects to the promoted store, the deployment MUST stop every engine
23:   and `api` process that was connected to the old primary" and "the old primary MUST NOT serve a
24:   component again" — are its deployment basis, not facts established here. Histories may extend differently
25:   after this prefix; equality of complete histories is unnecessary.
26: * `DurablePrefix`: a report is in bounds and the actual durable records equal that history's
27:   prefix at the reported endpoint. It assumes observer/report correctness and continuous durable
28:   WAL prefixes. `STO-7`: "has flushed the primary's WAL up to the flush position the primary reports
29:   on that connection". `STO-54`: "both hold a prefix of one WAL sequence". For promotion the
30:   snapshots are after old component processes stop; reports describe retained, not discarded, WAL.
31: * `SynchronousCommit`: a received acknowledgement has an actual commit record and at least one
32:   named standby's report is beyond it. `STO-7`: "PostgreSQL acknowledges a commit only once one of
33:   them has flushed it to durable storage". It is the trusted deployment/platform duty, supplied
34:   separately from the durable-prefix facts, never a field assuming replicated membership.
35: * `MaximalReport`: selection compares every eligible standby, including equality. `STO-54`:
36:   "a standby whose reported end is at least as far ahead as the other's is promoted (either may
37:   be chosen when they are equal)". The eligible names here stand for the deployment's named pair.
38: 
39: The model proves list membership from these premises. It does not prove PostgreSQL implementation
40: or SQL behavior, observer/report correctness, actual topology/configuration, process stopping or
41: fencing in a deployment, or every externally visible action's safety. It models neither incident
42: procedures nor permission to promote: H-e can be an operator-authorized restore, never evidence
43: for calling it a restart. It does not compose with `Restore.History`, which is live engine steps.
44: No new runtime mechanism, trusted assumption, or implementation conformance follows from a green
45: gate. No rendered region is added; see `ADR-0025` for authority.
```

