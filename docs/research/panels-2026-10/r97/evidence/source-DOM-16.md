**DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This is in addition to, not instead of, the per-request purchase acknowledgement
(`API-15`).

*Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*

## Error taxonomy

One closed set of error kinds, used by drivers, the rescue engine, and the API alike.

| Kind | Meaning | HTTP |
|---|---|---|
| `invalid_request` | Caller error, deterministic | 400 |
| `not_found` | Named resource does not exist | 404 |
| `conflict` | State or idempotency conflict | 409 |
| `unsupported` | Capability not declared or not implemented | 501 |
| `authentication` | Caller or provider credential rejected | 401 |
| `rate_limited` | Caller or provider throttled | 429 |
| `provider` | Provider returned an error response | 502 |
| `network` | Transport failure reaching the provider | 502 |
| `timeout` | Operation exceeded its deadline | 502 |
| `integrity` | Digest or host-key verification failed | 422 |
| `internal` | Defect in this system | 500 |
| `insufficient_balance` | Available balance cannot fund the required commitment (`LDG-9`) | 402 |
| `not_activated` | Tenant exists but is still pending funding (`API-35`) | 403 |
| `halted` | Refused while a solvency halt is in force or a rate is unavailable (halt transitions: `LDG-40`; consequences: `LDG-20`) | 503 |
| `gone` | Resource existed and was removed by retention (`STO-14`, `STO-33`) | 410 |
| `suspended` | Tenant is suspended; only the maintenance actions remain (`API-58`) | 403 |
| `ceiling_exceeded` | A per-principal ceiling for the current interval is exhausted (`SEC-39`) | 429 |
| `overloaded` | The replica obtained no store connection within the checkout bound; refused before any transaction (`STO-55`). Retryable; the refusal leaves no receipt of its own | 503 |

