# 02 — Provider driver contract

A provider driver adapts one provider account to the uniform interface below. This
document specifies the interface in prose: each operation's inputs, outputs, errors, and
invariants. It deliberately does not give a signature in any language.

## General obligations

**PRV-1** Every operation MUST be safe to call concurrently on the same driver instance.
The control plane serializes work per machine (`OPS-8`) but not per provider account.

**PRV-2** Every operation except *describe capabilities* and *get machine* MUST have a
default implementation that fails with an `unsupported` error naming the operation and
the account. A driver opts in by overriding; it MUST NOT be possible to add an operation
to the interface and silently get a wrong default behaviour in every existing driver.

**PRV-3** *Get machine* MUST be implemented by every driver. It is the refresh primitive
the whole lifecycle depends on.

**PRV-4** A driver MUST NOT declare a capability it does not implement, and MUST NOT
implement an operation whose capability it does not declare (`DOM-15`).

**PRV-5** A driver MUST map provider transport failures to `network`, provider timeouts
to `timeout`, provider non-2xx responses to `provider` (or the more specific
`authentication`, `not_found`, `conflict`, `rate_limited` where the status warrants it),
and MUST attach the upstream HTTP status code to `details.status`. The lifecycle
classifier reads that field to decide whether a failure was ambiguous (`OPS-11`).

**PRV-6** A driver MUST NOT interpolate a caller-controlled value into a provider URL
path without encoding it. Path segments MUST be percent-encoded, and the driver MUST
additionally validate `external_id` against a provider-appropriate character set. An
`external_id` containing `/`, `.`, `?`, or `#` can otherwise redirect the request to a
different endpoint of the same authenticated account. See `DEF-2`.

**PRV-7** A driver MUST NOT log, return, or store a provider credential, a generated
rescue password, or a private key. Where it captures a provider response into an error,
it MUST redact first (`DOM-18`).

## Operations

### Describe capabilities

**Input** — none.
**Output** — account identifier, provider kind, and the declared capability set.

Pure and synchronous; it MUST NOT perform network I/O. It is called on every capability
check and on every `GET /v1/providers`.

### List offers

**Input** — none.
**Output** — offers (`DOM-9`).
**Capability** — none; a driver that cannot enumerate offers returns `unsupported`.

May aggregate several provider endpoints (for example a standard catalog and an auction
market). Offers from different channels MUST be distinguishable by their identifier so
the create path can route on it.

### Create machine

**Input** — offer identifier, optional region, hostname, optional image, SSH public
keys, optional user data, labels, and a provider-options object.
**Output** — the created machine.
**Capability** — `provision_virtual` or `provision_bare_metal` per `DOM-10`.

**PRV-8** Create MUST require at least one SSH public key. The control plane MUST NOT
persist a provider-generated root password, so a machine created without a key would be
unreachable.

**PRV-9** Where the provider requires SSH keys to be registered as account-level
resources before they can be attached, the driver MUST create them, attach them, and
then remove them — but it MUST NOT remove them until the provider has actually consumed
the key material. For a synchronous create that copies key material at creation time,
cleanup immediately after the create call returns is correct. For an *asynchronous*
deploy that reads the key registration later, immediate cleanup produces a machine
nobody can log into. The driver MUST know which of the two its provider is, and the
adapter notes MUST record the answer. See `DEF-6`.

**PRV-10** For a provider that bills on order, create MUST reject the request unless the
request's provider options carry an explicit purchase acknowledgement, *and* the account
is configured to allow ordering. Both, not either.

**PRV-11** Ordering is generally not idempotent at the provider. Where create polls an
order transaction to completion, timing out MUST produce a `timeout` error whose message
states that the order may still be pending and MUST NOT be blindly repeated, and whose
details carry the transaction identifier.

### Get machine

**Input** — `external_id`.
**Output** — the machine as the provider currently reports it.

**PRV-12** Get machine MUST be read-only and free of side effects. It is called
opportunistically after other actions and during reconciliation.

**PRV-28** **Adoption is not a driver operation, and this resolves `F10`'s complaint that
`adopt_existing` is declared as a capability and exposed by the API while no driver operation
implements it.** Adopting is get-machine (`PRV-12`) followed by writing a local row; every driver
already implements the only provider call it needs. The `adopt_existing` capability therefore
gates *the control plane's willingness to adopt against that provider*, not a distinct driver
method — which is worth stating, because a reader looking for the missing operation will not find
one and may add a redundant method to the trait.

`OPS-27`'s resolved-observed outcome takes exactly this path: a machine discovered by its
correlator is attached by reading it and writing the row. Two consequences follow. Attachment
inherits `PRV-12`'s side-effect-free guarantee, so reconciliation cannot mutate anything
(`OPS-28`) even by accident. And an adopted machine has **no correlator**, because nothing wrote
one at its creation — so `STO-17`'s cross-tenant uniqueness, not the correlator, is what stops
two tenants adopting the same machine.

### Delete machine

**Input** — `external_id`.
**Output** — an action result.
**Capability** — `delete_machine`.

**PRV-13** Deletion semantics differ by provider and MUST be modelled, not assumed. Three
shapes exist:

| Shape | Behaviour | May declare `delete_machine` |
|---|---|---|
| Immediate destroy | Resource gone, billing stops | yes |
| Scheduled cancellation | API accepts a cancellation date, possibly bounded by a provider-reported earliest permitted date | yes, with the caveat below |
| Out-of-band process | Support ticket or contract negotiation, no API | no |

A driver in the second category MUST surface the effective cancellation date in its action
result, because "deleted" does not mean "billing stopped" there. A driver in the third
category MUST NOT declare `delete_machine`; modelling a contract termination as a synchronous
API call is a business error, not a missing feature.

**PRV-13a** Deleting a machine does not necessarily delete everything billable that was
attached to it. A driver MUST document which associated resources — volumes, snapshots,
backups, reserved addresses — survive machine deletion and continue to bill, and MUST expose
cleanup for every such resource the provider's API can delete. Only resources the API cannot
reach may be left to an operator procedure, and those MUST be named. A control plane that
reports a machine deleted while its storage continues to accrue cost is reporting a falsehood.

**PRV-13b** A system that resells a machine on prepaid terms MUST be able to bound its own
exposure before taking money. That requires, per product: an API path to stop the cost, a
**measured** worst-case delay before cost actually stops, and cleanup for every billable
attachment (`PRV-13a`).

The reserve is computed **in the provider's billing currency** and converted once, at hold time,
into the ledger unit:

```
reserve_native = setup_fee                              # at cost, no markup (ADR-0006)
               + accrued_unbilled_usage
               + requested_runway × customer_rate       # PRV-13d, customer-chosen
               + wind_down_cost                         # see below
               + billable_attachments                   # PRV-13a
               + cost_through_earliest_cancellation_date # exception branch only (PRV-13c)

hold = to_ledger_unit( reserve_native × (1 + conversion_haircut) )
```

**`customer_rate`, not provider cost.** The reserve must cover what the *customer* is committing
to spend, and since `customer_rate ≥ provider_rate` by construction, holding the customer price
also covers the operator's exposure. Using provider cost here would under-hold every machine by
exactly the margin. **The setup fee is the exception and is held at cost**, because `ADR-0006`
passes it through unmarked — the operator does not profit from a fee it did not earn, and it is
also the one term that is entirely lost if the customer vanishes an hour later, so it MUST be
fully collected before the order is placed.

**`F18` fixed: there is one haircut and it belongs to the conversion, not to the sum.** The
earlier text trailed `× fx_haircut` after the formula without saying whether it multiplied the
whole reserve or only the foreign-currency part, and it conflated two different risks. They are
now separated:

- The **conversion haircut** covers the spread and the rate's staleness at the instant of
  conversion. It applies to the conversion, once.
- **There is no volatile-asset haircut**, because the reserve is no longer held in a volatile
  asset relative to its own liability. Under `ADR-0003` the ledger is denominated in satoshis
  and so is the customer's balance, so a bitcoin move re-prices the *customer's* purchasing
  power, not the operator's coverage. Movement is handled by re-deriving the hold each period
  (`PRV-13e`), not by over-collateralising it once.

**`wind_down_cost` is smaller than this document used to claim, and the reason is worth
recording.** The previous text sized it against an on-call rota — 24 to 72 hours, "72 if the
rota does not cover weekends" — because a failed cancellation classified to
`needs_reconciliation`, which at the time had no exit and therefore meant *wait for a human*.
`OPS-27` changed that: a cancellation's true outcome is readable from provider state through the
machine lookup every driver already implements (`PRV-3`), so the normal case now resolves in
minutes without anyone waking up. Size `wind_down_cost` as **detection interval + measured
confirmed-cancellation latency + margin**, and reserve the pager-latency figure for the case
where provider state cannot be read at all.

*This is the clearest illustration in the document of why `F1` was worth fixing: giving
`needs_reconciliation` an exit did not merely tidy a state machine, it removed days of human
latency from a number that every customer pays for in frozen balance.*

**Where billing is capped per period, that cap is a catastrophe bound worth having.**

**PRV-13d** A create MAY carry a caller-requested **runway** — how long the machine should be
guaranteed to run before an exhausted balance can cancel it. The deployment MUST enforce a floor
equal to `wind_down_cost`'s duration, below which the operator is not covered, and MUST reject a
create whose available balance cannot fund the resulting hold. Making runway a caller input
rather than an operator constant matters because the caller is software that knows its own
intent: a two-hour scratch box and a machine meant to survive a month should not freeze the same
amount of a customer's balance.

**PRV-13e** The hold MUST be re-derived each billing period from current prices and the current
rate, not fixed at create. Where the re-derived hold exceeds the current one and the balance can
cover the difference, an additional hold is placed; where it cannot, the machine enters the same
balance-exhaustion path as a customer who simply ran out of money. **A price or rate movement
MUST NOT be a special case with its own machinery** — it is an ordinary way for a balance to
become insufficient. A single-tick increase MUST be capped and a deficiency MUST persist across
more than one derivation before it can trigger cancellation, so that one bad rate read cannot
cancel a paying customer's machine.

**Where billing is capped per period, that cap is a catastrophe bound worth having.** If total
failure to cancel costs at most `setup_fee + one period cap` per machine, record it: the
reserve above is the expected case, and the cap is the provable upper bound.

**PRV-13c** **A deployment MUST NOT encode any provider's current commercial terms as
constants.** Minimum term, notice period, cancellation immediacy and billing granularity are
per-contract facts that change, differ between a provider's own product lines, and differ
between a machine you ordered and a machine you adopted.

The required shape is read-and-branch: order or adopt, **read** the provider's per-machine
cancellation constraint, and branch to the exception path when it is materially in the future
(`DOM-19`). A machine on the exception branch MUST either carry a machine-specific reserve of
cost-through-that-date, or not be sold on prepaid terms at all.

*This requirement exists because a specification, a reviewing model, and a researching model
each asserted a different set of terms for the same provider, and two of the three were wrong.
Assumptions about commercial terms do not survive review, and they do not survive the provider
changing them. Adoption is the main road onto the exception branch, not a legacy curiosity: an
adopted machine carries whatever contract it came with.*

### Power

**Input** — `external_id`, one of power-on / power-off / reboot / hard-reset.
**Output** — an action result.
**Capability** — `power_control`, or `hard_reset` for the hard reset.

**PRV-14** A driver MUST distinguish a graceful reboot from an out-of-band hard reset,
and MUST return `unsupported` for hard reset rather than silently substituting a
graceful one. On bare metal these have very different consequences.

### Begin rescue

**Input** — `external_id`, and a rescue access request carrying a key name and a
freshly generated single-use public key.
**Output** — a rescue session (`DOM-11`).
**Capability** — `rescue_ssh`.

**PRV-15** Begin rescue MUST both activate the rescue environment *and* initiate the
reboot or reset needed to enter it. The rescue engine waits for SSH; it does not reboot.

**PRV-16** Begin rescue MUST populate the session's host keys with complete OpenSSH
public host keys whenever the provider exposes them. A driver MUST NOT return an empty
host-key list when the provider published keys the driver simply did not parse.

**PRV-17** Begin rescue SHOULD use the supplied ephemeral public key. A driver that uses
provider-generated password authentication instead MUST document why (the provider offers
no key-based rescue), because it forces the workflow onto a password that a
first-connection attacker can capture when host-key pinning is unavailable. It MUST NOT
accept the ephemeral key and then ignore it. See `DEF-7`.

**PRV-18** Begin rescue MUST clean up after itself on partial failure. If the rescue
environment is activated but the reboot fails, the driver MUST attempt to deactivate
rescue and remove any temporary key it registered. If that cleanup itself fails, the
driver MUST attach the identifiers of the leaked resources to the error's details so an
operator can find them.

### Refresh rescue session

**Input** — `external_id`, the current session.
**Output** — an updated session.

**PRV-19** Refresh MUST be safe to call repeatedly while waiting for the rescue system to
boot. Its purpose is to pick up metadata — most importantly host keys — that a provider
only publishes once the rescue environment is running. The default implementation returns
the session unchanged.

**PRV-20** Refresh MUST NOT downgrade a session: it MUST NOT clear an already-known host
key set, and MUST NOT replace key material with an empty value.

### End rescue

**Input** — `external_id`, the session.
**Output** — an action result.
**Capability** — `rescue_ssh`.

**PRV-21** End rescue MUST deactivate the rescue environment, reset or reboot into the
installed system, and remove any temporary credential it registered, using the session's
opaque cleanup token to find it.

**PRV-22** Failure of end rescue is *always* ambiguous — the machine may be in rescue, may
be rebooting into the new system, and a temporary credential may still be registered. The
driver MUST surface it as an error rather than swallowing it, so the lifecycle can route
the operation to reconciliation (`OPS-11`).

### Rebuild

**Input** — `external_id`, a catalog image, optional hostname, SSH keys, user data, and
provider options.
**Output** — an action result.
**Capability** — `native_rebuild`.

**PRV-23** Where the provider's rebuild API has no field for SSH keys and the driver
injects them through a first-boot script instead, this MUST be documented in the adapter
notes, because it silently depends on the target image running a first-boot agent, and it
conflicts with a caller-supplied first-boot payload. The driver MUST NOT quietly discard
either the keys or the caller's payload.

### Boot iPXE

**Input** — `external_id`, an iPXE script.
**Output** — an action result.
**Capability** — `custom_ipxe`.

**PRV-24** The driver MUST reject a script that does not begin with the iPXE shebang.
This is validated in the API layer too (`API-13`); the driver check is the backstop for
direct driver use.

### Set reverse DNS

**Input** — an IP address, a hostname.
**Output** — an action result.
**Capability** — `reverse_dns`.

**PRV-25** The caller-supplied IP MUST have been verified by the control plane to belong
to the machine before the driver is called (`API-16`). The driver MUST still encode it
into the request path safely (`PRV-6`).

### Carrying a correlator

This is not an operation. It is an obligation on **create**, and it is what makes automated
recovery from an ambiguous outcome possible at all.

**PRV-26** A create MUST carry the operation's identifier into the provider, using whatever
caller-controlled field that provider offers, and the driver MUST be able to find resources
bearing it afterwards. Every provider examined offers such a field (`08-provider-notes.md`), so
a driver that cannot do this is asserting something unusual about its provider and MUST say so
in its notes — because it thereby forfeits automated reconciliation (`OPS-27`) and hands every
ambiguous create to a human.

Three constraints on what is written:

- **It MUST be opaque.** The operation UUID and nothing else. It MUST NOT encode the tenant, a
  customer identifier, a hostname the customer chose, or anything else linkable to a person
  (`ADR-0005`). Anyone reading the operator's provider console sees a UUID.
- **It MUST be written in the same request that performs the mutation**, never as a follow-up
  call. A correlator applied afterwards is absent in exactly the case it exists for — the
  request whose reply was lost.
- **It MUST survive the payload purge.** The correlator is a provider-side identifier, which
  `OPS-13` already requires be retained, so it outlives the request body it was derived from.

**PRV-27** Where the provider's caller-controlled field lives on an *order* rather than on the
resulting machine — the robot-style ordering shape — the driver MUST record the provider's own
transaction identifier before treating the outcome as ambiguous, and MUST use the provider's
transaction listing to resolve. This is a stronger position than label search, not a weaker one:
it answers "which orders did I place" directly, rather than inferring it from which machines
exist. Its limit is the provider's listing window (`08-provider-notes.md`).

## Adding a driver

A new driver is expected to:

1. Declare only the capabilities it operationally supports (`PRV-4`).
2. Implement machine lookup (`PRV-3`).
3. Implement provider-specific rescue activation and exit (`PRV-15`, `PRV-21`), and reuse
   the generic rescue engine for everything between them (`OVR-8`).
4. Map provider status strings to normalized machine states, mapping the unrecognized to
   `unknown` (`DOM-7`).
5. Encode every path segment (`PRV-6`).
6. Record, in `08-provider-notes.md`, the answers to: does key material get copied at
   create time or read later (`PRV-9`)? does the provider publish rescue host keys
   (`PRV-16`)? is deletion an API call or a contract process (`PRV-13`)?
