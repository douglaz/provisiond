**Verdict: amend.** Keep the first group in the order account → offer → channel, and keep skipping the cap and balance checks. Name (A)'s kind and fix the consequences below.

**Why.** Both placements are already settled. ADR-0039 owes "The purchase tail refuses an unsellable offer" (`docs/adr/0039…md:73`), and ADR-0036 owes "`API-7`'s tail" (`docs/adr/0036…md:72`).

The order changes three things a caller sees: the HTTP status, the top-level `kind`, and whether a `Retry-After` leads the response. Envelope `retryable` does not change, because `WIR-9b` makes it "true iff every refusal entry's `retryable` is true". "Which headline helps an agent act" can't be the rule, since ADR-0030 rejected "non-retryable-first ordering … which makes the headline depend on a different fault than the resource the caller named". Containment works instead: the caller names the account and then the offer, the channel comes from the offer, and the pool comes last. That gives your order, and it keeps the permanent offer refusal above a 429.

`API-50` ("`rate_limited` for everything else") allows (B) even on a well-paced caller's first create, and `CNF-152` only tests polls. The cost is that only the size of `retry_after_ms` separates "channel closed for hours, try another account" from ordinary throttling.

The skip follows the one principle `API-7` already has: price checks run only where a price is served, which is why it quotes `WIR-30`'s 404. An unsellable offer has no served price. A closed channel still has one, so the balance check runs and its result stays useful while the caller waits.

**Cases** (rate available unless stated; `cap?` only when the request supplies a cap)

| Case | `refusals` | Headline | Top pacing | Envelope | `not_checked` |
|---|---|---|---|---|---|
| unhealthy + unsellable | account, offer | 409 `conflict`/`state` | none | false | cap?, balance × {account, offer} |
| unsellable + closed channel | offer, channel | 400 (defect 1) | none; the channel entry keeps its own | false | cap?, balance × offer |
| healthy, sellable, closed + short balance | channel, balance | 429 `rate_limited` | the channel's | false | `[]` |
| unsellable + no rate | offer, `rate_unavailable` | 400 | none | false | cap?, balance × {offer, rate} |
| standard offer, only auction closed | none: the gate is per "account and channel" (`PRV-40` still says "two order endpoints", `02-provider-contract.md:952`) | admitted | — | — | — |

Keep the channel entry beside an unsellable offer, because it applies to every other offer on that channel. Cap and balance entries there would price an offer nobody can buy.

**Defects**

1. **(A) has no kind.** Neither ADR-0039 nor `CNF-166` (`10-conformance-checklist.md:2958`, "refused before any provider call") names one, so item 1 can't be answered as framed.
   - I recommend `invalid_request` 400 with `retryable: false`, plus a `details` key that identifies the cause.
   - Sellability is fixed by a deployment's configuration and changes only between releases. `WIR-30` already rejects an install whose strategy the offer doesn't list as `invalid_request` (`13-wire-contract.md:989-991`).
2. **(A) is not new.** `PRV-31` (`02-provider-contract.md:429-431`), `LDG-32` (`12-billing-and-ledger.md:327-328`) and `RSC-45`/`CNF-287` (`10-conformance-checklist.md:1449`) each already refuse a create with no kind and no position in the tail. They can route to (A) later.
   - Caveat: `PRV-31`'s bound "MAY be reported on the offer instead" (`02-provider-contract.md:81`). For an unhealthy account the listing 404s, so that bound can't be evaluated, and `not_checked`'s closed `check` set has no way to report it.
   - So fold in only causes that can be decided from the descriptor, such as ADR-0039's traffic bound (`PRV-44`).
3. **Item 3's premise does not hold.**
   - `WIR-30` does not filter unsellable offers yet (`13-wire-contract.md:962-981`).
   - A whitespace-normalised search found no requirement that refuses a create naming an unlisted offer. That is a separate gap; give it the same kind.
   - `WIR-29` holds that "omission from the listing is not by itself the control" (`:944-946`).
   - It can't go at step 5 either, because step 5 runs before 5a (`04-api-contract.md:208-211`). A release that made an already-sold offer unsellable would turn a replay's stored `202` into a 400.
4. **Pacing sentence is too narrow.** "a subordinate halted entry MUST NOT supply pacing" (`04-api-contract.md:277-278`) covers only `halted`. Change it to "a subordinate entry".
5. **Ranks need splitting.** "the request's own resource refusal" is singular (`04-api-contract.md:264`), and `TailRefusal.rank` gives account and fence the same rank, 0 (`Admission.lean:1064`). Three create refusals can now occur together, so each needs its own rank.
6. **`OPS-11` must list the refusal, not the kind.** Its admission-only kinds "MUST NOT be emitted by a worker or a driver" (`03-operation-lifecycle.md:234`), but `rate_limited` means "Caller or provider throttled" (`01-domain-model.md:565`), and drivers emit it.
7. **`CNF-283` describes the wrong shape.** It asserts the create is "classified `failed`" (`10-conformance-checklist.md:1425`). A refused tail "MUST commit nothing", so no operation exists to classify.
8. **Omitted guard.** ADR-0036's "At most one create is in flight per offer" (`docs/adr/0036…md:43`) can't be a read of the snapshot, because the tail runs "without an extra lock". It belongs with "the conditional-write guards in `API-63` and `LDG-62`" (`04-api-contract.md:280-281`).

**Smaller shape / don't build.** Build one generic "not sellable on prepaid terms" refusal with one `not_checked` reason, `offer_not_sellable`, rather than an entry specific to traffic. Don't move (B) ahead of the tail: a sixth pipeline kind breaks `refusals_are_within_the_five_kinds` (`Admission.lean:765`).

**Edits**

- `API-7`: the first group, the skip sentence and the pacing sentence.
- `WIR-9a`: add the reason to the `because` set, ordered account, offer, rate. Add retryability rows (offer `false`, channel `true`) and the `invalid_request` key.
- `WIR-30`/`DOM-9`, `PRV-40`, `OPS-11`.
- `CNF-307` (the table's cases), `CNF-283`, and the conformance item ADR-0039 owes.

**Lean**

- `TailRefusal` gains `offerNotSellable` and `orderChannelClosed`; `UncheckedReason` gains `unsellable`.
- `purchaseTail` and `tailAdmitted` gain `sellable` and `channelOpen` inputs, with `priced := rate && (!create || (healthy && sellable))`.
- `rank` runs 0–6, and `retryable` gets values for the two new refusals.
- The five tail theorems take the new inputs, and `unpriced_checks_are_skipped` gets a new hypothesis. `Witnesses.lean:3598` calls `purchaseTail` positionally, so it changes too.

I tried this in a scratch copy; the diff is at `/tmp/r28scripts/prototype.diff`. The formal gate passes, including new witnesses for account + offer + channel and for channel + balance. It passes only after raising `maxHeartbeats` on four theorems, because their case splits grow to 2048. The tracked tree is untouched, and the baseline `tools/check-all.sh` passed.
