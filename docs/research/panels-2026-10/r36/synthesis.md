# Panel r36 synthesis — pv-ucs.2's three owner questions on the provider request budget (ADR-0034), 2026-10-10

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 16f9db8. All exit 0. Fable's
CLI output held only its closing line; its review was recovered from its session log.

## The framing: Decision 3 protects a bucket v1 does not use, with a count that cannot see it

- **v1 sells only Robot (`ADR-0039`).** No v1 tenant operation reaches Hetzner Cloud's shared project
  bucket. `PRV-46` names only Cloud's scope, and `PRV-44`'s `request_budget {scope, limit, per}` cannot
  express Robot's per-endpoint limits (opus, sol, astra).
- **A local count cannot hold the reserve.** Cloud's bucket is "per Project", refills one a second, and
  the operator's console and CLI spend it; `ADR-0036` already rejected a local count for Robot orders
  ("A local count can drift from it in both directions, while a gate closed by the provider's own answer
  cannot"). Every Cloud reply carries `RateLimit-Remaining` (fable, opus). `ADR-0034`'s "It never
  reaches the system's own deletes" is false under every reading (all four).
- **Strongest "don't build":** defer Decision 3 until an offer sharing a bucket is sellable; keep
  Decisions 1–2 and Q10 (opus, sol; astra: "defer a universal budget abstraction"). Fable instead keeps
  the reserve as a stop on new admissions read from `RateLimit-Remaining`.
- **The live v1 gap is Robot's own limits** (opus; verified in the Robot webservice reference, retrieved
  2026-10-10): `GET /server` and `GET /server/{server-number}` are "200 requests per 1 hour", as are
  `POST`/`GET`/`DELETE /server/{server-number}/cancellation`. At a 60 s freshness window one machine's
  refresh loop costs up to 60 reads/hour, so four machines' loops exceed 200, and the system's direct
  re-reads (`OPS-32`, `PRV-42`'s confirmation) use the same endpoint. `ADR-0034` lists this as "Not
  covered here".

## Q19a — continuations versus the reserve (if a budget is built): split

- (3) continuations spend; the reserve only stops NEW admissions, gated on the provider's reported
  remaining (fable, opus). Residual: operations admitted above the reserve finish on it; bounded by
  `OPS-8`'s one operation per machine.
- (1) continuations wait, system work scheduled first, deadline interaction stated (sol).
- A fourth: drop the continuation exemption; refuse before dispatch; after acceptance enter
  `needs_reconciliation` per `OPS-11`'s accepted-mutation rule (astra).
- (2) rejected by all: no bound on polling (`OPS-33`: "This adds no timeout on an in-progress order").

## Q19b — operator-origin traffic: by path, 3–1

- By path/purpose (fable, astra, sol): exposure-reducing and evidence work is eligible whoever asked;
  `API-64` episode retries and `API-65` releases are never refused; `requested_by` stays an audit stamp;
  `SEC-39`'s operator ceilings remain the operator's bound. Fable: `PRV-46`'s "tenant-initiated" would
  refuse a tenant's own delete at reserve-only — the operation the reserve exists to let through.
- By actor (opus): refuse only `requested_by: caller` work, never a `release_attachment`; a caller's
  `delete_machine` is an open owner question.
- All four: episode retries and operator releases are never refused by this budget.

## Q19c — the refusal surface: unanimous

Decide at worker claim, after the cache check: `202`, then `failed`/`rate_limited` with
`retry_after_ms`, `retryable: true`, zero provider calls, a create's commitment released — `PRV-40`'s
claim-time paragraph (Q17) is the precedent. No synchronous `429`. Sol flags a separate existing
contradiction: `API-50` says every `429` is `ceiling_exceeded` while `DOM-17` maps `rate_limited` to `429`.

## Lean and CNF (if built)

One sequence (fable, opus): tenant admitted above the reserve → continuations (and outside traffic)
reach it → a new tenant operation refused at claim → a cache-fresh refresh settles locally → a tenant
delete, an operator retry, a release and a system cancellation dispatch. `Witnesses.lean`'s system
witness runs before the depletion; `ProviderTraffic.lean:181` proves a local predicate, not capacity.
