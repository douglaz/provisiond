10-conformance-checklist.md
- [ ] **CNF-202** — Suspending a tenant returns a `suspend_tenant` operation whose children are
      readable through `GET /v1/operations`; resume is synchronous and restores no machines.
      Separately, hold a power operation the caller requested `running` at its driver call on one
      of a tenant's machines, and keep a second worker free. Enqueue a second power operation the
      caller requests on that machine, and hold the engine's clock from then until a worker has
      claimed the `suspend_tenant` operation. `OPS-8` says “A claim (`OPS-5`) that the index refuses
      because another running operation holds the machine MUST return the operation to `queued`
      with a short delay”. Before suspending, read the second at the store and check it is
      `queued` with `claim_number` 0. `OPS-6` says “A claim the per-machine index refuses
      (`OPS-8`) never left `queued` and does not advance the number”. Suspend the tenant. Keep the
      first held until the second has left `queued`. If the first settles before that, the setup
      failed and the case has not run. If the second is still `queued` when a stated bound
      passes, the case fails there, before any release. Otherwise release the first, and wait
      until the `suspend_tenant` operation has settled. Then assert the second is `failed` with `conflict` and
      `details.reason: "tenant_suspended"`: `API-58` says “`queued` but never claimed straight to
      `failed`, carrying the reason in the operation's `error`: `conflict`, with
      `details.reason: "tenant_suspended"`”. Assert its `requested_by` is `caller` and its
      `system_reason` is null: `API-58` says “Its `requested_by` stays `caller` and its
      `system_reason` stays null”. Assert no provider request was made for it: `API-58` says “it
      has touched no provider”.
      (`WIR-39`, `WIR-41`, `API-58`, `WIR-9a`, `WIR-10b`, `OPS-6`, `OPS-8`, `ADR-0022`)

      Independently admit an otherwise valid create while the tenant is active, with a healthy provider
      account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
      the create before the suspension fan-out can fail it. Assert failed, conflict with
      details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
      request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
      stamp, and no admission-only suspended error.

      Separately let the worker's early tenant read see active, then commit suspension before the
      step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
      no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
      tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
      commits and is acknowledged, suspend before the provider call and assert the attempt is treated
      as potentially dispatched and allowed to settle, with a system cancellation in the machine's
      attach transaction if the tenant remains suspended. Exercise late evidence attachment after
      the suspension parent has settled as well.

      Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
      deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
      full release and no speculative dispatch. Retain the worker claim guard in every settlement.
      Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
      provider using per-order temporary keys.

      Independently combine an unhealthy provider account with a suspended tenant and assert the
      account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
      channel and assert tenant_suspended wins. Assert no provider request in either case.

      *Amended 2026-10-21 (`pv-1wn`, panel r60): added the queued, never-claimed caller power
      operation that suspension fails with `tenant_suspended`, held `queued` behind a running
      power operation on its machine, quoting `API-58` for each assertion.*
