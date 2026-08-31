# 07 — Security requirements

Normative. Each requirement here is testable; `10-conformance-checklist.md` says how.

## Threat model

Assumed adversaries, in descending order of concern:

1. **A legitimate tenant escalating past its boundary** — reaching another tenant's
   machines, or the operator's own infrastructure inside the same provider account. This
   is the primary threat, because the control plane holds credentials far broader than
   any one tenant's entitlement.
2. **A network adversary on the path to a rescue environment** — able to impersonate a
   rescue host on first connection and capture a root credential or serve a different
   image.
3. **An adversary who obtains the operation store or a backup** — signed image URLs,
   provider metadata, machine inventory.
4. **A compromised or malicious image host** — serving something other than what the
   caller intended.

Explicitly *not* defended against: a compromised operator, a compromised provider API, or
an adversary with filesystem access to the running service.

## Credentials

**SEC-1** Provider credentials MUST NOT appear in configuration files, in any form.
Configuration names an environment variable; the process reads the value (`OVR-7`).

**SEC-2** API tokens MUST be stored only as digests — the operator's in process memory
(`API-4`), a customer's persisted in `tenants` (`API-3`, `STO-21`) — and compared in
constant time (`API-3`).

**SEC-3** No credential — provider token, rescue password, private key, signed URL — may
appear in a log line, an operation result, an error message, or a stored metadata blob.
Redaction (`DOM-6`) MUST be applied on the write path, so that a later change to the read
path cannot expose what was stored in the clear.

**SEC-4** Redaction MUST be applied to provider responses captured from *successful*
requests as well as failed ones. A 200 response that the driver could not interpret is
exactly as sensitive as a 500 (`DOM-18`, `DEF-3`).

**SEC-5** Credential-bearing in-memory types MUST redact in debug formatting and SHOULD
zero on drop (`DOM-11`).

## Tenancy

**SEC-6** A tenant's authority MUST derive from machine records, never from the ability to
name a provider account. Naming a configured account MUST grant nothing (`DOM-3`).

**SEC-7** Adoption MUST require entitlement proof (`API-18`). This is the single most
important tenancy requirement: without it, "per-tenant isolation" holds only for machines
the system itself created, and any tenant can take over any machine in any configured
account.

**SEC-8** Machine lookup MUST be tenant-scoped, and a machine outside the tenant MUST be
indistinguishable from one that does not exist (`API-17`).

**SEC-9** The admin tenant-override header MUST be honoured only for admin identities and
MUST be validated (`API-5`, `API-6`).

**SEC-10** Two tenants MUST NOT be able to hold records for the same external machine. If
adoption entitlement (`SEC-7`) is enforced by an operator-maintained assignment, that
assignment MUST be unique per external machine.

## Injection

**SEC-11** Caller-controlled values MUST NOT be interpolated into provider URL paths
without percent-encoding, and `external_id` MUST additionally be character-set validated
(`PRV-6`). Demonstrated impact when this is missing: a crafted identifier redirects the
request to an unrelated endpoint of the same authenticated provider account, and the
response is returned to the tenant through the operation's error details.

**SEC-12** Caller-controlled values MUST NOT be interpolated into remote shell text.
Base64-transport everything (`RSC-15`).

**SEC-13** Caller-controlled values MUST NOT be interpolated into generated installer
configuration without validation for line breaks, NUL, and whitespace where the format is
whitespace-delimited (`RSC-23`).

**SEC-14** Database access MUST use parameter binding throughout. No query may be built
by string concatenation with request data.

## Capability enforcement

**SEC-15** Every operation MUST be capability-gated before the driver is called,
including create (`DOM-10`). A driver-internal check is defense in depth, not the gate.

## Image trust

**SEC-16** **AMENDED.** A content digest MUST be required for every image **whose bytes this
system writes** — `rootfs_tarball` and `raw_disk`, exactly `DOM-14`'s scope, verified on the
rescue host (`RSC-25`). The original said "every custom image", which `F12` flagged as
conflicting with `DOM-14` — and the conflict resolves on a capability fact, not a preference:
where this system does not touch the bytes there is nothing here to verify and a digest would
attest nothing. **The live case is catalogue install** (`ADR-0013`): the provider fetches the
image, converts it and boots its own copy, and DigitalOcean's import API has no checksum field, so
nothing on that path can attest what reaches the disk. *The example that carried this argument
was the iPXE script, whose surface was withdrawn on 2026-08-31; the argument outlived it and now
describes a path that ships.* Where integrity is out of this system's reach it MUST NOT be
implied; `SEC-17`'s provenance note applies with double force.

**SEC-17** Digest verification is *not* signature verification. It proves the bytes match
what the caller asked for; it proves nothing about who authored them. Deployments that
need provenance MUST add signature verification outside this system.

**SEC-18** Image URLs MUST be HTTPS unless insecure HTTP is explicitly enabled, MUST NOT
carry embedded credentials, and MUST NOT carry a fragment (`API-13`).

**SEC-19** A host allowlist SHOULD be configured in production. An empty allowlist means
"any host" — this is a fail-open default and MUST be flagged loudly at startup when the
service is not in a development mode.

**SEC-20** Wildcard allowlist patterns MUST match only proper subdomains — `*.example.com`
MUST NOT match `example.com` — and matching MUST be case-insensitive.

**SEC-21** Signed image URLs stored in the operation record are credentials (`STO-9`).
They MUST have short lifetimes, and the store MUST be encrypted (`OVR-12`).

## Transport to rescue

**SEC-22** Host-key pinning MUST be enforced per `RSC-3`. First-use trust MUST be an
explicit, per-request, opt-in decision by the caller — never a fallback the system takes
on its own (`RSC-5`).

**SEC-23** A provider that cannot publish rescue host keys MUST be documented as such, so
callers know they must supply keys out of band (`08-provider-notes.md`).

**SEC-24** Password-based rescue combined with first-use trust exposes a root password to
a first-connection adversary. Where a driver has no key-based rescue (`PRV-17`), the
deployment SHOULD refuse the first-use-trust option for that provider entirely.

## Destructive and billable actions

**SEC-25** Installs and deletions MUST carry a per-request destructive acknowledgement
(`API-14`).

**SEC-26** Orders MUST carry a per-request purchase acknowledgement *and* an account-level
opt-in (`API-15`, `PRV-10`).

**SEC-27** Ambiguous mutations MUST NOT be retried automatically (`OPS-12`). Automatic
retry of a create is how a control plane buys two servers.

**SEC-28** Requeue MUST be operator-only (`API-19`) and MUST make re-purchase explicit
(`OPS-20`).

## Availability

**SEC-41** **Reselling concentrates every customer's fate in one provider account.** A
deployment that resells capacity MUST establish, from the provider's actual terms rather than
from assumption, whether abuse consequences are scoped to the offending resource or reach the
account. Where they reach the account, **one abusive tenant can terminate every tenant**, and
that MUST be recorded as an explicitly accepted risk with named mitigations — segregation into
separate provider accounts by risk tier, egress controls, an enforced content policy — not left
as a footnote.

Two facts usually need separate answers: whether the provider's terms permit reselling at all,
and whether they permit *anonymous* downstream customers. Permission for the first does not
imply the second, and the reseller normally remains the provider's sole counterparty and is
fully liable for what its customers do.

**SEC-42** **Where customers supply their own OS images, the deployment MUST derive an
acceptable-use policy from the provider's own terms and enforce what it can.** A customer image
is arbitrary code running on hardware rented in the operator's name. Typical provider
prohibitions that a reseller inherits and must pass on: no manual MAC address changes, no
scanning of foreign networks, no source-IP spoofing, no cryptocurrency mining, and no combining
customer-owned OS licences with provider-leased ones. *"Enforce what it can" is bounded (`F18`):
enforceable means checkable at request time from data the system already holds (image source
pairings, provider options, capability gates) — each such rule MUST be enforced and named;
everything only observable on the running machine is explicitly a terms obligation backed by
`SEC-45`'s ability to stop serving a tenant, and MUST be listed as such rather than implied
enforced.* The deployment
MUST state which of these
it can technically enforce, which it can only contractually require, and what it does on a
provider abuse notice.

**SEC-39** **A per-request acknowledgement is not a control when the caller is not human.**
`API-14` and `SEC-25` require an explicit destructive acknowledgement on every install and
delete, and that works because a person reading a confirmation is a person who can decline.
An autonomous caller sets the flag from a template on every request; it becomes a constant,
and the safety property it was carrying quietly disappears while the field is still present
and still `true`.

A deployment whose callers are autonomous MUST therefore enforce **server-side ceilings per
principal** — the interval is a stated deployment parameter, **default one hour**, and each
ceiling is a stated integer (`F18`) — at minimum machines destroyed per interval, machines
created per interval,
images written per interval, **rescue entries per interval** and **power cycles per interval**,
plus a spend ceiling where the deployment prices its own resources.

**AMENDED 2026-08-31 — rescue entries and power cycles were uncapped, and one of them reboots a
running machine.** `RSC-38`'s rescue inventory boots a machine into the provider's rescue system to
read its disks, and `PRV-22` makes the exit always ambiguous, so a failure can strand a customer's
machine there with nothing serving. It carries no destructive acknowledgement and, until now, no
ceiling — while an agent's natural loop is read-inventory, install, fail, read-inventory again. Each
iteration took the machine down and nothing counted them. Power and hard-reset were in the same
position. The ceiling is on *rescue entries* rather than on the operation, so it covers the
inventory pass and every rescue-entering install together — the two ways a machine gets rebooted
into another operating system.

**AMENDED 2026-08-31 — ceilings apply to operator principals too, and this is the larger change.**
Every dangerous shortcut in this set is justified by "an operator decides": `OPS-27` attempts
automatic resolution "before asking a human", `PRV-33` resolves to an operator "never to a guess",
`DOM-23` has an operator read a notice and transcribe it, and `API-19` makes requeue operator-only
*because* it can re-issue a purchase. **Those all assume the operator is a person who does not
loop.** Where an operator principal is a program — and this deployment's is — the paragraph above
applies to it unchanged, and it has strictly more power than any customer: requeue places physical
orders, resolve-observed attaches a machine to a tenant on the operator's say-so, suspend cancels a
fleet. A deployment MUST therefore state ceilings for operator principals — at minimum requeues,
resolutions, suspensions and provider-account re-assignments per interval — with a stated override
path for a genuine incident, and MUST record that the override is the uncapped thing.

**Every operator verb MUST emit a monitorable event** naming the principal, the target, and the
reason. `SEC-32`'s audit record already covers mutating *requests*; this is the operator surface
specifically, where the actor may be automated and the harm is authorised by construction rather
than by a bug.

*The asymmetry was the finding: the customer side was hardened against a looping program and the
operator side, which can do strictly more, was not — because the word "operator" was carrying an
assumption nobody had written down.* The acknowledgement field is retained as a statement of intent and as a defence
against the accidental call; it MUST NOT be the only thing standing between a looping agent
and an emptied account.

The distinguishing property is simple: **a ceiling is something the caller cannot set for
itself.** Any control the caller supplies in its own request is advisory.

**SEC-29** Request bodies MUST be size-capped globally, and individual fields MUST be
capped per `API-13`.

**SEC-30** Unauthenticated endpoints MUST be rate-limited, and per-tenant rate limiting
SHOULD exist for enqueues (`API-29`, `OPS-24`).

**SEC-31** A tenant MUST NOT be able to starve other tenants' operations through queue
flooding (`OPS-24`).

## Audit

**SEC-32** Every mutating request MUST produce an audit record containing: correlation
id, tenant, authenticated identity, whether an admin override was used and to which
tenant, operation id, operation kind, target machine, and outcome.

**SEC-33** Audit records MUST be written to a destination separate from the operation
store, so that a compromise of the service's own database does not erase the trail.

**SEC-34** The operation log is not an audit log. It records what the system did, not who
asked or under what authority.

## Deployment posture

**SEC-35** **AMENDED — collapsed to the single-component form settled by `ADR-0001`.** The
lifecycle service cannot run on a private management network, because the customer is the
caller, so the deployment MUST compensate: the in-code credential boundary of `OVR-10a`,
operator routes on a separate listener (`API-27`), and per-principal ceilings (`SEC-39`). A
deployment that implements none of these has traded its only structural defence for packaging
convenience. *The withdrawn branch made the private management network the primary control in
the separate-service form; there is no such form.*

**SEC-36** The service SHOULD run as an unprivileged user, with a read-only root
filesystem, no new privileges, and writable mounts only for the store and the recovery
directory.

**SEC-37** Provider accounts SHOULD be least-privileged and separate per deployment where
the provider supports scoped credentials.

**SEC-38** Credential rotation procedures MUST exist for API tokens, provider
credentials, and any persisted recovery key.

## Surviving an account-level termination

`SEC-41` records the contractual fact; these are the requirements that follow from it once
`ADR-0002` lets anonymous strangers run arbitrary code on the operator's accounts.

**SEC-43** Tenants MUST be distributed across **multiple provider accounts** at the same
provider, so that an account-level termination takes a fraction of the customer base rather than
all of it. This is the purpose `API-17b`'s account assignment serves — it is not merely an
authorization rule, it is the blast-radius control, and an assignment policy that puts every
tenant in one account satisfies `API-17b` while defeating this requirement.

**SEC-44** **[verify]** Whether a provider treats separately-registered accounts as genuinely
separate MUST be checked before relying on `SEC-43`. Providers commonly link accounts sharing a
payment method, a contact address or a beneficial owner, and terminate them together — in which
case the isolation is illusory and real separation requires distinct legal entities. **A control
that has not been verified against the provider's actual practice is a belief, not a defence.**

**SEC-55** **A catalogue install puts a customer's operating system in a catalogue shared with every
other customer of that provider account, and the exposure is accepted and bounded rather than
solved.** `ADR-0013`'s import route (`RSC-39`) writes the image into the operator's own account at
the provider, and at least one launch provider offers **no scoping below the account** — custom
images are not a per-project resource there, so any credential with image-read permission on that
account can list one image and build a machine from it.

**No caller can reach another tenant's image.** Callers supply URLs and never image identifiers, the
identifier is minted internally per install, and `API-17`'s tenant scoping applies as everywhere
else. **This is not a tenant-to-tenant hole**; it is operator-side concentration, of the same kind
`SEC-41` records for abuse consequences and `SEC-44` records for account linkage.

Two things bound it, and the deployment MUST rely on both rather than on either alone:

- **Time.** `RSC-42` deletes both copies when the operation stops being live, so the window is one
  install rather than the machine's lifetime, and `OPS-32`'s sweep deletes an orphan whose delete
  was lost.
- **Blast radius.** `SEC-43` already distributes tenants across multiple provider accounts, which
  reduces how many customers share any one catalogue — a control that was written for account
  termination and turns out to bound this too.

**A provider account per tenant is not the remedy**, and the reason is `ADR-0002`: account or team
creation is not a self-serve API act, and enrolment has no operator step by design. A separate
account per anonymous stranger is not operable.

*Recorded rather than mitigated further, and named so a deployment states it rather than discovers
it. The alternative considered was making the delete part of the settling transaction; a provider
call cannot be inside a database transaction, and phrasing it as ordering-plus-retry is how `STO-40`
became self-contradictory.*

**SEC-45** **AMENDED 2026-08-15 — the premise was wrong, and it was propagating.** The withdrawn
text said a deployment MUST terminate one tenant and every machine it owns in a single operator
action *"fast enough to meet the provider's abuse-notice deadline"*, and called responsiveness
*"the entire remedy"*. It described a stopwatch. **Abuse handling is correspondence, and the
suspension is the provider's, not the operator's.**

What a real notice does, from one read against the live process: it alleges an attack from a named
server, sets a dated deadline days out, requires a **statement** in reply, and warns that the
**server may be locked** — not terminated — if no effective solution is shown. Manual replies are
not processed; a single-use link is the only channel, and submitting through it *concludes the
deadline immediately*. `08-provider-notes.md` already recorded the shape — *"routine abuse
handling targets the offending IP after notice, deadline and manual review"* — and this
requirement was written as though it had not.

What a deployment MUST actually be able to do:

- **Resolve the notice to a tenant.** Given a provider resource, an address and an instant, the
  system MUST identify the owning tenant, the machine, and the operations that touched it inside
  that window. This is the fact every answer depends on, and **no requirement previously said
  so** — the capability was assumed to exist in the schema and appeared nowhere in the normative
  set. **AMENDED 2026-08-16: it did not exist in the schema either.** This text claimed the
  question was "answerable from `machines` (`public_ips`, …)"; `public_ips` is current state
  overwritten by every refresh (`DOM-8`), so an address plus an *instant* had nothing to bind to,
  and resolving against it names whichever tenant holds the address **now** — routinely a
  different, innocent customer, since providers reissue addresses and the usual sequence is that
  the machine was deleted before the notice arrived. `SEC-54` and `STO-41` supply the missing
  history; the mechanism is `05-persistence.md`'s, and this bullet cites it rather than restating
  it (see this document's scope note).
- **Relay the allegation to that tenant and take back a statement**, in provider-neutral terms.
  The operator remains the provider's sole counterparty and fully liable (`08-provider-notes.md`),
  so the statement that reaches the provider is the operator's, informed by the tenant's. **The
  provider's own case reference and statement link MUST NOT be relayed to a tenant** — for the
  same reason `WIR-30` and `LDG-26` strip provider price, currency and raw metadata from the
  customer surface, and because that link is a one-shot bearer credential whose use ends a
  deadline the tenant does not own. *The surface now exists: `DOM-23`'s abuse case, `API-59`'s two
  reads and `WIR-43`'s statement write, with `ADR-0012` recording why nothing is relayed in either
  direction. Under `ADR-0005` there is no email and no contact, so it could only ever be a read the
  caller polls and a write it submits — the shape `LDG-15` already relies on.*
- **Suspend a tenant and cancel its fleet in one operator action** (`API-58`). This capability
  survives the amendment; only its justification changes. It is the operator's own decision to
  stop serving a tenant — an unanswered notice, a repeat offender, a legal instruction — and not
  a race against a provider deadline. It MUST NOT depend on the operator enumerating machines by
  hand.

**What this changes downstream:** nothing that depended on the *capability*, everything that
depended on the *urgency*. `SEC-42`'s unenforceable AUP rules are backed by the operator's ability
to stop serving a tenant, not by beating a deadline. `OPS-14` and `OPS-27` route around a human in
the loop because a suspended tenant's fleet should not bill on indefinitely, which is a money
argument and stands on its own.

**A locked machine still bills.** The provider's remedy leaves the machine running, charging, and
useless to its owner, so the customer's runway keeps draining (`LDG-13`, `LDG-33`) for compute it
cannot reach. *Settled 2026-08-16 by `LDG-71` and `DOM-27`: it keeps billing, the machine view carries the
restriction as a structured fact beside `runway_until`, and delete stays available as the
customer's own remedy. `DOM-27` owns the reasoning; this note cites it rather than repeating it,
because the first version of that argument was copied into three documents and was wrong in all
three.*

**SEC-54** **The deployment MUST be able to answer which machines held a given address at a given
instant, and MUST answer it as a candidate set rather than a single machine.** This is the first
step of every abuse notice and the one with the worst failure mode: a confident wrong answer
accuses an innocent tenant and then invites that tenant to explain a machine it never owned, which
is a cross-tenant disclosure performed by the operator. The record it reads is `STO-41`, which
stores **observation** windows — provisiond polls a provider rather than watching one — so the
honest result is every machine observed holding the address in a window containing the instant,
which MAY be empty and MAY hold several. **Operator-only** (`WIR-46`, `WIR-34`): it maps an
address to a customer, which is the single most identifying join the system can perform. *It cited
`API-60` until 2026-08-16, which covers creating, closing and recording transmission — none of them
this, and none of them a `GET`.*

**SEC-46** **AMENDED twice — and "lost" turned out to mean three different things.** Only one of
them establishes that billing has stopped, and releasing on the other two hands the customer their
satoshis back while the operator keeps paying for machines that are still running:

| State | Meaning | Commitments |
|---|---|---|
| `account_unreachable` | API down, network partition | **Retained** — the machines are almost certainly still running and still billing |
| `credentials_rejected` | Auth failing; the account may be intact | **Retained** — losing the key is not losing the servers |
| Confirmed termination | The provider states the resources are gone | **Closed, released in full** (`LDG-32`) |

Where exposure must be carried without confirmation, it MUST be recorded as an **operator
deficiency** (`LDG-66`) rather than left implicit. On confirmed termination the customers did
nothing wrong, their machines are genuinely gone, and continuing to reserve against them would
convert the operator's misfortune into the customer's loss — that release is not a refund
(`ADR-0004` prohibits those), it is the same release any cancelled machine triggers.

*The first amendment fixed "holds"/`LDG-9`. **This second one was written on 2026-08-13, failed to
apply, and shipped as prose claiming it had** — `LDG-32` cited it as amended and `CNF-188` tested
the amended behaviour while this requirement still mandated the opposite. Two reviewers caught it
independently.*
*The original said "holds" and cited `LDG-9`'s withdrawn wording; the hold became a commitment
that decays, and `LDG-9` survives AMENDED as the availability formula.*

**SEC-47** The ledger MUST NOT depend on any provider account remaining reachable. Balances,
commitments and history are this system's own records; losing an account is an inventory event,
not a financial one, and a design that reads provider state to answer "what do I owe this
customer" loses the answer at the worst moment.

*Note on this document's scope, added 2026-08-14 after a skeptical audit.* Where a security
requirement here restates a rule owned by a numbered requirement elsewhere, **the other document
is authoritative and this one cites rather than repeats it.** `SEC-46` is why: it restated
`LDG-32`'s release rule, the two drifted apart, and an amendment to one shipped while the other
still mandated the opposite — through a panel review that tested the amended behaviour. A second
normative copy is not redundancy, it is a second thing to forget.

## Key custody

`ADR-0009`. These requirements exist because `ADR-0008` made the deployment derive Bitcoin
addresses, which turned `F13` — one compromise takes the machines *and* the float — from a worry
into a key on a disk.

**SEC-48** **AMENDED 2026-08-31 — the original stated something no Lightning deployment can
satisfy, and it conflated two boundaries.**

**The on-chain float MUST be watch-only.** An extended public key or output descriptor is sufficient
to derive every deposit address (`LDG-50`) and to observe every payment (`LDG-57`); nothing in the
specified behaviour requires more. **The key that can move those funds MUST live outside the
deployment**, and no code path in the deployment may reach it. This part stands unchanged.

**The credential-holding process MUST reach Lightning only through a credential scoped to invoice
creation and observation** — create, look up, list and subscribe — **on a separate host.** This is
the boundary that matters for `ADR-0001`: the process holding provider credentials and root on
every customer machine cannot move the float, and that is achievable today with per-RPC credential
scoping.

*The withdrawn clause was "MUST NOT hold anything that can construct a spend", stated of the whole
deployment. Two independent research passes established that it is unsatisfiable: **receiving
Lightning is inseparable from spending it.** Settling an inbound HTLC means signing a new commitment
transaction, and the key that signs it can sign the balance away — there is no Lightning analogue of
an extended public key. And a node's "watch-only" mode does not deliver it either: the signer signs
whatever the watch-only node hands it, so key material is off the box while spend authority is not.
A requirement that cannot be met is not a control; it is a belief, which is what `SEC-44` says about
unverified controls generally.*

**SEC-49** **Lightning is necessarily hot, so it MUST be bounded. AMENDED 2026-08-31 — the bound
covers two pots, and the sweep is a manual operator action.**

A deployment MUST state a ceiling in satoshis covering **the channel balance *plus* the Lightning
node's own on-chain wallet**, and sweep the excess to the cold destination `SEC-50` fixes. That
figure is the blast radius of a full compromise of the Lightning host, and it MUST be chosen against
the size of the float rather than against the convenience of not sweeping.

**The node's on-chain wallet is the second pot and was never counted.** Opening and closing channels
are on-chain spends, so a Lightning node necessarily holds a spending key for a wallet of its own,
and a closed channel's balance lands there. `ADR-0009` sells the ceiling as "the blast radius
expressed as a number"; counting only the channels understated it by whatever sits in that wallet.

**The sweep is a manual operator action, like `SEC-51`'s refill**, and the deployment MUST state its
mechanism — a cooperative close, or a swap — because Lightning balance cannot be sent directly to an
on-chain address and the choice has real consequences: closing channels destroys the inbound
capacity `CNF-136` depends on, and a swap introduces a counterparty `ADR-0009` rejected a custodian
to avoid. **Where the sweep is signed on the Lightning host, the signer MUST reject any transaction
whose outputs are not the pinned cold destination**, which is what makes the ceiling a mechanism
rather than a habit.

*A stated bound the operator enforces by acting is weaker than one the code enforces. It is recorded
as such rather than described as automatic.*

**SEC-50** **The sweep destination MUST be fixed at deployment and MUST NOT be settable at
runtime.** A process that can be told where to sweep can be told to sweep to an attacker, which
converts the ceiling from a bound into a delay.

**SEC-51** **Refilling channels from cold MUST be a manual operator action** and MUST NOT be
automatable by any path the process controls. Automating it would be a path from the compromised
process back to the cold key, which is the whole thing `SEC-48` buys.

This is affordable only because of how `ADR-0008` shaped deposits: a deposit carries **both**
destinations, so exhausted inbound capacity does not stop funding — the customer pays the address
instead. **Without the second rail this requirement would make an operator's sleep into an
outage.**

**SEC-52** **The watch-only key material MUST be treated as confidential although it grants no
spending.** An extended public key reveals every address ever derived from it, so disclosing it
publishes the operator's entire deposit history with every customer's payments linked together —
`ADR-0005`'s exact prohibited outcome, reached without a single credential being stolen. It is a
privacy secret rather than a spending secret, and the distinction is a reason to handle it
carefully, not casually.

**SEC-53** **The cold key's backup and recovery procedure MUST be documented and MUST have been
tested before the first customer payment is accepted.** `ADR-0009` moves risk from compromise to
custody, and custody is only the smaller risk if this exists. Losing the key destroys the entire
float with no recovery, no insurance and no counterparty to appeal to — and unlike a compromise,
it can happen with no attacker involved at all.
