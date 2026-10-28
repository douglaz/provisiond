**Complete B3 replacement B3R — UNREVIEWED; all amendments behaviour changed.**

Replace STO-55’s “During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`).” with:

> One durable serialized authority outside PostgreSQL MUST grant a distinct permit before every component physical dial, including reconnect, rollout and startup-lock attempts. Controlled ingress MUST prohibit bypass and redial. Each permit authorizes at most one backend and identifies incarnation, attempt and target boot; bind PID/backend_start when known. Unknown attempts stay charged. Never release on timeout, client/process death, lease expiry or merely leaving SyncRep. Release requires fencing every delayed/retry capability and fresh authoritative evidence of termination; unidentified attempts remain charged through proven server-incarnation termination.
>
> Outstanding component permits MUST be at most C. Allowances A include live, residual and uncertain observer/operator/migrator attempts and waiting runners; apply the same before-dial accounting. Require C+A+server reserves to fit max_connections, with separately bounded internal pools/resources. Reserve read capacity separately. Maintain bounded privileged observation using reserved resources and controlled ingress, assuming responsive database/control resources; otherwise freeze releases and admissions. Exhaustion alarms and delays replacements. Accounting loss closes ingress until fenced conservative reconstruction or stopped-components primary shutdown. No local fallback or second issuer is permitted.

Matching edits:

> STO-55: replace “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” with “Pool sizing reserves consumer checkouts; physical growth additionally requires deployment admission.”
>
> OPS-49: denied admission sends no SQL and consumes existing store-error bounds. Stop-record bounds/exits remain unchanged. STO-7’s “MUST NOT cancel or terminate a primary backend while it waits for a standby” remains, including its shutdown exception.
>
> OPS-47: replace “under an external supervisor that restarts it and never runs two.” with “under an external supervisor that never runs two and retries startup subject to STO-55; exhausted admission may delay startup indefinitely.”
>
> CNF-290: replace “release the first and assert the second then starts.” with “With admission available, release the first and assert the second then starts; separately exhaust admission, assert delayed startup, then restore verified capacity and assert startup.”
>
> CNF-296/299: add “Retain independently admitted live read sessions and functioning admission/observation throughout these existing success traces.” Keep the cancellation-only pool bound.
>
> Add a residual drill: precheck engine and multiple api replicas; pause commits before local flush; lose selected client transports while preserving server legs; admit replacements while healthy. Freeze, release paused commits, verify old SyncRep PIDs, stop the engine through recording expiry and overlap rollout. Failed replacement checks remain closed unused. Blackhole further check replies/disconnects, retaining server legs until C exhausts; assert no additional dial and bounded refusal. Promise reads only on retained read sessions. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and accounting loss. Restore replication/transports, verify actual termination, release permits and resume. Register C/allowances/reconstruction in OVR-19 and alarms in OVR-18.

The invariant is injective: actual controlled backends ≤ unreleased permits ≤ C. It requires durable-before-dial grants, complete ingress control and release-after-fenced-termination. Leaving SyncRep is not disappearance. Observer allowances include their own failed attempts.

Strongest argument: retained charges prevent double-spending departed processes’ slots. Owner costs: reserves, independent durable admission, indefinite restart delay and possible reconstruction shutdown. Capacity is guaranteed conditionally; continued service is not.

