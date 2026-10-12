**Verdict:** (c), restated as a correction. The bound covers successful observations. The cache check runs when a worker claims the refresh (not when it is enqueued), and no attempt state is added. This holds within `ADR-0034`'s scope; the Robot case is left to the follow-up the ADR already defers.

**Why.** The gap is real. `OPS-11`'s refresh row says "Always `failed`… a failure changed nothing" (03-operation-lifecycle.md:223), and `state_observed_at` records only "an authoritative read of the provider" (05-persistence.md:276).

The bound protects no operator money. The budget is spent "before any provider call" (ADR-0034:39-40), and because of the reserve, tenant drain "never reaches the system's own deletes" (:65). The bound only sets the price of one tenant denying another, which the ADR already accepts as "priced to the attacker, and alarmed on exhaustion" (:64-65).

Within scope, a tenant can't choose when reads fail:
- **5xx, network, timeout** come from the provider or the deployment. A timeout holds the machine under `OPS-8` (03:183-186), so that loop runs at one read per timeout.
- **Provider 429**: the budget is spent before every call, so a 429 means traffic outside the declared budget.
- **404 past `PRV-36`'s window** is a gone write and ends the loop (12-billing-and-ledger.md:525-531).
- **404 inside that window**: "a read is not evidence of absence at all" (:531-532). Each window costs a paid create.
- **Authentication**: `PRV-41`'s "terminal for that credential" (02-provider-contract.md:945-946) plausibly bars the next read.
- **Robot's per-endpoint limits** are the one case a few tenant machines could trigger. ADR-0034:72-73 excludes them: "Not covered here: … Robot's per-endpoint limits".

So a cooldown buys fairness only during incidents the attacker didn't cause.

**Defects in the framing**

1. **The unasked hole is where the cache check runs.** The endpoint enqueues and returns `202` (04-api-contract.md:247), and no requirement says where the check happens. If it runs at enqueue, N refreshes fired at a stale machine all queue. `OPS-8` runs them one at a time but doesn't merge them, so N *successful* reads reach the provider. The check must run at claim, beside "before its first provider call" (ADR-0034:47).
2. **Two sentences are false universals:** "however fast a caller loops" (ADR-0034:33) and "needs many paid machines, not one" (:62). A failed read retires both (AGENTS.md:41). The fix is a sentence, not machinery.
3. **What (a) needs.** Your correction holds: `OPS-45` doesn't govern refresh (tools/formal/Provisiond/Rescue.lean:411-416). Built from `operations`, (a) fails three ways:
   - The only machine index is `STO-51`'s partial one over `running` rows (05-persistence.md:388-392), so settled refreshes aren't indexed by machine.
   - `created_at` is enqueue time, not dispatch time.
   - A success answered from the cache looks identical to a real read: refresh returns `{}` (13-wire-contract.md:277), and `STO-50` closes `request_summary`.

   The honest form of (a) is a new `machines` timestamp, written by a worker under `STO-3`'s claim number. It would sit beside `STO-48`'s "money column", which is the column an implementer will be tempted to stamp instead. It must also be refresh-only, or a failed `OPS-32` re-read would block a tenant's refresh.
4. **(a) breaks ADR-0034:66**, "A refresh can return state up to one window old". In an outage it settles `succeeded` on state of any age, so the result flips from `failed` to `succeeded` with nothing learned. It also hides the provider's error from the caller who asked because of it.
5. **(b) needs no new error kind:** `rate_limited` ("Caller or provider throttled", 01-domain-model.md:552) already carries `retry_after_ms` (13-wire-contract.md:131). It doesn't breach `API-50` either: the refusal is an operation error read through a poll, not an HTTP `429`, and `CNF-152` tests polls. But a legitimate retry after one 5xx waits a whole window, and the caller learns that only by being refused.
6. **Q1, existing records.** 5xx, network and timeout leave only the failed row. A 429's `retry_after_ms` is guidance to the caller (`DOM-17`) and bounds nothing for a looping caller that ignores it. Only the gone write ends a loop. `ADR-0035` doesn't touch refresh: "The refresh, parent, install/rescue-inventory and admission-only rows are unchanged" (03:264).
7. **Q3, other readers.** Under (c), `OPS-32` and `DOM-8`'s opportunistic reads only freshen the cache ("what it observed *present* it may still record", 03:1334), so nothing changes.

**Strongest "don't build this":** it adds a second timestamp beside the money column, only to buy fairness during incidents nobody chose.

**Edits**
- **ADR-0034 Decision 1 (:32-33):** a dated amendment: "a machine whose provider answers costs at most one read per window; a failed read moves nothing (`OPS-11`) and the next refresh reads again, one at a time (`OPS-8`), from the tenant share".
- **ADR-0034 Consequences (:62-65):** qualify with "while the provider answers", and name the incident residual as accepted.
- **`OPS-11` refresh row (03:223):** the cache-answered settlement already owed, decided at claim. A failed read writes no `state_observed_at`.
- **04-api-contract.md:247:** refresh stays `202`.
- **`OVR-19`:** the freshness window (already owed).
- **Conformance:**
  - Stale machine, failing provider: the refresh settles `failed`, `state_observed_at` is unchanged, and the next refresh reads.
  - N refreshes queued against a stale machine, provider answering: one provider read.
- **No change** to columns or error kinds, and no Lean change: `refresh_always_failed` (Tables.lean:225) stands.

The gate (`check-all.sh`, run unpiped) passed with exit 0. I edited no tracked files; running `br show` left an untracked `.beads/*migration-state` file. This report is also saved at `docs/research/panels-2026-10/r26/opus-review.md`.
