# Panel r43 synthesis — a still-future earliest cancellation day near midnight (Q25), 2026-10-11

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 12a1c89. All exit 0. Opus's CLI
output held only its closing line; its review was recovered from its session log.

## Agreed (4–0)

- The rules disagree as written: `PRV-13c` branches on the stored start (wording `3b717a0` introduced;
  before it, "when it is materially in the future"), `PRV-13b` adds the date's cost on the exception branch
  only, and `LDG-33` protects any future permitted-from date through its day end.
- No current Robot sale reaches it: "You can only cancel immediately" (Hetzner); three live deliveries
  returned today as the earliest date. The brief's `CNF-147` quote ("no launch product reaches the branch
  by default") is stale — `CNF-147` reaches the branch only by injection.
- End-of-day pricing is right where a cancellation is dated for that day (the prescribed fallback when
  `now` is rejected); a permitted-from date alone is not a scheduled stop (astra, sol).

## Split

- **Make such offers unsellable in v1 (opus, astra, sol):** an offer whose declared bound is later than
  the provider's today permits future-scheduled cancellation, which `LDG-38` says "requires an automatic,
  idempotent corrective credit" v1 does not post. State the exclusion in `PRV-31`; `API-7`'s existing "not
  sellable under `PRV-13b` or `PRV-31`" refuses before any order; `CNF-166` covers it; leave the threshold
  for when such offers are enabled (opus: judging by the day's end makes the hourly threshold dead for
  day-only dates). Opus: Robot's declared bound is never stated, and V12's "30 days to the end of the month"
  would, under this rule, make every Robot offer unsellable — record Robot's bound as today; `LDG-63`'s
  "bounded per machine by `PRV-31`'s declared worst case" is false for a read date later than the bound.
- **Judge a still-future earliest day by its day end (fable):** a one-phrase repair of `PRV-13c`; a
  specified, tested branch must be coherent while dormant; under the start-based test the near-midnight
  case is a false exhaustion that seizes a day of the customer's balance.

Owner decision Q25: unsellable in v1 (ADR-0037's amendment of 2026-10-11).
