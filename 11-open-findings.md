# 11 — Open findings

An independent structural audit read all twelve documents end to end on 2026-08-09 and
returned **21 findings, 5 of them critical**, with the verdict:

> **NO.** A competent engineer could not build this without asking the author questions.

A separate usability audit reached the same conclusion by a different route: the `core`,
`providers` and `rescue` documents are buildable on day one; every stall is in the API and
persistence surface.

This file tracks all of it. Items marked **FIXED** were resolved on 2026-08-09; the rest are
open and inherited by whoever picks this up.

## The three questions a builder must ask first

Answer these before writing code. Everything else is detail.

1. **Which deployment form and tenant model is authoritative** — `OVR-10`'s separation form and
   `DOM-1a`'s registry branch — and where do customer credentials and per-tenant ceilings live?
2. **How is `needs_reconciliation` resolved without replaying the mutation**, including adopting
   a resource discovered after an ambiguous create, and repairing a terminal state?
3. **What is the complete deletion and billing contract** — attachment cleanup surface,
   cancellation fields and transitions, reserve calculation, and the point at which a machine
   may truthfully be called `deleted`?

## Critical — open

**F1. `needs_reconciliation` has no resolution path.** The only operator verb is requeue
(`API-19`), which replays the original mutation — a second purchase for a create, a second
disk write for an install. There is no way to record "the provider acted," attach a discovered
machine, or close the operation as resolved. Yet `OPS-25` retains these records "until an
operator resolves them," and `OPS-11` makes this the *default* outcome for a failed install.
The specification's self-declared most important property has no exit.
*Both auditors independently named this the highest-value remaining edit. Write it from the
transcript of a real ambiguous outcome, not from imagination.*

**F2. The registry branch of `DOM-1a` is not buildable.** It requires runtime tenant creation,
suspension, deletion and credential rotation. `API-4` requires every token to come from the
environment at startup, and neither the API nor the persistence document provides a tenant
lifecycle or a credential store. The two contracts cannot both describe a self-serve
deployment. **Consequence: the self-serve product this spec was extracted for cannot be
specified by it yet.**

**F5. Deletion semantics are incomplete.** `STO-8` tombstones once the machine is gone;
`PRV-13a` calls reporting deletion false whenever attachments still bill. There is no state for
"machine gone, attachments still billing," no attachment model, no cleanup operation, and no
schema columns for effective cancellation date, earliest-cancellation constraint, or
machine-specific reserve. `DOM-19` and `STO-8a` describe behaviour the schema cannot store.

## Critical — fixed 2026-08-09

**F3. Operations had no tenancy rule.** `API-17` covered only machine-scoped endpoints, so
`/v1/operations` and `/v1/operations/{id}` could expose another tenant's operation, provider
account, result and error. Pagination was specified; isolation was not. → **`API-17a`.**

**F4. Any tenant could create against any provider account.** Create is the only verb with no
target to authorize against, and neither account assignment nor spending authority existed.
`allow_orders` plus an acknowledgement prevents accidents, not unauthorized spending — which
directly contradicted `DOM-3`. → **`API-17b`.**

## High — open

**F6. Password-only rescue is impossible under the declared interface.** Begin-rescue always
receives an ephemeral public key, and `PRV-17` forbids accepting-then-ignoring it. No
alternative access-request variant exists, so a password-rescue provider cannot conform.

**F8. Idempotency has no retention boundary.** `API-11` promises the existing operation for a
reused key indefinitely; `STO-14` retention deletes it. After deletion the same key performs
the mutation again — a duplicate purchase, by design.

**F9. Mandatory data is absent from the normative schema:** cancellation date, correlation id
(`API-28`), requeue reason and preserved previous error. `operation_requeues` holds only
operation id, key and timestamp, so it cannot satisfy `OPS-19`.

**F10. The capability model has dead branches.** `remote_console` has no operation and console
proxying is a non-goal; `attach_iso` gates an install pairing with no provider operation behind
it; list-offers has no capability at all, contradicting `OVR-2`; and `adopt_existing` is
declared and exposed by the API while the provider contract has no adopt operation.

**F13. The single-process credential boundary is not proven by its own tests.** Provider
secrets originate in the process environment, which customer-facing code can read without ever
referencing the private credential type. `CNF-71`/`CNF-72` prove *type visibility*, not
inability to call environment APIs or inspect shared process state. `SEC-40` is also wrong:
`API-4`/`API-5`, `API-10` and `API-29` already provide per-principal state without a registry.

**F15. Global uniqueness of an external machine is required but not enforceable.** `SEC-10` and
`CNF-6` require it across tenants; the only specified constraint includes `tenant_id` and
therefore permits duplicates. No assignment table or atomic guard is specified.

**F17. Tier assignments change under honest application of the rule.** `CNF-65` is BLOCKING —
autonomous deletion can leave unbounded billable attachments. `CNF-58` is BLOCKING if an
unknown stored state can become `queued` and repeat a mutation. `CNF-66`–`CNF-68` are BLOCKING
in the separate-service form, and `CNF-71`–`CNF-74` apply only in the single-component form —
so **neither family can be tiered until `OVR-10`'s form is chosen.**

## High — fixed 2026-08-09

**F7. Install failure classification was neither total nor consistent.** `authentication` and
`rate_limited` were absent from both install outcomes, and `PRV-22` appeared to contradict the
install row. → `OPS-11` table made total, the `PRV-22` interaction stated explicitly, `CNF-31`
split into `CNF-31a` (misclassification causes a repeated mutation) and `CNF-31b` (totality).

**F11. "Every non-`GET` endpoint MUST return `202`"** contradicted mandatory `400`, `401`,
`409`. → `API-1` now says every *accepted, valid* write.

**F14. `API-30` contradicted itself** — registry deployments "MAY treat the options as
advisory," then an unconditional "MUST do one." → rewritten, and it now states what a registry
does *not* buy: it proves an override names an existing tenant, never that it names the
*right* one.

**F16. Tier arithmetic was wrong.** `CNF-31` appeared in two tiers; the blocking list held 50
items while the prose said "roughly 44"; `CNF-62` was DEFERRED while the area sort called its
parent PRE-SCALE; `CNF-60` was PRE-SCALE while `API-21` was DEFERRED. → all corrected.

**F21. Stale citations after the day's edits.** `OPS-13` cited `RSC-17` instead of `RSC-19`;
`API-30`, `CNF-67` and `SEC-40` still said "amend `DOM-1`" after `DOM-1a` superseded it; the
README claimed no provider fact was web-verified while `08` carries a dated verified claim.
→ all corrected.

## Medium — open

**F12. Digest policy conflicts.** `DOM-14` requires digests for rootfs and raw disk only; ISO's
is explicitly optional and iPXE has none. `SEC-16` requires one for "every custom image."

**F18. Several MUSTs are untestable as written:** "measured worst-case delay," "materially in
the future" (`PRV-13c`), ceilings "per interval" (`SEC-39`), "enforce what it can" (`SEC-42`),
"a sane range" (`API-26`), "controlled, immutable storage" (`RSC-30`). No units, thresholds,
measurement procedure or pass/fail boundary. `PRV-13b`'s formula also leaves ambiguous whether
the FX haircut multiplies the whole reserve or only part of it.

**F19. The wire contract does not exist.** In ~2,600 lines there is exactly one JSON example —
the error envelope. No request or response body for any endpoint. The idempotency header is
required by `API-8` and never named; likewise the tenant-override header and the destructive
and purchase acknowledgement fields. `CNF-21` tests "byte-equivalent body" against a contract
nobody wrote, so every implementer invents one and the checklist blesses it. `API-13` also
omits `PRV-8`'s minimum-one-key create rule. **Two competent implementations will not
interoperate.**

**F20. Durable queueing conflicts with short-lived signed image URLs.** `OPS-2` persists the
request; `SEC-21` wants short URL lifetimes. A URL can expire between enqueue, restart,
deferral and execution, and there is no refresh or caller-replacement mechanism.

## How to read the fixed/open split

Do not infer that the fixed items were the important ones. They were the *cheap* ones —
self-contradictions and stale references introduced by a day of heavy editing, plus two security
holes clear enough to close without a product decision. **Every remaining open item needs either
a decision from the operator or evidence from a real transaction.** That is the honest state,
and it is why this file exists rather than a claim that the audit was addressed.
