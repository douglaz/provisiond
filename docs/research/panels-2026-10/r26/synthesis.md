# Panel r26 synthesis — does a failed refresh count toward the per-machine bound? (2026-10-08)

Readers: astra, sol (codex xhigh); fable, opus (claude xhigh, started after the 5-hour window reset).
Clones at 0c52755 (pv-ucs-impl). All exit 0. Brief: brief.md; the Manager's blocker: manager-blocker.md.

## Verdict: (c), 4–0 — the bound covers successful observations; accept the failed-read residual.

- The gap is real: `OPS-11`'s refresh row is "Always `failed`… a failure changed nothing", and
  `state_observed_at` records only "an authoritative read of the provider". A failed read moves nothing.
- It protects no operator money. ADR-0034 Decision 3 spends the budget "before any provider call" and
  the reserve means tenant drain "never reaches the system's own deletes"; the per-machine bound only
  prices one tenant denying another, which ADR-0034 already accepts as "priced to the attacker, and
  alarmed on exhaustion".
- A tenant cannot choose read failures (fable, opus, astra): 5xx/network/timeout are the provider's;
  a provider 429 means traffic outside the declared budget; a 404 past the create's window is a
  gone-write that ends the loop; a 404 inside it costs a paid create per window; authentication is
  `PRV-41`'s credential-wide stop. The residual is "one paid machine, during a provider read failure
  you did not cause" (fable).
- (a) rejected: needs a new `machines` timestamp (no dispatch time exists; `operations` is indexed by
  machine only over running rows), settles `succeeded` with nothing learned, hides the provider's error
  from the caller who asked because of it, and breaks ADR-0034's "up to one window old".
- (b) rejected: delays a legitimate retry after one 5xx by a whole window, and the same new clock.
  (opus: it would not breach API-50; fable: it collides with API-50's pacing promise — split, moot.)

## Findings beyond the question (verified)

1. **Where the cache check runs (opus).** The endpoint enqueues and returns 202; no requirement says
   where the check happens. At enqueue, N refreshes fired at a stale machine all queue and OPS-8 runs
   them one at a time — N successful reads. The check must run when a worker claims the refresh,
   beside "before its first provider call".
2. **ADR-0034's "the caller already reads its age from `state_observed_at`" is false (fable, astra,
   sol).** `WIR-11`'s machine view has no `state_observed_at`; refresh returns `{}`. Expose it.
3. **Two false universals in ADR-0034 (opus):** "however fast a caller loops" and "needs many paid
   machines, not one" — qualify to "while the provider answers".
4. My claim that the dispatch time was already in `operations` was false (all four confirmed).

## Edits (converged)

ADR-0034 dated amendment (Decision 1 + Consequences: successful observations; the incident residual
accepted); `OPS-11` refresh row (cache-answered settlement decided at claim; a failed read writes no
`state_observed_at`); `DOM-8`; `04-api-contract.md` refresh row stays 202 and the endpoint text;
`OVR-19` window; `WIR-11` exposes `state_observed_at` (nullable); conformance: (i) stale machine,
failing provider → refresh `failed`, `state_observed_at` unchanged, next refresh reads; (ii) N
refreshes queued against a stale machine, provider answering → one provider read. No new column, no
new error kind; `Provisiond.Tables.refresh_always_failed` stands.
