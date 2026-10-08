# Panel r27 synthesis — what a driver reports when it cannot tell acceptance (2026-10-08)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 4830cd0 (cf3c32a = pv-ucs.3's
unaccepted implementation). All exit 0. Brief: brief.md; the Manager's blocker: manager-blocker.md.

## Verdict: amend, 4–0 — keep the cause's kind; no `internal` override for a lost reply.

- The conflict is behavioural, not wording (all four): cf3c32a's `PRV-5` says both "transport failures to
  `network`" and "MUST report `internal`" for the same trace; a 5xx answer also collides with "non-2xx
  responses to `provider`" (opus). `internal` means "Defect in this system" (`DOM-17`), so a provider
  outage would point operators at provisiond's own code. Classification, `retryable` (always false on
  `needs_reconciliation`, `WIR-9b`), `OPS-27`/`OPS-31` resolution and `LDG-39` do not change.
- My narrowed rule covers almost nothing (opus, fable): a 4xx answer to the mutating request is a known
  rejection; every reply-less failure already has an ambiguous kind under `PRV-5`'s mapping. `internal`
  is left for the one case no mapping covers: an unreadable reply (and a 2xx whose body cannot be parsed,
  which is `accepted: true`).
- `ADR-0035` never said `null`; the tri-state and "MUST NOT substitute `false`" came from cf3c32a
  (fable, opus). The ADR change is an amendment (it changes the wire kind and `CNF-322`), not a wording
  note (opus, sol, astra).

## Split: keep `accepted: null`?

- Keep (opus, sol, astra): it distinguishes "nothing reached the provider" (`false`, e.g. connect/DNS
  failure before any byte) from "it may have" — `OPS-13` evidence for an operator. Opus: `OPS-11` must
  NOT read `null` (it would only ever agree with the kind rule); no Lean type change.
- Drop (fable): only `true` is ever read; `false` = "no success reply to the mutating request" is
  literally true on a reset; a provable `accepted_false_is_neutral` theorem replaces the fallback.
- Sol alone: a provably-pre-send `network` failure with `false` should settle `failed` — a behaviour
  change beyond the question (opus: that over-caution predates this change). Not taken.

## Converged rule (opus's wording, closest to the 3–1 majority)

`PRV-5`: "A driver that cannot determine acceptance MUST report `details.accepted: null` with the
mutating request's own failure mapped as above, `internal` only where no mapping applies; it MUST NOT
report a later request's failure in its place, omit the field or substitute `false`." Pre-send failure
is `false`; after acceptance "Known acceptance MUST remain `true` on every later error".

## Defects in my framing (verified)

1. "network/timeout with `accepted: null`" is wrong at both ends: before any byte it is `false`; after
   acceptance it stays `true` (cf3c32a `PRV-5`).
2. I left out the 5xx collision with "non-2xx responses to `provider`".
3. The unreadable-reply case was undecided under my rule.
4. "Clarification" understated it: this amends ADR-0035's Decision.

## Edits

`PRV-5` (the sentence above); `OPS-11` (re-quote); `ADR-0035` dated amendment; `CNF-322` (`null` with
the mutating request's own kind; add the 5xx and unreadable-reply cases); `CNF-31b` and `CNF-323`
("the `internal` fallback" → "unknown acceptance"); `CNF-31a` unchanged. Lean: the `Failure` docstring
and `rejected_order_witness`'s third conjunct only; `classify`, totality proofs and the ci.yml control
unchanged.
