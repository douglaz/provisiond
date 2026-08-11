# Setup fees pass through at cost; inventory and the VM line are deferred, together

**Status:** accepted (2026-08-11)

v1 orders a machine per tenant and cancels it when funding runs out (`LDG-13`). **No machine
ever serves two tenants.** Setup fees are passed through to the renter **at cost, with no
markup** — the operator does not profit from a fee it did not earn.

Holding a fleet and re-renting it *is* the intended direction, and it was chosen deliberately.
It is deferred because its economics depend on something v1 does not have.

## Why inventory cannot ship before slicing

A standard dedicated setup fee is roughly equal to a month of that machine's runtime — on an
AX-class box, about €39 against €39/month, or some **730 hours of runtime per setup fee**. A
tenant renting for two hours consumes eleven cents of machine time and thirty-nine euros of
setup. Pass-through pricing does not merely look unfair there; it makes short dedicated rentals
economically absurd.

Amortising that fee requires keeping the machine between tenants, which requires absorbing idle
time. **Sequential whole-machine rentals leave large gaps**, and the saved setup fee does not
cover them. What closes the gap is density: slicing one box into many VMs fills it with enough
small tenants that idle time shrinks and the fee amortises across all of them at once. Inventory
without slicing is the worst of both — you carry the idle cost and get none of the utilisation.

So the two ship together, or neither does.

## What v1 does instead

**Steer callers to the products that have no setup fee.** Auction/market dedicated servers carry
none (`08-provider-notes.md`), and neither do cloud VMs. The expensive case is one product line,
not the catalogue, and the API should make the difference legible rather than hiding it in a
total.

## Consequences

- **No secure-wipe requirement in v1**, because there is no reuse. It becomes **blocking** the
  moment a machine can serve a second tenant: bare metal has no hypervisor to zero anything, so
  provable erasure between tenants is a new requirement with a data-leak failure mode, and it
  MUST be specified before the first re-rent, not after.
- **`LDG-14`'s destroy-on-exhaustion stays correct for v1** and becomes wrong under inventory,
  where the machine returns to a pool rather than to the provider.
- The reserve keeps its `setup_fee` term (`PRV-13b`). Under inventory that term disappears for a
  pooled machine and is replaced by an idle-cost allowance, which is an operator risk rather
  than a customer charge — a different formula, not a tweaked one.

## The VM line

Slicing dedicated machines into VMs sold under the same API is accepted as a **future business
line with its own specification**, not an extension of this one. One architectural note is worth
recording now because it shapes both:

**`provisiond` would become its own driver.** A hypervisor layer implements the same contract as
Hetzner and Cherry — capabilities, create, delete, power, rescue, install — so the VM product
appears as another provider account rather than a parallel system. That is also a real test of
whether this specification's abstraction was ever right: if the driver trait cannot express a
hypervisor the operator fully controls, it was a description of three vendors rather than a
contract. And host provisioning needs no new machinery — installing a hypervisor onto bare metal
*is* the rescue and `installimage` path in `06-rescue-install.md`, which makes the operator its
own first customer for the differentiator.

What it also brings, and what its specification must answer before any of it ships:

- **Addressing.** Hetzner's System Policies forbid manual MAC changes (`SEC-42`); the supported
  path is a Hetzner-assigned MAC per additional address, or a routed subnet. **[verify]** — this
  constrains the network design and has not been checked against current documentation.
- **Isolation.** Two tenants share silicon, so a hypervisor escape crosses a customer boundary
  that reselling never risked, because Hetzner owned it.
- **Correlated failure.** One host dies and every VM on it dies. Single boxes with local disks
  have no live migration.
- **Abuse blast radius.** `SEC-41` already notes one abusive tenant can expose the whole account.
  Under slicing, one abusive VM can get the host nulled — killing every paying tenant on it.
- **Uptime and durability become the operator's.** Reselling meant the provider owed the SLA.

The two products also sell different things, and conflating them would weaken both: resale sells
multi-vendor reach and automation; slicing sells margin and control, and needs no multi-vendor
abstraction at all.
