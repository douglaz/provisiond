**Framing check.** The sources contradict two assumptions behind the brief's options:
- **v1 sells no offer that shares a request bucket.** `ADR-0039` says: "v1 sells Hetzner Robot's default dedicated servers only". So no tenant *operation* reaches a Cloud project. One gap remains: `GET /v1/providers/{account}/offers` calls `list_offers` synchronously and needs no machine. It sits outside `PRV-46`'s per-operation admission, and I found no rule that caches it [verify]. Robot's quotas are per endpoint (`GET /server/{n}`: 200/h, per the Robot webservice reference). `PRV-44`'s `{scope, limit, per}` cannot express per-endpoint quotas, and `PRV-46` names only Cloud's scope (`02-provider-contract.md:1052`).
- **Cloud publishes its own counter.** Every response carries `RateLimit-Remaining`, which "will increase by 1 every second" (cloud.spec.json). The model leaves out exactly that: "no refill or external traffic" (`tools/formal/Provisiond/ProviderTraffic.lean:9`). `ADR-0036:55` already rejected a local count: it "can drift from it in both directions, while a gate closed by the provider's own answer cannot."

**Strongest "don't build this", for all three:** defer Decision 3 until an offer that shares a bucket is re-admitted (`ADR-0039` Decision 2's live test), and ship Decisions 1–2 and Q10 now. The threat that is live in v1 is one `ADR-0034:78` lists as "Not covered here". If Robot counts `GET /server/{n}` per account, refresh loops on four machines at a 60 s window exceed 200/h. `PRV-42`'s "read directly to confirm the machine" and `OPS-32`'s direct re-read use that same endpoint [verify].

## Q19a — Reading (3), gated on the provider's reported remaining rather than a local count

A new caller operation is admitted only while the scope's last `RateLimit-Remaining` exceeds the reserve and no `429` reset is pending. Continuations always dispatch. If the provider refuses one, `OPS-11` and `OPS-48` already cover it. What the reserve buys over plain throttling is one thing: a system delete's first request does not meet a `429`, settle `failed` and stall (`OPS-48`).

Residual: only three things can enter the reserve. They are continuations of operations admitted above it, concurrent claims landing between two responses, and traffic from outside provisiond. The residual is finite because nothing new is admitted. Per machine it is `OPS-8`'s one unyielded operation plus `RSC-41`'s bounded phase. `OVR-19` sizes the reserve against it.

Reading (1) needs a wait inside an operation, ordered against new admissions, and still can't reserve what outside traffic spends. Reading (2) fails on `OPS-33`: orders "poll through an `in process` state with no documented bound" (`03-operation-lifecycle.md:1457`).

Defects:
- `ADR-0034:71` says "It never reaches the system's own deletes". That is false under every reading.
- `ProviderTraffic.lean:181` proves a local predicate, not capacity; it still holds when `remaining` is negative.
- `Witnesses.lean:3927` runs the system work before the depletion happens.
- `CNF-338` (`10-conformance-checklist.md:3351`) asserts continuation "when total available capacity is exhausted". That is a provider fact the deployment cannot observe.
- `PRV-46` (`02:1064`) never says where admission is recorded. `OPS-8`'s defers re-claim operations that have already called the provider, so admission belongs on the operation row.

Edits:
- `PRV-46` (`02:1053-1056`): replace "account for each provider request before dispatch" with "read the provider's reported remaining". Drop the lowered limit and `OVR-19`'s limit row (`00-overview.md:378`).
- `ADR-0034:71`: state the residual instead.

## Q19b — Gate by who enqueued the operation: caller requests may be refused, system and operator work never

Gating by actor fails on `API-65` (`04-api-contract.md:1099`): "A release the delete's terminal transaction enqueues carries the delete's own `requested_by`". A tenant delete's release is therefore stamped `caller`, yet it reduces exposure, and Robot lists additional IPs as "possible `api` survivors" (`ADR-0037:155`). Gating by path needs an exposure-reducing class that nothing stores.

Operators are already bounded: "`SEC-39`'s ceilings at 5c are the operator's whole budget" (`04:165-166`). `API-64` says "a stalled episode is retried by an operator, and by nothing else". Refusing that retry recreates the stall the reserve exists to prevent.

A caller's `delete_machine` is an open owner question. Refusing it bills the tenant for time it asked to stop. But `OPS-42` fences only exposure-reducing cancellations, so a refused delete can be resent.

Defects: `Origin` (`ProviderTraffic.lean:107`) has no operator case, and `PRV-46` (`02:1062-1066`) lists paths instead of `WIR-10a` values.

Edits: `PRV-46` may refuse only `requested_by: caller` work, and never a `release_attachment`. `Origin` becomes `WIR-10a`'s three values plus `kind`.

## Q19c — Admit at claim, after the cache check: `202`, then `failed`/`rate_limited`, no `429`

`PRV-46` says "Local cache settlements make no provider request and need no request-budget admission" (`02:1070`). Q10 says "The cache check runs when a worker claims the refresh" (`ADR-0034:96`). A check at enqueue would refuse refreshes the claim could answer from the cache, and it would read capacity that is stale by claim time.

Settle the refusal as `PRV-40`'s claim-time paragraph does (`02:1037`), citing it rather than copying it: `retry_after_ms`, `retryable: true`, and a create's commitment released. With no `429`, `API-50` (`04:1241`) needs no new exception. Add no purchase-tail copy: capacity moves every second, while `API-7`'s channel closure does not.

Defects:
- `PRV-46` never says how to derive `retry_after_ms`, which `WIR-9a` requires (`13-wire-contract.md:132`). It is (reserve − remaining + 1) × period/limit, capped by `RateLimit-Reset`.
- `OPS-11`'s note on refusals before acceptance (`03:254`) names only `PRV-40`.

## Lean and CNF

One trace, with reported remaining, refill and outside traffic:
1. A caller operation is admitted above the reserve.
2. Its continuations plus outside traffic take remaining down to the reserve.
3. A new caller operation is refused at claim: no call, `rate_limited`, retry-after > 0.
4. A refresh with a fresh cache settles locally.
5. A caller delete's release, an operator retry and a system delete all dispatch.
6. Theorem: after closure, caller dispatches come only from operations admitted before it.

Mutants: checking the budget before the cache refuses step 4; an actor-only gate refuses the release; a local count admits step 3.

CNF changes:
- `CNF-338` takes the sequence above.
- `CNF-337` (`:3344`) adds the operator retry and release.
- `CNF-336` (`:3335`) drops "each has already consumed budget".
- `CNF-339` (`:3358`) loses the lowered-limit rows.

Housekeeping: I edited no tracked file. I ran `check-all.sh` once, unpiped, at `16f9db8` after reading, and it exited 0; there was no before-and-after pair. I wrote two scratch files under `/tmp`, against the brief, and have deleted them.
