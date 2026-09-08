# Adopt is withdrawn from v1 with its whole surface, and returns with a driver that can price the machine

**Status:** accepted (2026-09-08). Leaves `ADR-0006` untouched: no machine serves two tenants in
v1, and inventory is still deferred with slicing.

## The problem as found

The set specified adopt two ways at once. `OPS-11` classified it "Always `failed`. Both are
read-only; a failure changed nothing." `WIR-35`, the `resolution` column, `OPS-31`, `CNF-179`
(BLOCKING) and the commitment diagram admitted `observed`, `absent` and `abandoned` "for a create
or adopt" — verbs that presuppose an uncertain adopt and rest on a correlator search (`OPS-27`)
that an adopted machine, having "**no correlator**" (`PRV-28`), can never satisfy. `OPS-45`
excluded adopt from its marker rule because "there is no machine yet ... the answer comes from
`OPS-27`'s correlator search", which is false for a machine that already exists.

Two defects hung on the contradiction. The commitment opened at enqueue (`LDG-11`, `API-7`'s
tail), before the read that adoption is; `LDG-32` released it on "the create fails deterministically"
and on abandonment, and named no failed adopt, so an adopt refused by the provider froze a
customer's balance with no verb that released it. And `PRV-31` said "an adopted machine's date is
read before its commitment opens", which the enqueue ordering made false, while the commitment
could not be sized without that read: `PRV-13b`'s formula needs a rate and a cancellation date, an
adopted machine has no offer to take them from, and the adopt body carried no price.

Two independent reviews of the same brief, one by Codex and one by a fresh Claude reader, agreed
on the diagnosis and recommended making adopt a synchronous operator write: read first, then one
transaction for authorization, row, runway and commitment. That design is sound, and it is the shape
adopt returns with. It was not adopted, because the question underneath it had a different answer.

## Where an adopted machine's price comes from

The commitment is sized from the customer rate, which is provider cost plus margin (`LDG-24`). A
created machine takes its cost from the offer snapshot. An adopted machine was bought by somebody
else, and the driver has to read its cost from the provider. Checked against the providers' own
API documents on 2026-09-08:

- Hetzner Cloud's server read embeds the server type with per-location hourly and monthly prices.
- DigitalOcean's droplet read embeds the size with hourly and monthly prices.
- Hetzner Robot's server read returns the product name and data centre and no price. Both order
  listings return a product object with hardware fields and no price. The Robot web service has no
  invoice endpoint. A standard server's product and location resolve to today's catalogue list
  price, which is not necessarily the price on an older contract. An auction server's price existed
  only in the offer while it was listed; after purchase the API carries it nowhere.

So on two of three launch drivers the price is readable, on the third it is a list price for
standard servers and unavailable for auction servers, and the only party who knows the missing
number is the operator reading an invoice. Sizing a customer's commitment from an operator's typed
number, or from a guess, was rejected.

## The scenarios, and why none of them is v1

- **A machine the operator bought by hand in the provider account.** Dismissed: every machine
  rented through this system is bought through it.
- **A machine provisiond bought, whose first tenant left, kept to rent again.** That is inventory,
  not adopt. `ADR-0006` deferred it with slicing and named the secure wipe that becomes blocking the
  moment a machine can serve a second tenant. Nothing here reopens it.
- **A machine with no provider at all — a home lab.** That arrives with a driver of its own, whose
  machine read returns what the operator configured, price included. It is still the driver
  supplying the price; the operator wrote the driver's inventory rather than a request field. No
  such driver is in `ADR-0010`'s launch set.

Adopt therefore has no v1 scenario, and a verb no launch driver can serve is what `DOM-15` calls a
defect.

## The decision

- **Adopt is withdrawn from v1 with its whole surface**, the way `DOM-22` swept iPXE: the route
  (`WIR-18`), the operator verb (`API-18`), the operation kind `adopt_machine`, the capability
  `adopt_existing` and its mapping row, `PRV-28`, `LDG-36`, `SEC-7`, the adopt clauses of `OPS-11`,
  `OPS-31`, `OPS-45`, `API-7`, `API-63`, `LDG-12`, `LDG-32`, `WIR-10`, `WIR-10a`, `WIR-10b`,
  `WIR-35`, `STO-17`, `STO-47`, the `resolution` column and the commitment diagram, and every
  conformance item that tested adopt (`CNF-5`, `CNF-258`, and the adopt clauses of `CNF-74`,
  `CNF-179`, `CNF-277`, `CNF-288` and the pipeline items). Withdrawn identifiers go to `README.md`'s
  index. `DEF-1` stays: it records what the reference implementation did.
- **It returns as one edit, with a driver whose machine read supplies the price**, and it returns
  in the shape the reviews converged on: a synchronous operator write in `API-48`'s list that reads
  the machine first and then, in one store transaction, authorizes, writes the row, sets the runway
  and opens the commitment. The descriptor (`PRV-44`) gains a field naming how a driver prices an
  existing machine — from the machine read, from the catalogue by product and location, or not at
  all — and a driver declaring the last MUST NOT declare the capability. The reviews' change
  inventories are in `11-open-findings.md` under this ADR's finding.
- **A running refresh found at startup settles `failed`.** The same review found that `OPS-15`
  moved every interrupted `running` operation to `needs_reconciliation` with `suspend_tenant` as
  the single exception, while `WIR-35` said refresh "never reach[es] `needs_reconciliation`". A
  read has nothing to reconcile, which is the sentence this ADR rests on, so `OPS-15` gains the
  exception and `CNF-29` asserts it.

## Considered options

**Keep adopt asynchronous and fix the union.** Strip adopt from the reconciliation verbs, add an
`LDG-32` row for a failed adopt, add `OPS-15` and `OPS-21` exceptions. Rejected: the commitment is
sized at enqueue from a rate and a date that only the read supplies, so either the frozen commitment
stays or the commitment moves into the worker's terminal transaction, which is the synchronous design
executed one hop later.

**Make adopt synchronous now.** The right shape, and recorded above as the return path. Rejected for
v1 because no launch driver can price every machine it can read, and a verb that refuses on every
driver is a defect with a route.

**Price from the operator's request.** Rejected: the operator is a program (`SEC-39`) or a person
reading an invoice, and a customer's commitment is not sized from either.

**Match a catalogue product for every driver.** Rejected: it ignores the embedded price where one
exists and guesses on Robot's auction servers, which are the machines the notes call the cheap way
to buy.

## Consequences

- `API-7`'s operator carve-out no longer has a one-verb exception: every operator verb skips steps 2
  and 5b, since the only operator verb that bought against a named tenant is gone.
- `STO-17`'s cross-tenant uniqueness stays, with its rationale restated for the paths that remain:
  create and the resolution attach.
- `PRV-13c`'s exception branch loses its "main road". A created machine reaches it only where the
  provider's per-machine date is materially in the future, which the notes record as rare on the
  launch set. The branch stays specified because the read-and-branch shape is what makes an
  adopted machine safe when adopt returns.
- `OPS-32`'s unclaimed-machine rule keeps its Robot example and loses its adopted-machine one.
- `CONTEXT.md` keeps *Adopt* as a headword marked as not a v1 verb, because the concept returns;
  `requeue`, which does not, survives there only as an avoided word.
- `ADR-0006` is untouched. If inventory is taken up, it starts with the secure wipe and amends that
  ADR, not this one.
