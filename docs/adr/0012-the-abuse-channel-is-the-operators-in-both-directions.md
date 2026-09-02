# The abuse channel is the operator's, in both directions

## Context

`SEC-45` was rewritten on 2026-08-15 after its premise turned out to be false. It had described
abuse handling as a stopwatch — terminate a tenant "fast enough to meet the provider's abuse-notice
deadline", with responsiveness as "the entire remedy". A real Hetzner notice, read against the live
process, says something else: it alleges an attack from a named server, sets a deadline days out,
asks for a **statement**, and warns that the server **may be locked** — not terminated. Abuse
handling is correspondence, and the suspension is the provider's.

That left a hole the rewrite could name but not fill. The operator is obliged to relay an
allegation to a tenant and take back a statement, and `ADR-0005` had removed every channel for
doing it: no email, no contact, no identity. `12-billing-and-ledger.md` had already stated the
consequence in another context — *"a caller that is software will act on a number long before it
would act on an email, and there is no email."*

The obvious design is to forward what the provider sent. It was the standing recommendation for
part of a session, in its mildest form: relay the notice read-only, and let the tenant follow the
provider's own link to answer. **The sample notice killed it.** That link is a single-use bearer
credential, it identifies nobody, and *submitting through it concludes the deadline immediately* —
after which "manual replies will only be handled in the event of a lock down". Handed to an
autonomous caller, a poll loop ends the operator's window in the first second, with no human ever
deciding to answer. This is `SEC-39`'s reasoning — a control that assumes a human reading it stops
being a control when the caller is a program — arriving at a surface nobody had looked at.

Half-measures were considered and rejected as worse than either whole: staging the link behind an
operator release, relaying the case reference but not the link. Each keeps the coupling to the
provider's process while adding a mechanism, and each leaves the operator's deadline partly in a
program's hands.

## Decision

**The operator is the only party that speaks to either side. Nothing crosses automatically in
either direction, and the provider's own material never crosses at all.**

*Stated that way deliberately. A first draft said "nothing is relayed in either direction", which is
false in one direction by this ADR's own decision: a tenant's statement may be forwarded verbatim
when the operator decides so and records it. The provider's case reference, link and wording are
the absolute ban; the tenant's words are gated on a judgement, not prohibited.*

Inbound, the provider's notice stops at the operator. The case reference, the statement link, the
provider's own wording and any third party it named MUST NOT reach a tenant (`WIR-45`). What the
tenant sees is a **case** the operator wrote: which machine, what is alleged, what happens next,
and one deadline (`DOM-23`). Neutrality is produced by the act of rewriting, which is why there is
no allegation taxonomy and no parser — an operator reads the notice and types it in.

Outbound, the tenant's statement stops at the operator. It is submitted as an ordinary
synchronous write (`WIR-43`), read by the operator, and what reaches the provider is the operator's
own statement. Forwarding a tenant's words verbatim stays available as a **per-case operator
decision**, recorded explicitly on the case with the statements it covers (`WIR-44`), because
sometimes the customer's own account is the most credible thing to send — but composing is the
default, and the decision is an artifact rather than a habit.

The operator's existing power to stop serving a tenant (`API-58`) is untouched and stays what
`SEC-45` made it: the operator's own decision, not a race against a deadline. **No *consequence* of
a case fires on a timer** (`DOM-25`).

*Amended 2026-09-02: this sentence read "nothing in the case fires on a timer", which is `DOM-25`'s
withdrawn wording preserved past its withdrawal. `DOM-25` is a rule about **consequences** — a passed
deadline may not suspend a tenant, cancel a machine, seal the case or move a balance — and the
absolute form forbade `STO-42`'s retention purge, which `ADR-0005` requires and which is the only
clock in the whole surface that fires without an operator. An ADR that preserves the withdrawn half
of a requirement is worse than one that omits it: the requirement carries its own correction, and
this file did not.*

## Consequences

- **The operator is a bottleneck, deliberately.** A tenant cannot answer an allegation while the
  operator sleeps, and the tenant-facing deadline must therefore sit earlier than the provider's by
  however long analysis and composition take. Only one of those two dates is stored (`STO-39`); the
  provider's lives where the notice does, so it cannot leak from a field that does not exist.
- **Two translations mean two chances to garble.** The operator rewrites the allegation inward and
  the statement outward, and a customer may answer a question the provider did not quite ask. The
  alternative was a bearer credential in a poll loop.
- **The abuse channel is not an identity channel.** A tenant's free-text statement may contain a
  name, a company, or an email that nobody asked for. It is stored verbatim and uninspected —
  scrubbing free text is unreliable and untestable — bounded instead by a size cap, by purge at
  close (`STO-42`), and by the operator never being permitted to treat anything in it as
  identifying the customer. That last rule is what keeps this from quietly becoming the KYC surface
  `ADR-0004` exists to avoid.
- **It made a latent defect visible.** Resolving a notice needs to know who held an address at an
  *instant*, and `machines.public_ips` is current state overwritten by every refresh. Every design
  that relays the notice hides this, because the provider's own record does the resolving. Owning
  the channel forced `STO-41`'s observation history and `SEC-54`'s candidate-set answer — without
  which the operator accuses whichever customer holds the address today.

## Rejected

**Relay the notice read-only and let the tenant follow the provider's link.** Cheapest by far,
needs no case model, and puts the customer directly in touch with the only party that can lift the
block. Rejected because the link concludes the operator's deadline on first use and the caller is a
program.

**Automated ingestion — a driver capability or a parsed mailbox.** No provider in the launch set
exposes abuse cases over an API (`08-provider-notes.md` describes notice, deadline and manual
review, and names no endpoint), so this is an email parser feeding untrusted input into an entity
whose consequences reach a customer's machines.

**Stay out of the process entirely.** The operator answers notices from what it can see and never
asks the customer. Honest about `ADR-0006`'s pass-through v1 — and it leaves suspension as the only
response to an allegation, which makes the nuclear option the default one.
