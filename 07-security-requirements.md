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

**SEC-2** API tokens MUST be stored only as digests in process memory and compared in
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

**SEC-16** A content digest MUST be required for every custom image, verified on the
rescue host (`DOM-14`, `RSC-25`).

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
customer-owned OS licences with provider-leased ones. The deployment MUST state which of these
it can technically enforce, which it can only contractually require, and what it does on a
provider abuse notice.

**SEC-39** **A per-request acknowledgement is not a control when the caller is not human.**
`API-14` and `SEC-25` require an explicit destructive acknowledgement on every install and
delete, and that works because a person reading a confirmation is a person who can decline.
An autonomous caller sets the flag from a template on every request; it becomes a constant,
and the safety property it was carrying quietly disappears while the field is still present
and still `true`.

A deployment whose callers are autonomous MUST therefore enforce **server-side ceilings per
principal** — at minimum machines destroyed per interval, machines created per interval,
and images written per interval, plus a spend ceiling where the deployment prices its own
resources. The acknowledgement field is retained as a statement of intent and as a defence
against the accidental call; it MUST NOT be the only thing standing between a looping agent
and an emptied account.

The distinguishing property is simple: **a ceiling is something the caller cannot set for
itself.** Any control the caller supplies in its own request is advisory.

**SEC-40** Ceilings MUST be enforced where per-principal state exists. In a deployment where
the deployment chose `DOM-1a`'s no-registry branch, that is not here — it is the front service
(`API-30`), and the deployment MUST say so rather than assuming the control plane enforces
something it cannot.

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

**SEC-35** In the separate-service form of `OVR-10`, the lifecycle service MUST run on a
private management network. In the single-component form it cannot, and the deployment MUST
compensate: the in-code credential boundary of `OVR-10a`, operator routes on a separate
listener (`API-27`), and per-principal ceilings (`SEC-39`). A single-component deployment that
implements none of these has traded its only structural defence for packaging convenience.

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

**SEC-45** A deployment MUST be able to terminate one tenant and every machine it owns in a
single operator action, fast enough to meet the provider's abuse-notice deadline. Under
`ADR-0005` there is no identity to appeal to and no relationship to repair; responsiveness is the
entire remedy, and it MUST NOT depend on the operator enumerating machines by hand under time
pressure.

**SEC-46** When a provider account is lost, the affected tenants' **holds MUST be released back
to available balance**. The customers did nothing wrong, their machines are gone, and continuing
to freeze satoshis against machines that no longer exist would convert the operator's misfortune
into the customer's loss. This is not a refund — `ADR-0004` prohibits those — it is the same
release any cancelled machine triggers, and the ledger already expresses it (`LDG-9`).

**SEC-47** The ledger MUST NOT depend on any provider account remaining reachable. Balances,
holds and history are this system's own records; losing an account is an inventory event, not a
financial one, and a design that reads provider state to answer "what do I owe this customer"
loses the answer at the worst moment.
