# Panel r32 synthesis — pv-ucs.5's three owner questions (Q17a–c), 2026-10-10

Readers: astra, sol (codex xhigh), fable, opus (claude xhigh); clones at 7d21478 (869ee2b = pv-ucs.5's
unaccepted implementation, already in HEAD's files). All exit 0.

## Q17a — startup validation of API-35's activation minimum: 4–0 accept (positive integer only).

- A startup purchase-price check needs an offer and a live rate; during a rate outage `OVR-19`'s "refuse to
  run" would turn a rate outage into an engine outage, and "While the engine is down no
  exposure-reducing mechanism runs" — it would switch off the deadline cancellations that bound the
  outage (opus, fable; astra, sol: create already "MUST halt" without a rate, `LDG-40`).
- No other `OVR-19` "validated" row reads live data; the closest market-dependent value (`LDG-52`'s
  on-chain floor) is also just "satoshis, per rail". A pass would prove nothing after the next price move.
- Framing defect: the activation row's TYPE cell restates `API-35`'s obligation, and `CNF-345`'s "configure
  below the price needed to purchase something: startup refuses each" has no price basis.
- Edits: `OVR-19` row type → positive integer satoshis; `CNF-345` drops the price clause (structural
  rejections only); `API-35` keeps "large enough to purchase something" as the operator's obligation.

## Q17b — a create admitted before the channel closed: 4–0 accept (fail locally before the order request).

- Tenant outcome is identical either way (`failed`, commitment released in full, no setup fee or first
  unit — `LDG-39` "Deterministic rejection before acceptance"); the difference is provider-side: a send
  into a closed window may extend it ("whether requests after a 403 move the window" is [verify]).
- Placement: before the order request — fable: at claim (`OPS-5`), so the per-order key upload is not spent
  either; opus: in `API-63`'s correlator-entry transaction, "the last write before the ordering call".
  A plain READ, not a conditional write: a closure committed after the read just leaves the provider's 403
  to settle it the same way.
- Outcome: `failed`, `rate_limited`, `retry_after_ms` = remaining closure, operation-view `retryable: true`
  (retrying after expiry is a new operation). Not admission-only: `OPS-11`'s note already says
  "`rate_limited` remains available to drivers and workers"; opus would add "or at dispatch a worker
  failure" to its occurrence sentence.

## Q17c — the loser of the one-in-flight-per-offer guard: ordinary `409 conflict`/`state`; split 2–2 on retryable.

- Ordinary error, no rich refusal list (4–0): the guard runs after the tail found nothing; a rich list would
  need a new tail constructor and amend the settled order. `API-50` does not apply (it governs `429`).
- `retryable: false` (fable, opus): the winner usually succeeds and the offer leaves the feed; the claim is
  held "until its outcome is known" and a Robot order "can sit `in process` with no documented bound"
  (ADR-0040), so `true` invites N losers to poll an unbounded hold for a machine someone else bought; the
  listing is the loser's oracle.
- `retryable: true` (astra, sol): the loser bought nothing; repeating the same request is safe and succeeds
  if the winner fails.
- Home: not `WIR-9a`'s table ("Purchase-tail entries"); one sentence in `API-7` for all three guards
  (`API-63`, `LDG-62`, `PRV-42`) or `PRV-42` itself. `API-63`'s own guard-loss retryability is owed too.
