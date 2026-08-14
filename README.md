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
| `11-open-findings.md` | **Read this before building.** Findings `F1`–`F33` accumulated over several successive audits, which are fixed and which are open, and the three questions a builder must ask first — all three now answered |
| `12-billing-and-ledger.md` | The ledger, commitments, the meter, funding, exhaustion and solvency. Under `ADR-0002` this **is** the authorization system |
| `CONTEXT.md` | Glossary. Which word means what, and which words are banned |
| `13-wire-contract.md` | Bodies, headers, bearer auth, the error envelope. Closes `F19`, panel-reviewed |
| `docs/adr/` | The decisions, and what was rejected to reach them |

Read `00`, `01`, and `03` first. `03` is the heart of the design — the operation
lifecycle and its treatment of uncertainty is the part that distinguishes this from a
thin API proxy, and it is the part most implementations get wrong.

## The decisions this specification is built on

Earlier revisions opened with two unanswered questions — the separation form (`OVR-10`) and the
tenant registry (`DOM-1a`) — and warned that inheriting either by accident produces a deployment
with requirements it cannot satisfy. **Both are now answered, along with the product decisions
that followed from them.** They live in `docs/adr/`, and each records what was rejected:

| ADR | Decision |
|---|---|
| `0001` | One deployable, not a customer-facing service in front of a credential-holding engine. Settles `OVR-10`; `OVR-10a` is therefore the only structural credential defence left |
| `0002` | Self-serve enrolment, with a prepaid balance as the entire spending authority. Settles `DOM-1a` in favour of a registry |
| `0003` | The customer float is denominated in satoshis, with a recorded dissent |
| `0004` | The regulatory perimeter is held by product design — no withdrawal, no transfer, no fiat refund, B2B only |
| `0005` | Collect nothing about customers; purge caller payload once an operation stops being live |
| `0006` | v1 is pass-through: setup fees at cost, no machine reuse. Inventory and the VM line are deferred together |
| `0007` | Margin is a percentage of machine time; installs and rescue are free but metered |
| `0008` | A deposit is one object — amount and expiry — payable over Lightning or on-chain; the payer chooses. Attribution is by destination, never by payer |
| `0009` | The process is watch-only and cannot spend the float. Lightning is hot and therefore capped; that cap is the blast radius |
| `0010` | v1 ships three drivers — Hetzner Cloud, Hetzner Robot, DigitalOcean — for both machine shapes across two companies. Settles the launch-set question |
| `0011` | Commitments are fixed at open and never auto-widen; a price move shifts the runway date instead. Closes `F27`; amends `ADR-0003`'s matching claim |

**Read `ADR-0002` through `ADR-0004` before `12-billing-and-ledger.md`**, and read `ADR-0003`'s
dissent before treating satoshi denomination as settled. The credential question is settled:
customer requests carry a **server-issued bearer token, stored hashed** (`API-39`, reversed
2026-08-13 from a caller-supplied-key scheme after a wire-contract panel found the signing
protocol guarded a non-extractable balance at outsized interop cost). A leaked table of token
hashes discloses nothing usable.

## How much to trust this

Every requirement here wears the same costume — a MUST, a stable identifier, a conformance
item. **The confidence behind them is not uniform, and the formatting hides that.** Read this
before treating a checklist tick as assurance.

- **Nothing here has been validated against a running implementation.** The set was extracted
  from code that never compiled and never ran.
- **Provider facts carry explicit markers** — `[design]`, `[observed]`, `[verify]` — in
  `08-provider-notes.md`. Treat `[verify]` as unverified, because it is.
- **Requirements are reversed in place when they turn out wrong, and the reversals are recorded**
  where they happened rather than tidied away: `DOM-1a`, `PRV-13c` and `OVR-10` were the first three; there have been many since, and the
  amendment markers in place are the record.

That last point cuts the opposite way to how it reads. Recorded corrections mark where a review
happened to collide with the text — they are not evidence that errors get caught. **The honest
inference is the base rate:** three load-bearing reversals across roughly a dozen edits means
the unmarked text plausibly carries similar error density, unmarked.

**The least-reviewed documents are identifiable.** `03-operation-lifecycle.md`,
`06-rescue-install.md` and `09-known-defects.md` were written before four separate changes to the
product model and have not been re-read against the final one. `03` is also the document this
README calls the heart of the design. Weight accordingly.

**A green conformance checklist certifies the requirements that are written down.** It says
nothing about what is missing. The three inventions this paragraph used to list — a wire format,
an adopt operation, the resolution path out of `needs_reconciliation` — now exist
(`13-wire-contract.md`, `PRV-28`, `OPS-27`–`OPS-38`), which does not retire the warning: what is
missing is, by construction, whatever nobody has noticed yet, and `F24` records how that went
last time.

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
| `LDG-n` | Billing and the ledger |
| `WIR-n` | Wire contract |
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
