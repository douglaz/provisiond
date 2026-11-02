**WIR-10** The **operation view** (`API-20`):

```json
{
  "id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11", "kind": "create_machine",
  "tenant": "agent-7", "status": "running", "terminal": false,
  "revision": 4, "retryable": false,
  "requested_by": "caller", "system_reason": null, "episode_id": null,
  "machine_id": null, "provider_account": "hetzner-robot-1",
  "idempotency_key": "agent-7:create:2026-08-12T14",
  "committed_sats": 72000,
  "result": null, "error": null,
  "poll_after_ms": 5000,
  "created_at": "2026-08-12T14:00:11Z", "updated_at": "2026-08-12T14:00:12Z",
  "correlation_id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11"
}
```

`tenant` is required (`API-20`) and follows `DOM-1`, not UUID form. `poll_after_ms` present only
while non-terminal, mirrored by `Retry-After = ceil(poll_after_ms / 1000)` seconds (`WIR-4`,
`API-49`). `committed_sats` is present on `create` operations — the satoshis the
commitment reserved, so a caller reads what it spent without diffing `GET /v1/balance`.
`system_reason` non-null only when `requested_by` is `system` (`OPS-39`). `episode_id` (*added
2026-09-08, `ADR-0017`*) names the episode this operation is an attempt under (`DOM-31`, `WIR-51`)
and is null on every other operation.

