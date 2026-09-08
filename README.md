# provisiond — specification set

A language-neutral specification for a multi-provider control plane that provisions,
adopts, rebuilds, reimages, powers, and deletes VPS and dedicated (bare-metal) machines.

This directory contains **specifications only**, with one carve-out: `tools/` holds the
gates that check the specifications, and `.github/workflows/` runs them. Nothing that
implements the specified system belongs here, and none should be added. *The carve-out was
made on 2026-08-31 for a concrete reason: the gates had always lived in a scratch directory,
that directory was cleaned by age, and they ceased to exist without anyone noticing. A check
that guards this set has to outlive the machine that last ran it.* The specs were extracted
from a Rust reference implementation that was reviewed and found to be unbuilt, untested,
and holed in two of its load-bearing safety claims. The *architecture* of that implementation is
worth keeping; the *code* is not. Everything the code got right is written down here as a
requirement, and everything it got wrong is written down in `09-known-defects.md` as a requirement
not to repeat it.

## Gates

`bash tools/check-all.sh` runs all six, and CI runs the same script on every push:

| Gate | What it refuses |
|---|---|
| `tools/check_ids.py` | A duplicate identifier, a citation to an id nothing defines, a gap in a namespace's sequence, an id far above its neighbours, a reference to an ADR that does not exist |
| `tools/check_fixtures.py` | A JSON example that does not parse, carries a `...` placeholder, repeats an object member, exceeds `WIR-1a`'s integer bound, spells a timestamp `+00:00`, or carries a malformed digest. Also structurally checks every Mermaid diagram, since one that is broken looks fine in source and fails in the browser |
| `tools/check_obligations.py` | A duty assigned to another requirement's subject — "`LDG-62` MUST write `destroy_committed`" — where that requirement's own text names none of the machinery. *`OPS-42` did exactly this to `LDG-62` and the fence protecting a paying customer's machine silently did not exist. Two full-set cross-model reviews read past it; the other gates all passed, because the citation resolved and both requirements had conformance items. Only the relationship was broken.* Run `--selftest` in a full clone to watch it catch that commit |
| `tools/check_coverage.py` | A fall in the number of requirements exercised by at least one conformance item, against a recorded baseline. *It overstated coverage by eight points on its first day — it attributed prose in the tier-assignment sections to whichever item preceded it. Fixed 2026-09-01; a gate that overstates is worse than no gate, because the ratchet then guards a number nobody earned.* |
| `tools/check_arithmetic.py` | A numeric claim the documents make that their own formulas do not support. It **executes** `LDG-33`'s runway derivation and `LDG-38`'s rounding-credit recurrence rather than reading them, and asserts the properties each requirement claims — that `OPS-41`'s abort predicate reaches a terminal state on every machine the sweep routes, that the rounding credit stays in `[0,1)`, that it posts identically to the withdrawn cumulative form, and that corrupting it in range costs at most one satoshi. *`OPS-41`'s predicate flipped twice across three cross-model reviews before a ten-line evaluation exhibited the counterexample: one usable satoshi at two satoshis per second. Reading could not settle it; running it did in seconds. Its own first draft derived both sides of that comparison from one variable and was a tautology that could never fail, which is why CI swaps the withdrawn predicate back in and requires the gate to reject it.* |

The workflow also breaks a document deliberately on every run and asserts the identifier
gate rejects it. `DEF-16` is why: the discarded implementation shipped CI that ran a suite
containing zero tests, and a green check beside it.

## How to read this

| Document | Contents |
|---|---|
| `executive-summary.md` | **Start here if you are new.** One self-contained orientation to the whole set — what it is, the decisions everything follows from, why the money model is the security model, what is genuinely hard, and what has and has not been validated |
| `00-overview.md` | Problem statement, design goals, system context, non-goals |
| `01-domain-model.md` | Entities, machine states, the capability model |
| `02-provider-contract.md` | The provider driver interface, operation by operation |
| `03-operation-lifecycle.md` | Async operation queue, claiming, the episode, the reconciliation state machine |
| `04-api-contract.md` | REST surface, authentication, tenancy, idempotency, error envelope |
| `05-persistence.md` | Storage requirements and schema specification |
| `06-rescue-install.md` | Rescue-mode workflow, host-key pinning, image installers |
| `07-security-requirements.md` | Normative security requirements |
| `08-provider-notes.md` | Per-provider API facts worth preserving, and their caveats |
| `09-known-defects.md` | Defects found in the reference implementation, as prohibitions |
| `10-conformance-checklist.md` | What a reimplementation must demonstrate before it serves traffic |
| `11-open-findings.md` | **Read this before building.** Findings `F1`–`F45` accumulated over several successive audits, which are fixed and which are open, and the three questions a builder must ask first — all three now answered. `F37` is the first closed by measuring a live provider rather than by reading one; `F36` is the first closed by deleting the mechanism that produced it (`ADR-0014`) |
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
| `0011` | Commitments are fixed at open and never auto-widen — save for the scheduled-cancellation branch, the one automatic exception (`LDG-63`); a price move shifts the runway date instead. Closes `F27`; amends `ADR-0003`'s matching claim |
| `0012` | Abuse handling is the operator's in both directions: the provider's notice, case reference and one-shot statement link never reach a tenant, and a tenant's statement reaches the provider only through the operator. Closes `F34` |
| `0013` | Catalogue install is a second feature, not a second strategy: DigitalOcean has no rescue API, but imports custom images, so bring-your-own-OS exists on both companies by different means and with different promises. Closes `F32` |
| `0014` | A create cannot be requeued: the operator cannot re-place the customer's order and `ADR-0002` leaves nobody to ask for it. Closes `F36` by deleting the mechanism that produced it; opens `F38` and `F39` |
| `0015` | PostgreSQL is the store. The single-writer engine's single point of failure is an outage of every mechanism that stops a machine billing, and `LDG-35`'s "MUST state which" had been met by accident for as long as it stood |
| `0016` | The engine is one supervised process fenced by a per-lifetime epoch; `api` alone is replicable. The leases, the heartbeat, the sweep cadence and the machine lock are deleted rather than fenced, and the restart window is the accepted outage. Amends `0015` |
| `0017` | A cancellation episode is an entity with its own states; `failed` is a fact about one attempt, and "known but not done" belongs to the episode. Requeue, reduced to one kind by `0014`, is deleted — that kind's recovery is an operator `retry` on the episode |
| `0018` | A driver's declarations are one typed, immutable descriptor, and a measured window is the larger of the declared bound and the largest observed sample, held in the store. Attachments get list and release methods under `delete_machine` |

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

**The least-reviewed document is identifiable.** `09-known-defects.md` was written before four
separate changes to the product model and has not been re-read against the final one. Weight
accordingly. `03-operation-lifecycle.md` and `06-rescue-install.md` were once in this sentence and
are not any more: `03` has been rewritten repeatedly under review since, and `06` was rewritten on
2026-08-13 (`RSC-26`, `RSC-38`). Both carry their amendment records inline, which is the evidence
to read — not this paragraph.

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

### Identifiers are append-only. Text is not.

**AMENDED 2026-08-31.** The rule was doing two jobs and only one was paying for itself.

**Identifiers, absolutely.** An identifier is never reused and never renumbered. This costs nothing
— zero bytes — and it is what makes a citation durable across seventeen documents, commit messages
and future tests. `SEC-46` is cited from six places and `LDG-33` from eight; renumbering silently
repoints every one of them, and a wrong citation in this set is how `SEC-46` shipped an amendment
claiming to have applied while the requirement said the opposite.

**Text, only where a trap sits behind it.** Withdrawn wording is retained when deleting it would let
someone re-lay a trap — something that looked correct, was nearly built, and broke. `PRV-30`'s
`comment` field, `LDG-8`'s posting index, `OPS-36`'s automatic seizure and `PRV-13e`'s three failed
versions are all of that kind, and they stay. Withdrawn wording that merely records a fact that
changed is **deleted outright** — no marker, no tombstone paragraph. Nobody re-adds five reserve
columns by accident.

**Deleting the text is not reusing the number.** The gap in the sequence *is* the tombstone. A
deleted identifier goes in the index below so an old citation still resolves, and `tools/check_ids.py`
reads that index — an id may be absent from the documents only if it is listed here.

*The measurement behind the change: 61 of 719 requirements carried an amendment record and 199 lines
carried a marker, about 2% of the set. Retention was never what made this large; 719 requirements
did. But its value is wildly uneven, and the test above is what separates the halves.*

### A decision gets its identifier when it is accepted, not when it is written

**Added 2026-08-31, from a defect this convention would have caught.** A review session accepted
forty-seven changes. Forty-six were phrased against an identifier — "amend `LDG-38`", "add
`OPS-42`" — and one was phrased as "record this in `07-security-requirements.md`". That one was
never written, and it was the only one that could not be. Checking the other forty-six was a `grep`;
checking the last one required remembering it existed.

So: **when a decision is accepted, name the identifier that will carry it** — the requirement it
amends, or the next free number in the right namespace if it needs a new one. Mint the number at
acceptance. An accepted decision with no identifier has nothing to search for, and the gates cannot
help: nothing dangles, because nothing points at it.

This costs one line at decision time and turns "did we apply everything?" into a command.

### Withdrawn identifiers

Deleted from the documents. Never reused. Listed so an older citation still resolves.

| Identifier | Was | Why it went |
|---|---|---|
| `DOM-12` | A round-trip rule for the rescue-session type | Folded into `DOM-11`, which forbids persisting one at all. `DEF-9` keeps the defect it came from |
| `API-30` | The front service's tenant-override rule | `ADR-0001` chose one deployable; the header it governed does not exist |
| `API-31` | The front service's own audit log | Same shape, same reason. `SEC-32` already names the identity and tenant |
| `PRV-24` | The driver's iPXE shebang check | Swept with the rest of the iPXE surface — `DOM-22` deferred the capability from v1 and no launch driver declares it |
| `SEC-40` | Where per-principal ceilings live | `SEC-39` carries the whole obligation unconditionally |
| `SEC-25` | "Installs and deletions MUST carry a per-request destructive acknowledgement" | A word-for-word restatement of `API-14`, adding no security obligation. Deleted 2026-09-02 under this document's own scope note; `SEC-39` is the requirement that says something about what an acknowledgement is worth against a caller that is a program |
| `SEC-26` | "Orders MUST carry a per-request purchase acknowledgement *and* an account-level opt-in" | Same, for `API-15` and `PRV-10` |
| `CNF-66` | The front service's chosen tenancy option, recorded | Conditional on a deployment shape `ADR-0001` deleted |
| `CNF-67` | The front service's per-tenant signing or allowlist test | Same |
| `CNF-68` | The front service's own audit log, joined by correlation id | Same |
| `CNF-75` | "Recorded which separation form it chose" | The form is a constant, so the item tested nothing |
| `CNF-204` | A duplicate of `CNF-193`'s middle clause | Duplicate |
| `CNF-205` | A duplicate of `CNF-198` | Duplicate; its one distinct assertion moved into `CNF-198` |
| `WIR-6` | The Ed25519 signed byte string | Reversed by `API-39`, which carries the argument in full — elaborate authentication guarding a non-extractable asset, at the cost of the most interop-fragile construct in the set |
| `WIR-7` | Clock-skew tolerance for the signature timestamp | Nothing is signed |
| `WIR-8` | Ed25519 key rotation | Superseded by `WIR-38`, authorized by the recovery credential |
| `OPS-7` | Lease renewal on a heartbeat | `ADR-0016`: one engine, one epoch; there is no lease to renew |
| `OPS-9` | Atomic machine-lock acquisition and takeover | `ADR-0016`: `OPS-8`'s at-most-one-running rule is a store index, and defer-on-refusal moved into `OPS-8` |
| `OPS-10` | Machine-lock lease renewed with the operation lease | `ADR-0016`: neither lease exists |
| `OPS-14` | The lease sweeper | `ADR-0016`: with one writer, `OPS-15`'s startup pass is the whole sweep |
| `OPS-17` | Sweep interval tied to lease duration | `ADR-0016`: no lease, no interval |
| `OPS-18` | Requeue restricted by kind | `ADR-0017`: requeue is deleted |
| `OPS-19` | Requeue audit trail | `ADR-0017`: the episode and `WIR-51`'s `reason` carry it |
| `OPS-20` | Requeue places a second order, reuses and re-prices the commitment | `ADR-0014` withdrew it for creates; `ADR-0017` deleted the verb |
| `OPS-34` | Requeue equivalence check | `ADR-0017`: nothing is requeued, so nothing is compared. `F38` holds the `target` history |
| `OPS-46` | The admissible requeue set | `ADR-0017`: reduced to one kind by `F39`, and that kind's recovery is `API-64`'s `retry` on the episode |
| `STO-2` | Conditional upsert for the machine lock | `ADR-0016`: `machine_locks` is deleted; `STO-51` is the index that replaces it |
| `STO-11` | `machine_locks` primary key | Same |
| `STO-20` | `operation_requeues` audit columns | `ADR-0017`: the table is deleted with the verb |
| `API-19` | Requeue is operator-only | `ADR-0017`: `API-64`'s `retry` carries the operator-only rule |
| `WIR-28` | `POST /v1/operations/{id}/actions/requeue` | `ADR-0017`: `WIR-51` is the episode surface. Its fixture carried an acknowledgement its own prose forbade — `F43` |
| `RSC-37` | The operation lease during a long install, renewed by heartbeat | `ADR-0016`: no lease; a long install simply holds the machine (`OPS-8`) |
| `SEC-28` | Requeue operator-only and re-purchase explicit | Both cited rules are deleted by `ADR-0017`; restating `API-64` here would be the second copy the scope note forbids |
| `CNF-28` | A worker whose lease is stolen mid-flight abandons its work | `ADR-0016`: `CNF-290`'s stale-epoch clause is the analogue |
| `CNF-48` | A 90-minute install does not lose its lease | `ADR-0016`: nothing to lose |
| `CNF-221` | The requeue equivalence test | `ADR-0017`: it tested `OPS-34` by name |
| `CNF-261` | Two operations racing `machine_locks` | `ADR-0016`: `CNF-290` and `CNF-27` assert `STO-51`'s index instead |

*Swept 2026-08-31. The `machines` table also lost five `reserve_*` columns in the same pass —
written by nothing, read by nothing, and left over from the `holds` model `LDG-30` replaced on
2026-08-12. Columns carry no identifier, so they are recorded here rather than listed above.*

## Language and runtime

Nothing in this specification assumes a particular language or HTTP framework, and
`02-provider-contract.md` "deliberately does not give a signature in any language."

**The database engine is no longer open**: it is PostgreSQL (`ADR-0015`, 2026-09-06).
That was always the one choice with architectural consequences — the reference
implementation used Rust, an async HTTP framework and SQLite, and only the last of
those reached the requirements. `05-persistence.md` still states what the store must
provide rather than how, so a reimplementation is free to satisfy `STO-1`–`STO-7`
another way; what it may not do is satisfy them on an engine that forbids a second
`api` replica. `api` is the module that scales; the engine is deliberately one
supervised process (`ADR-0016`), and its outage window is alarmed rather than
replicated away (`OVR-18`).

## Status

These documents describe a target system. No part of them has been validated against
a running implementation. Provider API details in `08-provider-notes.md` are marked
**per item**, each with a dated confidence note: some were read out of the reference
adapters and never checked, some have since been verified against current provider
documentation, and the DigitalOcean section came from neither — the reference set had
no such driver. Read the marker on the fact you are about to rely on, and verify
against current provider documentation before implementing an adapter.
