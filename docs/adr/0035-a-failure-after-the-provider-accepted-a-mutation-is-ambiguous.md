# A failure after the provider accepted a mutation is ambiguous

**Status:** accepted (2026-10-06, owner decision Q4 of the provider-research grill).

## Context

`OPS-11` decides ambiguity from the kind of the last failed request. Its list is `network`,
`timeout`, `internal`, a cut-off `conflict` and a 5xx, because "A 4xx generally means the provider
rejected the request and did not act". That holds when the 4xx is the mutating request's own answer.
It is false when the 4xx answers a later read.

A Hetzner Cloud create sends `POST /servers` and the server is created. If the following read is
throttled (`429`), not yet visible (`404`) or refused after a token rotation (`401`), the create
settles `failed`, `LDG-32` releases the commitment, and the machine runs with the tenant's key while
the operator pays. `OPS-32` reports such a machine and does not attach it. Robot reaches the same
hole with no attacker at all: "a Robot order reports `ready` with a server number before the server
API lists the machine". Robot also throttles with `403 RATE_LIMIT_EXCEEDED`, not `429`.

The other kinds on `OPS-11`'s last row share the hole. `OPS-45` records dispatch for them, but its
own text says "Everything else follows `OPS-11`'s classification". The costly one is release
attachment: only "A successful release writes the row's `released_at`", so a release the provider
performed, followed by a failed read, keeps metering the customer for a volume that no longer exists.

`F48` named the missing fact: it is "a fact only the driver has (`PRV-5`), and no requirement obliges
a driver to report it".

## Decision

**A failure of an operation whose mutating request the provider accepted is ambiguous, whatever
its kind.** The rule covers every kind on `OPS-11`'s last row: create, power, reverse-DNS, delete
and release attachment.

- The driver reports the fact on every error as `details.accepted`. It is true once the provider
  answered with success the request that performs the mutation, the one that carries the correlator
  (`PRV-26`). A key upload before an order is not that request.
- A driver that cannot tell reports `internal`, which is already ambiguous. No implicit default
  enters `OPS-11`.
- Robot's `403 RATE_LIMIT_EXCEEDED` maps to `rate_limited`.
- `PRV-11`'s poll timeout becomes one case of the rule.
- After acceptance, `OPS-27`'s settle-time search succeeds only on exactly one resource. Any other
  result is `needs_reconciliation`, and `OPS-33`'s negative window does not run against a matched
  order that is still in progress.
- A release that resolution finds applied writes `released_at`.

The set already keys on acceptance everywhere else. `LDG-39`'s fee rows begin "Order accepted by the
provider", `OPS-27` enters on the provider "accepting the order in its reply", and `ADR-0033`
debits the prepaid unit on confirmed acceptance. `OPS-11` was the one reader that did not.

## Considered and rejected

- **Key on dispatch.** A dispatch is true for a key upload before the order, and for the order's
  own 4xx rejection. Every sold-out or refused order would become a reconciliation. Each would hold
  the tenant's commitment through `OPS-33`'s window and spend `ADR-0034`'s reserve. On Robot's
  standard channel each would page an operator, up to twenty a day per account, free to an
  attacker. A connection that dies mid-request is already ambiguous by kind. Acceptance requires a
  placed order, which the attacker pays for.
- **Only a `rate_limited` failure after the order.** It misses Robot's `403` and every `404` and
  `401` after acceptance.
- **A durable dispatch marker on create, like `OPS-45`'s.** The engine cannot see inside the
  driver's call, so its marker cannot tell a key upload from an order or a rejection from an
  acceptance.

## Consequences

- An accepted create that fails reaches `OPS-27`'s automatic correlator search. It attaches the
  machine to the tenant who ordered it, or resolves it absent and releases the commitment.
- Edits owed:
  - `PRV-5`: the field and Robot's mapping.
  - `OPS-11`: a fourth ambiguity bullet.
  - `PRV-11`: an instance of the rule.
  - `OPS-27`: the settle-time search and the window.
  - Resolution writes `released_at` (`OPS-31`/`OPS-48`).
  - `LDG-39`: row precedence. An accepted create that is unresolved takes the pending-fee row.
  - `CNF-31a`, which today requires the defect ("A create failing with a provider 4xx is
    `failed`").
  - The wire pairing of `retry_after_ms` with `retryable: false`.
  - The formal layer's `Tables` classifier gains `accepted`, with a theorem that an accepted
    last-row failure is never `failed`.
- Not covered here: a delete whose success is followed by a throttled attachment listing. Only that
  listing writes `machine_attachments`, so `LDG-32` can close while a surviving volume bills the
  operator. That defect predates this one and has its own ticket.
