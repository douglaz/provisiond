# provisiond — specification set

A language-neutral specification for a multi-provider control plane that provisions,
adopts, rebuilds, reimages, powers, and deletes VPS and dedicated (bare-metal) machines.

This directory contains **specifications only**. There is deliberately no source code
here, and none should be added. The specs were extracted from a Rust reference
implementation that was reviewed and found to be unbuilt, untested, and holed in two
of its load-bearing safety claims. The *architecture* of that implementation is worth
keeping; the *code* is not. Everything the code got right is written down here as a
requirement, and everything it got wrong is written down in `09-known-defects.md` as a
requirement not to repeat it.

## How to read this

| Document | Contents |
|---|---|
| `00-overview.md` | Problem statement, design goals, system context, non-goals |
| `01-domain-model.md` | Entities, machine states, the capability model |
| `02-provider-contract.md` | The provider driver interface, operation by operation |
| `03-operation-lifecycle.md` | Async operation queue, leases, locks, the reconciliation state machine |
| `04-api-contract.md` | REST surface, authentication, tenancy, idempotency, error envelope |
| `05-persistence.md` | Storage requirements and schema specification |
| `06-rescue-install.md` | Rescue-mode workflow, host-key pinning, image installers |
| `07-security-requirements.md` | Normative security requirements |
| `08-provider-notes.md` | Per-provider API facts worth preserving, and their caveats |
| `09-known-defects.md` | Defects found in the reference implementation, as prohibitions |
| `10-conformance-checklist.md` | What a reimplementation must demonstrate before it serves traffic |

Read `00`, `01`, and `03` first. `03` is the heart of the design — the operation
lifecycle and its treatment of uncertainty is the part that distinguishes this from a
thin API proxy, and it is the part most implementations get wrong.

## Two decisions to make before reading anything else

Both change *which requirements apply to you*. Neither has a default, and inheriting one by
accident is how a deployment ends up with requirements it cannot satisfy and defences it does
not have.

**1. Where is the boundary between customer-facing and credential-holding? (`OVR-10`)**

A separate service in front, or a module boundary inside one deployable. The separate service
keeps the public surface away from provider credentials, but puts the tenancy boundary on a
header the engine cannot verify (`API-30`) and splits money from lifecycle across two stores
with no shared transaction. The single component gets one transaction and a tenancy boundary the
engine can actually check — at the cost of running the public surface in the same address space
as credentials to every customer's machines. If you choose the single component, **`OVR-10a` is
not optional hardening; it is the only structural defence you have left**, and `CNF-71`–`CNF-75`
are the items that prove it.

**2. Do you maintain a tenant registry? (`DOM-1a`)**

Self-serve enrolment requires one, because a new tenant must be writable at runtime.
Operator-configured deployments do not need one and are simpler without. Earlier revisions of
this document asserted flatly that no registry is maintained; that was a description of one
implementation promoted to a rule, and it has been withdrawn.

Record both answers where the next reader will find them.

## How much to trust this

Every requirement here wears the same costume — a MUST, a stable identifier, a conformance
item. **The confidence behind them is not uniform, and the formatting hides that.** Read this
before treating a checklist tick as assurance.

- **Nothing here has been validated against a running implementation.** The set was extracted
  from code that never compiled and never ran.
- **Provider facts carry explicit markers** — `[design]`, `[observed]`, `[verify]` — in
  `08-provider-notes.md`. Treat `[verify]` as unverified, because it is.
- **Three requirements were reversed in place during authoring**, and the reversals are recorded
  where they happened rather than tidied away: `DOM-1a`, `PRV-13c`, `OVR-10`.

That last point cuts the opposite way to how it reads. Recorded corrections mark where a review
happened to collide with the text — they are not evidence that errors get caught. **The honest
inference is the base rate:** three load-bearing reversals across roughly a dozen edits means
the unmarked text plausibly carries similar error density, unmarked.

**The least-reviewed documents are identifiable.** `03-operation-lifecycle.md`,
`06-rescue-install.md` and `09-known-defects.md` were written before four separate changes to the
product model and have not been re-read against the final one. `03` is also the document this
README calls the heart of the design. Weight accordingly.

**A green conformance checklist certifies the requirements that are written down.** It says
nothing about what is missing — and a builder will have to invent a wire format, an adopt
driver operation, and the resolution path out of `needs_reconciliation`, none of which this set
specifies (see `10-conformance-checklist.md` for what tiering does and does not cover).

## Requirement conventions

Requirements use RFC 2119 keywords: **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**,
**MAY**. Each is tagged with a stable identifier so it can be cited in code review,
tests, and issue trackers:

| Prefix | Domain |
|---|---|
| `OVR-n` | Overview and scope |
| `DOM-n` | Domain model |
| `PRV-n` | Provider driver contract |
| `OPS-n` | Operation lifecycle |
| `API-n` | HTTP API contract |
| `STO-n` | Persistence |
| `RSC-n` | Rescue and image installation |
| `SEC-n` | Security |
| `DEF-n` | Defect prohibitions |
| `CNF-n` | Conformance checklist items |

Identifiers are append-only. If a requirement is withdrawn, mark it `WITHDRAWN` in
place rather than renumbering the ones after it.

## Language and runtime

Nothing in this specification assumes a particular language, HTTP framework, or
database engine, except where a requirement explicitly says otherwise (see
`05-persistence.md` for the transactional guarantees the operation queue needs). The
reference implementation used Rust, an async HTTP framework, and SQLite; only the
last of those had architectural consequences, and `05` describes what a replacement
must provide.

## Status

These documents describe a target system. No part of them has been validated against
a running implementation. Provider API details in `08-provider-notes.md` were read
out of the reference adapters, not verified against live provider APIs, and each one
carries an explicit confidence note. Verify against current provider documentation
before implementing an adapter.
