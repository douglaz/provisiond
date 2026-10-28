**Complete exact replacement B4* — UNREVIEWED.** This replaces B4 entirely. All amendments are **behaviour changed**.

STO-55: use the consumer-sentence replacement above. Replace “During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`).” with:

> Every physical connection attempt by component pools, reconnects, rollout incarnations, startup-lock holders, migrators and waiting runners MUST receive a distinct durable reservation before dialing from one serialized authority outside the protected store. Ingress MUST prohibit bypass and redial under one reservation. Bind grants to component/attempt identity and database boot identity, and to backend PID and `backend_start` when known. Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant.
>
> Unreleased grants MUST fit component capacity C. Bounded observer/operator/other-client allowances A include their residual and uncertain attempts. C+A MUST fit usable capacity after server reservations, with background/server resource pools budgeted separately. Keep separate read/write checkout budgets.
>
> Release requires fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended. Leaving SyncRep is insufficient. Unidentified attempts remain charged until fenced server-incarnation termination proves absence. Observer failure denies growth and retains charges.
>
> Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or stopped components and verified primary shutdown before a fresh account; either path fences all old grants and delayed attempts. Existing admitted sessions may continue. Exhaustion alarms, refuses growth and delays replacements.
>
> Startup acquisition refusal exits for supervisor retry; api returns overloaded before any transaction; worker/periodic acquisition refusal is an OPS-49 store error. Stop-record refusals consume existing bounds and send no SQL. No individual SyncRep backend may be cancelled or terminated to make room; primary shutdown remains STO-7’s exception.

OPS-47: replace “supervisor that restarts it and never runs two” with “supervisor that retries startup subject to STO-55 admission and never runs two”.

OPS-49 adds:

> An attempt denied by STO-55 admission is a store error for this loop and sends no SQL.

OVR-18 adds admission/accounting alarms. OVR-19 registers STO-55-owned C, allowances, resource ceilings and authority/reconstruction procedures.

CNF-290: replace “release the first and assert the second then starts” with:

> with sufficient STO-55 admission available, release the first and assert the second then starts; repeat with exhausted admission and assert delayed startup until verified capacity release

CNF-57/296/299 successful-service fixtures retain adequate reservations and live independent read sessions. CNF-362 successful-recording fixtures require admitted recording capacity; refused admission exercises existing exhaustion bounds.

New drill:

> Precheck engine and multiple api pools; freeze standbys, send disjoint writes and identify waiting PIDs. Stop the engine through its recording bound, lose api database transports, and overlap a rollout. Preserve one admitted read session if asserting read success. Verify old PIDs survive outside live pools.
>
> Keep replacement checks enabled; hold check replies/disconnect detection so replacement backends remain while attempts fail unused. Accumulate verified residuals and unreleased grants to exhaustion; assert no extra dial, alarm, bounded refusal and reserved observer access. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and lost accounting. Restore progress, fence attempts and prove backend termination before release and restart. Never release merely because `wait_event` changed.

This preserves STO-7’s “other than by shutting the primary down” exception and OPS-21’s “MUST wait at least the Stop-record bound”. Costs: reserves, durable admission infrastructure, restart delay and possible shutdown for unreconstructable accounting.

