# Panel r37 synthesis — Robot's per-endpoint request limits in v1 (Q20), 2026-10-10

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 16f9db8. All exit 0.

## Agreed (4–0)

- No generic request budget (Q19 stands). Q19's withdrawal is not yet applied at 16f9db8 (expected:
  `02:1051`, `00:378`, CNF-336–339, `01:145`/`01:149` "tenant share", `ADR-0034:71`).
- **The counter's scope is undocumented.** Robot's reference gives "200 requests per 1 hour" per endpoint
  but not whether it counts per webservice user, account or source IP, nor whether different
  `{server-number}` paths share a counter. "Four machines' loops exceed 200" (r36) holds only if they
  share one; settle it live (batch B), extend `08-provider-notes.md:416`'s `[verify]` to every limit.
- `08-provider-notes.md:411-418` records only order and cancellation limits; add the table.
- An absence still needs `OPS-32`'s direct re-read (`03:1379`); a failed read never advances freshness.
- The brief's `PRV-50` does not exist; the owner is `PRV-5` (`02:50`).

## Q20 — refresh against Robot's 200/hour server reads: coalesce on the account list (3–1)

- **Fable:** require the refresh freshness window to be no shorter than the account-sweep interval, and
  the sweep to record every machine it observed present (`DOM-8` 01:133 already says "MUST write what it
  saw"; `OPS-32` 03:1350 says an interrupted pass "may"). Tenant refreshes then cost zero provider reads
  while the sweep runs; Decision 1's one read per machine per window is the fallback when it falls behind.
  On Robot the per-machine read observes nothing the list lacks except availability booleans (`status` is
  "ready" or "in process"; no power state; rDNS on neither). No new mechanism.
- **Opus (sol similar):** a stale refresh reads the account listing (`GET /server`, plus `GET /ip` and
  `/subnet` for `PRV-35`'s `locked`) and records every listed machine; a machine missing from it takes the
  direct read; a listing absence never writes gone. One list read per window per account whatever the
  fleet size or counting rule. Add an alarm on `rate_limited` for a system read.
- **Astra:** close new tenant reads of the endpoint on Robot's `403` for its interval, alarm, keep
  exposure-reducing and evidence work eligible; accept the first throttled interval as residual. The list
  lacks cancellation dates and lock evidence, so coalescing cannot replace every direct read.
- (b) a per-driver window sized to the limit: rejected by all (W must grow with the fleet: W ≥ 18N s).
- (c) as an addition: sol yes; opus only if live testing shows requests after a `403` move the window;
  fable no (it restores no capacity; Robot's own `403` already refuses the tenant).

## Also found (for later questions)

- **`POST /reset` at 50/hour** (power, rescue entry and exit, install): no system path resets; a throttled
  exit reset is "always ambiguous" (`PRV-22`) and can strand another tenant's install. Accept the residual
  under `SEC-39` ceilings (fable, opus) vs a Robot limit on new reset-producing admissions that accounts for
  outstanding exits (sol); astra flags it.
- **The delete's pre-read** of `GET /server/{n}/cancellation` for `reserve_location` (`08:405`) may be
  unnecessary: sending `reserve_location=false` satisfies both documented branches (astra) — verify.
- Order-transaction polling (500/hour) is the one bucket the system can exhaust alone (≈ six concurrent
  creates at a 5 s poll); a throttled poll after acceptance is already `needs_reconciliation` (fable).
