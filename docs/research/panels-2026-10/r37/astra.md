FAIL at `16f9db8`: use provider-triggered suppression with explicit residual-loss acceptance; neither paid machines nor caching guarantees system capacity.

| Path | Robot requests; documented limits | Driver |
|---|---|---|
| Refresh | `GET /server/{n}` 200/h; IP/subnet reads 5000/h for restriction evidence | Repeatable tenant work |
| Create / resolution | Product reads 500/h; order POST 20/day/channel; transaction GETs 500/h; direct server confirmation and cancellation-constraint GET 200/h; key registration/deletion 200/h | Tenant starts; system completes/searches |
| Delete | Cancellation GET/POST 200/h; direct server confirmation 200/h | Tenant or system |
| Account sweep | `GET /server` 200/h; missing-server direct GET 200/h; attachment/key enumeration and cleanup | System evidence |
| Power, rescue inventory/install | `POST /reset/{n}` 50/h; rescue GET/POST/DELETE 500/h; temporary keys | Repeatable tenant work; necessary exit cleanup |
| Attachment release | IP/subnet enumeration/direct GET 5000/h; cancellation GET/POST 200/h | System/operator |
| Reverse DNS | `/rdns` GET and per-address GET/POST/PUT 500/h | Repeatable tenant writes; resolution reads |

Limits: [Robot reference](https://robot.hetzner.com/doc/webservice/en.html). Linux boot endpoints are also 500/h, but are not inherently part of the specified SSH/installimage route. Cancellation withdrawal has no v1 tenant verb.

The reference does **not establish** account versus webservice-user versus source-IP scope, nor whether different server numbers share a counter. Its explicit IP lockout concerns authentication. Therefore four machines exhausting one bucket is conditional, not verified. The error owner is `PRV-5`, not `PRV-50`: `02-provider-contract.md:50` says “MUST map to `rate_limited`”.

**Blocker — paid machines do not bound interference.** At a 60-second window, four responding loops demand 240 reads/hour if the bucket is shared. With failures, one paid machine can drive repeated requests: `01-domain-model.md:145` permits “a fresh subsequent operation can read again”. A configured window below 18 seconds also permits one healthy loop to exceed 200/hour.

Orders constrain acquisition rate, not accumulated fleet size or requests per existing machine. The attacker funds accepted machines at the customer rate, including their first units; repeated refreshes and resets require no new purchase. `04-api-contract.md:247` says “they are not purchases, and they pass no spending gate”. An order’s transaction polling also has no request-count bound derived from the order ceiling.

Resets matter independently: `07-security-requirements.md:212` specifies “ceilings per principal”, not an aggregate endpoint bound. If configured ceilings permit, one machine can issue 50 power resets; several principals can combine traffic. Rescue needs entry and exit resets: `02-provider-contract.md:579` requires “initiate the reboot or reset”; `:615` requires “reset or reboot into the installed system”. Exhaustion can strand another operation’s exit if they share the counter. Paying for attack machines does not establish that collateral operator loss is priced.

**Blocker — the reservation pre-read premise is unnecessary.** `08-provider-notes.md:405` says “you learn which case applies only by reading” cancellation first. When cancelling without reservation, that distinction is unnecessary: always sending `reserve_location=false` satisfies both documented branches. Retain reads needed for actual contract dates or ambiguous outcomes. [Cancellation input](https://robot.hetzner.com/doc/webservice/en.html#post-server-server-number-cancellation).

Candidate **(a)** reduces successful list fetches to 60/hour at a 60-second window, independent of fleet size. However, the list lacks cancellation dates and IP/subnet locking evidence. `02-provider-contract.md:889` requires “report positive network-restriction evidence”. It also cannot replace absence confirmation: `03-operation-lifecycle.md:1379` says “A missing machine MUST be re-read directly”; `:468` requires create confirmation “by a direct read”. Coalescing positive observations is useful, but supplemental reads and Q10’s failure behavior remain. Candidate **(b)** cannot bound arbitrary fleet size or failed reads.

My smallest choice is **(c), with explicit acceptance of its residual**:

- Persist a closure on configured account and method/endpoint after Robot’s `403`, using its reported interval; alarm. Treat that key as local policy until upstream scope is verified.
- At worker claim, after the cache check, fail new optional tenant work needing that endpoint locally: `rate_limited`, remaining `retry_after_ms`, `retryable:true`. Cache hits still succeed.
- Keep deletes, releases, evidence work and required cleanup eligible regardless of actor; preserve admitted continuations and acceptance classification.

This suppresses amplification. It cannot protect the first exhausted interval or guarantee recovery against outside traffic. Do not add timed mutation retries. The strongest “don’t build” is that guessed counters and scheduling machinery cannot establish undocumented upstream isolation.

Edits: finish Q19’s withdrawal at `02-provider-contract.md:1051`, the descriptor/register and ADR-0034. Remove budget-only Lean declarations and CNF expectations while retaining refresh/PTR behavior. Put Robot suppression in one provider-contract owner; amend `01-domain-model.md:145` and extend `10-conformance-checklist.md:3310` for an actual throttle, preserving successful-observation-only freshness.

Lean must prove cache-first closure behavior and zero calls on local refusal—not upstream capacity. CNF must exercise concurrent tenants, restart/expiry, failed reads, reset exhaustion during rescue exit, throttled system evidence, no false absence/age advancement, and alarm/operator recovery. A provider measurement must separately establish counter scope and reset behavior.

Both unpiped gate runs passed. Tracked files are unchanged.