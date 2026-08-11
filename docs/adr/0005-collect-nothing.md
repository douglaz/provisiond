# Collect nothing about customers; keep only what operating the machines requires

**Status:** accepted (2026-08-11)

Privacy is treated as a design constraint of the same rank as correctness, not as a setting.
`provisiond` collects no customer identity, keeps no caller IP addresses, no analytics and no
request logs beyond what an operation needs while it is live, and **purges caller-supplied
payload the moment an operation reaches a terminal state**, retaining a redacted summary and
provider-side identifiers only.

## What this changes in the existing specification

- **`OPS-2` is narrowed.** The full request payload persists only while the operation is live.
  SSH public keys, signed image URLs and up to 1 MiB of post-install script are the most
  sensitive material in the system, and under the previous text they persisted indefinitely in
  exactly the failure case — `OPS-25` retains `needs_reconciliation` records until an operator
  resolves them.
- **`OPS-13` is satisfied without secrets.** It asks for *what was attempted* and *which
  provider-side identifiers exist*, not for the script itself. A `needs_reconciliation` record
  therefore holds evidence forever and secrets never.
- **`API-28` and `SEC-32` need a data-minimisation rule.** A correlation identifier is fine; a
  correlation identifier next to a caller IP address is a tracking record.

## What it does not deliver, and the specification must say so

**Privacy from the provider.** The machine lives in the operator's own provider account. Hetzner
knows the address, the traffic and the operator's identity, and legal process runs to Hetzner
without passing through `provisiond`. The guarantee actually on offer is narrower and should be
stated as such: **the reseller layer learns nothing linkable about the customer.**

## Consequences

- **This selects the sanctions posture.** With no identity collected there is no name to screen
  against Council Reg. 269/2014's list, so the controls reduce to what is observable without
  retention — jurisdictional controls, an enforced acceptable-use policy, a contractual warranty
  from the customer, and the ability to freeze and terminate a machine immediately. **The
  residual is an accepted operator-borne risk and MUST be recorded as one**, because sanctions
  breach is broadly strict liability and does not care that the operator sits outside the
  financial perimeter (`ADR-0004`). Two independent analyses rated this the largest single legal
  exposure in the design. Restricting what is sold — in particular avoiding advanced compute
  subject to dual-use export controls — shrinks it materially and costs nothing in v1.
- **Holding no personal data is the cheapest GDPR posture available**: data minimisation is
  Art. 5(1)(c), and there is no breach-notification surface and nothing to disclose on request.
  This is a legal consequence of the principle, not merely an ethical one.
- Purging on terminal state must be specified precisely enough to test — what a redacted summary
  may contain, and that purge happens on *every* terminal state including
  `needs_reconciliation`.
