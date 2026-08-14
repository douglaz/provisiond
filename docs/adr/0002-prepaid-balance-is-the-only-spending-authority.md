# Self-serve enrolment, with a prepaid balance as the entire spending authority

**Status:** accepted (2026-08-09)

A customer's agent enrols itself at runtime — no operator step, no identity, no email. Because
a stranger who can enrol can spend the operator's money in the operator's provider accounts,
the counterweight is that **a prepaid balance is the only thing that authorizes spending**. No
credit, no invoicing, no collections. If the balance cannot cover the reserve, the create is
rejected at the boundary.

This resolves `API-17b`, which required a deployment to define both which accounts a tenant may
create in *and* that tenant's spending authority, and left both undefined. It collapses to one
rule: the balance is the authority.

## Considered options

- **Operator-onboarded tenants, no registry.** Cheapest; keeps `API-4`'s environment-only tokens
  intact; matches a concierge first sale. Rejected: the product is self-serve resale to agents,
  and hand-onboarding cannot reach it.
- **Post-pay with a per-interval ceiling.** Rejected: extends credit to anonymous strangers,
  dragging in identity verification, collections and bad-debt reserve, with no chargeback
  recourse in either direction.
- **Prepaid plus an operator approval threshold above some size.** Rejected: the operation states
  are a closed set (`03-operation-lifecycle.md`'s states table, `WIR-10a`'s enum), and this needs a
  new non-terminal *awaiting approval* state
  plus an operator queue and timeout policy — and it breaks the core promise for exactly the
  machines that matter, since an agent cannot buy a dedicated box at 3am.

## Consequences

- **`DOM-1a`'s registry branch is now required**, and `F2` is promoted from "out of scope" to
  "must fix": tenants must be creatable at runtime, which `API-4` (tokens from the environment,
  validated at startup) cannot express. `API-4` must be amended, not kept.
- **The money path is v1-blocking.** Both panel reviewers had recommended deferring it in favour
  of one hand-issued invoice per sale. Self-serve enrolment overrides that recommendation
  deliberately. Cost estimate: +12–16 weeks on a ~20–25 week v1.
- **Two non-goals in `00-overview.md` were withdrawn** — customer billing, and abuse handling.
- **Automated cancellation becomes load-bearing**, which withdrew a third non-goal. A balance
  that reaches zero with no way to stop the meter converts a customer's exhausted credit into
  the operator's ongoing loss. This is why `PRV-13c`'s verified fact — Hetzner Robot has no
  minimum term and cancels immediately — is a requirement input and not trivia.
- Authorizing a create and opening its commitment MUST be one transaction (`LDG-11`). See
  `ADR-0001`. *"Hold" is the withdrawn primitive; `CONTEXT.md` bans the word.*
