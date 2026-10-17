# Panel brief: triage of bead pv-14b (complete `OPS-43`'s claim order), 2026-10-16

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `cdc6adf` (branch `pv-14b-triage`: master `3acb2ef` plus one
bead comment). Read `AGENTS.md` first. `br show pv-14b` prints the bead and its two comments. Do not edit
tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`). This is a text
question; you need not run the gates (green at `3acb2ef`). Never call a provider API. This owner often shows
my framing wrong with a first-principles question; check this framing too, and verify every fact below
before relying on it.

## Settled and off-limits

- `pv-hsm`'s five-step claim order and sale re-test in `OPS-43` (03:671-695; panel r54, 4-0).
- `DOM-9`'s sale filter governs the customer listing only; the driver's List offers carries unsellable offers
  (`PRV-13c`, 02:575). This was the PR #5 ruling on a codex finding.
- `CNF-241`'s claim-time cases: "Assert no provider mutation: no per-order key upload and no order request;
  the List offers read is permitted" (10:2582-2583).
- Other beads own what makes an offer sellable (`pv-nd6`, `pv-2s6`) and how a failed List offers read
  classifies (`pv-qga`). Don't decide them; question 4 asks only about dependency.

## The bead

The bead names three gaps:

1. `API-63`'s claim-time account re-check has no place in `OPS-43`'s order.
2. Neither do `OPS-23`'s missing-field failure or `PRV-47`'s driver validation.
3. An offer absent from the step-2 List offers result has no outcome.

The bead asks to place each check, give the absent offer an outcome, and then align `CNF-278` and `CNF-342`.

## Facts I rely on (verify each)

1. `OPS-43` (03:679-688) orders the claim: closure read, List offers, re-test, price, then "any per-order key
   upload or other provider mutation". For an absent offer (03:693-695), it bars every step-5 mutation, but it
   names no kind, no `OPS-11` class and no release. The failure paragraph (03:697-711) opens "If the re-test
   finds the offer unsellable".
2. `API-63` (04:1407-1418) runs its check "in the transaction that records the attempt's correlator entry
   (`OPS-35`, `PRV-26`) — the last write before the ordering call". On failure it fails "releasing its
   commitment, with no provider mutation". Its rule for a termination: "a claimed attempt with no entry has
   not passed the check and will fail at it, and one with an entry MUST be treated as potentially dispatched".
3. `CNF-278`'s fourth barrier (10:2348-2350) reads "claim a create, commit the termination before its
   correlator entry is written, and assert it fails `account_terminated` with no provider call". Step 2 is a
   provider call.
4. `PRV-47` (02:157-160) says "reject invalid values without sending that order request" and is silent on
   the key upload. `PRV-10` (02:153-155) is another create check. `CNF-342` (10:3529-3537) asserts only that
   the driver "sends no order request". `PRV-9` (02:151): a surviving key "blocks the caller's next same-key
   create".
5. `OPS-23` (03:1673-1676) calls a missing field "a deterministic failure in the worker" and names no kind;
   neither does `ADR-0024`:125-126. `OPS-11` (03:262-263) makes `internal` ambiguous, and its create row
   (03:232) maps that to `needs_reconciliation`.
6. `PRV-40` (02:1185-1193) has the closure read at claim "before any provider request, including a per-order
   key upload". It is a plain read (`ADR-0036`:94-99).
7. At admission, `API-7`'s tail (04:264-267) puts the account refusal before `offer_not_sellable`. `DOM-9`
   (01:189-192): "a remembered ID still meets `API-7`'s create tail". **I found no rule for a create naming an
   offer absent from the driver's List offers at admission.** Check.
8. Q17c (`ADR-0036`:100-104): the resource-offer guard's loser gets `409 conflict`/`state`, `retryable:
   false`, because "the offer leaves the listing".
9. 13:165: `offer_not_sellable` is `retryable: false`, "The offer cannot be bought on the same request".

## My reading (attack it)

Category `bug`. Two conformant engines give different outcomes, and `CNF-278` fails a conformant engine.

- **Account check.** "with no provider mutation" forces `API-63`'s transaction before step 5. I lean to
  placing it after step 4, so the correlator entry stays "the last write before the ordering call". Then an
  unsellable offer or `price_moved` beats an unhealthy account. `CNF-278` must say "no provider mutation",
  as `CNF-241` does. Option: also a plain account read at step 1, like `PRV-40`'s closure read. An account
  already recorded unreachable or credentials-rejected would then fail before step 2's read, which is
  `pv-qga`'s case.
- **Field checks.** Place `OPS-23`'s and `PRV-47`'s checks before step 5, plus one rule: the first failing
  step settles the operation.
- **Absent offer.** The same failure as an unsellable offer: `invalid_request`/`offer_not_sellable`, `failed`,
  released under `LDG-39`. The alternatives are `not_found`, or `conflict`/`state` on Q17c's model. Note that
  an auction offer that left the feed is gone, while a catalogue offer may return.

## What I need from you

1. **What the text already forces**, quoted, for each gap. Also name any claim-time check still missing from
   the order (`PRV-10`?).
2. **Picks for the rest:**
   - (a) where the account check goes: after step 4, before step 2, or with a step-1 plain read added;
   - (b) where `OPS-23` and `PRV-47` go, and whether `OPS-23` needs a named kind;
   - (c) the precedence rule.
3. **The absent offer:**
   - its kind, `details.reason`, `retryable`, `OPS-11` class and release;
   - whether admission is equally silent, and so whether the rule's home is `API-7` or `OPS-43`.
4. **Dependencies:** should `pv-qga` depend on pv-14b, be decided together with it, or be merged into it?
   One sentence on whether `pv-nd6` and `pv-2s6` are independent.
5. **Draft edits** for `CNF-278`'s fourth barrier and for `CNF-342`, one to three sentences each.
6. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   picks. It is not your position.

Under 700 words. Cite `file:line` or identifiers for every claim.
