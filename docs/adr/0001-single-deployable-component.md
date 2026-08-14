# Single deployable component, not a customer-facing service in front of a credential-holding engine

**Status:** accepted (2026-08-08)

`00-overview.md`'s `OVR-10` presents two separation forms and deliberately gives neither a
default. We chose the **single component**: one deployable named `provisiond` whose internal
architecture distinguishes external-facing from internal modules, rather than two services with
the customer surface in front.

The alternative — a separate front service holding the customer relationship, proxying to a
private engine — keeps provider credentials off the public surface, but puts the tenancy
boundary on a header the engine cannot verify (`API-30`) and splits money from machine
lifecycle across two stores with no shared transaction. That second cost turned out to be
decisive once a prepaid balance became the spending authority (`ADR-0002`): **authorizing a
create and opening the commitment must be one transaction**, and two stores cannot give us one.

## Consequences

- The public customer surface runs in the same address space as credentials to every customer's
  machine. `OVR-10a`'s in-code credential boundary is therefore **not optional hardening — it is
  the only structural defence left**, and `CNF-71`–`CNF-75` are the items that prove it.
- `API-27` applies in its single-component form: customer routes public, operator and
  reconciliation routes on a separate listener.
- `CNF-66`–`CNF-68` (separate-service items) do not apply. `CNF-71`–`CNF-74` do. `F17` in
  `11-open-findings.md` recorded that neither family could be tiered until this was decided;
  this decision unblocks it.
- Adding treasury and Lightning credentials to the same process raises the stakes again. One
  compromise now takes the machines *and* the float. **AMENDED by `ADR-0009`:** the process is
watch-only and cannot spend the on-chain float, so a compromise takes the machines and whatever
sits under `SEC-49`'s channel ceiling — a stated number, not everything.
