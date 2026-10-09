# Panel r28 synthesis — two new create refusals in the purchase tail (2026-10-08)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 023ed3f. All exit 0.

## Agreed (4–0)

- Order: account not healthy → offer not sellable → order channel closed, then solvency, rate, cap,
  balance. ADR-0030's own rule decides it ("the resource before the pool, then pricing and spending"):
  the caller names the account and the offer; the channel comes from the offer and is shared by every
  tenant (fable calls it the first pool entry; same wire result). "Which headline helps an agent" is not
  the rule — ADR-0030 rejected non-retryable-first ordering; envelope `retryable` is WIR-9b's
  conjunction whatever the headline.
- (B) is a tail refusal, not a pre-tail stage: it reads a stored "closed until" fact and spends nothing;
  a pre-tail stop would hide the other refusals ADR-0030 exists to report.
- The channel gate is per account AND channel: a closed auction channel does not refuse a standard offer.
- A remembered unsellable offer is refused by its own reason, not `not_found`: "omission from the listing
  is not by itself the control" (WIR-29).
- `API-50` needs a sentence: another tenant can close the shared provider channel before a well-paced
  caller gets any hint, so the channel refusal joins the 429s that may arrive on a first request.

## Split 2–2 (owner)

1. Skip cap/balance for an unsellable offer?
   - Skip (fable, opus): API-7 already runs price checks only where a price is served (it quotes
     WIR-30's 404 for an unhealthy account); an unsellable offer is filtered from the listing, so its
     price is not served. Needs one new `not_checked` reason `offer_not_sellable`.
   - Run them (sol, astra): the price is computable; skipping hides a cap or balance problem and needs a
     new reason. CNF-307 already runs cap/balance on a fenced extension.
2. Kind for "offer not sellable":
   - `409 conflict` + `details.reason: offer_not_sellable` (sol, fable): like the account's state.
   - `400 invalid_request` + a `details` key (astra, opus): sellability is deployment configuration;
     precedent WIR-30 rejects an install strategy the offer does not list as `invalid_request`.

## Found beyond the question (verified where cited)

- ADR-0036's "joins `OPS-11`'s admission-only list" cannot hold for the kind: that list's kinds "MUST NOT
  be emitted by a worker or a driver", and drivers emit `rate_limited`. Record the occurrence, not the
  kind (fable, opus).
- `PRV-31` already refuses an offer with no declared bound before any provider call (CNF-166) with no kind
  and no tail position — the new refusal gives it one (fable, opus; opus: only descriptor-decidable
  causes).
- `API-7`'s pacing sentence covers only "a subordinate halted entry" → "a subordinate entry" (opus).
- `TailRefusal.rank` gives account and fence the same rank; three create refusals can now co-occur →
  distinct ranks 0–6 (opus, astra). Opus prototyped it: the gate passes after raising maxHeartbeats on
  four theorems.
- `CNF-283` asserts the create is "classified `failed`", but a refused tail "MUST commit nothing" (opus).
- ADR-0036's "at most one create in flight per offer" cannot be a snapshot read under the tail's no-lock
  rule; it belongs with API-63/LDG-62's conditional-write guards (opus).
- `DOM-20`'s "clears in milliseconds under the deployment's own control" is false for the provider-shared
  throttle (astra).

## Edits (union)

API-7 (first group, skip sentence, pacing sentence), WIR-9a (reason set and order, retryability rows,
the offer key), WIR-30/DOM-9, PRV-31, PRV-40/PRV-44, OPS-11 (occurrence, not kind), API-50, DOM-20,
ADR-0030 dated note, ADR-0036 dated correction; CNF-307, CNF-283, CNF-166, CNF-152, CNF-31b. Lean
`Provisiond.Admission`: `TailRefusal` + `offerNotSellable`, `orderChannelClosed`; `UncheckedReason` +
`unsellable` (if skip); `purchaseTail`/`tailAdmitted` new inputs; `rank` 0–6; `retryable`; the five tail
theorems; `Witnesses.lean` positional call.
